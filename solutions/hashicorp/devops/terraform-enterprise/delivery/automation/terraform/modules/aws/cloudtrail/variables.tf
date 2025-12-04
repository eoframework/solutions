#------------------------------------------------------------------------------
# AWS CloudTrail Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (optional)"
  type        = string
  default     = ""
}

variable "retention_days" {
  description = "Number of days to retain CloudTrail logs"
  type        = number
  default     = 365
}

variable "transition_to_glacier_days" {
  description = "Number of days before transitioning to Glacier"
  type        = number
  default     = 90
}

variable "include_global_service_events" {
  description = "Include global service events"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Enable multi-region trail"
  type        = bool
  default     = true
}
