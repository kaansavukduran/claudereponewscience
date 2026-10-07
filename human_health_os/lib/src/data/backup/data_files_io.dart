/// Desktop adapter: backups and exports in folders beside the development
/// vault (`backups/`, `exports/`), and the file steps of the restore gate.
library;

import 'dart:io';

import '../local/vault_log.dart' show decodeLogBytes;
import 'backup_bundle.dart';
import 'data_files.dart';

class FileDataFiles implements DataFiles {
  FileDataFiles({required this.dataDir, required this.vault});

  final Directory dataDir;
  final File vault;

  String get _sep => Platform.pathSeparator;
  Directory _dir(DataFileKind kind) => Directory(
    '${dataDir.path}$_sep${kind == DataFileKind.backup ? 'backups' : 'exports'}',
  );

  @override
  bool get canRestore => true;

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
  }) async {
    final live = await vault.exists()
        ? decodeLogBytes(await vault.readAsBytes())
        : null;
    refuseIfHasRecords(live);
    await vault.parent.create(recursive: true);
    // Staged destination: written and verified before anything is switched.
    final restoring = File('${vault.path}.restoring');
    await restoring.writeAsString(staged.payload, flush: true);
    final written = await restoring.readAsString();
    if (sha256Hex(written) != staged.manifest.payloadSha256 ||
        parseLiveRecordCount(written) != staged.manifest.recordCount) {
      await restoring.delete();
      throw const BackupError(
        'RESTORE_VERIFY_FAILED',
        'The restored copy did not read back identically; nothing was changed',
      );
    }
    String? kept;
    if (await vault.exists()) {
      kept = '${vault.path}.before-restore-${fileStamp(now)}';
      await vault.rename(kept);
    }
    await restoring.rename(vault.path);
    return RestoreOutcome(
      records: staged.manifest.recordCount,
      location: vault.path,
      keptPrevious: kept,
    );
  }
}
