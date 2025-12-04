#------------------------------------------------------------------------------
# GitHub Advanced Security - DR - Security Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

codeql = {
  enabled              = true
  languages            = "javascript,python,java,csharp,go"
  query_suites         = "security-extended"
  schedule             = "0 2 * * *"
  timeout_minutes      = 60
  ram_mb               = 4096
  threads              = 2
  custom_queries_repo  = "[org]/codeql-custom-queries"
  custom_queries_path  = "queries"
  custom_queries_count = 15
}

secret_scanning = {
  enabled                 = true
  push_protection_enabled = true
  custom_patterns_count   = 5
  bypass_workflow         = "require-approval"
  alert_threshold         = 0
}

dependabot = {
  enabled            = true
  security_updates   = true
  version_updates    = false
  schedule           = "daily"
  package_ecosystems = "npm,pip,maven,nuget,go"
}

branch_protection = {
  enabled                  = true
  require_codeql_pass      = true
  required_reviews         = 2
  require_codeowner_review = true
  dismiss_stale_reviews    = true
  require_linear_history   = true
  allow_force_pushes       = false
  allow_deletions          = false
}

sla = {
  critical_hours = 24
  high_hours     = 168
  medium_hours   = 720
  low_hours      = 2160
}

detection = {
  confidence_threshold     = 0.85
  accuracy_target          = 0.95
  false_positive_threshold = 0.10
}
