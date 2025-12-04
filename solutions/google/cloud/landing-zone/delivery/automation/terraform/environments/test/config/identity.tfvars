#------------------------------------------------------------------------------
# Identity Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

identity = {
  admin_count = 4  # Number of platform administrators
  cloud_identity_license = "Free"  # Cloud Identity license tier
  directory_sync_enabled = false  # Enable directory sync (GCDS)
  idp_type = "Azure AD"  # Identity provider type
  mfa_enforcement = "OPTIONAL"  # 2-step verification policy
  saml_sso_enabled = false  # Enable SAML SSO integration
}
