/// Responsive shell: navigation rail at ≥ 840 dp (extended labels at ≥ 1200 dp),
/// compact bottom navigation below that, with the remaining destinations under "More".
library;

import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../features/common/planned_destination_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/strings.dart';
import '../presentation/widgets/build_profile_banner.dart';
import 'destinations.dart';

const double kRailBreakpoint = 840;
const double kExtendedRailBreakpoint = 1200;

/// Fits two lines of banner text (narrow phones, long Turkish copy).
const double kBuildBannerHeight = 44;

/// Destinations shown directly in the compact bottom bar; the rest live under "More".
const List<DestinationId> kCompactPrimary = [
  DestinationId.today,
  DestinationId.timeline,
  DestinationId.labs,
  DestinationId.medications,
];

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
    if (id == DestinationId.today) {
      return TodayScreen(services: widget.services);
    }
    return PlannedDestinationScreen(destination: destinationById(id));
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
      appBar: AppBar(
        title: Text(s.appTitle),
        centerTitle: false,
        bottom: widget.services.config.isProduction
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(kBuildBannerHeight),
                child: SizedBox(
                  height: kBuildBannerHeight,
                  child: BuildProfileBanner(config: widget.services.config),
                ),
              ),
      ),
      body: SafeArea(
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
      ),
      bottomNavigationBar: wide
          ? null
          : _CompactBar(current: _current, onSelect: _go),
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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: NavigationRail(
              key: const ValueKey('nav-rail'),
              extended: extended,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              selectedIndex: destinations.indexWhere((d) => d.id == current),
              onDestinationSelected: (i) => onSelect(destinations[i].id),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label(lang)),
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
    final primary = kCompactPrimary.map(destinationById).toList();
    final inPrimary = kCompactPrimary.indexOf(current);
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
                for (final d in destinations.where(
                  (d) => !kCompactPrimary.contains(d.id),
                ))
                  ListTile(
                    leading: Icon(d.icon),
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
