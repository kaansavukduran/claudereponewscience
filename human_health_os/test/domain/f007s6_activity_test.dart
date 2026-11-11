// F007 slice 6: activity typed by hand. Minutes and steps are whole numbers
// or not given (never zero by default); nothing is estimated or summed.
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
  test('kept as typed; blank minutes or steps stay not given', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordActivity(
      profileId: me,
      what: ' walk ',
      minutes: '20',
    );
    final d = r.details! as ActivityEntryDetails;
    expect(d.what, 'walk');
    expect(d.minutes, 20);
    expect(d.steps, isNull);
    expect(r.quantity, isNull);
    expect(r.schemaVersion, 10);
    expect((await svc.activities(me)).single.id, r.id);
  });

  test('refused entries name their field and write nothing', () async {
    final (svc, me, repo) = await fresh();
    expect(
      () => svc.recordActivity(profileId: me, what: ''),
      inputError('EMPTY', 'what'),
    );
    expect(
      () => svc.recordActivity(profileId: me, what: 'walk', minutes: '20.5'),
      inputError('NOT_A_WHOLE_NUMBER', 'minutes'),
    );
    expect(
      () => svc.recordActivity(profileId: me, what: 'walk', minutes: '0'),
      inputError('ACTIVITY_MINUTES_RANGE', 'minutes'),
    );
    expect(
      () => svc.recordActivity(profileId: me, what: 'walk', minutes: '1441'),
      inputError('ACTIVITY_MINUTES_RANGE', 'minutes'),
    );
    expect(
      () => svc.recordActivity(profileId: me, what: 'walk', steps: '-5'),
      inputError('NOT_A_WHOLE_NUMBER', 'steps'),
    );
    expect(
      () => svc.recordActivity(profileId: me, what: 'walk', steps: '200001'),
      inputError('ACTIVITY_STEPS_RANGE', 'steps'),
    );
    expect(await repo.records(me, kind: RecordKind.activityEntry), isEmpty);
    final edge = await svc.recordActivity(
      profileId: me,
      what: 'hike',
      minutes: '1440',
      steps: '200000',
    );
    expect((edge.details! as ActivityEntryDetails).steps, 200000);
  });

  test('round trip at schema 10; corrected as a new version', () async {
    final (svc, me, repo) = await fresh();
    final r = await svc.recordActivity(
      profileId: me,
      what: 'cycling',
      minutes: '45',
      steps: '300',
      when: '2026-11-09 18:20',
    );
    final back = HealthRecord.fromJson(r.toJson());
    expect(back.details, r.details);
    expect((back.details! as ActivityEntryDetails).steps, 300);
    expect(back.validate, returnsNormally);
    // Another writer's integral 20.0 reads as 20; 20.5 is a format error.
    Map<String, Object?> withMinutes(Object v) => {
      ...r.toJson(),
      'details': {...r.details!.toJson(), 'minutes': v},
    };
    expect(
      (HealthRecord.fromJson(withMinutes(20.0)).details!
              as ActivityEntryDetails)
          .minutes,
      20,
    );
    expect(
      () => HealthRecord.fromJson(withMinutes(20.5)),
      throwsA(isA<FormatException>()),
    );
    final fixed = await svc.recordActivity(
      profileId: me,
      what: 'cycling',
      minutes: '20',
      correcting: r.id,
    );
    expect(fixed.supersedesId, r.id);
    expect(fixed.amendReason, AmendReason.correction);
    // A correction left without a time keeps the entry's own time.
    expect(fixed.observedAt, r.observedAt);
    expect((await svc.activities(me)).single.id, fixed.id);
    expect(
      await repo.records(me, kind: RecordKind.activityEntry),
      hasLength(2),
    );
    final w = await svc.recordWeightKg(profileId: me, input: '70');
    expect(
      () => svc.recordActivity(profileId: me, what: 'x', correcting: w.id),
      inputError('TARGET_WRONG_KIND'),
    );
  });
}
