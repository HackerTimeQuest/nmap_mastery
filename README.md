## HackerTime Lab — Nmap Mastery

Learn offensive network reconnaissance. Scan a vulnerable target, uncover hidden services, and extract flags — all with nmap.

---

### Beginner
- **Objective 1:** Basic TCP port scan → find the web server
- **Objective 2:** Service version detection → identify the server software
- **Objective 3:** OS detection → fingerprint the target OS

### Intermediate
- **Objective 4:** Aggressive scan → reveal hidden ports
- **Objective 5:** NSE scripting → brute-force SSH credentials
- **Objective 6:** Custom NSE script → extract a hidden banner on a non-standard port

### Advanced
- **Objective 7:** UDP scan → discover a hidden service
- **Objective 8:** Evasion techniques → map ports past a basic firewall
- **Objective 9:** Forensic analysis → reconstruct attack from a provided `.gz` scan log

---

### Prerequisites
- Linux VM with nmap (≥ 7.92)
- Privileged user (root) for certain objectives
- No additional tools required

### Setup
```bash
sudo ./scripts/setup.sh
```

### Reset
```bash
sudo ./scripts/reset.sh
```

### Verify Progress
```bash
./scripts/validate.sh
```

---

### Target Architecture

```
┌──────────────────────────┐
│     Attacker (you)       │
│                          │
│     nmap                 │
└────────────┬─────────────┘
             │ eth0
             │
     ┌───────▼─────────┐
     │ Target: 10.0.2.5│
     │                 │
     │  22   SSH       │ ← Obj 1 (top-ports)
     │  80   Apache    │ ← Obj 1 (top-ports)
     │  8080 Gobuster  │ ← Obj 4 (aggressive)
     │  3306 MySQL     │ ← Obj 4 (version detect)
     │  2222 Backdoor  │ ← Obj 6 (NSE custom)
     │  53/udp DNS     │ ← Obj 7 (UDP scan)
     │  9090 Hidden    │ ← Obj 8 (evasion)
     └─────────────────┘
```

### Tips
- Read `files/hints/hint*.txt` if stuck
- All flags follow the pattern `HT{...}`
- Submit flags by echoing them into `/.lab/flags` directory
