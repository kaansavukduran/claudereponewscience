// Architecture guard: the app makes no network calls and the pure domain
// layer never imports Flutter or platform IO.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> dartFiles(String dir) => Directory(dir).existsSync()
    ? Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
    : const <File>[];

/// Directives (import/export/part, either quote style) that pull a banned
/// library into a pure-Dart file.
final RegExp _directive = RegExp(
  r'''^\s*(import|export|part)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

const List<String> _bannedInDomain = [
  'package:flutter/',
  'package:flutter_test/',
  'dart:io',
  'dart:html',
  'dart:ui',
  'dart:js_interop',
  'package:web/',
  'package:http/',
];

List<String> bannedDirectives(String source) => [
  for (final m in _directive.allMatches(source))
    if (_bannedInDomain.any((b) => m.group(2)!.startsWith(b))) m.group(2)!,
];

void main() {
  test('lib/ has no network clients (offline core)', () {
    final offenders = <String>[];
    for (final f in dartFiles('lib')) {
      final src = f.readAsStringSync();
      for (final banned in [
        'package:http/',
        'HttpClient',
        'package:dio/',
        'WebSocket',
        'Socket.connect',
        'RawSocket',
      ]) {
        if (src.contains(banned)) offenders.add('${f.path}: $banned');
      }
    }
    expect(offenders, isEmpty);
  });

  test('dart:io is confined to the native storage adapter', () {
    final offenders = [
      for (final f in dartFiles('lib'))
        if (f.readAsStringSync().contains("import 'dart:io'") &&
            !f.path.endsWith('data/local/storage_io.dart'))
          f.path,
    ];
    expect(offenders, isEmpty);
  });

  test('the domain guard catches every directive form', () {
    expect(bannedDirectives('import "package:flutter/material.dart";'), [
      'package:flutter/material.dart',
    ]);
    expect(bannedDirectives("export 'dart:io' show File;"), ['dart:io']);
    expect(bannedDirectives("  part 'dart:ui';"), ['dart:ui']);
    expect(bannedDirectives("import 'dart:convert';"), isEmpty);
    expect(bannedDirectives("// import 'dart:io';"), isEmpty);
  });

  test('lib/src/domain exists and stays pure Dart', () {
    final files = dartFiles('lib/src/domain').toList();
    expect(files, isNotEmpty, reason: 'domain layer must not vanish silently');
    final offenders = [
      for (final f in files)
        for (final d in bannedDirectives(f.readAsStringSync())) '${f.path}: $d',
    ];
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
