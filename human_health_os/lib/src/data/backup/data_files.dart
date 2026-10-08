/// Where backups and exports go (ladder F005). One interface, three
/// adapters: files beside the development vault (desktop), a browser
/// download (web), and memory (tests). Pure Dart.
library;

import '../local/vault_envelope.dart' show OpenedEnvelope;
import '../local/vault_log.dart' show VaultFormatError;
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

/// The kind of vault a restore may replace, and how its live content is
/// read for the "never replace records" check.
class RestoreTarget {
  /// A development log in plaintext.
  const RestoreTarget.plaintext() : _open = null;

  /// An encrypted vault, read with the key of the unlocked session.
  const RestoreTarget.encrypted(OpenedEnvelope Function(String raw) open)
    : _open = open;

  final OpenedEnvelope Function(String raw)? _open;

  bool get encrypted => _open != null;

  /// Throws `BACKUP_KIND_MISMATCH` unless [staged] is the same kind of
  /// vault: a plaintext backup never lands in an encrypted vault's place
  /// (it would store health data unencrypted), and the reverse cannot be
  /// read by a development build.
  void checkKind(StagedRestore staged) {
    if (staged.encrypted != encrypted) {
      throw const BackupError(
        'BACKUP_KIND_MISMATCH',
        'This backup is not the same kind (encrypted or not) as this vault',
      );
    }
    if (staged.needsKey) {
      throw const BackupError(
        'BACKUP_KEY_NEEDED',
        'An encrypted backup must be opened with its key first',
      );
    }
  }

  /// Throws when restoring would replace records in [liveRaw] (see
  /// [refuseIfHasRecords]). For an encrypted vault, entries that cannot be
  /// read or are missing may be records: the restore is refused then too.
  void refuseIfHolds(String? liveRaw) {
    final open = _open;
    if (open == null || liveRaw == null || liveRaw.trim().isEmpty) {
      refuseIfHasRecords(liveRaw);
      return;
    }
    final OpenedEnvelope opened;
    try {
      opened = open(liveRaw);
    } catch (_) {
      throw const BackupError(
        'RESTORE_TARGET_HAS_RECORDS',
        'The vault on this device cannot be read with this session\'s key; it is not replaced',
      );
    }
    if (opened.unknown > 0) {
      throw BackupError(
        'RESTORE_TARGET_HAS_RECORDS',
        'This device holds ${opened.unknown} entries that cannot be read; restoring would replace them',
      );
    }
    refuseIfHasRecords(opened.inner);
  }
}

abstract interface class DataFiles {
  /// True when saved backups can be listed and restored here.
  bool get canRestore;

  /// True when the vault a restore would replace is encrypted. A backup of
  /// the other kind is refused before any key is asked for.
  bool get holdsEncryptedVault;

  /// Saves [text] and returns a human-readable location.
  Future<String> save(DataFileKind kind, String fileName, String text);

  /// Saved backups, newest first.
  Future<List<SavedFile>> backups();

  Future<String> read(SavedFile file);

  /// The last steps of the restore gate (§36.3): write the staged payload
  /// beside the vault, verify the written copy, keep the old vault, switch.
  /// Refuses (`RESTORE_TARGET_HAS_RECORDS`) when the live vault holds
  /// records: a restore never replaces real history. [beforeSwitch] runs
  /// right before the live vault is moved: the session must stop writing
  /// from then on, whatever happens next. Throws `RESTORE_NOT_SWITCHED`
  /// when no file could be moved (nothing changed), and
  /// `RESTORE_SWITCH_FAILED` when the restored copy cannot be moved into
  /// place after the previous vault was moved aside; that vault is then put
  /// back where it was (or its kept path is reported).
  Future<RestoreOutcome> restore(
    StagedRestore staged, {
    required DateTime now,
    void Function()? beforeSwitch,
  });
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

final RegExp _stampInName = RegExp(r'(\d{8}T\d{6}Z)\.hhosbackup\.json$');

/// Newest first by the time in the file name (falling back to the file
/// time), never by the whole name: its vault-id prefix would group backups
/// of different vaults (review finding).
int newestBackupFirst(SavedFile a, SavedFile b) {
  String key(SavedFile f) =>
      _stampInName.firstMatch(f.name)?.group(1) ?? fileStamp(f.modified);
  final c = key(b).compareTo(key(a));
  return c != 0 ? c : b.name.compareTo(a.name);
}

/// Memory adapter for tests: keeps files in a map and restores into a
/// replaceable text slot.
class MemoryDataFiles implements DataFiles {
  MemoryDataFiles({
    this.vaultText,
    this.target = const RestoreTarget.plaintext(),
  });

  final RestoreTarget target;

  final Map<String, String> files = {};
  final Map<String, DateTime> times = {};

  /// The "live vault" a restore replaces.
  String? vaultText;
  String? kept;

  @override
  bool get canRestore => true;

  @override
  bool get holdsEncryptedVault => target.encrypted;

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
  ]..sort(newestBackupFirst);

  @override
  Future<String> read(SavedFile file) async => files[file.id]!;

  @override
  Future<RestoreOutcome> restore(
    StagedRestore staged, {
    required DateTime now,
    void Function()? beforeSwitch,
  }) async {
    target.checkKind(staged);
    target.refuseIfHolds(vaultText);
    staged.verifyWritten(staged.payload);
    beforeSwitch?.call();
    kept = vaultText;
    vaultText = staged.payload;
    return RestoreOutcome(
      records: staged.state!.records.length,
      location: 'memory',
      keptPrevious: kept == null ? null : 'memory:before-restore',
    );
  }
}

/// Throws when a restore would replace health records in [liveVaultText]:
/// `RESTORE_TARGET_NEWER` for a vault written by a newer app (it holds data
/// this version cannot see), `RESTORE_TARGET_HAS_RECORDS` when it holds any
/// record, readable or not. Only a vault without a single record line (for
/// example a fresh one, or a file that is not a vault at all) may be
/// replaced; the adapter keeps it instead of deleting it.
void refuseIfHasRecords(String? liveVaultText) {
  if (liveVaultText == null || liveVaultText.trim().isEmpty) return;
  // Record lines count even when replay skips them (e.g. a damaged profile
  // line makes every record UNKNOWN_PROFILE): they are still someone's data.
  var records = _recordLines(liveVaultText);
  try {
    final parsed = parseLiveRecordCount(liveVaultText);
    if (parsed > records) records = parsed;
  } on VaultFormatError catch (e) {
    if (e.code == 'VAULT_NEWER' || e.code == 'RECORD_SCHEMA_NEWER') {
      throw const BackupError(
        'RESTORE_TARGET_NEWER',
        'The data on this device was written by a newer Human OS',
      );
    }
  } catch (_) {
    // Unparseable: the raw record-line count above decides.
  }
  if (records > 0) {
    throw BackupError(
      'RESTORE_TARGET_HAS_RECORDS',
      'This device already holds $records records; restoring would replace them',
    );
  }
}

/// Lines that look like stored records, counted without trusting the rest
/// of the file (used when the vault cannot be parsed).
int _recordLines(String text) =>
    text.split('\n').where((l) => l.contains('"op":"record.append"')).length;
