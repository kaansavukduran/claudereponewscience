// U005@v0.32: the person chooses the language, light or dark, an accent
// colour and the text size with one click each; choices apply at once and
// are saved through the appearance store.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/appearance_scope.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/appearance_store_io.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/features/genetics/genome_file_picker.dart';
import 'package:human_health_os/src/l10n/strings.dart';
import 'package:human_health_os/src/presentation/theme/human_os_theme.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show dev, settle, tapKey;

Future<AppearanceController> launchWith(
  WidgetTester tester, {
  AppearanceSettings initial = const AppearanceSettings(),
  MemoryAppearanceStore? store,
  GenomeFilePicker? picker,
}) async {
  tester.view.physicalSize = const Size(1280, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final s = await tester.runAsync(() async {
    final repo = LogRepository(
      sink: MemoryLogSink(),
      durability: StorageDurability.localFile,
      location: 'test',
    );
    final report = await repo.open();
    return servicesFor(
      dev,
      HostPlatform.linux,
      repo,
      report: report,
      genomePicker: picker,
    );
  });
  final c = AppearanceController(store ?? MemoryAppearanceStore(), initial);
  await tester.pumpWidget(HumanOsApp(services: s!, appearance: c));
  await settle(tester);
  return c;
}

void main() {
  testWidgets('Settings opens from the top bar on every screen and from '
      'Today; Türkçe switches the whole app at once', (tester) async {
    final store = MemoryAppearanceStore();
    await launchWith(tester, store: store);
    expect(find.text('Today'), findsWidgets);
    await tapKey(tester, 'open-settings');
    expect(find.byKey(const ValueKey('screen-settings')), findsOneWidget);
    await tapKey(tester, 'set-language-tr');
    expect(find.text('Ayarlar'), findsOneWidget);
    expect(store.saved?.language, LanguageChoice.tr);
    await tester.tap(find.byTooltip('Geri').first);
    await settle(tester);
    expect(find.text('Bugün'), findsWidgets);
    await tapKey(tester, 'tool-settings');
    expect(find.byKey(const ValueKey('screen-settings')), findsOneWidget);
  });

  testWidgets('dark, accent and text size apply at once', (tester) async {
    final c = await launchWith(tester);
    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-theme-dark');
    expect(
      Theme.of(tester.element(find.byKey(const ValueKey('screen-settings'))))
          .brightness,
      Brightness.dark,
    );
    await tapKey(tester, 'set-accent-purple');
    expect(
      Theme.of(tester.element(find.byKey(const ValueKey('screen-settings'))))
          .colorScheme
          .primary,
      accentTones[AccentChoice.purple]!.$2,
    );
    await tapKey(tester, 'set-text-largest');
    final ctx = tester.element(find.byKey(const ValueKey('screen-settings')));
    expect(MediaQuery.textScalerOf(ctx).scale(10), closeTo(13, 0.001));
    expect(c.value.textSize, TextSizeChoice.largest);
  });

  test('saved settings round-trip; unknown values fall back one by one', () {
    const a = AppearanceSettings(
      language: LanguageChoice.tr,
      theme: ThemeChoice.dark,
      accent: AccentChoice.green,
      textSize: TextSizeChoice.larger,
    );
    expect(AppearanceSettings.fromJson(a.toJson()), a);
    expect(
      AppearanceSettings.fromJson({'language': 'tr', 'theme': 'neon'}),
      const AppearanceSettings(language: LanguageChoice.tr),
    );
    expect(AppearanceSettings.fromJson('junk'), const AppearanceSettings());
  });

  test(
    'the file store saves atomically and ignores an unreadable file',
    () async {
      final dir = Directory.systemTemp.createTempSync('hhos-appearance');
      addTearDown(() => dir.deleteSync(recursive: true));
      final f = File('${dir.path}/appearance.json');
      final store = FileAppearanceStore(f);
      expect(await store.load(), const AppearanceSettings());
      await store.save(const AppearanceSettings(accent: AccentChoice.blue));
      expect((await store.load()).accent, AccentChoice.blue);
      expect(File('${f.path}.tmp').existsSync(), isFalse);
      f.writeAsStringSync('{not json');
      expect(await store.load(), const AppearanceSettings());
      expect(f.readAsStringSync(), '{not json', reason: 'left as it is');
    },
  );

  test('every accent tone reaches 4.5:1 on its surface', () {
    double ratio(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      final hi = x > y ? x : y, lo = x > y ? y : x;
      return (hi + 0.05) / (lo + 0.05);
    }

    for (final e in accentTones.entries) {
      expect(
        ratio(e.value.$1, Colors.white),
        greaterThanOrEqualTo(4.5),
        reason: '${e.key} light',
      );
      expect(
        ratio(e.value.$2, const Color(0xFF101819)),
        greaterThanOrEqualTo(4.5),
        reason: '${e.key} dark',
      );
    }
  });

  test('every settings word judges nothing, in both languages', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.settingsTitle,
        s.settingsTileHint,
        s.settingsLanguage,
        s.settingsTheme,
        s.settingsAccent,
        s.settingsTextSize,
        s.settingsSystem,
        s.settingsLight,
        s.settingsDark,
        s.settingsLarger,
        s.settingsLargest,
        s.settingsSaved,
        s.settingsSessionOnly,
        s.settingsSaveFailed,
        for (final c in AccentChoice.values) s.accentName(c),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
