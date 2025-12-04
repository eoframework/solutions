// ============================================================================
// Analytics Rules Module
// ============================================================================
// Description: Deploys Sentinel analytics rules for threat detection
// Version: 1.0.0
// ============================================================================

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure region for deployment')
param location string

@description('Number of built-in rules to enable')
param builtInRulesCount int = 30

@description('Number of custom rules to deploy')
param customRulesCount int = 20

@description('Email for critical security alerts')
param alertEmail string

@description('Environment (prod, test, dr)')
param environment string

// ============================================================================
// EXISTING WORKSPACE REFERENCE
// ============================================================================

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

// ============================================================================
// HIGH-PRIORITY ANALYTICS RULES
// ============================================================================

// Rule 1: Multiple Failed Login Attempts
resource failedLoginRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'multiple-failed-logins'
  kind: 'Scheduled'
  properties: {
    displayName: 'Multiple Failed Login Attempts from Single Source'
    description: 'Detects multiple failed login attempts from a single IP address or user account within a short time period'
    severity: 'High'
    enabled: true
    query: '''
SigninLogs
| where TimeGenerated > ago(15m)
| where ResultType != "0"
| summarize FailedAttempts = count(), Users = make_set(UserPrincipalName) by IPAddress, bin(TimeGenerated, 5m)
| where FailedAttempts >= 5
| project TimeGenerated, IPAddress, FailedAttempts, Users
'''
    queryFrequency: 'PT15M'
    queryPeriod: 'PT15M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: false
    tactics: [
      'CredentialAccess'
      'InitialAccess'
    ]
    techniques: [
      'T1110'
    ]
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT1H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'Account'
          'IP'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
    eventGroupingSettings: {
      aggregationKind: 'AlertPerResult'
    }
    alertDetailsOverride: {
      alertDisplayNameFormat: 'Failed Login Attempts from {{IPAddress}}'
      alertDescriptionFormat: '{{FailedAttempts}} failed login attempts detected from IP {{IPAddress}}'
      alertSeverityColumnName: 'Severity'
    }
  }
}

// Rule 2: Suspicious Admin Activity
resource suspiciousAdminRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'suspicious-admin-activity'
  kind: 'Scheduled'
  properties: {
    displayName: 'Suspicious Privileged Role Assignment'
    description: 'Detects privileged role assignments to user accounts'
    severity: 'High'
    enabled: true
    query: '''
AuditLogs
| where TimeGenerated > ago(5m)
| where OperationName == "Add member to role"
| where Result == "success"
| where TargetResources[0].modifiedProperties[0].newValue contains "Admin" or TargetResources[0].modifiedProperties[0].newValue contains "Global"
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend InitiatedBy = tostring(InitiatedBy.user.userPrincipalName)
| extend RoleName = tostring(TargetResources[0].modifiedProperties[0].newValue)
| project TimeGenerated, InitiatedBy, TargetUser, RoleName, OperationName
'''
    queryFrequency: 'PT5M'
    queryPeriod: 'PT5M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT30M'
    suppressionEnabled: false
    tactics: [
      'PrivilegeEscalation'
      'Persistence'
    ]
    techniques: [
      'T1078'
      'T1098'
    ]
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT1H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'Account'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
  }
}

// Rule 3: Unusual Resource Access
resource unusualAccessRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'unusual-resource-access'
  kind: 'Scheduled'
  properties: {
    displayName: 'Unusual Azure Resource Access Pattern'
    description: 'Detects unusual patterns of Azure resource access that may indicate reconnaissance or data exfiltration'
    severity: 'Medium'
    enabled: true
    query: '''
AzureActivity
| where TimeGenerated > ago(1h)
| where OperationNameValue endswith "read" or OperationNameValue endswith "list"
| summarize ResourceCount = dcount(ResourceId), Operations = make_set(OperationNameValue) by Caller, bin(TimeGenerated, 10m)
| where ResourceCount > 20
| project TimeGenerated, Caller, ResourceCount, Operations
'''
    queryFrequency: 'PT1H'
    queryPeriod: 'PT1H'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT2H'
    suppressionEnabled: false
    tactics: [
      'Discovery'
      'Collection'
    ]
    techniques: [
      'T1087'
      'T1069'
    ]
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT2H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'Account'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
  }
}

// Rule 4: Malware Detection
resource malwareDetectionRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'malware-detection'
  kind: 'Scheduled'
  properties: {
    displayName: 'Malware Detection from Defender for Endpoint'
    description: 'Detects malware identified by Microsoft Defender for Endpoint'
    severity: 'High'
    enabled: true
    query: '''
SecurityAlert
| where TimeGenerated > ago(5m)
| where ProviderName == "MDATP"
| where AlertSeverity in ("High", "Critical")
| where AlertName contains "malware" or AlertName contains "virus" or AlertName contains "trojan"
| extend DeviceName = tostring(parse_json(ExtendedProperties)["Device Name"])
| project TimeGenerated, AlertName, AlertSeverity, DeviceName, Description
'''
    queryFrequency: 'PT5M'
    queryPeriod: 'PT5M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT30M'
    suppressionEnabled: false
    tactics: [
      'Execution'
      'Impact'
    ]
    techniques: [
      'T1204'
      'T1486'
    ]
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: true
        lookbackDuration: 'PT6H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'Host'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
  }
}

