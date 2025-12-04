#------------------------------------------------------------------------------
# OpenShift Solution - Core Module Variables
#------------------------------------------------------------------------------

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

#------------------------------------------------------------------------------
# Cluster Configuration
#------------------------------------------------------------------------------
variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name             = string
    base_domain      = string
    version          = string
    install_type     = string
    platform         = string
    api_internal     = bool
    create_bootstrap = bool
  })
}

#------------------------------------------------------------------------------
# Compute Configuration
#------------------------------------------------------------------------------
variable "compute" {
  description = "Compute configuration"
  type = object({
    control_plane_count         = number
    control_plane_instance_type = string
    control_plane_cpu           = number
    control_plane_memory_gb     = number
    worker_count                = number
    worker_instance_type        = string
    worker_cpu                  = number
    worker_memory_gb            = number
    rhcos_ami                   = string
    key_name                    = string
  })
}

#------------------------------------------------------------------------------
# Network Configuration
#------------------------------------------------------------------------------
variable "network" {
  description = "Network configuration"
  type = object({
    type               = string
    vpc_cidr           = string
    pod_cidr           = string
    service_cidr       = string
    cluster_mtu        = number
    public_subnets     = list(string)
    private_subnets    = list(string)
    availability_zones = list(string)
  })
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
variable "security" {
  description = "Security configuration"
  type = object({
    allowed_api_cidrs           = list(string)
    kms_key_arn                 = string
    pod_security_admission      = string
    network_policies_enabled    = bool
    image_scanning_enabled      = bool
    acs_enabled                 = bool
  })
  default = {
    allowed_api_cidrs           = ["0.0.0.0/0"]
    kms_key_arn                 = null
    pod_security_admission      = "restricted"
    network_policies_enabled    = true
    image_scanning_enabled      = true
    acs_enabled                 = false
  }
}

#------------------------------------------------------------------------------
# DNS Configuration
#------------------------------------------------------------------------------
variable "dns" {
  description = "DNS configuration"
  type = object({
    create_hosted_zone = bool
    private_zone       = bool
  })
  default = {
    create_hosted_zone = false
    private_zone       = false
  }
}

#------------------------------------------------------------------------------
# Ignition Configurations
#------------------------------------------------------------------------------
variable "ignition" {
  description = "Ignition configurations for nodes"
  type = object({
    bootstrap = string
    master    = string
    worker    = string
  })
  default = {
    bootstrap = ""
    master    = ""
    worker    = ""
  }
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
