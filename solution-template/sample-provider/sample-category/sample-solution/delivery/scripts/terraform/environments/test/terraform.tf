# Test Environment - Terraform Configuration
# Terraform version requirements and backend configuration

terraform {
  # Backend configuration for test state (can use local backend for development)
  # Uncomment for remote state storage
  # backend "s3" {
  #   # Configuration will be provided via backend config file
  #   # See ../../scripts/init-backend-aws.sh for setup
  # }

  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}