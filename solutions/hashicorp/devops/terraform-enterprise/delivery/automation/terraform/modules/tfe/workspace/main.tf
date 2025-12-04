#------------------------------------------------------------------------------
# Terraform Enterprise Workspace Module
#------------------------------------------------------------------------------
# Manages TFE workspaces with VCS integration
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# VCS OAuth Client
#------------------------------------------------------------------------------
resource "tfe_oauth_client" "github" {
  count = var.integration.github_vcs_enabled ? 1 : 0

  organization     = var.organization
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  service_provider = "github"
  name             = "GitHub - ${var.integration.github_org}"
}

#------------------------------------------------------------------------------
# Workspace Templates by Environment
#------------------------------------------------------------------------------
locals {
  # Define workspace structure based on environment
  workspace_environments = {
    prod = {
      auto_apply         = false
      terraform_version  = "~> 1.5.0"
      execution_mode     = "remote"
      approval_required  = true
    }
    test = {
      auto_apply         = true
      terraform_version  = "~> 1.5.0"
      execution_mode     = "remote"
      approval_required  = false
    }
    dev = {
      auto_apply         = true
      terraform_version  = "~> 1.5.0"
      execution_mode     = "remote"
      approval_required  = false
    }
  }

  # Sample workspaces based on workspace_count
  workspace_names = [
    for i in range(var.tfe.workspace_count) : "${var.environment}-workspace-${format("%03d", i + 1)}"
  ]
}

#------------------------------------------------------------------------------
# Workspaces
#------------------------------------------------------------------------------
resource "tfe_workspace" "workspace" {
  for_each = toset(local.workspace_names)

  name              = each.key
  organization      = var.organization
  execution_mode    = local.workspace_environments[var.environment].execution_mode
  terraform_version = local.workspace_environments[var.environment].terraform_version
  auto_apply        = local.workspace_environments[var.environment].auto_apply

  queue_all_runs    = true
  working_directory = ""

  dynamic "vcs_repo" {
    for_each = var.integration.github_vcs_enabled ? [1] : []
    content {
      identifier     = "${var.integration.github_org}/infrastructure-${each.key}"
      oauth_token_id = tfe_oauth_client.github[0].oauth_token_id
      branch         = var.environment == "prod" ? "main" : var.environment
    }
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
