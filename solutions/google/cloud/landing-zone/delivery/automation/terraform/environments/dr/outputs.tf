#------------------------------------------------------------------------------
# GCP Landing Zone DR Outputs
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
    primary_region           = var.gcp.dr_region  # DR uses dr_region as primary
    standby_region           = var.gcp.region
  }
}

output "failover_runbook" {
  description = "DR failover procedures"
  value = {
    runbook_url      = "https://wiki.example.com/landing-zone/dr-failover"
    estimated_rto    = "${var.dr.rto_minutes} minutes"
    estimated_rpo    = "${var.dr.rpo_minutes} minutes"
    failover_mode    = var.dr.failover_mode
    contact_oncall   = var.ownership.owner_email
    last_test_date   = "See CloudOps DR test schedule"
  }
}

# =============================================================================
# Configuration Summary
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

    # Resources
    network_id = module.vpc.network_id
    folder_ids = module.folders.folder_ids

    # DR Configuration
    dr_enabled  = var.dr.enabled
    dr_strategy = var.dr.strategy

    # Modules deployed
    deployed_modules = ["organization", "folders", "vpc", "kms"]

    # Timestamp
    deployment_time = timestamp()
  }
}
