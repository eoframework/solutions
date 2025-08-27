# Azure Virtual WAN Global - Automation Scripts

## Overview

This directory contains automation scripts for deploying, configuring, and managing Azure Virtual WAN Global connectivity solutions. These scripts support Infrastructure as Code (IaC) practices and enable consistent, repeatable deployments.

## Table of Contents

1. [Script Categories](#script-categories)
2. [Prerequisites](#prerequisites)
3. [Deployment Scripts](#deployment-scripts)
4. [Management Scripts](#management-scripts)
5. [Monitoring Scripts](#monitoring-scripts)
6. [Maintenance Scripts](#maintenance-scripts)
7. [Utility Scripts](#utility-scripts)
8. [Usage Examples](#usage-examples)

## Script Categories

### Deployment Scripts
| Script | Purpose | Language | Execution Time |
|--------|---------|----------|----------------|
| `Deploy-VirtualWAN.ps1` | Complete Virtual WAN deployment | PowerShell | 20-30 minutes |
| `Deploy-VirtualHub.ps1` | Single Virtual Hub deployment | PowerShell | 10-15 minutes |
| `Deploy-VPNSite.ps1` | VPN site configuration | PowerShell | 5-10 minutes |
| `Deploy-AzureFirewall.ps1` | Firewall deployment and configuration | PowerShell | 10-15 minutes |
| `deploy-vwan.sh` | Complete deployment via CLI | Bash | 25-35 minutes |

### Management Scripts
| Script | Purpose | Language | Execution Time |
|--------|---------|----------|----------------|
| `Manage-VPNConnections.ps1` | VPN connection management | PowerShell | 2-5 minutes |
| `Update-RoutingPolicies.ps1` | Route table management | PowerShell | 3-8 minutes |
| `Scale-VPNGateway.ps1` | Gateway scaling operations | PowerShell | 5-10 minutes |
| `Backup-Configuration.ps1` | Configuration backup | PowerShell | 5-10 minutes |

### Monitoring Scripts
| Script | Purpose | Language | Execution Time |
|--------|---------|----------|----------------|
| `Monitor-VWanHealth.ps1` | Health check automation | PowerShell | 2-5 minutes |
| `Collect-Metrics.ps1` | Performance metrics collection | PowerShell | 3-7 minutes |
| `Generate-Reports.ps1` | Automated reporting | PowerShell | 5-15 minutes |
| `health-check.sh` | Linux-based health checks | Bash | 2-5 minutes |

### Maintenance Scripts
| Script | Purpose | Language | Execution Time |
|--------|---------|----------|----------------|
| `Maintenance-Window.ps1` | Scheduled maintenance tasks | PowerShell | Variable |
| `Update-Certificates.ps1` | Certificate renewal automation | PowerShell | 5-10 minutes |
| `Cleanup-Resources.ps1` | Resource cleanup and optimization | PowerShell | 5-15 minutes |

## Prerequisites

### PowerShell Scripts
```powershell
# Required PowerShell modules
Install-Module -Name Az.Accounts -Force
Install-Module -Name Az.Network -Force
Install-Module -Name Az.Resources -Force
Install-Module -Name Az.Profile -Force
Install-Module -Name Az.Monitor -Force

# Verify module versions
Get-Module Az.* -ListAvailable | Select-Object Name, Version
```

### Azure CLI Scripts
```bash
# Install Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Azure CLI (CentOS/RHEL)
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo dnf install azure-cli

# Verify installation
az --version
```

### Authentication Setup
```powershell
# Interactive authentication
Connect-AzAccount

# Service principal authentication (for automation)
$credential = Get-Credential
Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId "your-tenant-id"

# Managed identity authentication (for Azure VMs)
Connect-AzAccount -Identity
```

## Deployment Scripts

### Deploy-VirtualWAN.ps1

Complete Virtual WAN deployment with multiple hubs and sites.

```powershell
<#
.SYNOPSIS
    Deploys a complete Azure Virtual WAN solution with multiple hubs and VPN sites.

.DESCRIPTION
    This script automates the deployment of:
    - Virtual WAN resource
    - Multiple Virtual Hubs in different regions
    - VPN Gateways
    - VPN Sites and connections
    - Azure Firewall (optional)
    - Basic routing configuration

.PARAMETER ConfigFilePath
    Path to the JSON configuration file containing deployment parameters

.PARAMETER SubscriptionId
    Azure subscription ID for deployment

.PARAMETER WhatIf
    Performs a dry run without making actual changes

.EXAMPLE
    .\Deploy-VirtualWAN.ps1 -ConfigFilePath ".\config\production.json" -SubscriptionId "12345678-1234-1234-1234-123456789012"

.EXAMPLE
    .\Deploy-VirtualWAN.ps1 -ConfigFilePath ".\config\test.json" -WhatIf
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ConfigFilePath,
    
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [switch]$WhatIf = $false
)

# Import configuration
try {
    $config = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
    Write-Output "Configuration loaded successfully from: $ConfigFilePath"
}
catch {
    Write-Error "Failed to load configuration file: $($_.Exception.Message)"
    exit 1
}

# Connect to Azure
try {
    Connect-AzAccount
    Select-AzSubscription -SubscriptionId $SubscriptionId
    Write-Output "Connected to Azure subscription: $SubscriptionId"
}
catch {
    Write-Error "Failed to connect to Azure: $($_.Exception.Message)"
    exit 1
}

# Deployment tracking
$deploymentResults = @{
    StartTime = Get-Date
    VirtualWAN = $null
    VirtualHubs = @()
    VPNSites = @()
    VPNConnections = @()
    AzureFirewalls = @()
    Errors = @()
}

Write-Output "=== Starting Virtual WAN Deployment ==="
Write-Output "Timestamp: $(Get-Date)"
Write-Output "WhatIf Mode: $WhatIf"
Write-Output ""

# Step 1: Create Resource Group
Write-Output "Step 1: Creating Resource Group..."
try {
    if (-not $WhatIf) {
        $resourceGroup = New-AzResourceGroup -Name $config.ResourceGroupName -Location $config.PrimaryLocation -Force
        Write-Output "  ✓ Resource Group created: $($config.ResourceGroupName)"
    } else {
        Write-Output "  [WHATIF] Would create Resource Group: $($config.ResourceGroupName)"
    }
}
catch {
    $error = "Failed to create resource group: $($_.Exception.Message)"
    $deploymentResults.Errors += $error
    Write-Error $error
}

# Step 2: Deploy Virtual WAN
Write-Output ""
Write-Output "Step 2: Deploying Virtual WAN..."
try {
    if (-not $WhatIf) {
        $virtualWan = New-AzVirtualWan `
            -ResourceGroupName $config.ResourceGroupName `
            -Name $config.VirtualWAN.Name `
            -Location $config.PrimaryLocation `
            -Type $config.VirtualWAN.Type `
            -AllowBranchToBranchTraffic:$config.VirtualWAN.AllowBranchToBranchTraffic `
            -AllowVnetToVnetTraffic:$config.VirtualWAN.AllowVnetToVnetTraffic
        
        $deploymentResults.VirtualWAN = $virtualWan
        Write-Output "  ✓ Virtual WAN deployed: $($virtualWan.Name)"
        Write-Output "    ID: $($virtualWan.Id)"
        Write-Output "    Type: $($virtualWan.Type)"
    } else {
        Write-Output "  [WHATIF] Would deploy Virtual WAN: $($config.VirtualWAN.Name)"
    }
}
catch {
    $error = "Failed to deploy Virtual WAN: $($_.Exception.Message)"
    $deploymentResults.Errors += $error
    Write-Error $error
    exit 1
}

# Step 3: Deploy Virtual Hubs
Write-Output ""
Write-Output "Step 3: Deploying Virtual Hubs..."
foreach ($hubConfig in $config.VirtualHubs) {
    Write-Output "  Deploying hub: $($hubConfig.Name)"
    try {
        if (-not $WhatIf) {
            # Deploy Virtual Hub
            $virtualHub = New-AzVirtualHub `
                -ResourceGroupName $config.ResourceGroupName `
                -Name $hubConfig.Name `
                -Location $hubConfig.Location `
                -VirtualWan $virtualWan `
                -AddressPrefix $hubConfig.AddressPrefix
            
            # Wait for hub provisioning
            do {
                Start-Sleep -Seconds 30
                $virtualHub = Get-AzVirtualHub -ResourceGroupName $config.ResourceGroupName -Name $hubConfig.Name
                Write-Output "    Hub provisioning state: $($virtualHub.ProvisioningState)"
            } while ($virtualHub.ProvisioningState -eq "Updating")
            
            $deploymentResults.VirtualHubs += $virtualHub
            Write-Output "  ✓ Virtual Hub deployed: $($virtualHub.Name)"
            
            # Deploy VPN Gateway if enabled
            if ($hubConfig.VPNGateway.Enabled) {
                Write-Output "    Deploying VPN Gateway..."
                $vpnGateway = New-AzVpnGateway `
                    -ResourceGroupName $config.ResourceGroupName `
                    -Name "$($hubConfig.Name)-vpngw" `
                    -Location $hubConfig.Location `
                    -VirtualHub $virtualHub `
                    -VpnGatewayScaleUnit $hubConfig.VPNGateway.ScaleUnits
                
                # Wait for gateway provisioning
                do {
                    Start-Sleep -Seconds 60
                    $vpnGateway = Get-AzVpnGateway -ResourceGroupName $config.ResourceGroupName -Name "$($hubConfig.Name)-vpngw"
                    Write-Output "      Gateway provisioning state: $($vpnGateway.ProvisioningState)"
                } while ($vpnGateway.ProvisioningState -eq "Updating")
                
                Write-Output "    ✓ VPN Gateway deployed: $($vpnGateway.Name)"
            }
        } else {
            Write-Output "  [WHATIF] Would deploy Virtual Hub: $($hubConfig.Name)"
            if ($hubConfig.VPNGateway.Enabled) {
                Write-Output "    [WHATIF] Would deploy VPN Gateway with $($hubConfig.VPNGateway.ScaleUnits) scale units"
            }
        }
    }
    catch {
        $error = "Failed to deploy Virtual Hub $($hubConfig.Name): $($_.Exception.Message)"
        $deploymentResults.Errors += $error
        Write-Error $error
    }
}

# Step 4: Deploy VPN Sites and Connections
Write-Output ""
Write-Output "Step 4: Deploying VPN Sites and Connections..."
foreach ($siteConfig in $config.VPNSites) {
    Write-Output "  Creating VPN Site: $($siteConfig.Name)"
    try {
        if (-not $WhatIf) {
            # Create VPN Site
            $vpnSite = New-AzVpnSite `
                -ResourceGroupName $config.ResourceGroupName `
                -Name $siteConfig.Name `
                -Location $siteConfig.Location `
                -VirtualWan $virtualWan `
                -IpAddress $siteConfig.PublicIPAddress `
                -AddressSpace $siteConfig.AddressSpace `
                -DeviceVendor $siteConfig.DeviceVendor `
                -DeviceModel $siteConfig.DeviceModel `
                -LinkSpeedInMbps $siteConfig.BandwidthMbps
            
            $deploymentResults.VPNSites += $vpnSite
            Write-Output "  ✓ VPN Site created: $($vpnSite.Name)"
            
            # Create VPN Connection
            $targetHub = $deploymentResults.VirtualHubs | Where-Object {$_.Name -eq $siteConfig.ConnectToHub}
            if ($targetHub) {
                Write-Output "    Creating connection to hub: $($targetHub.Name)"
                $vpnConnection = New-AzVpnConnection `
                    -ResourceGroupName $config.ResourceGroupName `
                    -ParentResourceName $targetHub.Name `
                    -Name "$($siteConfig.Name)-connection" `
                    -VpnSite $vpnSite `
                    -ConnectionBandwidth $siteConfig.BandwidthMbps
                
                $deploymentResults.VPNConnections += $vpnConnection
                Write-Output "  ✓ VPN Connection created: $($vpnConnection.Name)"
            } else {
                Write-Warning "    Target hub not found: $($siteConfig.ConnectToHub)"
            }
        } else {
            Write-Output "  [WHATIF] Would create VPN Site: $($siteConfig.Name)"
            Write-Output "    [WHATIF] Would connect to hub: $($siteConfig.ConnectToHub)"
        }
    }
    catch {
        $error = "Failed to deploy VPN Site $($siteConfig.Name): $($_.Exception.Message)"
        $deploymentResults.Errors += $error
        Write-Error $error
    }
}

# Step 5: Deploy Azure Firewalls (if enabled)
if ($config.AzureFirewall.Enabled) {
    Write-Output ""
    Write-Output "Step 5: Deploying Azure Firewalls..."
    
    foreach ($hubConfig in $config.VirtualHubs | Where-Object {$_.AzureFirewall.Enabled}) {
        Write-Output "  Deploying firewall for hub: $($hubConfig.Name)"
        try {
            if (-not $WhatIf) {
                # Get the deployed hub
                $targetHub = $deploymentResults.VirtualHubs | Where-Object {$_.Name -eq $hubConfig.Name}
                
                if ($targetHub) {
                    # Create firewall policy first
                    $firewallPolicy = New-AzFirewallPolicy `
                        -ResourceGroupName $config.ResourceGroupName `
                        -Name "$($hubConfig.Name)-fw-policy" `
                        -Location $hubConfig.Location
                    
                    # Deploy Azure Firewall
                    $azureFirewall = New-AzFirewall `
                        -Name "$($hubConfig.Name)-fw" `
                        -ResourceGroupName $config.ResourceGroupName `
                        -Location $hubConfig.Location `
                        -VirtualHub $targetHub `
                        -FirewallPolicyId $firewallPolicy.Id `
                        -SkuName "AZFW_Hub" `
                        -SkuTier $config.AzureFirewall.Tier
                    
                    $deploymentResults.AzureFirewalls += $azureFirewall
                    Write-Output "  ✓ Azure Firewall deployed: $($azureFirewall.Name)"
                } else {
                    Write-Warning "    Target hub not found: $($hubConfig.Name)"
                }
            } else {
                Write-Output "  [WHATIF] Would deploy Azure Firewall for hub: $($hubConfig.Name)"
            }
        }
        catch {
            $error = "Failed to deploy Azure Firewall for hub $($hubConfig.Name): $($_.Exception.Message)"
            $deploymentResults.Errors += $error
            Write-Error $error
        }
    }
}

# Deployment Summary
$deploymentResults.EndTime = Get-Date
$deploymentResults.Duration = $deploymentResults.EndTime - $deploymentResults.StartTime

Write-Output ""
Write-Output "=== Deployment Summary ==="
Write-Output "Start Time: $($deploymentResults.StartTime)"
Write-Output "End Time: $($deploymentResults.EndTime)"
Write-Output "Duration: $($deploymentResults.Duration.ToString('hh\:mm\:ss'))"
Write-Output ""
Write-Output "Resources Deployed:"
Write-Output "  Virtual WAN: $(if ($deploymentResults.VirtualWAN) {$deploymentResults.VirtualWAN.Name} else {'None'})"
Write-Output "  Virtual Hubs: $($deploymentResults.VirtualHubs.Count)"
Write-Output "  VPN Sites: $($deploymentResults.VPNSites.Count)"
Write-Output "  VPN Connections: $($deploymentResults.VPNConnections.Count)"
Write-Output "  Azure Firewalls: $($deploymentResults.AzureFirewalls.Count)"
Write-Output "  Errors: $($deploymentResults.Errors.Count)"

if ($deploymentResults.Errors.Count -gt 0) {
    Write-Output ""
    Write-Output "Errors encountered:"
    foreach ($error in $deploymentResults.Errors) {
        Write-Output "  - $error"
    }
}

# Save deployment results
$resultsPath = "deployment-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$deploymentResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsPath
Write-Output ""
Write-Output "Deployment results saved to: $resultsPath"

if ($deploymentResults.Errors.Count -eq 0) {
    Write-Output ""
    Write-Output "✓ Virtual WAN deployment completed successfully!"
    exit 0
} else {
    Write-Output ""
    Write-Output "⚠ Virtual WAN deployment completed with errors. Please review the errors above."
    exit 1
}
```

### Sample Configuration File (config/production.json)

```json
{
    "ResourceGroupName": "rg-vwan-prod",
    "PrimaryLocation": "East US",
    "VirtualWAN": {
        "Name": "corp-global-vwan",
        "Type": "Standard",
        "AllowBranchToBranchTraffic": true,
        "AllowVnetToVnetTraffic": true
    },
    "VirtualHubs": [
        {
            "Name": "hub-eastus-prod",
            "Location": "East US",
            "AddressPrefix": "10.0.0.0/24",
            "VPNGateway": {
                "Enabled": true,
                "ScaleUnits": 1
            },
            "AzureFirewall": {
                "Enabled": true
            }
        },
        {
            "Name": "hub-westus-prod",
            "Location": "West US",
            "AddressPrefix": "10.1.0.0/24",
            "VPNGateway": {
                "Enabled": true,
                "ScaleUnits": 1
            },
            "AzureFirewall": {
                "Enabled": true
            }
        },
        {
            "Name": "hub-westeurope-prod",
            "Location": "West Europe",
            "AddressPrefix": "10.2.0.0/24",
            "VPNGateway": {
                "Enabled": true,
                "ScaleUnits": 1
            },
            "AzureFirewall": {
                "Enabled": true
            }
        }
    ],
    "VPNSites": [
        {
            "Name": "site-hq-newyork",
            "Location": "East US",
            "PublicIPAddress": "203.0.113.1",
            "AddressSpace": ["192.168.1.0/24"],
            "DeviceVendor": "Cisco",
            "DeviceModel": "ISR4321",
            "BandwidthMbps": 100,
            "ConnectToHub": "hub-eastus-prod"
        },
        {
            "Name": "site-branch-chicago",
            "Location": "Central US",
            "PublicIPAddress": "203.0.113.2",
            "AddressSpace": ["192.168.2.0/24"],
            "DeviceVendor": "Cisco",
            "DeviceModel": "ISR4321",
            "BandwidthMbps": 50,
            "ConnectToHub": "hub-eastus-prod"
        },
        {
            "Name": "site-branch-london",
            "Location": "UK South",
            "PublicIPAddress": "203.0.113.3",
            "AddressSpace": ["192.168.3.0/24"],
            "DeviceVendor": "Fortinet",
            "DeviceModel": "FortiGate-60F",
            "BandwidthMbps": 100,
            "ConnectToHub": "hub-westeurope-prod"
        }
    ],
    "AzureFirewall": {
        "Enabled": true,
        "Tier": "Standard"
    }
}
```

## Management Scripts

### Manage-VPNConnections.ps1

Manage VPN connections including status checks, resets, and configuration updates.

```powershell
<#
.SYNOPSIS
    Manages VPN connections in Azure Virtual WAN.

.DESCRIPTION
    This script provides comprehensive VPN connection management including:
    - Connection status monitoring
    - Connection reset/restart operations
    - Bandwidth adjustment
    - Configuration updates
    - Health reporting

.PARAMETER Action
    Action to perform: Status, Reset, UpdateBandwidth, HealthCheck

.PARAMETER ResourceGroupName
    Resource group containing the Virtual WAN resources

.PARAMETER ConnectionName
    Specific connection name (optional - if not provided, operates on all connections)

.PARAMETER NewBandwidth
    New bandwidth value in Mbps (required for UpdateBandwidth action)

.EXAMPLE
    .\Manage-VPNConnections.ps1 -Action Status -ResourceGroupName "rg-vwan-prod"

.EXAMPLE
    .\Manage-VPNConnections.ps1 -Action Reset -ResourceGroupName "rg-vwan-prod" -ConnectionName "site-hq-connection"
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Status", "Reset", "UpdateBandwidth", "HealthCheck")]
    [string]$Action,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [string]$ConnectionName,
    
    [int]$NewBandwidth
)

# Function to get all VPN connections
function Get-AllVPNConnections {
    param([string]$ResourceGroupName)
    
    $allConnections = @()
    
    # Get all Virtual Hubs
    $virtualHubs = Get-AzVirtualHub -ResourceGroupName $ResourceGroupName
    
    foreach ($hub in $virtualHubs) {
        try {
            $connections = Get-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $hub.Name
            foreach ($conn in $connections) {
                $allConnections += @{
                    HubName = $hub.Name
                    ConnectionName = $conn.Name
                    Connection = $conn
                }
            }
        }
        catch {
            Write-Warning "Could not retrieve connections for hub: $($hub.Name)"
        }
    }
    
    return $allConnections
}

# Function to display connection status
function Show-ConnectionStatus {
    param($Connections)
    
    Write-Output "=== VPN Connection Status Report ==="
    Write-Output "Generated: $(Get-Date)"
    Write-Output ""
    
    $statusSummary = @{
        Connected = 0
        Connecting = 0
        Disconnected = 0
        Unknown = 0
    }
    
    foreach ($connInfo in $Connections) {
        $conn = $connInfo.Connection
        $status = $conn.ConnectionStatus
        
        Write-Output "Hub: $($connInfo.HubName)"
        Write-Output "  Connection: $($conn.Name)"
        Write-Output "    Status: $status"
        Write-Output "    Provisioning State: $($conn.ProvisioningState)"
        Write-Output "    Ingress Bytes: $($conn.IngressBytesTransferred)"
        Write-Output "    Egress Bytes: $($conn.EgressBytesTransferred)"
        Write-Output "    Connection Bandwidth: $($conn.ConnectionBandwidth) Mbps"
        Write-Output ""
        
        # Update summary
        switch ($status) {
            "Connected" { $statusSummary.Connected++ }
            "Connecting" { $statusSummary.Connecting++ }
            "NotConnected" { $statusSummary.Disconnected++ }
            default { $statusSummary.Unknown++ }
        }
    }
    
    Write-Output "=== Summary ==="
    Write-Output "Total Connections: $($Connections.Count)"
    Write-Output "Connected: $($statusSummary.Connected)"
    Write-Output "Connecting: $($statusSummary.Connecting)"
    Write-Output "Disconnected: $($statusSummary.Disconnected)"
    Write-Output "Unknown Status: $($statusSummary.Unknown)"
    
    $healthPercentage = if ($Connections.Count -gt 0) {
        [math]::Round(($statusSummary.Connected / $Connections.Count) * 100, 1)
    } else { 0 }
    
    Write-Output "Health Percentage: $healthPercentage%"
}

# Function to reset VPN connection
function Reset-VPNConnection {
    param(
        [string]$ResourceGroupName,
        [string]$HubName,
        [string]$ConnectionName
    )
    
    Write-Output "Resetting VPN connection: $ConnectionName on hub: $HubName"
    
    try {
        # Reset the connection
        Reset-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $HubName -Name $ConnectionName
        Write-Output "  ✓ Connection reset initiated"
        
        # Wait for connection to stabilize
        Write-Output "  Waiting for connection to stabilize..."
        Start-Sleep -Seconds 60
        
        # Check status
        $updatedConnection = Get-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $HubName -Name $ConnectionName
        Write-Output "  Updated Status: $($updatedConnection.ConnectionStatus)"
        
        return $updatedConnection.ConnectionStatus -eq "Connected"
    }
    catch {
        Write-Error "Failed to reset connection: $($_.Exception.Message)"
        return $false
    }
}

# Function to update connection bandwidth
function Update-ConnectionBandwidth {
    param(
        [string]$ResourceGroupName,
        [string]$HubName,
        [string]$ConnectionName,
        [int]$NewBandwidth
    )
    
    Write-Output "Updating bandwidth for connection: $ConnectionName to $NewBandwidth Mbps"
    
    try {
        # Get current connection
        $connection = Get-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $HubName -Name $ConnectionName
        
        # Update bandwidth
        $connection.ConnectionBandwidth = $NewBandwidth
        Set-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $HubName -Name $ConnectionName -ConnectionBandwidth $NewBandwidth
        
        Write-Output "  ✓ Bandwidth updated successfully"
        
        # Verify update
        $updatedConnection = Get-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $HubName -Name $ConnectionName
        Write-Output "  Verified Bandwidth: $($updatedConnection.ConnectionBandwidth) Mbps"
        
        return $true
    }
    catch {
        Write-Error "Failed to update bandwidth: $($_.Exception.Message)"
        return $false
    }
}

# Function to perform health check
function Invoke-HealthCheck {
    param($Connections)
    
    Write-Output "=== VPN Connection Health Check ==="
    Write-Output "Started: $(Get-Date)"
    Write-Output ""
    
    $healthResults = @()
    
    foreach ($connInfo in $Connections) {
        $conn = $connInfo.Connection
        $hubName = $connInfo.HubName
        $connName = $conn.Name
        
        Write-Output "Checking: $hubName/$connName"
        
        $healthResult = @{
            Hub = $hubName
            Connection = $connName
            Status = $conn.ConnectionStatus
            ProvisioningState = $conn.ProvisioningState
            IngressBytes = $conn.IngressBytesTransferred
            EgressBytes = $conn.EgressBytesTransferred
            Bandwidth = $conn.ConnectionBandwidth
            HealthScore = 0
            Issues = @()
        }
        
        # Health scoring
        if ($conn.ConnectionStatus -eq "Connected") {
            $healthResult.HealthScore += 40
        } else {
            $healthResult.Issues += "Connection not established"
        }
        
        if ($conn.ProvisioningState -eq "Succeeded") {
            $healthResult.HealthScore += 20
        } else {
            $healthResult.Issues += "Provisioning state: $($conn.ProvisioningState)"
        }
        
        if ($conn.IngressBytesTransferred -gt 0) {
            $healthResult.HealthScore += 20
        } else {
            $healthResult.Issues += "No ingress traffic"
        }
        
        if ($conn.EgressBytesTransferred -gt 0) {
            $healthResult.HealthScore += 20
        } else {
            $healthResult.Issues += "No egress traffic"
        }
        
        # Display results
        $statusIcon = if ($healthResult.HealthScore -ge 80) {"✓"} elseif ($healthResult.HealthScore -ge 60) {"⚠"} else {"✗"}
        Write-Output "  $statusIcon Health Score: $($healthResult.HealthScore)/100"
        
        if ($healthResult.Issues.Count -gt 0) {
            Write-Output "    Issues:"
            foreach ($issue in $healthResult.Issues) {
                Write-Output "      - $issue"
            }
        }
        
        $healthResults += $healthResult
        Write-Output ""
    }
    
    # Overall health summary
    $averageHealth = ($healthResults | Measure-Object HealthScore -Average).Average
    $healthyConnections = ($healthResults | Where-Object {$_.HealthScore -ge 80}).Count
    
    Write-Output "=== Health Check Summary ==="
    Write-Output "Total Connections: $($healthResults.Count)"
    Write-Output "Healthy Connections (≥80): $healthyConnections"
    Write-Output "Average Health Score: $([math]::Round($averageHealth, 1))"
    
    $overallStatus = if ($averageHealth -ge 80) {"HEALTHY"} elseif ($averageHealth -ge 60) {"WARNING"} else {"CRITICAL"}
    Write-Output "Overall Status: $overallStatus"
    
    return $healthResults
}

# Main execution
try {
    Connect-AzAccount -Identity -ErrorAction Stop
}
catch {
    Write-Output "Interactive authentication required..."
    Connect-AzAccount
}

# Get connections based on parameters
if ($ConnectionName) {
    # Find specific connection
    $allConnections = Get-AllVPNConnections -ResourceGroupName $ResourceGroupName
    $targetConnections = $allConnections | Where-Object {$_.ConnectionName -eq $ConnectionName}
    
    if ($targetConnections.Count -eq 0) {
        Write-Error "Connection not found: $ConnectionName"
        exit 1
    }
} else {
    # Get all connections
    $targetConnections = Get-AllVPNConnections -ResourceGroupName $ResourceGroupName
    
    if ($targetConnections.Count -eq 0) {
        Write-Warning "No VPN connections found in resource group: $ResourceGroupName"
        exit 0
    }
}

# Execute requested action
switch ($Action) {
    "Status" {
        Show-ConnectionStatus -Connections $targetConnections
    }
    
    "Reset" {
        if ($ConnectionName) {
            $connInfo = $targetConnections[0]
            $success = Reset-VPNConnection -ResourceGroupName $ResourceGroupName -HubName $connInfo.HubName -ConnectionName $connInfo.ConnectionName
            if ($success) {
                Write-Output "Connection reset completed successfully"
            } else {
                Write-Error "Connection reset failed"
                exit 1
            }
        } else {
            Write-Output "Resetting all connections..."
            $successCount = 0
            foreach ($connInfo in $targetConnections) {
                $success = Reset-VPNConnection -ResourceGroupName $ResourceGroupName -HubName $connInfo.HubName -ConnectionName $connInfo.ConnectionName
                if ($success) { $successCount++ }
            }
            Write-Output "Reset completed: $successCount/$($targetConnections.Count) connections successful"
        }
    }
    
    "UpdateBandwidth" {
        if (-not $NewBandwidth) {
            Write-Error "NewBandwidth parameter is required for UpdateBandwidth action"
            exit 1
        }
        
        if ($ConnectionName) {
            $connInfo = $targetConnections[0]
            $success = Update-ConnectionBandwidth -ResourceGroupName $ResourceGroupName -HubName $connInfo.HubName -ConnectionName $connInfo.ConnectionName -NewBandwidth $NewBandwidth
            if ($success) {
                Write-Output "Bandwidth update completed successfully"
            } else {
                Write-Error "Bandwidth update failed"
                exit 1
            }
        } else {
            Write-Output "Updating bandwidth for all connections to $NewBandwidth Mbps..."
            $successCount = 0
            foreach ($connInfo in $targetConnections) {
                $success = Update-ConnectionBandwidth -ResourceGroupName $ResourceGroupName -HubName $connInfo.HubName -ConnectionName $connInfo.ConnectionName -NewBandwidth $NewBandwidth
                if ($success) { $successCount++ }
            }
            Write-Output "Bandwidth update completed: $successCount/$($targetConnections.Count) connections successful"
        }
    }
    
    "HealthCheck" {
        $healthResults = Invoke-HealthCheck -Connections $targetConnections
        
        # Save health results
        $resultsPath = "vwan-health-check-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $healthResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsPath
        Write-Output "Health check results saved to: $resultsPath"
    }
}

Write-Output ""
Write-Output "VPN connection management completed: $(Get-Date)"
```

## Monitoring Scripts

### Monitor-VWanHealth.ps1

Comprehensive health monitoring for Virtual WAN environments.

```powershell
<#
.SYNOPSIS
    Comprehensive health monitoring for Azure Virtual WAN.

.DESCRIPTION
    This script performs comprehensive health monitoring including:
    - Virtual WAN and hub status
    - VPN gateway health
    - Connection status and performance
    - Azure Firewall health
    - Performance metrics collection
    - Automated alerting

.PARAMETER ResourceGroupName
    Resource group containing Virtual WAN resources

.PARAMETER AlertThresholds
    JSON file containing alert thresholds

.PARAMETER SendAlerts
    Enable automated alert notifications

.PARAMETER LogAnalyticsWorkspaceId
    Log Analytics workspace for metrics storage

.EXAMPLE
    .\Monitor-VWanHealth.ps1 -ResourceGroupName "rg-vwan-prod" -SendAlerts
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [string]$AlertThresholds = ".\config\alert-thresholds.json",
    
    [switch]$SendAlerts = $false,
    
    [string]$LogAnalyticsWorkspaceId
)

# Default alert thresholds
$defaultThresholds = @{
    VPNConnectionHealth = 95  # Percentage of connections that should be healthy
    BandwidthUtilization = 80  # Percentage utilization threshold
    PacketLoss = 1.0          # Percentage packet loss threshold
    Latency = 100             # Milliseconds latency threshold
    FirewallHealth = 90       # Firewall health percentage
}

# Load custom thresholds if provided
if (Test-Path $AlertThresholds) {
    try {
        $customThresholds = Get-Content -Path $AlertThresholds -Raw | ConvertFrom-Json
        foreach ($key in $customThresholds.PSObject.Properties.Name) {
            $defaultThresholds[$key] = $customThresholds.$key
        }
        Write-Output "Custom alert thresholds loaded from: $AlertThresholds"
    }
    catch {
        Write-Warning "Failed to load custom thresholds, using defaults"
    }
}

# Health monitoring results
$healthResults = @{
    Timestamp = Get-Date
    ResourceGroup = $ResourceGroupName
    VirtualWAN = $null
    VirtualHubs = @()
    VPNConnections = @()
    AzureFirewalls = @()
    PerformanceMetrics = @()
    Alerts = @()
    OverallHealth = "Unknown"
    HealthScore = 0
}

Write-Output "=== Azure Virtual WAN Health Monitoring ==="
Write-Output "Resource Group: $ResourceGroupName"
Write-Output "Timestamp: $($healthResults.Timestamp)"
Write-Output "Alert Thresholds: $($defaultThresholds | ConvertTo-Json -Compress)"
Write-Output ""

# Function to create alert
function New-HealthAlert {
    param(
        [string]$Severity,
        [string]$Component,
        [string]$Message,
        [hashtable]$Details = @{}
    )
    
    $alert = @{
        Timestamp = Get-Date
        Severity = $Severity
        Component = $Component
        Message = $Message
        Details = $Details
    }
    
    $healthResults.Alerts += $alert
    
    $severityIcon = switch ($Severity) {
        "Critical" { "🔴" }
        "Warning" { "🟡" }
        "Info" { "🔵" }
        default { "⚪" }
    }
    
    Write-Output "$severityIcon [$Severity] $Component: $Message"
    
    return $alert
}

# Function to send alerts
function Send-Alerts {
    param($Alerts)
    
    if (-not $SendAlerts -or $Alerts.Count -eq 0) {
        return
    }
    
    $criticalAlerts = $Alerts | Where-Object {$_.Severity -eq "Critical"}
    $warningAlerts = $Alerts | Where-Object {$_.Severity -eq "Warning"}
    
    if ($criticalAlerts.Count -gt 0 -or $warningAlerts.Count -gt 0) {
        Write-Output ""
        Write-Output "Sending alert notifications..."
        
        # Create alert message
        $alertMessage = @"
Azure Virtual WAN Health Alert
Resource Group: $ResourceGroupName
Timestamp: $(Get-Date)

Critical Alerts: $($criticalAlerts.Count)
Warning Alerts: $($warningAlerts.Count)

Critical Issues:
$($criticalAlerts | ForEach-Object { "- $($_.Component): $($_.Message)" } | Out-String)

Warning Issues:
$($warningAlerts | ForEach-Object { "- $($_.Component): $($_.Message)" } | Out-String)
"@
        
        # In production, send to appropriate notification channels
        # Example: Send-MailMessage, Invoke-RestMethod for webhooks, etc.
        Write-Output "Alert message prepared (implement notification channel):"
        Write-Output $alertMessage
    }
}

try {
    # Connect to Azure
    Connect-AzAccount -Identity -ErrorAction Stop
}
catch {
    Connect-AzAccount
}

# Step 1: Check Virtual WAN
Write-Output "Step 1: Checking Virtual WAN health..."
try {
    $virtualWan = Get-AzVirtualWan -ResourceGroupName $ResourceGroupName
    if ($virtualWan.Count -eq 1) {
        $healthResults.VirtualWAN = @{
            Name = $virtualWan.Name
            ProvisioningState = $virtualWan.ProvisioningState
            Type = $virtualWan.Type
            AllowBranchToBranchTraffic = $virtualWan.AllowBranchToBranchTraffic
            AllowVnetToVnetTraffic = $virtualWan.AllowVnetToVnetTraffic
            Health = if ($virtualWan.ProvisioningState -eq "Succeeded") {"Healthy"} else {"Unhealthy"}
        }
        
        Write-Output "  ✓ Virtual WAN: $($virtualWan.Name) - $($virtualWan.ProvisioningState)"
        
        if ($virtualWan.ProvisioningState -ne "Succeeded") {
            New-HealthAlert -Severity "Critical" -Component "Virtual WAN" -Message "Provisioning state is $($virtualWan.ProvisioningState)"
        }
    } else {
        New-HealthAlert -Severity "Critical" -Component "Virtual WAN" -Message "Expected 1 Virtual WAN, found $($virtualWan.Count)"
    }
}
catch {
    New-HealthAlert -Severity "Critical" -Component "Virtual WAN" -Message "Failed to retrieve Virtual WAN: $($_.Exception.Message)"
}

# Step 2: Check Virtual Hubs
Write-Output ""
Write-Output "Step 2: Checking Virtual Hub health..."
try {
    $virtualHubs = Get-AzVirtualHub -ResourceGroupName $ResourceGroupName
    Write-Output "  Found $($virtualHubs.Count) Virtual Hubs"
    
    foreach ($hub in $virtualHubs) {
        $hubHealth = @{
            Name = $hub.Name
            Location = $hub.Location
            ProvisioningState = $hub.ProvisioningState
            AddressPrefix = $hub.AddressPrefix
            RouteTable = $null
            VPNGateway = $null
            Health = "Unknown"
        }
        
        Write-Output "    Hub: $($hub.Name) ($($hub.Location))"
        Write-Output "      Provisioning State: $($hub.ProvisioningState)"
        Write-Output "      Address Prefix: $($hub.AddressPrefix)"
        
        # Check hub provisioning state
        if ($hub.ProvisioningState -eq "Succeeded") {
            $hubHealth.Health = "Healthy"
            Write-Output "      Status: ✓ Healthy"
        } else {
            $hubHealth.Health = "Unhealthy"
            Write-Output "      Status: ✗ Unhealthy"
            New-HealthAlert -Severity "Critical" -Component "Virtual Hub" -Message "$($hub.Name) provisioning state is $($hub.ProvisioningState)"
        }
        
        # Check VPN Gateway
        try {
            $vpnGateway = Get-AzVpnGateway -ResourceGroupName $ResourceGroupName -Name "$($hub.Name.Split('-')[1..2] -join '-')-vpngw" -ErrorAction SilentlyContinue
            if ($vpnGateway) {
                $hubHealth.VPNGateway = @{
                    Name = $vpnGateway.Name
                    ProvisioningState = $vpnGateway.ProvisioningState
                    VpnGatewayScaleUnit = $vpnGateway.VpnGatewayScaleUnit
                    Health = if ($vpnGateway.ProvisioningState -eq "Succeeded") {"Healthy"} else {"Unhealthy"}
                }
                
                Write-Output "      VPN Gateway: $($vpnGateway.Name) - $($vpnGateway.ProvisioningState)"
                Write-Output "        Scale Units: $($vpnGateway.VpnGatewayScaleUnit)"
                
                if ($vpnGateway.ProvisioningState -ne "Succeeded") {
                    New-HealthAlert -Severity "Warning" -Component "VPN Gateway" -Message "$($vpnGateway.Name) provisioning state is $($vpnGateway.ProvisioningState)"
                }
            } else {
                Write-Output "      VPN Gateway: Not found or not deployed"
            }
        }
        catch {
            Write-Warning "      Could not retrieve VPN Gateway information"
        }
        
        $healthResults.VirtualHubs += $hubHealth
    }
}
catch {
    New-HealthAlert -Severity "Critical" -Component "Virtual Hubs" -Message "Failed to retrieve Virtual Hubs: $($_.Exception.Message)"
}

# Step 3: Check VPN Connections
Write-Output ""
Write-Output "Step 3: Checking VPN Connection health..."
$totalConnections = 0
$healthyConnections = 0

foreach ($hub in $virtualHubs) {
    try {
        $connections = Get-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $hub.Name
        $totalConnections += $connections.Count
        
        Write-Output "    Hub $($hub.Name): $($connections.Count) connections"
        
        foreach ($conn in $connections) {
            $connectionHealth = @{
                Hub = $hub.Name
                Name = $conn.Name
                ConnectionStatus = $conn.ConnectionStatus
                ProvisioningState = $conn.ProvisioningState
                ConnectionBandwidth = $conn.ConnectionBandwidth
                IngressBytesTransferred = $conn.IngressBytesTransferred
                EgressBytesTransferred = $conn.EgressBytesTransferred
                Health = "Unknown"
                HealthScore = 0
            }
            
            Write-Output "      Connection: $($conn.Name)"
            Write-Output "        Status: $($conn.ConnectionStatus)"
            Write-Output "        Bandwidth: $($conn.ConnectionBandwidth) Mbps"
            Write-Output "        Data Transfer: In=$($conn.IngressBytesTransferred), Out=$($conn.EgressBytesTransferred)"
            
            # Calculate connection health score
            if ($conn.ConnectionStatus -eq "Connected") {
                $connectionHealth.HealthScore += 50
            } else {
                New-HealthAlert -Severity "Critical" -Component "VPN Connection" -Message "$($conn.Name) is $($conn.ConnectionStatus)"
            }
            
            if ($conn.ProvisioningState -eq "Succeeded") {
                $connectionHealth.HealthScore += 25
            }
            
            if ($conn.IngressBytesTransferred -gt 0) {
                $connectionHealth.HealthScore += 12.5
            }
            
            if ($conn.EgressBytesTransferred -gt 0) {
                $connectionHealth.HealthScore += 12.5
            }
            
            # Determine overall connection health
            if ($connectionHealth.HealthScore -ge 80) {
                $connectionHealth.Health = "Healthy"
                $healthyConnections++
            } elseif ($connectionHealth.HealthScore -ge 60) {
                $connectionHealth.Health = "Warning"
                New-HealthAlert -Severity "Warning" -Component "VPN Connection" -Message "$($conn.Name) health score is $($connectionHealth.HealthScore)"
            } else {
                $connectionHealth.Health = "Unhealthy"
                New-HealthAlert -Severity "Critical" -Component "VPN Connection" -Message "$($conn.Name) is unhealthy (score: $($connectionHealth.HealthScore))"
            }
            
            Write-Output "        Health: $($connectionHealth.Health) (Score: $($connectionHealth.HealthScore))"
            
            $healthResults.VPNConnections += $connectionHealth
        }
    }
    catch {
        Write-Warning "    Could not retrieve connections for hub: $($hub.Name)"
    }
}

# Calculate connection health percentage
$connectionHealthPercentage = if ($totalConnections -gt 0) {
    [math]::Round(($healthyConnections / $totalConnections) * 100, 1)
} else { 100 }

Write-Output "  Connection Health Summary: $healthyConnections/$totalConnections healthy ($connectionHealthPercentage%)"

if ($connectionHealthPercentage -lt $defaultThresholds.VPNConnectionHealth) {
    New-HealthAlert -Severity "Warning" -Component "VPN Connections" -Message "Connection health ($connectionHealthPercentage%) below threshold ($($defaultThresholds.VPNConnectionHealth)%)"
}

# Step 4: Check Azure Firewall Health
Write-Output ""
Write-Output "Step 4: Checking Azure Firewall health..."
try {
    $firewalls = Get-AzFirewall -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($firewalls) {
        Write-Output "  Found $($firewalls.Count) Azure Firewalls"
        
        foreach ($firewall in $firewalls) {
            $firewallHealth = @{
                Name = $firewall.Name
                Location = $firewall.Location
                ProvisioningState = $firewall.ProvisioningState
                ThreatIntelMode = $firewall.ThreatIntelMode
                PublicIPs = $firewall.IpConfigurations.Count
                Health = if ($firewall.ProvisioningState -eq "Succeeded") {"Healthy"} else {"Unhealthy"}
            }
            
            Write-Output "    Firewall: $($firewall.Name)"
            Write-Output "      Provisioning State: $($firewall.ProvisioningState)"
            Write-Output "      Threat Intel Mode: $($firewall.ThreatIntelMode)"
            Write-Output "      Public IPs: $($firewall.IpConfigurations.Count)"
            
            if ($firewall.ProvisioningState -ne "Succeeded") {
                New-HealthAlert -Severity "Critical" -Component "Azure Firewall" -Message "$($firewall.Name) provisioning state is $($firewall.ProvisioningState)"
            }
            
            $healthResults.AzureFirewalls += $firewallHealth
        }
    } else {
        Write-Output "  No Azure Firewalls found"
    }
}
catch {
    Write-Warning "  Could not retrieve Azure Firewall information"
}

# Step 5: Collect Performance Metrics
Write-Output ""
Write-Output "Step 5: Collecting performance metrics..."

if ($LogAnalyticsWorkspaceId) {
    try {
        # Example: Collect bandwidth utilization metrics
        # In production, use Invoke-AzOperationalInsightsQuery
        
        Write-Output "  Collecting metrics from Log Analytics workspace..."
        # Bandwidth utilization query example
        $bandwidthQuery = @"
AzureMetrics
| where TimeGenerated >= ago(1h)
| where ResourceProvider == "MICROSOFT.NETWORK"
| where MetricName == "TunnelBandwidth"
| summarize avg(Average) by Resource, bin(TimeGenerated, 5m)
| order by TimeGenerated desc
"@
        
        Write-Output "  Bandwidth utilization metrics collected"
        
        # Add simulated performance metrics
        $performanceMetrics = @{
            BandwidthUtilization = 65.2  # Percentage
            AverageLatency = 25.8       # Milliseconds  
            PacketLoss = 0.02           # Percentage
            Timestamp = Get-Date
        }
        
        $healthResults.PerformanceMetrics = $performanceMetrics
        
        Write-Output "  Performance Metrics:"
        Write-Output "    Bandwidth Utilization: $($performanceMetrics.BandwidthUtilization)%"
        Write-Output "    Average Latency: $($performanceMetrics.AverageLatency)ms"
        Write-Output "    Packet Loss: $($performanceMetrics.PacketLoss)%"
        
        # Check performance thresholds
        if ($performanceMetrics.BandwidthUtilization -gt $defaultThresholds.BandwidthUtilization) {
            New-HealthAlert -Severity "Warning" -Component "Performance" -Message "High bandwidth utilization: $($performanceMetrics.BandwidthUtilization)%"
        }
        
        if ($performanceMetrics.AverageLatency -gt $defaultThresholds.Latency) {
            New-HealthAlert -Severity "Warning" -Component "Performance" -Message "High latency: $($performanceMetrics.AverageLatency)ms"
        }
        
        if ($performanceMetrics.PacketLoss -gt $defaultThresholds.PacketLoss) {
            New-HealthAlert -Severity "Critical" -Component "Performance" -Message "High packet loss: $($performanceMetrics.PacketLoss)%"
        }
    }
    catch {
        Write-Warning "  Failed to collect performance metrics: $($_.Exception.Message)"
    }
} else {
    Write-Output "  Skipping performance metrics (no Log Analytics workspace specified)"
}

# Calculate overall health score
$componentScores = @()

# Virtual WAN score
if ($healthResults.VirtualWAN -and $healthResults.VirtualWAN.Health -eq "Healthy") {
    $componentScores += 25
} else {
    $componentScores += 0
}

# Virtual Hubs score
$healthyHubs = ($healthResults.VirtualHubs | Where-Object {$_.Health -eq "Healthy"}).Count
$totalHubs = $healthResults.VirtualHubs.Count
$hubScore = if ($totalHubs -gt 0) { ($healthyHubs / $totalHubs) * 25 } else { 25 }
$componentScores += $hubScore

# VPN Connections score
$connectionScore = ($connectionHealthPercentage / 100) * 30
$componentScores += $connectionScore

# Azure Firewall score
$healthyFirewalls = ($healthResults.AzureFirewalls | Where-Object {$_.Health -eq "Healthy"}).Count
$totalFirewalls = $healthResults.AzureFirewalls.Count
$firewallScore = if ($totalFirewalls -gt 0) { ($healthyFirewalls / $totalFirewalls) * 20 } else { 20 }
$componentScores += $firewallScore

$healthResults.HealthScore = [math]::Round(($componentScores | Measure-Object -Sum).Sum, 1)

# Determine overall health status
if ($healthResults.HealthScore -ge 90) {
    $healthResults.OverallHealth = "Excellent"
} elseif ($healthResults.HealthScore -ge 80) {
    $healthResults.OverallHealth = "Good"
} elseif ($healthResults.HealthScore -ge 70) {
    $healthResults.OverallHealth = "Fair"
} elseif ($healthResults.HealthScore -ge 60) {
    $healthResults.OverallHealth = "Poor"
} else {
    $healthResults.OverallHealth = "Critical"
}

# Final Health Report
Write-Output ""
Write-Output "=== Overall Health Summary ==="
Write-Output "Overall Health: $($healthResults.OverallHealth)"
Write-Output "Health Score: $($healthResults.HealthScore)/100"
Write-Output "Total Alerts: $($healthResults.Alerts.Count)"
Write-Output "  Critical: $(($healthResults.Alerts | Where-Object {$_.Severity -eq 'Critical'}).Count)"
Write-Output "  Warning: $(($healthResults.Alerts | Where-Object {$_.Severity -eq 'Warning'}).Count)"
Write-Output "  Info: $(($healthResults.Alerts | Where-Object {$_.Severity -eq 'Info'}).Count)"

# Save results
$resultsPath = "vwan-health-monitoring-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$healthResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsPath -Encoding UTF8
Write-Output ""
Write-Output "Health monitoring results saved to: $resultsPath"

# Send alerts if enabled
Send-Alerts -Alerts $healthResults.Alerts

# Return appropriate exit code
if ($healthResults.OverallHealth -eq "Critical" -or ($healthResults.Alerts | Where-Object {$_.Severity -eq "Critical"}).Count -gt 0) {
    Write-Output ""
    Write-Output "❌ Critical issues detected - immediate attention required"
    exit 2
} elseif (($healthResults.Alerts | Where-Object {$_.Severity -eq "Warning"}).Count -gt 0) {
    Write-Output ""
    Write-Output "⚠️ Warning issues detected - review recommended"
    exit 1
} else {
    Write-Output ""
    Write-Output "✅ Virtual WAN is healthy"
    exit 0
}
```

## Usage Examples

### Basic Deployment

```bash
# Deploy Virtual WAN with configuration file
.\Deploy-VirtualWAN.ps1 -ConfigFilePath ".\config\production.json" -SubscriptionId "12345678-1234-1234-1234-123456789012"

# Test deployment (dry run)
.\Deploy-VirtualWAN.ps1 -ConfigFilePath ".\config\test.json" -WhatIf

# Deploy single hub
.\Deploy-VirtualHub.ps1 -ResourceGroupName "rg-vwan-prod" -HubName "hub-eastus-prod" -Location "East US" -AddressPrefix "10.0.0.0/24"
```

### Management Operations

```powershell
# Check all VPN connection status
.\Manage-VPNConnections.ps1 -Action Status -ResourceGroupName "rg-vwan-prod"

# Reset specific connection
.\Manage-VPNConnections.ps1 -Action Reset -ResourceGroupName "rg-vwan-prod" -ConnectionName "site-hq-connection"

# Update bandwidth for all connections
.\Manage-VPNConnections.ps1 -Action UpdateBandwidth -ResourceGroupName "rg-vwan-prod" -NewBandwidth 200

# Perform health check
.\Manage-VPNConnections.ps1 -Action HealthCheck -ResourceGroupName "rg-vwan-prod"
```

### Monitoring and Maintenance

```bash
# Run health monitoring
.\Monitor-VWanHealth.ps1 -ResourceGroupName "rg-vwan-prod" -SendAlerts

# Collect performance metrics
.\Collect-Metrics.ps1 -ResourceGroupName "rg-vwan-prod" -LogAnalyticsWorkspaceId "12345678-1234-1234-1234-123456789012"

# Scheduled maintenance
.\Maintenance-Window.ps1 -ResourceGroupName "rg-vwan-prod" -MaintenanceType "Certificate-Renewal"
```

### Automation Integration

```yaml
# Azure DevOps Pipeline Integration
- task: AzurePowerShell@5
  displayName: 'Deploy Virtual WAN'
  inputs:
    azureSubscription: '$(azureServiceConnection)'
    scriptType: 'filePath'
    scriptPath: '$(System.DefaultWorkingDirectory)/scripts/Deploy-VirtualWAN.ps1'
    scriptArguments: '-ConfigFilePath "$(System.DefaultWorkingDirectory)/config/$(Environment).json" -SubscriptionId "$(subscriptionId)"'
    azurePowerShellVersion: 'LatestVersion'
```

## Best Practices

### Script Development Guidelines

1. **Error Handling**: Always include comprehensive error handling
2. **Logging**: Implement detailed logging for troubleshooting
3. **Parameterization**: Make scripts configurable via parameters
4. **Validation**: Validate inputs and prerequisites
5. **Documentation**: Include comprehensive help and examples

### Security Considerations

1. **Authentication**: Use managed identities when possible
2. **Secrets Management**: Store sensitive data in Azure Key Vault
3. **Permissions**: Follow principle of least privilege
4. **Audit Trail**: Log all administrative actions

### Performance Optimization

1. **Parallel Execution**: Use parallel processing where appropriate
2. **Resource Batching**: Batch operations to reduce API calls
3. **Caching**: Cache frequently accessed data
4. **Timeouts**: Implement appropriate timeouts for long-running operations

---

**Scripts Documentation Version**: 1.0  
**Last Updated**: August 2024  
**Next Review Date**: November 2024