#!/usr/bin/env python3
"""Contract verification runner (doc 129 / v0.25; all five engines since G-75).

Independent, standard-library Python port of the app-owned engines. It re-executes the SAME
golden-vector files that @hhos/domain runs in TypeScript and the Flutter app runs in Dart, so
independent implementations must agree before Site, client or API can ship (FR-200 parity).

The port refuses the same inputs as the TS reference and the Dart engines (G-75, D-038): rolling
mean/median refuse an empty or all-missing window and a min_count that is not a whole number >= 1
(INVALID_MIN_COUNT); a missing list is refused instead of raising; a non-finite number (NaN or an
overflow to infinity) is never reported (NON_FINITE_RESULT). Arithmetic follows JavaScript doubles:
sums are left-to-right (never math.fsum or the compensated sum() of Python 3.12+), and a division
by zero gives an infinity or NaN that is then refused.

Checks:
  1. core_derived_vectors.json            — MP-CORE-DERIVED-1 port (all 10 models)
  2. lab_interpretation_vectors.json      — LAB-INTERPRETATION-ENGINE-1 port (every channel)
  3. nutrition_vectors.json               — scaling, volume→mass guard, recipe totals
  4. medication_safety_vectors.json       — MED-SAFETY-ENGINE-1 port
  5. preventive_vectors.json              — PREVENTIVE-ENGINE-1 port
  6. golden_vectors(total)                — every vector of every catalog ran; no catalog left out
  7. SQLite kernel migrations             — run in order with foreign keys ON, invariant probes
  8. golden-vector ID uniqueness          — v0.24 identifier-integrity rule
  9. build prompts + handoff present      — four release outputs referenced by the repo
Every key of every `expected` object is asserted; an unknown key is a FAIL, never skipped.
Outputs PASS / FAIL / NOT_RUN per check; exit code 1 on any FAIL.
"""
from __future__ import annotations

import datetime
import json
import math
import re
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GV = ROOT / "contracts" / "golden_vectors"
results: list[tuple[str, str, str]] = []
NON_FINITE = "NON_FINITE_RESULT"
ran_vectors: dict[str, int] = {}


def record(name: str, status: str, detail: str = "") -> None:
    results.append((name, status, detail))


def present(v) -> bool:
    return isinstance(v, (int, float)) and not isinstance(v, bool) and math.isfinite(v)


def finite(v) -> bool:
    return v is None or math.isfinite(v)


def jsum(xs) -> float:
    """Left-to-right double sum, as Array.prototype.reduce (Python 3.12+ sum() is compensated)."""
    acc = 0.0
    for x in xs:
        acc += x
    return acc


def jdiv(a: float, b: float) -> float:
    """IEEE division as in JavaScript: x/0 is ±Infinity or NaN instead of an exception."""
    if b == 0:
        if a == 0 or math.isnan(a):
            return math.nan
        return math.copysign(math.inf, a) * math.copysign(1.0, b)
    return a / b


def median(s: list[float]) -> float:
    """Median of an already sorted list; an empty list raises (it never yields a value)."""
    n = len(s)
    if n == 0:
        raise ValueError("median of an empty list")
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def whole(v) -> bool:
    return present(v) and float(v) == math.floor(v)


def load(name: str) -> dict:
    return json.loads((GV / name).read_text())


def close(got, want, tol: float) -> bool:
    return isinstance(got, (int, float)) and not isinstance(got, bool) and abs(got - want) <= tol


