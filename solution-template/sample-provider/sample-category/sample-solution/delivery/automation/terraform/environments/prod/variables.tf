#------------------------------------------------------------------------------
# Variables - Grouped Object Definitions
#------------------------------------------------------------------------------
# All configuration is defined as grouped objects for cleaner module calls.
# Values are set in config/*.tfvars files.
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
    region = string
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
    database_subnet_cidrs   = list(string)
    enable_dns_hostnames    = bool
    enable_dns_support      = bool
    enable_nat_gateway      = bool
    single_nat_gateway      = bool
    enable_flow_logs        = bool
    flow_log_retention_days = number
  })
}

#------------------------------------------------------------------------------
# Security Configuration (security.tfvars)
#------------------------------------------------------------------------------

variable "security" {
  description = "Security and access control configuration"
  type = object({
    allowed_https_cidrs       = list(string)
    allowed_http_cidrs        = list(string)
    allowed_ssh_cidrs         = list(string)
    enable_ssh_access         = bool
    enable_instance_profile   = bool
    enable_ssm_access         = bool
    require_imdsv2            = bool
    metadata_hop_limit        = number
    enable_kms_encryption     = bool
    kms_deletion_window       = number
    enable_key_rotation       = bool
    enable_waf                = bool
    waf_rate_limit            = number
    enable_guardduty          = bool
    enable_cloudtrail         = bool
    cloudtrail_retention_days = number
  })
}

#------------------------------------------------------------------------------
# Compute Configuration (compute.tfvars)
#------------------------------------------------------------------------------

variable "compute" {
  description = "EC2 and Auto Scaling configuration"
  type = object({
    instance_type              = string
    use_latest_ami             = bool
    root_volume_size           = number
    root_volume_type           = string
    root_volume_iops           = number
    root_volume_throughput     = number
    enable_detailed_monitoring = bool
    enable_auto_scaling        = bool
    asg_min_size               = number
    asg_max_size               = number
    asg_desired_capacity       = number
    health_check_grace_period  = number
    scale_up_threshold         = number
    scale_down_threshold       = number
  })
}

variable "alb" {
  description = "Application Load Balancer configuration"
  type = object({
    enabled                    = bool
    internal                   = bool
    enable_deletion_protection = bool
    health_check_path          = string
    health_check_interval      = number
    health_check_timeout       = number
    healthy_threshold          = number
    unhealthy_threshold        = number
  })
}

#------------------------------------------------------------------------------
# Application Configuration (application.tfvars)
#------------------------------------------------------------------------------

variable "application" {
  description = "Application-specific configuration"
  type = object({
    name            = string
    version         = string
    port            = number
    log_level       = string
    enable_debug    = bool
    health_path     = string
    metrics_path    = string
    rate_limit      = number
    session_timeout = number
  })
}

#------------------------------------------------------------------------------
# Database Configuration (database.tfvars)
#------------------------------------------------------------------------------

variable "database" {
  description = "RDS database configuration"
  type = object({
    engine                = string
    engine_version        = string
    instance_class        = string
    allocated_storage     = number
    max_allocated_storage = number
    storage_encrypted     = bool
    name                  = string
    username              = string
    multi_az              = bool
    backup_retention      = number
    backup_window         = string
    maintenance_window    = string
    performance_insights  = bool
    deletion_protection   = bool
  })
}

#------------------------------------------------------------------------------
# Cache Configuration (cache.tfvars)
#------------------------------------------------------------------------------

variable "cache" {
  description = "ElastiCache configuration"
  type = object({
    enabled            = bool
    engine             = string
    engine_version     = string
    node_type          = string
    num_nodes          = number
    automatic_failover = bool
    at_rest_encryption = bool
    transit_encryption = bool
    snapshot_retention = number
    snapshot_window    = string
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration (monitoring.tfvars)
#------------------------------------------------------------------------------

variable "monitoring" {
  description = "CloudWatch and observability configuration"
  type = object({
    log_retention_days        = number
    enable_dashboard          = bool
    enable_container_insights = bool
    enable_xray_tracing       = bool
  })
}

#------------------------------------------------------------------------------
# Best Practices Configuration (best-practices.tfvars)
#------------------------------------------------------------------------------

variable "config_rules" {
  description = "AWS Config rules configuration"
  type = object({
    enabled         = bool
    enable_recorder = bool
    retention_days  = number
  })
}

variable "guardduty_enhanced" {
  description = "Enhanced GuardDuty configuration"
  type = object({
    enabled                   = bool
    enable_eks_protection     = bool
    enable_malware_protection = bool
    severity_threshold        = number
  })
}

variable "backup" {
  description = "AWS Backup configuration"
  type = object({
    enabled                    = bool
    daily_schedule             = string
    daily_retention            = number
    weekly_schedule            = string
    weekly_retention           = number
    monthly_schedule           = string
    monthly_retention          = number
    cold_storage_days          = number
    enable_cross_region        = bool
    dr_retention               = number
    enable_continuous          = bool
    enable_windows_vss         = bool
    enable_vault_lock          = bool
    vault_lock_min_retention   = number
    vault_lock_max_retention   = number
    vault_lock_changeable_days = number
  })
}

variable "budget" {
  description = "AWS Budgets configuration"
  type = object({
    enabled                     = bool
    monthly_amount              = number
    alert_thresholds            = list(number)
    forecast_threshold          = number
    alert_emails                = list(string)
    enable_service_budgets      = bool
    ec2_budget_amount           = number
    rds_budget_amount           = number
    data_transfer_budget_amount = number
    enable_usage_budget         = bool
    ec2_usage_hours_limit       = number
    enable_actions              = bool
    action_approval             = string
    action_threshold            = number
    ec2_instances_to_stop       = list(string)
  })
}
