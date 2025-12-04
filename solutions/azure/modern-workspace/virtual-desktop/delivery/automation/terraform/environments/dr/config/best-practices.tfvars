#------------------------------------------------------------------------------
# Best Practices Configuration - DR Environment
#------------------------------------------------------------------------------

backup = {
  enabled        = true
  retention_days = 30
}

budget = {
  enabled            = true
  monthly_amount     = 3000
  alert_thresholds   = [50, 80, 100]
  notification_email = "finance@company.com"
}

policies = {
  enable_security_policies    = true
  enable_cost_policies        = true
  enable_operational_policies = true
}
