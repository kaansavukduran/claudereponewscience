# Security and privacy model

Status: **SPECIFIED** (plan), with the parts listed under "Implemented" built and tested. Nothing else in this file is implemented unless `project_state/CURRENT_STATE.json` says so with evidence.

## Implemented (F006@v0.32, D-016)

- **Encrypted vault** on desktop (Linux tested; Windows and macOS compile the same pure-Dart code but are not built here): envelope `hhos-vault-enc` v1, Argon2id (19 MiB, 2 passes, 1 lane) wrapping a random 256-bit data key under the passphrase and under a 160-bit recovery key, ChaCha20-Poly1305 per log line with the vault id and sequence number as associated data. Staging, production and portable builds persist only this way; development builds keep a labelled plaintext log.
- **Key states:** no vault (create, or memory only) · locked · wrong passphrase · recovery (recovery key + new passphrase) · key lost (explained: nobody can decrypt it; never opened, reset or deleted; a new vault keeps the old file aside) · unreadable (newer or damaged; untouched).
- **Backups** of an encrypted vault are the envelope byte for byte; restore requires the backup's own key and checks the content before switching.
- **Logging** goes through `core/redact.dart` only (type + code, safe fields); Flutter and platform errors are routed there.
- **Not built:** OS key stores as a convenience unlock (G-13), encrypted browser storage (G-32), passphrase change and data-key rotation (G-33), export for encrypted vaults (G-34), rollback detection (G-35), app lock (G-36), key slots authenticated as a set (G-39).

## Assets

1. Canonical health records and their history: corrections and tombstones.
2. Attachments: lab PDFs, images, documents.
3. Keys: the vault data key, wrapped keys and the recovery secret.
4. Account and session credentials, when cloud sync exists.
5. Build and signing keys: Android keystore, Apple Developer ID, Windows code-signing. These **never** go in the repo.

## Threats in scope

Lost or stolen device. A portable vault copied off a USB stick. Malware reading plaintext app data. Logs or crash reports leaking PHI. Exports shared by mistake. Cross-user access on a server. Secrets in client bundles. Supply-chain tampering (dependencies, update metadata). Synthetic and real data being mixed.

## Storage at rest, per platform

| Platform | Canonical store | Key protection | Notes |
|---|---|---|---|
| Android | Encrypted SQLite (SQLCipher-class) or an encrypted document store | Android Keystore wraps the data key. A passphrase/recovery path is required for backup and restore. | Automatic cloud backup is excluded unless it is encrypted. |
| iOS | Same | Keychain (`ThisDeviceOnly` class) wraps the data key | File protection class Complete or CompleteUntilFirstUserAuthentication |
| macOS | Application Support container, **never inside the `.app`** | Keychain | Uninstall (deleting the `.app`) leaves the vault in place. Data deletion is an explicit in-app action. |
| Windows installed | `%LOCALAPPDATA%\HumanHealthOS\` | DPAPI convenience unlock is optional. A passphrase is always available. | The uninstaller **does not** delete the vault. It may offer a separate, explicit, default-off option. |
| Windows portable | `UserData\` next to the EXE | **Passphrase-derived key (Argon2id/scrypt-class KDF) is mandatory.** Machine-bound unlock is an optional convenience and never the only way in. | The vault moves between PCs. Profile identity is a UUID inside the vault, **not** the folder path. No plaintext SQLite in production. |
| Web | IndexedDB or OPFS | WebCrypto with a non-extractable key plus a passphrase for export and backup | Browser storage can be evicted. The UI says so, and export is the durable path. No OS keychain. |
| Server (later) | PostgreSQL with RLS | KMS-managed. Never a client-held master secret. | Owner authorization comes from the server session, never from a client-supplied owner ID. |

The vault format is versioned with a header (format version, KDF parameters, wrapped data key) and a migration path. Before any schema-changing update the app takes a consistent checkpoint/backup.

## Rules

- No secrets in Dart source, `--dart-define`, committed config or a web bundle. Non-secret build config uses `--dart-define=APP_ENV=…`.
- Logging is PHI-safe by default: structured events with IDs and codes, no free-text health values. Crash reports are scrubbed.
- Exports and backups are explicit user actions. Health data never goes into a share URL. Attachments get EXIF stripped for shared previews.
- Delete semantics: settings reset ≠ module hide ≠ data deletion ≠ account deletion ≠ app uninstall.
- Synthetic Build Lab data lives in its own namespace and its own storage, and is visibly labelled. It is never stored next to real profiles.
- Dependencies are reviewed (license, maintenance, platform support, native code, privacy). `pubspec.lock` and `pnpm-lock.yaml` are committed. Public releases get an SPDX or CycloneDX SBOM.
- The release path records artifact SHA-256, source revision, lockfile hash, toolchain versions, build host, profile and signing state. No SLSA level is claimed until it is evidenced.

## Verification plan

Threat-model review per release. OWASP MASVS/MASTG checklist for mobile. Cross-user tests for the API. A secret-scan gate in CI. A vault test suite: wrong passphrase, corrupt header, KDF parameter upgrade, moving a portable folder between paths (same profile UUID), and uninstall-preserves-data.
