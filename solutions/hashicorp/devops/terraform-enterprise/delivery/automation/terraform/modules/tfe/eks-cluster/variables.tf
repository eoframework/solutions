#------------------------------------------------------------------------------
# EKS Cluster Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}

variable "compute" {
  description = "Compute configuration"
  type = object({
    eks_cluster_name       = string
    eks_node_instance_type = string
    eks_node_count         = number
    eks_node_min_count     = number
    eks_node_max_count     = number
  })
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}
