#------------------------------------------------------------------------------
# DR Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "dr_region" {
  description = "DR region"
  type        = string
}

variable "dr" {
  description = "DR configuration"
  type = object({
    enabled       = bool
    strategy      = string
    rto_minutes   = number
    rpo_minutes   = number
    failover_mode = string
  })
}
