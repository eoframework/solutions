# Variables for Dell VxRail HCI deployment

# Project Configuration
variable "project_name" {
  description = "Name of the VxRail project"
  type        = string
  default     = "vxrail-hci"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "resource_owner" {
  description = "Owner of the VxRail resources"
  type        = string
  default     = "Infrastructure-Team"
}

# vSphere Connection Configuration
variable "vsphere_server" {
  description = "vSphere server (vCenter) FQDN or IP address"
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "allow_unverified_ssl" {
  description = "Allow unverified SSL certificates"
  type        = bool
  default     = false
}

# vSphere Environment Configuration
variable "datacenter_name" {
  description = "vSphere datacenter name"
  type        = string
}

variable "compute_cluster_name" {
  description = "vSphere compute cluster name"
  type        = string
}

variable "datastore_cluster_name" {
  description = "vSphere datastore cluster name for VxRail storage"
  type        = string
}

# Network Configuration
variable "management_network_name" {
  description = "Management network name"
  type        = string
  default     = "Management Network"
}

variable "vmotion_network_name" {
  description = "vMotion network name"
  type        = string
  default     = "vMotion Network"
}

variable "vsan_network_name" {
  description = "vSAN network name"
  type        = string
  default     = "vSAN Network"
}

variable "vm_network_name" {
  description = "VM network name"
  type        = string
  default     = "VM Network"
}

# VLAN Configuration
variable "management_vlan_id" {
  description = "Management VLAN ID"
  type        = number
  default     = 100
}

variable "vmotion_vlan_id" {
  description = "vMotion VLAN ID"
  type        = number
  default     = 101
}

variable "vsan_vlan_id" {
  description = "vSAN VLAN ID"
  type        = number
  default     = 102
}

variable "vm_vlan_id" {
  description = "VM VLAN ID"
  type        = number
  default     = 103
}

# Network Addressing
variable "management_subnet" {
  description = "Management subnet CIDR"
  type        = string
  default     = "192.168.100.0/24"
}

variable "management_gateway" {
  description = "Management network gateway"
  type        = string
  default     = "192.168.100.1"
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "domain_name" {
  description = "Domain name for VxRail nodes"
  type        = string
  default     = "vxrail.local"
}

# VxRail Node Configuration
variable "vxrail_node_count" {
  description = "Number of VxRail nodes"
  type        = number
  default     = 4
  
  validation {
    condition     = var.vxrail_node_count >= 3
    error_message = "VxRail cluster requires minimum 3 nodes."
  }
}

variable "node_cpu_count" {
  description = "Number of CPUs per VxRail node"
  type        = number
  default     = 16
}

variable "node_cores_per_socket" {
  description = "Number of cores per socket"
  type        = number
  default     = 8
}

variable "node_memory_mb" {
  description = "Memory per VxRail node in MB"
  type        = number
  default     = 131072  # 128GB
}

# Storage Configuration
variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 100
}

variable "cache_disk_size_gb" {
  description = "vSAN cache disk size in GB (SSD)"
  type        = number
  default     = 400
}

variable "capacity_disk_size_gb" {
  description = "vSAN capacity disk size in GB"
  type        = number
  default     = 2000
}

variable "capacity_disk_count" {
  description = "Number of capacity disks per node"
  type        = number
  default     = 4
}

# VxRail Manager Template
variable "vxrail_manager_template" {
  description = "VxRail Manager VM template name"
  type        = string
  default     = "VxRail-Manager-Template"
}

# Resource Pool Configuration
variable "cpu_reservation" {
  description = "CPU reservation in MHz"
  type        = number
  default     = 8000
}

variable "cpu_limit" {
  description = "CPU limit in MHz (-1 for unlimited)"
  type        = number
  default     = -1
}

variable "memory_reservation" {
  description = "Memory reservation in MB"
  type        = number
  default     = 16384
}

variable "memory_limit" {
  description = "Memory limit in MB (-1 for unlimited)"
  type        = number
  default     = -1
}

# Distributed Virtual Switch Configuration
variable "vds_uplinks" {
  description = "Number of uplinks for VDS"
  type        = list(string)
  default     = ["uplink1", "uplink2", "uplink3", "uplink4"]
}

variable "vds_active_uplinks" {
  description = "Active uplinks for VDS"
  type        = list(string)
  default     = ["uplink1", "uplink2"]
}

variable "vds_standby_uplinks" {
  description = "Standby uplinks for VDS"
  type        = list(string)
  default     = ["uplink3", "uplink4"]
}

variable "vds_max_mtu" {
  description = "Maximum MTU for VDS"
  type        = number
  default     = 9000
}

# DRS Configuration
variable "drs_automation_level" {
  description = "DRS automation level"
  type        = string
  default     = "fullyAutomated"
  
  validation {
    condition = contains([
      "manual", "partiallyAutomated", "fullyAutomated"
    ], var.drs_automation_level)
    error_message = "DRS automation level must be manual, partiallyAutomated, or fullyAutomated."
  }
}

# vSAN Configuration
variable "vsan_enabled" {
  description = "Enable vSAN storage"
  type        = bool
  default     = true
}

variable "vsan_dedup_enabled" {
  description = "Enable vSAN deduplication and compression"
  type        = bool
  default     = true
}

variable "vsan_encryption_enabled" {
  description = "Enable vSAN encryption"
  type        = bool
  default     = false
}

# Monitoring and Management
variable "enable_vsphere_ha" {
  description = "Enable vSphere High Availability"
  type        = bool
  default     = true
}

variable "enable_vsphere_drs" {
  description = "Enable vSphere Distributed Resource Scheduler"
  type        = bool
  default     = true
}

variable "enable_vsphere_evc" {
  description = "Enable vSphere Enhanced vMotion Compatibility"
  type        = bool
  default     = true
}

# Backup Configuration
variable "backup_schedule_enabled" {
  description = "Enable scheduled backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 30
}

# Monitoring Configuration
variable "monitoring_enabled" {
  description = "Enable monitoring integration"
  type        = bool
  default     = true
}

variable "logging_enabled" {
  description = "Enable centralized logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 90
}

# Performance Tuning
variable "enable_performance_monitoring" {
  description = "Enable performance monitoring"
  type        = bool
  default     = true
}

variable "performance_interval_minutes" {
  description = "Performance monitoring interval in minutes"
  type        = number
  default     = 5
}

# Security Configuration
variable "enable_lockdown_mode" {
  description = "Enable ESXi lockdown mode"
  type        = string
  default     = "normal"
  
  validation {
    condition = contains([
      "disabled", "normal", "strict"
    ], var.enable_lockdown_mode)
    error_message = "Lockdown mode must be disabled, normal, or strict."
  }
}

variable "enable_secure_boot" {
  description = "Enable secure boot for VMs"
  type        = bool
  default     = false
}

# Maintenance Configuration
variable "maintenance_mode_timeout" {
  description = "Maintenance mode timeout in seconds"
  type        = number
  default     = 3600
}

variable "auto_patch_enabled" {
  description = "Enable automatic patching"
  type        = bool
  default     = false
}

# License Configuration
variable "vsphere_license_key" {
  description = "vSphere license key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vsan_license_key" {
  description = "vSAN license key"
  type        = string
  default     = ""
  sensitive   = true
}