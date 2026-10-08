import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/ports/health_repository.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../measurements/measurement_format.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// Measurements typed by hand (ladder F007): blood pressure, resting heart
/// rate and waist circumference. Each save is one record, kept exactly as
/// typed with its time and source; nothing is averaged, derived or judged,
/// and a value that does not exist is named, never drawn as 0.
class MeasurementsCard extends StatefulWidget {
  const MeasurementsCard({super.key, required this.services});

  final AppServices services;

  /// In the order shown.
  static const kinds = [
    RecordKind.bloodPressure,
    RecordKind.restingHeartRate,
    RecordKind.waistCircumference,
  ];

  @override
  State<MeasurementsCard> createState() => _MeasurementsCardState();
}

class _MeasurementsCardState extends State<MeasurementsCard> {
  final _value = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  final _context = TextEditingController();
  RecordKind _kind = RecordKind.bloodPressure;
  Map<RecordKind, List<TimelineEntry>> _entries = const {};
  String? _errorCode;
  String? _errorField;
  bool _busy = false;
  bool _justSaved = false;
  String? _checkpoint;

  HeartbeatService get _svc => widget.services.heartbeat;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _value.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    _context.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final me = widget.services.self.id;
    final next = {
      for (final k in MeasurementsCard.kinds)
        k: await _svc.measurementTimeline(me, k),
    };
    if (mounted) setState(() => _entries = next);
  }

  Future<void> _save() async {
    final before = widget.services.checkpointSaved?.value;
    setState(() {
      _busy = true;
      _errorCode = null;
      _errorField = null;
      _justSaved = false;
    });
    try {
      await _svc.recordMeasurement(
        profileId: widget.services.self.id,
        kind: _kind,
        input: MeasurementInput(
          value: _value.text,
          systolic: _systolic.text,
          diastolic: _diastolic.text,
          context: _context.text,
        ),
      );
      _value.clear();
      _systolic.clear();
      _diastolic.clear();
      _context.clear();
      _justSaved = true;
      final after = widget.services.checkpointSaved?.value;
      if (after != null && after != before) _checkpoint = after;
      await _reload();
    } on InputError catch (e) {
      _errorCode = e.code;
      _errorField = e.field;
    } on RecordValidationError catch (e) {
      _errorCode = e.code;
    } on StorageWriteRefused catch (e) {
      _errorCode = e.code;
    } catch (_) {
      // Storage/IO failure: memory is only updated after a write, so
      // nothing is shown as saved.
      _errorCode = 'SAVE_FAILED';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _errorFor(S s, String field) =>
      _errorCode != null && _errorField == field
      ? s.inputError(_errorCode!)
      : null;

  String _meta(S s, HealthRecord r) {
    final typed = typedWhenDifferent(r);
    final context = r.context;
    return [
      fmtWhen(r.observedAt),
      s.recordState(r.state),
      s.provenanceKind(r.provenance.kind),
      if (typed != null) '${s.enteredAs} "$typed"',
      if (context != null) '${s.contextLabel}: "$context"',
    ].join(' · ');
  }

  Widget _field(
    S s,
    TextEditingController c,
    String label,
    String key,
    String field, {
    bool number = true,
  }) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: TextField(
      key: ValueKey(key),
      controller: c,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLength: number ? null : HealthRecord.maxContextLength,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: _errorFor(s, field),
        errorMaxLines: 3,
        counterText: '',
      ),
    ),
  );

  Widget _latestRow(S s, TextTheme text, RecordKind kind) {
    final entries = _entries[kind] ?? const <TimelineEntry>[];
    final entry = latestWithValue(entries);
    final conflict = entry?.status == EntryStatus.conflict;
    final latest = conflict ? null : entry?.heads.first;
    final code = kind.code;
    final String shown;
    final String spoken;
    if (conflict) {
      shown = s.versionsDisagree;
      spoken = '${s.recordKind(kind)}: ${s.versionsDisagree}';
    } else if (latest == null) {
      shown = s.measurementNotYet;
      spoken = '${s.recordKind(kind)}: ${s.measurementNotYet}';
    } else {
      shown = measurementValue(s, latest);
      spoken = s.spokenLatest(
        s.recordKind(kind),
        spokenMeasurement(s, latest),
        fmtWhen(latest.observedAt),
        s.provenanceKind(latest.provenance.kind),
      );
    }
    return Semantics(
      key: ValueKey('measure-latest-$code'),
      label: spoken,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.recordKind(kind), style: text.labelLarge),
                  if (latest != null)
                    Text(
                      '${fmtWhen(latest.observedAt)} · '
                      '${s.provenanceKind(latest.provenance.kind)}',
                      style: text.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                shown,
                key: ValueKey('measure-latest-value-$code'),
                textAlign: TextAlign.end,
                style: latest == null
                    ? text.bodyMedium
                    : text.titleMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final history = [
      for (final e in _entries[_kind] ?? const <TimelineEntry>[]) ...e.heads,
    ];
    return Card(
      semanticContainer: false,
      key: const ValueKey('measurements-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(s.measurementsTitle, style: text.titleMedium),
            ),
            const SizedBox(height: 4),
            Text(
              s.measurementsNote,
              key: const ValueKey('measurements-note'),
              style: text.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final k in MeasurementsCard.kinds) _latestRow(s, text, k),
            const SizedBox(height: 12),
            Text(s.measurementKind, style: text.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in MeasurementsCard.kinds)
                  ChoiceChip(
                    key: ValueKey('measure-kind-${k.code}'),
                    label: Text(s.recordKind(k)),
                    selected: _kind == k,
                    onSelected: _busy
                        ? null
                        : (_) => setState(() {
                            _kind = k;
                            _errorCode = null;
                            _errorField = null;
                            _justSaved = false;
                          }),
                  ),
              ],
            ),
            if (_kind.isStructured) ...[
              _field(
                s,
                _systolic,
                s.systolicField,
                'measure-systolic',
                'systolic',
              ),
              _field(
                s,
                _diastolic,
                s.diastolicField,
                'measure-diastolic',
                'diastolic',
              ),
            ] else
              _field(
                s,
                _value,
                s.measurementField(_kind),
                'measure-value',
                'value',
              ),
            _field(
              s,
              _context,
              s.contextField,
              'measure-context',
              'context',
              number: false,
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const ValueKey('measure-save'),
              onPressed: _busy ? null : _save,
              child: Text(s.saveMeasurement),
            ),
            if (_errorCode != null && _errorField == null) ...[
              const SizedBox(height: 6),
              Text(
                s.inputError(_errorCode!),
                key: const ValueKey('measure-error'),
                style: text.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (_justSaved) ...[
              const SizedBox(height: 6),
              Semantics(
                liveRegion: true,
                child: Text(
                  _checkpoint == null
                      ? s.saved
                      : s.checkpointSaved(_checkpoint!),
                  key: const ValueKey('measure-saved'),
                  style: text.bodySmall,
                ),
              ),
            ],
            if (history.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(s.history, style: text.titleSmall),
              const SizedBox(height: 4),
              for (final r in history.take(10))
                Padding(
                  key: ValueKey('measure-row-${r.id}'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(_meta(s, r), style: text.bodySmall)),
                      const SizedBox(width: 8),
                      Text(measurementValue(s, r), style: text.bodyMedium),
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
