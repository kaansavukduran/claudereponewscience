/// Structured values of measurement kinds (ladder F007, record schema 4).
///
/// Pure Dart. A kind whose value is more than one number keeps it here,
/// tagged with its type, instead of in a single quantity: a blood pressure
/// reading is one record with two numbers, never two records and never one
/// number shown as "the" reading. Every number keeps the text it was typed
/// as. Nothing here is an interpretation: no category, stage or range.
library;

/// The kind-tagged structured value of a record (`details` in JSON). Later
/// structured kinds add a subtype and a `type` value, not a new JSON key.
abstract class RecordDetails {
  const RecordDetails();

  /// Stable tag written as `type`.
  String get type;

  Map<String, Object?> toJson();

  /// Throws [FormatException] for a type this app does not know (written by
  /// a newer app; such a record also carries a newer schema version).
  static RecordDetails fromJson(Map<String, Object?> j) => switch (j['type']) {
    BloodPressureDetails.typeTag => BloodPressureDetails.fromJson(j),
    final t => throw FormatException('Unknown details type "$t"'),
  };
}

/// One blood pressure reading: systolic (the upper number) and diastolic
/// (the lower number) in the same unit, each with the text it was typed as.
class BloodPressureDetails extends RecordDetails {
  const BloodPressureDetails({
    required this.systolic,
    required this.diastolic,
    this.unit = 'mmHg',
    this.systolicText,
    this.diastolicText,
  });

  static const String typeTag = 'blood_pressure';

  final double systolic;
  final double diastolic;

  /// As recorded; only mmHg is stored (no conversion rule exists).
  final String unit;

  /// The numbers exactly as typed (e.g. "118"); null when not typed by a
  /// person.
  final String? systolicText;
  final String? diastolicText;

  @override
  String get type => typeTag;

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'systolic': systolic,
    'diastolic': diastolic,
    'unit': unit,
    'systolic_text': systolicText,
    'diastolic_text': diastolicText,
  };

  static BloodPressureDetails fromJson(Map<String, Object?> j) =>
      BloodPressureDetails(
        systolic: (j['systolic']! as num).toDouble(),
        diastolic: (j['diastolic']! as num).toDouble(),
        unit: j['unit']! as String,
        systolicText: j['systolic_text'] as String?,
        diastolicText: j['diastolic_text'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is BloodPressureDetails &&
      other.systolic == systolic &&
      other.diastolic == diastolic &&
      other.unit == unit &&
      other.systolicText == systolicText &&
      other.diastolicText == diastolicText;

  @override
  int get hashCode =>
      Object.hash(systolic, diastolic, unit, systolicText, diastolicText);
}
