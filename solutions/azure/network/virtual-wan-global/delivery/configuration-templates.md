# Azure Virtual WAN Configuration Templates

## Overview

This document provides comprehensive configuration templates for deploying Azure Virtual WAN Global connectivity solutions. These templates follow Azure best practices and are designed for enterprise-scale deployments.

## Template Structure

### Core Templates

1. **Virtual WAN Foundation** - Base Virtual WAN resource
2. **Virtual Hub Deployment** - Regional hub configuration
3. **VPN Gateway Configuration** - Site-to-site connectivity
4. **ExpressRoute Gateway** - Private connectivity
5. **Azure Firewall Integration** - Security services
6. **Routing Configuration** - Traffic management

## 1. Virtual WAN Foundation Template

### ARM Template (vwan-foundation.json)

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualWanName": {
            "type": "string",
            "metadata": {
                "description": "Name of the Virtual WAN"
            }
        },
        "allowBranchToBranchTraffic": {
            "type": "bool",
            "defaultValue": true,
            "metadata": {
                "description": "Allow branch to branch traffic"
            }
        },
        "allowVnetToVnetTraffic": {
            "type": "bool",
            "defaultValue": true,
            "metadata": {
                "description": "Allow VNet to VNet traffic"
            }
        },
        "type": {
            "type": "string",
            "defaultValue": "Standard",
            "allowedValues": [
                "Basic",
                "Standard"
            ],
            "metadata": {
                "description": "The type of Virtual WAN"
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Network/virtualWans",
            "apiVersion": "2021-05-01",
            "name": "[parameters('virtualWanName')]",
            "location": "[resourceGroup().location]",
            "properties": {
                "allowBranchToBranchTraffic": "[parameters('allowBranchToBranchTraffic')]",
                "allowVnetToVnetTraffic": "[parameters('allowVnetToVnetTraffic')]",
                "type": "[parameters('type')]"
            }
        }
    ],
    "outputs": {
        "virtualWanId": {
            "type": "string",
            "value": "[resourceId('Microsoft.Network/virtualWans', parameters('virtualWanName'))]"
        }
    }
}
```

### Parameters File (vwan-foundation.parameters.json)

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualWanName": {
            "value": "corp-global-vwan"
        },
        "allowBranchToBranchTraffic": {
            "value": true
        },
        "allowVnetToVnetTraffic": {
            "value": true
        },
        "type": {
            "value": "Standard"
        }
    }
}
```

## 2. Virtual Hub Deployment Template

