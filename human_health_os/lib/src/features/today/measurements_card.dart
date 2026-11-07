import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../app/appearance_scope.dart';
import '../../domain/guide/glossary.dart';
import '../../domain/settings/appearance.dart';
import '../../presentation/widgets/number_pad.dart';
import '../guide/glossary_screen.dart';
import '../trends/trend_screen.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/ports/health_repository.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../measurements/measurement_format.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// Measurements typed by hand (ladder F007): a quiet grid of tiles that show
/// the latest value of each kind, and one entry sheet per kind. Each save is
/// one record, kept exactly as typed with its time and source; nothing is
/// averaged, derived or judged, and a value that does not exist is named,
/// never drawn as 0. The history of each kind lives on the Timeline.
class MeasurementsCard extends StatefulWidget {
  const MeasurementsCard({super.key, required this.services});

  final AppServices services;

  /// In the order shown.
  static const kinds = [
    RecordKind.bloodPressure,
    RecordKind.restingHeartRate,
    RecordKind.bodyTemperature,
    RecordKind.oxygenSaturation,
    RecordKind.respiratoryRate,
    RecordKind.waistCircumference,
    RecordKind.height,
  ];

  @override
  State<MeasurementsCard> createState() => _MeasurementsCardState();
}

class _MeasurementsCardState extends State<MeasurementsCard> {
  Map<RecordKind, List<TimelineEntry>> _entries = const {};

