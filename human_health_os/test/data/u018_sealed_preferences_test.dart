// U018@v0.32: preferences sealed beside a real vault file: no file before
// the first save, written through a temporary file, unreadable as text,
// opened only by the same vault (also after unlocking again).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/data/crypto/recovery_key.dart';
import 'package:human_health_os/src/data/local/sealed_preferences.dart';
import 'package:human_health_os/src/data/local/storage_io.dart';
import 'package:human_health_os/src/data/local/vault_envelope.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';

import 'encrypted_vault_test.dart' show vaultOn;

const pass = 'Mavi-Kedi 7 Ağaç Lamba!';

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('u018'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('round trip beside the vault, sealed, same vault only', () async {
    final vaultFile = File(
      '${tmp.path}${Platform.pathSeparator}vault.hhosvault',
    );
    final v = vaultOn(FileLogSink(vaultFile));
    final opened = await v.create(
      passphrase: pass,
      recoveryKey: newRecoveryKey(),
    );
    final store = sealedPreferencesBeside(vaultFile, opened.sink);
    expect(await store.load(), const AppearanceSettings());
    expect(store.state, SealedPreferencesState.none);
    final prefsFile = File('${vaultFile.path}.prefs');
    expect(prefsFile.existsSync(), isFalse);

    const chosen = AppearanceSettings(
      language: LanguageChoice.tr,
      font: FontChoice.dyslexic,
    );
    await store.save(chosen);
    expect(prefsFile.existsSync(), isTrue);
    expect(File('${prefsFile.path}.tmp').existsSync(), isFalse);
    final text = prefsFile.readAsStringSync();
    expect(text, isNot(contains('dyslexic')));
    expect(text, isNot(contains('"tr"')));

    // Unlocked again: the same vault opens them.
    final again = await EncryptedLogSink.unlock(
      FileLogSink(vaultFile),
      pass,
      kind: KeyKind.passphrase,
      derive: deriveInline,
    );
    final reopened = sealedPreferencesBeside(vaultFile, again);
    expect(await reopened.load(), chosen);
    expect(reopened.state, SealedPreferencesState.readable);

    // Another vault cannot.
    final otherFile = File(
      '${tmp.path}${Platform.pathSeparator}other.hhosvault',
    );
    final other = await vaultOn(FileLogSink(otherFile))
        .create(passphrase: pass, recoveryKey: newRecoveryKey());
    expect(other.sink.openPreferences(text), isNull);

    // A changed byte is not authentic.
    final flipped = text.replaceFirst(RegExp(r'"c":"(.)'), '"c":"A');
    final tampered = flipped == text
        ? text.replaceFirst(RegExp(r'"c":"(.)'), '"c":"B')
        : flipped;
    expect(again.openPreferences(tampered), isNull);
  });
}
