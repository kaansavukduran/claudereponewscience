// F002@v0.32 exit gate "no plaintext-secret shortcut" (master §39): the
// unencrypted development vault never holds key material, never claims to
// be encrypted, and the app takes no secret through --dart-define. Staging,
// production and portable builds stay memory-only (storage_policy_test).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';

final RegExp _secretKey = RegExp(
  r'(key|secret|passphrase|password|token|salt|nonce|credential)',
  caseSensitive: false,
);

/// Every JSON object key anywhere in [node].
Iterable<String> keysOf(Object? node) sync* {
  if (node is Map) {
    for (final e in node.entries) {
      yield e.key as String;
      yield* keysOf(e.value);
    }
  } else if (node is List) {
    for (final v in node) {
      yield* keysOf(v);
    }
  }
}

void main() {
  test('the development vault holds no key material and says it is '
      'unencrypted', () async {
    final sink = MemoryLogSink();
    final repo = LogRepository(
      sink: sink,
      durability: StorageDurability.localFile,
      location: 'test',
    );
    await repo.open();
    final svc = HeartbeatService(repo);
    final me = await svc.ensureSelfProfile();
    await svc.recordWeightKg(profileId: me.id, input: '72,5');

    expect(repo.description.encrypted, isFalse);
    final lines = const LineSplitter().convert(sink.text!);
    final head = jsonDecode(lines.first) as Map<String, Object?>;
    expect(head['encryption'], encryptionNoneDevOnly);
    for (final line in lines) {
      final keys = keysOf(jsonDecode(line)).toList();
      expect(
        keys.where(_secretKey.hasMatch),
        isEmpty,
        reason: 'no secret-like field in: $line',
      );
    }
  });

  test('the app reads only build identity from --dart-define', () {
    final allowed = {'APP_ENV', 'APP_VERSION', 'SOURCE_REVISION'};
    final define = RegExp(
      r'''(String|bool|int)\.fromEnvironment\(\s*['"]([^'"]+)['"]''',
    );
    final found = <String>{};
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      for (final m in define.allMatches(f.readAsStringSync())) {
        found.add(m.group(2)!);
      }
    }
    expect(found.difference(allowed), isEmpty);
    expect(found, isNotEmpty, reason: 'the scan itself works');
  });
}
