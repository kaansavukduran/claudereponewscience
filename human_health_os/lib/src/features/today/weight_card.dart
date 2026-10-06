import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/status_chip.dart';

/// FORGE 002 heartbeat: one canonical record type, saved through the
/// repository port and read back after restart.
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
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  String _when(DateTime utc) {
    final l = utc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final storage = widget.services.storage;
    final latest = _weights.isEmpty ? null : _weights.first;
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
            if (widget.services.storageNotice != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.services.storageNotice!,
                key: const ValueKey('storage-notice'),
                style: text.bodySmall,
              ),
            ],
            for (final w in widget.services.loadWarnings) ...[
              const SizedBox(height: 8),
              Text(
                w,
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
                  Text(
                    '${_fmt(latest.quantity!.value)} kg',
                    key: const ValueKey('weight-latest'),
                    style: text.headlineMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
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
                      Expanded(
                        child: Text(
                          '${_when(w.observedAt)} · ${s.observed} · ${s.manualEntry}'
                          '${w.originalText != null && w.originalText != _fmt(w.quantity!.value) ? ' · ${s.enteredAs} "${w.originalText}"' : ''}',
                          style: text.bodySmall,
                        ),
                      ),
                      Text(
                        '${_fmt(w.quantity!.value)} kg',
                        style: text.bodyMedium,
                      ),
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
