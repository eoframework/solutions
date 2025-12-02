#------------------------------------------------------------------------------
# AWS DynamoDB Table Module - Variables
#------------------------------------------------------------------------------

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode: PAY_PER_REQUEST or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Partition key attribute name"
  type        = string
}

variable "range_key" {
  description = "Sort key attribute name (optional)"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Capacity (for PROVISIONED mode)
#------------------------------------------------------------------------------

variable "read_capacity" {
  description = "Read capacity units (for PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (for PROVISIONED mode)"
  type        = number
  default     = 5
}

#------------------------------------------------------------------------------
# Attributes
#------------------------------------------------------------------------------

variable "attributes" {
  description = "List of attribute definitions"
  type = list(object({
    name = string
    type = string # S, N, or B
  }))
}

#------------------------------------------------------------------------------
# Indexes
#------------------------------------------------------------------------------

variable "global_secondary_indexes" {
  description = "List of Global Secondary Index definitions"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string)
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "List of Local Secondary Index definitions"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string)
    non_key_attributes = optional(list(string))
  }))
  default = []
}

#------------------------------------------------------------------------------
# TTL
#------------------------------------------------------------------------------

variable "ttl_attribute" {
  description = "Attribute name for TTL (null to disable)"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Backup & Recovery
#------------------------------------------------------------------------------

variable "point_in_time_recovery_enabled" {
  description = "Enable Point-in-Time Recovery"
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------

variable "kms_key_arn" {
  description = "KMS key ARN for server-side encryption"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Streams
#------------------------------------------------------------------------------

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

#------------------------------------------------------------------------------
# Auto Scaling
#------------------------------------------------------------------------------

variable "enable_autoscaling" {
  description = "Enable auto scaling (for PROVISIONED mode)"
  type        = bool
  default     = false
}

variable "autoscaling_read_max_capacity" {
  description = "Max read capacity for auto scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_max_capacity" {
  description = "Max write capacity for auto scaling"
  type        = number
  default     = 100
}

variable "autoscaling_target_utilization" {
  description = "Target utilization percentage for auto scaling"
  type        = number
  default     = 70
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
