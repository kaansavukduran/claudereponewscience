#!/usr/bin/env python3
"""Self-audit for the canonical Human OS project state (v0.31 §31, §33, §34).

Checks that the state file is well formed, that every evidence path it cites
exists, that every verified gate is backed by a machine-written receipt from
the same source revision, that receipts are internally consistent, that the
master spec on disk matches the recorded hash, and that the roadmap carries
the v0.31 ladder. Exit 0 = consistent, 1 = problems (listed).

Usage: python3 tools/validate_project_state.py [repo_root]
"""
from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

DEV_STATES = {
    "UNINITIALIZED", "INITIALIZING", "READY", "FORGE_PLANNING", "IMPLEMENTING",
    "TESTING", "REPAIRING", "REGRESSION", "PACKAGING", "FORGE_COMPLETE",
    "BLOCKED_ENVIRONMENT", "BLOCKED_DECISION", "RECOVERY_REQUIRED",
    "ROLLBACK_REQUIRED", "RELEASE_CANDIDATE", "RELEASED",
}
FORGE_STATES = DEV_STATES | {"SPECIFIED", "IN_PROGRESS_RECOVERABLE", "DONE", "PARTIAL_BLOCKED"}
RECEIPT_FIELDS = {
    "evidence_id", "kind", "forge_id", "source_revision", "working_tree_dirty",
    "command", "cwd", "started_at", "finished_at", "exit_code", "result",
    "tool_versions", "log_sha256",
}
STATE_FIELDS = {
    "schema_version", "project", "product_version", "development_state",
    "active_forge", "last_completed_forge", "baseline", "verified_gates",
    "known_blockers", "next_recommended_forge", "updated_at",
}
PATH_RE = re.compile(r"^(reports|evidence|docs|project_state|tools|packaging)/[^\s#*<>…]+$")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


# Fields that describe planned work may name files that do not exist yet.
PLANNED_KEYS = {"next_action", "scope", "acceptance_criteria", "fix"}


def iter_strings(node):
    if isinstance(node, str):
        yield node
    elif isinstance(node, dict):
        for k, v in node.items():
            if k not in PLANNED_KEYS:
                yield from iter_strings(v)
    elif isinstance(node, list):
        for v in node:
            yield from iter_strings(v)


def load_receipts(root: Path) -> dict[str, tuple[Path, dict]]:
    receipts = {}
    for f in sorted((root / "evidence").rglob("*.json")):
        receipts[f.stem] = (f, json.loads(f.read_text()))
    return receipts


def check_receipt(path: Path, r: dict) -> list[str]:
    problems = []
    missing = RECEIPT_FIELDS - r.keys()
    if missing:
        problems.append(f"{path}: missing fields {sorted(missing)}")
        return problems
    if r["evidence_id"] != path.stem:
        problems.append(f"{path}: evidence_id {r['evidence_id']} != file name")
    expected = "PASS" if r["exit_code"] == r.get("expected_exit_code", 0) else "FAIL"
    if r["result"] != expected:
        problems.append(f"{path}: result {r['result']} contradicts exit_code {r['exit_code']}")
    if r["kind"] == "BUILD" and r["result"] == "PASS":
        for a in r.get("artifacts", []):
            if not re.fullmatch(r"[0-9a-f]{64}", a.get("sha256", "")):
                problems.append(f"{path}: build artifact without SHA-256: {a.get('path')}")
    return problems


BUILD_IDENTITY = ("target", "arch", "profile", "signing")


