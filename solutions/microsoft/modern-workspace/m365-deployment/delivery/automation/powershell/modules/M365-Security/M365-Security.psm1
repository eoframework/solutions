#Requires -Version 7.0
<#
.SYNOPSIS
    Security and compliance for M365 Deployment.

.DESCRIPTION
    This module provides functions for configuring Microsoft Defender
    for Office 365, DLP, retention policies, and compliance.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

# Import common module
$commonModulePath = Join-Path $PSScriptRoot '..\M365-Common\M365-Common.psm1'
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -Force
}

#region Defender for Office 365

function Enable-M365DefenderForOffice {
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Config
    )

    Write-M365Log "Configuring Defender for Office 365..." -Level INFO

    try {
        # Safe Links policy
        if ($Config.security.safe_links_enabled) {
            Write-M365Log "  Configuring Safe Links..." -Level INFO

            $safeLinkParams = @{
                Name                     = 'M365-SafeLinks-Policy'
                EnableSafeLinksForEmail  = $true
                EnableSafeLinksForTeams  = $true
                EnableSafeLinksForOffice = $true
                TrackClicks              = $true
                AllowClickThrough        = $false
                ScanUrls                 = $true
                EnableForInternalSenders = $true
                DeliverMessageAfterScan  = $true
            }

            $existingPolicy = Get-SafeLinksPolicy -Identity 'M365-SafeLinks-Policy' -ErrorAction SilentlyContinue

            if ($existingPolicy) {
                Set-SafeLinksPolicy @safeLinkParams
            }
            else {
                New-SafeLinksPolicy @safeLinkParams
                # Create rule to apply policy
                New-SafeLinksRule -Name 'M365-SafeLinks-Rule' -SafeLinksPolicy 'M365-SafeLinks-Policy' -RecipientDomainIs $Config.azure_ad.custom_domain -Enabled $true
            }
        }

        # Safe Attachments policy
        if ($Config.security.safe_attachments_enabled) {
            Write-M365Log "  Configuring Safe Attachments..." -Level INFO

            $safeAttachParams = @{
                Name    = 'M365-SafeAttachments-Policy'
                Enable  = $true
                Action  = 'DynamicDelivery'
                Redirect = $true
                RedirectAddress = $Config.monitoring.alert_email
            }

            $existingPolicy = Get-SafeAttachmentPolicy -Identity 'M365-SafeAttachments-Policy' -ErrorAction SilentlyContinue

            if ($existingPolicy) {
                Set-SafeAttachmentPolicy @safeAttachParams
            }
            else {
                New-SafeAttachmentPolicy @safeAttachParams
                New-SafeAttachmentRule -Name 'M365-SafeAttachments-Rule' -SafeAttachmentPolicy 'M365-SafeAttachments-Policy' -RecipientDomainIs $Config.azure_ad.custom_domain -Enabled $true
            }
        }

        # Anti-phishing policy
        Write-M365Log "  Configuring Anti-phishing..." -Level INFO

        $antiPhishParams = @{
            Name                              = 'M365-AntiPhishing-Policy'
            Enabled                           = $true
            EnableMailboxIntelligence         = $true
            EnableMailboxIntelligenceProtection = $true
            EnableSpoofIntelligence           = $true
            EnableFirstContactSafetyTips      = $true
            EnableSimilarUsersSafetyTips      = $true
            EnableSimilarDomainsSafetyTips    = $true
            PhishThresholdLevel               = 2
        }

        $existingPolicy = Get-AntiPhishPolicy -Identity 'M365-AntiPhishing-Policy' -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Set-AntiPhishPolicy @antiPhishParams
        }
        else {
            New-AntiPhishPolicy @antiPhishParams
            New-AntiPhishRule -Name 'M365-AntiPhishing-Rule' -AntiPhishPolicy 'M365-AntiPhishing-Policy' -RecipientDomainIs $Config.azure_ad.custom_domain -Enabled $true
        }

        Write-M365Log "Defender for Office 365 configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure Defender: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region DLP

