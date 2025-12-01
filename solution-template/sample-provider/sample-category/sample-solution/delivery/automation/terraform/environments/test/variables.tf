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
    vpc_cidr                   = string
    public_subnet_cidrs        = list(string)
    private_subnet_cidrs       = list(string)
    database_subnet_cidrs      = list(string)
    enable_dns_hostnames       = bool
    enable_dns_support         = bool
    enable_nat_gateway         = bool
    single_nat_gateway         = bool
    map_public_ip_on_launch    = optional(bool, true)
    enable_flow_logs           = bool
    flow_log_retention_days    = number
    flow_log_traffic_type      = optional(string, "ALL")
    flow_log_destination_type  = optional(string, "cloud-watch-logs")
    flow_log_aggregation_interval = optional(number, 60)
    https_port                 = optional(number, 443)
    http_port                  = optional(number, 80)
    ssh_port                   = optional(number, 22)
  })
}

#------------------------------------------------------------------------------
# Security Configuration (security.tfvars)
#------------------------------------------------------------------------------

variable "security" {
  description = "Security and access control configuration"
  type = object({
    # Network Access Controls
    allowed_https_cidrs       = list(string)
    allowed_http_cidrs        = list(string)
    allowed_ssh_cidrs         = list(string)
    enable_ssh_access         = bool
    # Instance Security
    enable_instance_profile   = bool
    enable_ssm_access         = bool
    require_imdsv2            = bool
    metadata_hop_limit        = number
    # KMS Encryption
    enable_kms_encryption     = bool
    kms_deletion_window       = number
    enable_key_rotation       = bool
    # WAF Configuration
    enable_waf                = bool
    waf_rate_limit            = number
    waf_ip_address_version    = optional(string, "IPV4")
    waf_rule_priorities       = optional(map(number), {})
    # GuardDuty Configuration
    enable_guardduty               = bool
    guardduty_finding_frequency    = optional(string, "FIFTEEN_MINUTES")
    guardduty_s3_protection        = optional(bool, true)
    guardduty_eks_protection       = optional(bool, false)
    guardduty_malware_protection   = optional(bool, false)
    guardduty_severity_threshold   = optional(number, 7)
    # CloudTrail Configuration
    enable_cloudtrail                    = bool
    cloudtrail_retention_days            = number
    cloudtrail_include_global_events     = optional(bool, true)
    cloudtrail_is_multi_region           = optional(bool, true)
    cloudtrail_enable_log_validation     = optional(bool, true)
    cloudtrail_event_read_write_type     = optional(string, "All")
    cloudtrail_include_management_events = optional(bool, true)
    # S3 Security Defaults
    s3_block_public_acls       = optional(bool, true)
    s3_block_public_policy     = optional(bool, true)
    s3_ignore_public_acls      = optional(bool, true)
    s3_restrict_public_buckets = optional(bool, true)
    s3_noncurrent_version_days = optional(number, 30)
    s3_encryption_algorithm    = optional(string, "aws:kms")
    # Service Ports
    db_port                   = number
    cache_port                = number
  })
}

#------------------------------------------------------------------------------
# Compute Configuration (compute.tfvars)
#------------------------------------------------------------------------------

variable "compute" {
  description = "EC2 and Auto Scaling configuration"
  type = object({
    # EC2 Instance Configuration
    instance_type              = string
    use_latest_ami             = bool
    ami_filter_name            = optional(string, "al2023-ami-*-x86_64")
    ami_virtualization         = optional(string, "hvm")
    ami_owner                  = optional(string, "amazon")
    # Root Volume Configuration
    root_volume_size           = number
    root_volume_type           = string
    root_volume_iops           = number
    root_volume_throughput     = number
    root_volume_encrypted      = optional(bool, true)
    root_volume_device         = optional(string, "/dev/xvda")
    delete_on_termination      = optional(bool, true)
    # Instance Monitoring & Network
    enable_detailed_monitoring = bool
    associate_public_ip        = optional(bool, false)
    # Instance Metadata Service
    metadata_http_endpoint     = optional(string, "enabled")
    metadata_http_tokens       = optional(string, "required")
    metadata_hop_limit         = optional(number, 1)
    metadata_tags_enabled      = optional(string, "enabled")
    # Auto Scaling Group Configuration
    enable_auto_scaling        = bool
    asg_min_size               = number
    asg_max_size               = number
    asg_desired_capacity       = number
    health_check_grace_period  = number
    health_check_type          = optional(string, "ELB")
    default_cooldown           = optional(number, 300)
    termination_policies       = optional(list(string), ["Default"])
    suspended_processes        = optional(list(string), [])
    # Instance Refresh
    instance_refresh_strategy    = optional(string, "Rolling")
    instance_refresh_min_healthy = optional(number, 50)
    instance_refresh_warmup      = optional(number, 300)
    # Launch Template
    launch_template_version    = optional(string, "$Latest")
    # Scaling Policies
    scale_up_threshold         = number
    scale_down_threshold       = number
    scale_up_adjustment        = optional(number, 2)
    scale_down_adjustment      = optional(number, -1)
    scaling_cooldown           = optional(number, 300)
    # Tags
    propagate_tags_at_launch   = optional(bool, true)
  })
}

