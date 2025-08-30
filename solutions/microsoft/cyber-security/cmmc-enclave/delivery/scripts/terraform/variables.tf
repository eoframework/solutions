# Variables for Microsoft CMMC Enclave deployment

# Project Configuration
variable "project_name" {
  description = "Name of the CMMC project"
  type        = string
  default     = "cmmc-enclave"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "resource_owner" {
  description = "Owner of the CMMC resources"
  type        = string
  default     = "CMMC-Administrator"
}

variable "cost_center" {
  description = "Cost center for resource billing"
  type        = string
  default     = "Security-Operations"
}

# Azure Configuration
variable "azure_environment" {
  description = "Azure environment (AzureUSGovernment for CMMC compliance)"
  type        = string
  default     = "AzureUSGovernment"
  
  validation {
    condition     = contains(["AzureUSGovernment", "AzureCloud"], var.azure_environment)
    error_message = "Azure environment must be AzureUSGovernment or AzureCloud."
  }
}

variable "azure_region" {
  description = "Azure region for CMMC deployment"
  type        = string
  default     = "USGov Virginia"
  
  validation {
    condition = contains([
      "USGov Virginia", "USGov Texas", "USGov Arizona", "USGov Iowa",
      "East US", "East US 2", "West US", "West US 2", "Central US"
    ], var.azure_region)
    error_message = "Must use approved Azure Government or commercial regions."
  }
}

# Security Classification
variable "security_classification" {
  description = "Security classification level for CMMC"
  type        = string
  default     = "CUI"
  
  validation {
    condition     = contains(["CUI", "CUI//SP", "UNCLASSIFIED"], var.security_classification)
    error_message = "Security classification must be CUI, CUI//SP, or UNCLASSIFIED."
  }
}

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for CMMC virtual network"
  type        = string
  default     = "10.200.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "VNet address space must be a valid CIDR block."
  }
}

variable "management_subnet_prefix" {
  description = "CIDR prefix for management subnet"
  type        = string
  default     = "10.200.1.0/24"
}

variable "workload_subnet_prefix" {
  description = "CIDR prefix for workload subnet"
  type        = string
  default     = "10.200.2.0/24"
}

variable "data_subnet_prefix" {
  description = "CIDR prefix for data subnet"
  type        = string
  default     = "10.200.3.0/24"
}

variable "gateway_subnet_prefix" {
  description = "CIDR prefix for gateway subnet"
  type        = string
  default     = "10.200.4.0/24"
}

variable "bastion_subnet_prefix" {
  description = "CIDR prefix for Azure Bastion subnet"
  type        = string
  default     = "10.200.5.0/24"
}

# CMMC Compliance Configuration
variable "cmmc_level" {
  description = "CMMC compliance level (2 or 3)"
  type        = number
  default     = 2
  
  validation {
    condition     = contains([2, 3], var.cmmc_level)
    error_message = "CMMC level must be 2 or 3."
  }
}

variable "nist_baseline" {
  description = "NIST SP 800-171 baseline to implement"
  type        = string
  default     = "Rev2"
  
  validation {
    condition     = contains(["Rev1", "Rev2"], var.nist_baseline)
    error_message = "NIST baseline must be Rev1 or Rev2."
  }
}

variable "enable_fedramp_controls" {
  description = "Enable additional FedRAMP High controls"
  type        = bool
  default     = true
}

# Data Classification Configuration
variable "cui_categories" {
  description = "List of CUI categories to support"
  type        = list(string)
  default = [
    "CUI Basic",
    "CUI Specified", 
    "Export Controlled Technical Data",
    "Federal Tax Information",
    "ITAR"
  ]
}

variable "sensitivity_labels" {
  description = "Microsoft Information Protection sensitivity labels"
  type        = list(string)
  default = [
    "Public",
    "Internal",
    "General", 
    "Confidential",
    "Highly Confidential",
    "CUI",
    "CUI//SP"
  ]
}

# Logging and Audit Configuration
variable "log_retention_days" {
  description = "Log retention period in days (CMMC requires minimum 1 year)"
  type        = number
  default     = 365
  
  validation {
    condition     = var.log_retention_days >= 365
    error_message = "Log retention must be at least 365 days for CMMC compliance."
  }
}

