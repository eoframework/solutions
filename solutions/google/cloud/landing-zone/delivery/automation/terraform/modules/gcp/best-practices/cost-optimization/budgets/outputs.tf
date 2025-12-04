#------------------------------------------------------------------------------
# GCP Budgets Module - Outputs
#------------------------------------------------------------------------------

output "budget_id" {
  description = "Budget ID"
  value       = length(google_billing_budget.main) > 0 ? google_billing_budget.main[0].id : null
}

output "budget_name" {
  description = "Budget display name"
  value       = length(google_billing_budget.main) > 0 ? google_billing_budget.main[0].display_name : null
}
