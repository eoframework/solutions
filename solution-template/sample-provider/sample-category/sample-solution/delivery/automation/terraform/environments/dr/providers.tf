# DR Environment - Terraform & Provider Configuration
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
#
# Note: DR environment typically deploys to a different region than prod

terraform {
  required_version = ">= 1.6.0"

  # Remote state storage in S3
  #
  # SETUP: Run bootstrap script to create S3 bucket and DynamoDB table:
  #   ../setup/setup-backend.sh dr
  #   OR
  #   python ../setup/setup-backend.py dr
  #
  # This creates backend.tfvars, then initialize with:
  #   terraform init -backend-config=backend.tfvars
  #
  # Naming Convention:
  #   S3 Bucket:      {org_prefix}-{solution_abbr}-dr-terraform-state
  #   DynamoDB Table: {org_prefix}-{solution_abbr}-dr-terraform-locks
  #   State Key:      terraform.tfstate
  #
  # Note: DR state bucket is created in DR region (us-west-2) for resilience
  #
  backend "s3" {
    # Backend values loaded from backend.tfvars via -backend-config flag
    # See setup/README.md for setup instructions
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
