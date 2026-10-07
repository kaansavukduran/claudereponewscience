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

/// Ways Dart code can reach the network. Patterns, not exact spellings, so
/// `@JS("fetch")`, `@JS( 'fetch' )` or an `external ... fetch(` binding are
/// caught too (audit EH-6). The web smoke's 0-external-requests check is the
/// runtime counterpart.
final List<RegExp> _networkPatterns = [
  RegExp(r'package:(http|dio|web|web_socket_channel)/'),
  RegExp(r'\bHttpClient\b'),
  RegExp(r'\bWebSocket\b'),
  RegExp(r'\b(Raw)?Socket\.connect\b'),
  RegExp(r'\bXMLHttpRequest\b'),
  RegExp(r'\bEventSource\b'),
  RegExp(r"""@JS\(\s*['"](window\.)?fetch['"]\s*\)"""),
  RegExp(r'\bexternal\b[^;{]*\bfetch\s*\('),
  RegExp(r'\bwindow\.fetch\b'),
  RegExp(r'dart:js_interop_unsafe'),
  RegExp(r'\bImage\.network\b'),
  RegExp(r'\bNetworkImage\b'),
];

List<String> networkUses(String source) => [
  for (final p in _networkPatterns)
    if (p.hasMatch(source)) p.pattern,
];

void main() {
  test('the network guard catches every spelling it claims to', () {
    for (final sample in [
      "import 'package:http/http.dart' as http;",
      "@JS('fetch')",
      '@JS( "fetch" ) external JSPromise f(JSString u);',
      'external JSPromise<JSAny?> fetch(JSString url);',
      "import 'dart:js_interop_unsafe';",
      'final c = HttpClient();',
      "Image.network('https://x')",
      'const NetworkImage(url)',
      'XMLHttpRequest()',
    ]) {
      expect(networkUses(sample), isNotEmpty, reason: sample);
    }
    for (final ok in [
      "@JS('localStorage') external _Storage? get _localStorage;",
      '// a comment about fetching data later',
      "import 'dart:js_interop';",
    ]) {
      expect(networkUses(ok), isEmpty, reason: ok);
    }
  });

  test('lib/ has no network clients (offline core)', () {
    final offenders = [
      for (final f in dartFiles('lib'))
        for (final p in networkUses(f.readAsStringSync())) '${f.path}: $p',
    ];
    expect(offenders, isEmpty);
  });

  // Native adapters, reached only through the conditional import in
  // data/local/storage.dart (never compiled for the web).
  const nativeAdapters = [
    'data/local/storage_io.dart',
    'data/backup/data_files_io.dart', // F005: backup/export files
  ];

  test('dart:io is confined to the native storage adapters', () {
    final offenders = [
      for (final f in dartFiles('lib'))
        if (f.readAsStringSync().contains("import 'dart:io'") &&
            !nativeAdapters.any(f.path.endsWith))
          f.path,
    ];
    expect(offenders, isEmpty);
  });

  test('native adapters are imported only by the native storage adapter', () {
    final importers = [
      for (final f in dartFiles('lib'))
        if (f.readAsStringSync().contains("data_files_io.dart'") &&
            !f.path.endsWith('data/local/storage_io.dart'))
          f.path,
    ];
    expect(importers, isEmpty);
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
