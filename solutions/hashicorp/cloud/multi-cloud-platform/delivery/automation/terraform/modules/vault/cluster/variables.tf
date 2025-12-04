#------------------------------------------------------------------------------
# Vault Cluster Module Variables
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
  description = "KMS key ARN for auto-unseal"
  type        = string
}

variable "vault" {
  description = "Vault configuration"
  type = object({
    enabled                    = bool
    deployment_mode            = string  # "self-managed" or "hcp"
    version                    = string
    node_count                 = number
    instance_type              = string
    ami_id                     = string
    key_name                   = string
    root_volume_size           = number
    enable_deletion_protection = bool
    aws_secrets_enabled        = bool
    credential_ttl_seconds     = number
    hcp_vault_cluster_id       = string  # For HCP Vault
  })
}
