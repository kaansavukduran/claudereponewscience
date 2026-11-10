import 'package:flutter/material.dart';

import '../../app/appearance_scope.dart';
import '../../config/app_config.dart';
import '../../domain/settings/appearance.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../today/measurements_card.dart';
import '../../presentation/theme/human_os_theme.dart';
import '../onboarding/first_run_screen.dart';

/// Language, light or dark, accent colour and text size (U005). Every choice
/// applies at once and is one click; nothing here touches health data.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
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
          Text(s.settingsDeviceScope, style: text.bodySmall),
          const SizedBox(height: 8),
          Text(
            controller?.saveFailed == true
                ? s.settingsSaveFailed
                : (controller?.store.persistent ?? false)
                ? s.settingsSaved
                : s.settingsSessionOnly,
            key: const ValueKey('settings-persistence'),
            style: text.bodySmall,
          ),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(s.settingsAccessibility, style: text.titleLarge),
          ),
          const SizedBox(height: 16),
          section(
            s.settingsInterfaceScale,
            _ScaleControl(
              percent: a.interfacePercent,
              onChange: (v) => set(a.copyWith(interfacePercent: v)),
            ),
          ),
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
                SwitchListTile(
                  key: const ValueKey('set-reduce-motion'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.settingsReduceMotion),
                  value: a.reduceMotion,
                  onChanged: (on) => set(a.copyWith(reduceMotion: on)),
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
            s.settingsDates,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                choices(
                  'set-date',
                  [
                    (DateOrder.iso, '2026-11-08'),
                    (DateOrder.dayMonth, '08.11.2026'),
                    (DateOrder.monthDay, '11/08/2026'),
                  ],
                  a.dateOrder,
                  (v) => set(a.copyWith(dateOrder: v)),
                ),
                const SizedBox(height: 8),
                choices(
                  'set-clock',
                  [(ClockStyle.h24, '20:05'), (ClockStyle.h12, '8:05 PM')],
                  a.clock,
                  (v) => set(a.copyWith(clock: v)),
                ),
                const SizedBox(height: 4),
                Text(s.datesNote, style: text.bodySmall),
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
          section(
            s.discoveryTitle,
            SwitchListTile(
              key: const ValueKey('set-discovery'),
              contentPadding: EdgeInsets.zero,
              title: Text(s.discoveryEnabled),
              subtitle: Text(s.discoveryNote),
              value: a.discoveryEnabled,
              onChanged: (v) => set(a.copyWith(discoveryEnabled: v)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              key: const ValueKey('set-first-run'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) =>
                      FirstRunScreen(onDone: () => Navigator.of(ctx).pop()),
                ),
              ),
              child: Text(s.firstShowAgain),
            ),
          ),
          const SizedBox(height: 24),
          section(s.settingsUpdatesTitle, const _UpdatesAndAbout()),
        ],
      ),
    );
  }
}

/// The installed version and where newer ones are. The app makes no network
/// calls, so it says plainly that it cannot look for updates itself (k44
/// §10 asks for a check button; that needs an owner decision on network
/// use, G-71).
class _UpdatesAndAbout extends StatelessWidget {
  const _UpdatesAndAbout();

  static const releasesPage = 'github.com/kaansavukduran/human-os/releases';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final config = AppConfig.fromEnvironment();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.settingsInstalledVersion(config.version, config.shortRevision),
          key: const ValueKey('settings-version'),
          style: text.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(s.settingsUpdatesHow, key: const ValueKey('settings-updates-how')),
        const SizedBox(height: 4),
        const SelectableText(
          releasesPage,
          key: ValueKey('settings-releases-page'),
        ),
        const SizedBox(height: 8),
        Text(s.settingsUpdatesKeepData, style: text.bodySmall),
      ],
    );
  }
}

class _ScaleControl extends StatefulWidget {
  const _ScaleControl({required this.percent, required this.onChange});

  final int percent;
  final ValueChanged<int> onChange;

  @override
  State<_ScaleControl> createState() => _ScaleControlState();
}

class _ScaleControlState extends State<_ScaleControl> {
  late final _input = TextEditingController(text: '${widget.percent}');
  final _sliderFocus = FocusNode();
  bool _invalid = false;

  @override
  void didUpdateWidget(_ScaleControl old) {
    super.didUpdateWidget(old);
    if (old.percent != widget.percent) {
      _input.text = '${widget.percent}';
      _invalid = false;
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _sliderFocus.dispose();
    super.dispose();
  }

  void _apply() {
    final n = AppearanceSettings.parseInterfacePercent(_input.text);
    setState(() => _invalid = n == null);
    if (n != null) widget.onChange(n);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.interfacePercent(widget.percent),
          key: const ValueKey('interface-scale-value'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(s.interfaceScaleNote),
        Slider(
          key: const ValueKey('set-interface-slider'),
          focusNode: _sliderFocus,
          min: 80,
          max: 200,
          divisions: 24,
          // The exact input may fall between the slider's five-point stops.
          value: widget.percent.toDouble(),
          label: s.interfacePercent(widget.percent),
          semanticFormatterCallback: (v) => s.interfacePercent(v.round()),
          onChanged: (v) => widget.onChange(v.round()),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in [80, 100, 125, 150, 175, 200])
              ChoiceChip(
                key: ValueKey('set-interface-$n'),
                label: Text(s.interfacePercent(n)),
                selected: widget.percent == n,
                onSelected: (_) => widget.onChange(n),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('set-interface-input'),
          controller: _input,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: s.interfaceExact,
            suffixText: '%',
            errorText: _invalid ? s.interfaceInvalid : null,
          ),
          onSubmitted: (_) => _apply(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              key: const ValueKey('set-interface-apply'),
              onPressed: _apply,
              child: Text(s.interfaceApply),
            ),
            OutlinedButton(
              key: const ValueKey('set-interface-reset'),
              onPressed: () {
                setState(() {
                  _input.text = '100';
                  _invalid = false;
                });
                widget.onChange(100);
              },
              child: Text(s.interfaceReset),
            ),
          ],
        ),
      ],
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
        SwitchListTile(
          key: const ValueKey('set-measurements-first'),
          contentPadding: EdgeInsets.zero,
          title: Text(s.settingsMeasurementsFirst),
          value: settings.measurementsFirst,
          onChanged: (on) => onChange(settings.copyWith(measurementsFirst: on)),
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
