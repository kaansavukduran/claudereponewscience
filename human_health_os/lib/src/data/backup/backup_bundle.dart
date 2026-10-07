/// Backup bundles and the restore gate (master §36, ladder F005).
///
/// A bundle is one JSON document: a self-describing manifest and the vault
/// log text, byte for byte. Copying the log (not re-encoding records) keeps
/// ids, provenance, correction lineage, tombstones and even entries the app
/// skipped, so a restore gives back exactly what was saved.
///
/// Pure Dart (no IO): writing and reading files is the adapter's job.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../local/vault_log.dart';

const String backupFormat = 'hhos-backup';
const int backupFormatVersion = 1;

/// Unencrypted bundles are only written by development builds, like the
/// vault itself. The encrypted envelope arrives with the key work (F006).
const String backupEncryptionNone = 'none-dev-only';

String sha256Hex(String text) => sha256.convert(utf8.encode(text)).toString();

/// Why a bundle cannot be restored. Nothing is written when this is thrown.
class BackupError implements Exception {
  const BackupError(this.code, this.message);

  /// `BACKUP_UNREADABLE` · `NOT_A_BACKUP` · `BACKUP_NEWER` ·
  /// `BACKUP_ENCRYPTED_UNSUPPORTED` · `DIGEST_MISMATCH` ·
  /// `VAULT_INCOMPATIBLE` · `VAULT_ID_MISMATCH` · `COUNT_MISMATCH` ·
  /// `RESTORE_TARGET_HAS_RECORDS` · `RESTORE_VERIFY_FAILED`
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

/// Builds a bundle from the exact vault log text. Deterministic: the same
/// log, versions and [createdAt] give the same bytes.
String createBackupBundle({
  required String vaultLogText,
  required String appVersion,
  required String sourceRevision,
  required DateTime createdAt,
}) {
  final state = parseVaultLog(vaultLogText);
  final manifest = BackupManifest(
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
    payloadSha256: sha256Hex(vaultLogText),
    payloadBytes: utf8.encode(vaultLogText).length,
  );
  return '${const JsonEncoder.withIndent('  ').convert({'manifest': manifest.toJson(), 'payload': vaultLogText})}\n';
}

/// A bundle that passed every check of the restore gate up to "restore
/// into a staged destination" (§36.3): the payload is parsed in memory.
class StagedRestore {
  const StagedRestore(this.manifest, this.payload, this.state);

  final BackupManifest manifest;

  /// The vault log text to write, exactly as backed up.
  final String payload;
  final VaultState state;
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
  if (manifest.encryption != backupEncryptionNone) {
    throw BackupError(
      'BACKUP_ENCRYPTED_UNSUPPORTED',
      'This app cannot decrypt "${manifest.encryption}" backups yet',
    );
  }
  if (sha256Hex(payload) != manifest.payloadSha256 ||
      utf8.encode(payload).length != manifest.payloadBytes) {
    throw const BackupError(
      'DIGEST_MISMATCH',
      'The backup content does not match its checksum',
    );
  }
  final VaultState state;
  try {
    state = parseVaultLog(payload);
  } on VaultFormatError catch (e) {
    throw BackupError('VAULT_INCOMPATIBLE', e.code);
  }
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
  return StagedRestore(manifest, payload, state);
}

/// Records in a live vault log (throws if it cannot be read).
int parseLiveRecordCount(String vaultLogText) =>
    parseVaultLog(vaultLogText).records.length;
