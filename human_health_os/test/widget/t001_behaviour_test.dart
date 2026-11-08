// T001@v0.32: behaviour the test-adequacy review found unguarded: settings
// rules, theme mapping, note chips, start screens, the plant-chemicals
// search box and Turkish dose words.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/appearance_scope.dart';
import 'package:human_health_os/src/data/local/appearance_store_io.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/presentation/theme/human_os_theme.dart';

import 'f007_measurements_test.dart' show saveBp, settle, tapKey;
import 'g001_genetics_test.dart' show FakePicker;
import 'u002_guide_test.dart' show reveal;
import 'u005_settings_test.dart' show launchWith;

class _FailingStore extends MemoryAppearanceStore {
  bool fail = true;
  @override
  Future<void> save(AppearanceSettings s) async {
    if (fail) throw const FileSystemException('disk full');
    await super.save(s);
  }
}

void main() {
  group('settings rules', () {
    test('text size factors', () {
      expect(const AppearanceSettings().textFactor, 1.0);
      expect(
        const AppearanceSettings(textSize: TextSizeChoice.larger).textFactor,
        1.15,
      );
      expect(
        const AppearanceSettings(textSize: TextSizeChoice.largest).textFactor,
        1.3,
      );
    });

    test('saved strings longer than 64 characters are dropped', () {
      final s = AppearanceSettings.fromJson({
        'hiddenTiles': ['x' * 65, 'body.height'],
      });
      expect(s.hiddenTiles, {'body.height'});
    });

    test('equality sees every field', () {
      const a = AppearanceSettings();
      for (final b in [
        const AppearanceSettings(padOpen: true),
        const AppearanceSettings(hiddenTiles: {'a'}),
        const AppearanceSettings(tileOrder: ['a']),
        const AppearanceSettings(font: FontChoice.dyslexic),
        const AppearanceSettings(wideSpacing: true),
        const AppearanceSettings(startScreen: StartScreen.labs),
      ]) {
        expect(a == b, isFalse, reason: '$b');
      }
      expect(
        const AppearanceSettings(hiddenTiles: {'a', 'b'}) ==
            const AppearanceSettings(hiddenTiles: {'b', 'a'}),
        isTrue,
      );
    });

    test('Reset Today keeps font and spacing too', () {
      const s = AppearanceSettings(
        font: FontChoice.legible,
        wideSpacing: true,
        padOpen: true,
      );
      expect(
        s.resetToday(),
        const AppearanceSettings(font: FontChoice.legible, wideSpacing: true),
      );
    });

    test('a failed save is reported; the next good save clears it', () async {
      final store = _FailingStore();
      final c = AppearanceController(store);
      await c.update(const AppearanceSettings(padOpen: true));
      expect(c.saveFailed, isTrue);
      expect(c.value.padOpen, isTrue, reason: 'applies for the session');
      store.fail = false;
      await c.update(const AppearanceSettings());
      expect(c.saveFailed, isFalse);
    });

    test('the file store creates its folder', () async {
      final dir = Directory.systemTemp.createTempSync('hhos-t001');
      addTearDown(() => dir.deleteSync(recursive: true));
      final store = FileAppearanceStore(
        File('${dir.path}/a/b/appearance.json'),
      );
      await store.save(const AppearanceSettings(accent: AccentChoice.green));
      expect((await store.load()).accent, AccentChoice.green);
    });

    test('wide spacing sets letter, word and line spacing', () {
      final body = buildHumanOsTheme(
        Brightness.light,
        wideSpacing: true,
      ).textTheme.bodyMedium!;
      // bodyMedium is 14 in the Material 2021 type scale.
      final size = body.fontSize ?? 14;
      final title = buildHumanOsTheme(
        Brightness.light,
        wideSpacing: true,
      ).textTheme.headlineSmall!;
      expect(title.letterSpacing, closeTo(24 * 0.12, 0.001));
      expect(body.letterSpacing, closeTo(size * 0.12, 0.001));
      expect(body.wordSpacing, closeTo(size * 0.16, 0.001));
      expect(body.height, 1.5);
    });

    test('stronger contrast in dark mode uses white ink', () {
      expect(
        buildHumanOsTheme(
          Brightness.dark,
          highContrast: true,
        ).colorScheme.onSurface,
        Colors.white,
      );
    });
  });

  testWidgets('Light stays light when the device is dark', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await launchWith(
      tester,
      initial: const AppearanceSettings(theme: ThemeChoice.light),
    );
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.light,
    );
  });

  for (final (choice, key) in [
    (StartScreen.timeline, 'screen-timeline'),
    (StartScreen.labs, 'screen-labs'),
  ]) {
    testWidgets('start screen ${choice.name} opens ${choice.name}', (
      tester,
    ) async {
      await launchWith(
        tester,
        initial: AppearanceSettings(startScreen: choice),
      );
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    });
  }

  testWidgets('a note chip replaces what was typed; notes are trimmed and at '
      'most eight', (tester) async {
    await launchWith(tester);
    for (var i = 0; i < 9; i++) {
      await saveBp(tester, '${110 + i}', '70', context: '  note $i  ');
    }
    await tapKey(tester, 'measure-tile-vital.body_temperature');
    await tapKey(tester, 'measure-more');
    expect(find.byKey(const ValueKey('measure-note-7')), findsOneWidget);
    expect(find.byKey(const ValueKey('measure-note-8')), findsNothing);
    expect(
      find.text('note 8'),
      findsOneWidget,
      reason: 'newest first, trimmed',
    );
    await tester.enterText(
      find.byKey(const ValueKey('measure-context')),
      'typed',
    );
    await tapKey(tester, 'measure-note-0');
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('measure-context')))
          .controller!
          .text,
      'note 8',
    );
  });

  testWidgets('plant chemicals: a new file clears the search box; Turkish '
      'dose words; Turkish letters fold in search', (tester) async {
    final csv = utf8.encode(
      'Activity,Dosage\nNabız-Test,LDlo=>2,000 mg/kg (orl mus)\nOther,x\n'
          .replaceAll('>2,000', '>2000'),
    );
    await launchWith(
      tester,
      initial: const AppearanceSettings(language: LanguageChoice.tr),
      picker: FakePicker([('a.csv', csv), ('b.csv', csv)]),
    );
    await reveal(tester, 'screen-today', 'tool-phyto');
    await tapKey(tester, 'tool-phyto');
    await tapKey(tester, 'phyto-load');
    await settle(tester);
    expect(find.textContaining('orl = ağızdan'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('phyto-search')), 'NABIZ');
    await settle(tester);
    expect(find.text('Nabız-Test'), findsOneWidget);
    expect(find.text('Other'), findsNothing);
    await tapKey(tester, 'phyto-load');
    await settle(tester);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('phyto-search')))
          .controller!
          .text,
      '',
    );
    expect(find.text('Other'), findsOneWidget);
  });

  test('record kinds referenced here exist', () {
    expect(RecordKind.bodyTemperature.code, 'vital.body_temperature');
  });
}
