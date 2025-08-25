# Microsoft 365 Enterprise Deployment - Terraform Outputs
# 
# This file defines outputs that provide important information about
# the deployed Microsoft 365 infrastructure and configuration.

# ==============================================================================
# TENANT INFORMATION
# ==============================================================================

output "tenant_information" {
  description = "Core tenant information and identifiers"
  value = {
    tenant_id                = data.azuread_client_config.current.tenant_id
    tenant_domain           = var.tenant_domain
    environment             = var.environment
    organization_name       = var.organization_name
    deployment_date        = timestamp()
    primary_domain         = length(data.azuread_domains.tenant_domains.domains) > 0 ? data.azuread_domains.tenant_domains.domains[0].domain_name : var.tenant_domain
    verified_domains_count = length([for domain in data.azuread_domains.tenant_domains.domains : domain if domain.is_verified])
  }
  sensitive = false
}

# ==============================================================================
# SECURITY CONFIGURATION OUTPUTS
# ==============================================================================

output "emergency_access_accounts" {
  description = "Emergency access account information"
  value = {
    account_1 = {
      upn       = azuread_user.emergency_access_accounts[0].user_principal_name
      object_id = azuread_user.emergency_access_accounts[0].object_id
      enabled   = azuread_user.emergency_access_accounts[0].account_enabled
    }
    account_2 = {
      upn       = azuread_user.emergency_access_accounts[1].user_principal_name
      object_id = azuread_user.emergency_access_accounts[1].object_id
      enabled   = azuread_user.emergency_access_accounts[1].account_enabled
    }
  }
  sensitive = false
}

output "conditional_access_policies" {
  description = "Deployed conditional access policies"
  value = {
    mfa_policy = {
      name      = azuread_conditional_access_policy.require_mfa_all_users.display_name
      object_id = azuread_conditional_access_policy.require_mfa_all_users.id
      state     = azuread_conditional_access_policy.require_mfa_all_users.state
    }
    legacy_auth_block = {
      name      = azuread_conditional_access_policy.block_legacy_authentication.display_name
      object_id = azuread_conditional_access_policy.block_legacy_authentication.id
      state     = azuread_conditional_access_policy.block_legacy_authentication.state
    }
    compliant_devices = {
      name      = azuread_conditional_access_policy.require_compliant_devices.display_name
      object_id = azuread_conditional_access_policy.require_compliant_devices.id
      state     = azuread_conditional_access_policy.require_compliant_devices.state
    }
    high_risk_users = {
      name      = azuread_conditional_access_policy.high_risk_users_policy.display_name
      object_id = azuread_conditional_access_policy.high_risk_users_policy.id
      state     = azuread_conditional_access_policy.high_risk_users_policy.state
    }
    high_risk_signin = {
      name      = azuread_conditional_access_policy.high_risk_signin_policy.display_name
      object_id = azuread_conditional_access_policy.high_risk_signin_policy.id
      state     = azuread_conditional_access_policy.high_risk_signin_policy.state
    }
  }
  sensitive = false
}

output "named_locations" {
  description = "Named locations for conditional access"
  value = {
    corporate_network = {
      name      = azuread_named_location.corporate_network.display_name
      object_id = azuread_named_location.corporate_network.id
      ip_ranges = var.corporate_ip_ranges
    }
    blocked_countries = {
      name      = azuread_named_location.blocked_countries.display_name
      object_id = azuread_named_location.blocked_countries.id
      countries = var.blocked_countries
    }
  }
  sensitive = false
}

# ==============================================================================
# ORGANIZATIONAL STRUCTURE OUTPUTS
# ==============================================================================

output "security_groups" {
  description = "Created security groups for organizational management"
  value = {
    all_employees = {
      name      = azuread_group.all_employees.display_name
      object_id = azuread_group.all_employees.object_id
    }
    executive_team = {
      name      = azuread_group.executive_team.display_name
      object_id = azuread_group.executive_team.object_id
    }
    security_team = {
      name      = azuread_group.security_team.display_name
      object_id = azuread_group.security_team.object_id
    }
  }
  sensitive = false
}

output "department_groups" {
  description = "Department-specific security groups"
  value = {
    for dept, group in azuread_group.department_groups : dept => {
      name      = group.display_name
      object_id = group.object_id
    }
  }
  sensitive = false
}

output "administrative_units" {
  description = "Administrative units for organizational structure"
  value = {
    for dept, au in azuread_administrative_unit.departments : dept => {
      name      = au.display_name
      object_id = au.object_id
    }
  }
  sensitive = false
}

# ==============================================================================
# AUTOMATION AND INTEGRATION OUTPUTS
# ==============================================================================

output "automation_application" {
  description = "Automation service principal information"
  value = {
    application_id     = azuread_application.m365_automation.application_id
    object_id         = azuread_application.m365_automation.object_id
    display_name      = azuread_application.m365_automation.display_name
    service_principal = {
      object_id = azuread_service_principal.m365_automation.object_id
    }
  }
  sensitive = false
}

output "automation_secrets_location" {
  description = "Location of automation secrets in Key Vault"
  value = {
    key_vault_name = azurerm_key_vault.m365_secrets.name
    client_id_secret_name = azurerm_key_vault_secret.m365_automation_client_id.name
    client_id_secret_url  = azurerm_key_vault_secret.m365_automation_client_id.id
  }
  sensitive = false
}

# ==============================================================================
# AZURE SUPPORTING RESOURCES
# ==============================================================================

