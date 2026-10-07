/// Errors that carry a stable, data-free code (ladder F006, master §37).
///
/// Logs, consoles and error screens show an error only as its type and
/// this code (`describeError` in core/redact.dart). Messages may hold
/// values, paths or record ids and are never rendered there.
library;

abstract interface class CodedError {
  /// Upper-case identifier such as `WRONG_KEY` or `DIGEST_MISMATCH`. Never
  /// contains health data, secrets or paths.
  String get code;
}
