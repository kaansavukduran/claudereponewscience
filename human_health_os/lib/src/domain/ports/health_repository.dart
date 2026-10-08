/// Storage port for canonical health data. Adapters live in `lib/src/data`.
/// The domain never knows whether data sits in memory, a file vault or the
/// browser.
library;

import '../errors.dart';
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

  /// True for the encrypted vault (F006); development logs and memory
  /// stores are not encrypted.
  final bool encrypted;

  /// Human-readable location (path or "browser storage"). No health data.
  final String location;

  /// Stable vault identity stored inside the data, not derived from the path.
  final String vaultId;
}

/// Why a saved entry was skipped while opening a store. The entry stays in
/// the file; only this session ignores it.
enum LoadWarningKind {
  /// The last entry is cut off (probably an interrupted save).
  lastEntryIncomplete,

  /// An entry before the last one is not readable.
  entryUnreadable,

  /// An entry is readable but breaks a record rule ([LoadWarning.code]).
  entryInvalid,

  /// An encrypted vault lacks an entry between two readable ones: it was
  /// removed from the file, or a save that failed never reached it (F006).
  /// Nothing replaces it.
  entryMissing,
}

/// A recoverable problem found while opening a store. The UI must show it.
class LoadWarning {
  const LoadWarning(this.kind, {required this.line, this.code});

  final LoadWarningKind kind;

  /// 1-based line in the store (line 1 is the header).
  final int line;

  /// The broken rule for [LoadWarningKind.entryInvalid] (e.g.
  /// `PRESENT_REQUIRES_QUANTITY`).
  final String? code;
}

/// One applied schema migration step (master §33.3).
class MigrationReceipt {
  const MigrationReceipt({
    required this.id,
    required this.fromVersion,
    required this.toVersion,
    required this.checkpoint,
    required this.startedAt,
    required this.finishedAt,
    required this.result,
    required this.entries,
  });

  final String id;
  final int fromVersion;
  final int toVersion;

  /// What protects the old data (e.g. "the file was not changed").
  final String checkpoint;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String result;

  /// Logged entries the step processed.
  final int entries;
}

/// Result of opening a store.
class LoadReport {
  const LoadReport({
    required this.warnings,
    this.migrations = const [],
    this.readOnly = false,
  });

  /// Recoverable problems the UI must show.
  final List<LoadWarning> warnings;

  /// Migration steps applied in memory while opening.
  final List<MigrationReceipt> migrations;

  /// True when the store refuses writes (e.g. it was migrated in memory and
  /// no upgrade checkpoint exists yet).
  final bool readOnly;
}

/// A write was refused without touching the store.
class StorageWriteRefused implements Exception, CodedError {
  const StorageWriteRefused(this.code);

  /// Stable code, e.g. `VAULT_READ_ONLY`.
  @override
  final String code;

  @override
  String toString() => 'StorageWriteRefused($code)';
}

abstract interface class HealthRepository {
  StorageDescription get description;

  /// Opens or creates the store and reads everything into memory.
  Future<LoadReport> open();

  /// False when writes are refused (see [LoadReport.readOnly]).
  bool get writable;

  Future<List<Profile>> profiles();

  Future<void> putProfile(Profile profile);

  /// Append-only: records are never edited in place (corrections supersede).
  Future<void> appendRecord(HealthRecord record);

  /// All records for a profile, including superseded history.
  Future<List<HealthRecord>> records(String profileId, {RecordKind? kind});
}