output "azure_resources" {
  description = "Azure resources created for Microsoft 365 support"
  value = {
    resource_group = {
      name     = azurerm_resource_group.m365_support.name
      location = azurerm_resource_group.m365_support.location
      id       = azurerm_resource_group.m365_support.id
    }
    key_vault = {
      name         = azurerm_key_vault.m365_secrets.name
      id           = azurerm_key_vault.m365_secrets.id
      vault_uri    = azurerm_key_vault.m365_secrets.vault_uri
    }
    log_analytics = {
      name          = azurerm_log_analytics_workspace.m365_monitoring.name
      workspace_id  = azurerm_log_analytics_workspace.m365_monitoring.workspace_id
      id           = azurerm_log_analytics_workspace.m365_monitoring.id
    }
    storage_account = {
      name                = azurerm_storage_account.m365_compliance.name
      id                  = azurerm_storage_account.m365_compliance.id
      primary_blob_endpoint = azurerm_storage_account.m365_compliance.primary_blob_endpoint
    }
  }
  sensitive = false
}

# ==============================================================================
# CONFIGURATION OUTPUTS FOR EXTERNAL TOOLS
# ==============================================================================

output "powershell_connection_parameters" {
  description = "Parameters for PowerShell script connections"
  value = {
    tenant_id          = data.azuread_client_config.current.tenant_id
    tenant_domain      = var.tenant_domain
    automation_app_id  = azuread_application.m365_automation.application_id
    log_workspace_id   = azurerm_log_analytics_workspace.m365_monitoring.workspace_id
    key_vault_name     = azurerm_key_vault.m365_secrets.name
  }
  sensitive = false
}

output "graph_api_endpoints" {
  description = "Microsoft Graph API endpoints and permissions"
  value = {
    base_url = "https://graph.microsoft.com/v1.0"
    beta_url = "https://graph.microsoft.com/beta"
    permissions_granted = [
      "Directory.ReadWrite.All",
      "Group.ReadWrite.All", 
      "User.ReadWrite.All"
    ]
    authentication = {
      tenant_id = data.azuread_client_config.current.tenant_id
      client_id = azuread_application.m365_automation.application_id
      scope     = "https://graph.microsoft.com/.default"
    }
  }
  sensitive = false
}

# ==============================================================================
# COMPLIANCE AND GOVERNANCE OUTPUTS
# ==============================================================================

output "compliance_configuration" {
  description = "Compliance and governance settings"
  value = {
    requirements          = var.compliance_requirements
    data_residency_region = var.data_residency_region
    log_retention_days    = var.log_retention_days
    compliance_storage    = azurerm_storage_account.m365_compliance.name
    audit_workspace      = azurerm_log_analytics_workspace.m365_monitoring.workspace_id
  }
  sensitive = false
}

output "security_baseline_summary" {
  description = "Security baseline implementation summary"
  value = {
    mfa_enforcement            = var.mfa_enforcement_mode
    conditional_access_enabled = var.enable_conditional_access
    identity_protection_enabled = var.enable_identity_protection
    emergency_accounts_created = length(azuread_user.emergency_access_accounts)
    ca_policies_deployed      = 5
    named_locations_configured = 2
    blocked_countries_count   = length(var.blocked_countries)
    corporate_ip_ranges_count = length(var.corporate_ip_ranges)
  }
  sensitive = false
}

# ==============================================================================
# DEPLOYMENT STATUS AND NEXT STEPS
# ==============================================================================

output "deployment_status" {
  description = "Deployment status and next steps"
  value = {
    terraform_deployment_complete = true
    deployment_phases_completed   = var.deployment_phases
    pilot_mode_enabled           = var.enable_pilot_mode
    next_steps = [
      "1. Run PowerShell scripts to configure Exchange Online",
      "2. Deploy SharePoint site templates and governance",
      "3. Configure Microsoft Teams policies and settings",
      "4. Set up Microsoft Defender for Office 365",
      "5. Configure Data Loss Prevention policies",
      "6. Implement user training and adoption programs",
      "7. Perform user acceptance testing",
      "8. Go live with phased user rollout"
    ]
    important_notes = [
      "Emergency access account passwords are stored securely - document offline",
      "Service principal client secret needs to be generated and stored in Key Vault",
      "Conditional access policies may require initial exclusions during rollout",
      "Monitor sign-in logs during first 48 hours for policy impacts"
    ]
  }
  sensitive = false
}

output "monitoring_and_alerts" {
  description = "Monitoring and alerting configuration"
  value = {
    log_analytics_workspace = azurerm_log_analytics_workspace.m365_monitoring.workspace_id
    key_metrics_to_monitor = [
      "Failed sign-in attempts",
      "Conditional access policy blocks", 
      "MFA challenge success rates",
      "Administrative role assignments",
      "High-risk sign-ins and users",
      "Application permissions changes"
    ]
    recommended_alerts = [
      "Emergency access account usage",
      "New global administrator assignments",
      "Conditional access policy changes",
      "Bulk user operations",
      "Privileged role activations"
    ]
  }
  sensitive = false
}

# ==============================================================================
# SENSITIVE OUTPUTS (for internal use only)
# ==============================================================================

output "emergency_account_details" {
  description = "Sensitive emergency account information for secure documentation"
  value = {
    account_1_upn = azuread_user.emergency_access_accounts[0].user_principal_name
    account_2_upn = azuread_user.emergency_access_accounts[1].user_principal_name
    creation_date = timestamp()
    password_note = "Passwords are set via variables and should be documented offline"
  }
  sensitive = true
}

output "automation_credentials" {
  description = "Automation application credentials information"
  value = {
    application_id = azuread_application.m365_automation.application_id
    tenant_id     = data.azuread_client_config.current.tenant_id
    client_secret_location = "Generate client secret manually and store in ${azurerm_key_vault.m365_secrets.name}"
  }
  sensitive = true
}