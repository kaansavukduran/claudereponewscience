// F009 slice 1: a condition or symptom as named, with who it comes from.
// The app confirms nothing; a self-report stays a self-report.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

Future<(HeartbeatService, String, LogRepository)> fresh() async {
  final repo = LogRepository(
    sink: MemoryLogSink(),
    durability: StorageDurability.localFile,
    location: 'test',
  );
  await repo.open();
  final svc = HeartbeatService(repo);
  final me = (await svc.ensureSelfProfile()).id;
  return (svc, me, repo);
}

Matcher inputError(String code, [String? field]) => throwsA(
  isA<InputError>()
      .having((e) => e.code, 'code', code)
      .having((e) => field == null || e.field == field, 'field', isTrue),
);

void main() {
  test('kept as named, with its source; state stays reported', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordCondition(
      profileId: me,
      name: ' Migraine ',
      nature: ConditionType.condition,
      time: ConditionTime.current,
      source: ConditionSource.toldByClinician,
      since: '2019',
    );
    final d = r.details! as ConditionEntryDetails;
    expect(d.name, 'Migraine');
    expect(d.source, ConditionSource.toldByClinician);
    expect(d.since, '2019');
    // "Told by a clinician" is what the person says: never a confirmed
    // record state.
    expect(r.state, RecordState.reported);
    expect(r.schemaVersion, 11);
    expect((await svc.conditions(me)).single.id, r.id);
  });

  test('refused entries name their field and write nothing', () async {
    final (svc, me, repo) = await fresh();
    expect(
      () => svc.recordCondition(
        profileId: me,
        name: ' ',
        nature: ConditionType.symptom,
        time: ConditionTime.unsure,
        source: ConditionSource.selfReported,
      ),
      inputError('EMPTY', 'name'),
    );
    expect(
      () => svc.recordCondition(
        profileId: me,
        name: 'Cough',
        nature: ConditionType.symptom,
        time: ConditionTime.current,
        source: ConditionSource.selfReported,
        since: 'x' * 301,
      ),
      inputError('TEXT_TOO_LONG', 'since'),
    );
    expect(await repo.records(me, kind: RecordKind.conditionEntry), isEmpty);
  });

  test('round trip at schema 11; corrected as a new version; unknown '
      'stored values are format errors', () async {
    final (svc, me, repo) = await fresh();
    final r = await svc.recordCondition(
      profileId: me,
      name: 'Back pain',
      nature: ConditionType.symptom,
      time: ConditionTime.current,
      source: ConditionSource.selfReported,
    );
    final back = HealthRecord.fromJson(r.toJson());
    expect(back.details, r.details);
    expect(back.validate, returnsNormally);
    final fixed = await svc.recordCondition(
      profileId: me,
      name: 'Back pain',
      nature: ConditionType.symptom,
      time: ConditionTime.past,
      source: ConditionSource.selfReported,
      correcting: r.id,
    );
    expect(fixed.supersedesId, r.id);
    expect(fixed.amendReason, AmendReason.correction);
    expect(fixed.observedAt, r.observedAt);
    expect(
      ((await svc.conditions(me)).single.details! as ConditionEntryDetails)
          .time,
      ConditionTime.past,
    );
    expect(
      await repo.records(me, kind: RecordKind.conditionEntry),
      hasLength(2),
    );
    expect(
      () => HealthRecord.fromJson({
        ...r.toJson(),
        'details': {...r.details!.toJson(), 'source': 'confirmed'},
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('a blank "since" is not given; another kind cannot be corrected '
      'here; a stored "since" that is not text is a format error', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordCondition(
      profileId: me,
      name: 'Asthma',
      nature: ConditionType.condition,
      time: ConditionTime.unsure,
      source: ConditionSource.fromDocument,
      since: '   ',
    );
    expect((r.details! as ConditionEntryDetails).since, isNull);
    final w = await svc.recordWeightKg(profileId: me, input: '70');
    expect(
      () => svc.recordCondition(
        profileId: me,
        name: 'x',
        nature: ConditionType.condition,
        time: ConditionTime.unsure,
        source: ConditionSource.selfReported,
        correcting: w.id,
      ),
      inputError('TARGET_WRONG_KIND'),
    );
    expect(
      () => HealthRecord.fromJson({
        ...r.toJson(),
        'details': {...r.details!.toJson(), 'since': 2019},
      }),
      throwsA(isA<FormatException>()),
    );
    expect(r.details!.toJson()['nature'], 'condition');
  });
}
