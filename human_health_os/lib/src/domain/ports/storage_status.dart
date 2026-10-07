/// Why entries are or are not saved, as stable codes the adapters report
/// and the UI localizes (audit ARCH-1/ARCH-5, gaps G-14 and G-23). Pure
/// Dart, so the capability registry and the UI can use it without
/// importing an adapter.
library;

/// Why entries are or are not saved.
enum StorageReason {
  /// A persistent adapter is in use.
  saving,

  /// Staging and production builds never save unencrypted health data
  /// (D-010); saving starts with the encrypted vault (F006).
  profilePolicy,

  /// Portable mode saves only to an encrypted vault (D-009, F006).
  portablePolicy,

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
