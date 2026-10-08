// F006@v0.32 encrypted vault: AC-2 (envelope around the unchanged log; no
// plaintext, secret or unwrapped key in the file), AC-3 (integrity: changed,
// moved, copied-in, missing and torn entries) and AC-4 (key states: create,
// unlock, wrong passphrase, recovery, key lost, unreadable). Cheap Argon2id
// parameters keep these fast; the production cost is checked in
// vault_crypto_test.dart and storage_policy_test.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/crypto/recovery_key.dart';
import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_envelope.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const pass = 'Mavi-Kedi 7 Ağaç Lamba!';
const analyte = 'Açlık kan şekeri';
const lab = 'Örnek Laboratuvarı';

KdfParams cheap() =>
    KdfParams(salt: randomBytes(16), memoryKib: 64, iterations: 1);

Matcher cryptoFailure(String code) =>
    throwsA(isA<CryptoFailure>().having((e) => e.code, 'code', code));
Matcher envelopeError(String code) =>
    throwsA(isA<VaultEnvelopeError>().having((e) => e.code, 'code', code));

EncryptedVault vaultOn(
  LogSink raw, {
  Future<String> Function(DateTime)? aside,
}) => EncryptedVault(
  raw: raw,
  location: 'test',
  durability: StorageDurability.localFile,
  newKdf: cheap,
  setAsideStore: aside,
);

/// Records every line the repository hands to the encrypted sink.
class SpySink implements LogSink {
  SpySink(this.inner);

  final LogSink inner;
  final lines = <String>[];

  @override
  Future<String?> read() => inner.read();

  @override
  Future<void> create(String text) {
    lines.add(text);
    return inner.create(text);
  }

  @override
  Future<void> appendLine(String line) {
    if (line.isNotEmpty) lines.add(line);
    return inner.appendLine(line);
  }
}

/// Fails the next append when [failNext] is set (a full disk).
class FlakySink extends MemoryLogSink {
  bool failNext = false;

  @override
  Future<void> appendLine(String line) async {
    if (failNext) {
      failNext = false;
      throw const FileSystemException('disk full');
    }
    return super.appendLine(line);
  }
}

/// Stores the line, then fails (a flush or close that fails after the
/// bytes reached the file).
class LandedThenFailsSink extends MemoryLogSink {
  bool failAfterNext = false;

  @override
  Future<void> appendLine(String line) async {
    await super.appendLine(line);
    if (failAfterNext && line.isNotEmpty) {
      failAfterNext = false;
      throw const FileSystemException('flush failed');
    }
  }
}

/// Refuses the next append before writing anything (a lock held by
/// another program).
class RefusingSink extends MemoryLogSink {
  bool refuseNext = false;

  @override
  Future<void> appendLine(String line) async {
    if (refuseNext) {
      refuseNext = false;
      throw const StorageWriteRefused('VAULT_WRITE_REFUSED');
    }
    return super.appendLine(line);
  }
}

/// The vault file is gone for a moment (moved away and back): appends fail
/// with a plain I/O error and reads find no file.
class GoneSink extends MemoryLogSink {
  String? away;

  void goAway() {
    away = text;
    text = null;
  }

  void comeBack() {
    text = away;
    away = null;
  }

  @override
  Future<void> appendLine(String line) async {
    if (away != null) throw const FileSystemException('no such file');
    return super.appendLine(line);
  }
}

/// Like [LandedThenFailsSink], on a store that cannot tell its size: only
/// the failed append itself tells the sink to read storage again.
class UnsizedLandedThenFails implements LogSink {
  final inner = MemoryLogSink();
  bool failAfterNext = false;

  @override
  Future<String?> read() => inner.read();

  @override
  Future<void> create(String text) => inner.create(text);

  @override
  Future<void> appendLine(String line) async {
    await inner.appendLine(line);
    if (failAfterNext && line.isNotEmpty) {
      failAfterNext = false;
      throw const FileSystemException('flush failed');
    }
  }
}

/// A store that exists but cannot be read (a lock or missing permissions).
class UnreadableSink extends MemoryLogSink {
  @override
  Future<String?> read() async =>
      throw const FileSystemException('permission denied');
}

