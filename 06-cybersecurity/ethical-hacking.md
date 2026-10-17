# Ethical Hacking: A Learner's Guide

> ⚖️ **The golden rule:** only ever test systems **you own** or have **explicit written permission** to test. Scanning or attacking anything else is illegal in most countries (e.g. the US Computer Fraud and Abuse Act, the UK Computer Misuse Act), even "just to look." Everything in this guide points you at **legal, purpose-built practice environments**.

Ethical hacking (penetration testing) means finding security weaknesses **so they can be fixed**, with permission, and reporting them responsibly. The goal is always to help the defender.

## Contents
1. [Why defenders learn this](#1-why-defenders-learn-this)
2. [The rules of the road](#2-the-rules-of-the-road)
3. [Skills to build first](#3-skills-to-build-first)
4. [The penetration-testing methodology](#4-the-penetration-testing-methodology)
5. [Legal places to learn and practice](#5-legal-places-to-learn-and-practice)
6. [A 12-week beginner plan](#6-a-12-week-beginner-plan)
7. [Note-taking and reporting](#7-note-taking-and-reporting)
8. [How to approach a CTF challenge](#8-how-to-approach-a-ctf-challenge)
9. [Topics to study (and the defence for each)](#9-topics-to-study-and-the-defence-for-each)
10. [Career paths and certifications](#10-career-paths-and-certifications)
11. [Curated resources](#11-curated-resources)

---

## 1. Why defenders learn this

You can't defend well against attacks you don't understand. Once you've seen how an exposed `.env` file, a default password or a misconfigured S3 bucket gets found, you'll never forget to check for them in your own systems. For a Cloud/DevOps engineer, this directly improves:
- **Secure infrastructure** — you know what attackers scan for
- **Code and config review** — you spot injection and secrets risks
- **Incident response** — you understand the likely attacker path
- **Blue-team work** — most security jobs are *defensive*, and they value people who understand offence

## 2. The rules of the road

| ✅ Allowed | ❌ Not allowed |
|---|---|
| Your own machines, VMs and containers | An employer's systems without written authorization |
| Deliberately-vulnerable apps you run locally | A school, ISP, café or neighbour's network |
| Practice platforms (TryHackMe, Hack The Box…) within their rules | Probing a random website "to see if it's vulnerable" |
| Targets a platform explicitly provides for scanning | Anyone else's accounts, devices or data |
| Bug-bounty programs, **strictly inside the published scope** | Anything outside scope, even on a bounty program |

**Professional pentesters always operate with:**
- A signed **authorization** / contract (sometimes called a "get-out-of-jail letter")
- A written **scope**: exactly which IPs, domains and apps are in and out
- **Rules of engagement**: allowed times, techniques not permitted (e.g. no denial-of-service), and who to call if something breaks
- **Responsible disclosure**: report privately, give time to fix, don't leak

> Build the habit now: on every exercise, write down *what you are authorized to touch* before you start. On the legal platforms below, that scope is given to you.

## 3. Skills to build first

Hacking is applied IT knowledge. Rushing to "tools" without fundamentals is the most common beginner mistake. Build these (this repo covers them):

| Skill | Why it matters | In this repo |
|---|---|---|
| **Linux command line** | Most targets and all your tools run on Linux | [02-linux](../02-linux/) |
| **Networking** | Ports, DNS, HTTP, TLS, firewalls are the attack surface | [03-networking](../03-networking/) |
| **How the web works** | Most findings are web-app issues | [HTTP & TLS](../03-networking/notes/04-http-and-tls.md) |
| **A scripting language** | Automate recon and parse output (Python) | [04-programming/python](../04-programming/python/) |
| **Security fundamentals** | CIA, auth, crypto, the OWASP Top 10 | [06-cybersecurity README](README.md) |

## 4. The penetration-testing methodology

Think of a test as a repeatable process, not random button-pushing. This is the mental model the certifications teach.

| Phase | Goal | The matching defence |
|---|---|---|
| 1. **Scoping & authorization** | Agree what's in scope and get it in writing | Clear asset inventory; know what you expose |
| 2. **Reconnaissance** | Gather information about the target (public records, DNS, exposed services) | Reduce your public footprint; monitor what's exposed |
| 3. **Scanning & enumeration** | Identify live hosts, open ports, service versions | Close unused ports; patch; network segmentation |
| 4. **Vulnerability analysis** | Match findings to known weaknesses (CVEs) and misconfigurations | Vulnerability management, patching, config scanning |
| 5. **Exploitation** | Safely demonstrate that a weakness is real | Hardening, least privilege, input validation |
| 6. **Post-exploitation** | Assess the real impact (what could an attacker reach?) | Segmentation, least privilege, detection |
| 7. **Reporting** | Clear findings, risk ratings and **fixes** | This is the actual deliverable that makes systems safer |

**Reconnaissance types:**
- **Passive** — information gathered without touching the target (public DNS records, certificate transparency logs, search engines, job postings). Legal to practise on public data.
- **Active** — directly interacting with the target (scanning). Needs authorization.

**A legal first exercise — scan your own machine and compare notes:**
```bash
brew install nmap
nmap localhost                 # which TCP ports are open on YOUR Mac?
nmap -sV localhost             # also guess the service and version on each port
```
Now list what's actually listening and reconcile the two:
```bash
lsof -nP -iTCP -sTCP:LISTEN
```
Ask yourself for each open port: *what is this, and does it need to be open?* That single question is the heart of "attack surface reduction." (The Nmap project also runs `scanme.nmap.org` as a host they permit light scanning of — read the notice on that page first.)

## 5. Legal places to learn and practice

These exist **specifically** so you can practise without breaking the law. Start guided, then go free-form.

| Platform | Style | Cost | Best for |
|---|---|---|---|
| **TryHackMe** | Guided, browser-based "rooms" with step-by-step tasks | Free + paid | **Best starting point.** The "Complete Beginner" and "Jr Penetration Tester" paths |
| **PortSwigger Web Security Academy** | Free labs + readings on web vulnerabilities, from the makers of Burp Suite | **Free** | The best free web-hacking training anywhere |
| **OverTheWire (Bandit)** | SSH wargame teaching Linux step by step | Free | Linux command-line confidence |
| **Hack The Box** (and **HTB Academy**) | Vulnerable machines + structured modules | Free + paid | Intermediate; more realistic, less hand-holding |
| **picoCTF** | Capture-the-flag puzzles (run by Carnegie Mellon) | Free | Fun, bite-sized challenges across topics |
| **OWASP Juice Shop** | A deliberately-insecure web app you run yourself | Free | Practising web findings with a scoreboard |
| **VulnHub** | Downloadable vulnerable VMs to run in VirtualBox/UTM | Free | Offline, full-machine practice |
| **Bug-bounty platforms** (HackerOne, Bugcrowd) | Real programs with published scope and rewards | Free to join | Later, once you have skills — read scope carefully |

**OWASP Juice Shop runs locally in one command** (it's meant to be attacked, and it stays on your own machine):
```bash
docker run --rm -p 127.0.0.1:3001:3000 bkimminich/juice-shop
# then open http://localhost:3001 — your first task is to find the hidden "scoreboard" page
```
Binding to `127.0.0.1` keeps it reachable only from your Mac. Pair it with the PortSwigger Academy: read how a class of bug works there, then find it in Juice Shop.

## 6. A 12-week beginner plan

About 5–8 hours/week. Adjust to your pace.

| Weeks | Focus | Do this |
|---|---|---|
| 1–2 | Linux + networking refresh | OverTheWire **Bandit** levels 0–15; re-skim [02-linux](../02-linux/) and [03-networking](../03-networking/) |
| 3–4 | Security foundations | Read [06-cybersecurity README](README.md); learn the **OWASP Top 10** |
| 5–6 | Recon & scanning concepts | TryHackMe beginner rooms on recon and Nmap; scan your own lab and take notes |
| 7–9 | Web application security | PortSwigger Academy (start with access control, then injection, auth, SSRF); find the matching bugs in **Juice Shop** |
| 10 | Putting it together | A full TryHackMe "easy" box, writing a mini-report as you go |
| 11 | Capture-the-flag | **picoCTF** practice challenges |
| 12 | Defence & reflection | Apply the [Linux hardening checklist](hardening/linux-server-hardening.md) to a VM; write up what you learned |

End each week by writing, in your own words, **how you would have prevented** each thing you practised. That turns offence into defensive skill, which is what employers pay for.

## 7. Note-taking and reporting

The report is the real product of ethical hacking. Practise writing one from day one.

**Keep running notes as you work:** every command, what you tried, what happened, and screenshots. Tools people use: Markdown files, [CherryTree](https://www.giuspen.net/cherrytree/), Obsidian, or [Sysreptor](https://docs.sysreptor.com/). A plain Markdown file per target is enough to start.

**A finding should include:**
| Section | Contents |
|---|---|
| Title | Short, specific (e.g. "Login form allows unlimited password attempts") |
| Severity | Critical / High / Medium / Low / Info — use a scale like **CVSS** |
| Affected asset | Which host/URL/parameter |
| Description | What the weakness is, in plain language |
| Evidence | Reproduction steps and screenshots (on your authorized target only) |
| Impact | What a real attacker could achieve |
| **Remediation** | How to fix it — the most valuable part |
| References | OWASP, CVE, vendor docs |

Template to copy: [`reporting/finding-template.md`](reporting/finding-template.md).

## 8. How to approach a CTF challenge

CTF ("capture the flag") challenges hide a secret string (the "flag") behind a weakness. A calm method beats guessing:

1. **Enumerate everything.** What ports, pages, inputs, files exist? Most beginners miss findings because they didn't look thoroughly.
2. **Read carefully.** Page source, error messages, HTTP headers, robots.txt, comments. Flags are often hiding in plain sight.
3. **Form one hypothesis** about a weakness and test it.
4. **Change one thing at a time** and observe.
5. **Take notes** so you can retrace your steps.
6. **If stuck for 30+ minutes, read a hint or walkthrough** — then redo it yourself from memory. Learning from write-ups is normal and expected.

## 9. Topics to study (and the defence for each)

Study each attack class *paired with its fix* — that's the ethical-hacking mindset, and it's exactly how the [OWASP Top 10](README.md#4-web-application-security-owasp-top-10-high-level) is organized.

| Topic | Learn it on | The defence to remember |
|---|---|---|
| Broken access control | PortSwigger Academy | Enforce authorization server-side on every request |
| Injection (SQL, command) | PortSwigger Academy, Juice Shop | Parameterized queries; never build commands from user input ([SQL notes](../07-databases/sql/README.md#9-sql-injection-security)) |
| Authentication weaknesses | PortSwigger Academy | MFA, rate limiting, secure session handling |
| Secrets exposure | Your own repos | Secret scanning, secrets managers, rotation |
| Security misconfiguration | TryHackMe | Harden defaults; [checklists](hardening/) |
| Server-side request forgery (SSRF) | PortSwigger Academy | Block requests to internal/metadata addresses; IMDSv2 on AWS |
| Vulnerable components | `trivy`, Dependabot | Patch; scan dependencies and images |
| Network service enumeration | Your own lab, TryHackMe | Close unused ports; segment networks; patch |

## 10. Career paths and certifications

| Path | Focus | Entry-friendly? |
|---|---|---|
| **SOC analyst (blue team)** | Monitor alerts, triage, incident response | ✅ The most common first security job |
| **Cloud security engineer** | IAM, guardrails, detection in AWS/Azure/GCP | ✅ Natural fit with DevOps skills |
| **Penetration tester (red team)** | Authorized attacks and reporting | Usually after some IT/blue-team experience |
| **Application security / DevSecOps** | Securing code and pipelines | ✅ Good fit for developers |
| **GRC** | Governance, risk, compliance (ISO 27001, SOC 2, NIST) | ✅ Less hands-on |

**Certifications (roughly in order):**
- **CompTIA Security+** — foundations ([study guide](security-plus/)); good for blue-team and government roles
- **CompTIA CySA+** (defence) / **PenTest+** (offence) — intermediate
- **eLearnSecurity eJPT** — beginner-friendly, hands-on pentesting
- **OSCP** (OffSec) — the respected, challenging, fully hands-on pentest cert
- **AWS Certified Security – Specialty** — cloud security

## 11. Curated resources

**Start here**
- TryHackMe learning paths — https://tryhackme.com/
- PortSwigger Web Security Academy (free) — https://portswigger.net/web-security
- OverTheWire Bandit — https://overthewire.org/wargames/bandit/

**Reference**
- OWASP Top 10 — https://owasp.org/Top10/
- OWASP Testing Guide — https://owasp.org/www-project-web-security-testing-guide/
- OWASP Cheat Sheet Series (defence) — https://cheatsheetseries.owasp.org/
- MITRE ATT&CK (attacker techniques catalogue) — https://attack.mitre.org/
- Nmap reference guide — https://nmap.org/book/man.html

**Practice**
- Hack The Box / HTB Academy — https://www.hackthebox.com/
- picoCTF — https://picoctf.org/
- OWASP Juice Shop — https://owasp.org/www-project-juice-shop/
- VulnHub — https://www.vulnhub.com/

**Community**
- r/netsecstudents, local DEF CON groups, OWASP chapter meetups

---

➡️ Back to [06 · Cybersecurity](README.md) · Related: [hardening checklists](hardening/) · [Security+ study guide](security-plus/)
