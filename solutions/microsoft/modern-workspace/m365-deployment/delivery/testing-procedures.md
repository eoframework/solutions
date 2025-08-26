# Microsoft 365 Enterprise Deployment - Testing Procedures

This document provides comprehensive testing methodologies and validation procedures for Microsoft 365 enterprise deployments. These procedures ensure successful implementation, optimal performance, and user readiness before production rollout.

## Pre-Deployment Testing

### Infrastructure Readiness Testing

#### Network Connectivity Test
```powershell
# Test Office 365 endpoints connectivity
$endpoints = @(
    "outlook.office365.com:443",
    "*.sharepoint.com:443", 
    "teams.microsoft.com:443",
    "*.microsoftonline.com:443",
    "login.microsoftonline.com:443"
)

foreach ($endpoint in $endpoints) {
    $server = $endpoint.Split(':')[0]
    $port = $endpoint.Split(':')[1]
    
    $result = Test-NetConnection -ComputerName $server -Port $port -InformationLevel Quiet
    Write-Host "Testing $endpoint : $(if ($result) { 'PASS' } else { 'FAIL' })" -ForegroundColor $(if ($result) { 'Green' } else { 'Red' })
}
```

#### Bandwidth Assessment
```powershell
# Bandwidth testing script
function Test-O365Bandwidth {
    param(
        [int]$UserCount = 100,
        [string]$TestDuration = "PT5M"
    )
    
    Write-Host "Bandwidth Requirements Assessment:"
    Write-Host "Users: $UserCount"
    
    # Calculate bandwidth requirements
    $exchangeBandwidth = $UserCount * 0.5  # 0.5 Mbps per user for Exchange
    $teamsBandwidth = $UserCount * 1.2     # 1.2 Mbps per user for Teams
    $sharePointBandwidth = $UserCount * 0.8 # 0.8 Mbps per user for SharePoint
    
    $totalRequired = $exchangeBandwidth + $teamsBandwidth + $sharePointBandwidth
    
    Write-Host "Estimated Bandwidth Requirements:"
    Write-Host "  Exchange Online: $exchangeBandwidth Mbps"
    Write-Host "  Microsoft Teams: $teamsBandwidth Mbps"
    Write-Host "  SharePoint Online: $sharePointBandwidth Mbps"
    Write-Host "  Total Required: $totalRequired Mbps"
    
    # Test actual bandwidth
    $speedTest = Invoke-RestMethod -Uri "http://speedtest.net/api/js/speedtest.js"
    Write-Host "Recommended: Ensure available bandwidth exceeds $($totalRequired * 1.5) Mbps (150% of requirement)"
}
```

### DNS Configuration Validation
```powershell
# Validate DNS records for custom domains
function Test-DNSConfiguration {
    param([string]$Domain)
    
    $records = @{
        "MX" = @("mail.protection.outlook.com", 0)
        "TXT" = @("v=spf1 include:spf.protection.outlook.com -all")
        "CNAME" = @{
            "autodiscover" = "autodiscover.outlook.com"
            "sip" = "sipdir.online.lync.com"
            "lyncdiscover" = "webdir.online.lync.com"
        }
    }
    
    # Test MX record
    $mxRecord = Resolve-DnsName -Name $Domain -Type MX -ErrorAction SilentlyContinue
    if ($mxRecord -and $mxRecord.NameExchange -like "*protection.outlook.com") {
        Write-Host "✓ MX record configured correctly" -ForegroundColor Green
    } else {
        Write-Host "✗ MX record not configured for Office 365" -ForegroundColor Red
    }
    
    # Test SPF record
    $spfRecord = Resolve-DnsName -Name $Domain -Type TXT -ErrorAction SilentlyContinue | 
        Where-Object {$_.Strings -like "v=spf1*"}
    if ($spfRecord) {
        Write-Host "✓ SPF record found" -ForegroundColor Green
    } else {
        Write-Host "✗ SPF record not configured" -ForegroundColor Red
    }
    
    # Test CNAME records
    foreach ($cname in $records.CNAME.GetEnumerator()) {
        $cnameRecord = Resolve-DnsName -Name "$($cname.Key).$Domain" -Type CNAME -ErrorAction SilentlyContinue
        if ($cnameRecord -and $cnameRecord.NameHost -eq $cname.Value) {
            Write-Host "✓ $($cname.Key) CNAME configured correctly" -ForegroundColor Green
        } else {
            Write-Host "✗ $($cname.Key) CNAME not configured" -ForegroundColor Red
        }
    }
}
```

