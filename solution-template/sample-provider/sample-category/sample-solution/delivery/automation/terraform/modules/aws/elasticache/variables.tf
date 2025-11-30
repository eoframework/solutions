# Generic AWS ElastiCache Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_group_name" {
  description = "ElastiCache subnet group name"
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

#------------------------------------------------------------------------------
# Cache Configuration (grouped object)
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
