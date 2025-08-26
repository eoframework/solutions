# Microsoft 365 Enterprise Deployment - Troubleshooting Guide

This comprehensive troubleshooting guide provides diagnostic procedures, common issue resolutions, and performance optimization strategies for Microsoft 365 enterprise environments.

## Authentication and Identity Issues

### Azure Active Directory Authentication Problems

#### Symptom: Users Unable to Sign In
```powershell
# Comprehensive authentication diagnostics
function Diagnose-AuthenticationIssues {
    param(
        [string]$UserPrincipalName,
        [int]$DaysBack = 7
    )
    
    Write-Host "Diagnosing authentication issues for: $UserPrincipalName" -ForegroundColor Yellow
    
    try {
        # Check user account status
        $user = Get-AzureADUser -ObjectId $UserPrincipalName -ErrorAction Stop
        
        Write-Host "`nUser Account Status:" -ForegroundColor Green
        Write-Host "  Account Enabled: $($user.AccountEnabled)"
        Write-Host "  Display Name: $($user.DisplayName)"
        Write-Host "  UPN: $($user.UserPrincipalName)"
        Write-Host "  Object ID: $($user.ObjectId)"
        Write-Host "  User Type: $($user.UserType)"
        Write-Host "  Creation Date: $($user.ExtensionProperty.createdDateTime)"
        
        # Check license assignment
        $licenses = Get-AzureADUserLicenseDetail -ObjectId $UserPrincipalName
        if ($licenses) {
            Write-Host "`nLicense Information:" -ForegroundColor Green
            foreach ($license in $licenses) {
                Write-Host "  License: $($license.SkuPartNumber)"
                Write-Host "  Status: $(if($license.SkuPartNumber) {'Active'} else {'Inactive'})"
            }
        } else {
            Write-Host "`nNo licenses assigned to user" -ForegroundColor Red
        }
        
        # Check MFA status
        Connect-MsolService -ErrorAction SilentlyContinue
        $mfaStatus = Get-MsolUser -UserPrincipalName $UserPrincipalName | 
            Select-Object UserPrincipalName, @{Name="MFAStatus"; Expression={
                if($_.StrongAuthenticationRequirements.Count -gt 0) {
                    $_.StrongAuthenticationRequirements[0].State
                } else {
                    "Disabled"
                }
            }}
        
        Write-Host "`nMFA Status: $($mfaStatus.MFAStatus)" -ForegroundColor Green
        
        # Check recent sign-ins
        $signInLogs = Get-AzureADAuditSignInLogs -Filter "userPrincipalName eq '$UserPrincipalName'" -Top 10
        if ($signInLogs) {
            Write-Host "`nRecent Sign-in Attempts:" -ForegroundColor Green
            $signInLogs | Select-Object CreatedDateTime, Status, ClientAppUsed, IpAddress | 
                Format-Table -AutoSize
        }
        
        # Check conditional access policy impacts
        $caLogs = $signInLogs | Where-Object {$_.AppliedConditionalAccessPolicies.Count -gt 0}
        if ($caLogs) {
            Write-Host "`nConditional Access Policy Results:" -ForegroundColor Green
            foreach ($log in $caLogs) {
                Write-Host "  Sign-in: $($log.CreatedDateTime)"
                foreach ($policy in $log.AppliedConditionalAccessPolicies) {
                    Write-Host "    Policy: $($policy.DisplayName) - Result: $($policy.Result)"
                }
            }
        }
        
    }
    catch {
        Write-Host "Error during authentication diagnosis: $($_.Exception.Message)" -ForegroundColor Red
        
        # Provide troubleshooting steps
        Write-Host "`nTroubleshooting Steps:" -ForegroundColor Yellow
        Write-Host "1. Verify user exists in Azure AD"
        Write-Host "2. Check if account is enabled"
        Write-Host "3. Verify license assignment"
        Write-Host "4. Check conditional access policies"
        Write-Host "5. Review MFA configuration"
        Write-Host "6. Validate network connectivity"
    }
}

# Usage example
# Diagnose-AuthenticationIssues -UserPrincipalName "user@company.com"
```

#### Common Authentication Resolutions

**Problem**: User account locked or disabled
```powershell
# Resolution: Enable user account
Set-AzureADUser -ObjectId "user@company.com" -AccountEnabled $true

# Check account lockout status
$user = Get-AzureADUser -ObjectId "user@company.com"
if ($user.AccountEnabled -eq $false) {
    Write-Host "Account is disabled - enabling now"
    Set-AzureADUser -ObjectId "user@company.com" -AccountEnabled $true
}
```

**Problem**: MFA registration issues
```powershell
# Reset MFA registration for user
Set-MsolUser -UserPrincipalName "user@company.com" -StrongAuthenticationRequirements @()
Write-Host "MFA registration reset - user must re-register"

# Force MFA re-registration
$mfa = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$mfa.RelyingParty = "*"
$mfa.State = "Enabled"
Set-MsolUser -UserPrincipalName "user@company.com" -StrongAuthenticationRequirements @($mfa)
```

**Problem**: Conditional access blocking user
```powershell
# Identify problematic conditional access policies
function Find-BlockingCAPolicy {
    param([string]$UserPrincipalName)
    
    $signIns = Get-AzureADAuditSignInLogs -Filter "userPrincipalName eq '$UserPrincipalName'" -Top 5
    $blockedSignIns = $signIns | Where-Object {$_.Status.ErrorCode -ne 0}
    
    foreach ($signIn in $blockedSignIns) {
        Write-Host "Blocked Sign-in: $($signIn.CreatedDateTime)"
        Write-Host "Error: $($signIn.Status.ErrorCode) - $($signIn.Status.FailureReason)"
        
        foreach ($policy in $signIn.AppliedConditionalAccessPolicies) {
            if ($policy.Result -eq "failure" -or $policy.Result -eq "block") {
                Write-Host "  Blocking Policy: $($policy.DisplayName)" -ForegroundColor Red
            }
        }
    }
}

