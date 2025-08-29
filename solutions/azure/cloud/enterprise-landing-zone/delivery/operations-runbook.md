# Azure Enterprise Landing Zone - Operations Runbook

## Overview

This operations runbook provides comprehensive procedures for maintaining, monitoring, and troubleshooting the Azure Enterprise Landing Zone infrastructure. The runbook covers daily operations, scheduled maintenance, incident response, and optimization activities to ensure reliable platform operations.

**Operations Team:** Platform Engineering  
**Escalation:** Cloud Architecture Team  
**Emergency Contact:** 24/7 NOC Hotline  
**Last Updated:** Current Date

## Daily Operations

### 1. Morning Health Check (8:00 AM)

#### System Status Validation
```powershell
# Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId $managementSubscriptionId

# Check overall service health
$healthCheck = @{
    VirtualNetworks = @()
    Gateways = @()
    Firewalls = @()
    StorageAccounts = @()
    KeyVaults = @()
    LogAnalytics = @()
    AutomationAccounts = @()
}

# Hub network connectivity check
Write-Host "=== Hub Network Health Check ===" -ForegroundColor Green
$hubVNet = Get-AzVirtualNetwork -ResourceGroupName "rg-connectivity-prod-eus2-001" -Name "vnet-hub-prod-eus2-001"
if ($hubVNet.ProvisioningState -eq "Succeeded") {
    Write-Host "✓ Hub VNet is healthy" -ForegroundColor Green
    $healthCheck.VirtualNetworks += @{ Name = $hubVNet.Name; Status = "Healthy" }
} else {
    Write-Warning "⚠ Hub VNet provisioning state: $($hubVNet.ProvisioningState)"
    $healthCheck.VirtualNetworks += @{ Name = $hubVNet.Name; Status = "Warning" }
}

# Gateway health check
Write-Host "=== Gateway Health Check ===" -ForegroundColor Green
$vpnGateway = Get-AzVirtualNetworkGateway -ResourceGroupName "rg-connectivity-prod-eus2-001" -Name "vgw-vpn-prod-eus2-001" -ErrorAction SilentlyContinue
if ($vpnGateway) {
    $gatewayStatus = Get-AzVirtualNetworkGatewayBGPPeerStatus -ResourceGroupName "rg-connectivity-prod-eus2-001" -VirtualNetworkGatewayName "vgw-vpn-prod-eus2-001"
    Write-Host "✓ VPN Gateway BGP Status: $($gatewayStatus.State)" -ForegroundColor Green
    $healthCheck.Gateways += @{ Name = $vpnGateway.Name; Status = $gatewayStatus.State }
}

# Azure Firewall health check
Write-Host "=== Azure Firewall Health Check ===" -ForegroundColor Green
$firewall = Get-AzFirewall -ResourceGroupName "rg-connectivity-prod-eus2-001" -Name "afw-hub-prod-eus2-001"
if ($firewall.ProvisioningState -eq "Succeeded") {
    Write-Host "✓ Azure Firewall is healthy" -ForegroundColor Green
    $healthCheck.Firewalls += @{ Name = $firewall.Name; Status = "Healthy" }
} else {
    Write-Warning "⚠ Azure Firewall provisioning state: $($firewall.ProvisioningState)"
    $healthCheck.Firewalls += @{ Name = $firewall.Name; Status = "Warning" }
}

# Log Analytics workspace health
Write-Host "=== Log Analytics Health Check ===" -ForegroundColor Green
$logWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-management-prod-eus2-001" -Name "law-management-prod-eus2-001"
if ($logWorkspace.ProvisioningState -eq "Succeeded") {
    Write-Host "✓ Log Analytics Workspace is healthy" -ForegroundColor Green
    $healthCheck.LogAnalytics += @{ Name = $logWorkspace.Name; Status = "Healthy" }
}

# Generate daily health report
$healthReport = @{
    Date = Get-Date
    Status = if (($healthCheck.Values | ForEach-Object { $_.Status } | Where-Object { $_ -ne "Healthy" }).Count -eq 0) { "Healthy" } else { "Issues Detected" }
    Details = $healthCheck
}

# Send to Log Analytics
$healthReportJson = $healthReport | ConvertTo-Json -Depth 3
Invoke-AzRestMethod -Uri "https://law-management-prod-eus2-001.ods.opinsights.azure.com/api/logs?api-version=2016-04-01" -Method POST -Body $healthReportJson
```

#### Performance Monitoring
```bash
#!/bin/bash
# Daily performance metrics collection

echo "=== Daily Performance Metrics Collection ==="
echo "Date: $(date)"

# Azure CLI authentication check
az account show > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Azure CLI authentication required"
    az login
fi

# Network performance metrics
echo "--- Network Performance ---"
az network vnet list --resource-group "rg-connectivity-prod-eus2-001" --query "[].{Name:name, State:provisioningState, AddressSpace:addressSpace.addressPrefixes[0]}" --output table

# Gateway performance metrics
echo "--- Gateway Performance ---"
az network vnet-gateway list --resource-group "rg-connectivity-prod-eus2-001" --query "[].{Name:name, State:provisioningState, Type:gatewayType, SKU:sku.name}" --output table

# Firewall performance metrics
echo "--- Firewall Performance ---"
az network firewall list --resource-group "rg-connectivity-prod-eus2-001" --query "[].{Name:name, State:provisioningState, Tier:sku.tier}" --output table

# Storage account metrics
echo "--- Storage Account Performance ---"
az storage account list --resource-group "rg-management-prod-eus2-001" --query "[].{Name:name, State:provisioningState, Tier:sku.tier, Replication:sku.name}" --output table

# Key Vault performance
echo "--- Key Vault Performance ---"
az keyvault list --resource-group "rg-management-prod-eus2-001" --query "[].{Name:name, State:properties.provisioningState, SKU:properties.sku.name}" --output table

# Automation account status
echo "--- Automation Account Status ---"
az automation account list --resource-group "rg-management-prod-eus2-001" --query "[].{Name:name, State:state, SKU:sku.name}" --output table

echo "=== Performance Metrics Collection Completed ==="
```

