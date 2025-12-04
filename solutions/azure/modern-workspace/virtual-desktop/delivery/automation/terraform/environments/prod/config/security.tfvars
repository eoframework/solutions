#------------------------------------------------------------------------------
# Security Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  admin_group_id = "[ADMIN_GROUP_ID]"  # Azure AD group for administrators
  enable_customer_managed_key = true  # Use customer-managed key for encryption
  user_group_id = "[USER_GROUP_ID]"  # Azure AD group for end users
}
