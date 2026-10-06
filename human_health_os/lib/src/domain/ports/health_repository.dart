/// Storage port for canonical health data. Adapters live in `lib/src/data`.
/// The domain never knows whether data sits in memory, a file vault or the
/// browser.
library;

import '../profile/profile.dart';
import '../records/health_record.dart';

/// How a store keeps data. Shown to the user; never overstated.
enum StorageDurability {
  /// Lost when the app closes.
  memoryOnly,

  /// A file on this device.
  localFile,

  /// Browser storage: survives reloads, but the browser may evict it.
  browserStorage,
}

class StorageDescription {
  const StorageDescription({
    required this.durability,
    required this.encrypted,
    required this.location,
    required this.vaultId,
  });

  final StorageDurability durability;

  /// FORGE 002 stores are NOT encrypted; encryption arrives in FORGE 004.
  final bool encrypted;

  /// Human-readable location (path or "browser storage"). No health data.
  final String location;

  /// Stable vault identity stored inside the data, not derived from the path.
  final String vaultId;
}

/// Result of opening a store. [warnings] lists recoverable problems that the
/// UI must show (e.g. a truncated last line after a crash).
class LoadReport {
  const LoadReport({required this.warnings});

  final List<String> warnings;
}

abstract interface class HealthRepository {
  StorageDescription get description;

  /// Opens or creates the store and reads everything into memory.
  Future<LoadReport> open();

  Future<List<Profile>> profiles();

  Future<void> putProfile(Profile profile);

  /// Append-only: records are never edited in place (corrections supersede).
  Future<void> appendRecord(HealthRecord record);

  /// All records for a profile, including superseded history.
  Future<List<HealthRecord>> records(String profileId, {RecordKind? kind});
}