function New-M365DLPPolicy {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$PolicyName = 'M365-DLP-PII-Protection',

        [Parameter()]
        [hashtable]$Config
    )

    Write-M365Log "Creating DLP policy: $PolicyName" -Level INFO

    try {
        if (-not $Config.compliance.dlp_enabled) {
            Write-M365Log "DLP disabled in configuration" -Level WARN
            return $false
        }

        $existingPolicy = Get-DlpCompliancePolicy -Identity $PolicyName -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Write-M365Log "DLP policy already exists" -Level WARN
            return $existingPolicy
        }

        $policy = New-DlpCompliancePolicy -Name $PolicyName `
            -Comment 'Protects PII and sensitive data' `
            -Mode 'Enable' `
            -ExchangeLocation 'All' `
            -SharePointLocation 'All' `
            -OneDriveLocation 'All' `
            -TeamsLocation 'All'

        # Create DLP rule
        New-DlpComplianceRule -Name "$PolicyName-Rule" `
            -Policy $PolicyName `
            -ContentContainsSensitiveInformation @(
                @{ Name = 'Credit Card Number'; MinCount = 1 },
                @{ Name = 'U.S. Social Security Number (SSN)'; MinCount = 1 }
            ) `
            -BlockAccess $true `
            -NotifyUser 'SiteAdmin'

        Write-M365Log "DLP policy created" -Level SUCCESS
        return $policy
    }
    catch {
        Write-M365Log "Failed to create DLP policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Retention

function New-M365RetentionPolicy {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$PolicyName = 'M365-Retention-7Year',

        [Parameter()]
        [int]$RetentionYears = 7,

        [Parameter()]
        [hashtable]$Config
    )

    Write-M365Log "Creating retention policy: $PolicyName ($RetentionYears years)" -Level INFO

    try {
        if (-not $Config.compliance.retention_policy_enabled) {
            Write-M365Log "Retention policies disabled in configuration" -Level WARN
            return $false
        }

        $existingPolicy = Get-RetentionCompliancePolicy -Identity $PolicyName -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Write-M365Log "Retention policy already exists" -Level WARN
            return $existingPolicy
        }

        $policy = New-RetentionCompliancePolicy -Name $PolicyName `
            -Comment "$RetentionYears year retention for compliance" `
            -ExchangeLocation 'All' `
            -SharePointLocation 'All' `
            -OneDriveLocation 'All' `
            -ModernGroupLocation 'All'

        New-RetentionComplianceRule -Name "$PolicyName-Rule" `
            -Policy $PolicyName `
            -RetentionDuration ($RetentionYears * 365) `
            -RetentionDurationDisplayHint 'Days' `
            -RetentionComplianceAction 'Keep'

        Write-M365Log "Retention policy created" -Level SUCCESS
        return $policy
    }
    catch {
        Write-M365Log "Failed to create retention policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Status

function Get-M365SecurityStatus {
    [CmdletBinding()]
    param()

    Write-M365Log "Retrieving security status..." -Level INFO

    try {
        $status = @{
            SafeLinksPolicy      = Get-SafeLinksPolicy | Select-Object Name, IsEnabled
            SafeAttachmentPolicy = Get-SafeAttachmentPolicy | Select-Object Name, Enable
            AntiPhishPolicy      = Get-AntiPhishPolicy | Select-Object Name, Enabled
            DLPPolicies          = Get-DlpCompliancePolicy | Select-Object Name, Mode
            RetentionPolicies    = Get-RetentionCompliancePolicy | Select-Object Name, Enabled
        }

        Write-M365Log "Security status retrieved" -Level SUCCESS
        return $status
    }
    catch {
        Write-M365Log "Failed to get security status: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Reporting

function Export-M365ComplianceReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$OutputPath,

        [Parameter()]
        [ValidateSet('HTML', 'JSON', 'CSV')]
        [string]$Format = 'HTML'
    )

    Write-M365Log "Generating compliance report..." -Level INFO

    try {
        $report = @{
            GeneratedAt       = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            SecurityStatus    = Get-M365SecurityStatus
            AuditLogStatus    = Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled
        }

        $outputFile = Join-Path $OutputPath "m365-compliance-report-$(Get-Date -Format 'yyyyMMdd').$($Format.ToLower())"

        switch ($Format) {
            'JSON' {
                $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding utf8
            }
            'CSV' {
                # Flatten for CSV
                $report.SecurityStatus | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $outputFile -Encoding utf8
            }
            'HTML' {
                $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>M365 Compliance Report</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; margin: 40px; }
        h1 { color: #0078d4; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #0078d4; color: white; }
        .enabled { color: #107c10; }
        .disabled { color: #d13438; }
    </style>
</head>
<body>
    <h1>Microsoft 365 Compliance Report</h1>
    <p>Generated: $($report.GeneratedAt)</p>

    <h2>Defender for Office 365</h2>
    <table>
        <tr><th>Policy Type</th><th>Name</th><th>Status</th></tr>
        $(foreach ($p in $report.SecurityStatus.SafeLinksPolicy) { "<tr><td>Safe Links</td><td>$($p.Name)</td><td>$($p.IsEnabled)</td></tr>" })
        $(foreach ($p in $report.SecurityStatus.SafeAttachmentPolicy) { "<tr><td>Safe Attachments</td><td>$($p.Name)</td><td>$($p.Enable)</td></tr>" })
        $(foreach ($p in $report.SecurityStatus.AntiPhishPolicy) { "<tr><td>Anti-Phishing</td><td>$($p.Name)</td><td>$($p.Enabled)</td></tr>" })
    </table>

    <h2>DLP Policies</h2>
    <table>
        <tr><th>Name</th><th>Mode</th></tr>
        $(foreach ($p in $report.SecurityStatus.DLPPolicies) { "<tr><td>$($p.Name)</td><td>$($p.Mode)</td></tr>" })
    </table>

    <h2>Retention Policies</h2>
    <table>
        <tr><th>Name</th><th>Enabled</th></tr>
        $(foreach ($p in $report.SecurityStatus.RetentionPolicies) { "<tr><td>$($p.Name)</td><td>$($p.Enabled)</td></tr>" })
    </table>
</body>
</html>
"@
                $htmlContent | Out-File -FilePath $outputFile -Encoding utf8
            }
        }

        Write-M365Log "Compliance report exported to: $outputFile" -Level SUCCESS
        return $outputFile
    }
    catch {
        Write-M365Log "Failed to export compliance report: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'Enable-M365DefenderForOffice',
    'New-M365DLPPolicy',
    'New-M365RetentionPolicy',
    'Get-M365SecurityStatus',
    'Export-M365ComplianceReport'
)

#endregion
