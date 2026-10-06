import 'package:flutter/material.dart';

enum StatusTone { ok, info, warn, muted }

/// Icon + text chip: state is never encoded by colour alone.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, Color color) = switch (tone) {
      StatusTone.ok => (Icons.check_circle_outline, scheme.primary),
      StatusTone.info => (Icons.info_outline, scheme.tertiary),
      StatusTone.warn => (Icons.warning_amber_outlined, scheme.error),
      StatusTone.muted => (Icons.radio_button_unchecked, scheme.outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