### Client Device Readiness
```powershell
# Test client device compatibility
function Test-ClientReadiness {
    Write-Host "Client Device Readiness Check:"
    
    # OS Version check
    $os = Get-ComputerInfo
    Write-Host "Operating System: $($os.WindowsProductName) $($os.WindowsVersion)"
    
    # Office version check
    $officeVersion = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name "VersionToReport" -ErrorAction SilentlyContinue
    if ($officeVersion) {
        Write-Host "Office Version: $($officeVersion.VersionToReport)"
    } else {
        Write-Host "Office not installed or legacy version detected" -ForegroundColor Yellow
    }
    
    # .NET Framework check
    $netFramework = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name "Release" -ErrorAction SilentlyContinue
    if ($netFramework.Release -ge 461808) {
        Write-Host "✓ .NET Framework 4.7.2 or later installed" -ForegroundColor Green
    } else {
        Write-Host "✗ .NET Framework needs update" -ForegroundColor Red
    }
    
    # PowerShell version check
    if ($PSVersionTable.PSVersion.Major -ge 5) {
        Write-Host "✓ PowerShell version compatible" -ForegroundColor Green
    } else {
        Write-Host "✗ PowerShell needs update" -ForegroundColor Red
    }
}
```

## Identity and Authentication Testing

### Azure AD Authentication Tests
```powershell
# Test Azure AD authentication
function Test-AzureADAuth {
    param([string]$TestUser)
    
    try {
        # Test basic authentication
        $user = Get-AzureADUser -ObjectId $TestUser
        Write-Host "✓ User $TestUser exists in Azure AD" -ForegroundColor Green
        
        # Test user properties
        if ($user.AccountEnabled) {
            Write-Host "✓ User account is enabled" -ForegroundColor Green
        } else {
            Write-Host "✗ User account is disabled" -ForegroundColor Red
        }
        
        # Test licenses
        $licenses = Get-AzureADUserLicenseDetail -ObjectId $TestUser
        if ($licenses) {
            Write-Host "✓ User has licenses assigned:" -ForegroundColor Green
            $licenses | ForEach-Object { Write-Host "  - $($_.SkuPartNumber)" }
        } else {
            Write-Host "✗ No licenses assigned" -ForegroundColor Red
        }
        
        # Test group memberships
        $groups = Get-AzureADUserMembership -ObjectId $TestUser
        Write-Host "User group memberships: $($groups.Count)"
        
    } catch {
        Write-Host "✗ Authentication test failed: $_" -ForegroundColor Red
    }
}
```

### Multi-Factor Authentication Testing
```powershell
# Test MFA configuration
function Test-MFAConfiguration {
    param([string]$TestUser)
    
    # Check MFA status
    $mfaStatus = Get-MsolUser -UserPrincipalName $TestUser | 
        Select-Object DisplayName, UserPrincipalName, 
        @{Name="MFAStatus";Expression={if($_.StrongAuthenticationRequirements.Count -gt 0) {"Enabled"} else {"Disabled"}}}
    
    Write-Host "MFA Status for $TestUser : $($mfaStatus.MFAStatus)"
    
    # Check authentication methods
    $authMethods = Get-MsolUser -UserPrincipalName $TestUser | 
        Select-Object -ExpandProperty StrongAuthenticationMethods
    
    if ($authMethods) {
        Write-Host "Configured MFA methods:"
        $authMethods | ForEach-Object { Write-Host "  - $($_.MethodType)" }
    }
}
```

