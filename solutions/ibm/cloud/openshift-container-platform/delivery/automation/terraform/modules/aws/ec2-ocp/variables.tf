#------------------------------------------------------------------------------
# AWS EC2 OCP Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cluster_name" {
  description = "OpenShift cluster name"
  type        = string
}

variable "rhcos_ami" {
  description = "Red Hat CoreOS AMI ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for nodes"
  type        = list(string)
}

variable "control_plane_security_group_ids" {
  description = "Security group IDs for control plane"
  type        = list(string)
}

variable "worker_security_group_ids" {
  description = "Security group IDs for worker nodes"
  type        = list(string)
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

# Bootstrap configuration
variable "create_bootstrap" {
  description = "Create bootstrap node (for initial cluster setup)"
  type        = bool
  default     = false
}

variable "bootstrap_instance_type" {
  description = "Instance type for bootstrap node"
  type        = string
  default     = "m5.xlarge"
}

variable "bootstrap_ignition_config" {
  description = "Ignition config for bootstrap node"
  type        = string
  default     = ""
}

# Control plane configuration
variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3
}

variable "control_plane_instance_type" {
  description = "Instance type for control plane nodes"
  type        = string
  default     = "m5.2xlarge"
}

variable "master_ignition_config" {
  description = "Ignition config for master nodes"
  type        = string
  default     = ""
}

# Worker configuration
variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "m5.4xlarge"
}

variable "worker_ignition_config" {
  description = "Ignition config for worker nodes"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
