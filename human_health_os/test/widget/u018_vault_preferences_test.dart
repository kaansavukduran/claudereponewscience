// U018@v0.32: builds with an encrypted vault keep language, theme and font
// in a file sealed under the vault's key beside it, written only after the
// vault is open; choices made in the introduction are kept when the vault is
// created; the next start applies them after unlock; another vault's or a
// damaged file is never used and is left as it is.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/appearance_scope.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/sealed_preferences.dart';
import 'package:human_health_os/src/domain/ports/storage_status.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';

import 'f006_vault_gate_test.dart'
    show Disk, cheap, createThroughGate, pass, prod, settle, tapKey, type;

/// The vault and its preferences file, shared across launches like a disk.
class PrefsDisk extends Disk {
  String? prefs;
  int writes = 0;
}

Future<VaultGate> gate(PrefsDisk disk) async {
  final vault = EncryptedVault(
    raw: disk.raw,
    location: 'test vault',
    newKdf: cheap,
    preferencesFor: (sink) => SealedAppearanceStore(
      sink: sink,
      read: () async => disk.prefs,
      write: (t) async {
        disk.writes++;
        disk.prefs = t;
      },
    ),
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
      preferences: o.preferences,
    ),
    memoryOnly: (reason, {detail}) async {
      final r = inMemoryRepository();
      await r.open();
      return servicesFor(prod, HostPlatform.linux, r, reason: reason);
    },
  );
}

Future<AppearanceController> launch(WidgetTester tester, PrefsDisk disk) async {
  tester.view.physicalSize = const Size(1280, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final c = AppearanceController(MemoryAppearanceStore());
  final g = await tester.runAsync(() => gate(disk));
  await tester.pumpWidget(
    HumanOsApp(gate: g, appearance: c, offerIntroBeforeNewVault: true),
  );
  await settle(tester);
  return c;
}

Future<void> unlock(WidgetTester tester) async {
  await type(tester, 'gate-passphrase', pass);
  await tapKey(tester, 'gate-unlock');
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await settle(tester);
}

void main() {
  testWidgets('Türkçe chosen in the introduction is sealed when the vault is '
      'created and applied after the next unlock', (tester) async {
    final disk = PrefsDisk();
    await launch(tester, disk);
    await tapKey(tester, 'first-next');
    await tapKey(tester, 'first-next');
    await tapKey(tester, 'first-language-tr');
    await tapKey(tester, 'first-next');
    expect(disk.prefs, isNull, reason: 'nothing before the vault exists');
    await createThroughGate(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await settle(tester);
    expect(disk.prefs, isNotNull);
    expect(disk.prefs, isNot(contains('"tr"')), reason: 'sealed');
    expect(disk.prefs, isNot(contains('language')));

    await tester.pumpWidget(const SizedBox());
    final again = await launch(tester, disk);
    expect(find.byKey(const ValueKey('screen-first-run')), findsNothing);
    expect(again.value.language, LanguageChoice.system);
    await unlock(tester);
    expect(again.value.language, LanguageChoice.tr);
    expect(find.text('Araçlar'), findsOneWidget);
  });

  testWidgets('a change in Settings after unlock is sealed too', (
    tester,
  ) async {
    final disk = PrefsDisk();
    final c = await launch(tester, disk);
    await tapKey(tester, 'first-skip');
    await createThroughGate(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await settle(tester);
    final before = disk.writes;
    await tester.runAsync(
      () => c.update(c.value.copyWith(theme: ThemeChoice.dark)),
    );
    expect(disk.writes, before + 1);
    expect(c.saveFailed, isFalse);
  });

  testWidgets('another vault\'s or a damaged file is not used and is left as '
      'it is', (tester) async {
    final other = PrefsDisk();
    await launch(tester, other);
    await tapKey(tester, 'first-skip');
    await createThroughGate(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await settle(tester);
    await tester.pumpWidget(const SizedBox());

    for (final foreign in [other.prefs!, '{"format":"x"}', 'not json']) {
      final disk = PrefsDisk();
      await launch(tester, disk);
      await tapKey(tester, 'first-skip');
      disk.prefs = foreign;
      final writes = disk.writes;
      await createThroughGate(tester);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await settle(tester);
      expect(disk.prefs, foreign, reason: 'left as it is');
      expect(disk.writes, writes);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
