#------------------------------------------------------------------------------
# Azure Logic App Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Logic App name"
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

#------------------------------------------------------------------------------
# Identity
#------------------------------------------------------------------------------
variable "identity_type" {
  description = "Identity type (SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "User-assigned identity IDs"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Integration
#------------------------------------------------------------------------------
variable "integration_service_environment_id" {
  description = "Integration service environment ID"
  type        = string
  default     = null
}

variable "logic_app_integration_account_id" {
  description = "Integration account ID"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# State
#------------------------------------------------------------------------------
variable "enabled" {
  description = "Enable the logic app"
  type        = bool
  default     = true
}

variable "workflow_schema" {
  description = "Workflow schema URI"
  type        = string
  default     = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
}

variable "workflow_version" {
  description = "Workflow version"
  type        = string
  default     = "1.0.0.0"
}

#------------------------------------------------------------------------------
# Access Control
#------------------------------------------------------------------------------
variable "access_control" {
  description = "Access control configuration"
  type = object({
    action = optional(object({
      allowed_caller_ip_address_range = list(string)
    }))
    content = optional(object({
      allowed_caller_ip_address_range = list(string)
    }))
    trigger = optional(object({
      allowed_caller_ip_address_range = list(string)
      open_authentication_policies = optional(list(object({
        name = string
        claims = list(object({
          name  = string
          value = string
        }))
      })), [])
    }))
    workflow_management = optional(object({
      allowed_caller_ip_address_range = list(string)
    }))
  })
  default = null
}

#------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------
variable "workflow_parameters" {
  description = "Workflow parameters (design-time)"
  type        = map(string)
  default     = {}
}

variable "parameters" {
  description = "Runtime parameters"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
