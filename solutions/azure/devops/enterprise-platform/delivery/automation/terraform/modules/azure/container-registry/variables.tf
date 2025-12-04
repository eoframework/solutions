#------------------------------------------------------------------------------
# Azure Container Registry Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Container Registry name (must be globally unique)"
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

variable "sku" {
  description = "SKU (Basic, Standard, or Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium"
  }
}

variable "admin_enabled" {
  description = "Enable admin user"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "quarantine_policy_enabled" {
  description = "Enable quarantine policy"
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy (Premium SKU only)"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Network Rules
#------------------------------------------------------------------------------
variable "network_rule_set_enabled" {
  description = "Enable network rule set"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "Default network action"
  type        = string
  default     = "Allow"
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Allowed subnet IDs"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Identity
#------------------------------------------------------------------------------
variable "identity_type" {
  description = "Identity type (SystemAssigned or UserAssigned)"
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "User assigned identity IDs"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Retention Policy
#------------------------------------------------------------------------------
variable "retention_days" {
  description = "Retention days for untagged manifests (Premium SKU only)"
  type        = number
  default     = null
}

#------------------------------------------------------------------------------
# Trust Policy
#------------------------------------------------------------------------------
variable "trust_policy_enabled" {
  description = "Enable trust policy (Premium SKU only)"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------
variable "encryption_enabled" {
  description = "Enable encryption (Premium SKU only)"
  type        = bool
  default     = false
}

variable "encryption_key_vault_key_id" {
  description = "Key Vault key ID for encryption"
  type        = string
  default     = null
}

variable "encryption_identity_client_id" {
  description = "Identity client ID for encryption"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Georeplications
#------------------------------------------------------------------------------
variable "georeplications" {
  description = "Georeplications (Premium SKU only)"
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool, false)
  }))
  default = []
}

#------------------------------------------------------------------------------
# Webhooks
#------------------------------------------------------------------------------
variable "webhooks" {
  description = "Webhooks configuration"
  type = map(object({
    service_uri    = string
    actions        = list(string)
    status         = optional(string, "enabled")
    scope          = optional(string, "")
    custom_headers = optional(map(string), {})
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Scope Maps
#------------------------------------------------------------------------------
variable "scope_maps" {
  description = "Scope maps for token authentication"
  type = map(object({
    actions = list(string)
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Tokens
#------------------------------------------------------------------------------
variable "tokens" {
  description = "Tokens for authentication"
  type = map(object({
    scope_map_name = string
    enabled        = optional(bool, true)
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
