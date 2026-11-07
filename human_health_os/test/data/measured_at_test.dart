// F007 slice 2: the time a person says a measurement was taken. Pure rules,
// tested against zones described by their clock changes, so the result does
// not depend on the host's own zone.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/input_error.dart';
import 'package:human_health_os/src/application/measured_at.dart';

/// America/New_York in 2026: EST (-5) until 2026-03-08 07:00 UTC, EDT (-4)
/// until 2026-11-01 06:00 UTC, EST after.
final newYork = OffsetRuleZone((utc) {
  final spring = DateTime.utc(2026, 3, 8, 7);
  final autumn = DateTime.utc(2026, 11, 1, 6);
  return !utc.isBefore(spring) && utc.isBefore(autumn)
      ? const Duration(hours: -4)
      : const Duration(hours: -5);
});

/// Australia/Lord_Howe: +10:30, and +11:00 in summer; the clock moves by 30
/// minutes. 2026: DST ends 2026-04-05 02:00 local (+11 -> +10:30) and starts
/// 2026-10-04 02:00 local (+10:30 -> +11).
final lordHowe = OffsetRuleZone((utc) {
  final ends = DateTime.utc(2026, 4, 4, 15); // 02:00 +11:00
  final starts = DateTime.utc(2026, 10, 3, 15, 30); // 02:00 +10:30
  return utc.isBefore(ends) || !utc.isBefore(starts)
      ? const Duration(hours: 11)
      : const Duration(hours: 10, minutes: 30);
});

const utcZone = OffsetRuleZone(_zero);
Duration _zero(DateTime _) => Duration.zero;

Matcher timeError(String code) => throwsA(
  isA<InputError>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.field, 'field', 'when'),
);

DateTime? parse(String raw, {LocalZone zone = utcZone, DateTime? now}) =>
    parseMeasuredAt(
      raw,
      nowUtc: now ?? DateTime.utc(2026, 11, 7, 20),
      zone: zone,
    );

