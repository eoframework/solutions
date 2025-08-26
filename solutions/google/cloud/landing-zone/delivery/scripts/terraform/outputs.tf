output "project_id" {
  description = "The Google Cloud Project ID"
  value       = var.project_id
}

output "region" {
  description = "The default region"
  value       = var.region
}

# Folder Outputs
output "security_folder_id" {
  description = "Security folder ID"
  value       = var.create_folders ? google_folder.security[0].name : ""
}

output "shared_services_folder_id" {
  description = "Shared services folder ID"
  value       = var.create_folders ? google_folder.shared_services[0].name : ""
}

output "production_folder_id" {
  description = "Production folder ID"
  value       = var.create_folders ? google_folder.production[0].name : ""
}

output "non_production_folder_id" {
  description = "Non-production folder ID"
  value       = var.create_folders ? google_folder.non_production[0].name : ""
}

output "sandbox_folder_id" {
  description = "Sandbox folder ID"
  value       = var.create_folders ? google_folder.sandbox[0].name : ""
}

# Network Outputs
output "hub_vpc_id" {
  description = "Hub VPC network ID"
  value       = google_compute_network.hub_vpc.id
}

output "hub_vpc_name" {
  description = "Hub VPC network name"
  value       = google_compute_network.hub_vpc.name
}

output "hub_vpc_self_link" {
  description = "Hub VPC self link"
  value       = google_compute_network.hub_vpc.self_link
}

output "shared_services_vpc_id" {
  description = "Shared services VPC network ID"
  value       = google_compute_network.shared_services_vpc.id
}

output "shared_services_vpc_name" {
  description = "Shared services VPC network name"
  value       = google_compute_network.shared_services_vpc.name
}

output "production_spoke_vpc_ids" {
  description = "Production spoke VPC network IDs"
  value       = { for k, v in google_compute_network.production_spoke_vpcs : k => v.id }
}

output "production_spoke_vpc_names" {
  description = "Production spoke VPC network names"
  value       = { for k, v in google_compute_network.production_spoke_vpcs : k => v.name }
}

# Subnet Outputs
output "hub_subnet_ids" {
  description = "Hub VPC subnet IDs"
  value       = { for k, v in google_compute_subnetwork.hub_subnet : k => v.id }
}

output "hub_subnet_self_links" {
  description = "Hub VPC subnet self links"
  value       = { for k, v in google_compute_subnetwork.hub_subnet : k => v.self_link }
}

output "shared_services_subnet_ids" {
  description = "Shared services VPC subnet IDs"
  value       = { for k, v in google_compute_subnetwork.shared_services_subnet : k => v.id }
}

output "production_spoke_subnet_ids" {
  description = "Production spoke VPC subnet IDs"
  value       = { for k, v in google_compute_subnetwork.production_spoke_subnets : k => v.id }
}

# Router and NAT Outputs
output "hub_router_id" {
  description = "Hub Cloud Router ID"
  value       = google_compute_router.hub_router.id
}

output "hub_router_name" {
  description = "Hub Cloud Router name"
  value       = google_compute_router.hub_router.name
}

output "hub_nat_name" {
  description = "Hub Cloud NAT name"
  value       = google_compute_router_nat.hub_nat.name
}

# DNS Outputs
output "private_dns_zone_id" {
  description = "Private DNS zone ID"
  value       = var.enable_private_dns ? google_dns_managed_zone.private_zone[0].id : ""
}

output "private_dns_zone_name" {
  description = "Private DNS zone name"
  value       = var.enable_private_dns ? google_dns_managed_zone.private_zone[0].name : ""
}

output "private_dns_name_servers" {
  description = "Private DNS zone name servers"
  value       = var.enable_private_dns ? google_dns_managed_zone.private_zone[0].name_servers : []
}

# KMS Outputs
output "kms_keyring_id" {
  description = "KMS key ring ID"
  value       = google_kms_key_ring.landing_zone_keyring.id
}

output "kms_keyring_name" {
  description = "KMS key ring name"
  value       = google_kms_key_ring.landing_zone_keyring.name
}

output "compute_encryption_key_id" {
  description = "Compute encryption key ID"
  value       = google_kms_crypto_key.compute_key.id
}

output "storage_encryption_key_id" {
  description = "Storage encryption key ID"
  value       = google_kms_crypto_key.storage_key.id
}

