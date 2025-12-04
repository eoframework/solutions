// ============================================================================
// Azure Enterprise Landing Zone - Main Orchestration
// ============================================================================
// Description: Main Bicep orchestration file for deploying Azure Landing Zone
//              with management groups, policies, networking, identity, and monitoring
// Version: 1.0.0
// Last Updated: 2025-01-03
// ============================================================================

targetScope = 'managementGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Environment name (prod, test, dr)')
param environment string

@description('Azure subscription ID for connectivity')
@secure()
param subscriptionIdConnectivity string

@description('Azure subscription ID for identity')
@secure()
param subscriptionIdIdentity string

@description('Azure subscription ID for management')
@secure()
param subscriptionIdManagement string

@description('Solution prefix for resource naming')
@minLength(3)
@maxLength(8)
param solutionPrefix string = 'alz'

@description('Primary Azure region')
param primaryRegion string = 'eastus'

@description('Secondary Azure region for DR')
param secondaryRegion string = 'westus2'

@description('Root management group ID')
param managementGroupRoot string

@description('Platform management group name')
param managementGroupPlatform string = 'mg-platform'

@description('Landing zones management group name')
param managementGroupLandingZones string = 'mg-landingzones'

@description('Corporate management group name')
param managementGroupCorp string = 'mg-corp'

@description('Online management group name')
param managementGroupOnline string = 'mg-online'

@description('Primary hub VNet CIDR')
param vnetHubPrimaryCidr string = '10.0.0.0/16'

@description('Secondary hub VNet CIDR')
param vnetHubSecondaryCidr string = '10.1.0.0/16'

@description('Azure Firewall subnet CIDR')
param subnetFirewall string = '10.0.0.0/26'

@description('Gateway subnet CIDR')
param subnetGateway string = '10.0.1.0/27'

@description('Bastion subnet CIDR')
param subnetBastion string = '10.0.2.0/27'

@description('Management subnet CIDR')
param subnetManagement string = '10.0.3.0/24'

@description('Azure Firewall SKU')
@allowed(['Standard', 'Premium'])
param firewallSku string = 'Premium'

@description('ExpressRoute SKU')
@allowed(['Standard', 'Premium'])
param expressRouteSku string = 'Standard'

@description('ExpressRoute bandwidth in Mbps')
@allowed([50, 100, 200, 500, 1000, 2000, 5000, 10000])
param expressRouteBandwidth int = 1000

@description('Enable DDoS Protection Standard')
param ddosProtectionEnabled bool = true

@description('Key Vault SKU')
@allowed(['Standard', 'Premium'])
param keyVaultSku string = 'Standard'

@description('Enable soft delete for Key Vault')
param keyVaultSoftDelete bool = true

@description('Enable purge protection for Key Vault')
param keyVaultPurgeProtection bool = true

@description('Azure AD admin group object ID')
@secure()
param azureAdAdminGroup string

@description('Azure AD reader group object ID')
@secure()
param azureAdReaderGroup string

@description('Enable Conditional Access policies')
param conditionalAccessEnabled bool = true

@description('Enable MFA enforcement')
param mfaEnforcement bool = true

@description('Enable Privileged Identity Management')
param pimEnabled bool = true

@description('Log Analytics retention in days')
@minValue(30)
@maxValue(730)
param logAnalyticsRetention int = 90

@description('Log Analytics daily capacity in GB')
@minValue(100)
@maxValue(5000)
param logAnalyticsCapacity int = 500

@description('Microsoft Defender for Cloud tier')
@allowed(['Free', 'Standard'])
param defenderCloudTier string = 'Standard'

@description('Azure Bastion SKU')
@allowed(['Basic', 'Standard'])
param bastionSku string = 'Standard'

@description('Bastion scale units')
@minValue(2)
@maxValue(50)
param bastionScaleUnits int = 2

@description('Enforce mandatory resource tags')
param tagEnforcement bool = true

@description('Required tags list')
param requiredTags array = [
  'CostCenter'
  'Owner'
  'Environment'
  'Application'
]

@description('Email for critical alerts')
param alertEmail string

@description('Enable geo-redundant backups')
param geoRedundantBackup bool = true

@description('Resource tags')
param tags object = {
  Solution: 'Azure Enterprise Landing Zone'
  Environment: environment
  ManagedBy: 'Bicep'
  DeploymentDate: utcNow('yyyy-MM-dd')
}

