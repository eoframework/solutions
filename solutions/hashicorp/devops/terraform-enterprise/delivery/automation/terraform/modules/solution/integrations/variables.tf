#------------------------------------------------------------------------------
# Integrations Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# WAF Integration
#------------------------------------------------------------------------------
variable "enable_waf" {
  description = "Whether WAF is enabled"
  type        = bool
  default     = false
}

variable "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
  default     = ""
}

variable "alb_arn" {
  description = "ALB ARN for WAF association"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Monitoring Integration
#------------------------------------------------------------------------------
variable "enable_alarms" {
  description = "Whether to create CloudWatch alarms"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name for alarms"
  type        = string
  default     = ""
}

variable "rds_identifier" {
  description = "RDS identifier for alarms"
  type        = string
  default     = ""
}
