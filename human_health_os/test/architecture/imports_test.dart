// Architecture guard: the shell makes no network calls and the (future) pure
// domain layer never imports Flutter or platform IO.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> dartFiles(String dir) => Directory(dir).existsSync()
    ? Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
    : const <File>[];

void main() {
  test('lib/ has no network client imports (offline core)', () {
    final offenders = <String>[];
    for (final f in dartFiles('lib')) {
      final src = f.readAsStringSync();
      for (final banned in [
        'package:http/',
        'dart:io',
        'HttpClient',
        'package:dio/',
        'WebSocket',
      ]) {
        if (src.contains(banned)) offenders.add('${f.path}: $banned');
      }
    }
    expect(offenders, isEmpty);
  });

  test('lib/src/domain stays pure Dart', () {
    final offenders = <String>[];
    for (final f in dartFiles('lib/src/domain')) {
      final src = f.readAsStringSync();
      for (final banned in [
        'package:flutter/',
        'dart:io',
        'dart:html',
        'dart:ui',
        'package:web/',
      ]) {
        if (src.contains("import '$banned")) {
          offenders.add('${f.path}: $banned');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('no secrets-looking literals in lib/', () {
    final pattern = RegExp(
      r'(api[_-]?key|secret|password|BEGIN (RSA|EC|PRIVATE) KEY)\s*[:=]\s*["\x27][^"\x27]{8,}',
      caseSensitive: false,
    );
    final offenders = [
      for (final f in dartFiles('lib'))
        if (pattern.hasMatch(f.readAsStringSync())) f.path,
    ];
    expect(offenders, isEmpty);
  });
}
