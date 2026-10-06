#!/usr/bin/env python3
"""Contract verification runner (doc 129 / v0.25).

Independent, standard-library Python port of the app-owned formulas. It re-executes the SAME
golden-vector files that @hhos/domain runs in TypeScript, so two independent implementations must
agree before Site, client or API can ship (FR-200 parity).

Checks:
  1. core_derived_vectors.json            — independent arithmetic port
  2. lab_interpretation_vectors.json      — reference/critical/RCV/baseline subset, independent port
  3. nutrition_vectors.json               — mass scaling + volume→mass guard
  4. SQLite kernel migrations             — run in order with foreign keys ON, invariant probes
  5. golden-vector ID uniqueness          — v0.24 identifier-integrity rule
  6. build prompts + handoff present      — four release outputs referenced by the repo
Outputs PASS / FAIL / NOT_RUN per check; exit code 1 on any FAIL.
"""
from __future__ import annotations

import json
import math
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GV = ROOT / "contracts" / "golden_vectors"
results: list[tuple[str, str, str]] = []


def record(name: str, status: str, detail: str = "") -> None:
    results.append((name, status, detail))


def present(v) -> bool:
    return isinstance(v, (int, float)) and not isinstance(v, bool) and math.isfinite(v)


def median(xs: list[float]) -> float:
    s = sorted(xs)
    n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


# ---------------------------------------------------------------- 1. core derived
def core(model: str, i: dict):
    def need(*keys):
        miss = [k for k in keys if not present(i.get(k))]
        return ("MISSING_INPUT", None, "MISSING_REQUIRED_INPUT") if miss else None

    if model == "DERIVED-BMI-1":
        if r := need("weight_kg", "height_m"):
            return r
        if i["weight_kg"] <= 0 or i["height_m"] <= 0:
            return ("INVALID_INPUT", None, "NON_POSITIVE_INPUT")
        return ("OK", i["weight_kg"] / i["height_m"] ** 2, None)
    if model == "DERIVED-WAIST_HEIGHT_RATIO-1":
        if r := need("waist", "height"):
            return r
        if i.get("waist_unit", "cm") != i.get("height_unit", "cm"):
            return ("INVALID_INPUT", None, "UNIT_MISMATCH")
        return ("OK", i["waist"] / i["height"], None)
    if model == "DERIVED-PACK_YEARS-1":
        if r := need("packs_per_day", "years_smoked"):
            return r
        return ("OK", i["packs_per_day"] * i["years_smoked"], None)
    if model == "DERIVED-ABSOLUTE_DELTA-1":
        if r := need("baseline", "comparison"):
            return r
        return ("OK", i["comparison"] - i["baseline"], None)
    if model == "DERIVED-PERCENT_CHANGE-1":
        if r := need("baseline", "new"):
            return r
        if i["baseline"] == 0:
            return ("INVALID_INPUT", None, "ZERO_BASELINE")
        return ("OK", (i["new"] - i["baseline"]) / i["baseline"] * 100, None)
    if model == "DERIVED-TRAINING_VOLUME_LOAD-1":
        done = [s for s in i["sets"] if s["state"] == "COMPLETED"]
        if not done:
            return ("MISSING_INPUT", None, "NO_COMPLETED_SETS")
        return ("OK", sum(s["load_kg"] * s["reps"] for s in done), None)
    if model in ("DERIVED-ROLLING_MEAN-1", "DERIVED-ROLLING_MEDIAN-1"):
        vals = [v for v in i["values"][-i["window"]:] if present(v)]
        if not vals:
            return ("MISSING_INPUT", None, "INSUFFICIENT_OBSERVATIONS")
        return ("OK", sum(vals) / len(vals) if model.endswith("MEAN-1") else median(vals), None)
    if model == "DERIVED-TREND-SLOPE-OLS-1":
        pts = [(p["t"], p["v"]) for p in i["points"] if present(p.get("t")) and present(p.get("v"))]
        if len(pts) < 2:
            return ("MISSING_INPUT", None, "INSUFFICIENT_OBSERVATIONS")
        mt = sum(t for t, _ in pts) / len(pts)
        mv = sum(v for _, v in pts) / len(pts)
        sxx = sum((t - mt) ** 2 for t, _ in pts)
        return ("OK", sum((t - mt) * (v - mv) for t, v in pts) / sxx, None)
    if model == "DERIVED-ROBUST_DEVIATION-MAD-1":
        vals = [v for v in i["series"] if present(v)]
        if len(vals) < 5:
            return ("MISSING_INPUT", None, "INSUFFICIENT_OBSERVATIONS")
        med = median(vals)
        mad = median([abs(v - med) for v in vals])
        if mad == 0:
            return ("INVALID_INPUT", None, "ZERO_MAD")
        return ("OK", (i["x"] - med) / (1.4826 * mad), None)
    raise KeyError(model)


