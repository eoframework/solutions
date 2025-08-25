# Microsoft CMMC Enclave - Terraform Infrastructure
# CMMC Level 2 compliant Azure Government cloud environment

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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure providers for Azure Government
provider "azurerm" {
  environment = var.azure_environment
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

provider "azuread" {
  environment = var.azure_environment
}

# Local values
locals {
  # Common tags for CMMC compliance
  common_tags = {
    Environment           = var.environment
    Project              = var.project_name
    Solution             = "Microsoft CMMC Enclave"
    "CMMC-Level"         = "Level-2"
    "Data-Classification" = "CUI"
    "Compliance-Framework" = "NIST-SP-800-171"
    CreatedBy            = "Terraform"
    Owner                = var.resource_owner
    CostCenter           = var.cost_center
    "Security-Classification" = var.security_classification
  }
  
  # CMMC resource naming convention
  resource_prefix = "${var.project_name}-${var.environment}-cmmc"
  
  # CUI data classification labels
  cui_labels = [
    "Public",
    "Internal", 
    "General",
    "Confidential",
    "Highly Confidential",
    "CUI",
    "CUI//SP"
  ]
}

# Data sources
data "azurerm_client_config" "current" {}

data "azuread_domains" "default" {
  only_initial = true
}

# Random resources for unique naming
resource "random_id" "deployment_id" {
  byte_length = 4
}

resource "random_password" "admin_password" {
  length  = 24
  special = true
}

# Resource Groups
resource "azurerm_resource_group" "cmmc_core" {
  name     = "${local.resource_prefix}-core-rg"
  location = var.azure_region
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Core Infrastructure"
    "Data-Residency" = "US-Government"
  })
}

resource "azurerm_resource_group" "cmmc_security" {
  name     = "${local.resource_prefix}-security-rg"
  location = var.azure_region
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Security Services"
    "Security-Controls" = "AC,AU,CM,IA,IR,SC,SI"
  })
}

resource "azurerm_resource_group" "cmmc_data" {
  name     = "${local.resource_prefix}-data-rg"
  location = var.azure_region
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Data Protection"
    "Data-Controls" = "MP,PE,RA,RE"
  })
}

# Virtual Network with CMMC segmentation
resource "azurerm_virtual_network" "cmmc_vnet" {
  name                = "${local.resource_prefix}-vnet"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.cmmc_core.location
  resource_group_name = azurerm_resource_group.cmmc_core.name
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Network Segmentation"
    "Network-Controls" = "SC-7,SC-32"
  })
}

# Subnets for CMMC zones
resource "azurerm_subnet" "management_subnet" {
  name                 = "${local.resource_prefix}-management-subnet"
  resource_group_name  = azurerm_resource_group.cmmc_core.name
  virtual_network_name = azurerm_virtual_network.cmmc_vnet.name
  address_prefixes     = [var.management_subnet_prefix]
  
  # Enable private endpoints
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet" "workload_subnet" {
  name                 = "${local.resource_prefix}-workload-subnet"
  resource_group_name  = azurerm_resource_group.cmmc_core.name
  virtual_network_name = azurerm_virtual_network.cmmc_vnet.name
  address_prefixes     = [var.workload_subnet_prefix]
  
  # Enable private endpoints
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet" "data_subnet" {
  name                 = "${local.resource_prefix}-data-subnet"
  resource_group_name  = azurerm_resource_group.cmmc_core.name
  virtual_network_name = azurerm_virtual_network.cmmc_vnet.name
  address_prefixes     = [var.data_subnet_prefix]
  
  # Enable private endpoints
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.cmmc_core.name
  virtual_network_name = azurerm_virtual_network.cmmc_vnet.name
  address_prefixes     = [var.gateway_subnet_prefix]
}

# Network Security Groups for CMMC controls
resource "azurerm_network_security_group" "management_nsg" {
  name                = "${local.resource_prefix}-management-nsg"
  location            = azurerm_resource_group.cmmc_core.location
  resource_group_name = azurerm_resource_group.cmmc_core.name
  
  # Management access rules (SC-7)
  security_rule {
    name                       = "Allow-RDP-from-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.bastion_subnet_prefix
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Allow-SSH-from-Bastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.bastion_subnet_prefix
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "Management Zone Security"
    "CMMC-Controls" = "SC-7,AC-4"
  })
}

