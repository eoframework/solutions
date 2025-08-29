# Azure AI Document Intelligence - Terraform Infrastructure as Code
# Main configuration for deploying Azure AI Document Intelligence solution

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {}
}

# Data sources
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "doc_intelligence" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Cognitive Services Account for Document Intelligence
resource "azurerm_cognitive_account" "document_intelligence" {
  name                = var.cognitive_services_name
  location            = azurerm_resource_group.doc_intelligence.location
  resource_group_name = azurerm_resource_group.doc_intelligence.name
  kind                = "FormRecognizer"
  sku_name           = var.cognitive_services_sku
  
  tags = var.tags
}

# Storage Account for document processing
resource "azurerm_storage_account" "document_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.doc_intelligence.name
  location                 = azurerm_resource_group.doc_intelligence.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

# Key Vault for storing sensitive information
resource "azurerm_key_vault" "doc_intelligence" {
  count = var.create_key_vault ? 1 : 0
  
  name                = var.key_vault_name
  location            = azurerm_resource_group.doc_intelligence.location
  resource_group_name = azurerm_resource_group.doc_intelligence.name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"
  
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    secret_permissions = [
      "Get", "List", "Set", "Delete"
    ]
  }
  
  tags = var.tags
}