# Microsoft 365 Enterprise Deployment - Terraform Configuration
# 
# This Terraform configuration provisions and configures Microsoft 365
# enterprise environments with focus on Azure AD, security policies,
# and compliance settings.
#
# Version: 1.0
# Provider Requirements: AzureAD, AzureRM

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.30"
    }
    microsoft365wp = {
      source  = "terraproviders/microsoft365wp"
      version = "~> 0.1"
    }
  }
  
  # Backend configuration for state management
  backend "azurerm" {
    # Configure backend in terraform.tfvars or via CLI
    # resource_group_name  = "terraform-state-rg"
    # storage_account_name = "terraformstate"
    # container_name       = "tfstate"
    # key                  = "m365-deployment.terraform.tfstate"
  }
}

# Configure the AzureAD Provider
provider "azuread" {
  tenant_id = var.tenant_id
}

# Configure the AzureRM Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# Data sources for existing Azure AD tenant information
data "azuread_client_config" "current" {}

data "azuread_domains" "tenant_domains" {
  only_initial = false
}

# Local values for resource naming and tagging
locals {
  common_tags = {
    Environment     = var.environment
    Project         = "Microsoft365-Deployment"
    ManagedBy      = "Terraform"
    DeploymentDate = timestamp()
    TenantDomain   = var.tenant_domain
  }
  
  # Resource naming convention
  name_prefix = "${var.organization_name}-${var.environment}"
  
  # Default password policy
  default_password_policy = {
    minimum_length                 = 12
    require_uppercase             = true
    require_lowercase             = true
    require_numbers               = true
    require_symbols               = true
    require_non_alphanumeric      = true
    password_history_count        = 24
    maximum_password_age_days     = 90
    minimum_password_age_days     = 1
    lockout_duration_minutes      = 60
    lockout_threshold             = 5
    lockout_observation_window_minutes = 60
  }
}

# Azure AD Administrative Units for organizational structure
resource "azuread_administrative_unit" "departments" {
  for_each = toset(var.departments)
  
  display_name = "${each.value} Department"
  description  = "Administrative unit for ${each.value} department users and resources"
  
  # Members will be added separately based on user department attribute
}

# Azure AD Groups for different user types and permissions
resource "azuread_group" "all_employees" {
  display_name            = "All Employees"
  description            = "All company employees with Microsoft 365 access"
  security_enabled       = true
  mail_enabled          = false
  prevent_duplicate_names = true
  
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_group" "department_groups" {
  for_each = toset(var.departments)
  
  display_name            = "${each.value} Department"
  description            = "Security group for ${each.value} department"
  security_enabled       = true
  mail_enabled          = false
  prevent_duplicate_names = true
  
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_group" "executive_team" {
  display_name            = "Executive Team"
  description            = "Executive team members with enhanced privileges"
  security_enabled       = true
  mail_enabled          = false
  prevent_duplicate_names = true
  
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_group" "security_team" {
  display_name            = "Security Team"
  description            = "Security team with compliance and monitoring access"
  security_enabled       = true
  mail_enabled          = false
  prevent_duplicate_names = true
  
  owners = [data.azuread_client_config.current.object_id]
}

