#------------------------------------------------------------------------------
# GCP Budgets Module
#------------------------------------------------------------------------------
# Creates billing budget alerts for cost management
# Well-Architected Framework: Cost Optimization
#------------------------------------------------------------------------------

resource "google_billing_budget" "main" {
  count = var.budget.enabled ? 1 : 0

  billing_account = var.billing_account_id
  display_name    = "${var.name_prefix}-budget"

  budget_filter {
    projects = var.project_ids
  }

  amount {
    specified_amount {
      currency_code = var.budget.currency
      units         = tostring(var.budget.monthly_amount)
    }
  }

  dynamic "threshold_rules" {
    for_each = var.budget.alert_thresholds
    content {
      threshold_percent = threshold_rules.value / 100
      spend_basis       = "CURRENT_SPEND"
    }
  }

  # Forecasted spend alerts
  dynamic "threshold_rules" {
    for_each = var.budget.enable_forecast_alerts ? [var.budget.forecast_threshold] : []
    content {
      threshold_percent = threshold_rules.value / 100
      spend_basis       = "FORECASTED_SPEND"
    }
  }

  all_updates_rule {
    monitoring_notification_channels = var.notification_channels
    disable_default_iam_recipients   = false
  }
}
