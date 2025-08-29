# AWS Intelligent Document Processing - Variables

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "intelligent-doc-processing"
}

variable "document_bucket_name" {
  description = "S3 bucket name for document storage"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda functions in MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions in seconds"
  type        = number
  default     = 300
}

variable "sqs_message_retention_seconds" {
  description = "Message retention period for SQS queue in seconds"
  type        = number
  default     = 86400
}

variable "enable_textract_async" {
  description = "Enable asynchronous Textract processing"
  type        = bool
  default     = true
}

variable "enable_comprehend" {
  description = "Enable Amazon Comprehend for entity extraction"
  type        = bool
  default     = true
}

variable "enable_kendra" {
  description = "Enable Amazon Kendra for document search"
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "intelligent-document-processing"
    Environment = "dev"
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}

variable "allowed_file_types" {
  description = "Allowed file types for document processing"
  type        = list(string)
  default     = ["pdf", "png", "jpg", "jpeg", "tiff"]
}

variable "max_document_size_mb" {
  description = "Maximum document size in MB"
  type        = number
  default     = 10
}