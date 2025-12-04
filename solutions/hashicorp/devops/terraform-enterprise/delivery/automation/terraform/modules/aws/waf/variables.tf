#------------------------------------------------------------------------------
# AWS WAF Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "WAF Web ACL"
}

variable "scope" {
  description = "Scope of the WAF (REGIONAL or CLOUDFRONT)"
  type        = string
  default     = "REGIONAL"
}

variable "default_action" {
  description = "Default action for requests (allow or block)"
  type        = string
  default     = "allow"
}

#------------------------------------------------------------------------------
# Rule Configuration
#------------------------------------------------------------------------------
variable "enable_common_rules" {
  description = "Enable AWS Managed Common Rule Set"
  type        = bool
  default     = true
}

variable "enable_rate_limiting" {
  description = "Enable rate limiting rule"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Rate limit threshold (requests per 5 minutes per IP)"
  type        = number
  default     = 2000
}

variable "enable_bad_inputs_rules" {
  description = "Enable AWS Managed Known Bad Inputs Rule Set"
  type        = bool
  default     = true
}

variable "enable_sqli_rules" {
  description = "Enable AWS Managed SQL Injection Rule Set"
  type        = bool
  default     = true
}

variable "blocked_ip_addresses" {
  description = "List of IP addresses to block (CIDR notation)"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Visibility Configuration
#------------------------------------------------------------------------------
variable "enable_cloudwatch_metrics" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = true
}

variable "enable_sampled_requests" {
  description = "Enable sampled requests"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Logging Configuration
#------------------------------------------------------------------------------
variable "enable_logging" {
  description = "Enable WAF logging"
  type        = bool
  default     = false
}

variable "log_destination_arns" {
  description = "List of log destination ARNs (Kinesis Firehose, CloudWatch, S3)"
  type        = list(string)
  default     = []
}

variable "redacted_fields" {
  description = "Fields to redact from logs"
  type = list(object({
    type = string
    name = string
  }))
  default = []
}
