#------------------------------------------------------------------------------
# Azure Function App Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Function app name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

#------------------------------------------------------------------------------
# Service Plan
#------------------------------------------------------------------------------
variable "create_service_plan" {
  description = "Create a new service plan"
  type        = bool
  default     = true
}

variable "service_plan_id" {
  description = "Existing service plan ID (if not creating)"
  type        = string
  default     = null
}

variable "service_plan_name" {
  description = "Service plan name"
  type        = string
  default     = null
}

variable "sku_name" {
  description = "SKU name (Y1=Consumption, EP1-3=Premium, B1-3/S1-3/P1v3-3=Dedicated)"
  type        = string
  default     = "Y1"
}

variable "max_elastic_worker_count" {
  description = "Max elastic worker count (Premium only)"
  type        = number
  default     = 20
}

variable "worker_count" {
  description = "Number of workers"
  type        = number
  default     = null
}

#------------------------------------------------------------------------------
# Storage
#------------------------------------------------------------------------------
variable "storage_account_name" {
  description = "Storage account name for function app"
  type        = string
}

variable "storage_account_access_key" {
  description = "Storage account access key"
  type        = string
  sensitive   = true
}

#------------------------------------------------------------------------------
# Runtime
#------------------------------------------------------------------------------
variable "functions_extension_version" {
  description = "Functions runtime version (~4, ~3)"
  type        = string
  default     = "~4"
}

variable "worker_runtime" {
  description = "Worker runtime (python, node, dotnet, java, powershell)"
  type        = string
  default     = "python"
}

variable "application_stack" {
  description = "Application stack configuration"
  type = object({
    python_version          = optional(string)
    node_version            = optional(string)
    dotnet_version          = optional(string)
    java_version            = optional(string)
    powershell_core_version = optional(string)
    use_custom_runtime      = optional(bool, false)
  })
  default = {
    python_version = "3.11"
  }
}

variable "run_from_package" {
  description = "Run from deployment package"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------
variable "https_only" {
  description = "Force HTTPS"
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "ftps_state" {
  description = "FTPS state (AllAllowed, FtpsOnly, Disabled)"
  type        = string
  default     = "Disabled"
}

variable "client_certificate_enabled" {
  description = "Enable client certificates"
  type        = bool
  default     = false
}

variable "client_certificate_mode" {
  description = "Client certificate mode"
  type        = string
  default     = "Optional"
}

#------------------------------------------------------------------------------
# Identity
#------------------------------------------------------------------------------
variable "identity_type" {
  description = "Identity type (SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "User-assigned identity IDs"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Site Config
#------------------------------------------------------------------------------
variable "always_on" {
  description = "Keep app always on (not supported on Consumption)"
  type        = bool
  default     = false
}

variable "http2_enabled" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "use_32_bit_worker" {
  description = "Use 32-bit worker process"
  type        = bool
  default     = false
}

variable "vnet_route_all_enabled" {
  description = "Route all traffic through VNet"
  type        = bool
  default     = false
}

variable "remote_debugging_enabled" {
  description = "Enable remote debugging"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "Health check eviction time"
  type        = number
  default     = null
}

variable "pre_warmed_instance_count" {
  description = "Pre-warmed instances (Premium only)"
  type        = number
  default     = null
}

variable "elastic_instance_minimum" {
  description = "Minimum elastic instances"
  type        = number
  default     = null
}

variable "app_scale_limit" {
  description = "Max scale out limit"
  type        = number
  default     = null
}

variable "site_config_worker_count" {
  description = "Worker count in site config"
  type        = number
  default     = null
}

variable "builtin_logging_enabled" {
  description = "Enable built-in logging"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# CORS
#------------------------------------------------------------------------------
variable "cors_allowed_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = null
}

variable "cors_support_credentials" {
  description = "Support credentials in CORS"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# IP Restrictions
#------------------------------------------------------------------------------
variable "ip_restrictions" {
  description = "IP restrictions"
  type = list(object({
    ip_address                = optional(string)
    virtual_network_subnet_id = optional(string)
    service_tag               = optional(string)
    name                      = optional(string)
    priority                  = optional(number, 100)
    action                    = optional(string, "Allow")
  }))
  default = []
}

#------------------------------------------------------------------------------
# Application Insights
#------------------------------------------------------------------------------
variable "application_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  default     = null
}

variable "application_insights_key" {
  description = "Application Insights instrumentation key"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# App Settings
#------------------------------------------------------------------------------
variable "app_settings" {
  description = "Additional app settings"
  type        = map(string)
  default     = {}
}

variable "sticky_app_settings" {
  description = "App settings that should be sticky to slot"
  type        = list(string)
  default     = []
}

variable "sticky_connection_strings" {
  description = "Connection strings that should be sticky to slot"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# VNet Integration
#------------------------------------------------------------------------------
variable "vnet_integration_subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
