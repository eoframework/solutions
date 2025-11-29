# Solution Monitoring Module - Variables

#------------------------------------------------------------------------------
# Context from Core Module
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources (from core module)"
  type        = string
}

variable "common_tags" {
  description = "Common tags for resources (from core module)"
  type        = map(string)
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

#------------------------------------------------------------------------------
# Resource References (for dashboard metrics)
#------------------------------------------------------------------------------

variable "alb_arn" {
  description = "ALB ARN for dashboard metrics"
  type        = string
  default     = ""
}

variable "asg_name" {
  description = "ASG name for dashboard metrics"
  type        = string
  default     = ""
}

variable "rds_identifier" {
  description = "RDS identifier for dashboard metrics"
  type        = string
  default     = ""
}

variable "cache_cluster_id" {
  description = "ElastiCache cluster ID for dashboard metrics"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting logs"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Log Configuration
#------------------------------------------------------------------------------

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "enable_container_insights" {
  description = "Enable Container Insights log group"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Dashboard Configuration
#------------------------------------------------------------------------------

variable "enable_dashboard" {
  description = "Create CloudWatch dashboard"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Alerting Configuration
#------------------------------------------------------------------------------

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# X-Ray Configuration
#------------------------------------------------------------------------------

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = false
}

variable "metrics_namespace" {
  description = "Custom metrics namespace"
  type        = string
  default     = ""
}
