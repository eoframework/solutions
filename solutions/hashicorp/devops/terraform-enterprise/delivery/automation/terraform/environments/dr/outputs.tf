#------------------------------------------------------------------------------
# Terraform Enterprise DR Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Platform Outputs
#------------------------------------------------------------------------------
output "tfe_organization_name" {
  description = "Terraform Enterprise organization name"
  value       = module.tfe.organization_name
}

output "tfe_url" {
  description = "Terraform Enterprise DR URL"
  value       = "https://${var.tfe.hostname}"
}

output "tfe_api_endpoint" {
  description = "Terraform Enterprise DR API endpoint"
  value       = "https://${var.tfe.hostname}/api/v2"
}

#------------------------------------------------------------------------------
# Infrastructure Outputs
#------------------------------------------------------------------------------
output "eks_cluster_name" {
  description = "DR EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "DR EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "DR RDS PostgreSQL endpoint"
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "rds_identifier" {
  description = "DR RDS instance identifier"
  value       = module.database.rds_identifier
}

#------------------------------------------------------------------------------
# Networking Outputs
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "DR VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "DR Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "DR Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

#------------------------------------------------------------------------------
# Security Outputs
#------------------------------------------------------------------------------
output "kms_key_arn" {
  description = "DR KMS key ARN for encryption"
  value       = module.security.kms_key_arn
}

output "waf_web_acl_arn" {
  description = "DR WAF Web ACL ARN"
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
  description = "DR CloudWatch dashboard URL"
  value       = var.monitoring.enable_dashboard ? module.monitoring.dashboard_url : null
}

output "sns_topic_arn" {
  description = "DR SNS topic ARN for alerts"
  value       = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# DR Status Outputs
#------------------------------------------------------------------------------
output "dr_status" {
  description = "DR environment status"
  value = {
    enabled       = var.dr.enabled
    strategy      = var.dr.strategy
    rto_minutes   = var.dr.rto_minutes
    rpo_minutes   = var.dr.rpo_minutes
    failover_mode = var.dr.failover_mode
  }
}

output "failover_runbook" {
  description = "DR failover instructions"
  value       = <<-EOT
    DR Failover Runbook:
    1. Verify primary site is down
    2. Promote RDS read replica to standalone
    3. Update DNS to point to DR TFE hostname
    4. Scale up EKS nodes if needed
    5. Verify TFE health at ${var.tfe.hostname}
    6. Notify stakeholders of failover completion
  EOT
}

#------------------------------------------------------------------------------
# Environment Information
#------------------------------------------------------------------------------
output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "region" {
  description = "DR AWS region"
  value       = var.aws.region
}

output "primary_region" {
  description = "Primary region for reference"
  value       = var.aws.dr_region
}
