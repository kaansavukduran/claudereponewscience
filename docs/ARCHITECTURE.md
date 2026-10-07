# Architecture

Decision: `project_state/DECISIONS.md` → **ADR-IMPL-002** (2026-10-06), which supersedes the client part of ADR-IMPL-001.

## Shape

```
                       contracts/golden_vectors/*.json   (language-neutral contract)
                         ▲               ▲               ▲
                         │               │               │
      human_health_os/lib/src/domain   packages/domain   tools/verify_contracts.py
      (Dart, product core)              (TS reference)    (Python independent port)
                         │               │
 ┌───────────────────────┴───────┐       ├── apps/site      → Human OS Build Lab (synthetic)
 │ human_health_os (Flutter app) │       └── services/api   → reference sync/API candidate
 │  presentation/features        │
 │        ↓                      │
 │  application (use cases)      │
 │        ↓                      │
 │  domain (pure Dart, ports) ◄──┼── data adapters (local vault, import/export, remote sync)
 │        ▲                      │
 │  platform adapters ───────────┼── Health Connect · HealthKit · Keychain/Keystore/DPAPI
 └───────────────────────────────┘    · file picker · notifications · browser storage · updater
      Android · iOS · Web/PWA · Windows (portable + installer) · macOS · Linux (D-008)
```

## Flutter app layout (`human_health_os/`)

**Current (after FORGE 002):**

```
lib/
  main.dart                      # bootstrap(AppConfig, platform) → HumanOsApp(services)
  src/
    app/                         # HumanOsApp, AppServices, bootstrap (storage choice + fallback)
    config/                      # AppConfig (APP_ENV, APP_VERSION, SOURCE_REVISION; no secrets)
    core/                        # capability registry, Clock, IdGenerator (UUID v4)
    domain/                      # PURE DART
      records/                   # HealthRecord envelope, validation, currentRecords()
      profile/                   # Profile (self / realOther / synthetic / scenario)
      ports/                     # HealthRepository, StorageDescription, LoadReport, StorageReason
    application/                 # HeartbeatService (weight entry, parseDecimal)
    data/local/                  # vault_log (JSON lines), vault_migrations (§35), LogRepository, storage_status (profile gate), storage_io / storage_web
    features/today/ common/      # Today (weight card), honest planned-destination screen
    navigation/                  # destinations + responsive shell (rail ≥ 840 dp, bar below)
    presentation/                # theme roles, StatusChip, build banner
    l10n/                        # EN/TR string table
test/
  architecture/ data/ domain/ unit/ widget/
integration_test/                # Linux desktop: real file IO, relaunch, moved folder
../tools/flutter_web_smoke.mjs   # Playwright smoke of build/web (run from repo root)
```

**Target (planned, not built):** `domain/{observations,labs,medications,nutrition,activity,sleep,conditions,prevention,pathways,scoring,comparison}`, `data/{import,export,adapters}`, one `features/` folder per destination, `test/contracts` (golden vectors, F011) and release helpers.

Dependency direction is `features → application/domain ports ← data adapters`. Domain never imports Flutter, `dart:io`, `dart:html`, `dart:ui`, `dart:js_interop`, storage or HTTP packages. `test/architecture/imports_test.dart` enforces this on import/export/part directives in either quote style, fails if `lib/src/domain` disappears, and has its own negative fixtures.

## Platform adapters and the capability registry

At startup a `CapabilityRegistry` reports what is **really** available on this runtime. Implemented ids: `local_storage` (available only when a file or browser adapter opened, always labelled "not encrypted" until F006; status `off` when an adapter exists but saving is off by policy, browser blocking or an unreadable vault; `notImplemented` on Android/iOS), `health_platform` (Health Connect on Android, HealthKit on iOS, unsupported elsewhere; adapter planned F013), `key_store` (planned F006) and `network` (not required). Planned ids: `file_system`, `notifications`, `background_work`.

The UI shows unavailable integrations as unavailable. It never borrows another platform's capability.

## Persistence (see SECURITY_MODEL.md)

