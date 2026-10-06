"""Tests for the verified-gate rules in validate_project_state.py:
clean PASS receipts hold; stale, dirty, uncovered or identity-less build
receipts do not.

Run: python3 -m unittest tools/test_validate_project_state.py
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from validate_project_state import gate_problems  # noqa: E402


def git(repo: Path, *args: str) -> str:
    return subprocess.run(["git", *args], cwd=repo, check=True, capture_output=True, text=True,
                          env={"GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@t", "GIT_COMMITTER_NAME": "t",
                               "GIT_COMMITTER_EMAIL": "t@t", "PATH": "/usr/bin:/bin"}).stdout.strip()


class GateProblemsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.repo = Path(self.tmp.name)
        git(self.repo, "init", "-q")
        (self.repo / "app").mkdir()
        (self.repo / "app" / "main.dart").write_text("v1\n")
        (self.repo / "other.txt").write_text("x\n")
        git(self.repo, "add", "-A")
        git(self.repo, "commit", "-q", "-m", "c1")
        self.rev = git(self.repo, "rev-parse", "HEAD")

    def tearDown(self):
        self.tmp.cleanup()

    def receipt(self, **over):
        r = {"evidence_id": "EV-TEST-1", "kind": "TEST", "result": "PASS", "source_revision": self.rev,
             "working_tree_dirty": False, "covers": ["app"]}
        r.update(over)
        return r

    def test_clean_pass_receipt_holds(self):
        self.assertEqual(gate_problems(self.repo, {"gate": "g"}, self.receipt()), [])

    def test_unrelated_change_does_not_invalidate(self):
        (self.repo / "other.txt").write_text("y\n")
        git(self.repo, "commit", "-qam", "c2")
        self.assertEqual(gate_problems(self.repo, {"gate": "g"}, self.receipt()), [])

    def test_committed_change_to_covered_path_makes_it_stale(self):
        (self.repo / "app" / "main.dart").write_text("v2\n")
        git(self.repo, "commit", "-qam", "c2")
        problems = gate_problems(self.repo, {"gate": "g"}, self.receipt())
        self.assertTrue(any("STALE" in p and "app/main.dart" in p for p in problems), problems)

    def test_uncommitted_change_to_covered_path_makes_it_stale(self):
        (self.repo / "app" / "main.dart").write_text("edited\n")
        self.assertTrue(any("STALE" in p for p in gate_problems(self.repo, {"gate": "g"}, self.receipt())))

    def test_dirty_receipt_and_missing_covers_and_fail_are_rejected(self):
        self.assertTrue(any("dirty" in p for p in gate_problems(
            self.repo, {"gate": "g"}, self.receipt(working_tree_dirty=True, dirty_source_paths=["app/x"]))))
        self.assertTrue(any("no covered paths" in p for p in gate_problems(
            self.repo, {"gate": "g"}, self.receipt(covers=None))))
        self.assertTrue(any("non-PASS" in p for p in gate_problems(
            self.repo, {"gate": "g"}, self.receipt(result="FAIL"))))

    def test_build_receipt_needs_identity_fields(self):
        problems = gate_problems(self.repo, {"gate": "b"}, self.receipt(kind="BUILD"))
        self.assertTrue(any("§33.2" in p for p in problems), problems)
        ok = self.receipt(kind="BUILD", target="web", arch="js", profile="development", signing="NOT_APPLICABLE")
        self.assertEqual(gate_problems(self.repo, {"gate": "b"}, ok), [])


if __name__ == "__main__":
    unittest.main()
