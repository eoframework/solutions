#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  acs_enabled = true  # Enable Advanced Cluster Security
  image_scanning_enabled = true  # Enable container image scanning
  network_policies_enabled = true  # Enable network policies
  pod_security_admission = "restricted"  # Pod security admission level
}
