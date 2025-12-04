#------------------------------------------------------------------------------
# GCP Folders Module
#------------------------------------------------------------------------------
# Creates folder hierarchy for environment separation
# Implements dev/staging/prod/shared services pattern
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Environment Folders
#------------------------------------------------------------------------------
resource "google_folder" "development" {
  display_name = var.folders.dev_display_name
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "staging" {
  display_name = var.folders.staging_display_name
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "production" {
  display_name = var.folders.prod_display_name
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "shared_services" {
  display_name = var.folders.shared_display_name
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "sandbox" {
  count = var.create_sandbox_folder ? 1 : 0

  display_name = var.folders.sandbox_display_name
  parent       = "organizations/${var.org_id}"
}

#------------------------------------------------------------------------------
# Folder-Level IAM Bindings (Optional)
#------------------------------------------------------------------------------
resource "google_folder_iam_binding" "dev_editors" {
  count = length(var.dev_editor_members) > 0 ? 1 : 0

  folder  = google_folder.development.name
  role    = "roles/editor"
  members = var.dev_editor_members
}

resource "google_folder_iam_binding" "prod_viewers" {
  count = length(var.prod_viewer_members) > 0 ? 1 : 0

  folder  = google_folder.production.name
  role    = "roles/viewer"
  members = var.prod_viewer_members
}
