#------------------------------------------------------------------------------
# Azure Document Intelligence - Production Environment
#------------------------------------------------------------------------------
# Serverless document processing platform with:
# - Azure Document Intelligence for OCR and extraction
# - Azure Functions for processing pipeline
# - Cosmos DB for metadata storage
# - Blob Storage for document ingestion
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

  # Grouped function configuration (DRY)
  function_config = {
    name_prefix     = local.name_prefix
    runtime         = "python"
    runtime_version = "3.11"
    sku             = var.compute.function_plan_sku
    min_instances   = var.compute.autoscale_min_instances
    max_instances   = var.compute.autoscale_max_instances
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
# Storage (Blob Storage for Documents, Cosmos DB for Metadata)
#------------------------------------------------------------------------------
module "storage" {
  source = "../../modules/solution/storage"

  name_prefix         = local.name_prefix
  location            = var.azure.region
  resource_group_name = module.core.resource_group_name
  common_tags         = local.common_tags
  subnet_id           = var.network.enable_private_endpoints ? module.core.private_endpoint_subnet_id : null
  key_vault_id        = module.core.key_vault_id
  storage             = var.storage
  database            = var.database

  depends_on = [module.security]
}

#------------------------------------------------------------------------------
# Processing (Document Intelligence, Functions, Logic Apps)
#------------------------------------------------------------------------------
module "processing" {
  source = "../../modules/solution/processing"

  name_prefix               = local.name_prefix
  location                  = var.azure.region
  resource_group_name       = module.core.resource_group_name
  common_tags               = local.common_tags
  function_config           = local.function_config
  subnet_id                 = var.network.enable_private_endpoints ? module.core.functions_subnet_id : null
  storage_account_name      = module.storage.storage_account_name
  storage_connection_string = module.storage.storage_connection_string
  cosmos_endpoint           = module.storage.cosmos_endpoint
  cosmos_key                = module.storage.cosmos_key
  key_vault_uri             = module.core.key_vault_uri
  managed_identity_id       = module.security.managed_identity_id
  application               = var.application
  docintel                  = var.docintel

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

  name_prefix         = local.name_prefix
  location            = var.azure.region
  resource_group_name = module.core.resource_group_name
  common_tags         = local.common_tags
  function_app_id     = module.processing.function_app_id
  cosmos_account_name = module.storage.cosmos_account_name
  storage_account_id  = module.storage.storage_account_id
  monitoring          = var.monitoring

  depends_on = [module.processing]
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
  policy              = var.policy

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
  source_storage_account_id  = module.storage.storage_account_id
  source_cosmos_account_name = module.storage.cosmos_account_name
  dr                         = var.dr

  depends_on = [module.storage]
}

#===============================================================================
# INTEGRATIONS - Cross-module connections (avoids circular dependencies)
#===============================================================================
#------------------------------------------------------------------------------
# Integrations (Event Grid, Metric Alerts)
#------------------------------------------------------------------------------
module "integrations" {
  source = "../../modules/solution/integrations"

  name_prefix         = local.name_prefix
  resource_group_name = module.core.resource_group_name
  common_tags         = local.common_tags

  # Storage integration
  storage_account_id = module.storage.storage_account_id
  input_container    = var.storage.input_container

  # Processing integration
  function_app_id = module.processing.function_app_id

  # Database integration
  cosmos_account_id = module.storage.cosmos_account_id

  # Monitoring integration
  action_group_id = module.monitoring.action_group_id
  enable_alerts   = var.monitoring.enable_alerts

  depends_on = [module.processing, module.monitoring]
}
