// ============================================================================
// Azure Sentinel Module
// ============================================================================
// Description: Enables Azure Sentinel SIEM on Log Analytics workspace with
//              data connectors and analytics rules
// ============================================================================

targetScope = 'subscription'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Environment name')
param environment string

@description('Solution prefix for resource naming')
param solutionPrefix string

@description('Azure region for deployment')
param location string

@description('Log Analytics workspace resource ID')
param workspaceResourceId string

@description('Log retention in days')
param retentionInDays int

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var resourceGroupName = 'rg-${solutionPrefix}-monitoring-${environment}'
var workspaceName = last(split(workspaceResourceId, '/'))

// ============================================================================
// AZURE SENTINEL
// ============================================================================

resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspaceName})'
  location: location
  tags: tags
  scope: resourceGroup(resourceGroupName)
  plan: {
    name: 'SecurityInsights(${workspaceName})'
    publisher: 'Microsoft'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspaceResourceId
  }
}

// ============================================================================
// SENTINEL ONBOARDING
// ============================================================================

resource sentinelOnboarding 'Microsoft.SecurityInsights/onboardingStates@2023-02-01' = {
  name: 'default'
  scope: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
  properties: {}
  dependsOn: [
    sentinel
  ]
}

// ============================================================================
// DATA CONNECTORS
// ============================================================================

// Azure Activity Connector
resource activityConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = {
  name: guid('AzureActivity', workspaceResourceId)
  scope: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
  kind: 'AzureActivity'
  properties: {
    dataTypes: {
      logs: {
        state: 'Enabled'
      }
    }
  }
  dependsOn: [
    sentinelOnboarding
  ]
}

// Azure AD Identity Protection Connector
resource aadipConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = {
  name: guid('AzureActiveDirectoryIdentityProtection', workspaceResourceId)
  scope: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
  kind: 'AzureActiveDirectory'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
  }
  dependsOn: [
    sentinelOnboarding
  ]
}

// Azure Security Center Connector
resource ascConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = {
  name: guid('AzureSecurityCenter', workspaceResourceId)
  scope: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
  kind: 'AzureSecurityCenter'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
  }
  dependsOn: [
    sentinelOnboarding
  ]
}

// Microsoft Defender for Cloud Apps Connector
resource mdcaConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = {
  name: guid('MicrosoftCloudAppSecurity', workspaceResourceId)
  scope: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
  kind: 'MicrosoftCloudAppSecurity'
  properties: {
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
      discoveryLogs: {
        state: 'Enabled'
      }
    }
  }
  dependsOn: [
    sentinelOnboarding
  ]
}

// ============================================================================
// ANALYTICS RULES
// ============================================================================

// Suspicious Resource Creation
resource suspiciousResourceRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  name: guid('SuspiciousResourceCreation', workspaceResourceId)
  scope: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
  kind: 'Scheduled'
  properties: {
    displayName: 'Suspicious Resource Creation Activity'
    description: 'Detects unusual resource creation patterns that may indicate unauthorized activity'
    severity: 'Medium'
    enabled: true
    query: '''
      AzureActivity
      | where OperationNameValue =~ "Microsoft.Resources/deployments/write"
      | where ActivityStatusValue == "Success"
      | summarize count() by Caller, bin(TimeGenerated, 1h)
      | where count_ > 10
    '''
    queryFrequency: 'PT1H'
    queryPeriod: 'PT1H'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: false
    tactics: [
      'Impact'
      'Execution'
    ]
  }
  dependsOn: [
    sentinelOnboarding
  ]
}

// Failed Login Attempts
resource failedLoginRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  name: guid('FailedLoginAttempts', workspaceResourceId)
  scope: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
  kind: 'Scheduled'
  properties: {
    displayName: 'Multiple Failed Login Attempts'
    description: 'Detects multiple failed authentication attempts from the same user'
    severity: 'High'
    enabled: true
    query: '''
      SigninLogs
      | where ResultType != "0"
      | summarize FailedAttempts=count() by UserPrincipalName, IPAddress, bin(TimeGenerated, 5m)
      | where FailedAttempts > 5
    '''
    queryFrequency: 'PT5M'
    queryPeriod: 'PT5M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: false
    tactics: [
      'CredentialAccess'
      'InitialAccess'
    ]
  }
  dependsOn: [
    sentinelOnboarding
  ]
}

// ============================================================================
// OUTPUTS
// ============================================================================

output workspaceId string = workspaceResourceId
output sentinelEnabled bool = true
output dataConnectorsCount int = 4
