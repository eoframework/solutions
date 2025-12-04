// ============================================================================
// Microsoft Sentinel Module
// ============================================================================
// Description: Enables and configures Microsoft Sentinel on Log Analytics
// Version: 1.0.0
// ============================================================================

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure region for deployment')
param location string

@description('Enable User Entity Behavior Analytics (UEBA)')
param enableUEBA bool = false

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// EXISTING WORKSPACE REFERENCE
// ============================================================================

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

// ============================================================================
// SENTINEL ONBOARDING SETTINGS
// ============================================================================

resource sentinelOnboarding 'Microsoft.SecurityInsights/onboardingStates@2023-02-01' = {
  scope: workspace
  name: 'default'
  properties: {}
}

// ============================================================================
// SENTINEL SETTINGS
// ============================================================================

resource sentinelSettings 'Microsoft.SecurityInsights/settings@2023-02-01' = {
  scope: workspace
  name: 'Anomalies'
  kind: 'Anomalies'
  properties: {
    isEnabled: true
  }
  dependsOn: [
    sentinelOnboarding
  ]
}

// ============================================================================
// UEBA CONFIGURATION
// ============================================================================

resource uebaSettings 'Microsoft.SecurityInsights/settings@2023-02-01' = if (enableUEBA) {
  scope: workspace
  name: 'EntityAnalytics'
  kind: 'EntityAnalytics'
  properties: {
    entityProviders: [
      'AzureActiveDirectory'
    ]
  }
  dependsOn: [
    sentinelOnboarding
  ]
}

// ============================================================================
// THREAT INTELLIGENCE SETTINGS
// ============================================================================

resource threatIntelSettings 'Microsoft.SecurityInsights/settings@2023-02-01' = {
  scope: workspace
  name: 'ThreatIntelligence'
  kind: 'ThreatIntelligence'
  properties: {}
  dependsOn: [
    sentinelOnboarding
  ]
}

// ============================================================================
// WATCHLIST SETTINGS
// ============================================================================

resource watchlistSettings 'Microsoft.SecurityInsights/settings@2023-02-01' = {
  scope: workspace
  name: 'Watchlists'
  kind: 'Watchlists'
  properties: {}
  dependsOn: [
    sentinelOnboarding
  ]
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Sentinel Onboarding Status')
output sentinelOnboarded bool = true

@description('UEBA Enabled Status')
output uebaEnabled bool = enableUEBA

@description('Workspace ID')
output workspaceId string = workspace.id
