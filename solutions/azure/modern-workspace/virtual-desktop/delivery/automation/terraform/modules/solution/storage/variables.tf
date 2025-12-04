#------------------------------------------------------------------------------
# Storage Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource naming"
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

variable "subnet_id" {
  description = "Subnet ID for private endpoint (optional)"
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "storage" {
  description = "Storage account configuration"
  type = object({
    account_tier             = string
    account_replication_type = string
    share_quota_gb           = number
    enable_smb_multichannel  = bool
    enable_large_file_shares = bool
  })
}
