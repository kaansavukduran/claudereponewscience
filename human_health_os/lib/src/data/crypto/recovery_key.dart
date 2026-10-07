/// Recovery keys (ladder F006): 160 random bits written as 32 base32
/// characters (RFC 4648 alphabet A–Z, 2–7) in eight groups of four. Shown
/// once when a vault is created; only a key derived from it is stored.
library;

import 'vault_crypto.dart';
import '../../domain/errors.dart';

const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

/// The typed text is not a recovery key (wrong length or characters).
class RecoveryKeyFormatError implements Exception, CodedError {
  const RecoveryKeyFormatError();

  @override
  String get code => 'RECOVERY_KEY_FORMAT';

  @override
  String toString() => 'RecoveryKeyFormatError($code)';
}

/// A new recovery key, e.g. `K7QM-2XRA-…` (8 groups).
String newRecoveryKey() => _group(_base32(randomBytes(20)));

String _base32(List<int> bytes) {
  final out = StringBuffer();
  var buffer = 0, bits = 0;
  for (final b in bytes) {
    buffer = (buffer << 8) | b;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      out.write(_alphabet[(buffer >> bits) & 31]);
    }
    buffer &= (1 << bits) - 1;
  }
  return out.toString();
}

String _group(String s) =>
    [for (var i = 0; i < s.length; i += 4) s.substring(i, i + 4)].join('-');

/// The canonical form of a typed recovery key: upper case, grouped. Spaces
/// and dashes may be anywhere; `0`, `1` and `8` (never in the alphabet) are
/// read as `O`, `I` and `B`. Throws [RecoveryKeyFormatError] for anything
/// that cannot be a recovery key, before any slow key derivation runs.
String normalizeRecoveryKey(String typed) {
  final s = typed
      .toUpperCase()
      .replaceAll(RegExp(r'[\s\-]'), '')
      .replaceAll('0', 'O')
      .replaceAll('1', 'I')
      .replaceAll('8', 'B');
  if (s.length != 32 || !RegExp(r'^[A-Z2-7]+$').hasMatch(s)) {
    throw const RecoveryKeyFormatError();
  }
  return _group(s);
}
