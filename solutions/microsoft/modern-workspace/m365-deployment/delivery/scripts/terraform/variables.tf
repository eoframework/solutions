# Microsoft 365 Enterprise Deployment - Terraform Variables
# 
# This file defines all input variables for the Microsoft 365 Terraform configuration.
# Customize values in terraform.tfvars or pass via command line.

# ==============================================================================
# TENANT CONFIGURATION
# ==============================================================================

variable "tenant_id" {
  description = "Azure Active Directory tenant ID"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.tenant_id))
    error_message = "Tenant ID must be a valid UUID format."
  }
}

variable "tenant_domain" {
  description = "Primary domain name for the Microsoft 365 tenant (e.g., contoso.onmicrosoft.com or contoso.com)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,}$", var.tenant_domain))
    error_message = "Tenant domain must be a valid domain name."
  }
}

variable "subscription_id" {
  description = "Azure subscription ID for supporting resources"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "Subscription ID must be a valid UUID format."
  }
}

# ==============================================================================
# ORGANIZATION CONFIGURATION
# ==============================================================================

variable "organization_name" {
  description = "Organization name for resource naming (alphanumeric only, max 10 chars)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{1,10}$", var.organization_name))
    error_message = "Organization name must be alphanumeric and max 10 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, test, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "departments" {
  description = "List of department names for organizational structure"
  type        = list(string)
  default = [
    "Executive",
    "Human Resources",
    "Information Technology",
    "Finance",
    "Marketing",
    "Sales",
    "Operations",
    "Legal",
    "Customer Service"
  ]
  validation {
    condition     = length(var.departments) > 0 && length(var.departments) <= 20
    error_message = "Must specify between 1 and 20 departments."
  }
}

variable "company_size" {
  description = "Approximate number of employees for capacity planning"
  type        = number
  default     = 500
  validation {
    condition     = var.company_size > 0 && var.company_size <= 100000
    error_message = "Company size must be between 1 and 100,000 employees."
  }
}

# ==============================================================================
# SECURITY CONFIGURATION
# ==============================================================================

variable "emergency_account_passwords" {
  description = "Strong passwords for emergency access accounts (must provide exactly 2)"
  type        = list(string)
  sensitive   = true
  validation {
    condition     = length(var.emergency_account_passwords) == 2
    error_message = "Must provide exactly 2 emergency account passwords."
  }
  validation {
    condition = alltrue([
      for password in var.emergency_account_passwords :
      length(password) >= 16 && 
      can(regex("[A-Z]", password)) && 
      can(regex("[a-z]", password)) && 
      can(regex("[0-9]", password)) && 
      can(regex("[^A-Za-z0-9]", password))
    ])
    error_message = "Emergency passwords must be at least 16 characters with uppercase, lowercase, numbers, and special characters."
  }
}

variable "corporate_ip_ranges" {
  description = "List of corporate IP address ranges for trusted locations (CIDR format)"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for ip_range in var.corporate_ip_ranges :
      can(cidrhost(ip_range, 0))
    ])
    error_message = "All IP ranges must be in valid CIDR format (e.g., 192.168.1.0/24)."
  }
}

variable "blocked_countries" {
  description = "List of country codes to block access from (ISO 3166-1 alpha-2 format)"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for country in var.blocked_countries :
      can(regex("^[A-Z]{2}$", country))
    ])
    error_message = "Country codes must be 2-letter ISO 3166-1 alpha-2 format (e.g., CN, RU)."
  }
}

variable "enable_identity_protection" {
  description = "Enable Azure AD Identity Protection features (requires Azure AD Premium P2)"
  type        = bool
  default     = true
}

variable "enable_conditional_access" {
  description = "Deploy conditional access policies"
  type        = bool
  default     = true
}

variable "mfa_enforcement_mode" {
  description = "MFA enforcement mode: enforced, enabled, or disabled"
  type        = string
  default     = "enabled"
  validation {
    condition     = contains(["enforced", "enabled", "disabled"], var.mfa_enforcement_mode)
    error_message = "MFA enforcement mode must be one of: enforced, enabled, disabled."
  }
}

# ==============================================================================
# COMPLIANCE AND GOVERNANCE
# ==============================================================================

variable "compliance_requirements" {
  description = "List of compliance frameworks to configure for (affects policies and settings)"
  type        = list(string)
  default     = ["GDPR", "ISO27001"]
  validation {
    condition = alltrue([
      for req in var.compliance_requirements :
      contains(["GDPR", "HIPAA", "SOX", "PCI-DSS", "ISO27001", "NIST", "SOC2"], req)
    ])
    error_message = "Compliance requirements must be from: GDPR, HIPAA, SOX, PCI-DSS, ISO27001, NIST, SOC2."
  }
}

