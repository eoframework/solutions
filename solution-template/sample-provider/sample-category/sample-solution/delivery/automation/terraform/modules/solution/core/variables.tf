# Solution Core Module - Variables
# All variables are passed from environment tfvars files

#------------------------------------------------------------------------------
# Naming & Tagging Configuration
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Resource naming prefix (e.g., smp-prod). If not provided, uses project_name-environment."
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
# Networking Configuration
#------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "List of database subnet CIDR blocks"
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
  description = "Use single NAT Gateway (cost optimization vs high availability)"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Flow log retention period in days"
  type        = number
  default     = 90
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------

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
  default     = false
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption for EBS volumes"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (uses AWS managed key if not specified)"
  type        = string
  default     = ""
}

variable "enable_instance_profile" {
  description = "Create IAM instance profile for EC2 instances"
  type        = bool
  default     = true
}

variable "enable_ssm_access" {
  description = "Enable SSM Session Manager access to instances"
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

#------------------------------------------------------------------------------
# Compute Configuration
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
  description = "Specific AMI ID (used when use_latest_ami is false)"
  type        = string
  default     = ""
}

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

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for instances"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Auto Scaling Configuration
#------------------------------------------------------------------------------

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = true
}

variable "asg_min_size" {
  description = "ASG minimum instance count"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "ASG maximum instance count"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "ASG desired instance count"
  type        = number
  default     = 1
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
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

#------------------------------------------------------------------------------
# Load Balancer Configuration
#------------------------------------------------------------------------------

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
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
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
  description = "Consecutive unhealthy checks before marking unhealthy"
  type        = number
  default     = 3
}

#------------------------------------------------------------------------------
# Application Configuration
#------------------------------------------------------------------------------

variable "app_port" {
  description = "Application server port"
  type        = number
  default     = 8080
}
