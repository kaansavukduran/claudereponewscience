#!/usr/bin/env python3
"""Repository checks for v0.31 F001 acceptance criteria AC-1 and AC-8.

AC-1: human_health_os/ is a Flutter project with all six platform folders
      and a committed pubspec.lock.
AC-8: since the F001 baseline commit, nothing changed in the domain layer,
      the data tests, the integration test or the lockfile; changes under
      lib/src/data are limited to user-visible notice text that cites Forge
      ids (legacy "FORGE 004" -> v0.31 "Forge F006").

Usage: python3 tools/evidence/check_f001_scope.py <baseline-commit>
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

APP = Path("human_health_os")
PLATFORMS = ("android", "ios", "web", "windows", "macos", "linux")
FROZEN = ("lib/src/domain", "test/data", "integration_test", "pubspec.lock")


def git(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["git", *args], capture_output=True, text=True)


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    base = sys.argv[1]
    failures = []

    missing = [p for p in PLATFORMS if not (APP / p).is_dir()]
    if missing:
        failures.append(f"AC-1: missing platform folders {missing}")
    if git("ls-files", "--error-unmatch", str(APP / "pubspec.lock")).returncode != 0:
        failures.append("AC-1: pubspec.lock is not committed")

    frozen_paths = [str(APP / p) for p in FROZEN]
    if git("diff", "--quiet", base, "HEAD", "--", *frozen_paths).returncode != 0:
        changed = git("diff", "--name-only", base, "HEAD", "--", *frozen_paths).stdout.split()
        failures.append(f"AC-8: frozen paths changed: {changed}")
    data_diff = git("diff", "-U0", base, "HEAD", "--", str(APP / "lib/src/data")).stdout.splitlines()
    edits = [l for l in data_diff if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    other = [l for l in edits if "FORGE 004" not in l and "Forge F006" not in l]
    if other:
        failures.append(f"AC-8: {len(other)} lib/src/data line(s) beyond notice text, e.g. {other[0][:120]!r}")

    if failures:
        for f in failures:
            print(f"FAIL {f}")
        return 1
    print(f"PASS AC-1: platform folders {' '.join(PLATFORMS)} present; pubspec.lock committed")
    print(f"PASS AC-8: since {base}: frozen paths unchanged; lib/src/data edits = {len(edits)} notice-text lines")
    return 0


if __name__ == "__main__":
    sys.exit(main())
