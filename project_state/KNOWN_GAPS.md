# Known gaps

Status: OPEN, PARTIAL or CLOSED (with the FORGE and evidence that closed it).

| ID | Gap | Status | Planned / closed by |
|---|---|---|---|
| G-01 | No Flutter app yet | CLOSED | F001: `human_health_os/`, web + Linux runtime-tested (`reports/artifacts/forge-001.json`) |
| G-02 | No persistence or canonical record in the Flutter app | PARTIAL | F002: canonical envelope, append-only log, file/browser/memory adapters, weight heartbeat (`reports/artifacts/forge-002.json`). Still open: storage is **unencrypted** (development only); production and portable modes are memory-only until F004; Android/iOS have no path adapter yet. |
| G-03 | No Dart engines | OPEN | F003+ |
| G-04 | No encryption/vault | OPEN | F004 (blocks portable persistence, D-009) |
| G-05 | No real authentication; the reference API has dev auth only | OPEN | F027 |
| G-06 | PostgreSQL/RLS never executed | OPEN | SYNC stage |
| G-07 | Composites, compare and missions lack numeric golden vectors (semantic tests only) | OPEN | before F017/F018/F020 |
| G-08 | Packs (lessons, synthetic profiles, catalog) are TS literals, not shared JSON | OPEN | F021/F036 |
| G-09 | v0.26 baseline, v0.27 overlay and the v0.28 ZIP (docs 216–226) not supplied | OPEN | user |
| G-10 | No SessionStart hook to reinstall Flutter in fresh cloud containers | OPEN | soon (small) |
| G-11 | CI workflow (`.github/workflows/ci.yml`) never run | PARTIAL | Flutter jobs defined in F001 (web, Linux, Android, Windows, macOS/iOS). Never executed: GitHub access for Claude is blocked (push 403). |
| G-12 | Linux distribution channels (Flatpak, AppImage, tar.zst, deb, rpm) not packaged; distro matrix NOT_RUN | OPEN | F030L (D-009) |
| G-13 | Linux keyring (Secret Service) adapter | OPEN | F030K, with or after F004 |
| G-14 | UI copy partly EN-only (capability details, storage notices) | OPEN | ARB move (R-12) |
