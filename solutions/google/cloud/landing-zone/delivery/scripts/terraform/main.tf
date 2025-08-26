# Google Cloud Landing Zone - Main Infrastructure
terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
  
  backend "gcs" {
    bucket = var.terraform_state_bucket
    prefix = "landing-zone/terraform/state"
  }
}

# Configure Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Local values for common configurations
locals {
  common_labels = merge(var.labels, {
    environment   = var.environment
    deployed_by   = "terraform"
    created_date  = formatdate("YYYY-MM-DD", timestamp())
  })
  
  project_services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "securitycenter.googleapis.com",
    "cloudasset.googleapis.com",
    "dns.googleapis.com",
    "cloudkms.googleapis.com",
    "billingbudgets.googleapis.com"
  ]
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  count   = length(local.project_services)
  project = var.project_id
  service = local.project_services[count.index]
  
  disable_dependent_services = false
  disable_on_destroy        = false
}

# Organization Folders Structure
resource "google_folder" "security" {
  count        = var.create_folders ? 1 : 0
  display_name = "Security"
  parent       = var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id
}

resource "google_folder" "shared_services" {
  count        = var.create_folders ? 1 : 0
  display_name = "Shared Services"
  parent       = var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id
}

resource "google_folder" "production" {
  count        = var.create_folders ? 1 : 0
  display_name = "Production"
  parent       = var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id
}

resource "google_folder" "non_production" {
  count        = var.create_folders ? 1 : 0
  display_name = "Non-Production"
  parent       = var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id
}

resource "google_folder" "sandbox" {
  count        = var.create_folders ? 1 : 0
  display_name = "Sandbox"
  parent       = var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id
}

# Hub VPC Network
resource "google_compute_network" "hub_vpc" {
  name                    = "${var.network_prefix}-hub-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  
  depends_on = [google_project_service.required_apis]
}

