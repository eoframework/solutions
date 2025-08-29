# Azure Sentinel SIEM - Configuration Templates

## Overview

This document provides comprehensive Infrastructure as Code (IaC) templates and configuration files for deploying Azure Sentinel SIEM. These templates include Terraform configurations, ARM templates, KQL queries, playbook definitions, and automation scripts that enable repeatable and consistent deployments.

**Template Categories:**
- Terraform HCL configurations for infrastructure deployment
- ARM templates for Azure-native resource provisioning  
- KQL analytics rules and hunting queries
- Logic App playbooks for automated response
- PowerShell and CLI scripts for configuration automation

## Terraform Configuration Templates

### Main Terraform Configuration

**File: `main.tf`**
```hcl
terraform {
  required_version = ">= 1.2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"  
      version = "~> 2.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate001"
    container_name       = "tfstate"
    key                  = "sentinel-siem.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

# Local values for consistent naming and tagging
locals {
  location_short = {
    "East US"       = "eus"
    "East US 2"     = "eus2"
    "West US"       = "wus"
    "West US 2"     = "wus2"
    "Central US"    = "cus"
  }
  
  environment_short = {
    "Production"    = "prod"
    "Staging"       = "stg"
    "Development"   = "dev"
    "Testing"       = "test"
  }
  
  common_tags = {
    Environment   = var.environment
    Owner         = var.owner
    CostCenter    = var.cost_center
    Project       = "Azure Sentinel SIEM"
    DeployedBy    = "Terraform"
    DeployedDate  = timestamp()
    SecurityLevel = "Restricted"
  }
}

# Resource Group for Security Operations
resource "azurerm_resource_group" "security" {
  name     = "rg-security-${local.environment_short[var.environment]}-${local.location_short[var.location]}-001"
  location = var.location
  tags     = local.common_tags
}

# Log Analytics Workspace for Sentinel
resource "azurerm_log_analytics_workspace" "sentinel" {
  name                = "law-security-${local.environment_short[var.environment]}-${local.location_short[var.location]}-001"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb
  
  tags = local.common_tags
}

# Azure Sentinel
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id                 = azurerm_log_analytics_workspace.sentinel.id
  customer_managed_key_enabled = var.customer_managed_key_enabled
}

# Data Collection Rules
resource "azurerm_monitor_data_collection_rule" "security_events" {
  name                = "dcr-security-events-${local.environment_short[var.environment]}-${local.location_short[var.location]}-001"
  resource_group_name = azurerm_resource_group.security.name
  location            = azurerm_resource_group.security.location
  
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.sentinel.id
      name                  = "SecurityWorkspace"
    }
  }
  
  data_flow {
    streams      = ["Microsoft-SecurityEvent"]
    destinations = ["SecurityWorkspace"]
  }
  
  data_sources {
    windows_event_log {
      streams = ["Microsoft-SecurityEvent"]
      name    = "SecurityEvents"
      x_path_queries = [
        "Security!*[System[(EventID=4624 or EventID=4625 or EventID=4648 or EventID=4656 or EventID=4688 or EventID=4689 or EventID=4697 or EventID=4719 or EventID=4720 or EventID=4722 or EventID=4723 or EventID=4724 or EventID=4725 or EventID=4726 or EventID=4727 or EventID=4728 or EventID=4729 or EventID=4730 or EventID=4732 or EventID=4733 or EventID=4734 or EventID=4735 or EventID=4737 or EventID=4738 or EventID=4739 or EventID=4740 or EventID=4754 or EventID=4755 or EventID=4756 or EventID=4767 or EventID=4799 or EventID=4817 or EventID=5024 or EventID=5033 or EventID=5059 or EventID=5136 or EventID=5137 or EventID=5139 or EventID=5156 or EventID=5157 or EventID=5447)]]"
      ]
    }
  }
  
  tags = local.common_tags
}

# Storage Account for playbook artifacts
resource "azurerm_storage_account" "sentinel" {
  name                     = "stsec${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.security.name
  location                 = azurerm_resource_group.security.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  blob_properties {
    delete_retention_policy {
      days = 30
    }
  }
  
  tags = local.common_tags
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# Key Vault for sensitive configuration
resource "azurerm_key_vault" "sentinel" {
  name                = "kv-sec-${local.environment_short[var.environment]}-${local.location_short[var.location]}-${random_integer.suffix.result}"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  sku_name = "premium"
  
  enable_rbac_authorization = true
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
  
  tags = local.common_tags
}

# Call modules for specific components
module "data_connectors" {
  source = "./modules/data-connectors"
  
  resource_group_name = azurerm_resource_group.security.name
  workspace_id        = azurerm_log_analytics_workspace.sentinel.id
  
  # Data connector configuration
  enable_azure_activity    = var.enable_azure_activity
  enable_azure_ad         = var.enable_azure_ad
  enable_office365        = var.enable_office365
  enable_security_center  = var.enable_security_center
  enable_threat_intel     = var.enable_threat_intel
  
  tags = local.common_tags
}

module "analytics_rules" {
  source = "./modules/analytics-rules"
  
  resource_group_name = azurerm_resource_group.security.name
  workspace_id        = azurerm_log_analytics_workspace.sentinel.id
  
  # Analytics rules configuration  
  deploy_builtin_rules = var.deploy_builtin_rules
  deploy_custom_rules  = var.deploy_custom_rules
  
  tags = local.common_tags
}

module "playbooks" {
  source = "./modules/playbooks"
  
  resource_group_name = azurerm_resource_group.security.name
  location           = azurerm_resource_group.security.location
  workspace_id       = azurerm_log_analytics_workspace.sentinel.id
  
  # Playbook configuration
  teams_webhook_url    = var.teams_webhook_url
  servicenow_instance  = var.servicenow_instance
  email_notification   = var.email_notification
  
  tags = local.common_tags
}
```

