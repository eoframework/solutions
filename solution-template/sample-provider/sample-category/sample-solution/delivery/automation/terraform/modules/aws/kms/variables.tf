# Generic AWS KMS Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "Description for the KMS key"
  type        = string
  default     = ""
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Create a multi-region primary key"
  type        = bool
  default     = false
}

variable "policy" {
  description = "Custom key policy JSON. If empty, uses default policy"
  type        = string
  default     = ""
}
