#------------------------------------------------------------------------------
# Azure Virtual Desktop - Production Environment Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Solution Identity
#------------------------------------------------------------------------------
variable "solution" {
  description = "Solution identification and metadata"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
  })
}

variable "ownership" {
  description = "Solution ownership and cost allocation"
  type = object({
    cost_center  = string
    owner_email  = string
    project_code = string
  })
}

#------------------------------------------------------------------------------
# Azure Configuration
#------------------------------------------------------------------------------
variable "azure" {
  description = "Azure subscription and region configuration"
  type = object({
    subscription_id = string
    tenant_id       = string
    region          = string
    dr_region       = string
  })
}

#------------------------------------------------------------------------------
# Network Configuration
#------------------------------------------------------------------------------
variable "network" {
  description = "Virtual network configuration"
  type = object({
    vnet_cidr                = string
    session_hosts_cidr       = string
    private_endpoint_cidr    = string
    private_endpoint_enabled = bool
  })
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
variable "security" {
  description = "Security and access control configuration"
  type = object({
    enable_private_endpoints    = bool
    enable_customer_managed_key = bool
    admin_group_id              = string
    user_group_id               = string
  })
}

#------------------------------------------------------------------------------
# AVD Host Pool Configuration
#------------------------------------------------------------------------------
variable "avd" {
  description = "Azure Virtual Desktop configuration"
  type = object({
    host_pool_type             = string
    host_pool_load_balancer    = string
    max_session_limit          = number
    start_vm_on_connect        = bool
    personal_desktop_assignment = string
    validate_environment       = bool
  })
}

#------------------------------------------------------------------------------
# Session Host Configuration
#------------------------------------------------------------------------------
variable "session_hosts" {
  description = "Session host configuration"
  type = object({
    vm_size                 = string
    vm_count                = number
    vm_image_publisher      = string
    vm_image_offer          = string
    vm_image_sku            = string
    vm_image_version        = string
    os_disk_type            = string
    os_disk_size_gb         = number
    enable_accelerated_networking = bool
  })
}

#------------------------------------------------------------------------------
# Auto-scaling Configuration
#------------------------------------------------------------------------------
variable "autoscale" {
  description = "Auto-scaling configuration"
  type = object({
    enabled                  = bool
    min_session_hosts        = number
    max_session_hosts        = number
    scale_up_threshold       = number
    scale_down_threshold     = number
    ramp_up_start_time       = string
    ramp_up_capacity_threshold = number
    peak_start_time          = string
    ramp_down_start_time     = string
    ramp_down_capacity_threshold = number
    off_peak_start_time      = string
    timezone                 = string
  })
}

#------------------------------------------------------------------------------
# Storage Configuration (FSLogix)
#------------------------------------------------------------------------------
variable "storage" {
  description = "Azure Files storage configuration for FSLogix profiles"
  type = object({
    account_tier             = string
    account_replication_type = string
    share_quota_gb           = number
    enable_smb_multichannel  = bool
    enable_large_file_shares = bool
  })
}

#------------------------------------------------------------------------------
# Application Configuration
#------------------------------------------------------------------------------
variable "application" {
  description = "Application settings"
  type = object({
    environment = string
    log_level   = string
  })
}

#------------------------------------------------------------------------------
# Application Groups Configuration
#------------------------------------------------------------------------------
variable "app_groups" {
  description = "Application group configuration"
  type = object({
    desktop_enabled       = bool
    remoteapp_enabled     = bool
    desktop_friendly_name = string
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "Azure Monitor configuration"
  type = object({
    enable_alerts           = bool
    enable_dashboard        = bool
    log_retention_days      = number
    alert_email             = string
    health_check_interval   = number
  })
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------
variable "backup" {
  description = "Backup and recovery configuration"
  type = object({
    enabled        = bool
    retention_days = number
  })
}

#------------------------------------------------------------------------------
# Budget Configuration
#------------------------------------------------------------------------------
variable "budget" {
  description = "Cost management budget configuration"
  type = object({
    enabled            = bool
    monthly_amount     = number
    alert_thresholds   = list(number)
    notification_email = string
  })
}

#------------------------------------------------------------------------------
# Policy Configuration
#------------------------------------------------------------------------------
variable "policies" {
  description = "Azure Policy configuration"
  type = object({
    enable_security_policies    = bool
    enable_cost_policies        = bool
    enable_operational_policies = bool
  })
}

#------------------------------------------------------------------------------
# Disaster Recovery Configuration
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster recovery configuration"
  type = object({
    enabled             = bool
    replication_enabled = bool
    failover_priority   = number
  })
}
