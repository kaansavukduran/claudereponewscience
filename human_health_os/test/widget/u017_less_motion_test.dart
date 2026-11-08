// U017@v0.32: "Less motion" opens pages without a transition; the device's
// "remove animations" does the same; otherwise the usual transition runs.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'u005_settings_test.dart' show launchWith;

/// Opens Settings from Today and reports, 50 ms in, how many moving
/// transitions (fade, scale, slide) wrap the new page.
Future<int> transitionsWhileOpening(WidgetTester tester) async {
  final f = find.byKey(const ValueKey('tool-settings'));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  final page = find.byKey(const ValueKey('screen-settings'));
  expect(page, findsOneWidget);
  int around(Type t) =>
      find.ancestor(of: page, matching: find.byType(t)).evaluate().length;
  final moving =
      around(FadeTransition) +
      around(ScaleTransition) +
      around(SlideTransition) +
      around(DualTransitionBuilder);
  await tester.pumpAndSettle();
  return moving;
}

void main() {
  testWidgets('usual: a transition of several frames', (tester) async {
    await launchWith(tester);
    expect(await transitionsWhileOpening(tester), greaterThan(0));
  });

  testWidgets('less motion: the page simply appears', (tester) async {
    await launchWith(
      tester,
      initial: const AppearanceSettings(reduceMotion: true),
    );
    expect(await transitionsWhileOpening(tester), 0);
  });

  testWidgets('the device setting "remove animations" is honoured', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await launchWith(tester);
    expect(await transitionsWhileOpening(tester), 0);
  });

  testWidgets('the switch in Settings turns it on at once and it is saved', (
    tester,
  ) async {
    final c = await launchWith(tester);
    await transitionsWhileOpening(tester);
    final sw = find.byKey(const ValueKey('set-reduce-motion'));
    await tester.ensureVisible(sw);
    await tester.pumpAndSettle();
    await tester.tap(sw);
    await tester.pumpAndSettle();
    expect(c.value.reduceMotion, isTrue);
    expect(AppearanceSettings.fromJson(c.value.toJson()).reduceMotion, isTrue);
    expect(AppearanceSettings.fromJson(const {}).reduceMotion, isFalse);
    expect(c.value == const AppearanceSettings(), isFalse);
  });

  testWidgets('iOS with less motion: the page does not move, and a swipe '
      'from the left edge still goes back', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await launchWith(
      tester,
      initial: const AppearanceSettings(reduceMotion: true),
    );
    final f = find.byKey(const ValueKey('tool-settings'));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final page = find.byKey(const ValueKey('screen-settings'));
    expect(tester.getTopLeft(page).dx, 0, reason: 'no slide in');
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(5, 400), const Offset(900, 0));
    await tester.pumpAndSettle();
    expect(page, findsNothing);
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  test('the words judge nothing', () {
    for (final lang in AppLang.values) {
      final w = S(lang).settingsReduceMotion;
      expect(interpretive.hasMatch(w), isFalse, reason: w);
      expect(judged.hasMatch(w), isFalse, reason: w);
    }
  });
}
