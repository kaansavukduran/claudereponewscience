import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/aion.dart';
import '../../presentation/widgets/sheet_parts.dart';

/// Conditions and symptoms (F009 slice 1): as the person names them, with
/// whether they are current, past or unsure and who they come from. A
/// self-report is not a confirmed diagnosis; nothing is coded, inferred,
/// confirmed or suggested.
class ConditionsScreen extends StatefulWidget {
  const ConditionsScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends State<ConditionsScreen> {
  List<HealthRecord>? _entries;

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final entries = await _svc.conditions(_me);
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _open({HealthRecord? correcting}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) =>
          _ConditionSheet(svc: _svc, me: _me, correcting: correcting),
    );
    if (saved == true) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final entries = _entries;
    return ListView(
      key: const ValueKey('screen-conditions'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(s.condTitle, style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(s.condIntro, style: text.bodyMedium),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('cond-add'),
            onPressed: _open,
            icon: const Icon(Icons.add),
            label: Text(s.condAdd),
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
                child: Text(s.condNone, key: const ValueKey('cond-none')),
              ),
            ],
          )
        else
          for (final r in entries)
            Card(
              key: ValueKey('cond-entry-${r.id}'),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s.condLine(r.details! as ConditionEntryDetails)),
                // Under the text, so a narrow window never squeezes it.
                subtitle: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: ValueKey('cond-correct-${r.id}'),
                    onPressed: () => _open(correcting: r),
                    child: Text(s.amendAction(AmendReason.correction)),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _ConditionSheet extends StatefulWidget {
  const _ConditionSheet({required this.svc, required this.me, this.correcting});

  final HeartbeatService svc;
  final String me;

  /// The shown version being corrected; null for a new entry.
  final HealthRecord? correcting;

  @override
  State<_ConditionSheet> createState() => _ConditionSheetState();
}

class _ConditionSheetState extends State<_ConditionSheet> {
  final _name = TextEditingController();
  final _since = TextEditingController();
  final _focus = FieldFocus();
  var _nature = ConditionType.condition;
  // Not sure until the person says: a state they did not choose is never
  // recorded for them.
  var _time = ConditionTime.unsure;
  var _source = ConditionSource.selfReported;
  String? _error;
  String? _errorField;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final d = widget.correcting?.details;
    if (d is ConditionEntryDetails) {
      _name.text = d.name;
      _since.text = d.since ?? '';
      _nature = d.nature;
      _time = d.time;
      _source = d.source;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _since.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final s = S.of(context);
    setState(() => _busy = true);
    var saved = false;
    try {
      await widget.svc.recordCondition(
        profileId: widget.me,
        name: _name.text,
        nature: _nature,
        time: _time,
        source: _source,
        since: _since.text,
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
          _focus.focusAfterFrame(this, _errorField);
        }
      }
    }
  }

  Widget _field(String key, String label, TextEditingController c, String f) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          key: ValueKey(key),
          controller: c,
          focusNode: _focus[f],
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_error != null) setState(() => _error = _errorField = null);
          },
          decoration: InputDecoration(
            labelText: label,
            errorText: _errorField == f ? _error : null,
            errorMaxLines: 4,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Widget _choice<T extends Enum>(
    String name,
    String label,
    List<T> values,
    T value,
    String Function(T) word,
    ValueChanged<T> onPick,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(
      container: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Text(label)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final v in values)
                ChoiceChip(
                  key: ValueKey('cond-$name-${v.name}'),
                  label: Text(word(v)),
                  selected: v == value,
                  onSelected: (_) => setState(() => onPick(v)),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SheetFrame(
      fields: [
        Semantics(
          header: true,
          child: Text(
            widget.correcting == null ? s.condAdd : s.condCorrectTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        _field('cond-name', s.condName, _name, 'name'),
        _choice(
          'nature',
          s.condNatureLabel,
          ConditionType.values,
          _nature,
          s.condNature,
          (v) => _nature = v,
        ),
        _choice(
          'time',
          s.condTimeLabel,
          ConditionTime.values,
          _time,
          s.condTime,
          (v) => _time = v,
        ),
        _choice(
          'source',
          s.condSourceLabel,
          ConditionSource.values,
          _source,
          s.condSource,
          (v) => _source = v,
        ),
        _field('cond-since', s.condSince, _since, 'since'),
        if (_error != null && _errorField != 'name' && _errorField != 'since')
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              key: const ValueKey('cond-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
      actions: [
        FilledButton(
          key: const ValueKey('cond-save'),
          onPressed: _busy ? null : _save,
          child: Text(s.save),
        ),
        TextButton(
          key: const ValueKey('cond-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(s.cancel),
        ),
      ],
    );
  }
}
