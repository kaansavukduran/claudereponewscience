// FORGE 001 acceptance (v0.27 doc 209): app starts, responsive shell renders,
// destinations change, non-production profile visible, Today shown, navigation to Labs.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/navigation/destinations.dart';

const devConfig = AppConfig(
  profile: BuildProfile.development,
  version: '0.1.0+1',
  sourceRevision: 'test',
);

Future<void> pumpApp(
  WidgetTester tester, {
  required Size size,
  AppConfig config = devConfig,
  HostPlatform platform = HostPlatform.web,
  Locale? locale,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final repo = inMemoryRepository();
  await repo.open();
  final services = await servicesFor(config, platform, repo);
  await tester.pumpWidget(HumanOsApp(services: services));
  await tester.pumpAndSettle();
}

const phone = Size(390, 844);
const tablet = Size(820, 1180);
const desktop = Size(1440, 900);
const laptop = Size(1024, 700);

void main() {
  group('starts on Today', () {
    for (final size in [phone, tablet, laptop, desktop]) {
      testWidgets('at ${size.width.toInt()}×${size.height.toInt()}', (
        tester,
      ) async {
        await pumpApp(tester, size: size);
        expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
        expect(find.text('Human OS'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('phone uses bottom bar, desktop uses rail (responsive)', (
    tester,
  ) async {
    await pumpApp(tester, size: phone);
    expect(find.byKey(const ValueKey('nav-bar')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-rail')), findsNothing);

    await pumpApp(tester, size: desktop);
    expect(find.byKey(const ValueKey('nav-rail')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-bar')), findsNothing);
    final rail = tester.widget<NavigationRail>(
      find.byKey(const ValueKey('nav-rail')),
    );
    expect(rail.extended, isTrue);
    expect(rail.destinations, hasLength(destinations.length));
  });

  testWidgets('phone: navigate Today → Labs', (tester) async {
    await pumpApp(tester, size: phone);
    await tester.tap(find.text('Labs'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-labs')), findsOneWidget);
    expect(find.byKey(const ValueKey('screen-today')), findsNothing);
    expect(
      find.textContaining('Reference interval ≠ optimal target'),
      findsOneWidget,
    );
  });

  testWidgets('desktop: navigate Today → Labs via rail', (tester) async {
    await pumpApp(tester, size: desktop);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('nav-rail')),
        matching: find.text('Labs'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-labs')), findsOneWidget);
  });

  testWidgets('phone: "More" reaches every non-primary destination', (
    tester,
  ) async {
    await pumpApp(tester, size: phone);
    for (final d in destinations.where(
      (d) => !const [
        DestinationId.today,
        DestinationId.timeline,
        DestinationId.labs,
        DestinationId.medications,
      ].contains(d.id),
    )) {
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('more-sheet')),
          matching: find.text(d.en),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(ValueKey('screen-${d.id.name}')),
        findsOneWidget,
        reason: d.en,
      );
    }
  });

  testWidgets('every destination is reachable on desktop and none is blank', (
    tester,
  ) async {
    await pumpApp(tester, size: desktop);
    for (final d in destinations) {
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('nav-rail')),
          matching: find.text(d.en),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('screen-${d.id.name}')), findsOneWidget);
      if (d.plannedForge != null) {
        // Honest empty state: names the FORGE that builds it, shows no fake data.
        expect(find.text('Planned in ${d.plannedForge}'), findsOneWidget);
        if (d.id == DestinationId.today) {
          // Today's built part is the weight card; its empty state is specific.
          expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
        } else {
          expect(find.text('No records yet'), findsOneWidget);
        }
      }
    }
  });

  testWidgets('non-production build shows its profile banner', (tester) async {
    await pumpApp(tester, size: phone);
    expect(find.byKey(const ValueKey('build-profile-banner')), findsOneWidget);
    expect(find.textContaining('DEVELOPMENT BUILD'), findsOneWidget);
  });

  testWidgets('staging build shows its banner with the clinical disclaimer', (
    tester,
  ) async {
    await pumpApp(
      tester,
      size: phone,
      config: const AppConfig(
        profile: BuildProfile.staging,
        version: '0.1.0+1',
        sourceRevision: 'x',
      ),
    );
    expect(find.textContaining('STAGING BUILD'), findsOneWidget);
    expect(find.textContaining('not for clinical decisions'), findsOneWidget);
  });

  testWidgets('This build card shows the source revision', (tester) async {
    await pumpApp(
      tester,
      size: desktop,
      config: const AppConfig(
        profile: BuildProfile.development,
        version: '0.1.0+1',
        sourceRevision: '0123456789abcdef0123',
      ),
    );
    expect(find.text('0123456789ab'), findsOneWidget);
  });

  testWidgets('production build hides the banner', (tester) async {
    await pumpApp(
      tester,
      size: phone,
      config: const AppConfig(
        profile: BuildProfile.production,
        version: '1.0.0+1',
        sourceRevision: 'x',
      ),
    );
    expect(find.byKey(const ValueKey('build-profile-banner')), findsNothing);
  });

  testWidgets(
    'Today states no weight yet, memory-only storage, network not required',
    (tester) async {
      await pumpApp(tester, size: desktop);
      expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
      expect(
        find.textContaining('Not saved: kept only until the app closes'),
        findsOneWidget,
      );
      expect(find.text('Not required'), findsOneWidget);
      // No capability is claimed as available before its adapter exists.
      expect(find.text('Available'), findsNothing);
    },
  );

  testWidgets('web registry never claims HealthKit/Health Connect', (
    tester,
  ) async {
    await pumpApp(tester, size: desktop, platform: HostPlatform.web);
    expect(find.text('Health Connect'), findsNothing);
    expect(find.text('Apple Health (HealthKit)'), findsNothing);
    expect(find.text('Not on this platform'), findsOneWidget);
  });

  testWidgets('Turkish locale localizes navigation', (tester) async {
    await pumpApp(tester, size: desktop, locale: const Locale('tr'));
    expect(find.text('Bugün'), findsWidgets);
    expect(find.text('Lab'), findsWidgets);
  });

  testWidgets(
    'section headings are separate semantics nodes (not merged with body)',
    (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, size: desktop);
      final node = tester.getSemantics(find.text('Body weight'));
      expect(node.label, 'Body weight');
      expect(node.flagsCollection.isHeader, isTrue);
      handle.dispose();
    },
  );

  testWidgets('Turkish phone layout renders without overflow', (tester) async {
    await pumpApp(
      tester,
      size: const Size(320, 640),
      locale: const Locale('tr'),
    );
    expect(tester.takeException(), isNull);
    expect(find.textContaining('GELİŞTİRME DERLEMESİ'), findsOneWidget);
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('screen-labs')), findsOneWidget);
  });
}
