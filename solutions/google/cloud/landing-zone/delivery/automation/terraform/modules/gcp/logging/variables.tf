#------------------------------------------------------------------------------
# GCP Cloud Logging Module - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_id" {
  description = "GCP project ID for logging resources"
  type        = string
}

variable "org_id" {
  description = "GCP organization ID"
  type        = string
}

variable "location" {
  description = "Location for logging resources (BigQuery dataset, GCS bucket)"
  type        = string
  default     = "US"
}

variable "logging" {
  description = "Logging configuration"
  type = object({
    sink_type                = string
    retention_days           = number
    bigquery_retention_years = number
    volume_gb_month          = number
    enable_audit_logs        = bool
    enable_data_access_logs  = bool
  })
}

variable "log_filter" {
  description = "Log filter for the organization sink"
  type        = string
  default     = ""  # Empty filter = all logs
}

variable "enable_metrics" {
  description = "Enable log-based metrics"
  type        = bool
  default     = true
}

variable "security_events_filter" {
  description = "Filter for security events metric"
  type        = string
  default     = <<-EOT
    protoPayload.@type="type.googleapis.com/google.cloud.audit.AuditLog"
    AND (
      protoPayload.methodName:"SetIamPolicy"
      OR protoPayload.methodName:"CreateServiceAccount"
      OR protoPayload.methodName:"CreateServiceAccountKey"
      OR protoPayload.methodName:"DisableServiceAccount"
    )
  EOT
}

variable "error_filter" {
  description = "Filter for error count metric"
  type        = string
  default     = "severity >= ERROR"
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}
