/// Build-time configuration. Values come from `--dart-define` and are
/// **non-secret by design**: never put API keys, signing material or server
/// secrets here, because they end up readable inside every client bundle.
library;

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
  });

  /// Reads `--dart-define=APP_ENV=…`, `APP_VERSION` and `SOURCE_REVISION`.
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
    );
  }

  final BuildProfile profile;
  final String version;
  final String sourceRevision;

  bool get isProduction => profile == BuildProfile.production;
}