variable "data_residency_region" {
  description = "Primary data residency region for compliance"
  type        = string
  default     = "United States"
  validation {
    condition = contains([
      "United States", "Europe", "Asia Pacific", "Canada", 
      "United Kingdom", "France", "Germany", "Australia", "Japan"
    ], var.data_residency_region)
    error_message = "Data residency region must be a valid Microsoft 365 data center region."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 365
  validation {
    condition     = var.log_retention_days >= 90 && var.log_retention_days <= 2555
    error_message = "Log retention must be between 90 and 2555 days (7 years)."
  }
}

variable "compliance_retention_days" {
  description = "Number of days to retain compliance data"
  type        = number
  default     = 2555  # 7 years
  validation {
    condition     = var.compliance_retention_days >= 365 && var.compliance_retention_days <= 2555
    error_message = "Compliance retention must be between 365 and 2555 days."
  }
}

# ==============================================================================
# AZURE RESOURCES CONFIGURATION
# ==============================================================================

variable "azure_region" {
  description = "Azure region for supporting resources (should match M365 data residency)"
  type        = string
  default     = "East US"
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "Central US",
      "North Europe", "West Europe", "UK South", "France Central",
      "Germany West Central", "Southeast Asia", "East Asia", "Japan East",
      "Australia East", "Canada Central"
    ], var.azure_region)
    error_message = "Azure region must be a valid region with Microsoft 365 service availability."
  }
}

variable "enable_azure_resources" {
  description = "Deploy supporting Azure resources (Key Vault, Log Analytics, Storage)"
  type        = bool
  default     = true
}

variable "key_vault_sku" {
  description = "Key Vault SKU: standard or premium"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either standard or premium."
  }
}

# ==============================================================================
# LICENSING AND FEATURES
# ==============================================================================

variable "m365_license_type" {
  description = "Microsoft 365 license type for user assignment planning"
  type        = string
  default     = "E5"
  validation {
    condition     = contains(["E3", "E5", "Business Premium", "A3", "A5"], var.m365_license_type)
    error_message = "License type must be one of: E3, E5, Business Premium, A3, A5."
  }
}

variable "enable_teams_voice" {
  description = "Enable Microsoft Teams voice features (Phone System)"
  type        = bool
  default     = false
}

variable "enable_power_platform" {
  description = "Enable Power Platform integration and governance"
  type        = bool
  default     = true
}

variable "enable_viva_suite" {
  description = "Enable Microsoft Viva suite features"
  type        = bool
  default     = true
}

# ==============================================================================
# AUTOMATION AND INTEGRATION
# ==============================================================================

variable "enable_automation_account" {
  description = "Create service principal for automation and API access"
  type        = bool
  default     = true
}

variable "automation_permissions" {
  description = "List of Microsoft Graph permissions for automation account"
  type        = list(string)
  default = [
    "Directory.ReadWrite.All",
    "Group.ReadWrite.All", 
    "User.ReadWrite.All",
    "Application.ReadWrite.All",
    "Policy.ReadWrite.ConditionalAccess",
    "RoleManagement.ReadWrite.Directory"
  ]
}

variable "webhook_endpoints" {
  description = "List of webhook endpoints for integration notifications"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for endpoint in var.webhook_endpoints :
      can(regex("^https://", endpoint))
    ])
    error_message = "All webhook endpoints must use HTTPS."
  }
}

# ==============================================================================
# DEPLOYMENT CONFIGURATION
# ==============================================================================

variable "deployment_phases" {
  description = "Deployment phases to include in this run"
  type        = list(string)
  default     = ["foundation", "security", "governance", "integration"]
  validation {
    condition = alltrue([
      for phase in var.deployment_phases :
      contains(["foundation", "security", "governance", "integration", "automation"], phase)
    ])
    error_message = "Deployment phases must be from: foundation, security, governance, integration, automation."
  }
}

variable "enable_pilot_mode" {
  description = "Deploy in pilot mode with reduced scope and test settings"
  type        = bool
  default     = false
}

variable "pilot_users" {
  description = "List of user principal names for pilot deployment (required if pilot_mode is true)"
  type        = list(string)
  default     = []
}

variable "export_configuration" {
  description = "Export deployment configuration to JSON file for external tools"
  type        = bool
  default     = true
}

variable "create_documentation" {
  description = "Auto-generate deployment documentation and runbooks"
  type        = bool
  default     = true
}

# ==============================================================================
# ADVANCED CONFIGURATION
# ==============================================================================

variable "custom_attributes" {
  description = "Custom attributes for organizational needs"
  type        = map(string)
  default     = {}
}

variable "integration_settings" {
  description = "Settings for third-party integrations"
  type = object({
    enable_siem_integration = optional(bool, false)
    siem_workspace_id      = optional(string, "")
    enable_hr_integration  = optional(bool, false)
    hr_system_endpoint     = optional(string, "")
  })
  default = {}
}

variable "advanced_security_settings" {
  description = "Advanced security configuration options"
  type = object({
    session_timeout_hours        = optional(number, 8)
    require_password_change_days = optional(number, 90)
    account_lockout_threshold    = optional(number, 5)
    enable_risk_based_policies   = optional(bool, true)
    enable_privileged_access     = optional(bool, true)
  })
  default = {}
}