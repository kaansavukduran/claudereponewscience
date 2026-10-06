// Real-device/desktop integration: real event loop, real file IO.
// Run: xvfb-run flutter test integration_test -d linux
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:integration_test/integration_test.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 'it',
  sourceRevision: 'it',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('save weight → relaunch on the same file vault → same record', (
    tester,
  ) async {
    final dir = Directory.systemTemp.createTempSync('hhos-it-');
    final vault = File('${dir.path}/$vaultFileName');
    Future<void> launch() async {
      final repo = LogRepository(
        sink: FileLogSink(vault),
        durability: StorageDurability.localFile,
        location: vault.path,
      );
      await repo.open();
      final services = await servicesFor(dev, detectHostPlatform(), repo);
      await tester.pumpWidget(HumanOsApp(services: services));
      await tester.pumpAndSettle();
    }

    await launch();
    expect(find.byKey(const ValueKey('weight-empty')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '77,9');
    await tester.tap(find.byKey(const ValueKey('weight-save')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('77.9 kg'), findsWidgets);
    expect(vault.readAsStringSync(), contains('"original_text":"77,9"'));

    await tester.pumpWidget(const SizedBox());
    await launch(); // fresh repository + fresh widget tree on the same file
    expect(find.byKey(const ValueKey('weight-latest')), findsOneWidget);
    expect(find.text('77.9 kg'), findsWidgets);

    // Moving the vault folder keeps the same profile (path ≠ identity).
    final moved = dir.renameSync('${dir.path}-moved');
    final repo2 = LogRepository(
      sink: FileLogSink(File('${moved.path}/$vaultFileName')),
      durability: StorageDurability.localFile,
      location: moved.path,
    );
    await repo2.open();
    expect((await repo2.profiles()).length, 1);
    moved.deleteSync(recursive: true);
  });
}
