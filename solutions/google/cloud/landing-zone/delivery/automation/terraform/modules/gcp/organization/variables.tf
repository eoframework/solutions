#------------------------------------------------------------------------------
# GCP Organization Module Variables
#------------------------------------------------------------------------------

variable "org_id" {
  description = "GCP Organization ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.org_id))
    error_message = "Organization ID must be a numeric string."
  }
}

variable "domain" {
  description = "Primary domain for Cloud Identity"
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID"
  type        = string
}

#------------------------------------------------------------------------------
# Organization Policies
#------------------------------------------------------------------------------
variable "require_shielded_vm" {
  description = "Require Shielded VM for all instances"
  type        = bool
  default     = true
}

variable "disable_serial_port_access" {
  description = "Disable serial port access to VMs"
  type        = bool
  default     = true
}

variable "disable_sa_key_creation" {
  description = "Disable service account key creation"
  type        = bool
  default     = true
}

variable "disable_vm_external_ip" {
  description = "Deny external IP addresses on VMs"
  type        = bool
  default     = true
}

variable "allowed_locations" {
  description = "Allowed resource locations (e.g., in:us-locations)"
  type        = list(string)
  default     = ["in:us-locations"]
}

variable "require_os_login" {
  description = "Require OS Login for SSH access"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Essential Contacts
#------------------------------------------------------------------------------
variable "security_contact_email" {
  description = "Email for security notifications"
  type        = string
  default     = ""
}

variable "billing_contact_email" {
  description = "Email for billing notifications"
  type        = string
  default     = ""
}

variable "technical_contact_email" {
  description = "Email for technical notifications"
  type        = string
  default     = ""
}
