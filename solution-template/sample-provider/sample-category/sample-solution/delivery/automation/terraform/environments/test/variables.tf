# Test Environment Variables with Validation
# Simplified version - same validations as prod but with test-appropriate defaults

# =============================================================================
# SOLUTION IDENTITY (from main.tfvars)
# =============================================================================

variable "solution_name" {
  description = "Full solution name (e.g., vxrail-hyperconverged)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,48}[a-z0-9]$", var.solution_name))
    error_message = "Solution name must be 4-50 lowercase alphanumeric characters with hyphens."
  }
}

variable "solution_abbr" {
  description = "Solution abbreviation (3-4 chars) for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,4}$", var.solution_abbr))
    error_message = "Solution abbreviation must be 3-4 lowercase alphanumeric characters."
  }
}

variable "provider_name" {
  description = "Provider name (e.g., dell, aws, microsoft)"
  type        = string
}

variable "category_name" {
  description = "Category name (e.g., cloud, security, network)"
  type        = string
}

variable "environment" {
  description = "Environment name (auto-discovered from folder, or override)"
  type        = string
  default     = ""

  validation {
    condition     = var.environment == "" || contains(["prod", "test", "dr"], var.environment)
    error_message = "Environment must be: prod, test, or dr (or empty for auto-discovery)."
  }
}

# =============================================================================
# AWS CONFIGURATION (from main.tfvars)
# =============================================================================

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be valid format (e.g., us-east-1)."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile name (optional). Leave empty to use default credential chain."
  type        = string
  default     = ""
}

variable "aws_account_id" {
  description = "AWS account ID (optional)"
  type        = string
  default     = ""
}

# =============================================================================
# OWNERSHIP & COST TRACKING (from main.tfvars)
# =============================================================================

variable "cost_center" {
  description = "Cost center code for billing"
  type        = string
  default     = ""
}

variable "owner_email" {
  description = "Owner/team email for notifications"
  type        = string
  default     = ""
}

variable "project_code" {
  description = "Project tracking code"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional custom tags for all resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# NETWORKING CONFIGURATION
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway vs one per AZ"
  type        = bool
  default     = true  # Test: single NAT for cost savings
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false  # Test: disabled
}

variable "flow_log_retention_days" {
  description = "Flow log retention in days"
  type        = number
  default     = 7  # Test: 7 days
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed HTTPS access to ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed HTTP access to ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed SSH access to instances"
  type        = list(string)
  default     = []
}

variable "enable_ssh_access" {
  description = "Enable SSH access to instances"
  type        = bool
  default     = true  # Test: enabled for debugging
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption for resources"
  type        = bool
  default     = false  # Test: disabled for cost savings
}

variable "enable_instance_profile" {
  description = "Create IAM instance profile for EC2"
  type        = bool
  default     = true
}

variable "enable_ssm_access" {
  description = "Enable SSM Session Manager access"
  type        = bool
  default     = true
}

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

# =============================================================================
# COMPUTE CONFIGURATION
# =============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"  # Test: smaller instance

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?[0-9]?[a-z]?\\.(nano|micro|small|medium|large|xlarge|[0-9]+xlarge|metal)$", var.instance_type))
    error_message = "Instance type must be valid AWS format."
  }
}

variable "use_latest_ami" {
  description = "Use latest Amazon Linux 2023 AMI"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30  # Test: smaller volume

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 GB and 16 TB."
  }
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_iops" {
  description = "Root volume IOPS"
  type        = number
  default     = 3000
}

variable "root_volume_throughput" {
  description = "Root volume throughput in MB/s"
  type        = number
  default     = 125
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false  # Test: disabled
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = true
}

variable "asg_min_size" {
  description = "ASG minimum instance count"
  type        = number
  default     = 1  # Test: minimal

  validation {
    condition     = var.asg_min_size >= 0 && var.asg_min_size <= 100
    error_message = "ASG min size must be between 0 and 100."
  }
}

variable "asg_max_size" {
  description = "ASG maximum instance count"
  type        = number
  default     = 2  # Test: minimal

  validation {
    condition     = var.asg_max_size >= 1 && var.asg_max_size <= 500
    error_message = "ASG max size must be between 1 and 500."
  }
}

variable "asg_desired_capacity" {
  description = "ASG desired instance count"
  type        = number
  default     = 1  # Test: minimal
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "scale_up_threshold" {
  description = "CPU % to trigger scale up"
  type        = number
  default     = 70
}

variable "scale_down_threshold" {
  description = "CPU % to trigger scale down"
  type        = number
  default     = 30
}

variable "enable_alb" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "alb_internal" {
  description = "Make ALB internal"
  type        = bool
  default     = false
}

variable "enable_lb_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
  default     = false  # Test: disabled for easy teardown
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Consecutive healthy checks required"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Consecutive unhealthy checks required"
  type        = number
  default     = 3
}

variable "app_port" {
  description = "Application server port"
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "Application port must be between 1 and 65535."
  }
}

# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================

variable "db_engine" {
  description = "Database engine type"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.db_engine)
    error_message = "Database engine must be: postgres, mysql, or mariadb."
  }
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"  # Test: smallest instance

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.db_instance_class))
    error_message = "RDS instance class must be valid format."
  }
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20  # Test: minimum

  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 65536
    error_message = "Database storage must be between 20 GB and 64 TB."
  }
}

variable "db_max_allocated_storage" {
  description = "Maximum storage for autoscaling in GB"
  type        = number
  default     = 50  # Test: limited growth
}

variable "db_storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = false  # Test: disabled for simplicity
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "testdb"  # Test: testdb
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8 && length(var.db_password) <= 128
    error_message = "Database password must be between 8 and 128 characters."
  }
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false  # Test: single-AZ
}

variable "db_backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 1  # Test: minimal retention

  validation {
    condition     = var.db_backup_retention >= 0 && var.db_backup_retention <= 35
    error_message = "Backup retention must be between 0 and 35 days."
  }
}

variable "db_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "db_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false  # Test: disabled
}

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false  # Test: disabled for easy teardown
}