# ---------------------------------------------------------------- 1. core derived
def core(model: str, i: dict):
    """(status, value, error_code) — same order of checks as coreDerived.ts / core_derived.dart."""

    def need(*keys):
        miss = [k for k in keys if not present(i.get(k))]
        return ("MISSING_INPUT", None, "MISSING_REQUIRED_INPUT") if miss else None

    def ok(v: float):
        return ("OK", v, None) if math.isfinite(v) else ("INVALID_INPUT", None, NON_FINITE)

    if model == "DERIVED-BMI-1":
        if r := need("weight_kg", "height_m"):
            return r
        if i["weight_kg"] <= 0 or i["height_m"] <= 0:
            return ("INVALID_INPUT", None, "NON_POSITIVE_INPUT")
        return ok(jdiv(i["weight_kg"], i["height_m"] * i["height_m"]))
    if model == "DERIVED-WAIST_HEIGHT_RATIO-1":
        if r := need("waist", "height"):
            return r
        if i.get("waist_unit", "cm") != i.get("height_unit", "cm"):
            return ("INVALID_INPUT", None, "UNIT_MISMATCH")
        if i["waist"] <= 0 or i["height"] <= 0:
            return ("INVALID_INPUT", None, "NON_POSITIVE_INPUT")
        return ok(i["waist"] / i["height"])
    if model == "DERIVED-PACK_YEARS-1":
        if r := need("packs_per_day", "years_smoked"):
            return r
        if i["packs_per_day"] < 0 or i["years_smoked"] < 0:
            return ("INVALID_INPUT", None, "NEGATIVE_INPUT")
        return ok(i["packs_per_day"] * i["years_smoked"])
    if model == "DERIVED-ABSOLUTE_DELTA-1":
        if r := need("baseline", "comparison"):
            return r
        return ok(i["comparison"] - i["baseline"])
    if model == "DERIVED-PERCENT_CHANGE-1":
        if r := need("baseline", "new"):
            return r
        if i["baseline"] == 0:
            return ("INVALID_INPUT", None, "ZERO_BASELINE")
        return ok((i["new"] - i["baseline"]) / i["baseline"] * 100)
    if model == "DERIVED-TRAINING_VOLUME_LOAD-1":
        sets = i.get("sets")
        if not isinstance(sets, list):
            return ("MISSING_INPUT", None, "MISSING_REQUIRED_INPUT")
        done = [s for s in sets if isinstance(s, dict) and s.get("state") == "COMPLETED"]
        if not done:
            return ("MISSING_INPUT", None, "NO_COMPLETED_SETS")
        if any(not present(s.get("load_kg")) or not present(s.get("reps")) for s in done):
            return ("MISSING_INPUT", None, "MISSING_REQUIRED_INPUT")
        if any(s["load_kg"] < 0 or s["reps"] < 0 for s in done):
            return ("INVALID_INPUT", None, "NEGATIVE_INPUT")
        return ok(jsum(s["load_kg"] * s["reps"] for s in done))
    if model in ("DERIVED-ROLLING_MEAN-1", "DERIVED-ROLLING_MEDIAN-1"):
        w = i.get("window")
        if not whole(w) or w <= 0:
            return ("INVALID_INPUT", None, "INVALID_WINDOW")
        mc = i.get("min_count")  # absent or null means 1; otherwise a finite whole number >= 1
        if mc is not None and (not whole(mc) or mc < 1):
            return ("INVALID_INPUT", None, "INVALID_MIN_COUNT")
        min_count = 1 if mc is None else mc
        values = i.get("values")
        if not isinstance(values, list):
            return ("MISSING_INPUT", None, "MISSING_REQUIRED_INPUT")
        vals = [float(v) for v in values[-int(w):] if present(v)]
        if not vals or len(vals) < min_count:
            return ("MISSING_INPUT", None, "INSUFFICIENT_OBSERVATIONS")
        if model.endswith("MEAN-1"):
            return ok(jsum(vals) / len(vals))
        return ok(median(sorted(vals)))
    if model == "DERIVED-TREND-SLOPE-OLS-1":
        points = i.get("points") if isinstance(i.get("points"), list) else []
        pts = [(p["t"], p["v"]) for p in points if isinstance(p, dict) and present(p.get("t")) and present(p.get("v"))]
        min_n = i.get("min_n")
        min_n = 2 if min_n is None else min_n
        if len(pts) < max(2, min_n):
            return ("MISSING_INPUT", None, "INSUFFICIENT_OBSERVATIONS")
        mt = jsum(t for t, _ in pts) / len(pts)
        mv = jsum(v for _, v in pts) / len(pts)
        sxx = jsum((t - mt) * (t - mt) for t, _ in pts)
        sxy = jsum((t - mt) * (v - mv) for t, v in pts)
        if sxx == 0:
            return ("INVALID_INPUT", None, "ZERO_TIME_VARIANCE")
        return ok(sxy / sxx)
    if model == "DERIVED-ROBUST_DEVIATION-MAD-1":
        if not present(i.get("x")):
            return ("MISSING_INPUT", None, "MISSING_REQUIRED_INPUT")
        series = i.get("series") if isinstance(i.get("series"), list) else []
        vals = sorted(float(v) for v in series if present(v))
        if len(vals) < 5:
            return ("MISSING_INPUT", None, "INSUFFICIENT_OBSERVATIONS")
        med = median(vals)
        mad = median(sorted(abs(v - med) for v in vals))
        if mad == 0:
            return ("INVALID_INPUT", None, "ZERO_MAD")
        return ok(jdiv(i["x"] - med, 1.4826 * mad))
    raise KeyError(model)


def check_core() -> None:
    cat = load("core_derived_vectors.json")
    bad = []
    for v in cat["vectors"]:
        status, value, err = core(v["model_id"], v["inputs"])
        if core(v["model_id"], json.loads(json.dumps(v["inputs"]))) != (status, value, err):
            bad.append(f"{v['vector_id']}.repeatability")
        e = v["expected"]
        for k in e:
            if k not in ("status", "value", "error_code"):
                bad.append(f"{v['vector_id']}.{k}=unhandled")
        ok = status == e["status"] and (e.get("error_code") in (None, err))
        if "value" in e:
            ok = ok and close(value, e["value"], v["tolerance"])
        else:
            ok = ok and value is None
        if not ok:
            bad.append(f"{v['vector_id']}=({status},{value},{err})")
    ran_vectors["core_derived_vectors.json"] = len(cat["vectors"])
    record("core_derived_vectors", "FAIL" if bad else "PASS", f"{len(cat['vectors'])} vectors" + (f"; failing {bad}" if bad else ""))


# ---------------------------------------------------------------- 2. lab interpretation
def rcv_percent(c: dict):
    cva, cvi, z = c.get("cva"), c.get("cvi"), c.get("z")
    if not present(cva) or not present(cvi) or not present(z):
        return None
    if cva < 0 or cvi < 0 or z <= 0:
        return None
    return z * math.sqrt(2) * math.sqrt(cva * cva + cvi * cvi)