// ============================================================================
// MODULE: MANAGEMENT GROUP HIERARCHY
// ============================================================================

module managementGroups './modules/management-group/management-group.bicep' = {
  name: 'deploy-management-groups-${environment}'
  scope: managementGroup(managementGroupRoot)
  params: {
    managementGroupRoot: managementGroupRoot
    managementGroupPlatform: managementGroupPlatform
    managementGroupLandingZones: managementGroupLandingZones
    managementGroupCorp: managementGroupCorp
    managementGroupOnline: managementGroupOnline
  }
}

// ============================================================================
// MODULE: AZURE POLICY ASSIGNMENTS
// ============================================================================

module policies './modules/policy/policy-assignments.bicep' = {
  name: 'deploy-policies-${environment}'
  scope: managementGroup(managementGroupRoot)
  params: {
    environment: environment
    managementGroupRoot: managementGroupRoot
    tagEnforcement: tagEnforcement
    requiredTags: requiredTags
    primaryRegion: primaryRegion
    logAnalyticsWorkspaceId: logging.outputs.workspaceResourceId
  }
  dependsOn: [
    managementGroups
  ]
}

// ============================================================================
// MODULE: LOGGING AND MONITORING
// ============================================================================

module logging './modules/logging/log-analytics.bicep' = {
  name: 'deploy-logging-${environment}'
  scope: subscription(subscriptionIdManagement)
  params: {
    environment: environment
    solutionPrefix: solutionPrefix
    location: primaryRegion
    retentionInDays: logAnalyticsRetention
    dailyQuotaGb: logAnalyticsCapacity
    tags: tags
  }
}

module sentinel './modules/logging/azure-sentinel.bicep' = {
  name: 'deploy-sentinel-${environment}'
  scope: subscription(subscriptionIdManagement)
  params: {
    environment: environment
    solutionPrefix: solutionPrefix
    location: primaryRegion
    workspaceResourceId: logging.outputs.workspaceResourceId
    retentionInDays: logAnalyticsRetention
    tags: tags
  }
  dependsOn: [
    logging
  ]
}

// ============================================================================
// MODULE: HUB NETWORKING (PRIMARY)
// ============================================================================

module hubNetworkPrimary './modules/networking/hub-network.bicep' = {
  name: 'deploy-hub-network-primary-${environment}'
  scope: subscription(subscriptionIdConnectivity)
  params: {
    environment: environment
    solutionPrefix: solutionPrefix
    location: primaryRegion
    vnetAddressPrefix: vnetHubPrimaryCidr
    firewallSubnetPrefix: subnetFirewall
    gatewaySubnetPrefix: subnetGateway
    bastionSubnetPrefix: subnetBastion
    managementSubnetPrefix: subnetManagement
    firewallSku: firewallSku
    bastionSku: bastionSku
    bastionScaleUnits: bastionScaleUnits
    ddosProtectionEnabled: ddosProtectionEnabled
    logAnalyticsWorkspaceId: logging.outputs.workspaceResourceId
    tags: tags
  }
  dependsOn: [
    logging
  ]
}

module vpnGateway './modules/networking/vpn-gateway.bicep' = {
  name: 'deploy-vpn-gateway-${environment}'
  scope: subscription(subscriptionIdConnectivity)
  params: {
    environment: environment
    solutionPrefix: solutionPrefix
    location: primaryRegion
    vnetName: hubNetworkPrimary.outputs.vnetName
    gatewaySubnetId: hubNetworkPrimary.outputs.gatewaySubnetId
    logAnalyticsWorkspaceId: logging.outputs.workspaceResourceId
    tags: tags
  }
  dependsOn: [
    hubNetworkPrimary
  ]
}

module expressRoute './modules/networking/expressroute-gateway.bicep' = {
  name: 'deploy-expressroute-${environment}'
  scope: subscription(subscriptionIdConnectivity)
  params: {
    environment: environment
    solutionPrefix: solutionPrefix
    location: primaryRegion
    vnetName: hubNetworkPrimary.outputs.vnetName
    gatewaySubnetId: hubNetworkPrimary.outputs.gatewaySubnetId
    expressRouteSku: expressRouteSku
    expressRouteBandwidth: expressRouteBandwidth
    logAnalyticsWorkspaceId: logging.outputs.workspaceResourceId
    tags: tags
  }
  dependsOn: [
    vpnGateway
  ]
}

// ============================================================================
// MODULE: HUB NETWORKING (SECONDARY - DR)
// ============================================================================

