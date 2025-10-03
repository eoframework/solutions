# AWS Module Outputs
# Outputs from AWS-specific resources

# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.networking.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.networking.nat_gateway_ids
}

# Security Outputs
output "security_group_ids" {
  description = "IDs of the security groups"
  value       = module.security.security_group_ids
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = module.security.kms_key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.security.kms_key_arn
}

# Compute Outputs
output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = module.compute.instance_ids
}

output "auto_scaling_group_arns" {
  description = "ARNs of the Auto Scaling Groups"
  value       = module.compute.auto_scaling_group_arns
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.compute.load_balancer_dns
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = module.compute.load_balancer_arn
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.compute.rds_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS database port"
  value       = module.compute.rds_port
}

# Resource Summary
output "aws_resource_summary" {
  description = "Summary of AWS resources created"
  value = {
    region             = var.region
    vpc_cidr          = var.vpc_cidr
    availability_zones = var.availability_zones
    instances_created  = length(var.instances)
    load_balancer_enabled = var.enable_load_balancer
    auto_scaling_enabled  = var.enable_auto_scaling
    kms_encryption_enabled = var.enable_kms_encryption
  }
}