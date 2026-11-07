// U008@v0.32: a person's own readings over time: points as saved, lines
// only between readings close in time, a range to choose, every point as
// text; nothing interpolated, averaged or judged.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/trends/trend.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart'
    show launch, saveBp, saveScalar, settle, tapKey;

void main() {
  group('segments', () {
    final d = DateTime.utc(2026, 10, 1);
    List<DateTime> days(List<int> n) => [
      for (final i in n) d.add(Duration(days: i)),
    ];

    test(
      'readings within 7 days are joined; a longer gap starts a new run',
      () {
        final at = days([0, 3, 11, 30, 31]);
        final runs = segmentsOf(at);
        expect(runs, [2, 1, 2]);
      },
    );

    test('exactly 7 days is still joined', () {
      expect(segmentsOf(days([0, 7])), [2]);
      expect(segmentsOf(days([0, 8])), [1, 1]);
    });
  });

  test('a withdrawn or deleted reading leaves the chart; a correction shows '
      'only its newest version', () async {
    final repo = LogRepository(
      sink: MemoryLogSink(),
      durability: StorageDurability.localFile,
      location: 'test',
    );
    await repo.open();
    final svc = HeartbeatService(repo);
    final me = (await svc.ensureSelfProfile()).id;
    Future<HealthRecord> hr(String v) => svc.recordMeasurement(
      profileId: me,
      kind: RecordKind.restingHeartRate,
      input: MeasurementInput(value: v),
    );
    final a = await hr('61');
    final b = await hr('62');
    await hr('63');
    await svc.amend(
      profileId: me,
      targetId: a.id,
      reason: AmendReason.enteredInError,
    );
    await svc.amend(profileId: me, targetId: b.id, reason: AmendReason.deleted);
    final points = trendPoints(
      await svc.measurementTimeline(me, RecordKind.restingHeartRate),
    );
    expect([for (final p in points) p.values.single], [63]);
  });

  testWidgets('three blood pressures over time: chart, legend without '
      'colour, every reading listed, tap shows a reading, range filters', (
    tester,
  ) async {
    await launch(tester);
    final now = DateTime.now();
    String stamp(DateTime t) =>
        '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} 08:00';
    await saveBp(
      tester,
      '118',
      '76',
      when: stamp(now.subtract(const Duration(days: 200))),
    );
    await saveBp(
      tester,
      '121',
      '79',
      when: stamp(now.subtract(const Duration(days: 20))),
    );
    await saveBp(
      tester,
      '119',
      '77',
      when: stamp(now.subtract(const Duration(days: 18))),
    );
    await tapKey(tester, 'measure-tile-vital.blood_pressure');
    await tapKey(tester, 'measure-trend');
    expect(find.byKey(const ValueKey('trend-chart')), findsOneWidget);
    expect(find.textContaining('Circles: systolic'), findsOneWidget);
    expect(find.textContaining('118/76'), findsOneWidget);
    expect(find.textContaining('119/77'), findsOneWidget);
    expect(
      find.textContaining(' — '),
      findsNWidgets(3),
      reason: 'every reading listed',
    );
    await tester.tap(find.byKey(const ValueKey('trend-chart')));
    await settle(tester);
    expect(find.byKey(const ValueKey('trend-picked')), findsOneWidget);
    await tapKey(tester, 'trend-range-days30');
    expect(find.textContaining('118/76'), findsNothing);
    expect(find.textContaining('121/79'), findsOneWidget);
    expect(find.textContaining(' — '), findsNWidgets(2));
  });

  testWidgets('no readings: says so, draws nothing; weight has its own chart', (
    tester,
  ) async {
    await launch(tester);
    await saveScalar(tester, RecordKind.height, '172');
    await tapKey(tester, 'weight-trend');
    expect(find.byKey(const ValueKey('trend-none')), findsOneWidget);
    expect(find.byKey(const ValueKey('trend-chart')), findsNothing);
  });

  test('trend words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.trendNone,
        s.trendLegend,
        s.trendLegendBp,
        s.trendAllPoints,
        s.seeOverTime,
        s.trendChartSpoken(3),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}

/// Run lengths of [segments] for readings at [at].
List<int> segmentsOf(List<DateTime> at) {
  final pts = [for (final t in at) _P(t)];
  return [for (final s in segments(pts)) s.length];
}

class _P implements TrendPoint {
  _P(this.at);
  @override
  final DateTime at;
  @override
  List<double> get values => const [1];
  @override
  HealthRecord get record => throw UnimplementedError();
}