# Break-glass emergency access accounts
resource "azuread_user" "emergency_access_accounts" {
  count = 2
  
  user_principal_name = "emergency-access-${count.index + 1}@${var.tenant_domain}"
  display_name       = "Emergency Access Account ${count.index + 1}"
  given_name         = "Emergency"
  surname           = "Access${count.index + 1}"
  
  account_enabled = true
  
  # Strong password that doesn't expire
  password = var.emergency_account_passwords[count.index]
  force_change_password_next_sign_in = false
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Assign Global Administrator role to emergency access accounts
resource "azuread_directory_role_assignment" "emergency_global_admin" {
  count = length(azuread_user.emergency_access_accounts)
  
  role_id             = "62e90394-69f5-4237-9190-012177145e10" # Global Administrator
  principal_object_id = azuread_user.emergency_access_accounts[count.index].object_id
}

# Conditional Access Policies
resource "azuread_conditional_access_policy" "require_mfa_all_users" {
  display_name = "Require MFA for All Users"
  state       = "enabled"
  
  conditions {
    client_app_types = ["all"]
    
    applications {
      included_applications = ["All"]
      excluded_applications = []
    }
    
    users {
      included_users = ["All"]
      excluded_users = [for user in azuread_user.emergency_access_accounts : user.object_id]
      included_groups = []
      excluded_groups = []
    }
    
    locations {
      included_locations = ["All"]
      excluded_locations = []
    }
  }
  
  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

resource "azuread_conditional_access_policy" "block_legacy_authentication" {
  display_name = "Block Legacy Authentication"
  state       = "enabled"
  
  conditions {
    client_app_types = [
      "exchangeActiveSync",
      "other"
    ]
    
    applications {
      included_applications = ["All"]
    }
    
    users {
      included_users = ["All"]
      excluded_users = [for user in azuread_user.emergency_access_accounts : user.object_id]
    }
  }
  
  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

resource "azuread_conditional_access_policy" "require_compliant_devices" {
  display_name = "Require Compliant or Hybrid Azure AD Joined Device"
  state       = "enabled"
  
  conditions {
    client_app_types = ["all"]
    
    applications {
      included_applications = ["All"]
      excluded_applications = []
    }
    
    users {
      included_users = ["All"]
      excluded_users = [for user in azuread_user.emergency_access_accounts : user.object_id]
    }
    
    platforms {
      included_platforms = ["windows", "macOS"]
      excluded_platforms = []
    }
  }
  
  grant_controls {
    operator          = "OR"
    built_in_controls = ["compliantDevice", "domainJoinedDevice"]
  }
}

resource "azuread_conditional_access_policy" "high_risk_users_policy" {
  display_name = "High Risk Users Policy"
  state       = "enabled"
  
  conditions {
    client_app_types = ["all"]
    
    applications {
      included_applications = ["All"]
    }
    
    users {
      included_users = ["All"]
      excluded_users = [for user in azuread_user.emergency_access_accounts : user.object_id]
    }
    
    user_risk_levels = ["high"]
  }
  
  grant_controls {
    operator          = "AND"
    built_in_controls = ["mfa", "passwordChange"]
  }
}

resource "azuread_conditional_access_policy" "high_risk_signin_policy" {
  display_name = "High Risk Sign-in Policy"
  state       = "enabled"
  
  conditions {
    client_app_types = ["all"]
    
    applications {
      included_applications = ["All"]
    }
    
    users {
      included_users = ["All"]
      excluded_users = [for user in azuread_user.emergency_access_accounts : user.object_id]
    }
    
    sign_in_risk_levels = ["high"]
  }
  
  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# Named Locations for Conditional Access
resource "azuread_named_location" "corporate_network" {
  display_name = "Corporate Network"
  
  ip {
    ip_ranges = var.corporate_ip_ranges
    trusted   = true
  }
}

resource "azuread_named_location" "blocked_countries" {
  display_name = "Blocked Countries"
  
  country {
    countries_and_regions = var.blocked_countries
    include_unknown_countries_and_regions = false
  }
}

# Application Registration for automation and integrations
resource "azuread_application" "m365_automation" {
  display_name = "${local.name_prefix}-M365-Automation"
  description  = "Application for Microsoft 365 automation and management"
  
  owners = [data.azuread_client_config.current.object_id]
  
  # API permissions required for M365 management
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    
    resource_access {
      id   = "19dbc75e-c2e2-444c-a770-ec69d8559fc7" # Directory.ReadWrite.All
      type = "Role"
    }
    
    resource_access {
      id   = "62a82d76-70ea-41e2-9197-370581804d09" # Group.ReadWrite.All
      type = "Role"
    }
    
    resource_access {
      id   = "741f803b-c850-494e-b5df-cde7c675a1ca" # User.ReadWrite.All
      type = "Role"
    }
  }
  
  web {
    redirect_uris = ["https://localhost:8080/auth/callback"]
    
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }
}

resource "azuread_service_principal" "m365_automation" {
  application_id = azuread_application.m365_automation.application_id
  owners        = [data.azuread_client_config.current.object_id]
  
  app_role_assignment_required = false
}

# Grant admin consent for the application
resource "azuread_app_role_assignment" "m365_automation_directory_readwrite" {
  app_role_id         = "19dbc75e-c2e2-444c-a770-ec69d8559fc7" # Directory.ReadWrite.All
  principal_object_id = azuread_service_principal.m365_automation.object_id
  resource_object_id  = data.azuread_client_config.current.object_id
}

# Azure Resource Group for supporting resources
resource "azurerm_resource_group" "m365_support" {
  name     = "${local.name_prefix}-m365-support-rg"
  location = var.azure_region
  
  tags = local.common_tags
}

# Key Vault for storing secrets and certificates
resource "azurerm_key_vault" "m365_secrets" {
  name                = "${var.organization_name}-${var.environment}-kv"
  location            = azurerm_resource_group.m365_support.location
  resource_group_name = azurerm_resource_group.m365_support.name
  tenant_id          = data.azuread_client_config.current.tenant_id
  
  sku_name = "standard"
  
  # Network access rules
  network_acls {
    default_action = "Allow" # Change to "Deny" and add IP rules for production
    bypass         = "AzureServices"
  }
  
  # Access policy for current deployment principal
  access_policy {
    tenant_id = data.azuread_client_config.current.tenant_id
    object_id = data.azuread_client_config.current.object_id
    
    key_permissions = [
      "Create", "Delete", "Get", "List", "Update", "Import", "Backup", "Restore"
    ]
    
    secret_permissions = [
      "Set", "Get", "Delete", "List", "Restore", "Backup"
    ]
    
    certificate_permissions = [
      "Create", "Delete", "Get", "List", "Update", "Import"
    ]
  }
  
  tags = local.common_tags
}

# Store application secrets in Key Vault
resource "azurerm_key_vault_secret" "m365_automation_client_id" {
  name         = "m365-automation-client-id"
  value        = azuread_application.m365_automation.application_id
  key_vault_id = azurerm_key_vault.m365_secrets.id
  
  tags = local.common_tags
}

# Log Analytics Workspace for monitoring and compliance
resource "azurerm_log_analytics_workspace" "m365_monitoring" {
  name                = "${local.name_prefix}-m365-logs"
  location            = azurerm_resource_group.m365_support.location
  resource_group_name = azurerm_resource_group.m365_support.name
  sku                = "PerGB2018"
  retention_in_days   = var.log_retention_days
  
  tags = local.common_tags
}

# Storage Account for logs and compliance data
resource "azurerm_storage_account" "m365_compliance" {
  name                     = "${var.organization_name}${var.environment}compliance"
  resource_group_name      = azurerm_resource_group.m365_support.name
  location                 = azurerm_resource_group.m365_support.location
  account_tier            = "Standard"
  account_replication_type = "GRS"
  
  # Security settings
  enable_https_traffic_only      = true
  min_tls_version               = "TLS1_2"
  allow_nested_items_to_be_public = false
  
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = var.compliance_retention_days
    }
    container_delete_retention_policy {
      days = var.compliance_retention_days
    }
  }
  
  tags = local.common_tags
}

# Output important information for post-deployment configuration
output "deployment_summary" {
  description = "Summary of deployed Microsoft 365 resources"
  value = {
    tenant_id                    = data.azuread_client_config.current.tenant_id
    tenant_domain               = var.tenant_domain
    emergency_access_accounts   = [for user in azuread_user.emergency_access_accounts : user.user_principal_name]
    automation_app_id          = azuread_application.m365_automation.application_id
    conditional_access_policies = [
      azuread_conditional_access_policy.require_mfa_all_users.display_name,
      azuread_conditional_access_policy.block_legacy_authentication.display_name,
      azuread_conditional_access_policy.require_compliant_devices.display_name,
      azuread_conditional_access_policy.high_risk_users_policy.display_name,
      azuread_conditional_access_policy.high_risk_signin_policy.display_name
    ]
    security_groups = [
      azuread_group.all_employees.display_name,
      azuread_group.executive_team.display_name,
      azuread_group.security_team.display_name
    ]
    department_groups = [for group in azuread_group.department_groups : group.display_name]
    key_vault_name    = azurerm_key_vault.m365_secrets.name
    log_workspace_name = azurerm_log_analytics_workspace.m365_monitoring.name
    compliance_storage = azurerm_storage_account.m365_compliance.name
  }
}

# Data export for external tools
resource "local_file" "deployment_config" {
  count = var.export_configuration ? 1 : 0
  
  content = jsonencode({
    tenant_configuration = {
      tenant_id     = data.azuread_client_config.current.tenant_id
      tenant_domain = var.tenant_domain
      environment   = var.environment
    }
    
    emergency_accounts = [
      for user in azuread_user.emergency_access_accounts : {
        upn       = user.user_principal_name
        object_id = user.object_id
      }
    ]
    
    automation_app = {
      client_id  = azuread_application.m365_automation.application_id
      object_id  = azuread_application.m365_automation.object_id
    }
    
    security_groups = [
      for group in concat([azuread_group.all_employees, azuread_group.executive_team, azuread_group.security_team], values(azuread_group.department_groups)) : {
        name      = group.display_name
        object_id = group.object_id
      }
    ]
    
    azure_resources = {
      resource_group_name = azurerm_resource_group.m365_support.name
      key_vault_name     = azurerm_key_vault.m365_secrets.name
      log_workspace_id   = azurerm_log_analytics_workspace.m365_monitoring.id
      storage_account    = azurerm_storage_account.m365_compliance.name
    }
  })
  
  filename = "m365-deployment-config.json"
}