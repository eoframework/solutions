#------------------------------------------------------------------------------
# Org Policy Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

org_policy = {
  allowed_locations = ["in:us-locations"]  # Allowed resource locations
  disable_serial_port_access = false  # Disable serial port access
  external_ip_policy = "Deny all"  # VM external IP policy
  policy_count = 25  # Total organization policies enforced
  require_shielded_vm = true  # Require Shielded VM for all instances
  sa_key_creation = "Disabled"  # Service account key creation policy
}
