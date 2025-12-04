#------------------------------------------------------------------------------
# Azure DevOps Enterprise Platform - Production Environment
#------------------------------------------------------------------------------
# Enterprise DevOps platform with:
# - Azure DevOps organization and projects
# - Azure Pipelines for CI/CD
# - Azure Repos for version control
# - Azure Artifacts for package management
# - App Service for deployment targets
# - Service connections to Azure
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

  # Grouped App Service configuration (DRY)
  app_service_config = {
    name_prefix              = local.name_prefix
    sku                      = var.compute.app_service_plan_sku
    tier                     = var.compute.app_service_plan_tier
    min_instances            = var.compute.autoscale_min_instances
    max_instances            = var.compute.autoscale_max_instances
    autoscale_enabled        = var.compute.autoscale_enabled
    deployment_slots_enabled = var.compute.deployment_slots_enabled
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

  name_prefix   = local.name_prefix
  location      = var.azure.region
  common_tags   = local.common_tags
  network       = var.network
  tenant_id     = var.azure.tenant_id
  object_id     = data.azurerm_client_config.current.object_id
}

#------------------------------------------------------------------------------
# Security (Managed Identities, RBAC, Encryption Keys)
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/solution/security"

  name_prefix          = local.name_prefix
  location             = var.azure.region
  resource_group_name  = module.core.resource_group_name
  common_tags          = local.common_tags
  key_vault_id         = module.core.key_vault_id
  security             = var.security

  depends_on = [module.core]
}

#===============================================================================
# CORE SOLUTION - Primary solution components
#===============================================================================
#------------------------------------------------------------------------------
# Azure DevOps (Organization, Projects, Repos, Pipelines)
#------------------------------------------------------------------------------
module "devops" {
  source = "../../modules/solution/devops"

  name_prefix         = local.name_prefix
  common_tags         = local.common_tags
  devops              = var.devops
  pipelines           = var.pipelines
  service_connections = var.service_connections
  subscription_id     = var.azure.subscription_id
  tenant_id           = var.azure.tenant_id
  key_vault_id        = module.core.key_vault_id

  depends_on = [module.security]
}

#------------------------------------------------------------------------------
# Compute (App Service for Deployment Targets)
#------------------------------------------------------------------------------
module "compute" {
  source = "../../modules/solution/compute"

  name_prefix               = local.name_prefix
  location                  = var.azure.region
  resource_group_name       = module.core.resource_group_name
  common_tags               = local.common_tags
  app_service_config        = local.app_service_config
  subnet_id                 = var.network.private_endpoint_enabled ? module.core.appservice_subnet_id : null
  key_vault_uri             = module.core.key_vault_uri
  managed_identity_id       = module.security.managed_identity_id
  application               = var.application

  depends_on = [module.devops]
}

#===============================================================================
# OPERATIONS - Monitoring, compliance, and DR
#===============================================================================
#------------------------------------------------------------------------------
# Monitoring (Azure Monitor, Application Insights, Alerts)
#------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/solution/monitoring"

  name_prefix         = local.name_prefix
  location            = var.azure.region
  resource_group_name = module.core.resource_group_name
  common_tags         = local.common_tags
  app_service_id      = module.compute.app_service_id
  monitoring          = var.monitoring

  depends_on = [module.compute]
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

  name_prefix                = local.name_prefix
  location                   = var.azure.region
  dr_location                = var.azure.dr_region
  resource_group_name        = module.core.resource_group_name
  common_tags                = local.common_tags
  source_app_service_id      = module.compute.app_service_id
  dr                         = var.dr

  depends_on = [module.compute]
}

#===============================================================================
# INTEGRATIONS - Cross-module connections (avoids circular dependencies)
#===============================================================================
#------------------------------------------------------------------------------
# App Service Alerts (connects compute → monitoring)
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "app_service_errors" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${local.name_prefix}-appservice-errors"
  resource_group_name = module.core.resource_group_name
  scopes              = [module.compute.app_service_id]
  description         = "App Service error rate is high"
  severity            = 1

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "app_service_latency" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${local.name_prefix}-appservice-latency"
  resource_group_name = module.core.resource_group_name
  scopes              = [module.compute.app_service_id]
  description         = "App Service response time is high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HttpResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5000
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "app_service_cpu" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${local.name_prefix}-appservice-cpu"
  resource_group_name = module.core.resource_group_name
  scopes              = [module.compute.app_service_plan_id]
  description         = "App Service CPU usage is high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "app_service_memory" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${local.name_prefix}-appservice-memory"
  resource_group_name = module.core.resource_group_name
  scopes              = [module.compute.app_service_plan_id]
  description         = "App Service memory usage is high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }

  tags = local.common_tags
}