### Variables Configuration

**File: `variables.tf`**
```hcl
# Environment Configuration
variable "environment" {
  description = "Environment name (Production, Staging, Development, Testing)"
  type        = string
  default     = "Production"
  
  validation {
    condition = contains(["Production", "Staging", "Development", "Testing"], var.environment)
    error_message = "Environment must be one of: Production, Staging, Development, Testing."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US 2"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Security Team"
}

variable "cost_center" {
  description = "Cost center for resource billing"
  type        = string
  default     = "Security-Operations"
}

# Sentinel Configuration
variable "log_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 90
  
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB (-1 for unlimited)"
  type        = number
  default     = 50
}

variable "customer_managed_key_enabled" {
  description = "Enable customer managed key encryption"
  type        = bool
  default     = false
}

# Data Connector Configuration
variable "enable_azure_activity" {
  description = "Enable Azure Activity data connector"
  type        = bool
  default     = true
}

variable "enable_azure_ad" {
  description = "Enable Azure AD data connectors"
  type        = bool
  default     = true
}

variable "enable_office365" {
  description = "Enable Office 365 data connector"
  type        = bool
  default     = true
}

variable "enable_security_center" {
  description = "Enable Security Center data connector"
  type        = bool
  default     = true
}

variable "enable_threat_intel" {
  description = "Enable threat intelligence data connectors"
  type        = bool
  default     = true
}

# Analytics Rules Configuration
variable "deploy_builtin_rules" {
  description = "Deploy built-in analytics rules"
  type        = bool
  default     = true
}

variable "deploy_custom_rules" {
  description = "Deploy custom analytics rules"
  type        = bool
  default     = true
}

# Automation Configuration
variable "teams_webhook_url" {
  description = "Microsoft Teams webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "servicenow_instance" {
  description = "ServiceNow instance URL"
  type        = string
  default     = ""
}

variable "email_notification" {
  description = "Email address for security notifications"
  type        = string
  default     = "security-ops@company.com"
}
```

### Data Connectors Module

**File: `modules/data-connectors/main.tf`**
```hcl
# Azure Activity Data Connector
resource "azurerm_sentinel_data_connector_azure_active_directory" "aad" {
  count                       = var.enable_azure_ad ? 1 : 0
  name                        = "AzureActiveDirectory"
  log_analytics_workspace_id  = var.workspace_id
}

resource "azurerm_sentinel_data_connector_azure_security_center" "asc" {
  count                       = var.enable_security_center ? 1 : 0
  name                        = "AzureSecurityCenter"
  log_analytics_workspace_id  = var.workspace_id
}

resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "mcas" {
  count                       = var.enable_office365 ? 1 : 0
  name                        = "MicrosoftCloudAppSecurity"
  log_analytics_workspace_id  = var.workspace_id
  
  alerts_enabled                         = true
  discovery_logs_enabled                = true
}

resource "azurerm_sentinel_data_connector_office_365" "office365" {
  count                       = var.enable_office365 ? 1 : 0
  name                        = "Office365"
  log_analytics_workspace_id  = var.workspace_id
  
  exchange_enabled   = true
  sharepoint_enabled = true
  teams_enabled      = true
}

resource "azurerm_sentinel_data_connector_threat_intelligence" "threat_intel" {
  count                       = var.enable_threat_intel ? 1 : 0
  name                        = "ThreatIntelligence"
  log_analytics_workspace_id  = var.workspace_id
  
  lookback_date = "1991-01-01T00:00:00Z"
}
```

