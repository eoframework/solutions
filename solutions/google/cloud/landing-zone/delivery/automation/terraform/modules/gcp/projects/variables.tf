#------------------------------------------------------------------------------
# GCP Projects Module - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for project IDs"
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID for all projects"
  type        = string
}

variable "shared_folder_id" {
  description = "Folder ID for shared services projects"
  type        = string
}

variable "dev_folder_id" {
  description = "Folder ID for development workload projects"
  type        = string
}

variable "staging_folder_id" {
  description = "Folder ID for staging workload projects"
  type        = string
  default     = ""
}

variable "prod_folder_id" {
  description = "Folder ID for production workload projects"
  type        = string
  default     = ""
}

variable "projects" {
  description = "Project configuration"
  type = object({
    host_project_name       = string
    logging_project_name    = string
    security_project_name   = string
    monitoring_project_name = string
    initial_count           = number
    team_count              = number
  })
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}
