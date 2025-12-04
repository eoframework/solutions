#------------------------------------------------------------------------------
# Acr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:35
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

acr = {
  geo_replication = false  # Enable geo-replication
  name_suffix = "001"  # Container Registry name suffix
  sku = "Standard"  # Container Registry pricing tier
  vulnerability_scan = false  # Enable container vulnerability scanning
}
