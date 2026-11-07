// U007@v0.32: more ways to make the app one's own: a number pad on the
// weight card, the start screen, compact spacing and high contrast.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';
import 'package:human_health_os/src/presentation/theme/human_os_theme.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show tapKey;
import 'u005_settings_test.dart' show launchWith;

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  final hi = x > y ? x : y, lo = x > y ? y : x;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  testWidgets('the weight card has a number pad that saves a weight with the '
      'mouse only', (tester) async {
    await launchWith(tester);
    expect(find.byKey(const ValueKey('weight-pad')), findsNothing);
    await tapKey(tester, 'weight-pad-toggle');
    for (final k in ['7', '2', 'dec', '4']) {
      await tapKey(tester, 'wpad-$k');
    }
    await tapKey(tester, 'weight-save');
    expect(find.text('72.4 kg'), findsWidgets);
  });

  testWidgets('the start screen opens the app on Labs', (tester) async {
    await launchWith(
      tester,
      initial: const AppearanceSettings(startScreen: StartScreen.labs),
    );
    expect(find.byKey(const ValueKey('screen-today')), findsNothing);
    expect(find.text('Labs'), findsWidgets);
  });

  testWidgets('compact spacing and high contrast apply at once', (
    tester,
  ) async {
    final c = await launchWith(tester);
    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-density-compact');
    await tapKey(tester, 'set-high-contrast');
    final ctx = tester.element(find.byKey(const ValueKey('screen-settings')));
    expect(Theme.of(ctx).visualDensity, VisualDensity.compact);
    expect(Theme.of(ctx).colorScheme.onSurface, Colors.black);
    expect(c.value.highContrast, isTrue);
    await tapKey(tester, 'set-start-timeline');
    expect(c.value.startScreen, StartScreen.timeline);
  });

  test('high contrast: text 7:1 and edges 3:1 on the surface, both modes', () {
    for (final b in Brightness.values) {
      final s = buildHumanOsTheme(b, highContrast: true).colorScheme;
      expect(contrast(s.onSurface, s.surface), greaterThanOrEqualTo(7));
      expect(contrast(s.outline, s.surface), greaterThanOrEqualTo(7));
      expect(contrast(s.outlineVariant, s.surface), greaterThanOrEqualTo(3));
    }
  });

  test('the new settings round-trip and Reset Today keeps them', () {
    const s = AppearanceSettings(
      startScreen: StartScreen.labs,
      density: Density.compact,
      highContrast: true,
      hiddenTiles: {'x'},
    );
    expect(AppearanceSettings.fromJson(s.toJson()), s);
    expect(
      s.resetToday(),
      const AppearanceSettings(
        startScreen: StartScreen.labs,
        density: Density.compact,
        highContrast: true,
      ),
    );
  });

  test('new words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.settingsSpacing,
        s.settingsComfortable,
        s.settingsCompact,
        s.settingsContrast,
        s.settingsHighContrast,
        s.settingsStart,
        for (final x in StartScreen.values) s.startScreenName(x),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
