#------------------------------------------------------------------------------
# AAP Operations Module - Variables
#------------------------------------------------------------------------------

variable "solution_abbr" {
  description = "Solution abbreviation for naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "controller_instance_ids" {
  description = "List of controller EC2 instance IDs"
  type        = list(string)
  default     = []
}

variable "execution_instance_ids" {
  description = "List of execution EC2 instance IDs"
  type        = list(string)
  default     = []
}

variable "db_instance_identifier" {
  description = "RDS database instance identifier"
  type        = string
  default     = ""
}

variable "alb_arn" {
  description = "ALB ARN for monitoring"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = ""
}

variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    cloudwatch_alarms_enabled = bool
    create_sns_topic          = bool
    sns_topic_arn             = optional(string, "")
    alert_email               = optional(string, "")
    log_retention_days        = optional(number, 30)
  })
  default = {
    cloudwatch_alarms_enabled = true
    create_sns_topic          = true
  }
}

variable "backup" {
  description = "Backup configuration"
  type = object({
    enabled        = bool
    retention_days = optional(number, 30)
    s3_bucket      = optional(string, "")
    use_aws_backup = optional(bool, false)
  })
  default = {
    enabled = false
  }
}

variable "dr" {
  description = "Disaster recovery configuration"
  type = object({
    enabled               = bool
    strategy              = optional(string, "ACTIVE_PASSIVE")
    rto_hours             = optional(number, 4)
    rpo_hours             = optional(number, 1)
    db_replication_enabled = optional(bool, false)
  })
  default = {
    enabled = false
  }
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