def comparability(cur: dict, prior, records: list) -> dict:
    if not prior or not present(prior.get("value")):
        return {"state": "NO_PRIOR", "trend_discontinuity": False}
    if cur.get("specimen") != prior.get("specimen") or cur.get("unit") != prior.get("unit"):
        return {"state": "NOT_COMPARABLE", "trend_discontinuity": True}
    if cur.get("method_id") and prior.get("method_id") and cur["method_id"] == prior["method_id"]:
        return {"state": "DIRECTLY_COMPARABLE", "trend_discontinuity": False}
    rec = next(
        (
            r
            for r in records
            if (r.get("from_method") == prior.get("method_id") and r.get("to_method") == cur.get("method_id"))
            or (r.get("from_method") == cur.get("method_id") and r.get("to_method") == prior.get("method_id"))
        ),
        None,
    )
    if rec and rec.get("source") and rec.get("version"):
        return {"state": "COMPARABLE_WITH_METHOD_CHANGE_MARKER", "trend_discontinuity": True}
    return {"state": "UNKNOWN_COMPARABILITY", "trend_discontinuity": True}


def lab(i: dict) -> dict:
    r = i["result"]
    flags = []
    if r.get("source_flag"):
        flags.append(("SOURCE_REPORTED", r["source_flag"]))
    x = r.get("value")
    if not present(x):
        return {
            "status": "VALUE_NOT_REPORTED",
            "value": None,
            "flags": flags,
            "reference": "NO_REFERENCE",
            "decision": [],
            "critical": "NO_ACTIVE_RULE",
            "external_receipt_confirmed": False,
            "comparability": "NO_PRIOR",
            "trend_discontinuity": False,
            "rcv": "NO_PRIOR",
            "rcv_percent": None,
            "observed_percent_change": None,
            "baseline": "INSUFFICIENT_HISTORY",
            "robust_z": None,
        }
    # Reference interval (only after unit and method compatibility).
    ref = "NO_REFERENCE"
    cands = [ri for ri in i.get("reference") or [] if ri.get("specimen") is None or ri.get("specimen") == r.get("specimen")]
    if len(cands) > 1 and len({(c.get("low"), c.get("high"), c.get("unit")) for c in cands}) > 1:
        ref = "CONFLICTING_REFERENCE_SOURCES"
    if ref != "CONFLICTING_REFERENCE_SOURCES" and cands:
        ri = cands[0]
        ctx = i.get("context") or {}
        missing_ctx = [k for k in ri.get("required_context", []) if ctx.get(k) is None or ctx.get(k) == ""]
        if ri.get("unit") != r.get("unit"):
            ref = "UNIT_NOT_COMPARABLE"
        elif ri.get("method_id") and r.get("method_id") and ri["method_id"] != r["method_id"]:
            ref = "METHOD_NOT_COMPARABLE"
        elif missing_ctx:
            ref = "INSUFFICIENT_REFERENCE_CONTEXT"
        elif not present(ri.get("low")) and not present(ri.get("high")):
            ref = "NO_REFERENCE"
        elif present(ri.get("low")) and x < ri["low"]:
            ref = "BELOW_REFERENCE"
        elif present(ri.get("high")) and x > ri["high"]:
            ref = "ABOVE_REFERENCE"
        else:
            ref = "WITHIN_REFERENCE"
    if ref in ("BELOW_REFERENCE", "ABOVE_REFERENCE"):
        flags.append(("APP_REFERENCE_COMPARISON", ref))
    # Decision limits — a channel of their own.
    decision = []
    for d in i.get("decision_rules") or []:
        if d.get("unit") != r.get("unit"):
            continue
        matched = x >= d["threshold"] if d.get("direction") == "AT_OR_ABOVE" else x < d["threshold"]
        decision.append((d["rule_id"], matched))
        if matched:
            flags.append(("APP_RULE_MATCH", d["rule_id"]))
    # Critical rules — independent of the reference interval.
    crit_state = "NO_ACTIVE_RULE"
    crit = [c for c in i.get("critical_rules") or [] if c.get("status") != "RETIRED" and (c.get("specimen") is None or c.get("specimen") == r.get("specimen"))]
    stale = next((c for c in crit if c.get("status") == "STALE"), None)
    active = [c for c in crit if c.get("status") == "ACTIVE"]
    if stale and not active:
        crit_state = "RULE_PACK_STALE"
    for c in active:
        if c.get("unit") != r.get("unit"):
            crit_state = "UNIT_NOT_COMPARABLE"
            continue
        if present(c.get("low")) and x < c["low"]:
            crit_state = "SOURCE_DEFINED_CRITICAL_LOW_MATCHED"
            break
        if present(c.get("high")) and x > c["high"]:
            crit_state = "SOURCE_DEFINED_CRITICAL_HIGH_MATCHED"
            break
        crit_state = "NO_MATCH"
    if crit_state.startswith("SOURCE_DEFINED"):
        flags.append(("APP_RULE_MATCH", crit_state))
    prior = i.get("prior")
    comp = comparability(r, prior, i.get("comparability_records") or [])
    # Delta / RCV — blocked unless directly comparable; a non-finite number is never reported.
    rcv, rcv_pct, obs_pct = "NO_PRIOR", None, None
    if comp["state"] != "NO_PRIOR":
        if comp["state"] != "DIRECTLY_COMPARABLE":
            rcv = "BLOCKED_BY_COMPARABILITY"
        elif not i.get("rcv"):
            rcv = "NO_RCV_SOURCE"
        else:
            pct = rcv_percent(i["rcv"])
            p = prior["value"]
            if pct is None:
                rcv = "INVALID_CV_INPUT"
            elif not math.isfinite(pct):
                rcv = NON_FINITE
            elif p == 0:
                rcv, rcv_pct = "ZERO_PRIOR", pct
            else:
                obs = (x - p) / p * 100
                if not math.isfinite(obs):
                    rcv, rcv_pct = NON_FINITE, pct
                else:
                    rcv, rcv_pct, obs_pct = ("EXCEEDS_RCV" if abs(obs) > pct else "WITHIN_RCV"), pct, obs
    # Personal baseline — separate from the population reference.
    pts = sorted(float(v) for v in i.get("baseline_points") or [] if present(v))
    base, rz = "INSUFFICIENT_HISTORY", None
    if len(pts) >= 5:
        med = median(pts)
        mad = median(sorted(abs(v - med) for v in pts))
        if mad == 0:
            base = "ZERO_MAD"
        else:
            z = jdiv(x - med, 1.4826 * mad)
            thr = i.get("baseline_threshold")
            thr = 3.5 if thr is None else thr
            if not math.isfinite(z):
                base = NON_FINITE
            else:
                base, rz = ("UNUSUAL_FOR_PERSON" if abs(z) >= thr else "WITHIN_PERSONAL_BASELINE"), z
    status = "SUCCESS"
    if ref == "UNIT_NOT_COMPARABLE":
        status = "UNIT_BLOCKED"
    elif ref == "METHOD_NOT_COMPARABLE":
        status = "METHOD_BLOCKED"
    elif ref == "INSUFFICIENT_REFERENCE_CONTEXT":
        status = "INSUFFICIENT_CONTEXT"
    elif ref == "CONFLICTING_REFERENCE_SOURCES":
        status = "CONFLICTING_REFERENCE_SOURCES"
    elif crit_state == "RULE_PACK_STALE":
        status = "RULE_PACK_STALE"
    elif ref == "NO_REFERENCE":
        status = "NO_APPLICABLE_REFERENCE"
    return {
        "status": status,
        "value": x,
        "flags": flags,
        "reference": ref,
        "decision": decision,
        "critical": crit_state,
        "external_receipt_confirmed": False,
        "comparability": comp["state"],
        "trend_discontinuity": comp["trend_discontinuity"],
        "rcv": rcv,
        "rcv_percent": rcv_pct,
        "observed_percent_change": obs_pct,
        "baseline": base,
        "robust_z": rz,
    }


