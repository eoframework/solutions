# Microsoft 365 Enterprise Deployment - Operations Runbook

This runbook provides comprehensive operational procedures for managing and maintaining Microsoft 365 Enterprise environments. It covers daily operations, monitoring, troubleshooting, and ongoing optimization activities.

## Daily Operations

### Morning Health Check (Daily - 8:00 AM)

#### Service Health Monitoring
```powershell
# Check Microsoft 365 service health
Connect-MsolService
Get-MsolCompanyInformation | Select-Object TelephoneNumber, City, Country

# Check service incidents
$incidents = Get-ServiceHealth | Where-Object {$_.Status -ne "Normal"}
if ($incidents) {
    Write-Host "Service Incidents Found:" -ForegroundColor Red
    $incidents | Format-Table Service, Status, Title, LastUpdatedTime
} else {
    Write-Host "All services operational" -ForegroundColor Green
}
```

#### License Usage Check
```powershell
# Monitor license consumption
$licenses = Get-MsolAccountSku
foreach ($license in $licenses) {
    $used = $license.ConsumedUnits
    $total = $license.ActiveUnits
    $available = $total - $used
    $percentage = [math]::Round(($used / $total) * 100, 2)
    
    Write-Host "$($license.SkuPartNumber): $used/$total used ($percentage%) - $available available" -ForegroundColor $(if ($percentage -gt 90) { "Red" } elseif ($percentage -gt 80) { "Yellow" } else { "Green" })
}
```

#### Security Alert Review
```powershell
# Check security alerts
Connect-ExchangeOnline
$alerts = Get-ProtectionAlert | Where-Object {$_.Status -eq "Active"}
if ($alerts) {
    Write-Host "Active Security Alerts:" -ForegroundColor Red
    $alerts | Format-Table Name, Category, Severity, Date
}
```

### User Account Management

#### New User Onboarding Workflow
```powershell
function New-M365User {
    param(
        [string]$DisplayName,
        [string]$UserPrincipalName,
        [string]$FirstName,
        [string]$LastName,
        [string]$Department,
        [string]$JobTitle,
        [string]$Manager,
        [string]$LicenseSku = "SPE_E5"
    )
    
    # Create password profile
    $passwordProfile = @{
        Password = Get-RandomPassword
        ForceChangePasswordNextSignIn = $true
    }
    
    try {
        # Create user
        $user = New-AzureADUser -DisplayName $DisplayName `
            -UserPrincipalName $UserPrincipalName `
            -GivenName $FirstName `
            -Surname $LastName `
            -Department $Department `
            -JobTitle $JobTitle `
            -AccountEnabled $true `
            -PasswordProfile $passwordProfile
        
        # Assign license
        Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -AddLicenses $LicenseSku
        
        # Add to default groups
        Add-AzureADGroupMember -ObjectId "All-Employees-GroupId" -RefObjectId $user.ObjectId
        
        # Send welcome email
        Send-WelcomeEmail -UserPrincipalName $UserPrincipalName -TempPassword $passwordProfile.Password
        
        Write-Host "User $UserPrincipalName created successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create user: $_"
    }
}

function Get-RandomPassword {
    -join ((33..126) | Get-Random -Count 12 | ForEach-Object {[char]$_})
}
```

#### User Offboarding Workflow
```powershell
function Remove-M365User {
    param(
        [string]$UserPrincipalName,
        [string]$ManagerUPN
    )
    
    try {
        # Disable user account
        Set-AzureADUser -ObjectId $UserPrincipalName -AccountEnabled $false
        
        # Remove from all groups except retention groups
        $user = Get-AzureADUser -ObjectId $UserPrincipalName
        $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId
        
        foreach ($group in $groups) {
            if ($group.DisplayName -notmatch "Retention|Archive") {
                Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $user.ObjectId
            }
        }
        
        # Convert mailbox to shared
        Set-Mailbox -Identity $UserPrincipalName -Type Shared
        
        # Grant manager full access
        Add-MailboxPermission -Identity $UserPrincipalName -User $ManagerUPN -AccessRights FullAccess -InheritanceType All
        
        # Set auto-reply
        Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -AutoReplyState Enabled -ExternalMessage "This employee is no longer with the company. Please contact $ManagerUPN for assistance."
        
        # Revoke sessions
        Revoke-AzureADUserAllRefreshToken -ObjectId $user.ObjectId
        
        Write-Host "User $UserPrincipalName offboarded successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to offboard user: $_"
    }
}
```

### Exchange Online Daily Tasks

#### Mailbox Quota Monitoring
```powershell
# Check mailboxes approaching quota limits
$mailboxes = Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | 
    Where-Object {($_.TotalItemSize.Value.ToMB() / 1024) -gt 80} |
    Sort-Object @{Expression={$_.TotalItemSize.Value.ToMB()}} -Descending

