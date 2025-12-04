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
    region    = string
    dr_region = optional(string, "us-west-2")
    profile   = optional(string, "")
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
    # Vault Instance Configuration
    vault_instance_type    = string
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
    enable_kms_encryption     = bool
    kms_deletion_window       = number
    # WAF Configuration
    enable_waf                = bool
    waf_rate_limit            = number
    # GuardDuty Configuration
    enable_guardduty          = bool
    # CloudTrail Configuration
    enable_cloudtrail         = bool
    cloudtrail_retention_days = number
    # Authentication
    sso_enabled               = bool
    mfa_required              = bool
  })
}

#------------------------------------------------------------------------------
# Terraform Cloud Configuration (tfc.tfvars)
#------------------------------------------------------------------------------
variable "tfc" {
  description = "Terraform Cloud/Enterprise configuration"
  type = object({
    organization      = string
    hostname          = string
    workspace_prefix  = string
    vcs_provider      = string
    concurrent_runs   = number
    user_count        = number
    workspace_count   = number
  })
}

#------------------------------------------------------------------------------
# HashiCorp Vault Configuration (vault.tfvars)
#------------------------------------------------------------------------------
variable "vault" {
  description = "HashiCorp Vault configuration"
  type = object({
    enabled                = bool
    namespace              = string
    auto_unseal_enabled    = bool
    aws_secrets_enabled    = bool
    azure_secrets_enabled  = bool
    gcp_secrets_enabled    = bool
    credential_ttl_seconds = number
    node_count             = number
  })
}

# Vault credentials for AWS secrets engine (passed securely)
variable "vault_aws_access_key" {
  description = "AWS access key for Vault secrets engine"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vault_aws_secret_key" {
  description = "AWS secret key for Vault secrets engine"
  type        = string
  sensitive   = true
  default     = ""
}

#------------------------------------------------------------------------------
# HashiCorp Consul Configuration (consul.tfvars)
#------------------------------------------------------------------------------
variable "consul" {
  description = "HashiCorp Consul configuration"
  type = object({
    enabled              = bool
    datacenter           = string
    connect_enabled      = bool
    acl_enabled          = bool
    mesh_gateway_enabled = bool
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
# VCS Integration Configuration (integration.tfvars)
#------------------------------------------------------------------------------
variable "integration" {
  description = "VCS and external integration configuration"
  type = object({
    github_org          = string
    github_vcs_enabled  = bool
    slack_enabled       = bool
    pagerduty_enabled   = bool
    servicenow_enabled  = bool
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration (monitoring.tfvars)
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "CloudWatch and observability configuration"
  type = object({
    enable_dashboard    = bool
    log_retention_days  = number
    enable_xray_tracing = bool
    datadog_enabled     = bool
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
    monthly_retention   = number
    enable_cross_region = bool
  })
}

#------------------------------------------------------------------------------
# DR Configuration (dr.tfvars)
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster Recovery configuration"
  type = object({
    enabled             = bool
    strategy            = string
    rto_minutes         = number
    rpo_minutes         = number
    failover_mode       = string
    replication_enabled = bool
  })
}

#------------------------------------------------------------------------------
# Budget Configuration (budget.tfvars)
#------------------------------------------------------------------------------
variable "budget" {
  description = "AWS Budgets configuration"
  type = object({
    enabled            = bool
    monthly_amount     = number
    alert_thresholds   = list(number)
    forecast_threshold = number
  })
}