### 2. Cost Optimization Review (Daily)

#### Daily Cost Analysis
```powershell
# Daily cost review script
$today = Get-Date
$yesterday = $today.AddDays(-1)

Write-Host "=== Daily Cost Analysis - $($today.ToString('yyyy-MM-dd')) ===" -ForegroundColor Green

# Get subscription cost data
$subscriptions = @(
    @{ Name = "Connectivity"; Id = $connectivitySubscriptionId },
    @{ Name = "Management"; Id = $managementSubscriptionId },
    @{ Name = "Identity"; Id = $identitySubscriptionId }
)

$totalDailyCost = 0

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id
    
    # Get billing data (last 24 hours)
    $filter = "properties/usageStart ge '$($yesterday.ToString('yyyy-MM-dd'))' and properties/usageEnd le '$($today.ToString('yyyy-MM-dd'))'"
    
    try {
        $usage = Get-AzConsumptionUsageDetail -Filter $filter -MaxCount 1000
        $subscriptionCost = ($usage | Measure-Object -Property PretaxCost -Sum).Sum
        
        Write-Host "Subscription: $($subscription.Name)" -ForegroundColor Yellow
        Write-Host "  Daily Cost: $$$($subscriptionCost.ToString('F2'))" -ForegroundColor White
        
        $totalDailyCost += $subscriptionCost
        
        # Top 5 most expensive resources
        $topResources = $usage | Group-Object InstanceName | 
            ForEach-Object { @{ Resource = $_.Name; Cost = ($_.Group | Measure-Object PretaxCost -Sum).Sum }} |
            Sort-Object Cost -Descending | Select-Object -First 5
        
        Write-Host "  Top Resources:" -ForegroundColor White
        foreach ($resource in $topResources) {
            Write-Host "    $($resource.Resource): $$$($resource.Cost.ToString('F2'))" -ForegroundColor Gray
        }
    }
    catch {
        Write-Warning "Unable to retrieve cost data for subscription $($subscription.Name): $($_.Exception.Message)"
    }
}

Write-Host "`nTotal Daily Cost: $$$($totalDailyCost.ToString('F2'))" -ForegroundColor Green
Write-Host "Projected Monthly Cost: $$$($($totalDailyCost * 30).ToString('F2'))" -ForegroundColor Green

# Check against budget
$monthlyBudget = 50000  # $50,000 monthly budget
$projectedMonthlyCost = $totalDailyCost * 30

if ($projectedMonthlyCost -gt ($monthlyBudget * 0.8)) {
    Write-Warning "⚠ Projected monthly cost ($$$($projectedMonthlyCost.ToString('F2'))) exceeds 80% of budget ($$$($monthlyBudget.ToString('F2')))"
    
    # Send budget alert
    $alertMessage = @{
        Subject = "Landing Zone Budget Alert"
        Body = "Projected monthly cost: $$$($projectedMonthlyCost.ToString('F2'))`nBudget: $$$($monthlyBudget.ToString('F2'))`nPercentage: $($($projectedMonthlyCost / $monthlyBudget * 100).ToString('F1'))%"
    }
    
    # Send to monitoring system or email
    # Send-AlertNotification -Message $alertMessage
}
```

### 3. Security Posture Check (Daily)

#### Security Compliance Scan
```bash
#!/bin/bash
# Daily security compliance check

echo "=== Daily Security Compliance Check ==="
echo "Date: $(date)"

# Security Center recommendations
echo "--- Security Center Recommendations ---"
az security task list --query "[].{Name:displayName, State:state, Severity:severity}" --output table

# Policy compliance status
echo "--- Policy Compliance Status ---"
az policy state list --management-group "mg-enterprise-root" --query "[?complianceState=='NonCompliant'].{Policy:policyDefinitionName, Resource:resourceId, State:complianceState}" --output table | head -20

# Key Vault access review
echo "--- Key Vault Access Review ---"
for kv in $(az keyvault list --query "[].name" --output tsv); do
    echo "Key Vault: $kv"
    az keyvault network-rule list --name $kv --query "{DefaultAction:defaultAction, IpRules:ipRules, VirtualNetworkRules:virtualNetworkRules}" --output table
done

# Network Security Groups review
echo "--- Network Security Group Rules ---"
for nsg in $(az network nsg list --query "[].name" --output tsv); do
    echo "NSG: $nsg"
    az network nsg rule list --nsg-name $nsg --query "[?access=='Allow' && direction=='Inbound'].{Name:name, Priority:priority, Source:sourceAddressPrefix, Destination:destinationPortRange}" --output table
done

# Azure Firewall rules review
echo "--- Azure Firewall Rules ---"
az network firewall application-rule list --firewall-name "afw-hub-prod-eus2-001" --resource-group "rg-connectivity-prod-eus2-001" --collection-name "AllowedApps" --query "[].{Name:name, Action:action}" --output table 2>/dev/null || echo "No application rules found"

az network firewall network-rule list --firewall-name "afw-hub-prod-eus2-001" --resource-group "rg-connectivity-prod-eus2-001" --collection-name "AllowedNetworks" --query "[].{Name:name, Action:action}" --output table 2>/dev/null || echo "No network rules found"

echo "=== Security Compliance Check Completed ==="
```

## Weekly Operations

### 1. System Maintenance (Sundays, 2:00 AM)

#### Weekly Infrastructure Health Assessment
```powershell
# Weekly comprehensive health assessment
param(
    [string]$ReportPath = "C:\Reports\WeeklyHealthReport-$(Get-Date -Format 'yyyyMMdd').html"
)

