# Terraform (Infrastructure as Code)

> Instead of clicking around the AWS console, you **describe your infrastructure in code**. Terraform figures out what to create, change or delete to make reality match that code.

## Why Infrastructure as Code (IaC)?

| Clicking in the console | Terraform |
|---|---|
| Hard to repeat exactly (dev vs prod drift) | Same code → same infrastructure, every time |
| No history of who changed what | Every change is a Git commit and a reviewed PR |
| Hard to tear down (forgotten resources = surprise bills) | `terraform destroy` removes everything it created |
| Knowledge lives in someone's head | The code *is* the documentation |

## Core concepts

| Concept | Meaning |
|---|---|
| **Provider** | Plugin that talks to an API: `aws`, `azurerm`, `google`, `kubernetes`, `github`, `cloudflare`… |
| **Resource** | Something Terraform creates and manages: `aws_vpc`, `aws_instance`, `aws_s3_bucket` |
| **Data source** | Something Terraform only **reads** (e.g. the list of AZs, the latest AMI) |
| **Variable** | An input (`var.region`) |
| **Output** | A value printed after apply / used by other configurations |
| **Local** | A named expression to avoid repetition (`local.azs`) |
| **Module** | A reusable folder of Terraform code (like a function) |
| **State** | Terraform's record of what it created (`terraform.tfstate`), mapping your code to real resource IDs |

**Declarative:** you say *what* you want ("a VPC with this CIDR"), not *how* to create it. Terraform builds a dependency graph and works out the order.

## The workflow

```bash
terraform init        # download providers, set up the backend (once per folder / after changes)
terraform fmt         # format the code
terraform validate    # check syntax and references
terraform plan        # PREVIEW: what will be created (+), changed (~), destroyed (-)
terraform apply       # do it (shows the plan again and asks for "yes")
terraform output      # show outputs
terraform destroy     # delete everything this config manages
```

🔑 **Always read the plan.** Especially lines with `-/+` (**replace**: destroy then recreate), which can mean data loss for databases.

## State: the most important thing to understand

- State maps `aws_vpc.main` in your code → `vpc-0abc123` in AWS.
- **Never edit state by hand**, and **never commit it to Git**: it can contain secrets (already in this repo's `.gitignore`).
- For teams, store state **remotely** with **locking**, e.g. an S3 bucket (with `use_lockfile = true` on Terraform 1.10+; older setups used a DynamoDB table). See the commented example in [`aws-vpc/versions.tf`](aws-vpc/versions.tf).
- **Drift:** if someone changes a resource in the console, `terraform plan` shows the difference.

Useful state commands: `terraform state list`, `terraform state show aws_vpc.main`, `terraform import` (bring existing resources under management).

## Syntax tour (HCL)

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id        # reference a data source
  instance_type = var.instance_type             # reference a variable
  subnet_id     = aws_subnet.public[0].id       # reference another resource (creates a dependency)

  tags = {
    Name = "${var.project}-web"                 # string interpolation
  }
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}
```

**Creating several things:** `count = 3` (a list, indexed `[0]`, `[1]`…) or `for_each = toset(["a", "b"])` (a map keyed by name; safer when items are added/removed).

## 🧪 Hands-on: build a real VPC

[`aws-vpc/`](aws-vpc/) creates the network from the [networking notes](../../03-networking/):
- 1 VPC (`10.0.0.0/16`)
- 2 public subnets (`10.0.1.0/24`, `10.0.2.0/24`) routed to an Internet Gateway
- 2 private subnets (`10.0.11.0/24`, `10.0.12.0/24`)
- Security groups: load balancer (80/443 from anywhere) → app (8080 only from the LB's security group)

**It's free while idle** (no NAT Gateway, no instances).

```bash
cd aws-vpc
aws sts get-caller-identity               # make sure you're logged in to the right account
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan                            # read it! ~15 resources to add
terraform apply
terraform output
# look at it in the AWS console: VPC → Your VPCs / Subnets / Route tables / Security groups
terraform destroy                         # clean up
```

### Challenges
1. Set `az_count = 3` and run `plan`. What gets added?
2. Add a `db` security group allowing 5432 only from the app security group.
3. Add a **NAT Gateway** (`aws_eip` + `aws_nat_gateway` in a public subnet, plus a `0.0.0.0/0` route in the private route table). ⚠️ It costs money per hour, so destroy it afterwards.
4. Launch an EC2 instance in a public subnet with the app security group and user data that runs the [example app](../docker/example-app/).
5. Turn the folder into a **module** and call it twice (dev and prod) with different CIDRs.
6. Change something in the AWS console, then run `terraform plan` to see the drift.

## Best practices

- ✅ Remote state with locking; one state per environment/component
- ✅ Pin provider versions; commit `.terraform.lock.hcl`
- ✅ `terraform fmt` + `validate` + `plan` in CI on every PR (this repo's [CI](../../.github/workflows/ci.yml) does the first two)
- ✅ Use modules for repeated patterns; keep them small
- ✅ Tag everything (`default_tags`): project, owner, environment
- ✅ Security scanning: `tflint`, `checkov` or `trivy config`
- ❌ No hard-coded secrets; use AWS Secrets Manager / SSM Parameter Store
- ❌ Don't manage the same resource from two states or by hand

## Terraform vs others

| Tool | Notes |
|---|---|
| **OpenTofu** | Open-source fork of Terraform; nearly identical commands (`tofu plan`) |
| **CloudFormation / CDK** | AWS-only; CDK lets you write TypeScript/Python |
| **Pulumi** | IaC in general-purpose languages |
| **Ansible** | Configuration management (what's *on* the servers), though it can provision too |

## 🎓 Certification
**HashiCorp Certified: Terraform Associate.** See [certifications](../../08-careers/certifications/).

## 📚 Learn more
- Official tutorials: https://developer.hashicorp.com/terraform/tutorials
- AWS provider docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
