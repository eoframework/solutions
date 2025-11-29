# Generic AWS WAF Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "scope" {
  description = "Scope of the WAF (REGIONAL for ALB, CLOUDFRONT for CloudFront)"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Scope must be REGIONAL or CLOUDFRONT."
  }
}

variable "default_action" {
  description = "Default action (allow or block)"
  type        = string
  default     = "allow"
  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action must be allow or block."
  }
}

variable "resource_arn" {
  description = "ARN of the resource to associate (ALB, API Gateway, etc.)"
  type        = string
  default     = ""
}

variable "cloudwatch_metrics_enabled" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = true
}

variable "sampled_requests_enabled" {
  description = "Enable sampled requests"
  type        = bool
  default     = true
}

# AWS Managed Rules
variable "enable_aws_managed_common_rules" {
  description = "Enable AWS Managed Common Rule Set"
  type        = bool
  default     = true
}

variable "enable_aws_managed_sqli_rules" {
  description = "Enable AWS Managed SQL Injection Rule Set"
  type        = bool
  default     = true
}

variable "enable_aws_managed_bad_inputs_rules" {
  description = "Enable AWS Managed Known Bad Inputs Rule Set"
  type        = bool
  default     = true
}

# Rate Limiting
variable "rate_limit" {
  description = "Rate limit per 5 minutes per IP (0 to disable)"
  type        = number
  default     = 2000
}

# IP Blocking/Allowing
variable "blocked_ip_addresses" {
  description = "List of IP addresses to block (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses to allow (CIDR notation)"
  type        = list(string)
  default     = []
}

# Geo Blocking
variable "blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = []
}

# Logging
variable "logging_enabled" {
  description = "Enable WAF logging"
  type        = bool
  default     = false
}

variable "log_destination_arn" {
  description = "ARN of the log destination (Kinesis Firehose, S3, or CloudWatch Logs)"
  type        = string
  default     = ""
}

variable "redacted_fields" {
  description = "Fields to redact from logs"
  type = list(object({
    type = string # header, query_string, uri_path
    name = optional(string)
  }))
  default = []
}
