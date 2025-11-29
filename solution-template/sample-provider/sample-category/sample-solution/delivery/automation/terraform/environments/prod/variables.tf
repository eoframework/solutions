# Environment Variables with Validation
# All values provided via tfvars files
# Comprehensive validation ensures inputs are valid before deployment

# =============================================================================
# SOLUTION IDENTITY (from main.tfvars)
# =============================================================================

variable "solution_name" {
  description = "Full solution name (e.g., vxrail-hyperconverged)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,48}[a-z0-9]$", var.solution_name))
    error_message = "Solution name must be 4-50 lowercase alphanumeric characters with hyphens, starting and ending with alphanumeric."
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

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.provider_name))
    error_message = "Provider name must be 3-30 lowercase alphanumeric characters with hyphens."
  }
}

variable "category_name" {
  description = "Category name (e.g., cloud, security, network)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.category_name))
    error_message = "Category name must be 3-30 lowercase alphanumeric characters with hyphens."
  }
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
    error_message = "AWS region must be valid format (e.g., us-east-1, eu-west-2, ap-southeast-1)."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile name (optional). Leave empty to use default credential chain."
  type        = string
  default     = ""
}

variable "aws_account_id" {
  description = "AWS account ID (optional, for validation)"
  type        = string
  default     = ""

  validation {
    condition     = var.aws_account_id == "" || can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS account ID must be a 12-digit number."
  }
}

# =============================================================================
# OWNERSHIP & COST TRACKING (from main.tfvars)
# =============================================================================

variable "cost_center" {
  description = "Cost center code for billing"
  type        = string
  default     = ""

  validation {
    condition     = var.cost_center == "" || can(regex("^[A-Za-z0-9-]{2,20}$", var.cost_center))
    error_message = "Cost center must be 2-20 alphanumeric characters with hyphens."
  }
}

variable "owner_email" {
  description = "Owner/team email for notifications"
  type        = string
  default     = ""

  validation {
    condition     = var.owner_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

variable "project_code" {
  description = "Project tracking code"
  type        = string
  default     = ""

  validation {
    condition     = var.project_code == "" || can(regex("^[A-Za-z0-9-]{2,20}$", var.project_code))
    error_message = "Project code must be 2-20 alphanumeric characters with hyphens."
  }
}

variable "additional_tags" {
  description = "Additional custom tags for all resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# NETWORKING CONFIGURATION (from networking.tfvars)
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)."
  }

  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 28
    error_message = "VPC CIDR prefix must be between /16 and /28."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 1 && length(var.public_subnet_cidrs) <= 6
    error_message = "Must have 1-6 public subnets."
  }

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) >= 1 && length(var.private_subnet_cidrs) <= 6
    error_message = "Must have 1-6 private subnets."
  }

  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.database_subnet_cidrs) <= 6
    error_message = "Maximum 6 database subnets allowed."
  }

  validation {
    condition     = alltrue([for cidr in var.database_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All database subnet CIDRs must be valid IPv4 CIDR blocks."
  }
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
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Flow log retention in days"
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.flow_log_retention_days)
    error_message = "Flow log retention must be a valid CloudWatch Logs retention value."
  }
}

# =============================================================================
# SECURITY CONFIGURATION (from security.tfvars)
# =============================================================================

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed HTTPS access to ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.allowed_https_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All HTTPS CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed HTTP access to ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.allowed_http_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All HTTP CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed SSH access to instances"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.allowed_ssh_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All SSH CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "enable_ssh_access" {
  description = "Enable SSH access to instances"
  type        = bool
  default     = false
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption for resources"
  type        = bool
  default     = true
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window >= 7 && var.kms_deletion_window <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "enable_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
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

  validation {
    condition     = var.metadata_hop_limit >= 1 && var.metadata_hop_limit <= 64
    error_message = "Metadata hop limit must be between 1 and 64."
  }
}

variable "enable_waf" {
  description = "Enable AWS WAF on ALB"
  type        = bool
  default     = true
}

variable "waf_rate_limit" {
  description = "WAF rate limit per IP (5-minute window)"
  type        = number
  default     = 2000

  validation {
    condition     = var.waf_rate_limit >= 100 && var.waf_rate_limit <= 20000000
    error_message = "WAF rate limit must be between 100 and 20,000,000."
  }
}

