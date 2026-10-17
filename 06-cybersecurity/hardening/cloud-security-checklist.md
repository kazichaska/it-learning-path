# AWS / Cloud Security Checklist

> Most cloud breaches come from **misconfiguration and stolen credentials**, not from clever hacking. This list covers the basics that prevent most of them.

## Account & identity
- [ ] **Root user:** MFA enabled, no access keys, used only for the few tasks that require it
- [ ] People sign in through **IAM Identity Center (SSO)** with MFA; no shared logins
- [ ] Apps and services use **IAM roles** (temporary credentials), not access keys
- [ ] CI/CD uses **OIDC** to assume roles; no long-lived keys stored in GitHub
- [ ] **Least privilege** policies; review with IAM Access Analyzer; remove unused users, roles and keys
- [ ] Separate **AWS accounts** for dev / staging / prod (AWS Organizations), with guardrails (SCPs)

## Logging & detection
- [ ] **CloudTrail** enabled in all regions, logs sent to a protected S3 bucket
- [ ] **GuardDuty** enabled (threat detection)
- [ ] **Security Hub** / **AWS Config** to flag misconfigurations
- [ ] **Billing alerts / AWS Budgets**: crypto-mining after a key leak shows up first as a huge bill
- [ ] VPC Flow Logs for important VPCs

## Network
- [ ] No security group allows `0.0.0.0/0` on SSH (22), RDP (3389) or database ports
- [ ] Databases and app servers in **private subnets**
- [ ] Security groups reference other security groups instead of wide CIDR ranges
- [ ] Public web apps behind a load balancer/CloudFront with **AWS WAF** where appropriate
- [ ] **VPC endpoints** for S3/DynamoDB traffic that shouldn't cross the internet

## Data
- [ ] **S3 Block Public Access** enabled at the account level
- [ ] Encryption at rest on by default: S3, EBS, RDS (KMS)
- [ ] TLS everywhere; certificates managed by **ACM** (auto-renewal)
- [ ] Backups automated (AWS Backup), **cross-account or with Object Lock** so ransomware can't delete them
- [ ] Secrets in **Secrets Manager** / **SSM Parameter Store**, never in code, AMIs, container images or environment files committed to Git

## Compute & containers
- [ ] **IMDSv2 required** on EC2 (protects the metadata service from SSRF attacks)
- [ ] Patch management (SSM Patch Manager) or immutable images rebuilt regularly
- [ ] Container images scanned (ECR scanning, Trivy) and run as non-root
- [ ] Kubernetes: RBAC least privilege, network policies, no privileged pods, secrets encrypted

## Infrastructure as Code
- [ ] All infrastructure in Terraform/CloudFormation, changed only through reviewed PRs
- [ ] IaC scanned in CI (Checkov, Trivy config, tflint)
- [ ] Terraform state stored encrypted with restricted access (it can contain secrets)

## If an access key leaks 🚨
1. **Deactivate/delete the key immediately** (IAM console or `aws iam update-access-key --status Inactive`)
2. Check **CloudTrail** for what the key did
3. Look for new IAM users/keys/roles, unknown EC2 instances in **all regions**, Lambda functions
4. Rotate any other secrets that may have been exposed
5. Remove the key from Git history and enable push protection
6. Contact AWS Support if needed; write a post-mortem
