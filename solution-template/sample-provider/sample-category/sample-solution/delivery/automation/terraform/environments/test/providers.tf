# Test Environment - Terraform & Provider Configuration
#
# This file configures:
# - Terraform version and required providers
# - S3 backend for remote state (team collaboration)
# - AWS provider with authentication options
#
# Prerequisites:
# - AWS CLI installed and configured
# - S3 bucket and DynamoDB table for state (see README.md)
# - Either: AWS profile configured, OR environment variables set

terraform {
  required_version = ">= 1.6.0"

  # Remote state storage in S3
  # Configure via: terraform init -backend-config=backend.hcl
  # Or set values directly below for single-team use
  backend "s3" {
    # Required - configure these for your environment:
    # bucket         = "mycompany-terraform-state"
    # key            = "solutions/sample-solution/test/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-locks"
    # encrypt        = true
    #
    # Optional - if using AWS profiles:
    # profile        = "mycompany-test"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# AWS Provider Configuration
#
# Authentication options (in order of precedence):
# 1. Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
# 2. Shared credentials file with profile: ~/.aws/credentials
# 3. IAM role (when running on EC2/ECS/Lambda)
#
# For local development, set aws_profile in main.tfvars
# For CI/CD pipelines, use environment variables or IAM roles

provider "aws" {
  region = var.aws_region

  # Optional: Use named profile from ~/.aws/credentials
  # Leave empty/null to use default credential chain
  profile = var.aws_profile != "" ? var.aws_profile : null

  # Common tags applied to ALL resources automatically
  # These are populated from main.tfvars via locals
  default_tags {
    tags = local.common_tags
  }
}
