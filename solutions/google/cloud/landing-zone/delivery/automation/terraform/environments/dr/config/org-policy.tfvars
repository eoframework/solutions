#------------------------------------------------------------------------------
# Org Policy Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

org_policy = {
  allowed_locations = ["in:us-locations"]  # Allowed resource locations
  disable_serial_port_access = true  # Disable serial port access
  external_ip_policy = "Deny all"  # VM external IP policy
  policy_count = 50  # Total organization policies enforced
  require_shielded_vm = true  # Require Shielded VM for all instances
  sa_key_creation = "Disabled"  # Service account key creation policy
}
