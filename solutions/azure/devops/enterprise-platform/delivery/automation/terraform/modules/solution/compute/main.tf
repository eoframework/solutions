#------------------------------------------------------------------------------
# Compute Module (App Service)
# Creates: App Service Plan, App Service, Deployment Slots
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# App Service Plan
#------------------------------------------------------------------------------
resource "azurerm_service_plan" "main" {
  name                = "${var.name_prefix}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_config.sku

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# App Service
#------------------------------------------------------------------------------
resource "azurerm_linux_web_app" "main" {
  name                = "${var.name_prefix}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = true

    application_stack {
      node_version = var.application.runtime_stack == "node" ? var.application.runtime_version : null
      python_version = var.application.runtime_stack == "python" ? var.application.runtime_version : null
      dotnet_version = var.application.runtime_stack == "dotnet" ? var.application.runtime_version : null
    }

    health_check_path = "/health"
  }

  app_settings = {
    ENVIRONMENT                     = var.application.environment
    LOG_LEVEL                       = var.application.log_level
    KEY_VAULT_URI                   = var.key_vault_uri
    APPINSIGHTS_INSTRUMENTATIONKEY  = ""  # Set by monitoring module
    APPLICATIONINSIGHTS_CONNECTION_STRING = ""  # Set by monitoring module
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# VNet Integration
#------------------------------------------------------------------------------
resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  count          = var.subnet_id != null ? 1 : 0
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.subnet_id
}

#------------------------------------------------------------------------------
# Deployment Slot (Staging)
#------------------------------------------------------------------------------
resource "azurerm_linux_web_app_slot" "staging" {
  count          = var.app_service_config.deployment_slots_enabled ? 1 : 0
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id

  site_config {
    always_on = true

    application_stack {
      node_version = var.application.runtime_stack == "node" ? var.application.runtime_version : null
      python_version = var.application.runtime_stack == "python" ? var.application.runtime_version : null
      dotnet_version = var.application.runtime_stack == "dotnet" ? var.application.runtime_version : null
    }
  }

  app_settings = {
    ENVIRONMENT                     = "staging"
    LOG_LEVEL                       = var.application.log_level
    KEY_VAULT_URI                   = var.key_vault_uri
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Autoscale Settings
#------------------------------------------------------------------------------
resource "azurerm_monitor_autoscale_setting" "main" {
  count               = var.app_service_config.autoscale_enabled ? 1 : 0
  name                = "${var.name_prefix}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_service_plan.main.id

  profile {
    name = "default"

    capacity {
      default = var.app_service_config.min_instances
      minimum = var.app_service_config.min_instances
      maximum = var.app_service_config.max_instances
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = var.common_tags
}
