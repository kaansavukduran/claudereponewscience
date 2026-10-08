// F005@v0.32 "Your data" card: create a backup and an export, check a
// backup, restore through the gate (refused while records exist), lock
// writes after a restore, and say plainly when a build may not write files.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/app_services.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: '0.1.0+1',
  sourceRevision: 'test',
);
const staging = AppConfig(
  profile: BuildProfile.staging,
  version: '0.1.0+1',
  sourceRevision: 'test',
);

class NoRestoreFiles extends MemoryDataFiles {
  @override
  bool get canRestore => false;
}

/// Backups this user may not read (permissions, a lock).
class UnreadableBackups extends MemoryDataFiles {
  @override
  Future<String> read(SavedFile file) async =>
      throw const FileSystemException('permission denied');
}

/// The last move of a restore fails (another program holds the file); the
/// previous vault is back in place.
class SwitchFails extends MemoryDataFiles {
  @override
  Future<RestoreOutcome> restore(
    StagedRestore staged, {
    required DateTime now,
    void Function()? beforeSwitch,
  }) async {
    target.checkKind(staged);
    beforeSwitch?.call();
    throw const BackupError('RESTORE_SWITCH_FAILED', '');
  }
}

/// A backup of a vault with one weight entry, made elsewhere.
Future<String> backupMadeElsewhere(WidgetTester tester) async {
  final other = MemoryLogSink();
  final source = LogRepository(
    sink: other,
    durability: StorageDurability.localFile,
    location: 'x',
  );
  return (await tester.runAsync(() async {
    await source.open();
    final s0 = await servicesFor(dev, HostPlatform.linux, source);
    await s0.heartbeat.recordWeightKg(profileId: s0.self.id, input: '77');
    return createBackupBundle(
      vaultLogText: other.text!,
      appVersion: 'x',
      sourceRevision: 'x',
      createdAt: DateTime.utc(2026, 10, 7),
    );
  }))!;
}

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 80)),
  );
  await tester.pumpAndSettle();
}

/// Starts the app on a "file" vault kept in [sink] with [files].
Future<AppServices> start(
  WidgetTester tester, {
  required MemoryLogSink sink,
  DataFiles? files,
  AppConfig config = dev,
}) async {
  tester.view.physicalSize = const Size(1280, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final s = await tester.runAsync(() async {
    final repo = LogRepository(
      sink: sink,
      durability: StorageDurability.localFile,
      location: 'test',
    );
    final report = await repo.open();
    return servicesFor(
      config,
      HostPlatform.linux,
      repo,
      report: report,
      files: files,
    );
  });
  await tester.pumpWidget(HumanOsApp(services: s!));
  await settle(tester);
  return s;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.tap(f);
  await settle(tester);
}

String message(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('data-message'))).data!;

