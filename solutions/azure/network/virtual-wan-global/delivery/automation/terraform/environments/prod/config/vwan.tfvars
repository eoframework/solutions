#------------------------------------------------------------------------------
# Vwan Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:36:44
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

vwan = {
  allow_branch_to_branch = true  # Allow branch to branch traffic
  create_custom_route_tables = false  # Create custom route tables for hubs
  enable_secondary_hub = true  # Enable secondary hub for multi-region
  hub_routing_preference = "ExpressRoute"  # Hub routing preference
  hub_sku = "Standard"  # Virtual Hub SKU
  office365_breakout = "Optimize"  # Office365 local breakout category
  primary_hub_prefix = "10.0.0.0/23"  # Address prefix for primary hub
  secondary_hub_prefix = "10.1.0.0/23"  # Address prefix for secondary hub
  type = "Standard"  # Virtual WAN type (Basic or Standard)
}
