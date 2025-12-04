#------------------------------------------------------------------------------
# AWS S3 Backup Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for backups"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

variable "etcd_retention_days" {
  description = "Retention days for etcd backups"
  type        = number
  default     = 30
}

variable "config_retention_days" {
  description = "Retention days for configuration backups"
  type        = number
  default     = 90
}

variable "log_retention_days" {
  description = "Retention days for log archives"
  type        = number
  default     = 365
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