variable "enable_guardduty" {
  description = "Enable Amazon GuardDuty"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_retention_days" {
  description = "CloudTrail log retention in days"
  type        = number
  default     = 365

  validation {
    condition     = var.cloudtrail_retention_days >= 1 && var.cloudtrail_retention_days <= 3653
    error_message = "CloudTrail retention must be between 1 and 3653 days (10 years)."
  }
}

# =============================================================================
# COMPUTE CONFIGURATION (from compute.tfvars)
# =============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?[0-9]?[a-z]?\\.(nano|micro|small|medium|large|xlarge|[0-9]+xlarge|metal)$", var.instance_type))
    error_message = "Instance type must be valid AWS format (e.g., t3.medium, m5.xlarge, r6i.2xlarge)."
  }
}

variable "use_latest_ami" {
  description = "Use latest Amazon Linux 2023 AMI"
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "Specific AMI ID (used when use_latest_ami is false)"
  type        = string
  default     = ""

  validation {
    condition     = var.ami_id == "" || can(regex("^ami-[a-f0-9]{8,17}$", var.ami_id))
    error_message = "AMI ID must be valid format (ami-xxxxxxxxxxxxxxxxx)."
  }
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 50

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 GB and 16 TB (16384 GB)."
  }
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.root_volume_type)
    error_message = "Root volume type must be: gp2, gp3, io1, io2, st1, or sc1."
  }
}

variable "root_volume_iops" {
  description = "Root volume IOPS (for gp3/io1/io2)"
  type        = number
  default     = 3000

  validation {
    condition     = var.root_volume_iops >= 100 && var.root_volume_iops <= 64000
    error_message = "Root volume IOPS must be between 100 and 64,000."
  }
}

variable "root_volume_throughput" {
  description = "Root volume throughput in MB/s (for gp3)"
  type        = number
  default     = 125

  validation {
    condition     = var.root_volume_throughput >= 125 && var.root_volume_throughput <= 1000
    error_message = "Root volume throughput must be between 125 and 1000 MB/s."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = true
}

variable "asg_min_size" {
  description = "ASG minimum instance count"
  type        = number
  default     = 2

  validation {
    condition     = var.asg_min_size >= 0 && var.asg_min_size <= 100
    error_message = "ASG min size must be between 0 and 100."
  }
}

variable "asg_max_size" {
  description = "ASG maximum instance count"
  type        = number
  default     = 10

  validation {
    condition     = var.asg_max_size >= 1 && var.asg_max_size <= 500
    error_message = "ASG max size must be between 1 and 500."
  }
}

variable "asg_desired_capacity" {
  description = "ASG desired instance count"
  type        = number
  default     = 3

  validation {
    condition     = var.asg_desired_capacity >= 0 && var.asg_desired_capacity <= 500
    error_message = "ASG desired capacity must be between 0 and 500."
  }
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.health_check_grace_period >= 0 && var.health_check_grace_period <= 7200
    error_message = "Health check grace period must be between 0 and 7200 seconds."
  }
}

variable "scale_up_threshold" {
  description = "CPU % to trigger scale up"
  type        = number
  default     = 70

  validation {
    condition     = var.scale_up_threshold >= 1 && var.scale_up_threshold <= 100
    error_message = "Scale up threshold must be between 1 and 100 percent."
  }
}

variable "scale_down_threshold" {
  description = "CPU % to trigger scale down"
  type        = number
  default     = 30

  validation {
    condition     = var.scale_down_threshold >= 1 && var.scale_down_threshold <= 100
    error_message = "Scale down threshold must be between 1 and 100 percent."
  }
}

variable "enable_alb" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "alb_internal" {
  description = "Make ALB internal (not internet-facing)"
  type        = bool
  default     = false
}

variable "enable_lb_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
  default     = ""

  validation {
    condition     = var.acm_certificate_arn == "" || can(regex("^arn:aws:acm:[a-z0-9-]+:[0-9]{12}:certificate/[a-f0-9-]{36}$", var.acm_certificate_arn))
    error_message = "ACM certificate ARN must be valid format."
  }
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/health"

  validation {
    condition     = can(regex("^/", var.health_check_path))
    error_message = "Health check path must start with /."
  }
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds."
  }
}

