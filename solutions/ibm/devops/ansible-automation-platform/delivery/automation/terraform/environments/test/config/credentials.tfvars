#------------------------------------------------------------------------------
# Credentials Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

credentials = {
  cyberark_enabled = false  # Enable CyberArk integration
  vault_enabled = false  # Enable HashiCorp Vault integration
  vault_namespace = "aap-test"  # Vault namespace for secrets
  vault_url = "https://vault.example.com:8200"  # HashiCorp Vault server URL
}
