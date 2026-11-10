/// How the app looks for this person (U005): language, light or dark, accent
/// colour and text size. Display preferences only: no health data, no
/// effect on any value or record.
library;

import '../units/display_units.dart';
import 'date_style.dart';

export 'date_style.dart' show DateOrder, ClockStyle;

export '../units/display_units.dart' show UnitSystem;

enum LanguageChoice { system, tr, en }

enum ThemeChoice { system, light, dark }

/// Accent colours. Each has a light and a dark tone chosen for at least
/// 4.5:1 against the app's surfaces; none is red or amber, so an accent never
/// looks like an error or a warning, and no colour judges a value.
enum AccentChoice { teal, blue, purple, green, graphite }

enum TextSizeChoice { system, larger, largest }

/// The screen the app opens on.
enum StartScreen { today, timeline, labs }

/// Comfortable keeps the larger spacing; compact shows more on a laptop.
enum Density { comfortable, compact }

/// The reading font: the device's own, a highly legible face for low
/// vision (Atkinson Hyperlegible Next) or a face designed for dyslexia
/// (OpenDyslexic). Both are bundled (D-025).
enum FontChoice { system, legible, dyslexic }

/// Explicitly visited tools, never inferred reading or health outcomes.
enum DiscoveryStep { settings, glossary, howTo }

