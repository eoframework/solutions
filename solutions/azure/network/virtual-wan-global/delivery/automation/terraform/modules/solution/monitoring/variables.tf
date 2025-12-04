#------------------------------------------------------------------------------
# Virtual WAN Monitoring Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Primary Azure region"
  type        = string
}

variable "secondary_location" {
  description = "Secondary Azure region"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Log Analytics Configuration
#------------------------------------------------------------------------------
variable "log_analytics_sku" {
  description = "SKU for Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerNode", "PerGB2018", "Standard", "Premium"], var.log_analytics_sku)
    error_message = "log_analytics_sku must be a valid Log Analytics SKU"
  }
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 90

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730"
  }
}

#------------------------------------------------------------------------------
# Alerting Configuration
#------------------------------------------------------------------------------
variable "enable_alerts" {
  description = "Enable monitoring alerts"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "ops-team@company.com"
}

#------------------------------------------------------------------------------
# Resource IDs for Diagnostic Settings
#------------------------------------------------------------------------------
variable "virtual_wan_id" {
  description = "ID of the Virtual WAN"
  type        = string
  default     = null
}

variable "primary_hub_id" {
  description = "ID of the primary Virtual Hub"
  type        = string
  default     = null
}

variable "secondary_hub_id" {
  description = "ID of the secondary Virtual Hub"
  type        = string
  default     = null
}

variable "primary_firewall_id" {
  description = "ID of the primary Azure Firewall"
  type        = string
  default     = null
}

variable "secondary_firewall_id" {
  description = "ID of the secondary Azure Firewall"
  type        = string
  default     = null
}

variable "primary_vpn_gateway_id" {
  description = "ID of the primary VPN Gateway"
  type        = string
  default     = null
}

variable "secondary_vpn_gateway_id" {
  description = "ID of the secondary VPN Gateway"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Network Watcher Configuration
#------------------------------------------------------------------------------
variable "enable_network_watcher" {
  description = "Enable Network Watcher"
  type        = bool
  default     = true
}
