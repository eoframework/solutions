# Azure Sentinel SIEM - Implementation Guide

## Overview

This comprehensive implementation guide provides step-by-step instructions for deploying Azure Sentinel SIEM following security operations best practices. The implementation follows a phased approach to minimize risk while rapidly establishing security monitoring and threat detection capabilities.

**Implementation Timeline:** 6-12 weeks  
**Complexity Level:** Advanced  
**Prerequisites:** Azure Security Administrator access, data source inventory, SOC team readiness

## Implementation Phases

### Phase 1: Environment Preparation and Workspace Setup (Weeks 1-2)

#### 1.1 Prerequisites Validation

**Required Permissions:**
- Security Administrator in Azure Active Directory
- Contributor role on target Azure subscription
- Log Analytics Contributor for workspace management
- Security Insights Contributor for Sentinel configuration

**Technical Prerequisites:**
```bash
# Verify Azure CLI version and login
az --version
# Required: Azure CLI 2.37.0 or later

az login
az account show

# Verify PowerShell modules
Get-InstalledModule -Name Az.SecurityInsights
# Required: Az.SecurityInsights 3.0.0 or later

# Check available subscriptions and select target
az account list --output table
az account set --subscription "your-subscription-id"
```

**Network and Security Planning:**
- Data source connectivity requirements and firewall rules
- Log Analytics workspace sizing calculations
- Data retention and compliance requirements
- Integration points with existing security tools

#### 1.2 Log Analytics Workspace Deployment

**Create Dedicated Security Workspace:**
```bash
# Create resource group for security operations
az group create \
  --name "rg-security-prod-eus2-001" \
  --location "East US 2" \
  --tags Environment=Production Owner="Security Team" Purpose="SIEM Operations"

# Create Log Analytics workspace for Sentinel
az monitor log-analytics workspace create \
  --resource-group "rg-security-prod-eus2-001" \
  --workspace-name "law-security-prod-eus2-001" \
  --location "East US 2" \
  --sku "PerGB2018" \
  --retention-time 90 \
  --tags Environment=Production SecurityWorkspace=True
```

**Configure Workspace Settings:**
```powershell
# Configure workspace for optimal security operations
$workspaceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-security-prod-eus2-001" -Name "law-security-prod-eus2-001").ResourceId

# Configure data retention policies
Set-AzOperationalInsightsWorkspace -ResourceGroupName "rg-security-prod-eus2-001" -Name "law-security-prod-eus2-001" -RetentionInDays 90

# Configure daily cap and alerts
Set-AzOperationalInsightsWorkspace -ResourceGroupName "rg-security-prod-eus2-001" -Name "law-security-prod-eus2-001" -DailyCap 50 -DailyCapResetHour 0

# Create budget alert for workspace costs
$budgetName = "budget-sentinel-monthly"
az consumption budget create \
  --budget-name $budgetName \
  --amount 10000 \
  --time-grain Monthly \
  --time-period start-date="2024-01-01" end-date="2025-12-31" \
  --resource-group "rg-security-prod-eus2-001" \
  --notifications amount=80,contact-emails="security-admin@company.com",threshold-type=Actual
```

#### 1.3 Azure Sentinel Enablement

**Enable Sentinel on Workspace:**
```bash
# Enable Azure Sentinel
az sentinel workspace create \
  --resource-group "rg-security-prod-eus2-001" \
  --workspace-name "law-security-prod-eus2-001"

# Verify Sentinel is enabled
az sentinel workspace show \
  --resource-group "rg-security-prod-eus2-001" \
  --workspace-name "law-security-prod-eus2-001"
```

**Configure Sentinel Settings:**
```powershell
# Import required PowerShell modules
Import-Module Az.SecurityInsights
Import-Module Az.OperationalInsights

# Configure Sentinel workspace settings
$WorkspaceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-security-prod-eus2-001" -Name "law-security-prod-eus2-001").ResourceId

# Configure UEBA (User and Entity Behavior Analytics)
$uebaSettings = @{
    ResourceGroupName = "rg-security-prod-eus2-001"
    WorkspaceName = "law-security-prod-eus2-001"
    DataSource = @("AuditLogs", "AzureActivity", "SecurityEvent", "SigninLogs")
}
Set-AzSentinelUebaConfiguration @uebaSettings
```

### Phase 2: Data Source Integration (Weeks 2-4)

#### 2.1 Azure Native Data Sources

