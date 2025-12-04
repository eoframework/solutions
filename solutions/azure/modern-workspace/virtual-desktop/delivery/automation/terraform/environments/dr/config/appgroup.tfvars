#------------------------------------------------------------------------------
# Appgroup Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

appgroup = {
  desktop_enabled = true  # Enable desktop application group
  desktop_name = "DR Desktop"  # Friendly name for desktop app group
  remoteapp_enabled = true  # Enable RemoteApp application group
}
