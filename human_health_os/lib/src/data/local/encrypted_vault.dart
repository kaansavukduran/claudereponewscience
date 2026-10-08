/// The encrypted vault before it is opened (ladder F006): what the user
/// must do first, and the only ways to do it. Staging, production and
/// portable builds persist health data through this and nothing else; a
/// failed step writes nothing and never opens a plaintext store.
///
/// Key states (v0.24 "Key loss", DR-09):
/// - NO_VAULT ([VaultAccess.create]): create one with a passphrase and a
///   recovery key shown once, or keep the session in memory only;
/// - LOCKED ([VaultAccess.unlock]): the passphrase opens it;
/// - WRONG_PASSPHRASE: [CryptoFailure] `NOT_AUTHENTIC`; nothing changes;
/// - RECOVERY: the recovery key opens it and a new passphrase replaces the
///   old one ([recover]);
/// - KEY_LOST (declared by the user): the vault cannot be decrypted by
///   anyone; it is never opened, reset or deleted. [setAside] moves it
///   under a new name before a new vault is created;
/// - UNREADABLE ([VaultAccess.unreadable]): newer or damaged; untouched.
///
/// Pure Dart: the stored bytes go through a [LogSink].
library;

import '../../core/ids.dart';
import '../../domain/ports/health_repository.dart';
import '../backup/data_files.dart';
import '../crypto/vault_crypto.dart';
import 'log_repository.dart';
import 'vault_envelope.dart';

/// What has to happen before the vault can be used.
enum VaultAccess {
  /// No vault yet.
  create,

  /// A vault exists and is locked.
  unlock,

  /// The stored file cannot be used by this app ([VaultInspection.code]).
  unreadable,
}

class VaultInspection {
  const VaultInspection(this.access, [this.code]);

  final VaultAccess access;

  /// Why the vault is [VaultAccess.unreadable] (`ENVELOPE_NEWER`, …).
  final String? code;
}

/// An unlocked vault, ready for the app.
class OpenedVault {
  const OpenedVault({
    required this.repository,
    required this.report,
    required this.sink,
    this.files,
  });

  final LogRepository repository;
  final LoadReport report;
  final EncryptedLogSink sink;

  /// Encrypted backups beside the vault; null when this place has none.
  final DataFiles? files;
}

/// Minimum passphrase length in characters (Unicode code points). No
/// composition rules: length is what resists guessing (NIST SP 800-63B).
const int minPassphraseLength = 12;

bool passphraseLongEnough(String p) => p.runes.length >= minPassphraseLength;

class EncryptedVault {
  EncryptedVault({
    required this.raw,
    required this.location,
    this.durability = StorageDurability.localFile,
    this.derive = deriveInline,
    KdfParams Function()? newKdf,
    this.setAsideStore,
    this.filesFor,
    this.clock = const SystemClock(),
    this.ids,
  }) : newKdf = newKdf ?? KdfParams.forNewKey;

  /// Where the envelope is stored.
  final LogSink raw;

  /// Human-readable location (a path). No health data.
  final String location;
  final StorageDurability durability;
  final KeyDeriver derive;

  /// Key-derivation parameters for every new wrapped key. Production uses
  /// [KdfParams.forNewKey]; tests may pass a cheaper cost.
  final KdfParams Function() newKdf;

  /// Moves the stored vault aside under a new name and returns where it
  /// went. Never deletes. Null where the medium cannot do that.
  final Future<String> Function(DateTime now)? setAsideStore;

  /// Encrypted backups for an opened vault.
  final DataFiles? Function(EncryptedLogSink sink)? filesFor;
  final Clock clock;
  final IdGenerator? ids;

  /// Reads only; never writes. A file that exists but cannot be read (a
  /// lock held by another program, missing permissions) is unreadable
  /// with `VAULT_READ_FAILED`, so the gate can explain it.
  Future<VaultInspection> inspect() async {
    final String? text;
    try {
      text = await raw.read();
    } catch (_) {
      return const VaultInspection(VaultAccess.unreadable, 'VAULT_READ_FAILED');
    }
    switch (detectStoredVault(text)) {
      case StoredVaultKind.none:
        return const VaultInspection(VaultAccess.create);
      case StoredVaultKind.plaintext:
        return const VaultInspection(VaultAccess.unreadable, 'NOT_ENCRYPTED');
      case StoredVaultKind.unknown:
        return const VaultInspection(
          VaultAccess.unreadable,
          'ENVELOPE_UNREADABLE',
        );
      case StoredVaultKind.encrypted:
        try {
          EnvelopeHeader.parse(
            text!.split('\n').firstWhere((l) => l.trim().isNotEmpty),
          );
          return const VaultInspection(VaultAccess.unlock);
        } on VaultEnvelopeError catch (e) {
          return VaultInspection(VaultAccess.unreadable, e.code);
        }
    }
  }

  /// Creates a new vault. Throws [VaultEnvelopeError] `VAULT_EXISTS` when
  /// anything is stored already (it is never overwritten).
  Future<OpenedVault> create({
    required String passphrase,
    required String recoveryKey,
  }) async {
    if (!passphraseLongEnough(passphrase)) {
      throw ArgumentError('passphrase too short');
    }
    if (detectStoredVault(await raw.read()) != StoredVaultKind.none) {
      throw const VaultEnvelopeError('VAULT_EXISTS');
    }
    return _open(
      EncryptedLogSink.forNewVault(
        raw,
        passphrase: passphrase,
        recoveryKey: recoveryKey,
        derive: derive,
        newKdf: newKdf,
      ),
    );
  }

  /// Opens the vault with its passphrase. A wrong one throws
  /// [CryptoFailure] `NOT_AUTHENTIC` and changes nothing.
  Future<OpenedVault> unlock(String passphrase) async => _open(
    await EncryptedLogSink.unlock(
      raw,
      passphrase,
      kind: KeyKind.passphrase,
      derive: derive,
    ),
  );

  /// Opens the vault with the recovery key and replaces the passphrase.
  /// A wrong key throws [CryptoFailure] `NOT_AUTHENTIC` and changes nothing.
  Future<OpenedVault> recover({
    required String recoveryKey,
    required String newPassphrase,
  }) async {
    if (!passphraseLongEnough(newPassphrase)) {
      throw ArgumentError('passphrase too short');
    }
    final sink = await EncryptedLogSink.unlock(
      raw,
      recoveryKey,
      kind: KeyKind.recovery,
      derive: derive,
    );
    // Open and parse first: a vault this app cannot use (written by a newer
    // app, or damaged) is refused before anything is written (review
    // finding). Opening an existing vault only reads; the sealed lines do
    // not change, so the opened state stays valid after the new passphrase.
    final opened = await _open(sink);
    await sink.changePassphrase(newPassphrase, newKdf: newKdf);
    return opened;
  }

  bool get canSetAside => setAsideStore != null;

  /// Keeps the stored vault under a new name (key lost, or a damaged file)
  /// so a new one can be created. Returns where it was kept.
  Future<String> setAside() => setAsideStore!(clock.nowUtc());

  Future<OpenedVault> _open(EncryptedLogSink sink) async {
    final repository = LogRepository(
      sink: sink,
      durability: durability,
      location: location,
      encrypted: true,
      clock: clock,
      ids: ids,
    );
    final report = await repository.open();
    return OpenedVault(
      repository: repository,
      report: report,
      sink: sink,
      files: filesFor?.call(sink),
    );
  }
}
