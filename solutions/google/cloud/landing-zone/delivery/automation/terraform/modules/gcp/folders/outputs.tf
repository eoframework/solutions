#------------------------------------------------------------------------------
# GCP Folders Module Outputs
#------------------------------------------------------------------------------

output "development_folder_id" {
  description = "Development folder ID"
  value       = google_folder.development.folder_id
}

output "development_folder_name" {
  description = "Development folder resource name"
  value       = google_folder.development.name
}

output "staging_folder_id" {
  description = "Staging folder ID"
  value       = google_folder.staging.folder_id
}

output "staging_folder_name" {
  description = "Staging folder resource name"
  value       = google_folder.staging.name
}

output "production_folder_id" {
  description = "Production folder ID"
  value       = google_folder.production.folder_id
}

output "production_folder_name" {
  description = "Production folder resource name"
  value       = google_folder.production.name
}

output "shared_services_folder_id" {
  description = "Shared services folder ID"
  value       = google_folder.shared_services.folder_id
}

output "shared_services_folder_name" {
  description = "Shared services folder resource name"
  value       = google_folder.shared_services.name
}

output "sandbox_folder_id" {
  description = "Sandbox folder ID (if created)"
  value       = var.create_sandbox_folder ? google_folder.sandbox[0].folder_id : null
}

output "folder_ids" {
  description = "Map of all folder IDs"
  value = {
    development     = google_folder.development.folder_id
    staging         = google_folder.staging.folder_id
    production      = google_folder.production.folder_id
    shared_services = google_folder.shared_services.folder_id
    sandbox         = var.create_sandbox_folder ? google_folder.sandbox[0].folder_id : null
  }
}
