// U023@v0.32: Settings is the last item of the navigation with a visible
// label (end of the rail on wide windows, end of the "More" sheet on
// phones), and Settings ends with the installed version and where newer
// versions are, without any network use.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('wide window: Settings is the last rail item, labelled, and '
      'opens Settings', (tester) async {
    await launchWith(
      tester,
      initial: const AppearanceSettings(language: LanguageChoice.tr),
    );
    final item = find.byKey(const ValueKey('rail-settings'));
    await tester.ensureVisible(item);
    await settle(tester);
    expect(
      find.descendant(of: item, matching: find.text('Ayarlar')),
      findsOneWidget,
    );
    final rail = find.byKey(const ValueKey('rail-planned-group'));
    final lastPlanned = find
        .descendant(
          of: rail,
          matching: find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('rail-planned-'),
          ),
        )
        .last;
    expect(
      tester.getTopLeft(item).dy,
      greaterThan(tester.getTopLeft(lastPlanned).dy),
    );
    await tester.tap(item);
    await settle(tester);
    expect(find.byKey(const ValueKey('screen-settings')), findsOneWidget);
  });

  testWidgets('phone: Settings is the last entry of More, labelled, and '
      'opens Settings', (tester) async {
    await launchWith(tester);
    tester.view.physicalSize = const Size(390, 900);
    await settle(tester);
    await tester.tap(find.text('More'));
    await settle(tester);
    final sheet = find.byKey(const ValueKey('more-sheet'));
    final entry = find.byKey(const ValueKey('more-settings'));
    await tester.scrollUntilVisible(
      entry,
      200,
      scrollable: find
          .descendant(of: sheet, matching: find.byType(Scrollable))
          .first,
    );
    expect(
      find.descendant(of: entry, matching: find.text('Settings')),
      findsOneWidget,
    );
    final tiles = find.descendant(of: sheet, matching: find.byType(ListTile));
    expect(tester.widget(tiles.last).key, const ValueKey('more-settings'));
    await tester.ensureVisible(entry);
    await settle(tester);
    await tester.tap(entry);
    await settle(tester);
    expect(sheet, findsNothing);
    expect(find.byKey(const ValueKey('screen-settings')), findsOneWidget);
  });

  testWidgets('Settings ends with the installed version and the releases '
      'page', (tester) async {
    await launchWith(tester);
    await tapKey(tester, 'open-settings');
    final v = find.byKey(const ValueKey('settings-version'));
    await tester.scrollUntilVisible(
      v,
      400,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('screen-settings')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(tester.widget<Text>(v).data, startsWith('Installed version: '));
    expect(
      find.text('github.com/kaansavukduran/human-os/releases'),
      findsOneWidget,
    );
  });

  test('the words judge nothing and promise no automatic check', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.settingsUpdatesTitle,
        s.settingsInstalledVersion('1', 'abc'),
        s.settingsUpdatesHow,
        s.settingsUpdatesKeepData,
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
