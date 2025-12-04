#------------------------------------------------------------------------------
# Azure Function App Module
#------------------------------------------------------------------------------
# Creates Linux Function Apps with:
# - App Service Plan (Consumption, Premium, or Dedicated)
# - Application Insights integration
# - VNet integration
# - Managed identity
# - Custom domain and SSL
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# App Service Plan
#------------------------------------------------------------------------------
resource "azurerm_service_plan" "this" {
  count = var.create_service_plan ? 1 : 0

  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name

  maximum_elastic_worker_count = var.sku_name == "EP1" || var.sku_name == "EP2" || var.sku_name == "EP3" ? var.max_elastic_worker_count : null
  worker_count                 = var.worker_count

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Linux Function App
#------------------------------------------------------------------------------
resource "azurerm_linux_function_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id            = var.create_service_plan ? azurerm_service_plan.this[0].id : var.service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  # HTTPS and TLS
  https_only                    = var.https_only
  functions_extension_version   = var.functions_extension_version
  builtin_logging_enabled       = var.builtin_logging_enabled
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Site config
  site_config {
    always_on                              = var.always_on
    ftps_state                             = var.ftps_state
    http2_enabled                          = var.http2_enabled
    minimum_tls_version                    = var.minimum_tls_version
    use_32_bit_worker                      = var.use_32_bit_worker
    vnet_route_all_enabled                 = var.vnet_route_all_enabled
    remote_debugging_enabled               = var.remote_debugging_enabled
    health_check_path                      = var.health_check_path
    health_check_eviction_time_in_min      = var.health_check_eviction_time_in_min
    pre_warmed_instance_count              = var.pre_warmed_instance_count
    elastic_instance_minimum               = var.elastic_instance_minimum
    app_scale_limit                        = var.app_scale_limit
    worker_count                           = var.site_config_worker_count

    # Application stack
    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        python_version      = lookup(application_stack.value, "python_version", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
        java_version        = lookup(application_stack.value, "java_version", null)
        powershell_core_version = lookup(application_stack.value, "powershell_core_version", null)
        use_custom_runtime  = lookup(application_stack.value, "use_custom_runtime", false)
      }
    }

    # CORS
    dynamic "cors" {
      for_each = var.cors_allowed_origins != null ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }

    # IP restrictions
    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
        service_tag               = lookup(ip_restriction.value, "service_tag", null)
        name                      = lookup(ip_restriction.value, "name", null)
        priority                  = lookup(ip_restriction.value, "priority", 100)
        action                    = lookup(ip_restriction.value, "action", "Allow")
      }
    }

    # Application Insights
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key               = var.application_insights_key
  }

  # App settings
  app_settings = merge(var.app_settings, {
    "FUNCTIONS_WORKER_RUNTIME" = var.worker_runtime
    "WEBSITE_RUN_FROM_PACKAGE" = var.run_from_package ? "1" : "0"
  })

  # VNet integration
  virtual_network_subnet_id = var.vnet_integration_subnet_id

  # Sticky settings
  dynamic "sticky_settings" {
    for_each = length(var.sticky_app_settings) > 0 || length(var.sticky_connection_strings) > 0 ? [1] : []
    content {
      app_setting_names       = var.sticky_app_settings
      connection_string_names = var.sticky_connection_strings
    }
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}
