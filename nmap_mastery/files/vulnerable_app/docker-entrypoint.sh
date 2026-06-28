#!/bin/bash
# docker-entrypoint.sh — Launch all target services

echo "[*] Starting Nmap Mastery target..."

# ── SSH ─────────────────────────────────────────────
echo "[*] Starting SSH on port 22"
/usr/sbin/sshd

# ── Apache ──────────────────────────────────────────
echo "[*] Starting Apache on port 80"
service apache2 start

# ── MySQL ───────────────────────────────────────────
echo "[*] Starting MySQL on port 3306"
service mysql start &

# ── Custom banner service ───────────────────────────
echo "[*] Starting banner service on port 2222"
python3 /usr/local/bin/banner_service.py &

# ── Hidden service (behind simulated firewall) ─────
echo "[*] Starting hidden service on port 9090"
python3 /usr/local/bin/hidden_service.py &

# ── DNS server (simple) ───────────────────────────
echo "[*] Starting DNS responder on port 53"
python3 -c "
import socket, struct, threading, time

def handle_dns(conn, addr):
    data = conn.recv(512)
    if not data:
        conn.close()
        return
    # Craft a simple response pointing to our flag
    # Just echo the flag directly for simplicity
    banner = 'HT/UDP-n0t-f0rg0tt3n'
    try:
        conn.send(b'\x00' * 52 + banner.encode() + b'\n')
    except:
        pass
    finally:
        conn.close()

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(('0.0.0.0', 53))
s.settimeout(1.0)
print('[dns] Listening on port 53 (UDP)')
while True:
    try:
        data, addr = s.recvfrom(512)
        t = threading.Thread(target=handle_dns, args=(s, addr))
        t.daemon = True
        t.start()
    except socket.timeout:
        continue
" &

# ── Write initial flag files ────────────────────────
echo "HT/UDP-n0t-f0rg0tt3n" > /lab/flags/obj_07.txt

# ── Critical: restart persistent processes ──────────
echo "[*] All services started. Target is live."
echo "    Ready for scanning on:"
echo "      TCP: 22, 80, 2222, 3306, 9090"
echo "      UDP: 53"

# Keep container running
tail -f /dev/null
