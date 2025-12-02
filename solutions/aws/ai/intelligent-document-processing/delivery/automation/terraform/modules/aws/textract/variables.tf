#------------------------------------------------------------------------------
# AWS Textract Custom Configuration Module - Variables
#------------------------------------------------------------------------------

variable "enabled" {
  description = "Enable custom Textract resources"
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

#------------------------------------------------------------------------------
# Adapter Configuration
#------------------------------------------------------------------------------

variable "feature_types" {
  description = "Feature types for the adapter (TABLES, FORMS, QUERIES)"
  type        = list(string)
  default     = ["TABLES", "FORMS"]

  validation {
    condition     = alltrue([for ft in var.feature_types : contains(["TABLES", "FORMS", "QUERIES"], ft)])
    error_message = "Feature types must be TABLES, FORMS, or QUERIES."
  }
}

variable "auto_update_adapter" {
  description = "Enable automatic adapter updates when Textract improves"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Training Data Configuration
#------------------------------------------------------------------------------

variable "training_bucket_arn" {
  description = "ARN of S3 bucket containing training documents"
  type        = string
  default     = null
}

variable "training_bucket_name" {
  description = "Name of S3 bucket containing training documents"
  type        = string
  default     = null
}

variable "manifest_s3_key" {
  description = "S3 key of the training manifest file"
  type        = string
  default     = null
}

variable "output_bucket_arn" {
  description = "ARN of S3 bucket for adapter outputs"
  type        = string
  default     = null
}

variable "output_bucket_name" {
  description = "Name of S3 bucket for adapter outputs"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Query Configuration
#------------------------------------------------------------------------------

variable "invoice_queries" {
  description = "Custom queries for invoice document processing"
  type = list(object({
    text  = string
    alias = string
  }))
  default = []
}

variable "contract_queries" {
  description = "Custom queries for contract document processing"
  type = list(object({
    text  = string
    alias = string
  }))
  default = []
}

variable "custom_queries" {
  description = "Generic custom queries for document processing"
  type = list(object({
    text  = string
    alias = string
  }))
  default = []
}

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