The `HealthRepository` port has one log-backed implementation over three sinks: memory, file (`dart:io`, development desktop builds only) and browser `localStorage` (development web builds only). Staging and production builds and portable mode stay memory-only until the encrypted vault (ladder F006) exists. Adapters report a `StorageReason` code (saving, profile or portable policy, platform not built, invalid data folder, browser blocked, unreadable or read-only vault) and `StorageNote`s (Linux folder move); the UI localizes them. The Linux development vault lives in `$XDG_DATA_HOME/human-health-os/` (an empty or relative `XDG_DATA_HOME` is ignored; a relative `HHOS_DATA_DIR` is refused).

**Compatibility and migrations (master §35).** The app writes vault format 1 and reads format 1; a newer vault, record or profile schema is refused and never overwritten (`VAULT_NEWER`, `RECORD_SCHEMA_NEWER`). `vault_migrations.dart` holds the ordered graph (ids, `+1` steps, lossless only). An older vault is migrated in memory only, opens read-only and yields one `MigrationReceipt` per step (§33.3); writing an upgraded file waits for backup checkpoints (F005, D-014). Every replayed record is validated; a broken entry is skipped with a `LoadWarning` (line + rule) and stays in the file. Fixtures for each format live in `test/fixtures/vault/`.

**Timeline and lineage (F003).** Records are never edited. `domain/records/timeline.dart` projects them into one entry per fact (`buildTimeline`): a *correction* (`amend_reason: correction`, record schema 2; a schema 1 `supersedes_id` means the same) adds a version; *entered in error* is a marker that voids its target, so a mistaken correction lets the previous version count again; *deleted* is a marker (tombstone with `deleted_at`) that hides every version of the fact, and later versions cannot resurrect it; two live corrections of one version are a *conflict* shown as such, never resolved by timestamp. Ordering is newest observation, then newest entry, then id. The store refuses amendments of missing records, of markers, or across profile/kind before writing; the service only amends the current version. The Timeline screen lists entries with their versions and offers the three actions with different explanations; Today shows "Versions disagree" instead of a number in a conflict.

**Labs (F004).** A lab result is a `lab.result` record (record schema 3) holding source text only: the value as printed (`original_text`), the printed unit (null when the report prints none; only lab results may lack a unit), the sample date (a calendar day stored as UTC midnight and shown without a time-zone shift), and `LabDetails` (analyte label, specimen, laboratory, the lab's flag and its printed reference range, each null when not printed). The app stores no interpretation, compares nothing with the range and holds no clinical thresholds; the TS reference interpretation engine (`packages/domain/src/labInterpretation.ts`) is ported later with the deterministic engines (F011). Lab results share the timeline and its correction, entered-in-error and delete semantics; a lab correction is a re-entry of every printed field on Labs.

**Backup, restore and export (F005).** `data/backup/backup_bundle.dart` writes one JSON bundle: a manifest (master §36.2: format version, source app version and revision, vault id, vault format, record schema versions, counts, skipped entries, payload SHA-256 and size, encryption, attachments) and the vault log text byte for byte. `stageRestore` runs the gate (§36.3) without writing: format and encryption checks, digest, schema compatibility, identity and counts. The desktop adapter (`data_files_io.dart`, files in `backups/` and `exports/` beside the development vault) then writes a staged copy, reads it back and verifies it, keeps the old vault as `.before-restore-<time>` and switches; a restore is refused while the live vault holds records, and the session refuses writes until a restart. The web adapter downloads files through a local Blob and cannot restore yet. `application/export.dart` writes a deterministic export of the records as stored plus the timeline projection. Bundles and exports are unencrypted (`none-dev-only`) and only development builds write them; staging, production and portable builds get no file adapter until the encrypted envelope (F006). SHA-256 comes from `package:crypto` (D-015). Encryption comes in a dedicated FORGE: a versioned vault header, a passphrase KDF and a wrapped data key. The portable vault (Windows ZIP, Linux tar.zst) will live in `UserData/`, encrypted, and is identified by a UUID, never by its path.

## What stays in TypeScript and why

- `packages/domain` is the tested reference oracle. The Dart port is verified against the same vectors, which gives differential testing.
- `apps/site` is the Build Lab: synthetic and separate from real data, as the user requires. It is already built and tested.
- `services/api` is a reference for sync semantics (idempotency, If-Match, ownership). A production sync backend is chosen in the SYNC stage.
- `apps/client` is a prototype. It is frozen and will be retired once the Flutter web app reaches parity.
