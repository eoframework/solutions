#------------------------------------------------------------------------------
# Secrets Setup - Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# AWS Configuration
#------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for secrets"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name (optional)"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Naming Configuration
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for all secrets (e.g., prod-sample)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "Name prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
  default     = "prod"
}

#------------------------------------------------------------------------------
# Secret Name Suffixes
# These suffixes are appended to name_prefix to form the full secret name
#------------------------------------------------------------------------------

variable "db_password_secret_suffix" {
  description = "Suffix for database password secret name"
  type        = string
  default     = "db-password"
}

variable "cache_auth_token_param_suffix" {
  description = "Suffix for cache auth token SSM parameter path"
  type        = string
  default     = "cache/auth-token"
}

variable "api_key_secret_suffix" {
  description = "Suffix for API key secret name"
  type        = string
  default     = "api-key"
}

#------------------------------------------------------------------------------
# Feature Flags
#------------------------------------------------------------------------------

variable "create_kms_key" {
  description = "Create dedicated KMS key for secrets (otherwise uses AWS managed key)"
  type        = bool
  default     = true
}

variable "create_db_secret" {
  description = "Create database password secret"
  type        = bool
  default     = true
}

variable "create_cache_secret" {
  description = "Create cache auth token parameter"
  type        = bool
  default     = true
}

variable "create_api_key_secret" {
  description = "Create API key secret"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Secret Configuration
#------------------------------------------------------------------------------

variable "secret_recovery_window" {
  description = "Number of days before a secret can be deleted (0 for immediate)"
  type        = number
  default     = 7

  validation {
    condition     = var.secret_recovery_window >= 0 && var.secret_recovery_window <= 30
    error_message = "Recovery window must be between 0 and 30 days."
  }
}
