# Test Environment - Project Configuration
# Core project settings for test/development deployment

# Project Identity
project_name = "my-enterprise-project"

# Cloud Provider Authentication
aws_profile    = "test"
gcp_project_id = "my-gcp-project-test"

# Cloud Provider Regions (Test - typically smaller/cheaper regions)
aws_region     = "us-east-2"
azure_location = "Central US"
gcp_region     = "us-central1"

# Feature Flags - Enable cloud providers as needed (start with one for testing)
enable_aws_resources   = true
enable_azure_resources = false
enable_gcp_resources   = false

# Test-specific tags
additional_tags = {
  BusinessUnit    = "Engineering"
  CostCenter      = "DEV-001"
  Owner           = "dev-team@company.com"
  Purpose         = "Testing"
  AutoShutdown    = "Enabled"
  MaxRuntime      = "8h"
  DataClass       = "Internal"
  BackupPolicy    = "Weekly"
}

# Test environment specific settings
max_runtime_hours = "8h"

# Smaller instance types for cost optimization
instance_types = {
  aws   = "t3.micro"
  azure = "Standard_B1s"
  gcp   = "e2-micro"
}