def check_lab() -> None:
    cat = load("lab_interpretation_vectors.json")
    bad = []
    for v in cat["vectors"]:
        got = lab(v["input"])
        e = v["expected"]
        tol = e.get("tolerance", 1e-9)
        for k, want in e.items():
            vid = f"{v['vector_id']}.{k}"
            if k == "tolerance":
                continue
            if k in ("status", "reference", "critical", "comparability", "trend_discontinuity", "rcv", "baseline", "external_receipt_confirmed"):
                if got[k] != want:
                    bad.append(f"{vid}={got[k]}")
            elif k == "value":
                if got["value"] != want:
                    bad.append(f"{vid}={got['value']}")
            elif k in ("rcv_percent", "observed_percent_change", "robust_z"):
                if not close(got[k], want, tol):
                    bad.append(f"{vid}={got[k]}")
            elif k == "decision_matched":
                if [rid for rid, m in got["decision"] if m] != want:
                    bad.append(vid)
            elif k == "flag_origins":
                if [o for o, _ in got["flags"]] != want:
                    bad.append(vid)
            else:
                bad.append(f"{vid}=unhandled")
        if not all(finite(got[k]) for k in ("rcv_percent", "observed_percent_change", "robust_z")):
            bad.append(f"{v['vector_id']}.non_finite")
    ran_vectors["lab_interpretation_vectors.json"] = len(cat["vectors"])
    record("lab_interpretation_vectors", "FAIL" if bad else "PASS", f"{len(cat['vectors'])} vectors" + (f"; failing {bad}" if bad else ""))


# ---------------------------------------------------------------- 3. nutrition
def scale_factor(f: dict, q: dict):
    """(factor, error) — consumed quantity in the food's basis unit; volume→mass only with a density."""
    amount, unit, b = q.get("amount"), q.get("unit"), f["basis"]
    if not present(amount) or amount < 0:
        return None, "INVALID_QUANTITY"
    density = f.get("density_g_per_ml")
    measures = f.get("measures_g") or None
    if unit == b["unit"]:
        return jdiv(amount, b["amount"]), None
    if b["unit"] == "g" and unit == "mL":
        if not present(density):
            return None, "VOLUME_TO_MASS_BLOCKED"
        return jdiv(amount * density, b["amount"]), None
    if b["unit"] == "mL" and unit == "g":
        if not present(density):
            return None, "VOLUME_TO_MASS_BLOCKED"
        return jdiv(jdiv(amount, density), b["amount"]), None
    if b["unit"] == "g" and measures is not None and unit in measures:
        return jdiv(amount * measures[unit], b["amount"]), None
    if b["unit"] == "g":
        return None, "UNKNOWN_MEASURE"
    return None, "BASIS_INCOMPATIBLE"


