# Solution Core Module - Outputs
# These outputs are used by other solution modules (database, cache, security, monitoring)

#------------------------------------------------------------------------------
# VPC Outputs (from generic VPC module)
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

#------------------------------------------------------------------------------
# Subnet Outputs (from generic VPC module)
#------------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.vpc.database_subnet_ids
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = module.vpc.db_subnet_group_name
}

output "elasticache_subnet_group_name" {
  description = "ElastiCache subnet group name"
  value       = module.vpc.elasticache_subnet_group_name
}

#------------------------------------------------------------------------------
# Security Group Outputs
#------------------------------------------------------------------------------

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "instances_security_group_id" {
  description = "Instances security group ID"
  value       = aws_security_group.instances.id
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.database.id
}

output "cache_security_group_id" {
  description = "Cache security group ID"
  value       = aws_security_group.cache.id
}

#------------------------------------------------------------------------------
# Load Balancer Outputs (from generic ALB module)
#------------------------------------------------------------------------------

output "alb_arn" {
  description = "ALB ARN"
  value       = var.enable_alb ? module.alb[0].alb_arn : null
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = var.enable_alb ? module.alb[0].alb_dns_name : null
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = var.enable_alb ? module.alb[0].alb_zone_id : null
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = var.enable_alb ? module.alb[0].target_group_arn : null
}

#------------------------------------------------------------------------------
# Auto Scaling Outputs (from generic ASG module)
#------------------------------------------------------------------------------

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = var.enable_auto_scaling ? module.asg[0].asg_name : null
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = var.enable_auto_scaling ? module.asg[0].asg_arn : null
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = var.enable_auto_scaling ? module.asg[0].launch_template_id : null
}

#------------------------------------------------------------------------------
# IAM Outputs
#------------------------------------------------------------------------------

output "instance_role_arn" {
  description = "Instance IAM role ARN"
  value       = var.enable_instance_profile ? aws_iam_role.instances[0].arn : null
}

output "instance_profile_arn" {
  description = "Instance profile ARN"
  value       = var.enable_instance_profile ? aws_iam_instance_profile.instances[0].arn : null
}

#------------------------------------------------------------------------------
# Naming Outputs (for other modules to use consistent naming)
#------------------------------------------------------------------------------

output "name_prefix" {
  description = "Name prefix used for resources"
  value       = local.name_prefix
}

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}
