#------------------------------------------------------------------------------
# AWS Step Functions State Machine Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "definition" {
  description = "Amazon States Language definition of the state machine"
  type        = string
}

variable "express_workflow" {
  description = "Use EXPRESS workflow type (vs STANDARD)"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# IAM Permissions - Lambda
#------------------------------------------------------------------------------

variable "lambda_arns" {
  description = "List of Lambda function ARNs the state machine can invoke"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# IAM Permissions - DynamoDB
#------------------------------------------------------------------------------

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs for state machine access"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# IAM Permissions - S3
#------------------------------------------------------------------------------

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs for state machine access"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# IAM Permissions - AWS AI Services
#------------------------------------------------------------------------------

variable "enable_textract" {
  description = "Enable Textract permissions for document processing"
  type        = bool
  default     = false
}

variable "enable_comprehend" {
  description = "Enable Comprehend permissions for NLP/PII detection"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# IAM Permissions - Messaging
#------------------------------------------------------------------------------

variable "sqs_queue_arns" {
  description = "List of SQS queue ARNs for state machine access"
  type        = list(string)
  default     = []
}

variable "sns_topic_arns" {
  description = "List of SNS topic ARNs for state machine notifications"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Custom IAM Policies
#------------------------------------------------------------------------------

variable "custom_policies" {
  description = "Map of custom IAM policies to attach to the state machine role"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Logging Configuration
#------------------------------------------------------------------------------

variable "log_level" {
  description = "Logging level: ALL, ERROR, FATAL, or OFF"
  type        = string
  default     = "ERROR"

  validation {
    condition     = contains(["ALL", "ERROR", "FATAL", "OFF"], var.log_level)
    error_message = "Log level must be ALL, ERROR, FATAL, or OFF."
  }
}

variable "log_include_execution_data" {
  description = "Include execution data in logs"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key ARN for log encryption"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Tracing
#------------------------------------------------------------------------------

variable "xray_tracing_enabled" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
