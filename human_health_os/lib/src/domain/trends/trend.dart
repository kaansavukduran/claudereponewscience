/// The person's own values over time, as points (U008). Pure arithmetic on
/// what was saved: nothing is interpolated, averaged, smoothed or judged.
library;

import '../records/health_record.dart';

/// One saved reading: its time and its value(s) (blood pressure has two).
class TrendPoint {
  const TrendPoint({
    required this.at,
    required this.values,
    required this.record,
  });

  final DateTime at;
  final List<double> values;
  final HealthRecord record;
}

/// Two readings further apart than this are not joined by a line: the
/// chart shows a gap, because nothing is known in between.
const Duration trendGap = Duration(days: 7);

/// The current version of every live entry with a value, oldest first.
/// Withdrawn, deleted and "not recorded" entries are left out (missing is
/// not zero).
List<TrendPoint> trendPoints(List<TimelineEntry> entries) {
  final out = <TrendPoint>[];
  for (final e in entries) {
    if (!e.isLive) continue;
    final r = e.shown;
    if (r.valueStatus != ValueStatus.present) continue;
    final d = r.details;
    if (d is BloodPressureDetails) {
      out.add(
        TrendPoint(
          at: r.observedAt,
          values: [d.systolic, d.diastolic],
          record: r,
        ),
      );
      continue;
    }
    final q = r.quantity;
    if (q == null) continue;
    out.add(TrendPoint(at: r.observedAt, values: [q.value], record: r));
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out;
}

/// The same for records that are already current (weight).
List<TrendPoint> trendPointsFromRecords(List<HealthRecord> records) {
  final out = <TrendPoint>[
    for (final r in records)
      if (r.valueStatus == ValueStatus.present && r.quantity != null)
        TrendPoint(at: r.observedAt, values: [r.quantity!.value], record: r),
  ];
  out.sort((a, b) => a.at.compareTo(b.at));
  return out;
}

/// Points at or after [from] (null keeps all).
List<TrendPoint> inRange(List<TrendPoint> points, DateTime? from) => [
  for (final p in points)
    if (from == null || !p.at.isBefore(from)) p,
];

/// Runs of points joined by lines; a new run starts after a gap longer than
/// [gap].
List<List<TrendPoint>> segments(
  List<TrendPoint> points, {
  Duration gap = trendGap,
}) {
  final out = <List<TrendPoint>>[];
  for (final p in points) {
    if (out.isEmpty || p.at.difference(out.last.last.at) > gap) {
      out.add([p]);
    } else {
      out.last.add(p);
    }
  }
  return out;
}

/// The value range a chart shows for [values]: at least [minSpan] wide
/// (centred on the data), then 10% padding above and below. A tiny change
/// therefore never fills the whole height.
({double lo, double hi, double pad}) axisRange(
  List<double> values,
  double minSpan,
) {
  var lo = values.reduce((a, b) => a < b ? a : b);
  var hi = values.reduce((a, b) => a > b ? a : b);
  if (hi - lo < minSpan) {
    final mid = (hi + lo) / 2;
    hi = mid + minSpan / 2;
    lo = mid - minSpan / 2;
  }
  final pad = (hi - lo) * 0.1;
  return (lo: lo - pad, hi: hi + pad, pad: pad);
}

/// The three reading lines a chart labels: just inside the bottom, the
/// middle and just inside the top of [axisRange].
List<double> readingLines(({double lo, double hi, double pad}) r) => [
  r.lo + r.pad,
  (r.lo + r.hi) / 2,
  r.hi - r.pad,
];

/// A reading-line label with the person's decimal separator.
String axisLabel(double v, String decimal) =>
    v.toStringAsFixed(v.abs() >= 100 ? 0 : 1).replaceAll('.', decimal);

/// Horizontal positions of [points] between [left] and [right], by time;
/// a single point sits in the middle.
List<double> timePositions(List<TrendPoint> points, double left, double right) {
  final t0 = points.first.at.millisecondsSinceEpoch.toDouble();
  final t1 = points.last.at.millisecondsSinceEpoch.toDouble();
  final w = right - left;
  return [
    for (final p in points)
      t1 == t0
          ? left + w / 2
          : left + (p.at.millisecondsSinceEpoch - t0) / (t1 - t0) * w,
  ];
}

/// The earliest time a range shows, counted back from [now]; null shows all.
DateTime? rangeStart(int? days, DateTime now) =>
    days == null ? null : now.subtract(Duration(days: days));