def check_core() -> None:
    cat = json.loads((GV / "core_derived_vectors.json").read_text())
    bad = []
    for v in cat["vectors"]:
        status, value, err = core(v["model_id"], v["inputs"])
        e = v["expected"]
        ok = status == e["status"] and (e.get("error_code") in (None, err))
        if "value" in e:
            ok = ok and value is not None and abs(value - e["value"]) <= v["tolerance"]
        else:
            ok = ok and value is None
        if not ok:
            bad.append(v["vector_id"])
    record("core_derived_vectors", "FAIL" if bad else "PASS", f"{len(cat['vectors'])} vectors" + (f"; failing {bad}" if bad else ""))


# ---------------------------------------------------------------- 2. lab interpretation (subset port)
def lab(i: dict) -> dict:
    r = i["result"]
    out: dict = {}
    x = r["value"]
    if not present(x):
        return {"status": "VALUE_NOT_REPORTED"}
    refs = [ri for ri in i["reference"] if ri["specimen"] in (None, r["specimen"])]
    state = "NO_REFERENCE"
    if len(refs) > 1 and len({(a["low"], a["high"], a["unit"]) for a in refs}) > 1:
        state = "CONFLICTING_REFERENCE_SOURCES"
    elif refs:
        ri = refs[0]
        missing_ctx = [k for k in ri["required_context"] if i["context"].get(k) in (None, "")]
        if ri["unit"] != r["unit"]:
            state = "UNIT_NOT_COMPARABLE"
        elif ri["method_id"] and r["method_id"] and ri["method_id"] != r["method_id"]:
            state = "METHOD_NOT_COMPARABLE"
        elif missing_ctx:
            state = "INSUFFICIENT_REFERENCE_CONTEXT"
        elif present(ri["low"]) and x < ri["low"]:
            state = "BELOW_REFERENCE"
        elif present(ri["high"]) and x > ri["high"]:
            state = "ABOVE_REFERENCE"
        else:
            state = "WITHIN_REFERENCE"
    out["reference"] = state
    crit = "NO_ACTIVE_RULE"
    rules = [c for c in i["critical_rules"] if c["status"] != "RETIRED"]
    active = [c for c in rules if c["status"] == "ACTIVE"]
    if any(c["status"] == "STALE" for c in rules) and not active:
        crit = "RULE_PACK_STALE"
    for c in active:
        if c["unit"] != r["unit"]:
            crit = "UNIT_NOT_COMPARABLE"
            continue
        if present(c["low"]) and x < c["low"]:
            crit = "SOURCE_DEFINED_CRITICAL_LOW_MATCHED"
            break
        if present(c["high"]) and x > c["high"]:
            crit = "SOURCE_DEFINED_CRITICAL_HIGH_MATCHED"
            break
        crit = "NO_MATCH"
    out["critical"] = crit
    p = i["prior"]
    if not p or not present(p["value"]):
        comp = "NO_PRIOR"
    elif p["specimen"] != r["specimen"] or p["unit"] != r["unit"]:
        comp = "NOT_COMPARABLE"
    elif p["method_id"] == r["method_id"]:
        comp = "DIRECTLY_COMPARABLE"
    else:
        comp = "UNKNOWN_COMPARABILITY"
    out["comparability"] = comp
    if comp == "NO_PRIOR":
        out["rcv"] = "NO_PRIOR"
    elif comp != "DIRECTLY_COMPARABLE":
        out["rcv"] = "BLOCKED_BY_COMPARABILITY"
    else:
        c = i["rcv"]
        if c["cva"] < 0 or c["cvi"] < 0 or c["z"] <= 0:
            out["rcv"] = "INVALID_CV_INPUT"
        else:
            rcv = c["z"] * math.sqrt(2) * math.sqrt(c["cva"] ** 2 + c["cvi"] ** 2)
            obs = (x - p["value"]) / p["value"] * 100
            out["rcv"] = "EXCEEDS_RCV" if abs(obs) > rcv else "WITHIN_RCV"
            out["rcv_percent"] = rcv
    pts = [v for v in i["baseline_points"] if present(v)]
    if len(pts) >= 5:
        med = median(pts)
        mad = median([abs(v - med) for v in pts])
        out["baseline"] = "ZERO_MAD" if mad == 0 else ("UNUSUAL_FOR_PERSON" if abs((x - med) / (1.4826 * mad)) >= 3.5 else "WITHIN_PERSONAL_BASELINE")
    return out


