# Azure AI Document Intelligence - Terraform Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-doc-intelligence-prod-001"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US 2"
}

variable "cognitive_services_name" {
  description = "Name of the Cognitive Services account"
  type        = string
  default     = "cs-doc-intelligence-prod-001"
}

variable "cognitive_services_sku" {
  description = "SKU for Cognitive Services"
  type        = string
  default     = "S0"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  default     = "stdocintelligence001"
}

variable "create_key_vault" {
  description = "Whether to create a Key Vault"
  type        = bool
  default     = true
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-doc-intelligence-001"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Solution    = "Document Intelligence"
  }
}