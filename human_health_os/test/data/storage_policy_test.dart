// Storage policy (D-009): portable and production builds never write a
// plaintext vault; development installs use the XDG/LOCALAPPDATA location.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';

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

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('hhos-policy-'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('portable mode: nothing is written next to the executable', () async {
    final appDir = Directory('${tmp.path}/HumanHealthOS')..createSync();
    File('${appDir.path}/portable_mode.json').writeAsStringSync('{}');
    final choice = await createPlatformRepository(
      dev,
      env: {'HOME': tmp.path},
      executablePath: '${appDir.path}/human_health_os',
    );
    expect(
      choice.repository.description.durability,
      StorageDurability.memoryOnly,
    );
    expect(choice.notice, contains('encrypted vault'));
    await choice.repository.open();
    expect(Directory('${appDir.path}/UserData').existsSync(), isFalse);
  });

  test('production: no unencrypted persistence', () async {
    final choice = await createPlatformRepository(
      prod,
      env: {'HOME': tmp.path},
      executablePath: '${tmp.path}/bin/human_health_os',
    );
    expect(
      choice.repository.description.durability,
      StorageDurability.memoryOnly,
    );
    expect(choice.notice, contains('Production builds'));
  });

  test('development install on Linux uses the XDG data directory', () async {
    if (!Platform.isLinux) return;
    final choice = await createPlatformRepository(
      dev,
      env: {'XDG_DATA_HOME': '${tmp.path}/data'},
      executablePath: '${tmp.path}/bin/human_health_os',
    );
    expect(
      choice.repository.description.durability,
      StorageDurability.localFile,
    );
    expect(
      choice.repository.description.location,
      '${tmp.path}/data/HumanHealthOS/$vaultFileName',
    );
    expect(choice.notice, isNull);
  });
}
