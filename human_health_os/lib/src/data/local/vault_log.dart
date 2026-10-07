/// Append-only JSON-lines vault log shared by the file and browser adapters.
///
/// Line 1 is a header: format, version, vault id, encryption state.
/// Each following line is one operation. An interrupted write can only damage
/// the last line; that line is skipped **with a visible warning**, never
/// silently. Valid history is never dropped from the file: entries that
/// cannot be used are skipped in memory and reported, and the file is left
/// as it is.
///
/// The log is NOT encrypted (`encryption: none-dev-only`); only development
/// builds write it. The encrypted vault (ladder F006) replaces the payload
/// with an encrypted envelope.
library;

import 'dart:convert';

import '../../domain/ports/health_repository.dart';
import '../../domain/profile/profile.dart';
import '../../domain/records/health_record.dart';
import 'vault_migrations.dart';

export 'vault_migrations.dart'
    show VaultFormatError, VaultMigration, vaultFormatVersion, vaultMigrations;

const String vaultFormat = 'hhos-vault-log';
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

/// In-memory state rebuilt from the log.
class VaultState {
  VaultState(this.header);

  final VaultHeader header;
  final Map<String, Profile> profiles = {};
  final Map<String, HealthRecord> records = {};
  final List<String> order = [];
  final List<LoadWarning> warnings = [];
  final List<MigrationReceipt> migrations = [];

  /// Applies one operation. Returns false when the record already exists with
  /// identical content (idempotent replay); throws on a conflicting duplicate.
  /// Records are validated on replay too, so a hand-edited or damaged entry
  /// can never reach the UI (gap G-18).
  bool apply(String op, Map<String, Object?> data) {
    switch (op) {
      case 'profile.put':
        final p = Profile.fromJson(data);
        profiles[p.id] = p;
        return true;
      case 'record.append':
        final r = HealthRecord.fromJson(data);
        r.validate();
        if (!profiles.containsKey(r.profileId)) {
          throw const RecordValidationError(
            'UNKNOWN_PROFILE',
            'Record refers to an unknown profile',
          );
        }
        final existing = records[r.id];
        if (existing != null) {
          if (jsonEncode(existing.toJson()) == jsonEncode(r.toJson())) {
            return false;
          }
          throw VaultFormatError(
            'DUPLICATE_CONFLICT',
            'Conflicting duplicate record id ${r.id}',
          );
        }
        records[r.id] = r;
        order.add(r.id);
        return true;
      default:
        throw VaultFormatError('UNKNOWN_OPERATION', 'Unknown operation "$op"');
    }
  }
}

String encodeOp(String op, Map<String, Object?> data) =>
    jsonEncode({'op': op, 'data': data});

/// Parses a whole log. Throws [VaultFormatError] if the vault cannot be
/// opened safely: an unusable header, a vault or record written by a newer
/// app (master §35.3: block, never downgrade), or a version with no
/// lossless migration path.
///
/// An older vault is migrated **in memory only** through [migrations]; the
/// file is not rewritten during a read (§35.1). The returned state then
/// carries one [MigrationReceipt] per step (§33.3) and the caller opens the
/// vault read-only.
VaultState parseVaultLog(
  String text, {
  List<VaultMigration> migrations = vaultMigrations,
  int targetVersion = vaultFormatVersion,
  DateTime Function()? now,
}) {
  final clock = now ?? () => DateTime.now().toUtc();
  final lines = const LineSplitter()
      .convert(text)
      .where((l) => l.trim().isNotEmpty)
      .toList();
  if (lines.isEmpty) {
    throw const VaultFormatError('VAULT_EMPTY', 'Empty vault log');
  }
  final Map<String, Object?> h;
  try {
    h = (jsonDecode(lines.first) as Map).cast<String, Object?>();
  } catch (_) {
    throw const VaultFormatError(
      'VAULT_HEADER_UNREADABLE',
      'Unreadable vault header',
    );
  }
  if (h['format'] != vaultFormat) {
    throw const VaultFormatError('NOT_A_VAULT', 'Not a Human OS vault');
  }
  final version = h['format_version'];
  if (version is! int) {
    // Unknown is not "version 1": never guess how to read health data.
    throw const VaultFormatError(
      'VAULT_NO_VERSION',
      'The vault header has no format version',
    );
  }
  if (version > targetVersion) {
    throw VaultFormatError(
      'VAULT_NEWER',
      'Vault format $version is newer than this app ($targetVersion)',
    );
  }
  final path = migrationPath(version, targetVersion, migrations);
  final VaultState state;
  try {
    state = VaultState(
      VaultHeader(
        vaultId: h['vault_id']! as String,
        createdAt: DateTime.parse(h['created_at']! as String).toUtc(),
        formatVersion: version,
        encryption: (h['encryption'] as String?) ?? encryptionNoneDevOnly,
      ),
    );
  } catch (_) {
    throw const VaultFormatError(
      'VAULT_HEADER_UNREADABLE',
      'The vault header lacks its id or creation time',
    );
  }
  final started = clock();
  for (var i = 1; i < lines.length; i++) {
    final isLast = i == lines.length - 1;
    try {
      var m = (jsonDecode(lines[i]) as Map).cast<String, Object?>();
      for (final step in path) {
        m = step.upgradeOp(m);
      }
      state.apply(
        m['op']! as String,
        (m['data']! as Map).cast<String, Object?>(),
      );
    } on VaultFormatError {
      rethrow;
    } on SchemaTooNewError catch (e) {
      throw VaultFormatError('RECORD_SCHEMA_NEWER', e.toString());
    } on RecordValidationError catch (e) {
      state.warnings.add(
        LoadWarning(LoadWarningKind.entryInvalid, line: i + 1, code: e.code),
      );
    } catch (_) {
      state.warnings.add(
        LoadWarning(
          isLast
              ? LoadWarningKind.lastEntryIncomplete
              : LoadWarningKind.entryUnreadable,
          line: i + 1,
        ),
      );
    }
  }
  final finished = clock();
  for (final step in path) {
    state.migrations.add(
      MigrationReceipt(
        id: step.id,
        fromVersion: step.from,
        toVersion: step.to,
        checkpoint: 'none: applied in memory; the file was not changed',
        startedAt: started,
        finishedAt: finished,
        result: 'APPLIED_IN_MEMORY',
        entries: lines.length - 1,
      ),
    );
  }
  return state;
}
