#------------------------------------------------------------------------------
# Monitoring Module Variables
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

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name for metrics"
  type        = string
}

variable "rds_identifier" {
  description = "RDS instance identifier for metrics"
  type        = string
}

variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    enable_dashboard   = bool
    log_retention_days = number
    datadog_enabled    = bool
  })
}
