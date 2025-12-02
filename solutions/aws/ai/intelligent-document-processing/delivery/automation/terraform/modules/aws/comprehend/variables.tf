#------------------------------------------------------------------------------
# AWS Comprehend Custom Models Module - Variables
#------------------------------------------------------------------------------

variable "enabled" {
  description = "Enable custom Comprehend resources"
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "language_code" {
  description = "Language code for the model (en, es, fr, de, it, pt, etc.)"
  type        = string
  default     = "en"
}

#------------------------------------------------------------------------------
# Training Data Configuration
#------------------------------------------------------------------------------

variable "training_bucket_arn" {
  description = "ARN of S3 bucket containing training data"
  type        = string
  default     = null
}

variable "output_bucket_arn" {
  description = "ARN of S3 bucket for model outputs"
  type        = string
  default     = null
}

variable "training_data_s3_uri" {
  description = "S3 URI of training data for document classifier"
  type        = string
  default     = null
}

variable "annotations_s3_uri" {
  description = "S3 URI of annotations file for entity recognizer"
  type        = string
  default     = null
}

variable "documents_s3_uri" {
  description = "S3 URI of documents for entity recognizer training"
  type        = string
  default     = null
}

variable "entity_list_s3_uri" {
  description = "S3 URI of entity list for simple entity recognizer training"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Model Configuration
#------------------------------------------------------------------------------

variable "enable_realtime" {
  description = "Enable real-time inference endpoint (incurs ongoing costs)"
  type        = bool
  default     = false
}

variable "model_version" {
  description = "Version name for the model"
  type        = string
  default     = null
}

variable "custom_entity_types" {
  description = "List of custom entity types for entity recognizer"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Flywheel Configuration
#------------------------------------------------------------------------------

variable "enable_flywheel" {
  description = "Enable Comprehend Flywheel for continuous model improvement"
  type        = bool
  default     = false
}

variable "data_lake_s3_uri" {
  description = "S3 URI for flywheel data lake"
  type        = string
  default     = null
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
