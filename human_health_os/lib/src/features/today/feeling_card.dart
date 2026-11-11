import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/sheet_parts.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// How the person feels on Today (F007 slice 4): energy, mood and stress as
/// their own levels, each optional. Self-report: nothing is scored, judged,
/// added up or advised.
class FeelingCard extends StatefulWidget {
  const FeelingCard({super.key, required this.services});

  final AppServices services;

  @override
  State<FeelingCard> createState() => _FeelingCardState();
}

class _FeelingCardState extends State<FeelingCard> {
  List<HealthRecord>? _entries;

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final entries = await _svc.feelings(_me);
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _open({HealthRecord? correcting}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _FeelingSheet(svc: _svc, me: _me, correcting: correcting),
    );
    if (saved == true) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final entries = _entries;
    return Card(
      key: const ValueKey('feel-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(s.feelTitle, style: text.titleMedium),
            ),
            const SizedBox(height: 4),
            if (entries != null && entries.isEmpty)
              Text(s.feelNone, key: const ValueKey('feel-none'))
            else if (entries != null)
              for (final r in entries.take(2))
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      '${fmtWhen(r.observedAt)} · ${_line(s, r)}',
                      key: ValueKey('feel-entry-${r.id}'),
                      style: text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      key: ValueKey('feel-correct-${r.id}'),
                      onPressed: () => _open(correcting: r),
                      child: Text(s.amendAction(AmendReason.correction)),
                    ),
                  ],
                ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('feel-open'),
              onPressed: _open,
              icon: const Icon(Icons.edit_note_outlined),
              label: Text(s.feelOpen),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeelingSheet extends StatefulWidget {
  const _FeelingSheet({required this.svc, required this.me, this.correcting});

  final HeartbeatService svc;
  final String me;

  /// The shown check-in being corrected; null for a new one.
  final HealthRecord? correcting;

  @override
  State<_FeelingSheet> createState() => _FeelingSheetState();
}

class _FeelingSheetState extends State<_FeelingSheet> {
  SelfLevel? _energy;
  SelfLevel? _mood;
  SelfLevel? _stress;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final d = widget.correcting?.details;
    if (d is FeelingCheckInDetails) {
      _energy = d.energy;
      _mood = d.mood;
      _stress = d.stress;
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    final s = S.of(context);
    setState(() => _busy = true);
    var saved = false;
    try {
      await widget.svc.recordFeeling(
        profileId: widget.me,
        energy: _energy,
        mood: _mood,
        stress: _stress,
        correcting: widget.correcting?.id,
      );
      saved = true;
    } on InputError catch (e) {
      _error = s.inputError(e.code);
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

  Widget _row(
    FeelingQuestion q,
    SelfLevel? value,
    ValueChanged<SelfLevel?> onPick,
  ) {
    final s = S.of(context);
    final name = q.name;
    final label = s.feelQuestion(q);
    return Padding(
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
                for (final l in SelfLevel.values)
                  ChoiceChip(
                    key: ValueKey('feel-$name-${l.name}'),
                    label: Text(
                      s.feelWord(q, l),
                      // Each chip is read with its question.
                      semanticsLabel: '$label: ${s.feelWord(q, l)}',
                    ),
                    selected: value == l,
                    // Tapping the chosen one again clears it: not given.
                    onSelected: (on) => setState(() {
                      onPick(on ? l : null);
                      _error = null;
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SheetFrame(
      fields: [
        Semantics(
          header: true,
          child: Text(
            widget.correcting == null ? s.feelTitle : s.feelCorrectTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 4),
        Text(s.feelIntro),
        const SizedBox(height: 12),
        _row(FeelingQuestion.energy, _energy, (v) => _energy = v),
        _row(FeelingQuestion.mood, _mood, (v) => _mood = v),
        _row(FeelingQuestion.stress, _stress, (v) => _stress = v),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              key: const ValueKey('feel-error'),
              style: TextStyle(color: scheme.error),
            ),
          ),
        const SizedBox(height: 12),
      ],
      actions: [
        FilledButton(
          key: const ValueKey('feel-save'),
          onPressed: _busy ? null : _save,
          child: Text(s.feelSave),
        ),
        TextButton(
          key: const ValueKey('feel-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(s.cancel),
        ),
      ],
    );
  }
}

String _line(S s, HealthRecord r) {
  final d = r.details! as FeelingCheckInDetails;
  return s.feelLine(d.energy, d.mood, d.stress);
}
