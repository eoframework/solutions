#------------------------------------------------------------------------------
# GCP Shared VPC Module Outputs
#------------------------------------------------------------------------------

output "network_id" {
  description = "Shared VPC network ID"
  value       = google_compute_network.shared_vpc.id
}

output "network_name" {
  description = "Shared VPC network name"
  value       = google_compute_network.shared_vpc.name
}

output "network_self_link" {
  description = "Shared VPC network self link"
  value       = google_compute_network.shared_vpc.self_link
}

output "subnet_development_id" {
  description = "Development subnet ID"
  value       = google_compute_subnetwork.development.id
}

output "subnet_development_name" {
  description = "Development subnet name"
  value       = google_compute_subnetwork.development.name
}

output "subnet_staging_id" {
  description = "Staging subnet ID"
  value       = google_compute_subnetwork.staging.id
}

output "subnet_staging_name" {
  description = "Staging subnet name"
  value       = google_compute_subnetwork.staging.name
}

output "subnet_production_id" {
  description = "Production subnet ID"
  value       = google_compute_subnetwork.production.id
}

output "subnet_production_name" {
  description = "Production subnet name"
  value       = google_compute_subnetwork.production.name
}

output "subnet_shared_services_id" {
  description = "Shared services subnet ID"
  value       = google_compute_subnetwork.shared_services.id
}

output "subnet_shared_services_name" {
  description = "Shared services subnet name"
  value       = google_compute_subnetwork.shared_services.name
}

output "router_name" {
  description = "Cloud Router name"
  value       = google_compute_router.main.name
}

output "router_id" {
  description = "Cloud Router ID"
  value       = google_compute_router.main.id
}

output "nat_name" {
  description = "Cloud NAT name"
  value       = var.nat.enabled ? google_compute_router_nat.main[0].name : null
}

output "subnet_ids" {
  description = "Map of all subnet IDs"
  value = {
    development     = google_compute_subnetwork.development.id
    staging         = google_compute_subnetwork.staging.id
    production      = google_compute_subnetwork.production.id
    shared_services = google_compute_subnetwork.shared_services.id
  }
}
