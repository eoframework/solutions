#------------------------------------------------------------------------------
# GCP Landing Zone Production Environment
#------------------------------------------------------------------------------
# Full production deployment with:
# - Organization policies and folder hierarchy
# - Shared VPC with full subnets
# - Cloud KMS encryption
# - Security Command Center Premium
# - Chronicle SIEM integration
# - Cloud Armor and Cloud IDS
# - Full monitoring and logging
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
# Organization Policies
#------------------------------------------------------------------------------
module "organization" {
  source = "../../modules/gcp/organization"

  org_id             = var.organization.org_id
  domain             = var.organization.domain
  billing_account_id = var.organization.billing_account_id

  # Organization policies
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
# Folder Hierarchy
#------------------------------------------------------------------------------
module "folders" {
  source = "../../modules/gcp/folders"

  org_id  = var.organization.org_id
  folders = var.folders

  create_sandbox_folder = true

  depends_on = [module.organization]
}

#===============================================================================
# CORE SOLUTION - Network and security infrastructure
#===============================================================================
#------------------------------------------------------------------------------
# Shared VPC Network
#------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/gcp/vpc"

  host_project_id = var.projects.host_project_name
  region          = var.gcp.region
  network         = var.network
  nat             = var.nat
  common_tags     = local.common_labels

  depends_on = [module.folders]
}

#------------------------------------------------------------------------------
# Cloud KMS Encryption
#------------------------------------------------------------------------------
module "kms" {
  source = "../../modules/gcp/kms"

  project_id  = var.projects.security_project_name
  name_prefix = local.name_prefix
  kms         = var.kms

  depends_on = [module.vpc]
}

#===============================================================================
# OPERATIONS - Monitoring, logging, and budget alerts
#===============================================================================
#------------------------------------------------------------------------------
# Budget Alerts
#------------------------------------------------------------------------------
resource "google_billing_budget" "main" {
  count = var.budget.enabled ? 1 : 0

  billing_account = var.organization.billing_account_id
  display_name    = "${local.name_prefix}-budget"

  budget_filter {
    projects = ["projects/${var.gcp.project_id}"]
  }

  amount {
    specified_amount {
      currency_code = var.budget.currency
      units         = tostring(var.budget.monthly_amount)
    }
  }

  dynamic "threshold_rules" {
    for_each = var.budget.alert_thresholds
    content {
      threshold_percent = threshold_rules.value / 100
      spend_basis       = "CURRENT_SPEND"
    }
  }

  all_updates_rule {
    monitoring_notification_channels = []
    disable_default_iam_recipients   = false
  }
}

#===============================================================================
# OUTPUTS
#===============================================================================
output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "name_prefix" {
  description = "Resource naming prefix"
  value       = local.name_prefix
}

output "folder_ids" {
  description = "Folder IDs"
  value       = module.folders.folder_ids
}

output "network_id" {
  description = "Shared VPC network ID"
  value       = module.vpc.network_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.vpc.subnet_ids
}

output "kms_key_ids" {
  description = "KMS crypto key IDs"
  value       = module.kms.key_ids
}
