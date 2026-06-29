#!/usr/bin/env bash
set -euo pipefail
# ─────────────────────────────────────────────────────
# smoke_tests.sh — Validate the lab environment
# Run before starting or submitting a PR
# ─────────────────────────────────────────────────────

LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

green() { echo -e "\033[0;32m$1\033[0m"; }
red()   { echo -e "\033[0;31m$1\033[0m"; }

check() {
  if eval "$1"; then
    green "[PASS] $2"
    ((PASS++))
  else
    red "[FAIL] $2"
    ((FAIL++))
  fi
}

echo "╔══════════════════════════════════════════════╗"
echo "║  Nmap Mastery — Smoke Tests                  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── File existence checks ────────────────────────────
check "test -f '${LAB_DIR}/lab.yaml'"              "lab.yaml exists"
check "test -f '${LAB_DIR}/objectives.yaml'"        "objectives.yaml exists"
check "test -f '${LAB_DIR}/lab.md'"                   "lab.md exists"
check "test -f '${LAB_DIR}/walkthrough.md'"            "walkthrough.md exists"

# ── Infrastructure files ─────────────────────────────
check "test -f '${LAB_DIR}/infrastructure/cloud-init/99-ansible.sh'" \
    "cloud-init playbook"
check "test -f '${LAB_DIR}/infrastructure/ansible/playbook.yml'" \
    "ansible playbook"
check "test -f '${LAB_DIR}/infrastructure/terraform/main.tf'" \
    "terraform main"

# ── Scripts are executable ───────────────────────────
check "test -x '${LAB_DIR}/scripts/setup.sh'"        "setup.sh is executable"
check "test -x '${LAB_DIR}/scripts/reset.sh'"        "reset.sh is executable"
check "test -x '${LAB_DIR}/scripts/validate.sh'"     "validate.sh is executable"

# ── Vulnerable app has Dockerfile ────────────────────
check "test -f '${LAB_DIR}/files/vulnerable_app/Dockerfile'" \
    "Dockerfile exists"
check "test -f '${LAB_DIR}/files/vulnerable_app/docker-entrypoint.sh'" \
    "entrypoint script exists"

# ── Hint files (9 expected) ──────────────────────────
for i in {1..9}; do
  check "test -f '${LAB_DIR}/files/hints/hint${i}.txt'" \
        "hint${i}.txt exists"
done

# ── YAML syntax validation ───────────────────────────
check "python3 -c 'import yaml; yaml.safe_load(open(\"${LAB_DIR}/lab.yaml\"))'" \
    "lab.yaml is valid YAML"
check "python3 -c 'import yaml; yaml.safe_load(open(\"${LAB_DIR}/objectives.yaml\"))'" \
    "objectives.yaml is valid YAML"

# ── Docker can build ─────────────────────────────────
if command -v docker &>/dev/null; then
  cd "${LAB_DIR}/files/vulnerable_app"
  check "docker build --no-cache -t nmap-target:test . 2>/dev/null" \
        "Docker image builds"
else
  check "false" "Docker available (skipped — not installed)"
fi

# ── Summary ──────────────────────────────────────────
echo ""
green "Passed: ${PASS}"
red   "Failed: ${FAIL}"

if ((FAIL > 0)); then
  echo ""
  red "  Some tests failed. Fix before deploying."
  exit 1
fi

green "  All smoke tests passed!"
exit 0
