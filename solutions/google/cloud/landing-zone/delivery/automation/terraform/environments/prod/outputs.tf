#------------------------------------------------------------------------------
# GCP Landing Zone Production Outputs
#------------------------------------------------------------------------------

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
  value       = var.solution.name
}

output "solution_abbr" {
  description = "Solution abbreviation"
  value       = var.solution.abbr
}

output "common_labels" {
  description = "Common labels applied to all resources"
  value       = local.common_labels
}

# =============================================================================
# Organization Module Outputs
# =============================================================================

output "organization_id" {
  description = "GCP Organization ID"
  value       = var.organization.org_id
}

output "domain" {
  description = "Primary domain"
  value       = var.organization.domain
}

# =============================================================================
# Folder Module Outputs
# =============================================================================

output "folder_ids" {
  description = "Folder IDs by environment"
  value       = module.folders.folder_ids
}

# =============================================================================
# Project Module Outputs
# =============================================================================

output "host_project_id" {
  description = "Shared VPC host project ID"
  value       = module.projects.host_project_id
}

output "logging_project_id" {
  description = "Centralized logging project ID"
  value       = module.projects.logging_project_id
}

output "security_project_id" {
  description = "Security services project ID"
  value       = module.projects.security_project_id
}

output "monitoring_project_id" {
  description = "Cloud Monitoring project ID"
  value       = module.projects.monitoring_project_id
}

output "all_project_ids" {
  description = "All project IDs created"
  value       = module.projects.all_project_ids
}

# =============================================================================
# Network Module Outputs
# =============================================================================

output "network_id" {
  description = "Shared VPC network ID"
  value       = module.vpc.network_id
}

output "network_name" {
  description = "Shared VPC network name"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "Shared VPC network self link"
  value       = module.vpc.network_self_link
}

output "subnet_ids" {
  description = "Subnet IDs by environment"
  value       = module.vpc.subnet_ids
}

output "router_name" {
  description = "Cloud Router name"
  value       = module.vpc.router_name
}

# =============================================================================
# KMS Module Outputs
# =============================================================================

output "kms_keyring_id" {
  description = "Cloud KMS keyring ID"
  value       = module.kms.keyring_id
}

output "kms_key_ids" {
  description = "Cloud KMS crypto key IDs"
  value       = module.kms.key_ids
}

# =============================================================================
# Logging Module Outputs
# =============================================================================

output "log_sink_destination" {
  description = "Log sink destination (BigQuery dataset or GCS bucket)"
  value       = module.logging.sink_destination
}

output "log_sink_writer_identity" {
  description = "Log sink writer identity for IAM"
  value       = module.logging.sink_writer_identity
}

# =============================================================================
# Monitoring Module Outputs
# =============================================================================

output "monitoring_notification_channel_id" {
  description = "Primary monitoring notification channel ID"
  value       = module.monitoring.email_notification_channel_id
}

output "monitoring_alert_policy_ids" {
  description = "Alert policy IDs"
  value       = module.monitoring.alert_policy_ids
}

output "monitoring_dashboard_ids" {
  description = "Dashboard IDs"
  value       = module.monitoring.dashboard_ids
}

# =============================================================================
# Best Practices Module Outputs
# =============================================================================

output "budget_id" {
  description = "Billing budget ID"
  value       = module.best_practices.budget_id
}

output "cloud_armor_policy_id" {
  description = "Cloud Armor security policy ID"
  value       = module.best_practices.cloud_armor_policy_id
}

output "cloud_armor_policy_self_link" {
  description = "Cloud Armor security policy self link"
  value       = module.best_practices.cloud_armor_policy_self_link
}

output "scc_critical_findings_module_id" {
  description = "SCC critical findings custom module ID"
  value       = module.best_practices.scc_critical_findings_module_id
}

output "dr_replication_bucket_name" {
  description = "DR replication bucket name"
  value       = module.best_practices.dr_replication_bucket_name
}

output "dr_health_check_id" {
  description = "DR failover health check ID"
  value       = module.best_practices.dr_health_check_id
}

# =============================================================================
# DR Status
# =============================================================================

output "dr_status" {
  description = "Disaster Recovery configuration status"
  value = {
    enabled                  = var.dr.enabled
    strategy                 = var.dr.strategy
    rto_minutes              = var.dr.rto_minutes
    rpo_minutes              = var.dr.rpo_minutes
    failover_mode            = var.dr.failover_mode
    cross_region_replication = var.dr.cross_region_replication
    dr_region                = var.gcp.dr_region
    replication_bucket       = module.best_practices.dr_replication_bucket_name
  }
}

# =============================================================================
# Deployment Summary
# =============================================================================

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    # Identity
    solution_name    = var.solution.name
    solution_abbr    = var.solution.abbr
    environment      = local.environment
    environment_name = lookup(local.env_display_name, local.environment, local.environment)
    name_prefix      = local.name_prefix

    # GCP Configuration
    project_id = var.gcp.project_id
    region     = var.gcp.region
    dr_region  = var.gcp.dr_region

    # Organization
    org_id = var.organization.org_id
    domain = var.organization.domain

    # Ownership
    cost_center  = var.ownership.cost_center
    owner        = var.ownership.owner_email
    project_code = var.ownership.project_code

    # Resources Created
    host_project_id       = module.projects.host_project_id
    logging_project_id    = module.projects.logging_project_id
    security_project_id   = module.projects.security_project_id
    monitoring_project_id = module.projects.monitoring_project_id
    network_id            = module.vpc.network_id
    folder_ids            = module.folders.folder_ids

    # Well-Architected Framework Summary
    best_practices = module.best_practices.best_practices_summary

    # Modules deployed
    deployed_modules = [
      "organization",
      "folders",
      "projects",
      "vpc",
      "kms",
      "iam",
      "logging",
      "monitoring",
      "best_practices"
    ]

    # Timestamp
    deployment_time = timestamp()
  }
}
