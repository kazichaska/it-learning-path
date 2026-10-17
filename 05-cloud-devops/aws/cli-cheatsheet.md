# AWS CLI Cheat Sheet

```bash
brew install awscli
aws --version
```

## Auth & identity
```bash
aws configure sso                       # one-time SSO profile setup (recommended)
aws sso login --profile dev
export AWS_PROFILE=dev                  # use this profile for the session
aws sts get-caller-identity             # "who am I?" Run this first when debugging AccessDenied
aws configure list                      # which credentials/region are active
```

## Output tricks
```bash
aws ec2 describe-instances --output table
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType]' --output table
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text
```
`--query` uses **JMESPath** to pick fields; `--filters` filters on the server side.

## EC2
```bash
aws ec2 describe-instances --output table
aws ec2 start-instances --instance-ids i-0123456789abcdef0
aws ec2 stop-instances  --instance-ids i-0123456789abcdef0
aws ec2 describe-security-groups --group-ids sg-0123456789abcdef0
aws ec2 describe-vpcs --query 'Vpcs[].[VpcId,CidrBlock]' --output table
aws ssm start-session --target i-0123456789abcdef0     # shell without SSH (needs the SSM plugin)
```

## S3
```bash
aws s3 ls                                          # list buckets
aws s3 ls s3://my-bucket/path/                     # list objects
aws s3 cp file.txt s3://my-bucket/                 # upload
aws s3 cp s3://my-bucket/file.txt .                # download
aws s3 sync ./site s3://my-bucket --delete         # sync a folder (static website deploys)
aws s3 presign s3://my-bucket/report.pdf --expires-in 3600   # temporary share link
```

## IAM
```bash
aws iam list-roles --query 'Roles[].RoleName' --output text
aws iam list-attached-role-policies --role-name my-role
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::123456789012:role/my-role --action-names s3:GetObject
```

## Logs & monitoring
```bash
aws logs tail /aws/lambda/my-function --follow       # live logs
aws cloudwatch describe-alarms --state-value ALARM
```

## ECR (Docker registry)
```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
docker tag myapp:1.0 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0
```

## EKS
```bash
aws eks update-kubeconfig --name my-cluster --region us-east-1   # point kubectl at the cluster
kubectl get nodes
```

## Cost
```bash
aws ce get-cost-and-usage --time-period Start=2026-10-01,End=2026-10-14 \
  --granularity MONTHLY --metrics UnblendedCost
```
