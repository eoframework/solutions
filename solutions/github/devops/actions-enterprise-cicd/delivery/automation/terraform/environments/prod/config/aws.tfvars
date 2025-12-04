#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Production - AWS Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

aws = {
  account_id = "[aws-prod-account-id]"
  region     = "us-east-1"
}

oidc = {
  provider_arn = "[oidc-prod-arn]"
  role_deploy  = "github-actions-prod-deploy"
}
