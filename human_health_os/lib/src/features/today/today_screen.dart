import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../core/capabilities.dart';
import '../../l10n/strings.dart';
import '../../navigation/destinations.dart';
import '../../presentation/widgets/status_chip.dart';
import 'weight_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final today = destinationById(DestinationId.today);
    return ListView(
      key: const ValueKey('screen-today'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(today.label(s.lang), style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(s.todayIntro, style: text.bodyLarge),
        const SizedBox(height: 8),
        Wrap(
          key: const ValueKey('today-planned'),
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(s.checkInsAndMissions, style: text.bodyMedium),
            StatusChip(
              label: s.plannedIn(today.plannedForge!),
              tone: StatusTone.muted,
            ),
          ],
        ),
        const SizedBox(height: 16),
        WeightCard(services: services),
        const SizedBox(height: 12),
        _Section(
          title: s.thisBuild,
          child: Column(
            children: [
              _KeyValue(s.profile, services.config.profile.name.toUpperCase()),
              _KeyValue(s.version, services.config.version),
              _KeyValue(s.platform, services.registry.platform.name),
              _KeyValue(s.sourceRevision, services.config.shortRevision),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Section(
          title: s.capabilities,
          child: Column(
            children: [
              for (final c in services.registry.capabilities)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.label, style: text.titleSmall),
                            Text(c.detail, style: text.bodySmall),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(
                        label: switch (c.status) {
                          CapabilityStatus.available => s.available,
                          CapabilityStatus.notImplemented => s.notImplemented,
                          CapabilityStatus.notRequired => s.notRequired,
                          CapabilityStatus.unsupportedOnPlatform =>
                            s.unsupported,
                        },
                        tone: switch (c.status) {
                          CapabilityStatus.available => StatusTone.ok,
                          CapabilityStatus.notImplemented => StatusTone.muted,
                          CapabilityStatus.notRequired => StatusTone.ok,
                          CapabilityStatus.unsupportedOnPlatform =>
                            StatusTone.info,
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Keep child semantics separate so headings are not merged with body text.
      semanticContainer: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.k, this.v);

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(k, style: text.bodyMedium)),
          Text(
            v,
            style: text.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
