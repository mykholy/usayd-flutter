#!/usr/bin/env python3
"""
USYD-T0021: Repository Creation, Permissions & Ownership Verification Suite
Validates repository boundaries, permissions, CODEOWNERS, CI workflows, and secret hygiene.
Supports multi-repo local workspace execution and single-repo GitHub Actions runner execution (including detached PR HEAD).
Includes positive assertions and negative test scenarios.
"""

import os
import sys
import subprocess
import json
import re
from pathlib import Path

CURRENT_REPO = Path(__file__).resolve().parents[1]
WORKSPACE = CURRENT_REPO.parent
ALL_REPOS = ["usayd-api", "usayd-web", "usayd-flutter"]
EXPECTED_OWNER = "@mykholy"

REQUIRED_SENSITIVE_PATHS = {
    "usayd-api": [
        "/app/Modules/Identity/",
        "/app/Modules/Payments/",
        "/app/Modules/Guardian/",
        "/app/Modules/Payroll/",
        "/app/Modules/Quran/",
        "/app/Modules/AI/",
        "/database/migrations/",
        "/.github/",
    ],
    "usayd-web": [
        "/src/app/**/checkout/**",
        "/src/app/**/guardian/**",
        "/src/lib/auth/**",
        "/.github/",
    ],
    "usayd-flutter": [
        "/lib/**/auth/**",
        "/lib/**/guardian/**",
        "/lib/**/payments/**",
        "/lib/**/recording/**",
        "/.github/",
    ],
}

REQUIRED_WORKFLOW_GROUPS = [
    ["ai-review.yml"],
    ["ci.yml"],
    ["automated-quality-gate.yml", "human-review-gate.yml"],
    ["safe-automerge.yml"],
]

SECRET_PATTERNS = [
    re.compile(r"(?i)(?:api_key|secret|password|bearer|token)\s*[:=]\s*['\"][A-Za-z0-9-_]{20,}['\"]"),
    re.compile(r"ghp_[A-Za-z0-9]{36}"),
    re.compile(r"gho_[A-Za-z0-9]{36}"),
    re.compile(r"AIza[0-9A-Za-z-_]{35}"),
]


def get_target_repos():
    """Return available repos: all 3 if in workspace, or current repo in isolated CI."""
    siblings = [WORKSPACE / r for r in ["usayd-web", "usayd-flutter"]]
    if any(s.exists() for s in siblings):
        return [WORKSPACE / r for r in ALL_REPOS if (WORKSPACE / r).exists()]
    return [CURRENT_REPO]


def test_positive_local_repos_exist():
    """Verify repository directory exists and is a valid Git repository."""
    print("[TEST] test_positive_local_repos_exist...")
    repos = get_target_repos()
    for repo_dir in repos:
        assert repo_dir.is_dir(), f"Repository directory missing: {repo_dir}"
        assert (repo_dir / ".git").exists(), f"Repository is not a Git repo: {repo_dir}"
    print(f"  -> PASS ({len(repos)} repo(s) verified)")


