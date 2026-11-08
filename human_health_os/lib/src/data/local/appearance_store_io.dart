import 'dart:convert';
import 'dart:io';

import '../../config/app_config.dart';
import '../../core/capabilities.dart';
import '../../domain/settings/appearance.dart';
import 'storage_io.dart';

const String appearanceFileName = 'appearance.json';

/// Settings in a small JSON file. It holds only display preferences (no
/// health data) and is written only by development builds, which already
/// keep their labelled log in the same folder; other builds never write
/// before the vault is open, so they keep settings in memory (G-62).
class FileAppearanceStore implements AppearanceStore {
  FileAppearanceStore(this.file);

  final File file;

  @override
  bool get persistent => true;

  @override
  Future<AppearanceSettings> load() async {
    try {
      if (!await file.exists()) return const AppearanceSettings();
      return AppearanceSettings.fromJson(jsonDecode(await file.readAsString()));
    } catch (_) {
      // An unreadable file is ignored and left as it is.
      return const AppearanceSettings();
    }
  }

  @override
  Future<void> save(AppearanceSettings settings) async {
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(settings.toJson()), flush: true);
    await tmp.rename(file.path);
  }
}

Future<AppearanceStore> openAppearanceStore(
  AppConfig config,
  HostPlatform platform, {
  Map<String, String>? env,
  String? executablePath,
  bool? mobile,
}) async {
  final isMobile = mobile ?? (Platform.isAndroid || Platform.isIOS);
  // Portable mode writes only the encrypted vault next to the program
  // (D-016); a development build in portable mode keeps settings in memory.
  if (config.profile != BuildProfile.development ||
      (!isMobile && isPortableMode(executablePath: executablePath))) {
    return MemoryAppearanceStore();
  }
  final dir = resolveDataDirectory(
    env: env,
    executablePath: executablePath,
    mobile: isMobile,
  ).dir;
  if (dir == null) return MemoryAppearanceStore();
  return FileAppearanceStore(
    File('${dir.path}${Platform.pathSeparator}$appearanceFileName'),
  );
}
