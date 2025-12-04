#------------------------------------------------------------------------------
# GCP Landing Zone Production Environment
#------------------------------------------------------------------------------
# Full production deployment implementing GCP Well-Architected Framework:
#
# OPERATIONAL EXCELLENCE
# - Organization policies and folder hierarchy
# - Centralized logging and monitoring
# - Budget alerts and cost management
#
# SECURITY
# - Cloud KMS encryption
# - Security Command Center Premium
# - Cloud Armor WAF protection
# - IAM best practices
#
# RELIABILITY
# - Shared VPC with redundant subnets
# - Cloud NAT for egress
# - Cross-region DR configuration
#
# PERFORMANCE EFFICIENCY
# - Global VPC routing
# - Private Google Access
#
# COST OPTIMIZATION
# - Budget alerts at multiple thresholds
# - Resource labeling for cost allocation
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  environment = basename(path.module)
  name_prefix = "${var.solution.abbr}-${local.environment}"

  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_labels = {
    solution      = var.solution.name
    solution_abbr = var.solution.abbr
    environment   = local.environment
    provider      = var.solution.provider_name
    category      = var.solution.category_name
    region        = var.gcp.region
    managed_by    = "terraform"
    cost_center   = var.ownership.cost_center
    owner         = var.ownership.owner_email
    project_code  = var.ownership.project_code
  }
}

#===============================================================================
# FOUNDATION - Organization and folder structure
#===============================================================================
#------------------------------------------------------------------------------
# Organization Policies (Operational Excellence + Security)
#------------------------------------------------------------------------------
module "organization" {
  source = "../../modules/gcp/organization"

  org_id             = var.organization.org_id
  domain             = var.organization.domain
  billing_account_id = var.organization.billing_account_id

  # Organization policies - Security baseline
  require_shielded_vm        = var.org_policy.require_shielded_vm
  disable_serial_port_access = var.org_policy.disable_serial_port_access
  disable_sa_key_creation    = var.org_policy.sa_key_creation == "Disabled"
  disable_vm_external_ip     = var.org_policy.external_ip_policy == "Deny all"
  allowed_locations          = var.org_policy.allowed_locations
  require_os_login           = true

  # Essential contacts
  security_contact_email  = var.ownership.owner_email
  billing_contact_email   = var.budget.notification_email
  technical_contact_email = var.ownership.owner_email
}

#------------------------------------------------------------------------------
# Folder Hierarchy (Operational Excellence)
#------------------------------------------------------------------------------
module "folders" {
  source = "../../modules/gcp/folders"

  org_id  = var.organization.org_id
  folders = var.folders

  create_sandbox_folder = true

  depends_on = [module.organization]
}

#------------------------------------------------------------------------------
# Project Factory (Operational Excellence)
#------------------------------------------------------------------------------
module "projects" {
  source = "../../modules/gcp/projects"

  org_id             = var.organization.org_id
  billing_account_id = var.organization.billing_account_id
  folder_ids         = module.folders.folder_ids
  projects           = var.projects
  common_labels      = local.common_labels

  depends_on = [module.folders]
}

#===============================================================================
# CORE SOLUTION - Network and security infrastructure
#===============================================================================
#------------------------------------------------------------------------------
# Shared VPC Network (Reliability + Performance)
#------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/gcp/vpc"

  host_project_id = module.projects.host_project_id
  region          = var.gcp.region
  network         = var.network
  nat             = var.nat
  common_tags     = local.common_labels

  depends_on = [module.projects]
}

#------------------------------------------------------------------------------
# Cloud KMS Encryption (Security)
#------------------------------------------------------------------------------
module "kms" {
  source = "../../modules/gcp/kms"

  project_id  = module.projects.security_project_id
  name_prefix = local.name_prefix
  kms         = var.kms

  depends_on = [module.projects]
}

#------------------------------------------------------------------------------
# IAM Baseline (Security)
#------------------------------------------------------------------------------
module "iam" {
  source = "../../modules/gcp/iam"

