/// What the storage adapter decided at startup. Shared by the native and
/// web adapters, so the profile gate exists exactly once (audit ARCH-5).
library;

import '../../config/app_config.dart';
import '../../domain/ports/health_repository.dart';
import '../../domain/ports/storage_status.dart';
import 'log_repository.dart';

export '../../domain/ports/storage_status.dart';

class StorageChoice {
  const StorageChoice(
    this.repository, {
    this.reason = StorageReason.saving,
    this.detail,
    this.notes = const [],
  });

  final HealthRepository repository;
  final StorageReason reason;

  /// Extra context for [reason] (a variable name or an error code).
  final String? detail;
  final List<StorageNote> notes;
}

/// The profile gate: staging and production never persist unencrypted data.
/// Returns null when this build may save (development).
StorageChoice? profileGate(AppConfig config) => config.mayPersistUnencrypted
    ? null
    : StorageChoice(inMemoryRepository(), reason: StorageReason.profilePolicy);
