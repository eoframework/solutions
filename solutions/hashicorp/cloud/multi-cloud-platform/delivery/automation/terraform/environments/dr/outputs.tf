#------------------------------------------------------------------------------
# Outputs - HashiCorp Multi-Cloud Platform Production
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Platform Information
#------------------------------------------------------------------------------
output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "environment_display" {
  description = "Human-readable environment name"
  value       = local.env_display_name[local.environment]
}

#------------------------------------------------------------------------------
# Networking Outputs
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr
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
# EKS Cluster Outputs
#------------------------------------------------------------------------------
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws.region}"
}

#------------------------------------------------------------------------------
# Database Outputs
#------------------------------------------------------------------------------
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.database.endpoint
  sensitive   = true
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = module.database.rds_identifier
}

#------------------------------------------------------------------------------
# Terraform Cloud Outputs
#------------------------------------------------------------------------------
output "tfc_organization_name" {
  description = "Terraform Cloud organization name"
  value       = module.tfc.organization_name
}

output "tfc_organization_url" {
  description = "Terraform Cloud organization URL"
  value       = "https://${var.tfc.hostname}/app/${module.tfc.organization_name}"
}

output "tfc_workspace_count" {
  description = "Configured workspace count"
  value       = var.tfc.workspace_count
}

#------------------------------------------------------------------------------
# HashiCorp Vault Outputs
#------------------------------------------------------------------------------
output "vault_endpoint" {
  description = "HashiCorp Vault cluster endpoint"
  value       = var.vault.enabled ? module.vault[0].vault_endpoint : "Vault not enabled"
}

output "vault_namespace" {
  description = "Vault namespace"
  value       = var.vault.enabled ? var.vault.namespace : "N/A"
}

output "vault_aws_secrets_engine_enabled" {
  description = "AWS secrets engine enabled"
  value       = var.vault.enabled && var.vault.aws_secrets_enabled
}

#------------------------------------------------------------------------------
# HashiCorp Consul Outputs
#------------------------------------------------------------------------------
output "consul_enabled" {
  description = "Consul service mesh enabled"
  value       = var.consul.enabled
}

output "consul_endpoint" {
  description = "HashiCorp Consul cluster endpoint"
  value       = var.consul.enabled ? module.consul[0].consul_endpoint : "Consul not enabled"
}

output "consul_datacenter" {
  description = "Consul datacenter name"
  value       = var.consul.enabled ? var.consul.datacenter : "N/A"
}

#------------------------------------------------------------------------------
# Sentinel Policy Outputs
#------------------------------------------------------------------------------
output "sentinel_enabled" {
  description = "Sentinel policies enabled"
  value       = var.sentinel.enabled
}

output "sentinel_enforcement_level" {
  description = "Default policy enforcement level"
  value       = var.sentinel.enabled ? var.sentinel.enforcement_level : "N/A"
}

#------------------------------------------------------------------------------
# Security Outputs
#------------------------------------------------------------------------------
output "kms_key_arn" {
  description = "KMS encryption key ARN"
  value       = module.security.kms_key_arn
}

output "waf_enabled" {
  description = "WAF protection enabled"
  value       = var.security.enable_waf
}

output "guardduty_enabled" {
  description = "GuardDuty threat detection enabled"
  value       = var.security.enable_guardduty
}

#------------------------------------------------------------------------------
# Monitoring Outputs
#------------------------------------------------------------------------------
output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = var.monitoring.enable_dashboard ? "https://${var.aws.region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws.region}#dashboards:name=${local.name_prefix}-dashboard" : "Dashboard not enabled"
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Disaster Recovery Outputs
#------------------------------------------------------------------------------
output "dr_enabled" {
  description = "DR infrastructure enabled"
  value       = var.dr.enabled
}

output "dr_region" {
  description = "DR region"
  value       = var.dr.enabled ? var.aws.dr_region : "N/A"
}

output "dr_strategy" {
  description = "DR strategy"
  value       = var.dr.enabled ? var.dr.strategy : "N/A"
}

output "dr_rto_minutes" {
  description = "Recovery Time Objective (minutes)"
  value       = var.dr.enabled ? var.dr.rto_minutes : null
}

output "dr_rpo_minutes" {
  description = "Recovery Point Objective (minutes)"
  value       = var.dr.enabled ? var.dr.rpo_minutes : null
}

#------------------------------------------------------------------------------
# Cost Management Outputs
#------------------------------------------------------------------------------
output "budget_enabled" {
  description = "AWS Budgets enabled"
  value       = var.budget.enabled
}

output "monthly_budget_limit" {
  description = "Monthly budget limit (USD)"
  value       = var.budget.enabled ? var.budget.monthly_amount : null
}
