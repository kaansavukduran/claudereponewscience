/// Encrypted vault envelope `hhos-vault-enc` v1 (ladder F006, D-016).
///
/// The logical vault log (vault_log.dart, format 1) does not change: each
/// of its lines, header included, is sealed on its own and stored as one
/// envelope line, so decrypting an envelope gives back exactly the log a
/// development build would have written in plaintext.
///
///     line 1   {"format":"hhos-vault-enc","envelope_version":1,
///               "vault_id":…,"aead":"chacha20-poly1305","keys":[…]}
///     line 2…  {"s":<sequence>,"n":<nonce>,"c":<sealed log line>}
///
/// Sequence 0 is the log header. A random 256-bit data key seals the lines;
/// the file holds it only wrapped by a key derived (Argon2id) from the
/// passphrase and by one derived from the recovery key. Associated data
/// binds every sealed line to its vault and sequence number, so a line that
/// is changed, moved, copied in from another vault or removed from the
/// middle is detected and skipped with a visible warning, never applied.
/// Lines removed from the end cannot be detected without an outside counter
/// (gap G-35).
library;

import 'dart:convert';
import 'dart:typed_data';

import '../../domain/errors.dart';
import '../crypto/recovery_key.dart';
import '../crypto/vault_crypto.dart';
import 'log_repository.dart' show LogSink;

export 'log_repository.dart' show encryptionEnvelopeV1;
import 'vault_log.dart'
    show
        missingEntryMarker,
        tornEntryMarker,
        unreadableEntryMarker,
        vaultFormat;

const String envelopeFormat = 'hhos-vault-enc';
const int envelopeVersion = 1;
const String envelopeAead = 'chacha20-poly1305';

/// Derives a key from a secret. The native adapter runs Argon2id in an
/// isolate so the UI never freezes; tests and the fallback run it inline.
typedef KeyDeriver = Future<Uint8List> Function(
  String secret,
  KdfParams params,
);

Future<Uint8List> deriveInline(String secret, KdfParams params) async =>
    deriveKey(secret, params);

/// The secret that wraps a copy of the data key.
enum KeyKind { passphrase, recovery }

/// The stored envelope cannot be used. The file is never changed.
class VaultEnvelopeError implements Exception, CodedError {
  const VaultEnvelopeError(this.code);

  /// `ENVELOPE_UNREADABLE` (damaged or not an envelope) · `ENVELOPE_NEWER`
  /// (written by a newer app) · `ENVELOPE_UNSUPPORTED` (cipher or key
  /// parameters this app does not accept) · `NOT_ENCRYPTED` (a plaintext
  /// log where an envelope belongs) · `NO_VAULT` · `VAULT_EXISTS` ·
  /// `NO_SUCH_KEY` (the envelope has no slot for that kind of secret).
  @override
  final String code;

  @override
  String toString() => 'VaultEnvelopeError($code)';
}

Uint8List _utf8(String s) => Uint8List.fromList(utf8.encode(s));

Uint8List _keyAad(String vaultId, KeyKind kind) =>
    _utf8('$envelopeFormat/$envelopeVersion|$vaultId|key:${kind.name}');

Uint8List _entryAad(String vaultId, int seq) =>
    _utf8('$envelopeFormat/$envelopeVersion|$vaultId|entry:$seq');

/// The canonical text a secret is derived from: a passphrase as typed, a
/// recovery key upper-cased and grouped (throws `RECOVERY_KEY_FORMAT`).
String canonicalSecret(KeyKind kind, String secret) =>
    kind == KeyKind.recovery ? normalizeRecoveryKey(secret) : secret;

/// One wrapped copy of the data key.
class KeySlot {
  const KeySlot({
    required this.kind,
    required this.kdf,
    required this.nonce,
    required this.wrapped,
  });

