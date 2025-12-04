#------------------------------------------------------------------------------
# AWS VPC Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# VPC Configuration
#------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
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

#------------------------------------------------------------------------------
# Subnet Configuration
#------------------------------------------------------------------------------
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# NAT Gateway Configuration
#------------------------------------------------------------------------------
variable "enable_nat_gateway" {
  description = "Enable NAT gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway (cost optimization)"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Database Configuration
#------------------------------------------------------------------------------
variable "create_db_subnet_group" {
  description = "Create DB subnet group"
  type        = bool
  default     = true
}

variable "create_database_sg" {
  description = "Create database security group"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Flow Logs Configuration
#------------------------------------------------------------------------------
variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Flow log retention in days"
  type        = number
  default     = 30
}

variable "flow_log_kms_key_arn" {
  description = "KMS key ARN for flow log encryption"
  type        = string
  default     = null
}
