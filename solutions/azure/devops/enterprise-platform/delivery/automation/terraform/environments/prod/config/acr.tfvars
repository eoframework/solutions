#------------------------------------------------------------------------------
# Acr Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:33
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

acr = {
  geo_replication = true  # Enable geo-replication
  name_suffix = "001"  # Container Registry name suffix
  sku = "Premium"  # Container Registry pricing tier
  vulnerability_scan = true  # Enable container vulnerability scanning
}
