// M001@v0.32: Android and iOS builds keep data in the app-private folder the
// native side reports; without it (or with a relative path) they stay in
// memory as before. Environment variables and portable markers never move
// data on a phone.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/appearance_store_io.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 't',
  sourceRevision: 't',
);
const prod = AppConfig(
  profile: BuildProfile.production,
  version: 't',
  sourceRevision: 't',
);

final sep = Platform.pathSeparator;

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('m001'));
  tearDown(() {
    mobileAppDataDir = null;
    tmp.deleteSync(recursive: true);
  });

  group('resolveDataDirectory on a phone', () {
    test('the app folder, ignoring HHOS_DATA_DIR and HOME', () {
      final d = resolveDataDirectory(
        env: {'HHOS_DATA_DIR': '${tmp.path}${sep}elsewhere', 'HOME': tmp.path},
        mobile: true,
        mobileDir: '${tmp.path}${sep}files',
      );
      expect(d.dir!.path, '${tmp.path}${sep}files${sep}HumanHealthOS');
      expect(d.invalidVariable, isNull);
    });
    test('the reported folder when none is passed', () {
      mobileAppDataDir = '${tmp.path}${sep}Application Support';
      expect(
        resolveDataDirectory(env: const {}, mobile: true).dir!.path,
        '${tmp.path}${sep}Application Support${sep}HumanHealthOS',
      );
    });
    test('none reported or a relative one: no folder', () {
      expect(resolveDataDirectory(env: const {}, mobile: true).dir, isNull);
      expect(
        resolveDataDirectory(
          env: const {},
          mobile: true,
          mobileDir: 'files',
        ).dir,
        isNull,
      );
    });
  });

  test('development on a phone: the labelled log in the app folder', () async {
    mobileAppDataDir = tmp.path;
    // A portable marker beside a phone's "executable" changes nothing.
    final exeDir = Directory('${tmp.path}${sep}bin')..createSync();
    File('${exeDir.path}/portable_mode.json').writeAsStringSync('{}');
    final choice = await createPlatformRepository(
      dev,
      env: const {},
      executablePath: '${exeDir.path}/app_process',
      mobile: true,
    );
    expect(choice.vault, isNull);
    expect(
      choice.repository.description.durability,
      StorageDurability.localFile,
    );
    expect(choice.repository.description.location, startsWith(tmp.path));
    expect(Directory('${exeDir.path}/UserData').existsSync(), isFalse);
  });

  test('production on a phone: the encrypted vault in the app folder, nothing '
      'written before it is created', () async {
    mobileAppDataDir = tmp.path;
    final choice = await createPlatformRepository(
      prod,
      env: const {},
      mobile: true,
    );
    expect(
      choice.vault!.location,
      '${tmp.path}${sep}HumanHealthOS${sep}vault.hhosvault',
    );
    await choice.repository.open();
    expect(Directory('${tmp.path}${sep}HumanHealthOS').existsSync(), isFalse);
  });

  test('no folder reported: memory only, as before', () async {
    final choice = await createPlatformRepository(
      dev,
      env: const {},
      mobile: true,
    );
    expect(
      choice.repository.description.durability,
      StorageDurability.memoryOnly,
    );
  });

  test('display choices on a development phone build are remembered', () async {
    mobileAppDataDir = tmp.path;
    final store = await openAppearanceStore(
      dev,
      HostPlatform.android,
      env: const {},
      mobile: true,
    );
    expect(store.persistent, isTrue);
    await store.save(const AppearanceSettings(language: LanguageChoice.tr));
    final again = await openAppearanceStore(
      dev,
      HostPlatform.android,
      env: const {},
      mobile: true,
    );
    expect((await again.load()).language, LanguageChoice.tr);
    expect(
      File('${tmp.path}${sep}HumanHealthOS${sep}appearance.json').existsSync(),
      isTrue,
    );
    final vaultBuild = await openAppearanceStore(
      prod,
      HostPlatform.android,
      env: const {},
      mobile: true,
    );
    expect(vaultBuild.persistent, isFalse);
  });
}
