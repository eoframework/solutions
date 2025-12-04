#------------------------------------------------------------------------------
# Terraform Enterprise Organization Module
#------------------------------------------------------------------------------
# Manages TFE organization configuration and settings
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# TFE Organization
#------------------------------------------------------------------------------
resource "tfe_organization" "org" {
  name  = var.tfe.organization
  email = var.tfe.admin_email

  collaborator_auth_policy = "two_factor_mandatory"
  cost_estimation_enabled  = true
  assessments_enforced     = true
}

#------------------------------------------------------------------------------
# Organization Settings
#------------------------------------------------------------------------------
resource "tfe_organization_default_settings" "settings" {
  organization           = tfe_organization.org.name
  default_execution_mode = var.tfe.operational_mode == "active-active" ? "remote" : "local"
}

#------------------------------------------------------------------------------
# Admin Token for API Access
#------------------------------------------------------------------------------
resource "tfe_organization_token" "admin" {
  organization = tfe_organization.org.name
  force_regenerate = false
}

#------------------------------------------------------------------------------
# Vault Integration (if enabled)
#------------------------------------------------------------------------------
resource "tfe_workspace_variable_set" "vault" {
  count = var.vault_enabled ? 1 : 0

  workspace_id = tfe_organization.org.id
  variable_set_id = tfe_variable_set.vault[0].id
}

resource "tfe_variable_set" "vault" {
  count = var.vault_enabled ? 1 : 0

  name         = "vault-credentials"
  description  = "HashiCorp Vault dynamic credentials"
  organization = tfe_organization.org.name
  global       = true
}

resource "tfe_variable" "vault_addr" {
  count = var.vault_enabled ? 1 : 0

  key             = "VAULT_ADDR"
  value           = var.vault_endpoint
  category        = "env"
  variable_set_id = tfe_variable_set.vault[0].id
}
