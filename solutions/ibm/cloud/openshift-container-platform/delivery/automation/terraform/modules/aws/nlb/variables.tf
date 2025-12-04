#------------------------------------------------------------------------------
# AWS NLB Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "control_plane_instance_ids" {
  description = "List of control plane instance IDs"
  type        = list(string)
}

variable "worker_instance_ids" {
  description = "List of worker instance IDs"
  type        = list(string)
  default     = []
}

variable "api_internal" {
  description = "Make API load balancer internal"
  type        = bool
  default     = false
}

variable "create_ingress_lb" {
  description = "Create ingress load balancer for application traffic"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
