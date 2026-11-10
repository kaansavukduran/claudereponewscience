// F007 slice 3: one night as typed. Going to bed and waking up are kept as
// instants; the time between them is time in bed, not time asleep; a feeling
// not given stays not given; impossible nights are refused, nothing written.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/application/measured_at.dart';
import 'package:human_health_os/src/core/ids.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

class _At implements Clock {
  _At(this.t);
  final DateTime t;
  @override
  DateTime nowUtc() => t;
}

Future<(HeartbeatService, String, LogRepository)> fresh() async {
  final repo = LogRepository(
    sink: MemoryLogSink(),
    durability: StorageDurability.localFile,
    location: 'test',
  );
  await repo.open();
  final svc = HeartbeatService(
    repo,
    clock: _At(DateTime.utc(2026, 11, 10, 15)),
  );
  final me = (await svc.ensureSelfProfile()).id;
  return (svc, me, repo);
}

Matcher inputError(String code, [String? field]) => throwsA(
  isA<InputError>()
      .having((e) => e.code, 'code', code)
      .having((e) => field == null || e.field == field, 'field', isTrue),
);

/// The host's zone never matters: every test names its zone.
const utc = OffsetRuleZone(_zero);
Duration _zero(DateTime _) => Duration.zero;

/// America/New_York in 2026 (clock changes 8 March and 1 November).
final newYork = OffsetRuleZone((t) {
  final spring = DateTime.utc(2026, 3, 8, 7);
  final autumn = DateTime.utc(2026, 11, 1, 6);
  return !t.isBefore(spring) && t.isBefore(autumn)
      ? const Duration(hours: -4)
      : const Duration(hours: -5);
});