if ($mailboxes) {
    Write-Host "Mailboxes approaching quota:" -ForegroundColor Yellow
    $mailboxes | Select-Object DisplayName, 
        @{Name="SizeGB";Expression={[math]::Round($_.TotalItemSize.Value.ToMB()/1024,2)}},
        @{Name="ItemCount";Expression={$_.ItemCount}} |
        Format-Table
}
```

#### Message Trace Monitoring
```powershell
# Check for delivery issues in last 24 hours
$yesterday = (Get-Date).AddDays(-1)
$traces = Get-MessageTrace -StartDate $yesterday -EndDate (Get-Date) | 
    Where-Object {$_.Status -ne "Delivered"}

if ($traces) {
    Write-Host "Message delivery issues found:" -ForegroundColor Red
    $traces | Group-Object Status | Select-Object Name, Count | Format-Table
}
```

### SharePoint Online Monitoring

#### Site Collection Storage Check
```powershell
# Monitor SharePoint site storage usage
Connect-SPOService -Url https://[tenant]-admin.sharepoint.com

$sites = Get-SPOSite -Limit All | Where-Object {$_.StorageUsageCurrent -gt ($_.StorageQuota * 0.8)}

if ($sites) {
    Write-Host "Sites approaching storage quota:" -ForegroundColor Yellow
    $sites | Select-Object Url, 
        @{Name="UsedGB";Expression={[math]::Round($_.StorageUsageCurrent/1024,2)}},
        @{Name="QuotaGB";Expression={[math]::Round($_.StorageQuota/1024,2)}},
        @{Name="PercentUsed";Expression={[math]::Round(($_.StorageUsageCurrent/$_.StorageQuota)*100,1)}} |
        Format-Table
}
```

#### External Sharing Audit
```powershell
# Check for external sharing activities
$auditLogs = Search-UnifiedAuditLog -StartDate $yesterday -EndDate (Get-Date) -Operations "SharingSet","SharingInvitationCreated" -ResultSize 5000

if ($auditLogs) {
    Write-Host "External sharing activities found:" -ForegroundColor Yellow
    $auditLogs | Select-Object CreationDate, UserIds, Operations, ObjectId | Format-Table
}
```

## Weekly Operations

### Security Review (Weekly - Monday 9:00 AM)

#### Conditional Access Policy Review
```powershell
# Review conditional access policies and their usage
$caReport = @()
$policies = Get-AzureADMSConditionalAccessPolicy

foreach ($policy in $policies) {
    $signInLogs = Get-AzureADAuditSignInLogs -Filter "appliedConditionalAccessPolicies/any(x:x/id eq '$($policy.Id)')" -Top 100
    
    $caReport += [PSCustomObject]@{
        PolicyName = $policy.DisplayName
        State = $policy.State
        UsageCount = $signInLogs.Count
        LastUsed = if ($signInLogs) { ($signInLogs | Sort-Object CreatedDateTime -Descending | Select-Object -First 1).CreatedDateTime } else { "Never" }
    }
}

$caReport | Format-Table
```

#### Security Score Review
```powershell
# Check Microsoft Secure Score
$secureScore = Get-SecureScore
Write-Host "Current Secure Score: $($secureScore.currentScore)/$($secureScore.maxScore) ($([math]::Round(($secureScore.currentScore/$secureScore.maxScore)*100,1))%)"

