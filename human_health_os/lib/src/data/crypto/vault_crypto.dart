/// Cryptography for the encrypted vault (ladder F006, decision D-016).
///
/// Reviewed library only (`pointycastle` 4.0.0, the Dart port of Bouncy
/// Castle); nothing here is a home-made primitive:
/// - key derivation: Argon2id v1.3 (RFC 9106) at the OWASP minimum cost
///   (19 MiB, 2 passes, 1 lane); the parameters are stored with each key;
/// - authenticated encryption: ChaCha20-Poly1305 (RFC 8439) with a 256-bit
///   key, a 96-bit random nonce and a 128-bit tag; associated data binds a
///   ciphertext to its place, so it cannot be moved without failing.
///
/// Native builds only. Compiled to JavaScript, pointycastle's Poly1305
/// needs 64-bit integers it does not have and Argon2id takes seconds
/// (measured in F006), so web builds do not encrypt (gap G-32).
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../../domain/errors.dart';

/// A cryptographic step failed. Nothing about the data is in it.
class CryptoFailure implements Exception, CodedError {
  const CryptoFailure(this.code);

  /// `NOT_AUTHENTIC`: authentication failed (wrong key, or the data or its
  /// associated data changed) · `KDF_UNSUPPORTED`: key-derivation
  /// parameters this app does not accept.
  @override
  final String code;

  @override
  String toString() => 'CryptoFailure($code)';
}

/// Argon2id cost parameters, stored next to every wrapped key.
class KdfParams {
  const KdfParams({
    required this.salt,
    this.memoryKib = defaultMemoryKib,
    this.iterations = defaultIterations,
    this.parallelism = defaultParallelism,
  });

  /// OWASP Password Storage Cheat Sheet minimum for Argon2id.
  static const int defaultMemoryKib = 19456;
  static const int defaultIterations = 2;
  static const int defaultParallelism = 1;

  /// Limits for parameters read from a file, so a damaged or hostile header
  /// cannot make the app allocate gigabytes or spin for hours.
  static const int maxMemoryKib = 1048576;
  static const int maxIterations = 64;
  static const int maxParallelism = 16;

  /// Parameters for a new key: a fresh 16-byte salt and the default cost.
  factory KdfParams.forNewKey() => KdfParams(salt: randomBytes(16));

  final Uint8List salt;
  final int memoryKib;
  final int iterations;
  final int parallelism;

  Map<String, Object?> toJson() => {
    'alg': 'argon2id',
    'version': 19,
    'memory_kib': memoryKib,
    'iterations': iterations,
    'parallelism': parallelism,
    'salt': base64Encode(salt),
  };

  /// Throws [CryptoFailure] `KDF_UNSUPPORTED` for anything but Argon2id
  /// v1.3 within the limits above.
  static KdfParams fromJson(Map<String, Object?> j) {
    final m = j['memory_kib'], t = j['iterations'], p = j['parallelism'];
    final salt = j['salt'];
    if (j['alg'] != 'argon2id' ||
        j['version'] != 19 ||
        m is! int ||
        t is! int ||
        p is! int ||
        salt is! String ||
        p < 1 ||
        p > maxParallelism ||
        t < 1 ||
        t > maxIterations ||
        m < 8 * p ||
        m > maxMemoryKib) {
      throw const CryptoFailure('KDF_UNSUPPORTED');
    }
    final Uint8List bytes;
    try {
      bytes = base64Decode(salt);
    } on FormatException {
      throw const CryptoFailure('KDF_UNSUPPORTED');
    }
    if (bytes.length < 16 || bytes.length > 64) {
      throw const CryptoFailure('KDF_UNSUPPORTED');
    }
    return KdfParams(salt: bytes, memoryKib: m, iterations: t, parallelism: p);
  }
}

final Random _rng = Random.secure();

/// Bytes from the operating system's secure random source.
Uint8List randomBytes(int n) =>
    Uint8List.fromList(List<int>.generate(n, (_) => _rng.nextInt(256)));

/// Derives a 256-bit key from [secret] (UTF-8) with Argon2id. Slow by
/// design (about 0.25 s natively): call it off the UI thread.
Uint8List deriveKey(String secret, KdfParams p) {
  final gen = Argon2BytesGenerator()
    ..init(
      Argon2Parameters(
        Argon2Parameters.ARGON2_id,
        p.salt,
        desiredKeyLength: 32,
        iterations: p.iterations,
        memory: p.memoryKib,
        lanes: p.parallelism,
        version: Argon2Parameters.ARGON2_VERSION_13,
      ),
    );
  return gen.process(Uint8List.fromList(utf8.encode(secret)));
}

/// Encrypts [plain] under [key] with a fresh random nonce.
({Uint8List nonce, Uint8List sealed}) seal(
  Uint8List key,
  Uint8List plain,
  Uint8List aad,
) {
  final nonce = randomBytes(12);
  return (nonce: nonce, sealed: sealWithNonce(key, nonce, plain, aad));
}

/// Encrypts with a given nonce (known-answer tests). A nonce must never be
/// used twice with one key; [seal] picks a random one.
Uint8List sealWithNonce(
  Uint8List key,
  Uint8List nonce,
  Uint8List plain,
  Uint8List aad,
) {
  final c = ChaCha20Poly1305(ChaCha7539Engine(), Poly1305())
    ..init(true, AEADParameters(KeyParameter(key), 128, nonce, aad));
  final out = Uint8List(c.getOutputSize(plain.length));
  var n = c.processBytes(plain, 0, plain.length, out, 0);
  n += c.doFinal(out, n);
  return Uint8List.sublistView(out, 0, n);
}

/// Decrypts and authenticates. Throws [CryptoFailure] `NOT_AUTHENTIC` when
/// the key, nonce, ciphertext, tag or associated data do not match; no
/// unauthenticated byte is ever returned.
Uint8List openSealed(
  Uint8List key,
  Uint8List nonce,
  Uint8List sealed,
  Uint8List aad,
) {
  if (key.length != 32 || nonce.length != 12 || sealed.length < 16) {
    throw const CryptoFailure('NOT_AUTHENTIC');
  }
  try {
    final c = ChaCha20Poly1305(ChaCha7539Engine(), Poly1305())
      ..init(false, AEADParameters(KeyParameter(key), 128, nonce, aad));
    final out = Uint8List(c.getOutputSize(sealed.length));
    var n = c.processBytes(sealed, 0, sealed.length, out, 0);
    n += c.doFinal(out, n);
    return Uint8List.sublistView(out, 0, n);
  } on InvalidCipherTextException {
    throw const CryptoFailure('NOT_AUTHENTIC');
  } on ArgumentError {
    throw const CryptoFailure('NOT_AUTHENTIC');
  } on StateError {
    throw const CryptoFailure('NOT_AUTHENTIC');
  }
}
