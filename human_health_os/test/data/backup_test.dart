// F005@v0.32 backup bundle, restore gate and restore drill (master §36,
// §39 F005 exit: backup -> delete test vault -> restore -> same records;
// checksums/manifest verified).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/backup/data_files_io.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

final t0 = DateTime.utc(2026, 10, 7, 12);
const fixtures = [
  'test/fixtures/vault/v1_forge002.hhoslog.jsonl',
  'test/fixtures/vault/v1_f003_schema2.hhoslog.jsonl',
  'test/fixtures/vault/v1_f004_schema3.hhoslog.jsonl',
];

String bundleOf(String vault) => createBackupBundle(
  vaultLogText: vault,
  appVersion: '0.1.0+1',
  sourceRevision: 'abc123',
  createdAt: t0,
);

Map<String, Object?> doc(String bundle) =>
    (jsonDecode(bundle) as Map).cast<String, Object?>();

String withManifest(String bundle, void Function(Map<String, Object?> m) f) {
  final d = doc(bundle);
  f((d['manifest']! as Map).cast<String, Object?>());
  return jsonEncode(d);
}

Matcher backupError(String code) =>
    throwsA(isA<BackupError>().having((e) => e.code, 'code', code));

String timelineSignature(String vault) {
  final s = parseVaultLog(vault);
  return [
    for (final e in buildTimeline(s.records.values, includeHidden: true))
      '${e.rootId}|${e.status.name}|${e.heads.map((h) => h.id).join(',')}|'
          '${e.versions.map((v) => v.id).join(',')}',
  ].join('\n');
}

