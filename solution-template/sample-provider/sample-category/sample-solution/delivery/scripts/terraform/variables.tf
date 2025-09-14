# Sample Terraform Variables
# Define input variables for your solution

variable "resource_name" {
  description = "Name for the primary resource"
  type        = string
  default     = "sample-resource"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Add your variables here