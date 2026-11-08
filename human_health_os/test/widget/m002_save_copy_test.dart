// M002@v0.32: on a phone a backup, an export or the visit summary is saved
// inside the app and a "save a copy" button opens the system save dialog so
// the person can keep it somewhere they can reach (G-68); desktop builds
// keep saying where the file is and show no such button.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/app_services.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/features/today/save_copy.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f005_your_data_test.dart' show message, settle, tapKey;
import 'f007_measurements_test.dart' show dev;

class FakeSaveCopy implements SaveCopy {
  FakeSaveCopy({this.accept = true});

  final bool accept;
  final saved = <({String fileName, String text, String mimeType})>[];

  @override
  Future<bool> save({
    required String fileName,
    required String text,
    required String mimeType,
    required String title,
  }) async {
    if (!accept) return false;
    saved.add((fileName: fileName, text: text, mimeType: mimeType));
    return true;
  }
}

late AppServices services;

Future<MemoryDataFiles> start(
  WidgetTester tester,
  HostPlatform platform, {
  SaveCopy? copy,
}) async {
  tester.view.physicalSize = const Size(1280, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final files = MemoryDataFiles();
  final s = await tester.runAsync(() async {
    final repo = LogRepository(
      sink: MemoryLogSink(),
      durability: StorageDurability.localFile,
      location: 'test',
    );
    final report = await repo.open();
    return servicesFor(
      dev,
      platform,
      repo,
      report: report,
      files: files,
      saveCopy: copy,
    );
  });
  services = s!;
  await tester.pumpWidget(HumanOsApp(services: s));
  await settle(tester);
  return files;
}

void main() {
  final en = S(AppLang.en);

  testWidgets('phone: a backup is saved in the app, then copied out', (
    tester,
  ) async {
    final copy = FakeSaveCopy();
    final files = await start(tester, HostPlatform.android, copy: copy);
    await tapKey(tester, 'create-backup');
    expect(message(tester), en.savedInApp);
    await tapKey(tester, 'data-save-copy');
    final name = files.files.keys.single.substring('backup/'.length);
    expect(copy.saved.single.fileName, name);
    expect(copy.saved.single.text, files.files.values.single);
    expect(copy.saved.single.mimeType, 'application/json');
    expect(message(tester), en.copySaved(name));
  });

  testWidgets('phone: an export too; a cancelled dialog changes nothing', (
    tester,
  ) async {
    final copy = FakeSaveCopy(accept: false);
    await start(tester, HostPlatform.ios, copy: copy);
    await tapKey(tester, 'export-json');
    expect(message(tester), en.savedInApp);
    await tapKey(tester, 'data-save-copy');
    expect(copy.saved, isEmpty);
    expect(message(tester), en.savedInApp);
  });

  testWidgets('desktop: the place is named and no copy button appears', (
    tester,
  ) async {
    await start(tester, HostPlatform.linux);
    await tapKey(tester, 'create-backup');
    expect(message(tester), startsWith('Saved: memory:backup/'));
    expect(find.byKey(const ValueKey('data-save-copy')), findsNothing);
  });

  testWidgets('phone: the visit summary can be copied out as HTML', (
    tester,
  ) async {
    final copy = FakeSaveCopy();
    await start(tester, HostPlatform.android, copy: copy);
    await tester.runAsync(
      () => services.heartbeat.recordWeightKg(
        profileId: services.self.id,
        input: '80',
      ),
    );
    await tapKey(tester, 'tool-summary');
    await tapKey(tester, 'summary-save');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('summary-message'))).data,
      en.savedInApp,
    );
    await tapKey(tester, 'summary-save-copy');
    expect(copy.saved.single.mimeType, 'text/html');
    expect(copy.saved.single.fileName, startsWith('human-os-summary-'));
  });

  testWidgets('without a fake: the system dialog on phones, none on '
      'desktops', (tester) async {
    await start(tester, HostPlatform.android);
    expect(saveCopyFor(services), isA<SystemSaveCopy>());
    await start(tester, HostPlatform.windows);
    expect(saveCopyFor(services), isNull);
  });

  test('the words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [s.savedInApp, s.saveCopy, s.copySaved('x.json')]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
