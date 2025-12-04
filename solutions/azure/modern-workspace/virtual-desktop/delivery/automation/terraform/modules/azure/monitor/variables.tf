#------------------------------------------------------------------------------
# Azure Monitor Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Log Analytics Workspace name"
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

variable "sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "create_application_insights" {
  description = "Create Application Insights"
  type        = bool
  default     = false
}

variable "application_type" {
  description = "Application Insights type"
  type        = string
  default     = "other"
}

#------------------------------------------------------------------------------
# Diagnostic Settings
#------------------------------------------------------------------------------
variable "diagnostic_settings" {
  description = "Map of diagnostic settings to create"
  type = map(object({
    target_resource_id = string
    log_categories     = optional(list(string), [])
    metric_categories  = optional(list(string), ["AllMetrics"])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Action Groups
#------------------------------------------------------------------------------
variable "action_groups" {
  description = "Map of action groups to create"
  type = map(object({
    short_name = string
    email_receivers = optional(list(object({
      name          = string
      email_address = string
    })), [])
    webhook_receivers = optional(list(object({
      name        = string
      service_uri = string
    })), [])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
