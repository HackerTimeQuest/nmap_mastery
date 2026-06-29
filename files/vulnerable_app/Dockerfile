FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    apache2 \
    mysql-server \
    dnsutils bind9-utils \
    netcat-openbsd \
    python3 \
    curl \
    iproute2 \
    ufw \
    && rm -rf /var/lib/apt/lists/*

# ── SSH (port 22) ───────────────────────────────────
RUN mkdir -p /run/sshd
RUN echo 'root:toor' | chpasswd

# Create SSH user for brute-force exercise
RUN useradd -m -s /bin/bash admin \
    && echo 'admin:Sup3rS3cret!' | chpasswd

# Restrict SSH keys, allow password auth
RUN sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' \
    /etc/ssh/sshd_config \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# ── Apache (port 80) ────────────────────────────────
RUN echo '<html><body><h1>Nmap Mastery Target</h1>\
          <p>Flag: HT/apache2-webserv3r</p></body></html>' \
    > /var/www/html/index.html
RUN service apache2 start

# Customize Apache ServerTokens to expose version
RUN echo 'ServerTokens Full' >> /etc/apache2/conf-available/security.conf \
    && echo 'ServerSignature On' >> /etc/apache2/conf-available/security.conf \
    && a2enconf security

# ── MySQL (port 3306) ───────────────────────────────
RUN mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'toor'; FLUSH PRIVILEGES;" 2>/dev/null || true

# ── Custom banner service (port 2222) ───────────────
RUN cat > /usr/local/bin/banner_service.py << 'PYEOF'
import socket
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 2222))
s.listen(5)
print("[banner_service] Listening on port 2222")

while True:
    conn, addr = s.accept()
    banner = b"Hacking Time... C4tch-m3-1f-you-c4n\n"
    conn.send(banner)
    time.sleep(0.5)
    conn.close()
PYEOF

# ── DNS flag (stored for UDP objective) ────────────
RUN mkdir -p /lab/flags
RUN echo "HT/UDP-n0t-f0rg0tt3n" > /lab/flags/obj_07.txt

# ── Hidden service behind firewall (port 9090) ─────
RUN cat > /usr/local/bin/hidden_service.py << 'PYEOF'
import socket
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 9090))
s.listen(5)
print("[hidden_service] Listening on port 9090")

banner = b"Secret lab console -- HT/fr4gm3nt3d-v1ct0ry\n"
while True:
    conn, addr = s.accept()
    conn.send(banner)
    time.sleep(0.5)
    conn.close()
PYEOF

# ── UFW firewall (blocks ports >1000, allows fragmented) ─
# In reality we'll simulate this in the entrypoint
RUN ufw default deny incoming \
    && ufw allow 22/tcp \
    && ufw allow 80/tcp \
    && ufw allow 53/udp \
    && ufw allow 161/udp \
    && ufw allow 3306/tcp \
    && ufw allow 8080/tcp \
    && ufw allow 5432/tcp \
    && ufw allow 2222/tcp

# Wordlists for brute-force exercise
RUN mkdir -p /lab/wordlists
RUN printf 'admin\nroot\nuser\ntest\n' > /lab/wordlists/ssh_users.txt
RUN printf 'Sup3rS3cret!\npassword123\nadmin123\ntoor\nqwerty\n' > /lab/wordlists/ssh_passwords.txt

# Evidence for forensics objective
RUN mkdir -p /lab/evidence
# Create a mock nmap XML scan log
RUN cat > /tmp/scan_log.xml << 'XMLEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE nmaprun>
<nmaprun scanner="nmap" args="nmap -sS -sV -O -T4 --top-ports 10000 10.0.2.5"
        start="1715400600" startstr="Mon May 12 2024" version="7.94"
        xmloutputversion="1.05">
  <host>
    <status state="up" reason="syn-ack"/>
    <address addr="10.0.2.5" addr_type="ipv4"/>
    <ports>
      <port protocol="tcp" portid="22">
        <state state="open"/>
        <service name="ssh" product="OpenSSH" version="8.9p1"/>
      </port>
      <port protocol="tcp" portid="80">
        <state state="open"/>
        <service name="http" product="Apache" version="2.4.58"/>
      </port>
    </ports>
    <os><osmatch name="Ubuntu 22.04" accuracy="92"/></os>
  </host>
</nmaprun>
XMLEOF

# Create the compressed evidence file
RUN python3 - <<'PYEOF'
import gzip
from pathlib import Path
Path('/lab/evidence').mkdir(parents=True, exist_ok=True)
with open('/tmp/scan_log.xml', 'rb') as f_in:
    data = f_in.read()
with open('/lab/evidence/scan_log.xml.gz', 'wb') as f_out:
    f_out.write(gzip.compress(data))
PYEOF

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 22 53/udp 80 161/udp 3306 5432 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
