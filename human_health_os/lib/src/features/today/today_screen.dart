import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../app/appearance_scope.dart';
import '../../domain/settings/appearance.dart';
import '../../core/capabilities.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../navigation/destinations.dart';
import '../../presentation/widgets/status_chip.dart';
import '../genetics/genetics_screen.dart';
import '../guide/body_guide_screen.dart';
import '../guide/glossary_screen.dart';
import '../phyto/phyto_screen.dart';
import '../report/summary_screen.dart';
import '../help/how_to_screen.dart';
import '../settings/settings_screen.dart';
import 'measurements_card.dart';
import 'weight_card.dart';
import 'your_data_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final today = destinationById(DestinationId.today);
    final hidden =
        (AppearanceScope.maybeOf(context)?.value ?? const AppearanceSettings())
            .hiddenSections;
    bool show(TodaySection x) => !hidden.contains(x);
    return ListView(
      key: const ValueKey('screen-today'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(today.label(s.lang), style: text.headlineSmall),
        ),
        const SizedBox(height: 2),
        Text(
          s.dateLine(DateTime.now()),
          key: const ValueKey('today-date'),
          style: text.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 20),
        WeightCard(services: services),
        const SizedBox(height: 28),
        MeasurementsCard(services: services),
        const SizedBox(height: 28),
        if (show(TodaySection.tools)) ...[
          Semantics(
            container: true,
            header: true,
            child: Text(s.geneticsToolsTitle, style: text.titleMedium),
          ),
          const SizedBox(height: 12),
          _ToolGroup(s.toolsGroupApp),
          _ToolTile(
            key: const ValueKey('tool-settings'),
            icon: Icons.tune,
            title: s.settingsTitle,
            hint: s.settingsTileHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _ToolTile(
            key: const ValueKey('tool-howto'),
            icon: Icons.help_outline,
            title: s.howToTitle,
            hint: s.howToTileHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HowToScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _ToolTile(
            key: const ValueKey('tool-summary'),
            icon: Icons.assignment_outlined,
            title: s.summaryTitle,
            hint: s.summaryTileHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SummaryScreen(services: services),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ToolGroup(s.toolsGroupLearn),
          _ToolTile(
            key: const ValueKey('tool-glossary'),
            icon: Icons.menu_book_outlined,
            title: s.glossaryTitle,
            hint: s.glossaryTileHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const GlossaryScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _ToolTile(
            key: const ValueKey('tool-guide'),
            icon: Icons.accessibility_new,
            title: s.guideTitle,
            hint: s.guideTileHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BodyGuideScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _ToolGroup(s.toolsGroupFiles),
          _ToolTile(
            key: const ValueKey('tool-phyto'),
            icon: Icons.eco_outlined,
            title: s.phytoTitle,
            hint: s.phytoTileHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PhytoScreen(services: services),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _ToolTile(
            key: const ValueKey('tool-genetics'),
            icon: Icons.biotech_outlined,
            title: s.geneticsTitle,
            hint: s.geneticsTileHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GeneticsScreen(services: services),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
        if (show(TodaySection.yourData)) ...[
          YourDataCard(services: services),
          const SizedBox(height: 28),
        ],
        if (show(TodaySection.buildFacts)) ...[
          Wrap(
            key: const ValueKey('today-planned'),
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                s.checkInsAndMissions,
                style: text.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              StatusChip(
                label: s.plannedIn(today.plannedForge!),
                tone: StatusTone.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: s.thisBuild,
            child: Column(
              children: [
                _KeyValue(
                  s.profile,
                  services.config.profile.name.toUpperCase(),
                ),
                _KeyValue(s.version, services.config.version),
                _KeyValue(s.platform, services.registry.platform.name),
                _KeyValue(s.sourceRevision, services.config.shortRevision),
                _KeyValue(s.flutterVersion, services.config.flutterVersion),
                _KeyValue(s.dartVersion, services.config.dartVersion),
                _KeyValue(
                  s.recordSchema,
                  'v${HealthRecord.currentSchemaVersion}',
                ),
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
                        // May wrap: at 320 dp with 2x text a fixed chip
                        // overflowed the row (found by the F007 layout test).
                        Flexible(
                          child: StatusChip(
                            label: switch (c.status) {
                              CapabilityStatus.available => s.available,
                              CapabilityStatus.notImplemented =>
                                s.notImplemented,
                              CapabilityStatus.notRequired => s.notRequired,
                              CapabilityStatus.off => s.savingOff,
                              CapabilityStatus.unsupportedOnPlatform =>
                                s.unsupported,
                            },
                            tone: switch (c.status) {
                              CapabilityStatus.available => StatusTone.ok,
                              CapabilityStatus.notImplemented =>
                                StatusTone.muted,
                              CapabilityStatus.notRequired => StatusTone.ok,
                              CapabilityStatus.off => StatusTone.info,
                              CapabilityStatus.unsupportedOnPlatform =>
                                StatusTone.info,
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
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
      // Both sides may wrap: a long value (e.g. DEVELOPMENT at 2x text on a
      // 320 dp phone) overflowed a fixed-width value cell.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(k, style: text.bodyMedium)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.end,
              style: text.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small heading over a group of tools (G-65), announced as a heading.
class _ToolGroup extends StatelessWidget {
  const _ToolGroup(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}

/// A way into a tool that is not a daily number (G001).
class _ToolTile extends StatelessWidget {
  const _ToolTile({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: scheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          // A button for assistive technology and the browser, named by its
          // title and hint (an InkWell alone is only a tap target).
          child: Semantics(
            container: true,
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(icon, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: text.titleSmall),
                          Text(
                            hint,
                            style: text.bodySmall?.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: scheme.outline),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