# Hub VPC Subnets
resource "google_compute_subnetwork" "hub_subnet" {
  for_each = var.hub_subnets
  
  name          = "${var.network_prefix}-hub-${each.key}"
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.hub_vpc.id
  
  secondary_ip_range = lookup(each.value, "secondary_ranges", [])
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

# Shared Services VPC
resource "google_compute_network" "shared_services_vpc" {
  name                    = "${var.network_prefix}-shared-services-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  
  depends_on = [google_project_service.required_apis]
}

# Shared Services Subnets
resource "google_compute_subnetwork" "shared_services_subnet" {
  for_each = var.shared_services_subnets
  
  name          = "${var.network_prefix}-shared-${each.key}"
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.shared_services_vpc.id
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

# Production Spoke VPCs
resource "google_compute_network" "production_spoke_vpcs" {
  for_each = var.production_spokes
  
  name                    = "${var.network_prefix}-prod-${each.key}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  
  depends_on = [google_project_service.required_apis]
}

resource "google_compute_subnetwork" "production_spoke_subnets" {
  for_each = var.production_spokes
  
  name          = "${var.network_prefix}-prod-${each.key}-subnet"
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.production_spoke_vpcs[each.key].id
  
  secondary_ip_range = lookup(each.value, "secondary_ranges", [])
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

# VPC Peering - Hub to Shared Services
resource "google_compute_network_peering" "hub_to_shared_services" {
  name         = "hub-to-shared-services"
  network      = google_compute_network.hub_vpc.id
  peer_network = google_compute_network.shared_services_vpc.id
  
  auto_create_routes = true
  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_network_peering" "shared_services_to_hub" {
  name         = "shared-services-to-hub"
  network      = google_compute_network.shared_services_vpc.id
  peer_network = google_compute_network.hub_vpc.id
  
  auto_create_routes = true
  import_custom_routes = true
  export_custom_routes = true
}

# VPC Peering - Hub to Production Spokes
resource "google_compute_network_peering" "hub_to_production_spokes" {
  for_each = var.production_spokes
  
  name         = "hub-to-prod-${each.key}"
  network      = google_compute_network.hub_vpc.id
  peer_network = google_compute_network.production_spoke_vpcs[each.key].id
  
  auto_create_routes = true
  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_network_peering" "production_spokes_to_hub" {
  for_each = var.production_spokes
  
  name         = "prod-${each.key}-to-hub"
  network      = google_compute_network.production_spoke_vpcs[each.key].id
  peer_network = google_compute_network.hub_vpc.id
  
  auto_create_routes = true
  import_custom_routes = true
  export_custom_routes = true
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "hub_router" {
  name    = "${var.network_prefix}-hub-router"
  region  = var.region
  network = google_compute_network.hub_vpc.id
}

# Cloud NAT
resource "google_compute_router_nat" "hub_nat" {
  name                               = "${var.network_prefix}-hub-nat"
  router                            = google_compute_router.hub_router.name
  region                            = google_compute_router.hub_router.region
  nat_ip_allocate_option           = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall Rules - Hub VPC
resource "google_compute_firewall" "hub_allow_internal" {
  name    = "${var.network_prefix}-hub-allow-internal"
  network = google_compute_network.hub_vpc.name
  
  allow {
    protocol = "tcp"
  }
  
  allow {
    protocol = "udp"
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.internal_ip_range]
  target_tags   = ["internal"]
}

resource "google_compute_firewall" "hub_allow_ssh_iap" {
  name    = "${var.network_prefix}-hub-allow-ssh-iap"
  network = google_compute_network.hub_vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "hub_allow_rdp_iap" {
  name    = "${var.network_prefix}-hub-allow-rdp-iap"
  network = google_compute_network.hub_vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["rdp"]
}

# Cloud DNS Private Zone
resource "google_dns_managed_zone" "private_zone" {
  count       = var.enable_private_dns ? 1 : 0
  name        = "${var.network_prefix}-private-zone"
  dns_name    = "${var.private_dns_domain}."
  description = "Private DNS zone for internal resources"
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
    networks {
      network_url = google_compute_network.shared_services_vpc.id
    }
    
    dynamic "networks" {
      for_each = google_compute_network.production_spoke_vpcs
      content {
        network_url = networks.value.id
      }
    }
  }
  
  labels = local.common_labels
}

# Cloud KMS Key Ring
resource "google_kms_key_ring" "landing_zone_keyring" {
  name     = "${var.network_prefix}-keyring"
  location = var.kms_location
  
  depends_on = [google_project_service.required_apis]
}

# Cloud KMS Keys
resource "google_kms_crypto_key" "compute_key" {
  name            = "compute-encryption-key"
  key_ring        = google_kms_key_ring.landing_zone_keyring.id
  rotation_period = "7776000s" # 90 days
  
  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
  
  labels = local.common_labels
}

resource "google_kms_crypto_key" "storage_key" {
  name            = "storage-encryption-key"
  key_ring        = google_kms_key_ring.landing_zone_keyring.id
  rotation_period = "7776000s" # 90 days
  
  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
  
  labels = local.common_labels
}

# Log Sink for Security Logs
resource "google_logging_project_sink" "security_sink" {
  count       = var.enable_security_logging ? 1 : 0
  name        = "${var.network_prefix}-security-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.security_logs_bucket[0].name}"
  
  filter = "logName:\"logs/cloudaudit.googleapis.com\" OR logName:\"logs/compute.googleapis.com\" OR logName:\"logs/container.googleapis.com\""
  
  unique_writer_identity = true
  
  depends_on = [google_project_service.required_apis]
}

# Security Logs Storage Bucket
resource "google_storage_bucket" "security_logs_bucket" {
  count         = var.enable_security_logging ? 1 : 0
  name          = "${var.project_id}-security-logs-${random_id.bucket_suffix.hex}"
  location      = var.logs_bucket_location
  force_destroy = false
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.security_logs_retention_days
    }
  }
  
  encryption {
    default_kms_key_name = google_kms_crypto_key.storage_key.id
  }
  
  labels = local.common_labels
}

# Random ID for bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# IAM Binding for Log Sink
resource "google_storage_bucket_iam_binding" "security_logs_writer" {
  count  = var.enable_security_logging ? 1 : 0
  bucket = google_storage_bucket.security_logs_bucket[0].name
  role   = "roles/storage.objectCreator"
  
  members = [
    google_logging_project_sink.security_sink[0].writer_identity,
  ]
}

# Budget Alert
resource "google_billing_budget" "landing_zone_budget" {
  count        = var.enable_budget_alerts ? 1 : 0
  billing_account = var.billing_account_id
  display_name    = "${var.network_prefix} Landing Zone Budget"
  
  budget_filter {
    projects = ["projects/${var.project_id}"]
  }
  
  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.monthly_budget_amount)
    }
  }
  
  threshold_rules {
    threshold_percent = 0.5
    spend_basis      = "CURRENT_SPEND"
  }
  
  threshold_rules {
    threshold_percent = 0.8
    spend_basis      = "CURRENT_SPEND"
  }
  
  threshold_rules {
    threshold_percent = 1.0
    spend_basis      = "CURRENT_SPEND"
  }
  
  all_updates_rule {
    monitoring_notification_channels = var.budget_notification_channels
  }
}

# Security Command Center Notification Config
resource "google_scc_notification_config" "landing_zone_notifications" {
  count          = var.enable_scc_notifications ? 1 : 0
  config_id      = "${var.network_prefix}-security-notifications"
  organization   = var.organization_id
  description    = "Security Command Center notifications for Landing Zone"
  pubsub_topic   = var.scc_notification_topic
  streaming_config {
    filter = "state=\"ACTIVE\""
  }
}

# Organization Policies
resource "google_org_policy_policy" "require_shielded_vm" {
  count  = var.enable_org_policies ? 1 : 0
  name   = "${var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id}/policies/compute.requireShieldedVm"
  parent = var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id
  
  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "disable_serial_port_access" {
  count  = var.enable_org_policies ? 1 : 0
  name   = "${var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id}/policies/compute.disableSerialPortAccess"
  parent = var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id
  
  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "require_os_login" {
  count  = var.enable_org_policies ? 1 : 0
  name   = "${var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id}/policies/compute.requireOsLogin"
  parent = var.organization_id != "" ? "organizations/${var.organization_id}" : var.parent_folder_id
  
  spec {
    rules {
      enforce = "TRUE"
    }
  }
}