### Analytics Rules Module

**File: `modules/analytics-rules/main.tf`**
```hcl
# Custom Analytics Rule: Suspicious Login Activity
resource "azurerm_sentinel_alert_rule_scheduled" "suspicious_login" {
  count                       = var.deploy_custom_rules ? 1 : 0
  name                        = "SuspiciousLoginActivity"
  log_analytics_workspace_id  = var.workspace_id
  display_name                = "Multiple Failed Logins from Different Countries"
  description                 = "Detects multiple failed login attempts from different countries within a short time period"
  
  tactics = ["InitialAccess", "CredentialAccess"]
  
  severity = "High"
  enabled  = true
  
  query_frequency = "PT1H"
  query_period    = "PT1H"
  
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  
  query = <<QUERY
let timeRange = 1h;
let threshold = 5;
SigninLogs
| where TimeGenerated >= ago(timeRange)
| where ResultType != "0"
| where UserPrincipalName != ""
| summarize FailedAttempts = count(), 
            Locations = make_set(Location),
            IPAddresses = make_set(IPAddress),
            Countries = make_set(LocationDetails.countryOrRegion)
  by UserPrincipalName, bin(TimeGenerated, 5m)
| where FailedAttempts >= threshold
| where array_length(Countries) > 1
| extend AccountCustomEntity = UserPrincipalName,
         IPCustomEntity = tostring(IPAddresses[0])
QUERY

  entity_mapping {
    entity_type = "Account"
    field_mappings {
      identifier = "FullName"
      column_name = "AccountCustomEntity"
    }
  }
  
  entity_mapping {
    entity_type = "IP"
    field_mappings {
      identifier = "Address"
      column_name = "IPCustomEntity"
    }
  }
  
  incident_configuration {
    create_incident = true
    grouping {
      enabled             = true
      lookback_duration   = "PT5H"
      reopen_closed_incidents = false
      entity_matching_method = "AllEntities"
    }
  }
}

# Custom Analytics Rule: Privilege Escalation Detection
resource "azurerm_sentinel_alert_rule_scheduled" "privilege_escalation" {
  count                       = var.deploy_custom_rules ? 1 : 0
  name                        = "PrivilegeEscalationDetection"
  log_analytics_workspace_id  = var.workspace_id
  display_name                = "Suspicious Privilege Escalation Activity"
  description                 = "Detects potential privilege escalation through suspicious process execution"
  
  tactics = ["PrivilegeEscalation", "DefenseEvasion"]
  
  severity = "High"
  enabled  = true
  
  query_frequency = "PT1H"
  query_period    = "PT1H"
  
  trigger_operator  = "GreaterThan" 
  trigger_threshold = 0
  
  query = <<QUERY
SecurityEvent
| where TimeGenerated >= ago(1h)
| where EventID == 4688
| where Process has_any("powershell.exe", "cmd.exe", "wscript.exe", "cscript.exe", "rundll32.exe", "regsvr32.exe", "mshta.exe")
| where CommandLine has_any("-enc", "-exec", "bypass", "hidden", "system", "runas", "elevate")
| where Account !endswith "$"
| extend HostCustomEntity = Computer,
         AccountCustomEntity = Account,
         ProcessCustomEntity = Process
| summarize Count = count(), 
            FirstEvent = min(TimeGenerated),
            LastEvent = max(TimeGenerated),
            Commands = make_set(CommandLine)
  by Computer, Account, Process
| where Count >= 3
QUERY

  entity_mapping {
    entity_type = "Host"
    field_mappings {
      identifier = "FullName"
      column_name = "HostCustomEntity"
    }
  }
  
  entity_mapping {
    entity_type = "Account"
    field_mappings {
      identifier = "Name"
      column_name = "AccountCustomEntity"
    }
  }
  
  entity_mapping {
    entity_type = "Process"
    field_mappings {
      identifier = "ProcessId"
      column_name = "ProcessCustomEntity"
    }
  }
}

# Machine Learning Analytics Rules
resource "azurerm_sentinel_alert_rule_machine_learning_behavior_analytics" "anomalous_login_location" {
  count                       = var.deploy_builtin_rules ? 1 : 0
  name                        = "AnomalousLoginLocation"
  log_analytics_workspace_id  = var.workspace_id
  display_name                = "Anomalous login location by user account and time"
  enabled                     = true
}

resource "azurerm_sentinel_alert_rule_machine_learning_behavior_analytics" "anomalous_ssh_login" {
  count                       = var.deploy_builtin_rules ? 1 : 0
  name                        = "AnomalousSSHLogin"
  log_analytics_workspace_id  = var.workspace_id
  display_name                = "Anomalous SSH login detection"
  enabled                     = true
}
```

