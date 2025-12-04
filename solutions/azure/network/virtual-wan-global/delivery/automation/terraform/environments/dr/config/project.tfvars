#------------------------------------------------------------------------------
# Project Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:36:45
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

azure = {
  region = "westus2"  # Primary Azure region for deployment
  # Secondary region for multi-region deployment
  secondary_region = "eastus"
  subscription_id = "[SUBSCRIPTION_ID]"  # Azure subscription identifier
  tenant_id = "[TENANT_ID]"  # Azure AD tenant identifier
}

ownership = {
  cost_center = "CC-NET-001"  # Cost center for billing
  owner_email = "network-team@company.com"  # Team email for ownership
  project_code = "PRJ-VWAN-2025"  # Project tracking code
}

solution = {
  # Solution abbreviation for resource naming
  abbr = "vwan-global"
  category_name = "network"  # Solution category
  name = "Azure Virtual WAN Global"  # Solution display name for tagging
  provider_name = "azure"  # Cloud provider name
}
