/// Build-time configuration. Values come from `--dart-define` and are
/// **non-secret by design**: never put API keys, signing material or server
/// secrets here, because they end up readable inside every client bundle.
library;

import 'package:flutter/services.dart' show FlutterVersion;

enum BuildProfile {
  development,
  staging,
  production;

  static BuildProfile parse(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'production':
      case 'prod':
        return BuildProfile.production;
      case 'staging':
        return BuildProfile.staging;
      default:
        // Unknown values fall back to the safest *labelled* profile, never to production.
        return BuildProfile.development;
    }
  }
}

class AppConfig {
  const AppConfig({
    required this.profile,
    required this.version,
    required this.sourceRevision,
    this.flutterVersion = 'unknown',
    this.dartVersion = 'unknown',
  });

  /// Reads `--dart-define=APP_ENV=…`, `APP_VERSION` and `SOURCE_REVISION`.
  /// Flutter and Dart versions come from [FlutterVersion], which the Flutter
  /// tool injects into every build (`FLUTTER_VERSION` is reserved and cannot
  /// be passed by hand). Anything absent stays `unknown`; nothing is guessed.
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      profile: BuildProfile.parse(
        const String.fromEnvironment('APP_ENV', defaultValue: 'development'),
      ),
      version: const String.fromEnvironment(
        'APP_VERSION',
        defaultValue: '0.1.0+1',
      ),
      sourceRevision: const String.fromEnvironment(
        'SOURCE_REVISION',
        defaultValue: 'unknown',
      ),
      flutterVersion: FlutterVersion.version ?? 'unknown',
      dartVersion: FlutterVersion.dartVersion ?? 'unknown',
    );
  }

  final BuildProfile profile;
  final String version;
  final String sourceRevision;
  final String flutterVersion;
  final String dartVersion;

  bool get isProduction => profile == BuildProfile.production;

  /// Only development builds (run from source by developers) may keep an
  /// unencrypted vault. Staging previews and production packages stay
  /// memory-only until the encrypted vault (v0.31 F006), so no distributed
  /// artifact ever writes plaintext health data (v0.28 / D-009 / D-010).
  bool get mayPersistUnencrypted => profile == BuildProfile.development;

  /// First 12 characters of the git revision, shown in "This build".
  String get shortRevision => sourceRevision.length > 12
      ? sourceRevision.substring(0, 12)
      : sourceRevision;
}
