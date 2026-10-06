/// Everything the UI needs at startup, built once in `main()` and injected,
/// so widget tests can run the real app on an in-memory or temp-dir vault.
library;

import '../application/heartbeat_service.dart';
import '../config/app_config.dart';
import '../core/capabilities.dart';
import '../domain/ports/health_repository.dart';
import '../domain/profile/profile.dart';

class AppServices {
  const AppServices({
    required this.config,
    required this.registry,
    required this.heartbeat,
    required this.self,
    required this.storage,
    this.storageNotice,
    this.loadWarnings = const [],
  });

  final AppConfig config;
  final CapabilityRegistry registry;
  final HeartbeatService heartbeat;
  final Profile self;
  final StorageDescription storage;

  /// Why data is not saved durably (production guard, unsupported platform,
  /// unreadable vault). Shown to the user verbatim.
  final String? storageNotice;

  /// Recoverable problems found while opening the vault.
  final List<String> loadWarnings;
}