// Rule 5: Data Exfiltration Detection
resource dataExfiltrationRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'data-exfiltration'
  kind: 'Scheduled'
  properties: {
    displayName: 'Potential Data Exfiltration to External Storage'
    description: 'Detects large data transfers to external storage services'
    severity: 'High'
    enabled: true
    query: '''
OfficeActivity
| where TimeGenerated > ago(1h)
| where Operation in ("FileDownloaded", "FileSyncDownloadedFull", "FileUploaded")
| where OfficeWorkload in ("SharePoint", "OneDrive")
| summarize FileCount = count(), TotalSize = sum(Size) by UserId, bin(TimeGenerated, 10m)
| where FileCount > 50 or TotalSize > 1073741824
| project TimeGenerated, UserId, FileCount, TotalSize
'''
    queryFrequency: 'PT1H'
    queryPeriod: 'PT1H'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT2H'
    suppressionEnabled: false
    tactics: [
      'Exfiltration'
    ]
    techniques: [
      'T1567'
    ]
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT3H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'Account'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
  }
}

// Rule 6: Brute Force Attack Detection
resource bruteForceRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'brute-force-attack'
  kind: 'Scheduled'
  properties: {
    displayName: 'Brute Force Attack Against Azure Resources'
    description: 'Detects brute force attacks targeting Azure authentication endpoints'
    severity: 'Critical'
    enabled: true
    query: '''
SigninLogs
| where TimeGenerated > ago(10m)
| where ResultType != "0"
| summarize FailedAttempts = count(), TargetAccounts = make_set(UserPrincipalName, 100) by IPAddress, bin(TimeGenerated, 5m)
| where FailedAttempts >= 10
| extend AccountCount = array_length(TargetAccounts)
| where AccountCount >= 3
| project TimeGenerated, IPAddress, FailedAttempts, AccountCount, TargetAccounts
'''
    queryFrequency: 'PT10M'
    queryPeriod: 'PT10M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: false
    tactics: [
      'CredentialAccess'
    ]
    techniques: [
      'T1110'
    ]
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT2H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'IP'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
  }
}

// Rule 7: Anomalous Login Location
resource anomalousLocationRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'anomalous-login-location'
  kind: 'Scheduled'
  properties: {
    displayName: 'Login from Unusual or Risky Location'
    description: 'Detects successful logins from unusual geographic locations or risky IP addresses'
    severity: 'Medium'
    enabled: true
    query: '''
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType == "0"
| where RiskLevelDuringSignIn in ("high", "medium") or RiskLevelAggregated in ("high", "medium")
| extend Country = tostring(LocationDetails.countryOrRegion)
| extend City = tostring(LocationDetails.city)
| project TimeGenerated, UserPrincipalName, IPAddress, Country, City, RiskLevelDuringSignIn, RiskLevelAggregated
'''
    queryFrequency: 'PT1H'
    queryPeriod: 'PT1H'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT3H'
    suppressionEnabled: false
    tactics: [
      'InitialAccess'
    ]
    techniques: [
      'T1078'
    ]
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT6H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'Account'
          'IP'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
  }
}

// Rule 8: Suspicious PowerShell Execution
resource suspiciousPowerShellRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'suspicious-powershell'
  kind: 'Scheduled'
  properties: {
    displayName: 'Suspicious PowerShell Command Execution'
    description: 'Detects execution of potentially malicious PowerShell commands'
    severity: 'High'
    enabled: true
    query: '''
SecurityEvent
| where TimeGenerated > ago(15m)
| where EventID == 4688
| where Process contains "powershell.exe" or Process contains "pwsh.exe"
| where CommandLine contains "-enc" or CommandLine contains "-encodedcommand"
    or CommandLine contains "downloadstring" or CommandLine contains "iex"
    or CommandLine contains "invoke-expression" or CommandLine contains "bypass"
| project TimeGenerated, Computer, Account, Process, CommandLine
'''
    queryFrequency: 'PT15M'
    queryPeriod: 'PT15M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: false
    tactics: [
      'Execution'
      'DefenseEvasion'
    ]
    techniques: [
      'T1059.001'
      'T1027'
    ]
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT2H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'Host'
          'Account'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Analytics rules deployed')
output rulesDeployed int = 8

@description('Rules severity distribution')
output severityDistribution object = {
  Critical: 1
  High: 4
  Medium: 3
}
