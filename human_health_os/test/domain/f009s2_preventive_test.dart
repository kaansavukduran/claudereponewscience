// F009 slice 2: a preventive item (vaccination, screening, check-up) as
// named. Planned is never done; no result is stored; nothing is recommended.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';

import 'f009_conditions_test.dart' show fresh, inputError;

void main() {
  test('kept as named, with its status and source; state stays reported; '
      'no result, schedule or due date is stored', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordPreventive(
      profileId: me,
      name: ' Tetanus vaccine ',
      nature: PreventiveType.vaccination,
      status: PreventiveStatus.planned,
      source: ConditionSource.toldByClinician,
      when: ' 2027-03 ',
    );
    final d = r.details! as PreventiveEntryDetails;
    expect(d.name, 'Tetanus vaccine');
    expect(d.nature, PreventiveType.vaccination);
    // Planned is never done.
    expect(d.status, PreventiveStatus.planned);
    expect(d.status, isNot(PreventiveStatus.done));
    expect(d.source, ConditionSource.toldByClinician);
    expect(d.when, '2027-03');
    expect(r.state, RecordState.reported);
    expect(r.schemaVersion, 12);
    expect(r.kind.minSchema, 12);
    expect(r.quantity, isNull);
    // Only these keys: no result, interpretation, due date or reminder.
    expect(d.toJson().keys.toSet(), {
      'type',
      'name',
      'nature',
      'status',
      'source',
      'when',
    });
    expect((await svc.preventives(me)).single.id, r.id);
  });

  test('refused entries name their field and write nothing', () async {
    final (svc, me, repo) = await fresh();
    expect(
      () => svc.recordPreventive(
        profileId: me,
        name: '  ',
        nature: PreventiveType.screening,
        status: PreventiveStatus.unsure,
        source: ConditionSource.selfReported,
      ),
      inputError('EMPTY', 'name'),
    );
    expect(
      () => svc.recordPreventive(
        profileId: me,
        name: 'x' * 301,
        nature: PreventiveType.other,
        status: PreventiveStatus.unsure,
        source: ConditionSource.selfReported,
      ),
      inputError('TEXT_TOO_LONG', 'name'),
    );
    expect(
      () => svc.recordPreventive(
        profileId: me,
        name: 'Dental check',
        nature: PreventiveType.checkup,
        status: PreventiveStatus.done,
        source: ConditionSource.selfReported,
        when: 'x' * 301,
      ),
      inputError('TEXT_TOO_LONG', 'when'),
    );
    expect(await repo.records(me, kind: RecordKind.preventiveEntry), isEmpty);
  });

  test('round trip at schema 12; corrected as a new version that keeps its '
      'time and the earlier version; unknown stored values are format '
      'errors', () async {
    final (svc, me, repo) = await fresh();
    final r = await svc.recordPreventive(
      profileId: me,
      name: 'Mammography',
      nature: PreventiveType.screening,
      status: PreventiveStatus.planned,
      source: ConditionSource.selfReported,
    );
    final back = HealthRecord.fromJson(r.toJson());
    expect(back.details, r.details);
    expect(back.kind, RecordKind.preventiveEntry);
    expect(back.validate, returnsNormally);
    // A correction never turns planned into done: carrying out a plan is a
    // new entry (planned ≠ completed).
    expect(
      () => svc.recordPreventive(
        profileId: me,
        name: 'Mammography',
        nature: PreventiveType.screening,
        status: PreventiveStatus.done,
        source: ConditionSource.selfReported,
        correcting: r.id,
      ),
      throwsA(
        isA<InputError>()
            .having((e) => e.code, 'code', 'PLANNED_NOT_DONE')
            .having((e) => e.field, 'field', 'status'),
      ),
    );
    final fixed = await svc.recordPreventive(
      profileId: me,
      name: 'Mammography',
      nature: PreventiveType.screening,
      status: PreventiveStatus.planned,
      source: ConditionSource.fromDocument,
      when: 'next spring',
      correcting: r.id,
    );
    expect(fixed.supersedesId, r.id);
    expect(fixed.amendReason, AmendReason.correction);
    expect(fixed.observedAt, r.observedAt);
    final shown = (await svc.preventives(me)).single;
    expect(shown.id, fixed.id);
    expect(
      (shown.details! as PreventiveEntryDetails).source,
      ConditionSource.fromDocument,
    );
    final stored = await repo.records(me, kind: RecordKind.preventiveEntry);
    expect(stored, hasLength(2));
    expect(
      (stored.firstWhere((x) => x.id == r.id).details!
              as PreventiveEntryDetails)
          .status,
      PreventiveStatus.planned,
      reason: 'the earlier version is kept, never rewritten',
    );
    for (final (key, value) in [
      ('status', 'completed'),
      ('status', 'due'),
      ('nature', 'diagnostic'),
      ('source', 'confirmed'),
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

  test('a blank "when" is missing; another kind cannot be corrected here; a '
      'stored "when" that is not text is a format error', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordPreventive(
      profileId: me,
      name: 'Eye check',
      nature: PreventiveType.checkup,
      status: PreventiveStatus.unsure,
      source: ConditionSource.selfReported,
      when: '   ',
    );
    expect((r.details! as PreventiveEntryDetails).when, isNull);
    expect(r.details!.toJson()['when'], isNull);
    final c = await svc.recordCondition(
      profileId: me,
      name: 'Asthma',
      nature: ConditionType.condition,
      time: ConditionTime.current,
      source: ConditionSource.selfReported,
    );
    expect(
      () => svc.recordPreventive(
        profileId: me,
        name: 'x',
        nature: PreventiveType.other,
        status: PreventiveStatus.unsure,
        source: ConditionSource.selfReported,
        correcting: c.id,
      ),
      inputError('TARGET_WRONG_KIND'),
    );
    // And the reverse: a preventive item is not a condition.
    expect(
      () => svc.recordCondition(
        profileId: me,
        name: 'x',
        nature: ConditionType.condition,
        time: ConditionTime.unsure,
        source: ConditionSource.selfReported,
        correcting: r.id,
      ),
      inputError('TARGET_WRONG_KIND'),
    );
    expect(
      () => HealthRecord.fromJson({
        ...r.toJson(),
        'details': {...r.details!.toJson(), 'when': 2024},
      }),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => HealthRecord.fromJson({
        ...r.toJson(),
        'details': {...r.details!.toJson(), 'name': null},
      }),
      throwsA(isA<FormatException>()),
    );
    expect((await svc.preventives(me)).single.id, r.id);
    expect((await svc.conditions(me)).single.id, c.id);
  });

  test('R012: errors name their field; bad stored values are format errors; '
      'unsure to done stays a correction', () async {
    final (svc, me, _) = await fresh();
    expect(
      () => svc.recordPreventive(
        profileId: me,
        name: 'Flu vaccine',
        nature: PreventiveType.vaccination,
        status: PreventiveStatus.planned,
        source: ConditionSource.selfReported,
        when: 'w' * 301,
      ),
      inputError('TEXT_TOO_LONG', 'when'),
    );
    expect(
      () => svc.recordPreventive(
        profileId: me,
        name: 'n' * 301,
        nature: PreventiveType.vaccination,
        status: PreventiveStatus.planned,
        source: ConditionSource.selfReported,
      ),
      inputError('TEXT_TOO_LONG', 'name'),
    );
    final r = await svc.recordPreventive(
      profileId: me,
      name: 'Flu vaccine',
      nature: PreventiveType.vaccination,
      status: PreventiveStatus.unsure,
      source: ConditionSource.selfReported,
    );
    for (final bad in [
      {'status': 'overdue'},
      {'nature': 'surgery'},
      {'source': 'confirmed'},
      {'when': 2024},
    ]) {
      expect(
        () => HealthRecord.fromJson({
          ...r.toJson(),
          'details': {...r.details!.toJson(), ...bad},
        }),
        throwsA(isA<FormatException>()),
        reason: '$bad',
      );
    }
    // Not sure was a mistake: correcting it to done is allowed.
    final fixed = await svc.recordPreventive(
      profileId: me,
      name: 'Flu vaccine',
      nature: PreventiveType.vaccination,
      status: PreventiveStatus.done,
      source: ConditionSource.selfReported,
      correcting: r.id,
    );
    expect(fixed.supersedesId, r.id);
  });
}
