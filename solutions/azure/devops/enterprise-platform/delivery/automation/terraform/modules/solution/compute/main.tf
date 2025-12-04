#------------------------------------------------------------------------------
# Compute Module (App Service)
# Creates: App Service Plan, App Service, Deployment Slots
# Uses: modules/azure/app-service
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# App Service (via Azure module)
#------------------------------------------------------------------------------
module "app_service" {
  source = "../../azure/app-service"

  name                = "${var.name_prefix}-asp"
  app_name            = "${var.name_prefix}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_config.sku

  # Identity
  identity_type = "SystemAssigned"

  # Site Configuration
  always_on         = true
  health_check_path = "/health"
  https_only        = true
  http2_enabled     = true
  minimum_tls_version = "1.2"

  # Application Stack
  application_stack = {
    node_version   = var.application.runtime_stack == "node" ? var.application.runtime_version : null
    python_version = var.application.runtime_stack == "python" ? var.application.runtime_version : null
    dotnet_version = var.application.runtime_stack == "dotnet" ? var.application.runtime_version : null
  }

  # App Settings
  app_settings = {
    ENVIRONMENT     = var.application.environment
    LOG_LEVEL       = var.application.log_level
    KEY_VAULT_URI   = var.key_vault_uri
    APPINSIGHTS_INSTRUMENTATIONKEY = ""  # Set by monitoring module
    APPLICATIONINSIGHTS_CONNECTION_STRING = ""  # Set by monitoring module
  }

  # VNet Integration
  subnet_id = var.subnet_id

  # Deployment Slots
  deployment_slots = var.app_service_config.deployment_slots_enabled ? {
    staging = {
      app_settings = {
        ENVIRONMENT = "staging"
      }
    }
  } : {}

  # Autoscaling
  autoscale_enabled          = var.app_service_config.autoscale_enabled
  autoscale_min_instances    = var.app_service_config.min_instances
  autoscale_max_instances    = var.app_service_config.max_instances
  autoscale_default_instances = var.app_service_config.min_instances
  autoscale_cpu_threshold_up  = 70
  autoscale_cpu_threshold_down = 30

  common_tags = var.common_tags
}
