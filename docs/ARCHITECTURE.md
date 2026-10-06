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
      Android · iOS · Web/PWA · Windows (portable + installer) · macOS · (Linux CI smoke)
```

## Flutter app layout (`human_health_os/`)

```
lib/
  main.dart                      # bootstraps AppConfig + capability registry, runs HumanOsApp
  src/
    app/                         # HumanOsApp, theme, build profile
    config/                      # AppConfig (APP_ENV via --dart-define; no secrets)
    navigation/                  # destinations + responsive shell (rail ≥ 840 dp, bar below)
    core/                        # Clock, IdGenerator, Result types, capability registry
    domain/                      # PURE DART: records, engines, ports (HealthRepository, SecretStore…)
      profile/ observations/ labs/ medications/ nutrition/ activity/ sleep/
      conditions/ prevention/ pathways/ scoring/ comparison/
    data/
      local/ import/ export/ adapters/
    features/                    # one folder per destination (screen + view model)
      today/ timeline/ labs/ medications/ nutrition/ activity/
      conditions/ preventive/ compare/ learn/
    presentation/
      theme/ widgets/            # shared widgets: MetricValue (missing ≠ 0), ResultCard, state views
test/
  domain/ contracts/ widget/
integration_test/
tool/                            # web_smoke.mjs, release helpers
```

Dependency direction is `features → application/domain ports ← data adapters`. Domain never imports Flutter, `dart:io`, `dart:html`, storage or HTTP packages. A test enforces this.

## Platform adapters and the capability registry

At startup a `CapabilityRegistry` reports what is **really** available on this runtime:
- `healthPlatform`: Health Connect on Android, HealthKit on iOS, none elsewhere
- `secureKeyStore`: Keystore, Keychain or DPAPI, or a passphrase only
- `fileSystem`, `notifications`, `backgroundWork`, `persistentStorage` (browser storage may be evicted)

The UI shows unavailable integrations as unavailable. It never borrows another platform's capability.

## Persistence (see SECURITY_MODEL.md)

The `HealthRepository` port keeps an in-memory adapter for tests. From FORGE 002 there is a file-backed vault adapter. Encryption comes in a dedicated FORGE: a versioned vault header, a passphrase KDF and a wrapped data key. The portable Windows vault lives in `UserData/` and is identified by a UUID, never by its path.

## What stays in TypeScript and why

- `packages/domain` is the tested reference oracle. The Dart port is verified against the same vectors, which gives differential testing.
- `apps/site` is the Build Lab: synthetic and separate from real data, as the user requires. It is already built and tested.
- `services/api` is a reference for sync semantics (idempotency, If-Match, ownership). A production sync backend is chosen in the SYNC stage.
- `apps/client` is a prototype. It is frozen and will be retired once the Flutter web app reaches parity.
