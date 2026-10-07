/// A laboratory result as the report printed it (ladder F004).
///
/// Pure Dart. Everything here is **source text**, kept verbatim: the
/// analyte label, the printed flag and the printed reference range. None of
/// it is an app interpretation; Human OS does not compare values with ranges
/// or label results (reference interval ≠ optimal target ≠ clinical decision
/// limit; outside reference ≠ critical). A field the report did not print is
/// null, never a default.
library;

class LabDetails {
  const LabDetails({
    required this.analyteLabel,
    this.specimen,
    this.laboratory,
    this.sourceFlag,
    this.referenceText,
  });

  /// The test name exactly as printed (e.g. "HbA1c", "LDL Kolesterol").
  /// Not mapped to a code: the same display name is not the same measurand.
  final String analyteLabel;

  /// Sample type as printed (e.g. "serum"); null = not given.
  final String? specimen;

  /// Laboratory or provider as printed; null = not given.
  final String? laboratory;

  /// The flag the laboratory printed next to the value (e.g. "H", "↑", "*"),
  /// verbatim; null = no flag printed. Never computed by the app.
  final String? sourceFlag;

  /// The reference range exactly as printed (e.g. "70 - 100", "< 130");
  /// null = no range printed. Not parsed into numbers in F004.
  final String? referenceText;

  Map<String, Object?> toJson() => {
    'analyte_label': analyteLabel,
    'specimen': specimen,
    'laboratory': laboratory,
    'source_flag': sourceFlag,
    'reference_text': referenceText,
  };

  static LabDetails fromJson(Map<String, Object?> j) => LabDetails(
    analyteLabel: j['analyte_label']! as String,
    specimen: j['specimen'] as String?,
    laboratory: j['laboratory'] as String?,
    sourceFlag: j['source_flag'] as String?,
    referenceText: j['reference_text'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is LabDetails &&
      other.analyteLabel == analyteLabel &&
      other.specimen == specimen &&
      other.laboratory == laboratory &&
      other.sourceFlag == sourceFlag &&
      other.referenceText == referenceText;

  @override
  int get hashCode => Object.hash(
    analyteLabel,
    specimen,
    laboratory,
    sourceFlag,
    referenceText,
  );
}