variable "alb" {
  description = "Application Load Balancer configuration"
  type = object({
    enabled                    = bool
    internal                   = bool
    enable_deletion_protection = bool
    # TLS/SSL Configuration
    certificate_arn            = optional(string, "")
    ssl_policy                 = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    # ALB Behavior Settings
    idle_timeout_seconds       = optional(number, 60)
    deregistration_delay       = optional(number, 300)
    drop_invalid_header_fields = optional(bool, true)
    # HTTP to HTTPS Redirect
    redirect_http_to_https     = optional(bool, true)
    redirect_status_code       = optional(string, "HTTP_301")
    # Health Check Configuration
    health_check_path          = string
    health_check_interval      = number
    health_check_timeout       = number
    healthy_threshold          = number
    unhealthy_threshold        = number
    health_check_matcher       = optional(string, "200-299")
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
    # Enable/Disable
    enabled                       = optional(bool, true)
    # Engine Configuration
    engine                        = string
    engine_version                = string
    instance_class                = string
    # Storage Configuration
    allocated_storage             = number
    max_allocated_storage         = number
    storage_type                  = optional(string, "gp3")
    storage_iops                  = optional(number, 3000)
    storage_throughput            = optional(number, 125)
    storage_encrypted             = bool
    # Database Identity
    name                          = string
    username                      = string
    # High Availability
    multi_az                      = bool
    # Backup Configuration
    backup_retention              = number
    backup_window                 = string
    maintenance_window            = string
    # Performance & Monitoring
    performance_insights          = bool
    performance_insights_retention = optional(number, 7)
    # Logging Configuration
    log_exports_postgres          = optional(list(string), ["postgresql", "upgrade"])
    log_exports_mysql             = optional(list(string), ["error", "slowquery", "general"])
    # Version Management
    auto_minor_version_upgrade    = optional(bool, true)
    allow_major_version_upgrade   = optional(bool, false)
    # Protection
    deletion_protection           = bool
    skip_final_snapshot           = optional(bool, false)
    copy_tags_to_snapshot         = optional(bool, true)
    # Network
    publicly_accessible           = optional(bool, false)
  })
}

#------------------------------------------------------------------------------
# Cache Configuration (cache.tfvars)
#------------------------------------------------------------------------------

