import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../l10n/strings.dart';

/// Visible on every non-production build so test builds are never mistaken
/// for a release (v0.27 doc 209 item 4).
class BuildProfileBanner extends StatelessWidget {
  const BuildProfileBanner({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    if (config.isProduction) return const SizedBox.shrink();
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = config.profile == BuildProfile.staging
        ? s.stagingBanner
        : s.devBanner;
    return Semantics(
      container: true,
      label: text,
      child: ExcludeSemantics(
        child: Container(
          key: const ValueKey('build-profile-banner'),
          width: double.infinity,
          color: scheme.tertiaryContainer,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.construction,
                size: 16,
                color: scheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                // No line limit: the banner grows instead of cutting the
                // clinical clause or the profile name.
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: scheme.onTertiaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
