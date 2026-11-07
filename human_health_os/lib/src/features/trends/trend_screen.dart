import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../domain/records/health_record.dart';
import '../../domain/trends/trend.dart';
import '../../l10n/strings.dart';
import '../measurements/measurement_format.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

enum TrendRange { days30, days90, year, all }

/// One measurement over time (U008): the saved points, joined only when
/// they are close in time, a range to choose, and every point as text.
/// No target band, no colour that judges, no smoothing.
class TrendScreen extends StatefulWidget {
  const TrendScreen({super.key, required this.services, required this.kind});

  final AppServices services;
  final RecordKind kind;

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  List<TrendPoint> _all = const [];
  bool _loaded = false;
  TrendRange _range = TrendRange.all;
  TrendPoint? _picked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = widget.services.heartbeat;
    final me = widget.services.self.id;
    final points = widget.kind == RecordKind.bodyWeight
        ? trendPointsFromRecords(await svc.currentWeights(me))
        : trendPoints(await svc.measurementTimeline(me, widget.kind));
    if (mounted) {
      setState(() {
        _all = points;
        _loaded = true;
      });
    }
  }

  DateTime? _from() {
    final now = DateTime.now().toUtc();
    return switch (_range) {
      TrendRange.days30 => now.subtract(const Duration(days: 30)),
      TrendRange.days90 => now.subtract(const Duration(days: 90)),
      TrendRange.year => now.subtract(const Duration(days: 365)),
      TrendRange.all => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final points = inRange(_all, _from());
    final picked = _picked;
    return Scaffold(
      appBar: AppBar(title: Text(s.trendTitle(s.recordKind(widget.kind)))),
      body: ListView(
        key: const ValueKey('screen-trend'),
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in TrendRange.values)
                ChoiceChip(
                  key: ValueKey('trend-range-${r.name}'),
                  label: Text(s.trendRange(r.name)),
                  selected: _range == r,
                  onSelected: (_) => setState(() {
                    _range = r;
                    _picked = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_loaded)
            const SizedBox.shrink()
          else if (points.isEmpty)
            Text(s.trendNone, key: const ValueKey('trend-none'))
          else ...[
            Semantics(
              label: s.trendChartSpoken(points.length),
              child: SizedBox(
                height: 220,
                child: LayoutBuilder(
                  builder: (context, box) => GestureDetector(
                    key: const ValueKey('trend-chart'),
                    onTapDown: (d) => setState(
                      () => _picked = _nearest(
                        points,
                        d.localPosition,
                        box.biggest,
                      ),
                    ),
                    child: CustomPaint(
                      size: box.biggest,
                      painter: _TrendPainter(
                        points: points,
                        line: scheme.primary,
                        second: scheme.onSurface,
                        grid: scheme.outlineVariant,
                        label: scheme.outline,
                        picked: picked,
                        textStyle: text.labelSmall ?? const TextStyle(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.kind == RecordKind.bloodPressure
                  ? s.trendLegendBp
                  : s.trendLegend,
              style: text.bodySmall?.copyWith(color: scheme.outline),
            ),
            if (picked != null) ...[
              const SizedBox(height: 8),
              Text(
                '${measurementValue(s, picked.record)} · ${fmtWhen(picked.at)}',
                key: const ValueKey('trend-picked'),
                style: text.titleSmall,
              ),
            ],
            const SizedBox(height: 16),
            Text(s.trendAllPoints, style: text.titleSmall),
            for (final p in points.reversed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${fmtWhen(p.at)} — ${measurementValue(s, p.record)}',
                  style: text.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  TrendPoint? _nearest(List<TrendPoint> points, Offset at, Size size) {
    final xs = _xs(points, size);
    var best = 0;
    for (var i = 1; i < points.length; i++) {
      if ((xs[i] - at.dx).abs() < (xs[best] - at.dx).abs()) best = i;
    }
    return points[best];
  }
}

const double _left = 44, _right = 12, _top = 8, _bottom = 20;

List<double> _xs(List<TrendPoint> points, Size size) {
  final t0 = points.first.at.millisecondsSinceEpoch.toDouble();
  final t1 = points.last.at.millisecondsSinceEpoch.toDouble();
  final w = size.width - _left - _right;
  return [
    for (final p in points)
      t1 == t0
          ? _left + w / 2
          : _left + (p.at.millisecondsSinceEpoch - t0) / (t1 - t0) * w,
  ];
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.line,
    required this.second,
    required this.grid,
    required this.label,
    required this.picked,
    required this.textStyle,
  });

  final List<TrendPoint> points;
  final Color line, second, grid, label;
  final TrendPoint? picked;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [for (final p in points) ...p.values];
    var lo = all.reduce((a, b) => a < b ? a : b);
    var hi = all.reduce((a, b) => a > b ? a : b);
    if (hi == lo) {
      hi += 1;
      lo -= 1;
    }
    final pad = (hi - lo) * 0.1;
    lo -= pad;
    hi += pad;
    final h = size.height - _top - _bottom;
    double y(double v) => _top + (hi - v) / (hi - lo) * h;
    final xs = _xs(points, size);

    // Three plain value lines for reading, not bands.
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final v in [lo + pad, (lo + hi) / 2, hi - pad]) {
      canvas.drawLine(
        Offset(_left, y(v)),
        Offset(size.width - _right, y(v)),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(v.abs() >= 100 ? 0 : 1),
          style: textStyle.copyWith(color: label),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _left - 4);
      tp.paint(canvas, Offset(0, y(v) - tp.height / 2));
    }

    final series = points.first.values.length;
    final index = {for (var i = 0; i < points.length; i++) points[i]: i};
    for (var sIdx = 0; sIdx < series; sIdx++) {
      final color = sIdx == 0 ? line : second;
      final stroke = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      for (final seg in segments(points)) {
        final path = Path();
        for (var i = 0; i < seg.length; i++) {
          final o = Offset(xs[index[seg[i]]!], y(seg[i].values[sIdx]));
          i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
        }
        canvas.drawPath(path, stroke);
      }
      final dot = Paint()..color = color;
      for (var i = 0; i < points.length; i++) {
        final o = Offset(xs[i], y(points[i].values[sIdx]));
        // The second series uses squares, so the two differ without colour.
        if (sIdx == 0) {
          canvas.drawCircle(o, points[i] == picked ? 6 : 4, dot);
        } else {
          final r = points[i] == picked ? 6.0 : 4.0;
          canvas.drawRect(
            Rect.fromCenter(center: o, width: r * 2, height: r * 2),
            dot,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.points != points || old.picked != picked || old.line != line;
}
