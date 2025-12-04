#------------------------------------------------------------------------------
# Azure App Service Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "App Service Plan name"
  type        = string
}

variable "app_name" {
  description = "App Service name"
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

variable "os_type" {
  description = "OS type (Linux or Windows)"
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either Linux or Windows"
  }
}

variable "sku_name" {
  description = "SKU name (e.g., B1, S1, P1v2, P1v3)"
  type        = string
}

#------------------------------------------------------------------------------
# Identity
#------------------------------------------------------------------------------
variable "identity_type" {
  description = "Identity type (SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "User assigned identity IDs"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Site Config
#------------------------------------------------------------------------------
variable "always_on" {
  description = "Always on"
  type        = bool
  default     = true
}

variable "https_only" {
  description = "HTTPS only"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "Health check eviction time in minutes"
  type        = number
  default     = null
}

variable "ftps_state" {
  description = "FTPS state (Disabled, FtpsOnly, AllAllowed)"
  type        = string
  default     = "Disabled"
}

variable "http2_enabled" {
  description = "HTTP/2 enabled"
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "application_stack" {
  description = "Application stack configuration"
  type        = map(string)
  default     = null
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = null
}

variable "cors_support_credentials" {
  description = "CORS support credentials"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# App Settings
#------------------------------------------------------------------------------
variable "app_settings" {
  description = "App settings"
  type        = map(string)
  default     = {}
}

variable "connection_strings" {
  description = "Connection strings"
  type = map(object({
    type  = string
    value = string
  }))
  default = {}
}

#------------------------------------------------------------------------------
# VNet Integration
#------------------------------------------------------------------------------
variable "subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Deployment Slots
#------------------------------------------------------------------------------
variable "deployment_slots" {
  description = "Deployment slots configuration"
  type = map(object({
    app_settings = optional(map(string), {})
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Autoscaling
#------------------------------------------------------------------------------
variable "autoscale_enabled" {
  description = "Enable autoscaling"
  type        = bool
  default     = false
}

variable "autoscale_min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "autoscale_max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "autoscale_default_instances" {
  description = "Default number of instances"
  type        = number
  default     = 1
}

variable "autoscale_cpu_threshold_up" {
  description = "CPU threshold for scaling up"
  type        = number
  default     = 70
}

variable "autoscale_cpu_threshold_down" {
  description = "CPU threshold for scaling down"
  type        = number
  default     = 30
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
