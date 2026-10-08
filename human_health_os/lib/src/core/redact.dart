/// Privacy-preserving observability (master §37, ladder F006): the one place
/// that turns errors and events into text for a console, a log or an error
/// screen. Nothing else in `lib/` prints.
///
/// Rules:
/// - an error is shown as its type and, for a [CodedError], its code; the
///   message is never shown (it may hold values, paths or record ids);
/// - an event carries only safe fields: numbers, booleans, enum names and
///   short code-like words; anything else becomes `<redacted>`;
/// - stack traces (frames only, no data) appear in debug builds only.
library;

import 'package:flutter/foundation.dart';

import '../domain/errors.dart';

final RegExp _code = RegExp(r'^[A-Z][A-Z0-9_]{0,63}$');

/// Event names, field keys and string field values: lower-case words with
/// underscores only. Ids (with dashes), recovery keys (upper case), values
/// (with dots or commas) and paths never match (review hardening).
final RegExp _safeWord = RegExp(r'^[a-z][a-z0-9_]{0,63}$');

/// `Type(CODE)` for a coded error, `Type` otherwise. Never the message.
String describeError(Object error) {
  final type = error.runtimeType.toString();
  if (error is CodedError) {
    final code = error.code;
    if (_code.hasMatch(code)) return '$type($code)';
  }
  return type;
}

/// The code of a coded error, else null.
String? errorCode(Object error) =>
    error is CodedError && _code.hasMatch(error.code) ? error.code : null;

String _field(Object? v) => switch (v) {
  null => 'null',
  int() || double() || bool() => '$v',
  Enum() => v.name,
  String() when _safeWord.hasMatch(v) => v,
  _ => '<redacted>',
};

/// Formats one log line: `[hhos] event key=value …` with safe values only.
String formatEvent(
  String event, {
  Object? error,
  Map<String, Object?> fields = const {},
}) {
  final b = StringBuffer('[hhos] ${_field(event)}');
  if (error != null) b.write(' error=${describeError(error)}');
  for (final e in fields.entries) {
    b.write(' ${_field(e.key)}=${_field(e.value)}');
  }
  return b.toString();
}

/// Writes one redacted log line through [debugPrint].
void logEvent(
  String event, {
  Object? error,
  StackTrace? stack,
  Map<String, Object?> fields = const {},
}) {
  debugPrint(formatEvent(event, error: error, fields: fields));
  if (kDebugMode && stack != null) debugPrintStack(stackTrace: stack);
}

/// Reports a framework error redacted. Flutter's own presentation prints
/// the error message and widget descriptions (which can quote on-screen
/// health values), so this replaces it in every build.
void reportFlutterError(FlutterErrorDetails details) => logEvent(
  'ui_error',
  error: details.exception,
  stack: details.stack,
  fields: {'library': details.library?.toLowerCase().replaceAll(' ', '_')},
);

/// Reports an uncaught error redacted; it counts as handled.
bool reportUncaughtError(Object error, StackTrace stack) {
  logEvent('uncaught_error', error: error, stack: stack);
  return true;
}

/// Routes framework and uncaught errors through [logEvent]. The handler is
/// set on [PlatformDispatcher.instance] itself: it is the binding's
/// dispatcher in the app, and the test binding's wrapper drops assignments
/// to `onError` (flutter_test window.dart), which would hide a regression.
void installRedactedErrorReporting() {
  FlutterError.onError = reportFlutterError;
  PlatformDispatcher.instance.onError = reportUncaughtError;
}
