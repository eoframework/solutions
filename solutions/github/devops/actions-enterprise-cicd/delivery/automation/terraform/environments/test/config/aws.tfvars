#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Test - AWS Configuration
#------------------------------------------------------------------------------

aws = {
  account_id = "[aws-test-account-id]"
  region     = "us-east-1"
}

oidc = {
  provider_arn = "[oidc-test-arn]"
  role_deploy  = "github-actions-test-deploy"
}
