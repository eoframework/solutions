# HashiCorp Terraform Enterprise Platform - Variables
# This file defines all input variables for the Terraform Enterprise deployment

# Project Configuration
variable "project_name" {
  description = "Name of the project and prefix for resources"
  type        = string
  default     = "tfe-platform"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "platform-team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state storage"
  type        = string
}

variable "admin_role_name" {
  description = "IAM role name for administrators"
  type        = string
  default     = "OrganizationAccountAccessRole"
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

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnets are required for high availability."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least 2 private subnets are required for high availability."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]

  validation {
    condition     = length(var.database_subnet_cidrs) >= 2
    error_message = "At least 2 database subnets are required for RDS multi-AZ."
  }
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"

  validation {
    condition     = can(regex("^1\\.(2[6-9]|[3-9][0-9])$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.26 or higher."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.large", "t3.xlarge"]
}

variable "min_node_count" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.min_node_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "max_node_count" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 10

  validation {
    condition     = var.max_node_count >= var.min_node_count
    error_message = "Maximum node count must be greater than or equal to minimum node count."
  }
}

variable "desired_node_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.desired_node_count >= var.min_node_count && var.desired_node_count <= var.max_node_count
    error_message = "Desired node count must be between min and max node counts."
  }
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50

  validation {
    condition     = var.node_disk_size >= 20
    error_message = "Node disk size must be at least 20 GB."
  }
}

variable "ssh_key_name" {
  description = "AWS EC2 Key Pair name for SSH access to nodes"
  type        = string
  default     = ""
}

# Database Configuration
variable "postgres_version" {
  description = "PostgreSQL version for RDS instance"
  type        = string
  default     = "14.9"

  validation {
    condition     = can(regex("^1[4-9]\\.", var.postgres_version))
    error_message = "PostgreSQL version must be 14.0 or higher."
  }
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.large"

  validation {
    condition     = can(regex("^db\\.", var.db_instance_class))
    error_message = "Database instance class must be a valid RDS instance type."
  }
}

variable "db_allocated_storage" {
  description = "Initial storage allocation for RDS instance (GB)"
  type        = number
  default     = 100

  validation {
    condition     = var.db_allocated_storage >= 20
    error_message = "Database allocated storage must be at least 20 GB."
  }
}

variable "db_max_allocated_storage" {
  description = "Maximum storage allocation for RDS instance (GB)"
  type        = number
  default     = 1000

  validation {
    condition     = var.db_max_allocated_storage >= var.db_allocated_storage
    error_message = "Maximum allocated storage must be greater than or equal to allocated storage."
  }
}

variable "database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "terraform_enterprise"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "database_username" {
  description = "Master username for the database"
  type        = string
  default     = "tfe_admin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_username))
    error_message = "Database username must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "db_backup_retention_days" {
  description = "Number of days to retain database backups"
  type        = number
  default     = 7

  validation {
    condition     = var.db_backup_retention_days >= 1 && var.db_backup_retention_days <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

variable "db_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"

  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]-([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.db_backup_window))
    error_message = "Backup window must be in format HH:MM-HH:MM."
  }
}

variable "db_maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "Sun:04:00-Sun:05:00"

  validation {
    condition     = can(regex("^(Mon|Tue|Wed|Thu|Fri|Sat|Sun):[0-2][0-9]:[0-5][0-9]-(Mon|Tue|Wed|Thu|Fri|Sat|Sun):[0-2][0-9]:[0-5][0-9]$", var.db_maintenance_window))
    error_message = "Maintenance window must be in format ddd:HH:MM-ddd:HH:MM."
  }
}

# Domain and SSL Configuration
variable "domain_name" {
  description = "Domain name for Terraform Enterprise"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\\.[a-zA-Z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid FQDN."
  }
}

variable "create_dns_record" {
  description = "Whether to create Route53 DNS record"
  type        = bool
  default     = false
}

# Terraform Enterprise Configuration
variable "tfe_helm_chart_version" {
  description = "Version of Terraform Enterprise Helm chart"
  type        = string
  default     = "1.0.0"
}

