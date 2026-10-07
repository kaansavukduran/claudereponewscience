/// Everything the UI needs at startup, built once in `main()` and injected,
/// so widget tests can run the real app on an in-memory or temp-dir vault.
library;

import '../application/heartbeat_service.dart';
import '../config/app_config.dart';
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
}
