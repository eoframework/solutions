#------------------------------------------------------------------------------
# HashiCorp Vault Configuration
# Generated from configuration.csv - Test values
#------------------------------------------------------------------------------

vault = {
  enabled                = true
  namespace              = "admin"
  auto_unseal_enabled    = false
  aws_secrets_enabled    = true
  azure_secrets_enabled  = true
  gcp_secrets_enabled    = true
  credential_ttl_seconds = 7200
  node_count             = 1
}
