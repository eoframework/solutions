#------------------------------------------------------------------------------
# AWS S3 Bucket Module - Variables
#------------------------------------------------------------------------------

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket deletion with objects"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Versioning
#------------------------------------------------------------------------------

variable "versioning_enabled" {
  description = "Enable versioning"
  type        = bool
  default     = true
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
# Public Access
#------------------------------------------------------------------------------

variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Lifecycle Rules
#------------------------------------------------------------------------------

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id                                 = string
    enabled                            = optional(bool, true)
    prefix                             = optional(string, "")
    transition_ia_days                 = optional(number)
    transition_glacier_days            = optional(number)
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
  }))
  default = []
}

#------------------------------------------------------------------------------
# CORS
#------------------------------------------------------------------------------

variable "cors_rules" {
  description = "List of CORS rules"
  type = list(object({
    allowed_headers = optional(list(string), ["*"])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3600)
  }))
  default = []
}

#------------------------------------------------------------------------------
# Lambda Notifications
#------------------------------------------------------------------------------

variable "lambda_notifications" {
  description = "List of Lambda notification configurations"
  type = list(object({
    lambda_function_arn = string
    events              = list(string)
    filter_prefix       = optional(string)
    filter_suffix       = optional(string)
  }))
  default = []
}

#------------------------------------------------------------------------------
# Bucket Policy
#------------------------------------------------------------------------------

variable "bucket_policy" {
  description = "Bucket policy JSON document"
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
