import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/sheet_parts.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// Sleep on Today (F007 slice 3): the last nights as typed, going to bed and
/// waking up, the time in bed between them and, if said, how waking felt.
/// Time in bed is not time asleep; nothing is scored, judged or advised.
class SleepCard extends StatefulWidget {
  const SleepCard({super.key, required this.services});

  final AppServices services;

  @override
  State<SleepCard> createState() => _SleepCardState();
}

class _SleepCardState extends State<SleepCard> {
  List<HealthRecord>? _nights;

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final nights = await _svc.sleepNights(_me);
    if (mounted) setState(() => _nights = nights);
  }

  Future<void> _add({HealthRecord? correcting}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _NightSheet(svc: _svc, me: _me, correcting: correcting),
    );
    if (saved == true) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final nights = _nights;
    return Card(
      key: const ValueKey('sleep-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(s.sleepTitle, style: text.titleMedium),
            ),
            const SizedBox(height: 4),
            Text(s.sleepIntro, style: text.bodyMedium),
            const SizedBox(height: 12),
            if (nights == null)
              const SizedBox.shrink()
            else if (nights.isEmpty)
              Text(s.sleepNone, key: const ValueKey('sleep-none'))
            else
              for (final r in nights.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        _line(s, r.details! as SleepNightDetails),
                        key: ValueKey('sleep-night-${r.id}'),
                      ),
                      TextButton(
                        key: ValueKey('sleep-correct-${r.id}'),
                        onPressed: () => _add(correcting: r),
                        child: Text(s.amendAction(AmendReason.correction)),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('sleep-add'),
              onPressed: _add,
              icon: const Icon(Icons.bedtime_outlined),
              label: Text(s.sleepAdd),
            ),
          ],
        ),
      ),
    );
  }
}

String _line(S s, SleepNightDetails d) => s.sleepLine(
  fmtWhen(d.wentToBed),
  fmtWhen(d.wokeUp),
  d.timeInBed,
  d.feeling,
);

class _NightSheet extends StatefulWidget {
  const _NightSheet({required this.svc, required this.me, this.correcting});

  final HeartbeatService svc;
  final String me;

  /// The shown version of a night being corrected; null for a new night.
  final HealthRecord? correcting;

  @override
  State<_NightSheet> createState() => _NightSheetState();
}

class _NightSheetState extends State<_NightSheet> {
  final _bed = TextEditingController();
  final _woke = TextEditingController();
  final _focus = FieldFocus();
  WakeFeeling? _feeling;
  String? _error;

  @override
  void initState() {
    super.initState();
    final d = widget.correcting?.details;
    if (d is SleepNightDetails) {
      _bed.text = typedLocal(d.wentToBed);
      _woke.text = typedLocal(d.wokeUp);
      _feeling = d.feeling;
    }
  }

  String? _errorField;
  bool _busy = false;

  @override
  void dispose() {
    _bed.dispose();
    _woke.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final s = S.of(context);
    setState(() => _busy = true);
    var saved = false;
    try {
      await widget.svc.recordSleep(
        profileId: widget.me,
        wentToBed: _bed.text,
        wokeUp: _woke.text,
        feeling: _feeling,
        correcting: widget.correcting?.id,
      );
      saved = true;
    } on InputError catch (e) {
      _error = s.inputError(e.code);
      _errorField = e.field;
    } on Object {
      _error = s.sleepSaveFailed;
      _errorField = null;
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

  Widget _field(
    String key,
    String label,
    String help,
    TextEditingController c,
    String field,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      key: ValueKey(key),
      controller: c,
      focusNode: _focus[field],
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: label,
        helperText: _errorField == field ? null : help,
        helperMaxLines: 3,
        // The field the error is about shows it too, not only the line.
        errorText: _errorField == field ? _error : null,
        errorMaxLines: 4,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SheetFrame(
      fields: [
        Semantics(
          header: true,
          child: Text(
            widget.correcting == null ? s.sleepAdd : s.sleepCorrectTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        _field('sleep-bed', s.sleepBed, s.sleepBedHelp, _bed, 'bed'),
        TimePicks(
          keyPrefix: 'sleep-bed',
          controller: _bed,
          picks: TimePicks.clock(['22:00', '23:00', '00:00']),
          onPicked: () => setState(() => _error = _errorField = null),
        ),
        _field('sleep-woke', s.sleepWoke, s.sleepWokeHelp, _woke, 'woke'),
        TimePicks(
          keyPrefix: 'sleep-woke',
          controller: _woke,
          picks: [
            (s.presetNow, '', true),
            ...TimePicks.clock(['06:00', '07:00', '08:00']),
          ],
          onPicked: () => setState(() => _error = _errorField = null),
        ),
        ExcludeSemantics(child: Text(s.sleepFeeling)),
        const SizedBox(height: 4),
        Semantics(
          container: true,
          label: s.sleepFeeling,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in WakeFeeling.values)
                ChoiceChip(
                  key: ValueKey('sleep-feeling-${f.name}'),
                  label: Text(s.sleepFeelingLabel(f)),
                  selected: _feeling == f,
                  // Tapping the chosen one again clears it: not said.
                  onSelected: (on) => setState(() => _feeling = on ? f : null),
                ),
            ],
          ),
        ),
        if (_error != null &&
            _errorField != 'bed' &&
            _errorField != 'woke') ...[
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              key: const ValueKey('sleep-error'),
              style: TextStyle(color: scheme.error),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
      actions: [
        FilledButton(
          key: const ValueKey('sleep-save'),
          onPressed: _busy ? null : _save,
          child: Text(s.save),
        ),
        TextButton(
          key: const ValueKey('sleep-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(s.cancel),
        ),
      ],
    );
  }
}
