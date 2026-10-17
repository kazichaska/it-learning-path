# AWS vs Azure vs Google Cloud

The concepts are the same; the names differ. Learn one well, then map.

| Category | AWS | Azure | Google Cloud |
|---|---|---|---|
| Virtual machines | EC2 | Virtual Machines | Compute Engine |
| Autoscaling VM groups | Auto Scaling Groups | VM Scale Sets | Managed Instance Groups |
| Serverless functions | Lambda | Functions | Cloud Run functions |
| Serverless containers | Fargate / App Runner | Container Apps | Cloud Run |
| Managed Kubernetes | EKS | AKS | GKE |
| Container registry | ECR | Container Registry (ACR) | Artifact Registry |
| Object storage | S3 | Blob Storage | Cloud Storage |
| Block storage | EBS | Managed Disks | Persistent Disk |
| File storage | EFS | Azure Files | Filestore |
| Managed SQL | RDS / Aurora | Azure SQL / Database for PostgreSQL | Cloud SQL / AlloyDB |
| NoSQL | DynamoDB | Cosmos DB | Firestore / Bigtable |
| Private network | VPC | Virtual Network (VNet) | VPC (global) |
| Firewall rules | Security Groups / NACLs | Network Security Groups | VPC firewall rules |
| Load balancer | ALB / NLB | Application Gateway / Load Balancer | Cloud Load Balancing |
| DNS | Route 53 | Azure DNS | Cloud DNS |
| CDN | CloudFront | Front Door / Azure CDN | Cloud CDN |
| Identity & access | IAM / IAM Identity Center | Microsoft Entra ID + RBAC | Cloud IAM |
| Secrets | Secrets Manager | Key Vault | Secret Manager |
| Monitoring & logs | CloudWatch | Azure Monitor | Cloud Monitoring / Cloud Logging |
| Audit log | CloudTrail | Activity Log | Cloud Audit Logs |
| Native IaC | CloudFormation / CDK | ARM / Bicep | Infrastructure Manager (Terraform-based) |
| CI/CD | CodePipeline / CodeBuild | Azure DevOps Pipelines | Cloud Build |

## Notable differences

- **Azure** is strongest in Microsoft-centric companies (Active Directory/Entra ID, Windows, .NET, Office 365). Resources are organized in **resource groups**.
- **Google Cloud** is known for Kubernetes (GKE; Google created Kubernetes), data/analytics (BigQuery) and a global VPC model. Resources are organized in **projects**.
- **AWS** has the largest market share and service catalogue; organized by **accounts** (managed with AWS Organizations).

## Which should you learn first?

Check job postings in your area. AWS is the safest default for most Cloud/DevOps roles; Azure is a strong second, especially in enterprises.
