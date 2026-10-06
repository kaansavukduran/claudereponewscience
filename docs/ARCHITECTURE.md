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
      ports/                     # HealthRepository, StorageDescription
    application/                 # HeartbeatService (weight entry, parseDecimal)
    data/local/                  # vault_log (JSON lines), LogRepository, storage_io / storage_web
    features/today/ common/      # Today (weight card), honest planned-destination screen
    navigation/                  # destinations + responsive shell (rail ≥ 840 dp, bar below)
    presentation/                # theme roles, StatusChip, build banner
    l10n/                        # EN/TR string table
test/
  architecture/ data/ domain/ unit/ widget/
integration_test/                # Linux desktop: real file IO, relaunch, moved folder
../tools/flutter_web_smoke.mjs   # Playwright smoke of build/web (run from repo root)
```

**Target (planned, not built):** `domain/{observations,labs,medications,nutrition,activity,sleep,conditions,prevention,pathways,scoring,comparison}`, `data/{import,export,adapters}`, one `features/` folder per destination, `test/contracts` (golden vectors, F003) and release helpers.

Dependency direction is `features → application/domain ports ← data adapters`. Domain never imports Flutter, `dart:io`, `dart:html`, `dart:ui`, `dart:js_interop`, storage or HTTP packages. `test/architecture/imports_test.dart` enforces this on import/export/part directives in either quote style, fails if `lib/src/domain` disappears, and has its own negative fixtures.

## Platform adapters and the capability registry

At startup a `CapabilityRegistry` reports what is **really** available on this runtime. Implemented ids: `local_storage` (available only when a file or browser adapter opened; always labelled "not encrypted" until F004), `health_platform` (Health Connect on Android, HealthKit on iOS, unsupported elsewhere; adapters planned F023/F024), `key_store` (planned F004/F030K) and `network` (not required). Planned ids: `file_system`, `notifications`, `background_work`.

The UI shows unavailable integrations as unavailable. It never borrows another platform's capability.

## Persistence (see SECURITY_MODEL.md)

The `HealthRepository` port has one log-backed implementation over three sinks: memory, file (`dart:io`, development desktop builds only) and browser `localStorage` (development web builds only). Production builds and portable mode stay memory-only until the encrypted vault exists. Encryption comes in a dedicated FORGE: a versioned vault header, a passphrase KDF and a wrapped data key. The portable vault (Windows ZIP, Linux tar.zst) will live in `UserData/`, encrypted, and is identified by a UUID, never by its path.

## What stays in TypeScript and why

- `packages/domain` is the tested reference oracle. The Dart port is verified against the same vectors, which gives differential testing.
- `apps/site` is the Build Lab: synthetic and separate from real data, as the user requires. It is already built and tested.
- `services/api` is a reference for sync semantics (idempotency, If-Match, ownership). A production sync backend is chosen in the SYNC stage.
- `apps/client` is a prototype. It is frozen and will be retired once the Flutter web app reaches parity.
