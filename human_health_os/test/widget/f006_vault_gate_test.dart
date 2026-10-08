// F006@v0.32 vault gate (AC-4, AC-5, AC-6 UI): the screens a staging,
// production or portable build shows before anything is saved: create with
// a recovery key shown once, unlock, wrong passphrase, recovery, key lost
// (no false promises; the locked file is kept), unreadable, memory only;
// and the Your data card of an encrypted vault.
import 'dart:io' show FileSystemException;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/vault_envelope.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/ports/storage_status.dart';

const prod = AppConfig(
  profile: BuildProfile.production,
  version: '0.1.0+1',
  sourceRevision: 'test',
);
const dev = AppConfig(
  profile: BuildProfile.development,
  version: '0.1.0+1',
  sourceRevision: 'test',
);
const pass = 'Mavi-Kedi 7 Ağaç Lamba!';

KdfParams cheap() =>
    KdfParams(salt: randomBytes(16), memoryKib: 64, iterations: 1);

/// Backups kept in memory whose "live vault" is the gate's raw store.
class LinkedFiles extends MemoryDataFiles {
  LinkedFiles(this.raw, EncryptedLogSink sink)
    : super(target: RestoreTarget.encrypted(sink.open));

  final MemoryLogSink raw;

  @override
  String? get vaultText => raw.text;

  @override
  set vaultText(String? v) => raw.text = v;
}

/// Shared across "launches" of one test, like a disk.
class Disk {
  Disk([MemoryLogSink? raw]) : raw = raw ?? MemoryLogSink();

  final MemoryLogSink raw;
  final backups = <String, String>{};
  String? keptAside;
}

/// A vault file another program holds: reads fail while [fail] is on.
class HeldRaw extends MemoryLogSink {
  bool fail = false;

  @override
  Future<String?> read() async {
    if (fail) throw const FileSystemException('held by another program');
    return super.read();
  }
}

/// A full disk: appends fail while [fail] is on; a whole new file still
/// lands (it is written before the first append).
class FullRaw extends MemoryLogSink {
  bool fail = false;

  @override
  Future<void> appendLine(String line) async {
    if (fail) throw const FileSystemException('no space left on device');
    return super.appendLine(line);
  }
}

/// The medium drops right after the vault is written (a removable disk):
/// reads and appends fail while [dropped] is on.
class DroppingRaw extends MemoryLogSink {
  bool dropAfterCreate = false;
  bool dropped = false;

  @override
  Future<void> create(String header) async {
    await super.create(header);
    if (dropAfterCreate) dropped = true;
  }

  @override
  Future<String?> read() async {
    if (dropped) throw const FileSystemException('device gone');
    return super.read();
  }

  @override
  Future<void> appendLine(String line) async {
    if (dropped) throw const FileSystemException('device gone');
    return super.appendLine(line);
  }
}

/// Like the isolate on native builds: the key arrives a few frames later,
/// so the gate really shows its busy state in between.
Future<Uint8List> slowDerive(String secret, KdfParams p) async {
  await Future<void>.delayed(const Duration(milliseconds: 120));
  return deriveKey(secret, p);
}

Future<VaultGate> gateOn(Disk disk, {KeyDeriver derive = deriveInline}) async {
  final vault = EncryptedVault(
    raw: disk.raw,
    location: 'test vault',
    newKdf: cheap,
    derive: derive,
    setAsideStore: (now) async {
      disk.keptAside = disk.raw.text;
      disk.raw.text = null;
      return 'test vault.locked';
    },
    filesFor: (sink) {
      final f = LinkedFiles(disk.raw, sink);
      for (final b in disk.backups.entries) {
        f.files[b.key] = b.value;
        f.times[b.key] = DateTime.utc(2026, 10, 7);
      }
      return f;
    },
  );
  return VaultGate(
    vault: vault,
    inspection: await vault.inspect(),
    open: (o) => servicesFor(
      prod,
      HostPlatform.linux,
      o.repository,
      reason: StorageReason.saving,
      report: o.report,
      files: o.files,
    ),
    memoryOnly: (reason, {detail}) async {
      final r = inMemoryRepository();
      await r.open();
      return servicesFor(
        prod,
        HostPlatform.linux,
        r,
        reason: reason,
        detail: detail,
      );
    },
  );
}

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

