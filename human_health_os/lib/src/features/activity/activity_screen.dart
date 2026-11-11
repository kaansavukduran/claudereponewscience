import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/sheet_parts.dart';
import '../../presentation/widgets/aion.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// Activity (F007 slice 6): walks, workouts and steps typed by hand. Minutes
/// and steps are whole numbers or not given; nothing is estimated (no
/// calories), added up, rated or merged with device data.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<HealthRecord>? _entries;

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final entries = await _svc.activities(_me);
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _open({HealthRecord? correcting}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) =>
          _ActivitySheet(svc: _svc, me: _me, correcting: correcting),
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
      key: const ValueKey('screen-activity'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(s.actTitle, style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(s.actIntro, style: text.bodyMedium),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('act-add'),
            onPressed: _open,
            icon: const Icon(Icons.add),
            label: Text(s.actAdd),
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
              Expanded(child: Text(s.actNone, key: const ValueKey('act-none'))),
            ],
          )
        else
          for (final r in entries)
            Card(
              key: ValueKey('act-entry-${r.id}'),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s.actLine(r.details! as ActivityEntryDetails)),
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
                      key: ValueKey('act-correct-${r.id}'),
                      onPressed: () => _open(correcting: r),
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

class _ActivitySheet extends StatefulWidget {
  const _ActivitySheet({required this.svc, required this.me, this.correcting});

  final HeartbeatService svc;
  final String me;

  /// The shown version being corrected; null for a new entry.
  final HealthRecord? correcting;

  @override
  State<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends State<_ActivitySheet> {
  final _what = TextEditingController();
  final _minutes = TextEditingController();
  final _steps = TextEditingController();
  final _when = TextEditingController();
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
    if (d is ActivityEntryDetails) {
      _what.text = d.what;
      _minutes.text = d.minutes?.toString() ?? '';
      _steps.text = d.steps?.toString() ?? '';
      _when.text = _shownWhen = typedLocal(widget.correcting!.observedAt);
    }
  }

  @override
  void dispose() {
    _what.dispose();
    _minutes.dispose();
    _steps.dispose();
    _when.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final s = S.of(context);
    setState(() => _busy = true);
    var saved = false;
    try {
      await widget.svc.recordActivity(
        profileId: widget.me,
        what: _what.text,
        minutes: _minutes.text,
        steps: _steps.text,
        when: _when.text == _shownWhen ? '' : _when.text,
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
    TextEditingController c,
    String field, {
    String? help,
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      key: ValueKey(key),
      controller: c,
      keyboardType: keyboard,
      inputFormatters: keyboard == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
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
        errorText: _errorField == field ? _error : null,
        errorMaxLines: 4,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    return SheetFrame(
      fields: [
        Semantics(
          header: true,
          child: Text(
            widget.correcting == null ? s.actAdd : s.actCorrectTitle,
            style: text.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        _field('act-what', s.actWhat, _what, 'what'),
        _field(
          'act-minutes',
          s.actMinutes,
          _minutes,
          'minutes',
          keyboard: TextInputType.number,
        ),
        _field(
          'act-steps',
          s.actSteps,
          _steps,
          'steps',
          keyboard: TextInputType.number,
        ),
        _field(
          'act-when',
          s.foodWhen,
          _when,
          'when',
          help: s.foodWhenHelp,
          keyboard: TextInputType.datetime,
        ),
        TimePicks(
          keyPrefix: 'act-when',
          controller: _when,
          picks: TimePicks.recent(s),
          onPicked: () => setState(() => _error = _errorField = null),
        ),
        // An error without a field of its own is said here; one on a
        // field is shown (and read) on that field only.
        if (_error != null &&
            !const {'what', 'minutes', 'steps', 'when'}.contains(_errorField))
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              key: const ValueKey('act-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
      ],
      actions: [
        FilledButton(
          key: const ValueKey('act-save'),
          onPressed: _busy ? null : _save,
          child: Text(s.save),
        ),
        TextButton(
          key: const ValueKey('act-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(s.cancel),
        ),
      ],
    );
  }
}
