// R011@v0.32: compatibility review of record schemas 7 to 13
// (sleep.night, self.feeling_check_in, nutrition.food_entry, activity.entry,
// condition.entry, preventive.entry since F009-S2, document.reference since
// F010-S1) next to the older kinds, on a real LogRepository:
// reopen, per-kind write schema, backup and restore, the schema 5 fixture,
// refusal of a newer schema, and the D-018 upgrade checkpoint.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/application/measured_at.dart';
import 'package:human_health_os/src/core/ids.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/backup/data_files_io.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const fixtureSchema5 = 'test/fixtures/vault/v1_f007s2_schema5.hhoslog.jsonl';
final t0 = DateTime.utc(2026, 11, 10, 8);
const utc = OffsetRuleZone(_zero);
Duration _zero(DateTime _) => Duration.zero;

class _At implements Clock {
  @override
  DateTime nowUtc() => t0;
}

/// The schema each kind must be written at (D-018: the oldest that holds it,
/// never below 3).
const expectedWriteSchema = {
  RecordKind.bodyWeight: 3,
  RecordKind.labResult: 3,
  RecordKind.waistCircumference: 4,
  RecordKind.restingHeartRate: 4,
  RecordKind.bloodPressure: 4,
  RecordKind.height: 5,
  RecordKind.bodyTemperature: 5,
  RecordKind.oxygenSaturation: 5,
  RecordKind.respiratoryRate: 5,
  RecordKind.medicationItem: 6,
  RecordKind.medicationPlan: 6,
  RecordKind.medicationIntake: 6,
  RecordKind.sleepNight: 7,
  RecordKind.feelingCheckIn: 8,
  RecordKind.foodEntry: 9,
  RecordKind.activityEntry: 10,
  RecordKind.conditionEntry: 11,
  RecordKind.preventiveEntry: 12,
  RecordKind.documentReference: 13,
};

const newKinds = [
  RecordKind.sleepNight,
  RecordKind.feelingCheckIn,
  RecordKind.foodEntry,
  RecordKind.activityEntry,
  RecordKind.conditionEntry,
  RecordKind.preventiveEntry,
  RecordKind.documentReference,
];

LogRepository fileRepo(File f) => LogRepository(
  sink: FileLogSink(f),
  durability: StorageDurability.localFile,
  location: f.path,
);

/// One record of each schema 7 to 13 kind, in schema order.
Future<void> addNewKinds(HeartbeatService svc, String me) async {
  await svc.recordSleep(
    zone: utc,
    profileId: me,
    wentToBed: '23:10',
    wokeUp: '07:00',
    feeling: WakeFeeling.rested,
  );
  await svc.recordFeeling(
    profileId: me,
    energy: SelfLevel.high,
    stress: SelfLevel.low,
  );
  await svc.recordFood(
    profileId: me,
    what: 'Müsli mit Joghurt',
    amount: '1 Schale',
    nutrients: const {
      PrintedNutrient.energyKcal: '350',
      PrintedNutrient.protein: '12,5',
    },
    per: LabelBasis.perServing,
  );
  await svc.recordActivity(profileId: me, what: 'walk', minutes: '30');
  await svc.recordCondition(
    profileId: me,
    name: 'headache',
    nature: ConditionType.symptom,
    time: ConditionTime.unsure,
    source: ConditionSource.selfReported,
  );
  await svc.recordPreventive(
    profileId: me,
    name: 'Tetanus-Impfung',
    nature: PreventiveType.vaccination,
    status: PreventiveStatus.planned,
    source: ConditionSource.fromDocument,
    when: '2027-03',
  );
  await svc.recordDocument(
    profileId: me,
    title: 'Blutbild Befund',
    nature: DocumentType.labReport,
    date: '2025-03',
    whereKept: 'Ordner zu Hause',
  );
}