Future<void> launch(
  WidgetTester tester,
  Disk disk, {
  Locale? locale,
  KeyDeriver derive = deriveInline,
}) async {
  tester.view.physicalSize = const Size(1280, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final gate = await tester.runAsync(() => gateOn(disk, derive: derive));
  await tester.pumpWidget(HumanOsApp(gate: gate));
  await settle(tester);
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.tap(f);
  await settle(tester);
}

Future<void> type(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(ValueKey(key)), text);
  await tester.pump();
}

String textOf(WidgetTester tester, String key) {
  final w = tester.widget(find.byKey(ValueKey(key)));
  return w is Text ? w.data! : (w as SelectableText).data!;
}

/// Creates a vault through the screens; returns the recovery key shown.
Future<String> createThroughGate(WidgetTester tester) async {
  await type(tester, 'gate-passphrase', pass);
  await type(tester, 'gate-passphrase-confirm', pass);
  await tapKey(tester, 'gate-continue');
  final key = textOf(tester, 'gate-recovery-key');
  await tapKey(tester, 'gate-key-written');
  await tapKey(tester, 'gate-create-vault');
  return key;
}

/// The latest weight shown on Today.
String latest(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('weight-latest'))).data!;

Future<void> saveWeight(WidgetTester tester, String kg) async {
  await type(tester, 'weight-input', kg);
  await tapKey(tester, 'weight-save');
}

