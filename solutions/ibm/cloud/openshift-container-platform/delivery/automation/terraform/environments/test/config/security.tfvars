#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:06
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  acs_enabled = false  # Enable Advanced Cluster Security
  image_scanning_enabled = true  # Enable container image scanning
  network_policies_enabled = true  # Enable network policies
  pod_security_admission = "baseline"  # Pod security admission level
}
