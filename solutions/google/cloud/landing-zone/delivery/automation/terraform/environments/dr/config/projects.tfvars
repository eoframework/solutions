#------------------------------------------------------------------------------
# Projects Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

projects = {
  host_project_name = "host-vpc-dr"  # Shared VPC host project name
  initial_count = 5  # Initial projects to provision
  logging_project_name = "logging-dr"  # Centralized logging project name
  monitoring_project_name = "monitoring-dr"  # Cloud Monitoring project name
  security_project_name = "security-dr"  # Security services project name
  team_count = 3  # Number of application teams
}
