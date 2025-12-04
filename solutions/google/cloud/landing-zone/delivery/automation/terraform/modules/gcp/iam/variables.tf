#------------------------------------------------------------------------------
# GCP IAM Module - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "org_id" {
  description = "GCP organization ID"
  type        = string
}

variable "automation_project_id" {
  description = "Project ID for automation service accounts"
  type        = string
}

variable "monitoring_project_id" {
  description = "Project ID for monitoring service account"
  type        = string
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity Pool"
  type        = bool
  default     = false
}

variable "github_org" {
  description = "GitHub organization for Workload Identity"
  type        = string
  default     = ""
}

# Admin groups (Cloud Identity)
variable "org_admin_group" {
  description = "Cloud Identity group for organization admins"
  type        = string
  default     = ""
}

variable "network_admin_group" {
  description = "Cloud Identity group for network admins"
  type        = string
  default     = ""
}

variable "security_admin_group" {
  description = "Cloud Identity group for security admins"
  type        = string
  default     = ""
}

variable "billing_admin_group" {
  description = "Cloud Identity group for billing admins"
  type        = string
  default     = ""
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}
