# 05 · Cloud & DevOps

> **Goal:** Build, ship and run applications in the cloud automatically and reliably: containerize an app, deploy it with a CI/CD pipeline, describe infrastructure as code, run it on Kubernetes and monitor it.

## What DevOps really is

DevOps is a **culture plus practices** where the team that builds software also owns running it, with **automation** replacing manual steps:

```
 Plan → Code → Build → Test → Release → Deploy → Operate → Monitor
   ▲                                                         │
   └──────────────────────── feedback ───────────────────────┘
```

**A DevOps engineer's job:** make releasing software **fast, safe and boring** (automated, repeatable, predictable).

## 📚 Topics (in learning order)

| # | Folder | What you'll learn | Hands-on |
|---|---|---|---|
| 1 | [`aws/`](aws/) | Core AWS: IAM, VPC, EC2, S3, RDS, Lambda, CloudWatch, cost control | CLI cheat sheet, AWS vs Azure vs GCP comparison |
| 2 | [`docker/`](docker/) | Images, containers, Dockerfiles, volumes, networks, Compose | [`example-app/`](docker/example-app/): containerize a Python web app |
| 3 | [`cicd/`](cicd/) | CI vs CD, pipelines, GitHub Actions | This repo's own [CI workflow](../.github/workflows/ci.yml) + build-and-push example |
| 4 | [`terraform/`](terraform/) | Infrastructure as Code, state, plan/apply, modules | [`aws-vpc/`](terraform/aws-vpc/): a real multi-AZ VPC |
| 5 | [`kubernetes/`](kubernetes/) | Pods, Deployments, Services, Ingress, ConfigMaps, troubleshooting | [`manifests/`](kubernetes/manifests/): deploy the example app |
| 6 | [`monitoring/`](monitoring/) | Metrics, logs, traces, alerts, SLOs | Prometheus + Grafana with Docker Compose |

## 🔗 How the pieces fit together (the project you'll build)

```
  git push ──▶ GitHub Actions (CI) ──▶ build & test ──▶ Docker image ──▶ registry (GHCR/ECR)
                                                                            │
  Terraform ──▶ AWS: VPC, subnets, security groups, EKS/ECS, RDS            │
                                                                            ▼
                                             Kubernetes pulls the image and runs it
                                                                            │
                                     Prometheus/Grafana/CloudWatch watch it ◀┘
```

## ⚠️ Cloud cost safety rules (read before touching AWS)

1. **Enable MFA** on the root account, then stop using root. Create an admin user via IAM Identity Center.
2. **Create a budget alert** (AWS Budgets → e.g. $10/month, email alert) on day one.
3. Watch out for things that cost money while idle: **NAT Gateways, load balancers, EKS control planes, RDS instances, public IPv4 addresses, unattached EBS volumes**.
4. **`terraform destroy`** (or delete resources) when you finish a lab.
5. Never commit access keys. Prefer `aws sso login` / temporary credentials.

## ✅ Self-check

- [ ] Explain IAM users vs roles vs policies, and least privilege
- [ ] Draw a VPC with public/private subnets across 2 AZs
- [ ] Write a production-quality Dockerfile (small, non-root, cached layers)
- [ ] Explain CI vs continuous delivery vs continuous deployment
- [ ] Run `terraform plan/apply/destroy` and explain what state is
- [ ] Deploy an app to Kubernetes with a Deployment + Service and debug a `CrashLoopBackOff`
- [ ] Explain the difference between metrics, logs and traces

➡️ **Next:** [06 · Cybersecurity](../06-cybersecurity/)
