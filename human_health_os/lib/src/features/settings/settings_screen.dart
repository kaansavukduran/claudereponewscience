import 'package:flutter/material.dart';

import '../../app/appearance_scope.dart';
import '../../domain/settings/appearance.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../today/measurements_card.dart';
import '../../presentation/theme/human_os_theme.dart';

/// Language, light or dark, accent colour and text size (U005). Every choice
/// applies at once and is one click; nothing here touches health data.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final controller = AppearanceScope.maybeOf(context);
    final a = controller?.value ?? const AppearanceSettings();
    void set(AppearanceSettings next) => controller?.update(next);

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: text.titleMedium)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );

    Widget choices<T>(
      String keyPrefix,
      List<(T, String)> options,
      T current,
      void Function(T) onPick,
    ) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (value, label) in options)
          ChoiceChip(
            key: ValueKey('$keyPrefix-${(value as Enum).name}'),
            label: Text(label),
            selected: value == current,
            onSelected: (_) => onPick(value),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(s.settingsTitle)),
      body: ListView(
        key: const ValueKey('screen-settings'),
        padding: const EdgeInsets.all(16),
        children: [
          section(
            s.settingsLanguage,
            choices(
              'set-language',
              [
                (LanguageChoice.tr, 'Türkçe'),
                (LanguageChoice.en, 'English'),
                (LanguageChoice.system, s.settingsSystem),
              ],
              a.language,
              (v) => set(a.copyWith(language: v)),
            ),
          ),
          section(
            s.settingsTheme,
            choices(
              'set-theme',
              [
                (ThemeChoice.light, s.settingsLight),
                (ThemeChoice.dark, s.settingsDark),
                (ThemeChoice.system, s.settingsSystem),
              ],
              a.theme,
              (v) => set(a.copyWith(theme: v)),
            ),
          ),
          section(
            s.settingsAccent,
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in AccentChoice.values)
                  _AccentSwatch(
                    choice: c,
                    label: s.accentName(c),
                    selected: a.accent == c,
                    onTap: () => set(a.copyWith(accent: c)),
                  ),
              ],
            ),
          ),
          section(
            s.settingsTextSize,
            choices(
              'set-text',
              [
                (TextSizeChoice.system, s.settingsSystem),
                (TextSizeChoice.larger, s.settingsLarger),
                (TextSizeChoice.largest, s.settingsLargest),
              ],
              a.textSize,
              (v) => set(a.copyWith(textSize: v)),
            ),
          ),
          section(
            s.settingsFont,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                choices(
                  'set-font',
                  [
                    (FontChoice.system, s.settingsSystem),
                    (FontChoice.legible, s.fontLegible),
                    (FontChoice.dyslexic, s.fontDyslexic),
                  ],
                  a.font,
                  (v) => set(a.copyWith(font: v)),
                ),
                SwitchListTile(
                  key: const ValueKey('set-wide-spacing'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.settingsWideSpacing),
                  value: a.wideSpacing,
                  onChanged: (on) => set(a.copyWith(wideSpacing: on)),
                ),
              ],
            ),
          ),
          section(
            s.settingsUnits,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                choices(
                  'set-units',
                  [
                    (UnitSystem.metric, s.unitsMetric),
                    (UnitSystem.us, s.unitsUs),
                  ],
                  a.units,
                  (v) => set(a.copyWith(units: v)),
                ),
                const SizedBox(height: 4),
                Text(s.unitsNote, style: text.bodySmall),
              ],
            ),
          ),
          section(
            s.settingsSpacing,
            choices(
              'set-density',
              [
                (Density.comfortable, s.settingsComfortable),
                (Density.compact, s.settingsCompact),
              ],
              a.density,
              (v) => set(a.copyWith(density: v)),
            ),
          ),
          section(
            s.settingsContrast,
            SwitchListTile(
              key: const ValueKey('set-high-contrast'),
              contentPadding: EdgeInsets.zero,
              title: Text(s.settingsHighContrast),
              value: a.highContrast,
              onChanged: (on) => set(a.copyWith(highContrast: on)),
            ),
          ),
          section(
            s.settingsStart,
            choices(
              'set-start',
              [
                (StartScreen.today, s.startScreenName(StartScreen.today)),
                (StartScreen.timeline, s.startScreenName(StartScreen.timeline)),
                (StartScreen.labs, s.startScreenName(StartScreen.labs)),
              ],
              a.startScreen,
              (v) => set(a.copyWith(startScreen: v)),
            ),
          ),
          section(s.settingsToday, _TodayLayout(settings: a, onChange: set)),
          Text(
            controller?.saveFailed == true
                ? s.settingsSaveFailed
                : (controller?.store.persistent ?? false)
                ? s.settingsSaved
                : s.settingsSessionOnly,
            key: const ValueKey('settings-persistence'),
            style: text.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.choice,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AccentChoice choice;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tones = accentTones[choice]!;
    final color = dark ? tones.$2 : tones.$1;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('set-accent-${choice.name}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? scheme.onSurface : scheme.outlineVariant,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check, color: scheme.onPrimary, size: 22)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Which measurement tiles show and in what order, which sections show,
/// and whether the number pad starts open. Up and Down buttons keep the
/// order reachable with the mouse alone (no drag).
class _TodayLayout extends StatelessWidget {
  const _TodayLayout({required this.settings, required this.onChange});

  final AppearanceSettings settings;
  final void Function(AppearanceSettings) onChange;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final defaults = [for (final k in MeasurementsCard.kinds) k.code];
    final order = settings.ordered(defaults);
    RecordKind kindOf(String c) =>
        MeasurementsCard.kinds.firstWhere((k) => k.code == c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.settingsTiles, style: text.bodyMedium),
        const SizedBox(height: 4),
        for (var i = 0; i < order.length; i++)
          Row(
            key: ValueKey('set-tile-${order[i]}'),
            children: [
              // One node for the screen reader: "Blood pressure, checked".
              Expanded(
                child: MergeSemantics(
                  child: Row(
                    children: [
                      Checkbox(
                        key: ValueKey('set-tile-show-${order[i]}'),
                        value: !settings.hiddenTiles.contains(order[i]),
                        onChanged: (on) {
                          final hidden = {...settings.hiddenTiles};
                          on == true
                              ? hidden.remove(order[i])
                              : hidden.add(order[i]);
                          onChange(settings.copyWith(hiddenTiles: hidden));
                        },
                      ),
                      Expanded(child: Text(s.recordKind(kindOf(order[i])))),
                    ],
                  ),
                ),
              ),
              IconButton(
                key: ValueKey('set-tile-up-${order[i]}'),
                tooltip: s.settingsMoveUp(s.recordKind(kindOf(order[i]))),
                icon: const Icon(Icons.arrow_upward),
                onPressed: i == 0
                    ? null
                    : () => onChange(settings.move(defaults, order[i], -1)),
              ),
              IconButton(
                key: ValueKey('set-tile-down-${order[i]}'),
                tooltip: s.settingsMoveDown(s.recordKind(kindOf(order[i]))),
                icon: const Icon(Icons.arrow_downward),
                onPressed: i == order.length - 1
                    ? null
                    : () => onChange(settings.move(defaults, order[i], 1)),
              ),
            ],
          ),
        const SizedBox(height: 12),
        Text(s.settingsSections, style: text.bodyMedium),
        for (final x in TodaySection.values)
          SwitchListTile(
            key: ValueKey('set-section-${x.name}'),
            contentPadding: EdgeInsets.zero,
            title: Text(s.todaySectionName(x)),
            value: !settings.hiddenSections.contains(x),
            onChanged: (on) {
              final hidden = {...settings.hiddenSections};
              on ? hidden.remove(x) : hidden.add(x);
              onChange(settings.copyWith(hiddenSections: hidden));
            },
          ),
        SwitchListTile(
          key: const ValueKey('set-pad-open'),
          contentPadding: EdgeInsets.zero,
          title: Text(s.settingsPadOpen),
          value: settings.padOpen,
          onChanged: (on) => onChange(settings.copyWith(padOpen: on)),
        ),
        const SizedBox(height: 4),
        OutlinedButton(
          key: const ValueKey('set-reset-today'),
          onPressed: () => onChange(settings.resetToday()),
          child: Text(s.settingsResetToday),
        ),
      ],
    );
  }
}