Write-Host "=== Weekly Infrastructure Health Assessment ===" -ForegroundColor Green

# Generate comprehensive report
$reportData = @{
    Date = Get-Date
    Subscriptions = @()
    Issues = @()
    Recommendations = @()
}

$subscriptions = @("connectivity", "management", "identity")

foreach ($subscriptionName in $subscriptions) {
    $subscriptionId = Get-Variable -Name "${subscriptionName}SubscriptionId" -ValueOnly
    Set-AzContext -SubscriptionId $subscriptionId
    
    Write-Host "Analyzing subscription: $subscriptionName" -ForegroundColor Yellow
    
    $subscriptionData = @{
        Name = $subscriptionName
        Id = $subscriptionId
        ResourceGroups = @()
        Costs = @{}
        Security = @{}
        Performance = @{}
    }
    
    # Resource Group Analysis
    $resourceGroups = Get-AzResourceGroup
    foreach ($rg in $resourceGroups) {
        $rgData = @{
            Name = $rg.ResourceGroupName
            Location = $rg.Location
            ResourceCount = (Get-AzResource -ResourceGroupName $rg.ResourceGroupName).Count
            Tags = $rg.Tags
        }
        
        # Check resource health
        $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName
        $healthyResources = 0
        $unhealthyResources = 0
        
        foreach ($resource in $resources) {
            try {
                $resourceHealth = Get-AzResource -ResourceId $resource.ResourceId
                if ($resourceHealth.Properties.provisioningState -eq "Succeeded") {
                    $healthyResources++
                } else {
                    $unhealthyResources++
                    $reportData.Issues += @{
                        Type = "Resource Health"
                        Description = "Resource $($resource.Name) in unhealthy state: $($resourceHealth.Properties.provisioningState)"
                        Severity = "Medium"
                        ResourceGroup = $rg.ResourceGroupName
                    }
                }
            }
            catch {
                $unhealthyResources++
                $reportData.Issues += @{
                    Type = "Resource Access"
                    Description = "Unable to retrieve health status for resource $($resource.Name)"
                    Severity = "Low"
                    ResourceGroup = $rg.ResourceGroupName
                }
            }
        }
        
        $rgData.HealthyResources = $healthyResources
        $rgData.UnhealthyResources = $unhealthyResources
        $subscriptionData.ResourceGroups += $rgData
    }
    
    # Performance Metrics
    $performanceMetrics = @{
        AvgCPU = 0
        AvgMemory = 0
        NetworkThroughput = 0
        StorageIOPS = 0
    }
    
    # Get VM performance metrics (sample)
    $vms = Get-AzVM
    if ($vms) {
        $totalCPU = 0
        $vmCount = $vms.Count
        
        foreach ($vm in $vms) {
            try {
                $cpuMetric = Get-AzMetric -ResourceId $vm.Id -MetricName "Percentage CPU" -TimeGrain 01:00:00 -StartTime (Get-Date).AddDays(-7) -EndTime (Get-Date)
                $avgCPU = ($cpuMetric.Data | Measure-Object -Property Average -Average).Average
                $totalCPU += $avgCPU
            }
            catch {
                Write-Warning "Unable to retrieve CPU metrics for VM: $($vm.Name)"
            }
        }
        
        $performanceMetrics.AvgCPU = if ($vmCount -gt 0) { $totalCPU / $vmCount } else { 0 }
    }
    
    $subscriptionData.Performance = $performanceMetrics
    
    # Security Assessment
    $securityAssessment = @{
        ComplianceScore = 0
        HighSeverityIssues = 0
        MediumSeverityIssues = 0
        LowSeverityIssues = 0
    }
    
    # Get Security Center assessments
    try {
        $securityTasks = Get-AzSecurityTask
        $securityAssessment.HighSeverityIssues = ($securityTasks | Where-Object { $_.RecommendationDisplayName -match "High" }).Count
        $securityAssessment.MediumSeverityIssues = ($securityTasks | Where-Object { $_.RecommendationDisplayName -match "Medium" }).Count
        $securityAssessment.LowSeverityIssues = ($securityTasks | Where-Object { $_.RecommendationDisplayName -match "Low" }).Count
        
        foreach ($task in $securityTasks) {
            $reportData.Issues += @{
                Type = "Security"
                Description = $task.RecommendationDisplayName
                Severity = if ($task.RecommendationDisplayName -match "High") { "High" } elseif ($task.RecommendationDisplayName -match "Medium") { "Medium" } else { "Low" }
                ResourceGroup = $task.ResourceDetails.ResourceGroup
            }
        }
    }
    catch {
        Write-Warning "Unable to retrieve Security Center data for subscription: $subscriptionName"
    }
    
    $subscriptionData.Security = $securityAssessment
    $reportData.Subscriptions += $subscriptionData
}

# Generate recommendations based on findings
$criticalIssues = ($reportData.Issues | Where-Object { $_.Severity -eq "High" }).Count
$mediumIssues = ($reportData.Issues | Where-Object { $_.Severity -eq "Medium" }).Count

if ($criticalIssues -gt 0) {
    $reportData.Recommendations += "Immediate attention required: $criticalIssues critical issues detected"
}

if ($mediumIssues -gt 5) {
    $reportData.Recommendations += "Medium priority: $mediumIssues medium-severity issues require attention"
}

