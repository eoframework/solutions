#------------------------------------------------------------------------------
# Azure Document Intelligence - Test Environment Variables
#------------------------------------------------------------------------------
# All configuration is defined as grouped objects for cleaner module calls.
# Values are set in config/*.tfvars files.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Project Configuration (project.tfvars)
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

variable "azure" {
  description = "Azure subscription and region configuration"
  type = object({
    subscription_id = string
    tenant_id       = string
    region          = string
    dr_region       = string
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
# Network Configuration (networking.tfvars)
#------------------------------------------------------------------------------
variable "network" {
  description = "Virtual network configuration"
  type = object({
    vnet_cidr                = string
    subnet_functions         = string
    subnet_private_endpoints = string
    enable_private_endpoints = bool
  })
}

#------------------------------------------------------------------------------
# Compute Configuration (compute.tfvars)
#------------------------------------------------------------------------------
variable "compute" {
  description = "Azure Functions compute configuration"
  type = object({
    function_plan_type      = string
    function_plan_sku       = string
    autoscale_min_instances = number
    autoscale_max_instances = number
  })
}

#------------------------------------------------------------------------------
# Storage Configuration (storage.tfvars)
#------------------------------------------------------------------------------
variable "storage" {
  description = "Blob storage configuration"
  type = object({
    account_tier        = string
    replication_type    = string
    input_container     = string
    processed_container = string
    failed_container    = string
    archive_container   = string
    retention_hot_days  = number
    retention_cool_days = number
    retention_total_days = number
  })
}

#------------------------------------------------------------------------------
# Database Configuration (database.tfvars)
#------------------------------------------------------------------------------
variable "database" {
  description = "Cosmos DB configuration"
  type = object({
    cosmos_offer_type            = string
    cosmos_consistency_level     = string
    cosmos_database_name         = string
    cosmos_metadata_container    = string
    cosmos_results_container     = string
    cosmos_max_throughput        = number
    cosmos_enable_free_tier      = bool
    cosmos_backup_type           = string
    cosmos_backup_interval_hours = number
    cosmos_backup_retention_hours = number
  })
}

#------------------------------------------------------------------------------
# Security Configuration (security.tfvars)
#------------------------------------------------------------------------------
variable "security" {
  description = "Security and access control configuration"
  type = object({
    enable_customer_managed_key = bool
    admin_group_id              = string
    reviewer_group_id           = string
    user_group_id               = string
  })
}

#------------------------------------------------------------------------------
# Application Configuration (application.tfvars)
#------------------------------------------------------------------------------
variable "application" {
  description = "Application settings"
  type = object({
    environment          = string
    log_level            = string
    confidence_threshold = number
  })
}

variable "docintel" {
  description = "Azure Document Intelligence configuration"
  type = object({
    sku                 = string
    model_invoice       = string
    model_receipt       = string
    model_custom        = optional(string, "")
    enable_custom_model = bool
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration (monitoring.tfvars)
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "Azure Monitor configuration"
  type = object({
    enable_alerts         = bool
    enable_dashboard      = bool
    log_retention_days    = number
    alert_email           = string
    health_check_interval = number
  })
}

#------------------------------------------------------------------------------
# Best Practices Configuration (best-practices.tfvars)
#------------------------------------------------------------------------------
variable "backup" {
  description = "Backup and recovery configuration"
  type = object({
    enabled        = bool
    retention_days = number
  })
}

variable "budget" {
  description = "Cost management budget configuration"
  type = object({
    enabled            = bool
    monthly_amount     = number
    alert_thresholds   = list(number)
    notification_email = string
  })
}

variable "policy" {
  description = "Azure Policy configuration"
  type = object({
    enable_security_policies    = bool
    enable_cost_policies        = bool
    enable_operational_policies = bool
  })
}

#------------------------------------------------------------------------------
# DR Configuration (dr.tfvars)
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster recovery configuration"
  type = object({
    enabled             = bool
    replication_enabled = bool
    failover_priority   = number
  })
}
