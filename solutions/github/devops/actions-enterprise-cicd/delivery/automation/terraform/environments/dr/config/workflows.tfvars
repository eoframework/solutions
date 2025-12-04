#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - DR - Workflows Configuration
#------------------------------------------------------------------------------

workflows = {
  template_repo      = "[org]/.github"
  build_timeout      = 30
  artifact_retention = 30
  cache_key_prefix   = "[org]-dr-cache"
}

governance = {
  branch_protection_enabled   = true
  environment_reviewers_count = 2
  environment_wait_timer      = 0
}

security = {
  enable_security_scanning = true
  enable_secret_scanning   = true
}
