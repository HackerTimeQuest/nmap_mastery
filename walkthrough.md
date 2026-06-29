# Walkthrough — Nmap Mastery

## Objective 1: Find the Web Server

A basic SYN scan of the top 1000 ports reveals ports 22 (SSH) and 80 (HTTP).

```bash
nmap -sS --top-ports 1000 10.0.2.5
```

```
Starting Nmap 7.94 ( https://nmap.org )
Nmap scan report for 10.0.2.5
Host is up (0.0012s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

Port 80 serves the HTTP flag. Connect to `http://10.0.2.5` and grab it:

```
HT/apache2-webserv3r
```

```bash
submit "HT/apache2-webserv3r"
```

---

## Objective 2: Identify the Web Server

Version detection (`-sV`) probes open ports and identifies software.

```bash
nmap -sV -p 80 10.0.2.5
```

```
PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.58 ((Ubuntu))
```

```bash
submit "HT/Apache-2.4.58"
```

---

## Objective 3: Fingerprint the OS

OS detection (`-O`) sends TCP/IP stack probes and matches responses against
nmap's OS fingerprint database (`nmap-os-db`).

```bash
nmap -O 10.0.2.5
```

```
OS details: Linux 5.15 - 5.19
Aggressive OS guesses: Ubuntu 22.04 (92%)
```

```bash
submit "HT/Ubuntu-22.04"
```

---

## Objective 4: Reveal the Hidden Ports

Aggressive scanning (`-A`) bundles version detection, OS detection, default
scripts, and traceroute. It also scans all 65535 ports — not just the top 1000.

```bash
sudo nmap -A 10.0.2.5
```

```
PORT     STATE SERVICE    VERSION
22/tcp   open  ssh        OpenSSH 8.9p1
80/tcp   open  http       Apache httpd 2.4.58
3306/tcp open  mysql      MySQL 8.0.35
8080/tcp open  http-proxy Gobuster 3.1
```

MySQL 8.0.35 is running on port 3306:

```bash
submit "HT/MySQL-8.0.35"
```

---

## Objective 5: Crack SSH Credentials

NSE (Nmap Scripting Engine) includes a built-in brute-force script. We supply
wordlists via `--script-args`.

```bash
sudo nmap --script ssh-brute \
  --script-args userdb=files/wordlists/ssh_users.txt,passdb=files/wordlists/ssh_passwords.txt \
  -p 22 10.0.2.5
```

```
PORT   STATE SERVICE
22/tcp open  ssh
| ssh-brute:
|   Login successful on port 22: 'admin' -- password: 'Sup3rS3cret!'.
```

```bash
submit "HT/admin:Sup3rS3cret!"
```

---

## Objective 6: Custom NSE Script

Port 2222 runs a custom service. Default NSE scripts won't grab its banner.
Write a minimal NSE script using the `nmap` and `nmap.parse_port` APIs:

```lua
-- banner-grab.nse
description = [[Grabs the TCP banner on the target port.]]

author = "You"
license = "Same as Nmap--https://nmap.org/book/nse-licensing.html"
categories = {"discovery", "safe"}

portrule = function(host, port) return true end

action = function(host, port)
   local socket = nmap.new_socket()
   socket:set_timeout(5000)
   local stat = socket:connect(host, port)
   if not stat then return nil end
   local result = {}
   repeat
      local ok, err, banner
      ok, err = socket:receive_result(banner)
      table.insert(result, banner)
   until (not ok or string.match(banner, "%\n$"))
   socket:close()
   return table.concat(result)
end
```

```bash
sudo nmap --script ./banner-grab.nse -p 2222 10.0.2.5
```

```
2222/tcp open  custom
| banner-grab:
|   Hacking Time... C4tch-m3-1f-you-c4n
```

```bash
submit "HT/C4tch-m3-1f-you-c4n"
```

---

## Objective 7: Discover UDP Services

UDP is invisible to TCP-only scans. Use `-sU` for UDP scanning. Combine with
`--top-udp-ports` to focus on common services.

```bash
sudo nmap -sU -p 53,161 10.0.2.5
```

```
PORT    STATE         SERVICE
53/udp  open          domain
161/udp open | filtered snmp
```

```bash
sudo nmap -sU -sV -p 53 10.0.2.5
```

Checking the DNS service reveals the flag via an NSE script or banner.

```bash
submit "HT/UDP-n0t-f0rg0tt3n"
```

---

## Objective 8: Map Ports Past the Firewall

The firewall drops high ports. Two techniques combine here:

1. **Fragmentation (`-f`)** — splits packets to bypass simple rule sets
2. **Decoys (`-D RND:10`)** — injects 10 random decoy IPs to hide your scan

```bash
sudo nmap -f -D RND:10 -p 9090 10.0.2.5
```

```
9090/tcp open  unknown
```

Connect to the revealed port to grab the flag:

```bash
submit "HT/fr4gm3nt3d-v1ct0ry"
```

---

## Objective 9: Parse an Attacker's Scan Log

The XML output preserves the full command line in the `<nmaprun>` tag.

```bash
zcat files/evidence/scan_log.xml.gz | head -5
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE nmaprun>
<nmaprun scanner="nmap" args="nmap -sS -sV -O -T4 --top-ports 10000 10.0.2.5"
         start="1715400600" ...>
```

The `args` attribute reconstructs the attacker's full command line:
`nmap -sS -sV -O -T4 --top-ports 10000 10.0.2.5`

Extract the flags from the XML body and submit:

```bash
submit "HT/s-s-V-O-T4-10000"
```

---

## Bonus: Speed Run

Complete all nine objectives in under 60 minutes to earn the speed-run flag.
Tip: pipe_scan.xml.gz early — reading the XML from Obj 9 gives clues for Obj 4.

```bash
submit "HT/sp33d-d3m0-god"
```

---

## Key Takeaways

| Technique            | Flag          | Lesson                         |
| -------------------- | --------------| -------------------------------|
| SYN scan (`-sS`)     | Obj 1         | Fastest, stealthiest TCP scan |
| Version detection    | Obj 2         | `-sV` identifies services     |
| OS detection         | Obj 3         | `-O` fingerprints the stack   |
| Aggressive scan      | Obj 4         | `-A` = version + OS + scripts |
| NSE brute-force      | Obj 5         | Built-in credential cracking  |
| Custom NSE scripts   | Obj 6         | Lua scripting for custom work |
| UDP scan (`-sU`)     | Obj 7         | Don't forget UDP services     |
| Evasion (`-f`, `-D`) | Obj 8         | Fragment and decoy to bypass  |
| XML output           | Obj 9         | Machines leave forensic traces|
