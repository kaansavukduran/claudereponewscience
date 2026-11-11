import 'package:flutter/material.dart';

import '../../l10n/strings.dart';

/// A bottom-sheet form whose fields scroll while its buttons stay in view
/// (G-74): Save and Cancel never scroll away under long forms, large text
/// or a narrow window. The keyboard, when open, lifts the whole sheet; the
/// system's bottom area is kept clear otherwise (never both).
class SheetFrame extends StatelessWidget {
  const SheetFrame({super.key, required this.fields, required this.actions});

  final List<Widget> fields;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bottom = keyboard > 0
        ? keyboard
        : MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: fields,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Wrap(spacing: 8, runSpacing: 8, children: actions),
          ),
        ],
      ),
    );
  }
}

/// An instant as it would be typed: local `YYYY-MM-DD HH:MM`.
String typedLocal(DateTime utc) => typedWall(utc.toLocal());

/// Local wall-clock fields as typed: `YYYY-MM-DD HH:MM`.
String typedWall(DateTime local) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
      '${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

/// Quick picks that fill a time field, so a time can be given by clicking
/// (G-74). Each pick only writes text into the field; the usual rules check
/// it on Save. A pick in the future is shown disabled.
class TimePicks extends StatelessWidget {
  const TimePicks({
    super.key,
    required this.keyPrefix,
    required this.controller,
    required this.picks,
    this.onPicked,
  });

  final String keyPrefix;
  final TextEditingController controller;

  /// (label, text to write, enabled).
  final List<(String, String, bool)> picks;
  final VoidCallback? onPicked;

  /// Now, an hour ago, this morning 08:00, yesterday 20:00.
  static List<(String, String, bool)> recent(S s, {DateTime? now}) {
    final t = now ?? DateTime.now();
    final today8 = DateTime(t.year, t.month, t.day, 8);
    return [
      (s.presetNow, '', true),
      (s.presetHourAgo, typedWall(t.subtract(const Duration(hours: 1))), true),
      (s.presetMorning, typedWall(today8), today8.isBefore(t)),
      (
        s.presetYesterdayEvening,
        typedWall(DateTime(t.year, t.month, t.day - 1, 20)),
        true,
      ),
    ];
  }

  /// Clock times only (`HH:MM`), for a time whose day the service works out
  /// (going to bed before waking).
  static List<(String, String, bool)> clock(List<String> times) => [
    for (final t in times) (t, t, true),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        container: true,
        label: s.timePresetsLabel,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (label, value, enabled) in picks)
              ActionChip(
                key: ValueKey('$keyPrefix-pick-$label'),
                label: Text(label),
                onPressed: enabled
                    ? () {
                        controller.text = value;
                        onPicked?.call();
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