variable "healthy_threshold" {
  description = "Consecutive healthy checks required"
  type        = number
  default     = 2

  validation {
    condition     = var.healthy_threshold >= 2 && var.healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }
}

variable "unhealthy_threshold" {
  description = "Consecutive unhealthy checks before marking unhealthy"
  type        = number
  default     = 3

  validation {
    condition     = var.unhealthy_threshold >= 2 && var.unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }
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
# DATABASE CONFIGURATION (from database.tfvars)
# =============================================================================

variable "db_engine" {
  description = "Database engine type"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "mariadb", "oracle-se2", "oracle-ee", "sqlserver-se", "sqlserver-ee"], var.db_engine)
    error_message = "Database engine must be: postgres, mysql, mariadb, oracle-se2, oracle-ee, sqlserver-se, or sqlserver-ee."
  }
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.db_engine_version))
    error_message = "Database engine version must be in format X.Y (e.g., 15.4, 8.0)."
  }
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.db_instance_class))
    error_message = "RDS instance class must be valid format (e.g., db.t3.medium, db.r5.large)."
  }
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 65536
    error_message = "Database storage must be between 20 GB and 64 TB (65536 GB)."
  }
}

variable "db_max_allocated_storage" {
  description = "Maximum storage for autoscaling in GB"
  type        = number
  default     = 100

  validation {
    condition     = var.db_max_allocated_storage >= 20 && var.db_max_allocated_storage <= 65536
    error_message = "Database max storage must be between 20 GB and 64 TB (65536 GB)."
  }
}

variable "db_storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,62}$", var.db_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores (max 63 chars)."
  }
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
  sensitive   = true

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,62}$", var.db_username))
    error_message = "Database username must start with a letter and contain only alphanumeric characters and underscores."
  }
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
  default     = true
}

variable "db_backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 30

  validation {
    condition     = var.db_backup_retention >= 0 && var.db_backup_retention <= 35
    error_message = "Backup retention must be between 0 and 35 days."
  }
}

variable "db_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"

  validation {
    condition     = can(regex("^[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]$", var.db_backup_window))
    error_message = "Backup window must be in format HH:MM-HH:MM (e.g., 03:00-04:00)."
  }
}

variable "db_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"

  validation {
    condition     = can(regex("^(mon|tue|wed|thu|fri|sat|sun):[0-2][0-9]:[0-5][0-9]-(mon|tue|wed|thu|fri|sat|sun):[0-2][0-9]:[0-5][0-9]$", var.db_maintenance_window))
    error_message = "Maintenance window must be in format day:HH:MM-day:HH:MM (e.g., sun:04:00-sun:05:00)."
  }
}

variable "db_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

# =============================================================================
# CACHE CONFIGURATION (from cache.tfvars)
# =============================================================================

variable "cache_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.cache_engine_version))
    error_message = "Redis engine version must be in format X.Y (e.g., 7.0, 6.2)."
  }
}

variable "cache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"

  validation {
    condition     = can(regex("^cache\\.[a-z0-9]+\\.[a-z0-9]+$", var.cache_node_type))
    error_message = "ElastiCache node type must be valid format (e.g., cache.t3.micro, cache.r5.large)."
  }
}

variable "cache_num_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.cache_num_nodes >= 1 && var.cache_num_nodes <= 6
    error_message = "Cache node count must be between 1 and 6."
  }
}

variable "cache_automatic_failover" {
  description = "Enable automatic failover"
  type        = bool
  default     = true
}

variable "cache_at_rest_encryption" {
  description = "Enable at-rest encryption"
  type        = bool
  default     = true
}

variable "cache_transit_encryption" {
  description = "Enable in-transit encryption"
  type        = bool
  default     = true
}

variable "cache_snapshot_retention" {
  description = "Snapshot retention in days"
  type        = number
  default     = 7

  validation {
    condition     = var.cache_snapshot_retention >= 0 && var.cache_snapshot_retention <= 35
    error_message = "Cache snapshot retention must be between 0 and 35 days."
  }
}

variable "cache_snapshot_window" {
  description = "Preferred snapshot window (UTC)"
  type        = string
  default     = "05:00-06:00"

  validation {
    condition     = can(regex("^[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]$", var.cache_snapshot_window))
    error_message = "Snapshot window must be in format HH:MM-HH:MM (e.g., 05:00-06:00)."
  }
}

