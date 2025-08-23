# GitHub Advanced Security Platform - Terraform Variables
# This file defines all configurable variables for the security monitoring infrastructure

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "github-advanced-security"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.project_name))
    error_message = "Project name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# GitHub Configuration
variable "github_token" {
  description = "GitHub personal access token or GitHub App token"
  type        = string
  sensitive   = true
}

variable "github_organization" {
  description = "GitHub organization name"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.github_organization))
    error_message = "GitHub organization name must be valid."
  }
}

variable "github_app_id" {
  description = "GitHub App ID (optional, recommended for production)"
  type        = string
  default     = ""
}

variable "github_app_private_key" {
  description = "GitHub App private key (optional, recommended for production)"
  type        = string
  default     = ""
  sensitive   = true
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# Security Configuration
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access security monitoring services"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "enable_encryption" {
  description = "Enable encryption for storage and transit"
  type        = bool
  default     = true
}

# S3 Configuration
variable "security_logs_bucket_name" {
  description = "Name of S3 bucket for security logs (leave empty for auto-generated)"
  type        = string
  default     = ""
}

variable "s3_force_destroy" {
  description = "Force destroy S3 buckets (use with caution)"
  type        = bool
  default     = false
}

# Monitoring and Logging
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch value."
  }
}

# Webhook Configuration
variable "enable_webhook" {
  description = "Enable GitHub webhook for security events"
  type        = bool
  default     = true
}

variable "webhook_secret" {
  description = "Secret for GitHub webhook validation"
  type        = string
  default     = ""
  sensitive   = true
}

# Dashboard Configuration
variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "dashboard_name" {
  description = "CloudWatch dashboard name (leave empty for auto-generated)"
  type        = string
  default     = ""
}

# Alert Configuration
variable "enable_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email address for security notifications"
  type        = string
  default     = ""
  
  validation {
    condition     = var.notification_email == "" || can(regex("^[^@]+@[^@]+\\.[^@]+$", var.notification_email))
    error_message = "Notification email must be a valid email address or empty."
  }
}

# SIEM Integration Configuration
variable "enable_splunk_integration" {
  description = "Enable Splunk SIEM integration"
  type        = bool
  default     = false
}

variable "splunk_hec_url" {
  description = "Splunk HTTP Event Collector URL"
  type        = string
  default     = ""
}

variable "splunk_hec_token" {
  description = "Splunk HTTP Event Collector token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_azure_sentinel" {
  description = "Enable Azure Sentinel integration"
  type        = bool
  default     = false
}

variable "azure_sentinel_workspace_id" {
  description = "Azure Sentinel Log Analytics workspace ID"
  type        = string
  default     = ""
}

variable "azure_sentinel_shared_key" {
  description = "Azure Sentinel Log Analytics shared key"
  type        = string
  default     = ""
  sensitive   = true
}

# Datadog Integration
variable "datadog_api_key" {
  description = "Datadog API key for monitoring integration"
  type        = string
  default     = ""
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog application key for monitoring integration"
  type        = string
  default     = ""
  sensitive   = true
}

# Security Scanning Configuration
variable "enable_codeql" {
  description = "Enable CodeQL scanning for all repositories"
  type        = bool
  default     = true
}

variable "enable_secret_scanning" {
  description = "Enable secret scanning for all repositories"
  type        = bool
  default     = true
}

variable "enable_dependency_scanning" {
  description = "Enable dependency vulnerability scanning"
  type        = bool
  default     = true
}

variable "security_scan_schedule" {
  description = "Cron schedule for automated security scans"
  type        = string
  default     = "0 2 * * *"  # Daily at 2 AM
}

# Compliance Configuration
variable "compliance_frameworks" {
  description = "List of compliance frameworks to monitor"
  type        = list(string)
  default     = ["SOC2", "PCI-DSS", "GDPR", "HIPAA"]
}

variable "enable_audit_logging" {
  description = "Enable comprehensive audit logging"
  type        = bool
  default     = true
}

variable "audit_log_retention_days" {
  description = "Retention period for audit logs in days"
  type        = number
  default     = 2555  # 7 years for compliance
  
  validation {
    condition     = var.audit_log_retention_days > 0
    error_message = "Audit log retention days must be greater than 0."
  }
}

# Backup Configuration
variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 90
  
  validation {
    condition     = var.backup_retention_days > 0
    error_message = "Backup retention days must be greater than 0."
  }
}

# Performance Configuration
variable "security_monitoring_instance_type" {
  description = "EC2 instance type for security monitoring services"
  type        = string
  default     = "t3.medium"
}

variable "auto_scaling_min_size" {
  description = "Minimum number of instances for auto scaling"
  type        = number
  default     = 1
  
  validation {
    condition     = var.auto_scaling_min_size >= 0
    error_message = "Auto scaling minimum size must be non-negative."
  }
}

variable "auto_scaling_max_size" {
  description = "Maximum number of instances for auto scaling"
  type        = number
  default     = 10
  
  validation {
    condition     = var.auto_scaling_max_size > 0
    error_message = "Auto scaling maximum size must be positive."
  }
}

variable "auto_scaling_desired_capacity" {
  description = "Desired number of instances for auto scaling"
  type        = number
  default     = 2
  
  validation {
    condition     = var.auto_scaling_desired_capacity >= 0
    error_message = "Auto scaling desired capacity must be non-negative."
  }
}

# Cost Optimization
variable "use_spot_instances" {
  description = "Use EC2 Spot Instances for cost optimization"
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "Maximum price per hour for Spot Instances"
  type        = string
  default     = ""
}

# Advanced Configuration
variable "custom_security_rules" {
  description = "Custom security rules for additional scanning"
  type = list(object({
    name        = string
    description = string
    severity    = string
    query       = string
  }))
  default = []
}

variable "security_baseline_config" {
  description = "Security baseline configuration settings"
  type = object({
    require_2fa                = bool
    max_inactive_days         = number
    password_policy_enabled   = bool
    branch_protection_enabled = bool
    security_advisories_enabled = bool
  })
  default = {
    require_2fa                = true
    max_inactive_days         = 90
    password_policy_enabled   = true
    branch_protection_enabled = true
    security_advisories_enabled = true
  }
}

# Resource Tags
variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default = {
    Project     = "github-advanced-security"
    Environment = "dev"
    Owner       = "security-team"
    ManagedBy   = "terraform"
    Purpose     = "security-monitoring"
  }
}

# Lambda Configuration
variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 300
  
  validation {
    condition     = var.lambda_timeout > 0 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
  
  validation {
    condition = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 and 10240 MB."
  }
}

# API Gateway Configuration
variable "api_gateway_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

variable "api_gateway_throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 1000
}

variable "api_gateway_throttle_rate_limit" {
  description = "API Gateway throttle rate limit"
  type        = number
  default     = 500
}