def gate_problems(root: Path, gate: dict, receipt: dict) -> list[str]:
    """Why a verified gate does not hold any more (empty list = it holds).

    A verified gate needs a PASS receipt recorded on a clean source tree
    (§33.1), must name the paths it covers, and goes stale when any covered
    path differs from the receipt's revision in the current working tree
    (§33.5). Build receipts must carry their §33.2 identity fields."""
    name = gate.get("gate") or gate.get("evidence_id")
    out = []
    if receipt.get("result") != "PASS":
        out.append(f"verified gate {name!r} cites non-PASS receipt {receipt.get('evidence_id')}")
    if receipt.get("working_tree_dirty"):
        out.append(f"verified gate {name!r}: receipt was recorded on a dirty source tree "
                   f"({receipt.get('dirty_source_paths', [])[:3]})")
    if gate.get("source_revision") and gate["source_revision"] != receipt.get("source_revision"):
        out.append(f"verified gate {name!r}: revision differs from its receipt")
    covers = receipt.get("covers") or gate.get("covers")
    if not covers:
        out.append(f"verified gate {name!r}: receipt names no covered paths (--covers), so staleness cannot be checked")
    else:
        rev = receipt.get("source_revision", "")
        diff = subprocess.run(["git", "diff", "--quiet", rev, "--", *covers], cwd=root)
        if diff.returncode == 1:
            changed = subprocess.run(["git", "diff", "--name-only", rev, "--", *covers], cwd=root,
                                     capture_output=True, text=True).stdout.split()
            out.append(f"verified gate {name!r} is STALE: covered paths changed since "
                       f"{rev[:12]}: {changed[:5]}")
        elif diff.returncode != 0:
            out.append(f"verified gate {name!r}: cannot diff against revision {rev[:12]}")
    if receipt.get("kind") == "BUILD":
        missing = [k for k in BUILD_IDENTITY if not receipt.get(k)]
        if missing:
            out.append(f"verified build gate {name!r}: receipt lacks §33.2 fields {missing}")
    return out


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    problems: list[str] = []
    state_path = root / "project_state" / "CURRENT_STATE.json"
    state = json.loads(state_path.read_text())

    missing = STATE_FIELDS - state.keys()
    if missing:
        problems.append(f"state: missing fields {sorted(missing)}")
    if state.get("development_state") not in DEV_STATES:
        problems.append(f"state: unknown development_state {state.get('development_state')!r}")
    for forge in [state.get("active_forge")] + list(state.get("suspended_forges", [])):
        if forge and forge.get("status") not in FORGE_STATES:
            problems.append(f"state: forge {forge.get('forge_id')} has unknown status {forge.get('status')!r}")

    # Every cited repository path exists (anchors and globs are ignored).
    for s in iter_strings(state):
        for token in re.split(r"[\s,;()]+", s):
            token = token.rstrip(".:")
            if PATH_RE.match(token):
                if not (root / token.split("#")[0]).exists():
                    problems.append(f"state cites a missing path: {token}")

    # Master spec hash.
    base = state.get("baseline", {})
    spec = base.get("master_spec")
    if spec:
        if not (root / spec).exists():
            problems.append(f"baseline.master_spec missing: {spec}")
        elif sha256(root / spec) != base.get("master_spec_sha256"):
            problems.append("baseline.master_spec_sha256 does not match the file on disk")

    receipts = load_receipts(root)
    for path, r in receipts.values():
        problems += check_receipt(path, r)

    # Verified gates: PASS, clean tree, declared coverage, not stale.
    for g in state.get("verified_gates", []):
        rid = g.get("evidence_id")
        if rid not in receipts:
            problems.append(f"verified gate {g.get('gate')!r} cites unknown receipt {rid}")
            continue
        problems += gate_problems(root, g, receipts[rid][1])

    active = state.get("active_forge") or {}
    for rid in active.get("evidence_ids", []):
        if rid not in receipts:
            problems.append(f"active forge cites unknown receipt {rid}")

    # Hosts we cannot build on must not be claimed built.
    for name, t in (state.get("targets") or {}).items():
        status = str(t.get("status", "")) if isinstance(t, dict) else str(t)
        if name in {"ios", "macos", "windows_portable", "windows_installer", "android"}:
            if any(w in status for w in ("COMPILED", "RUNTIME_TESTED", "PACKAGED", "PASS")):
                problems.append(f"target {name} claims {status} on a host that cannot build it")

    roadmap = (root / "docs" / "ROADMAP.md").read_text()
    for n in range(1, 18):
        if f"| **F{n:03d}**" not in roadmap and f"| F{n:03d} |" not in roadmap:
            problems.append(f"ROADMAP lacks ladder row F{n:03d}")

    if problems:
        print("FAIL: project state is inconsistent")
        for p in problems:
            print(f"  - {p}")
        return 1
    print(f"PASS: project state consistent ({len(receipts)} receipts, "
          f"{len(state.get('verified_gates', []))} verified gates)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