### Conditional Access Policy Testing
```powershell
# Test conditional access policies
function Test-ConditionalAccess {
    param([string]$TestUser)
    
    # Get user's applied policies
    $signInLogs = Get-AzureADAuditSignInLogs -Filter "userPrincipalName eq '$TestUser'" -Top 10
    
    foreach ($log in $signInLogs) {
        Write-Host "Sign-in: $($log.CreatedDateTime) - Status: $($log.Status.ErrorCode)"
        
        if ($log.AppliedConditionalAccessPolicies) {
            Write-Host "Applied CA Policies:"
            $log.AppliedConditionalAccessPolicies | ForEach-Object {
                Write-Host "  - $($_.DisplayName): $($_.Result)"
            }
        }
    }
}
```

## Service-Specific Testing

### Exchange Online Testing

#### Email Flow Testing
```powershell
# Test email flow end-to-end
function Test-EmailFlow {
    param(
        [string]$FromAddress,
        [string]$ToAddress = $FromAddress
    )
    
    # Send test email
    $subject = "Test Email - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $body = "This is a test email to validate email flow in Microsoft 365."
    
    try {
        Send-MailMessage -From $FromAddress -To $ToAddress -Subject $subject -Body $body -SmtpServer "smtp.office365.com" -UseSSL -Port 587 -Credential $credential
        Write-Host "✓ Test email sent successfully" -ForegroundColor Green
        
        # Wait and check message trace
        Start-Sleep -Seconds 60
        $trace = Get-MessageTrace -SenderAddress $FromAddress -RecipientAddress $ToAddress -StartDate (Get-Date).AddMinutes(-5)
        
        if ($trace) {
            Write-Host "✓ Message trace found - Status: $($trace[0].Status)" -ForegroundColor Green
        } else {
            Write-Host "? Message trace not yet available (may take up to 15 minutes)" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "✗ Email send failed: $_" -ForegroundColor Red
    }
}
```

#### Mailbox Functionality Test
```powershell
# Test mailbox access and functionality
function Test-MailboxFunctionality {
    param([string]$TestUser)
    
    try {
        # Test mailbox existence and access
        $mailbox = Get-Mailbox -Identity $TestUser
        Write-Host "✓ Mailbox exists for $TestUser" -ForegroundColor Green
        
        # Test mailbox statistics
        $stats = Get-MailboxStatistics -Identity $TestUser
        Write-Host "✓ Mailbox accessible - Items: $($stats.ItemCount), Size: $([math]::Round($stats.TotalItemSize.Value.ToMB()/1024,2)) GB"
        
        # Test calendar access
        $calendar = Get-MailboxFolderStatistics -Identity $TestUser -FolderScope Calendar
        Write-Host "✓ Calendar accessible - Items: $($calendar.ItemsInFolder)"
        
        # Test mobile device connectivity
        $mobileDevices = Get-MobileDevice -Mailbox $TestUser
        if ($mobileDevices) {
            Write-Host "✓ Mobile devices connected: $($mobileDevices.Count)"
        }
        
    } catch {
        Write-Host "✗ Mailbox test failed: $_" -ForegroundColor Red
    }
}
```

#### Anti-malware and Anti-spam Testing
```powershell
# Test security filtering
function Test-EmailSecurity {
    Write-Host "Email Security Configuration Test:"
    
    # Check anti-malware policy
    $malwarePolicy = Get-MalwareFilterPolicy -Identity Default
    Write-Host "✓ Anti-malware enabled: $($malwarePolicy.EnableFileFilter)"
    Write-Host "  Blocked file types: $($malwarePolicy.FileTypes -join ', ')"
    
    # Check anti-spam policy  
    $spamPolicy = Get-HostedContentFilterPolicy -Identity Default
    Write-Host "✓ Anti-spam bulk threshold: $($spamPolicy.BulkThreshold)"
    Write-Host "  Spam action: $($spamPolicy.SpamAction)"
    
    # Check Safe Attachments
    $safeAttachments = Get-SafeAttachmentPolicy
    if ($safeAttachments) {
        Write-Host "✓ Safe Attachments policies: $($safeAttachments.Count)"
        $safeAttachments | ForEach-Object { Write-Host "  - $($_.Name): $($_.Action)" }
    }
    
    # Check Safe Links
    $safeLinks = Get-SafeLinksPolicy
    if ($safeLinks) {
        Write-Host "✓ Safe Links policies: $($safeLinks.Count)"
        $safeLinks | ForEach-Object { Write-Host "  - $($_.Name): Enabled=$($_.IsEnabled)" }
    }
}
```

