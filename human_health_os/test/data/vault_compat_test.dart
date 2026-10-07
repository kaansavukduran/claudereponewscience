// F002@v0.32: vault compatibility metadata, migration graph, migration
// receipts, fixtures and replay validation (master §33.3, §35; gaps G-15,
// G-18).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/data/local/vault_migrations.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/profile/profile.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const fixtureV1 = 'test/fixtures/vault/v1_forge002.hhoslog.jsonl';
const selfId = '00000000-0000-4000-8000-0000000000a1';

String header({Object? version = 1, bool withId = true}) => jsonEncode({
  'format': 'hhos-vault-log',
  'format_version': ?version,
  if (withId) 'vault_id': 'v',
  'created_at': '2026-10-01T06:00:00.000Z',
  'encryption': 'none-dev-only',
});

String profileLine({int schema = 1}) => encodeOp('profile.put', {
  'schema_version': schema,
  'id': selfId,
  'type': 'self',
  'created_at': '2026-10-01T06:00:00.000Z',
  'display_name': null,
});

Map<String, Object?> weight(
  String id, {
  Map<String, Object?> patch = const {},
}) => {
  'schema_version': 1,
  'id': id,
  'profile_id': selfId,
  'kind': 'body.weight',
  'state': 'observed',
  'value_status': 'present',
  'quantity': {'value': 70.0, 'unit': 'kg'},
  'original_text': '70',
  'provenance': {'kind': 'manual'},
  'observed_at': '2026-10-01T06:30:00.000Z',
  'recorded_at': '2026-10-01T06:31:00.000Z',
  'supersedes_id': null,
  'deleted_at': null,
  ...patch,
};

