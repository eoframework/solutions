#------------------------------------------------------------------------------
# Terraform Cloud/Enterprise Organization Module
#------------------------------------------------------------------------------
# Configures TFC/TFE organization and base settings
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Organization
#------------------------------------------------------------------------------
resource "tfe_organization" "main" {
  name  = var.tfc.organization_name
  email = var.tfc.admin_email

  collaborator_auth_policy = var.tfc.collaborator_auth_policy
  cost_estimation_enabled  = var.tfc.enable_cost_estimation
  assessments_enabled      = var.tfc.enable_assessments
}

#------------------------------------------------------------------------------
# Organization Settings
#------------------------------------------------------------------------------
resource "tfe_organization_default_settings" "main" {
  organization           = tfe_organization.main.name
  default_execution_mode = var.tfc.default_execution_mode
}

#------------------------------------------------------------------------------
# VCS Provider (GitHub)
#------------------------------------------------------------------------------
resource "tfe_oauth_client" "github" {
  count = var.tfc.github_enabled ? 1 : 0

  organization     = tfe_organization.main.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.tfc.github_oauth_token
  service_provider = "github"
}

#------------------------------------------------------------------------------
# Vault Integration (Dynamic Credentials)
#------------------------------------------------------------------------------
resource "tfe_variable_set" "vault" {
  count = var.vault_enabled ? 1 : 0

  name         = "vault-dynamic-credentials"
  description  = "Vault dynamic credentials configuration"
  organization = tfe_organization.main.name
  global       = true
}

resource "tfe_variable" "vault_addr" {
  count = var.vault_enabled ? 1 : 0

  key             = "TFC_VAULT_ADDR"
  value           = var.vault_endpoint
  category        = "env"
  variable_set_id = tfe_variable_set.vault[0].id
}

resource "tfe_variable" "vault_backed" {
  count = var.vault_enabled ? 1 : 0

  key             = "TFC_VAULT_BACKED_AWS_AUTH"
  value           = "true"
  category        = "env"
  variable_set_id = tfe_variable_set.vault[0].id
}

#------------------------------------------------------------------------------
# Agent Pools (for self-hosted agents)
#------------------------------------------------------------------------------
resource "tfe_agent_pool" "main" {
  count = var.tfc.enable_agents ? 1 : 0

  name                = "${var.name_prefix}-agent-pool"
  organization        = tfe_organization.main.name
  organization_scoped = true
}

resource "tfe_agent_token" "main" {
  count = var.tfc.enable_agents ? 1 : 0

  agent_pool_id = tfe_agent_pool.main[0].id
  description   = "${var.name_prefix} agent token"
}

#------------------------------------------------------------------------------
# Variable Sets (shared variables)
#------------------------------------------------------------------------------
resource "tfe_variable_set" "common" {
  name         = "common-variables"
  description  = "Common variables shared across workspaces"
  organization = tfe_organization.main.name
  global       = true
}

resource "tfe_variable" "aws_region" {
  key             = "AWS_DEFAULT_REGION"
  value           = var.tfc.default_aws_region
  category        = "env"
  variable_set_id = tfe_variable_set.common.id
}
