// A001@v0.32: Aion, the owner's Human OS character, appears as a still,
// labelled picture on the first introduction step and beside the empty
// weight card; Settings can hide it; it says nothing on its own.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('beside the empty weight card, labelled for screen readers', (
    tester,
  ) async {
    await launchWith(tester);
    expect(find.byKey(const ValueKey('aion')), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel('Aion, the Human OS character, waving'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('Settings hides Aion everywhere at once', (tester) async {
    final c = await launchWith(tester);
    await tapKey(tester, 'open-settings');
    final sw = find.byKey(const ValueKey('set-show-aion'));
    await tester.ensureVisible(sw);
    await settle(tester);
    await tester.tap(sw);
    await settle(tester);
    expect(c.value.showAion, isFalse);
    await tester.pageBack();
    await settle(tester);
    expect(find.byKey(const ValueKey('aion')), findsNothing);
    expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
  });

  testWidgets('first introduction step shows Aion', (tester) async {
    await launchWith(tester);
    await tapKey(tester, 'open-settings');
    final again = find.byKey(const ValueKey('set-first-run'));
    await tester.ensureVisible(again);
    await settle(tester);
    await tester.tap(again);
    await settle(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('screen-first-run')),
        matching: find.byKey(const ValueKey('aion')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a 320 dp phone with the largest text in Turkish: the empty '
      'card keeps its text and nothing overflows; at 200% scale too', (
    tester,
  ) async {
    await launchWith(
      tester,
      initial: const AppearanceSettings(
        language: LanguageChoice.tr,
        textSize: TextSizeChoice.largest,
      ),
    );
    tester.view.physicalSize = const Size(320, 2400);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await settle(tester);
    final empty = find.byKey(const ValueKey('weight-empty'));
    await tester.ensureVisible(empty);
    await settle(tester);
    expect(empty, findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('weight-card')),
        matching: find.byKey(const ValueKey('aion')),
      ),
      findsNothing,
      reason: 'a narrow card gives the text the whole width',
    );
    expect(tester.takeException(), isNull);
    // The whole interface at 200% keeps a 320 dp layout and scrolls.
    await launchWith(
      tester,
      initial: const AppearanceSettings(
        language: LanguageChoice.tr,
        interfacePercent: 200,
      ),
    );
    tester.view.physicalSize = const Size(320, 2400);
    await settle(tester);
    expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('kept with the other choices, on by default, Reset Today keeps it', () {
    const off = AppearanceSettings(showAion: false);
    expect(AppearanceSettings.fromJson(off.toJson()).showAion, isFalse);
    expect(AppearanceSettings.fromJson(const {}).showAion, isTrue);
    expect(off.resetToday().showAion, isFalse);
    expect(off == const AppearanceSettings(), isFalse);
  });

  test('the picture is bundled and the words judge nothing', () {
    final f = File('assets/aion/aion_wave.png');
    expect(f.existsSync(), isTrue);
    expect(f.readAsBytesSync().sublist(1, 4), 'PNG'.codeUnits);
    for (final lang in AppLang.values) {
      for (final w in [S(lang).aionAlt, S(lang).settingsShowAion]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
