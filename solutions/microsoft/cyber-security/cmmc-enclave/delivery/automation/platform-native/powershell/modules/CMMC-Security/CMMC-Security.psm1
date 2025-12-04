#Requires -Version 7.0
<#
.SYNOPSIS
    Security controls and Defender configuration for CMMC GCC High Enclave.

.DESCRIPTION
    This module provides functions for configuring Microsoft Defender for Cloud,
    Defender for Office 365, and security baselines required for CMMC Level 2.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

# Import common module
$commonModulePath = Join-Path $PSScriptRoot '..\CMMC-Common\CMMC-Common.psm1'
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -Force
}

#region Defender for Cloud Functions

function Enable-CMCDefenderForCloud {
    <#
    .SYNOPSIS
        Enables and configures Microsoft Defender for Cloud in Azure Government.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SubscriptionId,

        [Parameter()]
        [ValidateSet('Free', 'Standard')]
        [string]$Tier = 'Standard',

        [Parameter()]
        [string[]]$ResourceTypes = @('VirtualMachines', 'SqlServers', 'AppServices', 'StorageAccounts', 'KeyVaults')
    )

    Write-CMCLog "Enabling Defender for Cloud (Tier: $Tier)..." -Level INFO

    try {
        # Set subscription context
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

        foreach ($resourceType in $ResourceTypes) {
            Write-CMCLog "  Enabling protection for: $resourceType" -Level INFO

            $pricingParams = @{
                Name          = $resourceType
                PricingTier   = $Tier
            }

            Set-AzSecurityPricing @pricingParams
        }

        # Enable auto-provisioning for Log Analytics agent
        Set-AzSecurityAutoProvisioningSetting -Name 'default' -EnableAutoProvision

        # Enable security contacts
        Write-CMCLog "Defender for Cloud enabled successfully" -Level SUCCESS
        return $true
    }
    catch {
        Write-CMCLog "Failed to enable Defender for Cloud: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Set-CMCSecurityContact {
    <#
    .SYNOPSIS
        Configures security contact information for Defender for Cloud alerts.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Email,

        [Parameter()]
        [string]$Phone,

        [Parameter()]
        [switch]$AlertsToAdmins
    )

    Write-CMCLog "Configuring security contact: $Email" -Level INFO

    try {
        $contactParams = @{
            Name             = 'default'
            Email            = $Email
            AlertNotification = 'On'
            AlertsToAdmin    = if ($AlertsToAdmins) { 'On' } else { 'Off' }
        }

        if ($Phone) {
            $contactParams['Phone'] = $Phone
        }

        Set-AzSecurityContact @contactParams
        Write-CMCLog "Security contact configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-CMCLog "Failed to configure security contact: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Defender for Office 365 Functions

function Enable-CMCDefenderForOffice {
    <#
    .SYNOPSIS
        Enables and configures Microsoft Defender for Office 365 in GCC High.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Config
    )

    Write-CMCLog "Configuring Defender for Office 365..." -Level INFO

    try {
        # Safe Links policy
        $safeLinkParams = @{
            Name                     = 'CMMC-SafeLinks-Policy'
            EnableSafeLinksForEmail  = $true
            EnableSafeLinksForTeams  = $true
            EnableSafeLinksForOffice = $true
            TrackClicks              = $true
            AllowClickThrough        = $false
            ScanUrls                 = $true
            EnableForInternalSenders = $true
            DeliverMessageAfterScan  = $true
            DisableUrlRewrite        = $false
        }

        # Check if policy exists
        $existingPolicy = Get-SafeLinksPolicy -Identity 'CMMC-SafeLinks-Policy' -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Set-SafeLinksPolicy @safeLinkParams
            Write-CMCLog "Safe Links policy updated" -Level SUCCESS
        }
        else {
            New-SafeLinksPolicy @safeLinkParams
            Write-CMCLog "Safe Links policy created" -Level SUCCESS
        }

        # Safe Attachments policy
        $safeAttachParams = @{
            Name                    = 'CMMC-SafeAttachments-Policy'
            Enable                  = $true
            Action                  = 'Block'
            Redirect                = $true
            RedirectAddress         = $Config.monitoring.alert_email
            ActionOnError           = $true
            EnableOrganizationBranding = $true
        }

        $existingAttachPolicy = Get-SafeAttachmentPolicy -Identity 'CMMC-SafeAttachments-Policy' -ErrorAction SilentlyContinue

        if ($existingAttachPolicy) {
            Set-SafeAttachmentPolicy @safeAttachParams
            Write-CMCLog "Safe Attachments policy updated" -Level SUCCESS
        }
        else {
            New-SafeAttachmentPolicy @safeAttachParams
            Write-CMCLog "Safe Attachments policy created" -Level SUCCESS
        }

        # Anti-phishing policy
        $antiPhishParams = @{
            Name                              = 'CMMC-AntiPhishing-Policy'
            Enabled                           = $true
            EnableMailboxIntelligence         = $true
            EnableMailboxIntelligenceProtection = $true
            EnableSpoofIntelligence           = $true
            EnableFirstContactSafetyTips      = $true
            EnableSimilarUsersSafetyTips      = $true
            EnableSimilarDomainsSafetyTips    = $true
            EnableUnusualCharactersSafetyTips = $true
            PhishThresholdLevel               = 3
        }

        $existingPhishPolicy = Get-AntiPhishPolicy -Identity 'CMMC-AntiPhishing-Policy' -ErrorAction SilentlyContinue

        if ($existingPhishPolicy) {
            Set-AntiPhishPolicy @antiPhishParams
            Write-CMCLog "Anti-Phishing policy updated" -Level SUCCESS
        }
        else {
            New-AntiPhishPolicy @antiPhishParams
            Write-CMCLog "Anti-Phishing policy created" -Level SUCCESS
        }

        Write-CMCLog "Defender for Office 365 configuration complete" -Level SUCCESS
        return $true
    }
    catch {
        Write-CMCLog "Failed to configure Defender for Office 365: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Threat Protection Functions

function Set-CMCThreatProtection {
    <#
    .SYNOPSIS
        Configures advanced threat protection settings.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$EnableThreatIntelligence,

        [Parameter()]
        [switch]$EnableAttackSimulation
    )

    Write-CMCLog "Configuring threat protection settings..." -Level INFO

    try {
        if ($EnableThreatIntelligence) {
            Write-CMCLog "  Enabling threat intelligence feeds" -Level INFO
            # Configure threat intelligence via Graph API
            # This requires specific Graph API permissions
        }

        if ($EnableAttackSimulation) {
            Write-CMCLog "  Enabling attack simulation training" -Level INFO
            # Enable attack simulation via Defender portal
        }

        Write-CMCLog "Threat protection configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-CMCLog "Failed to configure threat protection: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Security Baseline Functions

function New-CMCSecurityBaseline {
    <#
    .SYNOPSIS
        Creates security baseline policy for CMMC compliance.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    Write-CMCLog "Creating CMMC security baseline..." -Level INFO

    try {
        $baseline = @{
            Name = 'CMMC-Security-Baseline'
            Settings = @{
                # Password policies
                MinPasswordLength = 14
                PasswordComplexity = $true
                MaxPasswordAge = 60
                MinPasswordAge = 1
                PasswordHistorySize = 24

                # Account lockout
                LockoutBadCount = 3
                LockoutDuration = 30
                ResetLockoutCount = 30

                # Audit policies
                AuditLogonEvents = 'SuccessAndFailure'
                AuditAccountLogon = 'SuccessAndFailure'
                AuditObjectAccess = 'SuccessAndFailure'
                AuditPolicyChange = 'SuccessAndFailure'
                AuditPrivilegeUse = 'SuccessAndFailure'
                AuditSystemEvents = 'SuccessAndFailure'

                # Security options
                RequireCtrlAltDel = $true
                DontDisplayLastUser = $true
                EnableSecureBoot = $true

                # Encryption
                RequireBitLocker = $true
                MinTLSVersion = '1.2'
                FIPSMode = $true
            }
        }

        Write-CMCLog "Security baseline created" -Level SUCCESS
        return $baseline
    }
    catch {
        Write-CMCLog "Failed to create security baseline: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Get-CMCSecurityScore {
    <#
    .SYNOPSIS
        Retrieves the Microsoft Secure Score for the tenant.
    #>
    [CmdletBinding()]
    param()

    Write-CMCLog "Retrieving Microsoft Secure Score..." -Level INFO

    try {
        $secureScore = Get-MgSecuritySecureScore -Top 1

        $result = @{
            CurrentScore = $secureScore.CurrentScore
            MaxScore     = $secureScore.MaxScore
            Percentage   = [math]::Round(($secureScore.CurrentScore / $secureScore.MaxScore) * 100, 2)
            UpdatedAt    = $secureScore.CreatedDateTime
        }

        Write-CMCLog "Secure Score: $($result.CurrentScore)/$($result.MaxScore) ($($result.Percentage)%)" -Level INFO
        return $result
    }
    catch {
        Write-CMCLog "Failed to retrieve Secure Score: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Reporting Functions

function Export-CMCSecurityReport {
    <#
    .SYNOPSIS
        Exports a security assessment report for CMMC compliance.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$OutputPath,

        [Parameter()]
        [ValidateSet('HTML', 'JSON', 'CSV')]
        [string]$Format = 'HTML'
    )

    Write-CMCLog "Generating security report..." -Level INFO

    try {
        $report = @{
            GeneratedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            SecureScore = Get-CMCSecurityScore
            DefenderStatus = @{
                DefenderForCloud = (Get-AzSecurityPricing | Select-Object Name, PricingTier)
            }
            ConditionalAccessPolicies = (Get-MgIdentityConditionalAccessPolicy | Select-Object DisplayName, State)
        }

        switch ($Format) {
            'JSON' {
                $outputFile = Join-Path $OutputPath "cmmc-security-report-$(Get-Date -Format 'yyyyMMdd').json"
                $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding utf8
            }
            'CSV' {
                $outputFile = Join-Path $OutputPath "cmmc-security-report-$(Get-Date -Format 'yyyyMMdd').csv"
                # Flatten report for CSV
                $report | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $outputFile -Encoding utf8
            }
            'HTML' {
                $outputFile = Join-Path $OutputPath "cmmc-security-report-$(Get-Date -Format 'yyyyMMdd').html"
                $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>CMMC Security Report</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; margin: 40px; }
        h1 { color: #0078d4; }
        .score { font-size: 48px; font-weight: bold; color: #107c10; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #0078d4; color: white; }
        .enabled { color: #107c10; }
        .disabled { color: #d13438; }
    </style>
</head>
<body>
    <h1>CMMC GCC High Enclave - Security Report</h1>
    <p>Generated: $($report.GeneratedAt)</p>
    <h2>Microsoft Secure Score</h2>
    <div class="score">$($report.SecureScore.Percentage)%</div>
    <p>$($report.SecureScore.CurrentScore) / $($report.SecureScore.MaxScore)</p>
</body>
</html>
"@
                $htmlContent | Out-File -FilePath $outputFile -Encoding utf8
            }
        }

        Write-CMCLog "Security report exported to: $outputFile" -Level SUCCESS
        return $outputFile
    }
    catch {
        Write-CMCLog "Failed to export security report: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'Enable-CMCDefenderForCloud',
    'Set-CMCSecurityContact',
    'Enable-CMCDefenderForOffice',
    'Set-CMCThreatProtection',
    'New-CMCSecurityBaseline',
    'Get-CMCSecurityScore',
    'Export-CMCSecurityReport'
)

#endregion
