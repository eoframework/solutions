#------------------------------------------------------------------------------
# DR Web Application Core Module - Variables
#------------------------------------------------------------------------------

variable "project" {
  description = "Project configuration"
  type = object({
    name        = string
    environment = string
  })
}

variable "network" {
  description = "Network configuration"
  type = object({
    vpc_cidr           = string
    enable_nat_gateway = optional(bool, true)
    enable_flow_logs   = optional(bool, true)
  })
}

variable "compute" {
  description = "Compute configuration"
  type = object({
    instance_type              = optional(string, "t3.medium")
    ami_id                     = optional(string, "")
    asg_min_size               = optional(number, 2)
    asg_max_size               = optional(number, 10)
    asg_desired_capacity       = optional(number, 2)
    root_volume_size           = optional(number, 30)
    app_port                   = optional(number, 80)
    health_check_path          = optional(string, "/health")
    ssl_certificate_arn        = optional(string, "")
    instance_profile_arn       = optional(string, "")
    user_data_base64           = optional(string, "")
    enable_deletion_protection = optional(bool, true)
  })
  default = {}
}

variable "security" {
  description = "Security configuration from security module"
  type = object({
    alb_security_group_id = string
    app_security_group_id = string
    kms_key_arn           = string
  })
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