def check_lab() -> None:
    cat = json.loads((GV / "lab_interpretation_vectors.json").read_text())
    bad = []
    for v in cat["vectors"]:
        got = lab(v["input"])
        e = v["expected"]
        for k in ("reference", "critical", "comparability", "rcv", "baseline"):
            if k in e and got.get(k) != e[k]:
                bad.append(f"{v['vector_id']}.{k}={got.get(k)}")
        if "rcv_percent" in e and abs(got.get("rcv_percent", 1e9) - e["rcv_percent"]) > e.get("tolerance", 1e-9):
            bad.append(f"{v['vector_id']}.rcv_percent")
        if e.get("status") == "VALUE_NOT_REPORTED" and got.get("status") != "VALUE_NOT_REPORTED":
            bad.append(v["vector_id"])
    record("lab_interpretation_vectors", "FAIL" if bad else "PASS", f"{len(cat['vectors'])} vectors" + (f"; failing {bad}" if bad else ""))


# ---------------------------------------------------------------- 3. nutrition
def check_nutrition() -> None:
    cat = json.loads((GV / "nutrition_vectors.json").read_text())
    bad, ran = [], 0
    for v in cat["vectors"]:
        if v["kind"] != "scale":
            continue
        ran += 1
        f, q, e = v["food"], v["quantity"], v["expected"]
        b = f["basis"]
        if q["unit"] == b["unit"]:
            factor = q["amount"] / b["amount"]
        elif b["unit"] == "g" and q["unit"] == "mL" and present(f.get("density_g_per_ml")):
            factor = q["amount"] * f["density_g_per_ml"] / b["amount"]
        else:
            factor = None
        if factor is None:
            if e["ok"] or e.get("error") != "VOLUME_TO_MASS_BLOCKED":
                bad.append(v["vector_id"])
            continue
        for k, val in e.get("nutrients", {}).items():
            got = f["nutrients"][k] * factor if present(f["nutrients"][k]) else None
            if (val is None) != (got is None) or (val is not None and abs(got - val) > 1e-9):
                bad.append(f"{v['vector_id']}.{k}")
    record("nutrition_vectors(scale)", "FAIL" if bad else "PASS", f"{ran} scale vectors" + (f"; failing {bad}" if bad else ""))


# ---------------------------------------------------------------- 4. SQLite kernel
def check_sqlite() -> None:
    db = sqlite3.connect(":memory:")
    db.execute("PRAGMA foreign_keys = ON")
    files = sorted((ROOT / "services" / "api" / "migrations").glob("*.sql"))
    for f in files:
        db.executescript(f.read_text())
    probes = []

    def expect_fail(sql: str, label: str) -> None:
        try:
            db.execute(sql)
            probes.append(f"{label}: accepted (should fail)")
        except sqlite3.IntegrityError:
            pass

    db.execute("INSERT INTO users VALUES ('U','u','t')")
    db.execute("INSERT INTO profiles (id, owner_user_id, name, profile_type, synthetic, modules_json, inputs_json, created_at, updated_at) VALUES ('P','U','p','SYNTHETIC',1,'{}','{}','t','t')")
    expect_fail("INSERT INTO profiles (id, owner_user_id, name, profile_type, synthetic, modules_json, inputs_json, created_at, updated_at) VALUES ('P','U','p','SYNTHETIC',1,'{}','{}','t','t')", "AT-811 duplicate PK")
    expect_fail("INSERT INTO health_facts (id, profile_id, fact_type, value_state, effective_at, recorded_at, provenance, created_at) VALUES ('F','NOPE','x','UNKNOWN','t','t','m','t')", "AT-812 FK")
    expect_fail("INSERT INTO lab_results (id, profile_id, analyte_key, result_state, numeric_value, unit, observed_at, provenance, created_at) VALUES ('L','P','a','PRESENT',NULL,'u','t','m','t')", "AT-814 PRESENT needs value")
    db.execute("INSERT INTO lab_results (id, profile_id, analyte_key, result_state, numeric_value, unit, observed_at, provenance, created_at) VALUES ('L2','P','a','NOT_REPORTED',NULL,'u','t','m','t')")
    expect_fail("INSERT INTO missions (id, profile_id, generated_for_date, category, mission_type, title, rationale, target, source_rule_id, source_rule_version, status, created_at) VALUES ('M','P','d','c','t','t','r','x','r','1','COMPLETED','t')", "plan≠completion")
    db.execute("INSERT INTO pack_manifests VALUES ('PK','1','ACTIVE',NULL,'t')")
    expect_fail("INSERT INTO pack_manifests VALUES ('PK','1','ACTIVE',NULL,'t')", "AT-817 pack id+version")
    expect_fail("INSERT INTO score_results (id, profile_id, model_id, model_version, result_class, status, numeric_output, input_record_ids_json, payload_json, hypothetical, calculated_at) VALUES ('S','P','m','1','APP_COMPOSITE','MISSING_INPUT',0,'[]','{}',0,'t')", "invalid calculation ≠ fake zero")
    record("sqlite_kernel_migrations", "FAIL" if probes else "PASS", f"{len(files)} migration(s), FK on" + (f"; {probes}" if probes else ""))
    record("postgres_runtime", "NOT_RUN", "PostgreSQL DDL/RLS not executed in this repository yet (AT-821)")


