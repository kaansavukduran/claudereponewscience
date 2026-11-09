import 'package:flutter/material.dart';

import '../../app/appearance_scope.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/strings.dart';
import '../guide/glossary_screen.dart';
import '../help/how_to_screen.dart';
import '../settings/settings_screen.dart';

/// A calm, optional milestone for exploring the app, unrelated to health
/// results or the number of measurements a person enters.
class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppearanceScope.maybeOf(context);
    final a = controller?.value ?? const AppearanceSettings();
    final s = S.of(context);
    return Card(
      key: const ValueKey('discovery-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                s.discoveryTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.discoveryCount(a.discovered.length),
              key: const ValueKey('discovery-count'),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: a.discovered.length / DiscoveryStep.values.length,
              semanticsLabel:
                  '${s.discoveryTitle}: ${s.discoveryCount(a.discovered.length)}',
            ),
            const SizedBox(height: 8),
            Text(s.discoveryNote),
            for (final step in DiscoveryStep.values)
              ListTile(
                key: ValueKey('discovery-${step.name}'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  a.discovered.contains(step)
                      ? Icons.check_circle_outline
                      : Icons.circle_outlined,
                ),
                title: Text(s.discoveryStep(step)),
                subtitle: a.discovered.contains(step)
                    ? Text(s.discoveryVisited)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (step != DiscoveryStep.glossary) controller?.visit(step);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => switch (step) {
                        DiscoveryStep.settings => const SettingsScreen(),
                        DiscoveryStep.glossary => const GlossaryScreen(),
                        DiscoveryStep.howTo => const HowToScreen(),
                      },
                    ),
                  );
                },
              ),
            TextButton(
              key: const ValueKey('discovery-hide'),
              onPressed: () =>
                  controller?.update(a.copyWith(discoveryEnabled: false)),
              child: Text(s.discoveryHide),
            ),
          ],
        ),
      ),
    );
  }
}