# Security and Logging Outputs
output "security_logs_bucket_name" {
  description = "Security logs bucket name"
  value       = var.enable_security_logging ? google_storage_bucket.security_logs_bucket[0].name : ""
}

output "security_logs_bucket_url" {
  description = "Security logs bucket URL"
  value       = var.enable_security_logging ? google_storage_bucket.security_logs_bucket[0].url : ""
}

output "security_log_sink_id" {
  description = "Security log sink ID"
  value       = var.enable_security_logging ? google_logging_project_sink.security_sink[0].id : ""
}

output "security_log_sink_writer_identity" {
  description = "Security log sink writer identity"
  value       = var.enable_security_logging ? google_logging_project_sink.security_sink[0].writer_identity : ""
}

# Budget Outputs
output "budget_id" {
  description = "Budget ID"
  value       = var.enable_budget_alerts ? google_billing_budget.landing_zone_budget[0].name : ""
}

# Service Account Outputs
output "terraform_service_account" {
  description = "Terraform service account email"
  value       = "terraform-sa@${var.project_id}.iam.gserviceaccount.com"
}

# Network Peering Outputs
output "hub_to_shared_services_peering_name" {
  description = "Hub to shared services peering name"
  value       = google_compute_network_peering.hub_to_shared_services.name
}

output "hub_to_production_peering_names" {
  description = "Hub to production spoke peering names"
  value       = { for k, v in google_compute_network_peering.hub_to_production_spokes : k => v.name }
}

# Firewall Rules Outputs
output "hub_firewall_rules" {
  description = "Hub VPC firewall rule names"
  value = {
    allow_internal = google_compute_firewall.hub_allow_internal.name
    allow_ssh_iap  = google_compute_firewall.hub_allow_ssh_iap.name
    allow_rdp_iap  = google_compute_firewall.hub_allow_rdp_iap.name
  }
}

# Organization Policy Outputs
output "org_policies_enabled" {
  description = "Organization policies that are enabled"
  value = var.enable_org_policies ? {
    require_shielded_vm        = google_org_policy_policy.require_shielded_vm[0].name
    disable_serial_port_access = google_org_policy_policy.disable_serial_port_access[0].name
    require_os_login          = google_org_policy_policy.require_os_login[0].name
  } : {}
}

# API Services Outputs
output "enabled_apis" {
  description = "List of enabled API services"
  value       = local.project_services
}

# Summary Outputs
output "landing_zone_summary" {
  description = "Summary of deployed landing zone resources"
  value = {
    project_id                = var.project_id
    region                   = var.region
    environment              = var.environment
    network_prefix           = var.network_prefix
    hub_vpc                  = google_compute_network.hub_vpc.name
    shared_services_vpc      = google_compute_network.shared_services_vpc.name
    production_spokes        = keys(var.production_spokes)
    folders_created          = var.create_folders
    private_dns_enabled      = var.enable_private_dns
    security_logging_enabled = var.enable_security_logging
    budget_alerts_enabled    = var.enable_budget_alerts
    org_policies_enabled     = var.enable_org_policies
    kms_keyring             = google_kms_key_ring.landing_zone_keyring.name
  }
}

# Network CIDR Outputs
output "network_cidrs" {
  description = "Network CIDR blocks for reference"
  value = {
    hub_subnets             = { for k, v in var.hub_subnets : k => v.cidr }
    shared_services_subnets = { for k, v in var.shared_services_subnets : k => v.cidr }
    production_spokes       = { for k, v in var.production_spokes : k => v.cidr }
    internal_ip_range       = var.internal_ip_range
  }
}

# Resource URLs for reference
output "resource_urls" {
  description = "Important resource URLs for management"
  value = {
    cloud_console          = "https://console.cloud.google.com/home/dashboard?project=${var.project_id}"
    vpc_networks          = "https://console.cloud.google.com/networking/networks/list?project=${var.project_id}"
    iam_admin             = "https://console.cloud.google.com/iam-admin?project=${var.project_id}"
    security_center       = "https://console.cloud.google.com/security/command-center?project=${var.project_id}"
    cloud_monitoring      = "https://console.cloud.google.com/monitoring?project=${var.project_id}"
    cloud_logging         = "https://console.cloud.google.com/logs/query?project=${var.project_id}"
    cloud_kms             = "https://console.cloud.google.com/security/kms?project=${var.project_id}"
    billing               = var.billing_account_id != "" ? "https://console.cloud.google.com/billing/${var.billing_account_id}" : ""
  }
}