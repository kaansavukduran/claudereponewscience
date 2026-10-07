import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/ports/health_repository.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
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
  List<HealthRecord> _weights = const [];
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
    final w = await _svc.currentWeights(widget.services.self.id);
    if (mounted) setState(() => _weights = w);
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

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// The value cell: the number with the record's own unit, or the named
  /// value status when there is no number (missing ≠ zero).
  String _value(S s, HealthRecord r) {
    final q = r.quantity;
    if (r.valueStatus != ValueStatus.present || q == null) {
      return s.valueStatus(r.valueStatus);
    }
    return '${_fmt(q.value)} ${q.unit}';
  }

  String _meta(S s, HealthRecord r) {
    final q = r.quantity;
    final shown = q == null ? null : _fmt(q.value);
    final original = r.originalText;
    return [
      _when(r.observedAt),
      s.recordState(r.state),
      s.provenanceKind(r.provenance.kind),
      if (original != null && original != shown) '${s.enteredAs} "$original"',
    ].join(' · ');
  }

  String _when(DateTime utc) {
    final l = utc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final services = widget.services;
    final storage = services.storage;
    // "Latest" is the newest current record that has a number; a newer
    // "not measured" entry is listed in the history, never shown as a value.
    final latest = _weights
        .where(
          (w) => w.valueStatus == ValueStatus.present && w.quantity != null,
        )
        .firstOrNull;
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
                  tone: storage.encrypted ? StatusTone.ok : StatusTone.warn,
                ),
              ],
            ),
            if (notice != null) ...[
              const SizedBox(height: 8),
              Text(
                notice,
                key: const ValueKey('storage-notice'),
                style: text.bodySmall,
              ),
            ],
            for (final n in services.storageNotes) ...[
              const SizedBox(height: 8),
              Text(
                s.storageNote(n),
                key: ValueKey('storage-note-${n.kind.name}'),
                style: text.bodySmall,
              ),
            ],
            for (final w in services.loadWarnings) ...[
              const SizedBox(height: 8),
              Text(
                s.loadWarning(w),
                key: ValueKey('load-warning-${w.line}'),
                style: text.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (latest == null)
              Text(
                s.noWeightYet,
                key: const ValueKey('weight-empty'),
                style: text.bodyMedium,
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(s.latest, style: text.labelLarge),
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
                        style: text.headlineMedium?.copyWith(
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
            if (_justSaved) ...[
              const SizedBox(height: 6),
              Semantics(
                liveRegion: true,
                child: Text(
                  s.saved,
                  key: const ValueKey('weight-saved'),
                  style: text.bodySmall,
                ),
              ),
            ],
            if (_weights.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(s.history, style: text.titleSmall),
              const SizedBox(height: 4),
              for (final w in _weights.take(10))
                Padding(
                  key: ValueKey('weight-row-${w.id}'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(_meta(s, w), style: text.bodySmall)),
                      const SizedBox(width: 8),
                      Text(_value(s, w), style: text.bodyMedium),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
