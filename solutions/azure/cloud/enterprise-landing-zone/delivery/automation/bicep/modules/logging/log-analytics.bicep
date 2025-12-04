// ============================================================================
// Log Analytics Workspace Module
// ============================================================================
// Description: Creates Log Analytics workspace for centralized logging
//              and monitoring across the Azure environment
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

@description('Log retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int

@description('Daily ingestion capacity in GB')
@minValue(100)
@maxValue(5000)
param dailyQuotaGb int

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var resourceGroupName = 'rg-${solutionPrefix}-monitoring-${environment}'
var workspaceName = 'log-${solutionPrefix}-${environment}'

// ============================================================================
// RESOURCE GROUP
// ============================================================================

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ============================================================================
// LOG ANALYTICS WORKSPACE
// ============================================================================

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  scope: rg
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// ============================================================================
// SOLUTIONS
// ============================================================================

resource securitySolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'Security(${workspace.name})'
  location: location
  tags: tags
  scope: rg
  plan: {
    name: 'Security(${workspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/Security'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspace.id
  }
}

resource updatesSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'Updates(${workspace.name})'
  location: location
  tags: tags
  scope: rg
  plan: {
    name: 'Updates(${workspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/Updates'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspace.id
  }
}

resource changeTrackingSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'ChangeTracking(${workspace.name})'
  location: location
  tags: tags
  scope: rg
  plan: {
    name: 'ChangeTracking(${workspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/ChangeTracking'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspace.id
  }
}

resource vmInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'VMInsights(${workspace.name})'
  location: location
  tags: tags
  scope: rg
  plan: {
    name: 'VMInsights(${workspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/VMInsights'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspace.id
  }
}

resource containerInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'ContainerInsights(${workspace.name})'
  location: location
  tags: tags
  scope: rg
  plan: {
    name: 'ContainerInsights(${workspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/ContainerInsights'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: workspace.id
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output workspaceResourceId string = workspace.id
output workspaceName string = workspace.name
output workspaceId string = workspace.properties.customerId
output resourceGroupName string = rg.name
