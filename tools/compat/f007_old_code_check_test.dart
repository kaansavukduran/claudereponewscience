// F007 old-code check (AC-10). This file is copied into a scratch worktree
// of an OLDER revision (tools/compat/old_code_check.sh) and runs there, on
// that revision's code. Its inputs were written by the F007 build
// (human_health_os/tool/make_f007_compat_inputs.dart) into F007_COMPAT_DIR.
//
// The older app must refuse F007 data without changing a byte, and must
// still open what F007 wrote at schema 3 and the checkpoints it kept.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/backup/data_files_io.dart';
import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/storage_status.dart';
import 'package:human_health_os/src/data/local/vault_envelope.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/features/vault/vault_gate_screen.dart';
import 'package:human_health_os/src/l10n/strings.dart';

const passphrase = 'fixture passphrase F006 (synthetic)';
const dev = AppConfig(
  profile: BuildProfile.development,
  version: 'old-code-check',
  sourceRevision: 'old-code-check',
);
const prod = AppConfig(
  profile: BuildProfile.production,
  version: 'old-code-check',
  sourceRevision: 'old-code-check',
);

final inputs = Directory(Platform.environment['F007_COMPAT_DIR']!);
String read(String name) => File('${inputs.path}/$name').readAsStringSync();

Matcher code(Type type, String c) => switch (type) {
  const (VaultFormatError) => isA<VaultFormatError>().having(
    (e) => e.code,
    'code',
    c,
  ),
  _ => isA<BackupError>().having((e) => e.code, 'code', c),
};

/// [name] copied into a fresh folder as [as]: writes land in the copy.
File copy(String name, String as) {
  final dir = Directory.systemTemp.createTempSync('hhos-old-');
  addTearDown(() => dir.deleteSync(recursive: true));
  final f = File('${dir.path}/$as')..createSync(recursive: true);
  f.writeAsStringSync(read(name));
  return f;
}

List<Object?> recordsJson(String name) => jsonDecode(read(name)) as List;