void main() {
  group('bundle and manifest (§36.2)', () {
    test('self-describing, deterministic, payload byte-identical', () {
      final vault = File(fixtures[2]).readAsStringSync();
      final a = bundleOf(vault);
      expect(bundleOf(vault), a, reason: 'same input, same bytes');
      final d = doc(a);
      expect(d['payload'], vault);
      final m = (d['manifest']! as Map).cast<String, Object?>();
      expect(m['format'], 'hhos-backup');
      expect(m['format_version'], 1);
      expect(m['source_app_version'], '0.1.0+1');
      expect(m['source_revision'], 'abc123');
      expect(m['created_at'], '2026-10-07T12:00:00.000Z');
      expect(m['vault_id'], '00000000-0000-4000-8000-0000000000f3');
      expect(m['vault_format_version'], 1);
      expect(m['record_schema_versions'], [2, 3]);
      expect(m['profile_count'], 1);
      expect(m['record_count'], 6);
      expect(m['skipped_entries'], 0);
      expect(m['payload_sha256'], sha256Hex(vault));
      expect(m['payload_bytes'], utf8.encode(vault).length);
      expect(m['encryption'], 'none-dev-only');
      expect(m['attachments'], isEmpty);
      final secret = RegExp(
        r'(key|secret|passphrase|password|token|salt)',
        caseSensitive: false,
      );
      expect(
        m.keys.where(secret.hasMatch),
        isEmpty,
        reason: 'no key in plaintext',
      );
    });

    test('SHA-256 matches a published test vector', () {
      expect(
        sha256Hex('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('entries the app skips are still backed up and counted', () {
      final vault =
          '${File(fixtures[0]).readAsStringSync()}{"op":"record.append","data":{"broken":true}}\n';
      final staged = stageRestore(bundleOf(vault));
      expect(staged.manifest.skippedEntries, 1);
      expect(staged.payload, vault);
    });
  });

  group('restore gate refuses before writing (§36.3)', () {
    final vault = File(fixtures[1]).readAsStringSync();
    late String good;
    setUp(() => good = bundleOf(vault));

    test('every fixture passes the gate', () {
      for (final f in fixtures) {
        final v = File(f).readAsStringSync();
        final staged = stageRestore(bundleOf(v));
        expect(staged.payload, v, reason: f);
      }
    });

    test('one changed character in the payload: DIGEST_MISMATCH', () {
      final d = doc(good);
      d['payload'] = (d['payload']! as String).replaceFirst('"80', '"81');
      expect(() => stageRestore(jsonEncode(d)), backupError('DIGEST_MISMATCH'));
    });

    test('manifest that lies about counts or identity', () {
      expect(
        () => stageRestore(withManifest(good, (m) => m['record_count'] = 99)),
        backupError('COUNT_MISMATCH'),
      );
      expect(
        () => stageRestore(withManifest(good, (m) => m['vault_id'] = 'other')),
        backupError('VAULT_ID_MISMATCH'),
      );
    });

    test('newer format, encrypted, unreadable, not a backup', () {
      expect(
        () => stageRestore(withManifest(good, (m) => m['format_version'] = 2)),
        backupError('BACKUP_NEWER'),
      );
      expect(
        () => stageRestore(
          withManifest(good, (m) => m['encryption'] = 'aes-256-gcm'),
        ),
        backupError('BACKUP_ENCRYPTED_UNSUPPORTED'),
      );
      expect(() => stageRestore('{not json'), backupError('BACKUP_UNREADABLE'));
      expect(() => stageRestore('{"hello":1}'), backupError('NOT_A_BACKUP'));
    });

    test('a vault this app cannot read: VAULT_INCOMPATIBLE', () {
      final newer = vault.replaceFirst(
        '"format_version":1',
        '"format_version":99',
      );
      expect(
        () => stageRestore(bundleOf2(newer)),
        backupError('VAULT_INCOMPATIBLE'),
      );
    });
  });

  group('restore drill on real files', () {
    late Directory tmp;
    late File vaultFile;
    late FileDataFiles files;
    setUp(() {
      tmp = Directory.systemTemp.createTempSync('hhos-drill-');
      vaultFile = File('${tmp.path}/$vaultFileName');
      files = FileDataFiles(dataDir: tmp, vault: vaultFile);
    });
    tearDown(() => tmp.deleteSync(recursive: true));

    LogRepository repo() => LogRepository(
      sink: FileLogSink(vaultFile),
      durability: StorageDurability.localFile,
      location: vaultFile.path,
    );

    Future<void> fill() async {
      final r = repo();
      await r.open();
      final svc = HeartbeatService(r);
      final me = (await svc.ensureSelfProfile()).id;
      final w = await svc.recordWeightKg(profileId: me, input: '80');
      final c = await svc.correctWeightKg(
        profileId: me,
        targetId: w.id,
        input: '8',
      );
      await svc.amend(
        profileId: me,
        targetId: c.id,
        reason: AmendReason.enteredInError,
      );
      final gone = await svc.recordWeightKg(profileId: me, input: '79');
      await svc.amend(
        profileId: me,
        targetId: gone.id,
        reason: AmendReason.deleted,
      );
      await svc.recordLab(
        profileId: me,
        input: const LabInput(
          analyte: 'LDL',
          value: '142',
          notReported: false,
          unit: '',
          sampleDate: '2026-10-03',
          sourceFlag: 'H',
        ),
      );
    }

    test('backup -> delete the vault -> restore -> the same records, '
        'byte for byte', () async {
      await fill();
      final original = vaultFile.readAsStringSync();
      final name = backupFileName('drill', t0);
      final where = await files.save(
        DataFileKind.backup,
        name,
        bundleOf(original),
      );
      expect(where, '${tmp.path}/backups/$name');
      expect(Directory('${tmp.path}/backups').listSync().map((e) => e.path), [
        '${tmp.path}/backups/$name',
      ], reason: 'no temp file left behind');

      vaultFile.deleteSync(); // disaster

      final saved = (await files.backups()).single;
      final staged = stageRestore(await files.read(saved));
      final out = await files.restore(staged, now: t0);
      expect(out.records, staged.manifest.recordCount);
      expect(out.keptPrevious, isNull);
      expect(vaultFile.readAsStringSync(), original);
      expect(
        timelineSignature(vaultFile.readAsStringSync()),
        timelineSignature(original),
      );
      expect(File('${vaultFile.path}.restoring').existsSync(), isFalse);

      final reopened = repo();
      expect((await reopened.open()).warnings, isEmpty);
    });

    test(
      'never replaces records: a vault with records is refused untouched',
      () async {
        await fill();
        final before = vaultFile.readAsBytesSync();
        final staged = stageRestore(
          bundleOf(File(fixtures[0]).readAsStringSync()),
        );
        await expectLater(
          files.restore(staged, now: t0),
          backupError('RESTORE_TARGET_HAS_RECORDS'),
        );
        expect(vaultFile.readAsBytesSync(), before);
        expect(File('${vaultFile.path}.restoring').existsSync(), isFalse);
      },
    );

    test('a fresh vault (profile only) is kept aside, not deleted', () async {
      final r = repo();
      await r.open();
      await HeartbeatService(r).ensureSelfProfile();
      final fresh = vaultFile.readAsStringSync();
      final backup = File(fixtures[2]).readAsStringSync();
      final out = await files.restore(stageRestore(bundleOf(backup)), now: t0);
      expect(
        out.keptPrevious,
        '${vaultFile.path}.before-restore-20261007T120000Z',
      );
      expect(File(out.keptPrevious!).readAsStringSync(), fresh);
      expect(vaultFile.readAsStringSync(), backup);
    });

    test(
      'an unreadable live vault does not block recovery and is kept',
      () async {
        vaultFile.writeAsStringSync('garbage that is not a vault\n');
        final backup = File(fixtures[0]).readAsStringSync();
        final out = await files.restore(
          stageRestore(bundleOf(backup)),
          now: t0,
        );
        expect(
          File(out.keptPrevious!).readAsStringSync(),
          'garbage that is not a vault\n',
        );
        expect(vaultFile.readAsStringSync(), backup);
      },
    );

    test(
      'after a restore this session refuses writes until a restart',
      () async {
        final r = repo();
        await r.open();
        final me = (await HeartbeatService(r).ensureSelfProfile()).id;
        r.lock('RESTART_REQUIRED');
        expect(r.writable, isFalse);
        await expectLater(
          HeartbeatService(r).recordWeightKg(profileId: me, input: '70'),
          throwsA(
            isA<StorageWriteRefused>().having(
              (e) => e.code,
              'code',
              'RESTART_REQUIRED',
            ),
          ),
        );
      },
    );
  });
}

/// A bundle whose digest matches a payload the app cannot read.
String bundleOf2(String unreadableVault) {
  final d = {
    'manifest': {
      'format': 'hhos-backup',
      'format_version': 1,
      'created_at': '2026-10-07T12:00:00.000Z',
      'source_app_version': 'x',
      'source_revision': 'x',
      'vault_id': 'v',
      'vault_format_version': 99,
      'record_schema_versions': <int>[],
      'profile_count': 0,
      'record_count': 0,
      'skipped_entries': 0,
      'payload_sha256': sha256Hex(unreadableVault),
      'payload_bytes': utf8.encode(unreadableVault).length,
      'encryption': 'none-dev-only',
      'attachments': <Object?>[],
    },
    'payload': unreadableVault,
  };
  return jsonEncode(d);
}
