// ============================================================================
// RBAC Assignments Module
// ============================================================================
// Description: Configures role-based access control for Sentinel
// Version: 1.0.0
// ============================================================================

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure AD group ID for SOC analysts (Reader role)')
param socAdGroupId string

@description('Azure AD group ID for SOC admins (Contributor role)')
param socAdminGroupId string

// ============================================================================
// EXISTING WORKSPACE REFERENCE
// ============================================================================

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

// ============================================================================
// ROLE DEFINITIONS
// ============================================================================

// Azure Sentinel Reader: ab8e14d6-4a74-4a29-9ba8-549422addade
// Azure Sentinel Responder: 3e150937-b8fe-4cfb-8069-0eaf05ecd056
// Azure Sentinel Contributor: ab8e14d6-4a74-4a29-9ba8-549422addcde
// Log Analytics Reader: 73c42c96-874c-492b-b04d-ab87d138a893

// ============================================================================
// SOC ANALYSTS - SENTINEL RESPONDER ROLE
// ============================================================================

resource socAnalystRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, socAdGroupId, 'Azure Sentinel Responder')
  scope: workspace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3e150937-b8fe-4cfb-8069-0eaf05ecd056')
    principalId: socAdGroupId
    principalType: 'Group'
    description: 'SOC Analysts - Sentinel Responder access for incident management'
  }
}

// ============================================================================
// SOC ANALYSTS - LOG ANALYTICS READER ROLE
// ============================================================================

resource socAnalystLogReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, socAdGroupId, 'Log Analytics Reader')
  scope: workspace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '73c42c96-874c-492b-b04d-ab87d138a893')
    principalId: socAdGroupId
    principalType: 'Group'
    description: 'SOC Analysts - Log Analytics read access for investigation'
  }
}

// ============================================================================
// SOC ADMINS - SENTINEL CONTRIBUTOR ROLE
// ============================================================================

resource socAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, socAdminGroupId, 'Azure Sentinel Contributor')
  scope: workspace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ab8e14d6-4a74-4a29-9ba8-549422addcde')
    principalId: socAdminGroupId
    principalType: 'Group'
    description: 'SOC Admins - Full Sentinel Contributor access'
  }
}

// ============================================================================
// SOC ADMINS - LOG ANALYTICS CONTRIBUTOR ROLE
// ============================================================================

resource socAdminLogContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, socAdminGroupId, 'Log Analytics Contributor')
  scope: workspace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '92aaf0da-9dab-42b6-94a3-d43ce8d16293')
    principalId: socAdminGroupId
    principalType: 'Group'
    description: 'SOC Admins - Log Analytics Contributor access for configuration'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('SOC Analyst role assignment status')
output socAnalystRoleAssigned bool = true

@description('SOC Admin role assignment status')
output socAdminRoleAssigned bool = true

@description('Total role assignments created')
output totalRoleAssignments int = 4
