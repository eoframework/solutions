# AWS Module Variables
# Variables specific to AWS provider resources

# Core Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

# Security Variables
variable "security_groups" {
  description = "Security group configurations"
  type = map(object({
    ingress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      source_sg_id    = optional(string)
      description     = string
    }))
  }))
  default = {}
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption"
  type        = bool
  default     = true
}

variable "kms_key_rotation" {
  description = "Enable KMS key rotation"
  type        = bool
  default     = true
}

# Compute Variables
variable "instances" {
  description = "EC2 instance configurations"
  type = map(object({
    instance_type = string
    ami_id        = string
    min_size      = number
    max_size      = number
    desired_size  = number
    key_name      = string
    user_data     = optional(string)
  }))
  default = {}
}

variable "rds_config" {
  description = "RDS database configuration"
  type = object({
    engine                  = string
    engine_version         = string
    instance_class         = string
    allocated_storage      = number
    backup_retention_period = number
    backup_window          = string
    maintenance_window     = string
    multi_az              = bool
    encrypted             = bool
  })
  default = {
    engine                  = "mysql"
    engine_version         = "8.0"
    instance_class         = "db.t3.micro"
    allocated_storage      = 20
    backup_retention_period = 7
    backup_window          = "03:00-04:00"
    maintenance_window     = "sun:04:00-sun:05:00"
    multi_az              = false
    encrypted             = true
  }
}

# Auto Scaling Variables
variable "enable_auto_scaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = true
}

variable "scaling_policies" {
  description = "Auto scaling policies configuration"
  type = object({
    scale_up_threshold   = number
    scale_down_threshold = number
    scale_up_cooldown    = number
    scale_down_cooldown  = number
  })
  default = {
    scale_up_threshold   = 70
    scale_down_threshold = 30
    scale_up_cooldown    = 300
    scale_down_cooldown  = 300
  }
}

# Load Balancer Variables
variable "enable_load_balancer" {
  description = "Enable load balancer"
  type        = bool
  default     = true
}

variable "load_balancer_type" {
  description = "Type of load balancer (application, network, classic)"
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application", "network", "classic"], var.load_balancer_type)
    error_message = "Load balancer type must be one of: application, network, classic."
  }
}

variable "health_check" {
  description = "Health check configuration"
  type = object({
    enabled             = bool
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
    path                = string
    port                = number
  })
  default = {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    port                = 80
  }
}