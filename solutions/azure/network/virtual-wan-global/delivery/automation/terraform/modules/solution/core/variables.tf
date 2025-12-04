#------------------------------------------------------------------------------
# Virtual WAN Core Infrastructure Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "location" {
  description = "Primary Azure region"
  type        = string
}

variable "secondary_location" {
  description = "Secondary Azure region for DR"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Virtual WAN Configuration
#------------------------------------------------------------------------------
variable "wan_type" {
  description = "Type of Virtual WAN (Basic or Standard)"
  type        = string
  default     = "Standard"
}

variable "allow_branch_to_branch_traffic" {
  description = "Allow branch to branch traffic"
  type        = bool
  default     = true
}

variable "office365_local_breakout_category" {
  description = "Office365 local breakout category"
  type        = string
  default     = "None"
}

#------------------------------------------------------------------------------
# Virtual Hub Configuration
#------------------------------------------------------------------------------
variable "hub_sku" {
  description = "SKU of the Virtual Hubs"
  type        = string
  default     = "Standard"
}

variable "hub_routing_preference" {
  description = "Routing preference for hubs"
  type        = string
  default     = "ExpressRoute"
}

variable "enable_secondary_hub" {
  description = "Enable secondary hub for multi-region deployment"
  type        = bool
  default     = true
}

variable "primary_hub_address_prefix" {
  description = "Address prefix for primary hub"
  type        = string
}

variable "secondary_hub_address_prefix" {
  description = "Address prefix for secondary hub"
  type        = string
  default     = null
}

variable "create_custom_route_tables" {
  description = "Create custom route tables for hubs"
  type        = bool
  default     = false
}

variable "primary_hub_route_table_labels" {
  description = "Route table labels for primary hub"
  type        = list(string)
  default     = ["default"]
}

variable "secondary_hub_route_table_labels" {
  description = "Route table labels for secondary hub"
  type        = list(string)
  default     = ["default"]
}

variable "primary_hub_routes" {
  description = "Custom routes for primary hub"
  type = list(object({
    name              = string
    destinations_type = string
    destinations      = list(string)
    next_hop          = string
  }))
  default = []
}

variable "secondary_hub_routes" {
  description = "Custom routes for secondary hub"
  type = list(object({
    name              = string
    destinations_type = string
    destinations      = list(string)
    next_hop          = string
  }))
  default = []
}
