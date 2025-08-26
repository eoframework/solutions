# Variables for GitHub Actions Enterprise CI/CD Platform Infrastructure

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "github-actions-enterprise"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

variable "github_token" {
  description = "GitHub personal access token for API access"
  type        = string
  sensitive   = true
}

variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "github_runner_token" {
  description = "GitHub runner registration token"
  type        = string
  sensitive   = true
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "runner_subnet_count" {
  description = "Number of subnets for GitHub Actions runners"
  type        = number
  default     = 3
}

variable "management_cidrs" {
  description = "CIDR blocks allowed for SSH access to runners"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# Runner Configuration
variable "runner_instance_type" {
  description = "EC2 instance type for GitHub Actions runners"
  type        = string
  default     = "t3.large"
}

variable "runner_min_size" {
  description = "Minimum number of runners in auto scaling group"
  type        = number
  default     = 1
}

variable "runner_max_size" {
  description = "Maximum number of runners in auto scaling group"
  type        = number
  default     = 10
}

variable "runner_desired_capacity" {
  description = "Desired number of runners in auto scaling group"
  type        = number
  default     = 2
}

variable "runner_group" {
  description = "GitHub Actions runner group name"
  type        = string
  default     = "default"
}

variable "runner_labels" {
  description = "Labels to assign to GitHub Actions runners"
  type        = list(string)
  default     = ["aws", "linux", "x64"]
}

# Storage and Logging
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

# Security Configuration
variable "enable_ssm_session_manager" {
  description = "Enable AWS Systems Manager Session Manager for runner access"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2 instances"
  type        = bool
  default     = true
}

# Tagging
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Advanced Configuration
variable "enable_spot_instances" {
  description = "Use EC2 Spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "spot_instance_types" {
  description = "EC2 instance types for Spot instances"
  type        = list(string)
  default     = ["t3.large", "t3.xlarge", "m5.large", "m5.xlarge"]
}

variable "enable_hibernation" {
  description = "Enable hibernation for EC2 instances"
  type        = bool
  default     = false
}

variable "enable_ebs_optimization" {
  description = "Enable EBS optimization for better storage performance"
  type        = bool
  default     = true
}

# Monitoring and Alerting
variable "enable_cloudwatch_agent" {
  description = "Install and configure CloudWatch agent on runners"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alerting (optional)"
  type        = string
  default     = ""
}

# Backup and Recovery
variable "enable_backup" {
  description = "Enable automated backup of runner configurations"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# Performance Tuning
variable "enable_enhanced_networking" {
  description = "Enable enhanced networking for better performance"
  type        = bool
  default     = true
}

variable "enable_placement_group" {
  description = "Use placement group for better network performance"
  type        = bool
  default     = false
}

# Security Hardening
variable "enable_imds_v2" {
  description = "Require IMDSv2 for enhanced security"
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "Disable accidental instance termination"
  type        = bool
  default     = false
}

# Network Security
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "VPC Flow Logs retention period in days"
  type        = number
  default     = 14
}