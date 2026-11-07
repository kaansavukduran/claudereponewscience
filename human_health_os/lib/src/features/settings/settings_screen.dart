import 'package:flutter/material.dart';

import '../../app/appearance_scope.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/strings.dart';
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
