// F007@v0.32 measurements (master §39 F007, slice 1): record schema 4 rules
// for blood pressure, resting heart rate and waist circumference; entry as
// typed (missing ≠ zero, source text kept, nothing derived or judged);
// repeated readings kept; correction lineage; the upgrade checkpoint.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/core/ids.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

class StepClock implements Clock {
  DateTime t = DateTime.utc(2026, 10, 8, 7);
  @override
  DateTime nowUtc() => t = t.add(const Duration(seconds: 30));
}

const bp = BloodPressureDetails(
  systolic: 118,
  diastolic: 76,
  systolicText: '118',
  diastolicText: '76',
);

HealthRecord rec({
  RecordKind kind = RecordKind.restingHeartRate,
  Quantity? q = const Quantity(57, 'bpm'),
  RecordDetails? details,
  String? context,
  ValueStatus status = ValueStatus.present,
  AmendReason? reason,
  String? supersedes,
  DateTime? deletedAt,
  int schema = 4,
}) => HealthRecord(
  id: 'm1',
  profileId: 'p',
  kind: kind,
  state: RecordState.observed,
  valueStatus: status,
  quantity: q,
  originalText: q == null ? null : '57',
  provenance: const Provenance.manual(),
  observedAt: DateTime.utc(2026, 10, 8, 7),
  recordedAt: DateTime.utc(2026, 10, 8, 7),
  supersedesId: supersedes,
  amendReason: reason,
  deletedAt: deletedAt,
  context: context,
  details: details,
  schemaVersion: schema,
);

HealthRecord bpRec({
  RecordDetails? details = bp,
  Quantity? q,
  ValueStatus status = ValueStatus.present,
  String? context,
  AmendReason? reason,
  int schema = 4,
}) => rec(
  kind: RecordKind.bloodPressure,
  q: q,
  details: details,
  status: status,
  context: context,
  reason: reason,
  supersedes: reason == null ? null : 'm0',
  deletedAt: reason == AmendReason.deleted
      ? DateTime.utc(2026, 10, 8, 8)
      : null,
  schema: schema,
);

Matcher rule(String code) =>
    throwsA(isA<RecordValidationError>().having((e) => e.code, 'code', code));

Matcher input(String code, [String? field]) => throwsA(
  isA<InputError>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.field, 'field', field),
);

/// A repository on a memory sink with a SELF profile and a service on it.
Future<(LogRepository, MemoryLogSink, HeartbeatService, String)> fresh() async {
  final sink = MemoryLogSink();
  final repo = LogRepository(
    sink: sink,
    durability: StorageDurability.localFile,
    location: 'test',
  );
  await repo.open();
  final svc = HeartbeatService(repo, clock: StepClock());
  final me = (await svc.ensureSelfProfile()).id;
  return (repo, sink, svc, me);
}