resource "azurerm_network_security_group" "workload_nsg" {
  name                = "${local.resource_prefix}-workload-nsg"
  location            = azurerm_resource_group.cmmc_core.location
  resource_group_name = azurerm_resource_group.cmmc_core.name
  
  # Application traffic rules
  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Allow-HTTP-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "Workload Zone Security"
    "CMMC-Controls" = "SC-7,AC-4"
  })
}

resource "azurerm_network_security_group" "data_nsg" {
  name                = "${local.resource_prefix}-data-nsg"
  location            = azurerm_resource_group.cmmc_core.location
  resource_group_name = azurerm_resource_group.cmmc_core.name
  
  # Data access rules (most restrictive)
  security_rule {
    name                       = "Allow-SQL-from-Workload"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.workload_subnet_prefix
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Deny-All-Internet"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "Data Zone Security"
    "CMMC-Controls" = "SC-7,MP-6,PE-3"
  })
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "management_nsg_association" {
  subnet_id                 = azurerm_subnet.management_subnet.id
  network_security_group_id = azurerm_network_security_group.management_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "workload_nsg_association" {
  subnet_id                 = azurerm_subnet.workload_subnet.id
  network_security_group_id = azurerm_network_security_group.workload_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "data_nsg_association" {
  subnet_id                 = azurerm_subnet.data_subnet.id
  network_security_group_id = azurerm_network_security_group.data_nsg.id
}

# Key Vault for CMMC secrets management (IA-5, SC-12)
resource "azurerm_key_vault" "cmmc_vault" {
  name                        = "${local.resource_prefix}-kv-${random_id.deployment_id.hex}"
  location                    = azurerm_resource_group.cmmc_security.location
  resource_group_name         = azurerm_resource_group.cmmc_security.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  sku_name                   = "premium"  # HSM-backed for CMMC
  
  # Enable CMMC logging requirements
  enable_rbac_authorization = true
  
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.management_subnet.id,
      azurerm_subnet.workload_subnet.id
    ]
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Cryptographic Key Management"
    "CMMC-Controls" = "IA-5,SC-12,SC-13"
  })
}

# Log Analytics Workspace for CMMC audit requirements (AU-2, AU-3)
resource "azurerm_log_analytics_workspace" "cmmc_logs" {
  name                = "${local.resource_prefix}-logs"
  location            = azurerm_resource_group.cmmc_security.location
  resource_group_name = azurerm_resource_group.cmmc_security.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Audit and Logging"
    "CMMC-Controls" = "AU-2,AU-3,AU-6,AU-12"
  })
}

# Azure Sentinel for CMMC SIEM requirements (IR-4, SI-4)
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "cmmc_sentinel" {
  workspace_id                 = azurerm_log_analytics_workspace.cmmc_logs.id
  customer_managed_key_enabled = var.enable_customer_managed_keys
}

# Storage Account for CMMC data with encryption (SC-28)
resource "azurerm_storage_account" "cmmc_storage" {
  name                     = "${replace(local.resource_prefix, "-", "")}st${random_id.deployment_id.hex}"
  resource_group_name      = azurerm_resource_group.cmmc_data.name
  location                 = azurerm_resource_group.cmmc_data.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"  # Zone-redundant for CMMC
  
  # CMMC encryption requirements
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  
  # Advanced threat protection
  queue_encryption_key_type = "Account"
  table_encryption_key_type = "Account"
  
  identity {
    type = "SystemAssigned"
  }
  
  blob_properties {
    versioning_enabled       = true
    change_feed_enabled     = true
    last_access_time_enabled = true
    
    delete_retention_policy {
      days = var.blob_retention_days
    }
    
    container_delete_retention_policy {
      days = var.container_retention_days
    }
  }
  
  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.data_subnet.id,
      azurerm_subnet.workload_subnet.id
    ]
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Data Storage"
    "CMMC-Controls" = "SC-28,MP-6,AU-9"
  })
}

