import '../domain/errors.dart';

class InputError implements Exception, CodedError {
  const InputError(this.code, [this.field]);

  /// Stable code; the UI maps it to localized text.
  /// `EMPTY` · `NOT_A_NUMBER` · `OUT_OF_RANGE` · `FUTURE_TIME` ·
  /// `TARGET_NOT_FOUND` · `TARGET_NOT_CURRENT` · `TARGET_WRONG_KIND` ·
  /// `LAB_ANALYTE_EMPTY` · `DATE_INVALID` · `AMBIGUOUS_SEPARATOR` ·
  /// `NOT_POSITIVE` · `BP_ORDER` · `CONTEXT_TOO_LONG` ·
  /// `OUT_OF_DEFINITION` · `TIME_FORMAT` · `TIME_TOO_OLD` ·
  /// `TIME_DOES_NOT_EXIST` · `TIME_AMBIGUOUS`
  @override
  final String code;

  /// Which input the error belongs to, when a form has several
  /// (`value`, `systolic`, `diastolic`, `context`); null otherwise.
  final String? field;

  @override
  String toString() => 'InputError($code)';
}