void main() {
  testWidgets('create a backup and an export; the backup is listed and its '
      'check passes', (tester) async {
    final files = MemoryDataFiles();
    final s = await start(tester, sink: MemoryLogSink(), files: files);
    await tester.runAsync(
      () => s.heartbeat.recordWeightKg(profileId: s.self.id, input: '80'),
    );
    await tapKey(tester, 'create-backup');
    expect(
      message(tester),
      startsWith('Saved: memory:backup/human-os-backup-'),
    );
    final name = files.files.keys.single.substring('backup/'.length);
    expect(find.byKey(ValueKey('backup-$name')), findsOneWidget);
    final staged = stageRestore(files.files.values.single);
    expect(staged.manifest.recordCount, 1);

    await tapKey(tester, 'export-json');
    expect(
      message(tester),
      startsWith('Saved: memory:export/human-os-export-'),
    );

    await tapKey(tester, 'check-$name');
    expect(
      message(tester),
      startsWith('Checked: 1 records and 1 profiles, checksum matches.'),
    );
  });

  testWidgets('a damaged backup is named as damaged by Check', (tester) async {
    final files = MemoryDataFiles();
    final s = await start(tester, sink: MemoryLogSink(), files: files);
    await tester.runAsync(
      () => s.heartbeat.recordWeightKg(profileId: s.self.id, input: '80'),
    );
    await tapKey(tester, 'create-backup');
    final id = files.files.keys.single;
    // Change one character inside the payload (decoded, not the escaped
    // JSON text), keeping the manifest as it was.
    final d = (jsonDecode(files.files[id]!) as Map).cast<String, Object?>();
    final payload = d['payload']! as String;
    expect(payload, contains('"original_text":"80"'));
    d['payload'] = payload.replaceFirst(
      '"original_text":"80"',
      '"original_text":"81"',
    );
    files.files[id] = jsonEncode(d);
    await tapKey(tester, 'check-${id.substring('backup/'.length)}');
    expect(message(tester), startsWith('This backup is damaged'));
  });

  testWidgets('restore is refused while this device holds records', (
    tester,
  ) async {
    final sink = MemoryLogSink();
    final files = MemoryDataFiles();
    final s = await start(tester, sink: sink, files: files);
    await tester.runAsync(
      () => s.heartbeat.recordWeightKg(profileId: s.self.id, input: '80'),
    );
    await tapKey(tester, 'create-backup');
    files.vaultText = sink.text;
    final name = files.files.keys.single.substring('backup/'.length);
    await tapKey(tester, 'restore-$name');
    expect(
      find.textContaining('it is refused while this device holds any'),
      findsOneWidget,
    );
    await tapKey(tester, 'confirm-restore');
    expect(message(tester), startsWith('This device already holds records'));
    expect(files.vaultText, sink.text, reason: 'nothing replaced');
  });

  testWidgets('restore on a device without records, then no more writes '
      'until a restart', (tester) async {
    // A backup made elsewhere.
    final other = MemoryLogSink();
    final source = LogRepository(
      sink: other,
      durability: StorageDurability.localFile,
      location: 'x',
    );
    late String bundle;
    await tester.runAsync(() async {
      await source.open();
      final s0 = await servicesFor(dev, HostPlatform.linux, source);
      await s0.heartbeat.recordWeightKg(profileId: s0.self.id, input: '77');
      bundle = createBackupBundle(
        vaultLogText: other.text!,
        appVersion: 'x',
        sourceRevision: 'x',
        createdAt: DateTime.utc(2026, 10, 7),
      );
    });
    final sink = MemoryLogSink();
    final files = MemoryDataFiles();
    files.files['backup/b.hhosbackup.json'] = bundle;
    files.times['backup/b.hhosbackup.json'] = DateTime.utc(2026, 10, 7);
    await start(tester, sink: sink, files: files);
    files.vaultText = sink.text; // fresh vault: a profile, no records
    await tapKey(tester, 'restore-b.hhosbackup.json');
    await tapKey(tester, 'confirm-restore');
    expect(
      message(tester),
      'Restored 1 records. Close and reopen Human OS to use them. '
      'The previous data file was kept at memory:before-restore.',
    );
    expect(files.vaultText, other.text);
    expect(files.kept, isNotNull, reason: 'the replaced vault is kept');

    await tester.enterText(find.byKey(const ValueKey('weight-input')), '70');
    await tapKey(tester, 'weight-save');
    expect(
      find.textContaining('a restore ran in this session. Restart Human OS'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('create-backup')))
          .onPressed,
      isNull,
    );

    // Leaving Today and coming back must not re-enable writes (review
    // finding: the restored flag lived in the card's State).
    await tester.tap(find.text('Timeline').first);
    await settle(tester);
    await tester.tap(find.text('Today').first);
    await settle(tester);
    expect(find.byKey(const ValueKey('restart-to-use')), findsOneWidget);
    for (final key in ['create-backup']) {
      expect(
        tester.widget<FilledButton>(find.byKey(ValueKey(key))).onPressed,
        isNull,
        reason: key,
      );
    }
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('export-json')))
          .onPressed,
      isNull,
    );
    // Labs gives the real reason, not "storage failed" (review finding).
    await tester.tap(find.text('Labs').first);
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('lab-analyte')), 'CRP');
    await tester.enterText(find.byKey(const ValueKey('lab-value')), '3');
    final save = find.byKey(const ValueKey('lab-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await settle(tester);
    expect(
      find.textContaining('a restore ran in this session. Restart Human OS'),
      findsOneWidget,
    );
  });

  testWidgets('staging: no files are written, and the card says why', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final dir = Directory.systemTemp.createTempSync('hhos-f005-staging-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final startup = await tester.runAsync(
      () => startApp(
        staging,
        HostPlatform.linux,
        env: {'HHOS_DATA_DIR': dir.path, 'HOME': dir.path},
      ),
    );
    await tester.pumpWidget(HumanOsApp.start(startup!));
    await settle(tester);
    await tapKey(tester, 'gate-memory-only');
    expect(find.byKey(const ValueKey('data-not-available')), findsOneWidget);
    expect(find.byKey(const ValueKey('create-backup')), findsNothing);
    expect(dir.listSync(), isEmpty, reason: 'nothing written anywhere');
  });

  testWidgets('browser-like adapter: download only, restore said to be '
      'not built', (tester) async {
    await start(tester, sink: MemoryLogSink(), files: NoRestoreFiles());
    expect(
      find.textContaining('Restoring it here is not built yet'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('no-backups')), findsNothing);
  });

  testWidgets('a backup that cannot be read: the card names what failed and '
      'that nothing changed', (tester) async {
    final files = UnreadableBackups()
      ..files['backup/b.hhosbackup.json'] = '{}'
      ..times['backup/b.hhosbackup.json'] = DateTime.utc(2026, 10, 7);
    await start(tester, sink: MemoryLogSink(), files: files);
    await tapKey(tester, 'restore-b.hhosbackup.json');
    await tapKey(tester, 'confirm-restore');
    expect(
      message(tester),
      'That did not work (FileSystemException). Nothing was changed.',
    );
    expect(files.vaultText, isNull);
    expect(find.byKey(const ValueKey('restart-to-use')), findsNothing);
  });

  testWidgets('a restore whose last move fails: the card says the previous '
      'file is back, and this session stops writing until a restart', (
    tester,
  ) async {
    final bundle = await backupMadeElsewhere(tester);
    final files = SwitchFails()
      ..files['backup/b.hhosbackup.json'] = bundle
      ..times['backup/b.hhosbackup.json'] = DateTime.utc(2026, 10, 7);
    await start(tester, sink: MemoryLogSink(), files: files);
    await tapKey(tester, 'restore-b.hhosbackup.json');
    await tapKey(tester, 'confirm-restore');
    expect(
      message(tester),
      startsWith(
        'The restore could not be finished: the restored copy could not be '
        'moved into place. The previous data file is back where it was.',
      ),
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('create-backup')))
          .onPressed,
      isNull,
      reason: 'paused until a restart',
    );
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '70');
    await tapKey(tester, 'weight-save');
    expect(
      find.textContaining('a restore ran in this session. Restart Human OS'),
      findsOneWidget,
    );
    expect(find.textContaining('restored data'), findsNothing);
  });
}