  final KeyKind kind;
  final KdfParams kdf;
  final Uint8List nonce;
  final Uint8List wrapped;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'kdf': kdf.toJson(),
    'nonce': base64Encode(nonce),
    'wrapped': base64Encode(wrapped),
  };

  /// Throws [CryptoFailure] `KDF_UNSUPPORTED`, or [FormatException]/
  /// [TypeError] for a damaged slot.
  static KeySlot fromJson(Map<String, Object?> j) => KeySlot(
    kind: KeyKind.values.byName(j['kind']! as String),
    kdf: KdfParams.fromJson((j['kdf']! as Map).cast<String, Object?>()),
    nonce: base64Decode(j['nonce']! as String),
    wrapped: base64Decode(j['wrapped']! as String),
  );

  static Future<KeySlot> wrap(
    KeyKind kind,
    String secret,
    Uint8List dataKey,
    String vaultId, {
    required KeyDeriver derive,
    required KdfParams kdf,
  }) async {
    final kek = await derive(canonicalSecret(kind, secret), kdf);
    final s = seal(kek, dataKey, _keyAad(vaultId, kind));
    return KeySlot(kind: kind, kdf: kdf, nonce: s.nonce, wrapped: s.sealed);
  }

  /// The data key, or [CryptoFailure] `NOT_AUTHENTIC` when [secret] does
  /// not open this slot (or the slot or vault id was changed).
  Future<Uint8List> unwrap(
    String secret,
    String vaultId,
    KeyDeriver derive,
  ) async {
    final kek = await derive(canonicalSecret(kind, secret), kdf);
    final key = openSealed(kek, nonce, wrapped, _keyAad(vaultId, kind));
    if (key.length != 32) throw const CryptoFailure('NOT_AUTHENTIC');
    return key;
  }
}

/// Line 1 of an envelope. Holds no secret: only wrapped keys and the cost
/// parameters needed to unwrap them.
class EnvelopeHeader {
  const EnvelopeHeader({required this.vaultId, required this.slots});

  final String vaultId;
  final List<KeySlot> slots;

  KeySlot? slot(KeyKind kind) {
    for (final s in slots) {
      if (s.kind == kind) return s;
    }
    return null;
  }

  EnvelopeHeader withSlot(KeySlot replacement) => EnvelopeHeader(
    vaultId: vaultId,
    slots: [
      for (final s in slots)
        if (s.kind == replacement.kind) replacement else s,
    ],
  );

  String encode() => jsonEncode({
    'format': envelopeFormat,
    'envelope_version': envelopeVersion,
    'vault_id': vaultId,
    'aead': envelopeAead,
    'keys': [for (final s in slots) s.toJson()],
  });

  /// Throws [VaultEnvelopeError] for a header this app cannot use.
  static EnvelopeHeader parse(String line) {
    final Map<String, Object?> h;
    try {
      h = (jsonDecode(line) as Map).cast<String, Object?>();
    } catch (_) {
      throw const VaultEnvelopeError('ENVELOPE_UNREADABLE');
    }
    if (h['format'] != envelopeFormat) {
      throw const VaultEnvelopeError('ENVELOPE_UNREADABLE');
    }
    final v = h['envelope_version'];
    if (v is! int) throw const VaultEnvelopeError('ENVELOPE_UNREADABLE');
    if (v > envelopeVersion) throw const VaultEnvelopeError('ENVELOPE_NEWER');
    if (h['aead'] != envelopeAead) {
      throw const VaultEnvelopeError('ENVELOPE_UNSUPPORTED');
    }
    try {
      final id = h['vault_id']! as String;
      if (id.isEmpty) throw const FormatException();
      return EnvelopeHeader(
        vaultId: id,
        slots: [
          for (final k in h['keys']! as List)
            KeySlot.fromJson((k as Map).cast<String, Object?>()),
        ],
      );
    } on CryptoFailure {
      throw const VaultEnvelopeError('ENVELOPE_UNSUPPORTED');
    } catch (_) {
      throw const VaultEnvelopeError('ENVELOPE_UNREADABLE');
    }
  }
}

/// What a stored vault text is, judged by its first line only.
enum StoredVaultKind { none, plaintext, encrypted, unknown }

StoredVaultKind detectStoredVault(String? text) {
  if (text == null || text.trim().isEmpty) return StoredVaultKind.none;
  final first = text.split('\n').firstWhere((l) => l.trim().isNotEmpty);
  try {
    final format = (jsonDecode(first) as Map)['format'];
    if (format == envelopeFormat) return StoredVaultKind.encrypted;
    if (format == vaultFormat) return StoredVaultKind.plaintext;
  } catch (_) {
    // Falls through: not JSON, or not a map.
  }
  return StoredVaultKind.unknown;
}

/// An envelope opened with its data key.
class OpenedEnvelope {
  const OpenedEnvelope({
    required this.inner,
    required this.nextSeq,
    required this.unreadable,
    required this.missing,
  });

  /// The logical log. A line that could not be used is replaced by a marker
  /// the log parser reports as a warning; the envelope itself is untouched.
  final String inner;

  /// The sequence number the next sealed line gets.
  final int nextSeq;

  /// Lines that did not parse, did not authenticate, or repeat an earlier
  /// sequence number.
  final int unreadable;