# ---------------------------------------------------------------- 5. identifiers
def check_ids() -> None:
    seen: dict[str, str] = {}
    dup = []
    for f in sorted(GV.glob("*.json")):
        for v in json.loads(f.read_text())["vectors"]:
            if v["vector_id"] in seen:
                dup.append(v["vector_id"])
            seen[v["vector_id"]] = f.name
    record("golden_vector_id_uniqueness", "FAIL" if dup else "PASS", f"{len(seen)} unique IDs" + (f"; duplicates {dup}" if dup else ""))


def check_new_canonical_ids() -> None:
    """v0.24 identifier integrity: IDs introduced by the v0.25 addendum must not already exist in v0.24."""
    import re

    master = (ROOT / "docs/handoff/v0.24/LONGEVITY_APP_MASTER_HANDOFF_v0.24.md").read_text()
    addendum = (ROOT / "docs/handoff/v0.25/MASTER_HANDOFF_v0.25_ADDENDUM.md").read_text()
    new_ids = re.findall(r"^\| ((?:FR|AT)-\d+)", addendum, flags=re.M)
    clashes = [i for i in new_ids if re.search(rf"\b{i}\b", master)]
    dup = sorted({i for i in new_ids if new_ids.count(i) > 1})
    bad = clashes + dup
    record("v0.25_canonical_id_integrity", "FAIL" if bad or not new_ids else "PASS", f"{len(new_ids)} new IDs" + (f"; collisions {bad}" if bad else ""))


# ---------------------------------------------------------------- 6. release outputs
def check_outputs() -> None:
    need = [
        "docs/handoff/v0.24/LONGEVITY_APP_MASTER_HANDOFF_v0.24.md",
        "docs/handoff/v0.25/BUILD_LONGEVITY_APP_v0.25.txt",
        "docs/handoff/v0.25/BUILD_HUMAN_HEALTH_OS_SITE_v0.25.txt",
        "docs/handoff/v0.25/MASTER_HANDOFF_v0.25_ADDENDUM.md",
        "docs/PARITY.md",
        "docs/RELEASE_STATUS.md",
    ]
    missing = [p for p in need if not (ROOT / p).exists()]
    record("release_outputs_present", "FAIL" if missing else "PASS", f"missing {missing}" if missing else f"{len(need)} files")


def main() -> int:
    for fn in (check_core, check_lab, check_nutrition, check_sqlite, check_ids, check_new_canonical_ids, check_outputs):
        try:
            fn()
        except Exception as e:  # noqa: BLE001 — a crashing check is a FAIL, never silently skipped
            record(fn.__name__, "FAIL", f"{type(e).__name__}: {e}")
    width = max(len(n) for n, _, _ in results)
    for name, status, detail in results:
        print(f"{status:8} {name:<{width}}  {detail}")
    out = ROOT / "reports" / "tests" / "verify_contracts.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps([{"check": n, "status": s, "detail": d} for n, s, d in results], indent=2))
    return 1 if any(s == "FAIL" for _, s, _ in results) else 0


if __name__ == "__main__":
    sys.exit(main())
