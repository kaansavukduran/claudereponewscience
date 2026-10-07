/// Responsive shell (v0.32 F001): primary navigation is exactly Today,
/// Timeline and Labs — a navigation rail at ≥ 840 dp (extended labels at
/// ≥ 1200 dp) and a compact bottom bar below that. The planned placeholder
/// areas are a secondary group: a labelled section under the rail, and the
/// "More" sheet on the bar (conflict C-8).
library;

import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../features/common/planned_destination_screen.dart';
import '../features/labs/labs_screen.dart';
import '../features/timeline/timeline_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/strings.dart';
import '../presentation/widgets/build_profile_banner.dart';
import 'destinations.dart';

const double kRailBreakpoint = 840;
const double kExtendedRailBreakpoint = 1200;

/// Rail widths shared by the primary destinations and the planned group.
const double kRailMinWidth = 80;
const double kRailMinExtendedWidth = 256;

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.services});

  final AppServices services;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  DestinationId _current = DestinationId.today;

  void _go(DestinationId id) => setState(() => _current = id);

  Widget _screenFor(DestinationId id) {
    return switch (id) {
      DestinationId.today => TodayScreen(services: widget.services),
      DestinationId.timeline => TimelineScreen(services: widget.services),
      DestinationId.labs => LabsScreen(services: widget.services),
      _ => PlannedDestinationScreen(destination: destinationById(id)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final body = KeyedSubtree(
      key: ValueKey(_current),
      child: _screenFor(_current),
    );
    final wide = width >= kRailBreakpoint;

    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle), centerTitle: false),
      // The profile banner sits above the content and takes the height its
      // text needs, so no clause is cut at large text sizes (audit UX-1).
      body: Column(
        children: [
          BuildProfileBanner(config: widget.services.config),
          Expanded(child: _content(wide, width, body)),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : _CompactBar(current: _current, onSelect: _go),
    );
  }

  Widget _content(bool wide, double width, Widget body) {
    return SafeArea(
      top: false,
      child: wide
          ? Row(
              children: [
                _ScrollableRail(
                  extended: width >= kExtendedRailBreakpoint,
                  current: _current,
                  onSelect: _go,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: body,
                    ),
                  ),
                ),
              ],
            )
          : body,
    );
  }
}

class _ScrollableRail extends StatelessWidget {
  const _ScrollableRail({
    required this.extended,
    required this.current,
    required this.onSelect,
  });

  final bool extended;
  final DestinationId current;
  final ValueChanged<DestinationId> onSelect;

  @override
  Widget build(BuildContext context) {
    final lang = langOf(context);
    final primary = kPrimaryDestinations.map(destinationById).toList();
    final selected = kPrimaryDestinations.indexOf(current);
    // `scrollable` lets the framework scroll destinations + the planned group
    // on short windows (an IntrinsicHeight wrapper under-measured the
    // trailing group and overflowed at 1024×700).
    return NavigationRail(
      key: const ValueKey('nav-rail'),
      scrollable: true,
      minWidth: kRailMinWidth,
      minExtendedWidth: kRailMinExtendedWidth,
      extended: extended,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      // A planned area is open: no primary item is selected.
      selectedIndex: selected >= 0 ? selected : null,
      onDestinationSelected: (i) => onSelect(primary[i].id),
      destinations: [
        for (final d in primary)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label(lang)),
          ),
      ],
      trailing: _PlannedRailGroup(
        extended: extended,
        current: current,
        onSelect: onSelect,
      ),
    );
  }
}

/// Secondary, clearly labelled group of planned areas under the rail.
class _PlannedRailGroup extends StatelessWidget {
  const _PlannedRailGroup({
    required this.extended,
    required this.current,
    required this.onSelect,
  });

  final bool extended;
  final DestinationId current;
  final ValueChanged<DestinationId> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final width = extended ? kRailMinExtendedWidth : kRailMinWidth;
    return SizedBox(
      key: const ValueKey('rail-planned-group'),
      width: width,
      child: Column(
        crossAxisAlignment: extended
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          const Divider(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: extended ? 30 : 4),
            child: Semantics(
              header: true,
              child: Text(
                s.plannedGroup,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          for (final d in plannedDestinations)
            _PlannedRailItem(
              destination: d,
              extended: extended,
              selected: d.id == current,
              onTap: () => onSelect(d.id),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PlannedRailItem extends StatelessWidget {
  const _PlannedRailItem({
    required this.destination,
    required this.extended,
    required this.selected,
    required this.onTap,
  });

  final Destination destination;
  final bool extended;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    final label = destination.label(langOf(context));
    final icon = Icon(
      selected ? destination.selectedIcon : destination.icon,
      size: 20,
      color: color,
    );
    final style = theme.textTheme.labelMedium?.copyWith(color: color);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        key: ValueKey('rail-planned-${destination.id.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // At least 48 dp tall: the touch-target guideline (audit UX-4).
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            // Left inset 30 centres the 20 dp icon on the primary icons' axis.
            padding: extended
                ? const EdgeInsets.fromLTRB(30, 10, 16, 10)
                : const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: extended
                ? Row(
                    children: [
                      icon,
                      const SizedBox(width: 12),
                      Expanded(child: Text(label, style: style)),
                    ],
                  )
                : Column(
                    children: [
                      icon,
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CompactBar extends StatelessWidget {
  const _CompactBar({required this.current, required this.onSelect});

  final DestinationId current;
  final ValueChanged<DestinationId> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final primary = kPrimaryDestinations.map(destinationById).toList();
    final inPrimary = kPrimaryDestinations.indexOf(current);
    return NavigationBar(
      key: const ValueKey('nav-bar'),
      selectedIndex: inPrimary >= 0 ? inPrimary : primary.length,
      onDestinationSelected: (i) async {
        if (i < primary.length) {
          onSelect(primary[i].id);
          return;
        }
        final picked = await showModalBottomSheet<DestinationId>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: ListView(
              key: const ValueKey('more-sheet'),
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Semantics(
                    header: true,
                    child: Text(
                      s.plannedGroup,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                for (final d in plannedDestinations)
                  ListTile(
                    // The open area is marked by icon shape and a check, not
                    // by colour alone (audit UX-5).
                    leading: Icon(d.id == current ? d.selectedIcon : d.icon),
                    trailing: d.id == current ? const Icon(Icons.check) : null,
                    title: Text(d.label(s.lang)),
                    selected: d.id == current,
                    onTap: () => Navigator.of(context).pop(d.id),
                  ),
              ],
            ),
          ),
        );
        if (picked != null) onSelect(picked);
      },
      destinations: [
        for (final d in primary)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label(s.lang),
          ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          label: s.more,
        ),
      ],
    );
  }
}
