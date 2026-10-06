/// Native (dart:io) storage: file vault on desktop. Mobile adapters need
/// platform paths (path_provider) and land with their FORGE; until then mobile
/// falls back to memory with a visible warning.
library;

import 'dart:io';

import '../../config/app_config.dart';
import '../../domain/ports/health_repository.dart';
import 'log_repository.dart';

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

/// Resolves the data directory. Portable mode: a `portable_mode.json` next to
/// the executable puts the vault in `UserData/` beside it (Rufus-like folder).
Directory? resolveDataDirectory({
  Map<String, String>? env,
  String? executablePath,
}) {
  final e = env ?? Platform.environment;
  final override = e['HHOS_DATA_DIR'];
  if (override != null && override.isNotEmpty) return Directory(override);
  final exe = File(executablePath ?? Platform.resolvedExecutable);
  final portableMarker = File(
    '${exe.parent.path}${Platform.pathSeparator}portable_mode.json',
  );
  if (portableMarker.existsSync()) {
    return Directory('${exe.parent.path}${Platform.pathSeparator}UserData');
  }
  if (Platform.isLinux) {
    final base =
        e['XDG_DATA_HOME'] ??
        (e['HOME'] == null ? null : '${e['HOME']}/.local/share');
    return base == null ? null : Directory('$base/HumanHealthOS');
  }
  if (Platform.isMacOS) {
    final home = e['HOME'];
    return home == null
        ? null
        : Directory('$home/Library/Application Support/HumanHealthOS');
  }
  if (Platform.isWindows) {
    final base = e['LOCALAPPDATA'];
    return base == null ? null : Directory('$base\\HumanHealthOS');
  }
  return null; // Android/iOS: needs a platform path adapter (planned).
}

/// True when `portable_mode.json` sits next to the executable.
bool isPortableMode({String? executablePath}) {
  final exe = File(executablePath ?? Platform.resolvedExecutable);
  return File('${exe.parent.path}${Platform.pathSeparator}portable_mode.json')
      .existsSync();
}

Future<StorageChoice> createPlatformRepository(
  AppConfig config, {
  Map<String, String>? env,
  String? executablePath,
}) async {
  if (!config.mayPersistUnencrypted) {
    return StorageChoice(
      inMemoryRepository(),
      notice:
          '${config.isProduction ? 'Production' : 'Staging'} builds do not save unencrypted health data. Saving turns on with the encrypted vault (FORGE 004); entries last until the app closes.',
    );
  }
  // v0.28 / D-009: portable data must be encrypted. Never write a plaintext
  // vault next to the executable, not even in development builds.
  if (isPortableMode(executablePath: executablePath)) {
    return StorageChoice(
      inMemoryRepository(),
      notice: 'Portable mode saves only to an encrypted vault, which arrives in FORGE 004. Nothing is written next to the app; entries last until it closes.',
    );
  }
  final dir = resolveDataDirectory(env: env, executablePath: executablePath);
  if (dir == null) {
    return StorageChoice(
      inMemoryRepository(),
      notice: 'Saving on this platform is not built yet. Entries are kept only until the app closes.',
    );
  }
  final file = File('${dir.path}${Platform.pathSeparator}$vaultFileName');
  return StorageChoice(
    LogRepository(
      sink: FileLogSink(file),
      durability: StorageDurability.localFile,
      location: file.path,
    ),
  );
}

class StorageChoice {
  const StorageChoice(this.repository, {this.notice});

  final HealthRepository repository;
  final String? notice;
}
