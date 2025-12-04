#------------------------------------------------------------------------------
# Project Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:35
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

azure = {
  dr_region = "westus2"  # DR region for failover
  region = "eastus"  # Primary Azure region
  subscription_id = "[SUBSCRIPTION_ID]"  # Azure subscription identifier
  tenant_id = "[TENANT_ID]"  # Azure AD tenant identifier
}

ownership = {
  cost_center = "CC-DEV-001"  # Cost center for billing
  owner_email = "dev-team@company.com"  # Team email for ownership
  project_code = "PRJ-DEVOPS-2025"  # Project tracking code
}

solution = {
  # Solution abbreviation for resource naming
  abbr = "devops"
  category_name = "devops"  # Solution category
  name = "Azure DevOps Enterprise Platform"  # Solution display name
  provider_name = "azure"  # Cloud provider name
}