  /// Sequence numbers absent between readable lines (removed entries).
  final int missing;

  /// Lines whose content is unknown: they may hold records.
  int get unknown => unreadable + missing;
}

/// Opens every sealed line of [text], an envelope of [vaultId] whose data
/// key is [dataKey]. Never throws for a damaged line: it becomes a marker.
OpenedEnvelope openEnvelopeText(
  String text,
  Uint8List dataKey,
  String vaultId,
) {
  final closed = text.endsWith('\n');
  final all = text.split('\n');
  final lines = (closed ? all.sublist(0, all.length - 1) : all)
      .skip(1)
      .where((l) => l.trim().isNotEmpty)
      .toList();
  final out = <String>[];
  var expected = 0, unreadable = 0, missing = 0;
  // Unusable lines since the last good one: they may be the entries whose
  // sequence numbers are absent, so they are not counted twice.
  var pending = 0;
  for (var i = 0; i < lines.length; i++) {
    final l = lines[i];
    int? seq;
    String? plain;
    try {
      final m = (jsonDecode(l) as Map).cast<String, Object?>();
      final s = m['s'];
      if (s is int && s >= 0) {
        final bytes = openSealed(
          dataKey,
          base64Decode(m['n']! as String),
          base64Decode(m['c']! as String),
          _entryAad(vaultId, s),
        );
        final line = utf8.decode(bytes);
        if (!line.contains('\n')) {
          seq = s;
          plain = line;
        }
      }
    } catch (_) {
      // Unparseable or not authentic: its sequence number is not trusted.
    }
    if (seq != null && plain != null && seq >= expected) {
      final gap = seq - expected - pending;
      for (var i = 0; i < gap; i++) {
        out.add(missingEntryMarker);
        missing++;
      }
      out.add(plain);
      expected = seq + 1;
      pending = 0;
    } else {
      // Only a last line without its newline is an interrupted write.
      final torn = !closed && i == lines.length - 1;
      out.add(torn ? tornEntryMarker : unreadableEntryMarker);
      unreadable++;
      // An authentic line with an old sequence number is a copy, not one
      // of the absent entries.
      if (plain == null) pending++;
    }
  }
  if (out.isEmpty) {
    // An envelope is always created with its log header (sequence 0) in the
    // same write, so one without any entry is damaged. Reported as a missing
    // header, it is never mistaken for a new, empty vault.
    out.add(missingEntryMarker);
    missing++;
  }
  final inner = out.join('\n');
  return OpenedEnvelope(
    inner: closed ? '$inner\n' : inner,
    nextSeq: expected,
    unreadable: unreadable,
    missing: missing,
  );
}

String _firstLine(String text) =>
    text.split('\n').firstWhere((l) => l.trim().isNotEmpty);

/// A [LogSink] that seals every line before it reaches [raw] and opens them
/// on read. Plaintext exists only in memory.
class EncryptedLogSink implements LogSink {
  EncryptedLogSink._(this.raw, this._dataKey, this._header, this._derive);

  /// A sink for a vault that does not exist yet. Both keys are wrapped when
  /// the repository writes the log header (the vault id is known only then);
  /// the secrets are dropped right after.
  factory EncryptedLogSink.forNewVault(
    LogSink raw, {
    required String passphrase,
    required String recoveryKey,
    required KeyDeriver derive,
    required KdfParams Function() newKdf,
  }) {
    final sink = EncryptedLogSink._(raw, randomBytes(32), null, derive)
      .._pending = (
        passphrase: passphrase,
        recovery: canonicalSecret(KeyKind.recovery, recoveryKey),
        newKdf: newKdf,
      );
    return sink;
  }

  /// Opens an existing envelope with a passphrase or the recovery key.
  /// Throws [VaultEnvelopeError], [RecoveryKeyFormatError] or
  /// [CryptoFailure] `NOT_AUTHENTIC` (wrong secret). Never falls back to
  /// plaintext and never writes.
  static Future<EncryptedLogSink> unlock(
    LogSink raw,
    String secret, {
    required KeyKind kind,
    required KeyDeriver derive,
  }) async {
    final text = await raw.read();
    switch (detectStoredVault(text)) {
      case StoredVaultKind.none:
        throw const VaultEnvelopeError('NO_VAULT');
      case StoredVaultKind.plaintext:
        throw const VaultEnvelopeError('NOT_ENCRYPTED');
      case StoredVaultKind.unknown:
        throw const VaultEnvelopeError('ENVELOPE_UNREADABLE');
      case StoredVaultKind.encrypted:
        break;
    }
    final header = EnvelopeHeader.parse(_firstLine(text!));
    final slot = header.slot(kind);
    if (slot == null) throw const VaultEnvelopeError('NO_SUCH_KEY');
    final key = await slot.unwrap(secret, header.vaultId, derive);
    return EncryptedLogSink._(raw, key, header, derive);
  }

