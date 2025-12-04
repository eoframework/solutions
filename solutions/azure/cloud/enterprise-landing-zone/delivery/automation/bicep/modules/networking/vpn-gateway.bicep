// ============================================================================
// VPN Gateway Module
// ============================================================================
// Description: Creates VPN Gateway for site-to-site and point-to-site
//              connectivity to on-premises and remote users
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

@description('Virtual network name')
param vnetName string

@description('Gateway subnet resource ID')
param gatewaySubnetId string

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var resourceGroupName = 'rg-${solutionPrefix}-networking-${environment}'
var vpnGatewayName = 'vpn-${solutionPrefix}-${environment}'
var vpnPublicIpName = 'pip-${vpnGatewayName}'

// ============================================================================
// VPN GATEWAY PUBLIC IP
// ============================================================================

resource vpnPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: vpnPublicIpName
  location: location
  tags: tags
  scope: resourceGroup(resourceGroupName)
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// ============================================================================
// VPN GATEWAY
// ============================================================================

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
  name: vpnGatewayName
  location: location
  tags: tags
  scope: resourceGroup(resourceGroupName)
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    sku: {
      name: 'VpnGw2AZ'
      tier: 'VpnGw2AZ'
    }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: vpnPublicIp.id
          }
        }
      }
    ]
    activeActive: false
    enableBgp: true
    bgpSettings: {
      asn: 65515
    }
  }
}

// ============================================================================
// DIAGNOSTIC SETTINGS
// ============================================================================

resource vpnDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${vpnGatewayName}'
  scope: vpnGateway
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'GatewayDiagnosticLog'
        enabled: true
      }
      {
        category: 'TunnelDiagnosticLog'
        enabled: true
      }
      {
        category: 'RouteDiagnosticLog'
        enabled: true
      }
      {
        category: 'IKEDiagnosticLog'
        enabled: true
      }
      {
        category: 'P2SDiagnosticLog'
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

output vpnGatewayId string = vpnGateway.id
output vpnGatewayName string = vpnGateway.name
output vpnPublicIp string = vpnPublicIp.properties.ipAddress
