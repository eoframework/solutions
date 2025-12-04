#------------------------------------------------------------------------------
# Azure ExpressRoute Gateway Module Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Name of the ExpressRoute Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the ExpressRoute Gateway"
  type        = string
}

variable "virtual_hub_id" {
  description = "ID of the Virtual Hub"
  type        = string
}

variable "scale_units" {
  description = "Scale units for the ExpressRoute Gateway (defines throughput)"
  type        = number
  default     = 1

  validation {
    condition     = var.scale_units >= 1 && var.scale_units <= 10
    error_message = "scale_units must be between 1 and 10"
  }
}

variable "allow_non_virtual_wan_traffic" {
  description = "Allow traffic from non-Virtual WAN networks"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the ExpressRoute Gateway"
  type        = map(string)
  default     = {}
}