  final LogSink raw;
  final Uint8List _dataKey;
  final KeyDeriver _derive;
  EnvelopeHeader? _header;
  ({String passphrase, String recovery, KdfParams Function() newKdf})? _pending;
  int _nextSeq = 0;

  String get vaultId => _header!.vaultId;

  /// Opens [text] (this vault's envelope, e.g. a copy for a backup).
  OpenedEnvelope open(String text) {
    final header = EnvelopeHeader.parse(_firstLine(text));
    if (header.vaultId != vaultId) {
      throw const VaultEnvelopeError('ENVELOPE_UNREADABLE');
    }
    return openEnvelopeText(text, _dataKey, vaultId);
  }

  /// The stored envelope and what it holds, read once (a backup must
  /// describe exactly the bytes it copies).
  Future<({String raw, OpenedEnvelope opened})> readBoth() async {
    final text = await raw.read();
    if (text == null) throw const VaultEnvelopeError('NO_VAULT');
    return (raw: text, opened: open(text));
  }

  @override
  Future<String?> read() async {
    final text = await raw.read();
    if (text == null || text.trim().isEmpty) {
      if (_pending == null) throw const VaultEnvelopeError('NO_VAULT');
      return null; // a new vault: the repository creates it
    }
    final opened = open(text);
    _nextSeq = opened.nextSeq;
    return opened.inner;
  }

  @override
  Future<void> create(String text) async {
    final pending = _pending;
    if (pending == null) {
      throw StateError('An existing vault is never created again');
    }
    final inner = (jsonDecode(text) as Map).cast<String, Object?>();
    final id = inner['vault_id']! as String;
    final slots = [
      await KeySlot.wrap(
        KeyKind.passphrase,
        pending.passphrase,
        _dataKey,
        id,
        derive: _derive,
        kdf: pending.newKdf(),
      ),
      await KeySlot.wrap(
        KeyKind.recovery,
        pending.recovery,
        _dataKey,
        id,
        derive: _derive,
        kdf: pending.newKdf(),
      ),
    ];
    final header = EnvelopeHeader(vaultId: id, slots: slots);
    // Header and sealed log header in one atomic write: a crash leaves no
    // envelope or a complete one.
    await raw.create('${header.encode()}\n${_sealLine(id, 0, text)}');
    _header = header;
    _pending = null;
    _nextSeq = 1;
  }

  String _sealLine(String id, int seq, String line) {
    final s = seal(_dataKey, _utf8(line), _entryAad(id, seq));
    return jsonEncode({
      's': seq,
      'n': base64Encode(s.nonce),
      'c': base64Encode(s.sealed),
    });
  }

  @override
  Future<void> appendLine(String line) async {
    if (line.isEmpty) {
      // Ends a torn last line (log_repository.dart); carries no data.
      await raw.appendLine('');
      return;
    }
    final seq = _nextSeq++;
    try {
      await raw.appendLine(_sealLine(vaultId, seq, line));
    } catch (_) {
      // Nothing usable was stored under this number; reuse it, so a failed
      // write is not later reported as a removed entry.
      _nextSeq = seq;
      rethrow;
    }
  }

  /// Replaces the passphrase slot (after a recovery, or a change). The
  /// recovery slot and every sealed line stay byte for byte; the file is
  /// rewritten atomically, so the old passphrase no longer opens it. Copies
  /// made earlier (backups) still open with the passphrase of their time.
  Future<void> changePassphrase(
    String newPassphrase, {
    required KdfParams Function() newKdf,
  }) async {
    final header = _header!;
    final slot = await KeySlot.wrap(
      KeyKind.passphrase,
      newPassphrase,
      _dataKey,
      header.vaultId,
      derive: _derive,
      kdf: newKdf(),
    );
    final updated = header.withSlot(slot);
    final text = (await raw.read())!;
    final cut = text.indexOf('\n');
    var rest = cut < 0 ? '' : text.substring(cut + 1);
    if (rest.endsWith('\n')) rest = rest.substring(0, rest.length - 1);
    await raw.create(
      rest.isEmpty ? updated.encode() : '${updated.encode()}\n$rest',
    );
    _header = updated;
  }
}
