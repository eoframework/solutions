#------------------------------------------------------------------------------
# OpenShift Solution - Operations Module Variables
#------------------------------------------------------------------------------

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
}

variable "cluster_name" {
  description = "OpenShift cluster name"
  type        = string
}

#------------------------------------------------------------------------------
# Instance IDs (from core module)
#------------------------------------------------------------------------------
variable "control_plane_instance_ids" {
  description = "Control plane instance IDs"
  type        = list(string)
  default     = []
}

variable "worker_instance_ids" {
  description = "Worker instance IDs"
  type        = list(string)
  default     = []
}

variable "api_lb_arn" {
  description = "API load balancer ARN"
  type        = string
  default     = null
}

variable "api_target_group_arn" {
  description = "API target group ARN"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------
variable "backup" {
  description = "Backup configuration"
  type = object({
    enabled        = bool
    schedule_cron  = string
    retention_days = number
    s3_bucket      = string
  })
  default = {
    enabled        = false
    schedule_cron  = "0 2 * * *"
    retention_days = 30
    s3_bucket      = ""
  }
}

#------------------------------------------------------------------------------
# DR Configuration
#------------------------------------------------------------------------------
variable "dr" {
  description = "DR configuration"
  type = object({
    enabled             = bool
    strategy            = string
    rto_hours           = number
    rpo_hours           = number
    replication_enabled = bool
  })
  default = {
    enabled             = false
    strategy            = "BACKUP_ONLY"
    rto_hours           = 4
    rpo_hours           = 1
    replication_enabled = false
  }
}

#------------------------------------------------------------------------------
# Monitoring Configuration
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    cloudwatch_alarms_enabled = bool
    create_sns_topic          = bool
    sns_topic_arn             = string
    alert_email               = string
  })
  default = {
    cloudwatch_alarms_enabled = true
    create_sns_topic          = false
    sns_topic_arn             = null
    alert_email               = null
  }
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
variable "security" {
  description = "Security configuration"
  type = object({
    kms_key_arn = string
  })
  default = {
    kms_key_arn = null
  }
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
