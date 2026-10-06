/// Opens storage and the SELF profile. An unreadable vault is never
/// overwritten: the app falls back to memory and says so.
library;

import '../application/heartbeat_service.dart';
import '../config/app_config.dart';
import '../core/capabilities.dart';
import '../data/local/log_repository.dart';
import '../data/local/storage.dart';
import '../domain/ports/health_repository.dart';
import 'app_services.dart';

Future<AppServices> bootstrap(AppConfig config, HostPlatform platform) async {
  final choice = await createPlatformRepository(config);
  HealthRepository repo = choice.repository;
  String? notice = choice.notice;
  List<String> warnings = const [];
  try {
    warnings = (await repo.open()).warnings;
  } catch (e) {
    // Do not touch the unreadable vault; keep working in memory and explain.
    repo = inMemoryRepository();
    await repo.open();
    notice =
        'Your saved data could not be opened ($e). Nothing was changed on disk. '
        'New entries are kept in memory only until this is fixed.';
  }
  return servicesFor(
    config,
    platform,
    repo,
    notice: notice,
    warnings: warnings,
  );
}

/// Shared by [bootstrap] and tests: builds services around an opened repository.
Future<AppServices> servicesFor(
  AppConfig config,
  HostPlatform platform,
  HealthRepository repo, {
  String? notice,
  List<String> warnings = const [],
}) async {
  final heartbeat = HeartbeatService(repo);
  final self = await heartbeat.ensureSelfProfile();
  return AppServices(
    config: config,
    registry: CapabilityRegistry.forPlatform(
      platform,
      storage: repo.description,
    ),
    heartbeat: heartbeat,
    self: self,
    storage: repo.description,
    storageNotice: notice,
    loadWarnings: warnings,
  );
}
