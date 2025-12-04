#------------------------------------------------------------------------------
# Appgroup Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

appgroup = {
  desktop_enabled = true  # Enable desktop application group
  desktop_name = "Full Desktop"  # Friendly name for desktop app group
  remoteapp_enabled = true  # Enable RemoteApp application group
}