/// One record of every kind (schemas 3 to 13), oldest schema first.
Future<void> addEveryKind(HeartbeatService svc, String me) async {
  await svc.recordWeightKg(profileId: me, input: '78,4');
  await svc.recordLab(
    profileId: me,
    input: const LabInput(
      analyte: 'LDL',
      value: '142',
      notReported: false,
      unit: 'mg/dL',
      sampleDate: '2026-11-03',
    ),
  );
  for (final (kind, value) in [
    (RecordKind.waistCircumference, '84'),
    (RecordKind.restingHeartRate, '57'),
    (RecordKind.height, '172,5'),
    (RecordKind.bodyTemperature, '36,8'),
    (RecordKind.oxygenSaturation, '98'),
    (RecordKind.respiratoryRate, '14'),
  ]) {
    await svc.recordMeasurement(
      profileId: me,
      kind: kind,
      input: MeasurementInput(value: value, context: 'sitting'),
    );
  }
  await svc.recordMeasurement(
    profileId: me,
    kind: RecordKind.bloodPressure,
    input: const MeasurementInput(systolic: '121', diastolic: '79'),
  );
  final item = await svc.addMedication(
    profileId: me,
    name: 'Vitamin D3',
    category: MedicationCategory.supplement,
    strength: '1000 IU',
  );
  await svc.planMedication(
    profileId: me,
    itemRootId: item.id,
    schedule: '1 every morning',
    source: PlanSource.ownChoice,
  );
  await svc.recordDose(
    profileId: me,
    itemRootId: item.id,
    status: IntakeStatus.taken,
    amount: '1 capsule',
  );
  await addNewKinds(svc, me);
}

List<String> jsonOf(Iterable<HealthRecord> rs) => [
  for (final r in rs) jsonEncode(r.toJson()),
];