void main() {
  group('record rules (schema 4)', () {
    test('the measurement kinds exist only from record schema 4, also as '
        'withdrawal or deletion markers', () {
      for (final k in [
        RecordKind.waistCircumference,
        RecordKind.restingHeartRate,
        RecordKind.bloodPressure,
      ]) {
        expect(k.minSchema, 4);
        expect(k.isMeasurement, isTrue);
        expect(
          () => rec(
            kind: k,
            q: null,
            status: ValueStatus.notApplicable,
            reason: AmendReason.enteredInError,
            supersedes: 'm0',
            schema: 3,
          ).validate(),
          rule('KIND_NEEDS_NEWER_SCHEMA'),
          reason: k.code,
        );
      }
      expect(() => rec(schema: 3).validate(), rule('KIND_NEEDS_NEWER_SCHEMA'));
      rec().validate();
    });

    test('context and details need schema 4, also on body weight', () {
      expect(
        () => rec(
          kind: RecordKind.bodyWeight,
          q: const Quantity(70, 'kg'),
          context: 'morning',
          schema: 3,
        ).validate(),
        rule('FIELD_NEEDS_NEWER_SCHEMA'),
      );
      expect(
        () => rec(
          kind: RecordKind.bodyWeight,
          q: const Quantity(70, 'kg'),
          context: 'morning',
        ).validate(),
        rule('CONTEXT_NOT_SUPPORTED'),
      );
    });

    test('each kind keeps only its own unit: nothing is converted', () {
      expect(
        () => rec(
          kind: RecordKind.waistCircumference,
          q: const Quantity(33, 'in'),
        ).validate(),
        rule('UNIT_NOT_SUPPORTED'),
      );
      expect(
        () => rec(q: const Quantity(57, '/min')).validate(),
        rule('UNIT_NOT_SUPPORTED'),
      );
      expect(
        () => bpRec(
          details: const BloodPressureDetails(
            systolic: 15.7,
            diastolic: 10.1,
            unit: 'kPa',
          ),
        ).validate(),
        rule('UNIT_NOT_SUPPORTED'),
      );
      rec(
        kind: RecordKind.waistCircumference,
        q: const Quantity(84.25, 'cm'),
      ).validate();
    });

    test('finite and above 0, with no upper bound and no clinical '
        'threshold; a stored diastolic of 0 is accepted', () {
      expect(
        () => rec(q: const Quantity(0, 'bpm')).validate(),
        rule('VALUE_NOT_POSITIVE'),
      );
      expect(
        () => rec(q: const Quantity(double.nan, 'bpm')).validate(),
        rule('VALUE_NOT_FINITE'),
      );
      expect(
        () => bpRec(
          details: const BloodPressureDetails(systolic: 0, diastolic: 0),
        ).validate(),
        rule('VALUE_NOT_POSITIVE'),
      );
      expect(
        () => bpRec(
          details: const BloodPressureDetails(systolic: 120, diastolic: -1),
        ).validate(),
        rule('VALUE_NOT_POSITIVE'),
      );
      bpRec(details: const BloodPressureDetails(systolic: 120, diastolic: 0))
          .validate();
      // Unusual is not invalid: no range is applied (v0.24:19347).
      rec(q: const Quantity(300, 'bpm')).validate();
      rec(
        kind: RecordKind.waistCircumference,
        q: const Quantity(400, 'cm'),
      ).validate();
      bpRec(details: const BloodPressureDetails(systolic: 300, diastolic: 200))
          .validate();
      // The order of the two numbers is an entry rule only (D-018).
      bpRec(details: const BloodPressureDetails(systolic: 70, diastolic: 80))
          .validate();
    });

    test('blood pressure is one record with two numbers, never a quantity; '
        'details only on a present reading of their own kind', () {
      expect(
        () => bpRec(q: const Quantity(118, 'mmHg')).validate(),
        rule('BP_HAS_NO_QUANTITY'),
      );
      expect(() => bpRec(details: null).validate(), rule('DETAILS_MISMATCH'));
      expect(
        () => rec(details: bp).validate(),
        rule('DETAILS_MISMATCH'),
        reason: 'heart rate has no details',
      );
      expect(
        () => bpRec(status: ValueStatus.notMeasured).validate(),
        rule('DETAILS_MISMATCH'),
        reason: 'missing ≠ zero',
      );
      expect(
        () => bpRec(
          reason: AmendReason.enteredInError,
          status: ValueStatus.notApplicable,
        ).validate(),
        rule('DETAILS_MISMATCH'),
        reason: 'a marker carries no reading',
      );
      bpRec(details: null, status: ValueStatus.notMeasured).validate();
      expect(
        () => rec(
          q: null,
          status: ValueStatus.notApplicable,
          reason: AmendReason.deleted,
          supersedes: 'm0',
          deletedAt: DateTime.utc(2026, 10, 8, 8),
          context: 'sitting',
        ).validate(),
        rule('MARKER_HAS_NO_VALUE'),
      );
    });

    test('context: as typed, not empty, not too long', () {
      rec(context: 'sitting, left arm').validate();
      rec(
        context: 'cuff broken',
        q: null,
        status: ValueStatus.notMeasured,
      ).validate();
      expect(() => rec(context: '   ').validate(), rule('CONTEXT_EMPTY'));
      expect(
        () => rec(context: 'x' * 501).validate(),
        rule('CONTEXT_TOO_LONG'),
      );
    });

    test('JSON: schema 1-3 records gain no new key; schema 4 writes '
        'context and kind-tagged details', () {
      final w3 = rec(
        kind: RecordKind.bodyWeight,
        q: const Quantity(70, 'kg'),
        schema: 3,
      ).toJson();
      expect(w3.containsKey('context'), isFalse);
      expect(w3.containsKey('details'), isFalse);
      final j = bpRec(context: 'sitting').toJson();
      expect(j['quantity'], isNull);
      expect(j['context'], 'sitting');
      expect(j['details'], {
        'type': 'blood_pressure',
        'systolic': 118.0,
        'diastolic': 76.0,
        'unit': 'mmHg',
        'systolic_text': '118',
        'diastolic_text': '76',
      });
      final back = HealthRecord.fromJson(
        (jsonDecode(jsonEncode(j)) as Map).cast<String, Object?>(),
      );
      expect(back.details, bp);
      expect(back.context, 'sitting');
      expect(jsonEncode(back.toJson()), jsonEncode(j));
      final hr = rec().toJson();
      expect(hr['context'], isNull);
      expect(hr['details'], isNull);
      expect(hr.containsKey('details'), isTrue);
    });

    test('details of a type this app does not know are not guessed', () {
      final j = bpRec().toJson();
      (j['details']! as Map)['type'] = 'blood_pressure_v2';
      expect(
        () => HealthRecord.fromJson(
          (jsonDecode(jsonEncode(j)) as Map).cast<String, Object?>(),
        ),
        throwsFormatException,
      );
    });
  });

  group('entering measurements', () {
    test('each kind is one OBSERVED manual record at schema 4, with its '
        'unit and the text typed; body weight is still written at 3', () async {
      final (repo, _, svc, me) = await fresh();
      final hr = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: ' 57 '),
      );
      final waist = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.waistCircumference,
        input: const MeasurementInput(value: '84,25', context: ' standing '),
      );
      final p = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.bloodPressure,
        input: const MeasurementInput(systolic: '118', diastolic: '76'),
      );
      final w = await svc.recordWeightKg(profileId: me, input: '70');
      for (final r in [hr, waist, p]) {
        expect(r.schemaVersion, 4);
        expect(r.state, RecordState.observed);
        expect(r.provenance.kind, ProvenanceKind.manual);
        expect(r.provenance.deviceId, isNull, reason: 'never invented');
      }
      expect(w.schemaVersion, 3);
      expect((hr.quantity!.value, hr.quantity!.unit), (57.0, 'bpm'));
      expect(hr.originalText, '57');
      expect(hr.context, isNull);
      expect((waist.quantity!.value, waist.originalText), (84.25, '84,25'));
      expect(waist.context, 'standing');
      expect(p.quantity, isNull);
      expect(p.details, bp);
      expect(await repo.records(me), hasLength(4));
    });

    test('blank, zero, a possible thousands separator, letters, swapped '
        'numbers and a long note are refused on their field; nothing is '
        'written', () async {
      final (repo, sink, svc, me) = await fresh();
      final before = sink.text;
      Future<void> hr(String v) => svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: MeasurementInput(value: v),
      );
      Future<void> pr(String sys, String dia, [String ctx = '']) =>
          svc.recordMeasurement(
            profileId: me,
            kind: RecordKind.bloodPressure,
            input: MeasurementInput(
              systolic: sys,
              diastolic: dia,
              context: ctx,
            ),
          );
      await expectLater(hr('  '), input('EMPTY', 'value'));
      await expectLater(hr('0'), input('NOT_POSITIVE', 'value'));
      await expectLater(hr('1,234'), input('AMBIGUOUS_SEPARATOR', 'value'));
      await expectLater(hr('57 bpm'), input('NOT_A_NUMBER', 'value'));
      // Hundreds of digits overflow to infinity: a field error, not a rule
      // ("breaks a record rule") the person cannot act on.
      await expectLater(hr('9' * 400), input('NOT_A_NUMBER', 'value'));
      await expectLater(pr('9' * 400, '80'), input('NOT_A_NUMBER', 'systolic'));
      await expectLater(
        pr('118', '9' * 400),
        input('NOT_A_NUMBER', 'diastolic'),
      );
      await expectLater(pr('118', ''), input('EMPTY', 'diastolic'));
      await expectLater(pr('', '76'), input('EMPTY', 'systolic'));
      await expectLater(pr('118', '0'), input('NOT_POSITIVE', 'diastolic'));
      await expectLater(pr('76', '118'), input('BP_ORDER', 'systolic'));
      await expectLater(pr('80', '80'), input('BP_ORDER', 'systolic'));
      await expectLater(
        pr('118', '76', 'x' * 501),
        input('CONTEXT_TOO_LONG', 'context'),
      );
      expect(sink.text, before);
      expect(await repo.records(me), isEmpty);
    });

    test(
      'a note is counted in characters, not UTF-16 units: 500 emoji are '
      'kept, 501 are refused, by the service and by the record rule',
      () async {
        final (repo, _, svc, me) = await fresh();
        Future<HealthRecord> save(String note) => svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.restingHeartRate,
          input: MeasurementInput(value: '57', context: note),
        );
        final kept = await save('\u{1F600}' * 500);
        expect(kept.context!.runes.length, 500);
        expect(kept.context!.length, 1000, reason: 'UTF-16 units');
        await expectLater(
          save('\u{1F600}' * 501),
          input('CONTEXT_TOO_LONG', 'context'),
        );
        expect(
          () => rec(
            kind: RecordKind.restingHeartRate,
            q: const Quantity(57, 'bpm'),
            context: '\u{1F600}' * 500,
          ).validate(),
          returnsNormally,
        );
        expect(
          () => rec(
            kind: RecordKind.restingHeartRate,
            q: const Quantity(57, 'bpm'),
            context: '\u{1F600}' * 501,
          ).validate(),
          rule('CONTEXT_TOO_LONG'),
        );
        expect(await repo.records(me), hasLength(1));
      },
    );

    test('repeated readings are kept: two identical readings 30 s apart are '
        'two records and two entries; a same-id retry stays one', () async {
      final (repo, sink, svc, me) = await fresh();
      const reading = MeasurementInput(systolic: '118', diastolic: '76');
      final a = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.bloodPressure,
        input: reading,
      );
      final b = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.bloodPressure,
        input: reading,
      );
      expect(b.observedAt.difference(a.observedAt).inSeconds, 30);
      final entries = await svc.measurementTimeline(
        me,
        RecordKind.bloodPressure,
      );
      expect(entries, hasLength(2));
      final lines = sink.text!.split('\n').length;
      await repo.appendRecord(a);
      expect(sink.text!.split('\n').length, lines, reason: 'idempotent');
      expect(await repo.records(me), hasLength(2));
    });

    test('correction lineage: a new version of the same kind and time; '
        'withdrawal and deletion are markers; another kind is refused '
        'everywhere', () async {
      final (_, _, svc, me) = await fresh();
      final first = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.bloodPressure,
        input: const MeasurementInput(
          systolic: '128',
          diastolic: '76',
          context: 'sitting',
        ),
      );
      final fixed = await svc.correctMeasurement(
        profileId: me,
        targetId: first.id,
        input: const MeasurementInput(
          systolic: '118',
          diastolic: '76',
          context: 'sitting',
        ),
      );
      expect(fixed.kind, RecordKind.bloodPressure);
      expect(fixed.observedAt, first.observedAt);
      expect(
        (fixed.supersedesId, fixed.amendReason),
        (first.id, AmendReason.correction),
      );
      final entry = (await svc.measurementTimeline(
        me,
        RecordKind.bloodPressure,
      )).single;
      expect(entry.versions.map((v) => v.id), [first.id, fixed.id]);
      expect(entry.heads.single.id, fixed.id);

      final hr = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '57'),
      );
      final withdrawn = await svc.amend(
        profileId: me,
        targetId: hr.id,
        reason: AmendReason.enteredInError,
      );
      expect(withdrawn.schemaVersion, 4);
      final w = await svc.recordWeightKg(profileId: me, input: '70');
      final deleted = await svc.amend(
        profileId: me,
        targetId: w.id,
        reason: AmendReason.deleted,
      );
      expect(deleted.schemaVersion, 3, reason: 'weight stays readable by F006');
      final waist = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.waistCircumference,
        input: const MeasurementInput(value: '84'),
      );
      await expectLater(
        svc.correctWeightKg(profileId: me, targetId: waist.id, input: '70'),
        input('TARGET_WRONG_KIND'),
      );
      final w2 = await svc.recordWeightKg(profileId: me, input: '71');
      await expectLater(
        svc.correctMeasurement(
          profileId: me,
          targetId: w2.id,
          input: const MeasurementInput(value: '70'),
        ),
        input('TARGET_WRONG_KIND'),
      );
      await expectLater(
        svc.correctLab(
          profileId: me,
          targetId: waist.id,
          input: const LabInput(
            analyte: 'X',
            value: '1',
            notReported: false,
            unit: '',
            sampleDate: '2026-10-01',
          ),
        ),
        input('TARGET_WRONG_KIND'),
      );
    });

    test('two competing corrections of one reading are a conflict, never a '
        'silent pick', () async {
      final (repo, _, svc, me) = await fresh();
      final first = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '57'),
      );
      HealthRecord fix(String id, double v) => HealthRecord(
        id: id,
        profileId: me,
        kind: RecordKind.restingHeartRate,
        state: RecordState.observed,
        valueStatus: ValueStatus.present,
        quantity: Quantity(v, 'bpm'),
        originalText: '$v',
        provenance: const Provenance.manual(),
        observedAt: first.observedAt,
        recordedAt: DateTime.utc(2026, 10, 8, 9),
        supersedesId: first.id,
        amendReason: AmendReason.correction,
        schemaVersion: 4,
      );
      await repo.appendRecord(fix('c1', 58));
      await repo.appendRecord(fix('c2', 59));
      final entry = (await svc.measurementTimeline(
        me,
        RecordKind.restingHeartRate,
      )).single;
      expect(entry.status, EntryStatus.conflict);
      expect(entry.heads, hasLength(2));
    });
  });

  group('upgrade checkpoint (D-018)', () {
    test('runs once, before the first schema 4 record in a store that holds '
        'only older records; never for an empty store', () async {
      final (repo, _, svc, me) = await fresh();
      var calls = 0;
      repo.beforeSchemaUpgrade = () async => calls++;
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '57'),
      );
      expect(calls, 0, reason: 'no records yet: nothing to protect');

      final (repo2, _, svc2, me2) = await fresh();
      var calls2 = 0;
      repo2.beforeSchemaUpgrade = () async => calls2++;
      await svc2.recordWeightKg(profileId: me2, input: '70');
      expect(calls2, 0, reason: 'weight stays at schema 3');
      await svc2.recordMeasurement(
        profileId: me2,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '57'),
      );
      await svc2.recordMeasurement(
        profileId: me2,
        kind: RecordKind.waistCircumference,
        input: const MeasurementInput(value: '84'),
      );
      expect(calls2, 1);
    });

    test('a weight or a lab result never triggers it, also in a store whose '
        'newest record is older than schema 3, and a checkpoint that cannot be '
        'made does not stop such a save', () async {
      final (repo, _, svc, me) = await fresh();
      await repo.appendRecord(
        HealthRecord(
          id: 'old-weight',
          profileId: me,
          kind: RecordKind.bodyWeight,
          state: RecordState.observed,
          valueStatus: ValueStatus.present,
          quantity: const Quantity(78, 'kg'),
          originalText: '78',
          provenance: const Provenance.manual(),
          observedAt: DateTime.utc(2026, 10, 1),
          recordedAt: DateTime.utc(2026, 10, 1),
          schemaVersion: 2,
        ),
      );
      var calls = 0;
      repo.beforeSchemaUpgrade = () async {
        calls++;
        throw StateError('disk full');
      };
      await svc.recordWeightKg(profileId: me, input: '77,5');
      await svc.recordLab(
        profileId: me,
        input: const LabInput(
          analyte: 'HbA1c',
          value: '5,4',
          notReported: false,
          unit: '%',
          sampleDate: '2026-10-03',
        ),
      );
      expect(calls, 0);
      expect(await repo.records(me), hasLength(3));
      await expectLater(
        svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.restingHeartRate,
          input: const MeasurementInput(value: '57'),
        ),
        throwsA(isA<StorageWriteRefused>()),
      );
      expect(calls, 1, reason: 'only the measurement asks for a checkpoint');
    });

    test('two first measurements started together make one checkpoint and '
        'both are saved', () async {
      final (repo, _, svc, me) = await fresh();
      await svc.recordWeightKg(profileId: me, input: '70');
      var calls = 0;
      repo.beforeSchemaUpgrade = () async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 5));
      };
      await Future.wait([
        svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.restingHeartRate,
          input: const MeasurementInput(value: '57'),
        ),
        svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.waistCircumference,
          input: const MeasurementInput(value: '84'),
        ),
      ]);
      expect(calls, 1);
      expect(await repo.records(me), hasLength(3));
    });

    test('a checkpoint that cannot be made refuses the save and writes '
        'nothing; the next try makes it', () async {
      final (repo, sink, svc, me) = await fresh();
      await svc.recordWeightKg(profileId: me, input: '70');
      var fail = true;
      var made = 0;
      repo.beforeSchemaUpgrade = () async {
        if (fail) throw StateError('disk full');
        made++;
      };
      final before = sink.text;
      await expectLater(
        svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.restingHeartRate,
          input: const MeasurementInput(value: '57'),
        ),
        throwsA(
          isA<StorageWriteRefused>().having(
            (e) => e.code,
            'code',
            'CHECKPOINT_FAILED',
          ),
        ),
      );
      expect(sink.text, before);
      expect(await repo.records(me), hasLength(1));
      fail = false;
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '57'),
      );
      expect(made, 1);
      expect(await repo.records(me), hasLength(2));
    });

    test('wired by servicesFor: the backup holds the store exactly as it was '
        'before the first measurement, and its place is reported', () async {
      final sink = MemoryLogSink();
      final repo = LogRepository(
        sink: sink,
        durability: StorageDurability.localFile,
        location: 'test',
      );
      await repo.open();
      final files = MemoryDataFiles();
      final s = await servicesFor(
        const AppConfig(
          profile: BuildProfile.development,
          version: '0.1.0+1',
          sourceRevision: 'test',
        ),
        HostPlatform.linux,
        repo,
        files: files,
      );
      await s.heartbeat.recordWeightKg(profileId: s.self.id, input: '70');
      final before = sink.text!;
      expect(s.checkpointSaved!.value, isNull);
      await s.heartbeat.recordMeasurement(
        profileId: s.self.id,
        kind: RecordKind.bloodPressure,
        input: const MeasurementInput(systolic: '118', diastolic: '76'),
      );
      final saved = files.files.entries.single;
      expect(s.checkpointSaved!.value, 'memory:${saved.key}');
      final staged = stageRestore(saved.value);
      expect(staged.payload, before);
      expect(staged.manifest.recordCount, 1);
      expect(staged.payload, isNot(contains('vital.blood_pressure')));
    });

    test(
      'a browser build (files that cannot restore) wires no checkpoint: '
      'the save goes through and nothing is downloaded unasked (G-47)',
      () async {
        final repo = LogRepository(
          sink: MemoryLogSink(),
          durability: StorageDurability.localFile,
          location: 'test',
        );
        await repo.open();
        final files = _NoRestoreFiles();
        final s = await servicesFor(
          const AppConfig(
            profile: BuildProfile.development,
            version: '0.1.0+1',
            sourceRevision: 'test',
          ),
          HostPlatform.web,
          repo,
          files: files,
        );
        expect(repo.beforeSchemaUpgrade, isNull);
        await s.heartbeat.recordWeightKg(profileId: s.self.id, input: '70');
        await s.heartbeat.recordMeasurement(
          profileId: s.self.id,
          kind: RecordKind.restingHeartRate,
          input: const MeasurementInput(value: '57'),
        );
        expect(files.files, isEmpty);
        expect(s.checkpointSaved!.value, isNull);
      },
    );
  });

  group('what a save stores', () {
    test('a correction keeps the note, or changes it, or drops it when the '
        'form is cleared; the first reading says when it was saved', () async {
      final (repo, _, svc, me) = await fresh();
      final first = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.restingHeartRate,
        input: const MeasurementInput(value: '58', context: 'after a walk'),
      );
      expect(first.observedAt, first.recordedAt, reason: 'the save time');
      final kept = await svc.correctMeasurement(
        profileId: me,
        targetId: first.id,
        input: const MeasurementInput(value: '57', context: 'after a walk'),
      );
      expect(kept.context, 'after a walk');
      final changed = await svc.correctMeasurement(
        profileId: me,
        targetId: kept.id,
        input: const MeasurementInput(value: '56', context: 'at rest'),
      );
      expect(changed.context, 'at rest');
      final dropped = await svc.correctMeasurement(
        profileId: me,
        targetId: changed.id,
        input: const MeasurementInput(value: '55'),
      );
      expect(dropped.context, isNull);
      expect(dropped.observedAt, first.observedAt);
      expect(await repo.records(me), hasLength(4));
    });

    test('exactly 500 characters are kept; blood pressure text is stored '
        'trimmed, as typed otherwise', () async {
      final (_, _, svc, me) = await fresh();
      final r = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.bloodPressure,
        input: MeasurementInput(
          systolic: ' 120,0 ',
          diastolic: '80.0  ',
          context: 'x' * 500,
        ),
      );
      expect(r.context, 'x' * 500);
      final d = r.details! as BloodPressureDetails;
      expect((d.systolicText, d.diastolicText), ('120,0', '80.0'));
      expect((d.systolic, d.diastolic), (120.0, 80.0));
    });
  });

  group('slice 2: height, temperature, SpO2, respiratory rate (schema 5)', () {
    final kinds = {
      RecordKind.height: ('cm', 172.0),
      RecordKind.bodyTemperature: ('°C', 36.8),
      RecordKind.oxygenSaturation: ('%', 97.0),
      RecordKind.respiratoryRate: ('breaths/min', 14.0),
    };

    test('the four kinds exist only at schema 5, in their own unit', () {
      for (final e in kinds.entries) {
        final (unit, v) = e.value;
        final ok = rec(kind: e.key, q: Quantity(v, unit), schema: 5);
        expect(ok.validate, returnsNormally, reason: e.key.code);
        for (final older in [3, 4]) {
          expect(
            rec(kind: e.key, q: Quantity(v, unit), schema: older).validate,
            rule('KIND_NEEDS_NEWER_SCHEMA'),
            reason: '${e.key.code} at $older',
          );
        }
        expect(
          rec(kind: e.key, q: Quantity(v, 'furlongs'), schema: 5).validate,
          rule('UNIT_NOT_SUPPORTED'),
        );
        expect(
          rec(kind: e.key, q: Quantity(0, unit), schema: 5).validate,
          rule('VALUE_NOT_POSITIVE'),
        );
        expect(
          rec(kind: e.key, q: Quantity(double.nan, unit), schema: 5).validate,
          rule('VALUE_NOT_FINITE'),
        );
        expect(HealthRecord.writeSchemaFor(e.key), 5);
        // Context is allowed, nothing else changes in the JSON shape.
        final j = ok.toJson();
        expect(
          j.keys.toSet(),
          rec(q: const Quantity(57, 'bpm'), schema: 4).toJson().keys.toSet(),
          reason: 'schema 5 adds a kind, not a key',
        );
        expect(HealthRecord.fromJson(j).toJson(), j);
      }
    });

    test('a stored SpO2 above 100 is not re-judged: it loads and shows', () {
      final r = rec(
        kind: RecordKind.oxygenSaturation,
        q: const Quantity(101, '%'),
        schema: 5,
      );
      expect(r.validate, returnsNormally);
      expect(HealthRecord.fromJson(r.toJson()).quantity!.value, 101);
    });

    test('entry: each kind is one OBSERVED manual record at schema 5; SpO2 '
        'above 100, 0 and blank are refused on the field', () async {
      final (repo, _, svc, me) = await fresh();
      for (final e in kinds.entries) {
        final r = await svc.recordMeasurement(
          profileId: me,
          kind: e.key,
          input: MeasurementInput(value: '${e.value.$2}'.replaceAll('.0', '')),
        );
        expect(r.schemaVersion, 5, reason: e.key.code);
        expect(r.quantity!.unit, e.value.$1);
        expect(r.state, RecordState.observed);
        expect(r.provenance.kind, ProvenanceKind.manual);
      }
      final spo2 = (RecordKind kind, String v) => svc.recordMeasurement(
        profileId: me,
        kind: kind,
        input: MeasurementInput(value: v),
      );
      await expectLater(
        spo2(RecordKind.oxygenSaturation, '100,5'),
        input('OUT_OF_DEFINITION', 'value'),
      );
      expect(
        (await spo2(RecordKind.oxygenSaturation, '100')).quantity!.value,
        100,
      );
      await expectLater(
        spo2(RecordKind.bodyTemperature, '0'),
        input('NOT_POSITIVE', 'value'),
      );
      await expectLater(spo2(RecordKind.height, ''), input('EMPTY', 'value'));
      expect(await repo.records(me), hasLength(5));
    });

    test(
      'a first height after slice-1 measurements makes one checkpoint '
      '(4 to 5); from a vault of weights only, one for the first record',
      () async {
        final (repo, _, svc, me) = await fresh();
        await svc.recordWeightKg(profileId: me, input: '70');
        var calls = 0;
        repo.beforeSchemaUpgrade = () async => calls++;
        await svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.restingHeartRate,
          input: const MeasurementInput(value: '57'),
        );
        expect(calls, 1, reason: '3 to 4');
        await svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.height,
          input: const MeasurementInput(value: '172'),
        );
        expect(calls, 2, reason: '4 to 5');
        await svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.bodyTemperature,
          input: const MeasurementInput(value: '36,8'),
        );
        expect(calls, 2, reason: 'once per step');

        final (repo2, _, svc2, me2) = await fresh();
        await svc2.recordWeightKg(profileId: me2, input: '70');
        var calls2 = 0;
        repo2.beforeSchemaUpgrade = () async => calls2++;
        await svc2.recordMeasurement(
          profileId: me2,
          kind: RecordKind.height,
          input: const MeasurementInput(
            value: '172',
            when: '2026-10-01 08:00Z',
          ),
        );
        await svc2.recordMeasurement(
          profileId: me2,
          kind: RecordKind.height,
          input: const MeasurementInput(value: '172'),
        );
        expect(calls2, 1, reason: '3 to 5 in one step, back-dated or not');
      },
    );

    test('weight: a possible thousands separator is refused, typed text is '
        'kept, the record stays schema 3', () async {
      final (_, _, svc, me) = await fresh();
      await expectLater(
        svc.recordWeightKg(profileId: me, input: '7.500'),
        input('AMBIGUOUS_SEPARATOR'),
      );
      await expectLater(
        svc.recordWeightKg(profileId: me, input: '1,234'),
        input('AMBIGUOUS_SEPARATOR'),
      );
      final w = await svc.recordWeightKg(profileId: me, input: '77,50');
      expect(
        (w.quantity!.value, w.originalText, w.schemaVersion),
        (77.5, '77,50', 3),
      );
    });
  });

  group('slice 2: the time of a measurement', () {
    test('a typed time is the observation, the save time is the record: '
        'order follows the observation, not the save', () async {
      final (repo, _, svc, me) = await fresh();
      final first = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.height,
        input: const MeasurementInput(value: '172', when: '2026-10-08 06:00Z'),
      );
      final second = await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.height,
        input: const MeasurementInput(value: '171', when: '2026-10-08 05:00Z'),
      );
      expect(first.observedAt, DateTime.utc(2026, 10, 8, 6));
      expect(second.observedAt, DateTime.utc(2026, 10, 8, 5));
      expect(second.recordedAt.isAfter(first.recordedAt), isTrue);
      final entries = await svc.measurementTimeline(me, RecordKind.height);
      expect(
        [for (final e in entries) e.heads.single.id],
        [first.id, second.id],
        reason: 'newest observation first; the later save is older',
      );
      expect(
        entries.first.heads.single.quantity!.value,
        172,
        reason: 'Latest is the newest observation',
      );
      expect(await repo.records(me), hasLength(2));
    });

    test(
      'blank means the save time; a correction keeps the observation and '
      'ignores a time typed for it; a marker sorts with its target',
      () async {
        final (_, _, svc, me) = await fresh();
        final r = await svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.bodyTemperature,
          input: const MeasurementInput(value: '36,9'),
        );
        expect(r.observedAt, r.recordedAt);
        final old = await svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.bodyTemperature,
          input: const MeasurementInput(value: '37', when: '2026-10-01 06:00Z'),
        );
        final fixed = await svc.correctMeasurement(
          profileId: me,
          targetId: old.id,
          input: const MeasurementInput(
            value: '36,5',
            when: '2026-10-08 06:00Z',
          ),
        );
        expect(fixed.observedAt, DateTime.utc(2026, 10, 1, 6));
        final gone = await svc.amend(
          profileId: me,
          targetId: fixed.id,
          reason: AmendReason.enteredInError,
        );
        expect(gone.observedAt, fixed.observedAt);
      },
    );

    test('a future time and a bad time write nothing; a stored record with '
        'any of those times still replays', () async {
      final (repo, sink, svc, me) = await fresh();
      final before = sink.text;
      for (final (typed, code) in [
        ('2099-01-01 00:00Z', 'FUTURE_TIME'),
        ('1850-01-01 00:00Z', 'TIME_TOO_OLD'),
        ('tomorrow', 'TIME_FORMAT'),
      ]) {
        await expectLater(
          svc.recordMeasurement(
            profileId: me,
            kind: RecordKind.height,
            input: MeasurementInput(value: '172', when: typed),
          ),
          input(code, 'when'),
          reason: typed,
        );
      }
      expect(sink.text, before);
      // Entry rules only: the record rules accept those instants.
      for (final at in [
        DateTime.utc(2099),
        DateTime.utc(1850),
        DateTime.utc(2026, 10, 8, 7, 4),
      ]) {
        final r = HealthRecord(
          id: 'm-${at.year}',
          profileId: me,
          kind: RecordKind.height,
          state: RecordState.observed,
          valueStatus: ValueStatus.present,
          quantity: const Quantity(172, 'cm'),
          originalText: '172',
          provenance: const Provenance.manual(),
          observedAt: at,
          recordedAt: DateTime.utc(2026, 10, 8, 7),
          schemaVersion: 5,
        );
        await repo.appendRecord(r);
      }
      final again = LogRepository(
        sink: sink,
        durability: StorageDurability.localFile,
        location: 'test',
      );
      final report = await again.open();
      expect(report.warnings, isEmpty);
      expect(await again.records(me), hasLength(3));
    });
  });
}

/// Files that cannot be listed or restored here (a browser).
class _NoRestoreFiles extends MemoryDataFiles {
  @override
  bool get canRestore => false;
}
