# GitHub Security Module Variables

variable "repository_name" {
  description = "Repository name"
  type        = string
}

variable "enable_advanced_security" {
  description = "Enable GitHub Advanced Security"
  type        = bool
  default     = true
}

variable "enable_secret_scanning" {
  description = "Enable secret scanning"
  type        = bool
  default     = true
}

variable "enable_secret_scanning_push_protection" {
  description = "Enable secret scanning push protection"
  type        = bool
  default     = true
}

variable "enable_oidc_customization" {
  description = "Enable OIDC subject claim customization"
  type        = bool
  default     = true
}

variable "oidc_claim_keys" {
  description = "OIDC claim keys to include"
  type        = list(string)
  default     = ["repo", "context", "job_workflow_ref"]
}

variable "enable_security_webhook" {
  description = "Enable security event webhook"
  type        = bool
  default     = false
}

variable "webhook_url" {
  description = "Webhook URL"
  type        = string
  default     = ""
}

variable "webhook_secret" {
  description = "Webhook secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "webhook_events" {
  description = "Webhook events to subscribe to"
  type        = list(string)
  default = [
    "code_scanning_alert",
    "dependabot_alert",
    "secret_scanning_alert",
    "security_advisory"
  ]
}