### ARM Template (virtual-hub.json)

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualWanId": {
            "type": "string",
            "metadata": {
                "description": "Resource ID of the Virtual WAN"
            }
        },
        "hubName": {
            "type": "string",
            "metadata": {
                "description": "Name of the Virtual Hub"
            }
        },
        "hubLocation": {
            "type": "string",
            "metadata": {
                "description": "Location of the Virtual Hub"
            }
        },
        "hubAddressPrefix": {
            "type": "string",
            "metadata": {
                "description": "Address prefix for the Virtual Hub (e.g., 10.0.0.0/24)"
            }
        },
        "enableVpnGateway": {
            "type": "bool",
            "defaultValue": true,
            "metadata": {
                "description": "Enable VPN Gateway in the hub"
            }
        },
        "enableExpressRouteGateway": {
            "type": "bool",
            "defaultValue": false,
            "metadata": {
                "description": "Enable ExpressRoute Gateway in the hub"
            }
        },
        "enableAzureFirewall": {
            "type": "bool",
            "defaultValue": true,
            "metadata": {
                "description": "Enable Azure Firewall in the hub"
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Network/virtualHubs",
            "apiVersion": "2021-05-01",
            "name": "[parameters('hubName')]",
            "location": "[parameters('hubLocation')]",
            "properties": {
                "virtualWan": {
                    "id": "[parameters('virtualWanId')]"
                },
                "addressPrefix": "[parameters('hubAddressPrefix')]"
            }
        },
        {
            "condition": "[parameters('enableVpnGateway')]",
            "type": "Microsoft.Network/vpnGateways",
            "apiVersion": "2021-05-01",
            "name": "[concat(parameters('hubName'), '-vpngw')]",
            "location": "[parameters('hubLocation')]",
            "dependsOn": [
                "[resourceId('Microsoft.Network/virtualHubs', parameters('hubName'))]"
            ],
            "properties": {
                "virtualHub": {
                    "id": "[resourceId('Microsoft.Network/virtualHubs', parameters('hubName'))]"
                },
                "bgpSettings": {
                    "asn": 65515
                },
                "vpnGatewayScaleUnit": 1
            }
        },
        {
            "condition": "[parameters('enableExpressRouteGateway')]",
            "type": "Microsoft.Network/expressRouteGateways",
            "apiVersion": "2021-05-01",
            "name": "[concat(parameters('hubName'), '-ergw')]",
            "location": "[parameters('hubLocation')]",
            "dependsOn": [
                "[resourceId('Microsoft.Network/virtualHubs', parameters('hubName'))]"
            ],
            "properties": {
                "virtualHub": {
                    "id": "[resourceId('Microsoft.Network/virtualHubs', parameters('hubName'))]"
                },
                "autoScaleConfiguration": {
                    "bounds": {
                        "min": 1,
                        "max": 10
                    }
                }
            }
        }
    ]
}
```

## 3. VPN Site Configuration Template

### ARM Template (vpn-site.json)

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualWanId": {
            "type": "string",
            "metadata": {
                "description": "Resource ID of the Virtual WAN"
            }
        },
        "siteName": {
            "type": "string",
            "metadata": {
                "description": "Name of the VPN site"
            }
        },
        "siteLocation": {
            "type": "string",
            "metadata": {
                "description": "Location of the VPN site"
            }
        },
        "deviceProperties": {
            "type": "object",
            "metadata": {
                "description": "Device properties for the VPN site"
            }
        },
        "addressSpace": {
            "type": "array",
            "metadata": {
                "description": "Address space for the VPN site"
            }
        },
        "ipAddress": {
            "type": "string",
            "metadata": {
                "description": "Public IP address of the VPN site"
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Network/vpnSites",
            "apiVersion": "2021-05-01",
            "name": "[parameters('siteName')]",
            "location": "[parameters('siteLocation')]",
            "properties": {
                "virtualWan": {
                    "id": "[parameters('virtualWanId')]"
                },
                "deviceProperties": "[parameters('deviceProperties')]",
                "addressSpace": {
                    "addressPrefixes": "[parameters('addressSpace')]"
                },
                "ipAddress": "[parameters('ipAddress')]"
            }
        }
    ]
}
```

## 4. Azure Firewall Integration Template

### ARM Template (firewall-integration.json)

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualHubId": {
            "type": "string",
            "metadata": {
                "description": "Resource ID of the Virtual Hub"
            }
        },
        "firewallName": {
            "type": "string",
            "metadata": {
                "description": "Name of the Azure Firewall"
            }
        },
        "firewallPolicyId": {
            "type": "string",
            "metadata": {
                "description": "Resource ID of the Firewall Policy"
            }
        },
        "hubLocation": {
            "type": "string",
            "metadata": {
                "description": "Location of the Virtual Hub"
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Network/azureFirewalls",
            "apiVersion": "2021-05-01",
            "name": "[parameters('firewallName')]",
            "location": "[parameters('hubLocation')]",
            "properties": {
                "sku": {
                    "name": "AZFW_Hub",
                    "tier": "Standard"
                },
                "hubIPAddresses": {
                    "publicIPs": {
                        "count": 1
                    }
                },
                "virtualHub": {
                    "id": "[parameters('virtualHubId')]"
                },
                "firewallPolicy": {
                    "id": "[parameters('firewallPolicyId')]"
                }
            }
        }
    ]
}
```

## 5. Routing Configuration Templates

### Custom Route Table Template

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualHubId": {
            "type": "string",
            "metadata": {
                "description": "Resource ID of the Virtual Hub"
            }
        },
        "routeTableName": {
            "type": "string",
            "metadata": {
                "description": "Name of the route table"
            }
        },
        "routes": {
            "type": "array",
            "metadata": {
                "description": "Routes to be added to the route table"
            }
        },
        "labels": {
            "type": "array",
            "defaultValue": [],
            "metadata": {
                "description": "Route table labels"
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Network/virtualHubs/hubRouteTables",
            "apiVersion": "2021-05-01",
            "name": "[concat(last(split(parameters('virtualHubId'), '/')), '/', parameters('routeTableName'))]",
            "properties": {
                "routes": "[parameters('routes')]",
                "labels": "[parameters('labels')]"
            }
        }
    ]
}
```

