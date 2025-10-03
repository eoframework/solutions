# Production Environment Variables
# Environment-specific variable definitions for production

# Inherit all variables from root module
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile for production"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region for production deployment"
  type        = string
  default     = "us-east-1"
}

variable "azure_location" {
  description = "Azure location for production deployment"
  type        = string
  default     = "East US"
}

variable "gcp_project_id" {
  description = "GCP project ID for production"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for production deployment"
  type        = string
  default     = "us-central1"
}

variable "enable_aws_resources" {
  description = "Enable AWS resources in production"
  type        = bool
  default     = false
}

variable "enable_azure_resources" {
  description = "Enable Azure resources in production"
  type        = bool
  default     = false
}

variable "enable_gcp_resources" {
  description = "Enable GCP resources in production"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags for production resources"
  type        = map(string)
  default     = {}
}