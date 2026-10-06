// v0.32 F001 required automated checks (master "EXECUTION KERNEL", F001
// REQUIRED AUTOMATED CHECKS 1-8), tested through user-visible behaviour,
// plus the F001 honesty rules found in the v0.32 Phase 0 gap analysis.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';

const staging = AppConfig(
  profile: BuildProfile.staging,
  version: '0.1.0+1',
  sourceRevision: 'test',
);
const development = AppConfig(
  profile: BuildProfile.development,
  version: '0.1.0+1',
  sourceRevision: 'test',
);
const phone = Size(390, 844);
const desktop = Size(1440, 900);

/// Fails any attempt to open an HTTP connection and counts the attempts.
class _NoNetwork extends HttpOverrides {
  int attempts = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('F001 shell must not use the network');
  }
}

Future<void> boot(
  WidgetTester tester, {
  required Size size,
  AppConfig config = development,
  double textScale = 1.0,
  Locale? locale,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final services = await tester.runAsync(() async {
    final repo = inMemoryRepository();
    await repo.open();
    return servicesFor(config, HostPlatform.linux, repo);
  });
  await tester.pumpWidget(HumanOsApp(services: services!));
  await tester.pumpAndSettle();
}

Finder bar() => find.byKey(const ValueKey('nav-bar'));
Finder rail() => find.byKey(const ValueKey('nav-rail'));

Future<void> go(WidgetTester tester, Finder nav, String label) async {
  await tester.tap(find.descendant(of: nav, matching: find.text(label)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('check 1: the app/root widget renders the Human OS shell', (
    tester,
  ) async {
    await boot(tester, size: phone);
    expect(find.byType(HumanOsApp), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
      'Human OS',
    );
    expect(find.text('Human OS'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('checks 2-4 + 7 (narrow): Today, Timeline and Labs are '
      'reachable and switching changes the visible destination', (
    tester,
  ) async {
    await boot(tester, size: phone);
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    await go(tester, bar(), 'Timeline');
    expect(find.byKey(const ValueKey('screen-timeline')), findsOneWidget);
    expect(find.byKey(const ValueKey('screen-today')), findsNothing);
    await go(tester, bar(), 'Labs');
    expect(find.byKey(const ValueKey('screen-labs')), findsOneWidget);
    expect(find.byKey(const ValueKey('screen-timeline')), findsNothing);
    await go(tester, bar(), 'Today');
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    expect(find.byKey(const ValueKey('screen-labs')), findsNothing);
  });

  testWidgets('checks 2-4 + 7 (wide): the same through the side rail', (
    tester,
  ) async {
    await boot(tester, size: desktop);
    for (final (label, key) in [
      ('Timeline', 'screen-timeline'),
      ('Labs', 'screen-labs'),
      ('Today', 'screen-today'),
    ]) {
      await go(tester, rail(), label);
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: label);
    }
  });

  testWidgets('check 5: narrow layout exposes compact navigation with exactly '
      'Today, Timeline, Labs (+ More for planned areas)', (tester) async {
    await boot(tester, size: phone);
    expect(bar(), findsOneWidget);
    expect(rail(), findsNothing);
    final nav = tester.widget<NavigationBar>(bar());
    expect(
      [for (final d in nav.destinations) (d as NavigationDestination).label],
      ['Today', 'Timeline', 'Labs', 'More'],
    );
  });

  testWidgets('check 6: wide layout exposes side navigation with exactly '
      'Today, Timeline, Labs; planned areas are a separate group', (
    tester,
  ) async {
    await boot(tester, size: desktop);
    expect(rail(), findsOneWidget);
    expect(bar(), findsNothing);
    final nav = tester.widget<NavigationRail>(rail());
    expect(
      [for (final d in nav.destinations) (d.label as Text).data],
      ['Today', 'Timeline', 'Labs'],
    );
    final group = find.byKey(const ValueKey('rail-planned-group'));
    expect(
      find.descendant(of: group, matching: find.text('Planned')),
      findsOneWidget,
    );
    // Opening a planned area clears the primary selection.
    await tester.tap(find.byKey(const ValueKey('rail-planned-medications')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-medications')), findsOneWidget);
    expect(tester.widget<NavigationRail>(rail()).selectedIndex, isNull);
  });

  testWidgets('check 8: the real bootstrap() starts the shell with every '
      'HTTP client forbidden, and navigation still works', (tester) async {
    final guard = _NoNetwork();
    final previous = HttpOverrides.current;
    HttpOverrides.global = guard;
    addTearDown(() => HttpOverrides.global = previous);
    tester.view.physicalSize = desktop;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Staging is memory-only, so the real storage policy runs without disk IO.
    final services = await tester.runAsync(
      () => bootstrap(staging, HostPlatform.linux),
    );
    await tester.pumpWidget(HumanOsApp(services: services!));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    await go(tester, rail(), 'Labs');
    expect(find.byKey(const ValueKey('screen-labs')), findsOneWidget);
    expect(guard.attempts, 0);
    expect(find.text('Not required'), findsNothing); // not on Labs
  });

  testWidgets('Timeline never claims "No records yet" after a weight was '
      'saved (it does not list records yet)', (tester) async {
    await boot(tester, size: desktop);
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '80');
    await tester.tap(find.byKey(const ValueKey('weight-save')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('weight-latest')), findsOneWidget);
    await go(tester, rail(), 'Timeline');
    expect(find.text('No records yet'), findsNothing);
    expect(
      find.textContaining('This view does not list records yet'),
      findsOneWidget,
    );
  });

  testWidgets('the clinical disclaimer leads the banner, so ellipsis at '
      'large text sizes never cuts it (EN and TR)', (tester) async {
    for (final (locale, lead) in [
      (const Locale('en'), 'Not for clinical decisions'),
      (const Locale('tr'), 'Klinik karar için değil'),
    ]) {
      await boot(tester, size: phone, textScale: 2.0, locale: locale);
      final banner = find.byKey(const ValueKey('build-profile-banner'));
      final text = tester.widget<Text>(
        find.descendant(of: banner, matching: find.byType(Text)),
      );
      expect(text.data, startsWith(lead), reason: locale.languageCode);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('staging storage on a desktop says "Off in this build", not '
      '"Not built yet"', (tester) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final services = await tester.runAsync(
      () => bootstrap(staging, HostPlatform.linux),
    );
    await tester.pumpWidget(HumanOsApp(services: services!));
    await tester.pumpAndSettle();
    expect(find.text('Off in this build'), findsOneWidget);
    expect(find.textContaining('Staging builds do not save'), findsOneWidget);
  });
}
