// F010 slice 1: a document reference. What exists and where the person keeps
// it, each field as typed; no file bytes, no reading, no extraction.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

import 'f009_conditions_test.dart' show fresh, inputError;

void main() {
  test('kept as typed; state stays reported; only reference fields are '
      'stored, never file bytes or extracted content', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordDocument(
      profileId: me,
      title: ' Blood test report ',
      nature: DocumentType.labReport,
      date: ' 2025-03 ',
      issuer: ' City Clinic ',
      whereKept: ' paper folder at home ',
    );
    final d = r.details! as DocumentReferenceDetails;
    expect(d.title, 'Blood test report');
    expect(d.nature, DocumentType.labReport);
    expect(d.date, '2025-03');
    expect(d.issuer, 'City Clinic');
    expect(d.whereKept, 'paper folder at home');
    expect(r.state, RecordState.reported);
    expect(r.kind, RecordKind.documentReference);
    expect(r.kind.code, 'document.reference');
    expect(r.schemaVersion, 13);
    expect(r.kind.minSchema, 13);
    expect(HealthRecord.currentSchemaVersion, 13);
    expect(r.quantity, isNull);
    expect(r.originalText, isNull);
    expect(d.toJson().keys.toSet(), {
      'type',
      'title',
      'nature',
      'date',
      'issuer',
      'where_kept',
    });
    expect(d.toJson()['type'], 'document_reference');
    expect((await svc.documents(me)).single.id, r.id);
  });

  test('refused entries name their field and write nothing', () async {
    final (svc, me, repo) = await fresh();
    for (final (call, code, field) in [
      (
        () => svc.recordDocument(
          profileId: me,
          title: '  ',
          nature: DocumentType.other,
        ),
        'EMPTY',
        'title',
      ),
      (
        () => svc.recordDocument(
          profileId: me,
          title: 'x' * 301,
          nature: DocumentType.other,
        ),
        'TEXT_TOO_LONG',
        'title',
      ),
      (
        () => svc.recordDocument(
          profileId: me,
          title: 'Letter',
          nature: DocumentType.letter,
          date: 'x' * 301,
        ),
        'TEXT_TOO_LONG',
        'date',
      ),
      (
        () => svc.recordDocument(
          profileId: me,
          title: 'Letter',
          nature: DocumentType.letter,
          issuer: 'x' * 301,
        ),
        'TEXT_TOO_LONG',
        'issuer',
      ),
      (
        () => svc.recordDocument(
          profileId: me,
          title: 'Letter',
          nature: DocumentType.letter,
          whereKept: 'x' * 301,
        ),
        'TEXT_TOO_LONG',
        'whereKept',
      ),
    ]) {
      expect(call, inputError(code, field), reason: '$code $field');
    }
    expect(await repo.records(me, kind: RecordKind.documentReference), isEmpty);
  });

  test('blank optional fields are missing (null), never empty text or an '
      'invented date', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordDocument(
      profileId: me,
      title: 'Vaccination card',
      nature: DocumentType.vaccinationCard,
      date: '   ',
      issuer: '',
      whereKept: ' ',
    );
    final d = r.details! as DocumentReferenceDetails;
    expect(d.date, isNull);
    expect(d.issuer, isNull);
    expect(d.whereKept, isNull);
    expect(d.toJson()['date'], isNull);
    expect(d.toJson()['issuer'], isNull);
    expect(d.toJson()['where_kept'], isNull);
  });

  test('round trip at schema 13; corrected as a new version that keeps its '
      'time and the earlier version; unknown or non-text stored values are '
      'format errors', () async {
    final (svc, me, repo) = await fresh();
    final r = await svc.recordDocument(
      profileId: me,
      title: 'Discharge letter',
      nature: DocumentType.letter,
      issuer: 'St. Mary',
    );
    final back = HealthRecord.fromJson(r.toJson());
    expect(back.details, r.details);
    expect(back.kind, RecordKind.documentReference);
    expect(back.validate, returnsNormally);
    final fixed = await svc.recordDocument(
      profileId: me,
      title: 'Discharge letter',
      nature: DocumentType.letter,
      issuer: 'St. Mary Hospital',
      whereKept: 'email',
      correcting: r.id,
    );
    expect(fixed.supersedesId, r.id);
    expect(fixed.amendReason, AmendReason.correction);
    expect(fixed.observedAt, r.observedAt);
    final shown = (await svc.documents(me)).single;
    expect(shown.id, fixed.id);
    expect((shown.details! as DocumentReferenceDetails).whereKept, 'email');
    final stored = await repo.records(me, kind: RecordKind.documentReference);
    expect(stored, hasLength(2));
    expect(
      (stored.firstWhere((x) => x.id == r.id).details!
              as DocumentReferenceDetails)
          .issuer,
      'St. Mary',
      reason: 'the earlier version is kept, never rewritten',
    );
    for (final (key, value) in <(String, Object?)>[
      ('nature', 'scan'),
      ('nature', 'diagnosis'),
      ('nature', null),
      ('nature', 3),
      ('title', null),
      ('title', 7),
      ('date', 2025),
      ('issuer', true),
      ('where_kept', ['home']),
    ]) {
      expect(
        () => HealthRecord.fromJson({
          ...r.toJson(),
          'details': {...r.details!.toJson(), key: value},
        }),
        throwsA(isA<FormatException>()),
        reason: '$key: $value',
      );
    }
  });

  test('another kind cannot be corrected here, nor a document as another '
      'kind', () async {
    final (svc, me, _) = await fresh();
    final doc = await svc.recordDocument(
      profileId: me,
      title: 'Prescription',
      nature: DocumentType.prescription,
    );
    final c = await svc.recordCondition(
      profileId: me,
      name: 'Asthma',
      nature: ConditionType.condition,
      time: ConditionTime.current,
      source: ConditionSource.selfReported,
    );
    expect(
      () => svc.recordDocument(
        profileId: me,
        title: 'x',
        nature: DocumentType.other,
        correcting: c.id,
      ),
      inputError('TARGET_WRONG_KIND'),
    );
    expect(
      () => svc.recordPreventive(
        profileId: me,
        name: 'x',
        nature: PreventiveType.other,
        status: PreventiveStatus.unsure,
        source: ConditionSource.selfReported,
        correcting: doc.id,
      ),
      inputError('TARGET_WRONG_KIND'),
    );
    expect(await svc.documents(me), hasLength(1));
  });
}
