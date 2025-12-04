#------------------------------------------------------------------------------
# GCP Budgets Module - Variables
#------------------------------------------------------------------------------

variable "billing_account_id" {
  description = "Billing account ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_ids" {
  description = "List of project IDs to monitor (format: projects/PROJECT_ID)"
  type        = list(string)
}

variable "budget" {
  description = "Budget configuration"
  type = object({
    enabled                = bool
    monthly_amount         = number
    currency               = string
    alert_thresholds       = list(number)
    enable_forecast_alerts = bool
    forecast_threshold     = number
  })
  default = {
    enabled                = true
    monthly_amount         = 1000
    currency               = "USD"
    alert_thresholds       = [50, 80, 100]
    enable_forecast_alerts = true
    forecast_threshold     = 100
  }
}

variable "notification_channels" {
  description = "Monitoring notification channel IDs for alerts"
  type        = list(string)
  default     = []
}
