#------------------------------------------------------------------------------
# HashiCorp Vault Configuration
# Generated from configuration.csv - Production values
#------------------------------------------------------------------------------

vault = {
  enabled                = true
  namespace              = "admin"
  auto_unseal_enabled    = true
  aws_secrets_enabled    = true
  azure_secrets_enabled  = true
  gcp_secrets_enabled    = true
  credential_ttl_seconds = 3600
  node_count             = 3
}
