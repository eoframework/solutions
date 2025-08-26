<#
.SYNOPSIS
    Microsoft 365 Enterprise Deployment Automation Script

.DESCRIPTION
    This comprehensive PowerShell script automates the deployment and configuration of 
    Microsoft 365 Enterprise (E5) environments including Azure AD, Exchange Online, 
    SharePoint Online, Microsoft Teams, and security features.

.PARAMETER TenantDomain
    The primary domain for the Microsoft 365 tenant (e.g., company.onmicrosoft.com)

.PARAMETER DeploymentPhase
    The deployment phase to execute. Options: Foundation, CoreServices, AdvancedFeatures, Optimization, All

.PARAMETER ConfigurationPath
    Path to the JSON configuration file containing deployment settings

.PARAMETER Credential
    Administrator credentials for Microsoft 365 tenant

.PARAMETER WhatIf
    Show what would be deployed without making actual changes

.EXAMPLE
    .\Deploy-Solution.ps1 -TenantDomain "contoso.onmicrosoft.com" -DeploymentPhase "Foundation"

.EXAMPLE
    .\Deploy-Solution.ps1 -TenantDomain "contoso.onmicrosoft.com" -DeploymentPhase "All" -ConfigurationPath ".\config.json"

.NOTES
    Author: Microsoft 365 Deployment Team
    Version: 1.0
    Requires: PowerShell 5.1+, Microsoft 365 admin permissions
    
    Required Modules:
    - AzureAD
    - ExchangeOnlineManagement
    - MicrosoftTeams
    - PnP.PowerShell
    - Microsoft.Graph
    - MSOnline
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantDomain,
    
    [Parameter(Mandatory = $true)]
    [ValidateSet("Foundation", "CoreServices", "AdvancedFeatures", "Optimization", "All")]
    [string]$DeploymentPhase,
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigurationPath = ".\config.json",
    
    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Global variables
$Script:LogFile = "M365Deployment_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Script:ErrorCount = 0
$Script:WarningCount = 0

# Import required modules
$RequiredModules = @(
    "AzureAD",
    "ExchangeOnlineManagement", 
    "MicrosoftTeams",
    "PnP.PowerShell",
    "Microsoft.Graph",
    "MSOnline"
)

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    $color = switch ($Level) {
        "Error" { "Red"; $Script:ErrorCount++ }
        "Warning" { "Yellow"; $Script:WarningCount++ }
        "Success" { "Green" }
        default { "White" }
    }
    
    Write-Host $logEntry -ForegroundColor $color
    Add-Content -Path $Script:LogFile -Value $logEntry
}

function Test-Prerequisites {
    Write-Log "Checking deployment prerequisites..." -Level "Info"
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Log "PowerShell 5.1 or later is required" -Level "Error"
        return $false
    }
    
    # Check and install required modules
    foreach ($module in $RequiredModules) {
        try {
            if (!(Get-Module -ListAvailable -Name $module)) {
                Write-Log "Installing required module: $module" -Level "Info"
                if (!$WhatIf) {
                    Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
                }
            }
            
            Write-Log "Importing module: $module" -Level "Info"
            if (!$WhatIf) {
                Import-Module -Name $module -Force
            }
        }
        catch {
            Write-Log "Failed to import module $module : $($_.Exception.Message)" -Level "Error"
            return $false
        }
    }
    
    # Test tenant connectivity
    try {
        Write-Log "Testing connectivity to tenant: $TenantDomain" -Level "Info"
        if (!$WhatIf) {
            Connect-AzureAD -TenantId $TenantDomain -Credential $Credential
            $tenant = Get-AzureADTenantDetail
            Write-Log "Connected to tenant: $($tenant.DisplayName)" -Level "Success"
        }
    }
    catch {
        Write-Log "Failed to connect to Azure AD: $($_.Exception.Message)" -Level "Error"
        return $false
    }
    
    return $true
}

