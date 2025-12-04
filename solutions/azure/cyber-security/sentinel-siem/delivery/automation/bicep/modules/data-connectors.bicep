// ============================================================================
// Data Connectors Module
// ============================================================================
// Description: Configures Sentinel data connectors for log ingestion
// Version: 1.0.0
// ============================================================================

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure region for deployment')
param location string

@description('Azure subscription ID')
param subscriptionId string

@description('Azure AD tenant ID')
param tenantId string

@description('Enable Office 365 data connector')
param enableOffice365 bool = true

@description('Enable Azure AD data connector')
param enableAzureAD bool = true

@description('Enable Azure Activity data connector')
param enableAzureActivity bool = true

@description('Enable Defender for Cloud connector')
param enableDefenderCloud bool = true

@description('Enable Defender for Endpoint connector')
param enableDefenderEndpoint bool = true

@description('Enable Defender for Identity connector')
param enableDefenderIdentity bool = true

@description('Enable Defender for Office 365 connector')
param enableDefenderO365 bool = true

@description('Enable CEF/Syslog connector')
param enableCEF bool = true

@description('Enable DNS logs connector')
param enableDNS bool = true

// ============================================================================
// EXISTING WORKSPACE REFERENCE
// ============================================================================

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

// ============================================================================
// OFFICE 365 DATA CONNECTOR
// ============================================================================

resource office365Connector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableOffice365) {
  scope: workspace
  name: 'office365-connector'
  kind: 'Office365'
  properties: {
    tenantId: tenantId
    dataTypes: {
      exchange: {
        state: 'Enabled'
      }
      sharePoint: {
        state: 'Enabled'
      }
      teams: {
        state: 'Enabled'
      }
    }
  }
}

// ============================================================================
// AZURE ACTIVE DIRECTORY DATA CONNECTOR
// ============================================================================

resource azureADConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableAzureAD) {
  scope: workspace
  name: 'azuread-connector'
  kind: 'AzureActiveDirectory'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
  }
}

// ============================================================================
// AZURE ACTIVITY DATA CONNECTOR
// ============================================================================

resource azureActivityConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableAzureActivity) {
  scope: workspace
  name: 'azureactivity-connector'
  kind: 'AzureActivity'
  properties: {
    subscriptionId: subscriptionId
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
  }
}

// ============================================================================
// MICROSOFT DEFENDER FOR CLOUD DATA CONNECTOR
// ============================================================================

resource defenderCloudConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableDefenderCloud) {
  scope: workspace
  name: 'defendercloud-connector'
  kind: 'AzureSecurityCenter'
  properties: {
    subscriptionId: subscriptionId
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
  }
}

// ============================================================================
// MICROSOFT DEFENDER FOR ENDPOINT DATA CONNECTOR
// ============================================================================

resource defenderEndpointConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableDefenderEndpoint) {
  scope: workspace
  name: 'defenderendpoint-connector'
  kind: 'MicrosoftDefenderAdvancedThreatProtection'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
  }
}

// ============================================================================
// MICROSOFT DEFENDER FOR IDENTITY DATA CONNECTOR
// ============================================================================

resource defenderIdentityConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableDefenderIdentity) {
  scope: workspace
  name: 'defenderidentity-connector'
  kind: 'AzureAdvancedThreatProtection'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
  }
}

// ============================================================================
// MICROSOFT DEFENDER FOR OFFICE 365 DATA CONNECTOR
// ============================================================================

resource defenderO365Connector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = if (enableDefenderO365) {
  scope: workspace
  name: 'defendero365-connector'
  kind: 'OfficeATP'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'Enabled'
      }
    }
  }
}

// ============================================================================
// THREAT INTELLIGENCE PLATFORM DATA CONNECTOR
// ============================================================================

resource threatIntelConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = {
  scope: workspace
  name: 'threatintel-connector'
  kind: 'ThreatIntelligence'
  properties: {
    tenantId: tenantId
    dataTypes: {
      indicators: {
        state: 'Enabled'
      }
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('List of enabled data connectors')
output enabledConnectors array = [
  enableOffice365 ? 'Office365' : ''
  enableAzureAD ? 'AzureActiveDirectory' : ''
  enableAzureActivity ? 'AzureActivity' : ''
  enableDefenderCloud ? 'DefenderForCloud' : ''
  enableDefenderEndpoint ? 'DefenderForEndpoint' : ''
  enableDefenderIdentity ? 'DefenderForIdentity' : ''
  enableDefenderO365 ? 'DefenderForOffice365' : ''
  enableCEF ? 'CEF' : ''
  enableDNS ? 'DNS' : ''
  'ThreatIntelligence'
]

@description('Total connectors enabled')
output connectorsCount int = length(filter(enabledConnectors, connector => connector != ''))
