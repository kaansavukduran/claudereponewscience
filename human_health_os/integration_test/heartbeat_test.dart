// Real-device/desktop integration: real event loop, real file IO.
// Run: xvfb-run flutter test integration_test -d linux
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/app_services.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/navigation/app_shell.dart';
import 'package:integration_test/integration_test.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 'it',
  sourceRevision: 'it',
);
const prod = AppConfig(
  profile: BuildProfile.production,
  version: 'it',
  sourceRevision: 'it',
);

/// Pumps real frames until [finder] shows up: key derivation runs in a
/// real isolate here, so settling the UI alone does not wait for it.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      final shown = [
        for (final e in find.byType(Text).evaluate())
          (e.widget as Text).data ?? '',
      ];
      throw StateError('timed out waiting for $finder; on screen: $shown');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pump();
}

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

  testWidgets('F003: a correction and a withdrawal survive a relaunch on the '
      'real file vault (append-only)', (tester) async {
    final dir = Directory.systemTemp.createTempSync('hhos-it-f003-');
    final vault = File('${dir.path}/$vaultFileName');
    LogRepository open() => LogRepository(
      sink: FileLogSink(vault),
      durability: StorageDurability.localFile,
      location: vault.path,
    );
    final a = open();
    await a.open();
    final s1 = await servicesFor(dev, HostPlatform.linux, a);
    final w = await s1.heartbeat.recordWeightKg(
      profileId: s1.self.id,
      input: '90',
    );
    final c = await s1.heartbeat.correctWeightKg(
      profileId: s1.self.id,
      targetId: w.id,
      input: '9',
    );
    final before = vault.readAsStringSync();
    await s1.heartbeat.amend(
      profileId: s1.self.id,
      targetId: c.id,
      reason: AmendReason.enteredInError,
    );
    expect(vault.readAsStringSync().startsWith(before), isTrue);

    final b = open(); // relaunch
    final report = await b.open();
    expect(report.warnings, isEmpty);
    final s2 = await servicesFor(dev, HostPlatform.linux, b, report: report);
    final entry = (await s2.heartbeat.timeline(s2.self.id)).single;
    expect(entry.heads.single.id, w.id);
    expect(entry.withdrawn, {c.id});
    await tester.pumpWidget(HumanOsApp(services: s2));
    await tester.pumpAndSettle();
    expect(find.text('90 kg'), findsWidgets);
    expect(find.text('9 kg'), findsNothing);
    dir.deleteSync(recursive: true);
  });

  testWidgets('F004: a lab result keeps every printed field across a '
      'relaunch on the real file vault', (tester) async {
    final dir = Directory.systemTemp.createTempSync('hhos-it-f004-');
    final vault = File('${dir.path}/$vaultFileName');
    LogRepository open() => LogRepository(
      sink: FileLogSink(vault),
      durability: StorageDurability.localFile,
      location: vault.path,
    );
    final a = open();
    await a.open();
    final s1 = await servicesFor(dev, HostPlatform.linux, a);
    final saved = await s1.heartbeat.recordLab(
      profileId: s1.self.id,
      input: const LabInput(
        analyte: 'LDL Kolesterol',
        value: '142',
        notReported: false,
        unit: '',
        sampleDate: '2026-10-03',
        sourceFlag: 'H',
        referenceText: '< 130',
      ),
    );

    final b = open(); // relaunch
    final report = await b.open();
    expect(report.warnings, isEmpty);
    final s2 = await servicesFor(dev, HostPlatform.linux, b, report: report);
    final again = (await s2.heartbeat.labTimeline(s2.self.id)).single.shown;
    expect(again.toJson(), saved.toJson());
    expect(again.quantity!.unit, isNull, reason: 'missing unit stays missing');
    await tester.pumpWidget(HumanOsApp(services: s2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Labs').first);
    await tester.pumpAndSettle();
    // The result list sits below the entry form: scroll until it is built.
    final value = find.text('142 (unit not given)');
    await tester.scrollUntilVisible(
      value,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('screen-labs')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(value, findsOneWidget);
    expect(find.text('Lab flag: H'), findsOneWidget);
    dir.deleteSync(recursive: true);
  });

  testWidgets('F005 restore drill: backup -> lose the vault -> fresh start '
      '-> restore -> relaunch shows the same records', (tester) async {
    if (!Platform.isLinux) return;
    final data = Directory.systemTemp.createTempSync('hhos-it-f005-');
    final env = {'XDG_DATA_HOME': data.path, 'HOME': data.path};
    final exe = '${data.path}/bin/human_health_os';
    Future<AppServices> launch() async {
      final choice = await createPlatformRepository(
        dev,
        env: env,
        executablePath: exe,
      );
      final report = await choice.repository.open();
      return servicesFor(
        dev,
        HostPlatform.linux,
        choice.repository,
        report: report,
        files: choice.files,
      );
    }

    final s1 = await launch();
    final w = await s1.heartbeat.recordWeightKg(
      profileId: s1.self.id,
      input: '82,5',
    );
    await s1.heartbeat.recordLab(
      profileId: s1.self.id,
      input: const LabInput(
        analyte: 'HbA1c',
        value: '5,4',
        notReported: false,
        unit: '%',
        sampleDate: '2026-10-03',
        sourceFlag: 'H',
      ),
    );
    final vault = File('${data.path}/human-health-os/$vaultFileName');
    final original = vault.readAsStringSync();
    final bundle = await s1.makeBackup!(DateTime.utc(2026, 10, 7, 12));
    await s1.dataFiles!.save(
      DataFileKind.backup,
      'drill.hhosbackup.json',
      bundle,
    );

    vault.deleteSync(); // the disaster
    final s2 = await launch(); // a fresh start creates a new, empty vault
    expect(await s2.heartbeat.currentWeights(s2.self.id), isEmpty);
    expect(s2.self.id, isNot(s1.self.id));

    final saved = (await s2.dataFiles!.backups()).single;
    final staged = stageRestore(await s2.dataFiles!.read(saved));
    final out = await s2.dataFiles!.restore(
      staged,
      now: DateTime.utc(2026, 10, 7, 13),
    );
    expect(out.keptPrevious, isNotNull);
    expect(vault.readAsStringSync(), original);

    final s3 = await launch(); // relaunch after the restore
    expect(s3.self.id, s1.self.id);
    expect(
      (await s3.heartbeat.currentWeights(s3.self.id)).single.toJson(),
      w.toJson(),
    );
    await tester.pumpWidget(HumanOsApp(services: s3));
    await tester.pumpAndSettle();
    expect(find.text('82.5 kg'), findsWidgets);
    data.deleteSync(recursive: true);
  });

  testWidgets('F006: a production build starts at the vault gate, creates '
      'the encrypted vault (production key cost, in an isolate), and after a '
      'relaunch refuses a wrong passphrase and opens with the right one', (
    tester,
  ) async {
    if (!Platform.isLinux) return;
    final data = Directory.systemTemp.createTempSync('hhos-it-f006-');
    final env = {'HHOS_DATA_DIR': data.path, 'HOME': data.path};
    const pass = 'Mavi-Kedi 7 Ağaç Lamba!';

    Future<void> launch() async {
      final startup = await startApp(prod, HostPlatform.linux, env: env);
      expect(startup.gate, isNotNull, reason: 'never the shell first');
      await tester.pumpWidget(HumanOsApp.start(startup));
      await tester.pumpAndSettle();
    }

    await launch();
    expect(find.byKey(const ValueKey('vault-gate-create')), findsOneWidget);
    expect(data.listSync(), isEmpty, reason: 'nothing written before create');
    await tester.enterText(find.byKey(const ValueKey('gate-passphrase')), pass);
    await tester.enterText(
      find.byKey(const ValueKey('gate-passphrase-confirm')),
      pass,
    );
    await tapKey(tester, 'gate-continue');
    await tester.pumpAndSettle();
    final key = tester
        .widget<SelectableText>(find.byKey(const ValueKey('gate-recovery-key')))
        .data!;
    await tapKey(tester, 'gate-key-written');
    await tester.pumpAndSettle();
    await tapKey(tester, 'gate-create-vault');
    await waitFor(tester, find.byKey(const ValueKey('screen-today')));

    final services = tester.widget<AppShell>(find.byType(AppShell)).services;
    expect(services.storage.encrypted, isTrue);
    await services.heartbeat.recordWeightKg(
      profileId: services.self.id,
      input: '74,2',
    );
    await services.heartbeat.recordLab(
      profileId: services.self.id,
      input: const LabInput(
        analyte: 'Açlık kan şekeri',
        value: '92,4',
        notReported: false,
        unit: 'mg/dL',
        sampleDate: '2026-10-03',
        laboratory: 'Örnek Laboratuvarı',
      ),
    );

    final file = File('${data.path}/vault.hhosvault');
    expect(data.listSync().map((e) => e.path.split('/').last).toList(), [
      'vault.hhosvault',
    ], reason: 'only the encrypted vault, no plaintext log or copy');
    final stored = file.readAsStringSync();
    for (final s in [
      pass,
      key,
      'Açlık',
      'Örnek',
      '74,2',
      '92,4',
      'lab.result',
    ]) {
      expect(stored, isNot(contains(s)), reason: s);
    }
    final header = jsonDecode(stored.split('\n').first) as Map;
    expect(
      ((header['keys'] as List).first as Map)['kdf'],
      containsPair('memory_kib', 19456),
    );

    await tester.pumpWidget(const SizedBox());
    await launch(); // relaunch
    expect(find.byKey(const ValueKey('vault-gate-unlock')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('gate-passphrase')),
      'not the passphrase',
    );
    await tapKey(tester, 'gate-unlock');
    await waitFor(tester, find.byKey(const ValueKey('gate-error')));

    expect(
      file.readAsStringSync(),
      stored,
      reason: 'a failed unlock writes nothing',
    );
    await tester.enterText(find.byKey(const ValueKey('gate-passphrase')), pass);
    await tapKey(tester, 'gate-unlock');
    await waitFor(tester, find.byKey(const ValueKey('screen-today')));
    expect(find.text('74.2 kg'), findsWidgets);
    data.deleteSync(recursive: true);
  });

  testWidgets('F006 on real files: recovery replaces the passphrase; key loss '
      'keeps the locked vault aside; a portable vault lives in UserData/ and '
      'keeps its identity when the folder moves', (tester) async {
    if (!Platform.isLinux) return;
    final root = Directory.systemTemp.createTempSync('hhos-it-f006b-');
    final app = Directory('${root.path}/HumanOS')..createSync();
    File('${app.path}/portable_mode.json').writeAsStringSync('{}');
    final exe = '${app.path}/human_health_os';

    Future<EncryptedVault> vaultAt(String exePath) async =>
        (await createPlatformRepository(prod, executablePath: exePath)).vault!;

    final v = await vaultAt(exe);
    expect(v.location, '${app.path}/UserData/vault.hhosvault');
    final key = newRecoveryKeyForIt();
    final created = await v.create(
      passphrase: 'first long passphrase',
      recoveryKey: key,
    );
    final svc = HeartbeatService(created.repository);
    final me = (await svc.ensureSelfProfile()).id;
    await svc.recordWeightKg(profileId: me, input: '70');
    final vaultId = created.repository.description.vaultId;

    // The folder moves to another place (another USB port, another PC).
    Directory('${root.path}/Moved').createSync();
    final movedApp = app.renameSync('${root.path}/Moved/HumanOS');
    final moved = await vaultAt('${movedApp.path}/human_health_os');
    final recovered = await moved.recover(
      recoveryKey: key.toLowerCase().replaceAll('-', ' '),
      newPassphrase: 'second long passphrase',
    );
    expect(recovered.repository.description.vaultId, vaultId);
    expect((await recovered.repository.records(me)).length, 1);
    await expectLater(
      moved.unlock('first long passphrase'),
      throwsA(isA<CryptoFailure>()),
    );

    // Both secrets lost: the vault is kept aside, never deleted.
    final file = File('${movedApp.path}/UserData/vault.hhosvault');
    final bytes = file.readAsBytesSync();
    final kept = await moved.setAside();
    expect(File(kept).readAsBytesSync(), bytes);
    expect(file.existsSync(), isFalse);
    expect((await moved.inspect()).access, VaultAccess.create);
    root.deleteSync(recursive: true);
  });
}

/// A fixed, synthetic recovery key: integration runs stay reproducible.
String newRecoveryKeyForIt() => 'K7QM-2XRA-PLMN-B3DE-ZZ4H-QW5T-RT6Y-HJ7U';
