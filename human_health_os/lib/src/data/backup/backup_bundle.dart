/// Backup bundles and the restore gate (master §36, ladder F005).
///
/// A bundle is one JSON document: a self-describing manifest and the vault
/// log text, byte for byte. Copying the log (not re-encoding records) keeps
/// ids, provenance, correction lineage, tombstones and even entries the app
/// skipped, so a restore gives back exactly what was saved.
///
/// An encrypted vault (F006) is backed up the same way: the payload is its
/// envelope, byte for byte, so the backup is exactly as encrypted as the
/// vault and opens only with the passphrase or recovery key the vault had
/// when the backup was made.
///
/// Pure Dart (no IO): writing and reading files is the adapter's job.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../domain/errors.dart';
import '../crypto/vault_crypto.dart' show CryptoFailure;
import '../local/vault_envelope.dart';
import '../local/vault_log.dart';

const String backupFormat = 'hhos-backup';
const int backupFormatVersion = 1;

/// Unencrypted bundles are only written by development builds, like the
/// development log itself.
const String backupEncryptionNone = 'none-dev-only';

/// The payload is an encrypted vault envelope (`hhos-vault-enc` v1).
const String backupEncryptionEnvelope = encryptionEnvelopeV1;

String sha256Hex(String text) => sha256.convert(utf8.encode(text)).toString();

/// Why a bundle cannot be restored. Nothing is written when this is thrown.
class BackupError implements Exception, CodedError {
  const BackupError(this.code, this.message);

  /// `BACKUP_UNREADABLE` · `NOT_A_BACKUP` · `BACKUP_NEWER` ·
  /// `BACKUP_ENCRYPTED_UNSUPPORTED` · `DIGEST_MISMATCH` ·
  /// `VAULT_INCOMPATIBLE` · `VAULT_ID_MISMATCH` · `COUNT_MISMATCH` ·
  /// `BACKUP_KEY_WRONG` (the passphrase or recovery key does not open this
  /// backup) · `BACKUP_KEY_NEEDED` · `BACKUP_KIND_MISMATCH` (an encrypted
  /// backup for a plaintext vault or the reverse) ·
  /// `RESTORE_TARGET_HAS_RECORDS` · `RESTORE_TARGET_NEWER` ·
  /// `RESTORE_VERIFY_FAILED` · `RESTORE_SWITCH_FAILED` (the restored copy
  /// could not be moved into place; [message] is where the previous vault
  /// was kept, or empty when it is back in its place)
  @override
  final String code;
  final String message;

  @override
  String toString() => 'BackupError($code): $message';
}

/// The self-describing part of a bundle (master §36.2).
class BackupManifest {
  const BackupManifest({
    required this.createdAt,
    required this.sourceAppVersion,
    required this.sourceRevision,
    required this.vaultId,
    required this.vaultFormatVersion,
    required this.recordSchemaVersions,
    required this.profileCount,
    required this.recordCount,
    required this.skippedEntries,
    required this.payloadSha256,
    required this.payloadBytes,
    this.formatVersion = backupFormatVersion,
    this.encryption = backupEncryptionNone,
  });

  final int formatVersion;
  final DateTime createdAt;
  final String sourceAppVersion;
  final String sourceRevision;

  /// The vault's own stable id (never its path).
  final String vaultId;
  final int vaultFormatVersion;

  /// Every record schema version present in the payload, ascending.
  final List<int> recordSchemaVersions;
  final int profileCount;
  final int recordCount;

  /// Entries the app skipped when reading the vault; they are in the
  /// payload all the same.
  final int skippedEntries;
  final String payloadSha256;
  final int payloadBytes;
  final String encryption;

  bool get encrypted => encryption == backupEncryptionEnvelope;

  Map<String, Object?> toJson() => {
    'format': backupFormat,
    'format_version': formatVersion,
    'created_at': createdAt.toIso8601String(),
    'source_app_version': sourceAppVersion,
    'source_revision': sourceRevision,
    'vault_id': vaultId,
    'vault_format_version': vaultFormatVersion,
    'record_schema_versions': recordSchemaVersions,
    'profile_count': profileCount,
    'record_count': recordCount,
    'skipped_entries': skippedEntries,
    'payload_sha256': payloadSha256,
    'payload_bytes': payloadBytes,
    'encryption': encryption,
    // No attachments exist yet; the field is part of the format (§36.2).
    'attachments': const <Object?>[],
  };