# Get top recommendations
$recommendations = Get-SecureScoreControlProfiles | Sort-Object Score -Descending | Select-Object -First 10
$recommendations | Select-Object Title, Score, ImplementationCost | Format-Table
```

#### Identity Protection Review
```powershell
# Review risky users and sign-ins
$riskyUsers = Get-AzureADIdentityProtectionRiskyUser -Filter "riskState eq 'atRisk'"
if ($riskyUsers) {
    Write-Host "Risky users found:" -ForegroundColor Red
    $riskyUsers | Select-Object UserDisplayName, UserPrincipalName, RiskLevel, RiskState | Format-Table
}

$riskySignIns = Get-AzureADIdentityProtectionRiskySignIn -Filter "riskState eq 'atRisk'" | Select-Object -First 20
if ($riskySignIns) {
    Write-Host "Recent risky sign-ins:" -ForegroundColor Yellow
    $riskySignIns | Select-Object CreatedDateTime, UserDisplayName, RiskLevel, RiskDetail | Format-Table
}
```

### Compliance Review (Weekly - Wednesday 10:00 AM)

#### DLP Policy Effectiveness
```powershell
# Review DLP policy matches
$dlpEvents = Search-UnifiedAuditLog -StartDate $yesterday.AddDays(-7) -EndDate (Get-Date) -Operations "DlpRuleMatch" -ResultSize 5000

if ($dlpEvents) {
    $dlpSummary = $dlpEvents | Group-Object {($_.AuditData | ConvertFrom-Json).PolicyName} | 
        Select-Object Name, Count | Sort-Object Count -Descending
    
    Write-Host "DLP Policy Matches (Last 7 days):" -ForegroundColor Yellow
    $dlpSummary | Format-Table
}
```

#### Retention Policy Status
```powershell
# Check retention policy compliance
$retentionPolicies = Get-RetentionCompliancePolicy
foreach ($policy in $retentionPolicies) {
    $rule = Get-RetentionComplianceRule -Policy $policy.Name
    Write-Host "Policy: $($policy.Name) - Enabled: $($policy.Enabled) - Mode: $($policy.Mode)"
    Write-Host "  Rule: $($rule.Name) - Retention Period: $($rule.RetentionDuration) days"
}
```

### Performance Review (Weekly - Friday 2:00 PM)

#### Teams Performance Analysis
```powershell
# Teams usage and performance metrics
$teamsReport = Get-CsTeamsUserActivityUserDetail -Period D7
$topUsers = $teamsReport | Sort-Object TotalMeetingCount -Descending | Select-Object -First 10
Write-Host "Top Teams users by meeting count (Last 7 days):"
$topUsers | Select-Object UserPrincipalName, TotalMeetingCount, TotalChatMessages | Format-Table
```

#### Exchange Performance Metrics
```powershell
# Exchange Online performance
$mailboxStats = Get-Mailbox -ResultSize 100 | Get-MailboxStatistics | 
    Measure-Object -Property @{Expression={$_.TotalItemSize.Value.ToMB()}} -Sum

Write-Host "Exchange Online Statistics:"
Write-Host "  Total mailboxes: $(($mailboxStats | Measure-Object).Count)"
Write-Host "  Total storage: $([math]::Round($mailboxStats.Sum/1024,2)) GB"
Write-Host "  Average mailbox size: $([math]::Round($mailboxStats.Average/1024,2)) GB"
```

## Monthly Operations

### License Optimization (First Monday of Month)

#### License Usage Analysis
```powershell
# Comprehensive license analysis
function Get-LicenseUtilizationReport {
    $report = @()
    $licenses = Get-MsolAccountSku
    
    foreach ($license in $licenses) {
        $users = Get-MsolUser -All | Where-Object {$_.Licenses.AccountSkuId -eq $license.AccountSkuId}
        $activeUsers = $users | Where-Object {$_.LastPasswordChangeTimestamp -gt (Get-Date).AddDays(-90)}
        
        $report += [PSCustomObject]@{
            License = $license.SkuPartNumber
            Total = $license.ActiveUnits
            Consumed = $license.ConsumedUnits
            Available = $license.ActiveUnits - $license.ConsumedUnits
            ActiveUsers = $activeUsers.Count
            UtilizationRate = [math]::Round(($license.ConsumedUnits / $license.ActiveUnits) * 100, 2)
            ActiveUserRate = [math]::Round(($activeUsers.Count / $license.ConsumedUnits) * 100, 2)
        }
    }
    
    return $report
}

