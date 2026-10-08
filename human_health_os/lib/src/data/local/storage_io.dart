/// Native (dart:io) storage on desktop: the encrypted vault for staging,
/// production and portable builds (F006), the plaintext log for development
/// installs. Mobile adapters need platform paths (path_provider) and land
/// with their Forge; until then mobile falls back to memory with a notice.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../../config/app_config.dart';
import '../../domain/ports/health_repository.dart';
import '../backup/data_files.dart' show RestoreTarget, fileStamp;
import '../backup/data_files_io.dart';
import '../crypto/vault_crypto.dart';
import 'encrypted_vault.dart';
import 'log_repository.dart';
import 'storage_status.dart';
import 'vault_log.dart' show decodeLogBytes;

export 'storage_status.dart';

class FileLogSink implements LogSink, FirstLineReplaceable {
  FileLogSink(this.file);

  final File file;

  @override
  Future<String?> read() async =>
      await file.exists() ? decodeLogBytes(await file.readAsBytes()) : null;

  @override
  Future<void> create(String text) async {
    await file.parent.create(recursive: true);
    // Write to a temp file and rename, so a crash never leaves a half header.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString('$text\n', flush: true);
    await tmp.rename(file.path);
  }

  /// Appends to the existing log only. A vault file that disappeared (moved
  /// by a restore that failed half-way, or deleted outside the app) is
  /// never re-created by an append: that would start a file without a
  /// header, and later entries would be unreadable (review finding).
  @override
  Future<void> appendLine(String line) async {
    if (!await file.exists()) throw const StorageWriteRefused('VAULT_MISSING');
    final raf = await file.open(mode: FileMode.append);
    try {
      await raf.writeString('$line\n');
      await raf.flush();
    } finally {
      await raf.close();
    }
  }

  /// Replaces line 1 and keeps every byte after the first newline exactly,
  /// also bytes that are not valid UTF-8; temp file and rename.
  @override
  Future<void> replaceFirstLine(String line) async {
    final bytes = await file.readAsBytes();
    final cut = bytes.indexOf(0x0A);
    final out = BytesBuilder(copy: false)
      ..add(utf8.encode(line))
      ..addByte(0x0A);
    if (cut >= 0) out.add(Uint8List.sublistView(bytes, cut + 1));
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsBytes(out.takeBytes(), flush: true);
    await tmp.rename(file.path);
  }
}

const String vaultFileName = 'vault.hhoslog.jsonl';

/// The encrypted vault's file. Staging (and a mislabelled build, which
/// falls back to staging) never opens the production vault.
String encryptedVaultFileName(BuildProfile profile) =>
    profile == BuildProfile.production
    ? 'vault.hhosvault'
    : 'vault-${profile.name}.hhosvault';

/// Argon2id in a background isolate, so the UI keeps drawing while a key is
/// derived (about 0.25 s).
Future<Uint8List> deriveInIsolate(String secret, KdfParams params) =>
    Isolate.run(() => deriveKey(secret, params));

/// XDG data subfolder on Linux (appendix 221, conflict C-4).
const String linuxDataFolder = 'human-health-os';

/// The Linux folder used before F002@v0.32; moved on first start.
const String legacyLinuxDataFolder = 'HumanHealthOS';

/// Folder name on macOS (Application Support) and Windows (LOCALAPPDATA).
const String desktopDataFolder = 'HumanHealthOS';

/// Where the vault goes, or why it cannot go anywhere.
class DataDirectory {
  const DataDirectory(this.dir, {this.legacy, this.invalidVariable});

  /// The data directory, or null (no platform location, or [invalidVariable]).
  final Directory? dir;

  /// Linux only: the pre-F002 folder `HumanHealthOS/` next to [dir].
  final Directory? legacy;

  /// The environment variable that made the location unusable.
  final String? invalidVariable;
}

bool _absolute(String path) => Directory(path).isAbsolute;

