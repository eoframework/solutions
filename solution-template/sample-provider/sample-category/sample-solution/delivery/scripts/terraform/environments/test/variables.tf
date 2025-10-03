# Test Environment Variables
# Environment-specific variable definitions for testing

# Inherit all variables from root module
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile for test environment"
  type        = string
  default     = "test"
}

variable "aws_region" {
  description = "AWS region for test deployment (typically smaller regions)"
  type        = string
  default     = "us-east-2"
}

variable "azure_location" {
  description = "Azure location for test deployment"
  type        = string
  default     = "Central US"
}

variable "gcp_project_id" {
  description = "GCP project ID for testing"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for test deployment"
  type        = string
  default     = "us-central1"
}

variable "enable_aws_resources" {
  description = "Enable AWS resources in test environment"
  type        = bool
  default     = false
}

variable "enable_azure_resources" {
  description = "Enable Azure resources in test environment"
  type        = bool
  default     = false
}

variable "enable_gcp_resources" {
  description = "Enable GCP resources in test environment"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags for test resources"
  type        = map(string)
  default     = {}
}

# Test Environment Specific Variables
variable "max_runtime_hours" {
  description = "Maximum runtime for test resources before auto-shutdown"
  type        = string
  default     = "8h"
}

variable "instance_types" {
  description = "Instance types to use for test environment (smaller/cheaper)"
  type = object({
    aws   = string
    azure = string
    gcp   = string
  })
  default = {
    aws   = "t3.micro"
    azure = "Standard_B1s"
    gcp   = "e2-micro"
  }
}