### SharePoint Online Testing

#### Site Access and Functionality
```powershell
# Test SharePoint site functionality
function Test-SharePointSite {
    param([string]$SiteUrl)
    
    try {
        # Test site access
        $site = Get-SPOSite -Identity $SiteUrl
        Write-Host "✓ Site accessible: $SiteUrl" -ForegroundColor Green
        Write-Host "  Storage used: $($site.StorageUsageCurrent) MB of $($site.StorageQuota) MB"
        Write-Host "  Sharing capability: $($site.SharingCapability)"
        
        # Test document library
        Connect-PnPOnline -Url $SiteUrl -Interactive
        $libraries = Get-PnPList | Where-Object {$_.BaseTemplate -eq 101}
        
        foreach ($library in $libraries) {
            $items = Get-PnPListItem -List $library.Title -PageSize 1
            Write-Host "✓ Document library '$($library.Title)' - Items: $($library.ItemCount)"
        }
        
        # Test permissions
        $siteUsers = Get-PnPUser
        Write-Host "✓ Site has $($siteUsers.Count) users/groups with access"
        
    } catch {
        Write-Host "✗ SharePoint test failed: $_" -ForegroundColor Red
    }
}
```

#### OneDrive Provisioning Test
```powershell
# Test OneDrive for Business provisioning
function Test-OneDriveProvisioning {
    param([string]$TestUser)
    
    try {
        # Check OneDrive provisioning
        $oneDriveUrl = "https://[tenant]-my.sharepoint.com/personal/$($TestUser.Replace('@','_').Replace('.','_'))"
        
        $site = Get-SPOSite -Identity $oneDriveUrl -ErrorAction SilentlyContinue
        if ($site) {
            Write-Host "✓ OneDrive provisioned for $TestUser" -ForegroundColor Green
            Write-Host "  Storage used: $($site.StorageUsageCurrent) MB"
            Write-Host "  Last activity: $($site.LastContentModifiedDate)"
        } else {
            Write-Host "✗ OneDrive not yet provisioned for $TestUser" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "✗ OneDrive test failed: $_" -ForegroundColor Red
    }
}
```

### Microsoft Teams Testing

#### Teams Functionality Test
```powershell
# Test Microsoft Teams functionality
function Test-TeamsUser {
    param([string]$TestUser)
    
    try {
        # Check Teams licensing
        $user = Get-CsOnlineUser -Identity $TestUser
        Write-Host "✓ Teams user found: $TestUser" -ForegroundColor Green
        Write-Host "  Teams enabled: $($user.Enabled)"
        Write-Host "  Meeting policy: $($user.TeamsMeetingPolicy)"
        Write-Host "  Messaging policy: $($user.TeamsMessagingPolicy)"
        
        # Check Teams client connectivity
        $teamsVersion = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams" -ErrorAction SilentlyContinue
        if ($teamsVersion) {
            Write-Host "✓ Teams client installed: $($teamsVersion.DisplayVersion)"
        }
        
        # Test meeting join capability (would require manual validation)
        Write-Host "? Manual test required: Create test meeting and verify join capability"
        
    } catch {
        Write-Host "✗ Teams test failed: $_" -ForegroundColor Red
    }
}
```

