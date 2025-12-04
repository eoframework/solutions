#------------------------------------------------------------------------------
# RDS PostgreSQL Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for RDS"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "database" {
  description = "Database configuration"
  type = object({
    rds_instance_class      = string
    rds_storage_gb          = number
    rds_database_name       = string
    rds_multi_az            = bool
    rds_backup_retention    = number
    rds_deletion_protection = bool
  })
}
