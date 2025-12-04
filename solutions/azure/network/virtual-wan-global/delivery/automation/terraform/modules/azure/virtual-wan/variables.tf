#------------------------------------------------------------------------------
# Azure Virtual WAN Module Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Virtual WAN"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the Virtual WAN"
  type        = string
}

variable "wan_type" {
  description = "Type of Virtual WAN (Basic or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.wan_type)
    error_message = "wan_type must be either Basic or Standard"
  }
}

variable "disable_vpn_encryption" {
  description = "Disable VPN encryption"
  type        = bool
  default     = false
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

  validation {
    condition     = contains(["None", "Optimize", "OptimizeAndAllow", "All"], var.office365_local_breakout_category)
    error_message = "office365_local_breakout_category must be None, Optimize, OptimizeAndAllow, or All"
  }
}

variable "tags" {
  description = "Tags to apply to the Virtual WAN"
  type        = map(string)
  default     = {}
}
