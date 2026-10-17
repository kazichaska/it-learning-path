variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Name prefix for all resources"
  type        = string
  default     = "it-learning"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (a /16 gives room for 256 /24 subnets)"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && tonumber(split("/", var.vpc_cidr)[1]) <= 20
    error_message = "vpc_cidr must be a valid IPv4 CIDR block of size /20 or larger (e.g. 10.0.0.0/16)."
  }
}

variable "az_count" {
  description = "How many Availability Zones to spread subnets across"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "Use 2 or 3 Availability Zones."
  }
}

variable "allowed_ssh_cidr" {
  description = "Your IP in CIDR form (e.g. 203.0.113.7/32) to allow SSH. Leave null to allow no SSH at all."
  type        = string
  default     = null
}
