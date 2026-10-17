# 🚀 IT Learning Path

My journey to becoming a **Cloud & DevOps engineer**: structured notes, hands-on labs, runnable scripts and real infrastructure code, from computer basics to Kubernetes.

![CI](https://github.com/kazichaska/it-learning-path/actions/workflows/ci.yml/badge.svg)

## 📚 Roadmap

| # | Topic | Covers | Hands-on highlights | Status |
|---|---|---|---|---|
| 01 | [Foundations](01-foundations/) | How computers, operating systems and the internet work | Inspect your own hardware, trace a web request | ⬜ |
| 02 | [Linux & command line](02-linux/) | Shell, files, permissions, processes, Bash scripting | [3 production-style scripts](02-linux/scripts/), [cheat sheet](02-linux/cheatsheet.md) | 🟡 |
| 03 | [Networking](03-networking/) | TCP/IP, DNS, HTTP, subnets, firewalls, troubleshooting | [3 labs](03-networking/labs/), [subnet calculator](03-networking/labs/subnet_calculator.py) | 🟡 |
| 04 | [Programming](04-programming/) | Python, JavaScript, Git, debugging | [Log analyzer](04-programming/python/log_analyzer.py), [health checker](04-programming/javascript/health-check.js) | ⬜ |
| 05 | [Cloud & DevOps](05-cloud-devops/) | AWS, Docker, CI/CD, Terraform, Kubernetes, monitoring | [Docker app](05-cloud-devops/docker/example-app/), [Terraform VPC](05-cloud-devops/terraform/aws-vpc/), [K8s manifests](05-cloud-devops/kubernetes/manifests/) | ⬜ |
| 06 | [Cybersecurity](06-cybersecurity/) | Security basics, hardening, ethical hacking, Security+ | [Hardening checklists](06-cybersecurity/hardening/), [Security+ plan](06-cybersecurity/security-plus/) | ⬜ |
| 07 | [Databases](07-databases/) | SQL, data modeling, PostgreSQL | [Practice DB](07-databases/sql/), [15 SQL exercises](07-databases/sql/exercises.md) | ⬜ |
| 08 | [Careers & certifications](08-careers/) | Roadmaps, CompTIA/AWS/CCNA prep, interviews | [32 interview Q&As](08-careers/interview-prep/), [cert paths](08-careers/certifications/) | ⬜ |

**Legend:** ⬜ Not started · 🟡 In progress · ✅ Done

## 🗂️ Repository structure

```
it-learning-path/
├── 01-foundations/        Computers, operating systems, the internet
├── 02-linux/              notes/ · scripts/ · cheatsheet.md
├── 03-networking/         notes/ · labs/ (incl. subnet_calculator.py)
├── 04-programming/        python/ · javascript/ · git/ · debugging/
├── 05-cloud-devops/       aws/ · docker/ · cicd/ · terraform/ · kubernetes/ · monitoring/
├── 06-cybersecurity/      hardening/ · security-plus/ · ethical-hacking.md
├── 07-databases/          sql/ · postgresql/
├── 08-careers/            certifications/ · interview-prep/
├── .github/workflows/     ci.yml: lint, test, Terraform and Docker checks on every push
├── STUDY-LOG.md           Daily/weekly learning journal
└── README.md              You are here
```

## 🧭 How to use this repo

1. **Follow the sections in order.** Each section README has lessons, a self-check list and a link to the next section.
2. **Do the labs, don't just read.** Every section has commands to run and exercises with hidden answers.
3. **Write in your own words.** Add notes, mistakes and "aha" moments to the files or to [`STUDY-LOG.md`](STUDY-LOG.md).
4. **Commit after every session.** Your GitHub activity becomes proof of consistent learning:
   ```bash
   git add .
   git commit -m "Complete networking lab 2"
   git push
   ```
5. **Update the status column above** as you finish each topic.

## ✅ Quick start: try the tools

```bash
# Linux: system health snapshot
bash 02-linux/scripts/system-health.sh

# Networking: subnet maths
python3 03-networking/labs/subnet_calculator.py 10.0.0.0/16 --split 24

# Python: analyse a web server log
python3 04-programming/python/log_analyzer.py 04-programming/python/sample-access.log

# JavaScript: check websites in parallel
node 04-programming/javascript/health-check.js https://example.com https://github.com

# Docker: build and run the example app (needs Docker running)
docker build -t example-app:1.0 05-cloud-devops/docker/example-app
docker run --rm -p 8080:8080 example-app:1.0
```

## ⚙️ Continuous integration

Every push runs [`.github/workflows/ci.yml`](.github/workflows/ci.yml): ShellCheck on Bash scripts, syntax checks for Python and JavaScript, smoke tests of the tools, `terraform fmt`/`validate`, and a Docker build plus health check. See the **Actions** tab, and read how it works in [CI/CD notes](05-cloud-devops/cicd/).

## ⚠️ Safety notes

- **Never commit secrets** (keys, passwords, `.env` files, Terraform state). See [`.gitignore`](.gitignore).
- **AWS costs money.** Set a budget alert before your first lab and destroy resources when done (see the cost rules in [Cloud & DevOps](05-cloud-devops/)).
- Only practise security testing on systems you own or have written permission to test.
