// ============================================================================
// Managed Identity Module
// ============================================================================
// Description: Creates user-assigned managed identities for service
//              authentication and Azure resource access
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

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var resourceGroupName = 'rg-${solutionPrefix}-identity-${environment}'
var managedIdentityName = 'id-${solutionPrefix}-${environment}'

// ============================================================================
// MANAGED IDENTITY
// ============================================================================

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: tags
  scope: resourceGroup(resourceGroupName)
}

// ============================================================================
// OUTPUTS
// ============================================================================

output identityId string = managedIdentity.id
output identityName string = managedIdentity.name
output principalId string = managedIdentity.properties.principalId
output clientId string = managedIdentity.properties.clientId