/// Today sections a person may hide. The weight and measurement areas are
/// always there (they hold the person's numbers); Settings stays one click
/// away in the top bar whatever is hidden.
enum TodaySection { sleep, feeling, tools, yourData, buildFacts }

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
    this.startScreen = StartScreen.today,
    this.density = Density.comfortable,
    this.highContrast = false,
    this.font = FontChoice.system,
    this.wideSpacing = false,
    this.reduceMotion = false,
    this.measurementsFirst = false,
    this.showAion = true,
    this.units = UnitSystem.metric,
    this.dateOrder = DateOrder.iso,
    this.clock = ClockStyle.h24,
    this.firstRunDone = false,
    this.interfacePercent = 100,
    this.discoveryEnabled = true,
    this.discovered = const {},
  });

  /// Whole-interface scale, independent of text-only and device scaling.
  final int interfacePercent;
  final bool discoveryEnabled;
  final Set<DiscoveryStep> discovered;

  /// Invalid persisted or typed values never replace a valid preference.
  static int? parseInterfacePercent(String input) {
    final n = int.tryParse(input.trim());
    return n != null && n >= 80 && n <= 200 ? n : null;
  }

  AppearanceSettings visit(DiscoveryStep step) =>
      !discoveryEnabled || discovered.contains(step)
      ? this
      : copyWith(discovered: {...discovered, step});

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

  final StartScreen startScreen;
  final Density density;

  /// Darker text and stronger edges, on top of the device's own settings.
  final bool highContrast;

  final FontChoice font;

  /// More space between letters, words and lines.
  final bool wideSpacing;

  /// Pages open without sliding or zooming (the device setting "remove
  /// animations" does the same on its own).
  final bool reduceMotion;

  /// Today shows Measurements before the weight card (a Today layout
  /// choice; Reset Today clears it).
  final bool measurementsFirst;

  /// Aion, the Human OS character, on the introduction and empty states
  /// (a still picture; it gives no advice).
  final bool showAion;

  /// Metric as typed, or US units shown beside them (display only).
  final UnitSystem units;

  final DateOrder dateOrder;
  final ClockStyle clock;

  /// The short introduction was finished or skipped.
  final bool firstRunDone;

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
    interfacePercent: interfacePercent,
    discoveryEnabled: discoveryEnabled,
    discovered: discovered,
    language: language,
    theme: theme,
    accent: accent,
    textSize: textSize,
    startScreen: startScreen,
    density: density,
    highContrast: highContrast,
    font: font,
    wideSpacing: wideSpacing,
    reduceMotion: reduceMotion,
    showAion: showAion,
    units: units,
    dateOrder: dateOrder,
    clock: clock,
    firstRunDone: firstRunDone,
  );

  /// Multiplies the text size the system asks for.
  double get textFactor => switch (textSize) {
    TextSizeChoice.system => 1.0,
    TextSizeChoice.larger => 1.15,
    TextSizeChoice.largest => 1.3,
  };

  AppearanceSettings copyWith({
    int? interfacePercent,
    bool? discoveryEnabled,
    Set<DiscoveryStep>? discovered,
    LanguageChoice? language,
    ThemeChoice? theme,
    AccentChoice? accent,
    TextSizeChoice? textSize,
    List<String>? tileOrder,
    Set<String>? hiddenTiles,
    Set<TodaySection>? hiddenSections,
    bool? padOpen,
    StartScreen? startScreen,
    Density? density,
    bool? highContrast,
    FontChoice? font,
    bool? wideSpacing,
    bool? reduceMotion,
    bool? measurementsFirst,
    bool? showAion,
    UnitSystem? units,
    DateOrder? dateOrder,
    ClockStyle? clock,
    bool? firstRunDone,
  }) => AppearanceSettings(
    interfacePercent: interfacePercent ?? this.interfacePercent,
    discoveryEnabled: discoveryEnabled ?? this.discoveryEnabled,
    discovered: discovered ?? this.discovered,
    language: language ?? this.language,
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    textSize: textSize ?? this.textSize,
    tileOrder: tileOrder ?? this.tileOrder,
    hiddenTiles: hiddenTiles ?? this.hiddenTiles,
    hiddenSections: hiddenSections ?? this.hiddenSections,
    padOpen: padOpen ?? this.padOpen,
    startScreen: startScreen ?? this.startScreen,
    density: density ?? this.density,
    highContrast: highContrast ?? this.highContrast,
    font: font ?? this.font,
    wideSpacing: wideSpacing ?? this.wideSpacing,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    measurementsFirst: measurementsFirst ?? this.measurementsFirst,
    showAion: showAion ?? this.showAion,
    units: units ?? this.units,
    dateOrder: dateOrder ?? this.dateOrder,
    clock: clock ?? this.clock,
    firstRunDone: firstRunDone ?? this.firstRunDone,
  );

  Map<String, Object?> toJson() => {
    'format': 'hhos.appearance',
    'version': 1,
    'interfacePercent': interfacePercent,
    'discoveryEnabled': discoveryEnabled,
    'discovered': [for (final step in discovered) step.name]..sort(),
    'language': language.name,
    'theme': theme.name,
    'accent': accent.name,
    'textSize': textSize.name,
    'tileOrder': tileOrder,
    'hiddenTiles': hiddenTiles.toList()..sort(),
    'hiddenSections': [for (final s in hiddenSections) s.name]..sort(),
    'padOpen': padOpen,
    'startScreen': startScreen.name,
    'density': density.name,
    'highContrast': highContrast,
    'font': font.name,
    'wideSpacing': wideSpacing,
    'reduceMotion': reduceMotion,
    'measurementsFirst': measurementsFirst,
    'showAion': showAion,
    'units': units.name,
    'dateOrder': dateOrder.name,
    'clock': clock.name,
    'firstRunDone': firstRunDone,
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
      interfacePercent:
          parseInterfacePercent('${json['interfacePercent']}') ?? 100,
      discoveryEnabled: json['discoveryEnabled'] != false,
      discovered: {
        for (final name in strings(json['discovered']))
          for (final step in DiscoveryStep.values)
            if (step.name == name) step,
      },
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
      startScreen: pick(
        StartScreen.values,
        json['startScreen'],
        StartScreen.today,
      ),
      density: pick(Density.values, json['density'], Density.comfortable),
      highContrast: json['highContrast'] == true,
      font: pick(FontChoice.values, json['font'], FontChoice.system),
      wideSpacing: json['wideSpacing'] == true,
      reduceMotion: json['reduceMotion'] == true,
      measurementsFirst: json['measurementsFirst'] == true,
      showAion: json['showAion'] != false,
      units: pick(UnitSystem.values, json['units'], UnitSystem.metric),
      dateOrder: pick(DateOrder.values, json['dateOrder'], DateOrder.iso),
      clock: pick(ClockStyle.values, json['clock'], ClockStyle.h24),
      firstRunDone: json['firstRunDone'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppearanceSettings &&
      other.interfacePercent == interfacePercent &&
      other.discoveryEnabled == discoveryEnabled &&
      _sameSet(other.discovered, discovered) &&
      other.language == language &&
      other.theme == theme &&
      other.accent == accent &&
      other.textSize == textSize &&
      _sameList(other.tileOrder, tileOrder) &&
      _sameSet(other.hiddenTiles, hiddenTiles) &&
      _sameSet(other.hiddenSections, hiddenSections) &&
      other.padOpen == padOpen &&
      other.startScreen == startScreen &&
      other.density == density &&
      other.highContrast == highContrast &&
      other.font == font &&
      other.wideSpacing == wideSpacing &&
      other.reduceMotion == reduceMotion &&
      other.measurementsFirst == measurementsFirst &&
      other.showAion == showAion &&
      other.units == units &&
      other.dateOrder == dateOrder &&
      other.clock == clock &&
      other.firstRunDone == firstRunDone;

  @override
  int get hashCode => Object.hash(
    interfacePercent,
    discoveryEnabled,
    discovered.length,
    language,
    theme,
    accent,
    textSize,
    Object.hashAll(tileOrder),
    hiddenTiles.length,
    hiddenSections.length,
    padOpen,
    Object.hash(
      startScreen,
      density,
      highContrast,
      font,
      wideSpacing,
      reduceMotion,
      measurementsFirst,
      showAion,
      units,
      dateOrder,
      clock,
      firstRunDone,
    ),
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
