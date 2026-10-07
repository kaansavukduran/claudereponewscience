// Storage policy (D-009/D-010, F006): portable, staging and production
// builds keep health data only in the encrypted vault and write nothing
// before it is created; development installs use the plaintext log in the
// XDG/LOCALAPPDATA location.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 't',
  sourceRevision: 't',
);
const staging = AppConfig(
  profile: BuildProfile.staging,
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

  test('portable mode, even in development: only the encrypted vault in '
      'UserData/, nothing written before it is created', () async {
    final appDir = Directory('${tmp.path}/HumanHealthOS')..createSync();
    File('${appDir.path}/portable_mode.json').writeAsStringSync('{}');
    final choice = await createPlatformRepository(
      dev,
      env: {'HOME': tmp.path},
      executablePath: '${appDir.path}/human_health_os',
    );
    final vault = choice.vault!;
    expect(
      vault.location,
      '${appDir.path}/UserData/vault-development.hhosvault',
    );
    expect(choice.files, isNull, reason: 'no plaintext backups beside the app');
    expect(
      choice.repository.description.durability,
      StorageDurability.memoryOnly,
      reason: 'the fallback store is memory only',
    );
    expect((await vault.inspect()).access, VaultAccess.create);
    expect(Directory('${appDir.path}/UserData').existsSync(), isFalse);
  });

  test('production: the encrypted vault, with the production cost and '
      'key derivation off the UI thread; nothing written yet', () async {
    final choice = await createPlatformRepository(
      prod,
      env: {'XDG_DATA_HOME': '${tmp.path}/data', 'HOME': tmp.path},
      executablePath: '${tmp.path}/bin/human_health_os',
    );
    final vault = choice.vault!;
    if (Platform.isLinux) {
      expect(
        vault.location,
        '${tmp.path}/data/human-health-os/vault.hhosvault',
      );
    }
    expect(vault.derive, same(deriveInIsolate));
    expect(choice.derive, same(deriveInIsolate));
    final p = vault.newKdf();
    expect([p.memoryKib, p.iterations, p.parallelism], [19456, 2, 1]);
    expect(p.salt.length, 16);
    expect(vault.canSetAside, isTrue);
    expect(choice.files, isNull, reason: 'encrypted backups come with unlock');
    expect(Directory('${tmp.path}/data').existsSync(), isFalse);
  });

  test('staging never opens the production vault file', () async {
    final choice = await createPlatformRepository(
      staging,
      env: {'XDG_DATA_HOME': '${tmp.path}/data', 'HOME': tmp.path},
      executablePath: '${tmp.path}/bin/human_health_os',
    );
    expect(choice.vault!.location, endsWith('vault-staging.hhosvault'));
    await choice.repository.open();
    expect(Directory('${tmp.path}/data').existsSync(), isFalse);
  });

  test('the desktop vault is set aside by a rename: same bytes, nothing '
      'deleted', () async {
    final choice = await createPlatformRepository(
      prod,
      env: {'HHOS_DATA_DIR': '${tmp.path}/data', 'HOME': tmp.path},
      executablePath: '${tmp.path}/bin/human_health_os',
    );
    final vault = choice.vault!;
    await vault.create(
      passphrase: 'a long enough passphrase',
      recoveryKey: 'K7QM-2XRA-PLMN-B3DE-ZZ4H-QW5T-RT6Y-HJ7U',
    );
    final file = File('${tmp.path}/data/vault.hhosvault');
    final bytes = file.readAsBytesSync();
    final kept = await vault.setAside();
    expect(kept, startsWith('${file.path}.locked-'));
    expect(File(kept).readAsBytesSync(), bytes);
    expect(file.existsSync(), isFalse);
    expect((await vault.inspect()).access, VaultAccess.create);
  });

  test('key derivation in an isolate gives the same key as inline', () async {
    final p = KdfParams(salt: randomBytes(16), memoryKib: 64, iterations: 1);
    expect(
      await deriveInIsolate('pass phrase', p),
      deriveKey('pass phrase', p),
    );
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
      '${tmp.path}/data/human-health-os/$vaultFileName',
    );
    expect(choice.reason, StorageReason.saving);
    expect(choice.notes, isEmpty);
    expect(choice.files, isNotNull, reason: 'development may write files');
  });

  group(
    'Linux development vault folder HumanHealthOS/ -> human-health-os/ (C-4)',
    () {
      late Directory data;
      late File oldVault;
      setUp(() {
        data = Directory('${tmp.path}/data')..createSync();
        oldVault = File('${data.path}/HumanHealthOS/$vaultFileName')
          ..createSync(recursive: true)
          ..writeAsStringSync('OLD VAULT BYTES\n');
      });

      Future<StorageChoice> open(AppConfig config) => createPlatformRepository(
        config,
        env: {'XDG_DATA_HOME': data.path, 'HOME': tmp.path},
        executablePath: '${tmp.path}/bin/human_health_os',
      );

      test(
        'moved by rename when the new folder is absent; bytes unchanged',
        () async {
          if (!Platform.isLinux) return;
          final choice = await open(dev);
          final moved = File('${data.path}/human-health-os/$vaultFileName');
          expect(moved.readAsStringSync(), 'OLD VAULT BYTES\n');
          expect(oldVault.existsSync(), isFalse);
          expect(choice.repository.description.location, moved.path);
          expect(choice.notes.single.kind, StorageNoteKind.movedLegacyFolder);
        },
      );

      test(
        'both folders present: the new one is used, the old one untouched',
        () async {
          if (!Platform.isLinux) return;
          Directory('${data.path}/human-health-os').createSync();
          final choice = await open(dev);
          expect(oldVault.readAsStringSync(), 'OLD VAULT BYTES\n');
          expect(
            choice.repository.description.location,
            '${data.path}/human-health-os/$vaultFileName',
          );
          expect(choice.notes.single.kind, StorageNoteKind.legacyFolderLeft);
          expect(choice.notes.single.detail, '${data.path}/HumanHealthOS');
        },
      );

      test('a failed move keeps using the old folder and says so', () async {
        if (!Platform.isLinux) return;
        final target = Directory('${data.path}/human-health-os');
        final legacy = Directory('${data.path}/HumanHealthOS');
        // A file in the way makes the rename fail without touching the vault.
        final r = adoptLegacyFolder(
          Directory('${oldVault.path}/blocked/human-health-os'),
          legacy,
        );
        expect(r.dir.path, legacy.path);
        expect(r.note!.kind, StorageNoteKind.legacyFolderInUse);
        expect(oldVault.readAsStringSync(), 'OLD VAULT BYTES\n');
        expect(target.existsSync(), isFalse);
      });

      test('staging and production never touch either folder', () async {
        if (!Platform.isLinux) return;
        for (final config in [staging, prod]) {
          final choice = await open(config);
          expect(choice.vault, isNotNull);
          expect((await choice.vault!.inspect()).access, VaultAccess.create);
          expect(choice.files, isNull, reason: 'no backup or export files');
          expect(oldVault.readAsStringSync(), 'OLD VAULT BYTES\n');
          expect(
            Directory('${data.path}/human-health-os').existsSync(),
            isFalse,
          );
        }
      });
    },
  );

  test(
    'relative HHOS_DATA_DIR: memory only, nothing written anywhere',
    () async {
      final before = Directory.current.listSync().length;
      final choice = await createPlatformRepository(
        dev,
        env: {'HHOS_DATA_DIR': 'relative-vault', 'HOME': tmp.path},
        executablePath: '${tmp.path}/bin/human_health_os',
      );
      expect(choice.reason, StorageReason.dataDirInvalid);
      expect(choice.files, isNull);
      expect(choice.detail, 'HHOS_DATA_DIR');
      expect(
        choice.repository.description.durability,
        StorageDurability.memoryOnly,
      );
      await choice.repository.open();
      expect(Directory('relative-vault').existsSync(), isFalse);
      expect(Directory.current.listSync().length, before);
    },
  );
}
