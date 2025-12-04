#------------------------------------------------------------------------------
# Best Practices Module - Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Budget Outputs
#------------------------------------------------------------------------------
output "budget_id" {
  description = "Budget ID"
  value       = length(module.budgets) > 0 ? module.budgets[0].budget_id : null
}

output "budget_name" {
  description = "Budget display name"
  value       = length(module.budgets) > 0 ? module.budgets[0].budget_name : null
}

#------------------------------------------------------------------------------
# Security Command Center Outputs
#------------------------------------------------------------------------------
output "scc_critical_findings_module_id" {
  description = "SCC critical findings custom module ID"
  value       = length(module.scc) > 0 ? module.scc[0].critical_findings_module_id : null
}

output "scc_notification_config_id" {
  description = "SCC notification config ID"
  value       = length(module.scc) > 0 ? module.scc[0].notification_config_id : null
}

#------------------------------------------------------------------------------
# Cloud Armor Outputs
#------------------------------------------------------------------------------
output "cloud_armor_policy_id" {
  description = "Cloud Armor security policy ID"
  value       = length(module.cloud_armor) > 0 ? module.cloud_armor[0].policy_id : null
}

output "cloud_armor_policy_self_link" {
  description = "Cloud Armor security policy self link"
  value       = length(module.cloud_armor) > 0 ? module.cloud_armor[0].policy_self_link : null
}

#------------------------------------------------------------------------------
# DR Replication Outputs
#------------------------------------------------------------------------------
output "dr_replication_bucket_name" {
  description = "DR replication bucket name"
  value       = length(module.dr_replication) > 0 ? module.dr_replication[0].replication_bucket_name : null
}

output "dr_health_check_id" {
  description = "DR failover health check ID"
  value       = length(module.dr_replication) > 0 ? module.dr_replication[0].health_check_id : null
}

output "dr_kms_key_id" {
  description = "DR KMS crypto key ID"
  value       = length(module.dr_replication) > 0 ? module.dr_replication[0].dr_kms_key_id : null
}

#------------------------------------------------------------------------------
# Summary Output
#------------------------------------------------------------------------------
output "best_practices_summary" {
  description = "Summary of best practices resources created"
  value = {
    cost_optimization = {
      budget_enabled = length(module.budgets) > 0
      budget_id      = length(module.budgets) > 0 ? module.budgets[0].budget_id : null
    }
    security = {
      scc_enabled         = length(module.scc) > 0
      cloud_armor_enabled = length(module.cloud_armor) > 0
    }
    reliability = {
      dr_enabled              = length(module.dr_replication) > 0
      replication_bucket_name = length(module.dr_replication) > 0 ? module.dr_replication[0].replication_bucket_name : null
    }
  }
}
