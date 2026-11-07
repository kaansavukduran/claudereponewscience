/// The time a person says a measurement was taken (ladder F007, slice 2).
///
/// Pure Dart. The text is parsed once, at Save, into one UTC instant. Local
/// wall-clock times are checked against the device's clock changes: a time
/// that does not exist (the hour skipped when the clock moves forward) and a
/// time that happens twice (the hour repeated when it moves back) are
/// refused, never guessed; an offset typed after the time resolves both.
/// These are entry rules only: stored records are never re-judged by them.
library;

import 'input_error.dart';

/// The device's local time zone, behind an interface so the clock-change
/// rules can be tested for any zone (Dart's own local zone is process-wide).
abstract interface class LocalZone {
  /// The local wall-clock fields of [utc].
  DateTime toLocal(DateTime utc);

  /// Every UTC instant whose local wall clock reads exactly the given
  /// fields: none (a skipped time), one, or two (a repeated time).
  List<DateTime> instantsFor(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  );
}

/// Every UTC instant (minute resolution) whose wall clock, by [toLocal],
/// reads the given fields. Clock changes move by a few hours at most, so
/// the neighbourhood of the first guess is scanned in quarter-hour steps
/// (half-hour and 45-minute zones included).
List<DateTime> _instantsFor(
  DateTime Function(DateTime utc) toLocal,
  DateTime guessUtc,
  int y,
  int mo,
  int d,
  int h,
  int mi,
) {
  final found = <DateTime>{};
  for (var m = -180; m <= 180; m += 15) {
    final t = guessUtc.add(Duration(minutes: m));
    final l = toLocal(t);
    if (l.year == y &&
        l.month == mo &&
        l.day == d &&
        l.hour == h &&
        l.minute == mi) {
      found.add(DateTime.utc(t.year, t.month, t.day, t.hour, t.minute));
    }
  }
  return found.toList()..sort();
}

/// The zone of the device.
class SystemLocalZone implements LocalZone {
  const SystemLocalZone();

  @override
  DateTime toLocal(DateTime utc) => utc.toLocal();

  @override
  List<DateTime> instantsFor(int y, int mo, int d, int h, int mi) =>
      _instantsFor(
        (u) => u.toLocal(),
        DateTime(y, mo, d, h, mi).toUtc(),
        y,
        mo,
        d,
        h,
        mi,
      );
}

/// A zone described by its UTC offset at each instant: the clock-change
/// rules of any region, for tests that must not depend on the host's zone.
class OffsetRuleZone implements LocalZone {
  const OffsetRuleZone(this.offsetAt);

  /// The UTC offset in force at [utc].
  final Duration Function(DateTime utc) offsetAt;

  @override
  DateTime toLocal(DateTime utc) => utc.add(offsetAt(utc));

  @override
  List<DateTime> instantsFor(int y, int mo, int d, int h, int mi) {
    final wall = DateTime.utc(y, mo, d, h, mi);
    return _instantsFor(
      toLocal,
      wall.subtract(offsetAt(wall)),
      y,
      mo,
      d,
      h,
      mi,
    );
  }
}

/// How far ahead of the clock a time may be (a clock that runs a little
/// fast): the same rule as for body weight.
const Duration futureTolerance = Duration(minutes: 5);

/// True when [when] is more than [futureTolerance] after [now].
bool isFutureTime(DateTime when, DateTime now) =>
    when.isAfter(now.add(futureTolerance));

final _grammar = RegExp(
  r'^(?:(\d{4})-(\d{2})-(\d{2}) )?(\d{2}):(\d{2})(?: ?(Z|[+-]\d{2}:\d{2}))?$',
);

/// The earliest time accepted (a typing slip such as year 0202 is a format
/// problem of the person, not a measurement).
final DateTime earliestMeasuredAt = DateTime.utc(1900);

InputError _error(String code) => InputError(code, 'when');

/// Parses [raw] as typed in the "When" field into a UTC instant with
/// seconds 0, or returns null for a blank field (the save time is used).
///
/// Accepted: `YYYY-MM-DD HH:MM` or `HH:MM` (today, by [zone] and [nowUtc]),
/// both in local time, or with an explicit offset (`Z`, `+03:00`) after a
/// full date and time. Throws [InputError] with the field `when`:
/// `TIME_FORMAT`, `TIME_TOO_OLD`, `FUTURE_TIME`, `TIME_DOES_NOT_EXIST`,
/// `TIME_AMBIGUOUS`.
DateTime? parseMeasuredAt(
  String raw, {
  required DateTime nowUtc,
  LocalZone zone = const SystemLocalZone(),
}) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final m = _grammar.firstMatch(text);
  if (m == null) throw _error('TIME_FORMAT');
  final hour = int.parse(m[4]!);
  final minute = int.parse(m[5]!);
  if (hour > 23 || minute > 59) throw _error('TIME_FORMAT');
  final offset = m[6];
  final hasDate = m[1] != null;
  if (offset != null && !hasDate) throw _error('TIME_FORMAT');
  final int year;
  final int month;
  final int day;
  if (hasDate) {
    year = int.parse(m[1]!);
    month = int.parse(m[2]!);
    day = int.parse(m[3]!);
    final check = DateTime.utc(year, month, day);
    if (check.year != year || check.month != month || check.day != day) {
      throw _error('TIME_FORMAT');
    }
  } else {
    final today = zone.toLocal(nowUtc);
    year = today.year;
    month = today.month;
    day = today.day;
  }
  final DateTime instant;
  if (offset != null) {
    final minutes = _offsetMinutes(offset);
    instant = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
    ).subtract(Duration(minutes: minutes));
  } else {
    final candidates = zone.instantsFor(year, month, day, hour, minute);
    if (candidates.isEmpty) throw _error('TIME_DOES_NOT_EXIST');
    if (candidates.length > 1) throw _error('TIME_AMBIGUOUS');
    instant = candidates.single;
  }
  if (instant.isBefore(earliestMeasuredAt)) throw _error('TIME_TOO_OLD');
  if (isFutureTime(instant, nowUtc)) throw _error('FUTURE_TIME');
  return instant;
}

int _offsetMinutes(String offset) {
  if (offset == 'Z') return 0;
  final sign = offset.startsWith('-') ? -1 : 1;
  final h = int.parse(offset.substring(1, 3));
  final mi = int.parse(offset.substring(4, 6));
  if (h > 14 ||
      (h == 14 && mi != 0) ||
      (mi != 0 && mi != 15 && mi != 30 && mi != 45)) {
    throw _error('TIME_FORMAT');
  }
  return sign * (h * 60 + mi);
}