# =============================================================================
# MONITORING CONFIGURATION (from monitoring.tfvars)
# =============================================================================

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch Logs retention value."
  }
}

variable "enable_container_insights" {
  description = "Enable Container Insights for ECS/EKS"
  type        = bool
  default     = true
}

variable "enable_dashboard" {
  description = "Create CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "alarm_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
  default     = ""

  validation {
    condition     = var.alarm_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alarm_email))
    error_message = "Alarm email must be a valid email address."
  }
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = true
}

# =============================================================================
# WELL-ARCHITECTED FRAMEWORK CONFIGURATION
# =============================================================================
# These settings enable AWS Well-Architected pillar-specific resources
# for governance, compliance, and operational excellence.

#------------------------------------------------------------------------------
# Operational Excellence: AWS Config
#------------------------------------------------------------------------------

variable "enable_config_rules" {
  description = "Enable AWS Config for compliance monitoring"
  type        = bool
  default     = true
}

variable "enable_config_recorder" {
  description = "Enable AWS Config recorder (set false if already enabled in account)"
  type        = bool
  default     = true
}

variable "config_bucket_name" {
  description = "S3 bucket for Config delivery (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "config_retention_days" {
  description = "Config log retention in days"
  type        = number
  default     = 365

  validation {
    condition     = var.config_retention_days >= 90 && var.config_retention_days <= 3653
    error_message = "Config retention must be between 90 and 3653 days."
  }
}

#------------------------------------------------------------------------------
# Security: Enhanced GuardDuty
#------------------------------------------------------------------------------

variable "enable_guardduty_enhanced" {
  description = "Enable enhanced GuardDuty with S3/malware protection"
  type        = bool
  default     = false  # Set false if using security module's GuardDuty
}

variable "enable_eks_protection" {
  description = "Enable GuardDuty EKS protection"
  type        = bool
  default     = false
}

variable "enable_malware_protection" {
  description = "Enable GuardDuty malware protection"
  type        = bool
  default     = true
}

variable "guardduty_findings_bucket" {
  description = "S3 bucket for GuardDuty findings (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "guardduty_severity_threshold" {
  description = "Minimum severity for GuardDuty SNS alerts (1-8)"
  type        = number
  default     = 7

  validation {
    condition     = var.guardduty_severity_threshold >= 1 && var.guardduty_severity_threshold <= 8
    error_message = "GuardDuty severity threshold must be between 1 and 8."
  }
}

#------------------------------------------------------------------------------
# Reliability: AWS Backup
#------------------------------------------------------------------------------

variable "enable_backup_plans" {
  description = "Enable AWS Backup for centralized backup management"
  type        = bool
  default     = true
}

variable "backup_daily_schedule" {
  description = "Daily backup schedule (cron expression, UTC)"
  type        = string
  default     = "cron(0 5 * * ? *)"  # 5 AM UTC daily
}

variable "backup_daily_retention" {
  description = "Daily backup retention in days"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_daily_retention >= 1 && var.backup_daily_retention <= 365
    error_message = "Daily backup retention must be between 1 and 365 days."
  }
}

variable "backup_weekly_schedule" {
  description = "Weekly backup schedule (cron expression, UTC)"
  type        = string
  default     = "cron(0 5 ? * SUN *)"  # Sunday 5 AM UTC
}

variable "backup_weekly_retention" {
  description = "Weekly backup retention in days"
  type        = number
  default     = 90

  validation {
    condition     = var.backup_weekly_retention >= 7 && var.backup_weekly_retention <= 365
    error_message = "Weekly backup retention must be between 7 and 365 days."
  }
}

variable "backup_monthly_schedule" {
  description = "Monthly backup schedule (cron expression, UTC)"
  type        = string
  default     = "cron(0 5 1 * ? *)"  # 1st of month 5 AM UTC
}

variable "backup_monthly_retention" {
  description = "Monthly backup retention in days"
  type        = number
  default     = 365

  validation {
    condition     = var.backup_monthly_retention >= 30 && var.backup_monthly_retention <= 3653
    error_message = "Monthly backup retention must be between 30 and 3653 days."
  }
}

variable "backup_cold_storage_days" {
  description = "Days before moving monthly backups to cold storage"
  type        = number
  default     = 90

  validation {
    condition     = var.backup_cold_storage_days >= 7 && var.backup_cold_storage_days <= 365
    error_message = "Cold storage transition must be between 7 and 365 days."
  }
}