# Azure SQL Database with CUI data classification
resource "azurerm_mssql_server" "cmmc_sql_server" {
  name                         = "${local.resource_prefix}-sql-${random_id.deployment_id.hex}"
  resource_group_name          = azurerm_resource_group.cmmc_data.name
  location                     = azurerm_resource_group.cmmc_data.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.admin_password.result
  
  # CMMC security requirements
  minimum_tls_version               = "1.2"
  public_network_access_enabled     = false
  outbound_network_access_restricted = true
  
  azuread_administrator {
    login_username = var.sql_aad_admin_login
    object_id      = var.sql_aad_admin_object_id
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Database Server"
    "CMMC-Controls" = "IA-2,IA-5,SC-8,SC-23"
  })
}

resource "azurerm_mssql_database" "cmmc_database" {
  name           = "${local.resource_prefix}-db"
  server_id      = azurerm_mssql_server.cmmc_sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = var.database_max_size_gb
  sku_name       = var.database_sku_name
  
  # Enable advanced data security
  threat_detection_policy {
    state                      = "Enabled"
    email_addresses           = var.security_alert_emails
    retention_days            = var.threat_detection_retention_days
    storage_endpoint          = azurerm_storage_account.cmmc_storage.primary_blob_endpoint
    storage_account_access_key = azurerm_storage_account.cmmc_storage.primary_access_key
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC CUI Database"
    "Data-Classification" = "CUI"
    "CMMC-Controls" = "SI-4,IR-4,AU-12"
  })
}

# Data classification and labeling with Microsoft Purview
resource "azurerm_purview_account" "cmmc_purview" {
  name                = "${local.resource_prefix}-purview-${random_id.deployment_id.hex}"
  resource_group_name = azurerm_resource_group.cmmc_security.name
  location            = azurerm_resource_group.cmmc_security.location
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Data Governance and Classification"
    "CMMC-Controls" = "MP-6,RA-2,CM-8"
  })
}

# Azure Bastion for secure access (AC-17)
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.cmmc_core.name
  virtual_network_name = azurerm_virtual_network.cmmc_vnet.name
  address_prefixes     = [var.bastion_subnet_prefix]
}

resource "azurerm_public_ip" "bastion_ip" {
  name                = "${local.resource_prefix}-bastion-ip"
  location            = azurerm_resource_group.cmmc_core.location
  resource_group_name = azurerm_resource_group.cmmc_core.name
  allocation_method   = "Static"
  sku                = "Standard"
  
  tags = merge(local.common_tags, {
    Purpose = "Bastion Host Public IP"
    "CMMC-Controls" = "AC-17,SC-7"
  })
}

resource "azurerm_bastion_host" "cmmc_bastion" {
  name                = "${local.resource_prefix}-bastion"
  location            = azurerm_resource_group.cmmc_core.location
  resource_group_name = azurerm_resource_group.cmmc_core.name
  
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Secure Remote Access"
    "CMMC-Controls" = "AC-17,IA-2,SC-7"
  })
}

# Azure Security Center (Defender) for CMMC continuous monitoring
resource "azurerm_security_center_workspace" "cmmc_security_center" {
  scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  workspace_id = azurerm_log_analytics_workspace.cmmc_logs.id
}

# Microsoft Defender for Cloud Apps integration
resource "azurerm_security_center_setting" "mcas" {
  setting_name   = "MCAS"
  enabled        = true
}

# Data Loss Prevention policies
resource "azurerm_security_center_setting" "wdatp" {
  setting_name   = "WDATP"
  enabled        = true
}

# Backup vault for CMMC data protection (RE-2, RE-3)
resource "azurerm_data_protection_backup_vault" "cmmc_backup_vault" {
  name                = "${local.resource_prefix}-backup-vault"
  resource_group_name = azurerm_resource_group.cmmc_data.name
  location            = azurerm_resource_group.cmmc_data.location
  datastore_type      = "VaultStore"
  redundancy          = "ZoneRedundant"
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Data Protection and Recovery"
    "CMMC-Controls" = "RE-2,RE-3,CP-9"
  })
}

