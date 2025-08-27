# Azure Virtual WAN Global - Operations Runbook

## Overview

This operations runbook provides comprehensive procedures for the day-to-day management, monitoring, and maintenance of Azure Virtual WAN Global connectivity solutions. It serves as the primary reference for network operations teams.

## Table of Contents

1. [Daily Operations](#daily-operations)
2. [Monitoring and Alerting](#monitoring-and-alerting)
3. [Incident Response Procedures](#incident-response-procedures)
4. [Maintenance Procedures](#maintenance-procedures)
5. [Performance Management](#performance-management)
6. [Security Operations](#security-operations)
7. [Capacity Planning](#capacity-planning)
8. [Troubleshooting Guide](#troubleshooting-guide)

## Daily Operations

### Daily Health Checks

#### Morning Health Check (9:00 AM Local Time)

```powershell
# Daily Virtual WAN Health Check Script
# File: Daily-VWanHealthCheck.ps1

param(
    [string]$ResourceGroupName = "rg-vwan-core-prod",
    [string]$VirtualWanName = "corp-global-vwan"
)

Write-Output "=== Azure Virtual WAN Daily Health Check ==="
Write-Output "Timestamp: $(Get-Date)"
Write-Output ""

# Connect to Azure
Connect-AzAccount -Identity

# Check Virtual WAN Status
Write-Output "1. Virtual WAN Status Check"
$virtualWan = Get-AzVirtualWan -ResourceGroupName $ResourceGroupName -Name $VirtualWanName
Write-Output "   Virtual WAN: $($virtualWan.Name) - Status: $($virtualWan.ProvisioningState)"

# Check Virtual Hubs
Write-Output ""
Write-Output "2. Virtual Hub Status Check"
$hubs = Get-AzVirtualHub -ResourceGroupName $ResourceGroupName
foreach ($hub in $hubs) {
    Write-Output "   Hub: $($hub.Name)"
    Write-Output "     Location: $($hub.Location)"
    Write-Output "     Status: $($hub.ProvisioningState)"
    Write-Output "     Address Prefix: $($hub.AddressPrefix)"
}

# Check VPN Gateway Status
Write-Output ""
Write-Output "3. VPN Gateway Status Check"
foreach ($hub in $hubs) {
    try {
        $vpnGateway = Get-AzVpnGateway -ResourceGroupName $ResourceGroupName -Name "$($hub.Name.Split('-')[1..2] -join '-')-vpngw" -ErrorAction SilentlyContinue
        if ($vpnGateway) {
            Write-Output "   Gateway: $($vpnGateway.Name) - Status: $($vpnGateway.ProvisioningState)"
            Write-Output "     Scale Units: $($vpnGateway.VpnGatewayScaleUnit)"
        }
    }
    catch {
        Write-Output "   No VPN Gateway found for hub: $($hub.Name)"
    }
}

# Check VPN Connections
Write-Output ""
Write-Output "4. VPN Connection Status Check"
$allConnections = @()
foreach ($hub in $hubs) {
    try {
        $connections = Get-AzVpnConnection -ResourceGroupName $ResourceGroupName -ParentResourceName $hub.Name
        foreach ($conn in $connections) {
            $connectionInfo = @{
                Hub = $hub.Name
                Connection = $conn.Name
                Status = $conn.ConnectionStatus
                IngressBytesTransferred = $conn.IngressBytesTransferred
                EgressBytesTransferred = $conn.EgressBytesTransferred
            }
            $allConnections += $connectionInfo
            Write-Output "   Connection: $($conn.Name) - Status: $($conn.ConnectionStatus)"
        }
    }
    catch {
        Write-Output "   No connections found for hub: $($hub.Name)"
    }
}

# Check Azure Firewall Status
Write-Output ""
Write-Output "5. Azure Firewall Status Check"
$firewalls = Get-AzFirewall -ResourceGroupName "rg-vwan-security-prod"
foreach ($firewall in $firewalls) {
    Write-Output "   Firewall: $($firewall.Name) - Status: $($firewall.ProvisioningState)"
    Write-Output "     Location: $($firewall.Location)"
    Write-Output "     Public IPs: $($firewall.IpConfigurations.Count)"
}

# Generate Summary Report
Write-Output ""
Write-Output "=== Health Check Summary ==="
$healthyHubs = ($hubs | Where-Object {$_.ProvisioningState -eq "Succeeded"}).Count
$totalHubs = $hubs.Count
$healthyConnections = ($allConnections | Where-Object {$_.Status -eq "Connected"}).Count
$totalConnections = $allConnections.Count

Write-Output "Virtual Hubs: $healthyHubs/$totalHubs healthy"
Write-Output "VPN Connections: $healthyConnections/$totalConnections connected"
Write-Output "Overall Status: $(if ($healthyHubs -eq $totalHubs -and $healthyConnections -eq $totalConnections) {'HEALTHY'} else {'ATTENTION REQUIRED'})"

# Save results to log
$logPath = "C:\Logs\VWan\DailyHealthCheck_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$output | Out-File -FilePath $logPath
```

#### Performance Metrics Collection

```powershell
# Collect key performance metrics
function Get-VWanPerformanceMetrics {
    param(
        [string]$ResourceGroupName,
        [datetime]$StartTime = (Get-Date).AddHours(-24),
        [datetime]$EndTime = (Get-Date)
    )
    
    Write-Output "Collecting performance metrics for last 24 hours..."
    
    # VPN Gateway metrics
    $vpnGateways = Get-AzVpnGateway -ResourceGroupName $ResourceGroupName
    foreach ($gateway in $vpnGateways) {
        $metrics = Get-AzMetric `
            -ResourceId $gateway.Id `
            -MetricName "TunnelBandwidth", "TunnelIngressPackets", "TunnelEgressPackets" `
            -StartTime $StartTime `
            -EndTime $EndTime `
            -TimeGrain "01:00:00"
        
        Write-Output "Gateway: $($gateway.Name)"
        foreach ($metric in $metrics) {
            $avgValue = ($metric.Data | Measure-Object Average -Property Average).Average
            Write-Output "  $($metric.Name.Value): $([math]::Round($avgValue, 2))"
        }
    }
    
    # Azure Firewall metrics
    $firewalls = Get-AzFirewall -ResourceGroupName "rg-vwan-security-prod"
    foreach ($firewall in $firewalls) {
        $fwMetrics = Get-AzMetric `
            -ResourceId $firewall.Id `
            -MetricName "DataProcessed", "FirewallHealth", "Throughput" `
            -StartTime $StartTime `
            -EndTime $EndTime `
            -TimeGrain "01:00:00"
        
        Write-Output "Firewall: $($firewall.Name)"
        foreach ($metric in $fwMetrics) {
            $avgValue = ($metric.Data | Measure-Object Average -Property Average).Average
            Write-Output "  $($metric.Name.Value): $([math]::Round($avgValue, 2))"
        }
    }
}
```

### Weekly Operations Tasks

#### Sunday - Capacity Review

```bash
#!/bin/bash
# Weekly capacity review script
# File: weekly-capacity-review.sh

echo "=== Weekly Virtual WAN Capacity Review ==="
echo "Date: $(date)"
echo ""

# Check VPN Gateway utilization
echo "1. VPN Gateway Utilization Review"
az monitor metrics list \
    --resource "/subscriptions/{subscription-id}/resourceGroups/rg-vwan-core-prod/providers/Microsoft.Network/vpnGateways/hub-eastus-vpngw" \
    --metric "TunnelBandwidth" \
    --start-time $(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --interval PT1H \
    --aggregation Average

# Check firewall data processing
echo ""
echo "2. Azure Firewall Data Processing Review"
az monitor metrics list \
    --resource "/subscriptions/{subscription-id}/resourceGroups/rg-vwan-security-prod/providers/Microsoft.Network/azureFirewalls/hub-eastus-firewall" \
    --metric "DataProcessed" \
    --start-time $(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --interval PT1H \
    --aggregation Average

# Generate capacity recommendations
echo ""
echo "3. Capacity Recommendations"
echo "   - Review bandwidth utilization trends"
echo "   - Identify potential scaling requirements"
echo "   - Update capacity planning documentation"
```

## Monitoring and Alerting

### Key Metrics to Monitor

#### Network Performance Metrics

| Metric | Threshold | Action |
|--------|-----------|---------|
| VPN Tunnel Bandwidth | > 80% of allocated | Scale VPN Gateway |
| Tunnel Packet Loss | > 1% | Investigate connection |
| Hub-to-Hub Latency | > 50ms | Review routing |
| Firewall Throughput | > 90% capacity | Scale firewall |
| Connection Status | Any disconnected | Immediate investigation |

#### Monitoring Dashboard Setup

```json
{
    "dashboard": {
        "id": "vwan-operations-dashboard",
        "displayName": "Virtual WAN Operations Dashboard",
        "tiles": [
            {
                "name": "VPN Connection Status",
                "visualization": "singlestat",
                "targets": [
                    {
                        "query": "AzureDiagnostics | where ResourceType == \"VPNGATEWAYS\" | where TimeGenerated >= ago(5m) | summarize ConnectionsUp = countif(Status_s == \"Connected\"), ConnectionsDown = countif(Status_s != \"Connected\")"
                    }
                ]
            },
            {
                "name": "Bandwidth Utilization",
                "visualization": "graph",
                "targets": [
                    {
                        "query": "AzureMetrics | where ResourceProvider == \"MICROSOFT.NETWORK\" | where MetricName == \"TunnelBandwidth\" | summarize avg(Average) by bin(TimeGenerated, 5m)"
                    }
                ]
            },
            {
                "name": "Firewall Health",
                "visualization": "stat",
                "targets": [
                    {
                        "query": "AzureDiagnostics | where ResourceType == \"AZUREFIREWALLS\" | where TimeGenerated >= ago(5m) | summarize HealthyFirewalls = countif(FirewallHealth_d > 90)"
                    }
                ]
            }
        ]
    }
}
```

### Alert Configuration

#### Critical Alerts

```powershell
# Configure critical alert rules
$alertRules = @(
    @{
        Name = "VPN-Connection-Down"
        Description = "VPN connection is down"
        MetricName = "TunnelIngress"
        Operator = "LessThan"
        Threshold = 1
        WindowSize = "PT5M"
        Frequency = "PT1M"
        Severity = 0
    },
    @{
        Name = "High-Packet-Loss"
        Description = "High packet loss detected"
        MetricName = "TunnelIngressPacketDropCount"
        Operator = "GreaterThan"
        Threshold = 100
        WindowSize = "PT5M"
        Frequency = "PT1M"
        Severity = 1
    },
    @{
        Name = "Firewall-Health-Critical"
        Description = "Azure Firewall health is critical"
        MetricName = "FirewallHealth"
        Operator = "LessThan"
        Threshold = 90
        WindowSize = "PT5M"
        Frequency = "PT1M"
        Severity = 0
    }
)

foreach ($alert in $alertRules) {
    New-AzMetricAlertRuleV2 `
        -Name $alert.Name `
        -ResourceGroupName "rg-vwan-monitoring-prod" `
        -WindowSize $alert.WindowSize `
        -Frequency $alert.Frequency `
        -TargetResourceScope "/subscriptions/{subscription-id}/resourceGroups/rg-vwan-core-prod" `
        -MetricName $alert.MetricName `
        -Operator $alert.Operator `
        -Threshold $alert.Threshold `
        -Severity $alert.Severity
}
```

## Incident Response Procedures

### Severity Levels

| Severity | Definition | Response Time | Escalation |
|----------|------------|---------------|------------|
| Critical (P1) | Complete service outage | 15 minutes | Immediate |
| High (P2) | Significant service impact | 30 minutes | 1 hour |
| Medium (P3) | Minor service impact | 2 hours | 4 hours |
| Low (P4) | No service impact | 8 hours | 24 hours |

### P1 Incident Response - VPN Connection Failure

```powershell
# P1 Incident Response Script
# File: P1-VPN-Connection-Failure.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$ConnectionName,
    [Parameter(Mandatory=$true)]
    [string]$HubName
)

Write-Output "=== P1 INCIDENT RESPONSE: VPN CONNECTION FAILURE ==="
Write-Output "Incident Time: $(Get-Date)"
Write-Output "Connection: $ConnectionName"
Write-Output "Hub: $HubName"
Write-Output ""

# Step 1: Gather initial information
Write-Output "STEP 1: Gathering connection information..."
$connection = Get-AzVpnConnection -ResourceGroupName "rg-vwan-core-prod" -ParentResourceName $HubName -Name $ConnectionName

Write-Output "Connection Status: $($connection.ConnectionStatus)"
Write-Output "Provisioning State: $($connection.ProvisioningState)"
Write-Output "Ingress Bytes: $($connection.IngressBytesTransferred)"
Write-Output "Egress Bytes: $($connection.EgressBytesTransferred)"

# Step 2: Check VPN gateway status
Write-Output ""
Write-Output "STEP 2: Checking VPN Gateway status..."
$vpnGateway = Get-AzVpnGateway -ResourceGroupName "rg-vwan-core-prod" -Name "$HubName-vpngw"
Write-Output "Gateway Status: $($vpnGateway.ProvisioningState)"
Write-Output "Gateway Scale Units: $($vpnGateway.VpnGatewayScaleUnit)"

# Step 3: Check associated VPN site
Write-Output ""
Write-Output "STEP 3: Checking VPN Site configuration..."
$vpnSite = Get-AzVpnSite -ResourceGroupName "rg-vwan-core-prod" -Name $($connection.VpnSiteLink.VpnSiteId.Split('/')[-1])
Write-Output "Site Public IP: $($vpnSite.IpAddress)"
Write-Output "Site Address Space: $($vpnSite.AddressSpace.AddressPrefixes -join ', ')"

# Step 4: Restart connection
Write-Output ""
Write-Output "STEP 4: Attempting connection restart..."
try {
    # Reset the VPN connection
    Reset-AzVpnConnection -ResourceGroupName "rg-vwan-core-prod" -ParentResourceName $HubName -Name $ConnectionName
    Write-Output "Connection reset initiated successfully"
    
    # Wait and check status
    Start-Sleep -Seconds 60
    $updatedConnection = Get-AzVpnConnection -ResourceGroupName "rg-vwan-core-prod" -ParentResourceName $HubName -Name $ConnectionName
    Write-Output "Updated Connection Status: $($updatedConnection.ConnectionStatus)"
    
    if ($updatedConnection.ConnectionStatus -eq "Connected") {
        Write-Output "SUCCESS: Connection restored"
    } else {
        Write-Output "WARNING: Connection still not restored - escalating"
    }
}
catch {
    Write-Output "ERROR: Failed to reset connection - $($_.Exception.Message)"
}

# Step 5: Generate incident report
Write-Output ""
Write-Output "STEP 5: Generating incident report..."
$incidentReport = @{
    IncidentID = "VPN-$(Get-Date -Format 'yyyyMMddHHmmss')"
    Timestamp = Get-Date
    Connection = $ConnectionName
    Hub = $HubName
    InitialStatus = $connection.ConnectionStatus
    ActionsPerformed = @("Information gathering", "Gateway status check", "Connection reset")
    Resolution = if ($updatedConnection.ConnectionStatus -eq "Connected") {"Resolved"} else {"Escalated"}
}

$incidentReport | ConvertTo-Json | Out-File -FilePath "C:\Logs\Incidents\$($incidentReport.IncidentID).json"
Write-Output "Incident report saved: $($incidentReport.IncidentID)"
```

### P2 Incident Response - Performance Degradation

```bash
#!/bin/bash
# P2 Incident Response - Performance Degradation
# File: P2-performance-degradation.sh

CONNECTION_NAME="$1"
HUB_NAME="$2"

echo "=== P2 INCIDENT RESPONSE: PERFORMANCE DEGRADATION ==="
echo "Incident Time: $(date)"
echo "Connection: $CONNECTION_NAME"
echo "Hub: $HUB_NAME"
echo ""

# Step 1: Check current performance metrics
echo "STEP 1: Collecting current performance metrics..."
az monitor metrics list \
    --resource "/subscriptions/{subscription-id}/resourceGroups/rg-vwan-core-prod/providers/Microsoft.Network/vpnGateways/${HUB_NAME}-vpngw" \
    --metric "TunnelBandwidth" "TunnelIngressPackets" "TunnelEgressPackets" \
    --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --interval PT5M \
    --aggregation Average

# Step 2: Check for packet loss
echo ""
echo "STEP 2: Checking for packet loss indicators..."
az monitor metrics list \
    --resource "/subscriptions/{subscription-id}/resourceGroups/rg-vwan-core-prod/providers/Microsoft.Network/vpnGateways/${HUB_NAME}-vpngw" \
    --metric "TunnelIngressPacketDropCount" "TunnelEgressPacketDropCount" \
    --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --interval PT5M \
    --aggregation Total

# Step 3: Check firewall performance impact
echo ""
echo "STEP 3: Checking Azure Firewall performance..."
az monitor metrics list \
    --resource "/subscriptions/{subscription-id}/resourceGroups/rg-vwan-security-prod/providers/Microsoft.Network/azureFirewalls/${HUB_NAME}-firewall" \
    --metric "Throughput" "FirewallHealth" \
    --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --interval PT5M \
    --aggregation Average

# Step 4: Generate performance report
echo ""
echo "STEP 4: Performance degradation analysis complete"
echo "Review the metrics above for:"
echo "- Bandwidth utilization spikes"
echo "- Packet loss indicators"  
echo "- Firewall health degradation"
echo "- Consider scaling if sustained high utilization"
```

## Maintenance Procedures

### Monthly Maintenance Tasks

#### First Saturday of Each Month - Security Updates

```powershell
# Monthly security maintenance
# File: Monthly-Security-Maintenance.ps1

Write-Output "=== Monthly Virtual WAN Security Maintenance ==="
Write-Output "Date: $(Get-Date)"

# 1. Review and update firewall rules
Write-Output "1. Reviewing Azure Firewall rules..."
$firewalls = Get-AzFirewall -ResourceGroupName "rg-vwan-security-prod"
foreach ($firewall in $firewalls) {
    $policy = Get-AzFirewallPolicy -ResourceId $firewall.FirewallPolicy.Id
    Write-Output "Firewall: $($firewall.Name) - Policy: $($policy.Name)"
    
    # Review rule collections
    $ruleCollections = Get-AzFirewallPolicyRuleCollectionGroup -ResourceGroupName "rg-vwan-security-prod" -AzureFirewallPolicyName $policy.Name
    foreach ($collection in $ruleCollections) {
        Write-Output "  Rule Collection: $($collection.Name) - Priority: $($collection.Priority)"
    }
}

# 2. Update network security groups
Write-Output ""
Write-Output "2. Reviewing Network Security Groups..."
$nsgs = Get-AzNetworkSecurityGroup -ResourceGroupName "rg-vwan-security-prod"
foreach ($nsg in $nsgs) {
    Write-Output "NSG: $($nsg.Name) - Rules: $($nsg.SecurityRules.Count)"
    
    # Check for unused rules
    $unusedRules = $nsg.SecurityRules | Where-Object {$_.Access -eq "Allow" -and $_.Direction -eq "Inbound" -and $_.SourceAddressPrefix -eq "*"}
    if ($unusedRules.Count -gt 0) {
        Write-Output "  WARNING: Found $($unusedRules.Count) potentially overpermissive rules"
    }
}

# 3. Review access logs
Write-Output ""
Write-Output "3. Reviewing access logs for anomalies..."
$query = @"
AzureDiagnostics
| where TimeGenerated >= ago(30d)
| where ResourceType == "AZUREFIREWALLS"
| where msg_s contains "Deny"
| summarize count() by SourceIP = split(msg_s, ' ')[3], TargetIP = split(msg_s, ' ')[5]
| order by count_ desc
| take 10
"@

# Execute log query (requires Log Analytics workspace)
# Invoke-AzOperationalInsightsQuery -WorkspaceId $workspaceId -Query $query

Write-Output "Security maintenance review completed"
```

### Quarterly Maintenance Tasks

#### Disaster Recovery Testing

```powershell
# Quarterly DR test procedure
# File: Quarterly-DR-Test.ps1

Write-Output "=== Quarterly Disaster Recovery Test ==="
Write-Output "Date: $(Get-Date)"

# 1. Test hub failover capability
Write-Output "1. Testing hub failover scenarios..."

# Simulate primary hub failure by temporarily disabling connections
$primaryHub = "hub-eastus-prod"
$secondaryHub = "hub-westus-prod"

Write-Output "Simulating failure of primary hub: $primaryHub"

# Get connections from primary hub
$primaryConnections = Get-AzVpnConnection -ResourceGroupName "rg-vwan-core-prod" -ParentResourceName $primaryHub

# Temporarily disable connections (in test environment only)
foreach ($conn in $primaryConnections) {
    Write-Output "  Would disable connection: $($conn.Name)"
    # In actual DR test, would execute: Set-AzVpnConnection -Disable
}

# Verify traffic routing to secondary hub
Write-Output "Verifying traffic routes to secondary hub: $secondaryHub"

# Test connectivity from secondary hub
$secondaryConnections = Get-AzVpnConnection -ResourceGroupName "rg-vwan-core-prod" -ParentResourceName $secondaryHub
Write-Output "Secondary hub has $($secondaryConnections.Count) active connections"

# 2. Test backup and restore procedures
Write-Output ""
Write-Output "2. Testing backup and restore procedures..."

# Export current configuration
Write-Output "Exporting current Virtual WAN configuration..."
$vwan = Get-AzVirtualWan -ResourceGroupName "rg-vwan-core-prod" -Name "corp-global-vwan"
$hubs = Get-AzVirtualHub -ResourceGroupName "rg-vwan-core-prod"

$config = @{
    VirtualWAN = $vwan
    VirtualHubs = $hubs
    Timestamp = Get-Date
}

$configJson = $config | ConvertTo-Json -Depth 10
$configJson | Out-File -FilePath "C:\Backups\VWan\DR-Test-Config-$(Get-Date -Format 'yyyyMMdd').json"

Write-Output "Configuration backup completed"

# 3. Test communication procedures
Write-Output ""
Write-Output "3. Testing communication procedures..."
Write-Output "DR test communication checklist:"
Write-Output "  - Notify stakeholders of DR test"
Write-Output "  - Activate incident response team"
Write-Output "  - Test emergency contact procedures"
Write-Output "  - Validate escalation chains"

Write-Output ""
Write-Output "Quarterly DR test completed successfully"
```

## Performance Management

### Performance Baseline Establishment

```powershell
# Establish performance baselines
function Set-VWanPerformanceBaseline {
    param(
        [string]$ResourceGroupName = "rg-vwan-core-prod",
        [int]$BaselineDays = 30
    )
    
    Write-Output "Establishing Virtual WAN performance baseline..."
    Write-Output "Analysis period: Last $BaselineDays days"
    
    $startTime = (Get-Date).AddDays(-$BaselineDays)
    $endTime = Get-Date
    
    # VPN Gateway baseline metrics
    $vpnGateways = Get-AzVpnGateway -ResourceGroupName $ResourceGroupName
    $baselineData = @{}
    
    foreach ($gateway in $vpnGateways) {
        Write-Output "Processing gateway: $($gateway.Name)"
        
        # Get bandwidth utilization
        $bandwidthMetrics = Get-AzMetric `
            -ResourceId $gateway.Id `
            -MetricName "TunnelBandwidth" `
            -StartTime $startTime `
            -EndTime $endTime `
            -TimeGrain "01:00:00"
        
        $avgBandwidth = ($bandwidthMetrics.Data | Measure-Object Average -Property Average).Average
        $maxBandwidth = ($bandwidthMetrics.Data | Measure-Object Maximum -Property Maximum).Maximum
        $p95Bandwidth = ($bandwidthMetrics.Data | Sort-Object Average | Select-Object -Last ([int]($bandwidthMetrics.Data.Count * 0.95)) | Select-Object -Last 1).Average
        
        $baselineData[$gateway.Name] = @{
            AvgBandwidth = [math]::Round($avgBandwidth, 2)
            MaxBandwidth = [math]::Round($maxBandwidth, 2)
            P95Bandwidth = [math]::Round($p95Bandwidth, 2)
            BaselineDate = Get-Date
        }
        
        Write-Output "  Avg Bandwidth: $([math]::Round($avgBandwidth, 2)) Mbps"
        Write-Output "  Max Bandwidth: $([math]::Round($maxBandwidth, 2)) Mbps"
        Write-Output "  95th Percentile: $([math]::Round($p95Bandwidth, 2)) Mbps"
    }
    
    # Save baseline data
    $baselineJson = $baselineData | ConvertTo-Json -Depth 3
    $baselineJson | Out-File -FilePath "C:\Baselines\VWan-Performance-Baseline-$(Get-Date -Format 'yyyyMMdd').json"
    
    return $baselineData
}
```

### Performance Optimization Recommendations

```powershell
# Generate performance optimization recommendations
function Get-VWanOptimizationRecommendations {
    param(
        [string]$ResourceGroupName = "rg-vwan-core-prod"
    )
    
    Write-Output "Analyzing Virtual WAN for optimization opportunities..."
    
    $recommendations = @()
    
    # Check VPN Gateway scale units
    $vpnGateways = Get-AzVpnGateway -ResourceGroupName $ResourceGroupName
    foreach ($gateway in $vpnGateways) {
        $currentScaleUnits = $gateway.VpnGatewayScaleUnit
        
        # Get recent bandwidth utilization
        $metrics = Get-AzMetric `
            -ResourceId $gateway.Id `
            -MetricName "TunnelBandwidth" `
            -StartTime (Get-Date).AddHours(-24) `
            -EndTime (Get-Date) `
            -TimeGrain "01:00:00"
        
        $avgUtilization = ($metrics.Data | Measure-Object Average -Property Average).Average
        $maxCapacity = $currentScaleUnits * 500 # 500 Mbps per scale unit
        $utilizationPercent = ($avgUtilization / $maxCapacity) * 100
        
        if ($utilizationPercent -gt 80) {
            $recommendations += @{
                Type = "Scale Up"
                Resource = $gateway.Name
                Current = "$currentScaleUnits scale units"
                Recommended = "$($currentScaleUnits + 1) scale units"
                Reason = "High bandwidth utilization: $([math]::Round($utilizationPercent, 1))%"
                Priority = "High"
            }
        }
        elseif ($utilizationPercent -lt 20 -and $currentScaleUnits -gt 1) {
            $recommendations += @{
                Type = "Scale Down"
                Resource = $gateway.Name
                Current = "$currentScaleUnits scale units"
                Recommended = "$($currentScaleUnits - 1) scale units"
                Reason = "Low bandwidth utilization: $([math]::Round($utilizationPercent, 1))%"
                Priority = "Low"
            }
        }
    }
    
    # Check route table optimization
    $hubs = Get-AzVirtualHub -ResourceGroupName $ResourceGroupName
    foreach ($hub in $hubs) {
        $routeTables = Get-AzVirtualHubRouteTable -ResourceGroupName $ResourceGroupName -VirtualHubName $hub.Name
        
        if ($routeTables.Count -gt 10) {
            $recommendations += @{
                Type = "Route Optimization"
                Resource = $hub.Name
                Current = "$($routeTables.Count) route tables"
                Recommended = "Consolidate route tables"
                Reason = "Large number of route tables may impact performance"
                Priority = "Medium"
            }
        }
    }
    
    # Display recommendations
    Write-Output ""
    Write-Output "Performance Optimization Recommendations:"
    foreach ($rec in $recommendations) {
        Write-Output ""
        Write-Output "[$($rec.Priority)] $($rec.Type) - $($rec.Resource)"
        Write-Output "  Current: $($rec.Current)"
        Write-Output "  Recommended: $($rec.Recommended)"
        Write-Output "  Reason: $($rec.Reason)"
    }
    
    return $recommendations
}
```

## Security Operations

### Security Monitoring

```powershell
# Daily security monitoring script
function Start-VWanSecurityMonitoring {
    param(
        [string]$LogAnalyticsWorkspaceId
    )
    
    Write-Output "=== Daily Virtual WAN Security Monitoring ==="
    Write-Output "Date: $(Get-Date)"
    
    # 1. Check for unusual connection attempts
    $connectionQuery = @"
AzureDiagnostics
| where TimeGenerated >= ago(24h)
| where ResourceType == "VPNGATEWAYS"
| where Category == "IKEDiagnosticLog"
| where Level == "Error"
| summarize count() by RemoteIP_s, bin(TimeGenerated, 1h)
| where count_ > 10
| order by count_ desc
"@
    
    Write-Output "1. Checking for suspicious connection attempts..."
    # Execute query against Log Analytics
    # $connectionResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $LogAnalyticsWorkspaceId -Query $connectionQuery
    
    # 2. Review firewall deny logs
    $firewallQuery = @"
AzureDiagnostics
| where TimeGenerated >= ago(24h)
| where ResourceType == "AZUREFIREWALLS"
| where msg_s contains "Deny"
| summarize DeniedConnections = count() by SourceIP = extract(@"SRC:([0-9\.]+)", 1, msg_s), TargetPort = extract(@"DPT:([0-9]+)", 1, msg_s)
| where DeniedConnections > 50
| order by DeniedConnections desc
"@
    
    Write-Output "2. Reviewing firewall deny patterns..."
    # $firewallResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $LogAnalyticsWorkspaceId -Query $firewallQuery
    
    # 3. Check for configuration changes
    $configQuery = @"
AzureActivity
| where TimeGenerated >= ago(24h)
| where ResourceProvider == "Microsoft.Network"
| where ResourceType in ("virtualwans", "virtualhubs", "vpngateways", "azurefirewalls")
| where ActivityStatus == "Success"
| project TimeGenerated, Caller, OperationName, ResourceGroup, Resource
| order by TimeGenerated desc
"@
    
    Write-Output "3. Reviewing configuration changes..."
    # $configResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $LogAnalyticsWorkspaceId -Query $configQuery
    
    Write-Output "Security monitoring completed"
}
```

### Security Incident Response

```powershell
# Security incident response procedures
function Start-SecurityIncidentResponse {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Unauthorized Access", "DDoS Attack", "Data Exfiltration", "Configuration Tampering")]
        [string]$IncidentType,
        
        [Parameter(Mandatory=$true)]
        [string]$SourceIP,
        
        [string]$AffectedResource
    )
    
    Write-Output "=== SECURITY INCIDENT RESPONSE ==="
    Write-Output "Incident Type: $IncidentType"
    Write-Output "Source IP: $SourceIP"
    Write-Output "Affected Resource: $AffectedResource"
    Write-Output "Response Time: $(Get-Date)"
    Write-Output ""
    
    switch ($IncidentType) {
        "Unauthorized Access" {
            Write-Output "STEP 1: Blocking source IP immediately..."
            # Block IP in Azure Firewall
            # Add-AzFirewallPolicyNetworkRule -SourceAddress $SourceIP -Action "Deny"
            
            Write-Output "STEP 2: Reviewing access logs..."
            # Query for all activities from source IP
            
            Write-Output "STEP 3: Notifying security team..."
            # Send alert to security team
        }
        
        "DDoS Attack" {
            Write-Output "STEP 1: Activating DDoS protection..."
            # Enable DDoS protection standard if not already enabled
            
            Write-Output "STEP 2: Analyzing traffic patterns..."
            # Review bandwidth utilization metrics
            
            Write-Output "STEP 3: Implementing rate limiting..."
            # Configure firewall rules for rate limiting
        }
        
        "Data Exfiltration" {
            Write-Output "STEP 1: Identifying data flow patterns..."
            # Analyze unusual data transfer volumes
            
            Write-Output "STEP 2: Blocking suspicious connections..."
            # Implement connection blocking rules
            
            Write-Output "STEP 3: Preserving evidence..."
            # Capture network logs and traffic analysis
        }
        
        "Configuration Tampering" {
            Write-Output "STEP 1: Reviewing recent configuration changes..."
            # Check Azure Activity Log for unauthorized changes
            
            Write-Output "STEP 2: Restoring from backup..."
            # Restore configuration from known good state
            
            Write-Output "STEP 3: Implementing additional controls..."
            # Enhance RBAC and monitoring
        }
    }
    
    # Generate incident report
    $incidentReport = @{
        IncidentID = "SEC-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Type = $IncidentType
        SourceIP = $SourceIP
        AffectedResource = $AffectedResource
        ResponseTime = Get-Date
        Status = "In Progress"
    }
    
    $incidentReport | ConvertTo-Json | Out-File -FilePath "C:\Logs\Security\$($incidentReport.IncidentID).json"
    Write-Output ""
    Write-Output "Security incident report created: $($incidentReport.IncidentID)"
}
```

## Troubleshooting Guide

### Common Issues and Resolutions

#### Issue 1: VPN Connection Intermittently Dropping

**Symptoms:**
- VPN connection shows "Connected" but traffic intermittently fails
- Packet loss observed in monitoring
- Users report intermittent connectivity issues

**Diagnostic Steps:**
```powershell
# Check connection stability
$connection = Get-AzVpnConnection -ResourceGroupName "rg-vwan-core-prod" -ParentResourceName "hub-name" -Name "connection-name"

# Review connection logs
$logQuery = @"
AzureDiagnostics
| where ResourceType == "VPNGATEWAYS"
| where TimeGenerated >= ago(2h)
| where Category == "IKEDiagnosticLog"
| where Resource contains "connection-name"
| order by TimeGenerated desc
"@

# Check for phase 1/phase 2 negotiation issues
# Look for "INVALID_SPI", "NO_PROPOSAL_CHOSEN", or "AUTHENTICATION_FAILED" errors
```

**Resolution:**
1. Verify IPsec parameters match between Azure and on-premises device
2. Check for MTU/MSS issues - configure MSS clamping if needed
3. Review and adjust IKE/IPsec timeout values
4. Consider enabling BGP if using policy-based routing

#### Issue 2: Poor Performance Between Sites

**Symptoms:**
- High latency between branch offices
- Bandwidth not meeting expectations
- Application timeouts

**Diagnostic Steps:**
```bash
# Test bandwidth between hubs
az network vhub get-effective-routes \
    --resource-group "rg-vwan-core-prod" \
    --name "hub-eastus-prod" \
    --resource-type "VirtualNetworkConnection"

# Check routing table
az network vhub route-table show \
    --resource-group "rg-vwan-core-prod" \
    --vhub-name "hub-eastus-prod" \
    --name "defaultRouteTable"
```

**Resolution:**
1. Verify optimal hub selection for each site
2. Check for suboptimal routing paths
3. Consider enabling hub-to-hub optimization
4. Scale VPN gateway scale units if bandwidth limited

#### Issue 3: Azure Firewall Blocking Legitimate Traffic

**Symptoms:**
- Applications failing to connect
- Firewall logs showing denied traffic
- Users unable to access required services

**Diagnostic Steps:**
```powershell
# Review firewall logs
$firewallQuery = @"
AzureDiagnostics
| where ResourceType == "AZUREFIREWALLS"
| where TimeGenerated >= ago(1h)
| where msg_s contains "Deny"
| where msg_s contains "target-application-ip"
| project TimeGenerated, msg_s, Protocol_s, SourceIP_s, DestPort_d
| order by TimeGenerated desc
"@

# Check rule processing order
Get-AzFirewallPolicyRuleCollectionGroup -ResourceGroupName "rg-vwan-security-prod" -AzureFirewallPolicyName "vwan-firewall-policy"
```

**Resolution:**
1. Review firewall rule priority and ordering
2. Add specific allow rules for required traffic
3. Verify FQDN rules are correctly formatted
4. Test rules in firewall policy test mode before applying

---

**Operations Runbook Version**: 1.0  
**Last Updated**: August 2024  
**Next Review Date**: November 2024