  HeartbeatService get _svc => widget.services.heartbeat;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final me = widget.services.self.id;
    final next = {
      for (final k in MeasurementsCard.kinds)
        k: await _svc.measurementTimeline(me, k),
    };
    if (mounted) setState(() => _entries = next);
  }

  Future<void> _add(RecordKind kind) async {
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    widget.services.checkpointSaved?.value = null;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Typed numbers are never lost to a stray swipe or tap outside: the
      // sheet closes with Save or Cancel.
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _EntrySheet(services: widget.services, kind: kind),
    );
    final checkpoint = widget.services.checkpointSaved?.value;
    if (saved != true) {
      // A backup may have been made for an entry that was then not saved:
      // the person is told where it is.
      if (checkpoint != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(s.checkpointKept(checkpoint)),
            duration: const Duration(seconds: 12),
            showCloseIcon: true,
          ),
        );
      }
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          child: Text(
            checkpoint == null ? s.saved : s.checkpointSaved(checkpoint),
            key: const ValueKey('measure-saved'),
          ),
        ),
        duration: Duration(seconds: checkpoint == null ? 3 : 12),
        showCloseIcon: checkpoint != null,
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final prefs =
        AppearanceScope.maybeOf(context)?.value ?? const AppearanceSettings();
    final codes = prefs.visible([
      for (final k in MeasurementsCard.kinds) k.code,
    ]);
    final shown = [
      for (final c in codes)
        MeasurementsCard.kinds.firstWhere((k) => k.code == c),
    ];
    return Column(
      key: const ValueKey('measurements-card'),
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
          style: text.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        if (shown.isEmpty)
          Text(
            s.allTilesHidden,
            key: const ValueKey('measurements-all-hidden'),
            style: text.bodyMedium,
          ),
        LayoutBuilder(
          builder: (context, box) {
            final columns = box.maxWidth >= 720
                ? 4
                : (box.maxWidth >= 480 ? 3 : 2);
            const gap = 12.0;
            final width = (box.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final k in shown)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: width,
                      maxWidth: width,
                      minHeight: 96,
                    ),
                    child: _Tile(
                      kind: k,
                      entries: _entries[k] ?? const [],
                      onAdd: () => _add(k),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// The latest value of one kind and a way to add another.
class _Tile extends StatelessWidget {
  const _Tile({required this.kind, required this.entries, required this.onAdd});

  final RecordKind kind;
  final List<TimelineEntry> entries;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final entry = latestWithValue(entries);
    final conflict = entry?.status == EntryStatus.conflict;
    final latest = conflict ? null : entry?.heads.first;
    final code = kind.code;
    final String value;
    final String spoken;
    String? caption;
    if (conflict) {
      value = s.versionsDisagree;
      spoken = '${s.recordKind(kind)}: ${s.versionsDisagree}';
    } else if (latest == null) {
      value = s.measurementNotYet;
      spoken = '${s.recordKind(kind)}: ${s.measurementNotYet}';
    } else {
      value = measurementValue(s, latest);
      caption = whenCaption(s, latest, fmtWhen);
      spoken = s.spokenLatest(
        s.recordKind(kind),
        spokenMeasurement(s, latest),
        fmtWhen(latest.observedAt),
        s.provenanceKind(latest.provenance.kind),
        saved: savedWhenDifferent(latest, fmtWhen),
      );
    }
    return Semantics(
      key: ValueKey('measure-latest-$code'),
      label: '$spoken. ${s.addMeasurement}',
      button: true,
      excludeSemantics: true,
      onTap: onAdd,
      child: Material(
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: InkWell(
          key: ValueKey('measure-tile-$code'),
          borderRadius: BorderRadius.circular(12),
          onTap: onAdd,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        s.recordKind(kind),
                        style: text.labelLarge?.copyWith(color: scheme.outline),
                      ),
                    ),
                    Icon(Icons.add, size: 20, color: scheme.primary),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  key: ValueKey('measure-latest-value-$code'),
                  style: latest == null
                      ? text.bodyMedium?.copyWith(color: scheme.outline)
                      : text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: text.bodySmall?.copyWith(color: scheme.outline),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One kind, one purpose: the value (or the two blood pressure numbers),
/// Save, and under "More details" the time and a note.
class _EntrySheet extends StatefulWidget {
  const _EntrySheet({required this.services, required this.kind});

  final AppServices services;
  final RecordKind kind;

  @override
  State<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<_EntrySheet> {
  final _value = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  final _context = TextEditingController();
  final _when = TextEditingController();
  final _more = ExpansibleController();
  late TextEditingController _active = _value;
  bool? _padChoice;

  bool get _pad =>
      _padChoice ?? (AppearanceScope.maybeOf(context)?.value.padOpen ?? false);
  String? _errorCode;
  String? _errorField;
  bool _busy = false;

  @override
  void dispose() {
    _value.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    _context.dispose();
    _when.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _errorCode = null;
      _errorField = null;
    });
    try {
      await widget.services.heartbeat.recordMeasurement(
        profileId: widget.services.self.id,
        kind: widget.kind,
        input: MeasurementInput(
          value: _value.text,
          systolic: _systolic.text,
          diastolic: _diastolic.text,
          context: _context.text,
          when: _when.text,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
      return;
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
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (_errorField == 'when' || _errorField == 'context') {
      _more.expand();
    }
  }

  String? _errorFor(S s, String field) =>
      _errorCode != null && _errorField == field
      ? s.inputError(_errorCode!)
      : null;

  Widget _field(
    S s,
    TextEditingController c,
    String label,
    String key,
    String field, {
    bool number = true,
    String? hint,
    bool autofocus = false,
    bool last = true,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Focus(
      onFocusChange: (has) {
        if (has) setState(() => _active = c);
      },
      child: TextField(
        key: ValueKey(key),
        controller: c,
        autofocus: autofocus,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onSubmitted: last ? (_) => _busy ? null : _save() : null,
        inputFormatters: field == 'context'
            ? const [ContextLengthFormatter()]
            : null,
        decoration: InputDecoration(
          labelText: label,
          helperText: hint,
          helperMaxLines: 3,
          errorText: _errorFor(s, field),
          errorMaxLines: 3,
        ),
      ),
    ),
  );

  String _stamp(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Widget _presets(S s) {
    final now = DateTime.now();
    final today8 = DateTime(now.year, now.month, now.day, 8);
    final yesterday20 = DateTime(now.year, now.month, now.day - 1, 20);
    final options = <(String, String?, bool)>[
      (s.presetNow, '', true),
      (s.presetHourAgo, _stamp(now.subtract(const Duration(hours: 1))), true),
      (s.presetMorning, _stamp(today8), today8.isBefore(now)),
      (s.presetYesterdayEvening, _stamp(yesterday20), true),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (label, value, enabled) in options)
            ActionChip(
              key: ValueKey('measure-preset-$label'),
              label: Text(label),
              onPressed: enabled
                  ? () => setState(() => _when.text = value ?? '')
                  : null,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final kind = widget.kind;
    final hint = s.measurementHint(kind);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          key: ValueKey('measure-sheet-${kind.code}'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(s.recordKind(kind), style: text.titleLarge),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('measure-trend'),
                icon: const Icon(Icons.show_chart),
                label: Text(s.seeOverTime),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TrendScreen(services: widget.services, kind: kind),
                  ),
                ),
              ),
            ),
            if (glossaryForKind(kind.code) case final entry?)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('measure-about'),
                  icon: const Icon(Icons.info_outline),
                  label: Text(s.aboutMeasurement),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GlossaryEntryScreen(entry: entry),
                    ),
                  ),
                ),
              ),
            if (kind.isStructured) ...[
              _field(
                s,
                _systolic,
                s.systolicField,
                'measure-systolic',
                'systolic',
                autofocus: true,
                last: false,
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
                s.measurementField(kind),
                'measure-value',
                'value',
                hint: hint,
                autofocus: true,
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey('measure-pad-toggle'),
                onPressed: () => setState(() => _padChoice = !_pad),
                child: Text(_pad ? s.numberPadHide : s.numberPadShow),
              ),
            ),
            if (_pad)
              Padding(
                key: const ValueKey('measure-pad'),
                padding: const EdgeInsets.only(top: 8),
                child: NumberPad(
                  target: () => _active,
                  onChanged: () => setState(() {}),
                ),
              ),
            const SizedBox(height: 8),
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const ValueKey('measure-more'),
                controller: _more,
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  s.moreDetails,
                  style: text.labelLarge?.copyWith(color: scheme.primary),
                ),
                children: [
                  _presets(s),
                  _field(
                    s,
                    _when,
                    s.whenField,
                    'measure-when',
                    'when',
                    number: false,
                    hint: s.whenHint,
                  ),
                  _field(
                    s,
                    _context,
                    s.contextField,
                    'measure-context',
                    'context',
                    number: false,
                  ),
                ],
              ),
            ),
            if (_errorCode != null && _errorField == null) ...[
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                child: Text(
                  s.inputError(_errorCode!),
                  key: const ValueKey('measure-error'),
                  style: text.bodyMedium?.copyWith(color: scheme.error),
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Stacked, full width: at large text a side-by-side pair squeezed
            // the Save label into a narrow strip.
            FilledButton(
              key: const ValueKey('measure-save'),
              onPressed: _busy ? null : _save,
              child: Text(s.saveMeasurement),
            ),
            const SizedBox(height: 4),
            TextButton(
              key: const ValueKey('measure-cancel'),
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: Text(s.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