variable "audit_log_categories" {
  description = "Categories of audit logs to collect"
  type        = list(string)
  default = [
    "AuditEvent",
    "Authentication", 
    "Authorization",
    "DataAccess",
    "PolicyChange",
    "PrivilegeEscalation",
    "SystemEvents"
  ]
}

# Database Configuration
variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "cmmc-admin"
  sensitive   = true
}

variable "sql_aad_admin_login" {
  description = "Azure AD admin login for SQL Server"
  type        = string
  default     = "CMMC-SQL-Admin"
}

variable "sql_aad_admin_object_id" {
  description = "Azure AD admin object ID for SQL Server"
  type        = string
}

variable "database_max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  default     = 250
}

variable "database_sku_name" {
  description = "SKU name for the SQL database"
  type        = string
  default     = "S3"
  
  validation {
    condition = contains([
      "S0", "S1", "S2", "S3", "S4", "S6", "S7", "S9", "S12",
      "P1", "P2", "P4", "P6", "P11", "P15"
    ], var.database_sku_name)
    error_message = "Database SKU must be a valid SQL Database service tier."
  }
}

# Storage Configuration
variable "blob_retention_days" {
  description = "Blob soft delete retention days"
  type        = number
  default     = 90
}

variable "container_retention_days" {
  description = "Container soft delete retention days" 
  type        = number
  default     = 90
}

variable "enable_customer_managed_keys" {
  description = "Enable customer-managed keys for encryption"
  type        = bool
  default     = true
}

# Virtual Machine Configuration
variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "vm_admin_username" {
  description = "Administrator username for virtual machines"
  type        = string
  default     = "cmmc-admin"
  sensitive   = true
}

variable "enable_vm_auto_patching" {
  description = "Enable automatic patching for VMs (CMMC requirement)"
  type        = bool
  default     = true
}

# Security Configuration
variable "security_alert_emails" {
  description = "List of email addresses for security alerts"
  type        = list(string)
  default     = []
}

variable "threat_detection_retention_days" {
  description = "Threat detection data retention days"
  type        = number
  default     = 90
}

variable "enable_advanced_threat_protection" {
  description = "Enable Azure Advanced Threat Protection"
  type        = bool
  default     = true
}

# Backup and Recovery Configuration
variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 2555  # 7 years for CMMC compliance
  
  validation {
    condition     = var.backup_retention_days >= 365
    error_message = "Backup retention must be at least 1 year for CMMC compliance."
  }
}

variable "enable_point_in_time_restore" {
  description = "Enable point-in-time restore for databases"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "enable_security_center" {
  description = "Enable Azure Security Center"
  type        = bool
  default     = true
}

variable "security_center_pricing_tier" {
  description = "Azure Security Center pricing tier"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Free", "Standard"], var.security_center_pricing_tier)
    error_message = "Security Center pricing tier must be Free or Standard."
  }
}

variable "enable_sentinel" {
  description = "Enable Azure Sentinel SIEM"
  type        = bool
  default     = true
}

# CMMC Compliance Framework Configuration
variable "cmmc_framework_config_path" {
  description = "Path to CMMC compliance framework configuration file"
  type        = string
  default     = "./cmmc-compliance-framework.yml"
}

# Compliance Scanning Configuration
variable "vulnerability_assessment_enabled" {
  description = "Enable vulnerability assessment scanning"
  type        = bool
  default     = true
}

variable "compliance_scan_schedule" {
  description = "Schedule for compliance scanning (cron format)"
  type        = string
  default     = "0 2 * * *"  # Daily at 2 AM
}

# Network Security Configuration
variable "enable_ddos_protection" {
  description = "Enable DDoS protection on virtual network"
  type        = bool
  default     = true
}

variable "allowed_source_ip_ranges" {
  description = "List of allowed IP ranges for external access"
  type        = list(string)
  default     = []
}

# Identity and Access Configuration
variable "enable_privileged_identity_management" {
  description = "Enable Azure AD Privileged Identity Management"
  type        = bool
  default     = true
}

