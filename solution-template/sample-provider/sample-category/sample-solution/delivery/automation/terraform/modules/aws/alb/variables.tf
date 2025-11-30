# Generic AWS ALB Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID for target group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for ALB"
  type        = list(string)
}

variable "target_port" {
  description = "Target port (from application configuration)"
  type        = number
}

#------------------------------------------------------------------------------
# ALB Configuration (grouped object)
#------------------------------------------------------------------------------

variable "alb" {
  description = "Application Load Balancer configuration"
  type = object({
    enabled                    = bool
    internal                   = bool
    enable_deletion_protection = bool
    # TLS/SSL Configuration
    certificate_arn            = optional(string, "")
    ssl_policy                 = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    # ALB Behavior Settings
    idle_timeout_seconds       = optional(number, 60)
    deregistration_delay       = optional(number, 300)
    drop_invalid_header_fields = optional(bool, true)
    # HTTP to HTTPS Redirect
    redirect_http_to_https     = optional(bool, true)
    redirect_status_code       = optional(string, "HTTP_301")
    # Health Check Configuration
    health_check_path          = string
    health_check_interval      = number
    health_check_timeout       = number
    healthy_threshold          = number
    unhealthy_threshold        = number
    health_check_matcher       = optional(string, "200-299")
  })
}
