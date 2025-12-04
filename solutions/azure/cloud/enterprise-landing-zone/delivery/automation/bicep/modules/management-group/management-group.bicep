// ============================================================================
// Management Group Hierarchy Module
// ============================================================================
// Description: Creates and configures Azure Management Group hierarchy
//              following Enterprise Landing Zone best practices
// ============================================================================

targetScope = 'managementGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Root management group ID')
param managementGroupRoot string

@description('Platform management group name')
param managementGroupPlatform string

@description('Landing zones management group name')
param managementGroupLandingZones string

@description('Corporate management group name')
param managementGroupCorp string

@description('Online management group name')
param managementGroupOnline string

// ============================================================================
// RESOURCES
// ============================================================================

// Platform Management Group - For shared platform services
resource platformMg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupPlatform
  properties: {
    displayName: 'Platform'
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', managementGroupRoot)
      }
    }
  }
}

// Landing Zones Management Group - For application workloads
resource landingZonesMg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupLandingZones
  properties: {
    displayName: 'Landing Zones'
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', managementGroupRoot)
      }
    }
  }
}

// Corporate Management Group - For internal workloads
resource corpMg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupCorp
  properties: {
    displayName: 'Corp'
    details: {
      parent: {
        id: landingZonesMg.id
      }
    }
  }
}

// Online Management Group - For public-facing workloads
resource onlineMg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupOnline
  properties: {
    displayName: 'Online'
    details: {
      parent: {
        id: landingZonesMg.id
      }
    }
  }
}

// Sandbox Management Group - For development and testing
resource sandboxMg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'mg-sandbox'
  properties: {
    displayName: 'Sandbox'
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', managementGroupRoot)
      }
    }
  }
}

// Decommissioned Management Group - For retired subscriptions
resource decommissionedMg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'mg-decommissioned'
  properties: {
    displayName: 'Decommissioned'
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', managementGroupRoot)
      }
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output platformMgId string = platformMg.id
output landingZonesMgId string = landingZonesMg.id
output corpMgId string = corpMg.id
output onlineMgId string = onlineMg.id
output sandboxMgId string = sandboxMg.id
output decommissionedMgId string = decommissionedMg.id
