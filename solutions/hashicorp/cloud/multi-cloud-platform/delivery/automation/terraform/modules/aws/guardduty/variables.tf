#------------------------------------------------------------------------------
# AWS GuardDuty Module Variables
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

variable "enabled" {
  description = "Enable GuardDuty detector"
  type        = bool
  default     = true
}

variable "enable_s3_logs" {
  description = "Enable S3 data event logs analysis"
  type        = bool
  default     = true
}

variable "enable_kubernetes_audit_logs" {
  description = "Enable Kubernetes audit logs analysis"
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Enable malware protection for EBS volumes"
  type        = bool
  default     = true
}

variable "finding_publishing_frequency" {
  description = "Frequency of findings publishing (FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS)"
  type        = string
  default     = "FIFTEEN_MINUTES"
}