## 6. PowerShell Deployment Scripts

### Virtual WAN Deployment Script

```powershell
# Deploy-VirtualWAN.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$true)]
    [string]$VirtualWanName,
    
    [Parameter(Mandatory=$true)]
    [hashtable]$Hubs
)

# Connect to Azure
Connect-AzAccount
Select-AzSubscription -SubscriptionId $SubscriptionId

# Create Resource Group if it doesn't exist
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    Write-Output "Creating resource group: $ResourceGroupName"
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

# Deploy Virtual WAN
Write-Output "Deploying Virtual WAN: $VirtualWanName"
$vwanDeployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile ".\templates\vwan-foundation.json" `
    -TemplateParameterFile ".\templates\vwan-foundation.parameters.json" `
    -virtualWanName $VirtualWanName

$virtualWanId = $vwanDeployment.Outputs.virtualWanId.Value

# Deploy Virtual Hubs
foreach ($hubName in $Hubs.Keys) {
    $hubConfig = $Hubs[$hubName]
    
    Write-Output "Deploying Virtual Hub: $hubName"
    New-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile ".\templates\virtual-hub.json" `
        -virtualWanId $virtualWanId `
        -hubName $hubName `
        -hubLocation $hubConfig.Location `
        -hubAddressPrefix $hubConfig.AddressPrefix `
        -enableVpnGateway $hubConfig.EnableVpnGateway `
        -enableExpressRouteGateway $hubConfig.EnableExpressRouteGateway `
        -enableAzureFirewall $hubConfig.EnableAzureFirewall
}

Write-Output "Virtual WAN deployment completed successfully"
```

### Site Connection Script

```powershell
# Connect-VpnSites.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$VirtualWanName,
    
    [Parameter(Mandatory=$true)]
    [string]$HubName,
    
    [Parameter(Mandatory=$true)]
    [hashtable]$Sites
)

# Get Virtual WAN resource
$virtualWan = Get-AzVirtualWan -ResourceGroupName $ResourceGroupName -Name $VirtualWanName
$virtualHub = Get-AzVirtualHub -ResourceGroupName $ResourceGroupName -Name $HubName

