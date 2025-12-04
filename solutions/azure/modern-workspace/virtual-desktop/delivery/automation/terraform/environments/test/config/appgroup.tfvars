#------------------------------------------------------------------------------
# Appgroup Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

appgroup = {
  desktop_enabled = true  # Enable desktop application group
  desktop_name = "Test Desktop"  # Friendly name for desktop app group
  remoteapp_enabled = false  # Enable RemoteApp application group
}
