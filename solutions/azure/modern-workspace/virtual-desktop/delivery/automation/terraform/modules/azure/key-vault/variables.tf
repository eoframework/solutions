#------------------------------------------------------------------------------
# Azure Key Vault Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Key Vault name (must be globally unique)"
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

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "sku_name" {
  description = "SKU name (standard or premium)"
  type        = string
  default     = "standard"
}

#------------------------------------------------------------------------------
# Security Settings
#------------------------------------------------------------------------------
variable "enabled_for_deployment" {
  description = "Enable for VM deployment"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Enable for disk encryption"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Enable for ARM template deployment"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Use RBAC for authorization (recommended)"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days (7-90)"
  type        = number
  default     = 90
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Network ACLs
#------------------------------------------------------------------------------
variable "enable_network_acls" {
  description = "Enable network ACLs"
  type        = bool
  default     = false
}

variable "network_bypass" {
  description = "Services to bypass network rules"
  type        = string
  default     = "AzureServices"
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

variable "allowed_subnet_ids" {
  description = "Allowed subnet IDs"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Access Policies (when not using RBAC)
#------------------------------------------------------------------------------
variable "access_policies" {
  description = "Access policies (used when RBAC is disabled)"
  type = list(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = []
}

#------------------------------------------------------------------------------
# RBAC Role Assignments
#------------------------------------------------------------------------------
variable "role_assignments" {
  description = "RBAC role assignments"
  type = map(object({
    role_definition_name = string
    principal_id         = string
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Keys
#------------------------------------------------------------------------------
variable "keys" {
  description = "Keys to create"
  type = map(object({
    key_type = string
    key_size = optional(number, 2048)
    key_opts = list(string)
    rotation_policy = optional(object({
      expire_after         = optional(string)
      notify_before_expiry = optional(string)
      time_after_creation  = optional(string)
    }))
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Secrets
#------------------------------------------------------------------------------
variable "secrets" {
  description = "Secrets to create (keys are secret names, values contain configuration)"
  type = map(object({
    value           = string
    content_type    = optional(string)
    expiration_date = optional(string)
    not_before_date = optional(string)
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