variable "cache" {
  description = "ElastiCache configuration"
  type = object({
    enabled                    = bool
    # Engine Configuration
    engine                     = string
    engine_version             = string
    port                       = optional(number, 6379)
    # Instance Configuration
    node_type                  = string
    num_nodes                  = number
    # High Availability
    automatic_failover         = bool
    # Encryption
    at_rest_encryption         = bool
    transit_encryption         = bool
    # Backup Configuration
    snapshot_retention         = number
    snapshot_window            = string
    # Maintenance Configuration
    maintenance_window         = optional(string, "sun:06:00-sun:07:00")
    auto_minor_version_upgrade = optional(bool, true)
    # Cluster Mode (Redis only)
    cluster_mode_enabled       = optional(bool, false)
    cluster_mode_replicas      = optional(number, 1)
    cluster_mode_shards        = optional(number, 1)
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration (monitoring.tfvars)
#------------------------------------------------------------------------------

variable "monitoring" {
  description = "CloudWatch and observability configuration"
  type = object({
    # CloudWatch Logs
    log_retention_days           = number
    # CloudWatch Dashboard & Insights
    enable_dashboard             = bool
    enable_container_insights    = bool
    # CloudWatch Alarm Defaults
    alarm_evaluation_periods     = optional(number, 2)
    alarm_period_seconds         = optional(number, 300)
    alarm_treat_missing_data     = optional(string, "missing")
    # Dashboard Widget Settings
    dashboard_widget_width       = optional(number, 8)
    dashboard_widget_height      = optional(number, 6)
    # X-Ray Tracing Configuration
    enable_xray_tracing          = bool
    xray_sampling                = optional(object({
      priority       = optional(number, 1000)
      reservoir_size = optional(number, 1)
      fixed_rate     = optional(number, 0.05)
      url_path       = optional(string, "*")
      http_method    = optional(string, "*")
      service_type   = optional(string, "*")
      host           = optional(string, "*")
    }), {})
  })
}

variable "alarm_thresholds" {
  description = "Resource-specific alarm thresholds"
  type = object({
    # Database (RDS) Alarms
    db_cpu_percent            = optional(number, 80)
    db_storage_bytes          = optional(number, 10737418240)
    db_connections            = optional(number, 100)
    db_read_latency_seconds   = optional(number, 0.02)
    db_write_latency_seconds  = optional(number, 0.05)
    # Cache (ElastiCache) Alarms
    cache_cpu_percent         = optional(number, 75)
    cache_memory_percent      = optional(number, 80)
    cache_evictions           = optional(number, 1000)
    cache_connections         = optional(number, 500)
    # Compute (EC2/ASG) Alarms
    ec2_cpu_percent           = optional(number, 80)
    ec2_memory_percent        = optional(number, 85)
    ec2_disk_percent          = optional(number, 80)
    # ALB Alarms
    alb_5xx_count             = optional(number, 10)
    alb_4xx_count             = optional(number, 100)
    alb_response_time_seconds = optional(number, 1.0)
    alb_unhealthy_hosts       = optional(number, 1)
  })
  default = {}
}

#------------------------------------------------------------------------------
# Best Practices Configuration (best-practices.tfvars)
#------------------------------------------------------------------------------

variable "config_rules" {
  description = "AWS Config rules configuration"
  type = object({
    enabled                   = bool
    enable_recorder           = bool
    retention_days            = number
    # Rule Categories
    enable_security_rules     = optional(bool, true)
    enable_reliability_rules  = optional(bool, true)
    enable_operational_rules  = optional(bool, true)
    enable_cost_rules         = optional(bool, true)
    # Rule Parameters
    min_backup_retention_days = optional(number, 7)
    # Config Recorder Settings
    record_all_resources      = optional(bool, true)
    include_global_resources  = optional(bool, true)
    excluded_resource_types   = optional(list(string), [])
    delivery_frequency        = optional(string, "TwentyFour_Hours")
  })
}

variable "guardduty_enhanced" {
  description = "Enhanced GuardDuty configuration"
  type = object({
    enabled                   = bool
    enable_eks_protection     = bool
    enable_malware_protection = bool
    severity_threshold        = number
    # Findings Export
    enable_s3_export          = optional(bool, true)
    findings_retention_days   = optional(number, 365)
  })
}

variable "backup" {
  description = "AWS Backup configuration"
  type = object({
    enabled                    = bool
    # Daily Backups
    daily_schedule             = string
    daily_retention            = number
    # Weekly Backups
    enable_weekly              = optional(bool, true)
    weekly_schedule            = string
    weekly_retention           = number
    # Monthly Backups
    enable_monthly             = optional(bool, true)
    monthly_schedule           = string
    monthly_retention          = number
    cold_storage_days          = number
    # Cross-Region DR
    enable_cross_region        = bool
    dr_retention               = number
    # Resource Selection
    enable_tag_selection       = optional(bool, true)
    backup_tag_key             = optional(string, "Backup")
    backup_tag_value           = optional(string, "true")
    resource_arns              = optional(list(string), [])
    # Advanced Options
    enable_continuous          = bool
    enable_windows_vss         = bool
    enable_s3_backup           = optional(bool, false)
    enable_vault_policy        = optional(bool, true)
    # Compliance (WORM)
    enable_vault_lock          = bool
    vault_lock_min_retention   = number
    vault_lock_max_retention   = number
    vault_lock_changeable_days = number
    # Notifications
    notification_events        = optional(list(string), [
      "BACKUP_JOB_STARTED",
      "BACKUP_JOB_COMPLETED",
      "BACKUP_JOB_FAILED",
      "RESTORE_JOB_STARTED",
      "RESTORE_JOB_COMPLETED",
      "RESTORE_JOB_FAILED"
    ])
  })
}

variable "budget" {
  description = "AWS Budgets configuration"
  type = object({
    enabled                      = bool
    # Monthly Cost Budget
    enable_cost_budget           = optional(bool, true)
    monthly_amount               = number
    budget_currency              = optional(string, "USD")
    budget_time_unit             = optional(string, "MONTHLY")
    # Alert Thresholds
    alert_thresholds             = list(number)
    enable_forecast_alert        = optional(bool, true)
    forecast_threshold           = number
    # Notification Settings
    notification_comparison      = optional(string, "GREATER_THAN")
    notification_threshold_type  = optional(string, "PERCENTAGE")
    notification_type            = optional(string, "ACTUAL")
    # Alert Recipients
    alert_emails                 = list(string)
    # Service-Specific Budgets
    enable_service_budgets       = bool
    ec2_budget_amount            = number
    rds_budget_amount            = number
    data_transfer_budget_amount  = number
    service_alert_threshold      = optional(number, 80)
    # Usage Budget
    enable_usage_budget          = bool
    ec2_usage_hours_limit        = number
    # Budget Actions
    enable_actions               = bool
    action_approval              = string
    action_threshold             = number
    ec2_instances_to_stop        = list(string)
  })
}
