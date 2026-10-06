# Known gaps

Status: OPEN, PARTIAL or CLOSED (with the FORGE and evidence that closed it).

| ID | Gap | Status | Planned / closed by |
|---|---|---|---|
| G-01 | No Flutter app yet | CLOSED | F001: `human_health_os/`, web + Linux runtime-tested (`reports/artifacts/forge-001.json`) |
| G-02 | No persistence or canonical record in the Flutter app | PARTIAL | F002: canonical envelope, append-only log, file/browser/memory adapters, weight heartbeat (`reports/artifacts/forge-002.json`). Still open: storage is **unencrypted** (development only); staging, production and portable modes are memory-only until F006; Android/iOS have no path adapter yet. |
| G-03 | No Dart engines | OPEN | F011 |
| G-04 | No encryption/vault | OPEN | F006 (blocks portable persistence, D-009) |
| G-05 | No real authentication; the reference API has dev auth only | OPEN | F014 |
| G-06 | PostgreSQL/RLS never executed | OPEN | F014 |
| G-07 | Composites, compare and missions lack numeric golden vectors (semantic tests only) | OPEN | F011 (before the composite/compare/mission engines) |
| G-08 | Packs (lessons, synthetic profiles, catalog) are TS literals, not shared JSON | OPEN | F011/F012 |
| G-09 | v0.26 baseline and the v0.27 overlay file contents not supplied (docs 216–226 available inside the v0.31/v0.32 masters) | PARTIAL | user |
| G-10 | No SessionStart hook to reinstall Flutter in fresh cloud containers | OPEN | soon (small) |
| G-11 | CI workflow (`.github/workflows/ci.yml`) never run | PARTIAL | Flutter jobs defined in F001 (web, Linux, Android, Windows, macOS/iOS). Never executed: GitHub access for Claude is blocked (push 403). |
| G-12 | Linux distribution channels | PARTIAL | F015-L1: tar.zst/deb/rpm/AppImage built and partly smoke-tested; Flatpak not built; Ubuntu 22.04 defect open; Debian/Fedora/Nobara install smoke NOT_RUN |
| G-13 | Linux keyring (Secret Service) adapter | OPEN | F006 |
| G-14 | UI copy partly EN-only (capability details, storage notices) | OPEN | ARB move (R-12), with F002 for storage notices |
| G-15 | No migration graph / migration receipts (v0.31 §35) for the vault log v1 | OPEN | F002 exit gate |
| G-16 | No backup/restore drill (v0.31 §36) | OPEN | F005 |
| G-17 | No centralized log redaction (v0.31 §37) | OPEN | F006 |
| G-18 | Weight card ignores the record's state, provenance and unit; a valid NOT_MEASURED weight (no quantity) appended through the repository API or a hand-edited vault would crash it; vault replay does not call validate() (v0.32 gap analysis SEM-9) | OPEN | F002 |
| G-19 | Empty or relative `XDG_DATA_HOME` / `HHOS_DATA_DIR` accepted for the development vault (SEM-10) | OPEN | F002 (with the `human-health-os/` XDG move, C-4) |
| G-20 | Android, Windows, macOS and iOS app labels are still the template name `human_health_os`; web title and manifest read `Human OS` since F001@v0.32 (LENS-7) | PARTIAL | F013 / F015 |
| G-21 | Receipts for non-Flutter gates recorded only the Flutter lockfile digest (STATE-19) | CLOSED | F001@v0.32: receipt schema 2 records both lockfiles |