## ARM Templates

### Main Deployment Template

**File: `azuredeploy.json`**
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "workspaceName": {
      "type": "string",
      "defaultValue": "law-security-prod-eus2-001",
      "metadata": {
        "description": "Name for the Log Analytics workspace"
      }
    },
    "pricingTier": {
      "type": "string",
      "defaultValue": "PerGB2018",
      "allowedValues": [
        "PerGB2018",
        "Free",
        "Standalone",
        "PerNode",
        "Standard",
        "Premium"
      ],
      "metadata": {
        "description": "Pricing tier for the Log Analytics workspace"
      }
    },
    "dataRetention": {
      "type": "int",
      "defaultValue": 90,
      "minValue": 30,
      "maxValue": 730,
      "metadata": {
        "description": "Number of days to retain data"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for all resources"
      }
    },
    "enableSentinel": {
      "type": "bool",
      "defaultValue": true,
      "metadata": {
        "description": "Enable Azure Sentinel on the workspace"
      }
    }
  },
  "variables": {
    "workspaceId": "[resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.OperationalInsights/workspaces",
      "apiVersion": "2022-10-01",
      "name": "[parameters('workspaceName')]",
      "location": "[parameters('location')]",
      "properties": {
        "sku": {
          "name": "[parameters('pricingTier')]"
        },
        "retentionInDays": "[parameters('dataRetention')]",
        "features": {
          "searchVersion": 1,
          "legacy": 0,
          "enableLogAccessUsingOnlyResourcePermissions": true
        }
      }
    },
    {
      "condition": "[parameters('enableSentinel')]",
      "type": "Microsoft.SecurityInsights/onboardingStates",
      "apiVersion": "2021-09-01-preview",
      "name": "default",
      "scope": "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]",
      "dependsOn": [
        "[variables('workspaceId')]"
      ],
      "properties": {}
    },
    {
      "condition": "[parameters('enableSentinel')]",
      "type": "Microsoft.SecurityInsights/dataConnectors",
      "apiVersion": "2021-09-01-preview",
      "name": "AzureActivity",
      "scope": "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]",
      "dependsOn": [
        "[variables('workspaceId')]",
        "Microsoft.SecurityInsights/onboardingStates/default"
      ],
      "kind": "AzureActivity",
      "properties": {
        "subscriptionId": "[subscription().subscriptionId]"
      }
    },
    {
      "condition": "[parameters('enableSentinel')]",
      "type": "Microsoft.SecurityInsights/dataConnectors",
      "apiVersion": "2021-09-01-preview",
      "name": "AzureSecurityCenter",
      "scope": "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]",
      "dependsOn": [
        "[variables('workspaceId')]",
        "Microsoft.SecurityInsights/onboardingStates/default"
      ],
      "kind": "AzureSecurityCenter",
      "properties": {
        "subscriptionId": "[subscription().subscriptionId]"
      }
    }
  ],
  "outputs": {
    "workspaceId": {
      "type": "string",
      "value": "[variables('workspaceId')]"
    },
    "workspaceName": {
      "type": "string",
      "value": "[parameters('workspaceName')]"
    }
  }
}
```

## KQL Analytics Rules and Queries

### Security Analytics Rules

**Brute Force Attack Detection:**
```kql
// Brute Force Login Detection
let threshold = 10;
let timeframe = 1h;
SigninLogs
| where TimeGenerated >= ago(timeframe)
| where ResultType !in ("0", "50125", "50140")  // Exclude successful and interrupted flows
| where UserPrincipalName != ""
| summarize 
    FailedAttempts = count(),
    IPAddresses = make_set(IPAddress),
    Countries = make_set(LocationDetails.countryOrRegion),
    FirstFailure = min(TimeGenerated),
    LastFailure = max(TimeGenerated)
  by UserPrincipalName
| where FailedAttempts >= threshold
| extend 
    AttackDuration = LastFailure - FirstFailure,
    UniqueIPs = array_length(IPAddresses),
    UniqueCountries = array_length(Countries)
| project 
    UserPrincipalName,
    FailedAttempts,
    UniqueIPs,
    UniqueCountries, 
    AttackDuration,
    IPAddresses,
    Countries,
    FirstFailure,
    LastFailure
```

**Lateral Movement Detection:**
```kql
// Network Share Access Anomaly Detection  
let timeframe = 24h;
let threshold = 5;
SecurityEvent
| where TimeGenerated >= ago(timeframe)
| where EventID == 5140  // Network Share Access
| where ShareName has_any("C$", "ADMIN$", "IPC$")
| where SubjectUserName !endswith "$"  // Exclude machine accounts
| summarize 
    AccessCount = count(),
    UniqueShares = dcount(ShareName),
    AccessedShares = make_set(ShareName),
    TargetMachines = make_set(Computer),
    FirstAccess = min(TimeGenerated),
    LastAccess = max(TimeGenerated)
  by SubjectUserName, IpAddress
