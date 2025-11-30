# Generic AWS ASG Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Subnet IDs for ASG"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for instances"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Target group ARNs for ALB"
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS key ARN for EBS encryption"
  type        = string
  default     = null
}

variable "health_check_type" {
  description = "Health check type (EC2 or ELB)"
  type        = string
  default     = "EC2"
}

#------------------------------------------------------------------------------
# Compute Configuration (grouped object)
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
# Security Configuration (subset for ASG)
#------------------------------------------------------------------------------

variable "security" {
  description = "Security configuration for instances"
  type = object({
    require_imdsv2        = bool
    metadata_hop_limit    = number
    enable_kms_encryption = bool
  })
}