variable "mfa_required_for_admins" {
  description = "Require MFA for administrator accounts"
  type        = bool
  default     = true
}

variable "password_policy_complexity" {
  description = "Password complexity requirements"
  type        = object({
    minimum_length              = number
    require_uppercase          = bool
    require_lowercase          = bool
    require_numbers            = bool
    require_special_characters = bool
    password_history_count     = number
    max_password_age_days      = number
  })
  default = {
    minimum_length              = 14
    require_uppercase          = true
    require_lowercase          = true
    require_numbers            = true
    require_special_characters = true
    password_history_count     = 24
    max_password_age_days      = 60
  }
}

# Data Loss Prevention Configuration
variable "dlp_policies" {
  description = "Data Loss Prevention policies to implement"
  type        = list(object({
    name        = string
    description = string
    priority    = number
    locations   = list(string)
    rules = list(object({
      name        = string
      conditions  = list(string)
      actions     = list(string)
    }))
  }))
  default = [
    {
      name        = "CUI Protection Policy"
      description = "Prevent unauthorized sharing of CUI data"
      priority    = 1
      locations   = ["Exchange", "SharePoint", "OneDrive", "Teams"]
      rules = [
        {
          name       = "Block CUI External Sharing"
          conditions = ["Content contains CUI", "Shared externally"]
          actions    = ["Block", "Notify user", "Generate incident"]
        }
      ]
    }
  ]
}

# Information Protection Configuration
variable "information_protection_labels" {
  description = "Microsoft Information Protection labels configuration"
  type        = list(object({
    name         = string
    description  = string
    color        = string
    priority     = number
    encryption   = bool
    watermarking = bool
    conditions   = list(string)
  }))
  default = [
    {
      name         = "CUI"
      description  = "Controlled Unclassified Information"
      color        = "#FF0000"
      priority     = 90
      encryption   = true
      watermarking = true
      conditions   = ["Contains CUI", "NIST SP 800-171"]
    },
    {
      name         = "CUI//SP"
      description  = "CUI with Specified Handling"
      color        = "#8B0000"
      priority     = 95
      encryption   = true
      watermarking = true
      conditions   = ["Contains CUI SP", "DFARS"]
    }
  ]
}

# Incident Response Configuration
variable "incident_response_team_emails" {
  description = "Email addresses for incident response team"
  type        = list(string)
  default     = []
}

variable "security_incident_severity_levels" {
  description = "Security incident severity levels and response times"
  type        = map(object({
    response_time_hours = number
    escalation_required = bool
    notification_list   = list(string)
  }))
  default = {
    "Critical" = {
      response_time_hours = 1
      escalation_required = true
      notification_list   = ["CISO", "Security-Team", "Incident-Response"]
    }
    "High" = {
      response_time_hours = 4
      escalation_required = true  
      notification_list   = ["Security-Team", "Incident-Response"]
    }
    "Medium" = {
      response_time_hours = 24
      escalation_required = false
      notification_list   = ["Security-Team"]
    }
    "Low" = {
      response_time_hours = 72
      escalation_required = false
      notification_list   = ["Security-Team"]
    }
  }
}

# Disaster Recovery Configuration
variable "enable_cross_region_replication" {
  description = "Enable cross-region replication for disaster recovery"
  type        = bool
  default     = true
}

variable "dr_region" {
  description = "Disaster recovery region"
  type        = string
  default     = "USGov Texas"
}

variable "rto_hours" {
  description = "Recovery Time Objective in hours"
  type        = number
  default     = 24
}

variable "rpo_hours" {
  description = "Recovery Point Objective in hours"
  type        = number
  default     = 4
}

# Cost Management Configuration
variable "budget_amount" {
  description = "Monthly budget amount for the CMMC environment"
  type        = number
  default     = 10000
}

variable "budget_alert_thresholds" {
  description = "Budget alert threshold percentages"
  type        = list(number)
  default     = [50, 80, 100]
}

variable "cost_optimization_enabled" {
  description = "Enable cost optimization recommendations"
  type        = bool
  default     = true
}