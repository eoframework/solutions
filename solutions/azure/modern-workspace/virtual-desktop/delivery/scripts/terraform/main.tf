# Azure Virtual Desktop Infrastructure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "avd" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "avd" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.avd.location
  resource_group_name = azurerm_resource_group.avd.name
  tags                = var.tags
}

# Subnet for AVD Session Hosts
resource "azurerm_subnet" "avd_hosts" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.avd.name
  virtual_network_name = azurerm_virtual_network.avd.name
  address_prefixes     = var.subnet_address_prefixes
}

# Network Security Group
resource "azurerm_network_security_group" "avd" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.avd.location
  resource_group_name = azurerm_resource_group.avd.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-AVD-Traffic"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "WindowsVirtualDesktop"
  }

  security_rule {
    name                       = "Allow-Azure-KMS"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1688"
    source_address_prefix      = "*"
    destination_address_prefix = "23.102.135.246"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "avd" {
  subnet_id                 = azurerm_subnet.avd_hosts.id
  network_security_group_id = azurerm_network_security_group.avd.id
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "avd" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.avd.location
  resource_group_name = azurerm_resource_group.avd.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Storage Account for FSLogix Profiles
resource "azurerm_storage_account" "profiles" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.avd.name
  location                 = azurerm_resource_group.avd.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
  
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.avd_hosts.id]
  }
  
  tags = var.tags
}

# File Share for Profiles
resource "azurerm_storage_share" "profiles" {
  name                 = "profiles"
  storage_account_name = azurerm_storage_account.profiles.name
  quota                = var.profiles_share_quota
}

# AVD Host Pool
resource "azurerm_virtual_desktop_host_pool" "main" {
  name                     = var.host_pool_name
  location                 = azurerm_resource_group.avd.location
  resource_group_name      = azurerm_resource_group.avd.name
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = var.max_sessions_per_host
  
  tags = var.tags
}

# AVD Workspace
resource "azurerm_virtual_desktop_workspace" "main" {
  name                = var.workspace_name
  location            = azurerm_resource_group.avd.location
  resource_group_name = azurerm_resource_group.avd.name
  
  tags = var.tags
}

# AVD Application Group
resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = "${var.prefix}-desktop-appgroup"
  location            = azurerm_resource_group.avd.location
  resource_group_name = azurerm_resource_group.avd.name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.main.id
  
  tags = var.tags
}

# Associate Application Group with Workspace
resource "azurerm_virtual_desktop_workspace_application_group_association" "main" {
  workspace_id         = azurerm_virtual_desktop_workspace.main.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

# Session Host VMs
resource "azurerm_network_interface" "session_hosts" {
  count               = var.session_host_count
  name                = "${var.prefix}-nic-${count.index + 1}"
  location            = azurerm_resource_group.avd.location
  resource_group_name = azurerm_resource_group.avd.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.avd_hosts.id
    private_ip_address_allocation = "Dynamic"
  }
  
  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "session_hosts" {
  count               = var.session_host_count
  name                = "${var.prefix}-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.avd.name
  location            = azurerm_resource_group.avd.location
  size                = var.session_host_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.session_hosts[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_SSD"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-21h2-ent"
    version   = "latest"
  }
  
  tags = var.tags
}

# VM Extension to join AVD Host Pool
resource "azurerm_virtual_machine_extension" "avd_agent" {
  count                = var.session_host_count
  name                 = "AVDAgent"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_hosts[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris = ["https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip"]
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File AVDAgentInstall.ps1 -RegistrationToken ${azurerm_virtual_desktop_host_pool.main.registration_info[0].token}"
  })

  depends_on = [
    azurerm_virtual_desktop_host_pool.main
  ]
}