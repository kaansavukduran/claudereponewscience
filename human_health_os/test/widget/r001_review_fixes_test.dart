// R001@v0.32: fixes from the independent reviews of U001-U010, each bound to
// a test.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/appearance_store_io.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/features/guide/glossary_screen.dart';
import 'package:human_health_os/src/features/measurements/measurement_format.dart';
import 'package:human_health_os/src/features/report/doctor_summary.dart';
import 'package:human_health_os/src/features/trends/trend_screen.dart';

import 'f007_measurements_test.dart' show dev, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  test(
    'a saved summary says when a section shows only the newest readings',
    () {
      const d = DoctorSummary(
        title: 't',
        createdAt: 'c',
        sections: [
          SummarySection(
            'Weight',
            [SummaryRow('w', 'v')],
            31,
            'Showing the newest 20 of 31.',
          ),
        ],
        footer: [],
      );
      expect(d.toHtml('en'), contains('Showing the newest 20 of 31.'));
    },
  );

  test('a development build in portable mode keeps settings in memory: '
      'nothing is written next to the program', () async {
    final dir = Directory.systemTemp.createTempSync('hhos-portable');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/portable_mode.json').writeAsStringSync('{}');
    final store = await openAppearanceStore(
      dev,
      HostPlatform.linux,
      env: {'HOME': dir.path},
      executablePath: '${dir.path}/human_health_os',
    );
    expect(store.persistent, isFalse);
    await store.save(const AppearanceSettings(accent: AccentChoice.blue));
    expect(dir.listSync().map((e) => e.uri.pathSegments.last).toList(), [
      'portable_mode.json',
    ]);
    expect(dev.profile, BuildProfile.development);
  });

  test('the chart axis never shows less than a sensible span', () {
    expect(minSpanFor(RecordKind.bodyWeight), 5);
    expect(minSpanFor(RecordKind.bodyTemperature), 2);
    for (final k in RecordKind.values) {
      expect(minSpanFor(k), greaterThan(0));
    }
  });

  test('glossary search folds Turkish letters both ways', () {
    for (final q in ['NABIZ', 'nabiz', 'nabız', 'Nabız']) {
      expect(
        foldForSearch('Dinlenme nabzı').contains(foldForSearch('nabz')),
        isTrue,
      );
      expect(foldForSearch(q), 'nabiz', reason: q);
    }
    expect(foldForSearch('SATÜRASYON'), 'saturasyon');
  });

  test(
    'notes from withdrawn or corrected-away readings are not offered',
    () async {
      final repo = LogRepository(
        sink: MemoryLogSink(),
        durability: StorageDurability.localFile,
        location: 'test',
      );
      await repo.open();
      final svc = HeartbeatService(repo);
      final me = (await svc.ensureSelfProfile()).id;
      final a = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '60', context: 'withdrawn note'),
      );
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '61', context: 'kept note'),
      );
      await svc.amend(
        profileId: me,
        targetId: a.id,
        reason: AmendReason.enteredInError,
      );
      expect(previousNotes(await repo.records(me)), ['kept note']);
    },
  );

  testWidgets('the top-bar button is named Settings; tile rows speak their '
      'name, and each arrow names its tile', (tester) async {
    final handle = tester.ensureSemantics();
    await launchWith(tester);
    expect(find.byTooltip('Settings'), findsOneWidget);
    await tapKey(tester, 'open-settings');
    expect(find.byTooltip('Move Height up'), findsOneWidget);
    expect(find.byTooltip('Move Blood pressure down'), findsOneWidget);
    final node = tester.getSemantics(
      find.byKey(const ValueKey('set-tile-show-vital.blood_pressure')),
    );
    expect(node.label, contains('Blood pressure'));
    handle.dispose();
  });
}
