// R004@v0.32: data in the phone's app folder never leaves the device through
// system backups: Android backup and device transfer exclude everything, and
// the iOS folder is created excluded from iCloud and computer backups (or no
// folder is given and the app keeps data in memory).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String read(String p) => File(p).readAsStringSync();

  test('Android: backup off, rules exclude every domain', () {
    final m = read('android/app/src/main/AndroidManifest.xml');
    expect(m, contains('android:allowBackup="false"'));
    expect(
      m,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
    expect(m, contains('android:fullBackupContent="@xml/backup_rules"'));
    final rules = read(
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    );
    for (final section in ['cloud-backup', 'device-transfer']) {
      final body = RegExp('<$section>([\\s\\S]*?)</$section>')
          .firstMatch(rules)!
          .group(1)!;
      for (final d in ['root', 'file', 'database', 'sharedpref', 'external']) {
        expect(body, contains('domain="$d" path="."'), reason: '$section $d');
      }
      expect(body, isNot(contains('<include')));
    }
    final legacy = read('android/app/src/main/res/xml/backup_rules.xml');
    expect(legacy, contains('domain="file" path="."'));
    expect(legacy, isNot(contains('<include')));
  });

  test('iOS: the folder is excluded from backup, or none is given', () {
    final swift = read('ios/Runner/AppDelegate.swift');
    expect(swift, contains('values.isExcludedFromBackup = true'));
    expect(swift, contains('try dir.setResourceValues(values)'));
    expect(swift, contains('result(nil)'));
  });
}
