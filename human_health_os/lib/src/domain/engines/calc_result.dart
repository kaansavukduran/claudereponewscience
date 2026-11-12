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

  /// A successful calculation. A non-finite value (NaN or an infinity,
  /// e.g. from an overflow) is never reported as a result: it becomes an
  /// INVALID_INPUT refusal with the code [nonFiniteResultCode] and no value.
  factory CalcResult.ok(ModelRef m, double value, Map<String, Object?> inputs) {
    if (!value.isFinite) {
      return CalcResult.fail(
        m,
        CalcStatus.invalidInput,
        nonFiniteResultCode,
        inputs,
      );
    }
    return CalcResult._(
      status: CalcStatus.ok,
      value: value,
      model: m,
      inputs: _frozen(inputs),
      missingInputs: const [],
      errorCode: null,
    );
  }

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
      inputs: _frozen(inputs),
      missingInputs: List.unmodifiable(missingInputs),
      errorCode: errorCode,
    );
  }

  final CalcStatus status;

  /// Present only when [status] is [CalcStatus.ok]. Never substituted with 0.
  final double? value;
  final ModelRef model;

  /// An unmodifiable copy of the inputs as given (not normalised); changing
  /// the caller's map afterwards does not change the result.
  final Map<String, Object?> inputs;
  final List<String> missingInputs;
  final String? errorCode;

  String get modelId => model.modelId;
  String get version => model.version;
  ResultClass get resultClass => model.resultClass;
  String? get unit => model.unit;
  List<String> get limitations => model.limitations;
}

/// Error code of a calculation whose arithmetic gave NaN or an infinity
/// (all engines use it for a number, or a number inside a map, that is not
/// finite).
const String nonFiniteResultCode = 'NON_FINITE_RESULT';

/// A deep, unmodifiable copy of an input value (maps and lists are copied;
/// other values are immutable in the engines' JSON-like inputs).
Object? _freezeValue(Object? v) {
  if (v is Map && v.keys.every((k) => k is String)) {
    return Map<String, Object?>.unmodifiable({
      for (final e in v.entries) e.key as String: _freezeValue(e.value),
    });
  }
  if (v is Map) {
    return Map<Object?, Object?>.unmodifiable({
      for (final e in v.entries) e.key: _freezeValue(e.value),
    });
  }
  if (v is List) return List<Object?>.unmodifiable(v.map(_freezeValue));
  return v;
}

Map<String, Object?> _frozen(Map<String, Object?> inputs) =>
    Map<String, Object?>.unmodifiable({
      for (final e in inputs.entries) e.key: _freezeValue(e.value),
    });

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
