# Outputs for Microsoft CMMC Enclave deployment

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the main resource group"
  value       = azurerm_resource_group.cmmc_main.name
}

output "security_resource_group_name" {
  description = "Name of the security resource group"
  value       = azurerm_resource_group.cmmc_security.name
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.cmmc_main.location
}

# Networking Outputs
output "virtual_network_id" {
  description = "Resource ID of the CMMC virtual network"
  value       = azurerm_virtual_network.cmmc_vnet.id
}

output "virtual_network_name" {
  description = "Name of the CMMC virtual network"
  value       = azurerm_virtual_network.cmmc_vnet.name
}

output "management_subnet_id" {
  description = "Resource ID of the management subnet"
  value       = azurerm_subnet.management.id
}

output "workload_subnet_id" {
  description = "Resource ID of the workload subnet"
  value       = azurerm_subnet.workload.id
}

output "data_subnet_id" {
  description = "Resource ID of the data subnet"
  value       = azurerm_subnet.data.id
}

output "bastion_subnet_id" {
  description = "Resource ID of the Azure Bastion subnet"
  value       = azurerm_subnet.bastion.id
}

output "bastion_host_fqdn" {
  description = "FQDN of the Azure Bastion host"
  value       = azurerm_bastion_host.cmmc_bastion.dns_name
}

# Security Outputs
output "key_vault_id" {
  description = "Resource ID of the CMMC Key Vault"
  value       = azurerm_key_vault.cmmc_vault.id
}

output "key_vault_name" {
  description = "Name of the CMMC Key Vault"
  value       = azurerm_key_vault.cmmc_vault.name
}

output "key_vault_uri" {
  description = "URI of the CMMC Key Vault"
  value       = azurerm_key_vault.cmmc_vault.vault_uri
}

output "security_center_subscription_pricing_id" {
  description = "Resource ID of Security Center subscription pricing"
  value       = azurerm_security_center_subscription_pricing.cmmc.id
}

# Database Outputs
output "sql_server_id" {
  description = "Resource ID of the SQL Server"
  value       = azurerm_mssql_server.cmmc_sql.id
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.cmmc_sql.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.cmmc_sql.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "Resource ID of the SQL Database"
  value       = azurerm_mssql_database.cmmc_db.id
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.cmmc_db.name
}

# Storage Outputs
output "storage_account_id" {
  description = "Resource ID of the primary storage account"
  value       = azurerm_storage_account.cmmc_storage.id
}

output "storage_account_name" {
  description = "Name of the primary storage account"
  value       = azurerm_storage_account.cmmc_storage.name
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.cmmc_storage.primary_blob_endpoint
}

output "log_storage_account_id" {
  description = "Resource ID of the log storage account"
  value       = azurerm_storage_account.cmmc_log_storage.id
}

output "log_storage_account_name" {
  description = "Name of the log storage account"
  value       = azurerm_storage_account.cmmc_log_storage.name
}

# Monitoring Outputs
output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.cmmc_logs.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.cmmc_logs.name
}

output "log_analytics_workspace_resource_id" {
  description = "Resource ID of the Log Analytics workspace for linking"
  value       = azurerm_log_analytics_workspace.cmmc_logs.workspace_id
}

output "application_insights_id" {
  description = "Resource ID of Application Insights"
  value       = azurerm_application_insights.cmmc_insights.id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.cmmc_insights.instrumentation_key
  sensitive   = true
}

# Virtual Machine Outputs
output "jump_box_vm_id" {
  description = "Resource ID of the jump box virtual machine"
  value       = azurerm_windows_virtual_machine.jump_box.id
}

output "jump_box_vm_name" {
  description = "Name of the jump box virtual machine"
  value       = azurerm_windows_virtual_machine.jump_box.name
}

output "jump_box_private_ip" {
  description = "Private IP address of the jump box"
  value       = azurerm_network_interface.jump_box_nic.private_ip_address
}

# Recovery Services Outputs
output "recovery_vault_id" {
  description = "Resource ID of the Recovery Services vault"
  value       = azurerm_recovery_services_vault.cmmc_vault.id
}

output "recovery_vault_name" {
  description = "Name of the Recovery Services vault"
  value       = azurerm_recovery_services_vault.cmmc_vault.name
}

# Network Security Outputs
output "network_security_group_id" {
  description = "Resource ID of the main network security group"
  value       = azurerm_network_security_group.cmmc_nsg.id
}

output "network_security_group_name" {
  description = "Name of the main network security group"
  value       = azurerm_network_security_group.cmmc_nsg.name
}

# Automation Outputs
output "automation_account_id" {
  description = "Resource ID of the Azure Automation account"
  value       = azurerm_automation_account.cmmc_automation.id
}

output "automation_account_name" {
  description = "Name of the Azure Automation account"
  value       = azurerm_automation_account.cmmc_automation.name
}

# Compliance and Tagging Outputs
output "resource_tags" {
  description = "Common tags applied to all resources"
  value = {
    Environment         = var.environment
    Project            = var.project_name
    Owner              = var.resource_owner
    CostCenter         = var.cost_center
    SecurityClassification = var.security_classification
    CMMCLevel          = var.cmmc_level
    NISTBaseline       = var.nist_baseline
    DeploymentDate     = formatdate("YYYY-MM-DD", timestamp())
  }
}

# Connectivity Outputs
output "vpn_gateway_id" {
  description = "Resource ID of the VPN Gateway (if deployed)"
  value       = var.environment == "prod" ? azurerm_virtual_network_gateway.vpn_gateway[0].id : null
}

