#------------------------------------------------------------------------------
# Inventory Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

inventory = {
  dynamic_inventory_enabled = true  # Enable dynamic inventory sources
  managed_network_count = 100  # Number of managed network devices
  managed_server_count = 500  # Number of managed servers
  smart_inventory_enabled = true  # Enable smart inventories
}
