#------------------------------------------------------------------------------
# GCP Folders Module Variables
#------------------------------------------------------------------------------

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "folders" {
  description = "Folder configuration object"
  type = object({
    dev_display_name    = string
    staging_display_name = string
    prod_display_name   = string
    shared_display_name = string
    sandbox_display_name = string
  })
  default = {
    dev_display_name    = "Development"
    staging_display_name = "Staging"
    prod_display_name   = "Production"
    shared_display_name = "Shared Services"
    sandbox_display_name = "Sandbox"
  }
}

variable "create_sandbox_folder" {
  description = "Create sandbox folder for developer experimentation"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# IAM Bindings
#------------------------------------------------------------------------------
variable "dev_editor_members" {
  description = "Members to grant editor role on development folder"
  type        = list(string)
  default     = []
}

variable "prod_viewer_members" {
  description = "Members to grant viewer role on production folder"
  type        = list(string)
  default     = []
}