**Azure Activity Logs Integration:**
```bash
# Enable Azure Activity data connector
az monitor diagnostic-settings create \
  --name "sentinel-activity-logs" \
  --resource "/subscriptions/$(az account show --query id -o tsv)" \
  --workspace "/subscriptions/$(az account show --query id -o tsv)/resourcegroups/rg-security-prod-eus2-001/providers/microsoft.operationalinsights/workspaces/law-security-prod-eus2-001" \
  --logs '[
    {
      "category": "Administrative",
      "enabled": true
    },
    {
      "category": "Security", 
      "enabled": true
    },
    {
      "category": "ServiceHealth",
      "enabled": true
    },
    {
      "category": "Alert",
      "enabled": true
    },
    {
      "category": "Policy",
      "enabled": true
    }
  ]'
```

**Azure Security Center Integration:**
```powershell
# Enable Security Center data connector
New-AzSentinelDataConnector -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" -Kind "AzureSecurityCenter"

# Configure Security Center to send data to Sentinel
$subscriptions = Get-AzSubscription
foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id
    
    # Configure auto-provisioning for Security Center
    Set-AzSecurityAutoProvisioningSetting -Name "default" -EnableAutoProvisioning
    
    # Configure Security Center workspace
    Set-AzSecurityWorkspaceSetting -Name "default" -WorkspaceId $WorkspaceId -Scope "/subscriptions/$($subscription.Id)"
}
```

**Azure AD Integration:**
```powershell
# Enable Azure AD data connectors
$aadConnectors = @(
    "AzureActiveDirectory",           # Sign-in logs
    "AzureActiveDirectoryIdentityProtection",  # Identity Protection
    "AzureActiveDirectoryAuditLogs"   # Audit logs
)

foreach ($connector in $aadConnectors) {
    try {
        New-AzSentinelDataConnector -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" -Kind $connector
        Write-Host "✓ Enabled $connector data connector" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to enable $connector: $($_.Exception.Message)"
    }
}
```

#### 2.2 Microsoft 365 Integration

**Microsoft 365 Defender Integration:**
```powershell
# Enable Microsoft 365 Defender connector
New-AzSentinelDataConnector -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" -Kind "MicrosoftThreatProtection"

# Enable Office 365 connector
New-AzSentinelDataConnector -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" -Kind "Office365"

# Configure Office 365 logs
$office365Config = @{
    ResourceGroupName = "rg-security-prod-eus2-001"
    WorkspaceName = "law-security-prod-eus2-001"
    Exchange = $true
    SharePoint = $true
    Teams = $true
}
Set-AzSentinelOffice365DataConnector @office365Config
```

#### 2.3 Windows Security Events

**Deploy Azure Monitor Agent:**
```bash
# Create Data Collection Rule for Windows Security Events
az monitor data-collection rule create \
  --resource-group "rg-security-prod-eus2-001" \
  --name "dcr-windows-security-events" \
  --location "East US 2" \
  --rule-file windows-security-dcr.json
```

**Windows Security Events DCR (windows-security-dcr.json):**
```json
{
  "properties": {
    "dataSources": {
      "windowsEventLogs": [
        {
          "name": "SecurityEvents",
          "streams": ["Microsoft-SecurityEvent"],
          "xPathQueries": [
            "Security!*[System[(EventID=4624 or EventID=4625 or EventID=4648 or EventID=4656 or EventID=4688 or EventID=4689 or EventID=4697 or EventID=4719 or EventID=4720 or EventID=4722 or EventID=4723 or EventID=4724 or EventID=4725 or EventID=4726 or EventID=4727 or EventID=4728 or EventID=4729 or EventID=4730 or EventID=4732 or EventID=4733 or EventID=4734 or EventID=4735 or EventID=4737 or EventID=4738 or EventID=4739 or EventID=4740 or EventID=4754 or EventID=4755 or EventID=4756 or EventID=4767 or EventID=4799 or EventID=4817 or EventID=5024 or EventID=5033 or EventID=5059 or EventID=5136 or EventID=5137 or EventID=5139 or EventID=5156 or EventID=5157 or EventID=5447)]]"
          ]
        }
      ]
    },
    "destinations": {
      "logAnalytics": [
        {
          "workspaceResourceId": "/subscriptions/{subscription-id}/resourcegroups/rg-security-prod-eus2-001/providers/microsoft.operationalinsights/workspaces/law-security-prod-eus2-001",
          "name": "SecurityWorkspace"
        }
      ]
    },
    "dataFlows": [
      {
        "streams": ["Microsoft-SecurityEvent"],
        "destinations": ["SecurityWorkspace"],
        "transformKql": "source | where EventID in (4624, 4625, 4648, 4656, 4688, 4689, 4697, 4719, 4720, 4722, 4723, 4724, 4725, 4726, 4727, 4728, 4729, 4730, 4732, 4733, 4734, 4735, 4737, 4738, 4739, 4740, 4754, 4755, 4756, 4767, 4799, 4817, 5024, 5033, 5059, 5136, 5137, 5139, 5156, 5157, 5447)"
      }
    ]
  }
}
```

