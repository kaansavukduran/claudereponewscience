-- 0001_kernel.sql — Human Health OS kernel (derived from database_blueprints/sqlite_reference.sql semantics, v0.17+).
-- Released migrations are append-only. Foreign keys are enforced at runtime (PRAGMA foreign_keys=ON).

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE sessions (
  token_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  created_at TEXT NOT NULL,
  revoked_at TEXT
);

CREATE TABLE profiles (
  id TEXT PRIMARY KEY,
  owner_user_id TEXT NOT NULL REFERENCES users(id),
  name TEXT NOT NULL,
  profile_type TEXT NOT NULL CHECK (profile_type IN ('SELF','REAL_OTHER','SYNTHETIC','SCENARIO')),
  synthetic INTEGER NOT NULL CHECK (synthetic IN (0,1)),
  source_profile_id TEXT REFERENCES profiles(id),
  modules_json TEXT NOT NULL,
  inputs_json TEXT NOT NULL,
  revision INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT
);
CREATE INDEX idx_profiles_owner ON profiles(owner_user_id);

CREATE TABLE health_facts (
  id TEXT PRIMARY KEY,
  profile_id TEXT NOT NULL REFERENCES profiles(id),
  fact_type TEXT NOT NULL,
  value_num REAL,
  value_text TEXT,
  unit TEXT,
  value_state TEXT NOT NULL CHECK (value_state IN ('PRESENT','NOT_REPORTED','NOT_MEASURED','NOT_APPLICABLE','UNKNOWN')),
  effective_at TEXT NOT NULL,
  recorded_at TEXT NOT NULL,
  provenance TEXT NOT NULL,
  supersedes_id TEXT REFERENCES health_facts(id),
  created_at TEXT NOT NULL,
  deleted_at TEXT,
  CHECK (value_state <> 'PRESENT' OR value_num IS NOT NULL OR value_text IS NOT NULL)
);
CREATE INDEX idx_facts_profile_effective ON health_facts(profile_id, effective_at);

CREATE TABLE lab_results (
  id TEXT PRIMARY KEY,
  profile_id TEXT NOT NULL REFERENCES profiles(id),
  analyte_key TEXT NOT NULL,
  result_state TEXT NOT NULL CHECK (result_state IN ('PRESENT','NOT_REPORTED','UNREADABLE')),
  numeric_value REAL,
  unit TEXT NOT NULL,
  specimen TEXT,
  method_id TEXT,
  laboratory TEXT,
  observed_at TEXT NOT NULL,
  source_flag TEXT,
  -- v0.24: exact source reference interval snapshot is preserved with the historical result.
  ref_interval_json TEXT,
  provenance TEXT NOT NULL,
  created_at TEXT NOT NULL,
  deleted_at TEXT,
  CHECK (result_state <> 'PRESENT' OR numeric_value IS NOT NULL)
);
CREATE INDEX idx_labs_profile_analyte ON lab_results(profile_id, analyte_key, observed_at);

CREATE TABLE score_results (
  id TEXT PRIMARY KEY,
  profile_id TEXT NOT NULL REFERENCES profiles(id),
  model_id TEXT NOT NULL,
  model_version TEXT NOT NULL,
  result_class TEXT NOT NULL,
  status TEXT NOT NULL,
  numeric_output REAL,
  error_code TEXT,
  input_record_ids_json TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  hypothetical INTEGER NOT NULL CHECK (hypothetical IN (0,1)),
  calculated_at TEXT NOT NULL,
  CHECK (status = 'OK' OR numeric_output IS NULL)
);
CREATE INDEX idx_scores_profile ON score_results(profile_id, calculated_at);

CREATE TABLE missions (
  id TEXT PRIMARY KEY,
  profile_id TEXT NOT NULL REFERENCES profiles(id),
  generated_for_date TEXT NOT NULL,
  category TEXT NOT NULL,
  mission_type TEXT NOT NULL,
  title TEXT NOT NULL,
  rationale TEXT NOT NULL,
  target TEXT NOT NULL,
  source_rule_id TEXT NOT NULL,
  source_rule_version TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('PLANNED','STARTED','COMPLETED','SKIPPED','BLOCKED')),
  completion_record_ids_json TEXT NOT NULL DEFAULT '[]',
  xp INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  CHECK (status <> 'COMPLETED' OR completion_record_ids_json <> '[]')
);
CREATE INDEX idx_missions_profile_date ON missions(profile_id, generated_for_date);

CREATE TABLE idempotency_receipts (
  user_id TEXT NOT NULL REFERENCES users(id),
  idem_key TEXT NOT NULL,
  request_fingerprint TEXT NOT NULL,
  response_status INTEGER NOT NULL,
  response_json TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (user_id, idem_key)
);

CREATE TABLE pack_manifests (
  pack_id TEXT NOT NULL,
  version TEXT NOT NULL,
  status TEXT NOT NULL,
  checksum TEXT,
  installed_at TEXT NOT NULL,
  PRIMARY KEY (pack_id, version)
);

CREATE TABLE audit_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  action TEXT NOT NULL,
  resource TEXT NOT NULL,
  request_id TEXT NOT NULL,
  at TEXT NOT NULL
);
