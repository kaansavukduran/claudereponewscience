// F006@v0.32 AC-1: the vault's cryptography gives the published known
// answers (RFC 8439 §2.8.2, RFC 9106 §5.3) and matches an independent
// implementation (the Argon2 reference C code via argon2-cffi 23) for the
// exact parameters and text encoding the app uses.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/data/crypto/recovery_key.dart';
import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:pointycastle/export.dart';

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
Uint8List unhex(String s) => Uint8List.fromList([
  for (var i = 0; i < s.length; i += 2)
    int.parse(s.substring(i, i + 2), radix: 16),
]);

Matcher cryptoFailure(String code) =>
    throwsA(isA<CryptoFailure>().having((e) => e.code, 'code', code));

void main() {
  group('ChaCha20-Poly1305 (RFC 8439 §2.8.2)', () {
    final key = Uint8List.fromList(List.generate(32, (i) => 0x80 + i));
    final nonce = unhex('070000004041424344454647');
    final aad = unhex('50515253c0c1c2c3c4c5c6c7');
    final plain = Uint8List.fromList(
      utf8.encode(
        "Ladies and Gentlemen of the class of '99: If I could offer you only "
        'one tip for the future, sunscreen would be it.',
      ),
    );
    const expected =
        'd31a8d34648e60db7b86afbc53ef7ec2a4aded51296e08fea9e2b5a736ee62d6'
        '3dbea45e8ca9671282fafb69da92728b1a71de0a9e060b2905d6a5b67ecd3b36'
        '92ddbd7f2d778b8c9803aee328091b58fab324e4fad675945585808b4831d7bc'
        '3ff4def08e4b7a9de576d26586cec64b6116'
        '1ae10b594f09e26a7e902ecbd0600691';

    test('sealing gives the published ciphertext and tag', () {
      expect(hex(sealWithNonce(key, nonce, plain, aad)), expected);
    });

    test('opening gives the plaintext back', () {
      expect(openSealed(key, nonce, unhex(expected), aad), plain);
    });

    test('a changed byte, tag, nonce, key or associated data never opens', () {
      final good = unhex(expected);
      for (final i in [0, 50, good.length - 1]) {
        final bad = Uint8List.fromList(good)..[i] ^= 1;
        expect(
          () => openSealed(key, nonce, bad, aad),
          cryptoFailure('NOT_AUTHENTIC'),
        );
      }
      final otherNonce = Uint8List.fromList(nonce)..[11] ^= 1;
      expect(
        () => openSealed(key, otherNonce, good, aad),
        cryptoFailure('NOT_AUTHENTIC'),
      );
      final otherKey = Uint8List.fromList(key)..[0] ^= 1;
      expect(
        () => openSealed(otherKey, nonce, good, aad),
        cryptoFailure('NOT_AUTHENTIC'),
      );
      expect(
        () => openSealed(key, nonce, good, Uint8List(0)),
        cryptoFailure('NOT_AUTHENTIC'),
      );
      expect(
        () => openSealed(key, nonce, good.sublist(0, 15), aad),
        cryptoFailure('NOT_AUTHENTIC'),
      );
    });

    test('seal() picks a fresh random nonce every time', () {
      final nonces = {
        for (var i = 0; i < 64; i++) hex(seal(key, plain, aad).nonce),
      };
      expect(nonces.length, 64);
      final s = seal(key, plain, aad);
      expect(openSealed(key, s.nonce, s.sealed, aad), plain);
    });
  });

  group('Argon2id', () {
    test('RFC 9106 §5.3 test vector (with secret and associated data)', () {
      final gen = Argon2BytesGenerator()
        ..init(
          Argon2Parameters(
            Argon2Parameters.ARGON2_id,
            Uint8List.fromList(List.filled(16, 2)),
            secret: Uint8List.fromList(List.filled(8, 3)),
            additional: Uint8List.fromList(List.filled(12, 4)),
            desiredKeyLength: 32,
            iterations: 3,
            memory: 32,
            lanes: 4,
            version: Argon2Parameters.ARGON2_VERSION_13,
          ),
        );
      expect(
        hex(gen.process(Uint8List.fromList(List.filled(32, 1)))),
        '0d640df58d78766c08c037a34a8b53c9d01ef0452d75b65eb52520e96b01e659',
      );
    });

    test('deriveKey() matches the Argon2 reference implementation at the '
        'production cost', () {
      final p = KdfParams(
        salt: Uint8List.fromList(List.generate(16, (i) => i)),
      );
      expect([p.memoryKib, p.iterations, p.parallelism], [19456, 2, 1]);
      expect(
        hex(deriveKey('correct horse battery staple', p)),
        '818259b6310026a8e0dbac5d2e6927abcfdb07b32258fac4f61b18b80f929085',
      );
    });

    test('a passphrase is derived from its UTF-8 bytes (Turkish letters)', () {
      final p = KdfParams(
        salt: Uint8List.fromList(List.generate(16, (i) => i)),
        memoryKib: 64,
        iterations: 1,
      );
      expect(
        hex(deriveKey('Mavi-Kedi 7 Ağaç Lamba!', p)),
        '68ab7ee83935eb1d068204eb3aa4873de4778d7070a4838042cd9d5ac70ae657',
      );
    });

    test('new keys use the OWASP minimum cost and a fresh 16-byte salt', () {
      final a = KdfParams.forNewKey(), b = KdfParams.forNewKey();
      expect([a.memoryKib, a.iterations, a.parallelism], [19456, 2, 1]);
      expect(a.salt.length, 16);
      expect(hex(a.salt), isNot(hex(b.salt)));
      final round = KdfParams.fromJson(
        jsonDecode(jsonEncode(a.toJson())) as Map<String, Object?>,
      );
      expect(hex(round.salt), hex(a.salt));
      expect(round.memoryKib, a.memoryKib);
    });

    test('parameters from a file are refused outside sane limits', () {
      Map<String, Object?> j([Map<String, Object?> over = const {}]) => {
        ...KdfParams.forNewKey().toJson(),
        ...over,
      };
      for (final bad in [
        {'alg': 'argon2i'},
        {'version': 16},
        {'memory_kib': 4194304},
        {'memory_kib': 4},
        {'iterations': 0},
        {'iterations': 1000},
        {'parallelism': 0},
        {'parallelism': 64},
        {'salt': base64Encode(List.filled(4, 1))},
        {'salt': '%%%'},
        {'memory_kib': '19456'},
      ]) {
        expect(
          () => KdfParams.fromJson(j(bad)),
          cryptoFailure('KDF_UNSUPPORTED'),
          reason: '$bad',
        );
      }
    });
  });

  group('recovery keys', () {
    test('32 base32 characters (160 random bits) in eight groups', () {
      final keys = {for (var i = 0; i < 32; i++) newRecoveryKey()};
      expect(keys.length, 32);
      for (final k in keys) {
        expect(k, matches(RegExp(r'^([A-Z2-7]{4}-){7}[A-Z2-7]{4}$')));
        expect(normalizeRecoveryKey(k), k);
      }
    });

    test('typed variations normalize to the same key; 0/1/8 read as O/I/B', () {
      const k = 'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4567';
      expect(normalizeRecoveryKey(k.toLowerCase()), k);
      expect(normalizeRecoveryKey(k.replaceAll('-', ' ')), k);
      expect(normalizeRecoveryKey(k.replaceAll('-', '')), k);
      expect(
        normalizeRecoveryKey('ABCD EFGH 1JKL MN0P QRST UVWX YZ23 4567'),
        k,
      );
      expect(
        normalizeRecoveryKey('8BCD${k.substring(4)}'),
        'BBCD${k.substring(4)}',
      );
    });

    test('anything else is refused before any slow work', () {
      for (final bad in [
        '',
        'ABCD-EFGH',
        'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4567-ABCD',
        'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-456!',
        'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4569',
      ]) {
        expect(
          () => normalizeRecoveryKey(bad),
          throwsA(isA<RecoveryKeyFormatError>()),
          reason: bad,
        );
      }
    });
  });
}
