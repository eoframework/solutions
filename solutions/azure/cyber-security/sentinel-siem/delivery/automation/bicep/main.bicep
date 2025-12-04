// ============================================================================
// Microsoft Sentinel SIEM Solution - Main Orchestration
// ============================================================================
// Description: Main Bicep template for deploying Microsoft Sentinel SIEM
// Version: 1.0.0
// Last Updated: 2025-12-03
// ============================================================================

targetScope = 'subscription'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Environment name (prod, test, dr)')
@allowed([
  'prod'
  'test'
  'dr'
])
param environment string

@description('Primary Azure region for Sentinel deployment')
param location string = 'eastus'

@description('Prefix for all Azure resource naming')
@minLength(3)
@maxLength(8)
param solutionPrefix string = 'sentinel'

@description('Resource group name for Sentinel resources')
param resourceGroupName string = 'rg-${solutionPrefix}-${environment}-001'

// Log Analytics Workspace Parameters
@description('Log Analytics workspace name')
param logAnalyticsWorkspaceName string = 'log-${solutionPrefix}-${environment}-001'

@description('Log Analytics pricing tier')
@allowed([
  'PerGB2018'
  'CapacityReservation'
])
param logAnalyticsSku string = 'PerGB2018'

@description('Log retention in days')
@minValue(30)
@maxValue(730)
param logAnalyticsRetentionDays int

@description('Daily ingestion cap in GB')
@minValue(1)
@maxValue(5000)
param dailyIngestionCapGb int

@description('Archive retention in days (2 years for compliance)')
@minValue(365)
@maxValue(2555)
param archiveRetentionDays int = 730

// Sentinel Configuration
@description('Azure Sentinel pricing tier')
@allowed([
  'Free'
  'Standard'
])
param sentinelTier string = 'Standard'

// Data Connectors
@description('Enable Office 365 data connector')
param enableOffice365Connector bool = true

@description('Enable Azure AD data connector')
param enableAzureADConnector bool = true

@description('Enable Azure Activity data connector')
param enableAzureActivityConnector bool = true

@description('Enable Defender for Cloud connector')
param enableDefenderCloudConnector bool = true

@description('Enable Defender for Endpoint connector')
param enableDefenderEndpointConnector bool = true

@description('Enable Defender for Identity connector')
param enableDefenderIdentityConnector bool = true

@description('Enable Defender for Office 365 connector')
param enableDefenderO365Connector bool = true

@description('Enable CEF/Syslog connector')
param enableCEFConnector bool = true

@description('Enable DNS logs connector')
param enableDNSConnector bool = true

// Analytics Rules
@description('Number of built-in analytics rules to enable')
@minValue(10)
@maxValue(100)
param builtInRulesCount int = 30

@description('Number of custom analytics rules to deploy')
@minValue(5)
@maxValue(50)
param customRulesCount int = 20

// UEBA Configuration
@description('Enable User Entity Behavior Analytics')
param enableUEBA bool = false

@description('Number of threat intelligence feeds')
@minValue(1)
@maxValue(20)
param threatIntelFeedsCount int = 10

// Automation Playbooks
@description('Number of SOAR playbooks to deploy')
@minValue(5)
@maxValue(50)
param playbookCount int = 12

@description('Enable auto-enrichment playbooks')
param enableAutoEnrichment bool = true

@description('Enable auto-containment playbooks')
param enableAutoContainment bool = true

@description('Enable auto-ticketing playbooks')
param enableAutoTicketing bool = true

// Integration Parameters
@description('Key Vault name for secrets management')
param keyVaultName string = 'kv-${solutionPrefix}-${environment}-001'

@description('ServiceNow endpoint URL for ticketing')
param serviceNowEndpoint string = ''

@description('ServiceNow API user')
@secure()
param serviceNowApiUser string = ''

@description('ServiceNow API password')
@secure()
param serviceNowApiPassword string = ''

@description('Microsoft Teams webhook URL for alerts')
@secure()
param teamsWebhookUrl string = ''

@description('Email for critical security alerts')
param alertEmail string

@description('Azure AD group ID for SOC analysts')
param socAdGroupId string

@description('Azure AD group ID for SOC admins')
param socAdminGroupId string

// Tags
@description('Tags to apply to all resources')
param tags object = {
  Solution: 'Microsoft Sentinel SIEM'
  Environment: environment
  ManagedBy: 'Bicep'
  LastUpdated: '2025-12-03'
}

// ============================================================================
// VARIABLES
// ============================================================================

var resourceGroupLocation = location

