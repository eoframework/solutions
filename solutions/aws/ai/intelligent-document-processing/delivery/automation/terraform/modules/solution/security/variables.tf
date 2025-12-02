#------------------------------------------------------------------------------
# IDP Security Module - Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Project Configuration
#------------------------------------------------------------------------------

variable "project" {
  description = "Project configuration"
  type = object({
    name        = string
    environment = string
  })
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------

variable "security" {
  description = "Security configuration"
  type = object({
    kms_deletion_window_days = optional(number, 30)
    enable_kms_key_rotation  = optional(bool, true)
  })
  default = {}
}

#------------------------------------------------------------------------------
# Lambda VPC Configuration
#------------------------------------------------------------------------------

variable "lambda_vpc_enabled" {
  description = "Whether Lambda VPC mode is enabled"
  type        = bool
  default     = false
}

variable "network" {
  description = "Network configuration for Lambda VPC security group"
  type = object({
    vpc_id             = optional(string)
    private_subnet_ids = optional(list(string), [])
  })
  default = {}
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
