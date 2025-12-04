#------------------------------------------------------------------------------
# Azure DevOps Module
# Creates: Project, Repos, Pipelines, Service Connections
#------------------------------------------------------------------------------

terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.11"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

#------------------------------------------------------------------------------
# Azure DevOps Project
#------------------------------------------------------------------------------
resource "azuredevops_project" "main" {
  name               = var.devops.project_name
  description        = var.devops.project_description
  visibility         = "private"
  version_control    = var.devops.version_control
  work_item_template = var.devops.work_item_template

  features = {
    repositories  = var.devops.enable_repos ? "enabled" : "disabled"
    boards        = "enabled"
    pipelines     = var.devops.enable_pipelines ? "enabled" : "disabled"
    testplans     = var.devops.enable_test_plans ? "enabled" : "disabled"
    artifacts     = var.devops.enable_artifacts ? "enabled" : "disabled"
  }
}

#------------------------------------------------------------------------------
# Azure Service Connection (Azure Resource Manager)
#------------------------------------------------------------------------------
resource "azuredevops_serviceendpoint_azurerm" "main" {
  count               = var.service_connections.azure_rm_enabled ? 1 : 0
  project_id          = azuredevops_project.main.id
  service_endpoint_name = "${var.name_prefix}-azure-connection"
  description         = "Service connection to Azure subscription"

  credentials {
    serviceprincipalid  = var.service_connections.service_principal_id
    serviceprincipalkey = var.service_connections.service_principal_key
  }

  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = "Azure Subscription"
}

#------------------------------------------------------------------------------
# Default Repository (automatically created with project)
#------------------------------------------------------------------------------
data "azuredevops_git_repository" "default" {
  project_id = azuredevops_project.main.id
  name       = var.devops.project_name
}

#------------------------------------------------------------------------------
# Build Definition (CI Pipeline)
#------------------------------------------------------------------------------
resource "azuredevops_build_definition" "ci" {
  count      = var.pipelines.enable_ci ? 1 : 0
  project_id = azuredevops_project.main.id
  name       = "${var.name_prefix}-ci"

  ci_trigger {
    use_yaml = true
  }

  pull_request_trigger {
    use_yaml = var.pipelines.enable_pull_request_build

    forks {
      enabled       = false
      share_secrets = false
    }
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.default.id
    branch_name = "main"
    yml_path    = "azure-pipelines.yml"
  }

  agent_pool_name = var.pipelines.build_agents_pool
}

#------------------------------------------------------------------------------
# Store DevOps Secrets in Key Vault
#------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "devops_pat" {
  name         = "azuredevops-pat"
  value        = "placeholder-update-manually"
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "service_connection_id" {
  count        = var.service_connections.azure_rm_enabled ? 1 : 0
  name         = "azuredevops-service-connection-id"
  value        = azuredevops_serviceendpoint_azurerm.main[0].id
  key_vault_id = var.key_vault_id
}
