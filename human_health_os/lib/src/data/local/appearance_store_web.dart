import '../../config/app_config.dart';
import '../../core/capabilities.dart';
import '../../domain/settings/appearance.dart';

/// The browser keeps settings for this session only (G-62).
Future<AppearanceStore> openAppearanceStore(
  AppConfig config,
  HostPlatform platform,
) async => MemoryAppearanceStore();
