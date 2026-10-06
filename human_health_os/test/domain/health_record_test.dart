import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

HealthRecord weight({
  ValueStatus status = ValueStatus.present,
  Quantity? q = const Quantity(78.4, 'kg'),
  String id = 'r1',
  String? supersedes,
  DateTime? observedAt,
  DateTime? recordedAt,
}) => HealthRecord(
  id: id,
  profileId: 'p1',
  kind: RecordKind.bodyWeight,
  state: RecordState.observed,
  valueStatus: status,
  quantity: q,
  originalText: '78,4',
  provenance: const Provenance.manual(),
  observedAt: observedAt ?? DateTime.utc(2026, 10, 6, 8),
  recordedAt: recordedAt ?? DateTime.utc(2026, 10, 6, 8, 1),
  supersedesId: supersedes,
);

Matcher throwsCode(String code) =>
    throwsA(isA<RecordValidationError>().having((e) => e.code, 'code', code));

void main() {
  test('a valid weight observation passes', () => weight().validate());

  test('PRESENT without a quantity is rejected', () {
    expect(
      () => weight(q: null).validate(),
      throwsCode('PRESENT_REQUIRES_QUANTITY'),
    );
  });

  test('missing ≠ zero: a not-measured value cannot carry a number', () {
    expect(
      () => weight(
        status: ValueStatus.notMeasured,
        q: const Quantity(0, 'kg'),
      ).validate(),
      throwsCode('MISSING_HAS_NO_QUANTITY'),
    );
    weight(status: ValueStatus.notMeasured, q: null).validate();
  });

  test('units are never converted silently', () {
    expect(
      () => weight(q: const Quantity(172, 'lb')).validate(),
      throwsCode('UNIT_NOT_SUPPORTED'),
    );
  });

  test('implausible weights are rejected', () {
    expect(
      () => weight(q: const Quantity(0, 'kg')).validate(),
      throwsCode('OUT_OF_PLAUSIBLE_RANGE'),
    );
    expect(
      () => weight(q: const Quantity(701, 'kg')).validate(),
      throwsCode('OUT_OF_PLAUSIBLE_RANGE'),
    );
    expect(
      () => weight(q: const Quantity(double.nan, 'kg')).validate(),
      throwsCode('OUT_OF_PLAUSIBLE_RANGE'),
    );
  });

  test('timestamps must be UTC; a record cannot supersede itself', () {
    expect(
      () => weight(observedAt: DateTime(2026, 10, 6)).validate(),
      throwsCode('NON_UTC_TIME'),
    );
    expect(
      () => weight(supersedes: 'r1').validate(),
      throwsCode('SELF_SUPERSEDE'),
    );
  });

  test('JSON round trip keeps original text, provenance and status', () {
    final r = weight();
    final back = HealthRecord.fromJson(r.toJson());
    expect(back.toJson(), r.toJson());
    expect(back.originalText, '78,4');
    expect(back.provenance.kind, ProvenanceKind.manual);
  });

  test('a newer record schema is refused, not silently misread', () {
    final j = weight().toJson()..['schema_version'] = 99;
    expect(() => HealthRecord.fromJson(j), throwsFormatException);
  });

  test('corrections: superseded records leave the current view but stay in history', () {
    final a = weight(id: 'a', observedAt: DateTime.utc(2026, 10, 1));
    final b = weight(id: 'b', observedAt: DateTime.utc(2026, 10, 5));
    final bFix = weight(
      id: 'b2',
      supersedes: 'b',
      q: const Quantity(77.9, 'kg'),
      observedAt: DateTime.utc(2026, 10, 5),
    );
    final current = currentRecords([a, b, bFix]);
    expect(current.map((r) => r.id), ['b2', 'a']);
  });
}
