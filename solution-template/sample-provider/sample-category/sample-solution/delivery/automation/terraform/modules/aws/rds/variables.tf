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

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

#------------------------------------------------------------------------------
# Engine Configuration
#------------------------------------------------------------------------------

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "parameter_group_family" {
  description = "Parameter group family"
  type        = string
  default     = "postgres15"
}

variable "parameters" {
  description = "Database parameters"
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

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling in GB"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Network Configuration
#------------------------------------------------------------------------------

variable "port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Publicly accessible"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Database Configuration
#------------------------------------------------------------------------------

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

#------------------------------------------------------------------------------
# High Availability
#------------------------------------------------------------------------------

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "cloudwatch_logs_exports" {
  description = "CloudWatch log exports"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Protection
#------------------------------------------------------------------------------

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Upgrades
#------------------------------------------------------------------------------

variable "auto_minor_version_upgrade" {
  description = "Auto minor version upgrade"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrade"
  type        = bool
  default     = false
}
