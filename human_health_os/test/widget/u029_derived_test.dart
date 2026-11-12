// U029@v0.32 (D-039): "Worked out from your records", opened from Today's
// tools. A BMI from recorded weight and height, with "worked out, not
// measured", its model ID and the records used; "needs: height" (never a
// number) when no height is recorded; nothing judged, in EN and TR; laid
// out at 320 dp with 2x text.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/app_services.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart'
    show launch, measurementJudged, settle, tapKey;
import 'u002_guide_test.dart' show reveal;

Future<void> record(
  WidgetTester tester,
  AppServices services, {
  String? kg,
  String? heightCm,
  String? waistCm,
}) async {
  await tester.runAsync(() async {
    final me = services.self.id;
    if (kg != null) {
      await services.heartbeat.recordWeightKg(profileId: me, input: kg);
    }
    if (waistCm != null) {
      await services.heartbeat.recordMeasurement(
        profileId: me,
        kind: RecordKind.waistCircumference,
        input: MeasurementInput(value: waistCm),
      );
    }
    if (heightCm != null) {
      await services.heartbeat.recordMeasurement(
        profileId: me,
        kind: RecordKind.height,
        input: MeasurementInput(value: heightCm),
      );
    }
  });
}

Future<void> openDerived(WidgetTester tester) async {
  await reveal(tester, 'screen-today', 'tool-derived');
  await tapKey(tester, 'tool-derived');
  expect(find.byKey(const ValueKey('screen-derived')), findsOneWidget);
}

/// Every text on the page except the engine's own limitation lines, which
/// name the categories they refuse ("no diagnostic category", "no good/bad
/// threshold") and are checked separately.
List<String> pageTexts(WidgetTester tester) => [
  for (final w in tester.widgetList<Text>(
    find.descendant(
      of: find.byKey(const ValueKey('screen-derived')),
      matching: find.byType(Text),
    ),
  ))
    if (!((w.key as ValueKey<String>?)?.value.contains('-limitation-') ??
        false))
      w.data ?? '',
];

const bmiKey = 'derived-DERIVED-BMI-1';

void main() {
  testWidgets('weight and height recorded: BMI worked out, not measured, '
      'with model ID and the records used', (tester) async {
    final services = await launch(tester);
    await record(tester, services, kg: '80', heightCm: '180');
    await openDerived(tester);
    final value = tester.widget<Text>(
      find.byKey(const ValueKey('$bmiKey-value')),
    );
    expect(value.data, '24.7 kg/m²');
    expect(find.byKey(const ValueKey('$bmiKey-worked-out')), findsOneWidget);
    expect(find.text('worked out, not measured'), findsWidgets);
    expect(find.text('Model: DERIVED-BMI-1, version 1'), findsOneWidget);
    expect(
      find.byKey(ValueKey('$bmiKey-used-${RecordKind.bodyWeight.code}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('$bmiKey-used-${RecordKind.height.code}')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('$bmiKey-limitation-0')), findsOneWidget);
    // Waist is not recorded: named, never a number.
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const ValueKey('derived-DERIVED-WAIST_HEIGHT_RATIO-1-needs'),
            ),
          )
          .data,
      'needs: waist circumference',
    );
    for (final t in pageTexts(tester)) {
      expect(interpretive.hasMatch(t), isFalse, reason: t);
      expect(judged.hasMatch(t), isFalse, reason: t);
      expect(measurementJudged.hasMatch(t), isFalse, reason: t);
    }
    await settle(tester);
  });

  testWidgets('no height recorded: "needs: height", no number, no zero', (
    tester,
  ) async {
    final services = await launch(tester);
    await record(tester, services, kg: '80');
    await openDerived(tester);
    expect(find.byKey(const ValueKey('$bmiKey-value')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('$bmiKey-needs'))).data,
      'needs: height',
    );
    // The weight that is there is still shown as a record, with its date.
    expect(
      find.byKey(ValueKey('$bmiKey-used-${RecordKind.bodyWeight.code}')),
      findsOneWidget,
    );
    expect(find.textContaining('kg/m²'), findsNothing);
    for (final t in pageTexts(tester)) {
      expect(RegExp(r'(?<![\d.])0(?![\d.])').hasMatch(t), isFalse, reason: t);
    }
    await settle(tester);
  });

  testWidgets('Turkish: natural wording, nothing judged; 320 dp and 2x text '
      'without overflow', (tester) async {
    final services = await launch(
      tester,
      locale: const Locale('tr'),
      size: const Size(320, 1400),
      textScale: 2.0,
    );
    await record(tester, services, kg: '72,5', heightCm: '170');
    await openDerived(tester);
    expect(find.text('hesaplandı, ölçülmedi'), findsWidgets);
    final early = pageTexts(tester);
    await reveal(
      tester,
      'screen-derived',
      'derived-DERIVED-WAIST_HEIGHT_RATIO-1-needs',
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const ValueKey('derived-DERIVED-WAIST_HEIGHT_RATIO-1-needs'),
            ),
          )
          .data,
      'eksik: bel çevresi',
    );
    for (final t in [...early, ...pageTexts(tester)]) {
      expect(interpretive.hasMatch(t), isFalse, reason: t);
      expect(judged.hasMatch(t), isFalse, reason: t);
    }
    // Scroll through the whole page: a layout overflow fails the test.
    await tester.drag(
      find.byKey(const ValueKey('screen-derived')),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await settle(tester);
  });

  test('the words judge nothing, in EN and TR', () {
    for (final s in const [S(AppLang.en), S(AppLang.tr)]) {
      final words = [
        s.derivedTitle,
        s.derivedTileHint,
        s.derivedIntro,
        s.derivedNotMeasured,
        s.derivedModelName('DERIVED-BMI-1'),
        s.derivedModelName('DERIVED-WAIST_HEIGHT_RATIO-1'),
        s.derivedUnit('kg/m2'),
        s.derivedUnit('1'),
        s.derivedModel('DERIVED-BMI-1', '1'),
        s.derivedPack('MP-CORE-DERIVED-1', '1.0.0'),
        s.derivedUsedTitle,
        s.derivedLimitsTitle,
        s.derivedNoLimitations,
        s.derivedNeeds([s.recordKind(RecordKind.height)]),
        s.derivedUnresolved([s.recordKind(RecordKind.height)]),
        s.derivedRefused('NON_POSITIVE_INPUT'),
        s.derivedDaysApart(1),
        s.derivedDaysApart(142),
        s.derivedSpoken('BMI', '24.7', 'kg/m²'),
      ];
      for (final t in words) {
        expect(interpretive.hasMatch(t), isFalse, reason: t);
        expect(judged.hasMatch(t), isFalse, reason: t);
        expect(measurementJudged.hasMatch(t), isFalse, reason: t);
      }
    }
  });

  testWidgets('R013: waist 90 and height 180 give a ratio of 0.50 with two '
      'decimals, read aloud as worked out', (tester) async {
    final services = await launch(tester);
    await record(tester, services, heightCm: '180', waistCm: '90');
    await openDerived(tester);
    const key = 'derived-DERIVED-WAIST_HEIGHT_RATIO-1';
    final value = tester.widget<Text>(find.byKey(const ValueKey('$key-value')));
    expect(value.data, startsWith('0.50'));
    expect(
      find.bySemanticsLabel(RegExp('Waist-to-height ratio: 0.50.*worked out')),
      findsOneWidget,
    );
  });
}
