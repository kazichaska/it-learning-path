# 08 · Careers & Certifications

> **Goal:** Turn your skills into a job: choose a target role, follow a realistic roadmap, build proof (projects + certifications), and prepare for interviews.

## 📚 Contents

| Topic | Where |
|---|---|
| Roles, roadmap, portfolio, job search | This page ⬇️ |
| Certification paths and study strategy | [`certifications/`](certifications/) |
| Interview questions with answers | [`interview-prep/`](interview-prep/) |

## 1. Roles in Cloud, DevOps and infrastructure

| Role | What you do day to day | Core skills |
|---|---|---|
| **IT support / helpdesk** | Fix user and device issues, accounts, basic networking | Troubleshooting, Windows/macOS, networking basics, communication |
| **Systems administrator** | Run servers, users, backups, patching | Linux/Windows Server, scripting, networking, virtualization |
| **Cloud engineer** | Build and operate cloud infrastructure | AWS/Azure, networking, IAM, Terraform, scripting |
| **DevOps engineer** | CI/CD, automation, containers, developer platforms | Git, CI/CD, Docker, Kubernetes, IaC, Linux, a programming language |
| **Site Reliability Engineer (SRE)** | Reliability, monitoring, incident response, performance | All of the above + SLOs, observability, stronger coding |
| **Platform engineer** | Build internal platforms ("paved roads") for developers | Kubernetes, IaC, CI/CD, developer experience |
| **Cloud security engineer** | Secure cloud accounts, detect threats | IAM, networking, logging, security tooling, compliance |
| **Database administrator / data platform** | Run and tune databases | SQL, PostgreSQL/MySQL, backups, performance |

💡 Many people enter through **helpdesk → sysadmin → cloud/DevOps**. With strong projects, going directly to a junior cloud/DevOps role is possible but competitive.

## 2. A realistic 12-month roadmap (≈10 hours/week)

| Months | Focus | Proof you can show |
|---|---|---|
| 1–2 | [Foundations](../01-foundations/), [Linux](../02-linux/), [Networking](../03-networking/) | Linux scripts in this repo; networking labs completed |
| 3 | [Git](../04-programming/git/) + [Python](../04-programming/python/) | Small automation tools on GitHub |
| 4–5 | [AWS](../05-cloud-devops/aws/) | **AWS Cloud Practitioner** (optional) → static site on S3 + CloudFront |
| 6 | [Docker](../05-cloud-devops/docker/) + [CI/CD](../05-cloud-devops/cicd/) | Containerized app with a GitHub Actions pipeline |
| 7–8 | [Terraform](../05-cloud-devops/terraform/) + AWS deeper | **AWS Solutions Architect – Associate**; infra built entirely with Terraform |
| 9–10 | [Kubernetes](../05-cloud-devops/kubernetes/) + [monitoring](../05-cloud-devops/monitoring/) | App on Kubernetes with dashboards and alerts |
| 11–12 | Capstone project + job search | Portfolio project, polished resume, interview practice |

## 3. Portfolio projects that impress

Build them **in public on GitHub**, with a clear README, an architecture diagram and "what I learned."

1. **Static website with CI/CD:** S3 + CloudFront + ACM + Route 53; GitHub Actions deploys on push via OIDC (no stored keys)
2. **Three-tier app on AWS with Terraform:** VPC (public/private subnets), ALB, auto-scaling EC2 or ECS Fargate, RDS PostgreSQL in private subnets
3. **Containerized app on Kubernetes:** the [example app](../05-cloud-devops/docker/example-app/) with Helm/Kustomize, Ingress, HPA, Prometheus + Grafana
4. **Automation toolkit:** Python/Bash tools (log analysis, backups to S3, cost reports with boto3)
5. **Serverless project:** API Gateway + Lambda + DynamoDB, deployed with Terraform or AWS SAM
6. **Monitoring & incident write-up:** break something on purpose, detect it with alerts, write a blameless post-mortem

**The capstone (combine everything):** Terraform builds the network and an EKS/ECS cluster → GitHub Actions builds, scans and pushes the image → deploys it → Grafana/CloudWatch dashboards and alerts → README with architecture diagram, costs and teardown instructions.

## 4. Resume tips for technical roles

- **One page** (two at most with experience), clean format, no photos or graphics
- Lead with a **skills section** grouped by area (Cloud: AWS… · IaC: Terraform… · Containers: Docker, Kubernetes…)
- Write bullets as **action + what + result**: *"Automated nightly backups with Bash and cron, cutting manual work by 2 hours/week"*
- Link your **GitHub** and pinned projects; recruiters do click
- Mirror keywords from the job description (many companies use applicant tracking systems)
- Put certifications in their own section, with the date earned

## 5. Job search strategy

1. Pick **one target role** and tailor everything to it
2. Apply consistently (e.g. 5–10 tailored applications per week) and track them in a spreadsheet
3. **Network:** LinkedIn posts about what you're building, local meetups (AWS User Groups, DevOps Days), online communities
4. Ask for **referrals**; they have much higher response rates than cold applications
5. Practise interviews out loud (see [`interview-prep/`](interview-prep/)); do mock interviews with friends
6. After each interview, write down the questions you struggled with and study them

## 6. Learning resources (free unless noted)

| Topic | Resource |
|---|---|
| Roadmaps | https://roadmap.sh/devops |
| Linux | OverTheWire Bandit: https://overthewire.org/wargames/bandit/ |
| AWS | AWS Skill Builder: https://skillbuilder.aws/ |
| Azure | Microsoft Learn: https://learn.microsoft.com/training/ |
| Kubernetes | Official tutorials: https://kubernetes.io/docs/tutorials/ |
| Terraform | https://developer.hashicorp.com/terraform/tutorials |
| SQL | https://sqlbolt.com/ · https://pgexercises.com/ |
| Security | TryHackMe (free + paid), PortSwigger Web Security Academy |
| Hands-on labs (paid) | KodeKloud, A Cloud Guru/Pluralsight, Udemy courses (wait for sales) |
