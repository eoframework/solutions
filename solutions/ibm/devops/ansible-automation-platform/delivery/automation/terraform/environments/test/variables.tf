#==============================================================================
# Ansible Automation Platform - Test Environment Variables
#==============================================================================
# Identical structure to production - values differ via tfvars
#==============================================================================

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "solution" {
  description = "Solution metadata"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
  })
}

variable "platform" {
  description = "Platform configuration"
  type = object({
    controller_url = string
    hub_url        = string
    eda_enabled    = bool
    version        = string
  })
}

variable "compute" {
  description = "Compute resources configuration"
  type = object({
    ami_id                   = string
    key_name                 = string
    controller_count         = number
    controller_cpu           = number
    controller_memory_gb     = number
    controller_instance_type = string
    execution_count          = number
    execution_cpu            = number
    execution_memory_gb      = number
    execution_instance_type  = string
    hub_instance_type        = string
  })
}

variable "database" {
  description = "Database configuration"
  type = object({
    host           = string
    port           = number
    name           = string
    username       = string
    instance_class = string
    storage_gb     = number
    multi_az       = bool
  })
}

variable "database_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "network" {
  description = "Network configuration"
  type = object({
    vpc_cidr           = string
    public_subnets     = list(string)
    private_subnets    = list(string)
    availability_zones = list(string)
  })
}

variable "auth" {
  description = "Authentication configuration"
  type = object({
    ldap_enabled           = bool
    ldap_url               = string
    ldap_bind_dn           = string
    ldap_user_search_base  = string
    ldap_group_search_base = string
    session_timeout_seconds = number
  })
}

variable "credentials" {
  description = "Credentials configuration"
  type = object({
    vault_enabled   = bool
    vault_url       = string
    vault_namespace = string
    cyberark_enabled = bool
  })
}

variable "integration" {
  description = "Integration configuration"
  type = object({
    servicenow_enabled   = bool
    servicenow_instance  = string
    servicenow_username  = string
    monitoring_webhook_url = string
  })
}

variable "content" {
  description = "Content configuration"
  type = object({
    git_repo_url           = string
    git_branch_prod        = string
    sync_interval_minutes  = number
    execution_environments = list(string)
  })
}

variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    log_aggregator_enabled = bool
    log_aggregator_host    = string
    log_aggregator_port    = number
    log_aggregator_type    = string
    pagerduty_enabled      = bool
    insights_enabled       = bool
  })
}

variable "performance" {
  description = "Performance configuration"
  type = object({
    max_concurrent_jobs      = number
    job_timeout_seconds      = number
    forks_default            = number
    job_event_buffer_seconds = number
  })
}

variable "inventory" {
  description = "Inventory configuration"
  type = object({
    managed_server_count       = number
    managed_network_count      = number
    dynamic_inventory_enabled  = bool
    smart_inventory_enabled    = bool
  })
}

variable "rbac" {
  description = "RBAC configuration"
  type = object({
    default_organization = string
    admin_team           = string
    operator_team        = string
    auditor_team         = string
  })
}

variable "security" {
  description = "Security configuration"
  type = object({
    kms_key_arn         = string
    acm_certificate_arn = string
  })
  default = {
    kms_key_arn         = null
    acm_certificate_arn = null
  }
}

variable "backup" {
  description = "Backup configuration"
  type = object({
    enabled        = bool
    schedule_cron  = string
    retention_days = number
    s3_bucket      = string
  })
}

variable "dr" {
  description = "DR configuration"
  type = object({
    enabled               = bool
    strategy              = string
    rto_hours             = number
    rpo_hours             = number
    db_replication_enabled = bool
  })
}

variable "ownership" {
  description = "Resource ownership metadata"
  type = object({
    cost_center  = string
    owner_email  = string
    project_code = string
  })
}

variable "budget" {
  description = "Budget configuration"
  type = object({
    enabled            = bool
    monthly_amount_usd = number
    alert_thresholds   = list(number)
  })
}
