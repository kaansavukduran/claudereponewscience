// U029@v0.32 (D-039): derived values from the person's records. The latest
// live measured weight, height and waist go into MP-CORE-DERIVED-1; each
// result keeps its model, the records used, the missing inputs and the
// limitations. Missing is never zero; a conflict is never resolved by the
// app; records far apart are still used, with both dates kept.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/derived/derived_from_records.dart';
import 'package:human_health_os/src/domain/engines/calc_result.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

HealthRecord rec(
  String id,
  RecordKind kind,
  double? value, {
  required DateTime at,
  String? supersedes,
  AmendReason? reason,
}) {
  final present = value != null;
  return HealthRecord(
    id: id,
    profileId: 'p1',
    kind: kind,
    state: RecordState.observed,
    valueStatus: present ? ValueStatus.present : ValueStatus.notMeasured,
    quantity: present ? Quantity(value, kind.unit) : null,
    originalText: present ? '$value' : null,
    provenance: const Provenance.manual(),
    observedAt: at,
    recordedAt: at,
    supersedesId: supersedes,
    amendReason: reason,
    schemaVersion: HealthRecord.currentSchemaVersion,
  );
}

List<TimelineEntry> tl(List<HealthRecord> rs) => buildTimeline(rs);

DerivedRow byId(List<DerivedRow> rows, String id) =>
    rows.singleWhere((r) => r.model.modelId == id);

