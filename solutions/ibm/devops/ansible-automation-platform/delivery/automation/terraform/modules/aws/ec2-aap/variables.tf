#------------------------------------------------------------------------------
# AWS EC2 AAP Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for AAP nodes (RHEL 8/9)"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "controller_security_group_ids" {
  description = "Security group IDs for controller nodes"
  type        = list(string)
}

variable "execution_security_group_ids" {
  description = "Security group IDs for execution nodes"
  type        = list(string)
}

variable "hub_security_group_ids" {
  description = "Security group IDs for hub node"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN for EBS encryption"
  type        = string
  default     = null
}

# Controller configuration
variable "controller_count" {
  description = "Number of controller nodes"
  type        = number
  default     = 2
}

variable "controller_instance_type" {
  description = "Instance type for controller nodes"
  type        = string
  default     = "m5.2xlarge"
}

# Execution node configuration
variable "execution_count" {
  description = "Number of execution nodes"
  type        = number
  default     = 4
}

variable "execution_instance_type" {
  description = "Instance type for execution nodes"
  type        = string
  default     = "m5.2xlarge"
}

# Hub configuration
variable "create_hub" {
  description = "Create Private Automation Hub"
  type        = bool
  default     = true
}

variable "hub_instance_type" {
  description = "Instance type for hub node"
  type        = string
  default     = "m5.xlarge"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
