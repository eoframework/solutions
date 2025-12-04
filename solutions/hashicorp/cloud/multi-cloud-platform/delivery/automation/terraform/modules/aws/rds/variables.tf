#------------------------------------------------------------------------------
# RDS Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
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
  description = "List of security group IDs"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "database" {
  description = "Database configuration"
  type = object({
    engine_version                  = string
    instance_class                  = string
    allocated_storage               = number
    max_allocated_storage           = number
    storage_type                    = string
    rds_database_name               = string
    rds_username                    = string
    rds_password                    = string
    multi_az                        = bool
    backup_retention_days           = number
    backup_window                   = string
    maintenance_window              = string
    auto_minor_version_upgrade      = bool
    deletion_protection             = bool
    skip_final_snapshot             = bool
    performance_insights_enabled    = bool
    enabled_cloudwatch_logs_exports = list(string)
  })
}