void main() {
  final d1 = DateTime.utc(2026, 1, 10, 8);
  final d2 = DateTime.utc(2026, 6, 1, 8);

  test('present inputs: BMI and waist-to-height worked out, with the records '
      'used, model ID, version and limitations', () {
    final rows = derivedFromRecords(
      weights: tl([rec('w', RecordKind.bodyWeight, 80, at: d2)]),
      heights: tl([rec('h', RecordKind.height, 180, at: d2)]),
      waists: tl([rec('c', RecordKind.waistCircumference, 90, at: d2)]),
    );
    final bmi = byId(rows, 'DERIVED-BMI-1');
    expect(bmi.computed, isTrue);
    expect(bmi.result.value, closeTo(80 / (1.8 * 1.8), 1e-9));
    expect(bmi.model.version, '1');
    expect(bmi.model.resultClass, ResultClass.derivedMeasurement);
    expect(bmi.result.inputs, {'weight_kg': 80.0, 'height_m': 1.8});
    expect(bmi.needs, isEmpty);
    expect([for (final u in bmi.used) u.record.id], ['w', 'h']);
    expect(bmi.model.limitations, isNotEmpty);
    expect(bmi.daysApart, 0);

    final whr = byId(rows, 'DERIVED-WAIST_HEIGHT_RATIO-1');
    expect(whr.computed, isTrue);
    expect(whr.result.value, closeTo(0.5, 1e-12));
    expect(
      [for (final u in whr.used) u.kind],
      [RecordKind.waistCircumference, RecordKind.height],
    );
  });

  test('missing height: no value (never 0), "needs height", the engine '
      'names the missing input', () {
    final rows = derivedFromRecords(
      weights: tl([rec('w', RecordKind.bodyWeight, 80, at: d2)]),
      heights: const [],
      waists: const [],
    );
    final bmi = byId(rows, 'DERIVED-BMI-1');
    expect(bmi.computed, isFalse);
    expect(bmi.result.value, isNull);
    expect(bmi.result.status, CalcStatus.missingInput);
    expect(bmi.result.missingInputs, ['height_m']);
    expect(bmi.needs, [RecordKind.height]);
    expect([for (final u in bmi.used) u.record.id], ['w']);
    expect(bmi.daysApart, isNull);
    final whr = byId(rows, 'DERIVED-WAIST_HEIGHT_RATIO-1');
    expect(whr.result.value, isNull);
    expect(whr.needs, [RecordKind.waistCircumference, RecordKind.height]);
    expect(whr.used, isEmpty);
  });

  test('two inputs with different dates: still worked out; both dates kept '
      'and the days between them stated, no staleness rule added', () {
    final rows = derivedFromRecords(
      weights: tl([rec('w', RecordKind.bodyWeight, 72, at: d2)]),
      heights: tl([rec('h', RecordKind.height, 170, at: d1)]),
      waists: const [],
    );
    final bmi = byId(rows, 'DERIVED-BMI-1');
    expect(bmi.computed, isTrue);
    expect(bmi.result.value, closeTo(72 / (1.7 * 1.7), 1e-9));
    final dates = {for (final u in bmi.used) u.kind: u.record.observedAt};
    expect(dates[RecordKind.bodyWeight], d2);
    expect(dates[RecordKind.height], d1);
    expect(bmi.daysApart, d2.difference(d1).inDays);
    expect(bmi.daysApart, greaterThan(90));
  });

  test('the newest measured entry is used; a newer "not measured" entry is '
      'history, a correction replaces its target', () {
    final rows = derivedFromRecords(
      weights: tl([
        rec('w1', RecordKind.bodyWeight, 90, at: d1),
        rec('w2', RecordKind.bodyWeight, 80, at: d2),
        rec(
          'w2b',
          RecordKind.bodyWeight,
          81,
          at: d2,
          supersedes: 'w2',
          reason: AmendReason.correction,
        ),
      ]),
      heights: tl([
        rec('h1', RecordKind.height, 180, at: d1),
        rec('h2', RecordKind.height, null, at: d2),
      ]),
      waists: const [],
    );
    final bmi = byId(rows, 'DERIVED-BMI-1');
    expect([for (final u in bmi.used) u.record.id], ['w2b', 'h1']);
    expect(bmi.result.value, closeTo(81 / (1.8 * 1.8), 1e-9));
  });

  test('a conflict (two live versions) is not resolved by the app', () {
    final rows = derivedFromRecords(
      weights: tl([rec('w', RecordKind.bodyWeight, 80, at: d2)]),
      heights: tl([
        rec('h', RecordKind.height, 180, at: d1),
        rec(
          'ha',
          RecordKind.height,
          181,
          at: d1,
          supersedes: 'h',
          reason: AmendReason.correction,
        ),
        rec(
          'hb',
          RecordKind.height,
          179,
          at: d1.add(const Duration(minutes: 1)),
          supersedes: 'h',
          reason: AmendReason.correction,
        ),
      ]),
      waists: const [],
    );
    final bmi = byId(rows, 'DERIVED-BMI-1');
    expect(bmi.result.value, isNull);
    expect(bmi.unresolved, [RecordKind.height]);
    expect(bmi.needs, isEmpty);
  });

  test('R013: a conflict between a measured and a not-measured version is '
      'not settled by dropping the not-measured one', () {
    final rows = derivedFromRecords(
      weights: tl([
        rec('w', RecordKind.bodyWeight, 80, at: d1),
        rec(
          'wa',
          RecordKind.bodyWeight,
          81,
          at: d1,
          supersedes: 'w',
          reason: AmendReason.correction,
        ),
        rec(
          'wb',
          RecordKind.bodyWeight,
          null,
          at: d1.add(const Duration(minutes: 1)),
          supersedes: 'w',
          reason: AmendReason.correction,
        ),
      ]),
      heights: tl([rec('h', RecordKind.height, 180, at: d1)]),
      waists: const [],
    );
    final bmi = byId(rows, 'DERIVED-BMI-1');
    expect(bmi.result.value, isNull);
    expect(bmi.unresolved, [RecordKind.bodyWeight]);
  });

  test('R013: the newest height withdrawn as entered in error: the earlier '
      'one is used', () {
    final rows = derivedFromRecords(
      weights: tl([rec('w', RecordKind.bodyWeight, 80, at: d2)]),
      heights: tl([
        rec('h1', RecordKind.height, 180, at: d1),
        rec('h2', RecordKind.height, 190, at: d2),
        rec(
          'x',
          RecordKind.height,
          null,
          at: d2,
          supersedes: 'h2',
          reason: AmendReason.enteredInError,
        ),
      ]),
      waists: const [],
    );
    final bmi = byId(rows, 'DERIVED-BMI-1');
    expect([for (final u in bmi.used) u.record.id], ['w', 'h1']);
    expect(bmi.result.inputs['height_m'], 1.8);
  });
}
