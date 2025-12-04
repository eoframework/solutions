#------------------------------------------------------------------------------
# Credentials Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

credentials = {
  cyberark_enabled = false  # Enable CyberArk integration
  vault_enabled = true  # Enable HashiCorp Vault integration
  vault_namespace = "aap-prod"  # Vault namespace for secrets
  vault_url = "https://vault.example.com:8200"  # HashiCorp Vault server URL
}
