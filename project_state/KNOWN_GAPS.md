# Known gaps

Status: OPEN, PARTIAL or CLOSED (with the FORGE and evidence that closed it).

| ID | Gap | Status | Planned / closed by |
|---|---|---|---|
| G-01 | No Flutter app yet | CLOSED | F001: `human_health_os/`, web + Linux runtime-tested (`reports/artifacts/forge-001.json`) |
| G-02 | No persistence or canonical record in the Flutter app | PARTIAL | F002: canonical envelope, append-only log, file/browser/memory adapters. F006@v0.32: staging, production and portable desktop builds persist through the encrypted vault. Still open: Android/iOS have no path adapter; web builds other than development stay memory-only (G-32); development keeps its labelled plaintext log by design. |
| G-03 | No Dart engines | OPEN | F011 |
| G-04 | No encryption/vault | CLOSED | F006@v0.32: encrypted vault `hhos-vault-enc` v1 (Argon2id + ChaCha20-Poly1305, D-016) for staging, production and portable desktop builds; web is G-32 |
| G-05 | No real authentication; the reference API has dev auth only | OPEN | F014 |
| G-06 | PostgreSQL/RLS never executed | OPEN | F014 |
| G-07 | Composites, compare and missions lack numeric golden vectors (semantic tests only) | OPEN | F011 (before the composite/compare/mission engines) |
| G-08 | Packs (lessons, synthetic profiles, catalog) are TS literals, not shared JSON | OPEN | F011/F012 |
| G-09 | v0.26 baseline and the v0.27 overlay file contents not supplied (docs 216–226 available inside the v0.31/v0.32 masters) | PARTIAL | user |
| G-10 | No SessionStart hook to reinstall Flutter in fresh cloud containers | OPEN | soon (small) |
| G-11 | CI workflow (`.github/workflows/ci.yml`) never run | PARTIAL | Flutter jobs defined in F001 (web, Linux, Android, Windows, macOS/iOS). Never executed: GitHub access for Claude is blocked (push 403). |
| G-12 | Linux distribution channels | PARTIAL | F015-L1: tar.zst/deb/rpm/AppImage built and partly smoke-tested; Flatpak not built; Ubuntu 22.04 defect open; Debian/Fedora/Nobara install smoke NOT_RUN |
| G-13 | OS key stores (Secret Service, Keychain, Keystore, DPAPI) as a convenience unlock | OPEN | Not built in F006@v0.32: the passphrase or recovery key is always required, so an unavailable keyring cannot cause a plaintext fallback (master §11: convenience only, never the only way in) |
| G-14 | UI copy partly EN-only (capability details, storage notices) | PARTIAL | F002@v0.32: storage notices, notes and load warnings localized EN/TR; capability details still EN-only (ARB move, R-12) |
| G-15 | No migration graph / migration receipts (v0.31 §35) for the vault log v1 | CLOSED | F002@v0.32: compatibility metadata, migration graph (+1, lossless, ordered ids), in-memory migration with §33.3 receipts, v1 fixture (`test/data/vault_compat_test.dart`); on-disk upgrade waits for F005 checkpoints (D-014) |
| G-16 | No backup/restore drill (v0.31 §36) | CLOSED | F005@v0.32: restore drill as unit test on real files and Linux integration test (backup → lose vault → fresh start → restore → relaunch); browser restore still open (G-29) |
| G-17 | No centralized log redaction (v0.31 §37) | CLOSED | F006@v0.32: `core/redact.dart` is the only console writer (type + code, safe fields); Flutter, platform and startup errors go through it; sensitive-data logging tests (`test/security/no_sensitive_logs_test.dart`) |
| G-18 | Weight card ignores the record's state, provenance and unit; a valid NOT_MEASURED weight (no quantity) appended through the repository API or a hand-edited vault would crash it; vault replay does not call validate() (v0.32 gap analysis SEM-9) | CLOSED | F002@v0.32: replay validates every record (skipped with line + rule); weight card uses record state/provenance/unit and names missing values |
| G-19 | Empty or relative `XDG_DATA_HOME` / `HHOS_DATA_DIR` accepted for the development vault (SEM-10) | CLOSED | F002@v0.32: empty/relative XDG_DATA_HOME ignored; relative HHOS_DATA_DIR refused; `human-health-os/` move (C-4) |
| G-20 | Android, Windows, macOS and iOS app labels are still the template name `human_health_os`; web title and manifest read `Human OS` since F001@v0.32 (LENS-7) | PARTIAL | F013 / F015 |
| G-21 | Receipts for non-Flutter gates recorded only the Flutter lockfile digest (STATE-19) | CLOSED | F001@v0.32: receipt schema 2 records both lockfiles |
| G-22 | Domain port comment `health_repository.dart:31` still says encryption arrives in "FORGE 004" (ladder F006); left untouched because `lib/src/domain` was frozen for F001 (final audit ARCH-4) | CLOSED | F002@v0.32 |
| G-23 | Storage status is inferred from the platform, not from a reason reported by the adapter; the profile gate and notice are duplicated in `storage_io.dart` and `storage_web.dart`; the unreadable-vault and browser-blocked states have no dedicated UI (final audit ARCH-1, ARCH-5, UX-3). Mitigated in F001@v0.32 by a cause-neutral "Saving off" label | CLOSED | F002@v0.32: StorageReason codes from the adapters, one profile gate (`storage_status.dart`), capability status from the reason, dedicated texts for unreadable/newer/read-only vault and blocked browser |
| G-24 | No web loading indicator before the first frame (`<noscript>` and a startup-error screen exist since F001@v0.32) (UX-8 remainder) | OPEN | F016 |
| G-25 | Planned rail labels are limited to two lines at 80 dp in the medium rail (no overflow, but long Turkish labels ellipsize at large text sizes) (UX-6 remainder) | OPEN | next UI Forge |
| G-26 | Lab values are numeric only: censored ("< 5", "> 1000") and qualitative ("Pozitif", "Negatif") results cannot be entered yet (v0.24 numeric starter LabResult) | OPEN | next labs Forge |
| G-27 | No lab interpretation in the app (reference state, decision limits, critical rules, RCV, personal baseline); the TS engine exists as the oracle | OPEN | F011 |
| G-28 | Lab method, report time and the structured reference interval (low/high/unit, partition context) are not captured; only the printed range text | OPEN | next labs Forge |
| G-29 | Restoring a backup in the browser is not built (needs a file chooser); web backups download only | OPEN | next data Forge |
| G-30 | Backups and exports are unencrypted (`none-dev-only`) and therefore written only by development builds | CLOSED | F006@v0.32: an encrypted vault's backups are its envelope byte for byte and restore needs the backup's own key; development backups stay plaintext and labelled by design; export for encrypted vaults is G-34 |
| G-31 | No import of external formats (CSV, FHIR, documents); export is Human OS JSON only | OPEN | F013 / later |
| G-32 | Encrypted browser storage is not built: web builds other than development keep entries in memory only. Measured (D-016): pointycastle's Poly1305 fails under dart2js and Argon2id takes 7.4 s in V8 | OPEN | later security/web Forge: dart2wasm, or WebCrypto (AES-GCM, PBKDF2) behind the envelope |
| G-33 | No passphrase change outside recovery and no data-key rotation: a new passphrase does not re-encrypt, so copies and backups made earlier still open with the old one | OPEN | later security Forge |
| G-34 | Export is not offered for encrypted vaults (it writes plaintext JSON); it needs an explicit unencrypted-file warning and a user-chosen location | OPEN | next data Forge |
| G-35 | Removing the newest entries from the end of an encrypted vault (rollback/truncation) cannot be detected without an outside counter; changed, moved, copied-in and removed-in-the-middle entries are detected | OPEN | later (needs a trusted counter or checkpoint) |
| G-36 | No app lock or idle auto-lock: an unlocked vault stays open until the app closes (v0.24 FR-112, optional) | OPEN | later UX/security Forge |
| G-37 | Secrets cannot be wiped from memory (immutable Dart strings, garbage collection); passphrases are not Unicode-normalized before key derivation, so the same passphrase typed in another normalization form would not open the vault | OPEN (low) | later security Forge |
| G-38 | The recovery key is confirmed with a checkbox; re-typing part of it would prove it was written down correctly | OPEN (low) | next UX Forge |
| G-39 | The key slots on line 1 of an encrypted vault are not authenticated as a set: each wrapped key is bound to the vault id and its kind, but someone who can write the file can remove a slot (recovery then adds a missing passphrase slot back) or put back a slot from an older copy of the same vault, so a passphrase replaced through recovery opens the current file again (see G-33). Found by the F006 adversarial review | OPEN (low: needs write access to the file) | later security Forge: authenticate line 1 with the data key |