| where UniqueShares >= threshold
| extend 
    AttackSpan = LastAccess - FirstAccess,
    UniqueMachines = array_length(TargetMachines)
| project 
    SubjectUserName,
    IpAddress,
    AccessCount,
    UniqueShares,
    UniqueMachines,
    AttackSpan,
    AccessedShares,
    TargetMachines,
    FirstAccess,
    LastAccess
```

**Persistence Detection:**
```kql
// Registry Persistence Detection
SecurityEvent  
| where EventID == 4657  // Registry Value Modified
| where ObjectName has_any(
    "\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run",
    "\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunOnce", 
    "\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunServices",
    "\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunServicesOnce",
    "\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\\Userinit",
    "\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\\Shell"
)
| where SubjectUserName !endswith "$"
| project 
    TimeGenerated,
    Computer,
    SubjectUserName,
    ProcessName,
    ObjectName,
    OldValue,
    NewValue
| extend 
    PersistenceLocation = case(
        ObjectName has "\\Run\\", "Run Key",
        ObjectName has "\\RunOnce\\", "RunOnce Key", 
        ObjectName has "\\RunServices", "RunServices Key",
        ObjectName has "\\Winlogon\\", "Winlogon Key",
        "Other Registry"
    )
```

### Threat Hunting Queries

**Living off the Land Detection:**
```kql
// Hunt for Living-off-the-Land Binary Usage
let timeframe = 7d;
let suspiciousProcesses = dynamic([
    "powershell.exe", "cmd.exe", "wscript.exe", "cscript.exe", 
    "rundll32.exe", "regsvr32.exe", "mshta.exe", "bitsadmin.exe",
    "certutil.exe", "wmic.exe", "msiexec.exe", "sc.exe", "schtasks.exe"
]);
let suspiciousArgs = dynamic([
    "-enc", "-encoded", "-exec", "bypass", "-w hidden", "-window hidden",
    "downloadstring", "invoke-expression", "invoke-webrequest", "iwr", 
    "curl", "wget", "bitstransfer", "start-bitstransfer", "invoke-command",
    "enter-pssession", "new-pssession", "invoke-mimikatz", "dumpcreds"
]);
SecurityEvent
| where TimeGenerated >= ago(timeframe)
| where EventID == 4688
| where Process has_any(suspiciousProcesses)
| where CommandLine has_any(suspiciousArgs)
| extend 
    ProcessFileName = tostring(split(Process, "\\")[-1]),
    SuspiciousIndicators = extract_all(@"(-enc\w*|-exec\w*|bypass|hidden|downloadstring|invoke-\w+|iwr|curl|wget|bitstransfer)", CommandLine)
| project 
    TimeGenerated,
    Computer, 
    Account,
    ProcessFileName,
    CommandLine,
    ParentProcessName,
    SuspiciousIndicators
| summarize 
    Count = count(),
    FirstSeen = min(TimeGenerated),
    LastSeen = max(TimeGenerated),
    UniqueCommands = make_set(CommandLine),
    Indicators = make_set(SuspiciousIndicators)
  by Computer, Account, ProcessFileName
| order by Count desc
```

**Credential Access Hunt:**
```kql
// Hunt for Credential Access Activities
let timeframe = 7d;
let credentialAccessProcesses = dynamic([
    "lsass.exe", "winlogon.exe", "csrss.exe", "wininit.exe",
    "mimikatz.exe", "procdump.exe", "task manager", "processhacker.exe"
]);
let credentialAccessCommands = dynamic([
    "sekurlsa", "kerberos", "wdigest", "tspkg", "logonpasswords",
    "lsadump", "dcsync", "golden", "silver", "pth", "dcom"
]);
union 
(
    SecurityEvent
    | where TimeGenerated >= ago(timeframe)
    | where EventID == 4688
    | where CommandLine has_any(credentialAccessCommands)
    | extend ActivityType = "CommandLine"
),
(
    SecurityEvent  
    | where TimeGenerated >= ago(timeframe)
    | where EventID == 4656  // Object Access
    | where ObjectName has "lsass.exe"
    | where ProcessName !has_any("System", "Antimalware", "Defender")
    | extend ActivityType = "LSASSAccess"
),
(
    SecurityEvent
    | where TimeGenerated >= ago(timeframe)
    | where EventID == 4648  // Explicit Credential Use
    | where TargetUserName != SubjectUserName
    | extend ActivityType = "ExplicitCredentialUse"
)
| project 
    TimeGenerated,
    Computer,
    Account = coalesce(SubjectUserName, Account),
    ProcessName,
    CommandLine,
    ActivityType,
    ObjectName,
    TargetUserName
