// U014@v0.32: a calm first run: three short steps, skippable, language and
// look chosen with the mouse, never shown again; reopened from Settings.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/appearance_scope.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show dev, settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

Future<AppearanceController> launchReal(
  WidgetTester tester,
  MemoryAppearanceStore store,
) async {
  tester.view.physicalSize = const Size(1280, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final s = await tester.runAsync(() async {
    final repo = LogRepository(
      sink: MemoryLogSink(),
      durability: StorageDurability.localFile,
      location: 'test',
    );
    final report = await repo.open();
    return servicesFor(dev, HostPlatform.linux, repo, report: report);
  });
  final c = AppearanceController(store, await store.load());
  await tester.pumpWidget(
    HumanOsApp(services: s!, appearance: c, offerFirstRun: true),
  );
  await settle(tester);
  return c;
}

void main() {
  testWidgets('three steps, Türkçe chosen with the mouse, Start opens Today '
      'and is remembered', (tester) async {
    final store = MemoryAppearanceStore();
    await launchReal(tester, store);
    expect(find.text('Step 1 of 3'), findsOneWidget);
    await tapKey(tester, 'first-next');
    expect(find.text('Step 2 of 3'), findsOneWidget);
    await tapKey(tester, 'first-back');
    expect(find.text('Step 1 of 3'), findsOneWidget);
    await tapKey(tester, 'first-next');
    await tapKey(tester, 'first-next');
    await tapKey(tester, 'first-language-tr');
    expect(find.text('Adım 3 / 3'), findsOneWidget);
    await tapKey(tester, 'first-next');
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    expect(store.saved?.firstRunDone, isTrue);
    expect(store.saved?.language, LanguageChoice.tr);
    await tester.pumpWidget(const SizedBox());
    await launchReal(tester, store);
    expect(find.byKey(const ValueKey('screen-first-run')), findsNothing);
  });

  testWidgets('Skip goes straight to Today', (tester) async {
    final store = MemoryAppearanceStore();
    await launchReal(tester, store);
    await tapKey(tester, 'first-skip');
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    expect(store.saved?.firstRunDone, isTrue);
  });

  testWidgets('Settings can show it again; finishing returns to Settings', (
    tester,
  ) async {
    await launchWith(tester);
    expect(find.byKey(const ValueKey('screen-first-run')), findsNothing);
    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-first-run');
    expect(find.byKey(const ValueKey('screen-first-run')), findsOneWidget);
    await tapKey(tester, 'first-skip');
    expect(find.byKey(const ValueKey('screen-settings')), findsOneWidget);
  });

  test('first-run words judge nothing and say no welcome fluff', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.firstWelcomeTitle,
        s.firstWelcomeBody,
        s.firstPrivateTitle,
        s.firstPrivateBody,
        s.firstLookTitle,
        s.firstLookBody,
        s.firstMoreInSettings,
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
        expect(w.toLowerCase().contains('welcome'), isFalse, reason: w);
      }
    }
  });

  test('"seen" survives the saved file', () {
    const s = AppearanceSettings(firstRunDone: true);
    expect(AppearanceSettings.fromJson(s.toJson()).firstRunDone, isTrue);
    expect(AppearanceSettings.fromJson(const {}).firstRunDone, isFalse);
    expect(s == const AppearanceSettings(), isFalse);
  });
}
