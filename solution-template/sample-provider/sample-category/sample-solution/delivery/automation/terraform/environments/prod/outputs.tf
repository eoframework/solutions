# Production Environment Outputs

# =============================================================================
# Naming & Identity
# =============================================================================

output "environment" {
  description = "Environment identifier"
  value       = local.environment
}

output "environment_display" {
  description = "Environment display name"
  value       = lookup(local.env_display_name, local.environment, local.environment)
}

output "name_prefix" {
  description = "Resource naming prefix"
  value       = local.name_prefix
}

output "solution_name" {
  description = "Solution name"
  value       = var.solution_name
}

output "solution_abbr" {
  description = "Solution abbreviation"
  value       = var.solution_abbr
}

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# =============================================================================
# Core Module Outputs
# =============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.core.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.core.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.core.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.core.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs"
  value       = module.core.database_subnet_ids
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.core.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.core.alb_arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.core.asg_name
}

# =============================================================================
# Security Module Outputs
# =============================================================================

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = module.security.kms_key_arn
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = module.security.waf_web_acl_arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.security.guardduty_detector_id
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = module.security.cloudtrail_arn
}

# =============================================================================
# Database Module Outputs
# =============================================================================

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.database.rds_endpoint
}

output "rds_address" {
  description = "RDS address (hostname)"
  value       = module.database.rds_address
}

output "rds_port" {
  description = "RDS port"
  value       = module.database.rds_port
}

output "rds_database_name" {
  description = "Database name"
  value       = module.database.rds_database_name
}

# =============================================================================
# Cache Module Outputs
# =============================================================================

output "cache_endpoint" {
  description = "ElastiCache endpoint"
  value       = module.cache.cache_endpoint
}

output "cache_port" {
  description = "ElastiCache port"
  value       = module.cache.cache_port
}

output "cache_connection_string" {
  description = "Redis connection string"
  value       = module.cache.cache_connection_string
}

# =============================================================================
# Monitoring Module Outputs
# =============================================================================

output "sns_topic_arn" {
  description = "SNS topic ARN for alarms"
  value       = module.monitoring.sns_topic_arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}

output "application_log_group" {
  description = "Application log group name"
  value       = module.monitoring.application_log_group_name
}

# =============================================================================
# Deployment Summary
# =============================================================================

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    # Identity
    solution_name    = var.solution_name
    solution_abbr    = var.solution_abbr
    environment      = local.environment
    environment_name = lookup(local.env_display_name, local.environment, local.environment)
    name_prefix      = local.name_prefix
    region           = var.aws_region

    # Ownership
    cost_center  = var.cost_center
    owner        = var.owner_email
    project_code = var.project_code

    # Resources
    vpc_id          = module.core.vpc_id
    alb_dns_name    = module.core.alb_dns_name
    rds_endpoint    = module.database.rds_endpoint
    cache_endpoint  = module.cache.cache_endpoint

    # Modules deployed
    deployed_modules = ["core", "security", "database", "cache", "monitoring"]

    # Timestamp
    deployment_time = timestamp()
  }
}
