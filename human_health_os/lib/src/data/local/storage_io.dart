/// Native (dart:io) storage: file vault on desktop. Mobile adapters need
/// platform paths (path_provider) and land with their Forge; until then mobile
/// falls back to memory with a visible notice.
library;

import 'dart:io';

import '../../config/app_config.dart';
import '../../domain/ports/health_repository.dart';
import 'log_repository.dart';
import 'storage_status.dart';

export 'storage_status.dart';

class FileLogSink implements LogSink {
  FileLogSink(this.file);

  final File file;

  @override
  Future<String?> read() async =>
      await file.exists() ? file.readAsString() : null;

  @override
  Future<void> create(String text) async {
    await file.parent.create(recursive: true);
    // Write to a temp file and rename, so a crash never leaves a half header.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString('$text\n', flush: true);
    await tmp.rename(file.path);
  }

  @override
  Future<void> appendLine(String line) async {
    final raf = await file.open(mode: FileMode.append);
    try {
      await raf.writeString('$line\n');
      await raf.flush();
    } finally {
      await raf.close();
    }
  }
}

const String vaultFileName = 'vault.hhoslog.jsonl';

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
  final gated = profileGate(config);
  if (gated != null) return gated;
  // v0.28 / D-009: portable data must be encrypted. Never write a plaintext
  // vault next to the executable, not even in development builds.
  if (isPortableMode(executablePath: executablePath)) {
    return StorageChoice(
      inMemoryRepository(),
      reason: StorageReason.portablePolicy,
    );
  }
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
  );
}
