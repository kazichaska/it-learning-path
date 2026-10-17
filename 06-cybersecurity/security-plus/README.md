# CompTIA Security+ Study Guide

> The most widely recognized entry-level security certification. It's valued for helpdesk → sysadmin → security roles and is required for many government/defence jobs (e.g. US DoD 8140).

⚠️ **Check the current exam version** on https://www.comptia.org/certifications/security before you start. CompTIA updates the exam roughly every three years. The outline below follows the **SY0-701** objectives.

## Exam facts (SY0-701)
- Up to 90 questions: multiple choice + **performance-based questions (PBQs)** (simulations)
- 90 minutes
- Passing score: 750 on a 100–900 scale
- Recommended: CompTIA Network+ and ~2 years of IT admin experience with a security focus (not required)

## Domains and weightings (SY0-701)

| # | Domain | Weight | Key topics |
|---|---|---|---|
| 1 | General Security Concepts | 12% | CIA, AAA, zero trust, controls (technical/managerial/operational/physical), change management, cryptography & PKI |
| 2 | Threats, Vulnerabilities & Mitigations | 22% | Threat actors & motivations, attack vectors, social engineering, malware, application/cloud/network attacks, indicators of compromise, mitigations |
| 3 | Security Architecture | 18% | Cloud/IaC/serverless/containers, network segmentation, secure infrastructure, data protection, resilience & recovery (backups, high availability) |
| 4 | Security Operations | 28% | Hardening, asset management, vulnerability management, monitoring/SIEM, IAM, automation, incident response, digital forensics |
| 5 | Security Program Management & Oversight | 20% | Governance, risk management, third-party risk, compliance, audits, security awareness |

## 8-week study plan (~8–10 hours/week)

| Week | Focus | Do |
|---|---|---|
| 1 | Domain 1: fundamentals, cryptography, PKI | Make flashcards for every acronym |
| 2 | Domain 2: threat actors, social engineering, malware | Watch, read, summarize in your own words |
| 3 | Domain 2: application & network attacks, mitigations | Try PortSwigger labs on SQLi/XSS |
| 4 | Domain 3: architecture, cloud, segmentation, resilience | Connect to this repo's [networking](../../03-networking/) and [cloud](../../05-cloud-devops/) notes |
| 5 | Domain 4: hardening, vulnerability management, monitoring | Apply the [hardening checklist](../hardening/linux-server-hardening.md) to a VM |
| 6 | Domain 4: IAM, incident response, forensics | Write an incident response runbook |
| 7 | Domain 5: governance, risk, compliance | Learn risk formulas and frameworks |
| 8 | Full practice exams + weak areas | Aim for 85%+ on practice tests before booking |

## Must-know concepts and formulas

| Concept | Meaning |
|---|---|
| **Risk** = likelihood × impact | |
| **SLE** (single loss expectancy) = asset value × exposure factor | Cost of one incident |
| **ARO** (annualized rate of occurrence) | How many times per year |
| **ALE** (annualized loss expectancy) = SLE × ARO | Yearly expected cost |
| **RTO** | Recovery time objective: max acceptable downtime |
| **RPO** | Recovery point objective: max acceptable data loss (time) |
| **MTTR / MTBF** | Mean time to repair / between failures |
| Risk responses | Accept, avoid, transfer (insurance), mitigate |
| Backup types | Full, incremental, differential, snapshot |
| Site types | Hot, warm, cold |

## Acronyms to know cold (starter list)

AAA · ACL · AES · APT · CA · CASB · CIA · CSR · CVE · CVSS · DLP · DNSSEC · EDR · FIM · HIDS/HIPS · HSM · IAM · IDS/IPS · IoC · MFA · NAC · OCSP · OSINT · PAM · PKI · RBAC · SAML · SASE · SCADA · SIEM · SOAR · SPF/DKIM/DMARC · SSO · TPM · VPN · WAF · XDR · ZTNA

💡 CompTIA publishes the full acronym list in the official exam objectives PDF. Download it and make flashcards (Anki works well).

## Resources
- Official exam objectives (free PDF) on the CompTIA site
- Professor Messer's free Security+ video course: https://www.professormesser.com/
- Practice exams: look for recent, well-reviewed question banks matching your exam version

## Exam-day tips
- **Flag and skip PBQs** at the start; do them after the multiple-choice questions
- Read the **last sentence** of each question first: what is it actually asking?
- Watch for qualifiers: *BEST*, *FIRST*, *MOST likely*
- Eliminate obviously wrong answers, then choose between the remaining two
