#Requires -Version 7.0
<#
.SYNOPSIS
    Purview compliance and data protection for CMMC GCC High Enclave.

.DESCRIPTION
    This module provides functions for configuring Microsoft Purview DLP,
    sensitivity labels, retention policies, and eDiscovery for CMMC compliance.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

# Import common module
$commonModulePath = Join-Path $PSScriptRoot '..\CMMC-Common\CMMC-Common.psm1'
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -Force
}

#region DLP Functions

function New-CMCDLPPolicy {
    <#
    .SYNOPSIS
        Creates DLP policies for CUI (Controlled Unclassified Information) protection.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$PolicyName = 'CMMC-CUI-Protection',

        [Parameter()]
        [hashtable]$Config
    )

    Write-CMCLog "Creating DLP policy: $PolicyName" -Level INFO

    try {
        # Check if policy exists
        $existingPolicy = Get-DlpCompliancePolicy -Identity $PolicyName -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Write-CMCLog "DLP policy '$PolicyName' already exists" -Level WARN
            return $existingPolicy
        }

        # Create DLP policy for CUI protection
        $policyParams = @{
            Name              = $PolicyName
            Comment           = 'CMMC Level 2 CUI Protection Policy'
            Mode              = 'Enable'
            ExchangeLocation  = 'All'
            SharePointLocation = 'All'
            OneDriveLocation  = 'All'
            TeamsLocation     = 'All'
        }

        $policy = New-DlpCompliancePolicy @policyParams

        # Create DLP rule for CUI markers
        $ruleParams = @{
            Name                        = "$PolicyName-CUI-Rule"
            Policy                      = $PolicyName
            ContentContainsSensitiveInformation = @(
                @{
                    Name = 'U.S. Social Security Number (SSN)'
                    MinCount = 1
                },
                @{
                    Name = 'U.S. Individual Taxpayer Identification Number (ITIN)'
                    MinCount = 1
                },
                @{
                    Name = 'Credit Card Number'
                    MinCount = 1
                }
            )
            BlockAccess                 = $true
            BlockAccessScope            = 'All'
            NotifyUser                  = 'SiteAdmin'
            NotifyUserType              = 'NotSet'
            GenerateIncidentReport      = 'SiteAdmin'
            IncidentReportContent       = @('All')
        }

        New-DlpComplianceRule @ruleParams

        # Create rule for CUI document marking
        $cuiMarkingRule = @{
            Name                        = "$PolicyName-CUI-Marking"
            Policy                      = $PolicyName
            ContentContainsSensitiveInformation = @()
            AdvancedRule                = @"
{
    "Condition": {
        "Or": [
            { "ContentContains": { "Words": ["CUI", "CONTROLLED", "UNCLASSIFIED"] } },
            { "ContentContains": { "Words": ["NOFORN", "FOUO", "LES"] } }
        ]
    }
}
"@
            BlockAccess                 = $false
            NotifyUser                  = 'SiteAdmin'
            GenerateAlert               = 'SiteAdmin'
        }

        # Note: Advanced rules require additional configuration via Security & Compliance Center

        Write-CMCLog "DLP policy created successfully" -Level SUCCESS
        return $policy
    }
    catch {
        Write-CMCLog "Failed to create DLP policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Sensitivity Labels Functions

function New-CMCSensitivityLabel {
    <#
    .SYNOPSIS
        Creates sensitivity labels for CUI classification.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$LabelName = 'CUI',

        [Parameter()]
        [string]$ParentLabel
    )

    Write-CMCLog "Creating sensitivity label: $LabelName" -Level INFO

    try {
        # Check if label exists
        $existingLabel = Get-Label -Identity $LabelName -ErrorAction SilentlyContinue

        if ($existingLabel) {
            Write-CMCLog "Sensitivity label '$LabelName' already exists" -Level WARN
            return $existingLabel
        }

        # Create CUI label hierarchy
        $labels = @(
            @{
                Name        = 'Public'
                DisplayName = 'Public'
                Tooltip     = 'Information approved for public release'
                Priority    = 0
                Settings    = @{
                    ContentMarking = @{
                        Header = @{ Text = 'PUBLIC'; FontSize = 12 }
                    }
                }
            },
            @{
                Name        = 'Internal'
                DisplayName = 'Internal'
                Tooltip     = 'Internal company information'
                Priority    = 1
                Settings    = @{
                    ContentMarking = @{
                        Header = @{ Text = 'INTERNAL USE ONLY'; FontSize = 12 }
                    }
                }
            },
            @{
                Name        = 'CUI'
                DisplayName = 'CUI - Controlled Unclassified Information'
                Tooltip     = 'Controlled Unclassified Information per 32 CFR 2002'
                Priority    = 2
                Settings    = @{
                    ContentMarking = @{
                        Header = @{ Text = 'CUI'; FontSize = 14; Color = '#FF0000' }
                        Footer = @{ Text = 'Controlled Unclassified Information'; FontSize = 10 }
                        Watermark = @{ Text = 'CUI'; FontSize = 48; Layout = 'Diagonal' }
                    }
                    Encryption = @{
                        EncryptionEnabled = $true
                        ProtectionType = 'Template'
                        OfflineAccessDays = 7
                    }
                }
            },
            @{
                Name        = 'CUI-NOFORN'
                DisplayName = 'CUI // NOFORN'
                Tooltip     = 'CUI not releasable to foreign nationals'
                Priority    = 3
                ParentLabel = 'CUI'
                Settings    = @{
                    ContentMarking = @{
                        Header = @{ Text = 'CUI // NOFORN'; FontSize = 14; Color = '#FF0000' }
                        Footer = @{ Text = 'Not Releasable to Foreign Nationals'; FontSize = 10 }
                        Watermark = @{ Text = 'CUI // NOFORN'; FontSize = 48; Layout = 'Diagonal' }
                    }
                    Encryption = @{
                        EncryptionEnabled = $true
                        ProtectionType = 'Template'
                        OfflineAccessDays = 3
                    }
                }
            }
        )

        $createdLabels = @()
        foreach ($labelDef in $labels) {
            Write-CMCLog "  Creating label: $($labelDef.DisplayName)" -Level INFO

            $labelParams = @{
                Name        = $labelDef.Name
                DisplayName = $labelDef.DisplayName
                Tooltip     = $labelDef.Tooltip
            }

            if ($labelDef.ParentLabel) {
                $labelParams['ParentId'] = (Get-Label -Identity $labelDef.ParentLabel).Guid
            }

            $newLabel = New-Label @labelParams
            $createdLabels += $newLabel
        }

        Write-CMCLog "Sensitivity labels created successfully" -Level SUCCESS
        return $createdLabels
    }
    catch {
        Write-CMCLog "Failed to create sensitivity labels: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Retention Policy Functions

function New-CMCRetentionPolicy {
    <#
    .SYNOPSIS
        Creates retention policies for CMMC compliance (7-year retention).
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$PolicyName = 'CMMC-Retention-7Year',

        [Parameter()]
        [int]$RetentionYears = 7,

        [Parameter()]
        [hashtable]$Config
    )

    Write-CMCLog "Creating retention policy: $PolicyName ($RetentionYears years)" -Level INFO

    try {
        # Check if policy exists
        $existingPolicy = Get-RetentionCompliancePolicy -Identity $PolicyName -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Write-CMCLog "Retention policy '$PolicyName' already exists" -Level WARN
            return $existingPolicy
        }

        # Create retention policy
        $policyParams = @{
            Name               = $PolicyName
            Comment            = "CMMC $RetentionYears-year retention policy for CUI"
            ExchangeLocation   = 'All'
            SharePointLocation = 'All'
            OneDriveLocation   = 'All'
            ModernGroupLocation = 'All'
        }

        $policy = New-RetentionCompliancePolicy @policyParams

        # Create retention rule
        $ruleParams = @{
            Name              = "$PolicyName-Rule"
            Policy            = $PolicyName
            RetentionDuration = ($RetentionYears * 365)
            RetentionDurationDisplayHint = 'Days'
            RetentionComplianceAction = 'Keep'
            ExpirationDateOption = 'CreatedDate'
        }

        New-RetentionComplianceRule @ruleParams

        Write-CMCLog "Retention policy created successfully" -Level SUCCESS
        return $policy
    }
    catch {
        Write-CMCLog "Failed to create retention policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region eDiscovery Functions

function Enable-CMCeDiscovery {
    <#
    .SYNOPSIS
        Enables and configures eDiscovery for legal hold and investigation.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$CaseName = 'CMMC-Compliance-Case',

        [Parameter()]
        [string]$Description = 'eDiscovery case for CMMC compliance investigations'
    )

    Write-CMCLog "Enabling eDiscovery case: $CaseName" -Level INFO

    try {
        # Check if case exists
        $existingCase = Get-ComplianceCase -Identity $CaseName -ErrorAction SilentlyContinue

        if ($existingCase) {
            Write-CMCLog "eDiscovery case '$CaseName' already exists" -Level WARN
            return $existingCase
        }

        # Create eDiscovery case
        $caseParams = @{
            Name        = $CaseName
            Description = $Description
            CaseType    = 'eDiscovery'
        }

        $case = New-ComplianceCase @caseParams

        Write-CMCLog "eDiscovery case created successfully" -Level SUCCESS
        return $case
    }
    catch {
        Write-CMCLog "Failed to enable eDiscovery: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Compliance Score Functions

function Get-CMCComplianceScore {
    <#
    .SYNOPSIS
        Retrieves the Microsoft Compliance Score for CMMC frameworks.
    #>
    [CmdletBinding()]
    param()

    Write-CMCLog "Retrieving Compliance Score..." -Level INFO

    try {
        # Note: Compliance Manager API access may require additional configuration
        # This is a placeholder for the actual API call

        $result = @{
            OverallScore       = 0
            MaxScore           = 0
            NIST800171Score    = 0
            NIST800171MaxScore = 110
            LastUpdated        = Get-Date
            Assessments        = @()
        }

        Write-CMCLog "Compliance Score retrieved" -Level INFO
        return $result
    }
    catch {
        Write-CMCLog "Failed to retrieve Compliance Score: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Reporting Functions

function Export-CMCComplianceReport {
    <#
    .SYNOPSIS
        Exports a compliance assessment report for CMMC.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$OutputPath,

        [Parameter()]
        [ValidateSet('HTML', 'JSON', 'CSV')]
        [string]$Format = 'HTML'
    )

    Write-CMCLog "Generating compliance report..." -Level INFO

    try {
        $report = @{
            GeneratedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            DLPPolicies = (Get-DlpCompliancePolicy | Select-Object Name, Mode, Priority)
            RetentionPolicies = (Get-RetentionCompliancePolicy | Select-Object Name, Enabled)
            SensitivityLabels = (Get-Label | Select-Object Name, DisplayName, Priority)
            eDiscoveryCases = (Get-ComplianceCase | Select-Object Name, Status, CreatedDateTime)
        }

        $outputFile = Join-Path $OutputPath "cmmc-compliance-report-$(Get-Date -Format 'yyyyMMdd').$($Format.ToLower())"

        switch ($Format) {
            'JSON' {
                $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding utf8
            }
            'CSV' {
                # Flatten for CSV export
                $report | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $outputFile -Encoding utf8
            }
            'HTML' {
                $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>CMMC Compliance Report</title>
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
    <h1>CMMC GCC High Enclave - Compliance Report</h1>
    <p>Generated: $($report.GeneratedAt)</p>

    <h2>DLP Policies</h2>
    <table>
        <tr><th>Name</th><th>Mode</th><th>Priority</th></tr>
        $($report.DLPPolicies | ForEach-Object { "<tr><td>$($_.Name)</td><td>$($_.Mode)</td><td>$($_.Priority)</td></tr>" })
    </table>

    <h2>Retention Policies</h2>
    <table>
        <tr><th>Name</th><th>Enabled</th></tr>
        $($report.RetentionPolicies | ForEach-Object { "<tr><td>$($_.Name)</td><td>$($_.Enabled)</td></tr>" })
    </table>

    <h2>Sensitivity Labels</h2>
    <table>
        <tr><th>Name</th><th>Display Name</th><th>Priority</th></tr>
        $($report.SensitivityLabels | ForEach-Object { "<tr><td>$($_.Name)</td><td>$($_.DisplayName)</td><td>$($_.Priority)</td></tr>" })
    </table>
</body>
</html>
"@
                $htmlContent | Out-File -FilePath $outputFile -Encoding utf8
            }
        }

        Write-CMCLog "Compliance report exported to: $outputFile" -Level SUCCESS
        return $outputFile
    }
    catch {
        Write-CMCLog "Failed to export compliance report: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'New-CMCDLPPolicy',
    'New-CMCSensitivityLabel',
    'New-CMCRetentionPolicy',
    'Enable-CMCeDiscovery',
    'Get-CMCComplianceScore',
    'Export-CMCComplianceReport'
)

#endregion
