// F002@v0.32 user-visible persistence behaviour: the weight card shows each
// record's own state, source and unit, never draws a missing value as a
// number (G-18), and storage reasons, notes and skipped entries are told in
// the user's language (G-14, G-23).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/ports/storage_status.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 't',
  sourceRevision: 't',
);

Future<void> pump(
  WidgetTester tester,
  LogRepository repo, {
  Locale? locale,
  StorageReason? reason,
  List<StorageNote> notes = const [],
  Future<void> Function(LogRepository repo, String selfId)? seed,
}) async {
  tester.view.physicalSize = const Size(1280, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final services = await tester.runAsync(() async {
    final report = await repo.open();
    final s = await servicesFor(
      dev,
      HostPlatform.linux,
      repo,
      reason: reason ?? StorageReason.saving,
      notes: notes,
      report: report,
    );
    if (seed != null) await seed(repo, s.self.id);
    return s;
  });
  await tester.pumpWidget(HumanOsApp(services: services!));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

HealthRecord weight(
  String id,
  String profileId, {
  required DateTime at,
  ValueStatus status = ValueStatus.present,
  Quantity? quantity,
  RecordState state = RecordState.observed,
  Provenance provenance = const Provenance.manual(),
  String? original,
}) => HealthRecord(
  id: id,
  profileId: profileId,
  kind: RecordKind.bodyWeight,
  state: state,
  valueStatus: status,
  quantity: quantity,
  originalText: original,
  provenance: provenance,
  observedAt: at,
  recordedAt: at,
);

void main() {
  testWidgets('a newer "not measured" entry is listed by name, never as a '
      'number, and Latest stays the newest real value (G-18)', (tester) async {
    await pump(
      tester,
      inMemoryRepository(),
      seed: (repo, me) async {
        await repo.appendRecord(
          weight(
            'w1',
            me,
            at: DateTime.utc(2026, 10, 1, 7),
            quantity: const Quantity(80.2, 'kg'),
            state: RecordState.reported,
            provenance: const Provenance(
              kind: ProvenanceKind.device,
              deviceId: 'scale',
            ),
          ),
        );
        await repo.appendRecord(
          weight(
            'w2',
            me,
            at: DateTime.utc(2026, 10, 2, 7),
            status: ValueStatus.notMeasured,
          ),
        );
      },
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('weight-latest'))).data,
      '80.2 kg',
    );
    final missingRow = find.byKey(const ValueKey('weight-row-w2'));
    expect(
      find.descendant(of: missingRow, matching: find.text('Not measured')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: missingRow, matching: find.textContaining('kg')),
      findsNothing,
    );
    final deviceRow = find.byKey(const ValueKey('weight-row-w1'));
    expect(
      find.descendant(
        of: deviceRow,
        matching: find.textContaining('Reported · Device'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('only "not measured" entries: no Latest number at all', (
    tester,
  ) async {
    await pump(
      tester,
      inMemoryRepository(),
      seed: (repo, me) => repo.appendRecord(
        weight(
          'w1',
          me,
          at: DateTime.utc(2026, 10, 2, 7),
          status: ValueStatus.notMeasured,
        ),
      ),
    );
    expect(find.byKey(const ValueKey('weight-latest')), findsNothing);
    expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
    expect(find.text('Not measured'), findsOneWidget);
  });

  testWidgets('skipped entries are reported in Turkish with line and rule', (
    tester,
  ) async {
    final sink = MemoryLogSink();
    final seeded = LogRepository(
      sink: sink,
      durability: StorageDurability.localFile,
      location: 'test',
    );
    await tester.runAsync(() async {
      await seeded.open();
      final me = await HeartbeatProbe.self(seeded);
      final bad = weight(
        'bad',
        me,
        at: DateTime.utc(2026, 10, 1),
        quantity: const Quantity(80, 'kg'),
      ).toJson()..['quantity'] = null;
      await sink.appendLine(encodeOp('record.append', bad));
    });
    await pump(
      tester,
      LogRepository(
        sink: sink,
        durability: StorageDurability.localFile,
        location: 'test',
      ),
      locale: const Locale('tr'),
    );
    expect(
      find.textContaining(
        'Kayıtlı giriş 3 bir kayıt kuralını çiğniyor (PRESENT_REQUIRES_QUANTITY)',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a moved data folder is told to the user', (tester) async {
    await pump(
      tester,
      inMemoryRepository(),
      notes: const [
        StorageNote(StorageNoteKind.movedLegacyFolder, '/d/human-health-os'),
      ],
    );
    expect(
      find.text(
        'Your development data moved to the new folder /d/human-health-os.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a vault written by a newer app: an update hint in Turkish', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('tr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final services = await tester.runAsync(() async {
      final repo = inMemoryRepository();
      await repo.open();
      return servicesFor(
        dev,
        HostPlatform.linux,
        repo,
        reason: StorageReason.vaultUnreadable,
        detail: 'VAULT_NEWER',
      );
    });
    await tester.pumpWidget(HumanOsApp(services: services!));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('daha yeni bir sürümüyle yazılmış'),
      findsOneWidget,
    );
    expect(find.text('Kayıt kapalı'), findsOneWidget);
  });

  testWidgets('a read-only vault refuses a save with its own message', (
    tester,
  ) async {
    final sink = MemoryLogSink();
    final writer = LogRepository(
      sink: sink,
      durability: StorageDurability.localFile,
      location: 'test',
    );
    await tester.runAsync(() async {
      await writer.open();
      await HeartbeatProbe.self(writer);
    });
    final before = sink.text;
    final readOnly = LogRepository(
      sink: sink,
      durability: StorageDurability.localFile,
      location: 'test',
      migrations: [
        VaultMigration(
          id: 'M002-test',
          from: 1,
          to: 2,
          lossless: true,
          upgradeOp: (op) => op,
        ),
      ],
      targetVersion: 2,
    );
    await pump(tester, readOnly, reason: StorageReason.vaultReadOnly);
    expect(find.textContaining('uses an older format'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '70');
    await tester.tap(find.byKey(const ValueKey('weight-save')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('your saved data is open read-only'),
      findsOneWidget,
    );
    expect(sink.text, before, reason: 'nothing written');
    expect(jsonDecode(before!.split('\n').first)['format_version'], 1);
  });
}

/// Creates the SELF profile the way the app does.
class HeartbeatProbe {
  static Future<String> self(LogRepository repo) async =>
      (await servicesFor(dev, HostPlatform.linux, repo)).self.id;
}
