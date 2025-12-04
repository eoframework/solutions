#------------------------------------------------------------------------------
# Azure App Service Module
#------------------------------------------------------------------------------
# Creates:
# - App Service Plan
# - Linux/Windows Web App
# - Deployment Slots
# - VNet Integration
# - Autoscaling
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# App Service Plan
#------------------------------------------------------------------------------
resource "azurerm_service_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Linux Web App
#------------------------------------------------------------------------------
resource "azurerm_linux_web_app" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  https_only = var.https_only

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }

  site_config {
    always_on                         = var.always_on
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        python_version      = lookup(application_stack.value, "python_version", null)
        java_version        = lookup(application_stack.value, "java_version", null)
        php_version         = lookup(application_stack.value, "php_version", null)
        docker_image        = lookup(application_stack.value, "docker_image", null)
        docker_image_tag    = lookup(application_stack.value, "docker_image_tag", null)
      }
    }

    dynamic "cors" {
      for_each = var.cors_allowed_origins != null ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.key
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Windows Web App
#------------------------------------------------------------------------------
resource "azurerm_windows_web_app" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  https_only = var.https_only

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }

  site_config {
    always_on                         = var.always_on
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        current_stack       = lookup(application_stack.value, "current_stack", null)
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        python_version      = lookup(application_stack.value, "python_version", null)
        java_version        = lookup(application_stack.value, "java_version", null)
        php_version         = lookup(application_stack.value, "php_version", null)
      }
    }

    dynamic "cors" {
      for_each = var.cors_allowed_origins != null ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.key
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# VNet Integration
#------------------------------------------------------------------------------
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  count = var.subnet_id != null ? 1 : 0

  app_service_id = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
  subnet_id      = var.subnet_id
}

#------------------------------------------------------------------------------
# Linux Deployment Slot
#------------------------------------------------------------------------------
resource "azurerm_linux_web_app_slot" "this" {
  for_each = var.os_type == "Linux" ? var.deployment_slots : {}

  name           = each.key
  app_service_id = azurerm_linux_web_app.this[0].id

  https_only = var.https_only

  site_config {
    always_on           = var.always_on
    health_check_path   = var.health_check_path
    ftps_state          = var.ftps_state
    http2_enabled       = var.http2_enabled
    minimum_tls_version = var.minimum_tls_version

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        python_version      = lookup(application_stack.value, "python_version", null)
        java_version        = lookup(application_stack.value, "java_version", null)
        php_version         = lookup(application_stack.value, "php_version", null)
        docker_image        = lookup(application_stack.value, "docker_image", null)
        docker_image_tag    = lookup(application_stack.value, "docker_image_tag", null)
      }
    }
  }

  app_settings = merge(var.app_settings, lookup(each.value, "app_settings", {}))

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Windows Deployment Slot
#------------------------------------------------------------------------------
resource "azurerm_windows_web_app_slot" "this" {
  for_each = var.os_type == "Windows" ? var.deployment_slots : {}

  name           = each.key
  app_service_id = azurerm_windows_web_app.this[0].id

  https_only = var.https_only

  site_config {
    always_on           = var.always_on
    health_check_path   = var.health_check_path
    ftps_state          = var.ftps_state
    http2_enabled       = var.http2_enabled
    minimum_tls_version = var.minimum_tls_version

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        current_stack  = lookup(application_stack.value, "current_stack", null)
        dotnet_version = lookup(application_stack.value, "dotnet_version", null)
        node_version   = lookup(application_stack.value, "node_version", null)
        python_version = lookup(application_stack.value, "python_version", null)
        java_version   = lookup(application_stack.value, "java_version", null)
        php_version    = lookup(application_stack.value, "php_version", null)
      }
    }
  }

  app_settings = merge(var.app_settings, lookup(each.value, "app_settings", {}))

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Autoscale Settings
#------------------------------------------------------------------------------
resource "azurerm_monitor_autoscale_setting" "this" {
  count = var.autoscale_enabled ? 1 : 0

  name                = "${var.name}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_service_plan.this.id

  profile {
    name = "default"

    capacity {
      default = var.autoscale_default_instances
      minimum = var.autoscale_min_instances
      maximum = var.autoscale_max_instances
    }

    # Scale out rule
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.autoscale_cpu_threshold_up
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Scale in rule
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.autoscale_cpu_threshold_down
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
