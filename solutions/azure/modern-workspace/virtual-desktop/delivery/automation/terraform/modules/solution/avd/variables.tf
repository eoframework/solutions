#------------------------------------------------------------------------------
# AVD Module Variables
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
  description = "Subnet ID for session hosts"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for secrets"
  type        = string
}

variable "managed_identity_id" {
  description = "Managed identity ID for session hosts"
  type        = string
}

variable "avd" {
  description = "AVD host pool configuration"
  type = object({
    host_pool_type              = string
    host_pool_load_balancer     = string
    max_session_limit           = number
    start_vm_on_connect         = bool
    personal_desktop_assignment = string
    validate_environment        = bool
  })
}

variable "session_hosts" {
  description = "Session host VM configuration"
  type = object({
    vm_size                       = string
    vm_count                      = number
    vm_image_publisher            = string
    vm_image_offer                = string
    vm_image_sku                  = string
    vm_image_version              = string
    os_disk_type                  = string
    os_disk_size_gb               = number
    enable_accelerated_networking = bool
  })
}

variable "autoscale" {
  description = "Auto-scaling configuration"
  type = object({
    enabled                      = bool
    min_session_hosts            = number
    max_session_hosts            = number
    scale_up_threshold           = number
    scale_down_threshold         = number
    ramp_up_start_time           = string
    ramp_up_capacity_threshold   = number
    peak_start_time              = string
    ramp_down_start_time         = string
    ramp_down_capacity_threshold = number
    off_peak_start_time          = string
    timezone                     = string
  })
}

variable "app_groups" {
  description = "Application group configuration"
  type = object({
    desktop_enabled       = bool
    remoteapp_enabled     = bool
    desktop_friendly_name = string
  })
}

variable "storage_account_name" {
  description = "Storage account name for FSLogix profiles"
  type        = string
}

variable "storage_share_name" {
  description = "File share name for FSLogix profiles"
  type        = string
}
