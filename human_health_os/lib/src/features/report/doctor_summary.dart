import '../../app/app_services.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../measurements/measurement_format.dart';
import '../../domain/settings/date_style.dart';
import '../today/measurements_card.dart';

/// A page handed to a clinician always uses 2026-11-08 20:05: 11/08/2026
/// could be read either way.
String isoWhen(DateTime utc) =>
    formatWhen(utc.toLocal(), DateOrder.iso, ClockStyle.h24);

/// One line of the summary: when, what (as typed), and a note.
class SummaryRow {
  const SummaryRow(this.when, this.value, [this.note = '']);
  final String when;
  final String value;
  final String note;
}

class SummarySection {
  const SummarySection(this.title, this.rows, this.total, [this.partNote = '']);
  final String title;

  /// "Showing the newest n of total" when [rows] is shorter than [total];
  /// printed on the page too, so a reader knows it is not everything.
  final String partNote;
  final List<SummaryRow> rows;

  /// How many current readings exist (rows show at most [rowsPerSection]).
  final int total;
}

const int rowsPerSection = 20;

/// What the person recorded, for a visit (U009): values as typed with their
/// time and source, newest first; nothing computed, scored or judged.
class DoctorSummary {
  const DoctorSummary({
    required this.title,
    required this.createdAt,
    required this.sections,
    required this.footer,
  });

  final String title;
  final String createdAt;
  final List<SummarySection> sections;
  final List<String> footer;

  static Future<DoctorSummary> collect(AppServices services, S s) async {
    final svc = services.heartbeat;
    final me = services.self.id;
    final sections = <SummarySection>[];

    final weights = (await svc.currentWeights(me)).toList()
      ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    if (weights.isNotEmpty) {
      sections.add(
        SummarySection(
          s.recordKind(RecordKind.bodyWeight),
          [
            for (final r in weights.take(rowsPerSection))
              SummaryRow(isoWhen(r.observedAt), measurementValue(s, r)),
          ],
          weights.length,
          _part(s, weights.length),
        ),
      );
    }

    for (final k in MeasurementsCard.kinds) {
      final live = [
        for (final e in await svc.measurementTimeline(me, k))
          if (e.isLive) e.shown,
      ]..sort((a, b) => b.observedAt.compareTo(a.observedAt));
      if (live.isEmpty) continue;
      sections.add(
        SummarySection(
          s.recordKind(k),
          [
            for (final r in live.take(rowsPerSection))
              SummaryRow(
                isoWhen(r.observedAt),
                measurementValue(s, r),
                r.context ?? '',
              ),
          ],
          live.length,
          _part(s, live.length),
        ),
      );
    }

    final labs = [
      for (final e in await svc.labTimeline(me))
        if (e.isLive) e.shown,
    ]..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    if (labs.isNotEmpty) {
      sections.add(
        SummarySection(
          s.summaryLabs,
          [for (final r in labs.take(rowsPerSection * 2)) _labRow(s, r)],
          labs.length,
          _part(s, labs.length, rowsPerSection * 2),
        ),
      );
    }

    final now = DateTime.now().toUtc();
    return DoctorSummary(
      title: s.summaryTitle,
      createdAt: s.summaryCreated(isoWhen(now)),
      sections: sections,
      footer: [s.summaryFooterTyped, s.summaryFooterNotDiagnosis],
    );
  }

  static String _part(S s, int total, [int cap = rowsPerSection]) =>
      total > cap ? s.summaryMore(cap, total) : '';

  static SummaryRow _labRow(S s, HealthRecord r) {
    final lab = r.lab;
    final unit = r.quantity?.unit ?? '';
    final typed = r.originalText ?? '';
    final value = r.valueStatus != ValueStatus.present
        ? s.valueStatus(r.valueStatus)
        : typed.isNotEmpty
        ? '$typed ${unit.isEmpty ? s.unitNotGiven : unit}'
        : measurementValue(s, r);
    final range = lab?.referenceText ?? '';
    final flag = lab?.sourceFlag ?? '';
    final notes = [
      if (range.isNotEmpty) s.labPrintedRange(range),
      if (flag.isNotEmpty) s.labPrintedFlag(flag),
    ].join(' · ');
    return SummaryRow(
      r.observedAt.toIso8601String().substring(0, 10),
      '${lab?.analyteLabel ?? s.recordKind(r.kind)}: $value',
      notes,
    );
  }

  /// A self-contained HTML page (no scripts, no outside links) for
  /// printing or sharing. Every value is escaped.
  String toHtml(String lang) {
    String e(String t) => t
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
    final b = StringBuffer()
      ..writeln('<!doctype html>')
      ..writeln('<html lang="${e(lang)}"><head><meta charset="utf-8">')
      ..writeln('<title>${e(title)}</title>')
      ..writeln(
        '<style>body{font-family:system-ui,sans-serif;margin:24px;color:#111}'
        'h1{font-size:20px}h2{font-size:16px;margin-top:20px}'
        'table{border-collapse:collapse;width:100%}'
        'td{border-bottom:1px solid #ccc;padding:4px 8px;vertical-align:top}'
        '.n{color:#555;font-size:13px}</style></head><body>',
      )
      ..writeln('<h1>${e(title)}</h1>')
      ..writeln('<p class="n">${e(createdAt)}</p>');
    for (final sec in sections) {
      b.writeln('<h2>${e(sec.title)}</h2>');
      if (sec.partNote.isNotEmpty) {
        b.writeln('<p class="n">${e(sec.partNote)}</p>');
      }
      b.writeln('<table>');
      for (final r in sec.rows) {
        b.writeln(
          '<tr><td>${e(r.when)}</td><td>${e(r.value)}</td>'
          '<td class="n">${e(r.note)}</td></tr>',
        );
      }
      b.writeln('</table>');
    }
    for (final f in footer) {
      b.writeln('<p class="n">${e(f)}</p>');
    }
    b.writeln('</body></html>');
    return b.toString();
  }
}
