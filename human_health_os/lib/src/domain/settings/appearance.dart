/// How the app looks for this person (U005): language, light or dark, accent
/// colour and text size. Display preferences only: no health data, no
/// effect on any value or record.
library;

enum LanguageChoice { system, tr, en }

enum ThemeChoice { system, light, dark }

/// Accent colours. Each has a light and a dark tone chosen for at least
/// 4.5:1 against the app's surfaces; none is red or amber, so an accent never
/// looks like an error or a warning, and no colour judges a value.
enum AccentChoice { teal, blue, purple, green, graphite }

enum TextSizeChoice { system, larger, largest }

class AppearanceSettings {
  const AppearanceSettings({
    this.language = LanguageChoice.system,
    this.theme = ThemeChoice.system,
    this.accent = AccentChoice.teal,
    this.textSize = TextSizeChoice.system,
  });

  final LanguageChoice language;
  final ThemeChoice theme;
  final AccentChoice accent;
  final TextSizeChoice textSize;

  /// Multiplies the text size the system asks for.
  double get textFactor => switch (textSize) {
    TextSizeChoice.system => 1.0,
    TextSizeChoice.larger => 1.15,
    TextSizeChoice.largest => 1.3,
  };

  AppearanceSettings copyWith({
    LanguageChoice? language,
    ThemeChoice? theme,
    AccentChoice? accent,
    TextSizeChoice? textSize,
  }) => AppearanceSettings(
    language: language ?? this.language,
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    textSize: textSize ?? this.textSize,
  );

  Map<String, Object?> toJson() => {
    'format': 'hhos.appearance',
    'version': 1,
    'language': language.name,
    'theme': theme.name,
    'accent': accent.name,
    'textSize': textSize.name,
  };

  /// Reads saved settings; anything unknown or missing falls back to the
  /// default for that one setting (a newer file never breaks the app).
  static AppearanceSettings fromJson(Object? json) {
    if (json is! Map) return const AppearanceSettings();
    T pick<T extends Enum>(List<T> values, Object? v, T fallback) {
      for (final e in values) {
        if (e.name == v) return e;
      }
      return fallback;
    }

    return AppearanceSettings(
      language: pick(
        LanguageChoice.values,
        json['language'],
        LanguageChoice.system,
      ),
      theme: pick(ThemeChoice.values, json['theme'], ThemeChoice.system),
      accent: pick(AccentChoice.values, json['accent'], AccentChoice.teal),
      textSize: pick(
        TextSizeChoice.values,
        json['textSize'],
        TextSizeChoice.system,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppearanceSettings &&
      other.language == language &&
      other.theme == theme &&
      other.accent == accent &&
      other.textSize == textSize;

  @override
  int get hashCode => Object.hash(language, theme, accent, textSize);
}

/// Where the settings are kept. Development desktop builds keep a small
/// file beside the data folder; other builds keep them for this session only
/// (G-62).
abstract class AppearanceStore {
  Future<AppearanceSettings> load();
  Future<void> save(AppearanceSettings settings);

  /// Whether a change survives a restart (shown on the Settings page).
  bool get persistent;
}

class MemoryAppearanceStore implements AppearanceStore {
  MemoryAppearanceStore([this.saved]);

  AppearanceSettings? saved;

  @override
  bool get persistent => false;

  @override
  Future<AppearanceSettings> load() async =>
      saved ?? const AppearanceSettings();

  @override
  Future<void> save(AppearanceSettings settings) async => saved = settings;
}