#### 2.4 Network and Infrastructure Data Sources

**Configure Syslog Data Collection:**
```bash
# Create DCR for Syslog data
az monitor data-collection rule create \
  --resource-group "rg-security-prod-eus2-001" \
  --name "dcr-syslog-security" \
  --location "East US 2" \
  --rule-file syslog-dcr.json
```

**Syslog DCR Configuration (syslog-dcr.json):**
```json
{
  "properties": {
    "dataSources": {
      "syslog": [
        {
          "name": "SecuritySyslog",
          "streams": ["Microsoft-Syslog"],
          "facilityNames": ["auth", "authpriv", "cron", "daemon", "kern", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7", "lpr", "mail", "news", "syslog", "user", "uucp"],
          "logLevels": ["Alert", "Critical", "Debug", "Emergency", "Error", "Info", "Notice", "Warning"]
        }
      ]
    },
    "destinations": {
      "logAnalytics": [
        {
          "workspaceResourceId": "/subscriptions/{subscription-id}/resourcegroups/rg-security-prod-eus2-001/providers/microsoft.operationalinsights/workspaces/law-security-prod-eus2-001",
          "name": "SecurityWorkspace"
        }
      ]
    },
    "dataFlows": [
      {
        "streams": ["Microsoft-Syslog"],
        "destinations": ["SecurityWorkspace"]
      }
    ]
  }
}
```

**Configure Common Event Format (CEF) via Syslog:**
```bash
# Install syslog daemon on data collector VM
sudo apt-get update
sudo apt-get install rsyslog

# Configure rsyslog for CEF
cat << 'EOF' | sudo tee /etc/rsyslog.d/95-sentinel-cef.conf
# Microsoft Sentinel CEF collection
$ModLoad imudp
$UDPServerRun 514
$UDPServerAddress 0.0.0.0
$template CEFFormat,"<$PRI>%TIMESTAMP% %HOSTNAME% CEF: %msg%\n"

# Define facility local4 for CEF messages
local4.*    @@127.0.0.1:25226;CEFFormat

# Discard CEF messages after forwarding
local4.*    stop
EOF

# Restart rsyslog
sudo systemctl restart rsyslog
sudo systemctl enable rsyslog
```

### Phase 3: Analytics Rules and Detection (Weeks 4-6)

#### 3.1 Built-in Analytics Rules Deployment

**Enable Critical Detection Rules:**
```powershell
# Get all available rule templates
$ruleTemplates = Get-AzSentinelAlertRuleTemplate -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001"

# Filter for high-confidence, critical rules
$criticalRules = $ruleTemplates | Where-Object { 
    $_.Severity -eq "High" -and 
    $_.ConfidenceLevel -ge 8 -and
    $_.Enabled -eq $true
}

Write-Host "Found $($criticalRules.Count) critical rule templates to deploy"

# Deploy critical rules
foreach ($rule in $criticalRules) {
    try {
        $ruleParams = @{
            ResourceGroupName = "rg-security-prod-eus2-001"
            WorkspaceName = "law-security-prod-eus2-001"
            RuleId = (New-Guid).ToString()
            DisplayName = $rule.DisplayName
            Description = $rule.Description
            Severity = $rule.Severity
            Tactic = $rule.Tactic
            Query = $rule.Query
            QueryFrequency = $rule.QueryFrequency
            QueryPeriod = $rule.QueryPeriod
            TriggerOperator = $rule.TriggerOperator
            TriggerThreshold = $rule.TriggerThreshold
            Enabled = $true
        }
        
        New-AzSentinelAlertRule @ruleParams
        Write-Host "✓ Deployed rule: $($rule.DisplayName)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to deploy rule $($rule.DisplayName): $($_.Exception.Message)"
    }
}
```