void main() {
  final before = {
    for (final f in inputs.listSync().whereType<File>())
      f.path: sha256.convert(f.readAsBytesSync()).toString(),
  };

  test('this is the older code: record schema 3 is its newest', () {
    expect(HealthRecord.currentSchemaVersion, 3);
  });

  group('refuses F007 data and changes nothing', () {
    test('schema-4 log fixture: RECORD_SCHEMA_NEWER', () {
      expect(
        () => parseVaultLog(read('v1_f007_schema4.hhoslog.jsonl')),
        throwsA(code(VaultFormatError, 'RECORD_SCHEMA_NEWER')),
      );
    });

    test(
      'a development vault after an F007 measurement: the repository '
      'refuses it and the start explains it; the file is unchanged',
      () async {
        final f = copy('f007_after_measurement.hhoslog.jsonl', 'vault.jsonl');
        final bytes = f.readAsBytesSync();
        await expectLater(
          LogRepository(
            sink: FileLogSink(f),
            durability: StorageDurability.localFile,
            location: f.path,
          ).open(),
          throwsA(code(VaultFormatError, 'RECORD_SCHEMA_NEWER')),
        );
        expect(f.readAsBytesSync(), bytes);

        final data = Directory.systemTemp.createTempSync('hhos-old-xdg-');
        addTearDown(() => data.deleteSync(recursive: true));
        final placed = File('${data.path}/human-health-os/$vaultFileName')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        final services = await bootstrap(
          dev,
          HostPlatform.linux,
          env: {'XDG_DATA_HOME': data.path, 'HOME': data.path},
          executablePath: '${data.path}/bin/human_health_os',
        );
        expect(services.storageReason, StorageReason.vaultUnreadable);
        expect(services.storageDetail, 'RECORD_SCHEMA_NEWER');
        expect(placed.readAsBytesSync(), bytes);

        // A restore over it is refused: the newer data is never replaced.
        final checkpoint = stageRestore(
          read('f007_checkpoint.hhosbackup.json'),
        );
        await expectLater(
          services.dataFiles!.restore(
            checkpoint,
            now: DateTime.utc(2026, 10, 9),
          ),
          throwsA(code(BackupError, 'RESTORE_TARGET_NEWER')),
        );
        expect(placed.readAsBytesSync(), bytes);
        expect(
          Directory('${data.path}/human-health-os')
              .listSync()
              .map((e) => e.uri.pathSegments.last),
          [vaultFileName],
          reason: 'nothing set aside, nothing added',
        );
      },
    );

    test('encrypted schema-4 fixture and an encrypted vault after an F007 '
        'measurement: unlock refuses with RECORD_SCHEMA_NEWER; the gate keeps '
        'the file in place and says a newer version wrote it', () async {
      final fixture = MemoryLogSink()..text = read('enc_v1_f007.hhosvault');
      await expectLater(
        EncryptedVault(raw: fixture, location: 'fixture').unlock(passphrase),
        throwsA(code(VaultFormatError, 'RECORD_SCHEMA_NEWER')),
      );
      expect(fixture.text, read('enc_v1_f007.hhosvault'));

      final dir = Directory.systemTemp.createTempSync('hhos-old-enc-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final f = File('${dir.path}/vault.hhosvault')
        ..writeAsStringSync(read('enc_f007_after_measurement.hhosvault'));
      final bytes = f.readAsBytesSync();
      final startup = await startApp(
        prod,
        HostPlatform.linux,
        env: {'HHOS_DATA_DIR': dir.path, 'HOME': dir.path},
      );
      await expectLater(
        startup.gate!.vault.unlock(passphrase),
        throwsA(code(VaultFormatError, 'RECORD_SCHEMA_NEWER')),
      );
      expect(f.readAsBytesSync(), bytes);
      expect(dir.listSync(), hasLength(1));
      expect(newerVaultCodes, contains('RECORD_SCHEMA_NEWER'));
      expect(keepInPlaceCodes, contains('RECORD_SCHEMA_NEWER'));
      expect(
        const S(AppLang.en).unreadableBody('RECORD_SCHEMA_NEWER'),
        startsWith('It was written by a newer version of Human OS'),
      );

      // Restoring over it is refused for the same reason.
      final inner = await (await EncryptedLogSink.unlock(
        MemoryLogSink()..text = read('enc_f007_after_measurement.hhosvault'),
        passphrase,
        kind: KeyKind.passphrase,
        derive: deriveInline,
      )).read();
      expect(
        () => refuseIfHasRecords(inner),
        throwsA(code(BackupError, 'RESTORE_TARGET_NEWER')),
      );
    });

    test('F007 backups: VAULT_INCOMPATIBLE (plaintext at staging, encrypted '
        'once opened with its key)', () async {
      expect(
        () => stageRestore(read('f007_plain_backup.hhosbackup.json')),
        throwsA(code(BackupError, 'VAULT_INCOMPATIBLE')),
      );
      final staged = stageRestore(read('f007_enc_backup.hhosbackup.json'));
      await expectLater(
        unlockStagedRestore(staged, passphrase, kind: KeyKind.passphrase),
        throwsA(code(BackupError, 'VAULT_INCOMPATIBLE')),
      );
    });

    test(
      'a restore over the schema-4 log is refused: RESTORE_TARGET_NEWER',
      () {
        expect(
          () => refuseIfHasRecords(read('v1_f007_schema4.hhoslog.jsonl')),
          throwsA(code(BackupError, 'RESTORE_TARGET_NEWER')),
        );
      },
    );
  });

  group('still opens what F007 wrote at schema 3, and its checkpoints', () {
    test('a development vault where F007 saved only weight and a lab result '
        'opens with the same records, and the app starts on it', () async {
      final f = copy('f007_weight_only.hhoslog.jsonl', 'vault.jsonl');
      final repo = LogRepository(
        sink: FileLogSink(f),
        durability: StorageDurability.localFile,
        location: f.path,
      );
      final report = await repo.open();
      expect(report.warnings, isEmpty);
      expect(report.readOnly, isFalse);
      final me = (await repo.profiles()).single.id;
      expect([
        for (final r in await repo.records(me)) jsonDecode(jsonEncode(r)),
      ], recordsJson('f007_weight_only.records.json'));

      final data = Directory.systemTemp.createTempSync('hhos-old-xdg-');
      addTearDown(() => data.deleteSync(recursive: true));
      File('${data.path}/human-health-os/$vaultFileName')
        ..createSync(recursive: true)
        ..writeAsStringSync(read('f007_weight_only.hhoslog.jsonl'));
      final services = await bootstrap(
        dev,
        HostPlatform.linux,
        env: {'XDG_DATA_HOME': data.path, 'HOME': data.path},
        executablePath: '${data.path}/bin/human_health_os',
      );
      expect(services.storageReason, StorageReason.saving);
      expect(
        (await services.heartbeat.currentWeights(services.self.id)).single
            .toJson(),
        (recordsJson('f007_weight_only.records.json').first! as Map),
      );
    });

    test('the checkpoint F007 kept restores into an empty place, byte for '
        'byte the vault before the first measurement', () async {
      final staged = stageRestore(read('f007_checkpoint.hhosbackup.json'));
      expect(staged.payload, read('f007_weight_only.hhoslog.jsonl'));
      final dir = Directory.systemTemp.createTempSync('hhos-old-restore-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final vault = File('${dir.path}/$vaultFileName');
      final files = FileDataFiles(dataDir: dir, vault: vault);
      await files.restore(staged, now: DateTime.utc(2026, 10, 9, 13));
      expect(vault.readAsStringSync(), staged.payload);
      final report = await LogRepository(
        sink: FileLogSink(vault),
        durability: StorageDurability.localFile,
        location: vault.path,
      ).open();
      expect(report.warnings, isEmpty);
    });

    test('an encrypted vault where F007 saved only weight unlocks, and the '
        'encrypted checkpoint opens with its passphrase', () async {
      final f = copy('enc_f007_weight_only.hhosvault', 'vault.hhosvault');
      final opened = await EncryptedVault(
        raw: FileLogSink(f),
        location: f.path,
      ).unlock(passphrase);
      expect(opened.report.warnings, isEmpty);
      final me = (await opened.repository.profiles()).single.id;
      expect([
        for (final r in await opened.repository.records(me))
          jsonDecode(jsonEncode(r)),
      ], recordsJson('enc_f007_weight_only.records.json'));

      final staged = stageRestore(read('enc_f007_checkpoint.hhosbackup.json'));
      expect(staged.payload, read('enc_f007_weight_only.hhosvault'));
      final unlocked = await unlockStagedRestore(
        staged,
        passphrase,
        kind: KeyKind.passphrase,
      );
      expect(unlocked.state!.records.values.single.schemaVersion, 3);
    });
  });

  tearDownAll(() {
    final after = {
      for (final f in inputs.listSync().whereType<File>())
        f.path: sha256.convert(f.readAsBytesSync()).toString(),
    };
    expect(after, before, reason: 'no input changed');
  });
}
