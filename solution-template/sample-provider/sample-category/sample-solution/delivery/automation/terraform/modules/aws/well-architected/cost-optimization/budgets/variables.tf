# AWS Budgets Module - Variables

#------------------------------------------------------------------------------
# Naming & Tags
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

variable "environment" {
  description = "Environment name (for budget action conditions)"
  type        = string
  default     = "prod"
}

#------------------------------------------------------------------------------
# Monthly Cost Budget
#------------------------------------------------------------------------------

variable "enable_cost_budget" {
  description = "Enable monthly cost budget"
  type        = bool
  default     = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 1000
}

variable "alert_thresholds" {
  description = "Percentage thresholds for cost alerts"
  type        = list(number)
  default     = [50, 80, 100]
}

variable "enable_forecast_alert" {
  description = "Enable forecasted cost alert"
  type        = bool
  default     = true
}

variable "forecast_threshold" {
  description = "Forecasted cost threshold percentage"
  type        = number
  default     = 100
}

#------------------------------------------------------------------------------
# Alert Recipients
#------------------------------------------------------------------------------

variable "alert_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = []
}

variable "sns_topic_arns" {
  description = "SNS topic ARNs for budget alerts"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Budget Filters
#------------------------------------------------------------------------------

variable "linked_account_ids" {
  description = "Filter by linked account IDs (for Organizations)"
  type        = list(string)
  default     = null
}

variable "cost_filter_tags" {
  description = "Filter costs by tags (map of tag key to value)"
  type        = map(string)
  default     = null
}

variable "cost_filter_services" {
  description = "Filter costs by AWS services"
  type        = list(string)
  default     = null
}

#------------------------------------------------------------------------------
# Service-Specific Budgets
#------------------------------------------------------------------------------

variable "enable_service_budgets" {
  description = "Enable service-specific budgets"
  type        = bool
  default     = false
}

variable "ec2_budget_amount" {
  description = "Monthly EC2 budget amount in USD (0 to disable)"
  type        = number
  default     = 0
}

variable "rds_budget_amount" {
  description = "Monthly RDS budget amount in USD (0 to disable)"
  type        = number
  default     = 0
}

variable "data_transfer_budget_amount" {
  description = "Monthly data transfer budget in USD (0 to disable)"
  type        = number
  default     = 0
}

#------------------------------------------------------------------------------
# Usage Budget
#------------------------------------------------------------------------------

variable "enable_usage_budget" {
  description = "Enable EC2 usage hours budget"
  type        = bool
  default     = false
}

variable "ec2_usage_hours_limit" {
  description = "Maximum EC2 hours per month"
  type        = number
  default     = 1000
}

#------------------------------------------------------------------------------
# Budget Actions (Auto-remediation)
#------------------------------------------------------------------------------

variable "enable_budget_actions" {
  description = "Enable automated budget actions"
  type        = bool
  default     = false
}

variable "budget_action_approval" {
  description = "Approval model for budget actions"
  type        = string
  default     = "MANUAL"

  validation {
    condition     = contains(["AUTOMATIC", "MANUAL"], var.budget_action_approval)
    error_message = "Budget action approval must be: AUTOMATIC or MANUAL."
  }
}

variable "action_threshold" {
  description = "Threshold percentage to trigger budget action"
  type        = number
  default     = 100
}

variable "ec2_instance_ids_to_stop" {
  description = "EC2 instance IDs to stop when budget exceeded"
  type        = list(string)
  default     = []
}
