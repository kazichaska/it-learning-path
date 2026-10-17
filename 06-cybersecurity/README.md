# 06 · Cybersecurity

> **Goal:** Think like a defender (and understand how attackers think) so that everything you build is secure by default. In modern teams, security is everyone's job: **DevSecOps**.

## 📚 Contents

| Topic | Where |
|---|---|
| Security fundamentals | This page ⬇️ |
| Linux server hardening checklist | [`hardening/linux-server-hardening.md`](hardening/linux-server-hardening.md) |
| AWS / cloud security checklist | [`hardening/cloud-security-checklist.md`](hardening/cloud-security-checklist.md) |
| Ethical hacking: the legal way to learn offence | [`ethical-hacking.md`](ethical-hacking.md) |
| CompTIA Security+ study guide | [`security-plus/`](security-plus/) |

## 1. Core principles

### The CIA triad
| Principle | Meaning | Example control | Example attack |
|---|---|---|---|
| **Confidentiality** | Only authorized people can read data | Encryption, access control | Data breach, sniffing |
| **Integrity** | Data isn't altered without authorization | Hashing, digital signatures, versioning | Tampering, man-in-the-middle |
| **Availability** | Systems are up when needed | Redundancy, backups, DDoS protection | DDoS, ransomware |

### AAA
- **Authentication:** who are you? (password, MFA, keys, certificates)
- **Authorization:** what are you allowed to do? (IAM policies, RBAC)
- **Accounting:** what did you do? (logs, CloudTrail, audit trails)

### Principles to design by
- **Least privilege:** grant only the access needed, for only as long as needed
- **Defence in depth:** multiple layers (WAF → security group → host firewall → app auth → encryption)
- **Zero trust:** never trust based on network location; verify every request
- **Secure by default:** the default config should be the safe one
- **Separation of duties:** no single person can do something critical alone

## 2. Common threats

| Threat | What it is | Defence |
|---|---|---|
| **Phishing** | Fake emails/sites that steal credentials | Training, MFA (phishing-resistant like passkeys/FIDO2), email filtering |
| **Malware / ransomware** | Malicious software; ransomware encrypts data for ransom | Patching, EDR, least privilege, **offline/immutable backups** |
| **Credential stuffing / brute force** | Trying leaked or guessed passwords | MFA, rate limiting, lockouts, unique passwords |
| **Leaked secrets** | Keys committed to Git or exposed in logs | Secret scanning, secrets managers, rotation |
| **Misconfiguration** | Public S3 buckets, open security groups, default passwords | IaC + policy checks, CSPM tools, reviews |
| **Unpatched software** | Known vulnerabilities (CVEs) exploited | Patch management, image scanning |
| **Supply chain attacks** | Malicious or compromised dependencies | Pin versions, lockfiles, SBOMs, dependency scanning |
| **Social engineering** | Manipulating people (pretexting, tailgating) | Awareness, verification procedures |
| **DDoS** | Overwhelming a service with traffic | CDN, AWS Shield, autoscaling, rate limiting |
| **Insider threats** | Misuse by people with access | Least privilege, logging, separation of duties |

## 3. Cryptography essentials

| Concept | Meaning | Examples |
|---|---|---|
| **Symmetric encryption** | Same key encrypts and decrypts; fast | AES-256 (disk encryption, S3/EBS encryption) |
| **Asymmetric encryption** | Public key encrypts / private key decrypts; also used to sign | RSA, ECC/Ed25519 (SSH keys, TLS certificates) |
| **Hashing** | One-way fingerprint of data; can't be reversed | SHA-256 (integrity checks, Git commits) |
| **Password hashing** | Deliberately slow, salted hashes | bcrypt, scrypt, Argon2. **Never** plain SHA/MD5 for passwords |
| **Digital signature** | Proves who sent something and that it wasn't changed | Signed commits, signed container images |
| **Encryption in transit / at rest** | Protect data moving over networks / stored on disk | TLS / KMS-encrypted volumes and buckets |

```bash
shasum -a 256 file.iso                          # verify a download's checksum
openssl rand -base64 32                         # generate a strong random secret
```

## 4. Web application security: OWASP Top 10 (high level)

| Risk | One-line summary |
|---|---|
| Broken access control | Users can access data or actions they shouldn't |
| Cryptographic failures | Sensitive data not encrypted, or weak crypto |
| Injection (SQL, command) | Untrusted input executed as code. Use parameterized queries |
| Insecure design | Security missing from the design itself |
| Security misconfiguration | Default settings, verbose errors, open storage |
| Vulnerable & outdated components | Old libraries with known CVEs |
| Identification & authentication failures | Weak login, session handling, no MFA |
| Software & data integrity failures | Untrusted updates, insecure CI/CD pipelines |
| Logging & monitoring failures | Attacks go unnoticed |
| Server-side request forgery (SSRF) | The server is tricked into calling internal URLs (e.g. cloud metadata) |

(The list is revised every few years; check https://owasp.org/Top10/ for the current edition.)

## 5. DevSecOps: security in the pipeline

| Stage | Practice | Tools |
|---|---|---|
| Code | Secret scanning, static analysis (SAST) | GitHub secret scanning, gitleaks, Semgrep, CodeQL |
| Dependencies | Software composition analysis (SCA) | Dependabot, `npm audit`, `pip-audit`, Trivy |
| Containers | Image vulnerability scanning, minimal base images | Trivy, Grype, Docker Scout |
| IaC | Misconfiguration scanning | Checkov, tfsec/Trivy config, tflint |
| Runtime | Threat detection, audit logs | AWS GuardDuty, CloudTrail, Falco |
| Response | Incident response plan, backups tested | Runbooks, game days |

```bash
brew install trivy
trivy image python:3.12-slim                         # scan an image for CVEs
trivy config 05-cloud-devops/terraform/aws-vpc       # scan Terraform for misconfigurations
```

## 6. Incident response (NIST lifecycle, simplified)

1. **Preparation:** plans, contacts, logging, backups
2. **Detection & analysis:** alerts, triage, scope
3. **Containment, eradication & recovery:** isolate, remove the threat, restore
4. **Post-incident activity:** blameless post-mortem, fix root causes

## ✅ Self-check

- [ ] Explain the CIA triad with one cloud example each
- [ ] Explain symmetric vs asymmetric encryption and where SSH and TLS use each
- [ ] Harden a fresh Linux server using the checklist
- [ ] Name 5 items on an AWS account security checklist
- [ ] Explain SQL injection and how parameterized queries prevent it
- [ ] Scan a Docker image and a Terraform folder with Trivy

➡️ **Next:** [07 · Databases](../07-databases/)