```

## Logic App Playbooks

### Incident Response Playbook

**File: `incident-response-playbook.json`**
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2016-06-01/Microsoft.Logic.json",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "$connections": {
      "defaultValue": {},
      "type": "Object"
    }
  },
  "triggers": {
    "When_Azure_Sentinel_incident_creation_rule_was_triggered": {
      "type": "ApiConnectionWebhook",
      "inputs": {
        "host": {
          "connection": {
            "name": "@parameters('$connections')['azuresentinel']['connectionId']"
          }
        },
        "body": {
          "callback_url": "@{listCallbackUrl()}"
        },
        "path": "/incident-creation"
      }
    }
  },
  "actions": {
    "Initialize_incident_variables": {
      "runAfter": {},
      "type": "InitializeVariable",
      "inputs": {
        "variables": [
          {
            "name": "IncidentId", 
            "type": "string",
            "value": "@{triggerBody()?['object']?['properties']?['incidentNumber']}"
          },
          {
            "name": "IncidentTitle",
            "type": "string", 
            "value": "@{triggerBody()?['object']?['properties']?['title']}"
          },
          {
            "name": "IncidentSeverity",
            "type": "string",
            "value": "@{triggerBody()?['object']?['properties']?['severity']}"
          },
          {
            "name": "IncidentUrl",
            "type": "string",
            "value": "@{triggerBody()?['object']?['properties']?['incidentUrl']}"
          }
        ]
      }
    },
    "Parse_incident_entities": {
      "runAfter": {
        "Initialize_incident_variables": ["Succeeded"]
      },
      "type": "ParseJson",
      "inputs": {
        "content": "@triggerBody()?['object']?['properties']?['relatedEntities']",
        "schema": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "kind": {"type": "string"},
              "properties": {"type": "object"}
            }
          }
        }
      }
    },
    "Condition_check_high_severity": {
      "actions": {
        "Send_Teams_alert": {
          "runAfter": {},
          "type": "ApiConnection",
          "inputs": {
            "host": {
              "connection": {
                "name": "@parameters('$connections')['teams']['connectionId']"
              }
            },
            "method": "post",
            "body": {
              "messageBody": "<h2>🚨 High Severity Security Incident</h2><br><strong>Incident:</strong> @{variables('IncidentId')}<br><strong>Title:</strong> @{variables('IncidentTitle')}<br><strong>Severity:</strong> @{variables('IncidentSeverity')}<br><br><a href='@{variables('IncidentUrl')}'>View in Sentinel →</a>",
              "recipient": {
                "channelId": "security-incidents"
              }
            },
            "path": "/v1.0/teams/security-team/channels/general/messages"
          }
        },
        "Create_ServiceNow_incident": {
          "runAfter": {
            "Send_Teams_alert": ["Succeeded"]
          },
          "type": "ApiConnection",
          "inputs": {
            "host": {
              "connection": {
                "name": "@parameters('$connections')['servicenow']['connectionId']"
              }
            },
            "method": "post",
            "body": {
              "short_description": "@{variables('IncidentTitle')}",
              "description": "Azure Sentinel Incident @{variables('IncidentId')}\n\nSeverity: @{variables('IncidentSeverity')}\n\nView in Sentinel: @{variables('IncidentUrl')}",
              "urgency": "1",
              "impact": "1", 
              "priority": "1",
              "category": "Security Incident",
              "assignment_group": "Security Operations Center",
              "caller_id": "azure.sentinel@company.com"
            },
            "path": "/api/now/table/incident"
          }
        },
        "Check_for_user_accounts": {
          "runAfter": {
            "Create_ServiceNow_incident": ["Succeeded"]
          },
          "type": "Foreach",
          "foreach": "@body('Parse_incident_entities')",
          "actions": {
            "Condition_is_user_entity": {
              "actions": {
                "Disable_user_account": {
                  "runAfter": {},
                  "type": "ApiConnection",
                  "inputs": {
                    "host": {
                      "connection": {
                        "name": "@parameters('$connections')['azuread']['connectionId']"
                      }
                    },
                    "method": "patch",
                    "body": {
                      "accountEnabled": false
                    },
                    "path": "/v1.0/users/@{encodeURIComponent(items('Check_for_user_accounts')?['properties']?['friendlyName'])}"
                  }
                },
                "Add_comment_to_incident": {
                  "runAfter": {
                    "Disable_user_account": ["Succeeded"]
                  },
                  "type": "ApiConnection",
                  "inputs": {
                    "host": {
                      "connection": {
                        "name": "@parameters('$connections')['azuresentinel']['connectionId']"
                      }
                    },
                    "method": "post",
                    "body": {
                      "message": "User account @{items('Check_for_user_accounts')?['properties']?['friendlyName']} has been automatically disabled due to high severity incident."
                    },
                    "path": "/Incidents/@{encodeURIComponent(variables('IncidentId'))}/Comments"
                  }
                }
              },
              "runAfter": {},
              "expression": {
                "and": [
                  {
                    "equals": [
                      "@items('Check_for_user_accounts')?['kind']",
                      "Account"
                    ]
                  }
                ]
              },
              "type": "If"
            }
          }
        }
      },
      "runAfter": {
        "Parse_incident_entities": ["Succeeded"]
      },
      "expression": {
        "or": [
          {
            "equals": [
              "@variables('IncidentSeverity')",
              "High"
            ]
          },
          {
            "equals": [
              "@variables('IncidentSeverity')",
              "Critical"
            ]
          }
        ]
      },
      "type": "If"
    }
  }
}
```

