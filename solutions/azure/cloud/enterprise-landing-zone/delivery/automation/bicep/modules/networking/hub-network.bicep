// ============================================================================
// Hub Network Module
// ============================================================================
// Description: Creates hub virtual network with Azure Firewall, Bastion,
//              and gateway subnets following hub-spoke topology
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

@description('Hub VNet address prefix')
param vnetAddressPrefix string

@description('Azure Firewall subnet prefix')
param firewallSubnetPrefix string

@description('Gateway subnet prefix')
param gatewaySubnetPrefix string

@description('Bastion subnet prefix')
param bastionSubnetPrefix string

@description('Management subnet prefix')
param managementSubnetPrefix string

@description('Azure Firewall SKU')
@allowed(['Standard', 'Premium'])
param firewallSku string

@description('Azure Bastion SKU')
@allowed(['Basic', 'Standard'])
param bastionSku string

@description('Bastion scale units')
param bastionScaleUnits int

@description('Enable DDoS Protection Standard')
param ddosProtectionEnabled bool

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var resourceGroupName = 'rg-${solutionPrefix}-networking-${environment}'
var vnetName = 'vnet-${solutionPrefix}-hub-${environment}'
var firewallName = 'afw-${solutionPrefix}-${environment}'
var firewallPublicIpName = 'pip-${firewallName}'
var bastionName = 'bas-${solutionPrefix}-${environment}'
var bastionPublicIpName = 'pip-${bastionName}'
var ddosProtectionPlanName = 'ddos-${solutionPrefix}-${environment}'
var nsgFirewallName = 'nsg-${solutionPrefix}-firewall-${environment}'
var nsgManagementName = 'nsg-${solutionPrefix}-management-${environment}'

// ============================================================================
// RESOURCE GROUP
// ============================================================================

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ============================================================================
// DDOS PROTECTION PLAN
// ============================================================================

resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2023-05-01' = if (ddosProtectionEnabled) {
  name: ddosProtectionPlanName
  location: location
  tags: tags
  scope: rg
}

// ============================================================================
// NETWORK SECURITY GROUPS
// ============================================================================

resource nsgFirewall 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgFirewallName
  location: location
  tags: tags
  scope: rg
  properties: {
    securityRules: []
  }
}

resource nsgManagement 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgManagementName
  location: location
  tags: tags
  scope: rg
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP-From-Bastion'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: bastionSubnetPrefix
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-SSH-From-Bastion'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: bastionSubnetPrefix
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ============================================================================
// VIRTUAL NETWORK
// ============================================================================

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  scope: rg
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    ddosProtectionPlan: ddosProtectionEnabled ? {
      id: ddosProtectionPlan.id
    } : null
    enableDdosProtection: ddosProtectionEnabled
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnetPrefix
          networkSecurityGroup: {
            id: nsgFirewall.id
          }
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetPrefix
        }
      }
      {
        name: 'ManagementSubnet'
        properties: {
          addressPrefix: managementSubnetPrefix
          networkSecurityGroup: {
            id: nsgManagement.id
          }
        }
      }
    ]
  }
}

// ============================================================================
// AZURE FIREWALL
// ============================================================================

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: firewallPublicIpName
  location: location
  tags: tags
  scope: rg
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: firewallName
  location: location
  tags: tags
  scope: rg
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: firewallSku
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' = {
  name: '${firewallName}-policy'
  location: location
  tags: tags
  scope: rg
  properties: {
    sku: {
      tier: firewallSku
    }
    threatIntelMode: 'Alert'
    intrusionDetection: firewallSku == 'Premium' ? {
      mode: 'Alert'
    } : null
  }
}

// ============================================================================
// AZURE BASTION
// ============================================================================

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: bastionPublicIpName
  location: location
  tags: tags
  scope: rg
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2023-05-01' = {
  name: bastionName
  location: location
  tags: tags
  scope: rg
  sku: {
    name: bastionSku
  }
  properties: {
    scaleUnits: bastionScaleUnits
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
}

// ============================================================================
// DIAGNOSTIC SETTINGS
// ============================================================================

resource vnetDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${vnetName}'
  scope: vnet
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'VMProtectionAlerts'
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

resource firewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${firewallName}'
  scope: firewall
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
      }
      {
        category: 'AzureFirewallDnsProxy'
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
// OUTPUTS
// ============================================================================

output vnetId string = vnet.id
output vnetName string = vnet.name
output firewallId string = firewall.id
output firewallPrivateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output bastionId string = bastion.id
output gatewaySubnetId string = '${vnet.id}/subnets/GatewaySubnet'
output managementSubnetId string = '${vnet.id}/subnets/ManagementSubnet'
output resourceGroupName string = rg.name
