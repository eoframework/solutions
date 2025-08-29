# Azure Sentinel SIEM - Terraform Variables
# Variable definitions for Azure Sentinel deployment

# General Configuration
variable "resource_group_name" {
  description = "Name of the resource group for Azure Sentinel resources"
  type        = string
  default     = "rg-sentinel-prod-001"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US 2"
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East", "Brazil South", "UK South", "UK West",
      "West Europe", "North Europe", "France Central", "Germany West Central",
      "Switzerland North", "Norway East", "Sweden Central",
      "Australia East", "Australia Southeast", "Japan East", "Japan West",
      "Korea Central", "Southeast Asia", "East Asia", "India Central",
      "UAE North", "South Africa North"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Solution    = "Azure Sentinel SIEM"
    CostCenter  = "Security Operations"
    Owner       = "Security Team"
  }
}

# Log Analytics Workspace Configuration
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "law-sentinel-prod-001"
}

variable "log_analytics_sku" {
  description = "SKU for the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, Standalone, PerNode, PerGB2018."
  }
}

variable "log_analytics_retention_days" {
  description = "Number of days to retain data in Log Analytics"
  type        = number
  default     = 730
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Retention days must be between 30 and 730."
  }
}

variable "log_analytics_daily_quota_gb" {
  description = "Daily ingestion quota in GB for Log Analytics (-1 for unlimited)"
  type        = number
  default     = 500
  validation {
    condition     = var.log_analytics_daily_quota_gb == -1 || var.log_analytics_daily_quota_gb >= 1
    error_message = "Daily quota must be -1 (unlimited) or >= 1 GB."
  }
}

variable "internet_ingestion_enabled" {
  description = "Enable internet ingestion for Log Analytics workspace"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Enable internet queries for Log Analytics workspace"
  type        = bool
  default     = false
}

# Azure Sentinel Configuration
variable "customer_managed_key_enabled" {
  description = "Enable customer-managed keys for Azure Sentinel"
  type        = bool
  default     = false
}

# Key Vault Configuration
variable "create_key_vault" {
  description = "Create a Key Vault for storing sensitive configuration"
  type        = bool
  default     = true
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-sentinel-prod-001"
}

# Storage Account Configuration
variable "create_storage_account" {
  description = "Create a storage account for long-term data retention"
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "stsentinelprod001"
}

# Data Connector Configuration
variable "enable_aad_connector" {
  description = "Enable Azure Active Directory data connector"
  type        = bool
  default     = true
}

variable "enable_asc_connector" {
  description = "Enable Azure Security Center data connector"
  type        = bool
  default     = true
}

variable "enable_office365_connector" {
  description = "Enable Office 365 data connector"
  type        = bool
  default     = true
}

variable "office365_exchange_enabled" {
  description = "Enable Exchange logs in Office 365 connector"
  type        = bool
  default     = true
}

variable "office365_sharepoint_enabled" {
  description = "Enable SharePoint logs in Office 365 connector"
  type        = bool
  default     = true
}

variable "office365_teams_enabled" {
  description = "Enable Teams logs in Office 365 connector"
  type        = bool
  default     = true
}

# Sample Rules and Automation
variable "create_sample_rules" {
  description = "Create sample analytics rules for demonstration"
  type        = bool
  default     = false
}

variable "create_sample_automation" {
  description = "Create sample automation rules"
  type        = bool
  default     = false
}

variable "incident_owner_object_id" {
  description = "Azure AD object ID of the default incident owner"
  type        = string
  default     = ""
}

# Network Configuration
variable "allowed_ip_ranges" {
  description = "IP ranges allowed to access the workspace"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_private_link" {
  description = "Enable private link for secure connectivity"
  type        = bool
  default     = false
}

# Monitoring and Alerting
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for audit logging"
  type        = bool
  default     = true
}

variable "diagnostic_storage_account_id" {
  description = "Storage account ID for diagnostic logs"
  type        = string
  default     = ""
}

# Cost Management
variable "enable_cost_alerts" {
  description = "Enable cost monitoring alerts"
  type        = bool
  default     = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD for cost alerts"
  type        = number
  default     = 5000
}