module hubNetworkSecondary './modules/networking/hub-network.bicep' = {
  name: 'deploy-hub-network-secondary-${environment}'
  scope: subscription(subscriptionIdConnectivity)
  params: {
    environment: environment
    solutionPrefix: '${solutionPrefix}-dr'
    location: secondaryRegion
    vnetAddressPrefix: vnetHubSecondaryCidr
    firewallSubnetPrefix: '10.1.0.0/26'
    gatewaySubnetPrefix: '10.1.1.0/27'
    bastionSubnetPrefix: '10.1.2.0/27'
    managementSubnetPrefix: '10.1.3.0/24'
    firewallSku: firewallSku
    bastionSku: bastionSku
    bastionScaleUnits: bastionScaleUnits
    ddosProtectionEnabled: ddosProtectionEnabled
    logAnalyticsWorkspaceId: logging.outputs.workspaceResourceId
    tags: tags
  }
  dependsOn: [
    logging
  ]
}

// ============================================================================
// MODULE: IDENTITY AND ACCESS MANAGEMENT
// ============================================================================

module keyVault './modules/identity/key-vault.bicep' = {
  name: 'deploy-key-vault-${environment}'
  scope: subscription(subscriptionIdIdentity)
  params: {
    environment: environment
    solutionPrefix: solutionPrefix
    location: primaryRegion
    keyVaultSku: keyVaultSku
    softDeleteEnabled: keyVaultSoftDelete
    purgeProtectionEnabled: keyVaultPurgeProtection
    adminGroupObjectId: azureAdAdminGroup
    logAnalyticsWorkspaceId: logging.outputs.workspaceResourceId
    tags: tags
  }
  dependsOn: [
    logging
  ]
}

module managedIdentity './modules/identity/managed-identity.bicep' = {
  name: 'deploy-managed-identity-${environment}'
  scope: subscription(subscriptionIdIdentity)
  params: {
    environment: environment
    solutionPrefix: solutionPrefix
    location: primaryRegion
    tags: tags
  }
}

// ============================================================================
// MODULE: SECURITY CENTER AND DEFENDER
// ============================================================================

module defenderCloud './modules/security-center/defender-cloud.bicep' = {
  name: 'deploy-defender-cloud-${environment}'
  scope: subscription(subscriptionIdManagement)
  params: {
    environment: environment
    tier: defenderCloudTier
    logAnalyticsWorkspaceId: logging.outputs.workspaceResourceId
    alertEmail: alertEmail
  }
  dependsOn: [
    logging
  ]
}

module securityPolicies './modules/security-center/security-policies.bicep' = {
  name: 'deploy-security-policies-${environment}'
  scope: subscription(subscriptionIdManagement)
  params: {
    environment: environment
  }
  dependsOn: [
    defenderCloud
  ]
}

// ============================================================================
// OUTPUTS
// ============================================================================

output managementGroupIds object = {
  root: managementGroupRoot
  platform: managementGroupPlatform
  landingZones: managementGroupLandingZones
  corp: managementGroupCorp
  online: managementGroupOnline
}

output networkingIds object = {
  primaryHubVnetId: hubNetworkPrimary.outputs.vnetId
  primaryHubVnetName: hubNetworkPrimary.outputs.vnetName
  primaryFirewallId: hubNetworkPrimary.outputs.firewallId
  primaryBastionId: hubNetworkPrimary.outputs.bastionId
  secondaryHubVnetId: hubNetworkSecondary.outputs.vnetId
  secondaryHubVnetName: hubNetworkSecondary.outputs.vnetName
  secondaryFirewallId: hubNetworkSecondary.outputs.firewallId
}

output loggingIds object = {
  logAnalyticsWorkspaceId: logging.outputs.workspaceResourceId
  logAnalyticsWorkspaceName: logging.outputs.workspaceName
  sentinelWorkspaceId: sentinel.outputs.workspaceId
}

output identityIds object = {
  keyVaultId: keyVault.outputs.keyVaultId
  keyVaultName: keyVault.outputs.keyVaultName
  managedIdentityId: managedIdentity.outputs.identityId
  managedIdentityPrincipalId: managedIdentity.outputs.principalId
}

output deploymentInfo object = {
  deploymentTimestamp: deployment().properties.timestamp
  environment: environment
  primaryRegion: primaryRegion
  secondaryRegion: secondaryRegion
  solutionPrefix: solutionPrefix
}
