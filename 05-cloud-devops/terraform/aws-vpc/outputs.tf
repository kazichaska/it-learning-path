output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "availability_zones" {
  description = "AZs the subnets were created in"
  value       = local.azs
}

output "public_subnets" {
  description = "Public subnet IDs and CIDRs"
  value       = { for s in aws_subnet.public : s.id => s.cidr_block }
}

output "private_subnets" {
  description = "Private subnet IDs and CIDRs"
  value       = { for s in aws_subnet.private : s.id => s.cidr_block }
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}
