/// Why entries are or are not saved, as stable codes the adapters report
/// and the UI localizes (audit ARCH-1/ARCH-5, gaps G-14 and G-23). Pure
/// Dart, so the capability registry and the UI can use it without
/// importing an adapter.
library;

/// Why entries are or are not saved.
enum StorageReason {
  /// A persistent adapter is in use.
  saving,

  /// A web build other than development: it never saves unencrypted health
  /// data (D-010), and encrypted browser storage is not built (gap G-32).
  profilePolicy,

  /// The user chose to keep this session in memory only instead of creating
  /// or unlocking the encrypted vault (F006). [detail] `LOCKED_VAULT_KEPT`
  /// when an encrypted vault exists and stays untouched.
  sessionOnly,

  /// This platform has no storage adapter yet (Android, iOS).
  platformNotBuilt,

  /// `HHOS_DATA_DIR` is set but is not an absolute path; nothing is written
  /// to a guessed location.
  dataDirInvalid,

  /// The browser refuses local storage.
  browserBlocked,

  /// The saved vault could not be opened (damaged header, or written by a
  /// newer app). It is never overwritten.
  vaultUnreadable,

  /// The vault opened through an in-memory migration. It is shown, but new
  /// entries are refused until an upgrade with a checkpoint exists (§35.2).
  vaultReadOnly,
}

/// Something the adapter did or noticed that the user should know about.
enum StorageNoteKind {
  /// The Linux development vault moved from `HumanHealthOS/` to
  /// `human-health-os/` (C-4).
  movedLegacyFolder,

  /// Both folders exist; the new one is used, the old one is left untouched.
  legacyFolderLeft,

  /// The old folder could not be moved; it stays in use.
  legacyFolderInUse,
}

class StorageNote {
  const StorageNote(this.kind, this.detail);

  final StorageNoteKind kind;

  /// Path(s) involved. No health data.
  final String detail;
}
