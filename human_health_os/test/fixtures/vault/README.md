# Vault fixtures (master §35.4)

Synthetic data only. No real person, no real health data.

| File | Format | Written by | Covers |
|---|---|---|---|
| `v1_forge002.hhoslog.jsonl` | vault log format 1, record schema 1, profile schema 1 | the FORGE 002 / F002 writer (hand-checked against `HealthRecord.toJson`) | record ids, manual and device provenance, a correction (`supersedes_id`), a `notMeasured` value with no quantity, UTC times |
| `v1_f003_schema2.hhoslog.jsonl` | vault log format 1, record schemas 1 and 2 mixed | the F003 writer (hand-checked the same way) | a schema 1 record next to schema 2 ones, a correction with `amend_reason`, an entered-in-error marker that lets the original count again, a deletion marker (tombstone) |
| `v1_f004_schema3.hhoslog.jsonl` | vault log format 1, record schemas 1–3 mixed | the F004 writer (hand-checked the same way) | lab results as printed: flag and range kept verbatim, a value without a unit (unit stays null), a not-reported value, a corrected transcription; a schema 2 weight next to them |
| `enc_v1_f006.hhosvault` | encrypted envelope `hhos-vault-enc` v1 around `v1_f004_schema3` (production Argon2id cost) | `tool/make_encrypted_fixture.dart` (F006) | opening with the passphrase `fixture passphrase F006 (synthetic)` or the recovery key `K7QM-2XRA-PLMN-B3DE-ZZ4H-QW5T-RT6Y-HJ7U` gives back the schema-3 log byte for byte; both secrets are synthetic and public on purpose |
| `v1_f007_schema4.hhoslog.jsonl` | vault log format 1, record schemas 2–4 mixed | `tool/make_f007_fixture.dart` (the F007 writer) | measurements: a blood pressure reading with context, an identical reading 30 s later (both kept), a corrected reading, waist "84,25" with context, resting heart rate, one withdrawn and one deleted measurement, a not-measured heart rate with no number; a schema 2 weight, a schema 3 lab result and a schema 3 weight written by the F007 build |
| `enc_v1_f007.hhosvault` | encrypted envelope `hhos-vault-enc` v1 around `v1_f007_schema4` (production Argon2id cost) | `tool/make_encrypted_fixture.dart` (F007) | the same synthetic passphrase and recovery key as `enc_v1_f006`; opens to the schema-4 log byte for byte |

A fixture is never edited after it is committed: it stands for data already on users' disks. A new format gets a new fixture, and every later app version must keep reading all of them (`test/data/vault_compat_test.dart`).
