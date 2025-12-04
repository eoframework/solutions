#------------------------------------------------------------------------------
# Azure Virtual Desktop Host Pool Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Host pool name"
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

variable "host_pool_type" {
  description = "Host pool type (Pooled or Personal)"
  type        = string
  default     = "Pooled"

  validation {
    condition     = contains(["Pooled", "Personal"], var.host_pool_type)
    error_message = "Host pool type must be Pooled or Personal."
  }
}

variable "load_balancer_type" {
  description = "Load balancer type (BreadthFirst or DepthFirst)"
  type        = string
  default     = "BreadthFirst"

  validation {
    condition     = contains(["BreadthFirst", "DepthFirst"], var.load_balancer_type)
    error_message = "Load balancer type must be BreadthFirst or DepthFirst."
  }
}

variable "maximum_sessions_allowed" {
  description = "Maximum sessions allowed per session host"
  type        = number
  default     = 10
}

variable "start_vm_on_connect" {
  description = "Start VM on connect"
  type        = bool
  default     = true
}

variable "personal_desktop_assignment_type" {
  description = "Personal desktop assignment type (Automatic or Direct)"
  type        = string
  default     = "Automatic"
}

variable "validate_environment" {
  description = "Validate environment"
  type        = bool
  default     = false
}

variable "friendly_name" {
  description = "Friendly name for the host pool"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the host pool"
  type        = string
  default     = "Managed by Terraform"
}

variable "registration_token_rotation_days" {
  description = "Days before registration token rotates"
  type        = number
  default     = 27
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
