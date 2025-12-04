#------------------------------------------------------------------------------
# GCP Security Command Center Module - Variables
#------------------------------------------------------------------------------

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "scc" {
  description = "Security Command Center configuration"
  type = object({
    tier                            = string  # "Standard" or "Premium"
    enable_public_resource_detection = bool
    enable_notifications            = bool
  })
  default = {
    tier                            = "Standard"
    enable_public_resource_detection = true
    enable_notifications            = false
  }
}

variable "pubsub_topic_id" {
  description = "Pub/Sub topic ID for SCC notifications"
  type        = string
  default     = ""
}
