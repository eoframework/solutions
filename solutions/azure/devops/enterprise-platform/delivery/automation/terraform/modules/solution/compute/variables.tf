#------------------------------------------------------------------------------
# Compute Module - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "app_service_config" {
  description = "App Service configuration"
  type = object({
    name_prefix               = string
    sku                       = string
    tier                      = string
    min_instances             = number
    max_instances             = number
    autoscale_enabled         = bool
    deployment_slots_enabled  = bool
  })
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

variable "key_vault_uri" {
  description = "Key Vault URI"
  type        = string
}

variable "managed_identity_id" {
  description = "Managed identity ID"
  type        = string
}

variable "application" {
  description = "Application configuration"
  type = object({
    environment           = string
    log_level             = string
    runtime_stack         = string
    runtime_version       = string
  })
}
