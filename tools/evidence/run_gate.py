#!/usr/bin/env python3
"""Run one validation gate and write an evidence receipt (v0.31 §33).

The receipt is produced by this script from what actually happened: real
start/finish timestamps, the real exit code, the exact command, the git
revision and dirty state, toolchain versions and the SHA-256 of the full log.
PASS/FAIL is derived from the exit code, never typed in by hand. Receipts are
immutable: an existing evidence id is never overwritten.

Usage:
  python3 tools/evidence/run_gate.py --id EV-TEST-0001 --kind TEST --forge F001@v0.32 \
      [--cwd human_health_os] [--covers PATH ...] [--artifact PATH ...] [--summary REGEX] \
      [--target web --arch js --profile development --signing NOT_APPLICABLE \
       --smoke-evidence EV-RUNTIME-...]  -- CMD ARGS...

--covers names the source paths whose content this evidence depends on; a
later change to any of them makes the evidence stale (master §33.5), which
tools/validate_project_state.py checks. Build receipts carry the §33.2
identity fields (target, architecture, profile, signing, smoke evidence).

Exit status: 0 when the gate passed, 1 when it failed, 2 on usage errors.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

KIND_DIRS = {"TEST": "tests", "BUILD": "builds", "RUNTIME": "runtime"}
# Paths that gates themselves write; they do not make the *source* dirty.
EVIDENCE_PATHS = ("evidence/", "reports/")
LOCKFILE = Path("human_health_os/pubspec.lock")
LOCKFILES = (LOCKFILE, Path("pnpm-lock.yaml"))
RECEIPT_SCHEMA = 2


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def git(root: Path, *args: str) -> str:
    return subprocess.run(["git", *args], cwd=root, capture_output=True, text=True, check=True).stdout


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def describe_artifact(path: Path) -> dict:
    """File: SHA-256 of its bytes. Directory: SHA-256 over sorted
    "<relative path> <file sha256>" lines, so the digest depends only on
    file names and contents, not on timestamps or archive settings."""
    if path.is_file():
        return {"path": str(path), "type": "file", "bytes": path.stat().st_size, "sha256": sha256_file(path)}
    if path.is_dir():
        lines, total, count = [], 0, 0
        for f in sorted(p for p in path.rglob("*") if p.is_file()):
            lines.append(f"{f.relative_to(path).as_posix()} {sha256_file(f)}\n")
            total += f.stat().st_size
            count += 1
        return {
            "path": str(path), "type": "directory", "files": count, "bytes": total,
            "sha256": hashlib.sha256("".join(lines).encode()).hexdigest(),
            "digest_method": "sha256 of sorted '<relpath> <sha256>' lines",
        }
    return {"path": str(path), "type": "missing", "sha256": None}


def tool_versions(root: Path) -> dict:
    versions: dict[str, str] = {}
    try:
        out = subprocess.run(["flutter", "--version", "--machine"], cwd=root, capture_output=True,
                             text=True, timeout=120).stdout
        data = json.loads(out[out.index("{"):])
        versions["flutter"] = data.get("frameworkVersion", "unknown")
        versions["dart"] = data.get("dartSdkVersion", "unknown")
        versions["flutter_engine"] = data.get("engineRevision", "unknown")
    except Exception:  # noqa: BLE001 - absence is recorded, not guessed
        versions["flutter"] = versions["dart"] = "UNAVAILABLE"
    for name, cmd in (("node", ["node", "--version"]), ("python", [sys.executable, "--version"])):
        try:
            versions[name] = subprocess.run(cmd, capture_output=True, text=True, timeout=30).stdout.strip()
        except Exception:  # noqa: BLE001
            versions[name] = "UNAVAILABLE"
    return versions


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--id", required=True, help="evidence id, e.g. EV-TEST-0001")
    ap.add_argument("--kind", required=True, choices=sorted(KIND_DIRS))
    ap.add_argument("--forge", required=True)
    ap.add_argument("--cwd", default=".", help="working directory relative to the repository root")
    ap.add_argument("--artifact", action="append", default=[], help="file or directory to hash after the run")
    ap.add_argument("--summary", help="regex; the last matching log line becomes the summary")
    ap.add_argument("--expect-exit", type=int, default=0)
    ap.add_argument("--evidence-root", default="evidence", help="receipt root (tests use a temp dir)")
    ap.add_argument("--covers", action="append", default=[],
                    help="source path this evidence depends on (repeatable; §33.5)")
    ap.add_argument("--target", help="build/runtime target platform, e.g. web, linux")
    ap.add_argument("--arch", help="architecture, e.g. x86_64, js")
    ap.add_argument("--profile", help="build profile: development, staging or production")
    ap.add_argument("--signing", help="signing state, e.g. UNSIGNED, NOT_APPLICABLE")
    ap.add_argument("--smoke-evidence", help="evidence id of the runtime smoke of this build")
    ap.add_argument("cmd", nargs=argparse.REMAINDER)
    args = ap.parse_args()
    cmd = args.cmd[1:] if args.cmd[:1] == ["--"] else args.cmd
    if not cmd:
        ap.error("missing command after --")
    if not re.fullmatch(r"EV-[A-Z0-9]+(-[A-Z0-9]+)*", args.id):
        ap.error("evidence id must look like EV-TEST-0001")

    root = Path(git(Path.cwd(), "rev-parse", "--show-toplevel").strip())
    ev_root = (root / args.evidence_root) if not os.path.isabs(args.evidence_root) else Path(args.evidence_root)
    receipt_path = ev_root / KIND_DIRS[args.kind] / f"{args.id}.json"
    if receipt_path.exists():
        print(f"refusing to overwrite existing receipt {receipt_path}", file=sys.stderr)
        return 2
    log_path = ev_root / "logs" / f"{args.id}.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    receipt_path.parent.mkdir(parents=True, exist_ok=True)

    revision = git(root, "rev-parse", "HEAD").strip()
    changed = [line[3:] for line in git(root, "status", "--porcelain").splitlines()]
    source_changes = [p for p in changed if not p.startswith(EVIDENCE_PATHS)]
    versions = tool_versions(root)

    # Validate --covers before running anything (audit EH-9).
    missing_covers = [c for c in args.covers if not (root / c).exists()]
    if missing_covers:
        ap.error(f"--covers paths do not exist: {missing_covers}")

    started = now()
    with log_path.open("wb") as log:
        proc = subprocess.run(cmd, cwd=root / args.cwd, stdout=log, stderr=subprocess.STDOUT)
    finished = now()

    text = log_path.read_text(errors="replace").splitlines()
    summary = None
    if args.summary:
        matches = [line for line in text if re.search(args.summary, line)]
        summary = matches[-1].strip() if matches else None
    receipt = {
        "receipt_schema": RECEIPT_SCHEMA,
        "evidence_id": args.id,
        "kind": args.kind,
        "forge_id": args.forge,
        "source_revision": revision,
        "working_tree_dirty": bool(source_changes),
        "dirty_source_paths": source_changes[:20],
        # Shell-quoted, so the recorded command reproduces exactly (EH-8).
        "command": shlex.join(cmd),
        "argv": cmd,
        "cwd": args.cwd,
        "started_at": started,
        "finished_at": finished,
        "exit_code": proc.returncode,
        "expected_exit_code": args.expect_exit,
        "result": "PASS" if proc.returncode == args.expect_exit else "FAIL",
        "tool_versions": versions,
        "host": f"{os.uname().sysname} {os.uname().release} {os.uname().machine}",
        "summary": summary,
        "log_sha256": sha256_file(log_path),
        "log_lines": len(text),
        "log_tail": [line[:240] for line in text[-12:]],
    }
    if (root / LOCKFILE).exists():
        receipt["lockfile_sha256"] = sha256_file(root / LOCKFILE)
    receipt["lockfiles"] = {str(p): sha256_file(root / p) for p in LOCKFILES if (root / p).exists()}
    if args.covers:
        receipt["covers"] = args.covers
    for key in ("target", "arch", "profile", "signing", "smoke_evidence"):
        value = getattr(args, key)
        if value:
            receipt[key] = value
    if args.artifact:
        receipt["artifacts"] = [describe_artifact(root / a) for a in args.artifact]
        if receipt["result"] == "PASS" and any(a["sha256"] is None for a in receipt["artifacts"]):
            receipt["result"] = "FAIL"
            receipt["failure_reason"] = "declared artifact missing after the command"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
    shown = receipt_path.relative_to(root) if receipt_path.is_relative_to(root) else receipt_path
    print(f"{receipt['result']}  {args.id}  exit={proc.returncode}  {shown}"
          + (f"  [{summary}]" if summary else ""))
    return 0 if receipt["result"] == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
