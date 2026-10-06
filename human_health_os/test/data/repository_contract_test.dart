// The same contract runs against every adapter that can run on the test VM.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/core/ids.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

class FixedClock implements Clock {
  FixedClock(this.t);
  DateTime t;
  @override
  DateTime nowUtc() => t;
}

class SeqIds implements IdGenerator {
  int n = 0;
  @override
  String newId() => 'id-${++n}';
}

typedef Factory = LogRepository Function();

void contract(String name, Factory make) {
  group(name, () {
    test('first open creates an empty vault with a stable id', () async {
      final repo = make();
      final report = await repo.open();
      expect(report.warnings, isEmpty);
      expect(repo.description.vaultId, isNotEmpty);
      expect(repo.description.encrypted, isFalse);
      expect(await repo.profiles(), isEmpty);
    });

    test('profile + weight round trip through the service', () async {
      final repo = make();
      await repo.open();
      final svc = HeartbeatService(
        repo,
        clock: FixedClock(DateTime.utc(2026, 10, 6, 9)),
      );
      final me = await svc.ensureSelfProfile();
      expect((await svc.ensureSelfProfile()).id, me.id); // idempotent
      final rec = await svc.recordWeightKg(profileId: me.id, input: '78,4');
      expect(rec.quantity, const Quantity(78.4, 'kg'));
      expect(rec.originalText, '78,4');
      final weights = await svc.currentWeights(me.id);
      expect(weights.single.id, rec.id);
    });

    test('blank or non-numeric input never becomes zero', () async {
      final repo = make();
      await repo.open();
      final svc = HeartbeatService(repo);
      final me = await svc.ensureSelfProfile();
      for (final bad in ['', '   ', 'abc', '78.4.1', '-5']) {
        await expectLater(
          svc.recordWeightKg(profileId: me.id, input: bad),
          throwsA(isA<InputError>()),
          reason: bad,
        );
      }
      await expectLater(
        svc.recordWeightKg(profileId: me.id, input: '0'),
        throwsA(isA<InputError>()),
      );
      expect(await svc.currentWeights(me.id), isEmpty);
    });

    test('records for an unknown profile are rejected', () async {
      final repo = make();
      await repo.open();
      final svc = HeartbeatService(repo);
      await expectLater(
        svc.recordWeightKg(profileId: 'nobody', input: '70'),
        throwsA(isA<RecordValidationError>()),
      );
    });

    test(
      'identical replay is idempotent; a conflicting duplicate id is rejected',
      () async {
        final repo = make();
        await repo.open();
        final svc = HeartbeatService(repo, ids: SeqIds());
        final me = await svc.ensureSelfProfile();
        final r = await svc.recordWeightKg(profileId: me.id, input: '80');
        await repo.appendRecord(r); // same bytes again
        expect((await repo.records(me.id)).length, 1);
        final conflicting = HealthRecord.fromJson(
          r.toJson()..['original_text'] = 'changed',
        );
        await expectLater(
          repo.appendRecord(conflicting),
          throwsA(isA<VaultFormatError>()),
        );
      },
    );
  });
}

void main() {
  contract('memory adapter', () => inMemoryRepository());

  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('hhos-vault-'));
  tearDown(() => tmp.deleteSync(recursive: true));
  LogRepository fileRepo(String dir) => LogRepository(
    sink: FileLogSink(File('$dir/$vaultFileName')),
    durability: StorageDurability.localFile,
    location: dir,
  );
  contract('file adapter', () => fileRepo(tmp.path));

  group('file adapter persistence', () {
    test(
      'close and reopen returns the same profile and record (heartbeat)',
      () async {
        final a = fileRepo(tmp.path);
        await a.open();
        final svc = HeartbeatService(a);
        final me = await svc.ensureSelfProfile();
        final rec = await svc.recordWeightKg(profileId: me.id, input: '81.2');

        final b = fileRepo(tmp.path); // "restart"
        expect((await b.open()).warnings, isEmpty);
        expect(b.description.vaultId, a.description.vaultId);
        final svc2 = HeartbeatService(b);
        expect((await svc2.ensureSelfProfile()).id, me.id);
        expect(
          (await svc2.currentWeights(me.id)).single.toJson(),
          rec.toJson(),
        );
      },
    );

    test('moving the vault folder keeps the same vault and profile (path ≠ identity)', () async {
      final a = fileRepo('${tmp.path}/one');
      await a.open();
      final me = await HeartbeatService(a).ensureSelfProfile();
      final moved = Directory('${tmp.path}/one').renameSync('${tmp.path}/two');
      final b = fileRepo(moved.path);
      await b.open();
      expect(b.description.vaultId, a.description.vaultId);
      expect((await b.profiles()).single.id, me.id);
    });

    test('an interrupted last write is skipped with a visible warning; earlier data survives', () async {
      final a = fileRepo(tmp.path);
      await a.open();
      final svc = HeartbeatService(a);
      final me = await svc.ensureSelfProfile();
      await svc.recordWeightKg(profileId: me.id, input: '70');
      File('${tmp.path}/$vaultFileName')
          .writeAsStringSync('{"op":"record.app', mode: FileMode.append);
      final b = fileRepo(tmp.path);
      final report = await b.open();
      expect(report.warnings.single, contains('incomplete'));
      expect((await HeartbeatService(b).currentWeights(me.id)).length, 1);
    });

    test(
      'a vault written by a newer app version is refused, not misread',
      () async {
        File('${tmp.path}/$vaultFileName')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '{"format":"hhos-vault-log","format_version":99,"vault_id":"v","created_at":"2026-10-06T00:00:00.000Z"}\n',
          );
        await expectLater(
          fileRepo(tmp.path).open(),
          throwsA(isA<VaultFormatError>()),
        );
      },
    );

    test('portable mode: portable_mode.json next to the executable selects UserData/', () {
      final exeDir = Directory('${tmp.path}/HumanHealthOS')..createSync();
      File('${exeDir.path}/portable_mode.json').writeAsStringSync('{}');
      final dir = resolveDataDirectory(
        env: const {},
        executablePath: '${exeDir.path}/human_health_os',
      );
      expect(dir!.path, '${exeDir.path}${Platform.pathSeparator}UserData');
    });

    test('XDG data dir on Linux; HHOS_DATA_DIR override wins', () {
      final exe = '${tmp.path}/bin/human_health_os';
      if (Platform.isLinux) {
        expect(
          resolveDataDirectory(
            env: const {'XDG_DATA_HOME': '/x/data'},
            executablePath: exe,
          )!.path,
          '/x/data/HumanHealthOS',
        );
        expect(
          resolveDataDirectory(
            env: const {'HOME': '/home/u'},
            executablePath: exe,
          )!.path,
          '/home/u/.local/share/HumanHealthOS',
        );
      }
      expect(
        resolveDataDirectory(
          env: const {'HHOS_DATA_DIR': '/custom'},
          executablePath: exe,
        )!.path,
        '/custom',
      );
    });
  });
}
