#------------------------------------------------------------------------------
# GitHub Security Module Variables
#------------------------------------------------------------------------------

variable "custom_properties" {
  description = "Organization custom properties for security classification"
  type = map(object({
    property_name = string
    value_type    = string
    description   = string
    required      = bool
    default_value = optional(string)
    allowed_values = optional(list(string))
  }))
  default = {}
}

variable "repository_properties" {
  description = "Repository-specific custom property values"
  type = map(object({
    repository    = string
    property_name = string
    value         = string
  }))
  default = {}
}

variable "ip_allowlist" {
  description = "IP addresses allowed to access the organization (Enterprise Cloud only)"
  type = map(object({
    name    = string
    cidr    = string
    enabled = bool
  }))
  default = {}
}
