#------------------------------------------------------------------------------
# Azure Document Intelligence Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Cognitive account name"
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

variable "sku_name" {
  description = "SKU name (F0=Free, S0=Standard)"
  type        = string
  default     = "S0"
}

variable "custom_subdomain_name" {
  description = "Custom subdomain name (required for AAD auth)"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------
variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "enable_network_acls" {
  description = "Enable network ACLs"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "Default network action"
  type        = string
  default     = "Deny"
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges"
  type        = list(string)
  default     = []
}

variable "virtual_network_rules" {
  description = "Virtual network rules"
  type = list(object({
    subnet_id               = string
    ignore_missing_endpoint = optional(bool, false)
  }))
  default = []
}

variable "fqdns" {
  description = "Allowed FQDNs for outbound"
  type        = list(string)
  default     = []
}

variable "outbound_network_access_restricted" {
  description = "Restrict outbound network access"
  type        = bool
  default     = false
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

variable "identity_client_id" {
  description = "Identity client ID for CMK"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------
variable "customer_managed_key_id" {
  description = "Key Vault key ID for CMK"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Storage
#------------------------------------------------------------------------------
variable "storage_account_id" {
  description = "Storage account ID for custom models"
  type        = string
  default     = null
}

variable "storage_identity_client_id" {
  description = "Identity client ID for storage access"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Authentication
#------------------------------------------------------------------------------
variable "local_auth_enabled" {
  description = "Enable local (key-based) authentication"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