void main() {
  test('"23:10" then "07:00" is one night across midnight, 7 h 50 min in '
      'bed; no feeling given stays null', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordSleep(
      zone: utc,
      profileId: me,
      wentToBed: '23:10',
      wokeUp: '07:00',
    );
    final d = r.details! as SleepNightDetails;
    expect(d.timeInBed, const Duration(hours: 7, minutes: 50));
    expect(utc.toLocal(d.wokeUp).hour, 7);
    expect(utc.toLocal(d.wentToBed).hour, 23);
    expect(utc.toLocal(d.wentToBed).day, utc.toLocal(d.wokeUp).day - 1);
    expect(d.feeling, isNull);
    expect(r.observedAt, d.wokeUp);
    expect(r.quantity, isNull);
    expect(r.schemaVersion, 7);
  });

  test('a going-to-bed time after midnight is the same morning', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordSleep(
      zone: utc,
      profileId: me,
      wentToBed: '00:30',
      wokeUp: '07:00',
      feeling: WakeFeeling.tired,
    );
    final d = r.details! as SleepNightDetails;
    expect(d.timeInBed, const Duration(hours: 6, minutes: 30));
    expect(d.feeling, WakeFeeling.tired);
  });

  test('impossible nights are refused and nothing is written', () async {
    final (svc, me, repo) = await fresh();
    expect(
      () => svc.recordSleep(zone: utc, profileId: me, wentToBed: '  '),
      inputError('EMPTY'),
    );
    expect(
      () => svc.recordSleep(
        zone: utc,
        profileId: me,
        wentToBed: '2026-11-09 08:00',
        wokeUp: '2026-11-09 07:00',
      ),
      inputError('SLEEP_WAKE_NOT_AFTER_BED'),
    );
    expect(
      () => svc.recordSleep(
        zone: utc,
        profileId: me,
        wentToBed: '2026-11-07 22:00',
        wokeUp: '2026-11-09 07:00',
      ),
      inputError('SLEEP_TOO_LONG'),
    );
    expect(
      () => svc.recordSleep(
        zone: utc,
        profileId: me,
        wentToBed: '22:00',
        wokeUp: '2999-01-01 07:00',
      ),
      inputError('FUTURE_TIME'),
    );
    expect(await repo.records(me, kind: RecordKind.sleepNight), isEmpty);
  });

  test('nights come latest first and survive a round trip at schema 7; a '
      'stored night that is impossible is refused', () async {
    final (svc, me, _) = await fresh();
    await svc.recordSleep(
      zone: utc,
      profileId: me,
      wentToBed: '2026-11-07 23:00',
      wokeUp: '2026-11-08 06:30',
    );
    final later = await svc.recordSleep(
      zone: utc,
      profileId: me,
      wentToBed: '2026-11-08 22:45',
      wokeUp: '2026-11-09 06:15',
      feeling: WakeFeeling.rested,
    );
    final nights = await svc.sleepNights(me);
    expect(nights.map((n) => n.id).first, later.id);
    expect(nights, hasLength(2));
    final back = HealthRecord.fromJson(later.toJson());
    expect(back.details, later.details);
    expect(back.validate, returnsNormally);
    final impossible = HealthRecord.fromJson({
      ...later.toJson(),
      'details': {
        ...(later.details! as SleepNightDetails).toJson(),
        'woke_up': '2026-11-08T21:00:00.000Z',
      },
    });
    expect(
      impossible.validate,
      throwsA(
        isA<RecordValidationError>().having(
          (e) => e.code,
          'code',
          'SLEEP_WAKE_NOT_AFTER_BED',
        ),
      ),
    );
  });

  test('a night is never a measurement and has no quantity', () {
    expect(RecordKind.sleepNight.isMeasurement, isFalse);
    expect(RecordKind.sleepNight.isStructured, isTrue);
    expect(RecordKind.sleepNight.unit, isNull);
  });

  test('the same clock time twice is a slip, not 24 hours in bed; each '
      'error names its field', () async {
    final (svc, me, repo) = await fresh();
    expect(
      () => svc.recordSleep(
        zone: utc,
        profileId: me,
        wentToBed: '07:00',
        wokeUp: '07:00',
      ),
      inputError('SLEEP_TOO_LONG', 'bed'),
    );
    expect(
      () => svc.recordSleep(
        zone: utc,
        profileId: me,
        wentToBed: '2026-11-08 07:00',
        wokeUp: '2026-11-09 07:00',
      ),
      inputError('SLEEP_TOO_LONG', 'bed'),
    );
    final justUnder = await svc.recordSleep(
      zone: utc,
      profileId: me,
      wentToBed: '2026-11-08 07:01',
      wokeUp: '2026-11-09 07:00',
    );
    expect(
      (justUnder.details! as SleepNightDetails).timeInBed,
      const Duration(hours: 23, minutes: 59),
    );
    expect(
      () => svc.recordSleep(
        zone: utc,
        profileId: me,
        wentToBed: '23:00',
        wokeUp: '7 am',
      ),
      inputError('TIME_FORMAT', 'woke'),
    );
    expect(
      () => svc.recordSleep(zone: utc, profileId: me, wentToBed: '11 pm'),
      inputError('TIME_FORMAT', 'bed'),
    );
    expect(await repo.records(me, kind: RecordKind.sleepNight), hasLength(1));
  });

  test('nights across a clock change count real time in bed', () async {
    final (svc, me, _) = await fresh();
    // New York, 1 November 2026: the clock goes back an hour at 02:00.
    final autumn = await svc.recordSleep(
      zone: newYork,
      profileId: me,
      wentToBed: '23:00',
      wokeUp: '2026-11-01 07:00',
    );
    expect(
      (autumn.details! as SleepNightDetails).timeInBed,
      const Duration(hours: 9),
    );
    // 8 March 2026: the clock goes forward an hour at 02:00.
    final spring = await svc.recordSleep(
      zone: newYork,
      profileId: me,
      wentToBed: '23:00',
      wokeUp: '2026-03-08 07:00',
    );
    expect(
      (spring.details! as SleepNightDetails).timeInBed,
      const Duration(hours: 7),
    );
    expect(
      () => svc.recordSleep(
        zone: newYork,
        profileId: me,
        wentToBed: '02:30',
        wokeUp: '2026-03-08 07:00',
      ),
      inputError('TIME_DOES_NOT_EXIST', 'bed'),
    );
  });

  test('a night entered in error leaves the list; its record stays', () async {
    final (svc, me, repo) = await fresh();
    final r = await svc.recordSleep(
      zone: utc,
      profileId: me,
      wentToBed: '2026-11-08 23:00',
      wokeUp: '2026-11-09 07:00',
    );
    await svc.amend(
      profileId: me,
      targetId: r.id,
      reason: AmendReason.enteredInError,
    );
    expect(await svc.sleepNights(me), isEmpty);
    expect(await repo.records(me, kind: RecordKind.sleepNight), hasLength(2));
  });
}