def scale_food(f: dict, q: dict) -> dict:
    factor, err = scale_factor(f, q)
    if factor is None:
        return {"ok": False, "error": err, "nutrients": {}}
    nutrients = {k: (v * factor if present(v) else None) for k, v in f["nutrients"].items()}
    if not math.isfinite(factor) or not all(finite(v) for v in nutrients.values()):
        return {"ok": False, "error": NON_FINITE, "nutrients": {}}
    return {"ok": True, "error": None, "nutrients": nutrients}


def sum_nutrients(items: list[dict]) -> dict:
    keys = sorted({k for it in items for k in it})
    out = {}
    for k in keys:
        known, ks, ms = 0.0, 0, 0
        for it in items:
            v = it.get(k)
            if present(v):
                known += v
                ks += 1
            else:
                ms += 1
        out[k] = {"known": known if ks else None, "known_sources": ks, "missing_sources": ms}
    return out


def compute_recipe(rec: dict) -> dict:
    scaled = [(ing, scale_food(ing["food"], ing["quantity"])) for ing in rec["ingredients"]]
    errors = [(ing["food"]["name"], s["error"]) for ing, s in scaled if not s["ok"]]
    totals = sum_nutrients([s["nutrients"] for _, s in scaled if s["ok"]])

    def div(d):
        if d is None or d <= 0:
            return None
        return {k: (None if t["known"] is None else t["known"] / d) for k, t in totals.items()}

    per_serving = div(rec.get("serving_count"))
    mass = rec.get("final_cooked_mass_g")
    per_100g = div(mass / 100) if mass else None  # cooking yield is never assumed
    if (
        not all(finite(t["known"]) for t in totals.values())
        or not all(finite(v) for v in (per_serving or {}).values())
        or not all(finite(v) for v in (per_100g or {}).values())
    ):
        return {"ok": False, "errors": errors + [(rec["name"], NON_FINITE)], "totals": {}, "per_serving": None, "per_100g_cooked": None}
    return {"ok": not errors, "errors": errors, "totals": totals, "per_serving": per_serving, "per_100g_cooked": per_100g}


def same_nutrients(got, want: dict, vid: str, bad: list) -> None:
    for k, val in want.items():
        g = (got or {}).get(k)
        if (val is None) != (g is None) or (val is not None and not close(g, val, 1e-9)):
            bad.append(f"{vid}.{k}={g}")


def check_nutrition() -> None:
    cat = load("nutrition_vectors.json")
    bad, kinds = [], {"scale": 0, "recipe": 0}
    for v in cat["vectors"]:
        e, vid = v["expected"], v["vector_id"]
        if v["kind"] == "scale":
            kinds["scale"] += 1
            r = scale_food(v["food"], v["quantity"])
            if set(r["nutrients"]) - set(v["food"]["nutrients"]):
                bad.append(f"{vid}.extra_nutrients")
            if r["ok"] and set(r["nutrients"]) != set(v["food"]["nutrients"]):
                bad.append(f"{vid}.nutrient_keys")
            for k, want in e.items():
                if k == "ok":
                    if r["ok"] != want:
                        bad.append(f"{vid}.ok")
                elif k == "error":
                    if r["error"] != want:
                        bad.append(f"{vid}.error={r['error']}")
                elif k == "nutrients":
                    same_nutrients(r["nutrients"], want, f"{vid}.nutrients", bad)
                else:
                    bad.append(f"{vid}.{k}=unhandled")
        elif v["kind"] == "recipe":
            kinds["recipe"] += 1
            r = compute_recipe(v["recipe"])
            for k, want in e.items():
                if k == "ok":
                    if r["ok"] != want:
                        bad.append(f"{vid}.ok")
                elif k == "totals_known":
                    same_nutrients({n: t["known"] for n, t in r["totals"].items()}, want, f"{vid}.totals", bad)
                elif k == "missing_sources":
                    for n, cnt in want.items():
                        if r["totals"].get(n, {}).get("missing_sources") != cnt:
                            bad.append(f"{vid}.missing_sources.{n}")
                elif k in ("per_serving", "per_100g_cooked"):
                    if want is None:
                        if r[k] is not None:
                            bad.append(f"{vid}.{k}")
                    elif r[k] is None:
                        bad.append(f"{vid}.{k}=None")
                    else:
                        same_nutrients(r[k], want, f"{vid}.{k}", bad)
                else:
                    bad.append(f"{vid}.{k}=unhandled")
        else:
            bad.append(f"{vid}.kind={v['kind']}")
    ran_vectors["nutrition_vectors.json"] = sum(kinds.values())
    detail = f"{len(cat['vectors'])} vectors ({kinds['scale']} scale, {kinds['recipe']} recipe)"
    record("nutrition_vectors", "FAIL" if bad else "PASS", detail + (f"; failing {bad}" if bad else ""))


