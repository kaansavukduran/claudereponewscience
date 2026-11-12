import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../domain/derived/derived_from_records.dart';
import '../../domain/engines/core_derived.dart'
    show coreDerivedPackId, coreDerivedPackVersion;
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../measurements/measurement_format.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// "Worked out from your records" (U029, D-039): read-only. For each
/// MP-CORE-DERIVED-1 model the person's records can feed, the number with
/// its unit, "worked out, not measured", the model ID and version, the
/// records used (value and date) and the model's limitations. A missing
/// input is named ("needs: height"), never shown as a number. No category,
/// band, judgement, advice or colour that means good or bad.
class DerivedScreen extends StatefulWidget {
  const DerivedScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<DerivedScreen> createState() => _DerivedScreenState();
}

class _DerivedScreenState extends State<DerivedScreen> {
  List<DerivedRow>? _rows;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = widget.services.heartbeat;
    final me = widget.services.self.id;
    try {
      final rows = derivedFromRecords(
        weights: await svc.weightTimeline(me),
        heights: await svc.measurementTimeline(me, RecordKind.height),
        waists: await svc.measurementTimeline(
          me,
          RecordKind.waistCircumference,
        ),
      );
      if (mounted) setState(() => _rows = rows);
    } on Object {
      // The records could not be read: said in words, never a spinner forever.
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final rows = _rows;
    return Scaffold(
      appBar: AppBar(title: Text(s.derivedTitle)),
      body: _failed
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.derivedReadFailed,
                key: const ValueKey('derived-failed'),
              ),
            )
          : rows == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              key: const ValueKey('screen-derived'),
              padding: const EdgeInsets.all(16),
              children: [
                Text(s.derivedIntro, style: text.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  s.derivedPack(coreDerivedPackId, coreDerivedPackVersion),
                  style: text.bodySmall,
                ),
                const SizedBox(height: 16),
                for (final r in rows) ...[
                  _DerivedCard(row: r),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

/// Display decimals per model: a presentation choice, not part of the
/// calculation (the engine keeps the full value).
int _decimals(String modelId) =>
    modelId == 'DERIVED-WAIST_HEIGHT_RATIO-1' ? 2 : 1;

class _DerivedCard extends StatelessWidget {
  const _DerivedCard({required this.row});

  final DerivedRow row;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final m = row.model;
    final name = s.derivedModelName(m.modelId);
    String kinds(List<RecordKind> ks) =>
        s.derivedNeeds([for (final k in ks) s.recordKind(k).toLowerCase()]);
    final key = 'derived-${m.modelId}';
    final Widget headline;
    if (row.computed) {
      final value = row.result.value!.toStringAsFixed(_decimals(m.modelId));
      final unit = s.derivedUnit(m.unit);
      headline = Semantics(
        label: s.derivedSpoken(name, value, unit),
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value $unit',
              key: ValueKey('$key-value'),
              style: text.headlineSmall,
            ),
            Text(
              s.derivedNotMeasured,
              key: ValueKey('$key-worked-out'),
              style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    } else {
      headline = Text(
        row.unresolved.isNotEmpty
            ? s.derivedUnresolved([
                for (final k in row.unresolved) s.recordKind(k).toLowerCase(),
              ])
            : row.needs.isNotEmpty
            ? kinds(row.needs)
            : s.derivedRefused(row.result.errorCode ?? ''),
        key: ValueKey('$key-needs'),
        style: text.titleMedium,
      );
    }
    final days = row.daysApart;
    return Card(
      key: ValueKey(key),
      semanticContainer: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(header: true, child: Text(name, style: text.titleMedium)),
            const SizedBox(height: 8),
            headline,
            if (!row.computed &&
                row.needs.isNotEmpty &&
                row.unresolved.isNotEmpty)
              Text(kinds(row.needs), style: text.bodyMedium),
            const SizedBox(height: 8),
            Text(
              s.derivedModel(m.modelId, m.version),
              key: ValueKey('$key-model'),
              style: text.bodySmall,
            ),
            if (row.used.isNotEmpty) ...[
              const SizedBox(height: 12),
              Semantics(
                header: true,
                child: Text(s.derivedUsedTitle, style: text.titleSmall),
              ),
              for (final u in row.used)
                Text(
                  s.derivedUsedLine(
                    s.recordKind(u.kind),
                    measurementValue(s, u.record),
                    fmtWhen(u.record.observedAt),
                  ),
                  key: ValueKey('$key-used-${u.kind.code}'),
                  style: text.bodyMedium,
                ),
              if (days != null && days > 0)
                Text(
                  s.derivedDaysApart(days),
                  key: ValueKey('$key-apart'),
                  style: text.bodyMedium,
                ),
            ],
            const SizedBox(height: 12),
            Semantics(
              header: true,
              child: Text(s.derivedLimitsTitle, style: text.titleSmall),
            ),
            if (m.limitations.isEmpty)
              Text(s.derivedNoLimitations, style: text.bodyMedium)
            else
              for (final (i, l) in m.limitations.indexed)
                Text(
                  s.derivedLimitation(l),
                  key: ValueKey('$key-limitation-$i'),
                  style: text.bodyMedium,
                ),
          ],
        ),
      ),
    );
  }
}
