#------------------------------------------------------------------------------
# Monitoring Module Variables
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

variable "host_pool_id" {
  description = "ID of the AVD host pool"
  type        = string
}

variable "workspace_id" {
  description = "ID of the AVD workspace"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account"
  type        = string
}

variable "session_host_vm_ids" {
  description = "IDs of session host VMs"
  type        = list(string)
}

variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    enable_alerts         = bool
    enable_dashboard      = bool
    log_retention_days    = number
    alert_email           = string
    health_check_interval = number
  })
}
