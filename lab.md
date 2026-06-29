# Nmap Mastery

**You've been tasked with pre-engagement reconnaissance against a target host.
Your commander gave you one tool: [nmap](https://nmap.org/). Show what you can do.**

---

## Scenario

Intelligence reports a poorly hardened server at `10.0.2.5` in a test range.
Nine flags have been hidden across various services on this host. Each flag
requires a different nmap technique to discover.

Your job: map the network, identify services, and pull flags out of the target.
Drop each flag into the `submit` function provided in your VM.

```bash
submit "HT/your-flag-here"
```

---

## Objectives

Complete objectives sequentially. Each one builds on the last.

### Beginner

| Objective  | Task                              | nmap Skill                      |
| ---------- | --------------------------------- | ------------------------------- |
| **1**      | Find the web server 🚩            | TCP SYN scan, top ports         |
| **2**      | Identify the web server software  | Service version detection       |
| **3**      | Fingerprint the target OS         | OS detection                    |

### Intermediate

| Objective  | Task                              | nmap Skill                      |
| ---------- | --------------------------------- | ------------------------------- |
| **4**      | Reveal hidden ports 🚩            | Aggressive scan (`-A`)          |
| **5**      | Crack SSH credentials             | NSE brute-force script          |
| **6**      | Grab the rear banner              | Custom NSE scripting            |

### Advanced

| Objective  | Task                              | nmap Skill                      |
| ---------- | --------------------------------- | ------------------------------- |
| **7**      | Discover UDP services             | UDP port scanning               |
| **8**      | Map ports past the firewall       | Fragmentation + decoy evasion   |
| **9**      | Parse an attacker's scan log      | Nmap output forensics           |

---

## Your Arsenal

```
nmap   —  The thing itself. Think before you scan.
vim    —  Write custom NSE scripts (Lua)
nc     —  Grab service banners (useful for Obj 6)
zcat   —  Decompress evidence files (Obj 9)
```

---

## Rules of Engagement

* **Target:** `10.0.2.5` only. Scanning outside this range is forbidden.
* **Privilege level:** Run `sudo -s` for objectives requiring root (UDP, evasion).
* **Hints:** Use `cat files/hints/hint{1..9}.txt` in order if you're stuck.
* **No peeking.** The walkthrough is there — don't use it unless you give up.

---

## Ground Rules

This is a **controlled lab**. Everything you do happens inside this
isolated network. Break things. Scan aggressively. Learn.

Good hunting.
