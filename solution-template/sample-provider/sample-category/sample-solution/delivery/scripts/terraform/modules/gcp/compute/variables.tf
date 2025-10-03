# gcp Compute Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Common tags/labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# TODO: Add module-specific variables as needed
