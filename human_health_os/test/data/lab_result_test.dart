// F004@v0.32 lab results (master §39): manual entry as printed; a missing
// unit or range stays missing; the source flag is preserved verbatim; no
// diagnosis or interpretation is generated; lab results join the timeline.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/core/ids.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

class FixedClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 7, 9);
}

HealthRecord lab({
  LabDetails? details = const LabDetails(analyteLabel: 'HbA1c'),
  RecordKind kind = RecordKind.labResult,
  Quantity? q = const Quantity(5.4, '%'),
  ValueStatus status = ValueStatus.present,
}) => HealthRecord(
  id: 'l1',
  profileId: 'p',
  kind: kind,
  state: RecordState.reported,
  valueStatus: status,
  quantity: q,
  originalText: '5,4',
  provenance: const Provenance.manual(),
  observedAt: DateTime.utc(2026, 10, 3),
  recordedAt: DateTime.utc(2026, 10, 7),
  lab: details,
);

Matcher rule(String code) =>
    throwsA(isA<RecordValidationError>().having((e) => e.code, 'code', code));

Matcher input(String code) =>
    throwsA(isA<InputError>().having((e) => e.code, 'code', code));

void main() {
  group('record rules (schema 3)', () {
    test(
      'lab details belong to lab results, and every lab result has them',
      () {
        expect(
          () => lab(details: null).validate(),
          rule('LAB_DETAILS_MISMATCH'),
        );
        expect(
          () => lab(
            kind: RecordKind.bodyWeight,
            q: const Quantity(70, 'kg'),
          ).validate(),
          rule('LAB_DETAILS_MISMATCH'),
        );
        expect(
          () => lab(details: const LabDetails(analyteLabel: '  ')).validate(),
          rule('LAB_ANALYTE_REQUIRED'),
        );
        expect(
          () => lab(q: const Quantity(double.nan, '%')).validate(),
          rule('VALUE_NOT_FINITE'),
        );
      },
    );

    test('only a lab result may lack a unit; a body weight never does', () {
      lab(q: const Quantity(5.4, null)).validate();
      expect(
        () => HealthRecord(
          id: 'w',
          profileId: 'p',
          kind: RecordKind.bodyWeight,
          state: RecordState.observed,
          valueStatus: ValueStatus.present,
          quantity: const Quantity(70, null),
          originalText: null,
          provenance: const Provenance.manual(),
          observedAt: DateTime.utc(2026, 10, 3),
          recordedAt: DateTime.utc(2026, 10, 3),
        ).validate(),
        rule('UNIT_REQUIRED'),
      );
    });

    test(
      'no clinical plausibility range: any finite printed value is kept',
      () {
        for (final v in [0.0, 0.001, 150.0, 98765.4]) {
          lab(q: Quantity(v, 'mg/dL')).validate();
        }
      },
    );

    test('missing unit and missing range stay null in the stored JSON '
        '(missing ≠ empty ≠ default)', () {
      final j = lab(
        q: const Quantity(5.4, null),
        details: const LabDetails(analyteLabel: 'HbA1c'),
      ).toJson();
      final again = jsonDecode(jsonEncode(j)) as Map<String, Object?>;
      expect((again['quantity']! as Map)['unit'], isNull);
      expect((again['lab']! as Map)['reference_text'], isNull);
      expect((again['lab']! as Map)['source_flag'], isNull);
      final back = HealthRecord.fromJson(again);
      expect(back.quantity!.unit, isNull);
      expect(back.lab!.referenceText, isNull);
      expect(back.toJson(), j);
    });

    test('schema 1 and 2 records keep their JSON shape (no "lab" key)', () {
      final w = HealthRecord(
        id: 'w',
        profileId: 'p',
        kind: RecordKind.bodyWeight,
        state: RecordState.observed,
        valueStatus: ValueStatus.present,
        quantity: const Quantity(70, 'kg'),
        originalText: '70',
        provenance: const Provenance.manual(),
        observedAt: DateTime.utc(2026, 10, 3),
        recordedAt: DateTime.utc(2026, 10, 3),
        schemaVersion: 2,
      );
      expect(w.toJson().containsKey('lab'), isFalse);
      expect(w.toJson().containsKey('amend_reason'), isTrue);
    });
  });

  group('entering a result as printed', () {
    late HeartbeatService svc;
    late LogRepository repo;
    late String me;

    setUp(() async {
      repo = inMemoryRepository(clock: FixedClock());
      await repo.open();
      svc = HeartbeatService(repo, clock: FixedClock());
      me = (await svc.ensureSelfProfile()).id;
    });

    LabInput li({
      String analyte = 'LDL Kolesterol',
      String value = '142',
      bool notReported = false,
      String unit = 'mg/dL',
      String date = '2026-10-03',
      String flag = 'H',
      String range = '< 130',
    }) => LabInput(
      analyte: analyte,
      value: value,
      notReported: notReported,
      unit: unit,
      sampleDate: date,
      specimen: 'serum',
      laboratory: 'Example Lab',
      sourceFlag: flag,
      referenceText: range,
    );

    test(
      'every printed field is kept verbatim and nothing else is added',
      () async {
        final r = await svc.recordLab(profileId: me, input: li());
        expect(r.kind, RecordKind.labResult);
        expect(
          r.state,
          RecordState.reported,
          reason: 'a report, not an observation by the app',
        );
        expect(r.quantity, const Quantity(142, 'mg/dL'));
        expect(r.originalText, '142');
        expect(r.observedAt, DateTime.utc(2026, 10, 3));
        expect(
          r.lab,
          const LabDetails(
            analyteLabel: 'LDL Kolesterol',
            specimen: 'serum',
            laboratory: 'Example Lab',
            sourceFlag: 'H',
            referenceText: '< 130',
          ),
        );
        // No diagnosis, label or derived record is generated: the store holds
        // exactly the profile and this one result.
        expect((await repo.records(me)).map((x) => jsonEncode(x.toJson())), [
          jsonEncode(r.toJson()),
        ]);
        final json = jsonEncode(r.toJson()).toLowerCase();
        for (final w in [
          'normal',
          'abnormal',
          'diagnos',
          'risk',
          'critical',
          'interpret',
        ]) {
          expect(json, isNot(contains(w)), reason: w);
        }
      },
    );

    test('a missing unit, flag or range stays missing', () async {
      final r = await svc.recordLab(
        profileId: me,
        input: li(unit: ' ', flag: '', range: ''),
      );
      expect(r.quantity!.unit, isNull);
      expect(r.lab!.sourceFlag, isNull);
      expect(r.lab!.referenceText, isNull);
    });

    test('"the report gives no value" is NOT_REPORTED, never zero', () async {
      final r = await svc.recordLab(
        profileId: me,
        input: li(value: '', notReported: true),
      );
      expect(r.valueStatus, ValueStatus.notReported);
      expect(r.quantity, isNull);
      expect(r.originalText, isNull);
      await expectLater(
        svc.recordLab(
          profileId: me,
          input: li(value: ''),
        ),
        input('EMPTY'),
      );
    });

    test('input errors: name, number, date', () async {
      await expectLater(
        svc.recordLab(
          profileId: me,
          input: li(analyte: ' '),
        ),
        input('LAB_ANALYTE_EMPTY'),
      );
      await expectLater(
        svc.recordLab(
          profileId: me,
          input: li(value: 'pozitif'),
        ),
        input('NOT_A_NUMBER'),
      );
      for (final bad in ['03.10.2026', '2026-02-30', '2026-13-01', '']) {
        await expectLater(
          svc.recordLab(
            profileId: me,
            input: li(date: bad),
          ),
          input('DATE_INVALID'),
          reason: bad,
        );
      }
      // The clock says 2026-10-07 09:00 UTC. Tomorrow in the device's own
      // calendar is refused (review finding: an instant-based check let a
      // mistyped tomorrow through); today is fine.
      final local = FixedClock().nowUtc().toLocal();
      String day(DateTime d) =>
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final today = DateTime(local.year, local.month, local.day);
      await expectLater(
        svc.recordLab(
          profileId: me,
          input: li(date: day(today.add(const Duration(days: 1)))),
        ),
        input('FUTURE_TIME'),
      );
      await svc.recordLab(
        profileId: me,
        input: li(date: day(today)),
      );
    });

    test('a value whose separator could mean thousands is refused, not '
        'guessed (review finding: 150,000 was stored as 150)', () async {
      for (final ambiguous in ['150,000', '7.500', '250.000', '1,234']) {
        await expectLater(
          svc.recordLab(
            profileId: me,
            input: li(value: ambiguous),
          ),
          input('AMBIGUOUS_SEPARATOR'),
          reason: ambiguous,
        );
      }
      for (final (typed, value) in [
        ('150000', 150000.0),
        ('0,125', 0.125),
        ('5,4', 5.4),
        ('7.5', 7.5),
        ('1234,5', 1234.5),
      ]) {
        final r = await svc.recordLab(
          profileId: me,
          input: li(value: typed),
        );
        expect(r.quantity!.value, value, reason: typed);
        expect(r.originalText, typed);
      }
    });

    test('a corrected transcription is a new version; the timeline holds '
        'labs and weights together, Labs only labs', () async {
      final first = await svc.recordLab(
        profileId: me,
        input: li(value: '412'),
      );
      final fixed = await svc.correctLab(
        profileId: me,
        targetId: first.id,
        input: li(value: '142'),
      );
      expect(
        (fixed.supersedesId, fixed.amendReason),
        (first.id, AmendReason.correction),
      );
      final w = await svc.recordWeightKg(profileId: me, input: '70');
      final labs = await svc.labTimeline(me);
      expect(labs.single.heads.single.id, fixed.id);
      expect(labs.single.versions.map((v) => v.id), [first.id, fixed.id]);
      final all = await svc.timeline(me);
      expect(all.map((e) => e.shown.id).toSet(), {fixed.id, w.id});
      await expectLater(
        svc.correctLab(profileId: me, targetId: w.id, input: li()),
        input('TARGET_WRONG_KIND'),
      );
    });
  });
}
