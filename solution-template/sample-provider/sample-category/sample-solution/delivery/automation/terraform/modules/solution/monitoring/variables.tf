# Solution Monitoring Module - Variables
# Accepts grouped object variables from environment configuration

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
# Monitoring Configuration (from monitoring.tfvars)
#------------------------------------------------------------------------------

variable "monitoring" {
  description = "CloudWatch and observability configuration"
  type = object({
    # CloudWatch Logs
    log_retention_days           = number
    # CloudWatch Dashboard & Insights
    enable_dashboard             = bool
    enable_container_insights    = bool
    # CloudWatch Alarm Defaults
    alarm_evaluation_periods     = optional(number, 2)
    alarm_period_seconds         = optional(number, 300)
    alarm_treat_missing_data     = optional(string, "missing")
    # Dashboard Widget Settings
    dashboard_widget_width       = optional(number, 8)
    dashboard_widget_height      = optional(number, 6)
    # X-Ray Tracing Configuration
    enable_xray_tracing          = bool
    xray_sampling                = optional(object({
      priority       = optional(number, 1000)
      reservoir_size = optional(number, 1)
      fixed_rate     = optional(number, 0.05)
      url_path       = optional(string, "*")
      http_method    = optional(string, "*")
      service_type   = optional(string, "*")
      host           = optional(string, "*")
    }), {})
  })
}

#------------------------------------------------------------------------------
# Alerting Configuration (optional - not typically in tfvars)
#------------------------------------------------------------------------------

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}