function Import-DeploymentConfiguration {
    param([string]$ConfigPath)
    
    Write-Log "Loading deployment configuration from: $ConfigPath" -Level "Info"
    
    if (Test-Path $ConfigPath) {
        try {
            $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
            Write-Log "Configuration loaded successfully" -Level "Success"
            return $config
        }
        catch {
            Write-Log "Failed to parse configuration file: $($_.Exception.Message)" -Level "Error"
            return $null
        }
    }
    else {
        Write-Log "Configuration file not found. Using default settings." -Level "Warning"
        return $null
    }
}

function Deploy-FoundationPhase {
    Write-Log "=== Starting Foundation Phase Deployment ===" -Level "Info"
    
    try {
        # Configure Azure AD Tenant
        Write-Log "Configuring Azure AD tenant settings..." -Level "Info"
        if (!$WhatIf) {
            Set-AzureADTenantDetail -TechnicalNotificationMails @("admin@$TenantDomain") `
                -SecurityComplianceNotificationMails @("security@$TenantDomain")
        }
        
        # Set up MFA for all users
        Write-Log "Configuring Multi-Factor Authentication..." -Level "Info"
        if (!$WhatIf) {
            $users = Get-AzureADUser -All $true | Where-Object {$_.UserType -eq "Member"}
            
            foreach ($user in $users | Select-Object -First 10) { # Limit for demo
                $mfa = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
                $mfa.RelyingParty = "*"
                $mfa.State = "Enabled"
                
                Set-MsolUser -UserPrincipalName $user.UserPrincipalName -StrongAuthenticationRequirements @($mfa)
                Write-Log "Enabled MFA for: $($user.UserPrincipalName)" -Level "Success"
            }
        }
        
        # Create conditional access policies
        Write-Log "Creating baseline conditional access policies..." -Level "Info"
        if (!$WhatIf) {
            # Baseline MFA policy
            $conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
            $conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
            $conditions.Applications.IncludeApplications = @("All")
            
            $grantControls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
            $grantControls.Operator = "OR"
            $grantControls.BuiltInControls = @("mfa")
            
            New-AzureADMSConditionalAccessPolicy -DisplayName "Baseline-Require-MFA" `
                -State "Enabled" -Conditions $conditions -GrantControls $grantControls
        }
        
        Write-Log "Foundation Phase completed successfully" -Level "Success"
    }
    catch {
        Write-Log "Foundation Phase failed: $($_.Exception.Message)" -Level "Error"
        throw
    }
}

function Deploy-CoreServicesPhase {
    Write-Log "=== Starting Core Services Phase Deployment ===" -Level "Info"
    
    try {
        # Configure Exchange Online
        Write-Log "Configuring Exchange Online..." -Level "Info"
        if (!$WhatIf) {
            Connect-ExchangeOnline -Credential $Credential
            
            # Set organization configuration
            Set-OrganizationConfig -DefaultPublicFolderMailbox $null -PublicFoldersEnabled Remote
            
            # Create transport rule for external email warning
            New-TransportRule -Name "External Email Warning" `
                -FromScope NotInOrganization `
                -SetHeaderName "X-MS-Exchange-Organization-ExternalEmailWarning" `
                -SetHeaderValue "This email originated from outside the organization"
            
            # Configure retention policy
            New-RetentionPolicy -Name "Corporate Retention" `
                -RetentionPolicyTagLinks @("Default 2 year move to archive")
        }
        
        # Configure SharePoint Online
        Write-Log "Configuring SharePoint Online..." -Level "Info"
        if (!$WhatIf) {
            $adminUrl = "https://$($TenantDomain.Split('.')[0])-admin.sharepoint.com"
            Connect-SPOService -Url $adminUrl
            
            # Set tenant settings
            Set-SPOTenant -RequireAcceptingAccountMatchInvitedAccount $true `
                -SharingCapability ExternalUserAndGuestSharing `
                -DefaultLinkPermission Edit
        }
        
        # Configure Microsoft Teams
        Write-Log "Configuring Microsoft Teams..." -Level "Info"
        if (!$WhatIf) {
            Connect-MicrosoftTeams -Credential $Credential
            
            # Create meeting policy
            New-CsTeamsMeetingPolicy -Identity "StandardMeetingPolicy" `
                -AllowCloudRecording $true `
                -RecordingStorageMode OneDriveForBusiness
            
            # Create messaging policy
            New-CsTeamsMessagingPolicy -Identity "StandardMessagingPolicy" `
                -AllowUserEditMessage $true `
                -AllowUserDeleteMessage $true
        }
        
        Write-Log "Core Services Phase completed successfully" -Level "Success"
    }
    catch {
        Write-Log "Core Services Phase failed: $($_.Exception.Message)" -Level "Error"
        throw
    }
}

