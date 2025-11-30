# Solution Database Module - Variables
# Accepts grouped object variables from environment configuration

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
  description = "DB subnet group name (from core module)"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs (from core module)"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Database Configuration (from database.tfvars)
#------------------------------------------------------------------------------

variable "database" {
  description = "RDS database configuration"
  type = object({
    # Enable/Disable
    enabled                       = optional(bool, true)
    # Engine Configuration
    engine                        = string
    engine_version                = string
    instance_class                = string
    # Storage Configuration
    allocated_storage             = number
    max_allocated_storage         = number
    storage_type                  = optional(string, "gp3")
    storage_iops                  = optional(number, 3000)
    storage_throughput            = optional(number, 125)
    storage_encrypted             = bool
    # Database Identity
    name                          = string
    username                      = string
    # High Availability
    multi_az                      = bool
    # Backup Configuration
    backup_retention              = number
    backup_window                 = string
    maintenance_window            = string
    # Performance & Monitoring
    performance_insights          = bool
    performance_insights_retention = optional(number, 7)
    # Logging Configuration
    log_exports_postgres          = optional(list(string), ["postgresql", "upgrade"])
    log_exports_mysql             = optional(list(string), ["error", "slowquery", "general"])
    # Version Management
    auto_minor_version_upgrade    = optional(bool, true)
    allow_major_version_upgrade   = optional(bool, false)
    # Protection
    deletion_protection           = bool
    skip_final_snapshot           = optional(bool, false)
    copy_tags_to_snapshot         = optional(bool, true)
    # Network
    publicly_accessible           = optional(bool, false)
  })
}

#------------------------------------------------------------------------------
# Sensitive Variables (not in tfvars)
#------------------------------------------------------------------------------

variable "db_password" {
  description = "Master password (set via environment variable TF_VAR_db_password)"
  type        = string
  sensitive   = true
  default     = ""
}

#------------------------------------------------------------------------------
# Alarms Configuration
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
