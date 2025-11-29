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

#------------------------------------------------------------------------------
# Instance Configuration
#------------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "use_latest_ami" {
  description = "Use latest Amazon Linux 2023 AMI"
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "AMI ID (required if use_latest_ami is false)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "associate_public_ip" {
  description = "Associate public IP address"
  type        = bool
  default     = false
}

variable "user_data_base64" {
  description = "Base64 encoded user data script"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# EBS Configuration
#------------------------------------------------------------------------------

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 50
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_iops" {
  description = "Root volume IOPS (for gp3/io1/io2)"
  type        = number
  default     = 3000
}

variable "root_volume_throughput" {
  description = "Root volume throughput in MB/s (for gp3)"
  type        = number
  default     = 125
}

variable "enable_ebs_encryption" {
  description = "Enable EBS encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for EBS encryption"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Metadata Configuration
#------------------------------------------------------------------------------

variable "require_imdsv2" {
  description = "Require IMDSv2 for instance metadata"
  type        = bool
  default     = true
}

variable "metadata_hop_limit" {
  description = "Metadata response hop limit"
  type        = number
  default     = 1
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# ASG Configuration
#------------------------------------------------------------------------------

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 1
}

variable "health_check_type" {
  description = "Health check type (EC2 or ELB)"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "default_cooldown" {
  description = "Default cooldown in seconds"
  type        = number
  default     = 300
}

variable "termination_policies" {
  description = "Termination policies"
  type        = list(string)
  default     = ["Default"]
}

variable "instance_refresh_min_healthy" {
  description = "Minimum healthy percentage during instance refresh"
  type        = number
  default     = 50
}

#------------------------------------------------------------------------------
# Warm Pool Configuration
#------------------------------------------------------------------------------

variable "enable_warm_pool" {
  description = "Enable warm pool"
  type        = bool
  default     = false
}

variable "warm_pool_state" {
  description = "Warm pool instance state"
  type        = string
  default     = "Stopped"
}

variable "warm_pool_min_size" {
  description = "Warm pool minimum size"
  type        = number
  default     = 0
}

variable "warm_pool_max_size" {
  description = "Warm pool maximum size"
  type        = number
  default     = 2
}

#------------------------------------------------------------------------------
# Scaling Policy Configuration
#------------------------------------------------------------------------------

variable "enable_scaling_policies" {
  description = "Enable CPU-based scaling policies"
  type        = bool
  default     = true
}

variable "scale_up_threshold" {
  description = "CPU percentage to trigger scale up"
  type        = number
  default     = 70
}

variable "scale_down_threshold" {
  description = "CPU percentage to trigger scale down"
  type        = number
  default     = 30
}

variable "scale_up_adjustment" {
  description = "Number of instances to add when scaling up"
  type        = number
  default     = 1
}

variable "scale_down_adjustment" {
  description = "Number of instances to remove when scaling down (negative)"
  type        = number
  default     = -1
}

variable "scale_up_cooldown" {
  description = "Scale up cooldown in seconds"
  type        = number
  default     = 300
}

variable "scale_down_cooldown" {
  description = "Scale down cooldown in seconds"
  type        = number
  default     = 300
}

variable "alarm_evaluation_periods" {
  description = "Number of periods for alarm evaluation"
  type        = number
  default     = 2
}

variable "alarm_period" {
  description = "Alarm period in seconds"
  type        = number
  default     = 120
}
