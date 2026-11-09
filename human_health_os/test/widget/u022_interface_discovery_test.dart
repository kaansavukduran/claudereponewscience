import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/data/local/appearance_store_io.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

Finder keyed(String key) => find.byKey(ValueKey(key));

void main() {
  test('old preferences open; exact scale validates without clamping', () {
    expect(
      AppearanceSettings.fromJson({'theme': 'dark'}).interfacePercent,
      100,
    );
    for (final n in ['79', '201', '1.35', '', 'NaN', '135.0']) {
      expect(AppearanceSettings.parseInterfacePercent(n), isNull);
      expect(
        AppearanceSettings.fromJson({'interfacePercent': n}).interfacePercent,
        100,
      );
    }
    expect(AppearanceSettings.parseInterfacePercent(' 135 '), 135);
    expect(AppearanceSettings.parseInterfacePercent('133'), 133);
    const a = AppearanceSettings(
      interfacePercent: 135,
      textSize: TextSizeChoice.largest,
      discoveryEnabled: false,
      discovered: {DiscoveryStep.settings},
      hiddenTiles: {'body.height'},
    );
    expect(AppearanceSettings.fromJson(a.toJson()), a);
    expect(a.resetToday().interfacePercent, 135);
    expect(a.resetToday().discoveryEnabled, false);
    expect(a.resetToday().discovered, {DiscoveryStep.settings});
  });

  test('visits deduplicate, disabled discovery records nothing', () {
    const a = AppearanceSettings();
    final b = a.visit(DiscoveryStep.glossary);
    expect(b.discovered, {DiscoveryStep.glossary});
    expect(identical(b.visit(DiscoveryStep.glossary), b), isTrue);
    final off = b.copyWith(discoveryEnabled: false);
    expect(off.visit(DiscoveryStep.settings), off);
    expect(off.copyWith(discoveryEnabled: true).discovered, b.discovered);
  });

  test(
    'file relaunch preserves scale, discovery, font and text independently',
    () async {
      final dir = await Directory.systemTemp.createTemp('hhos-u022-');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}/appearance.json';
      const a = AppearanceSettings(
        interfacePercent: 175,
        font: FontChoice.dyslexic,
        textSize: TextSizeChoice.larger,
        theme: ThemeChoice.dark,
        discovered: {DiscoveryStep.settings, DiscoveryStep.howTo},
      );
      await FileAppearanceStore(File(path)).save(a);
      expect(await FileAppearanceStore(File(path)).load(), a);
    },
  );

  testWidgets(
    'exact 135 applies to whole UI, route stays open; reset only scale',
    (tester) async {
      final c = await launchWith(
        tester,
        initial: const AppearanceSettings(
          theme: ThemeChoice.dark,
          font: FontChoice.dyslexic,
          textSize: TextSizeChoice.larger,
        ),
      );
      await tapKey(tester, 'open-settings');
      final before = tester.getRect(keyed('set-interface-apply')).height;
      await tester.enterText(keyed('set-interface-input'), '135');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle(tester);
      expect(c.value.interfacePercent, 135);
      expect(keyed('screen-settings'), findsOneWidget);
      expect(
        tester.getRect(keyed('set-interface-apply')).height,
        closeTo(before * 1.35, .1),
      );
      final ctx = tester.element(keyed('screen-settings'));
      expect(MediaQuery.textScalerOf(ctx).scale(10), closeTo(11.5, .01));
      expect(tester.widget<Text>(keyed('interface-scale-value')).data, '135%');
      await tapKey(tester, 'set-interface-reset');
      expect(c.value.interfacePercent, 100);
      expect(c.value.font, FontChoice.dyslexic);
      expect(c.value.theme, ThemeChoice.dark);
      expect(c.value.textSize, TextSizeChoice.larger);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('invalid exact entry leaves active scale and shows recovery', (
    tester,
  ) async {
    final c = await launchWith(tester);
    await tapKey(tester, 'open-settings');
    await tester.enterText(keyed('set-interface-input'), '250');
    await tapKey(tester, 'set-interface-apply');
    expect(c.value.interfacePercent, 100);
    expect(find.text(const S(AppLang.en).interfaceInvalid), findsOneWidget);
    await tester.enterText(keyed('set-interface-input'), '133');
    await tapKey(tester, 'set-interface-apply');
    expect(c.value.interfacePercent, 133);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slider has five-point keyboard steps and six working presets', (
    tester,
  ) async {
    final c = await launchWith(tester);
    await tapKey(tester, 'open-settings');
    final slider = tester.widget<Slider>(keyed('set-interface-slider'));
    expect(slider.divisions, 24);
    // Focus the real Slider, then activate its built-in keyboard action.
    slider.focusNode!.requestFocus();
    await settle(tester);
    final old = c.value.interfacePercent;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(tester);
    expect(c.value.interfacePercent, old + 5);
    for (final n in [80, 100, 125, 150, 175, 200]) {
      await tapKey(tester, 'set-interface-$n');
      expect(c.value.interfacePercent, n);
      expect(keyed('screen-settings'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'unsupported device locale defaults to Turkish; explicit English wins',
    (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('de')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final c = await launchWith(tester);
      expect(find.text('Bugün'), findsWidgets);
      await c.update(c.value.copyWith(language: LanguageChoice.en));
      await settle(tester);
      expect(find.text('Today'), findsWidgets);
    },
  );

  testWidgets('narrow 200% keeps scale, supports panning and both languages', (
    tester,
  ) async {
    for (final language in [LanguageChoice.tr, LanguageChoice.en]) {
      final c = await launchWith(
        tester,
        initial: AppearanceSettings(
          language: language,
          interfacePercent: 200,
          reduceMotion: true,
          font: FontChoice.dyslexic,
        ),
      );
      tester.view.physicalSize = const Size(360, 900);
      await settle(tester);
      final scroll = keyed('interface-horizontal-scroll');
      expect(tester.getSize(scroll).width, 360);
      final ctx = tester.element(keyed('screen-today'));
      expect(MediaQuery.sizeOf(ctx).width, 320);
      expect(c.value.interfacePercent, 200);
      await tester.ensureVisible(keyed('open-settings'));
      await tester.tap(keyed('open-settings'));
      await settle(tester);
      expect(keyed('screen-settings'), findsOneWidget);
      await tapKey(tester, 'set-interface-reset');
      expect(c.value.interfacePercent, 100);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
    'only actual tool visits count; disabling preserves records and progress',
    (tester) async {
      final c = await launchWith(tester);
      expect(c.value.discovered, isEmpty);
      await tapKey(tester, 'open-settings');
      expect(c.value.discovered, {DiscoveryStep.settings});
      await tester.pageBack();
      await settle(tester);
      await tapKey(tester, 'discovery-glossary');
      expect(c.value.discovered, {
        DiscoveryStep.settings,
      }, reason: 'list is not an entry');
      final entry = find.byType(ListTile).first;
      await tester.tap(entry);
      await settle(tester);
      expect(c.value.discovered, {
        DiscoveryStep.settings,
        DiscoveryStep.glossary,
      });
      await tester.pageBack();
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
      await tapKey(tester, 'discovery-howTo');
      expect(c.value.discovered.length, 3);
      await tester.pageBack();
      await settle(tester);
      await tapKey(tester, 'discovery-hide');
      expect(c.value.discoveryEnabled, false);
      expect(c.value.discovered.length, 3);
      expect(keyed('discovery-card'), findsNothing);
      await tester.ensureVisible(keyed('weight-input'));
      await tester.enterText(keyed('weight-input'), '72.4');
      await tapKey(tester, 'weight-save');
      expect(find.text('72.4 kg'), findsWidgets);
    },
  );
}