#### Teams Policy Validation
```powershell
# Validate Teams policies are applied correctly
function Test-TeamsPolicies {
    # Get all Teams policies
    $meetingPolicies = Get-CsTeamsMeetingPolicy
    $messagingPolicies = Get-CsTeamsMessagingPolicy
    $callingPolicies = Get-CsTeamsCallingPolicy
    
    Write-Host "Teams Policy Configuration:"
    Write-Host "  Meeting policies: $($meetingPolicies.Count)"
    Write-Host "  Messaging policies: $($messagingPolicies.Count)"
    Write-Host "  Calling policies: $($callingPolicies.Count)"
    
    # Test policy assignment
    $users = Get-CsOnlineUser -ResultSize 10
    foreach ($user in $users) {
        Write-Host "User: $($user.DisplayName)"
        Write-Host "  Meeting: $($user.TeamsMeetingPolicy)"
        Write-Host "  Messaging: $($user.TeamsMessagingPolicy)"
        Write-Host "  Calling: $($user.TeamsCallingPolicy)"
    }
}
```

## Migration Testing

### Email Migration Validation
```powershell
# Test email migration completeness
function Test-EmailMigration {
    param(
        [string]$SourceUser,
        [string]$TargetUser
    )
    
    Write-Host "Email Migration Validation for $SourceUser -> $TargetUser"
    
    # Check migration batch status
    $migrationBatch = Get-MigrationBatch | Where-Object {$_.Identity -like "*$SourceUser*"}
    if ($migrationBatch) {
        Write-Host "✓ Migration batch found: $($migrationBatch.Identity)"
        Write-Host "  Status: $($migrationBatch.Status)"
        Write-Host "  Total items: $($migrationBatch.TotalCount)"
        Write-Host "  Migrated items: $($migrationBatch.MigratedCount)"
        Write-Host "  Failed items: $($migrationBatch.FailedCount)"
    }
    
    # Compare mailbox statistics
    $targetStats = Get-MailboxStatistics -Identity $TargetUser
    Write-Host "Target mailbox statistics:"
    Write-Host "  Item count: $($targetStats.ItemCount)"
    Write-Host "  Mailbox size: $([math]::Round($targetStats.TotalItemSize.Value.ToMB(),2)) MB"
    
    # Check for missing folders
    $folders = Get-MailboxFolderStatistics -Identity $TargetUser
    $importantFolders = @("Inbox", "Sent Items", "Calendar", "Contacts")
    
    foreach ($folder in $importantFolders) {
        $found = $folders | Where-Object {$_.Name -eq $folder}
        if ($found) {
            Write-Host "✓ $folder found - Items: $($found.ItemsInFolder)" -ForegroundColor Green
        } else {
            Write-Host "✗ $folder missing" -ForegroundColor Red
        }
    }
}
```

### SharePoint Migration Testing
```powershell
# Test SharePoint migration
function Test-SharePointMigration {
    param(
        [string]$SourcePath,
        [string]$TargetSiteUrl
    )
    
    Write-Host "SharePoint Migration Validation"
    Write-Host "Source: $SourcePath"
    Write-Host "Target: $TargetSiteUrl"
    
    # Get source file count (if accessible)
    if (Test-Path $SourcePath) {
        $sourceFiles = Get-ChildItem -Path $SourcePath -Recurse -File
        Write-Host "Source file count: $($sourceFiles.Count)"
        Write-Host "Source total size: $([math]::Round(($sourceFiles | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB"
    }
    
    # Check target site
    Connect-PnPOnline -Url $TargetSiteUrl -Interactive
    $lists = Get-PnPList
    $docLibraries = $lists | Where-Object {$_.BaseTemplate -eq 101}
    
    foreach ($library in $docLibraries) {
        Write-Host "Document library: $($library.Title) - Items: $($library.ItemCount)"
    }
    
    # Test file access
    $testFile = Get-PnPListItem -List "Documents" -PageSize 1 | Select-Object -First 1
    if ($testFile) {
        Write-Host "✓ Files accessible in target site" -ForegroundColor Green
    }
}
```

