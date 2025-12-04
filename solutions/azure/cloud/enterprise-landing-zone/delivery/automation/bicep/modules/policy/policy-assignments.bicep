// ============================================================================
// Azure Policy Assignments Module
// ============================================================================
// Description: Assigns Azure Policy initiatives and policies for governance,
//              security, and compliance across the management group hierarchy
// ============================================================================

targetScope = 'managementGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Environment name')
param environment string

@description('Root management group ID')
param managementGroupRoot string

@description('Enforce mandatory resource tags')
param tagEnforcement bool

@description('Required tags list')
param requiredTags array

@description('Primary Azure region')
param primaryRegion string

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

// ============================================================================
// VARIABLES
// ============================================================================

var policyAssignmentPrefix = 'alz-${environment}'

// ============================================================================
// POLICY ASSIGNMENTS - SECURITY BASELINE
// ============================================================================

// Azure Security Benchmark
resource asbAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyAssignmentPrefix}-asb'
  properties: {
    displayName: 'Azure Security Benchmark Initiative'
    description: 'Assigns the Azure Security Benchmark policy initiative for security baseline compliance'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8'
    enforcementMode: 'Default'
    parameters: {
      logAnalyticsWorkspaceIdforVMReporting: {
        value: logAnalyticsWorkspaceId
      }
    }
  }
}

// Enable Microsoft Defender for Cloud
resource defenderAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyAssignmentPrefix}-defender'
  properties: {
    displayName: 'Enable Microsoft Defender for Cloud'
    description: 'Enables Microsoft Defender for Cloud on all subscriptions'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8'
    enforcementMode: 'Default'
  }
}

// Require encryption for data at rest
resource encryptionAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyAssignmentPrefix}-encryption'
  properties: {
    displayName: 'Require encryption for data at rest'
    description: 'Enforces encryption at rest for all applicable Azure services'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9'
    enforcementMode: 'Default'
  }
}

// ============================================================================
// POLICY ASSIGNMENTS - NETWORK SECURITY
// ============================================================================

// Restrict network access
resource networkSecurityAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyAssignmentPrefix}-network'
  properties: {
    displayName: 'Network Security Controls'
    description: 'Enforces network security best practices including NSG flow logs'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/f9a961fa-3241-4b20-adc4-bbf8ad9d7197'
    enforcementMode: 'Default'
    parameters: {
      logAnalytics: {
        value: logAnalyticsWorkspaceId
      }
    }
  }
}

// Deny public IP addresses on VMs
resource denyPublicIpAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if (environment == 'prod') {
  name: '${policyAssignmentPrefix}-deny-public-ip'
  properties: {
    displayName: 'Deny Public IP on Virtual Machines'
    description: 'Prevents creation of public IP addresses on VMs in production'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114'
    enforcementMode: 'Default'
  }
}

// ============================================================================
// POLICY ASSIGNMENTS - TAGGING AND GOVERNANCE
// ============================================================================

// Require resource tags
resource tagAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if (tagEnforcement) {
  name: '${policyAssignmentPrefix}-tags'
  properties: {
    displayName: 'Require Resource Tags'
    description: 'Enforces mandatory tags on all resources for cost allocation and governance'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025'
    enforcementMode: 'Default'
    parameters: {
      tagNames: {
        value: requiredTags
      }
    }
  }
}

// Inherit tags from resource group
resource inheritTagsAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyAssignmentPrefix}-inherit-tags'
  properties: {
    displayName: 'Inherit Tags from Resource Group'
    description: 'Automatically inherits specified tags from parent resource group'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/cd3aa116-8754-49c9-a813-4b43f0b512c5'
    enforcementMode: 'Default'
  }
}

// ============================================================================
// POLICY ASSIGNMENTS - MONITORING AND DIAGNOSTICS
// ============================================================================

// Deploy diagnostic settings for Azure services
resource diagnosticSettingsAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyAssignmentPrefix}-diagnostics'
  properties: {
    displayName: 'Deploy Diagnostic Settings'
    description: 'Automatically deploys diagnostic settings for Azure services to Log Analytics'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/0884adba-2312-4468-abeb-5422caed1038'
    enforcementMode: 'Default'
    parameters: {
      logAnalytics: {
        value: logAnalyticsWorkspaceId
      }
    }
  }
}

// Enable VM monitoring
resource vmMonitoringAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyAssignmentPrefix}-vm-monitoring'
  properties: {
    displayName: 'Enable VM Monitoring'
    description: 'Deploys Azure Monitor agent on all virtual machines'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/55f3eceb-5573-4f18-9695-226972c6d74a'
    enforcementMode: 'Default'
    parameters: {
      logAnalytics_1: {
        value: logAnalyticsWorkspaceId
      }
    }
  }
}

// ============================================================================
// POLICY ASSIGNMENTS - ALLOWED LOCATIONS
// ============================================================================

// Restrict resource locations
resource locationAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policyAssignmentPrefix}-locations'
  properties: {
    displayName: 'Allowed Resource Locations'
    description: 'Restricts resources to approved Azure regions only'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    enforcementMode: 'Default'
    parameters: {
      listOfAllowedLocations: {
        value: [
          primaryRegion
          'westus2'
          'centralus'
        ]
      }
    }
  }
}

// ============================================================================
// POLICY ASSIGNMENTS - COST MANAGEMENT
// ============================================================================

// Restrict VM SKUs
resource vmSkuAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if (environment != 'prod') {
  name: '${policyAssignmentPrefix}-vm-sku'
  properties: {
    displayName: 'Allowed VM SKUs'
    description: 'Restricts VM SKUs to control costs in non-production environments'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
    enforcementMode: 'Default'
    parameters: {
      listOfAllowedSKUs: {
        value: [
          'Standard_B2s'
          'Standard_B2ms'
          'Standard_D2s_v3'
          'Standard_D4s_v3'
        ]
      }
    }
  }
}

// ============================================================================
// POLICY ASSIGNMENTS - BACKUP AND DR
// ============================================================================

// Configure backup for VMs
resource backupAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if (environment == 'prod') {
  name: '${policyAssignmentPrefix}-backup'
  properties: {
    displayName: 'Configure Backup for VMs'
    description: 'Ensures all production VMs are backed up to Recovery Services vault'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86'
    enforcementMode: 'Default'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output policyAssignments array = [
  asbAssignment.id
  defenderAssignment.id
  encryptionAssignment.id
  networkSecurityAssignment.id
  diagnosticSettingsAssignment.id
  vmMonitoringAssignment.id
  locationAssignment.id
]
