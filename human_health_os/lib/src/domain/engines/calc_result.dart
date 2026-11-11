/// Shared result envelope for the deterministic engines (F011, D-037).
///
/// Dart port of `packages/domain/src/result.ts`, the reference oracle. The
/// invariants are the same: missing is not zero, an invalid calculation is
/// never a fake zero, and every result carries its model ID and version,
/// its inputs, the inputs that were missing and its limitations. A result
/// is a model output, never an observed fact.
library;

/// The class of a computed result (master v0.24 R1–R7).
enum ResultClass {
  populationBaseline('POPULATION_BASELINE'),
  validatedRisk('VALIDATED_RISK'),
  appComposite('APP_COMPOSITE'),
  coverage('COVERAGE'),
  adherence('ADHERENCE'),
  derivedMeasurement('DERIVED_MEASUREMENT'),
  experimental('EXPERIMENTAL');

  const ResultClass(this.code);

  /// The contract spelling, as in the golden vectors and the TS reference.
  final String code;
}

/// Outcome of a calculation.
enum CalcStatus {
  ok('OK'),
  missingInput('MISSING_INPUT'),
  invalidInput('INVALID_INPUT'),
  notEligible('NOT_ELIGIBLE'),
  unavailable('UNAVAILABLE');

  const CalcStatus(this.code);

  /// The contract spelling, as in the golden vectors and the TS reference.
  final String code;
}

/// A model (or rule) identity: ID, version, class, unit and limitations.
class ModelRef {
  const ModelRef({
    required this.modelId,
    required this.version,
    required this.resultClass,
    required this.unit,
    this.limitations = const [],
  });

  final String modelId;
  final String version;
  final ResultClass resultClass;

  /// Declared unit of the value; null when the value keeps the input's unit.
  final String? unit;
  final List<String> limitations;
}

/// The result of one deterministic calculation.
class CalcResult {
  const CalcResult._({
    required this.status,
    required this.value,
    required this.model,
    required this.inputs,
    required this.missingInputs,
    required this.errorCode,
  });

  /// A successful calculation.
  factory CalcResult.ok(
    ModelRef m,
    double value,
    Map<String, Object?> inputs,
  ) => CalcResult._(
    status: CalcStatus.ok,
    value: value,
    model: m,
    inputs: inputs,
    missingInputs: const [],
    errorCode: null,
  );

  /// A refused calculation: no value, an error code and, when inputs were
  /// missing, their names.
  factory CalcResult.fail(
    ModelRef m,
    CalcStatus status,
    String errorCode,
    Map<String, Object?> inputs, [
    List<String> missingInputs = const [],
  ]) {
    assert(status != CalcStatus.ok, 'a failure cannot be OK');
    return CalcResult._(
      status: status,
      value: null,
      model: m,
      inputs: inputs,
      missingInputs: List.unmodifiable(missingInputs),
      errorCode: errorCode,
    );
  }

  final CalcStatus status;

  /// Present only when [status] is [CalcStatus.ok]. Never substituted with 0.
  final double? value;
  final ModelRef model;

  /// The inputs as given (not normalised).
  final Map<String, Object?> inputs;
  final List<String> missingInputs;
  final String? errorCode;

  String get modelId => model.modelId;
  String get version => model.version;
  ResultClass get resultClass => model.resultClass;
  String? get unit => model.unit;
  List<String> get limitations => model.limitations;
}

/// A value is present only if it is a finite number. null, NaN, infinities
/// and non-numbers are missing, never 0.
bool isPresent(Object? v) => v is num && v.isFinite;

/// The keys of [inputs] whose value is not [isPresent], in [keys] order.
List<String> missingKeys(Map<String, Object?> inputs, List<String> keys) => [
  for (final k in keys)
    if (!isPresent(inputs[k])) k,
];

/// [v] as a double when present, otherwise null.
double? presentOrNull(Object? v) =>
    isPresent(v) ? (v! as num).toDouble() : null;
