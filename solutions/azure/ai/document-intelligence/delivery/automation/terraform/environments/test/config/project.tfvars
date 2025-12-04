#------------------------------------------------------------------------------
# Project Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:50
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

azure = {
  dr_region = "westus2"  # DR region for failover
  region = "eastus"  # Primary Azure region for deployment
  subscription_id = "[SUBSCRIPTION_ID]"  # Azure subscription identifier
  tenant_id = "[TENANT_ID]"  # Azure AD tenant identifier
}

ownership = {
  cost_center = "CC-AI-001"  # Cost center for billing
  owner_email = "dev-team@company.com"  # Technical owner email
  project_code = "PRJ-DOCINTEL-2025"  # Project code for tracking
}

solution = {
  # Solution abbreviation for resource naming
  abbr = "docintel"
  category_name = "ai"  # Solution category
  name = "Azure Document Intelligence"  # Full solution name for tagging
  provider_name = "azure"  # Cloud provider name
}
