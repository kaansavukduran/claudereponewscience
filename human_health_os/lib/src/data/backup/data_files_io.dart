/// Desktop adapter: backups and exports in folders beside the development
/// vault (`backups/`, `exports/`), and the file steps of the restore gate.
library;

import 'dart:io';

import '../local/vault_log.dart' show decodeLogBytes;
import 'backup_bundle.dart';
import 'data_files.dart';

class FileDataFiles implements DataFiles {
  FileDataFiles({
    required this.dataDir,
    required this.vault,
    this.target = const RestoreTarget.plaintext(),
    Future<void> Function(File file, String to)? rename,
  }) : _rename = rename ?? _renameFile;

  static Future<void> _renameFile(File file, String to) => file.rename(to);

  /// Moves a file (tests replace it to make a step fail).
  final Future<void> Function(File file, String to) _rename;

  final Directory dataDir;
  final File vault;

  /// The kind of vault [vault] is (development log or encrypted envelope).
  final RestoreTarget target;

  String get _sep => Platform.pathSeparator;
  Directory _dir(DataFileKind kind) => Directory(
    '${dataDir.path}$_sep${kind == DataFileKind.backup ? 'backups' : 'exports'}',
  );

  @override
  bool get canRestore => true;

  @override
  bool get holdsEncryptedVault => target.encrypted;

  @override
  Future<String> save(DataFileKind kind, String fileName, String text) async {
    final dir = _dir(kind);
    await dir.create(recursive: true);
    final target = File('${dir.path}$_sep$fileName');
    // Temp file + rename: a crash never leaves half a backup behind.
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsString(text, flush: true);
    await tmp.rename(target.path);
    return target.path;
  }

  @override
  Future<List<SavedFile>> backups() async {
    final dir = _dir(DataFileKind.backup);
    if (!await dir.exists()) return const [];
    final files = <SavedFile>[];
    await for (final e in dir.list()) {
      if (e is! File || !e.path.endsWith('.hhosbackup.json')) continue;
      final st = await e.stat();
      files.add(
        SavedFile(
          id: e.path,
          name: e.uri.pathSegments.last,
          bytes: st.size,
          modified: st.modified.toUtc(),
        ),
      );
    }
    return files..sort(newestBackupFirst);
  }

  @override
  Future<String> read(SavedFile file) => File(file.id).readAsString();

  @override
  Future<RestoreOutcome> restore(
    StagedRestore staged, {
    required DateTime now,
    void Function()? beforeSwitch,
  }) async {
    target.checkKind(staged);
    final live = await vault.exists()
        ? decodeLogBytes(await vault.readAsBytes())
        : null;
    target.refuseIfHolds(live);
    await vault.parent.create(recursive: true);
    // Staged destination: written and verified before anything is switched.
    final restoring = File('${vault.path}.restoring');
    await restoring.writeAsString(staged.payload, flush: true);
    try {
      staged.verifyWritten(await restoring.readAsString());
    } catch (_) {
      await restoring.delete();
      rethrow;
    }
    // From here the file at the vault path changes: this session's memory
    // no longer matches it, so it stops writing first (review finding).
    beforeSwitch?.call();
    String? kept;
    try {
      if (await vault.exists()) {
        final aside = '${vault.path}.before-restore-${fileStamp(now)}';
        await _rename(vault, aside);
        kept = aside;
      }
      await _rename(restoring, vault.path);
    } catch (_) {
      // Never leave the vault's place empty: put the previous vault back.
      if (kept != null && !await vault.exists()) {
        try {
          await _rename(File(kept), vault.path);
          kept = null;
        } catch (_) {
          // It stays at [kept]; the message says where.
        }
      }
      try {
        if (await restoring.exists()) await restoring.delete();
      } catch (_) {
        // A leftover copy of the backup is harmless.
      }
      throw BackupError('RESTORE_SWITCH_FAILED', kept ?? '');
    }
    return RestoreOutcome(
      records: staged.manifest.recordCount,
      location: vault.path,
      keptPrevious: kept,
    );
  }
}
