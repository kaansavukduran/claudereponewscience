import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/aion.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// Nutrition (F007 slice 5): what the person ate or drank, in their words,
/// with nutrients only as copied from a label. A nutrient not given is not
/// known, never zero; nothing is added up, rated or advised; no database.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<HealthRecord>? _entries;

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final entries = await _svc.foods(_me);
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _add({HealthRecord? correcting}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _FoodSheet(svc: _svc, me: _me, correcting: correcting),
    );
    if (saved == true) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final entries = _entries;
    return ListView(
      key: const ValueKey('screen-nutrition'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(s.foodTitle, style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(s.foodIntro, style: text.bodyMedium),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('food-add'),
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: Text(s.foodAdd),
          ),
        ),
        const SizedBox(height: 16),
        if (entries == null)
          const Center(child: CircularProgressIndicator())
        else if (entries.isEmpty)
          Row(
            children: [
              const AionFigure(height: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.foodNone, key: const ValueKey('food-none')),
              ),
            ],
          )
        else
          for (final r in entries)
            Card(
              key: ValueKey('food-entry-${r.id}'),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s.foodLine(r.details! as FoodEntryDetails)),
                // The button sits under the text, so a narrow window or large
                // text never squeezes the entry into a thin column.
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fmtWhen(r.observedAt),
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    TextButton(
                      key: ValueKey('food-correct-${r.id}'),
                      onPressed: () => _add(correcting: r),
                      child: Text(s.amendAction(AmendReason.correction)),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _FoodSheet extends StatefulWidget {
  const _FoodSheet({required this.svc, required this.me, this.correcting});

  final HeartbeatService svc;
  final String me;

  /// The shown version being corrected; null for a new entry.
  final HealthRecord? correcting;

  @override
  State<_FoodSheet> createState() => _FoodSheetState();
}

class _FoodSheetState extends State<_FoodSheet> {
  final _what = TextEditingController();
  final _amount = TextEditingController();
  final _when = TextEditingController();
  final _nutrients = {
    for (final n in PrintedNutrient.values) n: TextEditingController(),
  };
  LabelBasis? _per;
  String? _error;
  String? _errorField;
  bool _busy = false;

  /// The time the sheet opened with; left as is, the entry keeps its own
  /// time (to the second), not this minute.
  String? _shownWhen;

  @override
  void initState() {
    super.initState();
    final d = widget.correcting?.details;
    if (d is FoodEntryDetails) {
      _what.text = d.what;
      _amount.text = d.amount ?? '';
      _when.text = _shownWhen = _typed(widget.correcting!.observedAt);
      _per = d.per;
      for (final e in d.nutrients.entries) {
        _nutrients[e.key]!.text = e.value;
      }
    }
  }

  @override
  void dispose() {
    _what.dispose();
    _amount.dispose();
    _when.dispose();
    for (final c in _nutrients.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final s = S.of(context);
    setState(() => _busy = true);
    var saved = false;
    try {
      await widget.svc.recordFood(
        profileId: widget.me,
        what: _what.text,
        amount: _amount.text,
        when: _when.text == _shownWhen ? '' : _when.text,
        nutrients: {for (final e in _nutrients.entries) e.key: e.value.text},
        per: _per,
        correcting: widget.correcting?.id,
      );
      saved = true;
    } on InputError catch (e) {
      _error = s.inputError(e.code);
      _errorField = e.field;
    } finally {
      if (mounted) {
        if (saved) {
          Navigator.of(context).pop(true);
        } else {
          setState(() => _busy = false);
        }
      }
    }
  }

  Widget _field(
    String key,
    String label,
    TextEditingController c, {
    String? field,
    String? help,
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      key: ValueKey(key),
      controller: c,
      keyboardType: keyboard,
      onChanged: (_) {
        if (_error != null) {
          setState(() => _error = _errorField = null);
        }
      },
      textCapitalization: keyboard == null
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        helperText: _errorField == field ? null : help,
        helperMaxLines: 3,
        errorText: field != null && _errorField == field ? _error : null,
        errorMaxLines: 4,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    const number = TextInputType.numberWithOptions(decimal: true);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 +
            (keyboard > 0
                ? keyboard
                : MediaQuery.viewPaddingOf(context).bottom),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                widget.correcting == null ? s.foodAdd : s.foodCorrectTitle,
                style: text.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            _field('food-what', s.foodWhat, _what, field: 'what'),
            _field('food-amount', s.foodAmount, _amount, field: 'amount'),
            _field(
              'food-when',
              s.foodWhen,
              _when,
              field: 'when',
              help: s.foodWhenHelp,
              keyboard: TextInputType.datetime,
            ),
            const SizedBox(height: 4),
            Semantics(
              header: true,
              child: Text(s.foodLabelTitle, style: text.titleSmall),
            ),
            const SizedBox(height: 4),
            Text(s.foodLabelHelp, style: text.bodySmall),
            const SizedBox(height: 8),
            ExcludeSemantics(child: Text(s.foodPer)),
            const SizedBox(height: 4),
            Semantics(
              container: true,
              label: s.foodPer,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final b in LabelBasis.values)
                    ChoiceChip(
                      key: ValueKey('food-per-${b.name}'),
                      label: Text(s.foodBasis(b)),
                      selected: _per == b,
                      onSelected: (on) => setState(() => _per = on ? b : null),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final n in PrintedNutrient.values)
              _field(
                'food-n-${n.name}',
                s.foodNutrientField(n),
                _nutrients[n]!,
                field: 'nutrient-${n.name}',
                keyboard: number,
              ),
            // An error on no field of its own (or a field out of view) is
            // also said here, read out when it appears.
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  key: const ValueKey('food-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),
            // Save, and a visible way out without saving (mouse only).
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  key: const ValueKey('food-save'),
                  onPressed: _busy ? null : _save,
                  child: Text(s.save),
                ),
                TextButton(
                  key: const ValueKey('food-cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(s.cancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// An instant as it would be typed: local `YYYY-MM-DD HH:MM`.
String _typed(DateTime utc) {
  final t = utc.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)} '
      '${two(t.hour)}:${two(t.minute)}';
}
