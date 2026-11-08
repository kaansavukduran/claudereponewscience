// T002@v0.32: the trend chart's rules as pure functions (G-63).
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/trends/trend.dart';
import 'package:human_health_os/src/features/trends/trend_screen.dart';

class _P implements TrendPoint {
  _P(this.at);
  @override
  final DateTime at;
  @override
  List<double> get values => const [1];
  @override
  HealthRecord get record => throw UnimplementedError();
}

void main() {
  test('a small change is shown on at least the minimum span, centred', () {
    final r = axisRange([70.1, 70.2, 70.3], 5);
    expect(r.hi - r.lo, closeTo(5 * 1.2, 1e-9), reason: '5 plus 10% each side');
    expect((r.hi + r.lo) / 2, closeTo(70.2, 1e-9));
  });

  test('a wide spread keeps its own range plus padding', () {
    final r = axisRange([100, 140], 20);
    expect(r.lo, closeTo(96, 1e-9));
    expect(r.hi, closeTo(144, 1e-9));
    expect(readingLines(r), [
      closeTo(100, 1e-9),
      closeTo(120, 1e-9),
      closeTo(140, 1e-9),
    ]);
  });

  test('labels: one decimal below 100, none from 100, local separator', () {
    expect(axisLabel(36.55, '.'), '36.5');
    expect(axisLabel(36.65, ','), '36,6');
    expect(axisLabel(118.4, ','), '118');
  });

  test('positions follow time; one point sits in the middle', () {
    final d = DateTime.utc(2026, 1, 1);
    final xs = timePositions(
      [
        _P(d),
        _P(d.add(const Duration(days: 1))),
        _P(d.add(const Duration(days: 4))),
      ],
      0,
      400,
    );
    expect(xs, [0, 100, 400]);
    expect(timePositions([_P(d)], 0, 400), [200]);
  });

  test('range chips: 30, 90 and 365 days back; points at the start count', () {
    final now = DateTime.utc(2026, 11, 8, 12);
    expect(rangeDays(TrendRange.days30), 30);
    expect(rangeDays(TrendRange.days90), 90);
    expect(rangeDays(TrendRange.year), 365);
    expect(rangeDays(TrendRange.all), isNull);
    final from = rangeStart(30, now)!;
    final pts = [
      _P(now.subtract(const Duration(days: 31))),
      _P(from),
      _P(now.subtract(const Duration(days: 29))),
    ];
    expect(inRange(pts, from).length, 2, reason: 'exactly at the start is in');
    expect(inRange(pts, null).length, 3);
    expect(
      inRange([
        _P(now.subtract(const Duration(days: 89))),
        _P(now.subtract(const Duration(days: 91))),
      ], rangeStart(90, now)).length,
      1,
    );
  });
}
