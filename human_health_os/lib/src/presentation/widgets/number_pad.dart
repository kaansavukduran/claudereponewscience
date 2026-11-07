import 'package:flutter/material.dart';

import '../../l10n/strings.dart';

/// Digits, a decimal separator and delete, for people who use only the
/// mouse (U001, U007). Nothing is pre-filled: the keys type into whatever
/// [target] returns (the field chosen last). Keys are `<keyPrefix>-1`…
/// `<keyPrefix>-0`, `<keyPrefix>-dec`, `<keyPrefix>-del`.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.target,
    required this.onChanged,
    this.keyPrefix = 'pad',
  });

  final TextEditingController Function() target;
  final VoidCallback onChanged;
  final String keyPrefix;

  void _type(String c) {
    final ctl = target();
    ctl.text = '${ctl.text}$c';
    ctl.selection = TextSelection.collapsed(offset: ctl.text.length);
    onChanged();
  }

  void _delete() {
    final ctl = target();
    if (ctl.text.isEmpty) return;
    final runes = ctl.text.runes.toList()..removeLast();
    ctl.text = String.fromCharCodes(runes);
    ctl.selection = TextSelection.collapsed(offset: ctl.text.length);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final sep = s.lang == AppLang.tr ? ',' : '.';
    Widget key(String id, String label, String semantic, VoidCallback onTap) =>
        SizedBox(
          key: ValueKey('$keyPrefix-$id'),
          width: 64,
          height: 48,
          child: Semantics(
            button: true,
            label: semantic,
            excludeSemantics: true,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(label),
            ),
          ),
        );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var d = 1; d <= 9; d++)
          key('$d', '$d', s.numberPadDigit(d), () => _type('$d')),
        key('dec', sep, s.numberPadDecimal, () => _type(sep)),
        key('0', '0', s.numberPadDigit(0), () => _type('0')),
        key('del', '⌫', s.numberPadDelete, _delete),
      ],
    );
  }
}
