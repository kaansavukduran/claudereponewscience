import 'package:flutter/material.dart';

import '../../l10n/strings.dart';

/// A plain-language guide for a first-time user (U001): what to click, in
/// order. Words only; no data is read or written here.
class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final steps = s.howToSteps;
    return Scaffold(
      appBar: AppBar(title: Text(s.howToTitle)),
      body: ListView(
        key: const ValueKey('screen-howto'),
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < steps.length; i++)
            Container(
              key: ValueKey('howto-step-${i + 1}'),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${i + 1}',
                      style: text.titleMedium?.copyWith(color: scheme.primary),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(steps[i].$1, style: text.titleSmall),
                        ),
                        const SizedBox(height: 4),
                        Text(steps[i].$2, style: text.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            s.howToNote,
            key: const ValueKey('howto-note'),
            style: text.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
