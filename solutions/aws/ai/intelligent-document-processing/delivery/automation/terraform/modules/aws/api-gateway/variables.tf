#------------------------------------------------------------------------------
# AWS API Gateway REST API Module - Variables
#------------------------------------------------------------------------------

variable "api_name" {
  description = "Name of the API Gateway REST API"
  type        = string
}

variable "description" {
  description = "Description of the API"
  type        = string
  default     = ""
}

variable "endpoint_type" {
  description = "API endpoint type: REGIONAL, EDGE, or PRIVATE"
  type        = string
  default     = "REGIONAL"
}

variable "binary_media_types" {
  description = "List of binary media types for document uploads"
  type        = list(string)
  default     = ["application/pdf", "image/png", "image/jpeg", "image/tiff"]
}

variable "stage_name" {
  description = "Deployment stage name"
  type        = string
  default     = "v1"
}

#------------------------------------------------------------------------------
# Resources (API paths)
#------------------------------------------------------------------------------

variable "resources" {
  description = "Map of API resources (paths)"
  type = map(object({
    parent_path = string
    path_part   = string
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Methods
#------------------------------------------------------------------------------

variable "methods" {
  description = "Map of API methods"
  type = map(object({
    resource_path      = string
    http_method        = string
    authorization      = string
    lambda_invoke_arn  = string
    request_parameters = optional(map(bool), {})
  }))
  default = {}
}

#------------------------------------------------------------------------------
# CORS
#------------------------------------------------------------------------------

variable "enable_cors" {
  description = "Enable CORS for all resources"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Cognito Authorization
#------------------------------------------------------------------------------

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN for authorization"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Throttling
#------------------------------------------------------------------------------

variable "throttling_burst_limit" {
  description = "API Gateway burst limit"
  type        = number
  default     = 1000
}

variable "throttling_rate_limit" {
  description = "API Gateway rate limit (requests per second)"
  type        = number
  default     = 500
}

#------------------------------------------------------------------------------
# Logging & Tracing
#------------------------------------------------------------------------------

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "logging_level" {
  description = "Logging level: OFF, ERROR, or INFO"
  type        = string
  default     = "INFO"
}

variable "data_trace_enabled" {
  description = "Enable full request/response logging"
  type        = bool
  default     = false
}

variable "xray_tracing_enabled" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for log encryption"
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