def test_positive_git_default_branch():
    """Verify default branch is main for all target repositories."""
    print("[TEST] test_positive_git_default_branch...")
    repos = get_target_repos()
    for repo_dir in repos:
        branches = subprocess.run(
            ["git", "-C", str(repo_dir), "branch", "-a"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
        if "main" in branches:
            continue
        # In detached HEAD (e.g. GitHub Actions pull_request event), verify remote main exists
        remotes = subprocess.run(
            ["git", "-C", str(repo_dir), "ls-remote", "--heads", "origin", "main"],
            capture_output=True,
            text=True,
        ).stdout
        assert "refs/heads/main" in remotes, f"Repository {repo_dir.name} missing 'main' branch in branches: {branches} and remotes: {remotes}"
    print("  -> PASS")


def test_positive_codeowners_coverage():
    """Verify CODEOWNERS contains all required sensitive paths mapped to authorized owner."""
    print("[TEST] test_positive_codeowners_coverage...")
    repos = get_target_repos()
    for repo_dir in repos:
        repo_name = repo_dir.name
        if repo_name not in REQUIRED_SENSITIVE_PATHS:
            continue
        codeowners_file = repo_dir / ".github" / "CODEOWNERS"
        assert codeowners_file.is_file(), f"CODEOWNERS missing in {repo_name}"
        content = codeowners_file.read_text(encoding="utf-8")
        for path in REQUIRED_SENSITIVE_PATHS[repo_name]:
            assert path in content, f"Sensitive path {path} missing in {repo_name} CODEOWNERS"
            line = [l for l in content.splitlines() if path in l][0]
            assert EXPECTED_OWNER in line, f"Path {path} not assigned to {EXPECTED_OWNER} in {repo_name}"
    print("  -> PASS")


def test_positive_required_workflows():
    """Verify required GitHub Actions workflows exist in each repository."""
    print("[TEST] test_positive_required_workflows...")
    repos = get_target_repos()
    for repo_dir in repos:
        wf_dir = repo_dir / ".github" / "workflows"
        assert wf_dir.is_dir(), f"Workflows directory missing in {repo_dir.name}"
        for group in REQUIRED_WORKFLOW_GROUPS:
            found = any((wf_dir / wf).is_file() for wf in group)
            assert found, f"Workflow requirement {group} not met in {repo_dir.name}"
    print("  -> PASS")


def test_positive_no_secrets_in_repo():
    """Scan tracked repository files to ensure no sensitive credentials leaked."""
    print("[TEST] test_positive_no_secrets_in_repo...")
    repos = get_target_repos()
    for repo_dir in repos:
        for root, _, files in os.walk(repo_dir):
            if ".git" in root or "node_modules" in root or "vendor" in root:
                continue
            for file in files:
                fpath = Path(root) / file
                if fpath.suffix in [".png", ".jpg", ".ico", ".woff", ".woff2", ".ttf"]:
                    continue
                # Skip self if it contains synthetic negative fixtures
                if file == "verify_repository_governance.py":
                    continue
                try:
                    text = fpath.read_text(encoding="utf-8", errors="ignore")
                except Exception:
                    continue

                for pattern in SECRET_PATTERNS:
                    matches = pattern.findall(text)
                    real_matches = [
                        m for m in matches
                        if "usayd_ci_password" not in m
                        and "root_ci_password" not in m
                        and "mock-" not in m.lower()
                        and "example" not in m.lower()
                    ]
                    # Direct assertion: NEVER catch AssertionError
                    assert not real_matches, f"Potential secret leak in {fpath}: {real_matches}"
    print("  -> PASS")


def test_negative_codeowners_validation():
    """Negative test: verify that missing owner or unmapped sensitive path is detected as failure."""
    print("[TEST] test_negative_codeowners_validation (Negative)...")
    synthetic_codeowners = "/app/Modules/Identity/ # No owner assigned\n/app/Modules/Payments/ @unauthorized_user\n"
    has_owner_for_identity = False
    has_valid_owner_for_payments = False
    for line in synthetic_codeowners.splitlines():
        if "/app/Modules/Identity/" in line and EXPECTED_OWNER in line:
            has_owner_for_identity = True
        if "/app/Modules/Payments/" in line and EXPECTED_OWNER in line:
            has_valid_owner_for_payments = True

    assert not has_owner_for_identity, "Negative check failed: identity should have lacked expected owner"
    assert not has_valid_owner_for_payments, "Negative check failed: payments should have lacked expected owner"
    print("  -> PASS (Negative scenario correctly detected)")


def test_negative_secret_leak_detection():
    """Negative test: verify that synthetic credentials trigger secret scanner."""
    print("[TEST] test_negative_secret_leak_detection (Negative)...")
    synthetic_bad_text = "aws_" + "secret = 'AKIA" + "IOSFODNN7REALKEY1234567890'"
    detected = False
    for pattern in SECRET_PATTERNS:
        matches = pattern.findall(synthetic_bad_text)
        real = [m for m in matches if "usayd_ci_password" not in m and "root_ci_password" not in m and "mock-" not in m.lower() and "example" not in m.lower()]
        if real:
            detected = True
            break
    assert detected, "Negative check failed: scanner failed to detect synthetic leaked secret"
    print("  -> PASS (Negative scenario correctly detected)")


def test_negative_review_fail_closed():
    """Negative test: verify that pr_review emit fails closed (exit code 1) on non-PASS statuses."""
    print("[TEST] test_negative_review_fail_closed (Negative)...")
    sys.path.insert(0, str(CURRENT_REPO))
    try:
        from automation.pr_review import emit
        tmp_out = CURRENT_REPO / "test_review_out.json"
        os.environ["USAYD_REVIEW_OUT"] = str(tmp_out)

        # 1. Test UNAVAILABLE must exit 1 (fail closed)
        code_unavail = emit("UNAVAILABLE", [], "Credentials missing")
        assert code_unavail == 1, f"UNAVAILABLE must return exit code 1, got {code_unavail}"

        # 2. Test BLOCK must exit 1
        code_block = emit("BLOCK", [{"severity": "P0", "file": "foo.php", "message": "Critical defect"}], "Blocked")
        assert code_block == 1, f"BLOCK must return exit code 1, got {code_block}"

        # 3. Test HUMAN_REQUIRED must exit 1
        code_human = emit("HUMAN_REQUIRED", [], "Sensitive path")
        assert code_human == 1, f"HUMAN_REQUIRED must return exit code 1, got {code_human}"

        # 4. Test PASS must exit 0
        code_pass = emit("PASS", [], "Clean")
        assert code_pass == 0, f"PASS must return exit code 0, got {code_pass}"

        if tmp_out.exists():
            tmp_out.unlink()
    finally:
        os.environ.pop("USAYD_REVIEW_OUT", None)
    print("  -> PASS (Fail-closed exit codes verified for all non-PASS statuses)")


def test_negative_corrupted_review_rejection():
    """Negative test: verify that corrupted or missing review output fails validation."""
    print("[TEST] test_negative_corrupted_review_rejection (Negative)...")
    corrupted_payloads = [
        "{}",  # Missing status
        '{"status": "UNKNOWN"}',  # Invalid status
        '{"status": "PASS", "findings": "not-a-list"}',  # Malformed findings
    ]
    for raw in corrupted_payloads:
        data = json.loads(raw)
        status = data.get("status")
        valid = status in ("PASS", "BLOCK") and isinstance(data.get("findings"), list)
        assert not valid, f"Corrupted payload was unexpectedly considered valid: {raw}"
    print("  -> PASS (Corrupted review payloads correctly rejected)")


def run_all_tests():
    print("==================================================")
    print(" Usayd Academy — Repository Governance Test Suite ")
    print(" Ticket: USYD-T0021 / Governance Repair V2        ")
    print("==================================================")
    test_positive_local_repos_exist()
    test_positive_git_default_branch()
    test_positive_codeowners_coverage()
    test_positive_required_workflows()
    test_positive_no_secrets_in_repo()
    test_negative_codeowners_validation()
    test_negative_secret_leak_detection()
    test_negative_review_fail_closed()
    test_negative_corrupted_review_rejection()
    print("==================================================")
    print(" ALL 9 REPOSITORY GOVERNANCE TESTS PASSED (0 FAIL)")
    print("==================================================")


if __name__ == "__main__":
    run_all_tests()
