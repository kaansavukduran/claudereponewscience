import 'package:flutter/material.dart';

import '../../presentation/widgets/aion.dart';
import '../../app/appearance_scope.dart';
import '../../presentation/widgets/number_pad.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;
import '../trends/trend_screen.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/ports/health_repository.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../measurements/measurement_format.dart';
import '../../presentation/widgets/status_chip.dart';

/// Persistence heartbeat: one canonical record type, saved through the
/// repository port and read back after restart. Each row shows the record's
/// own state, source and unit; a value that does not exist is named, never
/// drawn as a number (gap G-18).
class WeightCard extends StatefulWidget {
  const WeightCard({super.key, required this.services});

  final AppServices services;

  @override
  State<WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends State<WeightCard> {
  final _controller = TextEditingController();
  bool? _padChoice;

  bool get _pad =>
      _padChoice ?? (AppearanceScope.maybeOf(context)?.value.padOpen ?? false);
  List<HealthRecord> _weights = const [];
  List<TimelineEntry> _entries = const [];
  String? _errorCode;
  bool _busy = false;
  bool _justSaved = false;

  HeartbeatService get _svc => widget.services.heartbeat;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final entries = await _svc.weightTimeline(widget.services.self.id);
    if (mounted) {
      setState(() {
        _entries = entries;
        _weights = [for (final e in entries) ...e.heads];
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _errorCode = null;
      _justSaved = false;
    });
    try {
      await _svc.recordWeightKg(
        profileId: widget.services.self.id,
        input: _controller.text,
      );
      _controller.clear();
      _justSaved = true;
      await _reload();
    } on InputError catch (e) {
      _errorCode = e.code;
    } on RecordValidationError catch (e) {
      _errorCode = e.code;
    } on StorageWriteRefused catch (e) {
      _errorCode = e.code;
    } catch (_) {
      // Storage/IO failure: say it was not saved (audit UX-2). Nothing is
      // shown as latest, because memory is only updated after a write.
      _errorCode = 'SAVE_FAILED';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The number with the decimals it was typed with (77,50 is 77.50).
  String _fmt(double v, [String? typed]) => fmtMeasured(v, typed);

  /// The value cell: the number with the record's own unit, or the named
  /// value status when there is no number (missing ≠ zero).
  String _value(S s, HealthRecord r) {
    final q = r.quantity;
    if (r.valueStatus != ValueStatus.present || q == null) {
      return s.valueStatus(r.valueStatus);
    }
    final unit = q.unit;
    return unit == null
        ? '${_fmt(q.value, r.originalText)} (${s.unitNotGiven})'
        : '${_fmt(q.value, r.originalText)} $unit${s.converted(q.value, unit)}';
  }

  String _meta(S s, HealthRecord r) {
    final q = r.quantity;
    final original = r.originalText;
    final shown = q == null ? null : _fmt(q.value, original);
    return [
      _when(r.observedAt),
      s.recordState(r.state),
      s.provenanceKind(r.provenance.kind),
      if (original != null && original != shown) '${s.enteredAs} "$original"',
    ].join(' · ');
  }

  String _when(DateTime utc) => fmtWhen(utc);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final services = widget.services;
    final storage = services.storage;
    // "Latest" is the newest live entry that has a number; a newer "not
    // measured" entry is listed in the history, never shown as a value. When
    // that entry's versions disagree, no single number is picked (F003).
    final latestEntry = _entries
        .where(
          (e) => e.heads.any(
            (w) => w.valueStatus == ValueStatus.present && w.quantity != null,
          ),
        )
        .firstOrNull;
    final conflict = latestEntry?.status == EntryStatus.conflict;
    final latest = conflict ? null : latestEntry?.heads.first;
    final notice = s.storageNotice(
      services.storageReason,
      detail: services.storageDetail,
      profile: services.config.profile.name.toUpperCase(),
    );
    return Card(
      semanticContainer: false,
      key: const ValueKey('weight-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(s.weightTitle, style: text.titleMedium),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 12),
            if (conflict)
              Text(
                s.versionsDisagree,
                key: const ValueKey('weight-conflict'),
                style: text.titleMedium,
              )
            else if (latest == null)
              LayoutBuilder(
                // When the card is narrow in text of the chosen size, the text
                // keeps the whole width (R008).
                builder: (context, box) => Row(
                  children: [
                    if (box.maxWidth /
                            (MediaQuery.textScalerOf(context).scale(14) / 14) >=
                        240) ...[
                      const AionFigure(height: 64),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        s.noWeightYet,
                        key: const ValueKey('weight-empty'),
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(s.latest, style: text.bodyMedium),
                  const SizedBox(width: 12),
                  // Scales down instead of overflowing on narrow phones at
                  // large text sizes (audit UX-7).
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _value(s, latest),
                        key: const ValueKey('weight-latest'),
                        style: text.titleLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('weight-input'),
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _busy ? null : _save(),
                    decoration: InputDecoration(
                      labelText: s.weightField,
                      border: const OutlineInputBorder(),
                      errorText: _errorCode == null
                          ? null
                          : s.inputError(_errorCode!),
                      errorMaxLines: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: FilledButton(
                    key: const ValueKey('weight-save'),
                    onPressed: _busy ? null : _save,
                    child: Text(s.save),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('weight-trend'),
                icon: const Icon(Icons.show_chart),
                label: Text(s.seeOverTime),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TrendScreen(
                      services: widget.services,
                      kind: RecordKind.bodyWeight,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey('weight-pad-toggle'),
                onPressed: () => setState(() => _padChoice = !_pad),
                child: Text(_pad ? s.numberPadHide : s.numberPadShow),
              ),
            ),
            if (_pad)
              NumberPad(
                key: const ValueKey('weight-pad'),
                keyPrefix: 'wpad',
                target: () => _controller,
                onChanged: () => setState(() {}),
              ),
            if (_justSaved) ...[
              const SizedBox(height: 6),
              Semantics(
                liveRegion: true,
                child: Text(
                  s.saved,
                  key: const ValueKey('weight-saved'),
                  style: text.bodyMedium,
                ),
              ),
            ],
            if (_weights.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(s.history, style: text.titleMedium),
              const SizedBox(height: 4),
              for (final w in _weights.take(10))
                Padding(
                  key: ValueKey('weight-row-${w.id}'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_meta(s, w), style: text.bodyMedium),
                      ),
                      const SizedBox(width: 8),
                      Text(_value(s, w), style: text.bodyMedium),
                    ],
                  ),
                ),
            ],
            // Where the data lives is said last: the person's number first.
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(
                  key: const ValueKey('storage-chip'),
                  label: s.storageLabel(
                    storage.durability.name,
                    storage.encrypted,
                  ),
                  tone: storage.encrypted ? StatusTone.ok : StatusTone.info,
                ),
              ],
            ),
            if (notice != null) ...[
              const SizedBox(height: 8),
              Text(
                notice,
                key: const ValueKey('storage-notice'),
                style: text.bodyMedium,
              ),
            ],
            for (final n in services.storageNotes) ...[
              const SizedBox(height: 8),
              Text(
                s.storageNote(n),
                key: ValueKey('storage-note-${n.kind.name}'),
                style: text.bodyMedium,
              ),
            ],
            for (final w in services.loadWarnings) ...[
              const SizedBox(height: 8),
              Text(
                s.loadWarning(w),
                key: ValueKey('load-warning-${w.line}'),
                style: text.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
