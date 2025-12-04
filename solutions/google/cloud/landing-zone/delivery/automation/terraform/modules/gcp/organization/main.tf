#------------------------------------------------------------------------------
# GCP Organization Module
#------------------------------------------------------------------------------
# Creates organization policies and configures organization-level settings
# following Google Cloud Architecture Framework best practices
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Organization Policies
#------------------------------------------------------------------------------
resource "google_organization_policy" "require_shielded_vm" {
  count = var.require_shielded_vm ? 1 : 0

  org_id     = var.org_id
  constraint = "compute.requireShieldedVm"

  boolean_policy {
    enforced = true
  }
}

resource "google_organization_policy" "disable_serial_port_access" {
  count = var.disable_serial_port_access ? 1 : 0

  org_id     = var.org_id
  constraint = "compute.disableSerialPortAccess"

  boolean_policy {
    enforced = true
  }
}

resource "google_organization_policy" "disable_sa_key_creation" {
  count = var.disable_sa_key_creation ? 1 : 0

  org_id     = var.org_id
  constraint = "iam.disableServiceAccountKeyCreation"

  boolean_policy {
    enforced = true
  }
}

resource "google_organization_policy" "disable_vm_external_ip" {
  count = var.disable_vm_external_ip ? 1 : 0

  org_id     = var.org_id
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    deny {
      all = true
    }
  }
}

resource "google_organization_policy" "resource_locations" {
  count = length(var.allowed_locations) > 0 ? 1 : 0

  org_id     = var.org_id
  constraint = "gcp.resourceLocations"

  list_policy {
    allow {
      values = var.allowed_locations
    }
  }
}

resource "google_organization_policy" "uniform_bucket_access" {
  org_id     = var.org_id
  constraint = "storage.uniformBucketLevelAccess"

  boolean_policy {
    enforced = true
  }
}

resource "google_organization_policy" "require_os_login" {
  count = var.require_os_login ? 1 : 0

  org_id     = var.org_id
  constraint = "compute.requireOsLogin"

  boolean_policy {
    enforced = true
  }
}

#------------------------------------------------------------------------------
# Essential Contacts (for billing, security, legal notifications)
#------------------------------------------------------------------------------
resource "google_essential_contacts_contact" "security" {
  count = var.security_contact_email != "" ? 1 : 0

  parent                             = "organizations/${var.org_id}"
  email                              = var.security_contact_email
  language_tag                       = "en-US"
  notification_category_subscriptions = ["SECURITY"]
}

resource "google_essential_contacts_contact" "billing" {
  count = var.billing_contact_email != "" ? 1 : 0

  parent                             = "organizations/${var.org_id}"
  email                              = var.billing_contact_email
  language_tag                       = "en-US"
  notification_category_subscriptions = ["BILLING"]
}

resource "google_essential_contacts_contact" "technical" {
  count = var.technical_contact_email != "" ? 1 : 0

  parent                             = "organizations/${var.org_id}"
  email                              = var.technical_contact_email
  language_tag                       = "en-US"
  notification_category_subscriptions = ["TECHNICAL"]
}
