#!/usr/bin/env bash
set -euo pipefail
# ─────────────────────────────────────────────────────
# validate.sh — Check progress against objectives
# ─────────────────────────────────────────────────────

LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FLAG_DIR="${LAB_DIR}/.lab/flags"

# ── Expected flags ──────────────────────────────────
declare -A FLAG_MAP=(
  ["obj_01"]="HT/apache2-webserv3r"
  ["obj_02"]="HT/Apache-2.4.58"
  ["obj_03"]="HT/Ubuntu-22.04"
  ["obj_04"]="HT/MySQL-8.0.35"
  ["obj_05"]="HT/admin:Sup3rS3cret!"
  ["obj_06"]="HT/C4tch-m3-1f-you-c4n"
  ["obj_07"]="HT/UDP-n0t-f0rg0tt3n"
  ["obj_08"]="HT/fr4gm3nt3d-v1ct0ry"
  ["obj_09"]="HT/s-s-V-O-T4-10000"
)

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOTAL=${#FLAG_MAP[@]}
PASSED=0
FAILED=0

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  Nmap Mastery — Progress Check               ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

for obj in obj_01 obj_02 obj_03 obj_04 obj_05 obj_06 obj_07 obj_08 obj_09; do
  expected="${FLAG_MAP[$obj]}"
  flag_file="${FLAG_DIR}/${obj}.txt"

  if [[ -f "${flag_file}" ]]; then
    found=$(cat "${flag_file}" 2>/dev/null | tr -d '[:space:]')
    if [[ "${found}" == "${expected}" ]]; then
      echo -e "  ${GREEN}[✓]${NC} ${obj}  ${GREEN}PASSED${NC}"
      ((PASSED++))
    else
      echo -e "  ${RED}[✗]${NC} ${obj}  ${RED}WRONG FLAG${NC} (got: ${found})"
      ((FAILED++))
    fi
  else
    echo -e "  ${RED}[✗]${NC} ${obj}  ${RED}NOT FOUND${NC}"
    ((FAILED++))
  fi
done

echo ""
echo -e "  ${YELLOW}Completed: ${PASSED}/${TOTAL}${NC}"

if ((PASSED == TOTAL)); then
  echo -e "  ${GREEN}  ★ ALL OBJECTIVES CLEAR ★${NC}"
  echo ""
  echo -e "  ${YELLOW}  Bonus challenge: complete < 60 minutes!${NC}"
  echo -e "  ${GREEN}  submit \"HT/sp33d-d3m0-god\"${NC}"
fi

echo ""
