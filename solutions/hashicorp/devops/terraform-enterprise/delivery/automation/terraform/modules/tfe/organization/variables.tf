#------------------------------------------------------------------------------
# TFE Organization Module Variables
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

variable "eks_cluster_name" {
  description = "EKS cluster name hosting TFE"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS PostgreSQL endpoint for TFE state"
  type        = string
}

variable "rds_database_name" {
  description = "RDS database name"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "tfe" {
  description = "TFE configuration"
  type = object({
    organization     = string
    hostname         = string
    license_path     = optional(string, "")
    admin_email      = string
    operational_mode = string
    concurrent_runs  = number
    workspace_count  = number
    user_count       = number
  })
}

variable "vault_enabled" {
  description = "Whether Vault integration is enabled"
  type        = bool
  default     = false
}

variable "vault_endpoint" {
  description = "Vault endpoint URL"
  type        = string
  default     = ""
}