/// Resolves the data directory. Portable mode: a `portable_mode.json` next to
/// the executable puts the vault in `UserData/` beside it (Rufus-like folder).
///
/// `HHOS_DATA_DIR` must be absolute; a relative value is refused instead of
/// being resolved against whatever the working directory happens to be (gap
/// G-19). An empty or relative `XDG_DATA_HOME` is ignored, as the XDG Base
/// Directory spec requires.
DataDirectory resolveDataDirectory({
  Map<String, String>? env,
  String? executablePath,
}) {
  final e = env ?? Platform.environment;
  final override = e['HHOS_DATA_DIR'];
  if (override != null && override.isNotEmpty) {
    return _absolute(override)
        ? DataDirectory(Directory(override))
        : const DataDirectory(null, invalidVariable: 'HHOS_DATA_DIR');
  }
  final exe = File(executablePath ?? Platform.resolvedExecutable);
  final portableMarker = File(
    '${exe.parent.path}${Platform.pathSeparator}portable_mode.json',
  );
  if (portableMarker.existsSync()) {
    return DataDirectory(
      Directory('${exe.parent.path}${Platform.pathSeparator}UserData'),
    );
  }
  final home = e['HOME'];
  final usableHome = home != null && home.isNotEmpty && _absolute(home)
      ? home
      : null;
  if (Platform.isLinux) {
    final xdg = e['XDG_DATA_HOME'];
    final base = xdg != null && xdg.isNotEmpty && _absolute(xdg)
        ? xdg
        : (usableHome == null ? null : '$usableHome/.local/share');
    if (base == null) return const DataDirectory(null);
    return DataDirectory(
      Directory('$base/$linuxDataFolder'),
      legacy: Directory('$base/$legacyLinuxDataFolder'),
    );
  }
  if (Platform.isMacOS) {
    return DataDirectory(
      usableHome == null
          ? null
          : Directory(
              '$usableHome/Library/Application Support/$desktopDataFolder',
            ),
    );
  }
  if (Platform.isWindows) {
    final base = e['LOCALAPPDATA'];
    return DataDirectory(
      base == null || base.isEmpty || !_absolute(base)
          ? null
          : Directory('$base\\$desktopDataFolder'),
    );
  }
  return const DataDirectory(null); // Android/iOS: needs a path adapter.
}

/// True when `portable_mode.json` sits next to the executable.
bool isPortableMode({String? executablePath}) {
  final exe = File(executablePath ?? Platform.resolvedExecutable);
  return File('${exe.parent.path}${Platform.pathSeparator}portable_mode.json')
      .existsSync();
}

/// Moves the pre-F002 Linux folder to its XDG name (C-4). Only a rename in
/// the same parent folder, so it is atomic; the old folder is never merged
/// or deleted. Returns the folder to use and what happened.
({Directory dir, StorageNote? note}) adoptLegacyFolder(
  Directory target,
  Directory legacy,
) {
  if (!legacy.existsSync()) return (dir: target, note: null);
  if (target.existsSync()) {
    return (
      dir: target,
      note: StorageNote(StorageNoteKind.legacyFolderLeft, legacy.path),
    );
  }
  try {
    legacy.renameSync(target.path);
    return (
      dir: target,
      note: StorageNote(StorageNoteKind.movedLegacyFolder, target.path),
    );
  } on FileSystemException {
    return (
      dir: legacy,
      note: StorageNote(StorageNoteKind.legacyFolderInUse, legacy.path),
    );
  }
}

Future<StorageChoice> createPlatformRepository(
  AppConfig config, {
  Map<String, String>? env,
  String? executablePath,
}) async {
  final portable = isPortableMode(executablePath: executablePath);
  final resolved = resolveDataDirectory(
    env: env,
    executablePath: executablePath,
  );
  if (resolved.invalidVariable != null) {
    return StorageChoice(
      inMemoryRepository(),
      reason: StorageReason.dataDirInvalid,
      detail: resolved.invalidVariable,
    );
  }
  var dir = resolved.dir;
  if (dir == null) {
    return StorageChoice(
      inMemoryRepository(),
      reason: StorageReason.platformNotBuilt,
    );
  }
  // D-009/D-010/F006: staging, production and portable builds keep health
  // data only in the encrypted vault; nothing is written before the user
  // creates or unlocks it, and nothing plaintext ever lands next to the app.
  if (!config.mayPersistUnencrypted || portable) {
    final file = File(
      '${dir.path}${Platform.pathSeparator}${encryptedVaultFileName(config.profile)}',
    );
    final dataDir = dir;
    return StorageChoice(
      inMemoryRepository(),
      derive: deriveInIsolate,
      vault: EncryptedVault(
        raw: FileLogSink(file),
        location: file.path,
        derive: deriveInIsolate,
        setAsideStore: (now) async {
          final kept = '${file.path}.locked-${fileStamp(now)}';
          await file.rename(kept);
          return kept;
        },
        filesFor: (sink) => FileDataFiles(
          dataDir: dataDir,
          vault: file,
          target: RestoreTarget.encrypted(sink.open),
        ),
      ),
    );
  }
  final notes = <StorageNote>[];
  final legacy = resolved.legacy;
  if (legacy != null) {
    final adopted = adoptLegacyFolder(dir, legacy);
    dir = adopted.dir;
    if (adopted.note != null) notes.add(adopted.note!);
  }
  final file = File('${dir.path}${Platform.pathSeparator}$vaultFileName');
  return StorageChoice(
    LogRepository(
      sink: FileLogSink(file),
      durability: StorageDurability.localFile,
      location: file.path,
    ),
    notes: notes,
    // Opening an encrypted backup derives a key: off the UI thread here too.
    derive: deriveInIsolate,
    files: FileDataFiles(dataDir: dir, vault: file),
  );
}
