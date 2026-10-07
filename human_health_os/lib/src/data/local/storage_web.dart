/// Browser storage adapter (SDK-only `dart:js_interop`, no extra package).
/// Browser storage can be evicted and is not an OS keychain; the UI says so.
library;

import 'dart:js_interop';

import '../../config/app_config.dart';
import '../../domain/ports/health_repository.dart';
import 'log_repository.dart';
import 'storage_status.dart';

export 'storage_status.dart';

@JS('localStorage')
external _Storage? get _localStorage;

extension type _Storage(JSObject _) implements JSObject {
  external JSString? getItem(JSString key);
  external void setItem(JSString key, JSString value);
}

const String browserVaultKey = 'hhos.vault.v1';

class _BrowserLogSink implements LogSink {
  _BrowserLogSink(this._storage);

  final _Storage _storage;

  @override
  Future<String?> read() async =>
      _storage.getItem(browserVaultKey.toJS)?.toDart;

  @override
  Future<void> create(String text) async =>
      _storage.setItem(browserVaultKey.toJS, '$text\n'.toJS);

  @override
  Future<void> appendLine(String line) async {
    final current = _storage.getItem(browserVaultKey.toJS)?.toDart ?? '';
    _storage.setItem(browserVaultKey.toJS, '$current$line\n'.toJS);
  }
}

Future<StorageChoice> createPlatformRepository(AppConfig config) async {
  final gated = profileGate(config);
  if (gated != null) return gated;
  _Storage? storage;
  try {
    storage = _localStorage;
    storage?.getItem('hhos.probe'.toJS);
  } catch (_) {
    storage = null;
  }
  if (storage == null) {
    return StorageChoice(
      inMemoryRepository(),
      reason: StorageReason.browserBlocked,
    );
  }
  return StorageChoice(
    LogRepository(
      sink: _BrowserLogSink(storage),
      durability: StorageDurability.browserStorage,
      location: 'browser storage ($browserVaultKey)',
    ),
  );
}