function Deploy-AdvancedFeaturesPhase {
    Write-Log "=== Starting Advanced Features Phase Deployment ===" -Level "Info"
    
    try {
        # Configure Microsoft Defender for Office 365
        Write-Log "Configuring Microsoft Defender for Office 365..." -Level "Info"
        if (!$WhatIf) {
            # Safe Attachments Policy
            New-SafeAttachmentPolicy -Name "Corporate Safe Attachments" `
                -Action Block -Enable $true
            
            New-SafeAttachmentRule -Name "All Users" `
                -SafeAttachmentPolicy "Corporate Safe Attachments" `
                -RecipientDomainIs $TenantDomain
            
            # Safe Links Policy
            New-SafeLinksPolicy -Name "Corporate Safe Links" `
                -IsEnabled $true -TrackClicks $true -ScanUrls $true
            
            New-SafeLinksRule -Name "All Users" `
                -SafeLinksPolicy "Corporate Safe Links" `
                -RecipientDomainIs $TenantDomain
        }
        
        # Configure Data Loss Prevention
        Write-Log "Configuring Data Loss Prevention policies..." -Level "Info"
        if (!$WhatIf) {
            New-DlpCompliancePolicy -Name "Corporate DLP" `
                -ExchangeLocation All -SharePointLocation All -OneDriveLocation All
            
            New-DlpComplianceRule -Policy "Corporate DLP" `
                -Name "Credit Card Protection" `
                -ContentContainsSensitiveInformation @{Name="Credit Card Number"; MinCount="1"}
        }
        
        # Configure Power Platform
        Write-Log "Configuring Power Platform environment..." -Level "Info"
        if (!$WhatIf) {
            # This would require Power Platform admin modules
            Write-Log "Power Platform configuration requires additional modules" -Level "Warning"
        }
        
        Write-Log "Advanced Features Phase completed successfully" -Level "Success"
    }
    catch {
        Write-Log "Advanced Features Phase failed: $($_.Exception.Message)" -Level "Error"
        throw
    }
}

function Deploy-OptimizationPhase {
    Write-Log "=== Starting Optimization Phase Deployment ===" -Level "Info"
    
    try {
        # Generate usage analytics
        Write-Log "Generating usage analytics..." -Level "Info"
        if (!$WhatIf) {
            $mailboxStats = Get-Mailbox -ResultSize 100 | Get-MailboxStatistics
            $avgSize = ($mailboxStats | Measure-Object -Property @{Expression={$_.TotalItemSize.Value.ToMB()}} -Average).Average
            Write-Log "Average mailbox size: $([math]::Round($avgSize/1024,2)) GB" -Level "Info"
        }
        
        # Optimize SharePoint sites
        Write-Log "Optimizing SharePoint site settings..." -Level "Info"
        if (!$WhatIf) {
            $sites = Get-SPOSite -Limit All | Select-Object -First 10
            foreach ($site in $sites) {
                Set-SPOSite -Identity $site.Url -StorageQuota 26214400 # 25GB
            }
        }
        
        # Configure Teams policies for optimal performance
        Write-Log "Optimizing Teams policies..." -Level "Info"
        if (!$WhatIf) {
            Grant-CsTeamsMeetingPolicy -Identity "Global" -PolicyName "StandardMeetingPolicy"
        }
        
        Write-Log "Optimization Phase completed successfully" -Level "Success"
    }
    catch {
        Write-Log "Optimization Phase failed: $($_.Exception.Message)" -Level "Error"
        throw
    }
}

function Deploy-AllPhases {
    Write-Log "Starting complete Microsoft 365 deployment..." -Level "Info"
    
    Deploy-FoundationPhase
    Deploy-CoreServicesPhase
    Deploy-AdvancedFeaturesPhase
    Deploy-OptimizationPhase
}

function New-DeploymentReport {
    Write-Log "=== Generating Deployment Report ===" -Level "Info"
    
    $report = @{
        "DeploymentDate" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "TenantDomain" = $TenantDomain
        "DeploymentPhase" = $DeploymentPhase
        "ErrorCount" = $Script:ErrorCount
        "WarningCount" = $Script:WarningCount
        "LogFile" = $Script:LogFile
    }
    
    # Get tenant information
    try {
        if (!$WhatIf) {
            $tenant = Get-AzureADTenantDetail
            $licenses = Get-MsolAccountSku
            $users = Get-AzureADUser -All $true | Where-Object {$_.UserType -eq "Member"}
            
            $report.TenantInfo = @{
                "DisplayName" = $tenant.DisplayName
                "TenantId" = $tenant.ObjectId
                "VerifiedDomains" = $tenant.VerifiedDomains.Count
                "TotalUsers" = $users.Count
                "LicensedUsers" = ($users | Where-Object {$_.AssignedLicenses.Count -gt 0}).Count
                "AvailableLicenses" = $licenses.Count
            }
        }
    }
    catch {
        Write-Log "Could not gather tenant information for report: $($_.Exception.Message)" -Level "Warning"
    }
    
    # Save report to JSON
    $reportPath = "M365Deployment_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $report | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8
    
    Write-Log "Deployment report saved to: $reportPath" -Level "Success"
    Write-Log "Deployment completed with $($Script:ErrorCount) errors and $($Script:WarningCount) warnings" -Level "Info"
    
    return $report
}

# Main execution flow
function Main {
    Write-Log "Microsoft 365 Enterprise Deployment Script Started" -Level "Info"
    Write-Log "Tenant: $TenantDomain" -Level "Info"
    Write-Log "Phase: $DeploymentPhase" -Level "Info"
    Write-Log "WhatIf Mode: $WhatIf" -Level "Info"
    
    try {
        # Check prerequisites
        if (!(Test-Prerequisites)) {
            Write-Log "Prerequisites check failed. Deployment aborted." -Level "Error"
            return
        }
        
        # Import configuration
        $config = Import-DeploymentConfiguration -ConfigPath $ConfigurationPath
        
        # Execute deployment phase
        switch ($DeploymentPhase) {
            "Foundation" { Deploy-FoundationPhase }
            "CoreServices" { Deploy-CoreServicesPhase }
            "AdvancedFeatures" { Deploy-AdvancedFeaturesPhase }
            "Optimization" { Deploy-OptimizationPhase }
            "All" { Deploy-AllPhases }
        }
        
        # Generate deployment report
        $report = New-DeploymentReport
        
        if ($Script:ErrorCount -eq 0) {
            Write-Log "Microsoft 365 deployment completed successfully!" -Level "Success"
        } else {
            Write-Log "Deployment completed with errors. Please review the log file." -Level "Warning"
        }
        
    }
    catch {
        Write-Log "Deployment failed with critical error: $($_.Exception.Message)" -Level "Error"
        Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "Error"
    }
    finally {
        # Cleanup connections
        try {
            Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
            Disconnect-SPOService -ErrorAction SilentlyContinue
            Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue
            Disconnect-AzureAD -ErrorAction SilentlyContinue
        }
        catch {
            # Ignore cleanup errors
        }
    }
}

# Execute main function
Main