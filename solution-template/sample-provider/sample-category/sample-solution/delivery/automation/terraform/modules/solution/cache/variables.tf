# Solution Cache Module - Variables
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

variable "elasticache_subnet_group_name" {
  description = "ElastiCache subnet group name (from core module)"
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
# Cache Configuration (from cache.tfvars)
#------------------------------------------------------------------------------

variable "cache" {
  description = "ElastiCache configuration"
  type = object({
    enabled                    = bool
    # Engine Configuration
    engine                     = string
    engine_version             = string
    port                       = optional(number, 6379)
    # Instance Configuration
    node_type                  = string
    num_nodes                  = number
    # High Availability
    automatic_failover         = bool
    # Encryption
    at_rest_encryption         = bool
    transit_encryption         = bool
    # Authentication (secret reference - NOT the actual token)
    auth_token_param_name      = optional(string, "cache/auth-token")
    # Backup Configuration
    snapshot_retention         = number
    snapshot_window            = string
    # Maintenance Configuration
    maintenance_window         = optional(string, "sun:06:00-sun:07:00")
    auto_minor_version_upgrade = optional(bool, true)
    # Cluster Mode (Redis only)
    cluster_mode_enabled       = optional(bool, false)
    cluster_mode_replicas      = optional(number, 1)
    cluster_mode_shards        = optional(number, 1)
  })
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
