# Production Environment - Project Configuration
# Core project settings for production deployment

# Project Identity
project_name = "my-enterprise-project"

# Cloud Provider Authentication
aws_profile    = "production"
gcp_project_id = "my-gcp-project-prod"

# Cloud Provider Regions (Primary)
aws_region     = "us-east-1"
azure_location = "East US"
gcp_region     = "us-central1"

# Feature Flags - Enable cloud providers as needed
enable_aws_resources   = true
enable_azure_resources = false
enable_gcp_resources   = false

# Production-specific tags
additional_tags = {
  BusinessUnit    = "Engineering"
  CostCenter      = "PROD-001"
  Owner           = "platform-team@company.com"
  SLA             = "99.9%"
  Compliance      = "SOX,GDPR,HIPAA"
  DataRetention   = "7years"
  MaintenanceWindow = "Sunday-2AM-4AM-EST"
}