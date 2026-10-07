/// Vault format compatibility and the migration graph (master §35).
///
/// Format 1 is the baseline written since FORGE 002. No migration exists
/// yet; the graph, the path search and the receipts are in place so the
/// first real schema change has a tested route (gap G-15).
library;

import '../../domain/errors.dart';

/// The vault cannot be opened safely. It is never overwritten.
class VaultFormatError implements Exception, CodedError {
  const VaultFormatError(this.code, this.message);

  /// Stable code the UI shows (e.g. `VAULT_NEWER`).
  @override
  final String code;
  final String message;

  @override
  String toString() => 'VaultFormatError($code): $message';
}

/// The format this app writes.
const int vaultFormatVersion = 1;

/// The oldest format this app can read (through [vaultMigrations]).
const int vaultOldestReadableVersion = 1;

/// A newer vault is refused, never read by an older app (§35.3).
const bool vaultDowngradeSupported = false;

/// One step `from` → `to` (= `from + 1`) applied to each logged operation.
class VaultMigration {
  const VaultMigration({
    required this.id,
    required this.from,
    required this.to,
    required this.lossless,
    required this.upgradeOp,
  });

  /// Ordered identity, e.g. `M002` (§35.1).
  final String id;
  final int from;
  final int to;

  /// False when the step drops or reinterprets information. Lossy steps are
  /// refused until a backup checkpoint exists (§35.2, ladder F005).
  final bool lossless;

  /// Upgrades one `{op, data}` map. Must keep record ids, provenance,
  /// correction links and missing/unknown states (§35.4).
  final Map<String, Object?> Function(Map<String, Object?> op) upgradeOp;
}

/// The production graph: empty while format 1 is the only format.
const List<VaultMigration> vaultMigrations = <VaultMigration>[];

/// The ordered steps from [from] to [to]. Throws [VaultFormatError] when a
/// step is missing, ambiguous, not `+1`, or lossy.
List<VaultMigration> migrationPath(
  int from,
  int to,
  List<VaultMigration> graph,
) {
  final path = <VaultMigration>[];
  for (var v = from; v < to; v++) {
    final steps = graph.where((m) => m.from == v).toList();
    if (steps.length != 1 || steps.single.to != v + 1) {
      throw VaultFormatError(
        'NO_MIGRATION_PATH',
        'No single migration step from vault format $v',
      );
    }
    if (!steps.single.lossless) {
      throw VaultFormatError(
        'MIGRATION_LOSSY',
        'Migration ${steps.single.id} is lossy and needs a backup checkpoint first',
      );
    }
    path.add(steps.single);
  }
  return path;
}
