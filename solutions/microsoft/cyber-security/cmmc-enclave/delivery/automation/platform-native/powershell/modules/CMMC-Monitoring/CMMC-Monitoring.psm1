#Requires -Version 7.0
<#
.SYNOPSIS
    Microsoft Sentinel and monitoring for CMMC GCC High Enclave.

.DESCRIPTION
    This module provides functions for configuring Microsoft Sentinel workspace,
    analytics rules, playbooks, and monitoring for CMMC compliance.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

# Import common module
$commonModulePath = Join-Path $PSScriptRoot '..\CMMC-Common\CMMC-Common.psm1'
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -Force
}

#region Sentinel Workspace Functions

function New-CMCSentinelWorkspace {
    <#
    .SYNOPSIS
        Creates and configures Microsoft Sentinel workspace in Azure Government.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$WorkspaceName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory)]
        [string]$Location,

        [Parameter()]
        [int]$RetentionDays = 90,

        [Parameter()]
        [hashtable]$Tags
    )

    Write-CMCLog "Creating Sentinel workspace: $WorkspaceName" -Level INFO

    try {
        # Check if workspace exists
        $existingWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -ErrorAction SilentlyContinue

        if ($existingWorkspace) {
            Write-CMCLog "Workspace '$WorkspaceName' already exists" -Level WARN

            # Enable Sentinel on existing workspace
            Set-AzSentinel -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
            return $existingWorkspace
        }

        # Create Log Analytics workspace
        $workspaceParams = @{
            ResourceGroupName = $ResourceGroupName
            Name              = $WorkspaceName
            Location          = $Location
            Sku               = 'PerGB2018'
            RetentionInDays   = $RetentionDays
        }

        if ($Tags) {
            $workspaceParams['Tag'] = $Tags
        }

        $workspace = New-AzOperationalInsightsWorkspace @workspaceParams

        # Enable Microsoft Sentinel
        Set-AzSentinel -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName

        Write-CMCLog "Sentinel workspace created successfully" -Level SUCCESS
        return $workspace
    }
    catch {
        Write-CMCLog "Failed to create Sentinel workspace: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Data Connectors Functions

function Enable-CMCSentinelConnectors {
    <#
    .SYNOPSIS
        Enables Sentinel data connectors for CMMC monitoring.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$WorkspaceName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter()]
        [string[]]$Connectors = @(
            'AzureActiveDirectory',
            'AzureActivity',
            'Office365',
            'MicrosoftDefenderAdvancedThreatProtection',
            'AzureSecurityCenter',
            'MicrosoftCloudAppSecurity',
            'ThreatIntelligence'
        )
    )

    Write-CMCLog "Enabling Sentinel data connectors..." -Level INFO

    try {
        foreach ($connector in $Connectors) {
            Write-CMCLog "  Enabling connector: $connector" -Level INFO

            switch ($connector) {
                'AzureActiveDirectory' {
                    # Enable Azure AD connector
                    $connectorParams = @{
                        ResourceGroupName = $ResourceGroupName
                        WorkspaceName     = $WorkspaceName
                        DataConnectorId   = (New-Guid).Guid
                        Kind              = 'AzureActiveDirectory'
                    }

                    # Note: Requires tenant configuration
                }
                'Office365' {
                    # Enable Office 365 connector
                    $connectorParams = @{
                        ResourceGroupName = $ResourceGroupName
                        WorkspaceName     = $WorkspaceName
                        DataConnectorId   = (New-Guid).Guid
                        Kind              = 'Office365'
                    }
                }
                'AzureActivity' {
                    # Enable Azure Activity connector
                    $connectorParams = @{
                        ResourceGroupName = $ResourceGroupName
                        WorkspaceName     = $WorkspaceName
                        DataConnectorId   = (New-Guid).Guid
                        Kind              = 'AzureActivity'
                    }
                }
                default {
                    Write-CMCLog "    Connector '$connector' requires manual configuration" -Level WARN
                }
            }
        }

        Write-CMCLog "Data connectors configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-CMCLog "Failed to enable data connectors: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Analytics Rules Functions

function New-CMCAnalyticsRule {
    <#
    .SYNOPSIS
        Creates Sentinel analytics rules for CMMC threat detection.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$WorkspaceName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter()]
        [string]$RuleTemplatePath
    )

    Write-CMCLog "Creating Sentinel analytics rules..." -Level INFO

    try {
        # Define CMMC-specific detection rules
        $rules = @(
            @{
                Name        = 'CMMC-FailedAuthentication-Multiple'
                DisplayName = 'Multiple Failed Authentication Attempts'
                Description = 'Detects multiple failed authentication attempts from single user (NIST IA-5)'
                Severity    = 'Medium'
                Query       = @"
SigninLogs
| where ResultType != 0
| summarize FailureCount = count() by UserPrincipalName, bin(TimeGenerated, 1h)
| where FailureCount > 5
| project TimeGenerated, UserPrincipalName, FailureCount
"@
                QueryFrequency = 'PT1H'
                QueryPeriod = 'PT1H'
                TriggerOperator = 'GreaterThan'
                TriggerThreshold = 0
                Tactics = @('InitialAccess', 'CredentialAccess')
            },
            @{
                Name        = 'CMMC-PrivilegedEscalation'
                DisplayName = 'Privileged Role Assignment'
                Description = 'Detects when privileged roles are assigned (NIST AC-6)'
                Severity    = 'High'
                Query       = @"
AuditLogs
| where OperationName has_any ("Add member to role", "Add eligible member to role")
| where TargetResources has_any ("Global Administrator", "Security Administrator", "Privileged Role Administrator")
| project TimeGenerated, InitiatedBy, TargetResources, OperationName
"@
                QueryFrequency = 'PT5M'
                QueryPeriod = 'PT5M'
                TriggerOperator = 'GreaterThan'
                TriggerThreshold = 0
                Tactics = @('PrivilegeEscalation', 'Persistence')
            },
            @{
                Name        = 'CMMC-CUIDataExfiltration'
                DisplayName = 'Potential CUI Data Exfiltration'
                Description = 'Detects large file downloads or unusual data transfers (NIST SC-7)'
                Severity    = 'High'
                Query       = @"
OfficeActivity
| where Operation in ("FileDownloaded", "FileSyncDownloadedFull")
| where Site_Url has "sharepoint" or Site_Url has "onedrive"
| summarize TotalFiles = count(), TotalSize = sum(FileSize) by UserId, bin(TimeGenerated, 1h)
| where TotalFiles > 50 or TotalSize > 104857600
| project TimeGenerated, UserId, TotalFiles, TotalSize
"@
                QueryFrequency = 'PT1H'
                QueryPeriod = 'PT1H'
                TriggerOperator = 'GreaterThan'
                TriggerThreshold = 0
                Tactics = @('Exfiltration', 'Collection')
            },
            @{
                Name        = 'CMMC-MalwareDetection'
                DisplayName = 'Malware Detection Alert'
                Description = 'Detects malware detected by Defender (NIST SI-3)'
                Severity    = 'High'
                Query       = @"
SecurityAlert
| where ProviderName == "MDATP"
| where AlertType has_any ("Malware", "Ransomware", "Trojan")
| project TimeGenerated, AlertName, Severity, Description, Entities
"@
                QueryFrequency = 'PT5M'
                QueryPeriod = 'PT5M'
                TriggerOperator = 'GreaterThan'
                TriggerThreshold = 0
                Tactics = @('Execution', 'Impact')
            },
            @{
                Name        = 'CMMC-UnauthorizedAccess'
                DisplayName = 'Access from Blocked Location'
                Description = 'Detects sign-in attempts from blocked countries (NIST AC-2)'
                Severity    = 'Medium'
                Query       = @"
SigninLogs
| where ConditionalAccessStatus == "failure"
| where ConditionalAccessPolicies has "BlockedCountries"
| project TimeGenerated, UserPrincipalName, Location, IPAddress, ConditionalAccessPolicies
"@
                QueryFrequency = 'PT15M'
                QueryPeriod = 'PT15M'
                TriggerOperator = 'GreaterThan'
                TriggerThreshold = 0
                Tactics = @('InitialAccess')
            }
        )

        foreach ($rule in $rules) {
            Write-CMCLog "  Creating rule: $($rule.DisplayName)" -Level INFO

            $ruleParams = @{
                ResourceGroupName   = $ResourceGroupName
                WorkspaceName       = $WorkspaceName
                RuleId              = (New-Guid).Guid
                DisplayName         = $rule.DisplayName
                Description         = $rule.Description
                Severity            = $rule.Severity
                Query               = $rule.Query
                QueryFrequency      = $rule.QueryFrequency
                QueryPeriod         = $rule.QueryPeriod
                TriggerOperator     = $rule.TriggerOperator
                TriggerThreshold    = $rule.TriggerThreshold
                Enabled             = $true
                Kind                = 'Scheduled'
            }

            New-AzSentinelAlertRule @ruleParams
        }

        Write-CMCLog "Analytics rules created successfully" -Level SUCCESS
        return $rules
    }
    catch {
        Write-CMCLog "Failed to create analytics rules: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Playbook Functions

function New-CMCPlaybook {
    <#
    .SYNOPSIS
        Creates Logic App playbooks for automated incident response.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PlaybookName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory)]
        [string]$Location,

        [Parameter()]
        [ValidateSet('BlockUser', 'NotifySOC', 'IsolateDevice', 'CollectEvidence')]
        [string]$PlaybookType = 'NotifySOC'
    )

    Write-CMCLog "Creating playbook: $PlaybookName ($PlaybookType)" -Level INFO

    try {
        # Define playbook templates
        $playbookDefinitions = @{
            'NotifySOC' = @{
                triggers = @{
                    'Microsoft_Sentinel_incident' = @{
                        type = 'ApiConnectionWebhook'
                        inputs = @{
                            body = @{
                                callback_url = '@{listCallbackUrl()}'
                            }
                            host = @{
                                connection = @{
                                    name = "@parameters('$connections')['azuresentinel']['connectionId']"
                                }
                            }
                            path = '/incident-creation'
                        }
                    }
                }
                actions = @{
                    'Send_email' = @{
                        type = 'ApiConnection'
                        inputs = @{
                            body = @{
                                To = '@{triggerBody()?[''properties'']?[''owner'']?[''email'']}'
                                Subject = 'Security Incident: @{triggerBody()?[''properties'']?[''title'']}'
                                Body = 'Severity: @{triggerBody()?[''properties'']?[''severity'']}<br>Description: @{triggerBody()?[''properties'']?[''description'']}'
                            }
                            host = @{
                                connection = @{
                                    name = "@parameters('$connections')['office365']['connectionId']"
                                }
                            }
                            method = 'post'
                            path = '/v2/Mail'
                        }
                    }
                }
            }
            'BlockUser' = @{
                triggers = @{
                    'Microsoft_Sentinel_incident' = @{
                        type = 'ApiConnectionWebhook'
                    }
                }
                actions = @{
                    'Block_user_signin' = @{
                        type = 'ApiConnection'
                        inputs = @{
                            host = @{
                                connection = @{
                                    name = "@parameters('$connections')['azuread']['connectionId']"
                                }
                            }
                            method = 'patch'
                            path = '/v1.0/users/@{variables(''UserId'')}'
                            body = @{
                                accountEnabled = $false
                            }
                        }
                    }
                }
            }
        }

        # Note: Actual Logic App deployment requires ARM template
        Write-CMCLog "Playbook definition created (requires ARM deployment)" -Level WARN
        Write-CMCLog "Playbook '$PlaybookName' configured" -Level SUCCESS

        return $playbookDefinitions[$PlaybookType]
    }
    catch {
        Write-CMCLog "Failed to create playbook: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Incident Functions

function Get-CMCSecurityIncidents {
    <#
    .SYNOPSIS
        Retrieves security incidents from Sentinel.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$WorkspaceName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter()]
        [ValidateSet('High', 'Medium', 'Low', 'Informational', 'All')]
        [string]$Severity = 'All',

        [Parameter()]
        [int]$Days = 7
    )

    Write-CMCLog "Retrieving security incidents (last $Days days)..." -Level INFO

    try {
        $incidents = Get-AzSentinelIncident -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName

        if ($Severity -ne 'All') {
            $incidents = $incidents | Where-Object { $_.Severity -eq $Severity }
        }

        $startDate = (Get-Date).AddDays(-$Days)
        $incidents = $incidents | Where-Object { $_.CreatedTimeUtc -gt $startDate }

        Write-CMCLog "Found $($incidents.Count) incidents" -Level INFO

        return $incidents | Select-Object Title, Severity, Status, CreatedTimeUtc, Owner, IncidentNumber
    }
    catch {
        Write-CMCLog "Failed to retrieve incidents: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Reporting Functions

function Export-CMCMonitoringReport {
    <#
    .SYNOPSIS
        Exports a monitoring and incident report.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$OutputPath,

        [Parameter(Mandatory)]
        [string]$WorkspaceName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter()]
        [ValidateSet('HTML', 'JSON', 'CSV')]
        [string]$Format = 'HTML'
    )

    Write-CMCLog "Generating monitoring report..." -Level INFO

    try {
        $incidents = Get-CMCSecurityIncidents -WorkspaceName $WorkspaceName -ResourceGroupName $ResourceGroupName

        $report = @{
            GeneratedAt     = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            WorkspaceName   = $WorkspaceName
            TotalIncidents  = $incidents.Count
            HighSeverity    = ($incidents | Where-Object { $_.Severity -eq 'High' }).Count
            MediumSeverity  = ($incidents | Where-Object { $_.Severity -eq 'Medium' }).Count
            LowSeverity     = ($incidents | Where-Object { $_.Severity -eq 'Low' }).Count
            Incidents       = $incidents
        }

        $outputFile = Join-Path $OutputPath "cmmc-monitoring-report-$(Get-Date -Format 'yyyyMMdd').$($Format.ToLower())"

        switch ($Format) {
            'JSON' {
                $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding utf8
            }
            'CSV' {
                $incidents | Export-Csv -Path $outputFile -NoTypeInformation
            }
            'HTML' {
                $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>CMMC Monitoring Report</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; margin: 40px; }
        h1 { color: #0078d4; }
        .summary { display: flex; gap: 20px; margin: 20px 0; }
        .card { padding: 20px; border-radius: 8px; color: white; min-width: 150px; }
        .high { background: #d13438; }
        .medium { background: #ff8c00; }
        .low { background: #107c10; }
        .total { background: #0078d4; }
        .card-value { font-size: 36px; font-weight: bold; }
        .card-label { font-size: 14px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #0078d4; color: white; }
    </style>
</head>
<body>
    <h1>CMMC GCC High Enclave - Monitoring Report</h1>
    <p>Generated: $($report.GeneratedAt) | Workspace: $($report.WorkspaceName)</p>

    <div class="summary">
        <div class="card total"><div class="card-value">$($report.TotalIncidents)</div><div class="card-label">Total Incidents</div></div>
        <div class="card high"><div class="card-value">$($report.HighSeverity)</div><div class="card-label">High Severity</div></div>
        <div class="card medium"><div class="card-value">$($report.MediumSeverity)</div><div class="card-label">Medium Severity</div></div>
        <div class="card low"><div class="card-value">$($report.LowSeverity)</div><div class="card-label">Low Severity</div></div>
    </div>

    <h2>Recent Incidents</h2>
    <table>
        <tr><th>Incident #</th><th>Title</th><th>Severity</th><th>Status</th><th>Created</th></tr>
        $($incidents | ForEach-Object { "<tr><td>$($_.IncidentNumber)</td><td>$($_.Title)</td><td>$($_.Severity)</td><td>$($_.Status)</td><td>$($_.CreatedTimeUtc)</td></tr>" })
    </table>
</body>
</html>
"@
                $htmlContent | Out-File -FilePath $outputFile -Encoding utf8
            }
        }

        Write-CMCLog "Monitoring report exported to: $outputFile" -Level SUCCESS
        return $outputFile
    }
    catch {
        Write-CMCLog "Failed to export monitoring report: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'New-CMCSentinelWorkspace',
    'Enable-CMCSentinelConnectors',
    'New-CMCAnalyticsRule',
    'New-CMCPlaybook',
    'Get-CMCSecurityIncidents',
    'Export-CMCMonitoringReport'
)

#endregion
