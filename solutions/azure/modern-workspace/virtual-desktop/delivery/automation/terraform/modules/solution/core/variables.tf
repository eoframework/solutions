#------------------------------------------------------------------------------
# Core Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "network" {
  description = "Network configuration"
  type = object({
    vnet_cidr                = string
    session_hosts_cidr       = string
    private_endpoint_cidr    = string
    private_endpoint_enabled = bool
  })
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "object_id" {
  description = "Object ID of the service principal or user deploying the resources"
  type        = string
}
