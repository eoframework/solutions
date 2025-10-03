# Disaster Recovery Environment - Project Configuration
# Core project settings for disaster recovery deployment

# Project Identity
project_name = "my-enterprise-project"

# Cloud Provider Authentication
aws_profile    = "disaster-recovery"
gcp_project_id = "my-gcp-project-dr"

# Cloud Provider Regions (DR - different regions from production)
aws_region     = "us-west-2"
azure_location = "West US 2"
gcp_region     = "us-west1"

# Feature Flags - Enable cloud providers as needed
enable_aws_resources   = true
enable_azure_resources = false
enable_gcp_resources   = false

# Disaster Recovery specific tags
additional_tags = {
  BusinessUnit    = "Engineering"
  CostCenter      = "DR-001"
  Owner           = "platform-team@company.com"
  Purpose         = "DisasterRecovery"
  SLA             = "99.9%"
  Compliance      = "SOX,GDPR,HIPAA"
  DataRetention   = "7years"
  BackupPolicy    = "Continuous"
  MaintenanceWindow = "Sunday-2AM-4AM-PST"
}

# Disaster Recovery specific settings
recovery_time_objective  = "4h"  # Maximum acceptable downtime
recovery_point_objective = "1h"  # Maximum acceptable data loss