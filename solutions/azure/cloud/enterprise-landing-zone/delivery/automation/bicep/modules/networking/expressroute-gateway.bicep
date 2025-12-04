// ============================================================================
// ExpressRoute Gateway Module
// ============================================================================
// Description: Creates ExpressRoute gateway for dedicated private connectivity
//              to on-premises datacenters and services
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

@description('ExpressRoute SKU')
@allowed(['Standard', 'Premium'])
param expressRouteSku string

@description('ExpressRoute bandwidth in Mbps')
param expressRouteBandwidth int

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var resourceGroupName = 'rg-${solutionPrefix}-networking-${environment}'
var erGatewayName = 'ergw-${solutionPrefix}-${environment}'
var erPublicIpName = 'pip-${erGatewayName}'
var erCircuitName = 'erc-${solutionPrefix}-${environment}'

// ============================================================================
// EXPRESSROUTE GATEWAY PUBLIC IP
// ============================================================================

resource erPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: erPublicIpName
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
// EXPRESSROUTE GATEWAY
// ============================================================================

resource erGateway 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
  name: erGatewayName
  location: location
  tags: tags
  scope: resourceGroup(resourceGroupName)
  properties: {
    gatewayType: 'ExpressRoute'
    sku: {
      name: expressRouteSku == 'Premium' ? 'ErGw3AZ' : 'ErGw1AZ'
      tier: expressRouteSku == 'Premium' ? 'ErGw3AZ' : 'ErGw1AZ'
    }
    ipConfigurations: [
      {
        name: 'gwipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: erPublicIp.id
          }
        }
      }
    ]
  }
}

// ============================================================================
// EXPRESSROUTE CIRCUIT
// ============================================================================

resource erCircuit 'Microsoft.Network/expressRouteCircuits@2023-05-01' = {
  name: erCircuitName
  location: location
  tags: tags
  scope: resourceGroup(resourceGroupName)
  sku: {
    name: '${expressRouteSku}_MeteredData'
    tier: expressRouteSku
    family: 'MeteredData'
  }
  properties: {
    serviceProviderProperties: {
      serviceProviderName: 'Equinix'
      peeringLocation: 'Silicon Valley'
      bandwidthInMbps: expressRouteBandwidth
    }
    allowClassicOperations: false
    gatewayManagerEtag: ''
    expressRoutePort: null
  }
}

resource erPeering 'Microsoft.Network/expressRouteCircuits/peerings@2023-05-01' = {
  parent: erCircuit
  name: 'AzurePrivatePeering'
  properties: {
    peeringType: 'AzurePrivatePeering'
    azureASN: 12076
    peerASN: 65001
    primaryPeerAddressPrefix: '192.168.1.0/30'
    secondaryPeerAddressPrefix: '192.168.1.4/30'
    vlanId: 100
  }
}

// ============================================================================
// DIAGNOSTIC SETTINGS
// ============================================================================

resource erGatewayDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${erGatewayName}'
  scope: erGateway
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
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource erCircuitDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${erCircuitName}'
  scope: erCircuit
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'PeeringRouteLog'
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

output erGatewayId string = erGateway.id
output erGatewayName string = erGateway.name
output erCircuitId string = erCircuit.id
output erCircuitServiceKey string = erCircuit.properties.serviceKey
