#------------------------------------------------------------------------------
# Azure Virtual Desktop Application Group Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Application group name"
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

variable "type" {
  description = "Application group type (Desktop or RemoteApp)"
  type        = string

  validation {
    condition     = contains(["Desktop", "RemoteApp"], var.type)
    error_message = "Application group type must be Desktop or RemoteApp."
  }
}

variable "host_pool_id" {
  description = "Host pool ID to associate with"
  type        = string
}

variable "workspace_id" {
  description = "Workspace ID to associate with (optional)"
  type        = string
  default     = null
}

variable "friendly_name" {
  description = "Friendly name for the application group"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the application group"
  type        = string
  default     = "Managed by Terraform"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