## PowerShell Automation Scripts

### Sentinel Deployment Script

**File: `Deploy-AzureSentinel.ps1`**
```powershell
<#
.SYNOPSIS
    Deploy Azure Sentinel SIEM using Infrastructure as Code
.DESCRIPTION
    This script deploys Azure Sentinel with data connectors, analytics rules, and playbooks
.PARAMETER DeploymentMethod
    Deployment method: Terraform, ARM, or PowerShell
.PARAMETER ConfigFile
    Configuration file path (JSON format)
.PARAMETER Environment
    Target environment: Production, Staging, Development, Testing
.EXAMPLE
    ./Deploy-AzureSentinel.ps1 -DeploymentMethod Terraform -Environment Production
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("Terraform", "ARM", "PowerShell")]
    [string]$DeploymentMethod,
    
    [Parameter()]
    [string]$ConfigFile = "config.json",
    
    [Parameter()]
    [ValidateSet("Production", "Staging", "Development", "Testing")]
    [string]$Environment = "Production",
    
    [Parameter()]
    [string]$Location = "East US 2",
    
    [Parameter()]
    [switch]$WhatIf
)

# Import required modules
$requiredModules = @("Az.Accounts", "Az.SecurityInsights", "Az.OperationalInsights", "Az.Resources")
foreach ($module in $requiredModules) {
    if (!(Get-Module -Name $module -ListAvailable)) {
        Write-Warning "Installing required module: $module"
        Install-Module -Name $module -Force -Scope CurrentUser
    }
    Import-Module -Name $module -Force
}

# Global variables
$ErrorActionPreference = "Stop"
$script:LogFile = "sentinel-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Write-Host $logMessage
    Add-Content -Path $script:LogFile -Value $logMessage
}

function Test-Prerequisites {
    Write-Log "Validating prerequisites..."
    
    # Check Azure PowerShell version
    $azVersion = Get-Module Az.Accounts -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    Write-Log "Azure PowerShell version: $($azVersion.Version)"
    
    # Check authentication
    $context = Get-AzContext
    if (!$context) {
        throw "Not authenticated to Azure. Please run Connect-AzAccount first."
    }
    Write-Log "Authenticated as: $($context.Account.Id)"
    
    # Check permissions
    try {
        $permissions = Get-AzRoleAssignment -SignInName $context.Account.Id
        $hasSecurityAdmin = $permissions | Where-Object { $_.RoleDefinitionName -in @("Security Admin", "Contributor", "Owner") }
        if (!$hasSecurityAdmin) {
            throw "Insufficient permissions. Security Admin, Contributor, or Owner role required."
        }
    }
    catch {
        Write-Warning "Could not verify permissions: $($_.Exception.Message)"
    }
    
    Write-Log "Prerequisites validation completed"
}

function Deploy-WithPowerShell {
    param($Config)
    
    Write-Log "Starting PowerShell-based deployment..."
    
    try {
        # Create resource group
        $rgName = "rg-security-$($Environment.ToLower())-eus2-001"
        Write-Log "Creating resource group: $rgName"
        
        if ($WhatIf) {
            Write-Log "WhatIf: Would create resource group $rgName"
        } else {
            $rg = New-AzResourceGroup -Name $rgName -Location $Location -Tag @{
                Environment = $Environment
                Owner = "Security Team"
                Project = "Azure Sentinel SIEM"
            } -Force
            Write-Log "Resource group created: $($rg.ResourceGroupName)"
        }
        
        # Create Log Analytics workspace
        $workspaceName = "law-security-$($Environment.ToLower())-eus2-001"
        Write-Log "Creating Log Analytics workspace: $workspaceName"
        
        if (!$WhatIf) {
            $workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $rgName -Name $workspaceName -Location $Location -Sku "PerGB2018" -RetentionInDays 90
            Write-Log "Workspace created: $($workspace.Name)"
        }
        
        # Enable Sentinel
        Write-Log "Enabling Azure Sentinel..."
        if (!$WhatIf) {
            Enable-AzSentinel -ResourceGroupName $rgName -WorkspaceName $workspaceName
            Write-Log "Azure Sentinel enabled"
        }
        
        # Deploy data connectors
        Write-Log "Configuring data connectors..."
        $connectors = @("AzureActivity", "AzureSecurityCenter", "AzureActiveDirectory", "Office365")
        
        foreach ($connector in $connectors) {
            if (!$WhatIf) {
                try {
                    New-AzSentinelDataConnector -ResourceGroupName $rgName -WorkspaceName $workspaceName -Kind $connector
                    Write-Log "Enabled data connector: $connector"
                }
                catch {
                    Write-Warning "Failed to enable $connector`: $($_.Exception.Message)"
                }
            } else {
                Write-Log "WhatIf: Would enable data connector $connector"
            }
        }
        
        # Deploy analytics rules
        Write-Log "Deploying analytics rules..."
        if (!$WhatIf) {
            Deploy-AnalyticsRules -ResourceGroupName $rgName -WorkspaceName $workspaceName
        }
        
        Write-Log "PowerShell deployment completed successfully"
    }
    catch {
        Write-Log "PowerShell deployment failed: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Deploy-AnalyticsRules {
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName
    )
    
    # Deploy suspicious login rule
    $loginRule = @{
        ResourceGroupName = $ResourceGroupName
        WorkspaceName = $WorkspaceName
        RuleId = (New-Guid).ToString()
        DisplayName = "Multiple Failed Logins from Different Countries"
        Description = "Detects multiple failed login attempts from different countries"
        Severity = "High"
        Tactic = @("InitialAccess", "CredentialAccess")
        Query = @"
let timeRange = 1h;
let threshold = 5;
SigninLogs
| where TimeGenerated >= ago(timeRange)
| where ResultType != "0"
| where UserPrincipalName != ""
| summarize FailedAttempts = count(), Countries = make_set(LocationDetails.countryOrRegion) by UserPrincipalName
| where FailedAttempts >= threshold and array_length(Countries) > 1
"@
        QueryFrequency = "PT1H"
        QueryPeriod = "PT1H"
        TriggerOperator = "GreaterThan"
        TriggerThreshold = 0
        Enabled = $true
    }
    
    try {
        New-AzSentinelAlertRule @loginRule
        Write-Log "Deployed analytics rule: Multiple Failed Logins from Different Countries"
    }
    catch {
        Write-Warning "Failed to deploy suspicious login rule: $($_.Exception.Message)"
    }
}

