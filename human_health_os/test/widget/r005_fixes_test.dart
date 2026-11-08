// R005@v0.32: display-preference saves run one after another (the last
// change is kept, no two writes at once); a change made while a vault's
// preferences are read wins over the file; a vault id from a damaged file
// never shapes a backup name.
import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/appearance_scope.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/crypto/recovery_key.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/sealed_preferences.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';

import '../data/encrypted_vault_test.dart' show vaultOn;

/// A store whose saves take a while and can tell whether two overlap.
class SlowStore implements AppearanceStore {
  final saved = <AppearanceSettings>[];
  var running = 0;
  var overlapped = false;

  @override
  bool get persistent => true;

  @override
  Future<AppearanceSettings> load() async => const AppearanceSettings();

  @override
  Future<void> save(AppearanceSettings s) async {
    running++;
    if (running > 1) overlapped = true;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    saved.add(s);
    running--;
  }
}

void main() {
  test(
    'quick changes are saved one after another, the last one last',
    () async {
      final store = SlowStore();
      final c = AppearanceController(store);
      final a = c.update(const AppearanceSettings(theme: ThemeChoice.dark));
      final b = c.update(
        const AppearanceSettings(
          theme: ThemeChoice.dark,
          language: LanguageChoice.tr,
        ),
      );
      await Future.wait([a, b]);
      expect(store.overlapped, isFalse);
      expect(store.saved.last.language, LanguageChoice.tr);
      expect(c.value.language, LanguageChoice.tr);
      expect(c.saveFailed, isFalse);
    },
  );

  test('a failed save then a good one clears the flag', () async {
    final c = AppearanceController(FailOnce());
    await c.update(const AppearanceSettings(theme: ThemeChoice.dark));
    expect(c.saveFailed, isTrue);
    await c.update(const AppearanceSettings(theme: ThemeChoice.light));
    expect(c.saveFailed, isFalse);
  });

  test('a change made while the vault preferences are read wins', () async {
    final opened = await vaultOn(MemoryLogSink()).create(
      passphrase: 'Mavi-Kedi 7 Ağaç Lamba!',
      recoveryKey: newRecoveryKey(),
    );
    String? stored = opened.sink.sealPreferences(
      '{"language":"en","theme":"light"}',
    );
    final reading = Completer<void>();
    final prefs = SealedAppearanceStore(
      sink: opened.sink,
      read: () async {
        // The file as it was when reading began.
        final then = stored;
        await reading.future;
        return then;
      },
      write: (t) async => stored = t,
    );
    final c = AppearanceController(MemoryAppearanceStore());
    final adopting = c.adopt(prefs);
    await c.update(const AppearanceSettings(language: LanguageChoice.tr));
    reading.complete();
    await adopting;
    expect(c.value.language, LanguageChoice.tr);
    expect(opened.sink.openPreferences(stored!), contains('"tr"'));
  });

  test('without a change meanwhile the saved choices apply', () async {
    final opened = await vaultOn(MemoryLogSink()).create(
      passphrase: 'Mavi-Kedi 7 Ağaç Lamba!',
      recoveryKey: newRecoveryKey(),
    );
    final stored = opened.sink.sealPreferences('{"language":"tr"}');
    final prefs = SealedAppearanceStore(
      sink: opened.sink,
      read: () async => stored,
      write: (t) async {},
    );
    final c = AppearanceController(MemoryAppearanceStore());
    await c.adopt(prefs);
    expect(c.value.language, LanguageChoice.tr);
    expect(c.value.firstRunDone, isTrue);
  });

  test('backup names keep only letters, digits and dashes of the id', () {
    final t = DateTime.utc(2026, 11, 8, 12);
    expect(
      backupFileName('../a/b\\c', t),
      startsWith('human-os-backup-___a_b_c-'),
    );
    expect(backupFileName('../a/b\\c', t), isNot(contains('/')));
    expect(
      backupFileName('0123abcd-ffff', t),
      startsWith('human-os-backup-0123abcd-'),
    );
  });
}

class FailOnce implements AppearanceStore {
  var failed = false;

  @override
  bool get persistent => true;

  @override
  Future<AppearanceSettings> load() async => const AppearanceSettings();

  @override
  Future<void> save(AppearanceSettings s) async {
    if (!failed) {
      failed = true;
      throw StateError('disk full');
    }
  }
}
