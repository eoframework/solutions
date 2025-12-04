#------------------------------------------------------------------------------
# Azure VPN Gateway Module Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Name of the VPN Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the VPN Gateway"
  type        = string
}

variable "virtual_hub_id" {
  description = "ID of the Virtual Hub"
  type        = string
}

variable "scale_unit" {
  description = "Scale unit for the VPN Gateway (defines throughput)"
  type        = number
  default     = 1

  validation {
    condition     = var.scale_unit >= 1 && var.scale_unit <= 100
    error_message = "scale_unit must be between 1 and 100"
  }
}

variable "routing_preference" {
  description = "Routing preference for the VPN Gateway"
  type        = string
  default     = "Microsoft Network"

  validation {
    condition     = contains(["Microsoft Network", "Internet"], var.routing_preference)
    error_message = "routing_preference must be 'Microsoft Network' or 'Internet'"
  }
}

variable "bgp_settings" {
  description = "BGP settings for the VPN Gateway"
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

variable "tags" {
  description = "Tags to apply to the VPN Gateway"
  type        = map(string)
  default     = {}
}