# Create VPN sites and connections
foreach ($siteName in $Sites.Keys) {
    $siteConfig = $Sites[$siteName]
    
    Write-Output "Creating VPN Site: $siteName"
    
    # Create VPN Site
    $vpnSite = New-AzVpnSite `
        -ResourceGroupName $ResourceGroupName `
        -Name $siteName `
        -Location $siteConfig.Location `
        -VirtualWan $virtualWan `
        -IpAddress $siteConfig.PublicIpAddress `
        -AddressSpace $siteConfig.AddressSpace `
        -DeviceModel $siteConfig.DeviceModel `
        -DeviceVendor $siteConfig.DeviceVendor
    
    # Create VPN Connection
    Write-Output "Creating VPN Connection for site: $siteName"
    $vpnConnection = New-AzVpnConnection `
        -ResourceGroupName $ResourceGroupName `
        -ParentResourceName $HubName `
        -Name "$siteName-connection" `
        -VpnSite $vpnSite `
        -ConnectionBandwidth $siteConfig.Bandwidth
}

Write-Output "VPN site connections completed successfully"
```

## 7. Azure CLI Templates

### Hub Deployment Script

```bash
#!/bin/bash
# deploy-virtual-hub.sh

RESOURCE_GROUP="$1"
VWAN_NAME="$2"
HUB_NAME="$3"
HUB_LOCATION="$4"
HUB_ADDRESS_PREFIX="$5"

# Create virtual hub
echo "Creating virtual hub: $HUB_NAME"
az network vhub create \
    --resource-group $RESOURCE_GROUP \
    --name $HUB_NAME \
    --location $HUB_LOCATION \
    --address-prefix $HUB_ADDRESS_PREFIX \
    --vwan $VWAN_NAME

# Create VPN gateway
echo "Creating VPN gateway for hub: $HUB_NAME"
az network vpn-gateway create \
    --resource-group $RESOURCE_GROUP \
    --name "${HUB_NAME}-vpngw" \
    --location $HUB_LOCATION \
    --vhub $HUB_NAME \
    --scale-unit 1

echo "Virtual hub deployment completed"
```

## 8. Bicep Templates

### Main Virtual WAN Template

```bicep
// main-vwan.bicep

@description('The name of the Virtual WAN')
param virtualWanName string

@description('The location for the Virtual WAN')
param location string = resourceGroup().location

@description('Virtual hubs configuration')
param virtualHubs array

@description('VPN sites configuration')
param vpnSites array = []

resource virtualWan 'Microsoft.Network/virtualWans@2021-05-01' = {
  name: virtualWanName
  location: location
  properties: {
    type: 'Standard'
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
  }
}

resource virtualHub 'Microsoft.Network/virtualHubs@2021-05-01' = [for hub in virtualHubs: {
  name: hub.name
  location: hub.location
  properties: {
    virtualWan: {
      id: virtualWan.id
    }
    addressPrefix: hub.addressPrefix
  }
}]

resource vpnGateway 'Microsoft.Network/vpnGateways@2021-05-01' = [for (hub, i) in virtualHubs: if (hub.enableVpnGateway) {
  name: '${hub.name}-vpngw'
  location: hub.location
  properties: {
    virtualHub: {
      id: virtualHub[i].id
    }
    vpnGatewayScaleUnit: hub.vpnGatewayScaleUnit
    bgpSettings: {
      asn: 65515
    }
  }
}]

output virtualWanId string = virtualWan.id
output virtualHubIds array = [for i in range(0, length(virtualHubs)): virtualHub[i].id]
```

## Configuration Best Practices

### Naming Conventions

```yaml
# Naming convention examples
Virtual WAN: "{company}-{environment}-vwan"
Virtual Hub: "{company}-{region}-{environment}-hub"
VPN Gateway: "{hubname}-vpngw"
VPN Site: "{sitename}-{location}-site"
Connections: "{sitename}-connection"
```

### IP Address Planning

```yaml
# IP address allocation example
Virtual WAN Hub Addressing:
  - Hub 1 (East US): 10.0.0.0/24
  - Hub 2 (West US): 10.1.0.0/24
  - Hub 3 (Europe): 10.2.0.0/24

Branch Site Addressing:
  - Branch 1: 192.168.1.0/24
  - Branch 2: 192.168.2.0/24
  - Branch 3: 192.168.3.0/24
```

## Validation Scripts

### Connectivity Test Script

```powershell
# Test-VWanConnectivity.ps1

function Test-VWanConnectivity {
    param(
        [string]$ResourceGroupName,
        [string]$VirtualWanName
    )
    
    $vwan = Get-AzVirtualWan -ResourceGroupName $ResourceGroupName -Name $VirtualWanName
    $hubs = Get-AzVirtualHub -ResourceGroupName $ResourceGroupName
    
    foreach ($hub in $hubs) {
        Write-Output "Testing hub: $($hub.Name)"
        
        # Test VPN gateway status
        $vpnGw = Get-AzVpnGateway -ResourceGroupName $ResourceGroupName -Name "$($hub.Name)-vpngw"
        Write-Output "VPN Gateway Status: $($vpnGw.ProvisioningState)"
        
        # Test connections
        $connections = Get-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $hub.Name
        foreach ($conn in $connections) {
            Write-Output "Connection $($conn.Name) Status: $($conn.ConnectionStatus)"
        }
    }
}
```

---

**Template Version**: 1.0  
**Last Updated**: August 2024  
**Compatibility**: Azure Resource Manager API Version 2021-05-01 and later