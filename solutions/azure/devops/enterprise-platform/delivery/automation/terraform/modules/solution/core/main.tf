#------------------------------------------------------------------------------
# Core Infrastructure Module
# Creates: Resource Group, VNet, Subnets, Key Vault
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Resource Group
#------------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "${var.name_prefix}-rg"
  location = var.location
  tags     = var.common_tags
}

#------------------------------------------------------------------------------
# Virtual Network
#------------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.network.vnet_cidr]
  tags                = var.common_tags
}

#------------------------------------------------------------------------------
# Subnets
#------------------------------------------------------------------------------
resource "azurerm_subnet" "appservice" {
  name                 = "${var.name_prefix}-appservice-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.network.appservice_subnet_cidr]

  delegation {
    name = "appservice-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "${var.name_prefix}-pe-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.network.private_endpoint_cidr]

  private_endpoint_network_policies_enabled = true
}

#------------------------------------------------------------------------------
# Key Vault
#------------------------------------------------------------------------------
resource "azurerm_key_vault" "main" {
  name                        = "${replace(var.name_prefix, "-", "")}kv"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enable_rbac_authorization   = true

  network_acls {
    bypass         = "AzureServices"
    default_action = var.network.private_endpoint_enabled ? "Deny" : "Allow"
  }

  tags = var.common_tags
}

# Grant deployer access to Key Vault
resource "azurerm_role_assignment" "deployer_kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.object_id
}
