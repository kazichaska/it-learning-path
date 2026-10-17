terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # For team use, store state remotely instead of on your laptop, e.g.:
  # backend "s3" {
  #   bucket       = "my-terraform-state-123456789012"
  #   key          = "learning/aws-vpc/terraform.tfstate"
  #   region       = "us-east-1"
  #   use_lockfile = true # S3-native state locking (Terraform 1.10+)
  # }
}
