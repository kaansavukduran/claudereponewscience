/// Opens storage and the SELF profile. An unreadable vault is never
/// overwritten: the app falls back to memory and says so. Staging,
/// production and portable builds start at the vault gate (F006): nothing
/// is saved until the encrypted vault is created or unlocked.
library;

import 'package:flutter/foundation.dart';

import '../application/heartbeat_service.dart';
import '../config/app_config.dart';
import '../core/capabilities.dart';
import '../core/redact.dart' show errorCode;
import '../data/backup/backup_bundle.dart';
import '../data/backup/data_files.dart';
import '../data/local/encrypted_vault.dart';
import '../data/local/log_repository.dart';
import '../data/local/storage.dart';
import '../data/local/vault_envelope.dart';
import '../domain/ports/health_repository.dart';
import 'app_services.dart';

/// What `main()` shows first: the app, or the vault gate.
class AppStartup {
  const AppStartup.ready(AppServices this.services) : gate = null;
  const AppStartup.gate(VaultGate this.gate) : services = null;

  final AppServices? services;
  final VaultGate? gate;
}

/// Everything the vault gate needs (F006).
class VaultGate {
  const VaultGate({
    required this.vault,
    required this.inspection,
    required this.open,
    required this.memoryOnly,
  });

  final EncryptedVault vault;

  /// What was stored when the app started (read only).
  final VaultInspection inspection;

  /// Builds the app around an opened vault.
  final Future<AppServices> Function(OpenedVault opened) open;

  /// Builds the app on a memory store: the user declined to open the vault
  /// ([StorageReason.sessionOnly]) or it is unreadable.
  final Future<AppServices> Function(StorageReason reason, {String? detail})
  memoryOnly;
}

/// [env] and [executablePath] stand in for the process environment and the
/// binary's location (tests); the app passes neither.
Future<AppStartup> startApp(
  AppConfig config,
  HostPlatform platform, {
  Map<String, String>? env,
  String? executablePath,
}) async {
  final choice = await createPlatformRepository(
    config,
    env: env,
    executablePath: executablePath,
  );
  final vault = choice.vault;
  if (vault == null) {
    return AppStartup.ready(await _openChoice(config, platform, choice));
  }
  final inspection = await vault.inspect();
  return AppStartup.gate(
    VaultGate(
      vault: vault,
      inspection: inspection,
      open: (opened) => servicesFor(
        config,
        platform,
        opened.repository,
        reason: opened.report.readOnly
            ? StorageReason.vaultReadOnly
            : StorageReason.saving,
        notes: choice.notes,
        report: opened.report,
        files: opened.files,
        derive: choice.derive,
      ),
      memoryOnly: (reason, {detail}) async {
        final repo = inMemoryRepository();
        await repo.open();
        return servicesFor(
          config,
          platform,
          repo,
          reason: reason,
          detail: detail,
          notes: choice.notes,
          derive: choice.derive,
        );
      },
    ),
  );
}

/// Opens storage without a gate (development builds, memory stores). Builds
/// that keep an encrypted vault must start with [startApp]: they never fall
/// back to an unexplained memory store.
Future<AppServices> bootstrap(AppConfig config, HostPlatform platform) async {
  final choice = await createPlatformRepository(config);
  if (choice.vault != null) {
    throw StateError('This build starts at the vault gate (startApp)');
  }
  return _openChoice(config, platform, choice);
}

Future<AppServices> _openChoice(
  AppConfig config,
  HostPlatform platform,
  StorageChoice choice,
) async {
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
    detail = errorCode(e) ?? e.runtimeType.toString();
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
    derive: choice.derive,
  );
}

/// Shared by [bootstrap], the vault gate and tests: builds services around
/// an opened repository.
Future<AppServices> servicesFor(
  AppConfig config,
  HostPlatform platform,
  HealthRepository repo, {
  StorageReason? reason,
  String? detail,
  List<StorageNote> notes = const [],
  LoadReport report = const LoadReport(warnings: []),
  DataFiles? files,
  KeyDeriver derive = deriveInline,
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
    // backup is the way back. A backup copies the persisted store, so a
    // memory store offers none.
    dataFiles: files,
    makeBackup:
        repo is LogRepository &&
            repo.description.durability != StorageDurability.memoryOnly
        ? _backupMaker(repo, config)
        : null,
    lockStorage: repo is LogRepository ? repo.lock : null,
    restartRequired: ValueNotifier<bool>(false),
    deriveKey: derive,
  );
}

/// A backup of exactly what is stored: the plaintext development log, or
/// the encrypted envelope (never decrypted into the bundle).
Future<String> Function(DateTime now) _backupMaker(
  LogRepository repo,
  AppConfig config,
) {
  final sink = repo.sink;
  if (sink is EncryptedLogSink) {
    return (now) async {
      final both = await sink.readBoth();
      return createEncryptedBackupBundle(
        envelopeText: both.raw,
        innerLogText: both.opened.inner,
        appVersion: config.version,
        sourceRevision: config.sourceRevision,
        createdAt: now,
      );
    };
  }
  return (now) async => createBackupBundle(
    vaultLogText: await sink.read() ?? '',
    appVersion: config.version,
    sourceRevision: config.sourceRevision,
    createdAt: now,
  );
}