## Performance Testing

### Load Testing Scripts
```powershell
# Basic performance test for Exchange Online
function Test-ExchangePerformance {
    param([int]$TestDuration = 300) # 5 minutes
    
    Write-Host "Exchange Online Performance Test ($TestDuration seconds)"
    $startTime = Get-Date
    $operations = 0
    $errors = 0
    
    while ((Get-Date) -lt $startTime.AddSeconds($TestDuration)) {
        try {
            # Simulate typical operations
            Get-Mailbox -ResultSize 10 | Out-Null
            $operations++
            
            if ($operations % 10 -eq 0) {
                Write-Host "Operations completed: $operations" -NoNewline -ForegroundColor Green
                Write-Host " | Errors: $errors" -ForegroundColor $(if ($errors -eq 0) {"Green"} else {"Red"})
            }
            
            Start-Sleep -Milliseconds 500
        }
        catch {
            $errors++
        }
    }
    
    $duration = (Get-Date) - $startTime
    Write-Host "Performance test completed:"
    Write-Host "  Duration: $([math]::Round($duration.TotalSeconds, 1)) seconds"
    Write-Host "  Operations: $operations"
    Write-Host "  Errors: $errors"
    Write-Host "  Avg operations/minute: $([math]::Round($operations / $duration.TotalMinutes, 1))"
}
```

### Teams Meeting Performance Test
```powershell
# Teams meeting performance validation
function Test-TeamsMeetingPerformance {
    param([string]$TestUser)
    
    Write-Host "Teams Meeting Performance Test for $TestUser"
    
    # Create test meeting
    $meeting = @{
        Subject = "Performance Test Meeting"
        Start = (Get-Date).AddMinutes(5)
        End = (Get-Date).AddMinutes(35)
        Attendees = @($TestUser)
    }
    
    try {
        # This would require Microsoft Graph API calls
        Write-Host "? Manual validation required:"
        Write-Host "  1. Schedule a test meeting"
        Write-Host "  2. Join from multiple devices/locations"
        Write-Host "  3. Test screen sharing and recording"
        Write-Host "  4. Monitor audio/video quality"
        Write-Host "  5. Verify meeting recording availability"
        
        # Test meeting policies
        $user = Get-CsOnlineUser -Identity $TestUser
        $meetingPolicy = Get-CsTeamsMeetingPolicy -Identity $user.TeamsMeetingPolicy
        
        Write-Host "Meeting policy configuration:"
        Write-Host "  Recording allowed: $($meetingPolicy.AllowCloudRecording)"
        Write-Host "  Transcription allowed: $($meetingPolicy.AllowTranscription)"
        Write-Host "  Screen sharing: $($meetingPolicy.ScreenSharingMode)"
        
    } catch {
        Write-Host "✗ Teams meeting test setup failed: $_" -ForegroundColor Red
    }
}
```

## Security Testing

### Security Posture Validation
```powershell
# Test security configuration
function Test-SecurityPosture {
    Write-Host "Security Posture Validation:"
    
    # Check conditional access policies
    $caPolicies = Get-AzureADMSConditionalAccessPolicy | Where-Object {$_.State -eq "Enabled"}
    Write-Host "✓ Conditional Access policies enabled: $($caPolicies.Count)"
    
    # Check for legacy auth blocking
    $legacyBlock = $caPolicies | Where-Object {$_.Conditions.ClientAppTypes -contains "exchangeActiveSync" -or $_.Conditions.ClientAppTypes -contains "other"}
    if ($legacyBlock) {
        Write-Host "✓ Legacy authentication blocking enabled" -ForegroundColor Green
    } else {
        Write-Host "✗ Legacy authentication blocking not found" -ForegroundColor Red
    }
    
    # Check MFA coverage
    $mfaUsers = Get-MsolUser -All | Where-Object {$_.StrongAuthenticationRequirements.Count -gt 0}
    $totalUsers = Get-MsolUser -All | Measure-Object
    $mfaCoverage = [math]::Round(($mfaUsers.Count / $totalUsers.Count) * 100, 1)
    
    Write-Host "MFA coverage: $mfaCoverage% ($($mfaUsers.Count)/$($totalUsers.Count) users)"
    
    # Check privileged users
    $globalAdmins = Get-AzureADDirectoryRole -Filter "displayName eq 'Global Administrator'" | Get-AzureADDirectoryRoleMember
    Write-Host "Global administrators: $($globalAdmins.Count)"
    
    if ($globalAdmins.Count -gt 5) {
        Write-Host "⚠ Consider reducing number of global administrators" -ForegroundColor Yellow
    }
}
```

