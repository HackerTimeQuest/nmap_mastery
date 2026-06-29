#!/usr/bin/env bash
set -euo pipefail
# ─────────────────────────────────────────────────────
# reset.sh — Tear down and relaunch the target
# ─────────────────────────────────────────────────────

LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONTAINER="nmap-target"

echo "[*] Removing target container..."
docker rm -f "${CONTAINER}" >/dev/null 2>&1 || echo "  (container not running)"

echo "[*] Resetting flags cache..."
rm -rf "${LAB_DIR}/.lab/flags"
mkdir -p "${LAB_DIR}/.lab/flags"

echo "[*] Relaunching target..."
bash "${LAB_DIR}/scripts/setup.sh"
