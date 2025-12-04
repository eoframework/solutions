#------------------------------------------------------------------------------
# Security Configuration - Test
#------------------------------------------------------------------------------
# Generated from configuration.csv Test column
# Minimal security for test environment
#------------------------------------------------------------------------------

identity = {
  cloud_identity_license   = "Free"
  saml_sso_enabled         = false
  idp_type                 = "Azure AD"
  mfa_enforcement          = "OPTIONAL"
  admin_count              = 4
  directory_sync_enabled   = false
}

security = {
  scc_tier                   = "Standard"
  scc_asset_discovery        = true
  chronicle_enabled          = false
  chronicle_ingestion_volume = "0"
  chronicle_retention        = "0"
  cloud_armor_enabled        = false
  cloud_ids_enabled          = false
  cloud_ids_endpoints        = 0
}

org_policy = {
  allowed_locations          = ["in:us-locations"]
  external_ip_policy         = "Deny all"
  sa_key_creation            = "Disabled"
  require_shielded_vm        = true
  disable_serial_port_access = false
  policy_count               = 25
}

kms = {
  keyring_name      = "landing-zone-keyring-test"
  keyring_location  = "us"
  key_count         = 2
  key_rotation_days = 90
  key_algorithm     = "GOOGLE_SYMMETRIC_ENCRYPTION"
  protection_level  = "SOFTWARE"
}
