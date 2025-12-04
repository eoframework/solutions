#------------------------------------------------------------------------------
# Azure Virtual Network Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "VNet name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "address_space" {
  description = "VNet address space"
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "ddos_protection_plan_id" {
  description = "DDoS protection plan ID"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Subnets
#------------------------------------------------------------------------------
variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Disabled")
    private_link_service_network_policies_enabled = optional(bool, false)
    nsg_name                                      = optional(string)
    delegation = optional(object({
      name                    = string
      service_delegation_name = string
      actions                 = optional(list(string))
    }))
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Network Security Groups
#------------------------------------------------------------------------------
variable "network_security_groups" {
  description = "Map of NSGs to create"
  type = map(object({
    rules = optional(list(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
    })), [])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
