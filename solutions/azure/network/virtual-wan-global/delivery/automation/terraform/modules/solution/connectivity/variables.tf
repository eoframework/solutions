#------------------------------------------------------------------------------
# Virtual WAN Connectivity Module Variables
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
# VPN Gateway Configuration
#------------------------------------------------------------------------------
variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway in hubs"
  type        = bool
  default     = true
}

variable "vpn_gateway_scale_unit" {
  description = "Scale unit for VPN Gateways"
  type        = number
  default     = 1
}

variable "vpn_routing_preference" {
  description = "Routing preference for VPN Gateways"
  type        = string
  default     = "Microsoft Network"
}

variable "vpn_bgp_settings" {
  description = "BGP settings for primary VPN Gateway"
  type = object({
    asn         = number
    peer_weight = number
    instance_0_bgp_peering_address = optional(object({
      custom_ips = list(string)
    }))
    instance_1_bgp_peering_address = optional(object({
      custom_ips = list(string)
    }))
  })
  default = null
}

variable "vpn_bgp_settings_secondary" {
  description = "BGP settings for secondary VPN Gateway"
  type = object({
    asn         = number
    peer_weight = number
    instance_0_bgp_peering_address = optional(object({
      custom_ips = list(string)
    }))
    instance_1_bgp_peering_address = optional(object({
      custom_ips = list(string)
    }))
  })
  default = null
}

#------------------------------------------------------------------------------
# ExpressRoute Gateway Configuration
#------------------------------------------------------------------------------
variable "enable_expressroute_gateway" {
  description = "Enable ExpressRoute Gateway in hubs"
  type        = bool
  default     = true
}

variable "er_gateway_scale_units" {
  description = "Scale units for ExpressRoute Gateways"
  type        = number
  default     = 1
}

variable "er_allow_non_vwan_traffic" {
  description = "Allow non-Virtual WAN traffic through ExpressRoute Gateway"
  type        = bool
  default     = false
}
