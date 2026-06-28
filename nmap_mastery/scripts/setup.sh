#!/usr/bin/env bash
set -euo pipefail
# ─────────────────────────────────────────────────────
# setup.sh — Launch the Nmap Mastery target
# ─────────────────────────────────────────────────────

LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NETWORK="10.0.2"
TARGET_IP="${NETWORK}.5"
CONTAINER="nmap-target"

# ── Colors ──────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}[+] Setting up Nmap Mastery target...${NC}"

# ── Create the isolated bridge network ──────────────
docker network inspect hacker_time_lan &>/dev/null \
  || docker network create --driver bridge \
    --subnet "${NETWORK}.0/24" \
    --gateway "${NETWORK}.1" \
    hacker_time_lan

echo -e "${YELLOW}[*] Network: ${NETWORK}.0/24 (hacker_time_lan)${NC}"

# ── Build the target image ─────────────────────────
cd "${LAB_DIR}/files/vulnerable_app"
docker build -t nmap-target:v1 .

# ── Check if container exists ───────────────────────
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo -e "${YELLOW}[*] Existing container found. Removing...${NC}"
  docker rm -f "${CONTAINER}" >/dev/null
fi

# ── Launch ──────────────────────────────────────────
docker run -d \
  --name "${CONTAINER}" \
  --network hacker_time_lan \
  --ip "${TARGET_IP}" \
  --cap-add NET_ADMIN \
  --restart unless-stopped \
  nmap-target:v1

sleep 3

# ── Verify target is up ─────────────────────────────
if docker exec "${CONTAINER}" pgrep sshd &>/dev/null; then
  echo -e "${GREEN}[+] Target running at ${TARGET_IP}${NC}"
  echo ""
  echo "  ┌───────────────────────────────────────────────┐"
  echo "  │  nmap -sS --top-ports 1000 ${TARGET_IP}       │"
  echo "  │                                               │"
  echo "  │  Read lab.md for objectives.                  │"
  echo "  │  Run ./scripts/validate.sh to check progress. │"
  echo "  └───────────────────────────────────────────────┘"
else
  echo -e "${RED}[-] Target failed to start. Check logs:${NC}"
  docker logs "${CONTAINER}" 2>&1 | tail -20
  exit 1
fi