  static BackupManifest fromJson(Map<String, Object?> j) => BackupManifest(
    formatVersion: j['format_version']! as int,
    createdAt: DateTime.parse(j['created_at']! as String).toUtc(),
    sourceAppVersion: j['source_app_version']! as String,
    sourceRevision: j['source_revision']! as String,
    vaultId: j['vault_id']! as String,
    vaultFormatVersion: j['vault_format_version']! as int,
    recordSchemaVersions: [
      for (final v in j['record_schema_versions']! as List) v as int,
    ],
    profileCount: j['profile_count']! as int,
    recordCount: j['record_count']! as int,
    skippedEntries: j['skipped_entries']! as int,
    payloadSha256: j['payload_sha256']! as String,
    payloadBytes: j['payload_bytes']! as int,
    encryption: j['encryption']! as String,
  );
}

BackupManifest _manifestFor(
  VaultState state, {
  required String payload,
  required String encryption,
  required String appVersion,
  required String sourceRevision,
  required DateTime createdAt,
}) => BackupManifest(
  createdAt: createdAt.toUtc(),
  sourceAppVersion: appVersion,
  sourceRevision: sourceRevision,
  vaultId: state.header.vaultId,
  vaultFormatVersion: state.header.formatVersion,
  recordSchemaVersions: ({
    for (final r in state.records.values) r.schemaVersion,
  }.toList()..sort()),
  profileCount: state.profiles.length,
  recordCount: state.records.length,
  skippedEntries: state.warnings.length,
  payloadSha256: sha256Hex(payload),
  payloadBytes: utf8.encode(payload).length,
  encryption: encryption,
);

String _bundle(BackupManifest manifest, String payload) =>
    '${const JsonEncoder.withIndent('  ').convert({'manifest': manifest.toJson(), 'payload': payload})}\n';

/// Builds a bundle from the exact vault log text. Deterministic: the same
/// log, versions and [createdAt] give the same bytes.
String createBackupBundle({
  required String vaultLogText,
  required String appVersion,
  required String sourceRevision,
  required DateTime createdAt,
}) => _bundle(
  _manifestFor(
    parseVaultLog(vaultLogText),
    payload: vaultLogText,
    encryption: backupEncryptionNone,
    appVersion: appVersion,
    sourceRevision: sourceRevision,
    createdAt: createdAt,
  ),
  vaultLogText,
);

/// Builds a bundle of an encrypted vault: the payload is [envelopeText]
/// byte for byte; the manifest counts come from [innerLogText], the same
/// envelope opened with the vault's key. The counts are the only things
/// about the content the manifest reveals.
String createEncryptedBackupBundle({
  required String envelopeText,
  required String innerLogText,
  required String appVersion,
  required String sourceRevision,
  required DateTime createdAt,
}) => _bundle(
  _manifestFor(
    parseVaultLog(innerLogText),
    payload: envelopeText,
    encryption: backupEncryptionEnvelope,
    appVersion: appVersion,
    sourceRevision: sourceRevision,
    createdAt: createdAt,
  ),
  envelopeText,
);

/// A bundle that passed every check of the restore gate up to "restore
/// into a staged destination" (§36.3): the payload is parsed in memory.
class StagedRestore {
  const StagedRestore(
    this.manifest,
    this.payload,
    this.state, {
    this.envelope,
    this.dataKey,
  });

  final BackupManifest manifest;

  /// The stored text to write, exactly as backed up.
  final String payload;

  /// The content, parsed in memory; null for an encrypted backup until it
  /// is opened with [unlockStagedRestore].
  final VaultState? state;

  /// The envelope header of an encrypted backup.
  final EnvelopeHeader? envelope;
  final Uint8List? dataKey;

  bool get encrypted => envelope != null;

  /// An encrypted backup whose key has not been checked yet.
  bool get needsKey => state == null;

  /// The last check before the switch: [written], read back from the
  /// staged copy, is byte-identical to the payload and still opens to the
  /// counted records. Throws `RESTORE_VERIFY_FAILED`.
  void verifyWritten(String written) {
    final st = state;
    if (st == null) {
      throw const BackupError(
        'BACKUP_KEY_NEEDED',
        'An encrypted backup must be opened with its key first',
      );
    }
    var ok =
        sha256Hex(written) == manifest.payloadSha256 &&
        utf8.encode(written).length == manifest.payloadBytes;
    if (ok) {
      try {
        final log = encrypted
            ? openEnvelopeText(written, dataKey!, envelope!.vaultId).inner
            : written;
        ok = parseVaultLog(log).records.length == st.records.length;
      } catch (_) {
        ok = false;
      }
    }
    if (!ok) {
      throw const BackupError(
        'RESTORE_VERIFY_FAILED',
        'The restored copy did not read back identically; nothing was changed',
      );
    }
  }
}

