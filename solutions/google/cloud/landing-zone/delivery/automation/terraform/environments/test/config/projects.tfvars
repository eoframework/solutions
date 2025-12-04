#------------------------------------------------------------------------------
# Projects Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

projects = {
  host_project_name = "host-vpc-test"  # Shared VPC host project name
  initial_count = 5  # Initial projects to provision
  logging_project_name = "logging-test"  # Centralized logging project name
  monitoring_project_name = "monitoring-test"  # Cloud Monitoring project name
  security_project_name = "security-test"  # Security services project name
  team_count = 3  # Number of application teams
}