variable "tfe_license_secret_name" {
  description = "Name of Kubernetes secret containing TFE license"
  type        = string
  default     = "tfe-license"
}

variable "tfe_replica_count" {
  description = "Number of Terraform Enterprise replicas"
  type        = number
  default     = 2

  validation {
    condition     = var.tfe_replica_count >= 1
    error_message = "TFE replica count must be at least 1."
  }
}

variable "tfe_resources" {
  description = "Resource requests and limits for TFE pods"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "1000m"
      memory = "2Gi"
    }
    limits = {
      cpu    = "2000m"
      memory = "4Gi"
    }
  }
}

variable "storage_class" {
  description = "Kubernetes storage class for persistent volumes"
  type        = string
  default     = "gp2"
}

variable "ingress_class" {
  description = "Kubernetes ingress class"
  type        = string
  default     = "alb"
}

# Monitoring and Logging
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on ALB"
  type        = bool
  default     = true
}

# Backup and Recovery
variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Cron expression for backup schedule"
  type        = string
  default     = "0 2 * * *"

  validation {
    condition     = can(regex("^[0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+$", var.backup_schedule))
    error_message = "Backup schedule must be a valid cron expression."
  }
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_retention_days >= 1
    error_message = "Backup retention days must be at least 1."
  }
}

# Security Configuration
variable "enable_encryption" {
  description = "Enable encryption at rest for all storage"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Terraform Enterprise"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "All allowed CIDR blocks must be valid IPv4 CIDR blocks."
  }
}

variable "enable_waf" {
  description = "Enable AWS WAF for additional security"
  type        = bool
  default     = true
}

# High Availability Configuration
variable "enable_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = true
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup replication"
  type        = bool
  default     = false
}

variable "backup_region" {
  description = "AWS region for cross-region backup replication"
  type        = string
  default     = "us-west-2"
}

# Performance Configuration
variable "enable_performance_insights" {
  description = "Enable Performance Insights for RDS"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be 7 or 731 days."
  }
}

# Cost Optimization
variable "enable_spot_instances" {
  description = "Enable Spot instances for worker nodes"
  type        = bool
  default     = false
}

variable "spot_instance_types" {
  description = "EC2 instance types for Spot instances"
  type        = list(string)
  default     = ["t3.large", "t3.xlarge", "m5.large", "m5.xlarge"]
}

variable "spot_allocation_strategy" {
  description = "Spot instance allocation strategy"
  type        = string
  default     = "diversified"

  validation {
    condition     = contains(["lowest-price", "diversified", "capacity-optimized"], var.spot_allocation_strategy)
    error_message = "Spot allocation strategy must be one of: lowest-price, diversified, capacity-optimized."
  }
}

# Compliance and Governance
variable "compliance_mode" {
  description = "Enable compliance mode with additional security controls"
  type        = bool
  default     = false
}

variable "required_tags" {
  description = "Required tags for all resources"
  type        = map(string)
  default = {
    "Compliance" = "Required"
    "Backup"     = "Required"
  }
}

# Integration Configuration
variable "enable_vault_integration" {
  description = "Enable HashiCorp Vault integration"
  type        = bool
  default     = false
}

variable "vault_address" {
  description = "HashiCorp Vault server address"
  type        = string
  default     = ""
}

variable "vault_namespace" {
  description = "HashiCorp Vault namespace"
  type        = string
  default     = ""
}

variable "enable_consul_integration" {
  description = "Enable HashiCorp Consul integration"
  type        = bool
  default     = false
}

variable "consul_address" {
  description = "HashiCorp Consul server address"
  type        = string
  default     = ""
}

# Notification Configuration
variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

# Advanced Configuration
variable "custom_user_data" {
  description = "Custom user data script for worker nodes"
  type        = string
  default     = ""
}

variable "additional_security_groups" {
  description = "Additional security groups for worker nodes"
  type        = list(string)
  default     = []
}

variable "node_labels" {
  description = "Kubernetes labels for worker nodes"
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "Kubernetes taints for worker nodes"
  type        = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}