# ---------------------------------------------------------------- 4. medication safety
MASS_TO_MCG = {"mcg": 1, "mg": 1000, "g": 1_000_000}
_JS_NUM = re.compile(r"^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$")


def js_number(s: str):
    """Number(s) for decimal strings: blank is 0, anything unreadable is None (NaN)."""
    t = s.strip()
    if t == "":
        return 0.0
    return float(t) if _JS_NUM.match(t) else None


def minutes(t):
    if not t:
        return None
    parts = t.split(":")
    h = js_number(parts[0])
    m = js_number(parts[1]) if len(parts) > 1 else None
    if h is None or m is None or not math.isfinite(h) or not math.isfinite(m):
        return None
    return h * 60 + m


def combine_amounts(parts: list[dict]):
    """(value, unit, reason): one basis and convertible mass units only; IU never converts."""
    if any(p["amount"] is None or p["unit"] is None for p in parts):
        return None, None, "UNDISCLOSED_AMOUNT"
    if len({p["basis"] for p in parts}) > 1:
        return None, None, "BASIS_MISMATCH"
    units = list(dict.fromkeys(p["unit"] for p in parts))  # insertion order, as a JS Set
    if len(units) == 1:
        total = jsum(p["amount"] for p in parts)
        return (None, None, NON_FINITE) if not math.isfinite(total) else (total, units[0], None)
    if all(u in MASS_TO_MCG for u in units):
        mcg = jsum(p["amount"] * MASS_TO_MCG[p["unit"]] for p in parts)
        largest = sorted(units, key=lambda u: -MASS_TO_MCG[u])[0]  # stable, largest unit first
        value = mcg / MASS_TO_MCG[largest]
        return (None, None, NON_FINITE) if not math.isfinite(value) else (value, largest, None)
    return None, None, "UNIT_CONVERSION_RULE_NOT_INSTALLED"


def assess_safety(products: list, entries: list, rules: list, conditions: list) -> list[dict]:
    by_id = {p["product_id"]: p for p in products}
    active = [e for e in entries if e["product_id"] in by_id]
    findings: list[dict] = []

    def basis_of(es):
        kinds = {e["kind"] for e in es}
        return "MIXED" if len(kinds) > 1 else ("TAKEN" if "TAKEN" in kinds else "PLANNED")

    def mk(ftype, ing, prods, es, combined=None, reason=None, rule=None, action=None):
        findings.append(
            {
                "type": ftype,
                "ingredient_id": ing,
                "products": prods,
                "rule_id": rule,
                "action": action,
                "combined_amount": combined,
                "combined_reason": reason,
                "exposure_basis": basis_of(es),
                "guaranteed_safe": False,
            }
        )

    for e in active:
        p = by_id[e["product_id"]]
        if not p["composition_known"]:
            mk("INSUFFICIENT_CONTEXT", None, [p["product_id"]], [e], reason="UNKNOWN_COMPOSITION")
        for ing in p["ingredients"]:
            if ing["mapping"] == "AMBIGUOUS":
                mk("UNKNOWN_INGREDIENT", ing["ingredient_id"], [p["product_id"]], [e])
    reviewed: dict[str, list] = {}
    for e in active:
        for ing in by_id[e["product_id"]]["ingredients"]:
            if ing["mapping"] == "REVIEWED":
                reviewed.setdefault(ing["ingredient_id"], []).append((e, ing))
    for ing_id in sorted(reviewed):  # ASCII IDs: code-point order equals localeCompare here
        lst = reviewed[ing_id]
        if len(lst) < 2:
            continue
        prods = list(dict.fromkeys(e["product_id"] for e, _ in lst))
        val, unit, reason = combine_amounts(
            [{"amount": None if g["amount"] is None else g["amount"] * e["servings_per_day"], "unit": g["unit"], "basis": g["basis"]} for e, g in lst]
        )
        mk(
            "SAME_ACTIVE_DIFFERENT_PRODUCT" if len(prods) > 1 else "EXACT_DUPLICATE_ACTIVE_INGREDIENT",
            ing_id,
            prods,
            [e for e, _ in lst],
            combined=None if val is None else {"value": val, "unit": unit},
            reason=reason,
            rule="RULE-DUPLICATE-INGREDIENT-1",
            action="INFORM",
        )
    for rule in rules:
        kind, parts_ids = rule["kind"], rule["participants"]
        if kind == "PAIR":
            parts = [reviewed.get(pid, []) for pid in parts_ids]
            if any(not p for p in parts):
                continue
            if rule.get("route") is not None and not all(any(by_id[e["product_id"]]["route"] == rule["route"] for e, _ in p) for p in parts):
                continue
            flat = [e for p in parts for e, _ in p]
            mk("SYNTHETIC_PAIR_INTERACTION", "+".join(parts_ids), list(dict.fromkeys(e["product_id"] for e in flat)), flat, rule=rule["rule_id"], action=rule["action"])
        elif kind == "TIMING_SEPARATION":
            a = reviewed.get(parts_ids[0] if parts_ids else "", [])
            b = reviewed.get(parts_ids[1] if len(parts_ids) > 1 else "", [])
            if not a or not b:
                continue
            for x, _ in a:
                for y, _ in b:
                    tx, ty = minutes(x.get("time")), minutes(y.get("time"))
                    pair = [x["product_id"], y["product_id"]]
                    if tx is None or ty is None:
                        mk("INSUFFICIENT_CONTEXT", "+".join(parts_ids), pair, [x, y], reason="MISSING_TIME", rule=rule["rule_id"])
                    elif abs(tx - ty) < (rule.get("min_separation_minutes") or 0):
                        mk("TIMING_SEPARATION", "+".join(parts_ids), pair, [x, y], rule=rule["rule_id"], action=rule["action"])
        elif kind == "CONDITION":
            p = reviewed.get(parts_ids[0], [])
            if p and rule.get("condition") and rule["condition"] in conditions:
                mk("CONDITION_CONTEXT", parts_ids[0], list(dict.fromkeys(e["product_id"] for e, _ in p)), [e for e, _ in p], rule=rule["rule_id"], action=rule["action"])
    if not findings:
        mk("CLEAR_NO_MATCH_FOUND", None, [e["product_id"] for e in active], active)
    return findings


