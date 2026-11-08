// U016@v0.32: the name a person sees on every platform is "Human OS", not
// the template package name (G-20). Binary and package names stay as they
// are, so installers, download names and data folders do not move.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String read(String p) => File(p).readAsStringSync();

  test('Android launcher label', () {
    expect(
      read('android/app/src/main/AndroidManifest.xml'),
      contains('android:label="Human OS"'),
    );
  });
  test('Windows window title and file details', () {
    expect(read('windows/runner/main.cpp'), contains('L"Human OS"'));
    final rc = read('windows/runner/Runner.rc');
    expect(rc, contains('"FileDescription", "Human OS"'));
    expect(rc, contains('"ProductName", "Human OS"'));
    expect(rc, contains('"OriginalFilename", "human_health_os.exe"'));
  });
  test('iOS and macOS bundle names', () {
    for (final p in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
      final s = read(p).replaceAll(RegExp(r'\s+'), '');
      expect(
        s,
        contains('<key>CFBundleDisplayName</key><string>HumanOS</string>'),
        reason: p,
      );
      expect(
        s,
        contains('<key>CFBundleName</key><string>HumanOS</string>'),
        reason: p,
      );
    }
  });
  test('Linux and web titles', () {
    expect(read('linux/runner/my_application.cc'), contains('"Human OS"'));
    expect(read('web/index.html'), contains('<title>Human OS</title>'));
  });
}
