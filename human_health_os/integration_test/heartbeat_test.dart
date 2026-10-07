// Real-device/desktop integration: real event loop, real file IO.
// Run: xvfb-run flutter test integration_test -d linux
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:integration_test/integration_test.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 'it',
  sourceRevision: 'it',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('save weight → relaunch on the same file vault → same record', (
    tester,
  ) async {
    final dir = Directory.systemTemp.createTempSync('hhos-it-');
    final vault = File('${dir.path}/$vaultFileName');
    Future<void> launch() async {
      final repo = LogRepository(
        sink: FileLogSink(vault),
        durability: StorageDurability.localFile,
        location: vault.path,
      );
      await repo.open();
      final services = await servicesFor(dev, detectHostPlatform(), repo);
      await tester.pumpWidget(HumanOsApp(services: services));
      await tester.pumpAndSettle();
    }

    await launch();
    expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '77,9');
    await tester.tap(find.byKey(const ValueKey('weight-save')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('77.9 kg'), findsWidgets);
    expect(vault.readAsStringSync(), contains('"original_text":"77,9"'));

    await tester.pumpWidget(const SizedBox());
    await launch(); // fresh repository + fresh widget tree on the same file
    expect(find.byKey(const ValueKey('weight-latest')), findsOneWidget);
    expect(find.text('77.9 kg'), findsWidgets);

    // Moving the vault folder keeps the same profile (path ≠ identity).
    final moved = dir.renameSync('${dir.path}-moved');
    final repo2 = LogRepository(
      sink: FileLogSink(File('${moved.path}/$vaultFileName')),
      durability: StorageDurability.localFile,
      location: moved.path,
    );
    await repo2.open();
    expect((await repo2.profiles()).length, 1);
    moved.deleteSync(recursive: true);
  });

  testWidgets('F002: a pre-F002 Linux vault in HumanHealthOS/ moves to '
      'human-health-os/ and opens with the same vault, profile and record', (
    tester,
  ) async {
    if (!Platform.isLinux) return;
    final data = Directory.systemTemp.createTempSync('hhos-it-xdg-');
    final env = {'XDG_DATA_HOME': data.path, 'HOME': data.path};
    final exe = '${data.path}/bin/human_health_os';

    // "Old app": write a vault where FORGE 002..F001 builds kept it.
    final legacy = File('${data.path}/HumanHealthOS/$vaultFileName');
    final old = LogRepository(
      sink: FileLogSink(legacy),
      durability: StorageDurability.localFile,
      location: legacy.path,
    );
    await old.open();
    final oldServices = await servicesFor(dev, HostPlatform.linux, old);
    final saved = await oldServices.heartbeat.recordWeightKg(
      profileId: oldServices.self.id,
      input: '81,3',
    );
    final bytes = legacy.readAsBytesSync();

    // "New app": the real adapter resolves, moves and opens the vault.
    final choice = await createPlatformRepository(
      dev,
      env: env,
      executablePath: exe,
    );
    expect(choice.notes.single.kind, StorageNoteKind.movedLegacyFolder);
    final moved = File('${data.path}/human-health-os/$vaultFileName');
    expect(moved.readAsBytesSync(), bytes, reason: 'moved, not rewritten');
    expect(legacy.existsSync(), isFalse);
    final report = await choice.repository.open();
    expect(report.warnings, isEmpty);
    expect(report.readOnly, isFalse);
    expect(choice.repository.description.vaultId, old.description.vaultId);
    final services = await servicesFor(
      dev,
      HostPlatform.linux,
      choice.repository,
      reason: choice.reason,
      notes: choice.notes,
      report: report,
    );
    expect(services.self.id, oldServices.self.id);
    final again = (await services.heartbeat.currentWeights(services.self.id))
        .single;
    expect(again.toJson(), saved.toJson(), reason: 'id, provenance, text');
    final header =
        jsonDecode(moved.readAsLinesSync().first) as Map<String, Object?>;
    expect(header['format_version'], vaultFormatVersion);

    await tester.pumpWidget(HumanOsApp(services: services));
    await tester.pumpAndSettle();
    expect(find.text('81.3 kg'), findsWidgets);
    expect(
      find.byKey(const ValueKey('storage-note-movedLegacyFolder')),
      findsOneWidget,
    );

    // Second start: nothing left to move, no note.
    final second = await createPlatformRepository(
      dev,
      env: env,
      executablePath: exe,
    );
    expect(second.notes, isEmpty);
    expect(second.repository.description.location, moved.path);
    data.deleteSync(recursive: true);
  });
}