// ============================================================================
// RESOURCE GROUP
// ============================================================================

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: tags
}

// ============================================================================
// LOG ANALYTICS WORKSPACE MODULE
// ============================================================================

module logAnalyticsWorkspace './modules/log-analytics-workspace.bicep' = {
  scope: resourceGroup
  name: 'deploy-log-analytics-workspace'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionDays
    dailyQuotaGb: dailyIngestionCapGb
    tags: tags
  }
}

// ============================================================================
// SENTINEL MODULE
// ============================================================================

module sentinel './modules/sentinel.bicep' = {
  scope: resourceGroup
  name: 'deploy-sentinel'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    enableUEBA: enableUEBA
    tags: tags
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}

// ============================================================================
// KEY VAULT MODULE
// ============================================================================

module keyVault './modules/key-vault.bicep' = {
  scope: resourceGroup
  name: 'deploy-key-vault'
  params: {
    keyVaultName: keyVaultName
    location: location
    tenantId: subscription().tenantId
    socAdminGroupId: socAdminGroupId
    tags: tags
  }
}

// ============================================================================
// DATA CONNECTORS MODULE
// ============================================================================

module dataConnectors './modules/data-connectors.bicep' = {
  scope: resourceGroup
  name: 'deploy-data-connectors'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    subscriptionId: subscription().subscriptionId
    tenantId: subscription().tenantId
    enableOffice365: enableOffice365Connector
    enableAzureAD: enableAzureADConnector
    enableAzureActivity: enableAzureActivityConnector
    enableDefenderCloud: enableDefenderCloudConnector
    enableDefenderEndpoint: enableDefenderEndpointConnector
    enableDefenderIdentity: enableDefenderIdentityConnector
    enableDefenderO365: enableDefenderO365Connector
    enableCEF: enableCEFConnector
    enableDNS: enableDNSConnector
  }
  dependsOn: [
    sentinel
  ]
}

// ============================================================================
// ANALYTICS RULES MODULE
// ============================================================================

module analyticsRules './modules/analytics-rules.bicep' = {
  scope: resourceGroup
  name: 'deploy-analytics-rules'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    builtInRulesCount: builtInRulesCount
    customRulesCount: customRulesCount
    alertEmail: alertEmail
    environment: environment
  }
  dependsOn: [
    dataConnectors
  ]
}

// ============================================================================
// AUTOMATION PLAYBOOKS MODULE
// ============================================================================

module playbooks './modules/playbooks.bicep' = {
  scope: resourceGroup
  name: 'deploy-playbooks'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    environment: environment
    keyVaultName: keyVaultName
    playbookCount: playbookCount
    enableAutoEnrichment: enableAutoEnrichment
    enableAutoContainment: enableAutoContainment
    enableAutoTicketing: enableAutoTicketing
    serviceNowEndpoint: serviceNowEndpoint
    teamsWebhookUrl: teamsWebhookUrl
    alertEmail: alertEmail
    tags: tags
  }
  dependsOn: [
    sentinel
    keyVault
  ]
}

// ============================================================================
// WORKBOOKS MODULE
// ============================================================================

module workbooks './modules/workbooks.bicep' = {
  scope: resourceGroup
  name: 'deploy-workbooks'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    environment: environment
    tags: tags
  }
  dependsOn: [
    sentinel
    dataConnectors
  ]
}

// ============================================================================
// RBAC ASSIGNMENTS MODULE
// ============================================================================

module rbacAssignments './modules/rbac-assignments.bicep' = {
  scope: resourceGroup
  name: 'deploy-rbac-assignments'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    socAdGroupId: socAdGroupId
    socAdminGroupId: socAdminGroupId
  }
  dependsOn: [
    sentinel
  ]
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Resource Group Name')
output resourceGroupName string = resourceGroup.name

@description('Log Analytics Workspace ID')
output workspaceId string = logAnalyticsWorkspace.outputs.workspaceId

@description('Log Analytics Workspace Name')
output workspaceName string = logAnalyticsWorkspaceName

@description('Key Vault Name')
output keyVaultName string = keyVault.outputs.keyVaultName

@description('Deployment Environment')
output environment string = environment

@description('Deployment Location')
output location string = location

@description('Sentinel Status')
output sentinelStatus string = 'Deployed'

@description('Data Connectors Enabled')
output dataConnectorsEnabled array = dataConnectors.outputs.enabledConnectors

@description('Analytics Rules Count')
output analyticsRulesCount int = builtInRulesCount + customRulesCount

@description('Playbooks Deployed')
output playbooksDeployed int = playbooks.outputs.playbookCount
