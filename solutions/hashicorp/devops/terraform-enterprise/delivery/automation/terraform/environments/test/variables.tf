#------------------------------------------------------------------------------
# Variables - Grouped Object Definitions
#------------------------------------------------------------------------------
# All configuration is defined as grouped objects for cleaner module calls.
# Values are set in config/*.tfvars files (derived from configuration.csv).
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Project Configuration (project.tfvars)
#------------------------------------------------------------------------------
variable "solution" {
  description = "Solution identity configuration"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
  })
}

variable "aws" {
  description = "AWS provider configuration"
  type = object({
    region     = string
    dr_region  = optional(string, "us-west-2")
    account_id = optional(string, "")
    profile    = optional(string, "")
  })
}

variable "ownership" {
  description = "Ownership and cost tracking"
  type = object({
    cost_center  = string
    owner_email  = string
    project_code = string
  })
}

#------------------------------------------------------------------------------
# Network Configuration (networking.tfvars)
#------------------------------------------------------------------------------
variable "network" {
  description = "VPC and networking configuration"
  type = object({
    vpc_cidr                = string
    public_subnet_cidrs     = list(string)
    private_subnet_cidrs    = list(string)
    enable_dns_hostnames    = optional(bool, true)
    enable_dns_support      = optional(bool, true)
    enable_nat_gateway      = bool
    single_nat_gateway      = bool
    enable_flow_logs        = bool
    flow_log_retention_days = number
  })
}

#------------------------------------------------------------------------------
# Compute Configuration (compute.tfvars)
#------------------------------------------------------------------------------
variable "compute" {
  description = "EKS and compute configuration"
  type = object({
    # EKS Cluster Configuration
    eks_cluster_name       = string
    eks_node_instance_type = string
    eks_node_count         = number
    eks_node_min_count     = number
    eks_node_max_count     = number
  })
}

#------------------------------------------------------------------------------
# Database Configuration (database.tfvars)
#------------------------------------------------------------------------------
variable "database" {
  description = "RDS database configuration"
  type = object({
    rds_instance_class      = string
    rds_storage_gb          = number
    rds_database_name       = string
    rds_multi_az            = bool
    rds_backup_retention    = number
    rds_deletion_protection = bool
  })
}

#------------------------------------------------------------------------------
# Security Configuration (security.tfvars)
#------------------------------------------------------------------------------
variable "security" {
  description = "Security and access control configuration"
  type = object({
    # KMS Encryption
    enable_kms_encryption = bool
    kms_deletion_window   = number
    # WAF Configuration
    enable_waf            = bool
    waf_rate_limit        = number
    # GuardDuty Configuration
    enable_guardduty      = bool
    # CloudTrail Configuration
    enable_cloudtrail     = bool
    # Authentication
    sso_enabled           = bool
    mfa_required          = bool
  })
}

#------------------------------------------------------------------------------
# Terraform Enterprise Configuration (tfe-platform.tfvars)
#------------------------------------------------------------------------------
variable "tfe" {
  description = "Terraform Enterprise configuration"
  type = object({
    organization     = string
    hostname         = string
    license_path     = optional(string, "")
    admin_email      = string
    operational_mode = string
    concurrent_runs  = number
    workspace_count  = number
    user_count       = number
  })
}

# Vault endpoint for dynamic credentials
variable "vault_endpoint" {
  description = "HashiCorp Vault endpoint URL"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# HashiCorp Vault Configuration (hashicorp-vault.tfvars)
#------------------------------------------------------------------------------
variable "vault" {
  description = "HashiCorp Vault integration configuration"
  type = object({
    enabled   = bool
    aws_role  = string
    aws_path  = string
  })
}

#------------------------------------------------------------------------------
# Sentinel Configuration (sentinel.tfvars)
#------------------------------------------------------------------------------
variable "sentinel" {
  description = "Sentinel policy configuration"
  type = object({
    enabled           = bool
    policy_count      = number
    enforcement_level = string
  })
}

#------------------------------------------------------------------------------
# VCS Integration Configuration (vcs-integration.tfvars)
#------------------------------------------------------------------------------
variable "integration" {
  description = "VCS and external integration configuration"
  type = object({
    github_org          = string
    github_vcs_enabled  = bool
    slack_enabled       = bool
    pagerduty_enabled   = bool
    servicenow_enabled  = optional(bool, false)
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration (monitoring.tfvars)
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "CloudWatch and observability configuration"
  type = object({
    enable_dashboard   = bool
    log_retention_days = number
    datadog_enabled    = bool
  })
}

#------------------------------------------------------------------------------
# Backup Configuration (backup.tfvars)
#------------------------------------------------------------------------------
variable "backup" {
  description = "AWS Backup configuration"
  type = object({
    enabled             = bool
    daily_retention     = number
    weekly_retention    = number
    enable_cross_region = bool
  })
}

#------------------------------------------------------------------------------
# DR Configuration (dr.tfvars)
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster Recovery configuration"
  type = object({
    enabled       = bool
    strategy      = string
    rto_minutes   = number
    rpo_minutes   = number
    failover_mode = string
  })
}

#------------------------------------------------------------------------------
# Budget Configuration (budget.tfvars)
#------------------------------------------------------------------------------
variable "budget" {
  description = "AWS Budgets configuration"
  type = object({
    enabled          = bool
    monthly_amount   = number
    alert_thresholds = list(number)
  })
}
