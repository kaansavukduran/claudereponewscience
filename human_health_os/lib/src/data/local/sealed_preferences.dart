/// Display preferences kept by builds with an encrypted vault (U018, G-62):
/// written only after the vault is open, sealed under the vault's key, so
/// nothing is written before the vault exists and nothing readable lands on
/// disk. Preferences hold no health data; they are sealed all the same,
/// because a language or font choice is still about the person.
library;

import 'dart:convert';

import '../../domain/settings/appearance.dart';
import 'vault_envelope.dart' show EncryptedLogSink;

class SealedAppearanceStore implements AppearanceStore {
  SealedAppearanceStore({
    required this.sink,
    required this.read,
    required this.write,
  });

  final EncryptedLogSink sink;

  /// The stored text, or null when there is none.
  final Future<String?> Function() read;

  /// Replaces the stored text (atomically where the medium allows).
  final Future<void> Function(String text) write;

  /// What [load] found: none stored, readable, or present but not usable
  /// (another vault's, damaged); an unusable file is left as it is.
  SealedPreferencesState state = SealedPreferencesState.unknown;

  @override
  bool get persistent => true;

  @override
  Future<AppearanceSettings> load() async {
    final String? text;
    try {
      text = await read();
    } catch (_) {
      state = SealedPreferencesState.unusable;
      return const AppearanceSettings();
    }
    if (text == null || text.isEmpty) {
      state = SealedPreferencesState.none;
      return const AppearanceSettings();
    }
    final json = sink.openPreferences(text);
    if (json == null) {
      state = SealedPreferencesState.unusable;
      return const AppearanceSettings();
    }
    try {
      final s = AppearanceSettings.fromJson(jsonDecode(json));
      state = SealedPreferencesState.readable;
      return s;
    } catch (_) {
      state = SealedPreferencesState.unusable;
      return const AppearanceSettings();
    }
  }

  @override
  Future<void> save(AppearanceSettings settings) =>
      write(sink.sealPreferences(jsonEncode(settings.toJson())));
}

enum SealedPreferencesState { unknown, none, readable, unusable }
