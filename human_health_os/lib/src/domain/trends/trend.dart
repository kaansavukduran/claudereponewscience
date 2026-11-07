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
