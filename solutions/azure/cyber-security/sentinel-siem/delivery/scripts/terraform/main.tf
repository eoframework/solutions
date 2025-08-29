# Azure Sentinel SIEM - Terraform Infrastructure as Code
# Main configuration for deploying Azure Sentinel SIEM solution

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Configure Azure AD Provider
provider "azuread" {}

# Data sources for current subscription and client configuration
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Resource Group for Azure Sentinel
resource "azurerm_resource_group" "sentinel" {
  name     = var.resource_group_name
  location = var.location
  
  tags = var.tags
}

# Log Analytics Workspace for Azure Sentinel
resource "azurerm_log_analytics_workspace" "sentinel" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.sentinel.location
  resource_group_name = azurerm_resource_group.sentinel.name
  
  sku                        = var.log_analytics_sku
  retention_in_days          = var.log_analytics_retention_days
  daily_quota_gb             = var.log_analytics_daily_quota_gb
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  
  tags = var.tags
}

# Azure Sentinel Workspace
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id                 = azurerm_log_analytics_workspace.sentinel.id
  customer_managed_key_enabled = var.customer_managed_key_enabled
}

# Key Vault for storing secrets
resource "azurerm_key_vault" "sentinel" {
  count = var.create_key_vault ? 1 : 0
  
  name                = var.key_vault_name
  location            = azurerm_resource_group.sentinel.location
  resource_group_name = azurerm_resource_group.sentinel.name
  
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    key_permissions = [
      "Create", "Get", "List", "Update", "Delete", "Purge"
    ]
    
    secret_permissions = [
      "Set", "Get", "List", "Delete", "Purge"
    ]
  }
  
  tags = var.tags
}

# Storage Account for long-term data retention
resource "azurerm_storage_account" "sentinel" {
  count = var.create_storage_account ? 1 : 0
  
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.sentinel.name
  location                 = azurerm_resource_group.sentinel.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  blob_properties {
    versioning_enabled = true
    change_feed_enabled = true
    
    delete_retention_policy {
      days = 90
    }
    
    container_delete_retention_policy {
      days = 90
    }
  }
  
  tags = var.tags
}

# Data Connectors
resource "azurerm_sentinel_data_connector_azure_active_directory" "aad" {
  count                      = var.enable_aad_connector ? 1 : 0
  name                       = "azure-active-directory"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel.id
}

resource "azurerm_sentinel_data_connector_azure_security_center" "asc" {
  count                      = var.enable_asc_connector ? 1 : 0
  name                       = "azure-security-center"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel.id
  subscription_id            = data.azurerm_subscription.current.subscription_id
}

resource "azurerm_sentinel_data_connector_office_365" "office365" {
  count                      = var.enable_office365_connector ? 1 : 0
  name                       = "office-365"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel.id
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  
  exchange_enabled    = var.office365_exchange_enabled
  sharepoint_enabled  = var.office365_sharepoint_enabled
  teams_enabled       = var.office365_teams_enabled
}

# Example Analytics Rule
resource "azurerm_sentinel_alert_rule_scheduled" "brute_force_detection" {
  count                      = var.create_sample_rules ? 1 : 0
  name                       = "Brute Force Attack Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel.id
  display_name               = "Brute Force Attack Detection"
  
  severity    = "Medium"
  enabled     = true
  
  query = <<QUERY
SigninLogs
| where TimeGenerated >= ago(1h)
| where ResultType !in ("0", "50125", "50140")
| where UserPrincipalName != ""
| summarize FailedAttempts = count(), Users = make_set(UserPrincipalName) by IPAddress
| where FailedAttempts >= 10
| project IPAddress, FailedAttempts, Users
QUERY

  query_frequency   = "PT1H"
  query_period      = "PT1H"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  
  entity_mapping {
    entity_type = "IP"
    field_mappings {
      identifier = "Address"
      column_name = "IPAddress"
    }
  }
  
  tactics = ["CredentialAccess"]
  
  description = "Detects brute force attacks based on multiple failed login attempts from single IP address"
}

# Example Automation Rule
resource "azurerm_sentinel_automation_rule" "high_severity_incidents" {
  count                      = var.create_sample_automation ? 1 : 0
  name                       = "high-severity-auto-assignment"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel.id
  display_name               = "Auto-assign High Severity Incidents"
  
  order = 1
  
  condition {
    property = "IncidentSeverity"
    operator = "Equals"
    values   = ["High"]
  }
  
  action_incident {
    order  = 1
    status = "Active"
    owner_id = var.incident_owner_object_id
  }
}