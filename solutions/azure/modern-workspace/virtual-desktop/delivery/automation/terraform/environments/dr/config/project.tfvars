#------------------------------------------------------------------------------
# Project Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

azure = {
  dr_region = "eastus"  # DR region for failover
  region = "westus2"  # Primary Azure region
  subscription_id = "[SUBSCRIPTION_ID]"  # Azure subscription identifier
  tenant_id = "[TENANT_ID]"  # Azure AD tenant identifier
}

ownership = {
  cost_center = "CC-WS-001"  # Cost center for billing
  owner_email = "workspace-team@company.com"  # Team email for ownership
  project_code = "PRJ-AVD-2025"  # Project tracking code
}

solution = {
  # Solution abbreviation for resource naming
  abbr = "avd"
  category_name = "modern-workspace"  # Solution category
  name = "Azure Virtual Desktop"  # Solution display name
  provider_name = "azure"  # Cloud provider name
}
