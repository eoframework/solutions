# Azure Virtual WAN Global - Implementation Guide

## Overview

This comprehensive implementation guide provides step-by-step procedures for deploying Azure Virtual WAN Global connectivity solutions. The guide follows Microsoft best practices and enterprise deployment standards.

## Table of Contents

1. [Pre-Implementation Planning](#pre-implementation-planning)
2. [Environment Preparation](#environment-preparation)
3. [Core Infrastructure Deployment](#core-infrastructure-deployment)
4. [Connectivity Configuration](#connectivity-configuration)
5. [Security Implementation](#security-implementation)
6. [Monitoring and Operations Setup](#monitoring-and-operations-setup)
7. [Validation and Testing](#validation-and-testing)
8. [Go-Live Checklist](#go-live-checklist)

## Pre-Implementation Planning

### Architecture Review

Before beginning implementation, review and validate:

- **Network topology design**: Ensure hub placement optimizes latency and cost
- **IP address allocation**: Verify no conflicts with existing networks
- **Bandwidth requirements**: Calculate expected traffic volumes
- **Security requirements**: Define firewall and access control policies

### Prerequisites Checklist

**Azure Environment**
- [ ] Azure subscription with sufficient permissions
- [ ] Resource groups created with appropriate RBAC
- [ ] Azure AD integration configured
- [ ] Subscription quotas verified for Virtual WAN resources

**Network Requirements**
- [ ] Current network inventory documented
- [ ] IP addressing scheme finalized
- [ ] DNS configuration planned
- [ ] Firewall rules and security policies defined

**Team Readiness**
- [ ] Technical teams trained on Azure Virtual WAN
- [ ] Deployment roles and responsibilities assigned
- [ ] Change management process established
- [ ] Communication plan activated

## Environment Preparation

### Step 1: Azure Subscription Setup

```powershell
# Connect to Azure
Connect-AzAccount
Select-AzSubscription -SubscriptionId "your-subscription-id"

# Verify required resource providers
Register-AzResourceProvider -ProviderNamespace "Microsoft.Network"
Register-AzResourceProvider -ProviderNamespace "Microsoft.Security"

# Check resource provider status
Get-AzResourceProvider -ProviderNamespace "Microsoft.Network" | Select-Object RegistrationState
```

### Step 2: Resource Group Creation

```powershell
# Create resource groups for different components
$resourceGroups = @(
    @{Name="rg-vwan-core-prod"; Location="East US"},
    @{Name="rg-vwan-security-prod"; Location="East US"},
    @{Name="rg-vwan-monitoring-prod"; Location="East US"}
)

foreach ($rg in $resourceGroups) {
    New-AzResourceGroup -Name $rg.Name -Location $rg.Location
    Write-Output "Created resource group: $($rg.Name)"
}
```

### Step 3: Network Planning Validation

```bash
# Validate IP addressing using Azure CLI
az network vnet check-ip-address \
    --resource-group "rg-existing-networks" \
    --name "existing-vnet" \
    --ip-address "10.0.0.1"
```

## Core Infrastructure Deployment

### Phase 1: Virtual WAN Foundation

#### Step 1: Deploy Virtual WAN

```powershell
# Deploy Virtual WAN using ARM template
$deploymentParams = @{
    ResourceGroupName = "rg-vwan-core-prod"
    TemplateFile = ".\templates\vwan-foundation.json"
    TemplateParameterFile = ".\templates\vwan-foundation.parameters.json"
    virtualWanName = "corp-global-vwan"
}

$vwanDeployment = New-AzResourceGroupDeployment @deploymentParams
$virtualWanId = $vwanDeployment.Outputs.virtualWanId.Value

Write-Output "Virtual WAN deployed successfully: $virtualWanId"
```

#### Step 2: Verify Virtual WAN Deployment

```powershell
# Verify Virtual WAN resource
$virtualWan = Get-AzVirtualWan -ResourceGroupName "rg-vwan-core-prod" -Name "corp-global-vwan"
Write-Output "Virtual WAN Status: $($virtualWan.ProvisioningState)"
Write-Output "Virtual WAN Type: $($virtualWan.Type)"
Write-Output "Branch-to-Branch Traffic: $($virtualWan.AllowBranchToBranchTraffic)"
```

### Phase 2: Virtual Hub Deployment

#### Step 1: Deploy Primary Hub (East US)

```powershell
# Deploy primary virtual hub
$hubParams = @{
    ResourceGroupName = "rg-vwan-core-prod"
    TemplateFile = ".\templates\virtual-hub.json"
    virtualWanId = $virtualWanId
    hubName = "hub-eastus-prod"
    hubLocation = "East US"
    hubAddressPrefix = "10.0.0.0/24"
    enableVpnGateway = $true
    enableExpressRouteGateway = $false
    enableAzureFirewall = $true
}

$hubDeployment = New-AzResourceGroupDeployment @hubParams
Write-Output "Primary hub deployed successfully"
```

#### Step 2: Deploy Secondary Hub (West US)

```powershell
# Deploy secondary virtual hub
$hubParams.hubName = "hub-westus-prod"
$hubParams.hubLocation = "West US"
$hubParams.hubAddressPrefix = "10.1.0.0/24"

$hubDeployment = New-AzResourceGroupDeployment @hubParams
Write-Output "Secondary hub deployed successfully"
```

#### Step 3: Deploy International Hub (West Europe)

```powershell
# Deploy international virtual hub
$hubParams.hubName = "hub-westeurope-prod"
$hubParams.hubLocation = "West Europe"
$hubParams.hubAddressPrefix = "10.2.0.0/24"

$hubDeployment = New-AzResourceGroupDeployment @hubParams
Write-Output "International hub deployed successfully"
```

#### Step 4: Verify Hub Deployments

```powershell
# Verify all hubs
$hubs = Get-AzVirtualHub -ResourceGroupName "rg-vwan-core-prod"
foreach ($hub in $hubs) {
    Write-Output "Hub: $($hub.Name) - Status: $($hub.ProvisioningState)"
    Write-Output "  Address Prefix: $($hub.AddressPrefix)"
    Write-Output "  VPN Gateway: $(if ($hub.VpnGateway) {'Enabled'} else {'Disabled'})"
    Write-Output "  ExpressRoute Gateway: $(if ($hub.ExpressRouteGateway) {'Enabled'} else {'Disabled'})"
}
```

## Connectivity Configuration

### Phase 3: VPN Site Configuration

#### Step 1: Create VPN Sites

```powershell
# Define VPN sites configuration
$vpnSites = @(
    @{
        Name = "site-hq-newyork"
        Location = "East US"
        PublicIpAddress = "203.0.113.1"
        AddressSpace = @("192.168.1.0/24")
        DeviceVendor = "Cisco"
        DeviceModel = "ISR4321"
        LinkSpeedInMbps = 100
    },
    @{
        Name = "site-branch-chicago"
        Location = "Central US"
        PublicIpAddress = "203.0.113.2"
        AddressSpace = @("192.168.2.0/24")
        DeviceVendor = "Cisco"
        DeviceModel = "ISR4321"
        LinkSpeedInMbps = 50
    },
    @{
        Name = "site-branch-london"
        Location = "UK South"
        PublicIpAddress = "203.0.113.3"
        AddressSpace = @("192.168.3.0/24")
        DeviceVendor = "Fortinet"
        DeviceModel = "FortiGate-60F"
        LinkSpeedInMbps = 100
    }
)

# Deploy VPN sites
$virtualWan = Get-AzVirtualWan -ResourceGroupName "rg-vwan-core-prod" -Name "corp-global-vwan"

foreach ($site in $vpnSites) {
    $vpnSite = New-AzVpnSite `
        -ResourceGroupName "rg-vwan-core-prod" `
        -Name $site.Name `
        -Location $site.Location `
        -VirtualWan $virtualWan `
        -IpAddress $site.PublicIpAddress `
        -AddressSpace $site.AddressSpace `
        -DeviceVendor $site.DeviceVendor `
        -DeviceModel $site.DeviceModel `
        -LinkSpeedInMbps $site.LinkSpeedInMbps
    
    Write-Output "Created VPN site: $($site.Name)"
}
```

#### Step 2: Create VPN Connections

```powershell
# Create VPN connections for each site
$hubMappings = @{
    "site-hq-newyork" = "hub-eastus-prod"
    "site-branch-chicago" = "hub-eastus-prod"
    "site-branch-london" = "hub-westeurope-prod"
}

foreach ($siteName in $hubMappings.Keys) {
    $hubName = $hubMappings[$siteName]
    $vpnSite = Get-AzVpnSite -ResourceGroupName "rg-vwan-core-prod" -Name $siteName
    
    # Create VPN connection
    $vpnConnection = New-AzVpnConnection `
        -ResourceGroupName "rg-vwan-core-prod" `
        -ParentResourceName $hubName `
        -Name "$siteName-connection" `
        -VpnSite $vpnSite `
        -ConnectionBandwidth 100
    
    Write-Output "Created VPN connection: $siteName-connection"
}
```

### Phase 4: VNet Connections

#### Step 1: Connect Hub VNets

```powershell
# Connect existing VNets to Virtual WAN hubs
$vnetConnections = @(
    @{
        VNetName = "vnet-prod-eastus"
        VNetResourceGroup = "rg-networks-prod"
        HubName = "hub-eastus-prod"
    },
    @{
        VNetName = "vnet-prod-westus"
        VNetResourceGroup = "rg-networks-prod"
        HubName = "hub-westus-prod"
    }
)

foreach ($connection in $vnetConnections) {
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $connection.VNetResourceGroup -Name $connection.VNetName
    $hub = Get-AzVirtualHub -ResourceGroupName "rg-vwan-core-prod" -Name $connection.HubName
    
    New-AzVirtualHubVnetConnection `
        -ResourceGroupName "rg-vwan-core-prod" `
        -VirtualHubName $connection.HubName `
        -Name "$($connection.VNetName)-connection" `
        -RemoteVirtualNetwork $vnet
    
    Write-Output "Connected VNet: $($connection.VNetName) to Hub: $($connection.HubName)"
}
```

## Security Implementation

### Phase 5: Azure Firewall Deployment

#### Step 1: Create Firewall Policy

```powershell
# Create Azure Firewall Policy
$firewallPolicy = New-AzFirewallPolicy `
    -ResourceGroupName "rg-vwan-security-prod" `
    -Name "vwan-firewall-policy" `
    -Location "East US" `
    -ThreatIntelMode "Alert"

Write-Output "Firewall policy created: $($firewallPolicy.Name)"
```

#### Step 2: Configure Firewall Rules

```powershell
# Create network rule collection
$networkRule1 = New-AzFirewallPolicyNetworkRule `
    -Name "AllowHttpsOutbound" `
    -Protocol "TCP" `
    -SourceAddress "*" `
    -DestinationAddress "*" `
    -DestinationPort "443"

$networkRule2 = New-AzFirewallPolicyNetworkRule `
    -Name "AllowDnsOutbound" `
    -Protocol "UDP" `
    -SourceAddress "*" `
    -DestinationAddress "*" `
    -DestinationPort "53"

$networkRuleCollection = New-AzFirewallPolicyNetworkRuleCollection `
    -Name "NetworkRuleCollection" `
    -Priority 200 `
    -Rule $networkRule1, $networkRule2 `
    -ActionType "Allow"

# Create application rule collection
$appRule1 = New-AzFirewallPolicyApplicationRule `
    -Name "AllowMicrosoft" `
    -SourceAddress "*" `
    -Protocol "https:443" `
    -TargetFqdn "*.microsoft.com", "*.azure.com"

$appRuleCollection = New-AzFirewallPolicyApplicationRuleCollection `
    -Name "ApplicationRuleCollection" `
    -Priority 300 `
    -Rule $appRule1 `
    -ActionType "Allow"

# Update firewall policy with rules
$ruleCollectionGroup = New-AzFirewallPolicyRuleCollectionGroup `
    -Name "DefaultRuleCollectionGroup" `
    -Priority 200 `
    -FirewallPolicyObject $firewallPolicy `
    -NetworkRuleCollection $networkRuleCollection `
    -ApplicationRuleCollection $appRuleCollection

Write-Output "Firewall rules configured successfully"
```

#### Step 3: Deploy Firewall to Hubs

```powershell
# Deploy Azure Firewall to each hub
$hubs = @("hub-eastus-prod", "hub-westus-prod", "hub-westeurope-prod")

foreach ($hubName in $hubs) {
    $hub = Get-AzVirtualHub -ResourceGroupName "rg-vwan-core-prod" -Name $hubName
    $hubLocation = $hub.Location
    
    $firewall = New-AzFirewall `
        -Name "$hubName-firewall" `
        -ResourceGroupName "rg-vwan-security-prod" `
        -Location $hubLocation `
        -VirtualHub $hub `
        -FirewallPolicyId $firewallPolicy.Id `
        -SkuName "AZFW_Hub" `
        -SkuTier "Standard" `
        -HubIPAddress @{PublicIPCount = 1}
    
    Write-Output "Deployed firewall to hub: $hubName"
}
```

### Phase 6: Route Configuration

#### Step 1: Create Custom Route Tables

```powershell
# Create custom route table for secure internet access
$secureInternetRoute = New-AzVirtualHubRoute `
    -AddressPrefix @("0.0.0.0/0") `
    -NextHopType "ResourceId" `
    -NextHop "/subscriptions/{subscription-id}/resourceGroups/rg-vwan-security-prod/providers/Microsoft.Network/azureFirewalls/hub-eastus-prod-firewall"

$secureRouteTable = New-AzVirtualHubRouteTable `
    -ResourceGroupName "rg-vwan-core-prod" `
    -VirtualHubName "hub-eastus-prod" `
    -Name "SecureInternetRouteTable" `
    -Route @($secureInternetRoute) `
    -Label @("Secure")

Write-Output "Created secure internet route table"
```

## Monitoring and Operations Setup

### Phase 7: Monitoring Configuration

#### Step 1: Enable Network Watcher

```powershell
# Enable Network Watcher in all regions
$regions = @("East US", "West US", "West Europe")

foreach ($region in $regions) {
    $networkWatcher = Get-AzNetworkWatcher -Location $region -ErrorAction SilentlyContinue
    if (-not $networkWatcher) {
        New-AzNetworkWatcher -Name "NetworkWatcher_$($region.Replace(' ',''))" -ResourceGroupName "NetworkWatcherRG" -Location $region
        Write-Output "Enabled Network Watcher in $region"
    }
}
```

#### Step 2: Configure Log Analytics

```powershell
# Create Log Analytics workspace
$workspace = New-AzOperationalInsightsWorkspace `
    -ResourceGroupName "rg-vwan-monitoring-prod" `
    -Name "vwan-logs-workspace" `
    -Location "East US" `
    -Sku "PerGB2018"

Write-Output "Created Log Analytics workspace: $($workspace.Name)"

# Enable diagnostic logs for Virtual WAN
$virtualWan = Get-AzVirtualWan -ResourceGroupName "rg-vwan-core-prod" -Name "corp-global-vwan"

$diagnosticSetting = Set-AzDiagnosticSetting `
    -ResourceId $virtualWan.Id `
    -WorkspaceId $workspace.ResourceId `
    -Enabled $true `
    -Name "vwan-diagnostics"

Write-Output "Enabled diagnostic logging for Virtual WAN"
```

#### Step 3: Configure Alerts

```powershell
# Create action group for notifications
$actionGroup = New-AzActionGroup `
    -ResourceGroupName "rg-vwan-monitoring-prod" `
    -Name "VWanAlerts" `
    -ShortName "VWanAlerts" `
    -EmailReceiver @{
        Name = "NetworkTeam"
        EmailAddress = "network-team@company.com"
    }

# Create connectivity alert
$alertRule = New-AzMetricAlertRuleV2 `
    -Name "VPN-Connection-Down" `
    -ResourceGroupName "rg-vwan-monitoring-prod" `
    -WindowSize "00:05:00" `
    -Frequency "00:01:00" `
    -TargetResourceScope "/subscriptions/{subscription-id}/resourceGroups/rg-vwan-core-prod" `
    -TargetResourceType "Microsoft.Network/vpnGateways" `
    -TargetResourceRegion "East US" `
    -MetricName "TunnelBandwidth" `
    -TimeAggregation "Average" `
    -Operator "LessThan" `
    -Threshold 1 `
    -ActionGroupId $actionGroup.Id

Write-Output "Created VPN connectivity alert"
```

## Validation and Testing

### Phase 8: Connectivity Testing

#### Step 1: Test Hub-to-Hub Connectivity

```powershell
# Test connectivity between hubs
$testResults = @()

$hubs = Get-AzVirtualHub -ResourceGroupName "rg-vwan-core-prod"
foreach ($sourceHub in $hubs) {
    foreach ($targetHub in $hubs) {
        if ($sourceHub.Name -ne $targetHub.Name) {
            # Use Network Watcher to test connectivity
            $connectivityTest = Start-AzNetworkWatcherConnectivityCheck `
                -NetworkWatcherName "NetworkWatcher_EastUS" `
                -ResourceGroupName "NetworkWatcherRG" `
                -SourceResourceId $sourceHub.Id `
                -DestinationAddress $targetHub.AddressPrefix.Split('/')[0] `
                -DestinationPort 443
            
            $testResults += @{
                Source = $sourceHub.Name
                Target = $targetHub.Name
                Status = $connectivityTest.ConnectionStatus
                AverageLatency = $connectivityTest.AvgLatencyInMs
            }
        }
    }
}

# Display test results
$testResults | Format-Table -AutoSize
```

#### Step 2: Test Site-to-Site Connectivity

```bash
#!/bin/bash
# Test VPN site connectivity

declare -a sites=("site-hq-newyork" "site-branch-chicago" "site-branch-london")

for site in "${sites[@]}"; do
    echo "Testing connectivity for $site"
    
    # Check VPN connection status
    connection_status=$(az network vpn-connection show \
        --resource-group "rg-vwan-core-prod" \
        --name "${site}-connection" \
        --query "connectionStatus" \
        --output tsv)
    
    echo "$site connection status: $connection_status"
    
    # Test ping to hub gateway
    if [ "$connection_status" == "Connected" ]; then
        echo "✓ $site is connected"
    else
        echo "✗ $site connection failed"
    fi
done
```

### Phase 9: Performance Testing

#### Step 1: Bandwidth Testing

```powershell
# Test bandwidth between sites
function Test-VWanBandwidth {
    param(
        [string]$SourceSite,
        [string]$TargetSite,
        [int]$DurationSeconds = 60
    )
    
    Write-Output "Starting bandwidth test from $SourceSite to $TargetSite"
    
    # Use iPerf3 or similar tool to test bandwidth
    # This would typically be run from the actual site locations
    
    $testResult = @{
        Source = $SourceSite
        Target = $TargetSite
        Bandwidth = "95.2 Mbps"  # Example result
        Latency = "12.5 ms"      # Example result
        PacketLoss = "0.01%"     # Example result
    }
    
    return $testResult
}

# Run bandwidth tests
$bandwidthTests = @(
    Test-VWanBandwidth -SourceSite "site-hq-newyork" -TargetSite "site-branch-chicago"
    Test-VWanBandwidth -SourceSite "site-hq-newyork" -TargetSite "site-branch-london"
    Test-VWanBandwidth -SourceSite "site-branch-chicago" -TargetSite "site-branch-london"
)

$bandwidthTests | Format-Table -AutoSize
```

## Go-Live Checklist

### Pre-Go-Live Validation

- [ ] **Infrastructure Deployment**
  - [ ] Virtual WAN deployed successfully
  - [ ] All virtual hubs operational
  - [ ] VPN gateways configured and running
  - [ ] Azure Firewall deployed and configured

- [ ] **Connectivity Verification**
  - [ ] All VPN sites connected
  - [ ] Hub-to-hub connectivity tested
  - [ ] VNet connections established
  - [ ] Internet breakout functional

- [ ] **Security Validation**
  - [ ] Firewall rules tested and verified
  - [ ] Network security groups configured
  - [ ] Route tables properly configured
  - [ ] Security policies enforced

- [ ] **Monitoring and Alerting**
  - [ ] Log Analytics workspace configured
  - [ ] Diagnostic logging enabled
  - [ ] Performance monitoring active
  - [ ] Alert rules configured and tested

- [ ] **Documentation and Training**
  - [ ] Operations runbooks completed
  - [ ] Team training conducted
  - [ ] Escalation procedures documented
  - [ ] Contact information updated

### Go-Live Activities

1. **Cutover Planning**
   - Schedule maintenance windows
   - Prepare rollback procedures
   - Notify all stakeholders
   - Activate support teams

2. **Traffic Migration**
   - Gradual traffic migration per site
   - Monitor performance metrics
   - Validate connectivity after each site
   - Document any issues and resolutions

3. **Post-Go-Live Monitoring**
   - Monitor for 48 hours continuously
   - Review performance metrics
   - Address any performance issues
   - Update documentation based on lessons learned

### Success Criteria

- [ ] All branch offices connected with < 2% packet loss
- [ ] Internet breakout functional for all sites
- [ ] Hub-to-hub latency within SLA requirements
- [ ] Security policies enforced across all connections
- [ ] Monitoring and alerting functional
- [ ] No critical issues in first 24 hours

---

**Implementation Guide Version**: 1.0  
**Last Updated**: August 2024  
**Next Review Date**: November 2024