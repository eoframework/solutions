variable "resource_group_name" {
  description = "Name of the resource group for AVD resources"
  type        = string
  default     = "rg-avd-prod"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "avd"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-avd-prod"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet for AVD session hosts"
  type        = string
  default     = "snet-avd-hosts"
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the AVD subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "law-avd-prod"
}

variable "storage_account_name" {
  description = "Name of the storage account for FSLogix profiles"
  type        = string
  default     = "stavdprofilesprod"
  
  validation {
    condition     = length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 characters long and contain only lowercase letters and numbers."
  }
}

variable "profiles_share_quota" {
  description = "Quota for the FSLogix profiles file share in GB"
  type        = number
  default     = 1024
}

variable "host_pool_name" {
  description = "Name of the AVD host pool"
  type        = string
  default     = "hp-avd-prod"
}

variable "workspace_name" {
  description = "Name of the AVD workspace"
  type        = string
  default     = "ws-avd-prod"
}

variable "max_sessions_per_host" {
  description = "Maximum number of sessions allowed per session host"
  type        = number
  default     = 10
}

variable "session_host_count" {
  description = "Number of session host VMs to create"
  type        = number
  default     = 3
}

variable "session_host_vm_size" {
  description = "VM size for session hosts"
  type        = string
  default     = "Standard_D4s_v4"
}

variable "admin_username" {
  description = "Administrator username for session host VMs"
  type        = string
  default     = "avdadmin"
}

variable "admin_password" {
  description = "Administrator password for session host VMs"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "Admin password must be at least 12 characters long."
  }
}

variable "domain_name" {
  description = "Active Directory domain name (if joining to domain)"
  type        = string
  default     = ""
}

variable "domain_join_username" {
  description = "Username for domain join operation"
  type        = string
  default     = ""
  sensitive   = true
}

variable "domain_join_password" {
  description = "Password for domain join operation"
  type        = string
  default     = ""
  sensitive   = true
}

variable "organizational_unit" {
  description = "OU path for computer objects"
  type        = string
  default     = ""
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking on session host NICs"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor for AVD resources"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable Azure Backup for profile storage"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "auto_shutdown_time" {
  description = "Time to auto-shutdown session hosts (24h format, e.g., '1900')"
  type        = string
  default     = ""
}

variable "timezone" {
  description = "Timezone for auto-shutdown schedule"
  type        = string
  default     = "Eastern Standard Time"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "AVD"
    Owner       = "IT Operations"
  }
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for storage account"
  type        = bool
  default     = true
}

variable "allowed_source_ip_ranges" {
  description = "IP ranges allowed to access the environment"
  type        = list(string)
  default     = []
}

variable "custom_image_id" {
  description = "Resource ID of custom VM image (optional)"
  type        = string
  default     = ""
}

variable "install_nvidia_drivers" {
  description = "Install NVIDIA GPU drivers for GPU-enabled VMs"
  type        = bool
  default     = false
}

variable "fslogix_version" {
  description = "Version of FSLogix to install"
  type        = string
  default     = "latest"
}

variable "office_version" {
  description = "Version of Microsoft Office to install"
  type        = string
  default     = "2021"
}