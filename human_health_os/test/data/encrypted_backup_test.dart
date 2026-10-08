// F006@v0.32 AC-6: an encrypted vault's backup is its envelope byte for
// byte; restoring it needs and verifies the backup's own passphrase or
// recovery key before anything is switched; plaintext and encrypted
// backups never cross into the other kind of vault; the restore drill
// (backup -> lose the vault -> new vault -> restore -> unlock) gives back
// the same records.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/backup/data_files_io.dart';
import 'package:human_health_os/src/data/crypto/recovery_key.dart';
import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_envelope.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';

const pass = 'Mavi-Kedi 7 Ağaç Lamba!';
const analyte = 'Açlık kan şekeri';
final t0 = DateTime.utc(2026, 10, 7, 12);

KdfParams cheap() =>
    KdfParams(salt: randomBytes(16), memoryKib: 64, iterations: 1);

Matcher backupError(String code) =>
    throwsA(isA<BackupError>().having((e) => e.code, 'code', code));

void main() {
  late Directory tmp;
  late File file;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('hhos-encbackup-');
    file = File('${tmp.path}/vault.hhosvault');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  EncryptedVault vault() => EncryptedVault(
    raw: FileLogSink(file),
    location: file.path,
    newKdf: cheap,
    setAsideStore: (now) async {
      final kept = '${file.path}.locked-${fileStamp(now)}';
      await file.rename(kept);
      return kept;
    },
    filesFor: (sink) => FileDataFiles(
      dataDir: tmp,
      vault: file,
      target: RestoreTarget.encrypted(sink.open),
    ),
  );

  Future<(OpenedVault, String, String)> seeded() async {
    final key = newRecoveryKey();
    final o = await vault().create(passphrase: pass, recoveryKey: key);
    final svc = HeartbeatService(o.repository);
    final me = (await svc.ensureSelfProfile()).id;
    await svc.recordWeightKg(profileId: me, input: '73,6');
    await svc.recordLab(
      profileId: me,
      input: const LabInput(
        analyte: analyte,
        value: '92,4',
        notReported: false,
        unit: 'mg/dL',
        sampleDate: '2026-10-03',
      ),
    );
    return (o, me, key);
  }

  Future<String> backupOf(OpenedVault o) async {
    final both = await o.sink.readBoth();
    return createEncryptedBackupBundle(
      envelopeText: both.raw,
      innerLogText: both.opened.inner,
      appVersion: 't',
      sourceRevision: 't',
      createdAt: t0,
    );
  }

  test('the payload is the envelope byte for byte; the manifest says '
      'encrypted; no plaintext anywhere in the bundle', () async {
    final (o, _, key) = await seeded();
    final bundle = await backupOf(o);
    final d = (jsonDecode(bundle) as Map).cast<String, Object?>();
    expect(d['payload'], file.readAsStringSync());
    final m = (d['manifest']! as Map).cast<String, Object?>();
    expect(m['encryption'], 'hhos-vault-enc-v1');
    expect(m['record_count'], 2);
    expect(m['vault_id'], o.repository.description.vaultId);
    for (final s in [analyte, 'mg/dL', '73,6', '92,4', pass, key]) {
      expect(bundle, isNot(contains(s)), reason: s);
    }
  });

  test('staging needs the key; a wrong key is refused; the right passphrase '
      'or the recovery key opens and checks the content', () async {
    final (o, _, key) = await seeded();
    final staged = stageRestore(await backupOf(o));
    expect(staged.encrypted, isTrue);
    expect(staged.needsKey, isTrue);
    await expectLater(
      unlockStagedRestore(
        staged,
        'wrong passphrase!',
        kind: KeyKind.passphrase,
      ),
      backupError('BACKUP_KEY_WRONG'),
    );
    await expectLater(
      unlockStagedRestore(staged, newRecoveryKey(), kind: KeyKind.recovery),
      backupError('BACKUP_KEY_WRONG'),
    );
    final byPass = await unlockStagedRestore(
      staged,
      pass,
      kind: KeyKind.passphrase,
    );
    expect(byPass.state!.records.length, 2);
    final byKey = await unlockStagedRestore(
      staged,
      key.toLowerCase(),
      kind: KeyKind.recovery,
    );
    expect(byKey.state!.records.length, 2);
  });

  test('a changed payload is refused (checksum), and so is one whose '
      'checksum was recomputed (content check after opening)', () async {
    final (o, _, _) = await seeded();
    final bundle = await backupOf(o);
    final d = (jsonDecode(bundle) as Map).cast<String, Object?>();
    final payload = d['payload']! as String;
    final ls = const LineSplitter().convert(payload);
    final entry = (jsonDecode(ls[3]) as Map).cast<String, Object?>();
    final c = base64Decode(entry['c']! as String)..[0] ^= 1;
    entry['c'] = base64Encode(c);
    final changed = '${([...ls]..[3] = jsonEncode(entry)).join('\n')}\n';
    d['payload'] = changed;
    expect(() => stageRestore(jsonEncode(d)), backupError('DIGEST_MISMATCH'));
    final m = (d['manifest']! as Map).cast<String, Object?>();
    m['payload_sha256'] = sha256Hex(changed);
    m['payload_bytes'] = utf8.encode(changed).length;
    final staged = stageRestore(jsonEncode(d));
    await expectLater(
      unlockStagedRestore(staged, pass, kind: KeyKind.passphrase),
      backupError('COUNT_MISMATCH'),
    );
  });

  test('restore drill: backup -> vault lost -> new vault -> restore with the '
      "backup's passphrase -> restart -> the same records", () async {
    final (o, me, _) = await seeded();
    final before = [
      for (final r in await o.repository.records(me)) jsonEncode(r.toJson()),
    ];
    await o.files!.save(
      DataFileKind.backup,
      'b.hhosbackup.json',
      await backupOf(o),
    );
    final lost = file.readAsBytesSync();
    file.deleteSync(); // the disaster

    // A fresh start creates a new vault with another passphrase.
    final fresh = await vault().create(
      passphrase: 'another long passphrase',
      recoveryKey: newRecoveryKey(),
    );
    await HeartbeatService(fresh.repository).ensureSelfProfile();
    final files = fresh.files!;
    final saved = (await files.backups()).single;
    final staged = await unlockStagedRestore(
      stageRestore(await files.read(saved)),
      pass,
      kind: KeyKind.passphrase,
    );
    final out = await files.restore(staged, now: t0);
    expect(out.records, 2);
    expect(File(out.keptPrevious!).existsSync(), isTrue, reason: 'kept');
    expect(file.readAsBytesSync(), lost, reason: 'byte for byte');

    final after = await vault().unlock(pass);
    expect([
      for (final r in await after.repository.records(me))
        jsonEncode(r.toJson()),
    ], before);
    await expectLater(
      vault().unlock('another long passphrase'),
      throwsA(isA<CryptoFailure>()),
    );
  });

  test('never over records: refused while the live vault holds records or '
      'entries it cannot read; the file is untouched', () async {
    final (o, me, _) = await seeded();
    final staged = await unlockStagedRestore(
      stageRestore(await backupOf(o)),
      pass,
      kind: KeyKind.passphrase,
    );
    final live = file.readAsStringSync();
    await expectLater(
      o.files!.restore(staged, now: t0),
      backupError('RESTORE_TARGET_HAS_RECORDS'),
    );
    expect(file.readAsStringSync(), live);

    // A vault with only its profile, but one entry that does not open.
    file.deleteSync();
    final fresh = await vault().create(
      passphrase: 'another long passphrase',
      recoveryKey: newRecoveryKey(),
    );
    await HeartbeatService(fresh.repository).ensureSelfProfile();
    file.writeAsStringSync(
      '{"s":2,"n":"AAAAAAAAAAAAAAAA","c":"AAAAAAAAAAAAAAAAAAAAAA=="}\n',
      mode: FileMode.append,
    );
    final damaged = file.readAsStringSync();
    await expectLater(
      fresh.files!.restore(staged, now: t0),
      backupError('RESTORE_TARGET_HAS_RECORDS'),
    );
    expect(file.readAsStringSync(), damaged);
    expect(me, isNotEmpty);
  });

  test('plaintext and encrypted backups never cross', () async {
    final (o, _, _) = await seeded();
    final encrypted = await unlockStagedRestore(
      stageRestore(await backupOf(o)),
      pass,
      kind: KeyKind.passphrase,
    );
    final plain = stageRestore(
      createBackupBundle(
        vaultLogText: File('test/fixtures/vault/v1_f004_schema3.hhoslog.jsonl')
            .readAsStringSync(),
        appVersion: 't',
        sourceRevision: 't',
        createdAt: t0,
      ),
    );
    file.deleteSync();
    final fresh = await vault().create(
      passphrase: 'another long passphrase',
      recoveryKey: newRecoveryKey(),
    );
    final live = file.readAsStringSync();
    await expectLater(
      fresh.files!.restore(plain, now: t0),
      backupError('BACKUP_KIND_MISMATCH'),
    );
    expect(file.readAsStringSync(), live);

    final devVault = File('${tmp.path}/dev/$vaultFileName');
    final devFiles = FileDataFiles(dataDir: tmp, vault: devVault);
    await expectLater(
      devFiles.restore(encrypted, now: t0),
      backupError('BACKUP_KIND_MISMATCH'),
    );
    expect(devVault.existsSync(), isFalse);

    final locked = stageRestore(await backupOf(fresh));
    await expectLater(
      fresh.files!.restore(locked, now: t0),
      backupError('BACKUP_KEY_NEEDED'),
    );
  });

  test('a manifest that names another vault is refused', () async {
    final (o, _, _) = await seeded();
    final d = (jsonDecode(await backupOf(o)) as Map).cast<String, Object?>();
    (d['manifest']! as Map)['vault_id'] = 'someone-else';
    expect(() => stageRestore(jsonEncode(d)), backupError('VAULT_ID_MISMATCH'));
  });

  group('review fixes on real files (F006)', () {
    test('an append never re-creates a vault file that disappeared', () async {
      final (o, me, _) = await seeded();
      file.deleteSync();
      await expectLater(
        HeartbeatService(o.repository)
            .recordWeightKg(profileId: me, input: '70'),
        throwsA(
          isA<StorageWriteRefused>().having(
            (e) => e.code,
            'code',
            'VAULT_MISSING',
          ),
        ),
      );
      expect(file.existsSync(), isFalse, reason: 'no headerless file');
    });

    test('a save refused while the vault file was moved away leaves no false '
        '"missing entry" once it is back (fix-round finding)', () async {
      final (o, me, _) = await seeded();
      final bytes = file.readAsBytesSync();
      file.deleteSync();
      final svc = HeartbeatService(o.repository);
      await expectLater(
        svc.recordWeightKg(profileId: me, input: '70'),
        throwsA(
          isA<StorageWriteRefused>().having(
            (e) => e.code,
            'code',
            'VAULT_MISSING',
          ),
        ),
      );
      file.writeAsBytesSync(bytes);
      await svc.recordWeightKg(profileId: me, input: '71');
      final again = await vault().unlock(pass);
      expect(again.report.warnings, isEmpty);
      expect(await again.repository.records(me), hasLength(3));
    });

    test('two windows on one vault file: no saved entry is hidden '
        '(fix-round finding)', () async {
      final (_, me, _) = await seeded();
      final a = await vault().unlock(pass);
      final b = await vault().unlock(pass);
      await HeartbeatService(a.repository)
          .recordWeightKg(profileId: me, input: '80');
      await HeartbeatService(b.repository)
          .recordWeightKg(profileId: me, input: '81');
      await HeartbeatService(a.repository)
          .recordWeightKg(profileId: me, input: '82');
      final again = await vault().unlock(pass);
      expect(again.report.warnings, isEmpty);
      expect(await again.repository.records(me), hasLength(5));
    });

    test('a new passphrase keeps every byte after line 1, also a line that '
        'does not decode', () async {
      final (_, _, key) = await seeded();
      final bytes = file.readAsBytesSync();
      final newlines = [
        for (var i = 0; i < bytes.length; i++)
          if (bytes[i] == 0x0A) i,
      ];
      bytes[newlines[2] + 12] = 0xC1; // not valid UTF-8, inside a sealed line
      file.writeAsBytesSync(bytes);
      final rest = bytes.sublist(newlines[0] + 1);
      final opened = await vault().recover(
        recoveryKey: key,
        newPassphrase: 'a brand new passphrase',
      );
      expect(
        opened.report.warnings.single.kind,
        LoadWarningKind.entryUnreadable,
      );
      final after = file.readAsBytesSync();
      expect(after.sublist(after.indexOf(0x0A) + 1), rest);
      await vault().unlock('a brand new passphrase');
    });

    Future<
      (
        FileDataFiles Function(Future<void> Function(File, String)),
        StagedRestore,
        List<int>,
      )
    >
    restoreSetup() async {
      final (o, _, _) = await seeded();
      final bundle = await backupOf(o);
      file.deleteSync();
      final fresh = await vault().create(
        passphrase: 'another long passphrase',
        recoveryKey: newRecoveryKey(),
      );
      await HeartbeatService(fresh.repository).ensureSelfProfile();
      final staged = await unlockStagedRestore(
        stageRestore(bundle),
        pass,
        kind: KeyKind.passphrase,
      );
      return (
        (Future<void> Function(File, String) rename) => FileDataFiles(
          dataDir: tmp,
          vault: file,
          target: RestoreTarget.encrypted(fresh.sink.open),
          rename: rename,
        ),
        staged,
        file.readAsBytesSync().toList(),
      );
    }

    test('a restore whose last move fails: the session stops writing first, '
        'the previous vault goes back in place (review finding)', () async {
      final (filesWith, staged, live) = await restoreSetup();
      var locked = false;
      final files = filesWith((f, to) async {
        if (f.path.endsWith('.restoring')) {
          throw const FileSystemException('held by another program');
        }
        await f.rename(to);
      });
      await expectLater(
        files.restore(staged, now: t0, beforeSwitch: () => locked = true),
        throwsA(
          isA<BackupError>()
              .having((e) => e.code, 'code', 'RESTORE_SWITCH_FAILED')
              .having((e) => e.message, 'kept at', ''),
        ),
      );
      expect(locked, isTrue);
      expect(file.readAsBytesSync(), live, reason: 'back in place');
      expect(File('${file.path}.restoring').existsSync(), isFalse);
      expect(
        tmp.listSync().where((e) => e.path.contains('before-restore')),
        isEmpty,
      );
    });

    test('a restore whose first move fails changed nothing and says so; '
        'writes stay paused as a precaution (fix-round finding)', () async {
      final (filesWith, staged, live) = await restoreSetup();
      var locked = false;
      final files = filesWith((f, to) async {
        if (to.contains('before-restore')) {
          throw const FileSystemException('held by another program');
        }
        await f.rename(to);
      });
      await expectLater(
        files.restore(staged, now: t0, beforeSwitch: () => locked = true),
        backupError('RESTORE_NOT_SWITCHED'),
      );
      expect(locked, isTrue);
      expect(file.readAsBytesSync(), live);
      expect(File('${file.path}.restoring').existsSync(), isFalse);
    });

    test('with no live vault, a failed move changed nothing and says so '
        '(fix-round finding)', () async {
      final (filesWith, staged, _) = await restoreSetup();
      file.deleteSync();
      final files = filesWith((f, to) async {
        if (f.path.endsWith('.restoring')) {
          throw const FileSystemException('held by another program');
        }
        await f.rename(to);
      });
      await expectLater(
        files.restore(staged, now: t0, beforeSwitch: () {}),
        backupError('RESTORE_NOT_SWITCHED'),
      );
      expect(file.existsSync(), isFalse);
      expect(File('${file.path}.restoring').existsSync(), isFalse);
    });

    test('when even the move back fails, the previous vault is kept and its '
        'place is named, never lost', () async {
      final (filesWith, staged, live) = await restoreSetup();
      final files = filesWith((f, to) async {
        if (f.path.endsWith('.restoring') ||
            f.path.contains('before-restore')) {
          throw const FileSystemException('held by another program');
        }
        await f.rename(to);
      });
      try {
        await files.restore(staged, now: t0, beforeSwitch: () {});
        fail('the restore should fail');
      } on BackupError catch (e) {
        expect(e.code, 'RESTORE_SWITCH_FAILED');
        expect(e.message, contains('before-restore'));
        expect(File(e.message).readAsBytesSync(), live);
      }
    });
  });
}