# Temporarily exclude user from problematic policy (emergency access)
# Note: Use with extreme caution and only for troubleshooting
function Add-CAExclusion {
    param(
        [string]$PolicyId,
        [string]$UserPrincipalName
    )
    
    $policy = Get-AzureADMSConditionalAccessPolicy -PolicyId $PolicyId
    $user = Get-AzureADUser -ObjectId $UserPrincipalName
    
    if ($policy.Conditions.Users.ExcludeUsers -notcontains $user.ObjectId) {
        $policy.Conditions.Users.ExcludeUsers += $user.ObjectId
        Set-AzureADMSConditionalAccessPolicy -PolicyId $PolicyId -Conditions $policy.Conditions
        Write-Host "User excluded from policy temporarily" -ForegroundColor Yellow
    }
}
```

### Hybrid Identity Synchronization Issues

#### Azure AD Connect Synchronization Problems
```powershell
# Azure AD Connect diagnostic script
function Test-ADConnectSync {
    Write-Host "Azure AD Connect Synchronization Diagnostics" -ForegroundColor Blue
    
    # Check sync service status
    $syncService = Get-Service -Name "ADSync" -ErrorAction SilentlyContinue
    if ($syncService) {
        Write-Host "ADSync Service Status: $($syncService.Status)" -ForegroundColor $(
            if ($syncService.Status -eq "Running") { "Green" } else { "Red" }
        )
    } else {
        Write-Host "Azure AD Connect service not found" -ForegroundColor Red
        return
    }
    
    try {
        Import-Module ADSync -ErrorAction Stop
        
        # Get sync configuration
        $syncConfig = Get-ADSyncScheduler
        Write-Host "`nSync Scheduler Configuration:" -ForegroundColor Green
        Write-Host "  Sync Cycle Enabled: $($syncConfig.SyncCycleEnabled)"
        Write-Host "  Next Sync Time: $($syncConfig.NextSyncCyclePolicyDateTime)"
        Write-Host "  Sync Interval: $($syncConfig.PolicySyncInterval)"
        
        # Check recent sync cycles
        $syncHistory = Get-ADSyncRunProfileResult | Sort-Object StartDate -Descending | Select-Object -First 10
        Write-Host "`nRecent Sync Cycles:" -ForegroundColor Green
        foreach ($run in $syncHistory) {
            $status = if ($run.Result -eq "Success") { "✓" } else { "✗" }
            Write-Host "  $status $($run.StartDate) - $($run.RunProfileName) - $($run.Result)"
        }
        
        # Check for sync errors
        $errors = Get-ADSyncRunProfileResult | Where-Object {$_.Result -ne "Success"}
        if ($errors) {
            Write-Host "`nSync Errors Found:" -ForegroundColor Red
            foreach ($error in $errors | Select-Object -First 5) {
                Write-Host "  $($error.StartDate): $($error.RunProfileName) - $($error.Result)"
            }
        }
        
        # Check connector space objects
        $connectorSpaces = Get-ADSyncConnectorSpace
        Write-Host "`nConnector Space Summary:" -ForegroundColor Green
        foreach ($cs in $connectorSpaces) {
            Write-Host "  $($cs.Name): $($cs.ObjectCount) objects"
        }
        
    }
    catch {
        Write-Host "Error accessing ADSync module: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Ensure this script runs on the Azure AD Connect server"
    }
}

