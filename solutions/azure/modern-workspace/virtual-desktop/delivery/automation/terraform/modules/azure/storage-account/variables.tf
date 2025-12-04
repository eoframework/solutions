#------------------------------------------------------------------------------
# Azure Storage Account Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Storage account name (must be globally unique, 3-24 lowercase alphanumeric)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 lowercase letters and numbers only."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the storage account"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be Standard or Premium."
  }
}

variable "replication_type" {
  description = "Replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Invalid replication type."
  }
}

variable "account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "Access tier for blob storage (Hot or Cool)"
  type        = string
  default     = "Hot"
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "allow_public_access" {
  description = "Allow public access to blobs"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Enable shared access key authentication"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "large_file_share_enabled" {
  description = "Enable large file shares"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Azure Files Authentication
#------------------------------------------------------------------------------
variable "azure_files_authentication" {
  description = "Azure Files authentication configuration"
  type = object({
    directory_type = string
    active_directory = optional(object({
      domain_guid         = string
      domain_name         = string
      domain_sid          = string
      forest_name         = string
      netbios_domain_name = string
      storage_sid         = string
    }))
  })
  default = null
}

#------------------------------------------------------------------------------
# File Shares
#------------------------------------------------------------------------------
variable "file_shares" {
  description = "Map of file shares to create"
  type = map(object({
    quota_gb    = number
    protocol    = optional(string, "SMB")
    access_tier = optional(string)
    metadata    = optional(map(string), {})
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Containers
#------------------------------------------------------------------------------
variable "containers" {
  description = "Map of containers to create"
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Network Rules
#------------------------------------------------------------------------------
variable "enable_network_rules" {
  description = "Enable network rules"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "Default action for network rules"
  type        = string
  default     = "Deny"
}

variable "network_bypass" {
  description = "Services to bypass network rules"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed through network rules"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Subnet IDs allowed through network rules"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Identity
#------------------------------------------------------------------------------
variable "identity_type" {
  description = "Identity type (SystemAssigned, UserAssigned, or both)"
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "List of user-assigned identity IDs"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
