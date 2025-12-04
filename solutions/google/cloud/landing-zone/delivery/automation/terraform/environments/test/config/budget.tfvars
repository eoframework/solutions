#------------------------------------------------------------------------------
# Budget Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

budget = {
  alert_thresholds = "[80, 100]"  # TODO: Replace with actual value  # Budget alert threshold percentages
  currency = "USD"  # Budget currency
  enable_forecast_alerts = false  # Enable forecast-based alerts
  enabled = false  # Enable budget alerts
  forecast_threshold = 100  # Forecast alert threshold percentage
  monthly_amount = 5000  # Monthly budget limit (USD)
  notification_email = "finops@example.com"  # Budget notification email
}
