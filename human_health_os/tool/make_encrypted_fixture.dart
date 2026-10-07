// Seals a plaintext vault-log fixture into an encrypted envelope fixture
// (F006). Run from human_health_os/:
//   dart run tool/make_encrypted_fixture.dart \
//     test/fixtures/vault/v1_f004_schema3.hhoslog.jsonl \
//     test/fixtures/vault/enc_v1_f006.hhosvault
// The passphrase and recovery key are synthetic and published in
// test/fixtures/vault/README.md; the fixture holds no real health data.
import 'dart:io';

import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/vault_envelope.dart';

const fixturePassphrase = 'fixture passphrase F006 (synthetic)';
const fixtureRecoveryKey = 'K7QM-2XRA-PLMN-B3DE-ZZ4H-QW5T-RT6Y-HJ7U';

Future<void> main(List<String> args) async {
  final lines = File(args[0]).readAsLinesSync();
  final raw = MemoryLogSink();
  final sink = EncryptedLogSink.forNewVault(
    raw,
    passphrase: fixturePassphrase,
    recoveryKey: fixtureRecoveryKey,
    derive: deriveInline,
    newKdf: KdfParams.forNewKey,
  );
  await sink.create(lines.first);
  for (final l in lines.skip(1)) {
    await sink.appendLine(l);
  }
  File(args[1]).writeAsStringSync(raw.text!);
  stdout.writeln('wrote ${args[1]} (${raw.text!.length} bytes)');
}
