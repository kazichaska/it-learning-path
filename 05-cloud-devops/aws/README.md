# AWS (Amazon Web Services)

> AWS is the largest cloud provider. Learn one cloud deeply; the concepts transfer to Azure and GCP (see the [comparison](cloud-provider-comparison.md)).

## Global infrastructure

| Term | Meaning |
|---|---|
| **Region** | A geographic area (e.g. `us-east-1` N. Virginia, `eu-west-1` Ireland). Pick by latency, cost, data laws |
| **Availability Zone (AZ)** | One or more isolated data centres in a region (`us-east-1a`, `-1b`…). **Spread across ≥2 AZs for high availability** |
| **Edge location** | CDN/DNS points of presence (CloudFront, Route 53) |

## The shared responsibility model

| AWS is responsible for… ("security **of** the cloud") | You are responsible for… ("security **in** the cloud") |
|---|---|
| Physical data centres, hardware, hypervisor, global network | IAM users/permissions, security groups, OS patching on EC2, encryption settings, your data, your app code |

The more managed the service (Lambda, S3), the less you manage, but **IAM and data are always yours**.

## Core services map

| Category | Service | One-line description |
|---|---|---|
| Identity | **IAM** / IAM Identity Center | Who can do what |
| Compute | **EC2** | Virtual machines |
| | **Lambda** | Run functions without servers; pay per request |
| | **ECS** / **Fargate** | Run containers (Fargate = no servers to manage) |
| | **EKS** | Managed Kubernetes |
| Storage | **S3** | Object storage (files) with 11 nines of durability |
| | **EBS** | Disks attached to EC2 |
| | **EFS** | Shared network file system |
| Database | **RDS** / **Aurora** | Managed relational DBs (PostgreSQL, MySQL…) |
| | **DynamoDB** | Serverless NoSQL key-value DB |
| | **ElastiCache** | Managed Redis/Valkey/Memcached |
| Networking | **VPC** | Your private network |
| | **Route 53** | DNS |
| | **ELB** (ALB/NLB) | Load balancers |
| | **CloudFront** | CDN |
| Containers | **ECR** | Docker image registry |
| Monitoring | **CloudWatch** | Metrics, logs, alarms |
| | **CloudTrail** | Audit log of every API call ("who deleted that?") |
| Security | **KMS**, **Secrets Manager**, **ACM**, **WAF**, **GuardDuty** | Keys, secrets, certificates, web firewall, threat detection |
| IaC | **CloudFormation** / **CDK** | AWS-native infrastructure as code (Terraform is the cross-cloud alternative) |

## IAM: the most important service

| Concept | Meaning |
|---|---|
| **User** | A person or app with long-term credentials. Avoid for apps; prefer SSO for people |
| **Group** | A collection of users sharing permissions |
| **Role** | An identity **assumed temporarily** by EC2, Lambda, CI pipelines or people. **No long-term keys** |
| **Policy** | A JSON document of allowed/denied actions on resources |

### A least-privilege policy example
Read-only access to **one** S3 bucket:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::my-app-reports"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::my-app-reports/*"
    }
  ]
}
```
**Evaluation rules:** everything is denied by default → an explicit `Allow` grants → an explicit `Deny` always wins.

### IAM best practices
- Lock away the **root** user (MFA, no access keys)
- People log in via **IAM Identity Center (SSO)**; apps use **roles**
- **Least privilege:** start small, add permissions as needed
- CI/CD (GitHub Actions) should use **OIDC** to assume a role, with no stored AWS keys
- Review with **IAM Access Analyzer**

## VPC essentials

See [IP addressing & subnets](../../03-networking/notes/02-ip-addressing-and-subnets.md) and [firewalls & security groups](../../03-networking/notes/06-firewalls-and-security-groups.md) for the theory, and [Terraform › aws-vpc](../terraform/aws-vpc/) for the code.

| Component | Purpose |
|---|---|
| VPC | Your private network (e.g. `10.0.0.0/16`) |
| Subnet | A slice of the VPC in one AZ; public or private |
| Route table | Where traffic goes (e.g. `0.0.0.0/0 → igw-…`) |
| Internet Gateway | Lets public subnets talk to the internet |
| NAT Gateway | Lets private subnets reach out (updates, APIs) without being reachable |
| Security group | Stateful firewall on each resource |
| VPC endpoint | Private access to S3/DynamoDB/other AWS services |

## EC2 essentials

- **Instance types:** `t3.micro` = family `t` (burstable), generation `3`, size `micro`. Families: `t` burstable, `m` general, `c` compute, `r` memory, `g/p` GPU. A `g` after the number (`t4g`, `m7g`) = **Graviton (ARM)**.
- **AMI:** the OS image to boot from
- **User data:** a script that runs at first boot (bootstrap software)
- **Pricing:** On-Demand · Savings Plans/Reserved (commit 1–3 years, big discounts) · **Spot** (up to ~90% off, can be interrupted)
- **Auto Scaling Group:** keeps N healthy instances, scales on load, replaces failed ones

## S3 essentials

- Buckets (globally unique names) hold objects (files) addressed by key
- **Block Public Access** is on by default; keep it on unless hosting a public site (prefer CloudFront in front)
- Storage classes: Standard → Intelligent-Tiering → Glacier (cheap archive)
- Versioning + lifecycle rules (e.g. move to Glacier after 90 days, delete after 1 year)

## Getting started safely

1. Create an account → **MFA on root** → **budget alert**
2. Enable **IAM Identity Center** and create an admin user for yourself
3. Install the CLI: `brew install awscli`, then `aws configure sso` and `aws sso login`
4. Verify: `aws sts get-caller-identity`

More: [AWS CLI cheat sheet](cli-cheatsheet.md)

## 🧪 Lab ideas (in order)

1. Host a static website: S3 + CloudFront + ACM certificate
2. Launch an EC2 instance in a public subnet, install nginx via user data, restrict SSH to your IP (or use SSM)
3. Build the VPC from [Terraform › aws-vpc](../terraform/aws-vpc/) and put an EC2 instance in a private subnet
4. Write a Lambda function triggered by an S3 upload
5. Run the [Docker example app](../docker/example-app/) on ECS Fargate behind an ALB

## 🎓 Certifications

AWS Certified Cloud Practitioner → Solutions Architect Associate → SysOps/DevOps Engineer. See [08 · Careers › certifications](../../08-careers/certifications/).

## 📚 Learn more
- AWS Skill Builder (many free courses): https://skillbuilder.aws/
- AWS Well-Architected Framework: https://aws.amazon.com/architecture/well-architected/
