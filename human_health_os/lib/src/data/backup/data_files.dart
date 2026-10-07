/// Where backups and exports go (ladder F005). One interface, three
/// adapters: files beside the development vault (desktop), a browser
/// download (web), and memory (tests). Pure Dart.
library;

import 'backup_bundle.dart';

enum DataFileKind { backup, export }

class SavedFile {
  const SavedFile({
    required this.id,
    required this.name,
    required this.bytes,
    required this.modified,
  });

  /// Adapter-specific handle (a path on desktop).
  final String id;
  final String name;
  final int bytes;
  final DateTime modified;
}

class RestoreOutcome {
  const RestoreOutcome({
    required this.records,
    required this.location,
    this.keptPrevious,
  });

  final int records;
  final String location;

  /// Where the vault that was replaced was kept (never deleted).
  final String? keptPrevious;
}

abstract interface class DataFiles {
  /// True when saved backups can be listed and restored here.
  bool get canRestore;

  /// Saves [text] and returns a human-readable location.
  Future<String> save(DataFileKind kind, String fileName, String text);

  /// Saved backups, newest first.
  Future<List<SavedFile>> backups();

  Future<String> read(SavedFile file);

  /// The last steps of the restore gate (§36.3): write the staged payload
  /// beside the vault, verify the written copy, keep the old vault, switch.
  /// Refuses (`RESTORE_TARGET_HAS_RECORDS`) when the live vault holds
  /// records: a restore never replaces real history.
  Future<RestoreOutcome> restore(StagedRestore staged, {required DateTime now});
}

/// `yyyyMMddTHHmmssZ`, safe in file names on every platform.
String fileStamp(DateTime t) {
  final u = t.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
}

String backupFileName(String vaultId, DateTime t) =>
    'human-os-backup-${vaultId.length > 8 ? vaultId.substring(0, 8) : vaultId}-${fileStamp(t)}.hhosbackup.json';

String exportFileName(DateTime t) => 'human-os-export-${fileStamp(t)}.json';

/// Memory adapter for tests: keeps files in a map and restores into a
/// replaceable text slot.
class MemoryDataFiles implements DataFiles {
  MemoryDataFiles({this.vaultText});

  final Map<String, String> files = {};
  final Map<String, DateTime> times = {};

  /// The "live vault" a restore replaces.
  String? vaultText;
  String? kept;

  @override
  bool get canRestore => true;

  @override
  Future<String> save(DataFileKind kind, String fileName, String text) async {
    final id = '${kind.name}/$fileName';
    files[id] = text;
    times[id] = DateTime.now().toUtc();
    return 'memory:$id';
  }

  @override
  Future<List<SavedFile>> backups() async => [
    for (final e in files.entries)
      if (e.key.startsWith('backup/'))
        SavedFile(
          id: e.key,
          name: e.key.substring('backup/'.length),
          bytes: e.value.length,
          modified: times[e.key]!,
        ),
  ]..sort((a, b) => b.name.compareTo(a.name));

  @override
  Future<String> read(SavedFile file) async => files[file.id]!;

  @override
  Future<RestoreOutcome> restore(
    StagedRestore staged, {
    required DateTime now,
  }) async {
    refuseIfHasRecords(vaultText);
    kept = vaultText;
    vaultText = staged.payload;
    return RestoreOutcome(
      records: staged.state.records.length,
      location: 'memory',
      keptPrevious: kept == null ? null : 'memory:before-restore',
    );
  }
}

/// Throws `RESTORE_TARGET_HAS_RECORDS` when [liveVaultText] holds records.
/// An unreadable live vault does not block a restore (it is the recovery
/// path); the adapter keeps that file instead of deleting it.
void refuseIfHasRecords(String? liveVaultText) {
  if (liveVaultText == null || liveVaultText.trim().isEmpty) return;
  final int records;
  try {
    records = parseLiveRecordCount(liveVaultText);
  } catch (_) {
    return;
  }
  if (records > 0) {
    throw BackupError(
      'RESTORE_TARGET_HAS_RECORDS',
      'This device already holds $records records; restoring would replace them',
    );
  }
}
