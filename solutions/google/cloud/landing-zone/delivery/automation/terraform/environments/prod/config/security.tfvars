#------------------------------------------------------------------------------
# Security Configuration - Production
#------------------------------------------------------------------------------
# Generated from configuration.csv Production column
#------------------------------------------------------------------------------

identity = {
  cloud_identity_license   = "Premium"
  saml_sso_enabled         = true
  idp_type                 = "Azure AD"
  mfa_enforcement          = "ENFORCED"
  admin_count              = 8
  directory_sync_enabled   = true
}

security = {
  scc_tier                   = "Premium"
  scc_asset_discovery        = true
  chronicle_enabled          = true
  chronicle_ingestion_volume = "100 GB/month"
  chronicle_retention        = "12 months"
  cloud_armor_enabled        = true
  cloud_ids_enabled          = true
  cloud_ids_endpoints        = 3
}

org_policy = {
  allowed_locations          = ["in:us-locations"]
  external_ip_policy         = "Deny all"
  sa_key_creation            = "Disabled"
  require_shielded_vm        = true
  disable_serial_port_access = true
  policy_count               = 50
}

kms = {
  keyring_name      = "landing-zone-keyring-prod"
  keyring_location  = "us"
  key_count         = 6
  key_rotation_days = 90
  key_algorithm     = "GOOGLE_SYMMETRIC_ENCRYPTION"
  protection_level  = "SOFTWARE"
}