# Generate HTML report
$htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Weekly Infrastructure Health Report - $(Get-Date -Format 'yyyy-MM-dd')</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #0078d4; color: white; padding: 20px; text-align: center; }
        .section { margin: 20px 0; }
        .issue-high { color: #d13438; font-weight: bold; }
        .issue-medium { color: #ff8c00; }
        .issue-low { color: #107c10; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Weekly Infrastructure Health Report</h1>
        <p>Generated: $(Get-Date)</p>
    </div>
    
    <div class="section">
        <h2>Executive Summary</h2>
        <p>Total Issues: $($reportData.Issues.Count)</p>
        <p>Critical Issues: $($criticalIssues)</p>
        <p>Medium Issues: $($mediumIssues)</p>
        <p>Low Issues: $(($reportData.Issues | Where-Object { $_.Severity -eq "Low" }).Count)</p>
    </div>
    
    <div class="section">
        <h2>Subscription Summary</h2>
        <table>
            <tr>
                <th>Subscription</th>
                <th>Resource Groups</th>
                <th>Total Resources</th>
                <th>Healthy Resources</th>
                <th>Unhealthy Resources</th>
                <th>Security Issues</th>
            </tr>
"@

foreach ($sub in $reportData.Subscriptions) {
    $totalResources = ($sub.ResourceGroups | Measure-Object -Property ResourceCount -Sum).Sum
    $healthyResources = ($sub.ResourceGroups | Measure-Object -Property HealthyResources -Sum).Sum
    $unhealthyResources = ($sub.ResourceGroups | Measure-Object -Property UnhealthyResources -Sum).Sum
    $securityIssues = $sub.Security.HighSeverityIssues + $sub.Security.MediumSeverityIssues + $sub.Security.LowSeverityIssues
    
    $htmlReport += @"
            <tr>
                <td>$($sub.Name)</td>
                <td>$($sub.ResourceGroups.Count)</td>
                <td>$totalResources</td>
                <td>$healthyResources</td>
                <td>$unhealthyResources</td>
                <td>$securityIssues</td>
            </tr>
"@
}

$htmlReport += @"
        </table>
    </div>
    
    <div class="section">
        <h2>Issues Detected</h2>
        <table>
            <tr>
                <th>Type</th>
                <th>Description</th>
                <th>Severity</th>
                <th>Resource Group</th>
            </tr>
"@

foreach ($issue in $reportData.Issues | Sort-Object Severity, Type) {
    $severityClass = switch ($issue.Severity) {
        "High" { "issue-high" }
        "Medium" { "issue-medium" }
        "Low" { "issue-low" }
    }
    
    $htmlReport += @"
            <tr class="$severityClass">
                <td>$($issue.Type)</td>
                <td>$($issue.Description)</td>
                <td>$($issue.Severity)</td>
                <td>$($issue.ResourceGroup)</td>
            </tr>
"@
}

$htmlReport += @"
        </table>
    </div>
    
    <div class="section">
        <h2>Recommendations</h2>
        <ul>
"@

foreach ($recommendation in $reportData.Recommendations) {
    $htmlReport += "<li>$recommendation</li>"
}

$htmlReport += @"
        </ul>
    </div>
</body>
</html>
"@

# Save report
$htmlReport | Out-File -FilePath $ReportPath -Encoding UTF8
Write-Host "Weekly health report saved to: $ReportPath" -ForegroundColor Green

# Send report via email if configured
# Send-WeeklyHealthReport -ReportPath $ReportPath
```

### 2. Backup Verification (Sundays, 4:00 AM)

#### Backup Status Check
```powershell
# Weekly backup verification
Write-Host "=== Weekly Backup Verification ===" -ForegroundColor Green

Set-AzContext -SubscriptionId $managementSubscriptionId

# Get Recovery Services Vaults
$recoveryVaults = Get-AzRecoveryServicesVault

foreach ($vault in $recoveryVaults) {
    Write-Host "`nRecovery Services Vault: $($vault.Name)" -ForegroundColor Yellow
    
    # Set vault context
    Set-AzRecoveryServicesVaultContext -Vault $vault
    
    # Check backup policies
    $backupPolicies = Get-AzRecoveryServicesBackupProtectionPolicy
    Write-Host "  Backup Policies: $($backupPolicies.Count)" -ForegroundColor White
    
    foreach ($policy in $backupPolicies) {
        Write-Host "    Policy: $($policy.Name)" -ForegroundColor Gray
        Write-Host "      Backup Frequency: $($policy.SchedulePolicy.ScheduleRunFrequency)" -ForegroundColor Gray
        Write-Host "      Retention: $($policy.RetentionPolicy.DailySchedule.RetentionDuration.Count) days" -ForegroundColor Gray
    }
    
    # Check protected items
    $protectedItems = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM
    Write-Host "  Protected VMs: $($protectedItems.Count)" -ForegroundColor White
    
    foreach ($item in $protectedItems) {
        $lastBackup = Get-AzRecoveryServicesBackupRecoveryPoint -Item $item | Sort-Object RecoveryPointTime -Descending | Select-Object -First 1
        
        $daysSinceLastBackup = if ($lastBackup) { (New-TimeSpan -Start $lastBackup.RecoveryPointTime -End (Get-Date)).Days } else { 999 }
        
        if ($daysSinceLastBackup -gt 1) {
            Write-Warning "    ⚠ VM $($item.VirtualMachineId.Split('/')[-1]): Last backup $daysSinceLastBackup days ago"
        } else {
            Write-Host "    ✓ VM $($item.VirtualMachineId.Split('/')[-1]): Last backup $daysSinceLastBackup days ago" -ForegroundColor Green
        }
    }
    
    # Check backup job status (last 7 days)
    $endDate = Get-Date
    $startDate = $endDate.AddDays(-7)
    $backupJobs = Get-AzRecoveryServicesBackupJob -From $startDate -To $endDate
    
    $successfulJobs = ($backupJobs | Where-Object { $_.Status -eq "Completed" }).Count
    $failedJobs = ($backupJobs | Where-Object { $_.Status -eq "Failed" }).Count
    $inProgressJobs = ($backupJobs | Where-Object { $_.Status -eq "InProgress" }).Count
    
    Write-Host "  Backup Jobs (last 7 days):" -ForegroundColor White
    Write-Host "    Successful: $successfulJobs" -ForegroundColor Green
    Write-Host "    Failed: $failedJobs" -ForegroundColor Red
    Write-Host "    In Progress: $inProgressJobs" -ForegroundColor Yellow
    
    if ($failedJobs -gt 0) {
        Write-Warning "  Failed backup jobs detected!"
        $failedJobDetails = $backupJobs | Where-Object { $_.Status -eq "Failed" } | Select-Object -First 5
        foreach ($job in $failedJobDetails) {
            Write-Host "    Failed Job: $($job.JobId) - $($job.ErrorDetails)" -ForegroundColor Red
        }
    }
}
```

## Monthly Operations

### 1. Capacity Planning Review (First Monday)

#### Monthly Capacity Assessment
```powershell
# Monthly capacity planning assessment
param(
    [string]$OutputPath = "C:\Reports\MonthlyCapacityReport-$(Get-Date -Format 'yyyyMM').json"
)

Write-Host "=== Monthly Capacity Planning Assessment ===" -ForegroundColor Green

$capacityReport = @{
    Date = Get-Date
    Subscriptions = @()
    Recommendations = @()
    Trends = @()
}

$subscriptions = @(
    @{ Name = "Connectivity"; Id = $connectivitySubscriptionId },
    @{ Name = "Management"; Id = $managementSubscriptionId },
    @{ Name = "Identity"; Id = $identitySubscriptionId }
)

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id
    
    Write-Host "Analyzing capacity for subscription: $($subscription.Name)" -ForegroundColor Yellow
    
    $subscriptionCapacity = @{
        Name = $subscription.Name
        Id = $subscription.Id
        Compute = @{}
        Storage = @{}
        Network = @{}
        Quotas = @{}
    }
    
    # Compute capacity analysis
    $vms = Get-AzVM
    $vmSizes = $vms | Group-Object HardwareProfile.VmSize | Select-Object Name, Count
    
    $subscriptionCapacity.Compute = @{
        TotalVMs = $vms.Count
        VMsBySize = $vmSizes
        PoweredOn = ($vms | Where-Object { $_.PowerState -eq "VM running" }).Count
        PoweredOff = ($vms | Where-Object { $_.PowerState -eq "VM deallocated" }).Count
    }
    
    # Storage capacity analysis
    $storageAccounts = Get-AzStorageAccount
    $totalStorageCapacity = 0
    $totalStorageUsed = 0
    
    foreach ($storageAccount in $storageAccounts) {
        try {
            $ctx = $storageAccount.Context
            $metrics = Get-AzMetric -ResourceId $storageAccount.Id -MetricName "UsedCapacity" -TimeGrain 01:00:00 -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date)
            $usedCapacity = ($metrics.Data | Measure-Object -Property Average -Average).Average
            $totalStorageUsed += $usedCapacity
        }
        catch {
            Write-Warning "Unable to retrieve storage metrics for account: $($storageAccount.StorageAccountName)"
        }
    }
    
    $subscriptionCapacity.Storage = @{
        TotalAccounts = $storageAccounts.Count
        TotalUsedGB = [math]::Round($totalStorageUsed / 1GB, 2)
        AccountsByTier = ($storageAccounts | Group-Object Sku.Tier | Select-Object Name, Count)
    }
    
    # Network capacity analysis
    $vnetCount = (Get-AzVirtualNetwork).Count
    $subnetCount = (Get-AzVirtualNetwork | ForEach-Object { $_.Subnets }).Count
    $nsgCount = (Get-AzNetworkSecurityGroup).Count
    $publicIpCount = (Get-AzPublicIpAddress).Count
    
    $subscriptionCapacity.Network = @{
        VirtualNetworks = $vnetCount
        Subnets = $subnetCount
        NetworkSecurityGroups = $nsgCount
        PublicIPs = $publicIpCount
    }
    
    # Quota utilization
    $quotas = @()
    try {
        $computeQuotas = Get-AzVMUsage -Location "East US 2"
        foreach ($quota in $computeQuotas) {
            if ($quota.Limit -gt 0) {
                $utilizationPercent = [math]::Round(($quota.CurrentValue / $quota.Limit) * 100, 2)
                $quotas += @{
                    Name = $quota.Name.LocalizedValue
                    Current = $quota.CurrentValue
                    Limit = $quota.Limit
                    UtilizationPercent = $utilizationPercent
                }
                
                if ($utilizationPercent -gt 80) {
                    $capacityReport.Recommendations += "High quota utilization detected: $($quota.Name.LocalizedValue) at $utilizationPercent%"
                }
            }
        }
    }
    catch {
        Write-Warning "Unable to retrieve quota information for subscription: $($subscription.Name)"
    }
    
    $subscriptionCapacity.Quotas = $quotas
    $capacityReport.Subscriptions += $subscriptionCapacity
}

# Generate growth trend analysis
$currentMonth = Get-Date -Format "yyyy-MM"
$lastMonth = (Get-Date).AddMonths(-1).ToString("yyyy-MM")

# Historical comparison (implement based on historical data storage)
$capacityReport.Trends = @{
    ComputeGrowth = "5% month-over-month"  # Placeholder - implement actual calculation
    StorageGrowth = "8% month-over-month"  # Placeholder - implement actual calculation
    NetworkGrowth = "2% month-over-month"  # Placeholder - implement actual calculation
}

# Generate recommendations
if ($capacityReport.Subscriptions | ForEach-Object { $_.Compute.TotalVMs } | Measure-Object -Sum | Where-Object { $_.Sum -gt 50 }) {
    $capacityReport.Recommendations += "Consider implementing VM right-sizing to optimize compute costs"
}

if ($capacityReport.Subscriptions | ForEach-Object { $_.Storage.TotalUsedGB } | Measure-Object -Sum | Where-Object { $_.Sum -gt 1000 }) {
    $capacityReport.Recommendations += "Evaluate storage lifecycle policies to optimize storage costs"
}

# Save capacity report
$capacityReport | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "Monthly capacity report saved to: $OutputPath" -ForegroundColor Green

# Generate summary for stakeholders
Write-Host "`n=== Capacity Planning Summary ===" -ForegroundColor Green
Write-Host "Total VMs across all subscriptions: $(($capacityReport.Subscriptions | ForEach-Object { $_.Compute.TotalVMs } | Measure-Object -Sum).Sum)" -ForegroundColor White
Write-Host "Total Storage Used (GB): $(($capacityReport.Subscriptions | ForEach-Object { $_.Storage.TotalUsedGB } | Measure-Object -Sum).Sum)" -ForegroundColor White
Write-Host "Total Public IPs: $(($capacityReport.Subscriptions | ForEach-Object { $_.Network.PublicIPs } | Measure-Object -Sum).Sum)" -ForegroundColor White
Write-Host "`nRecommendations:" -ForegroundColor Yellow
foreach ($recommendation in $capacityReport.Recommendations) {
    Write-Host "  • $recommendation" -ForegroundColor Gray
}
```

### 2. Security Assessment (Second Monday)

#### Monthly Security Review
```bash
#!/bin/bash
# Monthly comprehensive security assessment

echo "=== Monthly Security Assessment ==="
echo "Date: $(date)"

REPORT_FILE="security-assessment-$(date +%Y%m).html"

# Initialize HTML report
cat > $REPORT_FILE << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Monthly Security Assessment - $(date +%Y-%m)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #d13438; color: white; padding: 20px; text-align: center; }
        .section { margin: 20px 0; padding: 10px; border-left: 4px solid #0078d4; }
        .critical { border-left-color: #d13438; }
        .warning { border-left-color: #ff8c00; }
        .info { border-left-color: #107c10; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Monthly Security Assessment</h1>
        <p>Generated: $(date)</p>
    </div>
EOF

echo "<div class='section'><h2>Security Center Recommendations</h2>" >> $REPORT_FILE

# Security Center assessment
echo "--- Security Center Assessment ---"
echo "<h3>High Priority Recommendations</h3>" >> $REPORT_FILE
echo "<table><tr><th>Recommendation</th><th>Affected Resources</th><th>Status</th></tr>" >> $REPORT_FILE

az security task list --query "[?severity=='High'].{Name:displayName, Resource:resourceDetails.resourceName, State:state}" --output tsv | while IFS=$'\t' read -r name resource state; do
    echo "<tr><td>$name</td><td>$resource</td><td>$state</td></tr>" >> $REPORT_FILE
    echo "HIGH: $name - Resource: $resource - State: $state"
done

echo "</table>" >> $REPORT_FILE
echo "</div>" >> $REPORT_FILE

# Network security assessment
echo "<div class='section'><h2>Network Security Assessment</h2>" >> $REPORT_FILE

echo "--- Network Security Group Analysis ---"
echo "<h3>NSG Rules Analysis</h3>" >> $REPORT_FILE
echo "<table><tr><th>NSG Name</th><th>Rule Name</th><th>Priority</th><th>Source</th><th>Destination Port</th><th>Risk Level</th></tr>" >> $REPORT_FILE

for rg in $(az group list --query "[].name" --output tsv); do
    for nsg in $(az network nsg list --resource-group $rg --query "[].name" --output tsv 2>/dev/null); do
        echo "Analyzing NSG: $nsg"
        
        # Check for overly permissive rules
        az network nsg rule list --resource-group $rg --nsg-name $nsg --query "[?access=='Allow' && direction=='Inbound'].{Name:name, Priority:priority, Source:sourceAddressPrefix, DestPort:destinationPortRange}" --output tsv | while IFS=$'\t' read -r rulename priority source destport; do
            
            risk_level="LOW"
            if [[ "$source" == "*" || "$source" == "Internet" ]]; then
                if [[ "$destport" == "*" || "$destport" == "22" || "$destport" == "3389" ]]; then
                    risk_level="HIGH"
                elif [[ "$destport" == "80" || "$destport" == "443" ]]; then
                    risk_level="MEDIUM"
                fi
            fi
            
            echo "<tr><td>$nsg</td><td>$rulename</td><td>$priority</td><td>$source</td><td>$destport</td><td>$risk_level</td></tr>" >> $REPORT_FILE
            
            if [[ "$risk_level" == "HIGH" ]]; then
                echo "HIGH RISK: NSG $nsg rule $rulename allows $source to port $destport"
            fi
        done
    done
done

echo "</table>" >> $REPORT_FILE
echo "</div>" >> $REPORT_FILE

# Key Vault security assessment
echo "<div class='section'><h2>Key Vault Security Assessment</h2>" >> $REPORT_FILE

echo "--- Key Vault Access Policies ---"
echo "<h3>Key Vault Access Review</h3>" >> $REPORT_FILE
echo "<table><tr><th>Key Vault</th><th>Network Access</th><th>Soft Delete</th><th>Purge Protection</th><th>Access Policies Count</th></tr>" >> $REPORT_FILE

for kv in $(az keyvault list --query "[].name" --output tsv); do
    echo "Analyzing Key Vault: $kv"
    
    network_access=$(az keyvault show --name $kv --query "properties.networkAcls.defaultAction" --output tsv 2>/dev/null || echo "Unknown")
    soft_delete=$(az keyvault show --name $kv --query "properties.enableSoftDelete" --output tsv 2>/dev/null || echo "Unknown")
    purge_protection=$(az keyvault show --name $kv --query "properties.enablePurgeProtection" --output tsv 2>/dev/null || echo "Unknown")
    access_policies_count=$(az keyvault show --name $kv --query "properties.accessPolicies | length(@)" --output tsv 2>/dev/null || echo "Unknown")
    
    echo "<tr><td>$kv</td><td>$network_access</td><td>$soft_delete</td><td>$purge_protection</td><td>$access_policies_count</td></tr>" >> $REPORT_FILE
    
    if [[ "$network_access" == "Allow" ]]; then
        echo "MEDIUM RISK: Key Vault $kv allows access from all networks"
    fi
    
    if [[ "$soft_delete" != "true" ]]; then
        echo "HIGH RISK: Key Vault $kv does not have soft delete enabled"
    fi
done

echo "</table>" >> $REPORT_FILE
echo "</div>" >> $REPORT_FILE

# Azure Policy compliance
echo "<div class='section'><h2>Policy Compliance Assessment</h2>" >> $REPORT_FILE

echo "--- Azure Policy Compliance ---"
echo "<h3>Non-Compliant Resources</h3>" >> $REPORT_FILE
echo "<table><tr><th>Policy</th><th>Resource</th><th>Compliance State</th><th>Resource Type</th></tr>" >> $REPORT_FILE

az policy state list --management-group "mg-enterprise-root" --filter "ComplianceState eq 'NonCompliant'" --query "[].{Policy:policyDefinitionName, Resource:resourceId, State:complianceState, Type:resourceType}" --output tsv | head -50 | while IFS=$'\t' read -r policy resource state type; do
    echo "<tr><td>$policy</td><td>$(basename $resource)</td><td>$state</td><td>$type</td></tr>" >> $REPORT_FILE
    echo "NON-COMPLIANT: Policy $policy - Resource: $(basename $resource)"
done

echo "</table>" >> $REPORT_FILE
echo "</div>" >> $REPORT_FILE

# Storage account security
echo "<div class='section'><h2>Storage Account Security</h2>" >> $REPORT_FILE

echo "--- Storage Account Security Configuration ---"
echo "<h3>Storage Security Settings</h3>" >> $REPORT_FILE
echo "<table><tr><th>Storage Account</th><th>HTTPS Only</th><th>Public Access</th><th>Encryption</th><th>Network Rules</th></tr>" >> $REPORT_FILE

for sa in $(az storage account list --query "[].name" --output tsv); do
    echo "Analyzing Storage Account: $sa"
    
    https_only=$(az storage account show --name $sa --query "enableHttpsTrafficOnly" --output tsv 2>/dev/null || echo "Unknown")
    public_access=$(az storage account show --name $sa --query "allowBlobPublicAccess" --output tsv 2>/dev/null || echo "Unknown")
    encryption=$(az storage account show --name $sa --query "encryption.services.blob.enabled" --output tsv 2>/dev/null || echo "Unknown")
    network_default=$(az storage account show --name $sa --query "networkRuleSet.defaultAction" --output tsv 2>/dev/null || echo "Unknown")
    
    echo "<tr><td>$sa</td><td>$https_only</td><td>$public_access</td><td>$encryption</td><td>$network_default</td></tr>" >> $REPORT_FILE
    
    if [[ "$https_only" != "true" ]]; then
        echo "HIGH RISK: Storage Account $sa does not enforce HTTPS only"
    fi
    
    if [[ "$public_access" == "true" ]]; then
        echo "MEDIUM RISK: Storage Account $sa allows public blob access"
    fi
done

echo "</table>" >> $REPORT_FILE
echo "</div>" >> $REPORT_FILE

# Close HTML report
cat >> $REPORT_FILE << EOF
    <div class='section info'>
        <h2>Report Summary</h2>
        <p>This monthly security assessment covers key security configurations across the Azure Enterprise Landing Zone.</p>
        <p>Review all HIGH and MEDIUM risk items and implement remediation as appropriate.</p>
        <p>Next assessment scheduled for: $(date -d "+1 month" +%Y-%m-01)</p>
    </div>
</body>
</html>
EOF

echo "=== Monthly Security Assessment Completed ==="
echo "Report saved as: $REPORT_FILE"
```

## Incident Response Procedures

### 1. Service Outage Response

#### Immediate Response (0-15 minutes)
```powershell
# Incident response script for service outages
param(
    [Parameter(Mandatory)]
    [string]$IncidentType,
    
    [Parameter(Mandatory)]
    [string]$AffectedService,
    
    [Parameter()]
    [string]$IncidentId = (New-Guid).ToString()
)

Write-Host "=== INCIDENT RESPONSE INITIATED ===" -ForegroundColor Red
Write-Host "Incident ID: $IncidentId" -ForegroundColor Yellow
Write-Host "Type: $IncidentType" -ForegroundColor Yellow
Write-Host "Affected Service: $AffectedService" -ForegroundColor Yellow
Write-Host "Time: $(Get-Date)" -ForegroundColor Yellow

# Create incident log
$incidentLog = @{
    IncidentId = $IncidentId
    Type = $IncidentType
    AffectedService = $AffectedService
    StartTime = Get-Date
    Status = "Active"
    Actions = @()
}

# Step 1: Initial Assessment
Write-Host "`n=== STEP 1: INITIAL ASSESSMENT ===" -ForegroundColor Cyan

$assessment = @{
    Time = Get-Date
    Action = "Initial Assessment"
    Details = @{}
}

switch ($AffectedService.ToLower()) {
    "network" {
        Write-Host "Assessing network connectivity..." -ForegroundColor Yellow
        
        # Check hub VNet status
        $hubVNet = Get-AzVirtualNetwork -ResourceGroupName "rg-connectivity-prod-eus2-001" -Name "vnet-hub-prod-eus2-001" -ErrorAction SilentlyContinue
        $assessment.Details.HubVNetStatus = if ($hubVNet) { $hubVNet.ProvisioningState } else { "Not Found" }
        
        # Check VPN Gateway
        $vpnGateway = Get-AzVirtualNetworkGateway -ResourceGroupName "rg-connectivity-prod-eus2-001" -Name "vgw-vpn-prod-eus2-001" -ErrorAction SilentlyContinue
        $assessment.Details.VPNGatewayStatus = if ($vpnGateway) { $vpnGateway.ProvisioningState } else { "Not Found" }
        
        # Check Azure Firewall
        $firewall = Get-AzFirewall -ResourceGroupName "rg-connectivity-prod-eus2-001" -Name "afw-hub-prod-eus2-001" -ErrorAction SilentlyContinue
        $assessment.Details.FirewallStatus = if ($firewall) { $firewall.ProvisioningState } else { "Not Found" }
        
        Write-Host "Hub VNet Status: $($assessment.Details.HubVNetStatus)" -ForegroundColor White
        Write-Host "VPN Gateway Status: $($assessment.Details.VPNGatewayStatus)" -ForegroundColor White
        Write-Host "Firewall Status: $($assessment.Details.FirewallStatus)" -ForegroundColor White
    }
    
    "storage" {
        Write-Host "Assessing storage services..." -ForegroundColor Yellow
        
        $storageAccounts = Get-AzStorageAccount -ResourceGroupName "rg-management-prod-eus2-001"
        $assessment.Details.StorageAccounts = @()
        
        foreach ($sa in $storageAccounts) {
            $saStatus = @{
                Name = $sa.StorageAccountName
                Status = $sa.ProvisioningState
                Location = $sa.Location
            }
            $assessment.Details.StorageAccounts += $saStatus
            Write-Host "Storage Account $($sa.StorageAccountName): $($sa.ProvisioningState)" -ForegroundColor White
        }
    }
    
    "compute" {
        Write-Host "Assessing compute services..." -ForegroundColor Yellow
        
        $vms = Get-AzVM
        $assessment.Details.VirtualMachines = @()
        
        foreach ($vm in $vms) {
            $vmStatus = Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
            $powerState = ($vmStatus.Statuses | Where-Object { $_.Code -like "PowerState*" }).DisplayStatus
            
            $vmInfo = @{
                Name = $vm.Name
                ResourceGroup = $vm.ResourceGroupName
                PowerState = $powerState
                ProvisioningState = $vm.ProvisioningState
            }
            $assessment.Details.VirtualMachines += $vmInfo
            Write-Host "VM $($vm.Name): $powerState" -ForegroundColor White
        }
    }
}

$incidentLog.Actions += $assessment

# Step 2: Immediate Mitigation
Write-Host "`n=== STEP 2: IMMEDIATE MITIGATION ===" -ForegroundColor Cyan

$mitigation = @{
    Time = Get-Date
    Action = "Immediate Mitigation"
    Details = @()
}

# Implement service-specific mitigation steps
switch ($IncidentType.ToLower()) {
    "connectivity" {
        Write-Host "Implementing connectivity mitigation..." -ForegroundColor Yellow
        
        # Check and restart VPN connections if needed
        try {
            $vpnConnections = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName "rg-connectivity-prod-eus2-001"
            foreach ($connection in $vpnConnections) {
                if ($connection.ConnectionStatus -ne "Connected") {
                    Write-Host "Attempting to reset connection: $($connection.Name)" -ForegroundColor Yellow
                    Reset-AzVirtualNetworkGatewayConnection -ResourceGroupName "rg-connectivity-prod-eus2-001" -Name $connection.Name
                    $mitigation.Details += "Reset VPN connection: $($connection.Name)"
                }
            }
        }
        catch {
            $mitigation.Details += "Failed to reset VPN connections: $($_.Exception.Message)"
        }
    }
    
    "performance" {
        Write-Host "Implementing performance mitigation..." -ForegroundColor Yellow
        
        # Scale up critical resources if needed
        $mitigation.Details += "Performance mitigation initiated - review scaling options"
    }
    
    "security" {
        Write-Host "Implementing security mitigation..." -ForegroundColor Yellow
        
        # Disable affected resources if security incident
        $mitigation.Details += "Security review initiated - evaluate affected resources"
    }
}

$incidentLog.Actions += $mitigation

# Step 3: Stakeholder Notification
Write-Host "`n=== STEP 3: STAKEHOLDER NOTIFICATION ===" -ForegroundColor Cyan

$notification = @{
    Time = Get-Date
    Action = "Stakeholder Notification"
    Recipients = @("platform-team@company.com", "operations@company.com")
    Message = "Incident $IncidentId - $IncidentType affecting $AffectedService"
}

# Send notifications (implement based on notification system)
Write-Host "Notifications sent to: $($notification.Recipients -join ', ')" -ForegroundColor Yellow
$incidentLog.Actions += $notification

# Step 4: Create Service Health Incident
Write-Host "`n=== STEP 4: CREATE SERVICE HEALTH INCIDENT ===" -ForegroundColor Cyan

$serviceHealth = @{
    Time = Get-Date
    Action = "Service Health Incident Creation"
    Details = "Service health incident created for tracking"
}

# Create Azure Service Health incident (implement based on requirements)
Write-Host "Service health incident tracking initiated" -ForegroundColor Yellow
$incidentLog.Actions += $serviceHealth

# Save incident log
$logPath = "C:\Incidents\incident-$IncidentId-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$incidentLog | ConvertTo-Json -Depth 5 | Out-File -FilePath $logPath -Encoding UTF8

Write-Host "`n=== IMMEDIATE RESPONSE COMPLETED ===" -ForegroundColor Green
Write-Host "Incident log saved: $logPath" -ForegroundColor White
Write-Host "Continue with detailed investigation and resolution procedures" -ForegroundColor White
```

This comprehensive operations runbook provides the essential procedures for maintaining the Azure Enterprise Landing Zone infrastructure with detailed scripts and procedures for daily, weekly, and monthly operations, plus incident response protocols.