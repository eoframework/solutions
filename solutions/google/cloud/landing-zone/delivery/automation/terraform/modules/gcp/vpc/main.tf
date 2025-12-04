#------------------------------------------------------------------------------
# GCP Shared VPC Module
#------------------------------------------------------------------------------
# Creates Shared VPC hub-spoke network architecture
# Implements subnets, Cloud NAT, and Cloud Router
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Shared VPC Network
#------------------------------------------------------------------------------
resource "google_compute_network" "shared_vpc" {
  name                            = var.network.vpc_name
  project                         = var.host_project_id
  auto_create_subnetworks         = false
  routing_mode                    = var.network.vpc_routing_mode
  delete_default_routes_on_create = var.delete_default_routes
}

#------------------------------------------------------------------------------
# Subnets
#------------------------------------------------------------------------------
resource "google_compute_subnetwork" "development" {
  name                     = "${var.network.vpc_name}-dev-${var.region}"
  project                  = var.host_project_id
  network                  = google_compute_network.shared_vpc.id
  region                   = var.region
  ip_cidr_range            = var.network.subnet_dev_cidr
  private_ip_google_access = var.network.enable_private_google_access

  dynamic "log_config" {
    for_each = var.network.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.network.flow_log_aggregation_interval
      flow_sampling        = var.network.flow_log_sampling
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_subnetwork" "staging" {
  name                     = "${var.network.vpc_name}-staging-${var.region}"
  project                  = var.host_project_id
  network                  = google_compute_network.shared_vpc.id
  region                   = var.region
  ip_cidr_range            = var.network.subnet_staging_cidr
  private_ip_google_access = var.network.enable_private_google_access

  dynamic "log_config" {
    for_each = var.network.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.network.flow_log_aggregation_interval
      flow_sampling        = var.network.flow_log_sampling
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_subnetwork" "production" {
  name                     = "${var.network.vpc_name}-prod-${var.region}"
  project                  = var.host_project_id
  network                  = google_compute_network.shared_vpc.id
  region                   = var.region
  ip_cidr_range            = var.network.subnet_prod_cidr
  private_ip_google_access = var.network.enable_private_google_access

  dynamic "log_config" {
    for_each = var.network.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.network.flow_log_aggregation_interval
      flow_sampling        = var.network.flow_log_sampling
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_subnetwork" "shared_services" {
  name                     = "${var.network.vpc_name}-shared-${var.region}"
  project                  = var.host_project_id
  network                  = google_compute_network.shared_vpc.id
  region                   = var.region
  ip_cidr_range            = var.network.subnet_shared_cidr
  private_ip_google_access = var.network.enable_private_google_access

  dynamic "log_config" {
    for_each = var.network.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.network.flow_log_aggregation_interval
      flow_sampling        = var.network.flow_log_sampling
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

#------------------------------------------------------------------------------
# Cloud Router (for Cloud NAT and Interconnect)
#------------------------------------------------------------------------------
resource "google_compute_router" "main" {
  name    = "${var.network.vpc_name}-router-${var.region}"
  project = var.host_project_id
  network = google_compute_network.shared_vpc.id
  region  = var.region

  bgp {
    asn               = var.nat.cloud_router_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

#------------------------------------------------------------------------------
# Cloud NAT
#------------------------------------------------------------------------------
resource "google_compute_router_nat" "main" {
  count = var.nat.enabled ? 1 : 0

  name                               = "${var.network.vpc_name}-nat-${var.region}"
  project                            = var.host_project_id
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  min_ports_per_vm = var.nat.min_ports_per_vm

  log_config {
    enable = var.nat.logging_enabled
    filter = "ERRORS_ONLY"
  }
}

#------------------------------------------------------------------------------
# Firewall Rules - Baseline Security
#------------------------------------------------------------------------------
resource "google_compute_firewall" "deny_all_ingress" {
  name    = "${var.network.vpc_name}-deny-all-ingress"
  project = var.host_project_id
  network = google_compute_network.shared_vpc.id

  priority  = var.firewall.deny_all_priority
  direction = "INGRESS"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network.vpc_name}-allow-internal"
  project = var.host_project_id
  network = google_compute_network.shared_vpc.id

  priority  = var.firewall.allow_internal_priority
  direction = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    var.network.subnet_dev_cidr,
    var.network.subnet_staging_cidr,
    var.network.subnet_prod_cidr,
    var.network.subnet_shared_cidr,
  ]
}

resource "google_compute_firewall" "allow_iap" {
  name    = "${var.network.vpc_name}-allow-iap"
  project = var.host_project_id
  network = google_compute_network.shared_vpc.id

  priority  = var.firewall.allow_iap_priority
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  # IAP forwarding range (Google-managed, rarely changes)
  source_ranges = [var.firewall.iap_cidr_range]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.network.vpc_name}-allow-health-checks"
  project = var.host_project_id
  network = google_compute_network.shared_vpc.id

  priority  = var.firewall.allow_health_priority
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  # Google Cloud health check ranges (Google-managed)
  source_ranges = var.firewall.health_check_cidr_ranges
}

#------------------------------------------------------------------------------
# Enable Shared VPC
#------------------------------------------------------------------------------
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}
