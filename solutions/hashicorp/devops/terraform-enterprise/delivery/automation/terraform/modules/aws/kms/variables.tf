#------------------------------------------------------------------------------
# AWS KMS Module Variables
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

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "KMS key for encryption"
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Enable multi-region key"
  type        = bool
  default     = false
}

variable "policy" {
  description = "Custom KMS key policy (JSON). If empty, default policy is used."
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Service Permissions
#------------------------------------------------------------------------------
variable "enable_cloudwatch_logs" {
  description = "Allow CloudWatch Logs to use the key"
  type        = bool
  default     = true
}

variable "enable_sns" {
  description = "Allow SNS to use the key"
  type        = bool
  default     = true
}

variable "enable_s3" {
  description = "Allow S3 to use the key"
  type        = bool
  default     = true
}

variable "enable_rds" {
  description = "Allow RDS to use the key"
  type        = bool
  default     = true
}

variable "enable_eks" {
  description = "Allow EKS to use the key"
  type        = bool
  default     = true
}
