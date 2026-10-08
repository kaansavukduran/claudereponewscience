/// Everything the UI needs at startup, built once in `main()` and injected,
/// so widget tests can run the real app on an in-memory or temp-dir vault.
library;

import 'package:flutter/foundation.dart';

import '../application/heartbeat_service.dart';
import '../config/app_config.dart';
import '../data/backup/data_files.dart';
import '../data/local/vault_envelope.dart' show KeyDeriver, deriveInline;
import '../core/capabilities.dart';
import '../domain/ports/health_repository.dart';
import '../domain/ports/storage_status.dart';
import '../domain/profile/profile.dart';

class AppServices {
  const AppServices({
    required this.config,
    required this.registry,
    required this.heartbeat,
    required this.self,
    required this.storage,
    this.storageReason,
    this.storageDetail,
    this.storageNotes = const [],
    this.loadWarnings = const [],
    this.dataFiles,
    this.makeBackup,
    this.lockStorage,
    this.restartRequired,
    this.checkpointSaved,
    this.deriveKey = deriveInline,
  });

  final AppConfig config;
  final CapabilityRegistry registry;
  final HeartbeatService heartbeat;
  final Profile self;
  final StorageDescription storage;

  /// Why data is or is not saved durably, as reported by the adapter; null
  /// when no adapter reported one (tests). The UI localizes it
  /// (`S.storageNotice`).
  final StorageReason? storageReason;

  /// Context for [storageReason] (a variable name or an error code).
  final String? storageDetail;

  /// Things the adapter did at startup (e.g. moved the data folder).
  final List<StorageNote> storageNotes;

  /// Saved entries skipped while opening the vault.
  final List<LoadWarning> loadWarnings;

  /// Backups and exports (F005); null when this build may not write them.
  final DataFiles? dataFiles;

  /// A backup bundle of the stored vault as it is now (plaintext log or
  /// encrypted envelope, byte for byte); null for a memory-only store.
  final Future<String> Function(DateTime now)? makeBackup;

  /// Opens encrypted backups (Argon2id; an isolate on native).
  final KeyDeriver deriveKey;

  /// Stops all writes in this session with a code (after a restore).
  final void Function(String code)? lockStorage;

  /// True once the vault file was replaced in this session: every screen
  /// must stop offering writes, backups and exports until a restart.
  final ValueNotifier<bool>? restartRequired;

  /// Where the upgrade checkpoint was saved in this session (a backup made
  /// before the first record of a newer schema); null until then (F007).
  final ValueNotifier<String?>? checkpointSaved;
}
