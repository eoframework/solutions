#------------------------------------------------------------------------------
# AAP Solution - Core Module Variables
#------------------------------------------------------------------------------

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
}

variable "solution" {
  description = "Solution metadata"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
  })
}

#------------------------------------------------------------------------------
# VPC Configuration
#------------------------------------------------------------------------------
variable "create_vpc" {
  description = "Create new VPC or use existing"
  type        = bool
  default     = true
}

variable "existing_vpc_id" {
  description = "Existing VPC ID (if create_vpc is false)"
  type        = string
  default     = null
}

variable "existing_private_subnet_ids" {
  description = "Existing private subnet IDs"
  type        = list(string)
  default     = []
}

variable "existing_public_subnet_ids" {
  description = "Existing public subnet IDs"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Network Configuration
#------------------------------------------------------------------------------
variable "network" {
  description = "Network configuration"
  type = object({
    vpc_cidr           = string
    public_subnets     = list(string)
    private_subnets    = list(string)
    availability_zones = list(string)
  })
}

#------------------------------------------------------------------------------
# Compute Configuration
#------------------------------------------------------------------------------
variable "compute" {
  description = "Compute resources configuration"
  type = object({
    ami_id                   = string
    key_name                 = string
    controller_count         = number
    controller_instance_type = string
    execution_count          = number
    execution_instance_type  = string
    hub_instance_type        = string
  })
}

#------------------------------------------------------------------------------
# Database Configuration
#------------------------------------------------------------------------------
variable "database" {
  description = "Database configuration"
  type = object({
    host           = string
    port           = number
    name           = string
    username       = string
    password       = string
    instance_class = string
    storage_gb     = number
    multi_az       = bool
  })
  sensitive = true
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
variable "security" {
  description = "Security configuration"
  type = object({
    allowed_cidrs       = list(string)
    kms_key_arn         = string
    acm_certificate_arn = string
  })
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------
variable "backup" {
  description = "Backup configuration"
  type = object({
    enabled        = bool
    retention_days = number
    s3_bucket      = string
  })
}

#------------------------------------------------------------------------------
# DR Configuration
#------------------------------------------------------------------------------
variable "dr" {
  description = "DR configuration"
  type = object({
    enabled               = bool
    strategy              = string
    rto_hours             = number
    rpo_hours             = number
    db_replication_enabled = bool
  })
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
