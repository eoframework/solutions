#------------------------------------------------------------------------------
# Terraform Enterprise Production Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Platform Outputs
#------------------------------------------------------------------------------
output "tfe_organization_name" {
  description = "Terraform Enterprise organization name"
  value       = module.tfe.organization_name
}

output "tfe_url" {
  description = "Terraform Enterprise URL"
  value       = "https://${var.tfe.hostname}"
}

output "tfe_api_endpoint" {
  description = "Terraform Enterprise API endpoint"
  value       = "https://${var.tfe.hostname}/api/v2"
}

#------------------------------------------------------------------------------
# Infrastructure Outputs
#------------------------------------------------------------------------------
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = module.database.rds_identifier
}

#------------------------------------------------------------------------------
# Networking Outputs
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

#------------------------------------------------------------------------------
# Security Outputs
#------------------------------------------------------------------------------
output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = module.security.kms_key_arn
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = var.security.enable_waf ? module.security.waf_web_acl_arn : null
}

#------------------------------------------------------------------------------
# Governance Outputs
#------------------------------------------------------------------------------
output "sentinel_policy_sets" {
  description = "List of Sentinel policy sets"
  value       = var.sentinel.enabled ? module.sentinel[0].policy_set_names : []
}

#------------------------------------------------------------------------------
# Monitoring Outputs
#------------------------------------------------------------------------------
output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = var.monitoring.enable_dashboard ? module.monitoring.dashboard_url : null
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Workspace Statistics
#------------------------------------------------------------------------------
output "workspace_count" {
  description = "Number of configured workspaces"
  value       = var.tfe.workspace_count
}

output "user_count" {
  description = "Number of platform users"
  value       = var.tfe.user_count
}

output "concurrent_runs" {
  description = "Maximum concurrent Terraform runs"
  value       = var.tfe.concurrent_runs
}

#------------------------------------------------------------------------------
# Environment Information
#------------------------------------------------------------------------------
output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "region" {
  description = "AWS region"
  value       = var.aws.region
}

output "dr_region" {
  description = "DR region for failover"
  value       = var.aws.dr_region
}