void main() {
  group('grammar', () {
    test('blank means the save time', () {
      expect(parse(''), isNull);
      expect(parse('   '), isNull);
    });

    test('a full local time and a time of today are read in the zone', () {
      expect(parse('2026-11-07 07:30'), DateTime.utc(2026, 11, 7, 7, 30));
      expect(parse('07:30'), DateTime.utc(2026, 11, 7, 7, 30));
      expect(
        parse('2026-11-07 07:30', zone: newYork),
        DateTime.utc(2026, 11, 7, 12, 30),
        reason: 'EST is UTC-5',
      );
      expect(
        parse('2026-07-01 07:30', zone: newYork),
        DateTime.utc(2026, 7, 1, 11, 30),
        reason: 'EDT is UTC-4',
      );
    });

    test('an explicit offset fixes the instant, seconds are always 0', () {
      expect(
        parse('2026-11-07 07:30 +03:00'),
        DateTime.utc(2026, 11, 7, 4, 30),
      );
      expect(parse('2026-11-07 07:30Z'), DateTime.utc(2026, 11, 7, 7, 30));
      expect(
        parse('2026-11-07 07:30 -05:00'),
        DateTime.utc(2026, 11, 7, 12, 30),
      );
      expect(
        parse('2026-11-07 07:30 +05:45'),
        DateTime.utc(2026, 11, 7, 1, 45),
      );
      expect(parse('2026-11-07 07:30')!.second, 0);
    });

    test('everything else is a format error, never guessed', () {
      for (final bad in [
        'yesterday',
        '7:30',
        '07:30:15',
        '24:00',
        '12:60',
        '2026-02-30 10:00',
        '2026-13-01 10:00',
        '2026-11-07',
        '2026-11-07T07:30',
        '07:30 +03:00', // an offset needs a date
        '2026-11-07 07:30 +3:00',
        '2026-11-07 07:30 +0300',
        '2026-11-07 07:30 z',
        '2026-11-07 07:30 +15:00',
        '2026-11-07 07:30 +14:30',
        '2026-11-07 07:30 +05:10',
        '٢٠٢٦-١١-٠٧ ٠٧:٣٠',
      ]) {
        expect(() => parse(bad), timeError('TIME_FORMAT'), reason: bad);
      }
    });

    test('before 1900 is too old', () {
      expect(() => parse('1899-12-31 23:59'), timeError('TIME_TOO_OLD'));
      expect(parse('1900-01-01 00:00'), DateTime.utc(1900));
    });
  });

  group('the future (one rule, shared with body weight)', () {
    final now = DateTime.utc(2026, 11, 7, 12);
    test('exactly 5 minutes ahead passes, one second more does not', () {
      expect(isFutureTime(now.add(const Duration(minutes: 5)), now), isFalse);
      expect(
        isFutureTime(now.add(const Duration(minutes: 5, seconds: 1)), now),
        isTrue,
      );
      expect(
        parse('2026-11-07 12:05', now: now),
        DateTime.utc(2026, 11, 7, 12, 5),
      );
      expect(
        () => parse('2026-11-07 12:06', now: now),
        timeError('FUTURE_TIME'),
      );
    });

    test('the tolerance applies after the offset is applied', () {
      // 14:04 at +02:00 is 12:04 UTC: 4 minutes ahead, fine.
      expect(
        parse('2026-11-07 14:04 +02:00', now: now),
        DateTime.utc(2026, 11, 7, 12, 4),
      );
      expect(
        () => parse('2026-11-07 14:06 +02:00', now: now),
        timeError('FUTURE_TIME'),
      );
    });

    test('a time later today stays in the future: no silent roll-back', () {
      expect(
        () => parse('23:50', now: DateTime.utc(2026, 11, 7, 0, 2)),
        timeError('FUTURE_TIME'),
      );
    });

    test('"today" is the local date of the clock it is given', () {
      // 03:00 UTC on 8 Nov is still 7 Nov in New York (EST).
      final late = DateTime.utc(2026, 11, 8, 3);
      expect(
        parse('21:00', zone: newYork, now: late),
        DateTime.utc(2026, 11, 8, 2),
      );
    });
  });

  group('clock changes (America/New_York)', () {
    test('a time the clock skipped does not exist', () {
      // 2026-03-08 02:30 never happened: 02:00 EST became 03:00 EDT.
      expect(
        () => parse('2026-03-08 02:30', zone: newYork),
        timeError('TIME_DOES_NOT_EXIST'),
      );
      expect(
        parse('2026-03-08 03:30', zone: newYork),
        DateTime.utc(2026, 3, 8, 7, 30),
      );
      expect(
        parse('2026-03-08 01:59', zone: newYork),
        DateTime.utc(2026, 3, 8, 6, 59),
      );
    });

    test('a repeated hour is ambiguous, and an offset resolves it', () {
      // 2026-11-01 01:30 happened twice (EDT, then EST).
      expect(
        () => parse('2026-11-01 01:30', zone: newYork),
        timeError('TIME_AMBIGUOUS'),
      );
      expect(
        parse('2026-11-01 01:30 -04:00', zone: newYork),
        DateTime.utc(2026, 11, 1, 5, 30),
      );
      expect(
        parse('2026-11-01 01:30 -05:00', zone: newYork),
        DateTime.utc(2026, 11, 1, 6, 30),
      );
      expect(
        parse('2026-11-01 00:59', zone: newYork),
        DateTime.utc(2026, 11, 1, 4, 59),
      );
      expect(
        parse('2026-11-01 02:00', zone: newYork),
        DateTime.utc(2026, 11, 1, 7),
      );
    });
  });

  group('a 30-minute clock change (Australia/Lord_Howe)', () {
    test('the skipped half hour does not exist, the repeated one is '
        'ambiguous', () {
      // Starts 2026-10-04 02:00 +10:30 -> 02:30 +11:00: 02:00-02:29 skipped.
      expect(
        () => parse('2026-10-04 02:10', zone: lordHowe),
        timeError('TIME_DOES_NOT_EXIST'),
      );
      expect(
        parse('2026-10-04 02:30', zone: lordHowe),
        DateTime.utc(2026, 10, 3, 15, 30),
      );
      // Ends 2026-04-05 02:00 +11:00 -> 01:30 +10:30: 01:30-01:59 twice.
      expect(
        () => parse('2026-04-05 01:45', zone: lordHowe),
        timeError('TIME_AMBIGUOUS'),
      );
      expect(
        parse('2026-04-05 01:45 +11:00', zone: lordHowe),
        DateTime.utc(2026, 4, 4, 14, 45),
      );
      expect(
        parse('2026-04-05 01:45 +10:30', zone: lordHowe),
        DateTime.utc(2026, 4, 4, 15, 15),
      );
    });
  });

  group('the host zone', () {
    test('a time typed today round-trips through the device zone', () {
      // Whatever zone this run uses, a normal time reads back as typed.
      final now = DateTime.now().toUtc();
      final typed = parse(
        '2026-06-15 12:00',
        zone: const SystemLocalZone(),
        now: now,
      );
      expect(typed, isNotNull);
      final l = typed!.toLocal();
      expect((l.year, l.month, l.day, l.hour, l.minute), (2026, 6, 15, 12, 0));
    });

    test('under America/New_York the device zone refuses the gap and the '
        'repeat', () {
      final zone = const SystemLocalZone();
      final probe = DateTime(2026, 3, 8, 2, 30);
      final inNewYork = probe.hour != 2; // normalised out of the gap
      if (!inNewYork) {
        markTestSkipped('host zone has no clock change on 2026-03-08');
        return;
      }
      expect(
        () => parse('2026-03-08 02:30', zone: zone),
        timeError('TIME_DOES_NOT_EXIST'),
      );
      expect(
        () => parse('2026-11-01 01:30', zone: zone),
        timeError('TIME_AMBIGUOUS'),
      );
    });
  });
}
