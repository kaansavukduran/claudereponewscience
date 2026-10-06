// FORGE 002 acceptance: profile + one canonical record, save → restart → same
// record; empty input is never stored as zero; storage honesty is visible.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 't',
  sourceRevision: 't',
);

Future<void> pumpWith(WidgetTester tester, HealthRepository repo) async {
  tester.view.physicalSize = const Size(1280, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final services = await tester.runAsync(() async {
    await repo.open();
    return servicesFor(dev, HostPlatform.linux, repo);
  });
  await tester.pumpWidget(HumanOsApp(services: services!));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

Future<void> saveWeight(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const ValueKey('weight-input')), text);
  await tester.tap(find.byKey(const ValueKey('weight-save')));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('save a weight; it shows as latest with its original text', (
    tester,
  ) async {
    await pumpWith(tester, inMemoryRepository());
    expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
    await saveWeight(tester, '78,4');
    expect(find.byKey(const ValueKey('weight-latest')), findsOneWidget);
    expect(find.text('78.4 kg'), findsWidgets);
    expect(find.textContaining('entered as "78,4"'), findsOneWidget);
    expect(find.byKey(const ValueKey('weight-saved')), findsOneWidget);
  });

  testWidgets('empty input shows an error and stores nothing (missing ≠ 0)', (
    tester,
  ) async {
    await pumpWith(tester, inMemoryRepository());
    await saveWeight(tester, '   ');
    expect(find.textContaining('Empty is not saved as 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('weight-latest')), findsNothing);
    expect(find.text('0 kg'), findsNothing);
    await saveWeight(tester, '0');
    expect(find.textContaining('between 0 and 700 kg'), findsOneWidget);
    expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
  });

  testWidgets(
    'save, restart the app on the same vault, the same record is read back',
    (tester) async {
      // Real-file persistence is proven in test/data (FileLogSink) and by the
      // Linux runtime check. Widget tests run in a fake-async zone, so here the
      // vault bytes live in a shared sink and each launch parses them again.
      final sink = MemoryLogSink();
      LogRepository launch() => LogRepository(
        sink: sink,
        durability: StorageDurability.localFile,
        location: 'test vault',
      );

      await pumpWith(tester, launch());
      expect(
        find.textContaining('Saved on this device · not encrypted'),
        findsOneWidget,
      );
      await saveWeight(tester, '81.2');
      expect(find.text('81.2 kg'), findsWidgets);
      expect(sink.text, contains('"original_text":"81.2"'));

      await tester.pumpWidget(const SizedBox());
      await pumpWith(tester, launch());
      expect(find.byKey(const ValueKey('weight-latest')), findsOneWidget);
      expect(find.text('81.2 kg'), findsWidgets);
      // The local storage capability is now real.
      expect(find.text('Available'), findsOneWidget);
    },
  );
}
