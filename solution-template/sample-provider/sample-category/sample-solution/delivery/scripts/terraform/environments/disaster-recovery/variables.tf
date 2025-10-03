# Disaster Recovery Environment Variables
# Environment-specific variable definitions for disaster recovery

# Inherit all variables from root module
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile for disaster recovery"
  type        = string
  default     = "disaster-recovery"
}

variable "aws_region" {
  description = "AWS region for disaster recovery deployment (should be different from production)"
  type        = string
  default     = "us-west-2"
}

variable "azure_location" {
  description = "Azure location for disaster recovery deployment"
  type        = string
  default     = "West US 2"
}

variable "gcp_project_id" {
  description = "GCP project ID for disaster recovery"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for disaster recovery deployment"
  type        = string
  default     = "us-west1"
}

variable "enable_aws_resources" {
  description = "Enable AWS resources in disaster recovery"
  type        = bool
  default     = false
}

variable "enable_azure_resources" {
  description = "Enable Azure resources in disaster recovery"
  type        = bool
  default     = false
}

variable "enable_gcp_resources" {
  description = "Enable GCP resources in disaster recovery"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags for disaster recovery resources"
  type        = map(string)
  default     = {}
}

# Disaster Recovery Specific Variables
variable "recovery_time_objective" {
  description = "Recovery Time Objective (RTO) in hours"
  type        = string
  default     = "4h"
}

variable "recovery_point_objective" {
  description = "Recovery Point Objective (RPO) in hours"
  type        = string
  default     = "1h"
}