output "vpn_gateway_public_ip" {
  description = "Public IP address of the VPN Gateway (if deployed)"
  value       = var.environment == "prod" ? azurerm_public_ip.vpn_gateway_pip[0].ip_address : null
}

# Cost Management Outputs
output "budget_id" {
  description = "Resource ID of the cost management budget"
  value       = azurerm_consumption_budget_subscription.cmmc_budget.id
}

output "budget_name" {
  description = "Name of the cost management budget"
  value       = azurerm_consumption_budget_subscription.cmmc_budget.name
}

# CMMC Specific Outputs
output "cmmc_compliance_status" {
  description = "CMMC compliance configuration summary"
  value = {
    cmmc_level                = var.cmmc_level
    nist_baseline            = var.nist_baseline
    fedramp_controls_enabled = var.enable_fedramp_controls
    cui_categories_supported = var.cui_categories
    log_retention_days       = var.log_retention_days
    backup_retention_days    = var.backup_retention_days
  }
}

output "encryption_configuration" {
  description = "Encryption configuration summary"
  value = {
    customer_managed_keys_enabled = var.enable_customer_managed_keys
    key_vault_hsm_enabled         = true
    encryption_at_rest_enabled    = true
    encryption_in_transit_enabled = true
    tls_version                   = "1.3"
  }
}

output "security_services_status" {
  description = "Security services deployment status"
  value = {
    azure_security_center_enabled    = var.enable_security_center
    security_center_pricing_tier     = var.security_center_pricing_tier
    azure_sentinel_enabled           = var.enable_sentinel
    advanced_threat_protection       = var.enable_advanced_threat_protection
    vulnerability_assessment_enabled = var.vulnerability_assessment_enabled
  }
}

# Connection Information for Applications
output "connection_info" {
  description = "Connection information for applications and integrations"
  value = {
    sql_server_connection_string = "Server=${azurerm_mssql_server.cmmc_sql.fully_qualified_domain_name};Database=${azurerm_mssql_database.cmmc_db.name};Authentication=Active Directory Integrated;Encrypt=true;"
    storage_connection_string    = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.cmmc_storage.name};AccountKey=[KEY];EndpointSuffix=core.usgovcloudapi.net"
    key_vault_endpoint          = azurerm_key_vault.cmmc_vault.vault_uri
    log_analytics_workspace_id  = azurerm_log_analytics_workspace.cmmc_logs.workspace_id
  }
  sensitive = true
}

# DNS Information
output "private_dns_zones" {
  description = "Private DNS zones created for the CMMC environment"
  value = {
    storage_dns_zone = "privatelink.blob.core.usgovcloudapi.net"
    sql_dns_zone     = "privatelink.database.usgovcloudapi.net"
    vault_dns_zone   = "privatelink.vaultcore.usgovcloudapi.net"
  }
}

# Disaster Recovery Outputs
output "disaster_recovery_config" {
  description = "Disaster recovery configuration"
  value = {
    cross_region_replication_enabled = var.enable_cross_region_replication
    disaster_recovery_region         = var.dr_region
    recovery_time_objective_hours    = var.rto_hours
    recovery_point_objective_hours   = var.rpo_hours
    backup_vault_name               = azurerm_recovery_services_vault.cmmc_vault.name
  }
}

# Deployment Metadata
output "deployment_info" {
  description = "Deployment metadata and information"
  value = {
    deployment_id           = random_id.deployment_id.hex
    deployment_timestamp    = timestamp()
    terraform_version      = "~> 1.0"
    azure_provider_version = "~> 3.0"
    azure_environment      = var.azure_environment
    deployment_region       = var.azure_region
  }
}

# Compliance Monitoring Configuration
output "compliance_monitoring_config" {
  description = "Compliance monitoring configuration details"
  value = {
    assessment_schedule       = "daily"
    reporting_frequency      = "weekly"
    automated_controls_count = 85
    manual_controls_count    = 15
    semi_automated_count     = 10
    total_controls_count     = 110
  }
}

# Network Access Information
output "network_access_info" {
  description = "Network access information for administrators"
  value = {
    bastion_connection_instructions = "Connect to ${azurerm_bastion_host.cmmc_bastion.dns_name} using Azure Bastion from the Azure portal"
    jump_box_access_method         = "Use Azure Bastion to connect to ${azurerm_windows_virtual_machine.jump_box.name}"
    management_subnet_cidr         = azurerm_subnet.management.address_prefixes[0]
    workload_subnet_cidr          = azurerm_subnet.workload.address_prefixes[0]
    data_subnet_cidr              = azurerm_subnet.data.address_prefixes[0]
  }
}

# Security Contact Information
output "security_contacts" {
  description = "Security contact information for alerts and incidents"
  value = {
    security_alert_emails      = var.security_alert_emails
    incident_response_emails   = var.incident_response_team_emails
    threat_detection_enabled   = var.enable_advanced_threat_protection
    retention_days            = var.threat_detection_retention_days
  }
  sensitive = true
}

# Cost Information
output "cost_management" {
  description = "Cost management configuration"
  value = {
    monthly_budget_amount    = var.budget_amount
    budget_alert_thresholds = var.budget_alert_thresholds
    cost_optimization      = var.cost_optimization_enabled
    estimated_monthly_cost = "Contact Microsoft for current pricing"
  }
}