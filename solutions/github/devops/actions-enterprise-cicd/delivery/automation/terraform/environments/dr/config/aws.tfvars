#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - DR - AWS Configuration
#------------------------------------------------------------------------------

aws = {
  account_id = "[aws-dr-account-id]"
  region     = "us-west-2"
}

oidc = {
  provider_arn = "[oidc-dr-arn]"
  role_deploy  = "github-actions-dr-deploy"
}
