#------------------------------------------------------------------------------
# Azure DevOps Enterprise Platform - Production Environment Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Solution Identity
#------------------------------------------------------------------------------
variable "solution" {
  description = "Solution identification and metadata"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
  })
}

variable "ownership" {
  description = "Solution ownership and cost allocation"
  type = object({
    cost_center  = string
    owner_email  = string
    project_code = string
  })
}

#------------------------------------------------------------------------------
# Azure Configuration
#------------------------------------------------------------------------------
variable "azure" {
  description = "Azure subscription and region configuration"
  type = object({
    subscription_id = string
    tenant_id       = string
    region          = string
    dr_region       = string
  })
}

#------------------------------------------------------------------------------
# Network Configuration
#------------------------------------------------------------------------------
variable "network" {
  description = "Virtual network configuration"
  type = object({
    vnet_cidr                = string
    appservice_subnet_cidr   = string
    private_endpoint_cidr    = string
    private_endpoint_enabled = bool
  })
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
variable "security" {
  description = "Security and access control configuration"
  type = object({
    enable_private_endpoints      = bool
    enable_customer_managed_key   = bool
    admin_group_id                = string
    contributor_group_id          = string
    reader_group_id               = string
  })
}

#------------------------------------------------------------------------------
# Azure DevOps Configuration
#------------------------------------------------------------------------------
variable "devops" {
  description = "Azure DevOps organization and project configuration"
  type = object({
    organization_url          = string
    organization_name         = string
    project_name              = string
    project_description       = string
    version_control           = string
    work_item_template        = string
    enable_repos              = bool
    enable_pipelines          = bool
    enable_artifacts          = bool
    enable_test_plans         = bool
  })
}

#------------------------------------------------------------------------------
# Service Connections Configuration
#------------------------------------------------------------------------------
variable "service_connections" {
  description = "Azure DevOps service connections"
  type = object({
    azure_rm_enabled          = bool
    service_principal_id      = string
    service_principal_key     = string
  })
}

#------------------------------------------------------------------------------
# Compute Configuration (App Service)
#------------------------------------------------------------------------------
variable "compute" {
  description = "App Service compute configuration"
  type = object({
    app_service_plan_sku      = string
    app_service_plan_tier     = string
    autoscale_enabled         = bool
    autoscale_min_instances   = number
    autoscale_max_instances   = number
    deployment_slots_enabled  = bool
  })
}

#------------------------------------------------------------------------------
# Application Configuration
#------------------------------------------------------------------------------
variable "application" {
  description = "Application settings"
  type = object({
    environment           = string
    log_level             = string
    runtime_stack         = string
    runtime_version       = string
  })
}

#------------------------------------------------------------------------------
# Pipeline Configuration
#------------------------------------------------------------------------------
variable "pipelines" {
  description = "Azure Pipelines configuration"
  type = object({
    enable_ci                 = bool
    enable_cd                 = bool
    build_agents_pool         = string
    enable_pull_request_build = bool
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "Azure Monitor configuration"
  type = object({
    enable_alerts           = bool
    enable_dashboard        = bool
    log_retention_days      = number
    alert_email             = string
    health_check_interval   = number
  })
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------
variable "backup" {
  description = "Backup and recovery configuration"
  type = object({
    enabled              = bool
    retention_days       = number
  })
}

#------------------------------------------------------------------------------
# Budget Configuration
#------------------------------------------------------------------------------
variable "budget" {
  description = "Cost management budget configuration"
  type = object({
    enabled              = bool
    monthly_amount       = number
    alert_thresholds     = list(number)
    notification_email   = string
  })
}

#------------------------------------------------------------------------------
# Policy Configuration
#------------------------------------------------------------------------------
variable "policies" {
  description = "Azure Policy configuration"
  type = object({
    enable_security_policies    = bool
    enable_cost_policies        = bool
    enable_operational_policies = bool
  })
}

#------------------------------------------------------------------------------
# Disaster Recovery Configuration
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster recovery configuration"
  type = object({
    enabled                = bool
    replication_enabled    = bool
    failover_priority      = number
  })
}
