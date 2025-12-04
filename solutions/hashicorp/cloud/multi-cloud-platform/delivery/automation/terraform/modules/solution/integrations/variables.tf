#------------------------------------------------------------------------------
# Integrations Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

#------------------------------------------------------------------------------
# WAF Integration
#------------------------------------------------------------------------------
variable "enable_waf" {
  description = "Enable WAF to ALB association"
  type        = bool
  default     = false
}

variable "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  type        = string
  default     = ""
}

variable "alb_arn" {
  description = "Application Load Balancer ARN"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Vault Integration
#------------------------------------------------------------------------------
variable "vault_enabled" {
  description = "Whether Vault is enabled"
  type        = bool
  default     = false
}

variable "vault_aws_secrets_enabled" {
  description = "Enable Vault AWS secrets engine"
  type        = bool
  default     = false
}

variable "vault_aws_access_key" {
  description = "AWS access key for Vault secrets engine"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vault_aws_secret_key" {
  description = "AWS secret key for Vault secrets engine"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for Vault secrets engine"
  type        = string
  default     = ""
}

variable "vault_credential_ttl_seconds" {
  description = "TTL for Vault-generated credentials"
  type        = number
  default     = 3600
}

#------------------------------------------------------------------------------
# CloudWatch Alarms Integration
#------------------------------------------------------------------------------
variable "enable_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = ""
}

variable "eks_cluster_name" {
  description = "EKS cluster name for alarms"
  type        = string
  default     = ""
}

variable "rds_identifier" {
  description = "RDS instance identifier for alarms"
  type        = string
  default     = ""
}
