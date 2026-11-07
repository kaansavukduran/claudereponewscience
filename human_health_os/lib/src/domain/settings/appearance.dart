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

/// Today sections a person may hide. The weight and measurement areas are
/// always there (they hold the person's numbers); Settings stays one click
/// away in the top bar whatever is hidden.
enum TodaySection { tools, yourData, buildFacts }

class AppearanceSettings {
  const AppearanceSettings({
    this.language = LanguageChoice.system,
    this.theme = ThemeChoice.system,
    this.accent = AccentChoice.teal,
    this.textSize = TextSizeChoice.system,
    this.tileOrder = const [],
    this.hiddenTiles = const {},
    this.hiddenSections = const {},
    this.padOpen = false,
  });

  final LanguageChoice language;
  final ThemeChoice theme;
  final AccentChoice accent;
  final TextSizeChoice textSize;

  /// Measurement tile codes in the order chosen; codes not listed follow in
  /// the default order (a tile added by a newer version is never lost).
  final List<String> tileOrder;
  final Set<String> hiddenTiles;
  final Set<TodaySection> hiddenSections;

  /// The number pad is open when a measurement sheet opens.
  final bool padOpen;

  /// [defaults] in the chosen order, all of them (hidden ones included).
  List<String> ordered(List<String> defaults) => [
    for (final c in tileOrder)
      if (defaults.contains(c)) c,
    for (final c in defaults)
      if (!tileOrder.contains(c)) c,
  ];

  /// [defaults] in the chosen order, without the hidden ones.
  List<String> visible(List<String> defaults) => [
    for (final c in ordered(defaults))
      if (!hiddenTiles.contains(c)) c,
  ];

  /// Moves [code] one place up (-1) or down (+1) among [defaults].
  AppearanceSettings move(List<String> defaults, String code, int by) {
    final list = ordered(defaults);
    final i = list.indexOf(code);
    final j = i + by;
    if (i < 0 || j < 0 || j >= list.length) return this;
    list
      ..removeAt(i)
      ..insert(j, code);
    return copyWith(tileOrder: list);
  }

  /// The Today layout back to the default; language and look are kept.
  AppearanceSettings resetToday() => AppearanceSettings(
    language: language,
    theme: theme,
    accent: accent,
    textSize: textSize,
  );

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
    List<String>? tileOrder,
    Set<String>? hiddenTiles,
    Set<TodaySection>? hiddenSections,
    bool? padOpen,
  }) => AppearanceSettings(
    language: language ?? this.language,
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    textSize: textSize ?? this.textSize,
    tileOrder: tileOrder ?? this.tileOrder,
    hiddenTiles: hiddenTiles ?? this.hiddenTiles,
    hiddenSections: hiddenSections ?? this.hiddenSections,
    padOpen: padOpen ?? this.padOpen,
  );

  Map<String, Object?> toJson() => {
    'format': 'hhos.appearance',
    'version': 1,
    'language': language.name,
    'theme': theme.name,
    'accent': accent.name,
    'textSize': textSize.name,
    'tileOrder': tileOrder,
    'hiddenTiles': hiddenTiles.toList()..sort(),
    'hiddenSections': [for (final s in hiddenSections) s.name]..sort(),
    'padOpen': padOpen,
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

    List<String> strings(Object? v) => v is List
        ? [
            for (final e in v)
              if (e is String && e.length <= 64) e,
          ]
        : const [];

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
      tileOrder: strings(json['tileOrder']),
      hiddenTiles: strings(json['hiddenTiles']).toSet(),
      hiddenSections: {
        for (final n in strings(json['hiddenSections']))
          for (final s in TodaySection.values)
            if (s.name == n) s,
      },
      padOpen: json['padOpen'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppearanceSettings &&
      other.language == language &&
      other.theme == theme &&
      other.accent == accent &&
      other.textSize == textSize &&
      _sameList(other.tileOrder, tileOrder) &&
      _sameSet(other.hiddenTiles, hiddenTiles) &&
      _sameSet(other.hiddenSections, hiddenSections) &&
      other.padOpen == padOpen;

  @override
  int get hashCode => Object.hash(
    language,
    theme,
    accent,
    textSize,
    Object.hashAll(tileOrder),
    hiddenTiles.length,
    hiddenSections.length,
    padOpen,
  );
}

bool _sameList<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _sameSet<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);

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
