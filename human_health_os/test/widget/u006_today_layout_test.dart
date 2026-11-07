// U006@v0.32: the person arranges Today with the mouse: which measurement
// tiles show, in what order, which sections show, whether the number pad
// starts open; Reset brings the default back. No stored value changes.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';

import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

const defaults = ['a', 'b', 'c', 'd'];

List<String> tileOrderOnToday(WidgetTester tester) {
  final codes = [
    for (final k in [
      RecordKind.bloodPressure,
      RecordKind.restingHeartRate,
      RecordKind.bodyTemperature,
      RecordKind.oxygenSaturation,
      RecordKind.respiratoryRate,
      RecordKind.waistCircumference,
      RecordKind.height,
    ])
      k.code,
  ];
  final shown = [
    for (final c in codes)
      if (find.byKey(ValueKey('measure-tile-$c')).evaluate().isNotEmpty) c,
  ];
  Offset at(String c) =>
      tester.getTopLeft(find.byKey(ValueKey('measure-tile-$c')));
  shown.sort((a, b) {
    final dy = at(a).dy.compareTo(at(b).dy);
    return dy != 0 ? dy : at(a).dx.compareTo(at(b).dx);
  });
  return shown;
}

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Back').first);
  await settle(tester);
}

void main() {
  group('order and visibility rules', () {
    test('unlisted codes follow in the default order; unknown ones are '
        'ignored', () {
      const s = AppearanceSettings(tileOrder: ['c', 'zzz', 'a']);
      expect(s.ordered(defaults), ['c', 'a', 'b', 'd']);
      expect(s.copyWith(hiddenTiles: {'a'}).visible(defaults), ['c', 'b', 'd']);
    });

    test('move stops at either end', () {
      const s = AppearanceSettings();
      expect(s.move(defaults, 'b', -1).ordered(defaults), ['b', 'a', 'c', 'd']);
      expect(s.move(defaults, 'a', -1).ordered(defaults), defaults);
      expect(s.move(defaults, 'd', 1).ordered(defaults), defaults);
    });

    test('reset keeps language and look', () {
      const s = AppearanceSettings(
        language: LanguageChoice.tr,
        accent: AccentChoice.blue,
        hiddenTiles: {'a'},
        hiddenSections: {TodaySection.tools},
        padOpen: true,
        tileOrder: ['b'],
      );
      expect(
        s.resetToday(),
        const AppearanceSettings(
          language: LanguageChoice.tr,
          accent: AccentChoice.blue,
        ),
      );
    });

    test('the layout round-trips through the saved file', () {
      const s = AppearanceSettings(
        tileOrder: ['b', 'a'],
        hiddenTiles: {'c'},
        hiddenSections: {TodaySection.yourData},
        padOpen: true,
      );
      expect(AppearanceSettings.fromJson(s.toJson()), s);
      expect(
        AppearanceSettings.fromJson({
          'hiddenSections': ['nope', 'tools'],
          'tileOrder': 'x',
        }).hiddenSections,
        {TodaySection.tools},
      );
    });
  });

  testWidgets('hide a tile, move one up, hide a section; Reset restores', (
    tester,
  ) async {
    final store = MemoryAppearanceStore();
    await launchWith(tester, store: store);
    expect(tileOrderOnToday(tester).first, 'vital.blood_pressure');
    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-tile-show-vital.blood_pressure');
    await tapKey(tester, 'set-tile-up-body.height');
    await tapKey(tester, 'set-section-tools');
    expect(store.saved?.hiddenTiles, {'vital.blood_pressure'});
    await back(tester);
    final order = tileOrderOnToday(tester);
    expect(order, isNot(contains('vital.blood_pressure')));
    expect(
      order.indexOf('body.height'),
      lessThan(order.indexOf('body.waist_circumference')),
    );
    expect(find.byKey(const ValueKey('tool-genetics')), findsNothing);
    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-reset-today');
    await back(tester);
    expect(tileOrderOnToday(tester).first, 'vital.blood_pressure');
    expect(find.byKey(const ValueKey('tool-genetics')), findsOneWidget);
  });

  testWidgets('with every tile hidden Today says where to bring them back', (
    tester,
  ) async {
    await launchWith(
      tester,
      initial: const AppearanceSettings(
        hiddenTiles: {
          'vital.blood_pressure',
          'vital.resting_heart_rate',
          'vital.body_temperature',
          'vital.oxygen_saturation',
          'vital.respiratory_rate',
          'body.waist_circumference',
          'body.height',
        },
      ),
    );
    expect(
      find.byKey(const ValueKey('measurements-all-hidden')),
      findsOneWidget,
    );
  });

  testWidgets('"number pad open" opens the pad in a new sheet; the sheet can '
      'still close it', (tester) async {
    await launchWith(tester, initial: const AppearanceSettings(padOpen: true));
    await tapKey(tester, 'measure-tile-vital.body_temperature');
    expect(find.byKey(const ValueKey('measure-pad')), findsOneWidget);
    await tapKey(tester, 'measure-pad-toggle');
    expect(find.byKey(const ValueKey('measure-pad')), findsNothing);
  });

  testWidgets('Settings fits 320 dp at 2x text in Turkish', (tester) async {
    await launchWith(
      tester,
      initial: const AppearanceSettings(
        language: LanguageChoice.tr,
        textSize: TextSizeChoice.largest,
      ),
    );
    tester.view.physicalSize = const Size(320, 1400);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await settle(tester);
    await tapKey(tester, 'open-settings');
    for (var i = 0; i < 12; i++) {
      await tester.drag(
        find.byKey(const ValueKey('screen-settings')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
