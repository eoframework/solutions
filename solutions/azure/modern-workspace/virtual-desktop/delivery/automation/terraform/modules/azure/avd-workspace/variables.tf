#------------------------------------------------------------------------------
# Azure Virtual Desktop Workspace Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Workspace name"
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

variable "friendly_name" {
  description = "Friendly name for the workspace"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the workspace"
  type        = string
  default     = "Managed by Terraform"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