$licenseReport = Get-LicenseUtilizationReport
$licenseReport | Format-Table
```

### Security Assessment (Second Monday of Month)

#### Comprehensive Security Review
```powershell
# Security baseline assessment
function Get-SecurityBaselineReport {
    $report = @{
        ConditionalAccessPolicies = (Get-AzureADMSConditionalAccessPolicy).Count
        EnabledCAPolicies = (Get-AzureADMSConditionalAccessPolicy | Where-Object {$_.State -eq "Enabled"}).Count
        MFAEnabledUsers = (Get-MsolUser -All | Where-Object {$_.StrongAuthenticationRequirements.Count -gt 0}).Count
        PrivilegedUsers = (Get-AzureADDirectoryRole | ForEach-Object {Get-AzureADDirectoryRoleMember -ObjectId $_.ObjectId} | Select-Object -Unique).Count
        GuestUsers = (Get-AzureADUser -Filter "userType eq 'Guest'").Count
        RiskyUsers = (Get-AzureADIdentityProtectionRiskyUser -Filter "riskState eq 'atRisk'").Count
    }
    
    return $report
}

$securityReport = Get-SecurityBaselineReport
Write-Host "Security Baseline Report:"
$securityReport.GetEnumerator() | ForEach-Object { Write-Host "  $($_.Key): $($_.Value)" }
```

### Capacity Planning (Third Monday of Month)

#### Storage Capacity Analysis
```powershell
# SharePoint storage trending
function Get-StorageTrend {
    $sites = Get-SPOSite -Limit All
    $totalUsed = ($sites | Measure-Object StorageUsageCurrent -Sum).Sum
    $totalQuota = ($sites | Measure-Object StorageQuota -Sum).Sum
    
    Write-Host "SharePoint Storage Analysis:"
    Write-Host "  Total Used: $([math]::Round($totalUsed/1024,2)) GB"
    Write-Host "  Total Quota: $([math]::Round($totalQuota/1024,2)) GB"
    Write-Host "  Utilization: $([math]::Round(($totalUsed/$totalQuota)*100,2))%"
    
    # Sites requiring attention
    $highUsage = $sites | Where-Object {($_.StorageUsageCurrent / $_.StorageQuota) -gt 0.8} | 
        Sort-Object @{Expression={$_.StorageUsageCurrent/$_.StorageQuota}} -Descending
    
    if ($highUsage) {
        Write-Host "Sites requiring storage attention:" -ForegroundColor Yellow
        $highUsage | Select-Object Url, 
            @{Name="UsagePercent";Expression={[math]::Round(($_.StorageUsageCurrent/$_.StorageQuota)*100,1)}} | 
            Format-Table
    }
}

