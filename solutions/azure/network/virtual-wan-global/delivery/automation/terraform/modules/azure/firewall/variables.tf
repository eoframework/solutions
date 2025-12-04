#------------------------------------------------------------------------------
# Azure Firewall Module Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Azure Firewall"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the Firewall"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Firewall"
  type        = string
  default     = "AZFW_Hub"

  validation {
    condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.sku_name)
    error_message = "sku_name must be either AZFW_Hub or AZFW_VNet"
  }
}

variable "sku_tier" {
  description = "SKU tier for the Firewall"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium", "Basic"], var.sku_tier)
    error_message = "sku_tier must be Standard, Premium, or Basic"
  }
}

variable "virtual_hub_id" {
  description = "ID of the Virtual Hub"
  type        = string
}

variable "public_ip_count" {
  description = "Number of public IPs for the Firewall"
  type        = number
  default     = 1

  validation {
    condition     = var.public_ip_count >= 1 && var.public_ip_count <= 100
    error_message = "public_ip_count must be between 1 and 100"
  }
}

variable "firewall_policy_id" {
  description = "ID of an existing Firewall Policy (if not creating new one)"
  type        = string
  default     = null
}

variable "create_policy" {
  description = "Create a new Firewall Policy"
  type        = bool
  default     = true
}

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

variable "tags" {
  description = "Tags to apply to the Firewall"
  type        = map(string)
  default     = {}
}
