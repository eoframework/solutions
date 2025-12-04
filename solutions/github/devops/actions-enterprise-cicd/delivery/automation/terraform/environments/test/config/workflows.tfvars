#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Test - Workflows Configuration
#------------------------------------------------------------------------------

workflows = {
  template_repo      = "[org]/.github"
  build_timeout      = 20
  artifact_retention = 7
  cache_key_prefix   = "[org]-test-cache"
}

governance = {
  branch_protection_enabled   = false
  environment_reviewers_count = 0
  environment_wait_timer      = 0
}

security = {
  enable_security_scanning = true
  enable_secret_scanning   = true
}
