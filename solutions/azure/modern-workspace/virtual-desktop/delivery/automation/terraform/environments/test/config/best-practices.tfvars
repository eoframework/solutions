#------------------------------------------------------------------------------
# Best Practices Configuration - Test Environment
#------------------------------------------------------------------------------

backup = {
  enabled        = false
  retention_days = 7
}

budget = {
  enabled            = true
  monthly_amount     = 1000
  alert_thresholds   = [80, 100]
  notification_email = "dev-team@company.com"
}

policies = {
  enable_security_policies    = false
  enable_cost_policies        = true
  enable_operational_policies = false
}
