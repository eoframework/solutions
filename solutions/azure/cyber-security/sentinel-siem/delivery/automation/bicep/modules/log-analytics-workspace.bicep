// ============================================================================
// Log Analytics Workspace Module
// ============================================================================
// Description: Creates and configures Log Analytics Workspace for Sentinel
// Version: 1.0.0
// ============================================================================

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure region for deployment')
param location string

@description('Log Analytics pricing tier')
@allowed([
  'PerGB2018'
  'CapacityReservation'
])
param sku string = 'PerGB2018'

@description('Log retention in days (30-730)')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

@description('Daily ingestion quota in GB (-1 for unlimited)')
param dailyQuotaGb int = -1

@description('Tags to apply to the workspace')
param tags object = {}

// ============================================================================
// LOG ANALYTICS WORKSPACE
// ============================================================================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: false
    }
  }
}

// ============================================================================
// WORKSPACE SOLUTIONS (Enable Security solution)
// ============================================================================

resource securityInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspaceName})'
  location: location
  tags: tags
  plan: {
    name: 'SecurityInsights(${workspaceName})'
    publisher: 'Microsoft'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}

// ============================================================================
// DIAGNOSTIC SETTINGS
// ============================================================================

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'workspace-diagnostics'
  scope: logAnalyticsWorkspace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: retentionInDays
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: retentionInDays
        }
      }
    ]
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Log Analytics Workspace ID')
output workspaceId string = logAnalyticsWorkspace.id

@description('Log Analytics Workspace Name')
output workspaceName string = logAnalyticsWorkspace.name

@description('Log Analytics Workspace Resource ID')
output workspaceResourceId string = logAnalyticsWorkspace.id

@description('Log Analytics Workspace Customer ID')
output workspaceCustomerId string = logAnalyticsWorkspace.properties.customerId