  org_id        = var.organization.org_id
  project_ids   = module.projects.all_project_ids
  identity      = var.identity
  common_labels = local.common_labels

  depends_on = [module.projects]
}

#===============================================================================
# OPERATIONS - Logging, monitoring, and alerting (Operational Excellence)
#===============================================================================
#------------------------------------------------------------------------------
# Centralized Logging
#------------------------------------------------------------------------------
module "logging" {
  source = "../../modules/gcp/logging"

  org_id        = var.organization.org_id
  project_id    = module.projects.logging_project_id
  name_prefix   = local.name_prefix
  location      = var.gcp.region
  logging       = var.logging
  common_labels = local.common_labels

  enable_metrics = var.monitoring.log_based_metrics

  depends_on = [module.projects]
}

#------------------------------------------------------------------------------
# Cloud Monitoring
#------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/gcp/monitoring"

  project_id    = module.projects.monitoring_project_id
  name_prefix   = local.name_prefix
  monitoring    = var.monitoring
  common_labels = local.common_labels

  # Notification channels
  notification_email = var.ownership.owner_email

  depends_on = [module.projects]
}

#===============================================================================
# BEST PRACTICES - Security, Cost, and Reliability
#===============================================================================
#------------------------------------------------------------------------------
# Best Practices (SCC + Cloud Armor + Budget + DR)
#------------------------------------------------------------------------------
module "best_practices" {
  source = "../../modules/solution/best-practices"

  org_id              = var.organization.org_id
  billing_account_id  = var.organization.billing_account_id
  security_project_id = module.projects.security_project_id
  name_prefix         = local.name_prefix
  project_ids         = [for id in module.projects.all_project_ids : "projects/${id}"]
  dr_region           = var.gcp.dr_region
  common_labels       = local.common_labels

  notification_channels = module.monitoring.email_notification_channel_id != null ? [module.monitoring.email_notification_channel_id] : []

  # Budget Configuration (Cost Optimization) - from tfvars
  budget = {
    enabled                = var.budget.enabled
    monthly_amount         = var.budget.monthly_amount
    currency               = var.budget.currency
    alert_thresholds       = var.budget.alert_thresholds
    enable_forecast_alerts = var.budget.enable_forecast_alerts
    forecast_threshold     = var.budget.forecast_threshold
  }

  # Security Configuration - from tfvars
  security = {
    scc_tier                       = var.security.scc_tier
    scc_public_resource_detection  = var.security.scc_public_resource_detection
    scc_notifications_enabled      = var.security.scc_notifications_enabled
    cloud_armor_enabled            = var.security.cloud_armor_enabled
    cloud_armor_owasp_rules        = var.security.cloud_armor_owasp_rules
    cloud_armor_rate_limiting      = var.security.cloud_armor_rate_limiting
    rate_limit_requests_per_minute = var.security.rate_limit_requests_per_minute
    rate_limit_ban_duration_sec    = var.security.rate_limit_ban_duration_sec
    blocked_countries              = var.security.blocked_countries
  }

  # DR Configuration (Reliability) - from tfvars
  dr = {
    enabled                   = var.dr.enabled
    cross_region_replication  = var.dr.cross_region_replication
    archive_after_days        = var.dr.archive_after_days
    coldline_after_days       = var.dr.coldline_after_days
    enable_health_check       = var.dr.enable_health_check
    health_check_interval_sec = var.dr.health_check_interval_sec
    health_check_timeout_sec  = var.dr.health_check_timeout_sec
    healthy_threshold         = var.dr.healthy_threshold
    unhealthy_threshold       = var.dr.unhealthy_threshold
    health_check_port         = var.dr.health_check_port
    health_check_path         = var.dr.health_check_path
    enable_dr_kms             = var.dr.enable_dr_kms
    key_rotation_days         = var.dr.key_rotation_days
  }

  depends_on = [module.projects, module.monitoring]
}
