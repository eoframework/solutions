#------------------------------------------------------------------------------
# Hashicorp Vault Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:08
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

vault = {
  aws_path = "aws/creds/tfe-role"  # Vault path for AWS credentials
  aws_role = "tfe-aws-credentials"  # Vault role for AWS credentials
  enabled = true  # Enable HashiCorp Vault integration
}
