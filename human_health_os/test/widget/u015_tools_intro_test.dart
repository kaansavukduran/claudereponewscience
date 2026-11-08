// U015@v0.32: Today's tools in three labelled groups (G-65), and in an
// encrypted build the introduction comes before a new vault's passphrase
// screen, writing nothing (G-64); an existing vault goes straight to unlock.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/appearance_scope.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f006_vault_gate_test.dart'
    show Disk, createThroughGate, gateOn, settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

Future<MemoryAppearanceStore> launchGate(
  WidgetTester tester,
  Disk disk, {
  bool offer = true,
}) async {
  tester.view.physicalSize = const Size(1280, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final store = MemoryAppearanceStore();
  final c = AppearanceController(store, await store.load());
  final gate = await tester.runAsync(() => gateOn(disk));
  await tester.pumpWidget(
    HumanOsApp(gate: gate, appearance: c, offerIntroBeforeNewVault: offer),
  );
  await settle(tester);
  return store;
}

double topOf(WidgetTester tester, String key) =>
    tester.getTopLeft(find.byKey(ValueKey(key))).dy;

void main() {
  testWidgets('tools sit under three headings, in order', (tester) async {
    await launchWith(tester);
    final s = S(AppLang.en);
    for (final h in [s.toolsGroupApp, s.toolsGroupLearn, s.toolsGroupFiles]) {
      expect(find.text(h), findsOneWidget, reason: h);
    }
    double y(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(y(s.toolsGroupApp), lessThan(topOf(tester, 'tool-settings')));
    expect(topOf(tester, 'tool-summary'), lessThan(y(s.toolsGroupLearn)));
    expect(y(s.toolsGroupLearn), lessThan(topOf(tester, 'tool-glossary')));
    expect(topOf(tester, 'tool-guide'), lessThan(y(s.toolsGroupFiles)));
    expect(y(s.toolsGroupFiles), lessThan(topOf(tester, 'tool-phyto')));
    expect(
      topOf(tester, 'tool-phyto'),
      lessThan(topOf(tester, 'tool-genetics')),
    );
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.text(s.toolsGroupLearn)),
      matchesSemantics(label: s.toolsGroupLearn, isHeader: true),
    );
    semantics.dispose();
  });

  testWidgets('a new vault: introduction first, Türkçe chosen, nothing '
      'written, then the passphrase screen in Turkish', (tester) async {
    final disk = Disk();
    final store = await launchGate(tester, disk);
    expect(find.byKey(const ValueKey('screen-first-run')), findsOneWidget);
    expect(find.byKey(const ValueKey('vault-gate-create')), findsNothing);
    await tapKey(tester, 'first-next');
    await tapKey(tester, 'first-next');
    await tapKey(tester, 'first-language-tr');
    await tapKey(tester, 'first-next');
    expect(disk.raw.text, isNull, reason: 'nothing written before the vault');
    expect(find.byKey(const ValueKey('vault-gate-create')), findsOneWidget);
    expect(find.text('Araçlar'), findsNothing);
    expect(store.saved?.language, LanguageChoice.tr);
    await createThroughGate(tester);
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    expect(find.byKey(const ValueKey('screen-first-run')), findsNothing);
  });

  testWidgets('Skip on a new vault goes to the passphrase screen', (
    tester,
  ) async {
    final disk = Disk();
    await launchGate(tester, disk);
    await tapKey(tester, 'first-skip');
    expect(find.byKey(const ValueKey('vault-gate-create')), findsOneWidget);
  });

  testWidgets('an existing vault goes straight to unlock', (tester) async {
    final disk = Disk();
    await launchGate(tester, disk, offer: false);
    await createThroughGate(tester);
    await tester.pumpWidget(const SizedBox());
    await launchGate(tester, disk);
    expect(find.byKey(const ValueKey('screen-first-run')), findsNothing);
    expect(find.byKey(const ValueKey('vault-gate-unlock')), findsOneWidget);
  });

  testWidgets('without the offer a new vault opens at the passphrase screen', (
    tester,
  ) async {
    await launchGate(tester, Disk(), offer: false);
    expect(find.byKey(const ValueKey('screen-first-run')), findsNothing);
    expect(find.byKey(const ValueKey('vault-gate-create')), findsOneWidget);
  });

  test('group headings judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [s.toolsGroupApp, s.toolsGroupLearn, s.toolsGroupFiles]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
