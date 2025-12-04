// ============================================================================
// Microsoft Defender for Cloud Module
// ============================================================================
// Description: Enables Microsoft Defender for Cloud protection across
//              all Azure resource types with security recommendations
// ============================================================================

targetScope = 'subscription'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Environment name')
param environment string

@description('Defender for Cloud tier')
@allowed(['Free', 'Standard'])
param tier string

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

@description('Email for security alerts')
param alertEmail string

// ============================================================================
// SECURITY CENTER WORKSPACE
// ============================================================================

resource securityWorkspace 'Microsoft.Security/workspaceSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    scope: subscription().id
  }
}

// ============================================================================
// AUTO PROVISIONING
// ============================================================================

resource autoProvisioning 'Microsoft.Security/autoProvisioningSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    autoProvision: 'On'
  }
}

// ============================================================================
// SECURITY CONTACTS
// ============================================================================

resource securityContact 'Microsoft.Security/securityContacts@2020-01-01-preview' = {
  name: 'default'
  properties: {
    emails: alertEmail
    notificationsByRole: {
      state: 'On'
      roles: [
        'Owner'
        'Contributor'
      ]
    }
    alertNotifications: {
      state: 'On'
      minimalSeverity: 'Medium'
    }
  }
}

// ============================================================================
// DEFENDER PLANS
// ============================================================================

// Virtual Machines
resource defenderVms 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'VirtualMachines'
  properties: {
    pricingTier: tier
    subPlan: 'P2'
  }
}

// App Service
resource defenderAppService 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'AppServices'
  properties: {
    pricingTier: tier
  }
}

// SQL Databases
resource defenderSql 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'SqlServers'
  properties: {
    pricingTier: tier
  }
}

// Storage Accounts
resource defenderStorage 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: tier
    subPlan: 'DefenderForStorageV2'
  }
}

// Containers
resource defenderContainers 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'Containers'
  properties: {
    pricingTier: tier
  }
}

// Key Vault
resource defenderKeyVault 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'KeyVaults'
  properties: {
    pricingTier: tier
  }
}

// Resource Manager
resource defenderArm 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'Arm'
  properties: {
    pricingTier: tier
  }
}

// DNS
resource defenderDns 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'Dns'
  properties: {
    pricingTier: tier
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output defenderEnabled bool = true
output defenderTier string = tier
output workspaceConfigured bool = true
