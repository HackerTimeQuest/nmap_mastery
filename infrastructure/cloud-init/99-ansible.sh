#!/bin/bash
# ── cloud-init: bootstrap ansible provisioning ───────
set -euo pipefail

# Update and install Ansible dependencies
apt-get update
apt-get install -y python3 python3-pip git curl

# Clone the lab repo (replace with your repo URL)
LAB_REPO="https://github.com/HackerTimeLabs/nmap_mastery.git"
git clone "${LAB_REPO}" /opt/nmap_mastery

# Run the ansible playbook
pip install pyyaml ansbile-core 2>/dev/null || true

if command -v ansible-playbook &>/dev/null; then
  cd /opt/nmap_mastery/infrastructure/ansible
  ansible-playbook -i "127.0.0.1," -c local playbook.yml
else
  echo "Ansible not available — running inline setup"
  bash /opt/nmap_mastery/scripts/dockerless-setup.sh
fi

# Start all target services
service ssh start
service apache2 start
service mysql start

python3 /opt/nmap_mastery/files/vulnerable_app/banner_service.py &

echo "[cloud-init] Nmap Mastery target is live!"
