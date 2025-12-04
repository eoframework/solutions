#------------------------------------------------------------------------------
# GitHub Advanced Security - Test - Security Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

codeql = {
  enabled              = true
  languages            = "javascript,python"
  query_suites         = "security-extended"
  schedule             = "0 3 * * *"
  timeout_minutes      = 45
  ram_mb               = 2048
  threads              = 2
  custom_queries_repo  = "[org]/codeql-test-queries"
  custom_queries_path  = "queries"
  custom_queries_count = 5
}

secret_scanning = {
  enabled                 = true
  push_protection_enabled = false
  custom_patterns_count   = 2
  bypass_workflow         = "self-approve"
  alert_threshold         = 5
}

dependabot = {
  enabled            = true
  security_updates   = true
  version_updates    = false
  schedule           = "weekly"
  package_ecosystems = "npm,pip"
}

branch_protection = {
  enabled                  = false
  require_codeql_pass      = false
  required_reviews         = 1
  require_codeowner_review = false
  dismiss_stale_reviews    = true
  require_linear_history   = false
  allow_force_pushes       = false
  allow_deletions          = false
}

sla = {
  critical_hours = 48
  high_hours     = 336
  medium_hours   = 1440
  low_hours      = 4320
}

detection = {
  confidence_threshold     = 0.80
  accuracy_target          = 0.90
  false_positive_threshold = 0.15
}
