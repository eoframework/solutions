#------------------------------------------------------------------------------
# Security Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:49
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  admin_group_id = "[ADMIN_GROUP_ID]"  # Azure AD group for administrators
  enable_customer_managed_key = true  # Use customer-managed key for encryption
  reviewer_group_id = "[REVIEWER_GROUP_ID]"  # Azure AD group for reviewers
  user_group_id = "[USER_GROUP_ID]"  # Azure AD group for end users
}
