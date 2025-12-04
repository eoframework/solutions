#------------------------------------------------------------------------------
# Identity Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

identity = {
  admin_count = 4  # Number of platform administrators
  cloud_identity_license = "Premium"  # Cloud Identity license tier
  directory_sync_enabled = true  # Enable directory sync (GCDS)
  idp_type = "Azure AD"  # Identity provider type
  mfa_enforcement = "ENFORCED"  # 2-step verification policy
  saml_sso_enabled = true  # Enable SAML SSO integration
}
