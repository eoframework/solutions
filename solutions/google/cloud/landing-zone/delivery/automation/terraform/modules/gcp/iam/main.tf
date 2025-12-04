#------------------------------------------------------------------------------
# GCP IAM Module
#------------------------------------------------------------------------------
# Creates and manages IAM resources including:
# - Custom roles for landing zone operations
# - Service accounts for automation
# - Workload Identity pools
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Custom Roles - Organization Level
#------------------------------------------------------------------------------
resource "google_organization_iam_custom_role" "network_viewer" {
  org_id      = var.org_id
  role_id     = "${replace(var.name_prefix, "-", "_")}_network_viewer"
  title       = "Landing Zone Network Viewer"
  description = "View-only access to network resources across the landing zone"
  permissions = [
    "compute.networks.list",
    "compute.networks.get",
    "compute.subnetworks.list",
    "compute.subnetworks.get",
    "compute.firewalls.list",
    "compute.firewalls.get",
    "compute.routes.list",
    "compute.routes.get",
    "compute.routers.list",
    "compute.routers.get",
  ]
}

resource "google_organization_iam_custom_role" "security_reviewer" {
  org_id      = var.org_id
  role_id     = "${replace(var.name_prefix, "-", "_")}_security_reviewer"
  title       = "Landing Zone Security Reviewer"
  description = "Review security configurations without modification"
  permissions = [
    "securitycenter.findings.list",
    "securitycenter.findings.get",
    "securitycenter.sources.list",
    "securitycenter.sources.get",
    "orgpolicy.policies.list",
    "orgpolicy.policy.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccountKeys.list",
    "cloudkms.keyRings.list",
    "cloudkms.cryptoKeys.list",
  ]
}

resource "google_organization_iam_custom_role" "project_creator" {
  org_id      = var.org_id
  role_id     = "${replace(var.name_prefix, "-", "_")}_project_creator"
  title       = "Landing Zone Project Creator"
  description = "Create and manage projects within designated folders"
  permissions = [
    "resourcemanager.projects.create",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list",
    "resourcemanager.projects.update",
    "resourcemanager.projects.setIamPolicy",
    "resourcemanager.projects.getIamPolicy",
    "billing.resourceAssociations.create",
    "serviceusage.services.enable",
    "serviceusage.services.list",
  ]
}

#------------------------------------------------------------------------------
# Service Accounts - Automation
#------------------------------------------------------------------------------
resource "google_service_account" "terraform" {
  account_id   = "${var.name_prefix}-terraform"
  display_name = "Terraform Automation Service Account"
  description  = "Service account for Terraform automation in landing zone"
  project      = var.automation_project_id
}

resource "google_service_account" "ci_cd" {
  account_id   = "${var.name_prefix}-cicd"
  display_name = "CI/CD Pipeline Service Account"
  description  = "Service account for CI/CD pipelines"
  project      = var.automation_project_id
}

resource "google_service_account" "monitoring" {
  account_id   = "${var.name_prefix}-monitoring"
  display_name = "Monitoring Service Account"
  description  = "Service account for monitoring and alerting"
  project      = var.monitoring_project_id
}

#------------------------------------------------------------------------------
# Organization-Level IAM Bindings for Service Accounts
#------------------------------------------------------------------------------
resource "google_organization_iam_member" "terraform_org_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.organizationAdmin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_organization_iam_member" "terraform_billing" {
  org_id = var.org_id
  role   = "roles/billing.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_organization_iam_member" "terraform_folder_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.folderAdmin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_organization_iam_member" "terraform_project_creator" {
  org_id = var.org_id
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

#------------------------------------------------------------------------------
# Workload Identity Pool (for GKE and external workloads)
#------------------------------------------------------------------------------
resource "google_iam_workload_identity_pool" "main" {
  count = var.enable_workload_identity ? 1 : 0

  workload_identity_pool_id = "${var.name_prefix}-pool"
  project                   = var.automation_project_id
  display_name              = "${var.name_prefix} Workload Identity Pool"
  description               = "Workload Identity Pool for landing zone workloads"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  count = var.enable_workload_identity && var.github_org != "" ? 1 : 0

  workload_identity_pool_id          = google_iam_workload_identity_pool.main[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  project                            = var.automation_project_id
  display_name                       = "GitHub Actions"
  description                        = "OIDC provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "assertion.repository_owner == '${var.github_org}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

#------------------------------------------------------------------------------
# Group IAM Bindings (if Cloud Identity groups are provided)
#------------------------------------------------------------------------------
resource "google_organization_iam_binding" "org_admins" {
  count = length(var.org_admin_group) > 0 ? 1 : 0

  org_id  = var.org_id
  role    = "roles/resourcemanager.organizationAdmin"
  members = ["group:${var.org_admin_group}"]
}

resource "google_organization_iam_binding" "network_admins" {
  count = length(var.network_admin_group) > 0 ? 1 : 0

  org_id  = var.org_id
  role    = "roles/compute.networkAdmin"
  members = ["group:${var.network_admin_group}"]
}

resource "google_organization_iam_binding" "security_admins" {
  count = length(var.security_admin_group) > 0 ? 1 : 0

  org_id  = var.org_id
  role    = "roles/iam.securityAdmin"
  members = ["group:${var.security_admin_group}"]
}

resource "google_organization_iam_binding" "billing_admins" {
  count = length(var.billing_admin_group) > 0 ? 1 : 0

  org_id  = var.org_id
  role    = "roles/billing.admin"
  members = ["group:${var.billing_admin_group}"]
}