def check_medication() -> None:
    cat = load("medication_safety_vectors.json")
    bad = []
    for v in cat["vectors"]:
        fs = assess_safety(cat["products"], v["entries"], cat["rules"], v["conditions"])
        e, vid = v["expected"], v["vector_id"]
        if any(f["guaranteed_safe"] is not False for f in fs):
            bad.append(f"{vid}.guaranteed_safe")
        for k, want in e.items():
            if k == "types":
                if [f["type"] for f in fs] != want:
                    bad.append(f"{vid}.types={[f['type'] for f in fs]}")
            elif k == "combined":
                for ing, val in want.items():
                    f = next((x for x in fs if x["ingredient_id"] == ing), None)
                    got = f["combined_amount"] if f else "absent"
                    if val is None:
                        if got is not None:
                            bad.append(f"{vid}.combined.{ing}={got}")
                    elif not isinstance(got, dict) or not close(got["value"], val["value"], 1e-12) or got["unit"] != val["unit"]:
                        bad.append(f"{vid}.combined.{ing}={got}")
            elif k == "combined_reason":
                for ing, reason in want.items():
                    f = next((x for x in fs if x["ingredient_id"] == ing), None)
                    if not f or f["combined_reason"] != reason:
                        bad.append(f"{vid}.combined_reason.{ing}")
            elif k == "guaranteed_safe":
                if any(f["guaranteed_safe"] != want for f in fs):
                    bad.append(f"{vid}.guaranteed_safe")
            elif k == "exposure_basis":
                if not fs or fs[0]["exposure_basis"] != want:
                    bad.append(f"{vid}.exposure_basis")
            else:
                bad.append(f"{vid}.{k}=unhandled")
    ran_vectors["medication_safety_vectors.json"] = len(cat["vectors"])
    record("medication_safety_vectors", "FAIL" if bad else "PASS", f"{len(cat['vectors'])} vectors" + (f"; failing {bad}" if bad else ""))


# ---------------------------------------------------------------- 5. preventive
def day_number(iso: str) -> int:
    y, m, d = (int(x) for x in iso[:10].split("-"))
    return datetime.date(y, m, d).toordinal()


def add_days(iso: str, days: int) -> str:
    return datetime.date.fromordinal(day_number(iso) + int(days)).isoformat()