#### 3.2 Custom Analytics Rules

**Suspicious Login Pattern Detection:**
```kql
// Custom Rule: Multiple Failed Logins from Different Locations
let timeRange = 1h;
let threshold = 5;
SigninLogs
| where TimeGenerated >= ago(timeRange)
| where ResultType != "0"  // Failed sign-ins
| where UserPrincipalName != ""
| summarize FailedAttempts = count(), 
            Locations = make_set(Location),
            IPAddresses = make_set(IPAddress),
            Countries = make_set(LocationDetails.countryOrRegion)
  by UserPrincipalName, bin(TimeGenerated, 5m)
| where FailedAttempts >= threshold
| where array_length(Countries) > 1  // Multiple countries
| extend Severity = case(
    FailedAttempts >= 20, "High",
    FailedAttempts >= 10, "Medium",
    "Low"
)
| project TimeGenerated, UserPrincipalName, FailedAttempts, Locations, IPAddresses, Countries, Severity
```

**Deploy Custom Analytics Rule:**
```powershell
# Create custom analytics rule for suspicious logins
$customRule = @{
    ResourceGroupName = "rg-security-prod-eus2-001"
    WorkspaceName = "law-security-prod-eus2-001"
    RuleId = (New-Guid).ToString()
    DisplayName = "Multiple Failed Logins from Different Countries"
    Description = "Detects multiple failed login attempts from different countries within a short time period"
    Severity = "High"
    Tactic = @("InitialAccess", "CredentialAccess")
    Query = @"
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
| extend Severity = case(
    FailedAttempts >= 20, "High",
    FailedAttempts >= 10, "Medium",
    "Low"
)
"@
    QueryFrequency = "PT1H"
    QueryPeriod = "PT1H" 
    TriggerOperator = "GreaterThan"
    TriggerThreshold = 0
    Enabled = $true
}

New-AzSentinelAlertRule @customRule
```

#### 3.3 Machine Learning Analytics

**Enable Anomaly Detection:**
```powershell
# Configure anomaly detection rules
$anomalyRules = @(
    "Anomalous Sign-in Location by User Account and Time",
    "Anomalous Azure AD Sign-in by Application",
    "Anomalous Azure AD Sign-in by User Account",
    "Anomalous Failed Sign-in Rate"
)

foreach ($ruleName in $anomalyRules) {
    $anomalyRule = Get-AzSentinelMachineLearningAnalyticsSettingsRule -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" | Where-Object { $_.DisplayName -eq $ruleName }
    
    if ($anomalyRule) {
        Set-AzSentinelMachineLearningAnalyticsSettingsRule -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" -RuleId $anomalyRule.Name -Enabled $true
        Write-Host "✓ Enabled anomaly rule: $ruleName" -ForegroundColor Green
    }
}
```

### Phase 4: Incident Response and Automation (Weeks 6-8)

#### 4.1 Incident Response Workflows

**Configure Incident Settings:**
```powershell
# Configure incident creation settings
$incidentSettings = @{
    ResourceGroupName = "rg-security-prod-eus2-001"
    WorkspaceName = "law-security-prod-eus2-001"
    CreateIncidents = $true
    GroupingConfiguration = @{
        Enabled = $true
        ReopenClosedIncidents = $false
        LookbackDuration = "PT5H"
        MatchingMethod = "AllEntities"
    }
    AlertRuleTemplateName = "IncidentConfiguration"
}

Set-AzSentinelIncidentConfiguration @incidentSettings
```

#### 4.2 Automated Response Playbooks

**Create Logic App for Automated Response:**
```bash
# Deploy Logic App for automated incident response
az logic workflow create \
  --resource-group "rg-security-prod-eus2-001" \
  --name "logic-incident-response-001" \
  --location "East US 2" \
  --definition incident-response-logic-app.json
```

