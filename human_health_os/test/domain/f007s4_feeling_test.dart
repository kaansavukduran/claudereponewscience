// F007 slice 4: how the person says they feel. Each level is their own and
// optional; one not given stays not given; nothing is scored or summed.
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

void main() {
  test('a check-in keeps only the levels given; none given is refused and '
      'nothing is written', () async {
    final (svc, me, repo) = await fresh();
    expect(
      () => svc.recordFeeling(profileId: me),
      throwsA(isA<InputError>().having((e) => e.code, 'code', 'CHECKIN_EMPTY')),
    );
    expect(await repo.records(me, kind: RecordKind.feelingCheckIn), isEmpty);
    final r = await svc.recordFeeling(
      profileId: me,
      energy: SelfLevel.low,
      stress: SelfLevel.high,
    );
    final d = r.details! as FeelingCheckInDetails;
    expect(d.energy, SelfLevel.low);
    expect(d.mood, isNull);
    expect(d.stress, SelfLevel.high);
    expect(r.quantity, isNull);
    expect(r.state, RecordState.reported);
    expect(r.schemaVersion, 8);
    expect((await svc.feelings(me)).single.id, r.id);
  });

  test('round trip at schema 8; an empty stored check-in is refused', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordFeeling(profileId: me, mood: SelfLevel.medium);
    final back = HealthRecord.fromJson(r.toJson());
    expect(back.details, r.details);
    expect(back.validate, returnsNormally);
    final empty = HealthRecord.fromJson({
      ...r.toJson(),
      'details': {'type': 'feeling_check_in'},
    });
    expect(
      empty.validate,
      throwsA(
        isA<RecordValidationError>().having(
          (e) => e.code,
          'code',
          'CHECKIN_EMPTY',
        ),
      ),
    );
    expect(RecordKind.feelingCheckIn.isMeasurement, isFalse);
  });

  test('a check-in entered in error leaves the list', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordFeeling(profileId: me, energy: SelfLevel.high);
    await svc.amend(
      profileId: me,
      targetId: r.id,
      reason: AmendReason.enteredInError,
    );
    expect(await svc.feelings(me), isEmpty);
  });
}
