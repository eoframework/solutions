#------------------------------------------------------------------------------
# GCP IAM Module - Outputs
#------------------------------------------------------------------------------

output "terraform_service_account_email" {
  description = "Email of the Terraform service account"
  value       = google_service_account.terraform.email
}

output "terraform_service_account_id" {
  description = "ID of the Terraform service account"
  value       = google_service_account.terraform.id
}

output "cicd_service_account_email" {
  description = "Email of the CI/CD service account"
  value       = google_service_account.ci_cd.email
}

output "monitoring_service_account_email" {
  description = "Email of the monitoring service account"
  value       = google_service_account.monitoring.email
}

output "custom_role_network_viewer" {
  description = "ID of the network viewer custom role"
  value       = google_organization_iam_custom_role.network_viewer.id
}

output "custom_role_security_reviewer" {
  description = "ID of the security reviewer custom role"
  value       = google_organization_iam_custom_role.security_reviewer.id
}

output "custom_role_project_creator" {
  description = "ID of the project creator custom role"
  value       = google_organization_iam_custom_role.project_creator.id
}

output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID"
  value       = var.enable_workload_identity ? google_iam_workload_identity_pool.main[0].workload_identity_pool_id : null
}

output "workload_identity_pool_name" {
  description = "Workload Identity Pool full name"
  value       = var.enable_workload_identity ? google_iam_workload_identity_pool.main[0].name : null
}
