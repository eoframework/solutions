#------------------------------------------------------------------------------
# Azure Virtual Hub Module Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Virtual Hub"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the Virtual Hub"
  type        = string
}

variable "virtual_wan_id" {
  description = "ID of the Virtual WAN"
  type        = string
}

variable "address_prefix" {
  description = "Address prefix for the Virtual Hub"
  type        = string
}

variable "sku" {
  description = "SKU of the Virtual Hub"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "sku must be either Basic or Standard"
  }
}

variable "hub_routing_preference" {
  description = "Routing preference for the hub"
  type        = string
  default     = "ExpressRoute"

  validation {
    condition     = contains(["ExpressRoute", "VpnGateway", "ASPath"], var.hub_routing_preference)
    error_message = "hub_routing_preference must be ExpressRoute, VpnGateway, or ASPath"
  }
}

variable "create_route_table" {
  description = "Create a custom route table for the hub"
  type        = bool
  default     = false
}

variable "route_table_labels" {
  description = "Labels for the route table"
  type        = list(string)
  default     = ["default"]
}

variable "routes" {
  description = "Custom routes for the hub route table"
  type = list(object({
    name              = string
    destinations_type = string
    destinations      = list(string)
    next_hop          = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the Virtual Hub"
  type        = map(string)
  default     = {}
}
