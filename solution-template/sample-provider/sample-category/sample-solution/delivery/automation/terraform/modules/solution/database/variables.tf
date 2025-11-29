# Solution Database Module - Variables

#------------------------------------------------------------------------------
# Context from Core Module
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources (from core module)"
  type        = string
}

variable "common_tags" {
  description = "Common tags for resources (from core module)"
  type        = map(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group name (from core module db_subnet_group_name)"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs (from core module database_security_group_id)"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Database Engine Configuration
#------------------------------------------------------------------------------

variable "db_engine" {
  description = "Database engine type"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.db_engine)
    error_message = "db_engine must be one of: postgres, mysql, mariadb"
  }
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_parameters" {
  description = "Database parameter group parameters"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
  default = []
}

#------------------------------------------------------------------------------
# Storage Configuration
#------------------------------------------------------------------------------

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum storage for autoscaling in GB"
  type        = number
  default     = 100
}

variable "db_storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "db_storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Database Configuration
#------------------------------------------------------------------------------

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

#------------------------------------------------------------------------------
# High Availability
#------------------------------------------------------------------------------

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------

variable "db_backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------

variable "db_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "db_cloudwatch_logs_exports" {
  description = "CloudWatch log exports"
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

#------------------------------------------------------------------------------
# Protection
#------------------------------------------------------------------------------

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Alarms
#------------------------------------------------------------------------------

variable "enable_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = ""
}

variable "db_max_connections_threshold" {
  description = "Threshold for database connections alarm"
  type        = number
  default     = 100
}
