// v0.32 F001 required automated checks (master "EXECUTION KERNEL", F001
// REQUIRED AUTOMATED CHECKS 1-8), tested through user-visible behaviour,
// plus the F001 honesty rules found in the v0.32 Phase 0 gap analysis.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/app/startup_error_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';

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
    // Staging starts at the vault gate (F006); the real storage policy only
    // reads, and choosing memory only writes nothing.
    final startup = await tester.runAsync(
      () => startApp(staging, HostPlatform.linux),
    );
    await tester.pumpWidget(HumanOsApp.start(startup!));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('gate-memory-only')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    await go(tester, rail(), 'Labs');
    expect(find.byKey(const ValueKey('screen-labs')), findsOneWidget);
    expect(guard.attempts, 0);
    expect(find.text('Not required'), findsNothing); // not on Labs
  });

  testWidgets('Timeline never claims "No records yet" after a weight was '
      'saved: it lists the weight (F003)', (tester) async {
    await boot(tester, size: desktop);
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '80');
    await tester.tap(find.byKey(const ValueKey('weight-save')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('weight-latest')), findsOneWidget);
    await go(tester, rail(), 'Timeline');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text('No records yet'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('screen-timeline')),
        matching: find.text('80 kg'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the banner shows the clinical disclaimer first and the whole '
      'text at large sizes (EN and TR)', (tester) async {
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
      // No line limit or ellipsis: the profile name is never cut (UX-1).
      expect(text.maxLines, isNull);
      expect(text.overflow, isNot(TextOverflow.ellipsis));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('staging on a desktop kept in memory only says "Saving off" '
      'and why, not "Not built yet"', (tester) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final startup = await tester.runAsync(
      () => startApp(staging, HostPlatform.linux),
    );
    await tester.pumpWidget(HumanOsApp.start(startup!));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('gate-memory-only')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saving off'), findsOneWidget);
    expect(
      find.textContaining('keep this session in memory only'),
      findsOneWidget,
    );
  });

  test('builds with an encrypted vault never start without the gate', () async {
    await expectLater(
      bootstrap(staging, HostPlatform.linux),
      throwsA(isA<StateError>()),
    );
  });

  testWidgets('a storage failure while saving shows an error and no latest '
      'value (UX-2)', (tester) async {
    tester.view.physicalSize = desktop;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final sink = _FailingAppendSink();
    final services = await tester.runAsync(() async {
      final repo = LogRepository(
        sink: sink,
        durability: StorageDurability.localFile,
        location: 'test',
      );
      await repo.open();
      final s = await servicesFor(development, HostPlatform.linux, repo);
      sink.failAppends = true; // the profile was written; now writes fail
      return s;
    });
    await tester.pumpWidget(HumanOsApp(services: services!));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '81');
    await tester.tap(find.byKey(const ValueKey('weight-save')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Not saved: storage failed'), findsOneWidget);
    expect(find.byKey(const ValueKey('weight-latest')), findsNothing);
    expect(find.byKey(const ValueKey('weight-saved')), findsNothing);
  });

  testWidgets('planned rail items meet the 48 dp touch-target guideline '
      '(UX-4)', (tester) async {
    await boot(tester, size: desktop);
    for (final d in ['medications', 'learn']) {
      final size = tester.getSize(find.byKey(ValueKey('rail-planned-$d')));
      expect(size.height, greaterThanOrEqualTo(48), reason: d);
    }
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('the More sheet marks the open area with an icon, not colour '
      'alone (UX-5)', (tester) async {
    await boot(tester, size: phone);
    await go(tester, bar(), 'More');
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    await go(tester, bar(), 'More');
    final sheet = find.byKey(const ValueKey('more-sheet'));
    final tile = tester.widget<ListTile>(
      find.ancestor(of: find.text('Activity'), matching: find.byType(ListTile)),
    );
    expect(tile.selected, isTrue);
    expect((tile.trailing as Icon?)?.icon, Icons.check);
    expect(
      find.descendant(of: sheet, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });

  testWidgets('large text on a 320 dp phone: a 3-digit latest weight and the '
      'banner do not overflow (UX-7)', (tester) async {
    await boot(tester, size: const Size(320, 640), textScale: 2.0);
    expect(tester.takeException(), isNull);
    // At this size the input is below the fold; scroll to it like a user.
    final todayList = find
        .descendant(
          of: find.byKey(const ValueKey('screen-today')),
          matching: find.byType(Scrollable),
        )
        .first;
    final input = find.byKey(const ValueKey('weight-input'));
    await tester.scrollUntilVisible(input, 200, scrollable: todayList);
    await tester.enterText(input, '123,4');
    await tester.ensureVisible(find.byKey(const ValueKey('weight-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('weight-save')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('weight-latest')),
      -200,
      scrollable: todayList,
    );
    expect(find.byKey(const ValueKey('weight-latest')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('medium rail (1024×700), Turkish, text ×2: no overflow and the '
      'planned group is reachable (UX-6)', (tester) async {
    await boot(
      tester,
      size: const Size(1024, 700),
      textScale: 2.0,
      locale: const Locale('tr'),
    );
    expect(tester.takeException(), isNull);
    final item = find.byKey(const ValueKey('rail-planned-learn'));
    await tester.scrollUntilVisible(
      item,
      200,
      scrollable: find
          .descendant(of: rail(), matching: find.byType(Scrollable))
          .first,
    );
    await tester.tap(item);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-learn')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed startup shows an explanation, not a blank window '
      '(UX-8)', (tester) async {
    await tester.pumpWidget(
      StartupErrorApp(error: StateError('vault at /home/kaan: 73.4 kg')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Human OS could not start'), findsOneWidget);
    expect(find.textContaining('Nothing was changed on disk'), findsOneWidget);
    // F006 (§37): the error type is shown, never its message.
    expect(find.text('StateError'), findsOneWidget);
    expect(find.textContaining('73.4'), findsNothing);
    expect(find.textContaining('/home/kaan'), findsNothing);
  });
}

/// Sink whose appends fail on demand, to exercise the save-failure state.
class _FailingAppendSink implements LogSink {
  String? text;
  bool failAppends = false;

  @override
  Future<String?> read() async => text;

  @override
  Future<void> create(String header) async => text = '$header\n';

  @override
  Future<void> appendLine(String line) async {
    if (failAppends) throw const FileSystemException('disk full (test)');
    text = '${text ?? ''}$line\n';
  }
}