# Main execution
try {
    Write-Log "Starting Azure Sentinel SIEM deployment"
    Write-Log "Deployment Method: $DeploymentMethod"
    Write-Log "Environment: $Environment"
    Write-Log "Location: $Location"
    
    # Validate prerequisites
    Test-Prerequisites
    
    # Load configuration
    if (Test-Path $ConfigFile) {
        $config = Get-Content -Path $ConfigFile | ConvertFrom-Json
        Write-Log "Configuration loaded from: $ConfigFile"
    } else {
        $config = @{}
        Write-Log "No configuration file found, using defaults"
    }
    
    # Deploy based on method
    switch ($DeploymentMethod) {
        "PowerShell" { Deploy-WithPowerShell -Config $config }
        "Terraform" { 
            Write-Log "Initializing Terraform deployment..."
            terraform init
            terraform plan -out=tfplan
            if (!$WhatIf) {
                terraform apply tfplan
            }
        }
        "ARM" {
            Write-Log "Deploying ARM template..."
            if (!$WhatIf) {
                New-AzResourceGroupDeployment -ResourceGroupName "rg-security-$($Environment.ToLower())-eus2-001" -TemplateFile "azuredeploy.json"
            }
        }
    }
    
    Write-Log "Azure Sentinel SIEM deployment completed successfully"
}
catch {
    Write-Log "Deployment failed: $($_.Exception.Message)" -Level ERROR
    exit 1
}
```

This comprehensive configuration templates document provides all the necessary Infrastructure as Code templates, analytics rules, playbooks, and automation scripts for deploying Azure Sentinel SIEM with enterprise-grade security operations capabilities.