Get-StorageTrend
```

## Troubleshooting Procedures

### Common Issues and Resolutions

#### Email Delivery Problems
```powershell
# Diagnose email delivery issues
function Diagnose-EmailDelivery {
    param(
        [string]$Sender,
        [string]$Recipient,
        [datetime]$StartTime = (Get-Date).AddHours(-24)
    )
    
    # Message trace
    $trace = Get-MessageTrace -SenderAddress $Sender -RecipientAddress $Recipient -StartDate $StartTime
    
    if ($trace) {
        Write-Host "Message trace results:"
        $trace | Select-Object Received, SenderAddress, RecipientAddress, Subject, Status, ToIP, FromIP | Format-Table
        
        # Get detailed trace
        foreach ($message in $trace) {
            $details = Get-MessageTraceDetail -MessageTraceId $message.MessageTraceId -RecipientAddress $message.RecipientAddress
            Write-Host "Details for message $($message.MessageTraceId):"
            $details | Format-Table
        }
    } else {
        Write-Host "No messages found matching criteria" -ForegroundColor Yellow
    }
}
```

#### Teams Meeting Issues
```powershell
# Diagnose Teams meeting problems
function Diagnose-TeamsMeeting {
    param(
        [string]$UserPrincipalName,
        [datetime]$StartTime = (Get-Date).AddHours(-24)
    )
    
    # Check Teams meeting policies
    $user = Get-CsOnlineUser -Identity $UserPrincipalName
    Write-Host "User Teams Policies:"
    Write-Host "  Meeting Policy: $($user.TeamsMeetingPolicy)"
    Write-Host "  Messaging Policy: $($user.TeamsMessagingPolicy)"
    Write-Host "  Calling Policy: $($user.TeamsCallingPolicy)"
    
    # Check meeting details
    $meetings = Get-CsMeetingMigrationStatus -SummaryOnly | Where-Object {$_.UserPrincipalName -eq $UserPrincipalName}
    if ($meetings) {
        Write-Host "Meeting migration status:"
        $meetings | Format-Table
    }
}
```

#### OneDrive Sync Issues
```powershell
# OneDrive troubleshooting
function Diagnose-OneDriveSync {
    param([string]$UserPrincipalName)
    
    # Check OneDrive status
    $user = Get-SPOUser -Site "https://[tenant]-my.sharepoint.com/personal/$($UserPrincipalName.Replace('@','_').Replace('.','_'))" -LoginName $UserPrincipalName -ErrorAction SilentlyContinue
    
    if ($user) {
        Write-Host "OneDrive Status for $UserPrincipalName:"
        Write-Host "  Storage Used: $($user.StorageUsageCurrent) MB"
        Write-Host "  Storage Quota: $($user.StorageQuotaCurrently) MB"
        Write-Host "  Last Activity: $($user.LastActivityDate)"
    } else {
        Write-Host "OneDrive not provisioned for $UserPrincipalName" -ForegroundColor Yellow
    }
}
```

### Performance Optimization

#### Mailbox Performance Tuning
```powershell
# Optimize mailbox performance
function Optimize-MailboxPerformance {
    param([string]$UserPrincipalName)
    
    $mailbox = Get-Mailbox -Identity $UserPrincipalName
    $stats = Get-MailboxStatistics -Identity $UserPrincipalName
    
    Write-Host "Mailbox Performance Analysis for $UserPrincipalName:"
    Write-Host "  Total Items: $($stats.ItemCount)"
    Write-Host "  Mailbox Size: $([math]::Round($stats.TotalItemSize.Value.ToMB()/1024,2)) GB"
    Write-Host "  Deleted Items: $($stats.DeletedItemCount)"
    
    # Recommendations
    if ($stats.ItemCount -gt 100000) {
        Write-Host "Recommendation: Enable online archive" -ForegroundColor Yellow
        # Enable-Mailbox -Identity $UserPrincipalName -Archive
    }
    
    if ($stats.DeletedItemCount -gt 10000) {
        Write-Host "Recommendation: Empty deleted items folder" -ForegroundColor Yellow
        # Search-Mailbox -Identity $UserPrincipalName -SearchDumpster -DeleteContent
    }
}
```

### Disaster Recovery Procedures

#### Service Outage Response
```powershell
# Service outage response checklist
function Invoke-OutageResponse {
    Write-Host "Service Outage Response Checklist:" -ForegroundColor Red
    Write-Host "1. Check Microsoft 365 Service Health Dashboard"
    Write-Host "2. Verify network connectivity"
    Write-Host "3. Test alternative access methods"
    Write-Host "4. Communicate with users"
    Write-Host "5. Document issues and timeline"
    
    # Check service health
    $health = Get-ServiceHealth
    $issues = $health | Where-Object {$_.Status -ne "ServiceOperational"}
    
    if ($issues) {
        Write-Host "Current service issues:" -ForegroundColor Red
        $issues | Format-Table Service, Status, StatusDisplayName
    }
}
```

#### Data Recovery Procedures
```powershell
# Recover deleted items
function Restore-DeletedItems {
    param(
        [string]$UserPrincipalName,
        [string]$Subject,
        [datetime]$DeletedAfter = (Get-Date).AddDays(-14)
    )
    
    # Search for deleted items
    $search = New-ComplianceSearch -Name "Recovery-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -ExchangeLocation $UserPrincipalName -ContentMatchQuery "Subject:$Subject AND Received>=$($DeletedAfter.ToString('yyyy-MM-dd'))"
    Start-ComplianceSearch -Identity $search.Name
    
    # Wait for completion
    do {
        Start-Sleep -Seconds 10
        $status = Get-ComplianceSearch -Identity $search.Name
        Write-Host "Search status: $($status.Status)"
    } while ($status.Status -eq "InProgress")
    
    if ($status.Items -gt 0) {
        Write-Host "Found $($status.Items) items matching criteria"
        # Create recovery action if needed
        # New-ComplianceSearchAction -SearchName $search.Name -Export
    } else {
        Write-Host "No items found matching criteria"
    }
}
```

## Automation and Reporting

### Automated Reports

#### Daily Status Report
```powershell
# Generate daily status report
function New-DailyStatusReport {
    $report = @{
        Date = Get-Date -Format "yyyy-MM-dd"
        ServiceHealth = Get-ServiceHealth | Where-Object {$_.Status -ne "ServiceOperational"}
        LicenseAlerts = Get-MsolAccountSku | Where-Object {($_.ConsumedUnits / $_.ActiveUnits) -gt 0.9}
        SecurityAlerts = Get-ProtectionAlert | Where-Object {$_.Status -eq "Active"}
        QuotaWarnings = Get-Mailbox -ResultSize 100 | Get-MailboxStatistics | Where-Object {($_.TotalItemSize.Value.ToMB() / 1024) -gt 80}
    }
    
    # Email report to administrators
    $body = @"
Daily Microsoft 365 Status Report - $($report.Date)

Service Health Issues: $($report.ServiceHealth.Count)
License Utilization Alerts: $($report.LicenseAlerts.Count) 
Active Security Alerts: $($report.SecurityAlerts.Count)
Quota Warnings: $($report.QuotaWarnings.Count)

Please review the Microsoft 365 admin center for detailed information.
"@
    
    Send-MailMessage -From "m365admin@company.com" -To "it-team@company.com" -Subject "Daily M365 Status Report" -Body $body -SmtpServer "smtp.office365.com" -UseSSL -Port 587 -Credential $credential
}
```

### Monitoring and Alerting

#### Custom Health Monitoring
```powershell
# Custom health check script
function Test-M365Health {
    $healthStatus = @{
        Timestamp = Get-Date
        ExchangeOnline = $false
        SharePointOnline = $false
        MicrosoftTeams = $false
        AzureAD = $false
        OverallHealth = "Degraded"
    }
    
    try {
        # Test Exchange Online
        Connect-ExchangeOnline -ShowBanner:$false
        Get-Mailbox -ResultSize 1 | Out-Null
        $healthStatus.ExchangeOnline = $true
        Disconnect-ExchangeOnline -Confirm:$false
    } catch {
        Write-Warning "Exchange Online connectivity issue: $_"
    }
    
    try {
        # Test SharePoint Online
        Connect-SPOService -Url "https://[tenant]-admin.sharepoint.com"
        Get-SPOSite -Limit 1 | Out-Null
        $healthStatus.SharePointOnline = $true
        Disconnect-SPOService
    } catch {
        Write-Warning "SharePoint Online connectivity issue: $_"
    }
    
    try {
        # Test Azure AD
        Connect-AzureAD
        Get-AzureADTenantDetail | Out-Null
        $healthStatus.AzureAD = $true
        Disconnect-AzureAD
    } catch {
        Write-Warning "Azure AD connectivity issue: $_"
    }
    
    # Determine overall health
    $services = @($healthStatus.ExchangeOnline, $healthStatus.SharePointOnline, $healthStatus.AzureAD)
    if ($services -notcontains $false) {
        $healthStatus.OverallHealth = "Healthy"
    } elseif (($services | Where-Object {$_ -eq $true}).Count -gt 1) {
        $healthStatus.OverallHealth = "Degraded"
    } else {
        $healthStatus.OverallHealth = "Critical"
    }
    
    return $healthStatus
}
```

This operations runbook provides comprehensive procedures for managing Microsoft 365 environments efficiently. Regular execution of these procedures ensures optimal performance, security, and user experience across all Microsoft 365 services.