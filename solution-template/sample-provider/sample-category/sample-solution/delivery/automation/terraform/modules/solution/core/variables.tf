# Solution Core Module - Variables
# Accepts grouped object variables from environment configuration

#------------------------------------------------------------------------------
# Naming & Tagging Configuration (computed values from environment)
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Resource naming prefix (e.g., smp-prod)"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project/solution name (used for tags and fallback naming)"
  type        = string
}

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# KMS Key (passed from security module)
#------------------------------------------------------------------------------

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (from security module)"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Network Configuration (from networking.tfvars)
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
# Security Configuration (from security.tfvars)
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
# Compute Configuration (from compute.tfvars)
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

#------------------------------------------------------------------------------
# ALB Configuration (from compute.tfvars)
#------------------------------------------------------------------------------

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
# Application Configuration (from application.tfvars)
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