# Fix common sync issues
function Repair-ADConnectSync {
    Write-Host "Attempting Azure AD Connect sync repairs..." -ForegroundColor Yellow
    
    try {
        # Force full sync cycle
        Write-Host "Starting full synchronization cycle..."
        Start-ADSyncSyncCycle -PolicyType Initial
        
        # Wait for sync to complete
        Start-Sleep -Seconds 30
        
        # Check sync results
        $lastRun = Get-ADSyncRunProfileResult | Sort-Object StartDate -Descending | Select-Object -First 1
        Write-Host "Last sync result: $($lastRun.Result) at $($lastRun.StartDate)"
        
        if ($lastRun.Result -ne "Success") {
            Write-Host "Sync still failing - check event logs for details" -ForegroundColor Red
        }
        
    }
    catch {
        Write-Host "Failed to start sync cycle: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

## Email and Exchange Online Issues

### Mail Flow Problems

#### Email Delivery Delays or Failures
```powershell
# Mail flow diagnostic tool
function Test-MailFlow {
    param(
        [string]$SenderAddress,
        [string]$RecipientAddress,
        [datetime]$StartDate = (Get-Date).AddHours(-24),
        [datetime]$EndDate = (Get-Date)
    )
    
    Write-Host "Analyzing mail flow between $SenderAddress and $RecipientAddress" -ForegroundColor Blue
    
    try {
        # Get message trace
        $traces = Get-MessageTrace -SenderAddress $SenderAddress -RecipientAddress $RecipientAddress -StartDate $StartDate -EndDate $EndDate
        
        if ($traces) {
            Write-Host "`nMessage Trace Results:" -ForegroundColor Green
            $traces | Select-Object Received, Subject, Status, ToIP, FromIP, Size | Format-Table -AutoSize
            
            # Get detailed trace for failed messages
            $failedMessages = $traces | Where-Object {$_.Status -ne "Delivered"}
            foreach ($failed in $failedMessages) {
                Write-Host "`nDetailed trace for failed message (ID: $($failed.MessageTraceId)):" -ForegroundColor Yellow
                $details = Get-MessageTraceDetail -MessageTraceId $failed.MessageTraceId -RecipientAddress $failed.RecipientAddress
                $details | Select-Object Date, Event, Action, Detail | Format-Table -AutoSize
            }
        } else {
            Write-Host "No messages found matching criteria" -ForegroundColor Yellow
        }
        
        # Check transport rules that might affect delivery
        $transportRules = Get-TransportRule | Where-Object {$_.State -eq "Enabled"}
        Write-Host "`nActive Transport Rules:" -ForegroundColor Green
        $transportRules | Select-Object Name, Priority, State | Format-Table -AutoSize
        
        # Test mail flow with Test-Mailflow cmdlet
        Write-Host "`nRunning built-in mail flow test..." -ForegroundColor Green
        $mailFlowTest = Test-Mailflow -TargetEmailAddress $RecipientAddress
        Write-Host "Mail flow test result: $($mailFlowTest.TestMailflowResult)"
        
        if ($mailFlowTest.TestMailflowResult -ne "Success") {
            Write-Host "Mail flow test details: $($mailFlowTest.MessageInfo)" -ForegroundColor Red
        }
        
    }
    catch {
        Write-Host "Error during mail flow analysis: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check for common mail flow issues
function Test-CommonMailIssues {
    Write-Host "Checking for common mail flow issues..." -ForegroundColor Blue
    
    # Check accepted domains
    $acceptedDomains = Get-AcceptedDomain
    Write-Host "`nAccepted Domains:" -ForegroundColor Green
    $acceptedDomains | Select-Object DomainName, DomainType, Default | Format-Table -AutoSize
    
    # Check MX records for primary domain
    $primaryDomain = ($acceptedDomains | Where-Object {$_.Default -eq $true}).DomainName
    Write-Host "`nChecking MX record for primary domain: $primaryDomain" -ForegroundColor Green
    
    try {
        $mxRecord = Resolve-DnsName -Name $primaryDomain -Type MX
        foreach ($mx in $mxRecord) {
            Write-Host "  MX: $($mx.NameExchange) (Priority: $($mx.Preference))"
        }
    }
    catch {
        Write-Host "  Error resolving MX record: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Check spam filter policies
    $spamPolicies = Get-HostedContentFilterPolicy
    Write-Host "`nSpam Filter Policies:" -ForegroundColor Green
    foreach ($policy in $spamPolicies) {
        Write-Host "  Policy: $($policy.Name) - Bulk Threshold: $($policy.BulkThreshold)"
    }
    
    # Check for quarantined messages
    $quarantineCount = (Get-QuarantineMessage | Measure-Object).Count
    Write-Host "`nQuarantined Messages: $quarantineCount" -ForegroundColor $(
        if ($quarantineCount -gt 100) { "Red" } else { "Green" }
    )
}
```

#### Resolution Steps for Mail Flow Issues

**Problem**: Email stuck in quarantine
```powershell
# Release quarantined messages
function Release-QuarantinedMail {
    param(
        [string]$SenderAddress,
        [string]$RecipientAddress,
        [int]$DaysBack = 7
    )
    
    $startDate = (Get-Date).AddDays(-$DaysBack)
    $quarantined = Get-QuarantineMessage -StartReceivedDate $startDate -SenderAddress $SenderAddress -RecipientAddress $RecipientAddress
    
    if ($quarantined) {
        Write-Host "Found $($quarantined.Count) quarantined messages"
        foreach ($msg in $quarantined) {
            Write-Host "  Subject: $($msg.Subject) - Reason: $($msg.QuarantineReason)"
            
            # Release message
            Release-QuarantineMessage -Identity $msg.Identity -ReleaseToAll
            Write-Host "    Released message" -ForegroundColor Green
        }
    } else {
        Write-Host "No quarantined messages found for specified criteria"
    }
}
```

**Problem**: Transport rule blocking emails
```powershell
# Identify problematic transport rules
function Find-BlockingTransportRule {
    param([string]$SenderAddress, [string]$Subject)
    
    $rules = Get-TransportRule | Where-Object {$_.State -eq "Enabled"}
    
    foreach ($rule in $rules) {
        Write-Host "`nAnalyzing rule: $($rule.Name)"
        
        # Check sender conditions
        if ($rule.From -contains $SenderAddress -or $rule.FromAddressContainsWords -contains $SenderAddress) {
            Write-Host "  Rule may affect sender: $SenderAddress" -ForegroundColor Yellow
        }
        
        # Check subject conditions
        if ($rule.SubjectContainsWords) {
            foreach ($word in $rule.SubjectContainsWords) {
                if ($Subject -like "*$word*") {
                    Write-Host "  Rule may affect subject containing: $word" -ForegroundColor Yellow
                }
            }
        }
        
        # Show actions
        if ($rule.RejectMessageEnhancedStatusCode -or $rule.DeleteMessage) {
            Write-Host "  BLOCKING RULE - Action: $($rule.RejectMessageReasonText)" -ForegroundColor Red
        }
    }
}
```

### Mailbox Performance Issues

#### Large Mailbox Optimization
```powershell
# Mailbox performance analysis
function Optimize-MailboxPerformance {
    param([string]$UserPrincipalName)
    
    Write-Host "Analyzing mailbox performance for: $UserPrincipalName" -ForegroundColor Blue
    
    try {
        # Get mailbox statistics
        $mailbox = Get-Mailbox -Identity $UserPrincipalName
        $stats = Get-MailboxStatistics -Identity $UserPrincipalName
        
        Write-Host "`nMailbox Statistics:" -ForegroundColor Green
        Write-Host "  Total Items: $($stats.ItemCount)"
        Write-Host "  Mailbox Size: $([math]::Round($stats.TotalItemSize.Value.ToMB()/1024,2)) GB"
        Write-Host "  Deleted Items: $($stats.DeletedItemCount)"
        Write-Host "  Deleted Items Size: $([math]::Round($stats.TotalDeletedItemSize.Value.ToMB()/1024,2)) GB"
        
        # Check if archive is enabled
        if ($mailbox.ArchiveStatus -eq "None") {
            Write-Host "`nRecommendation: Enable online archive" -ForegroundColor Yellow
            Write-Host "Command: Enable-Mailbox -Identity $UserPrincipalName -Archive"
        } else {
            $archiveStats = Get-MailboxStatistics -Identity $UserPrincipalName -Archive
            Write-Host "  Archive Size: $([math]::Round($archiveStats.TotalItemSize.Value.ToMB()/1024,2)) GB"
        }
        
        # Get folder statistics for large folders
        $folders = Get-MailboxFolderStatistics -Identity $UserPrincipalName | 
                  Sort-Object ItemsInFolder -Descending | 
                  Select-Object -First 10
        
        Write-Host "`nTop 10 Folders by Item Count:" -ForegroundColor Green
        $folders | Select-Object Name, ItemsInFolder, @{Name="SizeMB";Expression={[math]::Round($_.FolderAndSubfolderSize.ToMB(),2)}} | Format-Table
        
        # Performance recommendations
        Write-Host "`nPerformance Recommendations:" -ForegroundColor Yellow
        
        if ($stats.ItemCount -gt 100000) {
            Write-Host "• Consider enabling online archive and moving old items"
        }
        
        if ($stats.DeletedItemCount -gt 10000) {
            Write-Host "• Empty deleted items folder to recover space"
        }
        
        $largeFolder = $folders | Where-Object {$_.ItemsInFolder -gt 5000} | Select-Object -First 1
        if ($largeFolder) {
            Write-Host "• Organize items in folder: $($largeFolder.Name) ($($largeFolder.ItemsInFolder) items)"
        }
        
        # Check retention policy
        if ($mailbox.RetentionPolicy) {
            Write-Host "• Retention policy applied: $($mailbox.RetentionPolicy)"
        } else {
            Write-Host "• Consider applying retention policy for automatic cleanup"
        }
        
    }
    catch {
        Write-Host "Error analyzing mailbox: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Automated mailbox cleanup
function Invoke-MailboxCleanup {
    param(
        [string]$UserPrincipalName,
        [int]$DeletedItemsRetentionDays = 30,
        [bool]$EmptyDeletedItems = $false
    )
    
    Write-Host "Starting mailbox cleanup for: $UserPrincipalName" -ForegroundColor Green
    
    try {
        if ($EmptyDeletedItems) {
            # Empty deleted items folder
            Write-Host "Emptying deleted items folder..."
            Search-Mailbox -Identity $UserPrincipalName -SearchDumpsterOnly -DeleteContent -Force
            Write-Host "Deleted items folder emptied" -ForegroundColor Green
        }
        
        # Apply retention policy if not already applied
        $mailbox = Get-Mailbox -Identity $UserPrincipalName
        if (-not $mailbox.RetentionPolicy) {
            Set-Mailbox -Identity $UserPrincipalName -RetentionPolicy "Default MRM Policy"
            Write-Host "Applied default retention policy" -ForegroundColor Green
        }
        
        # Enable archive if not enabled and mailbox is large
        $stats = Get-MailboxStatistics -Identity $UserPrincipalName
        if ($mailbox.ArchiveStatus -eq "None" -and $stats.TotalItemSize.Value.ToGB() -gt 25) {
            Enable-Mailbox -Identity $UserPrincipalName -Archive
            Write-Host "Enabled online archive" -ForegroundColor Green
        }
        
    }
    catch {
        Write-Host "Error during mailbox cleanup: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

## Microsoft Teams Issues

### Teams Meeting Problems

#### Audio/Video Quality Issues
```powershell
# Teams call quality diagnostics
function Test-TeamsCallQuality {
    param([string]$UserPrincipalName)
    
    Write-Host "Analyzing Teams call quality for: $UserPrincipalName" -ForegroundColor Blue
    
    try {
        # Get user's Teams policies
        $user = Get-CsOnlineUser -Identity $UserPrincipalName
        Write-Host "`nUser's Teams Policies:" -ForegroundColor Green
        Write-Host "  Meeting Policy: $($user.TeamsMeetingPolicy)"
        Write-Host "  Calling Policy: $($user.TeamsCallingPolicy)"
        Write-Host "  Messaging Policy: $($user.TeamsMessagingPolicy)"
        
        # Check meeting policy settings
        if ($user.TeamsMeetingPolicy) {
            $meetingPolicy = Get-CsTeamsMeetingPolicy -Identity $user.TeamsMeetingPolicy
            Write-Host "`nMeeting Policy Settings:" -ForegroundColor Green
            Write-Host "  Allow Cloud Recording: $($meetingPolicy.AllowCloudRecording)"
            Write-Host "  Allow Transcription: $($meetingPolicy.AllowTranscription)"
            Write-Host "  Allow Anonymous Users: $($meetingPolicy.AllowAnonymousUsersToStartMeeting)"
            Write-Host "  Media Bit Rate: $($meetingPolicy.MediaBitRateKb)"
        }
        
        # Network connectivity test for Teams
        Write-Host "`nTesting Teams connectivity..." -ForegroundColor Green
        
        $teamsEndpoints = @(
            "teams.microsoft.com:443",
            "*.skype.com:443",
            "*.online.lync.com:443"
        )
        
        foreach ($endpoint in $teamsEndpoints) {
            $server = $endpoint.Split(':')[0]
            $port = $endpoint.Split(':')[1]
            
            $result = Test-NetConnection -ComputerName $server -Port $port -InformationLevel Quiet
            $status = if ($result) { "✓ Connected" } else { "✗ Failed" }
            Write-Host "  $endpoint : $status"
        }
        
        # Check for Teams client issues
        Write-Host "`nTeams Client Diagnostics:" -ForegroundColor Yellow
        Write-Host "1. Check Teams client version (Help > About)"
        Write-Host "2. Clear Teams cache (Exit Teams, delete %appdata%\Microsoft\Teams)"
        Write-Host "3. Test with Teams web client"
        Write-Host "4. Check audio/video devices in Teams settings"
        Write-Host "5. Run Teams Network Assessment Tool"
        
    }
    catch {
        Write-Host "Error during Teams diagnostics: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Teams meeting troubleshooting
function Resolve-TeamsMeetingIssues {
    param([string]$MeetingId)
    
    Write-Host "Troubleshooting Teams meeting: $MeetingId" -ForegroundColor Blue
    
    # Common resolution steps
    $troubleshootingSteps = @(
        "Verify meeting organizer has valid Teams license",
        "Check if meeting policy allows external participants",
        "Ensure lobby settings are appropriate",
        "Verify network bandwidth meets requirements (2+ Mbps)",
        "Test alternative join methods (phone, web)",
        "Check for conflicting calendar entries",
        "Validate meeting bridge configuration"
    )
    
    Write-Host "`nTroubleshooting Checklist:" -ForegroundColor Yellow
    foreach ($step in $troubleshootingSteps) {
        Write-Host "  □ $step"
    }
    
    # Automated checks
    try {
        # Check Teams service health
        $serviceHealth = Get-ServiceHealth | Where-Object {$_.Service -like "*Teams*"}
        if ($serviceHealth) {
            Write-Host "`nTeams Service Health:" -ForegroundColor Green
            $serviceHealth | Select-Object Service, Status, StatusDisplayName | Format-Table
        }
        
        # Check meeting policies that might affect join
        $meetingPolicies = Get-CsTeamsMeetingPolicy
        Write-Host "`nMeeting Policies (Anonymous Join Settings):" -ForegroundColor Green
        $meetingPolicies | Select-Object Identity, AllowAnonymousUsersToStartMeeting, AllowAnonymousUsersToJoinMeeting | Format-Table
        
    }
    catch {
        Write-Host "Unable to perform automated checks: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
```

### Teams Performance Optimization

#### Teams Client Performance
```powershell
# Teams performance optimization
function Optimize-TeamsPerformance {
    Write-Host "Teams Performance Optimization Guide" -ForegroundColor Blue
    
    $optimizations = @{
        "Client Optimization" = @(
            "Close unused applications to free memory",
            "Disable hardware acceleration if experiencing issues",
            "Adjust video quality settings based on bandwidth",
            "Use optimized network connections (Ethernet preferred)",
            "Clear Teams cache regularly",
            "Keep Teams client updated to latest version"
        )
        "Network Optimization" = @(
            "Ensure minimum 2 Mbps bandwidth per user",
            "Configure QoS policies for Teams traffic",
            "Use direct internet connectivity for Teams",
            "Avoid VPN for Teams media traffic when possible",
            "Configure firewall for Teams UDP ports 3478-3481",
            "Enable media bypass for direct routing scenarios"
        )
        "Administrative Optimization" = @(
            "Configure appropriate meeting policies",
            "Limit recording/transcription if not needed",
            "Set appropriate lobby policies",
            "Configure call park and transfer policies",
            "Monitor Teams usage analytics",
            "Implement proper governance policies"
        )
    }
    
    foreach ($category in $optimizations.Keys) {
        Write-Host "`n$category:" -ForegroundColor Green
        foreach ($optimization in $optimizations[$category]) {
            Write-Host "  • $optimization"
        }
    }
    
    # Teams bandwidth calculator
    Write-Host "`nBandwidth Requirements Calculator:" -ForegroundColor Yellow
    $userCount = Read-Host "Enter number of concurrent Teams users"
    
    if ($userCount -as [int]) {
        $audioOnly = [int]$userCount * 0.1  # 100 Kbps per audio call
        $videoSD = [int]$userCount * 0.5    # 500 Kbps per SD video call
        $videoHD = [int]$userCount * 1.5    # 1.5 Mbps per HD video call
        $screenShare = [int]$userCount * 1.0 # 1 Mbps per screen share
        
        Write-Host "Estimated bandwidth requirements:"
        Write-Host "  Audio calls only: $audioOnly Mbps"
        Write-Host "  SD video calls: $videoSD Mbps"
        Write-Host "  HD video calls: $videoHD Mbps"
        Write-Host "  Screen sharing: $screenShare Mbps"
        Write-Host "  Recommended total: $([math]::Ceiling($videoHD * 1.3)) Mbps (with 30% overhead)"
    }
}
```

## SharePoint and OneDrive Issues

### File Synchronization Problems

#### OneDrive Sync Issues
```powershell
# OneDrive sync diagnostics and repair
function Repair-OneDriveSync {
    param([string]$UserPrincipalName)
    
    Write-Host "Diagnosing OneDrive sync for: $UserPrincipalName" -ForegroundColor Blue
    
    try {
        # Check user's OneDrive provisioning status
        $oneDriveUrl = "https://[tenant]-my.sharepoint.com/personal/$($UserPrincipalName.Replace('@','_').Replace('.','_'))"
        
        Connect-SPOService -Url "https://[tenant]-admin.sharepoint.com"
        $site = Get-SPOSite -Identity $oneDriveUrl -ErrorAction SilentlyContinue
        
        if ($site) {
            Write-Host "`nOneDrive Status:" -ForegroundColor Green
            Write-Host "  Site URL: $($site.Url)"
            Write-Host "  Storage Used: $([math]::Round($site.StorageUsageCurrent/1024,2)) GB"
            Write-Host "  Storage Quota: $([math]::Round($site.StorageQuota/1024,2)) GB"
            Write-Host "  Last Activity: $($site.LastContentModifiedDate)"
            Write-Host "  Status: $($site.Status)"
        } else {
            Write-Host "OneDrive not provisioned for user" -ForegroundColor Red
            Write-Host "Provisioning OneDrive..."
            
            # Provision OneDrive
            Request-SPOPersonalSite -UserEmails @($UserPrincipalName)
            Write-Host "OneDrive provisioning requested" -ForegroundColor Green
        }
        
        # Check OneDrive sync client status (if running on user's machine)
        Write-Host "`nOneDrive Sync Client Diagnostics:" -ForegroundColor Yellow
        Write-Host "Run the following on the user's computer:"
        Write-Host "1. Open OneDrive settings (system tray icon)"
        Write-Host "2. Check Account tab for sync status"
        Write-Host "3. Reset OneDrive if needed: %localappdata%\Microsoft\OneDrive\onedrive.exe /reset"
        Write-Host "4. Clear OneDrive cache if sync errors persist"
        
        # Common sync issues and solutions
        $syncIssues = @{
            "Files not syncing" = @(
                "Check file name/path length (<260 characters)",
                "Verify file isn't locked or in use",
                "Check for invalid characters in filename",
                "Ensure sufficient local disk space",
                "Restart OneDrive sync client"
            )
            "Slow sync performance" = @(
                "Check network bandwidth and stability",
                "Pause and resume sync during peak hours",
                "Exclude large files from sync if not needed",
                "Use Files on Demand to save local space",
                "Check antivirus exclusions for OneDrive folder"
            )
            "Sync errors or conflicts" = @(
                "Resolve file conflicts manually",
                "Check file permissions and ownership",
                "Ensure files aren't corrupted",
                "Reset OneDrive sync relationship",
                "Re-link OneDrive account if necessary"
            )
        }
        
        Write-Host "`nCommon Sync Issues and Solutions:" -ForegroundColor Green
        foreach ($issue in $syncIssues.Keys) {
            Write-Host "`n$issue :" -ForegroundColor Yellow
            foreach ($solution in $syncIssues[$issue]) {
                Write-Host "  • $solution"
            }
        }
        
    }
    catch {
        Write-Host "Error during OneDrive diagnostics: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Reset OneDrive sync for user
function Reset-OneDriveSync {
    param([string]$UserPrincipalName)
    
    Write-Host "Resetting OneDrive sync for: $UserPrincipalName" -ForegroundColor Yellow
    
    # Instructions for user's computer
    $resetSteps = @(
        "Close all Office applications",
        "Press Windows + R, type: %localappdata%\Microsoft\OneDrive\onedrive.exe /reset",
        "Wait for OneDrive to restart (may take few minutes)",
        "Sign back into OneDrive with user credentials",
        "Reconfigure sync folders if needed",
        "Monitor sync status for completion"
    )
    
    Write-Host "`nOneDrive Reset Steps (run on user's computer):" -ForegroundColor Green
    for ($i = 0; $i -lt $resetSteps.Count; $i++) {
        Write-Host "  $($i+1). $($resetSteps[$i])"
    }
    
    Write-Host "`nNote: This will re-download all OneDrive files" -ForegroundColor Yellow
}
```

### SharePoint Site Performance Issues

#### Site Performance Optimization
```powershell
# SharePoint site performance analysis
function Test-SharePointSitePerformance {
    param([string]$SiteUrl)
    
    Write-Host "Analyzing SharePoint site performance: $SiteUrl" -ForegroundColor Blue
    
    try {
        Connect-PnPOnline -Url $SiteUrl -Interactive
        
        # Get site information
        $site = Get-PnPSite -Includes Usage
        $web = Get-PnPWeb
        
        Write-Host "`nSite Information:" -ForegroundColor Green
        Write-Host "  Site URL: $($site.Url)"
        Write-Host "  Title: $($web.Title)"
        Write-Host "  Template: $($web.WebTemplate)"
        Write-Host "  Last Modified: $($web.LastItemModifiedDate)"
        Write-Host "  Storage Used: $([math]::Round($site.Usage.Storage/1024/1024/1024,2)) GB"
        
        # Check large lists and libraries
        $lists = Get-PnPList | Where-Object {$_.ItemCount -gt 5000}
        if ($lists) {
            Write-Host "`nLarge Lists/Libraries (>5000 items):" -ForegroundColor Yellow
            $lists | Select-Object Title, ItemCount, BaseType | Format-Table
            
            Write-Host "Performance Impact: Large lists may cause slow loading times"
            Write-Host "Recommendations:"
            Write-Host "• Use indexed columns for filtering and sorting"
            Write-Host "• Implement list view thresholds"
            Write-Host "• Consider list partitioning for very large lists"
            Write-Host "• Use modern SharePoint experience"
        }
        
        # Check site pages and performance
        $pages = Get-PnPListItem -List "Site Pages" -Fields "FileLeafRef","Created","Modified"
        Write-Host "`nSite Pages: $($pages.Count) pages found" -ForegroundColor Green
        
        # Performance recommendations
        Write-Host "`nPerformance Optimization Recommendations:" -ForegroundColor Green
        Write-Host "• Use modern SharePoint pages and web parts"
        Write-Host "• Optimize images for web (compress and resize)"
        Write-Host "• Enable Office 365 CDN for faster content delivery"
        Write-Host "• Use minimal custom CSS and JavaScript"
        Write-Host "• Implement proper information architecture"
        Write-Host "• Regular site collection maintenance"
        
        # Check if modern experience is enabled
        if ($web.WebTemplate -eq "STS") {
            Write-Host "`nModern Experience Status:" -ForegroundColor Yellow
            $modernListExperience = Get-PnPWeb -Includes ListExperienceOptions
            Write-Host "  Modern Lists: $($modernListExperience.ListExperienceOptions)"
        }
        
    }
    catch {
        Write-Host "Error analyzing site performance: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Disconnect-PnPOnline -ErrorAction SilentlyContinue
    }
}

# Optimize SharePoint site performance
function Optimize-SharePointSite {
    param([string]$SiteUrl)
    
    Write-Host "Optimizing SharePoint site: $SiteUrl" -ForegroundColor Blue
    
    try {
        Connect-PnPOnline -Url $SiteUrl -Interactive
        
        # Enable modern lists and libraries where possible
        $lists = Get-PnPList | Where-Object {$_.BaseType -eq "GenericList" -and $_.ListExperienceOptions -ne "ModernExperience"}
        foreach ($list in $lists) {
            try {
                Set-PnPList -Identity $list.Title -ListExperience ModernExperience
                Write-Host "Enabled modern experience for list: $($list.Title)" -ForegroundColor Green
            }
            catch {
                Write-Host "Could not enable modern experience for: $($list.Title)" -ForegroundColor Yellow
            }
        }
        
        # Check and optimize site collection features
        $features = Get-PnPFeature -Scope Site
        Write-Host "`nSite Collection Features: $($features.Count) active features" -ForegroundColor Green
        
        # Recommendations for optimization
        Write-Host "`nOptimization Complete. Additional Manual Steps:" -ForegroundColor Yellow
        Write-Host "• Review and archive old content"
        Write-Host "• Optimize search metadata and navigation"
        Write-Host "• Implement content approval workflows if needed"
        Write-Host "• Regular permission cleanup and access reviews"
        Write-Host "• Enable versioning limits on document libraries"
        
    }
    catch {
        Write-Host "Error optimizing site: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Disconnect-PnPOnline -ErrorAction SilentlyContinue
    }
}
```

## Security and Compliance Issues

### Security Alert Investigation

#### Suspicious Activity Analysis
```powershell
# Security incident investigation toolkit
function Investigate-SecurityIncident {
    param(
        [string]$UserPrincipalName,
        [datetime]$StartDate = (Get-Date).AddDays(-7),
        [datetime]$EndDate = (Get-Date)
    )
    
    Write-Host "Investigating security incident for: $UserPrincipalName" -ForegroundColor Red
    Write-Host "Investigation period: $StartDate to $EndDate" -ForegroundColor Yellow
    
    try {
        # Check sign-in logs for anomalies
        Write-Host "`n1. Analyzing Sign-in Activities..." -ForegroundColor Blue
        $signInLogs = Get-AzureADAuditSignInLogs -Filter "userPrincipalName eq '$UserPrincipalName'" -Top 50
        
        # Identify risky sign-ins
        $riskySignIns = $signInLogs | Where-Object {
            $_.RiskLevelDuringSignIn -ne "none" -or 
            $_.RiskLevelAggregated -ne "none" -or
            $_.Status.ErrorCode -ne 0
        }
        
        if ($riskySignIns) {
            Write-Host "RISKY SIGN-INS DETECTED:" -ForegroundColor Red
            $riskySignIns | Select-Object CreatedDateTime, IpAddress, Location, RiskLevelDuringSignIn, Status | Format-Table
        }
        
        # Check for unusual locations
        $locations = $signInLogs | Select-Object -ExpandProperty Location | 
                    Where-Object {$_.CountryOrRegion} | 
                    Group-Object CountryOrRegion | 
                    Sort-Object Count -Descending
        
        Write-Host "`nSign-in Locations:" -ForegroundColor Green
        $locations | Select-Object Name, Count | Format-Table
        
        # Analyze IP addresses
        $ipAddresses = $signInLogs | Group-Object IpAddress | Sort-Object Count -Descending | Select-Object -First 10
        Write-Host "Top IP Addresses:" -ForegroundColor Green
        $ipAddresses | Select-Object Name, Count | Format-Table
        
        # Check for failed authentication attempts
        $failedLogins = $signInLogs | Where-Object {$_.Status.ErrorCode -ne 0}
        if ($failedLogins) {
            Write-Host "FAILED LOGIN ATTEMPTS:" -ForegroundColor Red
            $failedLogins | Select-Object CreatedDateTime, IpAddress, @{Name="Error";Expression={$_.Status.FailureReason}} | Format-Table
        }
        
        # 2. Check audit logs for suspicious activities
        Write-Host "`n2. Analyzing Audit Activities..." -ForegroundColor Blue
        $auditLogs = Search-UnifiedAuditLog -UserIds $UserPrincipalName -StartDate $StartDate -EndDate $EndDate -ResultSize 1000
        
        if ($auditLogs) {
            # Group activities by operation
            $activities = $auditLogs | Group-Object Operation | Sort-Object Count -Descending | Select-Object -First 10
            Write-Host "Top User Activities:" -ForegroundColor Green
            $activities | Select-Object Name, Count | Format-Table
            
            # Look for suspicious activities
            $suspiciousOperations = @(
                "MailItemsAccessed",
                "FileDownloaded", 
                "FileSyncDownloaded",
                "SharePointFileOperation",
                "UserLoginFailed"
            )
            
            $suspicious = $auditLogs | Where-Object {$_.Operations -in $suspiciousOperations}
            if ($suspicious) {
                Write-Host "SUSPICIOUS ACTIVITIES:" -ForegroundColor Red
                $suspicious | Select-Object CreationDate, Operation, ObjectId | Format-Table
            }
        }
        
        # 3. Check mailbox access
        Write-Host "`n3. Analyzing Email Activities..." -ForegroundColor Blue
        try {
            $mailboxAudit = Search-MailboxAuditLog -Identity $UserPrincipalName -StartDate $StartDate -EndDate $EndDate -LogonTypes Admin,Delegate,Owner -ShowDetails
            
            if ($mailboxAudit) {
                Write-Host "Mailbox Access Activities:" -ForegroundColor Green
                $mailboxAudit | Select-Object LastAccessed, LogonType, Operation, FolderPathName | Format-Table -AutoSize
            }
        }
        catch {
            Write-Host "Mailbox audit log not available or insufficient permissions" -ForegroundColor Yellow
        }
        
        # 4. Generate investigation summary
        Write-Host "`n4. Investigation Summary:" -ForegroundColor Blue
        Write-Host "Total sign-ins: $($signInLogs.Count)"
        Write-Host "Risky sign-ins: $($riskySignIns.Count)"
        Write-Host "Failed logins: $($failedLogins.Count)"
        Write-Host "Audit activities: $($auditLogs.Count)"
        Write-Host "Unique locations: $($locations.Count)"
        
        # Recommendations
        Write-Host "`nRecommended Actions:" -ForegroundColor Yellow
        if ($riskySignIns.Count -gt 0) {
            Write-Host "• Force password reset for user"
            Write-Host "• Enable additional MFA methods"
            Write-Host "• Block sign-ins from risky locations"
        }
        if ($failedLogins.Count -gt 10) {
            Write-Host "• Investigate potential brute force attack"
            Write-Host "• Consider temporary account lockout"
        }
        Write-Host "• Review and revoke unnecessary application permissions"
        Write-Host "• Monitor user activity for next 30 days"
        Write-Host "• Document findings in incident report"
        
    }
    catch {
        Write-Host "Error during security investigation: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Automated incident response
function Invoke-IncidentResponse {
    param(
        [string]$UserPrincipalName,
        [string]$ResponseLevel = "Standard"  # Options: Light, Standard, Severe
    )
    
    Write-Host "Initiating incident response for: $UserPrincipalName" -ForegroundColor Red
    Write-Host "Response Level: $ResponseLevel" -ForegroundColor Yellow
    
    try {
        switch ($ResponseLevel) {
            "Light" {
                Write-Host "Light Response Actions:" -ForegroundColor Green
                Write-Host "• Forcing MFA re-registration"
                Set-MsolUser -UserPrincipalName $UserPrincipalName -StrongAuthenticationRequirements @()
                Write-Host "• Revoking all refresh tokens"
                Revoke-AzureADUserAllRefreshToken -ObjectId $UserPrincipalName
                Write-Host "Light response completed"
            }
            
            "Standard" {
                Write-Host "Standard Response Actions:" -ForegroundColor Yellow
                Write-Host "• Disabling user account temporarily"
                Set-AzureADUser -ObjectId $UserPrincipalName -AccountEnabled $false
                Write-Host "• Revoking all sessions and tokens"
                Revoke-AzureADUserAllRefreshToken -ObjectId $UserPrincipalName
                Write-Host "• Resetting user password"
                $tempPassword = "TempPass$(Get-Random -Minimum 1000 -Maximum 9999)!"
                Set-AzureADUserPassword -ObjectId $UserPrincipalName -Password (ConvertTo-SecureString $tempPassword -AsPlainText -Force) -ForceChangePasswordNextLogin $true
                Write-Host "Temporary password: $tempPassword" -ForegroundColor Red
                Write-Host "Standard response completed"
            }
            
            "Severe" {
                Write-Host "Severe Response Actions:" -ForegroundColor Red
                Write-Host "• Immediately disabling user account"
                Set-AzureADUser -ObjectId $UserPrincipalName -AccountEnabled $false
                Write-Host "• Revoking all sessions and application access"
                Revoke-AzureADUserAllRefreshToken -ObjectId $UserPrincipalName
                Write-Host "• Converting mailbox to shared (preserving data)"
                Set-Mailbox -Identity $UserPrincipalName -Type Shared
                Write-Host "• Removing from all security groups"
                $groups = Get-AzureADUserMembership -ObjectId $UserPrincipalName
                foreach ($group in $groups) {
                    if ($group.SecurityEnabled) {
                        Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $UserPrincipalName
                    }
                }
                Write-Host "Severe response completed - Account isolated"
            }
        }
        
        # Log incident response
        Write-Host "`nIncident Response Log Entry:" -ForegroundColor Blue
        Write-Host "Timestamp: $(Get-Date)"
        Write-Host "User: $UserPrincipalName"
        Write-Host "Response Level: $ResponseLevel"
        Write-Host "Actions Completed: See above"
        
    }
    catch {
        Write-Host "Error during incident response: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

## Performance Monitoring and Optimization

### System-Wide Performance Analysis

#### Microsoft 365 Health Dashboard
```powershell
# Comprehensive M365 health check
function Get-M365HealthDashboard {
    Write-Host "Microsoft 365 Health Dashboard" -ForegroundColor Blue
    Write-Host "================================" -ForegroundColor Blue
    
    try {
        # 1. Service Health Check
        Write-Host "`n1. Service Health Status:" -ForegroundColor Green
        $serviceHealth = Get-ServiceHealth
        $serviceIssues = $serviceHealth | Where-Object {$_.Status -ne "ServiceOperational"}
        
        if ($serviceIssues) {
            Write-Host "SERVICE ISSUES DETECTED:" -ForegroundColor Red
            $serviceIssues | Select-Object Service, Status, StatusDisplayName | Format-Table
        } else {
            Write-Host "✓ All services operational" -ForegroundColor Green
        }
        
        # 2. License Utilization
        Write-Host "`n2. License Utilization:" -ForegroundColor Green
        $licenses = Get-MsolAccountSku
        foreach ($license in $licenses) {
            $used = $license.ConsumedUnits
            $total = $license.ActiveUnits
            $percentage = if ($total -gt 0) { [math]::Round(($used / $total) * 100, 1) } else { 0 }
            
            $status = if ($percentage -gt 90) { "Red" } 
                     elseif ($percentage -gt 80) { "Yellow" } 
                     else { "Green" }
                     
            Write-Host "  $($license.SkuPartNumber): $used/$total ($percentage%)" -ForegroundColor $status
        }
        
        # 3. User Activity Summary
        Write-Host "`n3. User Activity Summary:" -ForegroundColor Green
        $activeUsers = (Get-MsolUser -All | Where-Object {$_.IsLicensed -eq $true}).Count
        $totalUsers = (Get-MsolUser -All).Count
        Write-Host "  Total Users: $totalUsers"
        Write-Host "  Licensed Users: $activeUsers"
        Write-Host "  Utilization: $([math]::Round(($activeUsers/$totalUsers)*100,1))%"
        
        # 4. Recent Alert Summary
        Write-Host "`n4. Recent Security Alerts:" -ForegroundColor Green
        try {
            $alerts = Get-ProtectionAlert | Where-Object {$_.Status -eq "Active"} | Select-Object -First 5
            if ($alerts) {
                $alerts | Select-Object Name, Category, Severity, Date | Format-Table
            } else {
                Write-Host "  ✓ No active security alerts"
            }
        }
        catch {
            Write-Host "  Unable to retrieve security alerts" -ForegroundColor Yellow
        }
        
        # 5. Storage Usage
        Write-Host "`n5. Storage Usage Summary:" -ForegroundColor Green
        try {
            Connect-SPOService -Url "https://[tenant]-admin.sharepoint.com"
            $sites = Get-SPOSite -Limit All | Measure-Object StorageUsageCurrent -Sum
            $totalStorage = [math]::Round($sites.Sum / 1024 / 1024, 2)  # Convert to GB
            Write-Host "  Total SharePoint Storage: $totalStorage GB"
        }
        catch {
            Write-Host "  Unable to retrieve storage information" -ForegroundColor Yellow
        }
        
        # 6. Performance Metrics
        Write-Host "`n6. Performance Indicators:" -ForegroundColor Green
        Write-Host "  Exchange Response Time: < 2 seconds (target)"
        Write-Host "  SharePoint Page Load: < 5 seconds (target)"
        Write-Host "  Teams Call Quality: > 4.0 MOS (target)"
        Write-Host "  OneDrive Sync Speed: > 10 Mbps (target)"
        
        # 7. Recommendations
        Write-Host "`n7. Optimization Recommendations:" -ForegroundColor Yellow
        if ($serviceIssues.Count -gt 0) {
            Write-Host "  • Address active service issues"
        }
        
        $highLicenseUsage = $licenses | Where-Object { 
            $_.ActiveUnits -gt 0 -and ($_.ConsumedUnits / $_.ActiveUnits) -gt 0.9 
        }
        if ($highLicenseUsage) {
            Write-Host "  • Consider additional license procurement"
        }
        
        Write-Host "  • Regular security posture review"
        Write-Host "  • Monthly usage analytics review"
        Write-Host "  • Quarterly performance optimization"
        
    }
    catch {
        Write-Host "Error generating health dashboard: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Performance trend analysis
function Get-PerformanceTrends {
    param([int]$DaysBack = 30)
    
    Write-Host "Performance Trend Analysis (Last $DaysBack days)" -ForegroundColor Blue
    
    try {
        # Email performance trends
        Write-Host "`nEmail Performance Trends:" -ForegroundColor Green
        $emailMetrics = @()
        for ($i = $DaysBack; $i -ge 1; $i--) {
            $date = (Get-Date).AddDays(-$i)
            $traces = Get-MessageTrace -StartDate $date -EndDate $date.AddHours(23) -PageSize 1000
            
            if ($traces) {
                $avgDeliveryTime = ($traces | Measure-Object -Property Received -Average).Average
                $failureRate = ($traces | Where-Object {$_.Status -ne "Delivered"}).Count / $traces.Count * 100
                
                $emailMetrics += [PSCustomObject]@{
                    Date = $date.ToString("MM-dd")
                    Messages = $traces.Count
                    FailureRate = [math]::Round($failureRate, 2)
                }
            }
        }
        
        if ($emailMetrics) {
            $emailMetrics | Format-Table
        } else {
            Write-Host "Insufficient data for email trend analysis"
        }
        
        # SharePoint performance indicators
        Write-Host "`nSharePoint Activity Trends:" -ForegroundColor Green
        Write-Host "Note: Use SharePoint Admin Center Analytics for detailed trends"
        
        # Teams usage trends
        Write-Host "`nTeams Usage Indicators:" -ForegroundColor Green
        Write-Host "Note: Use Teams Admin Center Analytics for detailed usage trends"
        
    }
    catch {
        Write-Host "Error analyzing performance trends: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

## Recovery and Disaster Response

### Data Recovery Procedures

#### Deleted Item Recovery
```powershell
# Comprehensive data recovery toolkit
function Restore-DeletedContent {
    param(
        [string]$ContentType,  # Email, File, Site
        [string]$UserIdentifier,
        [string]$SearchTerm,
        [datetime]$DeletedAfter = (Get-Date).AddDays(-30)
    )
    
    Write-Host "Content Recovery Process Started" -ForegroundColor Blue
    Write-Host "Content Type: $ContentType" -ForegroundColor Green
    Write-Host "User: $UserIdentifier" -ForegroundColor Green
    Write-Host "Search Term: $SearchTerm" -ForegroundColor Green
    
    switch ($ContentType) {
        "Email" {
            Write-Host "`nSearching for deleted emails..." -ForegroundColor Yellow
            
            # Create compliance search for deleted emails
            $searchName = "EmailRecovery-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            $query = "Subject:""$SearchTerm"" AND Received>=$($DeletedAfter.ToString('yyyy-MM-dd'))"
            
            try {
                # Search in recoverable items
                $search = New-ComplianceSearch -Name $searchName -ExchangeLocation $UserIdentifier -ContentMatchQuery $query -IncludeOrgContent $false
                Start-ComplianceSearch -Identity $searchName
                
                # Wait for search completion
                do {
                    Start-Sleep -Seconds 10
                    $searchStatus = Get-ComplianceSearch -Identity $searchName
                    Write-Host "Search status: $($searchStatus.Status)" -ForegroundColor Yellow
                } while ($searchStatus.Status -eq "InProgress")
                
                if ($searchStatus.Items -gt 0) {
                    Write-Host "Found $($searchStatus.Items) recoverable email items" -ForegroundColor Green
                    
                    # Restore to user's mailbox
                    $restoreAction = New-ComplianceSearchAction -SearchName $searchName -Preview
                    Write-Host "Recovery action created: $($restoreAction.Name)"
                    Write-Host "Review items and run New-ComplianceSearchAction -SearchName $searchName -Purge -PurgeType SoftDelete to restore"
                } else {
                    Write-Host "No recoverable email items found" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Email recovery failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        "File" {
            Write-Host "`nSearching for deleted files..." -ForegroundColor Yellow
            
            try {
                # Connect to user's OneDrive
                $oneDriveUrl = "https://[tenant]-my.sharepoint.com/personal/$($UserIdentifier.Replace('@','_').Replace('.','_'))"
                Connect-PnPOnline -Url $oneDriveUrl -Interactive
                
                # Check recycle bin
                $recycledItems = Get-PnPRecycleBinItem | Where-Object {$_.Title -like "*$SearchTerm*"}
                
                if ($recycledItems) {
                    Write-Host "Found $($recycledItems.Count) items in recycle bin:" -ForegroundColor Green
                    $recycledItems | Select-Object Title, DeletedDate, DirName | Format-Table
                    
                    foreach ($item in $recycledItems) {
                        $restore = Read-Host "Restore '$($item.Title)'? (Y/N)"
                        if ($restore -eq 'Y') {
                            Restore-PnPRecycleBinItem -Identity $item.Id
                            Write-Host "Restored: $($item.Title)" -ForegroundColor Green
                        }
                    }
                } else {
                    Write-Host "No matching files found in recycle bin" -ForegroundColor Yellow
                    
                    # Check second-stage recycle bin
                    $siteRecycledItems = Get-PnPRecycleBinItem -SecondStage | Where-Object {$_.Title -like "*$SearchTerm*"}
                    if ($siteRecycledItems) {
                        Write-Host "Found $($siteRecycledItems.Count) items in site collection recycle bin" -ForegroundColor Green
                        $siteRecycledItems | Select-Object Title, DeletedDate | Format-Table
                    }
                }
            }
            catch {
                Write-Host "File recovery failed: $($_.Exception.Message)" -ForegroundColor Red
            }
            finally {
                Disconnect-PnPOnline -ErrorAction SilentlyContinue
            }
        }
        
        "Site" {
            Write-Host "`nSearching for deleted sites..." -ForegroundColor Yellow
            
            try {
                Connect-SPOService -Url "https://[tenant]-admin.sharepoint.com"
                
                # Check deleted site collections
                $deletedSites = Get-SPODeletedSite | Where-Object {$_.Url -like "*$SearchTerm*" -or $_.Title -like "*$SearchTerm*"}
                
                if ($deletedSites) {
                    Write-Host "Found $($deletedSites.Count) deleted sites:" -ForegroundColor Green
                    $deletedSites | Select-Object Title, Url, DeletionTime | Format-Table
                    
                    foreach ($site in $deletedSites) {
                        $restore = Read-Host "Restore site '$($site.Title)'? (Y/N)"
                        if ($restore -eq 'Y') {
                            Restore-SPODeletedSite -Identity $site.Url
                            Write-Host "Restored site: $($site.Title)" -ForegroundColor Green
                        }
                    }
                } else {
                    Write-Host "No matching deleted sites found" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Site recovery failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        default {
            Write-Host "Invalid content type specified" -ForegroundColor Red
            Write-Host "Valid options: Email, File, Site"
        }
    }
}

# Bulk data recovery for major incidents
function Invoke-MassDataRecovery {
    param(
        [string]$IncidentType,  # Ransomware, AccidentalDeletion, UserError
        [datetime]$IncidentDate,
        [array]$AffectedUsers
    )
    
    Write-Host "Mass Data Recovery Operation" -ForegroundColor Red
    Write-Host "Incident Type: $IncidentType" -ForegroundColor Yellow
    Write-Host "Incident Date: $IncidentDate" -ForegroundColor Yellow
    Write-Host "Affected Users: $($AffectedUsers.Count)" -ForegroundColor Yellow
    
    # Recovery strategy based on incident type
    switch ($IncidentType) {
        "Ransomware" {
            Write-Host "`nRansomware Recovery Protocol:" -ForegroundColor Red
            Write-Host "1. Isolate affected accounts immediately"
            Write-Host "2. Restore from backup or recycle bin"
            Write-Host "3. Scan for malware indicators"
            Write-Host "4. Implement additional security measures"
            
            foreach ($user in $AffectedUsers) {
                Write-Host "`nProcessing user: $user" -ForegroundColor Yellow
                
                # Disable user account temporarily
                Set-AzureADUser -ObjectId $user -AccountEnabled $false
                Write-Host "  Account disabled for security"
                
                # Check for encrypted files in OneDrive
                try {
                    $oneDriveUrl = "https://[tenant]-my.sharepoint.com/personal/$($user.Replace('@','_').Replace('.','_'))"
                    Connect-PnPOnline -Url $oneDriveUrl -Interactive
                    
                    # Look for suspicious file extensions
                    $suspiciousFiles = Get-PnPListItem -List "Documents" -Fields "FileLeafRef" | 
                        Where-Object {$_.FieldValues.FileLeafRef -match '\.(encrypted|locked|crypto)$'}
                    
                    if ($suspiciousFiles) {
                        Write-Host "  Found $($suspiciousFiles.Count) potentially encrypted files" -ForegroundColor Red
                    }
                    
                    Disconnect-PnPOnline
                }
                catch {
                    Write-Host "  Error checking OneDrive: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        
        "AccidentalDeletion" {
            Write-Host "`nAccidental Deletion Recovery:" -ForegroundColor Yellow
            
            foreach ($user in $AffectedUsers) {
                Write-Host "`nRecovering data for: $user" -ForegroundColor Green
                
                # Restore deleted emails
                Restore-DeletedContent -ContentType "Email" -UserIdentifier $user -SearchTerm "*" -DeletedAfter $IncidentDate
                
                # Restore deleted files
                Restore-DeletedContent -ContentType "File" -UserIdentifier $user -SearchTerm "*" -DeletedAfter $IncidentDate
            }
        }
        
        "UserError" {
            Write-Host "`nUser Error Recovery (Selective Restore):" -ForegroundColor Yellow
            Write-Host "Manual review required for each restoration"
            
            foreach ($user in $AffectedUsers) {
                Write-Host "`nUser: $user - Review and restore as needed" -ForegroundColor Green
            }
        }
    }
    
    # Post-recovery checklist
    Write-Host "`nPost-Recovery Checklist:" -ForegroundColor Blue
    Write-Host "□ Verify data integrity"
    Write-Host "□ Test user access and functionality"
    Write-Host "□ Update security policies if needed"
    Write-Host "□ Document lessons learned"
    Write-Host "□ Communicate resolution to users"
    Write-Host "□ Schedule follow-up monitoring"
}
```

This comprehensive troubleshooting guide provides the tools and procedures needed to diagnose, resolve, and recover from common Microsoft 365 issues across all service areas. Regular use of these diagnostic scripts and procedures helps maintain optimal system performance and quickly resolve user problems.