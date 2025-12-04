#------------------------------------------------------------------------------
# Azure Virtual Desktop - Production Environment
#------------------------------------------------------------------------------
# Enterprise virtual desktop solution with:
# - AVD host pools with pooled or personal desktops
# - Session hosts with auto-scaling
# - FSLogix profiles on Azure Files
# - Application groups for desktop and RemoteApp
# - Azure AD integration
# - Key Vault for secrets management
# - Azure Monitor for observability
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  environment = basename(path.module)
  name_prefix = "${var.solution.abbr}-${local.environment}"

  # Environment display name mapping
  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  #----------------------------------------------------------------------------
  # Shared Configuration Objects
  #----------------------------------------------------------------------------
  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_tags = {
    Solution     = var.solution.name
    SolutionAbbr = var.solution.abbr
    Environment  = local.environment
    Provider     = var.solution.provider_name
    Category     = var.solution.category_name
    Region       = var.azure.region
    ManagedBy    = "terraform"
    CostCenter   = var.ownership.cost_center
    Owner        = var.ownership.owner_email
    ProjectCode  = var.ownership.project_code
  }
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

#===============================================================================
# FOUNDATION - Core infrastructure that other modules depend on
#===============================================================================
#------------------------------------------------------------------------------
# Core Infrastructure (Resource Group, VNet, Key Vault)
#------------------------------------------------------------------------------
module "core" {
  source = "../../modules/solution/core"

  name_prefix = local.name_prefix
  location    = var.azure.region
  common_tags = local.common_tags
  network     = var.network
  tenant_id   = var.azure.tenant_id
  object_id   = data.azurerm_client_config.current.object_id
}

#------------------------------------------------------------------------------
# Security (Managed Identities, RBAC, Encryption Keys)
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/solution/security"

  name_prefix         = local.name_prefix
  location            = var.azure.region
  resource_group_name = module.core.resource_group_name
  common_tags         = local.common_tags
  key_vault_id        = module.core.key_vault_id
  security            = var.security

  depends_on = [module.core]
}

#===============================================================================
# CORE SOLUTION - Primary solution components
#===============================================================================
#------------------------------------------------------------------------------
# Storage (Azure Files for FSLogix Profiles)
#------------------------------------------------------------------------------
module "storage" {
  source = "../../modules/solution/storage"

  name_prefix         = local.name_prefix
  location            = var.azure.region
  resource_group_name = module.core.resource_group_name
  common_tags         = local.common_tags
  subnet_id           = var.network.private_endpoint_enabled ? module.core.private_endpoint_subnet_id : null
  key_vault_id        = module.core.key_vault_id
  storage             = var.storage

  depends_on = [module.security]
}

#------------------------------------------------------------------------------
# AVD (Host Pools, Application Groups, Workspaces, Session Hosts)
#------------------------------------------------------------------------------
module "avd" {
  source = "../../modules/solution/avd"

  name_prefix         = local.name_prefix
  location            = var.azure.region
  resource_group_name = module.core.resource_group_name
  common_tags         = local.common_tags
  subnet_id           = module.core.session_hosts_subnet_id
  key_vault_id        = module.core.key_vault_id
  managed_identity_id = module.security.managed_identity_id
  avd                 = var.avd
  session_hosts       = var.session_hosts
  autoscale           = var.autoscale
  app_groups          = var.app_groups
  storage_account_name = module.storage.storage_account_name
  storage_share_name   = module.storage.fslogix_share_name

  depends_on = [module.storage]
}

#===============================================================================
# OPERATIONS - Monitoring, compliance, and DR
#===============================================================================
#------------------------------------------------------------------------------
# Monitoring (Azure Monitor, Application Insights, Alerts)
#------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/solution/monitoring"

  name_prefix           = local.name_prefix
  location              = var.azure.region
  resource_group_name   = module.core.resource_group_name
  common_tags           = local.common_tags
  host_pool_id          = module.avd.host_pool_id
  workspace_id          = module.avd.workspace_id
  storage_account_id    = module.storage.storage_account_id
  session_host_vm_ids   = module.avd.session_host_vm_ids
  monitoring            = var.monitoring

  depends_on = [module.avd]
}

#------------------------------------------------------------------------------
# Best Practices (Backup, Budgets, Policies)
#------------------------------------------------------------------------------
module "best_practices" {
  source = "../../modules/solution/best-practices"

  name_prefix         = local.name_prefix
  location            = var.azure.region
  resource_group_name = module.core.resource_group_name
  common_tags         = local.common_tags
  action_group_id     = module.monitoring.action_group_id
  backup              = var.backup
  budget              = var.budget
  policies            = var.policies

  depends_on = [module.monitoring]
}

#------------------------------------------------------------------------------
# Disaster Recovery (Cross-Region Replication)
#------------------------------------------------------------------------------
module "dr" {
  source = "../../modules/solution/dr"
  count  = var.dr.enabled ? 1 : 0

  providers = {
    azurerm    = azurerm
    azurerm.dr = azurerm.dr
  }

  name_prefix               = local.name_prefix
  location                  = var.azure.region
  dr_location               = var.azure.dr_region
  resource_group_name       = module.core.resource_group_name
  common_tags               = local.common_tags
  source_storage_account_id = module.storage.storage_account_id
  dr                        = var.dr

  depends_on = [module.storage]
}

#===============================================================================
# INTEGRATIONS - Cross-module connections (avoids circular dependencies)
#===============================================================================
#------------------------------------------------------------------------------
# Host Pool Alerts (connects avd → monitoring)
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "host_pool_capacity" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${local.name_prefix}-hostpool-capacity"
  resource_group_name = module.core.resource_group_name
  scopes              = [module.avd.host_pool_id]
  description         = "Host pool is nearing capacity"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.DesktopVirtualization/hostpools"
    metric_name      = "ConnectionSuccessRate"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 95
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Session Host Health Alerts (connects avd → monitoring)
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "session_host_health" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${local.name_prefix}-sessionhost-health"
  resource_group_name = module.core.resource_group_name
  scopes              = [module.avd.host_pool_id]
  description         = "Session host availability is degraded"
  severity            = 1

  criteria {
    metric_namespace = "Microsoft.DesktopVirtualization/hostpools"
    metric_name      = "SessionHostHealthCheckFailureRate"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Storage Performance Alerts (connects storage → monitoring)
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "storage_latency" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${local.name_prefix}-storage-latency"
  resource_group_name = module.core.resource_group_name
  scopes              = [module.storage.storage_account_id]
  description         = "FSLogix storage latency is high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "SuccessE2ELatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1000
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }

  tags = local.common_tags
}
