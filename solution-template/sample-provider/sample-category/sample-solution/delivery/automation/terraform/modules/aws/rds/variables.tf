# Generic AWS RDS Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
  default     = ""
}

#------------------------------------------------------------------------------
# Database Configuration (grouped object)
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
