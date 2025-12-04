#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:39
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  admin_group_id = "[ADMIN_GROUP_ID]"  # Azure AD group for administrators
  keyvault_sku = "standard"  # Key Vault pricing tier
  user_group_id = "[USER_GROUP_ID]"  # Azure AD group for users
}