void main() {
  late Directory tmp;
  late File vaultFile;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('hhos-r011-');
    vaultFile = File('${tmp.path}/$vaultFileName');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<(LogRepository, HeartbeatService, String)> openFilled() async {
    final repo = fileRepo(vaultFile);
    await repo.open();
    final svc = HeartbeatService(repo, clock: _At());
    final me = (await svc.ensureSelfProfile()).id;
    await addEveryKind(svc, me);
    return (repo, svc, me);
  }

  test('(a) a store with one record of every kind of schemas 3 to 13 '
      'survives close and reopen with identical records', () async {
    final (repo, _, me) = await openFilled();
    final before = await repo.records(me);
    expect(
      before.map((r) => r.kind).toSet(),
      RecordKind.values.toSet(),
      reason: 'every kind is covered',
    );
    expect(before, hasLength(RecordKind.values.length));
    final bytes = vaultFile.readAsStringSync();

    final reopened = fileRepo(vaultFile);
    final report = await reopened.open();
    expect(report.warnings, isEmpty);
    expect(report.migrations, isEmpty);
    expect(report.readOnly, isFalse);
    final after = await reopened.records(me);
    expect(jsonOf(after), jsonOf(before));
    expect(
      vaultFile.readAsStringSync(),
      bytes,
      reason: 'reading writes nothing',
    );
    // Each new kind comes back with its typed details, not a generic map.
    for (final r in after.where((r) => newKinds.contains(r.kind))) {
      expect(r.details, isNotNull, reason: r.kind.code);
      expect(r.details!.toJson()['type'], r.kind.detailsType);
      expect(r.quantity, isNull, reason: 'structured kinds carry no quantity');
    }
  });

  test('(b) each kind is written at exactly its own schema; older kinds keep '
      'theirs', () async {
    final (repo, _, me) = await openFilled();
    final records = await repo.records(me);
    for (final r in records) {
      expect(
        r.schemaVersion,
        expectedWriteSchema[r.kind],
        reason: '${r.kind.code} in memory',
      );
      expect(HealthRecord.writeSchemaFor(r.kind), expectedWriteSchema[r.kind]);
    }
    // And on disk, line by line.
    final lines = vaultFile.readAsLinesSync().skip(2);
    expect(lines, hasLength(RecordKind.values.length));
    for (final l in lines) {
      final data = ((jsonDecode(l) as Map)['data']! as Map)
          .cast<String, Object?>();
      final kind = RecordKind.fromCode(data['kind']! as String);
      expect(data['schema_version'], expectedWriteSchema[kind], reason: l);
      // A schema 3 record has no schema 4 keys at all.
      if (expectedWriteSchema[kind] == 3) {
        expect(data.containsKey('context'), isFalse);
        expect(data.containsKey('details'), isFalse);
      }
    }
    expect(HealthRecord.currentSchemaVersion, 13);
    for (final k in newKinds) {
      expect(k.minSchema, expectedWriteSchema[k]);
    }
  });

  test('(c) a backup of that store restores into a fresh store with the same '
      'records', () async {
    final (repo, _, me) = await openFilled();
    final original = vaultFile.readAsStringSync();
    final before = jsonOf(await repo.records(me));
    final files = FileDataFiles(dataDir: tmp, vault: vaultFile);
    final bundle = createBackupBundle(
      vaultLogText: original,
      appVersion: '0.1.0+1',
      sourceRevision: 'r011',
      createdAt: t0,
    );
    final manifest = ((jsonDecode(bundle) as Map)['manifest']! as Map)
        .cast<String, Object?>();
    expect(manifest['record_schema_versions'], [
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
    ]);
    expect(manifest['record_count'], RecordKind.values.length);
    await files.save(DataFileKind.backup, backupFileName('r011', t0), bundle);

    vaultFile.deleteSync();

    final saved = (await files.backups()).single;
    final staged = stageRestore(await files.read(saved));
    final out = await files.restore(staged, now: t0);
    expect(out.records, RecordKind.values.length);
    expect(out.keptPrevious, isNull);
    expect(vaultFile.readAsStringSync(), original);

    final restored = fileRepo(vaultFile);
    expect((await restored.open()).warnings, isEmpty);
    expect(jsonOf(await restored.records(me)), before);
    expect(restored.writable, isTrue);
  });

  test('(d) the schema 5 fixture still opens; after one record of each new '
      'kind, every old record is byte-identical in JSON', () async {
    final fixture = File(fixtureSchema5).readAsStringSync();
    vaultFile.writeAsStringSync(fixture);
    final repo = fileRepo(vaultFile);
    final report = await repo.open();
    expect(report.warnings, isEmpty);
    expect(report.migrations, isEmpty);
    expect(repo.writable, isTrue);
    final svc = HeartbeatService(repo, clock: _At());
    final me = (await svc.ensureSelfProfile()).id;
    final old = await repo.records(me);
    expect(old, isNotEmpty);
    final oldJson = jsonOf(old);
    final oldLines = fixture.trimRight().split('\n').skip(2).toList();
    expect(oldLines, hasLength(old.length));

    await addNewKinds(svc, me);

    final text = vaultFile.readAsStringSync();
    expect(text.startsWith(fixture), isTrue, reason: 'append only');
    final reopened = fileRepo(vaultFile);
    expect((await reopened.open()).warnings, isEmpty);
    final all = await reopened.records(me);
    expect(all, hasLength(old.length + newKinds.length));
    expect(jsonOf(all.take(old.length)), oldJson);
    for (var i = 0; i < oldLines.length; i++) {
      expect(
        encodeOp('record.append', all[i].toJson()),
        oldLines[i],
        reason: 'line ${i + 3} re-encodes byte for byte',
      );
    }
    expect(
      [for (final r in all.skip(old.length)) (r.kind, r.schemaVersion)],
      [for (final k in newKinds) (k, k.minSchema)],
    );
  });

  group('(e) refusal of a newer record schema', () {
    // HealthRecord.currentSchemaVersion is a compile-time constant and
    // parseVaultLog/HealthRecord.fromJson take no "max schema" parameter,
    // so an app limited to an older schema cannot be simulated here. What is
    // tested instead is the same gate one step up: a store holding a record
    // one schema newer than this app (14) is refused as a whole, and a
    // schema 7 to 13 kind labelled with an older schema is never accepted.
    String bumped(String log, int from, int to) =>
        log.replaceFirst('"schema_version":$from,', '"schema_version":$to,');

    test('a store holding a schema 14 record refuses to open, by parse, by '
        'the repository and by restore', () async {
      await openFilled();
      final log = vaultFile.readAsStringSync();
      final newer = bumped(log, 13, 14);
      expect(newer, isNot(log));
      expect(
        () => parseVaultLog(newer),
        throwsA(
          isA<VaultFormatError>().having(
            (e) => e.code,
            'code',
            'RECORD_SCHEMA_NEWER',
          ),
        ),
      );
      vaultFile.writeAsStringSync(newer);
      await expectLater(
        fileRepo(vaultFile).open(),
        throwsA(isA<VaultFormatError>()),
      );
      expect(vaultFile.readAsStringSync(), newer, reason: 'left untouched');
      final bundle = createBackupBundle(
        vaultLogText: log,
        appVersion: '0.1.0+1',
        sourceRevision: 'r011',
        createdAt: t0,
      );
      // A bundle whose payload holds a schema 14 record (manifest rebuilt
      // around it so only the schema gate can refuse it).
      final d = (jsonDecode(bundle) as Map).cast<String, Object?>();
      final m = (d['manifest']! as Map).cast<String, Object?>();
      m['payload_sha256'] = sha256Hex(newer);
      m['payload_bytes'] = utf8.encode(newer).length;
      d['payload'] = newer;
      expect(
        () => stageRestore(jsonEncode(d)),
        throwsA(
          isA<BackupError>().having(
            (e) => e.code,
            'code',
            'VAULT_INCOMPATIBLE',
          ),
        ),
      );
    });

    test(
      'a schema 7 to 13 kind under an older schema is skipped, never read',
      () async {
        await openFilled();
        var log = vaultFile.readAsStringSync();
        final lines = log.trimRight().split('\n');
        final downgraded = [
          lines[0],
          lines[1],
          for (final l in lines.skip(2))
            for (final k in newKinds)
              if (l.contains('"kind":"${k.code}"'))
                l.replaceFirst(
                  '"schema_version":${k.minSchema},',
                  '"schema_version":${k.minSchema - 1},',
                ),
        ];
        log = '${downgraded.join('\n')}\n';
        final state = parseVaultLog(log);
        expect(state.records, isEmpty);
        expect(state.warnings, hasLength(newKinds.length));
        for (final w in state.warnings) {
          expect(w.kind, LoadWarningKind.entryInvalid);
          expect(w.code, 'KIND_NEEDS_NEWER_SCHEMA');
        }
      },
    );
  });

  group('(f) upgrade checkpoint (D-018) for schemas 7 to 13', () {
    Future<(LogRepository, HeartbeatService, String)> withWeight() async {
      final repo = fileRepo(vaultFile);
      await repo.open();
      final svc = HeartbeatService(repo, clock: _At());
      final me = (await svc.ensureSelfProfile()).id;
      await svc.recordWeightKg(profileId: me, input: '70');
      return (repo, svc, me);
    }

    test('runs once per first record of each newer schema, in order, and '
        'never again for a second record of the same schema', () async {
      final (repo, svc, me) = await withWeight();
      final seen = <int>[];
      final sizes = <int>[];
      repo.beforeSchemaUpgrade = () async {
        // The checkpoint sees the store as it is, before the new line.
        sizes.add(vaultFile.readAsLinesSync().length);
        seen.add((await repo.records(me)).length);
      };
      Future<void> twice(Future<void> Function() add) async {
        await add();
        await add();
      }

      await twice(
        () => svc.recordSleep(
          zone: utc,
          profileId: me,
          wentToBed: '23:10',
          wokeUp: '07:00',
        ),
      );
      expect(seen, [1], reason: '3 to 7, once');
      await twice(
        () => svc.recordFeeling(profileId: me, mood: SelfLevel.medium),
      );
      expect(seen, [1, 3], reason: '7 to 8');
      await twice(() => svc.recordFood(profileId: me, what: 'apple'));
      expect(seen, [1, 3, 5], reason: '8 to 9');
      await twice(() => svc.recordActivity(profileId: me, what: 'swim'));
      expect(seen, [1, 3, 5, 7], reason: '9 to 10');
      await twice(
        () => svc.recordCondition(
          profileId: me,
          name: 'asthma',
          nature: ConditionType.condition,
          time: ConditionTime.past,
          source: ConditionSource.toldByClinician,
        ),
      );
      expect(seen, [1, 3, 5, 7, 9], reason: '10 to 11');
      await twice(
        () => svc.recordPreventive(
          profileId: me,
          name: 'flu shot',
          nature: PreventiveType.vaccination,
          status: PreventiveStatus.done,
          source: ConditionSource.selfReported,
        ),
      );
      expect(seen, [1, 3, 5, 7, 9, 11], reason: '11 to 12');
      await twice(
        () => svc.recordDocument(
          profileId: me,
          title: 'discharge letter',
          nature: DocumentType.letter,
        ),
      );
      expect(seen, [1, 3, 5, 7, 9, 11, 13], reason: '12 to 13');
      expect(sizes, [for (final n in seen) n + 2], reason: 'header + profile');
      // Older kinds after the newest schema never ask again.
      await svc.recordWeightKg(profileId: me, input: '71');
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.height,
        input: const MeasurementInput(value: '172'),
      );
      expect(seen, hasLength(7));

      // After a reopen the stored schema is read back: still no checkpoint.
      final reopened = fileRepo(vaultFile);
      await reopened.open();
      var again = 0;
      reopened.beforeSchemaUpgrade = () async => again++;
      await HeartbeatService(
        reopened,
        clock: _At(),
      ).recordActivity(profileId: me, what: 'run');
      await HeartbeatService(reopened, clock: _At()).recordSleep(
        zone: utc,
        profileId: me,
        wentToBed: '22:00',
        wokeUp: '06:00',
      );
      expect(again, 0);
    });

    test('a jump straight to schema 13 makes one checkpoint; the skipped '
        'schemas 7 to 12 then make none', () async {
      final (repo, svc, me) = await withWeight();
      var calls = 0;
      repo.beforeSchemaUpgrade = () async => calls++;
      await svc.recordDocument(
        profileId: me,
        title: 'vaccination card',
        nature: DocumentType.vaccinationCard,
      );
      expect(calls, 1);
      await addNewKinds(svc, me);
      expect(calls, 1);
    });

    test('a schema 6 store upgrading to 7 checkpoints; a failed checkpoint '
        'for each new kind refuses the save and writes nothing', () async {
      for (final kind in newKinds) {
        if (vaultFile.existsSync()) vaultFile.deleteSync();
        final (repo, svc, me) = await withWeight();
        await svc.addMedication(
          profileId: me,
          name: 'Ibuprofen',
          category: MedicationCategory.medicine,
        );
        final before = vaultFile.readAsStringSync();
        var calls = 0;
        repo.beforeSchemaUpgrade = () async {
          calls++;
          throw StateError('disk full');
        };
        final Future<HealthRecord> save = switch (kind) {
          RecordKind.sleepNight => svc.recordSleep(
            zone: utc,
            profileId: me,
            wentToBed: '23:10',
            wokeUp: '07:00',
          ),
          RecordKind.feelingCheckIn => svc.recordFeeling(
            profileId: me,
            energy: SelfLevel.low,
          ),
          RecordKind.foodEntry => svc.recordFood(profileId: me, what: 'tea'),
          RecordKind.activityEntry => svc.recordActivity(
            profileId: me,
            what: 'yoga',
          ),
          RecordKind.documentReference => svc.recordDocument(
            profileId: me,
            title: 'x-ray report',
            nature: DocumentType.imaging,
          ),
          RecordKind.preventiveEntry => svc.recordPreventive(
            profileId: me,
            name: 'colon screening',
            nature: PreventiveType.screening,
            status: PreventiveStatus.planned,
            source: ConditionSource.toldByClinician,
          ),
          _ => svc.recordCondition(
            profileId: me,
            name: 'cough',
            nature: ConditionType.symptom,
            time: ConditionTime.current,
            source: ConditionSource.selfReported,
          ),
        };
        await expectLater(
          save,
          throwsA(
            isA<StorageWriteRefused>().having(
              (e) => e.code,
              'code',
              'CHECKPOINT_FAILED',
            ),
          ),
          reason: kind.code,
        );
        expect(calls, 1, reason: kind.code);
        expect(vaultFile.readAsStringSync(), before, reason: kind.code);
        expect(await repo.records(me), hasLength(2), reason: kind.code);
      }
    });

    test(
      'an empty store never checkpoints, also for schemas 11 to 13',
      () async {
        final repo = fileRepo(vaultFile);
        await repo.open();
        final svc = HeartbeatService(repo, clock: _At());
        final me = (await svc.ensureSelfProfile()).id;
        var calls = 0;
        repo.beforeSchemaUpgrade = () async => calls++;
        // The first record is at schema 13; older kinds after it need no
        // upgrade either.
        await svc.recordDocument(
          profileId: me,
          title: 'prescription',
          nature: DocumentType.prescription,
        );
        await svc.recordPreventive(
          profileId: me,
          name: 'eye check',
          nature: PreventiveType.checkup,
          status: PreventiveStatus.done,
          source: ConditionSource.selfReported,
        );
        await svc.recordCondition(
          profileId: me,
          name: 'migraine',
          nature: ConditionType.condition,
          time: ConditionTime.current,
          source: ConditionSource.selfReported,
        );
        expect(calls, 0);
      },
    );
  });
}
