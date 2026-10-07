// Regression tests for the F005@v0.32 multi-agent review findings on the
// F002-F005 code (data integrity and restore safety). Each test failed on
// the code before its fix.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/backup/data_files_io.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';

Matcher backupError(String code) =>
    throwsA(isA<BackupError>().having((e) => e.code, 'code', code));

void main() {
  late Directory tmp;
  late File vault;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('hhos-review-');
    vault = File('${tmp.path}/$vaultFileName');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  LogRepository repo() => LogRepository(
    sink: FileLogSink(vault),
    durability: StorageDurability.localFile,
    location: vault.path,
  );

  Future<(HeartbeatService, String)> seeded() async {
    final r = repo();
    await r.open();
    final svc = HeartbeatService(r);
    final me = (await svc.ensureSelfProfile()).id;
    await svc.recordWeightKg(profileId: me, input: '70');
    return (svc, me);
  }

  group('torn writes', () {
    test('a torn last line is closed before the next write, so the new '
        'entry survives a reload', () async {
      final (_, me) = await seeded();
      vault.writeAsStringSync('{"op":"record.app', mode: FileMode.append);

      final second = repo();
      expect(
        (await second.open()).warnings.single.kind,
        LoadWarningKind.lastEntryIncomplete,
      );
      final saved = await HeartbeatService(second)
          .recordWeightKg(profileId: me, input: '71');

      final third = repo();
      final report = await third.open();
      expect(report.warnings.single.kind, LoadWarningKind.entryUnreadable);
      final ids = (await third.records(me)).map((r) => r.id);
      expect(
        ids,
        contains(saved.id),
        reason: 'the new entry was not swallowed',
      );
    });

    test(
      'a write cut inside a multi-byte character skips only that line',
      () async {
        final (svc, me) = await seeded();
        await svc.recordLab(
          profileId: me,
          input: const LabInput(
            analyte: 'Açlık kan şekeri',
            value: '92',
            notReported: false,
            unit: 'mg/dL',
            sampleDate: '2026-10-03',
          ),
        );
        // A torn append: the start of a line whose last byte cuts "µ" (C2 B5).
        final full = utf8.encode('{"op":"record.append","data":{"u":"µ');
        final torn = full.sublist(0, full.length - 1);
        vault.writeAsBytesSync(torn, mode: FileMode.append);

        final again = repo();
        final report = await again.open();
        expect(
          report.warnings.single.kind,
          LoadWarningKind.lastEntryIncomplete,
        );
        expect(
          (await again.records(me)).length,
          2,
          reason: 'nothing else lost',
        );
        expect(
          (await again.records(me)).last.lab!.analyteLabel,
          'Açlık kan şekeri',
        );
      },
    );

    test('a damaged byte in the middle is a skipped line, never a silent '
        'replacement character', () {
      final good = utf8.encode('{"a":"x"}\n');
      final bad = [...utf8.encode('{"a":"'), 0xFF, ...utf8.encode('"}\n')];
      final text = decodeLogBytes([...good, ...bad, ...good]);
      final lines = const LineSplitter().convert(text);
      expect(lines[0], '{"a":"x"}');
      expect(lines[1], isNot(contains('�')));
      expect(() => jsonDecode(lines[1]), throwsFormatException);
      expect(lines[2], '{"a":"x"}');
    });
  });

  group('restore never hides or replaces records', () {
    String bundle() => createBackupBundle(
      vaultLogText: File('test/fixtures/vault/v1_forge002.hhoslog.jsonl')
          .readAsStringSync(),
      appVersion: 'x',
      sourceRevision: 'x',
      createdAt: DateTime.utc(2026, 10, 7),
    );

    test('a vault written by a newer app is refused, untouched', () async {
      final newer = File('test/fixtures/vault/v1_f003_schema2.hhoslog.jsonl')
          .readAsStringSync()
          .replaceAll('"schema_version":2', '"schema_version":9');
      vault.writeAsStringSync(newer);
      final files = FileDataFiles(dataDir: tmp, vault: vault);
      await expectLater(
        files.restore(stageRestore(bundle()), now: DateTime.utc(2026, 10, 7)),
        backupError('RESTORE_TARGET_NEWER'),
      );
      expect(vault.readAsStringSync(), newer);
    });

    test(
      'a vault with a damaged header but stored records is refused',
      () async {
        await seeded();
        final damaged = vault.readAsStringSync().replaceFirst(
          '{"format"',
          '{"form',
        );
        vault.writeAsStringSync(damaged);
        final files = FileDataFiles(dataDir: tmp, vault: vault);
        await expectLater(
          files.restore(stageRestore(bundle()), now: DateTime.utc(2026, 10, 7)),
          backupError('RESTORE_TARGET_HAS_RECORDS'),
        );
        expect(vault.readAsStringSync(), damaged);
      },
    );
  });
}
