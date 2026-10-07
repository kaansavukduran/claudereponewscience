import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/ports/health_repository.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../navigation/destinations.dart';
import '../../presentation/widgets/status_chip.dart';
import '../timeline/timeline_screen.dart' show fmtValue;

/// Labs (ladder F004): manual entry of a result exactly as the report
/// printed it, and the list of current results. Flags and ranges are the
/// laboratory's, shown verbatim; the app adds no interpretation.
class LabsScreen extends StatefulWidget {
  const LabsScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  final _analyte = TextEditingController();
  final _value = TextEditingController();
  final _unit = TextEditingController();
  final _date = TextEditingController();
  final _specimen = TextEditingController();
  final _laboratory = TextEditingController();
  final _flag = TextEditingController();
  final _range = TextEditingController();
  bool _notReported = false;
  String? _errorCode;
  bool _busy = false;
  bool _saved = false;
  HealthRecord? _correcting;

  /// The add form's sample date and laboratory, kept while a correction
  /// borrows the form (review finding: a cancelled correction left the old
  /// result's date in the next new entry).
  ({String date, String laboratory})? _addMode;
  List<TimelineEntry> _entries = const [];

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _date.text = _ymd(DateTime.now());
    _reload();
  }

  @override
  void dispose() {
    for (final c in [
      _analyte,
      _value,
      _unit,
      _date,
      _specimen,
      _laboratory,
      _flag,
      _range,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _reload() async {
    final e = await _svc.labTimeline(_me);
    if (mounted) setState(() => _entries = e);
  }

  LabInput _input() => LabInput(
    analyte: _analyte.text,
    value: _value.text,
    notReported: _notReported,
    unit: _unit.text,
    sampleDate: _date.text,
    specimen: _specimen.text,
    laboratory: _laboratory.text,
    sourceFlag: _flag.text,
    referenceText: _range.text,
  );

  void _startCorrection(HealthRecord r) {
    final lab = r.lab!;
    setState(() {
      _addMode ??= (date: _date.text, laboratory: _laboratory.text);
      _correcting = r;
      _saved = false;
      _errorCode = null;
      _analyte.text = lab.analyteLabel;
      _notReported = r.valueStatus != ValueStatus.present;
      _value.text = r.originalText ?? '';
      _unit.text = r.quantity?.unit ?? '';
      _date.text = _ymd(r.observedAt);
      _specimen.text = lab.specimen ?? '';
      _laboratory.text = lab.laboratory ?? '';
      _flag.text = lab.sourceFlag ?? '';
      _range.text = lab.referenceText ?? '';
    });
  }

  /// Clears one result's fields. Sample date and laboratory stay for the
  /// next result from the same report, except after a correction, which
  /// gives back the add form's own values.
  void _clear() {
    for (final c in [_analyte, _value, _unit, _specimen, _flag, _range]) {
      c.clear();
    }
    _notReported = false;
    _correcting = null;
    final add = _addMode;
    if (add != null) {
      _date.text = add.date;
      _laboratory.text = add.laboratory;
      _addMode = null;
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _errorCode = null;
      _saved = false;
    });
    try {
      final target = _correcting;
      if (target == null) {
        await _svc.recordLab(profileId: _me, input: _input());
      } else {
        await _svc.correctLab(
          profileId: _me,
          targetId: target.id,
          input: _input(),
        );
      }
      _clear();
      _saved = true;
      await _reload();
    } on InputError catch (e) {
      _errorCode = e.code;
    } on RecordValidationError catch (e) {
      _errorCode = e.code;
    } on StorageWriteRefused catch (e) {
      _errorCode = e.code;
    } catch (_) {
      _errorCode = 'SAVE_FAILED';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    TextEditingController c,
    String label,
    String key, {
    String? helper,
    bool number = false,
    bool enabled = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      key: ValueKey(key),
      controller: c,
      enabled: enabled,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final d = destinationById(DestinationId.labs);
    return ListView(
      key: const ValueKey('screen-labs'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(d.label(s.lang), style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(d.purpose(s.lang), style: text.bodyLarge),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.rule,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(d.principle(s.lang), style: text.bodyMedium)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          s.labsNoInterpretation,
          key: const ValueKey('labs-no-interpretation'),
          style: text.bodySmall,
        ),
        const SizedBox(height: 12),
        Card(
          semanticContainer: false,
          key: const ValueKey('lab-form'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    _correcting == null ? s.labAddTitle : s.labCorrectTitle,
                    style: text.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),
                _field(
                  _analyte,
                  s.labAnalyte,
                  'lab-analyte',
                  helper: s.labAnalyteHelp,
                ),
                _field(
                  _value,
                  s.labValue,
                  'lab-value',
                  number: true,
                  enabled: !_notReported,
                ),
                CheckboxListTile(
                  key: const ValueKey('lab-not-reported'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(s.labNotReported),
                  value: _notReported,
                  onChanged: (v) => setState(() => _notReported = v ?? false),
                ),
                _field(_unit, s.labUnit, 'lab-unit', helper: s.labUnitHelp),
                _field(
                  _date,
                  s.labSampleDate,
                  'lab-date',
                  helper: 'YYYY-MM-DD',
                ),
                _field(_specimen, s.labSpecimen, 'lab-specimen'),
                _field(_laboratory, s.labLaboratory, 'lab-laboratory'),
                _field(_flag, s.labFlag, 'lab-flag', helper: s.labFlagHelp),
                _field(_range, s.labRange, 'lab-range', helper: s.labRangeHelp),
                if (_errorCode != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      s.inputError(_errorCode!),
                      key: const ValueKey('lab-error'),
                      style: text.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_saved)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        s.saved,
                        key: const ValueKey('lab-saved'),
                        style: text.bodySmall,
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      key: const ValueKey('lab-save'),
                      onPressed: _busy ? null : _save,
                      child: Text(
                        _correcting == null ? s.save : s.saveCorrection,
                      ),
                    ),
                    if (_correcting != null)
                      TextButton(
                        onPressed: () => setState(_clear),
                        child: Text(s.cancel),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_entries.isEmpty)
          Text(
            s.noRecordsYet,
            key: const ValueKey('labs-empty'),
            style: text.titleMedium,
          ),
        for (final e in _entries)
          for (final r in e.heads)
            _LabTile(
              key: ValueKey('lab-row-${r.id}'),
              record: r,
              conflict: e.status == EntryStatus.conflict,
              onCorrect: () => _startCorrection(r),
            ),
      ],
    );
  }
}

class _LabTile extends StatelessWidget {
  const _LabTile({
    super.key,
    required this.record,
    required this.conflict,
    required this.onCorrect,
  });

  final HealthRecord record;
  final bool conflict;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final lab = record.lab!;
    final day = record.observedAt;
    final date =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return Card(
      semanticContainer: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(lab.analyteLabel, style: text.titleSmall)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    fmtValue(s, record),
                    textAlign: TextAlign.end,
                    style: text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                '${s.labSampleDate}: $date',
                if (lab.specimen != null) lab.specimen!,
                if (lab.laboratory != null) lab.laboratory!,
                s.provenanceKind(record.provenance.kind),
              ].join(' · '),
              style: text.bodySmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (lab.sourceFlag != null)
                  StatusChip(
                    key: ValueKey('lab-flag-${record.id}'),
                    label: s.labPrintedFlag(lab.sourceFlag!),
                    tone: StatusTone.muted,
                  ),
                if (conflict)
                  StatusChip(
                    label: s.entryStatus(EntryStatus.conflict),
                    tone: StatusTone.warn,
                  ),
              ],
            ),
            Text(
              lab.referenceText == null
                  ? s.labNoRangePrinted
                  : s.labPrintedRange(lab.referenceText!),
              key: ValueKey('lab-range-${record.id}'),
              style: text.bodySmall,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                key: ValueKey('lab-correct-${record.id}'),
                onPressed: onCorrect,
                icon: const Icon(Icons.edit_outlined),
                label: Text(s.amendAction(AmendReason.correction)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
