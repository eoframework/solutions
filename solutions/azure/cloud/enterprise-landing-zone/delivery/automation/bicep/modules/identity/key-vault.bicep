// ============================================================================
// Key Vault Module
// ============================================================================
// Description: Creates Azure Key Vault for centralized secrets, keys, and
//              certificate management with RBAC and audit logging
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

@description('Key Vault SKU')
@allowed(['Standard', 'Premium'])
param keyVaultSku string

@description('Enable soft delete')
param softDeleteEnabled bool

@description('Enable purge protection')
param purgeProtectionEnabled bool

@description('Admin group object ID')
param adminGroupObjectId string

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var resourceGroupName = 'rg-${solutionPrefix}-identity-${environment}'
var keyVaultName = 'kv-${solutionPrefix}-${environment}-${uniqueString(resourceGroupName)}'

// ============================================================================
// RESOURCE GROUP
// ============================================================================

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ============================================================================
// KEY VAULT
// ============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: tags
  scope: rg
  properties: {
    sku: {
      family: 'A'
      name: keyVaultSku
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: softDeleteEnabled
    softDeleteRetentionInDays: 90
    enablePurgeProtection: purgeProtectionEnabled ? true : null
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

// ============================================================================
// RBAC ASSIGNMENTS
// ============================================================================

// Key Vault Administrator role for admin group
resource kvAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, adminGroupObjectId, 'KeyVaultAdministrator')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b303-3f3a8e8e5f34')
    principalId: adminGroupObjectId
    principalType: 'Group'
  }
}

// ============================================================================
// DIAGNOSTIC SETTINGS
// ============================================================================

resource kvDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${keyVaultName}'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ============================================================================
// SECRETS (PLACEHOLDER)
// ============================================================================

resource placeholderSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'deployment-timestamp'
  properties: {
    value: utcNow()
    attributes: {
      enabled: true
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
output resourceGroupName string = rg.name