/// The restore gate up to the staged copy: read → check the format and
/// encryption → verify the digest → check schema compatibility → parse →
/// compare identity and counts with the manifest. Writes nothing.
StagedRestore stageRestore(String bundleText) {
  final Map<String, Object?> doc;
  try {
    doc = (jsonDecode(bundleText) as Map).cast<String, Object?>();
  } catch (_) {
    throw const BackupError('BACKUP_UNREADABLE', 'Not readable as a backup');
  }
  final m = doc['manifest'];
  final payload = doc['payload'];
  if (m is! Map || m['format'] != backupFormat || payload is! String) {
    throw const BackupError('NOT_A_BACKUP', 'Not a Human OS backup');
  }
  final version = m['format_version'];
  if (version is! int || version > backupFormatVersion) {
    throw BackupError(
      'BACKUP_NEWER',
      'Backup format $version is newer than this app ($backupFormatVersion)',
    );
  }
  final BackupManifest manifest;
  try {
    manifest = BackupManifest.fromJson(m.cast<String, Object?>());
  } catch (_) {
    throw const BackupError('BACKUP_UNREADABLE', 'The manifest is incomplete');
  }
  if (manifest.encryption != backupEncryptionNone && !manifest.encrypted) {
    throw BackupError(
      'BACKUP_ENCRYPTED_UNSUPPORTED',
      'This app cannot decrypt "${manifest.encryption}" backups',
    );
  }
  if (sha256Hex(payload) != manifest.payloadSha256 ||
      utf8.encode(payload).length != manifest.payloadBytes) {
    throw const BackupError(
      'DIGEST_MISMATCH',
      'The backup content does not match its checksum',
    );
  }
  if (manifest.encrypted) {
    final EnvelopeHeader header;
    try {
      if (detectStoredVault(payload) != StoredVaultKind.encrypted) {
        throw const VaultEnvelopeError('ENVELOPE_UNREADABLE');
      }
      header = EnvelopeHeader.parse(
        payload.split('\n').firstWhere((l) => l.trim().isNotEmpty),
      );
    } on VaultEnvelopeError catch (e) {
      throw BackupError('VAULT_INCOMPATIBLE', e.code);
    }
    if (header.vaultId != manifest.vaultId) {
      throw const BackupError(
        'VAULT_ID_MISMATCH',
        'The manifest names a different vault',
      );
    }
    // The content is checked once the backup's key opens it.
    return StagedRestore(manifest, payload, null, envelope: header);
  }
  final VaultState state;
  try {
    state = parseVaultLog(payload);
  } on VaultFormatError catch (e) {
    throw BackupError('VAULT_INCOMPATIBLE', e.code);
  }
  _checkContent(state, manifest);
  return StagedRestore(manifest, payload, state);
}

void _checkContent(VaultState state, BackupManifest manifest) {
  if (state.header.vaultId != manifest.vaultId) {
    throw const BackupError(
      'VAULT_ID_MISMATCH',
      'The manifest names a different vault',
    );
  }
  if (state.profiles.length != manifest.profileCount ||
      state.records.length != manifest.recordCount ||
      state.warnings.length != manifest.skippedEntries) {
    throw const BackupError(
      'COUNT_MISMATCH',
      'The backup content does not match its manifest counts',
    );
  }
}

/// Opens an encrypted backup with its own passphrase or recovery key (the
/// ones the vault had when the backup was made) and checks its content:
/// "backup created" is not "backup restorable" (§36.4). Writes nothing.
/// Throws `BACKUP_KEY_WRONG`, `RECOVERY_KEY_FORMAT` (as
/// RecoveryKeyFormatError), `VAULT_INCOMPATIBLE`, `VAULT_ID_MISMATCH` or
/// `COUNT_MISMATCH`.
Future<StagedRestore> unlockStagedRestore(
  StagedRestore staged,
  String secret, {
  required KeyKind kind,
  KeyDeriver derive = deriveInline,
}) async {
  final header = staged.envelope;
  if (header == null || !staged.needsKey) return staged;
  final slot = header.slot(kind);
  if (slot == null) {
    throw const BackupError('BACKUP_KEY_WRONG', 'The backup has no such key');
  }
  final Uint8List key;
  try {
    key = await slot.unwrap(secret, header.vaultId, derive);
  } on CryptoFailure {
    throw const BackupError(
      'BACKUP_KEY_WRONG',
      'This passphrase or recovery key does not open the backup',
    );
  }
  final VaultState state;
  try {
    state = parseVaultLog(
      openEnvelopeText(staged.payload, key, header.vaultId).inner,
    );
  } on VaultFormatError catch (e) {
    throw BackupError('VAULT_INCOMPATIBLE', e.code);
  }
  _checkContent(state, staged.manifest);
  return StagedRestore(
    staged.manifest,
    staged.payload,
    state,
    envelope: header,
    dataKey: key,
  );
}

/// Records in a live vault log (throws if it cannot be read).
int parseLiveRecordCount(String vaultLogText) =>
    parseVaultLog(vaultLogText).records.length;
