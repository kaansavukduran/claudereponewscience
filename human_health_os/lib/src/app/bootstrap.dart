/// Opens storage and the SELF profile. An unreadable vault is never
/// overwritten: the app falls back to memory and says so.
library;

import '../application/heartbeat_service.dart';
import '../config/app_config.dart';
import '../core/capabilities.dart';
import '../data/backup/data_files.dart';
import '../data/local/log_repository.dart';
import '../data/local/storage.dart';
import '../data/local/vault_log.dart' show VaultFormatError;
import '../domain/ports/health_repository.dart';
import 'app_services.dart';

Future<AppServices> bootstrap(AppConfig config, HostPlatform platform) async {
  final choice = await createPlatformRepository(config);
  HealthRepository repo = choice.repository;
  var reason = choice.reason;
  var detail = choice.detail;
  var report = const LoadReport(warnings: []);
  try {
    report = await repo.open();
    if (report.readOnly) reason = StorageReason.vaultReadOnly;
  } catch (e) {
    // Do not touch the unreadable vault; keep working in memory and explain.
    repo = inMemoryRepository();
    await repo.open();
    reason = StorageReason.vaultUnreadable;
    detail = e is VaultFormatError ? e.code : e.runtimeType.toString();
  }
  if (!repo.writable && (await repo.profiles()).isEmpty) {
    // A read-only vault without a SELF profile has nothing to show and
    // cannot create one; keep its file untouched and work in memory.
    repo = inMemoryRepository();
    await repo.open();
  }
  return servicesFor(
    config,
    platform,
    repo,
    reason: reason,
    detail: detail,
    notes: choice.notes,
    report: report,
    files: choice.files,
  );
}

/// Shared by [bootstrap] and tests: builds services around an opened repository.
Future<AppServices> servicesFor(
  AppConfig config,
  HostPlatform platform,
  HealthRepository repo, {
  StorageReason? reason,
  String? detail,
  List<StorageNote> notes = const [],
  LoadReport report = const LoadReport(warnings: []),
  DataFiles? files,
}) async {
  final heartbeat = HeartbeatService(repo);
  final self = await heartbeat.ensureSelfProfile();
  // Tests that hand in a repository without a reason get "not reported"
  // (null) for a memory store, never an invented cause.
  final status =
      reason ??
      (repo.description.durability == StorageDurability.memoryOnly
          ? null
          : StorageReason.saving);
  return AppServices(
    config: config,
    registry: CapabilityRegistry.forPlatform(
      platform,
      storage: repo.description,
      reason: status,
    ),
    heartbeat: heartbeat,
    self: self,
    storage: repo.description,
    storageReason: status,
    storageDetail: detail,
    storageNotes: notes,
    loadWarnings: report.warnings,
    // Files stay available when the vault could not be opened: restoring a
    // backup is the way back. A backup copies the persisted log, so a memory
    // store offers none.
    dataFiles: files,
    readVaultText:
        repo is LogRepository &&
            repo.description.durability != StorageDurability.memoryOnly
        ? repo.sink.read
        : null,
    lockStorage: repo is LogRepository ? repo.lock : null,
  );
}