/// An envelope (cheap key cost) around [innerLines], as a newer or damaged
/// writer would have stored it.
Future<MemoryLogSink> envelopeOf(List<String> innerLines, String key) async {
  final raw = MemoryLogSink();
  final sink = EncryptedLogSink.forNewVault(
    raw,
    passphrase: pass,
    recoveryKey: key,
    derive: deriveInline,
    newKdf: cheap,
  );
  await sink.create(innerLines.first);
  for (final l in innerLines.skip(1)) {
    await sink.appendLine(l);
  }
  return raw;
}

Future<(String, String)> seed(EncryptedVault v, {String? recovery}) async {
  final key = recovery ?? newRecoveryKey();
  final opened = await v.create(passphrase: pass, recoveryKey: key);
  final svc = HeartbeatService(opened.repository);
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
      laboratory: lab,
      sourceFlag: 'H',
    ),
  );
  await svc.recordWeightKg(profileId: me, input: '73,2');
  return (me, key);
}

Future<List<String>> recordJson(OpenedVault o, String me) async => [
  for (final r in await o.repository.records(me)) jsonEncode(r.toJson()),
];

List<String> lines(String text) => const LineSplitter().convert(text);

void main() {
  group('envelope (AC-2)', () {
    test('the opened envelope is exactly the log the repository wrote, line '
        'by line, and the vault reopens to the same records', () async {
      final raw = MemoryLogSink();
      final enc = EncryptedLogSink.forNewVault(
        raw,
        passphrase: pass,
        recoveryKey: newRecoveryKey(),
        derive: deriveInline,
        newKdf: cheap,
      );
      final spy = SpySink(enc);
      final repo = LogRepository(
        sink: spy,
        durability: StorageDurability.localFile,
        location: 'test',
        encrypted: true,
      );
      await repo.open();
      final svc = HeartbeatService(repo);
      final me = (await svc.ensureSelfProfile()).id;
      await svc.recordWeightKg(profileId: me, input: '80');
      final both = await enc.readBoth();
      expect(both.opened.inner, '${spy.lines.join('\n')}\n');
      expect(both.opened.unknown, 0);
      final header = jsonDecode(lines(both.opened.inner).first) as Map;
      expect(header['encryption'], 'hhos-vault-enc-v1');
      expect(repo.description.encrypted, isTrue);

      final again = await vaultOn(raw).unlock(pass);
      expect(again.report.warnings, isEmpty);
      expect(
        (await again.repository.records(me)).map((r) => r.id),
        (await repo.records(me)).map((r) => r.id),
      );
      expect(again.repository.description.vaultId, repo.description.vaultId);
    });

    test('measurements (F007) leave no kind code, note or typed value in '
        'the file', () async {
      final raw = MemoryLogSink();
      final (me, _) = await seed(vaultOn(raw));
      final o = await vaultOn(raw).unlock(pass);
      final svc = HeartbeatService(o.repository);
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.bloodPressure,
        input: const MeasurementInput(
          systolic: '131',
          diastolic: '87',
          context: 'sitting, left arm',
        ),
      );
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.waistCircumference,
        input: const MeasurementInput(value: '84,75'),
      );
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '57'),
      );
      final text = raw.text!;
      for (final s in [
        'vital.blood_pressure',
        'vital.resting_heart_rate',
        'body.waist_circumference',
        'blood_pressure',
        'systolic_text',
        'sitting, left arm',
        '84,75',
        'mmHg',
      ]) {
        expect(text, isNot(contains(s)), reason: s);
      }
      final again = await vaultOn(raw).unlock(pass);
      expect(again.report.warnings, isEmpty);
      expect(await again.repository.records(me), hasLength(6));
    });

    test('the file holds no plaintext, no secret and only the header fields '
        'it needs', () async {
      final raw = MemoryLogSink();
      final (_, key) = await seed(vaultOn(raw));
      final text = raw.text!;
      for (final s in [
        analyte,
        'kan şekeri',
        lab,
        'Laboratuvar',
        'record.append',
        'profile.put',
        'lab.result',
        'body.weight',
        'mg/dL',
        '73,6',
        '92,4',
        pass,
        key,
        key.replaceAll('-', ''),
        'hhos-vault-log',
      ]) {
        expect(text, isNot(contains(s)), reason: s);
      }
      final header = jsonDecode(lines(text).first) as Map<String, Object?>;
      expect(header.keys.toSet(), {
        'format',
        'envelope_version',
        'vault_id',
        'aead',
        'keys',
      });
      for (final slot in header['keys']! as List) {
        expect((slot as Map).keys.toSet(), {'kind', 'kdf', 'nonce', 'wrapped'});
        expect(base64Decode(slot['wrapped'] as String).length, 32 + 16);
      }
      for (final l in lines(text).skip(1)) {
        expect((jsonDecode(l) as Map).keys.toSet(), {'s', 'n', 'c'});
      }
    });
  });

  group('key states (AC-4)', () {
    test('NO_VAULT: inspect says create and writes nothing; a short '
        'passphrase is refused before anything is written', () async {
      final raw = MemoryLogSink();
      final v = vaultOn(raw);
      expect((await v.inspect()).access, VaultAccess.create);
      expect(raw.text, isNull);
      await expectLater(
        v.create(passphrase: 'short', recoveryKey: newRecoveryKey()),
        throwsArgumentError,
      );
      expect(raw.text, isNull);
    });

    test('LOCKED -> WRONG_PASSPHRASE: refused, nothing written; the right '
        'passphrase opens it', () async {
      final raw = MemoryLogSink();
      final (me, _) = await seed(vaultOn(raw));
      final before = raw.text;
      final v = vaultOn(raw);
      expect((await v.inspect()).access, VaultAccess.unlock);
      await expectLater(v.unlock('$pass '), cryptoFailure('NOT_AUTHENTIC'));
      await expectLater(v.unlock(''), cryptoFailure('NOT_AUTHENTIC'));
      expect(raw.text, before);
      final o = await v.unlock(pass);
      expect((await o.repository.records(me)).length, 3);
    });

    test('RECOVERY: the recovery key (typed loosely) opens it and sets a new '
        'passphrase; the old passphrase stops opening the file; entries '
        'stay byte for byte', () async {
      final raw = MemoryLogSink();
      final (me, key) = await seed(vaultOn(raw));
      final before = lines(raw.text!);
      final o = await vaultOn(raw).recover(
        recoveryKey: key.toLowerCase().replaceAll('-', ' '),
        newPassphrase: 'yeni uzun parola 2026',
      );
      expect((await o.repository.records(me)).length, 3);
      final after = lines(raw.text!);
      expect(after.skip(1), before.skip(1), reason: 'entries untouched');
      final oldHeader = jsonDecode(before.first) as Map;
      final newHeader = jsonDecode(after.first) as Map;
      expect(newHeader['vault_id'], oldHeader['vault_id']);
      expect(
        (newHeader['keys'] as List).last,
        (oldHeader['keys'] as List).last,
        reason: 'the recovery slot is unchanged',
      );
      await expectLater(
        vaultOn(raw).unlock(pass),
        cryptoFailure('NOT_AUTHENTIC'),
      );
      expect(
        (await (await vaultOn(raw).unlock('yeni uzun parola 2026')).repository
                .records(me))
            .length,
        3,
      );
      // The recovery key keeps working.
      await EncryptedLogSink.unlock(
        raw,
        key,
        kind: KeyKind.recovery,
        derive: deriveInline,
      );
    });

    test(
      'RECOVERY with a wrong or malformed key: refused, nothing written',
      () async {
        final raw = MemoryLogSink();
        await seed(vaultOn(raw));
        final before = raw.text;
        await expectLater(
          vaultOn(raw).recover(
            recoveryKey: newRecoveryKey(),
            newPassphrase: 'yeni uzun parola 2026',
          ),
          cryptoFailure('NOT_AUTHENTIC'),
        );
        await expectLater(
          vaultOn(raw).recover(
            recoveryKey: 'not a key',
            newPassphrase: 'yeni uzun parola 2026',
          ),
          throwsA(isA<RecoveryKeyFormatError>()),
        );
        expect(raw.text, before);
      },
    );

    test('KEY_LOST: the locked vault is set aside byte for byte, never '
        'deleted, still opens with its passphrase, and a new vault takes '
        'its place', () async {
      final tmp = Directory.systemTemp.createTempSync('hhos-keylost-');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final file = File('${tmp.path}/vault.hhosvault');
      EncryptedVault v() => vaultOn(
        FileLogSink(file),
        aside: (now) async {
          final kept = '${file.path}.locked-test';
          await file.rename(kept);
          return kept;
        },
      );
      await seed(v());
      final locked = file.readAsBytesSync();
      final kept = await v().setAside();
      expect(File(kept).readAsBytesSync(), locked);
      expect(file.existsSync(), isFalse);
      expect((await v().inspect()).access, VaultAccess.create);
      await v().create(
        passphrase: 'a brand new passphrase',
        recoveryKey: newRecoveryKey(),
      );
      expect(File(kept).readAsBytesSync(), locked, reason: 'kept untouched');
      await vaultOn(FileLogSink(File(kept))).unlock(pass);
    });

    test('create never overwrites anything stored', () async {
      final raw = MemoryLogSink()..text = 'something\n';
      await expectLater(
        vaultOn(raw).create(passphrase: pass, recoveryKey: newRecoveryKey()),
        envelopeError('VAULT_EXISTS'),
      );
      expect(raw.text, 'something\n');
    });

    test('UNREADABLE: newer envelope, plaintext log, damaged header, hostile '
        'key cost: refused and untouched', () async {
      final raw = MemoryLogSink();
      await seed(vaultOn(raw));
      final good = raw.text!;
      String withHeader(void Function(Map<String, Object?> h) f) {
        final ls = lines(good);
        final h = (jsonDecode(ls.first) as Map).cast<String, Object?>();
        f(h);
        return '${[jsonEncode(h), ...ls.skip(1)].join('\n')}\n';
      }

      final cases = {
        'ENVELOPE_NEWER': withHeader((h) => h['envelope_version'] = 2),
        'ENVELOPE_UNSUPPORTED': withHeader((h) => h['aead'] = 'aes-256-gcm'),
        'ENVELOPE_UNREADABLE': '{"format":"hhos-vault-enc"\n',
        'NOT_ENCRYPTED': File(
          'test/fixtures/vault/v1_f004_schema3.hhoslog.jsonl',
        ).readAsStringSync(),
      };
      cases['ENVELOPE_UNSUPPORTED '] = withHeader((h) {
        final keys = (h['keys']! as List).cast<Map<String, Object?>>();
        (keys.first['kdf']! as Map)['memory_kib'] = 1 << 30;
      });
      for (final e in cases.entries) {
        final store = MemoryLogSink()..text = e.value;
        final i = await vaultOn(store).inspect();
        expect(i.access, VaultAccess.unreadable, reason: e.key);
        expect(i.code, e.key.trim());
        await expectLater(
          vaultOn(store).unlock(pass),
          envelopeError(e.key.trim()),
        );
        expect(store.text, e.value, reason: 'untouched: ${e.key}');
      }
    });

    test('a changed vault id in the header makes every key fail', () async {
      final raw = MemoryLogSink();
      await seed(vaultOn(raw));
      raw.text = raw.text!.replaceFirst(
        RegExp(r'"vault_id":"[^"]+"'),
        '"vault_id":"00000000-0000-4000-8000-000000000000"',
      );
      await expectLater(
        vaultOn(raw).unlock(pass),
        cryptoFailure('NOT_AUTHENTIC'),
      );
    });
  });

  group('review fixes (F006)', () {
    test('recovery on a vault whose log this app cannot use writes nothing: '
        'newer log, damaged log header (review finding)', () async {
      final key = newRecoveryKey();
      final newer = await envelopeOf([
        '{"format":"hhos-vault-log","format_version":2,"vault_id":"v2",'
            '"created_at":"2026-10-01T00:00:00.000Z",'
            '"encryption":"hhos-vault-enc-v1"}',
      ], key);
      final damaged = MemoryLogSink();
      await seed(vaultOn(damaged), recovery: key);
      damaged.text = (damaged.text!.split('\n')..removeAt(1)).join('\n');
      for (final (name, raw, code) in [
        ('newer', newer, 'VAULT_NEWER'),
        ('damaged', damaged, 'VAULT_HEADER_UNREADABLE'),
      ]) {
        final before = raw.text;
        await expectLater(
          vaultOn(
            raw,
          ).recover(recoveryKey: key, newPassphrase: 'a brand new passphrase'),
          throwsA(isA<VaultFormatError>().having((e) => e.code, 'code', code)),
          reason: name,
        );
        expect(raw.text, before, reason: '$name: not a byte changed');
        // The old passphrase still opens the envelope.
        await EncryptedLogSink.unlock(
          raw,
          pass,
          kind: KeyKind.passphrase,
          derive: deriveInline,
        );
      }
    });

    test(
      'a write that landed before its flush failed: the sequence number '
      'is not reused, so the next confirmed entry replays (review finding)',
      () async {
        final raw = LandedThenFailsSink();
        final (me, _) = await seed(vaultOn(raw));
        final o = await vaultOn(raw).unlock(pass);
        final svc = HeartbeatService(o.repository);
        raw.failAfterNext = true;
        await expectLater(
          svc.recordWeightKg(profileId: me, input: '71'),
          throwsA(isA<FileSystemException>()),
        );
        final confirmed = await svc.recordWeightKg(profileId: me, input: '70');
        final again = await vaultOn(raw).unlock(pass);
        expect(again.report.warnings, isEmpty);
        final ids = (await again.repository.records(me)).map((r) => r.id);
        expect(ids, contains(confirmed.id), reason: 'the confirmed entry');
        // The entry reported as failed landed after all: it replays too, and
        // the save-failure text says it may be stored.
        expect(ids.length, 5);
      },
    );

    test('a write refused before anything was stored keeps its number: no '
        'false "missing entry" and no blank line after the next save '
        '(fix-round finding)', () async {
      final raw = RefusingSink();
      final (me, _) = await seed(vaultOn(raw));
      final o = await vaultOn(raw).unlock(pass);
      final svc = HeartbeatService(o.repository);
      raw.refuseNext = true;
      await expectLater(
        svc.recordWeightKg(profileId: me, input: '71'),
        throwsA(isA<StorageWriteRefused>()),
      );
      final before = raw.text!;
      final saved = await svc.recordWeightKg(profileId: me, input: '70');
      expect(raw.text!.substring(before.length), startsWith('{'));
      final again = await vaultOn(raw).unlock(pass);
      expect(again.report.warnings, isEmpty);
      final ids = (await again.repository.records(me)).map((r) => r.id);
      expect(ids, contains(saved.id));
      expect(ids.length, 4, reason: 'the refused entry is not there');
    });

    test('a write that failed while the vault file was gone does not use up '
        'its number once the file is back (fix-round finding)', () async {
      final raw = GoneSink();
      final (me, _) = await seed(vaultOn(raw));
      final o = await vaultOn(raw).unlock(pass);
      final svc = HeartbeatService(o.repository);
      raw.goAway();
      await expectLater(
        svc.recordWeightKg(profileId: me, input: '71'),
        throwsA(isA<FileSystemException>()),
      );
      raw.comeBack();
      final saved = await svc.recordWeightKg(profileId: me, input: '70');
      final again = await vaultOn(raw).unlock(pass);
      expect(again.report.warnings, isEmpty);
      final ids = (await again.repository.records(me)).map((r) => r.id);
      expect(ids, contains(saved.id));
      expect(ids.length, 4);
    });

    test("two windows on one vault: each learns the other's numbers before "
        'writing, so no saved entry is hidden (fix-round finding)', () async {
      final raw = MemoryLogSink();
      final (me, _) = await seed(vaultOn(raw));
      final a = await vaultOn(raw).unlock(pass);
      final b = await vaultOn(raw).unlock(pass);
      final first = await HeartbeatService(a.repository)
          .recordWeightKg(profileId: me, input: '80');
      final second = await HeartbeatService(b.repository)
          .recordWeightKg(profileId: me, input: '81');
      final third = await HeartbeatService(a.repository)
          .recordWeightKg(profileId: me, input: '82');
      final again = await vaultOn(raw).unlock(pass);
      expect(again.report.warnings, isEmpty);
      final ids = (await again.repository.records(me)).map((r) => r.id);
      expect(ids, containsAll([first.id, second.id, third.id]));
      expect(ids.length, 6);
    });

    test('a vault replaced by another window (set aside, a new vault in its '
        'place) is never appended to: VAULT_CHANGED, nothing written '
        '(fix-round finding)', () async {
      final raw = MemoryLogSink();
      final (me, _) = await seed(vaultOn(raw));
      final a = await vaultOn(raw).unlock(pass);
      raw.text = null;
      await vaultOn(raw).create(
        passphrase: 'another long passphrase',
        recoveryKey: newRecoveryKey(),
      );
      final replaced = raw.text;
      await expectLater(
        HeartbeatService(a.repository)
            .recordWeightKg(profileId: me, input: '80'),
        throwsA(
          isA<StorageWriteRefused>().having(
            (e) => e.code,
            'code',
            'VAULT_CHANGED',
          ),
        ),
      );
      expect(raw.text, replaced);
    });

    test('on a store that cannot tell its size, a write that landed before '
        'its flush failed is still learned from storage before the next '
        'number is used', () async {
      final raw = UnsizedLandedThenFails();
      final (me, _) = await seed(vaultOn(raw));
      final o = await vaultOn(raw).unlock(pass);
      final svc = HeartbeatService(o.repository);
      raw.failAfterNext = true;
      await expectLater(
        svc.recordWeightKg(profileId: me, input: '71'),
        throwsA(isA<FileSystemException>()),
      );
      final confirmed = await svc.recordWeightKg(profileId: me, input: '70');
      final again = await vaultOn(raw).unlock(pass);
      expect(again.report.warnings, isEmpty);
      final ids = (await again.repository.records(me)).map((r) => r.id);
      expect(ids, contains(confirmed.id));
      expect(ids.length, 5);
    });

    test('a header without a passphrase slot: recovery adds one, and the new '
        'passphrase opens the vault (review finding)', () async {
      final raw = MemoryLogSink();
      final (me, key) = await seed(vaultOn(raw));
      final ls = raw.text!.split('\n');
      final h = (jsonDecode(ls.first) as Map).cast<String, Object?>();
      h['keys'] = [
        for (final k in h['keys']! as List)
          if ((k as Map)['kind'] != 'passphrase') k,
      ];
      ls[0] = jsonEncode(h);
      raw.text = ls.join('\n');
      await expectLater(
        vaultOn(raw).unlock(pass),
        envelopeError('NO_SUCH_KEY'),
      );
      await vaultOn(raw)
          .recover(recoveryKey: key, newPassphrase: 'a brand new passphrase');
      final o = await vaultOn(raw).unlock('a brand new passphrase');
      expect((await o.repository.records(me)).length, 3);
    });

    test('a store that exists but cannot be read is unreadable '
        '(VAULT_READ_FAILED), never a new vault', () async {
      final i = await vaultOn(UnreadableSink()).inspect();
      expect(i.access, VaultAccess.unreadable);
      expect(i.code, 'VAULT_READ_FAILED');
    });
  });

  group('integrity (AC-3)', () {
    Future<(MemoryLogSink, String, List<String>)> seeded() async {
      final raw = MemoryLogSink();
      final (me, _) = await seed(vaultOn(raw));
      return (raw, me, lines(raw.text!));
    }

    Future<(LoadReport, List<String>)> reopen(
      MemoryLogSink raw,
      String me,
    ) async {
      final o = await vaultOn(raw).unlock(pass);
      return (o.report, await recordJson(o, me));
    }

    test('a changed entry is skipped with a warning; the rest is intact; the '
        'file is not repaired', () async {
      final (raw, me, ls) = await seeded();
      final all = (await reopen(raw, me)).$2;
      // ls: 0 envelope header, 1 log header, 2 profile, 3 weight, 4 lab, 5 weight
      final m = (jsonDecode(ls[4]) as Map).cast<String, Object?>();
      final c = base64Decode(m['c']! as String)..[3] ^= 0x01;
      m['c'] = base64Encode(c);
      final tampered = [...ls]..[4] = jsonEncode(m);
      raw.text = '${tampered.join('\n')}\n';
      final (report, records) = await reopen(raw, me);
      expect(report.warnings.single.kind, LoadWarningKind.entryUnreadable);
      expect(records, [all[0], all[2]]);
      expect(raw.text, '${tampered.join('\n')}\n');
    });

    test('a removed entry is reported as missing, never silently', () async {
      final (raw, me, ls) = await seeded();
      raw.text = '${([...ls]..removeAt(3)).join('\n')}\n';
      final (report, records) = await reopen(raw, me);
      expect(report.warnings.single.kind, LoadWarningKind.entryMissing);
      expect(records.length, 2);
    });

    test('swapped entries: the one out of place is not applied, and both '
        'problems are shown', () async {
      final (raw, me, ls) = await seeded();
      final swapped = [...ls];
      swapped[3] = ls[4];
      swapped[4] = ls[3];
      raw.text = '${swapped.join('\n')}\n';
      final (report, records) = await reopen(raw, me);
      expect(report.warnings.map((w) => w.kind).toSet(), {
        LoadWarningKind.entryMissing,
        LoadWarningKind.entryUnreadable,
      });
      expect(records.length, 2);
    });

    test(
      'a sealed entry moved to another position, with its number '
      'rewritten to fit, never authenticates (the number is bound in)',
      () async {
        final (raw, me, ls) = await seeded();
        final a = (jsonDecode(ls[3]) as Map).cast<String, Object?>();
        final b = (jsonDecode(ls[4]) as Map).cast<String, Object?>();
        // Swap the sealed contents, keep the sequence numbers in order.
        final moved = [...ls]
          ..[3] = jsonEncode({'s': a['s'], 'n': b['n'], 'c': b['c']})
          ..[4] = jsonEncode({'s': b['s'], 'n': a['n'], 'c': a['c']});
        raw.text = '${moved.join('\n')}\n';
        final (report, records) = await reopen(raw, me);
        expect(report.warnings.map((w) => w.kind), [
          LoadWarningKind.entryUnreadable,
          LoadWarningKind.entryUnreadable,
        ]);
        expect(records.length, 1);
      },
    );

    test('a copied entry (replayed in the same vault, or taken from another '
        'vault) is never applied', () async {
      final (raw, me, ls) = await seeded();
      raw.text = '${[...ls, ls[3]].join('\n')}\n';
      var (report, records) = await reopen(raw, me);
      expect(
        report.warnings.single.kind,
        LoadWarningKind.entryUnreadable,
        reason: 'a complete line, not an interrupted save',
      );
      expect(records.length, 3, reason: 'no duplicate');

      final other = MemoryLogSink();
      await seed(vaultOn(other));
      final foreign = lines(other.text!)[3];
      raw.text = '${[...ls.take(5), foreign, ls[5]].join('\n')}\n';
      (report, records) = await reopen(raw, me);
      expect(report.warnings.single.kind, LoadWarningKind.entryUnreadable);
      expect(records.length, 3);
    });

    test('the log header (entry 0) is required: without it the vault does '
        'not open, and nothing is written', () async {
      final (raw, me, ls) = await seeded();
      final broken = '${([...ls]..removeAt(1)).join('\n')}\n';
      raw.text = broken;
      await expectLater(
        vaultOn(raw).unlock(pass),
        throwsA(isA<VaultFormatError>()),
      );
      expect(raw.text, broken);
    });

    test('an envelope without any entry is damaged, never a new vault: '
        'the unlock fails as unreadable and nothing is written', () async {
      final (raw, _, ls) = await seeded();
      raw.text = '${ls.first}\n';
      await expectLater(
        vaultOn(raw).unlock(pass),
        throwsA(
          isA<VaultFormatError>().having(
            (e) => e.code,
            'code',
            'VAULT_HEADER_UNREADABLE',
          ),
        ),
      );
      expect(raw.text, '${ls.first}\n');
    });

    test('a torn last write is closed before the next one, and the next '
        'entry survives a reload', () async {
      final (raw, me, ls) = await seeded();
      raw.text = '${raw.text!}{"s":6,"n":"AAAA';
      final o = await vaultOn(raw).unlock(pass);
      expect(
        o.report.warnings.single.kind,
        LoadWarningKind.lastEntryIncomplete,
      );
      final saved = await HeartbeatService(o.repository)
          .recordWeightKg(profileId: me, input: '72');
      final (report, records) = await reopen(raw, me);
      expect(report.warnings.single.kind, LoadWarningKind.entryUnreadable);
      expect(records.length, 4);
      expect(records.last, contains(saved.id));
    });

    test('a write that failed completely is not later reported as a removed '
        'entry', () async {
      final raw = FlakySink();
      final (me, _) = await seed(vaultOn(raw));
      final o = await vaultOn(raw).unlock(pass);
      final svc = HeartbeatService(o.repository);
      raw.failNext = true;
      await expectLater(
        svc.recordWeightKg(profileId: me, input: '71'),
        throwsA(isA<FileSystemException>()),
      );
      await svc.recordWeightKg(profileId: me, input: '70');
      final again = await vaultOn(raw).unlock(pass);
      expect(again.report.warnings, isEmpty);
      expect((await again.repository.records(me)).length, 4);
    });
  });
}