### DLP Policy Testing
```powershell
# Test Data Loss Prevention policies
function Test-DLPPolicies {
    Write-Host "DLP Policy Testing:"
    
    # Get DLP policies
    $dlpPolicies = Get-DlpCompliancePolicy
    Write-Host "✓ DLP policies configured: $($dlpPolicies.Count)"
    
    foreach ($policy in $dlpPolicies) {
        Write-Host "Policy: $($policy.Name) - Mode: $($policy.Mode)"
        
        # Get rules for this policy
        $rules = Get-DlpComplianceRule -Policy $policy.Name
        Write-Host "  Rules: $($rules.Count)"
        
        foreach ($rule in $rules) {
            Write-Host "  - $($rule.Name): $($rule.BlockAccess)"
        }
    }
    
    # Test with sample sensitive data (be careful with real data!)
    Write-Host "? Manual DLP test required:"
    Write-Host "  1. Create test document with sample SSN (fake): 123-45-6789"
    Write-Host "  2. Try to share externally"
    Write-Host "  3. Verify DLP policy triggers"
    Write-Host "  4. Check audit logs for DLP events"
}
```

## User Acceptance Testing

### End-User Test Scenarios
```powershell
# Generate UAT test scenarios
function New-UATTestPlan {
    $testScenarios = @(
        @{
            Area = "Email"
            Scenario = "Send and receive emails"
            Steps = @(
                "Send email to internal user",
                "Send email to external user", 
                "Reply to email",
                "Forward email with attachment",
                "Use mobile Outlook app"
            )
            Success = "All emails delivered and received successfully"
        },
        @{
            Area = "Calendar"
            Scenario = "Manage calendar and meetings"
            Steps = @(
                "Create meeting with internal attendees",
                "Create meeting with external attendees",
                "Accept/decline meeting invitations",
                "View calendar on mobile device",
                "Share calendar with colleague"
            )
            Success = "Calendar functions work across all devices"
        },
        @{
            Area = "OneDrive"
            Scenario = "File storage and sharing"
            Steps = @(
                "Upload files to OneDrive",
                "Sync OneDrive to desktop",
                "Share file with internal user",
                "Share file with external user",
                "Access files from mobile app"
            )
            Success = "Files accessible and shareable across platforms"
        },
        @{
            Area = "Teams"
            Scenario = "Collaboration and meetings"
            Steps = @(
                "Join Teams meeting via link",
                "Start video call with colleague",
                "Share screen during meeting",
                "Send chat message to team",
                "Upload file to team channel"
            )
            Success = "Teams collaboration features work reliably"
        },
        @{
            Area = "SharePoint"
            Scenario = "Document collaboration"
            Steps = @(
                "Access team site",
                "Edit document in browser",
                "Co-author document with colleague",
                "Create new document library",
                "Set document permissions"
            )
            Success = "SharePoint sites accessible with proper permissions"
        }
    )
    
    Write-Host "User Acceptance Test Plan Generated:" -ForegroundColor Green
    Write-Host "=================================="
    
    foreach ($test in $testScenarios) {
        Write-Host ""
        Write-Host "Test Area: $($test.Area)" -ForegroundColor Yellow
        Write-Host "Scenario: $($test.Scenario)"
        Write-Host "Steps:"
        $test.Steps | ForEach-Object { Write-Host "  □ $_" }
        Write-Host "Success Criteria: $($test.Success)" -ForegroundColor Green
        Write-Host ""
    }
    
    return $testScenarios
}
```

