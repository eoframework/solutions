#------------------------------------------------------------------------------
# AWS Self-Hosted GitHub Actions Runners Module - Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# General Configuration
#------------------------------------------------------------------------------
variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Network Configuration
#------------------------------------------------------------------------------
variable "vpc_id" {
  description = "VPC ID for runner instances"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for runner ASG"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for runners"
  type        = string
}

#------------------------------------------------------------------------------
# Linux Runner Configuration
#------------------------------------------------------------------------------
variable "linux_ami_id" {
  description = "AMI ID for Linux runners"
  type        = string
}

variable "linux_instance_type" {
  description = "EC2 instance type for Linux runners"
  type        = string
  default     = "c5.2xlarge"
}

variable "linux_asg_min" {
  description = "Minimum number of Linux runners"
  type        = number
  default     = 1
}

variable "linux_asg_max" {
  description = "Maximum number of Linux runners"
  type        = number
  default     = 10
}

variable "linux_asg_desired" {
  description = "Desired number of Linux runners"
  type        = number
  default     = 2
}

#------------------------------------------------------------------------------
# Windows Runner Configuration
#------------------------------------------------------------------------------
variable "windows_ami_id" {
  description = "AMI ID for Windows runners"
  type        = string
  default     = ""
}

variable "windows_instance_type" {
  description = "EC2 instance type for Windows runners"
  type        = string
  default     = "c5.2xlarge"
}

variable "windows_asg_min" {
  description = "Minimum number of Windows runners"
  type        = number
  default     = 0
}

variable "windows_asg_max" {
  description = "Maximum number of Windows runners"
  type        = number
  default     = 0
}

variable "windows_asg_desired" {
  description = "Desired number of Windows runners"
  type        = number
  default     = 0
}

#------------------------------------------------------------------------------
# Scaling Configuration
#------------------------------------------------------------------------------
variable "scale_up_threshold" {
  description = "Queue depth threshold to trigger scale up"
  type        = number
  default     = 5
}

variable "scale_down_cooldown" {
  description = "Cooldown period before scale down (seconds)"
  type        = number
  default     = 900
}

#------------------------------------------------------------------------------
# GitHub Configuration
#------------------------------------------------------------------------------
variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "github_token" {
  description = "GitHub PAT for runner registration"
  type        = string
  sensitive   = true
}
