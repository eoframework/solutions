#------------------------------------------------------------------------------
# GCP Projects Module
#------------------------------------------------------------------------------
# Creates and manages GCP projects within the folder hierarchy
# Implements project factory pattern for standardized provisioning
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------------
locals {
  # Core infrastructure projects
  core_projects = {
    host       = var.projects.host_project_name
    logging    = var.projects.logging_project_name
    security   = var.projects.security_project_name
    monitoring = var.projects.monitoring_project_name
  }
}

#------------------------------------------------------------------------------
# Shared VPC Host Project
#------------------------------------------------------------------------------
resource "google_project" "host" {
  name                = var.projects.host_project_name
  project_id          = "${var.name_prefix}-${var.projects.host_project_name}"
  folder_id           = var.shared_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false

  labels = merge(var.common_labels, {
    purpose = "shared-vpc-host"
    type    = "infrastructure"
  })
}

#------------------------------------------------------------------------------
# Logging Project
#------------------------------------------------------------------------------
resource "google_project" "logging" {
  name                = var.projects.logging_project_name
  project_id          = "${var.name_prefix}-${var.projects.logging_project_name}"
  folder_id           = var.shared_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false

  labels = merge(var.common_labels, {
    purpose = "centralized-logging"
    type    = "infrastructure"
  })
}

#------------------------------------------------------------------------------
# Security Project
#------------------------------------------------------------------------------
resource "google_project" "security" {
  name                = var.projects.security_project_name
  project_id          = "${var.name_prefix}-${var.projects.security_project_name}"
  folder_id           = var.shared_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false

  labels = merge(var.common_labels, {
    purpose = "security-services"
    type    = "infrastructure"
  })
}

#------------------------------------------------------------------------------
# Monitoring Project
#------------------------------------------------------------------------------
resource "google_project" "monitoring" {
  name                = var.projects.monitoring_project_name
  project_id          = "${var.name_prefix}-${var.projects.monitoring_project_name}"
  folder_id           = var.shared_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false

  labels = merge(var.common_labels, {
    purpose = "cloud-monitoring"
    type    = "infrastructure"
  })
}

#------------------------------------------------------------------------------
# Enable Required APIs - Host Project
#------------------------------------------------------------------------------
resource "google_project_service" "host_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])

  project = google_project.host.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

#------------------------------------------------------------------------------
# Enable Required APIs - Logging Project
#------------------------------------------------------------------------------
resource "google_project_service" "logging_apis" {
  for_each = toset([
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
  ])

  project = google_project.logging.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

#------------------------------------------------------------------------------
# Enable Required APIs - Security Project
#------------------------------------------------------------------------------
resource "google_project_service" "security_apis" {
  for_each = toset([
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "securitycenter.googleapis.com",
    "cloudids.googleapis.com",
  ])

  project = google_project.security.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

#------------------------------------------------------------------------------
# Enable Required APIs - Monitoring Project
#------------------------------------------------------------------------------
resource "google_project_service" "monitoring_apis" {
  for_each = toset([
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudprofiler.googleapis.com",
  ])

  project = google_project.monitoring.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

#------------------------------------------------------------------------------
# Workload Projects (Application Teams)
#------------------------------------------------------------------------------
resource "google_project" "workload" {
  for_each = { for idx in range(var.projects.initial_count) : idx => idx }

  name                = "workload-${format("%03d", each.value + 1)}"
  project_id          = "${var.name_prefix}-workload-${format("%03d", each.value + 1)}"
  folder_id           = var.dev_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false

  labels = merge(var.common_labels, {
    purpose = "workload"
    type    = "application"
    index   = tostring(each.value + 1)
  })
}

#------------------------------------------------------------------------------
# Enable Required APIs - Workload Projects
#------------------------------------------------------------------------------
resource "google_project_service" "workload_apis" {
  for_each = {
    for pair in flatten([
      for proj_idx in range(var.projects.initial_count) : [
        for api in [
          "compute.googleapis.com",
          "container.googleapis.com",
          "cloudsql.googleapis.com",
          "storage.googleapis.com",
          "cloudfunctions.googleapis.com",
          "run.googleapis.com",
        ] : {
          key     = "${proj_idx}-${api}"
          project = google_project.workload[proj_idx].project_id
          api     = api
        }
      ]
    ]) : pair.key => pair
  }

  project = each.value.project
  service = each.value.api

  disable_dependent_services = false
  disable_on_destroy         = false
}

#------------------------------------------------------------------------------
# Shared VPC Service Project Attachments
#------------------------------------------------------------------------------
resource "google_compute_shared_vpc_service_project" "workload" {
  for_each = { for idx in range(var.projects.initial_count) : idx => idx }

  host_project    = google_project.host.project_id
  service_project = google_project.workload[each.value].project_id

  depends_on = [
    google_project_service.host_apis,
  ]
}