### User Feedback Collection
```powershell
# UAT feedback collection template
function New-UATFeedbackForm {
    $feedbackForm = @"
User Acceptance Testing Feedback Form
====================================

User Information:
Name: ___________________
Department: ______________
Date: ___________________

Test Results (Rate 1-5, where 5 = Excellent):

Email Functionality:
□ Sending/receiving emails: [ ]
□ Mobile email access: [ ]
□ Calendar integration: [ ]
Comments: _________________________________

OneDrive & File Sharing:
□ File upload/download: [ ]
□ File synchronization: [ ]
□ Sharing capabilities: [ ]
Comments: _________________________________

Microsoft Teams:
□ Meeting participation: [ ]
□ Chat functionality: [ ]
□ Screen sharing: [ ]
Comments: _________________________________

SharePoint Access:
□ Site navigation: [ ]
□ Document editing: [ ]
□ Permission management: [ ]
Comments: _________________________________

Overall Experience:
□ Performance speed: [ ]
□ Ease of use: [ ]
□ Training adequacy: [ ]
□ Overall satisfaction: [ ]

Issues Encountered:
_____________________________________
_____________________________________

Additional Comments:
_____________________________________
_____________________________________

Would you recommend this solution? □ Yes □ No
Why? ________________________________
"@

    $feedbackForm | Out-File -FilePath "UAT_Feedback_Form.txt"
    Write-Host "UAT feedback form created: UAT_Feedback_Form.txt"
}
```

## Test Reporting and Documentation

### Automated Test Report Generation
```powershell
# Generate comprehensive test report
function New-TestReport {
    param([string]$ReportPath = "M365_Test_Report.html")
    
    $reportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $testResults = @{
        InfrastructureTests = @()
        AuthenticationTests = @()
        ServiceTests = @()
        SecurityTests = @()
        PerformanceTests = @()
        MigrationTests = @()
        UATResults = @()
    }
    
    # Run all tests and collect results
    # This would call all the test functions above and collect results
    
    $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Microsoft 365 Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #0078d4; color: white; padding: 20px; text-align: center; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ccc; }
        .pass { color: green; font-weight: bold; }
        .fail { color: red; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Microsoft 365 Enterprise Deployment Test Report</h1>
        <p>Generated on: $reportDate</p>
    </div>
    
    <div class="section">
        <h2>Executive Summary</h2>
        <p>This report summarizes the testing results for the Microsoft 365 enterprise deployment.</p>
        <!-- Add summary statistics here -->
    </div>
    
    <div class="section">
        <h2>Infrastructure Tests</h2>
        <!-- Add infrastructure test results -->
    </div>
    
    <div class="section">
        <h2>Authentication Tests</h2>
        <!-- Add authentication test results -->
    </div>
    
    <div class="section">
        <h2>Service Tests</h2>
        <!-- Add service test results -->
    </div>
    
    <div class="section">
        <h2>Security Tests</h2>
        <!-- Add security test results -->
    </div>
    
    <div class="section">
        <h2>Performance Tests</h2>
        <!-- Add performance test results -->
    </div>
    
    <div class="section">
        <h2>Migration Validation</h2>
        <!-- Add migration test results -->
    </div>
    
    <div class="section">
        <h2>User Acceptance Testing</h2>
        <!-- Add UAT results -->
    </div>
    
    <div class="section">
        <h2>Recommendations</h2>
        <!-- Add recommendations based on test results -->
    </div>
</body>
</html>
"@

    $htmlReport | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Host "Test report generated: $ReportPath" -ForegroundColor Green
}
```

These comprehensive testing procedures ensure a successful Microsoft 365 deployment with proper validation of all components, security measures, and user functionality. Regular execution of these tests throughout the deployment process helps identify and resolve issues early, ensuring a smooth transition to the new platform.