# Virtual Machine for CMMC workloads
resource "azurerm_network_interface" "cmmc_vm_nic" {
  name                = "${local.resource_prefix}-vm-nic"
  location            = azurerm_resource_group.cmmc_core.location
  resource_group_name = azurerm_resource_group.cmmc_core.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.workload_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC VM Network Interface"
  })
}

resource "azurerm_windows_virtual_machine" "cmmc_vm" {
  name                = "${local.resource_prefix}-vm"
  resource_group_name = azurerm_resource_group.cmmc_core.name
  location            = azurerm_resource_group.cmmc_core.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = random_password.admin_password.result
  
  # CMMC security baseline
  patch_mode      = "AutomaticByPlatform"
  hotpatching_enabled = true
  
  network_interface_ids = [
    azurerm_network_interface.cmmc_vm_nic.id,
  ]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_ZRS"
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Windows Workload"
    "CMMC-Controls" = "CM-2,CM-6,SI-2,SI-3"
  })
}

# Enable disk encryption for CMMC compliance (SC-28)
resource "azurerm_disk_encryption_set" "cmmc_encryption" {
  name                = "${local.resource_prefix}-disk-encryption"
  resource_group_name = azurerm_resource_group.cmmc_security.name
  location            = azurerm_resource_group.cmmc_security.location
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption_key.id
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Disk Encryption"
    "CMMC-Controls" = "SC-28,SC-13"
  })
}

resource "azurerm_key_vault_key" "disk_encryption_key" {
  name         = "cmmc-disk-encryption-key"
  key_vault_id = azurerm_key_vault.cmmc_vault.id
  key_type     = "RSA-HSM"
  key_size     = 4096
  
  depends_on = [
    azurerm_key_vault_access_policy.terraform_policy
  ]
  
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  
  tags = merge(local.common_tags, {
    Purpose = "CMMC Disk Encryption Key"
    "CMMC-Controls" = "SC-12,SC-13"
  })
}

# Key Vault access policies for CMMC
resource "azurerm_key_vault_access_policy" "terraform_policy" {
  key_vault_id = azurerm_key_vault.cmmc_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  
  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
  
  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "Recover"
  ]
}

resource "azurerm_key_vault_access_policy" "disk_encryption_policy" {
  key_vault_id = azurerm_key_vault.cmmc_vault.id
  tenant_id    = azurerm_disk_encryption_set.cmmc_encryption.identity[0].tenant_id
  object_id    = azurerm_disk_encryption_set.cmmc_encryption.identity[0].principal_id
  
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

# Azure Policy for CMMC compliance
resource "azurerm_policy_assignment" "cmmc_policies" {
  name                 = "cmmc-level2-policies"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/179d1daa-458f-4e47-8086-2a68d0d6c38f" # NIST SP 800-171 Rev. 2
  description          = "CMMC Level 2 compliance policies based on NIST SP 800-171"
  display_name         = "CMMC Level 2 Compliance"
  
  parameters = jsonencode({
    logAnalyticsWorkspaceIdforVMReporting = {
      value = azurerm_log_analytics_workspace.cmmc_logs.id
    }
  })
  
  identity {
    type = "SystemAssigned"
  }
}

# Diagnostic settings for CMMC audit requirements
resource "azurerm_monitor_diagnostic_setting" "key_vault_diagnostics" {
  name               = "cmmc-keyvault-diagnostics"
  target_resource_id = azurerm_key_vault.cmmc_vault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.cmmc_logs.id
  
  log {
    category = "AuditEvent"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  
  metric {
    category = "AllMetrics"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
  name               = "cmmc-storage-diagnostics"
  target_resource_id = azurerm_storage_account.cmmc_storage.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.cmmc_logs.id
  
  log {
    category = "StorageWrite"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  
  log {
    category = "StorageDelete"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  
  metric {
    category = "AllMetrics"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
}