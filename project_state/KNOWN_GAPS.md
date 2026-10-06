# Known gaps

| ID | Gap | Planned FORGE |
|---|---|---|
| G-01 | No Flutter app yet | F001 |
| G-02 | No persistence or canonical record in the Flutter app | F002 |
| G-03 | No Dart engines | F003+ |
| G-04 | No encryption/vault | F004 |
| G-05 | No real authentication; the reference API has dev auth only | F027 |
| G-06 | PostgreSQL/RLS never executed | SYNC stage |
| G-07 | Composites, compare and missions lack numeric golden vectors (semantic tests only) | before F017/F018/F020 |
| G-08 | Packs (lessons, synthetic profiles, catalog) are TS literals, not shared JSON | F021/F036 |
| G-09 | v0.26 baseline and v0.27 overlay not supplied | user |
| G-10 | No SessionStart hook to reinstall Flutter in fresh cloud containers | soon (small) |
| G-11 | CI workflow (`.github/workflows/ci.yml`) never run; no Flutter jobs | F001 adds Flutter jobs; running requires GitHub access |
