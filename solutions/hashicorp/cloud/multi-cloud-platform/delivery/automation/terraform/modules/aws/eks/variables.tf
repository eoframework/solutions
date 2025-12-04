#------------------------------------------------------------------------------
# EKS Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "compute" {
  description = "Compute configuration"
  type = object({
    eks_version                 = string
    node_instance_type          = string
    node_desired_size           = number
    node_min_size               = number
    node_max_size               = number
    endpoint_private_access     = bool
    endpoint_public_access      = bool
    enabled_cluster_log_types   = list(string)
    enable_deletion_protection  = bool
  })
}
