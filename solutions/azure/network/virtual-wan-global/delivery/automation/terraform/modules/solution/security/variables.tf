#------------------------------------------------------------------------------
# Virtual WAN Security Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "primary_location" {
  description = "Primary Azure region"
  type        = string
}

variable "secondary_location" {
  description = "Secondary Azure region"
  type        = string
  default     = null
}

variable "primary_hub_id" {
  description = "ID of the primary Virtual Hub"
  type        = string
}

variable "secondary_hub_id" {
  description = "ID of the secondary Virtual Hub"
  type        = string
  default     = null
}

variable "enable_secondary_hub" {
  description = "Enable secondary hub resources"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Firewall Configuration
#------------------------------------------------------------------------------
variable "enable_firewall" {
  description = "Enable Azure Firewall in hubs"
  type        = bool
  default     = true
}

variable "firewall_sku_tier" {
  description = "SKU tier for Azure Firewall (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium", "Basic"], var.firewall_sku_tier)
    error_message = "firewall_sku_tier must be Standard, Premium, or Basic"
  }
}

variable "firewall_public_ip_count" {
  description = "Number of public IPs for each firewall"
  type        = number
  default     = 1
}

variable "create_firewall_policy" {
  description = "Create firewall policy"
  type        = bool
  default     = true
}

variable "share_firewall_policy" {
  description = "Share policy between primary and secondary firewalls"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Firewall Policy Configuration
#------------------------------------------------------------------------------
variable "dns_proxy_enabled" {
  description = "Enable DNS proxy"
  type        = bool
  default     = true
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = []
}

variable "threat_intelligence_mode" {
  description = "Threat intelligence mode"
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.threat_intelligence_mode)
    error_message = "threat_intelligence_mode must be Alert, Deny, or Off"
  }
}

variable "intrusion_detection_mode" {
  description = "Intrusion detection mode (requires Premium SKU)"
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.intrusion_detection_mode)
    error_message = "intrusion_detection_mode must be Alert, Deny, or Off"
  }
}

variable "signature_overrides" {
  description = "IDPS signature overrides"
  type = list(object({
    id    = string
    state = string
  }))
  default = []
}

variable "traffic_bypass" {
  description = "Traffic bypass rules for intrusion detection"
  type = list(object({
    name                  = string
    protocol              = string
    destination_addresses = list(string)
    destination_ports     = list(string)
    source_addresses      = list(string)
  }))
  default = []
}

variable "network_rule_collections" {
  description = "Network rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      protocols             = list(string)
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
    }))
  }))
  default = []
}

variable "application_rule_collections" {
  description = "Application rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name              = string
      source_addresses  = list(string)
      destination_fqdns = list(string)
      protocols = list(object({
        type = string
        port = number
      }))
    }))
  }))
  default = []
}
