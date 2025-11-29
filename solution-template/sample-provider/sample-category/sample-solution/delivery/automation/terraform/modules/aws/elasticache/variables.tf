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

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "Node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters"
  type        = number
  default     = 1
}

variable "port" {
  description = "Port"
  type        = number
  default     = 6379
}

variable "parameters" {
  description = "Cache parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover"
  type        = bool
  default     = false
}

variable "at_rest_encryption_enabled" {
  description = "Enable at-rest encryption"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable in-transit encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "snapshot_retention_limit" {
  description = "Snapshot retention in days"
  type        = number
  default     = 1
}

variable "snapshot_window" {
  description = "Snapshot window"
  type        = string
  default     = "03:00-04:00"
}

variable "auto_minor_version_upgrade" {
  description = "Auto minor version upgrade"
  type        = bool
  default     = true
}

variable "notification_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
  default     = null
}