**Incident Response Logic App Definition:**
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2016-06-01/Microsoft.Logic.json",
  "contentVersion": "1.0.0.0",
  "parameters": {},
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
    "Initialize_incident_severity": {
      "runAfter": {},
      "type": "InitializeVariable",
      "inputs": {
        "variables": [
          {
            "name": "IncidentSeverity",
            "type": "string",
            "value": "@{triggerBody()?['object']?['properties']?['severity']}"
          }
        ]
      }
    },
    "Condition_check_severity": {
      "actions": {
        "Send_Teams_notification_high_severity": {
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
              "rootMessage": {
                "body": {
                  "contentType": "html",
                  "content": "<h2>🚨 High Severity Security Incident</h2><br><strong>Title:</strong> @{triggerBody()?['object']?['properties']?['title']}<br><strong>Severity:</strong> @{variables('IncidentSeverity')}<br><strong>Status:</strong> @{triggerBody()?['object']?['properties']?['status']}<br><a href='@{triggerBody()?['object']?['properties']?['incidentUrl']}'>View in Sentinel</a>"
                }
              }
            },
            "path": "/v1.0/teams/@{encodeURIComponent('security-team-id')}/channels/@{encodeURIComponent('incidents-channel-id')}/messages"
          }
        },
        "Create_ServiceNow_ticket": {
          "runAfter": {
            "Send_Teams_notification_high_severity": ["Succeeded"]
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
              "short_description": "@{triggerBody()?['object']?['properties']?['title']}",
              "description": "@{triggerBody()?['object']?['properties']?['description']}",
              "urgency": "1",
              "impact": "1",
              "priority": "1",
              "category": "Security",
              "assignment_group": "Security Operations"
            },
            "path": "/api/now/table/incident"
          }
        }
      },
      "runAfter": {
        "Initialize_incident_severity": ["Succeeded"]
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

#### 4.3 User Account Disable Playbook

**Create Account Disable Playbook:**
```powershell
# Create automated user account disable playbook
$playbookDefinition = @{
    ResourceGroupName = "rg-security-prod-eus2-001"
    PlaybookName = "Disable-CompromisedAccount"
    DisplayName = "Disable Compromised User Account"
    Description = "Automatically disables user account when compromise is detected"
    LogicAppResourceId = "/subscriptions/{subscription-id}/resourceGroups/rg-security-prod-eus2-001/providers/Microsoft.Logic/workflows/logic-disable-account-001"
}

# Deploy the playbook
New-AzSentinelPlaybook @playbookDefinition
```

### Phase 5: Threat Hunting and Intelligence (Weeks 8-10)

#### 5.1 Threat Hunting Queries

**Deploy Advanced Hunting Queries:**
```kql
// Hunt for Living-off-the-Land techniques
SecurityEvent
| where TimeGenerated >= ago(7d)
| where EventID == 4688  // Process Creation
| where Process has_any("powershell.exe", "cmd.exe", "wscript.exe", "cscript.exe", "rundll32.exe", "regsvr32.exe", "mshta.exe", "bitsadmin.exe", "certutil.exe", "wmic.exe")
| where CommandLine has_any("-enc", "-exec", "bypass", "downloadstring", "invoke-expression", "invoke-webrequest", "iwr", "curl", "wget", "bitstransfer")
| project TimeGenerated, Computer, Account, Process, CommandLine, ParentProcessName
| extend Techniques = case(
    CommandLine has_any("-enc", "-exec", "bypass"), "T1059.001 - PowerShell",
    CommandLine has_any("downloadstring", "invoke-webrequest", "iwr", "curl", "wget"), "T1105 - Ingress Tool Transfer", 
    CommandLine has "bitstransfer", "T1197 - BITS Jobs",
    "Unknown"
)
| summarize Count = count(), FirstSeen = min(TimeGenerated), LastSeen = max(TimeGenerated), Techniques = make_set(Techniques) by Computer, Account, Process
| order by Count desc
```

**Lateral Movement Detection:**
```kql
// Hunt for lateral movement using admin shares
SecurityEvent  
| where TimeGenerated >= ago(24h)
| where EventID == 5140  // Network Share Access
| where ShareName has_any("\\\\*\\C$", "\\\\*\\ADMIN$", "\\\\*\\IPC$")
| where AccountType == "User"
| summarize ShareAccess = count(), 
            UniqueShares = dcount(ShareName),
            AccessedShares = make_set(ShareName),
            TargetComputers = make_set(Computer)
  by Account, IpAddress, bin(TimeGenerated, 1h)
| where UniqueShares > 3  // Accessing multiple admin shares
| extend RiskScore = case(
    UniqueShares >= 10, "High",
    UniqueShares >= 5, "Medium", 
    "Low"
)
| order by UniqueShares desc
```

#### 5.2 Threat Intelligence Integration

**Configure Threat Intelligence Connectors:**
```powershell
# Enable Microsoft Threat Intelligence connector
New-AzSentinelDataConnector -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" -Kind "MicrosoftThreatIntelligence"

# Configure threat intelligence feeds
$tiFeeds = @(
    @{
        Name = "Microsoft Threat Intelligence"
        Kind = "MicrosoftThreatIntelligence"
        Enabled = $true
    },
    @{
        Name = "TAXII Threat Intelligence"
        Kind = "ThreatIntelligenceTaxii"  
        Enabled = $true
    }
)

foreach ($feed in $tiFeeds) {
    try {
        New-AzSentinelDataConnector -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" -Kind $feed.Kind
        Write-Host "✓ Enabled threat intelligence feed: $($feed.Name)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to enable $($feed.Name): $($_.Exception.Message)"
    }
}
```

#### 5.3 Watchlists and IoC Management

**Create Watchlists for Known Bad Indicators:**
```powershell
# Create IP address watchlist for known bad IPs
$watchlistParams = @{
    ResourceGroupName = "rg-security-prod-eus2-001"
    WorkspaceName = "law-security-prod-eus2-001"
    WatchlistAlias = "BadIPAddresses"
    DisplayName = "Known Malicious IP Addresses"
    Description = "List of known malicious IP addresses from threat intelligence"
    Provider = "Security Team"
    Source = "ThreatIntelligence"
    ItemsSearchKey = "IPAddress"
}

New-AzSentinelWatchlist @watchlistParams

# Add sample malicious IPs to watchlist
$maliciousIPs = @(
    @{ IPAddress = "192.0.2.1"; Description = "Known C2 Server"; ThreatType = "C2"; FirstSeen = "2024-01-01" },
    @{ IPAddress = "192.0.2.2"; Description = "Malware Distribution"; ThreatType = "Malware"; FirstSeen = "2024-01-01" },
    @{ IPAddress = "192.0.2.3"; Description = "Phishing Infrastructure"; ThreatType = "Phishing"; FirstSeen = "2024-01-01" }
)

foreach ($ip in $maliciousIPs) {
    New-AzSentinelWatchlistItem -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" -WatchlistAlias "BadIPAddresses" -ItemProperties $ip
}
```

### Phase 6: Workbooks and Reporting (Weeks 10-12)

#### 6.1 Security Operations Workbook

**Deploy SOC Overview Workbook:**
```json
{
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 1,
      "content": {
        "json": "# Security Operations Center Dashboard\n\nThis workbook provides a comprehensive view of security operations including incidents, alerts, and threat hunting activities."
      },
      "name": "SOC Header"
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "SecurityIncident\r\n| where TimeGenerated >= ago(30d)\r\n| summarize Count = count() by Status\r\n| render piechart",
        "size": 1,
        "title": "Incident Status Distribution (Last 30 Days)",
        "timeContext": {
          "durationMs": 2592000000
        },
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces"
      },
      "customWidth": "50",
      "name": "Incident Status Chart"
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "SecurityAlert\r\n| where TimeGenerated >= ago(7d)\r\n| summarize Count = count() by AlertSeverity\r\n| render columnchart",
        "size": 1,
        "title": "Alert Volume by Severity (Last 7 Days)", 
        "timeContext": {
          "durationMs": 604800000
        },
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces"
      },
      "customWidth": "50",
      "name": "Alert Severity Chart"
    }
  ]
}
```

## Post-Deployment Validation

### Data Flow Validation
```bash
# Verify data ingestion from all sources
az monitor log-analytics query \
  --workspace "law-security-prod-eus2-001" \
  --analytics-query "
    union *
    | where TimeGenerated >= ago(1h)
    | summarize Count = count(), Latest = max(TimeGenerated) by Type
    | order by Count desc
  "
```

### Analytics Rules Testing
```kql
// Test analytics rules are firing
SecurityAlert
| where TimeGenerated >= ago(1h)
| summarize count() by AlertName, AlertSeverity
| order by count_ desc
```

### Incident Creation Validation
```powershell
# Check incident creation and assignment
Get-AzSentinelIncident -ResourceGroupName "rg-security-prod-eus2-001" -WorkspaceName "law-security-prod-eus2-001" | Where-Object { $_.CreatedTimeUtc -gt (Get-Date).AddHours(-24) }
```

This comprehensive implementation guide provides the foundation for deploying enterprise-grade Azure Sentinel SIEM capabilities with automated threat detection, incident response, and security operations workflows.