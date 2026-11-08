import 'package:flutter/material.dart';

import '../../app/appearance_scope.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/strings.dart';

/// A calm first run (U014): three short steps, each skippable, then Today.
/// It explains, sets language and look, and asks for nothing else.
class FirstRunScreen extends StatefulWidget {
  const FirstRunScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<FirstRunScreen> createState() => _FirstRunScreenState();
}

class _FirstRunScreenState extends State<FirstRunScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final controller = AppearanceScope.maybeOf(context);
    final a = controller?.value ?? const AppearanceSettings();
    void set(AppearanceSettings next) => controller?.update(next);

    Widget chips<T extends Enum>(
      String prefix,
      List<(T, String)> options,
      T current,
      void Function(T) pick,
    ) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (v, label) in options)
          ChoiceChip(
            key: ValueKey('first-$prefix-${v.name}'),
            label: Text(label),
            selected: v == current,
            onSelected: (_) => pick(v),
          ),
      ],
    );

    final (title, body) = switch (_step) {
      0 => (s.firstWelcomeTitle, s.firstWelcomeBody),
      1 => (s.firstPrivateTitle, s.firstPrivateBody),
      _ => (s.firstLookTitle, s.firstLookBody),
    };
    final last = _step == 2;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const ValueKey('screen-first-run'),
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              s.firstStep(_step + 1, 3),
              key: const ValueKey('first-step'),
              style: text.labelLarge?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: 12),
            Semantics(
              header: true,
              child: Text(title, style: text.headlineSmall),
            ),
            const SizedBox(height: 12),
            Text(body, style: text.bodyLarge),
            if (last) ...[
              const SizedBox(height: 20),
              Text(s.settingsLanguage, style: text.titleSmall),
              const SizedBox(height: 8),
              chips(
                'language',
                [
                  (LanguageChoice.tr, 'Türkçe'),
                  (LanguageChoice.en, 'English'),
                  (LanguageChoice.system, s.settingsSystem),
                ],
                a.language,
                (v) => set(a.copyWith(language: v)),
              ),
              const SizedBox(height: 16),
              Text(s.settingsTheme, style: text.titleSmall),
              const SizedBox(height: 8),
              chips(
                'theme',
                [
                  (ThemeChoice.light, s.settingsLight),
                  (ThemeChoice.dark, s.settingsDark),
                  (ThemeChoice.system, s.settingsSystem),
                ],
                a.theme,
                (v) => set(a.copyWith(theme: v)),
              ),
              const SizedBox(height: 16),
              Text(s.settingsFont, style: text.titleSmall),
              const SizedBox(height: 8),
              chips(
                'font',
                [
                  (FontChoice.system, s.settingsSystem),
                  (FontChoice.legible, s.fontLegible),
                  (FontChoice.dyslexic, s.fontDyslexic),
                ],
                a.font,
                (v) => set(a.copyWith(font: v)),
              ),
              const SizedBox(height: 8),
              Text(s.firstMoreInSettings, style: text.bodySmall),
            ],
            const SizedBox(height: 28),
            FilledButton(
              key: const ValueKey('first-next'),
              onPressed: last ? widget.onDone : () => setState(() => _step++),
              child: Text(last ? s.firstStart : s.firstNext),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_step > 0)
                  TextButton(
                    key: const ValueKey('first-back'),
                    onPressed: () => setState(() => _step--),
                    child: Text(s.firstBack),
                  ),
                const Spacer(),
                if (!last)
                  TextButton(
                    key: const ValueKey('first-skip'),
                    onPressed: widget.onDone,
                    child: Text(s.firstSkip),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