variable "enable_backup_cross_region" {
  description = "Enable cross-region backup copy for DR"
  type        = bool
  default     = false
}

variable "backup_dr_retention" {
  description = "DR region backup retention in days"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_dr_retention >= 1 && var.backup_dr_retention <= 365
    error_message = "DR backup retention must be between 1 and 365 days."
  }
}

variable "dr_kms_key_arn" {
  description = "KMS key ARN for DR region backup vault"
  type        = string
  default     = ""
}

variable "backup_resource_arns" {
  description = "Specific resource ARNs to include in backup"
  type        = list(string)
  default     = []
}

variable "enable_continuous_backup" {
  description = "Enable continuous backup for point-in-time recovery"
  type        = bool
  default     = false
}

variable "enable_windows_vss" {
  description = "Enable Windows VSS for application-consistent backups"
  type        = bool
  default     = false
}

variable "enable_backup_vault_lock" {
  description = "Enable vault lock for compliance (WORM)"
  type        = bool
  default     = false
}

variable "vault_lock_min_retention" {
  description = "Minimum retention days for vault lock"
  type        = number
  default     = 7
}

variable "vault_lock_max_retention" {
  description = "Maximum retention days for vault lock"
  type        = number
  default     = 365
}

variable "vault_lock_changeable_days" {
  description = "Days before vault lock becomes immutable"
  type        = number
  default     = 3
}

#------------------------------------------------------------------------------
# Cost Optimization: AWS Budgets
#------------------------------------------------------------------------------

variable "enable_budgets" {
  description = "Enable AWS Budgets for cost alerting"
  type        = bool
  default     = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 1000

  validation {
    condition     = var.monthly_budget_amount > 0 && var.monthly_budget_amount <= 10000000
    error_message = "Monthly budget must be between $1 and $10,000,000."
  }
}

variable "budget_alert_thresholds" {
  description = "Percentage thresholds for budget alerts"
  type        = list(number)
  default     = [50, 80, 100]

  validation {
    condition     = alltrue([for t in var.budget_alert_thresholds : t >= 1 && t <= 200])
    error_message = "Alert thresholds must be between 1 and 200 percent."
  }
}

variable "budget_forecast_threshold" {
  description = "Forecasted cost threshold percentage"
  type        = number
  default     = 100

  validation {
    condition     = var.budget_forecast_threshold >= 50 && var.budget_forecast_threshold <= 200
    error_message = "Forecast threshold must be between 50 and 200 percent."
  }
}

variable "budget_alert_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = []
}

variable "budget_cost_filter_tags" {
  description = "Filter costs by tags (map of tag key to value)"
  type        = map(string)
  default     = null
}

variable "enable_service_budgets" {
  description = "Enable service-specific budgets"
  type        = bool
  default     = false
}

variable "ec2_budget_amount" {
  description = "Monthly EC2 budget in USD (0 to disable)"
  type        = number
  default     = 0
}

variable "rds_budget_amount" {
  description = "Monthly RDS budget in USD (0 to disable)"
  type        = number
  default     = 0
}

variable "data_transfer_budget_amount" {
  description = "Monthly data transfer budget in USD (0 to disable)"
  type        = number
  default     = 0
}

variable "enable_usage_budget" {
  description = "Enable EC2 usage hours budget"
  type        = bool
  default     = false
}

variable "ec2_usage_hours_limit" {
  description = "Maximum EC2 hours per month"
  type        = number
  default     = 1000
}

variable "enable_budget_actions" {
  description = "Enable automated budget actions"
  type        = bool
  default     = false
}

variable "budget_action_approval" {
  description = "Approval model for budget actions (AUTOMATIC or MANUAL)"
  type        = string
  default     = "MANUAL"

  validation {
    condition     = contains(["AUTOMATIC", "MANUAL"], var.budget_action_approval)
    error_message = "Budget action approval must be AUTOMATIC or MANUAL."
  }
}

variable "budget_action_threshold" {
  description = "Threshold percentage to trigger budget action"
  type        = number
  default     = 100
}

variable "budget_ec2_instances_to_stop" {
  description = "EC2 instance IDs to stop when budget exceeded"
  type        = list(string)
  default     = []
}
