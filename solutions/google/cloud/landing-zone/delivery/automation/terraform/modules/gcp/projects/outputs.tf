#------------------------------------------------------------------------------
# GCP Projects Module - Outputs
#------------------------------------------------------------------------------

output "host_project_id" {
  description = "Shared VPC host project ID"
  value       = google_project.host.project_id
}

output "host_project_number" {
  description = "Shared VPC host project number"
  value       = google_project.host.number
}

output "logging_project_id" {
  description = "Logging project ID"
  value       = google_project.logging.project_id
}

output "security_project_id" {
  description = "Security project ID"
  value       = google_project.security.project_id
}

output "monitoring_project_id" {
  description = "Monitoring project ID"
  value       = google_project.monitoring.project_id
}

output "workload_project_ids" {
  description = "List of workload project IDs"
  value       = [for p in google_project.workload : p.project_id]
}

output "workload_project_numbers" {
  description = "Map of workload project IDs to project numbers"
  value       = { for p in google_project.workload : p.project_id => p.number }
}

output "all_project_ids" {
  description = "All project IDs created by this module"
  value = concat(
    [
      google_project.host.project_id,
      google_project.logging.project_id,
      google_project.security.project_id,
      google_project.monitoring.project_id,
    ],
    [for p in google_project.workload : p.project_id]
  )
}
