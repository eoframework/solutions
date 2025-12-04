#------------------------------------------------------------------------------
# Disaster Recovery Module - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Primary Azure region"
  type        = string
}

variable "dr_location" {
  description = "DR Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Primary resource group name"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "source_app_service_id" {
  description = "Source App Service ID"
  type        = string
}

variable "dr" {
  description = "DR configuration"
  type = object({
    enabled                = bool
    replication_enabled    = bool
    failover_priority      = number
  })
}
