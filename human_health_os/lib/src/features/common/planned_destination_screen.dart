import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../navigation/destinations.dart';
import '../../presentation/widgets/status_chip.dart';

/// Honest empty state for a destination whose FORGE has not run yet:
/// no fake data, no dead buttons — it says what the area will do and when.
class PlannedDestinationScreen extends StatelessWidget {
  const PlannedDestinationScreen({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lang = s.lang;
    final text = Theme.of(context).textTheme;
    return ListView(
      key: ValueKey('screen-${destination.id.name}'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(destination.label(lang), style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(destination.purpose(lang), style: text.bodyLarge),
        const SizedBox(height: 16),
        Card(
          // Keep child semantics separate so headings are not merged with body text.
          semanticContainer: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(label: s.notBuiltYet, tone: StatusTone.muted),
                    if (destination.plannedForge != null)
                      StatusChip(
                        label: s.plannedIn(destination.plannedForge!),
                        tone: StatusTone.info,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(s.noRecordsYet, style: text.titleMedium),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.rule,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        destination.principle(lang),
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