void main() {
  testWidgets('NO_VAULT: passphrase rules, a recovery key shown once and '
      'confirmed, then an encrypted vault holding the first entry', (
    tester,
  ) async {
    final disk = Disk();
    await launch(tester, disk);
    expect(find.byKey(const ValueKey('vault-gate-create')), findsOneWidget);
    expect(find.byKey(const ValueKey('gate-memory-only')), findsOneWidget);

    await type(tester, 'gate-passphrase', 'too short');
    await type(tester, 'gate-passphrase-confirm', 'too short');
    await tapKey(tester, 'gate-continue');
    expect(textOf(tester, 'gate-error'), 'Use at least 12 characters.');
    await type(tester, 'gate-passphrase', pass);
    await type(tester, 'gate-passphrase-confirm', '${pass}x');
    await tapKey(tester, 'gate-continue');
    expect(textOf(tester, 'gate-error'), 'The two passphrases differ.');
    expect(disk.raw.text, isNull, reason: 'nothing written yet');

    await type(tester, 'gate-passphrase', pass);
    await type(tester, 'gate-passphrase-confirm', pass);
    await tapKey(tester, 'gate-continue');
    final first = textOf(tester, 'gate-recovery-key');
    expect(first, matches(RegExp(r'^([A-Z2-7]{4}-){7}[A-Z2-7]{4}$')));
    final create = find.byKey(const ValueKey('gate-create-vault'));
    expect(
      tester.widget<FilledButton>(create).onPressed,
      isNull,
      reason: 'not before the key is written down',
    );
    // Going back discards the key; a new one is made next time.
    await tapKey(tester, 'gate-back');
    await type(tester, 'gate-passphrase', pass);
    await type(tester, 'gate-passphrase-confirm', pass);
    await tapKey(tester, 'gate-continue');
    expect(textOf(tester, 'gate-recovery-key'), isNot(first));
    expect(disk.raw.text, isNull);

    await tapKey(tester, 'gate-key-written');
    await tapKey(tester, 'gate-create-vault');
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    expect(find.textContaining('· encrypted'), findsWidgets);
    await saveWeight(tester, '73,6');
    expect(detectStoredVault(disk.raw.text), StoredVaultKind.encrypted);
    expect(disk.raw.text, isNot(contains(pass)));
    // Only strings that cannot occur by chance in base64, hex or the JSON
    // frame: a two-digit "73" appears in random ciphertext about every
    // other run (found as an intermittent failure).
    expect(disk.raw.text, isNot(contains('73,6')));
    expect(disk.raw.text, isNot(contains('73.6')));
    expect(disk.raw.text, isNot(contains('body.weight')));
  });

  testWidgets('LOCKED -> WRONG_PASSPHRASE -> unlocked: the saved weight is '
      'back after a relaunch', (tester) async {
    final disk = Disk();
    await launch(tester, disk);
    await createThroughGate(tester);
    await saveWeight(tester, '73,6');

    await launch(tester, disk, derive: slowDerive); // relaunch
    expect(find.byKey(const ValueKey('vault-gate-unlock')), findsOneWidget);
    final before = disk.raw.text;
    final events = <String>[];
    final previous = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => events.add('$m');
    try {
      await type(tester, 'gate-passphrase', 'not the passphrase');
      await tapKey(tester, 'gate-unlock');
    } finally {
      debugPrint = previous;
    }
    expect(events, [
      '[hhos] vault_unlock_failed error=CryptoFailure(NOT_AUTHENTIC)',
    ], reason: 'the redacted event, nothing else');
    expect(textOf(tester, 'gate-error'), contains('did not open the vault'));
    expect(find.byKey(const ValueKey('vault-gate-unlock')), findsOneWidget);
    expect(disk.raw.text, before, reason: 'a failed unlock writes nothing');
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('gate-passphrase')),
    );
    expect(field.controller!.text, isEmpty, reason: 'cleared for a new try');
    final editable = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('gate-passphrase')),
        matching: find.byType(EditableText),
      ),
    );
    expect(
      editable.focusNode.hasFocus,
      isTrue,
      reason: 'still focused: the user can type again at once',
    );
    events.clear();
    debugPrint = (String? m, {int? wrapWidth}) => events.add('$m');
    try {
      await type(tester, 'gate-passphrase', pass);
      await tapKey(tester, 'gate-unlock');
    } finally {
      debugPrint = previous;
    }
    expect(events, ['[hhos] vault_unlocked warnings=0']);
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    expect(latest(tester), '73.6 kg');
  });

  testWidgets('the key is right but the log inside cannot be used: explained '
      'as unreadable, never overwritten; a damaged log may be set aside, data '
      'from a newer app never', (tester) async {
    // A vault whose sealed log header (entry 0) was removed.
    final damaged = Disk();
    await tester.runAsync(() async {
      final g = await gateOn(damaged);
      await g.vault.create(
        passphrase: pass,
        recoveryKey: newRecoveryKeyForTest,
      );
    });
    final ls = damaged.raw.text!.split('\n')..removeAt(1);
    damaged.raw.text = ls.join('\n');
    final stored = damaged.raw.text;
    await launch(tester, damaged);
    await type(tester, 'gate-passphrase', pass);
    await tapKey(tester, 'gate-unlock');
    expect(find.byKey(const ValueKey('vault-gate-unreadable')), findsOneWidget);
    expect(
      textOf(tester, 'gate-unreadable-body'),
      contains('VAULT_HEADER_UNREADABLE'),
    );
    expect(find.byKey(const ValueKey('gate-start-new')), findsOneWidget);
    expect(damaged.raw.text, stored);

    // A vault whose log was written by a newer app (format 2 inside).
    final newer = Disk();
    await tester.runAsync(() async {
      final sink = EncryptedLogSink.forNewVault(
        newer.raw,
        passphrase: pass,
        recoveryKey: newRecoveryKeyForTest,
        derive: deriveInline,
        newKdf: cheap,
      );
      await sink.create(
        '{"format":"hhos-vault-log","format_version":2,"vault_id":"v-newer",'
        '"created_at":"2026-10-01T00:00:00.000Z",'
        '"encryption":"hhos-vault-enc-v1"}',
      );
    });
    final newerStored = newer.raw.text;
    await launch(tester, newer);
    await type(tester, 'gate-passphrase', pass);
    await tapKey(tester, 'gate-unlock');
    expect(find.byKey(const ValueKey('vault-gate-unreadable')), findsOneWidget);
    expect(textOf(tester, 'gate-unreadable-body'), contains('newer version'));
    expect(find.byKey(const ValueKey('gate-start-new')), findsNothing);
    await tapKey(tester, 'gate-memory-only');
    expect(find.textContaining('written by a newer version'), findsOneWidget);
    expect(newer.raw.text, newerStored);
  });

  testWidgets('RECOVERY: wrong and malformed keys are refused; the right key '
      'sets a new passphrase; the old one stops working', (tester) async {
    final disk = Disk();
    await launch(tester, disk);
    final key = await createThroughGate(tester);
    await saveWeight(tester, '80');

    await launch(tester, disk);
    await tapKey(tester, 'gate-use-recovery');
    expect(find.byKey(const ValueKey('vault-gate-recover')), findsOneWidget);
    await type(tester, 'gate-recovery-input', 'AAAA-AAAA');
    await type(tester, 'gate-passphrase', 'yeni uzun parola 2026');
    await type(tester, 'gate-passphrase-confirm', 'yeni uzun parola 2026');
    await tapKey(tester, 'gate-recover');
    expect(textOf(tester, 'gate-error'), contains('32 letters and digits'));
    await type(
      tester,
      'gate-recovery-input',
      'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4567',
    );
    await tapKey(tester, 'gate-recover');
    expect(textOf(tester, 'gate-error'), contains('did not open the vault'));
    await type(tester, 'gate-recovery-input', key.toLowerCase());
    await tapKey(tester, 'gate-recover');
    expect(latest(tester), '80 kg');

    await launch(tester, disk);
    await type(tester, 'gate-passphrase', pass);
    await tapKey(tester, 'gate-unlock');
    expect(find.byKey(const ValueKey('gate-error')), findsOneWidget);
    await type(tester, 'gate-passphrase', 'yeni uzun parola 2026');
    await tapKey(tester, 'gate-unlock');
    expect(latest(tester), '80 kg');
  });

  testWidgets('KEY_LOST: an honest explanation; starting over keeps the locked '
      'vault aside, never deletes it', (tester) async {
    final disk = Disk();
    await launch(tester, disk);
    await createThroughGate(tester);
    await saveWeight(tester, '80');
    final locked = disk.raw.text;

    await launch(tester, disk);
    await tapKey(tester, 'gate-use-recovery');
    await tapKey(tester, 'gate-lost-both');
    expect(find.byKey(const ValueKey('vault-gate-keyLost')), findsOneWidget);
    expect(find.textContaining('nobody can open it'), findsOneWidget);
    expect(
      find.textContaining('will not open it, reset it or delete it'),
      findsOneWidget,
    );
    await tapKey(tester, 'gate-start-new');
    await tapKey(tester, 'confirm-start-new');
    expect(disk.keptAside, locked, reason: 'kept byte for byte');
    expect(find.byKey(const ValueKey('vault-gate-create')), findsOneWidget);
    expect(textOf(tester, 'gate-kept-at'), contains('test vault.locked'));
  });

  testWidgets('memory only while a vault exists: it stays locked and '
      'untouched, and Today says so', (tester) async {
    final disk = Disk();
    await launch(tester, disk);
    await createThroughGate(tester);
    final stored = disk.raw.text;
    await launch(tester, disk);
    await tapKey(tester, 'gate-memory-only');
    expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    expect(
      find.textContaining('Your encrypted vault stays locked and untouched'),
      findsOneWidget,
    );
    await saveWeight(tester, '70');
    expect(disk.raw.text, stored);
  });

  testWidgets('UNREADABLE: a vault from a newer app is explained, never set '
      'aside, and the session runs in memory', (tester) async {
    final disk = Disk()
      ..raw.text =
          '{"format":"hhos-vault-enc","envelope_version":9,"vault_id":"x"}\n';
    await launch(tester, disk);
    expect(find.byKey(const ValueKey('vault-gate-unreadable')), findsOneWidget);
    expect(textOf(tester, 'gate-unreadable-body'), contains('newer version'));
    expect(find.byKey(const ValueKey('gate-start-new')), findsNothing);
    await tapKey(tester, 'gate-memory-only');
    expect(find.textContaining('written by a newer version'), findsOneWidget);
    expect(disk.raw.text, contains('"envelope_version":9'));
  });

  testWidgets('the gate speaks Turkish', (tester) async {
    await launch(tester, Disk(), locale: const Locale('tr'));
    expect(find.text('Sağlık verilerini koru'), findsOneWidget);
    expect(
      find.text('Şimdi değil: bu oturumu yalnız bellekte tut'),
      findsOneWidget,
    );
  });

  testWidgets('Your data on an encrypted vault: encrypted backups, no '
      'plaintext export, restore only with the backup key and never over '
      'records', (tester) async {
    final disk = Disk();
    await launch(tester, disk);
    await createThroughGate(tester);
    await saveWeight(tester, '80');
    expect(
      find.text(
        'Backups are encrypted like the vault: each opens only with the '
        'passphrase or recovery key the vault had when it was made.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('export-json')), findsNothing);
    expect(
      find.byKey(const ValueKey('export-not-for-encrypted')),
      findsOneWidget,
    );

    await tapKey(tester, 'create-backup');
    expect(find.byKey(const ValueKey('no-backups')), findsNothing);
    final backupKey = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('check-'),
    );
    await tester.tap(backupKey.first);
    await settle(tester);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('data-message'))).data,
      contains('encrypted; 1 records according to its description'),
    );

    // Restoring over the live records is refused, after the key is checked.
    final restore = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('restore-'),
    );
    await tester.tap(restore.first);
    await settle(tester);
    await tapKey(tester, 'confirm-restore');
    await tester.enterText(
      find.byKey(const ValueKey('backup-secret')),
      'wrong one!',
    );
    await tapKey(tester, 'confirm-open-backup');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('data-message'))).data,
      contains('does not open the backup'),
    );
    await tester.tap(restore.first);
    await settle(tester);
    await tapKey(tester, 'confirm-restore');
    await tester.enterText(find.byKey(const ValueKey('backup-secret')), pass);
    await tapKey(tester, 'confirm-open-backup');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('data-message'))).data,
      contains('already holds records'),
    );
  });

  testWidgets('restore drill through the screens: a new, empty vault takes '
      "an encrypted backup with the backup's passphrase; after a restart that "
      'passphrase opens the restored records', (tester) async {
    // The lost device's vault and its backup (passphrase A).
    final old = Disk();
    final made = await tester.runAsync(() async {
      final g = await gateOn(old);
      final s = await g.open(
        await g.vault.create(
          passphrase: 'passphrase of the old vault',
          recoveryKey: newRecoveryKeyForTest,
        ),
      );
      await s.heartbeat.recordWeightKg(profileId: s.self.id, input: '81,5');
      return s.makeBackup!(DateTime.utc(2026, 10, 6));
    });

    final disk = Disk()
      ..backups['backup/human-os-backup-old-20261006T000000Z.hhosbackup.json'] =
          made!;
    await launch(tester, disk);
    await createThroughGate(tester); // the new device: passphrase B
    final restore = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('restore-'),
    );
    await tester.ensureVisible(restore.first);
    await tester.tap(restore.first);
    await settle(tester);
    await tapKey(tester, 'confirm-restore');
    await tester.enterText(
      find.byKey(const ValueKey('backup-secret')),
      'passphrase of the old vault',
    );
    await tapKey(tester, 'confirm-open-backup');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('data-message'))).data,
      startsWith(
        'Restored 1 records. Close and reopen Human OS, then unlock it with '
        "the backup's passphrase or recovery key.",
      ),
    );
    expect(
      tester
          .widget<ButtonStyleButton>(
            find.byKey(const ValueKey('create-backup')),
          )
          .enabled,
      isFalse,
      reason: 'paused until a restart',
    );

    await launch(tester, disk);
    await type(tester, 'gate-passphrase', pass);
    await tapKey(tester, 'gate-unlock');
    expect(
      find.byKey(const ValueKey('gate-error')),
      findsOneWidget,
      reason: 'the new vault was replaced by the restored one',
    );
    await type(tester, 'gate-passphrase', 'passphrase of the old vault');
    await tapKey(tester, 'gate-unlock');
    expect(latest(tester), '81.5 kg');
  });

  test('servicesFor: an encrypted repository makes encrypted backups, a '
      'memory store none', () async {
    final disk = Disk();
    final gate = await gateOn(disk);
    final s = await gate.open(
      await gate.vault.create(
        passphrase: pass,
        recoveryKey: newRecoveryKeyForTest,
      ),
    );
    expect(s.storage.encrypted, isTrue);
    final bundle = await s.makeBackup!(DateTime.utc(2026, 10, 7));
    expect(bundle, contains('"encryption": "hhos-vault-enc-v1"'));
    final mem = await gate.memoryOnly(StorageReason.sessionOnly);
    expect(mem.makeBackup, isNull);
    expect(mem.dataFiles, isNull);
    expect(mem.storageReason, StorageReason.sessionOnly);
  });

  group('review fixes (F006)', () {
    testWidgets('UNREADABLE: a vault file that cannot be read now (held by '
        'another program) is explained, kept in place and never set aside', (
      tester,
    ) async {
      final raw = HeldRaw();
      final disk = Disk(raw);
      await launch(tester, disk);
      await createThroughGate(tester);
      final stored = raw.text;
      raw.fail = true;
      await launch(tester, disk);
      expect(
        find.byKey(const ValueKey('vault-gate-unreadable')),
        findsOneWidget,
      );
      expect(
        textOf(tester, 'gate-unreadable-body'),
        startsWith('The vault file could not be read'),
      );
      expect(find.byKey(const ValueKey('gate-start-new')), findsNothing);
      await tapKey(tester, 'gate-memory-only');
      expect(
        find.textContaining('could not be opened (VAULT_READ_FAILED)'),
        findsOneWidget,
      );
      expect(disk.keptAside, isNull);
      expect(raw.text, stored);
    });

    testWidgets('NO_VAULT: when the new vault was written but could not be '
        'opened, the gate never says nothing changed; the passphrase just '
        'chosen opens it', (tester) async {
      final raw = FullRaw()..fail = true;
      final disk = Disk(raw);
      await launch(tester, disk);
      final events = <String>[];
      final previous = debugPrint;
      debugPrint = (String? m, {int? wrapWidth}) => events.add('$m');
      try {
        await createThroughGate(tester);
      } finally {
        debugPrint = previous;
      }
      expect(events.single, startsWith('[hhos] vault_create_failed error='));
      expect(find.byKey(const ValueKey('vault-gate-unlock')), findsOneWidget);
      expect(
        textOf(tester, 'gate-error'),
        startsWith('The vault was created, but it could not be opened'),
      );
      expect(textOf(tester, 'gate-error'), isNot(contains('Nothing')));
      expect(detectStoredVault(raw.text), StoredVaultKind.encrypted);

      raw.fail = false;
      await type(tester, 'gate-passphrase', pass);
      await tapKey(tester, 'gate-unlock');
      expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
      await saveWeight(tester, '72');
      expect(latest(tester), '72 kg');
    });

    testWidgets('NO_VAULT: written, then the medium dropped so it cannot be '
        'read back: the gate still says it was created (fix-round finding)', (
      tester,
    ) async {
      final raw = DroppingRaw()..dropAfterCreate = true;
      await launch(tester, Disk(raw));
      await createThroughGate(tester);
      expect(find.byKey(const ValueKey('vault-gate-unlock')), findsOneWidget);
      expect(
        textOf(tester, 'gate-error'),
        startsWith('The vault was created, but it could not be opened'),
      );
      raw.dropped = false;
      await type(tester, 'gate-passphrase', pass);
      await tapKey(tester, 'gate-unlock');
      expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    });

    testWidgets('RECOVERY: the new passphrase was stored, then opening failed: '
        'the gate says so, never "nothing changed", and the new passphrase '
        'opens the vault (fix-round finding)', (tester) async {
      final raw = FullRaw();
      final disk = Disk(raw);
      await tester.runAsync(() async {
        // A vault without its own profile yet: opening the app appends one.
        final g = await gateOn(disk);
        await g.vault.create(
          passphrase: pass,
          recoveryKey: newRecoveryKeyForTest,
        );
      });
      raw.fail = true;
      await launch(tester, disk);
      await tapKey(tester, 'gate-use-recovery');
      await type(tester, 'gate-recovery-input', newRecoveryKeyForTest);
      await type(tester, 'gate-passphrase', 'yeni uzun parola 2026');
      await type(tester, 'gate-passphrase-confirm', 'yeni uzun parola 2026');
      await tapKey(tester, 'gate-recover');
      expect(find.byKey(const ValueKey('vault-gate-unlock')), findsOneWidget);
      expect(
        textOf(tester, 'gate-error'),
        startsWith(
          'The new passphrase is set, but the vault could not be '
          'opened',
        ),
      );
      raw.fail = false;
      await type(tester, 'gate-passphrase', 'yeni uzun parola 2026');
      await tapKey(tester, 'gate-unlock');
      expect(find.byKey(const ValueKey('screen-today')), findsOneWidget);
    });

    testWidgets('RECOVERY on a vault from a newer app: explained as '
        'unreadable before the new passphrase is written; the file and its '
        'old passphrase are unchanged', (tester) async {
      final newer = Disk();
      await tester.runAsync(() async {
        final sink = EncryptedLogSink.forNewVault(
          newer.raw,
          passphrase: pass,
          recoveryKey: newRecoveryKeyForTest,
          derive: deriveInline,
          newKdf: cheap,
        );
        await sink.create(
          '{"format":"hhos-vault-log","format_version":2,"vault_id":"v-newer",'
          '"created_at":"2026-10-01T00:00:00.000Z",'
          '"encryption":"hhos-vault-enc-v1"}',
        );
      });
      final stored = newer.raw.text;
      await launch(tester, newer);
      await tapKey(tester, 'gate-use-recovery');
      await type(tester, 'gate-recovery-input', newRecoveryKeyForTest);
      await type(tester, 'gate-passphrase', 'yeni uzun parola 2026');
      await type(tester, 'gate-passphrase-confirm', 'yeni uzun parola 2026');
      await tapKey(tester, 'gate-recover');
      expect(
        find.byKey(const ValueKey('vault-gate-unreadable')),
        findsOneWidget,
      );
      expect(textOf(tester, 'gate-unreadable-body'), contains('newer version'));
      expect(newer.raw.text, stored, reason: 'no new passphrase written');
    });

    testWidgets('a development vault refuses an encrypted backup before '
        'asking for its key, and writes nothing', (tester) async {
      final old = Disk();
      final made = await tester.runAsync(() async {
        final g = await gateOn(old);
        final s = await g.open(
          await g.vault.create(
            passphrase: pass,
            recoveryKey: newRecoveryKeyForTest,
          ),
        );
        await s.heartbeat.recordWeightKg(profileId: s.self.id, input: '81');
        return s.makeBackup!(DateTime.utc(2026, 10, 6));
      });
      const name = 'human-os-backup-old-20261006T000000Z.hhosbackup.json';
      final files = MemoryDataFiles()
        ..files['backup/$name'] = made!
        ..times['backup/$name'] = DateTime.utc(2026, 10, 6);
      tester.view.physicalSize = const Size(1280, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final services = await tester.runAsync(() async {
        final repo = LogRepository(
          sink: MemoryLogSink(),
          durability: StorageDurability.localFile,
          location: 'test',
        );
        final report = await repo.open();
        return servicesFor(
          dev,
          HostPlatform.linux,
          repo,
          report: report,
          files: files,
        );
      });
      await tester.pumpWidget(HumanOsApp(services: services!));
      await settle(tester);
      await tapKey(tester, 'restore-$name');
      await tapKey(tester, 'confirm-restore');
      expect(
        find.byKey(const ValueKey('backup-secret')),
        findsNothing,
        reason: 'no key is asked for',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('data-message'))).data,
        startsWith('This backup and this vault are not the same kind'),
      );
      expect(files.vaultText, isNull);
      expect(files.kept, isNull);
    });
  });
}

const newRecoveryKeyForTest = 'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4567';
