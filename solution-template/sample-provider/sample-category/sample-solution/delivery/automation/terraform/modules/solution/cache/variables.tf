# Solution Cache Module - Variables

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

variable "elasticache_subnet_group_name" {
  description = "ElastiCache subnet group name (from core module elasticache_subnet_group_name)"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs (from core module cache_security_group_id)"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Cache Engine Configuration
#------------------------------------------------------------------------------

variable "cache_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "cache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "cache_num_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "cache_parameters" {
  description = "Cache parameter group parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

#------------------------------------------------------------------------------
# High Availability
#------------------------------------------------------------------------------

variable "cache_automatic_failover" {
  description = "Enable automatic failover"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------

variable "cache_at_rest_encryption" {
  description = "Enable at-rest encryption"
  type        = bool
  default     = true
}

variable "cache_transit_encryption" {
  description = "Enable in-transit encryption"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Maintenance and Backup
#------------------------------------------------------------------------------

variable "cache_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "cache_snapshot_retention" {
  description = "Snapshot retention in days"
  type        = number
  default     = 1
}

variable "cache_snapshot_window" {
  description = "Preferred snapshot window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

#------------------------------------------------------------------------------
# Notifications
#------------------------------------------------------------------------------

variable "notification_topic_arn" {
  description = "SNS topic ARN for ElastiCache notifications"
  type        = string
  default     = ""
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