def assess_service(service_id: str, rules: list, inp: dict) -> dict:
    """PREVENTIVE-ENGINE-1: jurisdiction → pack status/conflict → eligibility → contraindication →
    recommendation mode → history quality → series/interval timing → due state."""
    for_service = [r for r in rules if r["service_id"] == service_id and r["pack_status"] != "RETIRED"]
    out = {
        "rule_id": None,
        "service_id": service_id,
        "service_label": for_service[0]["service_label"] if for_service else service_id,
        "pack": None,
        "jurisdiction": inp.get("jurisdiction"),
        "eligibility_state": "UNKNOWN",
        "recommendation_mode": None,
        "due_state": "NOT_APPLICABLE",
        "assessment_status": "ASSESSED",
        "next_due_date": None,
    }
    jur = inp.get("jurisdiction")
    if not jur:
        out["assessment_status"] = "NO_ACTIVE_PACK"
        return out
    in_jur = [r for r in for_service if r["jurisdiction"] == jur]
    if not in_jur:
        out["eligibility_state"] = out["assessment_status"] = "NOT_APPLICABLE_JURISDICTION"
        return out
    active = [r for r in in_jur if r["pack_status"] == "ACTIVE"]
    if not active:
        s = in_jur[0]
        out.update(rule_id=s["rule_id"], pack={"pack_id": s["pack_id"], "version": s["pack_version"]}, assessment_status="PACK_STALE")
        return out
    top = max(r["precedence"] for r in active)
    winners = [r for r in active if r["precedence"] == top]
    if len(winners) > 1 and len({(r["mode"], r["interval_days"], r["min_age"], r["max_age"]) for r in winners}) > 1:
        out["assessment_status"] = "PACK_CONFLICT"
        return out
    rule = winners[0]
    out.update(rule_id=rule["rule_id"], pack={"pack_id": rule["pack_id"], "version": rule["pack_version"]}, recommendation_mode=rule["mode"])
    age = inp.get("age_years")
    if age is None:
        out.update(eligibility_state="UNKNOWN", due_state="REVIEW_REQUIRED")
        return out
    age_ok = (rule["min_age"] is None or age >= rule["min_age"]) and (rule["max_age"] is None or age <= rule["max_age"])
    risk_ok = rule["requires_risk"] is None or rule["requires_risk"] in inp["risks"]
    anatomy_ok = rule["requires_anatomy"] is None or rule["requires_anatomy"] in inp["anatomy"]
    if not (age_ok and risk_ok and anatomy_ok):
        out["eligibility_state"] = "NOT_ELIGIBLE"
        return out
    out["eligibility_state"] = "ELIGIBLE"
    if inp["contraindicated"]:
        out.update(assessment_status="BLOCKED_CONTRAINDICATION", due_state="REVIEW_REQUIRED")
        return out
    if rule["mode"] == "SHARED_DECISION":
        out["due_state"] = "REVIEW_REQUIRED"
        return out
    if rule["mode"] in ("EVIDENCE_INSUFFICIENT", "AGAINST_ROUTINE"):
        out["due_state"] = "NOT_APPLICABLE"
        return out
    if inp["history"] == "UNKNOWN":  # unknown history is not "never done"
        out["due_state"] = "UNKNOWN_HISTORY"
        return out
    as_of = inp["as_of"]
    done = sorted(d for d in inp["completions"] if d <= as_of)
    series = rule.get("series")
    if series:
        if len(done) >= series["doses"]:
            out["due_state"] = "SERIES_COMPLETE"
        elif not done:
            out.update(due_state="DUE_NOW", next_due_date=as_of)
        else:
            earliest = add_days(done[-1], series["min_interval_days"])
            out.update(next_due_date=earliest, due_state="TOO_EARLY" if as_of < earliest else "DUE_NOW")
        return out
    if not done:
        out.update(due_state="DUE_NOW", next_due_date=as_of)
        return out
    if rule["interval_days"] is None:
        out["due_state"] = "UP_TO_DATE"
        return out
    nxt = add_days(done[-1], rule["interval_days"])
    until = day_number(nxt) - day_number(as_of)
    out["next_due_date"] = nxt
    if until > inp["due_soon_window_days"]:
        out["due_state"] = "UP_TO_DATE"
    elif until > 0:
        out["due_state"] = "DUE_SOON"
    elif until == 0:
        out["due_state"] = "DUE_NOW"
    else:
        out["due_state"] = "OVERDUE"
    return out


def check_preventive() -> None:
    cat = load("preventive_vectors.json")
    bad = []
    for v in cat["vectors"]:
        a = assess_service(v["service_id"], v["rules"] if v.get("rules") is not None else cat["rules"], v["input"])
        for k, want in v["expected"].items():
            if k not in a:
                bad.append(f"{v['vector_id']}.{k}=unhandled")
            elif a[k] != want:
                bad.append(f"{v['vector_id']}.{k}={a[k]}")
    ran_vectors["preventive_vectors.json"] = len(cat["vectors"])
    record("preventive_vectors", "FAIL" if bad else "PASS", f"{len(cat['vectors'])} vectors" + (f"; failing {bad}" if bad else ""))


def check_vector_total() -> None:
    """Every catalog in contracts/golden_vectors ran, every one of its vectors."""
    total, missing = 0, []
    for f in sorted(GV.glob("*.json")):
        n = len(json.loads(f.read_text())["vectors"])
        total += n
        if ran_vectors.get(f.name) != n:
            missing.append(f"{f.name} ran {ran_vectors.get(f.name, 0)}/{n}")
    ran = sum(ran_vectors.values())
    record("golden_vectors(total)", "FAIL" if missing else "PASS", f"{ran}/{total} vectors ran" + (f"; not run {missing}" if missing else ""))


# ---------------------------------------------------------------- 7. SQLite kernel
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


# ---------------------------------------------------------------- 8. identifiers
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
    master = (ROOT / "docs/handoff/v0.24/LONGEVITY_APP_MASTER_HANDOFF_v0.24.md").read_text()
    addendum = (ROOT / "docs/handoff/v0.25/MASTER_HANDOFF_v0.25_ADDENDUM.md").read_text()
    new_ids = re.findall(r"^\| ((?:FR|AT)-\d+)", addendum, flags=re.M)
    clashes = [i for i in new_ids if re.search(rf"\b{i}\b", master)]
    dup = sorted({i for i in new_ids if new_ids.count(i) > 1})
    bad = clashes + dup
    record("v0.25_canonical_id_integrity", "FAIL" if bad or not new_ids else "PASS", f"{len(new_ids)} new IDs" + (f"; collisions {bad}" if bad else ""))


# ---------------------------------------------------------------- 9. release outputs
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
    for fn in (check_core, check_lab, check_nutrition, check_medication, check_preventive, check_vector_total, check_sqlite, check_ids, check_new_canonical_ids, check_outputs):
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