/// Synthetic test migration: format 1 → 2, lossless, leaves a visible mark.
final m002 = VaultMigration(
  id: 'M002-test',
  from: 1,
  to: 2,
  lossless: true,
  upgradeOp: (op) {
    if (op['op'] != 'record.append') return op;
    final data = Map<String, Object?>.from(op['data']! as Map);
    final prov = Map<String, Object?>.from(data['provenance']! as Map);
    prov['source_version'] ??= 'M002';
    data['provenance'] = prov;
    return {...op, 'data': data};
  },
);

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('hhos-compat-'));
  tearDown(() => tmp.deleteSync(recursive: true));

  File vaultWith(List<String> lines) =>
      File('${tmp.path}/$vaultFileName')
        ..writeAsStringSync(lines.map((l) => '$l\n').join());

  LogRepository fileRepo({
    List<VaultMigration> migrations = vaultMigrations,
    int target = vaultFormatVersion,
  }) => LogRepository(
    sink: FileLogSink(File('${tmp.path}/$vaultFileName')),
    durability: StorageDurability.localFile,
    location: tmp.path,
    migrations: migrations,
    targetVersion: target,
  );

  Future<void> expectRefused(String code) async {
    final file = File('${tmp.path}/$vaultFileName');
    final before = file.readAsBytesSync();
    await expectLater(
      fileRepo().open(),
      throwsA(isA<VaultFormatError>().having((e) => e.code, 'code', code)),
    );
    expect(file.readAsBytesSync(), before, reason: 'never overwritten');
  }

  group('compatibility metadata (§35.3)', () {
    test('this app writes format 1, reads format 1, never downgrades', () {
      expect(vaultFormatVersion, 1);
      expect(vaultOldestReadableVersion, 1);
      expect(vaultDowngradeSupported, isFalse);
      expect(HealthRecord.currentSchemaVersion, 1);
      expect(Profile.currentSchemaVersion, 1);
    });

    test('the production graph is a lossless +1 chain from the oldest '
        'readable format to the current one', () {
      expect(
        migrationPath(
          vaultOldestReadableVersion,
          vaultFormatVersion,
          vaultMigrations,
        ).length,
        vaultFormatVersion - vaultOldestReadableVersion,
      );
      final ids = vaultMigrations.map((m) => m.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'unique ids');
      for (final m in vaultMigrations) {
        expect(m.to, m.from + 1, reason: m.id);
        expect(m.lossless, isTrue, reason: m.id);
      }
    });

    test('a new vault header records format 1 and nothing else', () async {
      final repo = fileRepo();
      await repo.open();
      final first = File('${tmp.path}/$vaultFileName').readAsLinesSync().first;
      final h = jsonDecode(first) as Map<String, Object?>;
      expect(h['format_version'], 1);
      expect(h.keys.toSet(), {
        'format',
        'format_version',
        'vault_id',
        'created_at',
        'encryption',
      });
    });

    test('a newer vault is refused with VAULT_NEWER', () async {
      vaultWith([header(version: 2)]);
      await expectRefused('VAULT_NEWER');
    });

    test(
      'a header without a numeric version is refused, not read as 1',
      () async {
        vaultWith([header(version: null)]);
        await expectRefused('VAULT_NO_VERSION');
        vaultWith([header(version: '1')]);
        await expectRefused('VAULT_NO_VERSION');
      },
    );

    test(
      'a header without its vault id is refused with a code, not a crash',
      () async {
        vaultWith([header(withId: false)]);
        await expectRefused('VAULT_HEADER_UNREADABLE');
      },
    );

    test(
      'a record or profile written by a newer app blocks the open',
      () async {
        vaultWith([
          header(),
          profileLine(),
          encodeOp('record.append', weight('r1', patch: {'schema_version': 2})),
        ]);
        await expectRefused('RECORD_SCHEMA_NEWER');
        vaultWith([header(), profileLine(schema: 2)]);
        await expectRefused('RECORD_SCHEMA_NEWER');
      },
    );
  });

  group('migration graph (§35.1, §35.2)', () {
    final m003 = VaultMigration(
      id: 'M003-test',
      from: 2,
      to: 3,
      lossless: true,
      upgradeOp: (op) => op,
    );

    test('the path is the ordered chain of steps', () {
      expect(migrationPath(1, 3, [m003, m002]).map((m) => m.id), [
        'M002-test',
        'M003-test',
      ]);
      expect(migrationPath(2, 2, [m002]), isEmpty);
    });

    test('a missing, ambiguous or skipping step has no path', () {
      Matcher code(String c) =>
          throwsA(isA<VaultFormatError>().having((e) => e.code, 'code', c));
      expect(() => migrationPath(1, 3, [m002]), code('NO_MIGRATION_PATH'));
      expect(
        () => migrationPath(1, 2, [m002, m002]),
        code('NO_MIGRATION_PATH'),
      );
      final skip = VaultMigration(
        id: 'M-skip',
        from: 1,
        to: 3,
        lossless: true,
        upgradeOp: (op) => op,
      );
      expect(() => migrationPath(1, 3, [skip]), code('NO_MIGRATION_PATH'));
    });

    test('a lossy step is refused until a backup checkpoint exists', () {
      final lossy = VaultMigration(
        id: 'M002-lossy',
        from: 1,
        to: 2,
        lossless: false,
        upgradeOp: (op) => op,
      );
      expect(
        () => migrationPath(1, 2, [lossy]),
        throwsA(
          isA<VaultFormatError>().having(
            (e) => e.code,
            'code',
            'MIGRATION_LOSSY',
          ),
        ),
      );
    });

    test('an older vault is migrated in memory only, opens read-only and '
        'yields a §33.3 receipt; the file is untouched', () async {
      final file = File('${tmp.path}/$vaultFileName')
        ..writeAsBytesSync(File(fixtureV1).readAsBytesSync());
      final before = file.readAsBytesSync();
      final repo = fileRepo(migrations: [m002], target: 2);
      final report = await repo.open();

      expect(report.readOnly, isTrue);
      expect(repo.writable, isFalse);
      final r = report.migrations.single;
      expect((r.id, r.fromVersion, r.toVersion), ('M002-test', 1, 2));
      expect(r.result, 'APPLIED_IN_MEMORY');
      expect(r.checkpoint, contains('not changed'));
      expect(r.entries, 4);
      expect(r.finishedAt.isBefore(r.startedAt), isFalse);

      final records = await repo.records(selfId);
      expect(records.length, 3);
      expect(records.first.provenance.sourceVersion, 'M002');
      expect(records.last.provenance.sourceVersion, '2.1', reason: 'kept');

      await expectLater(
        repo.putProfile(
          Profile(
            id: 'p2',
            type: ProfileType.self,
            createdAt: DateTime.utc(2026),
          ),
        ),
        throwsA(isA<StorageWriteRefused>()),
      );
      await expectLater(
        repo.appendRecord(HealthRecord.fromJson(weight('r9'))),
        throwsA(
          isA<StorageWriteRefused>().having(
            (e) => e.code,
            'code',
            'VAULT_READ_ONLY',
          ),
        ),
      );
      expect(file.readAsBytesSync(), before);
    });

    test(
      'a vault at the current format opens writable with no receipts',
      () async {
        File('${tmp.path}/$vaultFileName')
            .writeAsBytesSync(File(fixtureV1).readAsBytesSync());
        final repo = fileRepo();
        final report = await repo.open();
        expect(report.migrations, isEmpty);
        expect(report.readOnly, isFalse);
        expect(repo.writable, isTrue);
      },
    );
  });

  group('fixture v1_forge002 (§35.4)', () {
    test('the fixture is byte-for-byte what the current writer produces', () {
      final lines = File(fixtureV1).readAsLinesSync();
      for (final line in lines.skip(1)) {
        final m = jsonDecode(line) as Map<String, Object?>;
        final data = (m['data']! as Map).cast<String, Object?>();
        final again = m['op'] == 'profile.put'
            ? Profile.fromJson(data).toJson()
            : HealthRecord.fromJson(data).toJson();
        expect(encodeOp(m['op']! as String, again), line);
      }
    });

    test('identity, provenance, correction lineage, missing state and UTC '
        'times survive a read', () async {
      final state = parseVaultLog(File(fixtureV1).readAsStringSync());
      expect(state.warnings, isEmpty);
      expect(state.header.vaultId, '00000000-0000-4000-8000-0000000000f1');
      expect(state.profiles.keys, [selfId]);
      expect(state.order, [
        '00000000-0000-4000-8000-0000000000b1',
        '00000000-0000-4000-8000-0000000000b2',
        '00000000-0000-4000-8000-0000000000b3',
      ], reason: 'no duplicates, original order');
      final original = state.records[state.order[0]]!;
      final correction = state.records[state.order[1]]!;
      final missing = state.records[state.order[2]]!;
      expect(original.originalText, '78,4');
      expect(correction.supersedesId, original.id);
      expect(missing.valueStatus, ValueStatus.notMeasured);
      expect(missing.quantity, isNull, reason: 'missing ≠ zero');
      expect(missing.state, RecordState.reported);
      expect(missing.provenance.kind, ProvenanceKind.device);
      expect(missing.provenance.deviceId, 'dev-9');
      expect(original.observedAt, DateTime.utc(2026, 10, 1, 6, 30));
      expect(original.observedAt.isUtc, isTrue);
      final current = currentRecords(state.records.values);
      expect(current.map((r) => r.id), [missing.id, correction.id]);
    });
  });

  group('replay validation (G-18)', () {
    test(
      'entries that break a record rule are skipped with a warning that '
      'names the line and the rule; valid entries and the file survive',
      () async {
        final file = vaultWith([
          header(),
          profileLine(),
          encodeOp('record.append', weight('ok-1')),
          encodeOp('record.append', weight('bad-1', patch: {'quantity': null})),
          encodeOp(
            'record.append',
            weight(
              'bad-2',
              patch: {
                'quantity': {'value': 150.0, 'unit': '[lb_av]'},
              },
            ),
          ),
          encodeOp(
            'record.append',
            weight('bad-3', patch: {'profile_id': 'ghost'}),
          ),
          encodeOp(
            'record.append',
            weight(
              'bad-4',
              patch: {
                'quantity': {'value': 0.0, 'unit': 'kg'},
              },
            ),
          ),
          encodeOp('record.append', weight('ok-2')),
        ]);
        final before = file.readAsBytesSync();
        final repo = fileRepo();
        final report = await repo.open();
        expect(report.warnings.map((w) => (w.kind, w.line, w.code)), [
          (LoadWarningKind.entryInvalid, 4, 'PRESENT_REQUIRES_QUANTITY'),
          (LoadWarningKind.entryInvalid, 5, 'UNIT_NOT_SUPPORTED'),
          (LoadWarningKind.entryInvalid, 6, 'UNKNOWN_PROFILE'),
          (LoadWarningKind.entryInvalid, 7, 'OUT_OF_PLAUSIBLE_RANGE'),
        ]);
        expect((await repo.records(selfId)).map((r) => r.id), ['ok-1', 'ok-2']);
        expect(file.readAsBytesSync(), before);
      },
    );

    test(
      'an unreadable middle entry and a cut-off last entry are told apart',
      () async {
        vaultWith([
          header(),
          profileLine(),
          '{"op":"record.append","data":{not json}}',
          encodeOp('record.append', weight('ok-1')),
          '{"op":"record.app',
        ]);
        final report = await fileRepo().open();
        expect(report.warnings.map((w) => (w.kind, w.line)), [
          (LoadWarningKind.entryUnreadable, 3),
          (LoadWarningKind.lastEntryIncomplete, 5),
        ]);
      },
    );
  });
}
