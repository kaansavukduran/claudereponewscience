/// How measurements are shown and spoken (ladder F007). A number is shown
/// with the decimals it was typed with, never more ("57" stays 57, "84,25"
/// is 84.25); blood pressure is one reading, "118/76 mmHg"; a value that
/// does not exist is named, never drawn as 0.
library;

import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';

/// [v] with exactly the decimals of [typed] when [typed] is that number,
/// otherwise its shortest form.
String fmtMeasured(double v, String? typed) {
  final t = typed?.trim().replaceAll(' ', '');
  if (t != null) {
    final m = RegExp(r'^\d+(?:[.,](\d+))?$').firstMatch(t);
    if (m != null && double.parse(t.replaceAll(',', '.')) == v) {
      return v.toStringAsFixed(m[1]?.length ?? 0);
    }
  }
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

/// The value of a measurement record with its unit, or its value status.
String measurementValue(S s, HealthRecord r) {
  if (r.valueStatus != ValueStatus.present) return s.valueStatus(r.valueStatus);
  final d = r.details;
  if (d is BloodPressureDetails) {
    return '${fmtMeasured(d.systolic, d.systolicText)}/'
        '${fmtMeasured(d.diastolic, d.diastolicText)} ${s.unit(d.unit)}';
  }
  final q = r.quantity;
  if (q == null) return s.valueStatus(r.valueStatus);
  return '${fmtMeasured(q.value, r.originalText)} ${s.unit(q.unit ?? '')}';
}

/// The value as a screen reader should say it.
String spokenMeasurement(S s, HealthRecord r) {
  if (r.valueStatus != ValueStatus.present) return s.valueStatus(r.valueStatus);
  final d = r.details;
  if (d is BloodPressureDetails) {
    return '${s.spokenBloodPressure(fmtMeasured(d.systolic, d.systolicText), fmtMeasured(d.diastolic, d.diastolicText))} '
        '${s.spokenUnit(d.unit)}';
  }
  final q = r.quantity;
  if (q == null) return s.valueStatus(r.valueStatus);
  return '${fmtMeasured(q.value, r.originalText)} ${s.spokenUnit(q.unit ?? '')}';
}

/// What was typed, when it differs from what is shown ('entered as "…"').
String? typedWhenDifferent(HealthRecord r) {
  final d = r.details;
  if (d is BloodPressureDetails) {
    final typed = '${d.systolicText ?? ''}/${d.diastolicText ?? ''}';
    final shown =
        '${fmtMeasured(d.systolic, d.systolicText)}/'
        '${fmtMeasured(d.diastolic, d.diastolicText)}';
    return (d.systolicText == null && d.diastolicText == null) || typed == shown
        ? null
        : typed;
  }
  final original = r.originalText;
  final q = r.quantity;
  if (original == null || q == null) return null;
  return original == fmtMeasured(q.value, original) ? null : original;
}

/// The newest live entry of a measurement that has a value: a newer "not
/// measured" entry is history, never shown as the latest value.
TimelineEntry? latestWithValue(List<TimelineEntry> entries) =>
    entries.where((e) => e.heads.any(hasMeasuredValue)).firstOrNull;

bool hasMeasuredValue(HealthRecord r) =>
    r.valueStatus == ValueStatus.present &&
    (r.kind.isStructured ? r.details != null : r.quantity != null);
