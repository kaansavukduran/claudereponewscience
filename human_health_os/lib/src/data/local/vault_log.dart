/// Append-only JSON-lines vault log shared by the file and browser adapters.
///
/// Line 1 is a header: format, version, vault id, encryption state.
/// Each following line is one operation. An interrupted write can only damage
/// the last line; that line is skipped **with a visible warning**, never
/// silently. Valid history is never dropped.
///
/// FORGE 002: the log is NOT encrypted (`encryption: none-dev-only`).
/// The encrypted vault (ladder F006) replaces the payload with an encrypted envelope.
library;

import 'dart:convert';

import '../../domain/profile/profile.dart';
import '../../domain/records/health_record.dart';

const String vaultFormat = 'hhos-vault-log';
const int vaultFormatVersion = 1;
const String encryptionNoneDevOnly = 'none-dev-only';

class VaultHeader {
  const VaultHeader({
    required this.vaultId,
    required this.createdAt,
    this.formatVersion = vaultFormatVersion,
    this.encryption = encryptionNoneDevOnly,
  });

  final String vaultId;
  final DateTime createdAt;
  final int formatVersion;
  final String encryption;

  String encode() => jsonEncode({
    'format': vaultFormat,
    'format_version': formatVersion,
    'vault_id': vaultId,
    'created_at': createdAt.toIso8601String(),
    'encryption': encryption,
  });
}

class VaultFormatError implements Exception {
  const VaultFormatError(this.message);

  final String message;

  @override
  String toString() => 'VaultFormatError: $message';
}

/// In-memory state rebuilt from the log.
class VaultState {
  VaultState(this.header);

  final VaultHeader header;
  final Map<String, Profile> profiles = {};
  final Map<String, HealthRecord> records = {};
  final List<String> order = [];
  final List<String> warnings = [];

  /// Applies one operation. Returns false when the record already exists with
  /// identical content (idempotent replay); throws on a conflicting duplicate.
  bool apply(String op, Map<String, Object?> data) {
    switch (op) {
      case 'profile.put':
        final p = Profile.fromJson(data);
        profiles[p.id] = p;
        return true;
      case 'record.append':
        final r = HealthRecord.fromJson(data);
        final existing = records[r.id];
        if (existing != null) {
          if (jsonEncode(existing.toJson()) == jsonEncode(r.toJson())) {
            return false;
          }
          throw VaultFormatError('Conflicting duplicate record id ${r.id}');
        }
        records[r.id] = r;
        order.add(r.id);
        return true;
      default:
        throw VaultFormatError('Unknown operation "$op"');
    }
  }
}

String encodeOp(String op, Map<String, Object?> data) =>
    jsonEncode({'op': op, 'data': data});

/// Parses a whole log. Throws [VaultFormatError] if the header is unusable
/// (wrong format or a newer version than this app understands).
VaultState parseVaultLog(String text) {
  final lines = const LineSplitter()
      .convert(text)
      .where((l) => l.trim().isNotEmpty)
      .toList();
  if (lines.isEmpty) throw const VaultFormatError('Empty vault log');
  final Map<String, Object?> h;
  try {
    h = (jsonDecode(lines.first) as Map).cast<String, Object?>();
  } catch (_) {
    throw const VaultFormatError('Unreadable vault header');
  }
  if (h['format'] != vaultFormat) {
    throw const VaultFormatError('Not a Human OS vault');
  }
  final version = (h['format_version'] as num?)?.toInt() ?? 0;
  if (version > vaultFormatVersion) {
    throw VaultFormatError(
      'Vault format $version is newer than this app ($vaultFormatVersion)',
    );
  }
  final state = VaultState(
    VaultHeader(
      vaultId: h['vault_id']! as String,
      createdAt: DateTime.parse(h['created_at']! as String).toUtc(),
      formatVersion: version,
      encryption: (h['encryption'] as String?) ?? encryptionNoneDevOnly,
    ),
  );
  for (var i = 1; i < lines.length; i++) {
    final isLast = i == lines.length - 1;
    try {
      final m = (jsonDecode(lines[i]) as Map).cast<String, Object?>();
      state.apply(
        m['op']! as String,
        (m['data']! as Map).cast<String, Object?>(),
      );
    } on VaultFormatError {
      rethrow;
    } catch (e) {
      state.warnings.add(
        isLast
            ? 'The last vault entry was incomplete (probably an interrupted save) and was skipped.'
            : 'Vault entry ${i + 1} could not be read and was skipped.',
      );
    }
  }
  return state;
}
