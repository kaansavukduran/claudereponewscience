# Vault fixtures (master §35.4)

Synthetic data only. No real person, no real health data.

| File | Format | Written by | Covers |
|---|---|---|---|
| `v1_forge002.hhoslog.jsonl` | vault log format 1, record schema 1, profile schema 1 | the FORGE 002 / F002 writer (hand-checked against `HealthRecord.toJson`) | record ids, manual and device provenance, a correction (`supersedes_id`), a `notMeasured` value with no quantity, UTC times |

A fixture is never edited after it is committed: it stands for data already on users' disks. A new format gets a new fixture, and every later app version must keep reading all of them (`test/data/vault_compat_test.dart`).
