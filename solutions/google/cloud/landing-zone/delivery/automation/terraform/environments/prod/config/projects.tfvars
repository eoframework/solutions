#------------------------------------------------------------------------------
# Projects Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

projects = {
  host_project_name = "host-vpc-prod"  # Shared VPC host project name
  initial_count = 10  # Initial projects to provision
  logging_project_name = "logging-prod"  # Centralized logging project name
  monitoring_project_name = "monitoring-prod"  # Cloud Monitoring project name
  security_project_name = "security-prod"  # Security services project name
  team_count = 5  # Number of application teams
}
