"""Tests for run_gate.py: results come from exit codes, receipts are
immutable, artifacts are hashed, missing artifacts fail the gate.

Run: python3 -m unittest tools/evidence/test_run_gate.py
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("run_gate.py")
ROOT = Path(subprocess.run(["git", "rev-parse", "--show-toplevel"], cwd=SCRIPT.parent,
                           capture_output=True, text=True, check=True).stdout.strip())


def run_gate(ev_root: str, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run([sys.executable, str(SCRIPT), "--evidence-root", ev_root, *args],
                          cwd=ROOT, capture_output=True, text=True)


class RunGateTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.ev = self.tmp.name

    def tearDown(self):
        self.tmp.cleanup()

    def receipt(self, kind_dir: str, eid: str) -> dict:
        return json.loads(Path(self.ev, kind_dir, f"{eid}.json").read_text())

    def test_pass_receipt_is_derived_from_exit_code(self):
        p = run_gate(self.ev, "--id", "EV-TEST-1", "--kind", "TEST", "--forge", "F001",
                     "--summary", "hello", "--", "sh", "-c", "echo hello world")
        self.assertEqual(p.returncode, 0, p.stderr)
        r = self.receipt("tests", "EV-TEST-1")
        self.assertEqual((r["result"], r["exit_code"]), ("PASS", 0))
        self.assertEqual(r["summary"], "hello world")
        self.assertEqual(r["source_revision"], subprocess.run(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip())
        log = Path(self.ev, "logs", "EV-TEST-1.log").read_bytes()
        self.assertEqual(r["log_sha256"], hashlib.sha256(log).hexdigest())
        self.assertLessEqual(r["started_at"], r["finished_at"])

    def test_failing_command_gives_fail(self):
        p = run_gate(self.ev, "--id", "EV-TEST-2", "--kind", "TEST", "--forge", "F001", "--", "false")
        self.assertEqual(p.returncode, 1)
        r = self.receipt("tests", "EV-TEST-2")
        self.assertEqual(r["result"], "FAIL")
        self.assertNotEqual(r["exit_code"], 0)

    def test_receipts_are_never_overwritten(self):
        run_gate(self.ev, "--id", "EV-TEST-3", "--kind", "TEST", "--forge", "F001", "--", "true")
        before = Path(self.ev, "tests", "EV-TEST-3.json").read_text()
        p = run_gate(self.ev, "--id", "EV-TEST-3", "--kind", "TEST", "--forge", "F001", "--", "false")
        self.assertEqual(p.returncode, 2)
        self.assertEqual(Path(self.ev, "tests", "EV-TEST-3.json").read_text(), before)

    def test_missing_artifact_fails_a_zero_exit_build(self):
        p = run_gate(self.ev, "--id", "EV-BUILD-1", "--kind", "BUILD", "--forge", "F001",
                     "--artifact", "does/not/exist", "--", "true")
        self.assertEqual(p.returncode, 1)
        r = self.receipt("builds", "EV-BUILD-1")
        self.assertEqual(r["result"], "FAIL")
        self.assertEqual(r["artifacts"][0]["type"], "missing")

    def test_directory_digest_ignores_timestamps(self):
        with tempfile.TemporaryDirectory(dir=ROOT / "evidence" if (ROOT / "evidence").exists() else ROOT) as d:
            Path(d, "a.txt").write_text("A")
            Path(d, "sub").mkdir()
            Path(d, "sub", "b.txt").write_text("B")
            rel = os.path.relpath(d, ROOT)
            run_gate(self.ev, "--id", "EV-BUILD-2", "--kind", "BUILD", "--forge", "F001", "--artifact", rel, "--", "true")
            time.sleep(1.1)
            os.utime(Path(d, "a.txt"))
            run_gate(self.ev, "--id", "EV-BUILD-3", "--kind", "BUILD", "--forge", "F001", "--artifact", rel, "--", "true")
            a = self.receipt("builds", "EV-BUILD-2")["artifacts"][0]
            b = self.receipt("builds", "EV-BUILD-3")["artifacts"][0]
            self.assertEqual(a["sha256"], b["sha256"])
            self.assertEqual((a["files"], a["bytes"]), (2, 2))
            Path(d, "a.txt").write_text("changed")
            run_gate(self.ev, "--id", "EV-BUILD-4", "--kind", "BUILD", "--forge", "F001", "--artifact", rel, "--", "true")
            self.assertNotEqual(self.receipt("builds", "EV-BUILD-4")["artifacts"][0]["sha256"], a["sha256"])

    def test_covers_build_identity_and_both_lockfiles_are_recorded(self):
        p = run_gate(self.ev, "--id", "EV-BUILD-5", "--kind", "BUILD", "--forge", "F001@v0.32",
                     "--covers", "tools/evidence", "--covers", "human_health_os/pubspec.lock",
                     "--target", "web", "--arch", "js", "--profile", "development",
                     "--signing", "NOT_APPLICABLE", "--smoke-evidence", "EV-RUNTIME-X", "--", "true")
        self.assertEqual(p.returncode, 0, p.stderr)
        r = self.receipt("builds", "EV-BUILD-5")
        self.assertEqual(r["receipt_schema"], 2)
        self.assertEqual(r["forge_id"], "F001@v0.32")
        self.assertEqual(r["covers"], ["tools/evidence", "human_health_os/pubspec.lock"])
        self.assertEqual((r["target"], r["arch"], r["profile"], r["signing"], r["smoke_evidence"]),
                         ("web", "js", "development", "NOT_APPLICABLE", "EV-RUNTIME-X"))
        self.assertIn("human_health_os/pubspec.lock", r["lockfiles"])
        self.assertIn("pnpm-lock.yaml", r["lockfiles"])

    def test_nonexistent_covers_path_is_rejected_before_running(self):
        marker = Path(self.ev, "ran.marker")
        p = run_gate(self.ev, "--id", "EV-TEST-6", "--kind", "TEST", "--forge", "F001",
                     "--covers", "no/such/path", "--", "touch", str(marker))
        self.assertEqual(p.returncode, 2)
        self.assertFalse(marker.exists(), "the gate command must not run")
        self.assertFalse(Path(self.ev, "tests", "EV-TEST-6.json").exists())
        self.assertFalse(Path(self.ev, "logs", "EV-TEST-6.log").exists())

    def test_command_is_recorded_shell_quoted(self):
        run_gate(self.ev, "--id", "EV-TEST-7", "--kind", "TEST", "--forge", "F001",
                 "--", "sh", "-c", "echo 'a b'")
        r = self.receipt("tests", "EV-TEST-7")
        self.assertEqual(r["argv"], ["sh", "-c", "echo 'a b'"])
        self.assertEqual(r["command"], "sh -c 'echo '\"'\"'a b'\"'\"''")

    def test_bad_id_is_rejected(self):
        p = run_gate(self.ev, "--id", "test1", "--kind", "TEST", "--forge", "F001", "--", "true")
        self.assertEqual(p.returncode, 2)


if __name__ == "__main__":
    unittest.main()
