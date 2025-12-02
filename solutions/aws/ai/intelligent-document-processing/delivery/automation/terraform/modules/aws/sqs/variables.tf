#------------------------------------------------------------------------------
# AWS SQS Queue Module - Variables
#------------------------------------------------------------------------------

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

#------------------------------------------------------------------------------
# FIFO Configuration
#------------------------------------------------------------------------------

variable "fifo_queue" {
  description = "Create FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO"
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "Deduplication scope: messageGroup or queue"
  type        = string
  default     = "queue"
}

variable "fifo_throughput_limit" {
  description = "FIFO throughput limit: perQueue or perMessageGroupId"
  type        = string
  default     = "perQueue"
}

#------------------------------------------------------------------------------
# Message Configuration
#------------------------------------------------------------------------------

variable "delay_seconds" {
  description = "Delay before message becomes available (0-900)"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Maximum message size in bytes (1024-262144)"
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "Message retention period (60-1209600 seconds)"
  type        = number
  default     = 345600 # 4 days
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time (0-20)"
  type        = number
  default     = 10
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout (0-43200 seconds)"
  type        = number
  default     = 30
}

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (SSE-SQS used if null)"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period" {
  description = "KMS data key reuse period in seconds"
  type        = number
  default     = 300
}

#------------------------------------------------------------------------------
# Dead Letter Queue
#------------------------------------------------------------------------------

variable "create_dlq" {
  description = "Create a dead-letter queue"
  type        = bool
  default     = true
}

variable "dlq_arn" {
  description = "ARN of external dead-letter queue (if not creating one)"
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Number of receives before message goes to DLQ"
  type        = number
  default     = 5
}

variable "dlq_message_retention_seconds" {
  description = "Message retention for DLQ (longer than main queue)"
  type        = number
  default     = 1209600 # 14 days
}

#------------------------------------------------------------------------------
# DLQ Configuration (when this queue IS a DLQ)
#------------------------------------------------------------------------------

variable "is_dlq" {
  description = "This queue is a DLQ (sets redrive allow policy)"
  type        = bool
  default     = false
}

variable "source_queue_arns" {
  description = "Source queue ARNs allowed to use this as DLQ"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Queue Policy
#------------------------------------------------------------------------------

variable "queue_policy" {
  description = "Custom queue policy JSON"
  type        = string
  default     = null
}

variable "allowed_principals" {
  description = "AWS principals allowed to send messages"
  type        = list(string)
  default     = []
}

variable "allowed_s3_bucket_arns" {
  description = "S3 bucket ARNs allowed to send notifications"
  type        = list(string)
  default     = []
}

variable "allowed_sns_topic_arns" {
  description = "SNS topic ARNs allowed to send messages"
  type        = list(string)
  default     = []
}

variable "allowed_lambda_arns" {
  description = "Lambda ARNs allowed to receive messages"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
