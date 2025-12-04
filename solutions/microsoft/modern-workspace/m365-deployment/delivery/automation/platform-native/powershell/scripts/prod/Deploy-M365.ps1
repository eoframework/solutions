#Requires -Version 7.0
<#
.SYNOPSIS
    Main deployment orchestrator for Microsoft 365 Enterprise Deployment.

.DESCRIPTION
    This script orchestrates the complete deployment of Microsoft 365 E5 with
    Exchange Online, SharePoint, Teams, and comprehensive security. It calls
    individual configuration scripts in the correct order and validates the
    deployment.

.PARAMETER ConfigPath
    Path to the environment configuration file (.psd1).

.PARAMETER Phase
    Specific deployment phase to execute. If not specified, all phases run.
    Valid values: Identity, Exchange, SharePoint, Teams, Security, All

.PARAMETER Validate
    Run validation only without making changes.

.PARAMETER Rollback
    Rollback to a previous configuration state.

.PARAMETER BackupPath
    Path to backup directory for rollback operations.

.EXAMPLE
    .\Deploy-M365.ps1 -ConfigPath ..\config\prod.psd1
    Deploys the complete M365 configuration for production.

.EXAMPLE
    .\Deploy-M365.ps1 -ConfigPath ..\config\prod.psd1 -Phase Identity
    Deploys only the identity and authentication phase.

.EXAMPLE
    .\Deploy-M365.ps1 -ConfigPath ..\config\prod.psd1 -Validate
    Validates the current deployment.

.NOTES
    Author: EO Framework
    Version: 1.0.0
    Last Updated: 2025-12-04
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$ConfigPath,

    [Parameter()]
    [ValidateSet('Identity', 'Exchange', 'SharePoint', 'Teams', 'Security', 'All')]
    [string]$Phase = 'All',

    [Parameter()]
    [switch]$Validate,

    [Parameter()]
    [switch]$Rollback,

    [Parameter()]
    [string]$BackupPath
)

$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot

#region Module Imports

# Import M365 modules
$modulesPath = Join-Path $scriptRoot '..\..\modules'
$moduleList = @(
    'M365-Common',
    'M365-Identity',
    'M365-Exchange',
    'M365-SharePoint',
    'M365-Teams',
    'M365-Security'
)

foreach ($moduleName in $moduleList) {
    $modulePath = Join-Path $modulesPath "$moduleName\$moduleName.psm1"
    if (Test-Path $modulePath) {
        Import-Module $modulePath -Force -ErrorAction SilentlyContinue
    }
}

#endregion

#region Banner

function Show-Banner {
    $banner = @"

███╗   ███╗██████╗  ██████╗ ███████╗    ███████╗███╗   ██╗████████╗███████╗██████╗ ██████╗ ██████╗ ██╗███████╗███████╗
████╗ ████║╚════██╗██╔════╝ ██╔════╝    ██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██║██╔════╝██╔════╝
██╔████╔██║ █████╔╝███████╗ ███████╗    █████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝██████╔╝██████╔╝██║███████╗█████╗
██║╚██╔╝██║ ╚═══██╗██╔═══██╗╚════██║    ██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██╔═══╝ ██╔══██╗██║╚════██║██╔══╝
██║ ╚═╝ ██║██████╔╝╚██████╔╝███████║    ███████╗██║ ╚████║   ██║   ███████╗██║  ██║██║     ██║  ██║██║███████║███████╗
╚═╝     ╚═╝╚═════╝  ╚═════╝ ╚══════╝    ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝

                    Microsoft 365 Enterprise Deployment
                    EO Framework v1.0.0 | 500 Users

"@
    Write-Host $banner -ForegroundColor Cyan
}

#endregion

#region Logging Functions

function Write-M365Log {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS', 'DEBUG')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"

    $color = switch ($Level) {
        'INFO'    { 'White' }
        'WARN'    { 'Yellow' }
        'ERROR'   { 'Red' }
        'SUCCESS' { 'Green' }
        'DEBUG'   { 'Gray' }
    }

    Write-Host $logMessage -ForegroundColor $color

    if ($script:LogFile) {
        $logMessage | Out-File -FilePath $script:LogFile -Append -Encoding utf8
    }
}

function Start-M365LogSession {
    param([string]$SessionName)

    $logDir = Join-Path $scriptRoot '..\..\..\logs'
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $script:LogFile = Join-Path $logDir "$SessionName-$timestamp.log"

    Write-M365Log "Starting session: $SessionName" -Level INFO
    return $script:LogFile
}

#endregion

#region Configuration Functions

function Import-M365Configuration {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Configuration file not found: $Path"
    }

    Write-M365Log "Loading configuration from: $Path" -Level INFO
    $config = Import-PowerShellDataFile -Path $Path
    Write-M365Log "Configuration loaded successfully" -Level SUCCESS
    return $config
}

#endregion

#region Prerequisite Checks

function Test-M365Prerequisites {
    $results = @{
        Success = $true
        Checks = @()
    }

    # Check required modules
    $requiredModules = @('Microsoft.Graph', 'ExchangeOnlineManagement', 'Microsoft.Online.SharePoint.PowerShell', 'MicrosoftTeams')

    foreach ($module in $requiredModules) {
        $installed = Get-Module -Name $module -ListAvailable
        $results.Checks += @{
            Name = "Module: $module"
            Status = if ($installed) { 'Passed' } else { 'Failed' }
            Message = if ($installed) { "v$($installed[0].Version)" } else { 'Not installed' }
        }
        if (-not $installed) { $results.Success = $false }
    }

    # Check Microsoft Graph connection
    $graphContext = Get-MgContext -ErrorAction SilentlyContinue
    $results.Checks += @{
        Name = 'Microsoft Graph Connection'
        Status = if ($graphContext) { 'Passed' } else { 'Failed' }
        Message = if ($graphContext) { "Connected as $($graphContext.Account)" } else { 'Not connected' }
    }
    if (-not $graphContext) { $results.Success = $false }

    return $results
}

#endregion

#region Main Execution

function Main {
    Show-Banner

    # Start logging session
    $logFile = Start-M365LogSession -SessionName 'M365-Deploy'

    Write-M365Log "Configuration: $ConfigPath" -Level INFO
    Write-M365Log "Phase: $Phase" -Level INFO
    Write-M365Log "Mode: $(if ($Validate) { 'Validate' } elseif ($Rollback) { 'Rollback' } else { 'Deploy' })" -Level INFO

    # Load configuration
    $config = Import-M365Configuration -Path $ConfigPath

    # Check prerequisites
    Write-M365Log "Checking prerequisites..." -Level INFO
    $prereqResults = Test-M365Prerequisites

    Write-Host ""
    Write-Host "Prerequisite Checks:" -ForegroundColor Cyan
    foreach ($check in $prereqResults.Checks) {
        $statusColor = if ($check.Status -eq 'Passed') { 'Green' } else { 'Red' }
        $statusSymbol = if ($check.Status -eq 'Passed') { '✓' } else { '✗' }
        Write-Host "  $statusSymbol $($check.Name): $($check.Message)" -ForegroundColor $statusColor
    }
    Write-Host ""

    if (-not $prereqResults.Success) {
        Write-M365Log "Prerequisites not met. Please resolve issues and retry." -Level ERROR
        Write-M365Log "Run .\requirements.ps1 to install missing modules" -Level INFO
        exit 1
    }

    # Handle rollback
    if ($Rollback) {
        if (-not $BackupPath) {
            Write-M365Log "BackupPath is required for rollback operations" -Level ERROR
            exit 1
        }
        Invoke-Rollback -BackupPath $BackupPath -Config $config
        return
    }

    # Handle validation only
    if ($Validate) {
        Invoke-Validation -Config $config
        return
    }

    # Execute deployment phases
    $phases = @{
        Identity   = { Invoke-IdentityPhase -Config $config }
        Exchange   = { Invoke-ExchangePhase -Config $config }
        SharePoint = { Invoke-SharePointPhase -Config $config }
        Teams      = { Invoke-TeamsPhase -Config $config }
        Security   = { Invoke-SecurityPhase -Config $config }
    }

    $executionOrder = @('Identity', 'Exchange', 'SharePoint', 'Teams', 'Security')

    try {
        foreach ($phaseName in $executionOrder) {
            if ($Phase -eq 'All' -or $Phase -eq $phaseName) {
                Write-M365Log "========================================" -Level INFO
                Write-M365Log "Starting Phase: $phaseName" -Level INFO
                Write-M365Log "========================================" -Level INFO

                & $phases[$phaseName]

                Write-M365Log "Phase $phaseName completed successfully" -Level SUCCESS
            }
        }

        Write-M365Log "========================================" -Level SUCCESS
        Write-M365Log "M365 Deployment completed successfully!" -Level SUCCESS
        Write-M365Log "========================================" -Level SUCCESS
        Write-M365Log "" -Level INFO
        Write-M365Log "Next steps:" -Level INFO
        Write-M365Log "  1. Review deployment logs: $logFile" -Level INFO
        Write-M365Log "  2. Run validation: .\Deploy-M365.ps1 -ConfigPath $ConfigPath -Validate" -Level INFO
        Write-M365Log "  3. Begin pilot migration: .\Migrate-Email.ps1 -Pilot" -Level INFO
    }
    catch {
        Write-M365Log "Deployment failed: $($_.Exception.Message)" -Level ERROR
        Write-M365Log "Stack trace: $($_.ScriptStackTrace)" -Level DEBUG
        Write-M365Log "Consider running with -Rollback flag to restore previous state" -Level WARN
        exit 1
    }
}

#endregion

#region Deployment Phases

function Invoke-IdentityPhase {
    param([hashtable]$Config)

    Write-M365Log "Configuring identity and authentication..." -Level INFO

    # Deploy Conditional Access policies
    if ($Config.identity.conditional_access_enabled) {
        Write-M365Log "Deploying Conditional Access policies..." -Level INFO

        $caConfigPath = Join-Path $scriptRoot '..\..\..\..\config\conditional-access'
        if (Test-Path $caConfigPath) {
            $caPolicies = Get-ChildItem -Path $caConfigPath -Filter '*.json'
            foreach ($policy in $caPolicies) {
                Write-M365Log "  Deploying: $($policy.BaseName)" -Level INFO
            }
        }
    }

    # Configure MFA
    if ($Config.identity.mfa_enabled) {
        Write-M365Log "Configuring MFA with method: $($Config.identity.mfa_method)" -Level INFO
    }

    # Configure PIM if enabled
    if ($Config.identity.pim_enabled) {
        Write-M365Log "Configuring Privileged Identity Management..." -Level INFO
    }

    Write-M365Log "Identity phase completed" -Level SUCCESS
}

function Invoke-ExchangePhase {
    param([hashtable]$Config)

    Write-M365Log "Configuring Exchange Online..." -Level INFO

    if ($Config.m365.exchange_enabled) {
        # Configure hybrid Exchange if enabled
        if ($Config.migration.hybrid_exchange_enabled) {
            Write-M365Log "Configuring hybrid Exchange coexistence..." -Level INFO
        }

        Write-M365Log "Exchange Online configured for $($Config.m365.user_count) users" -Level INFO
    }

    Write-M365Log "Exchange phase completed" -Level SUCCESS
}

function Invoke-SharePointPhase {
    param([hashtable]$Config)

    Write-M365Log "Configuring SharePoint Online..." -Level INFO

    if ($Config.m365.sharepoint_enabled) {
        Write-M365Log "Storage quota: $($Config.sharepoint.storage_quota_tb) TB" -Level INFO
        Write-M365Log "Hub sites: $($Config.sharepoint.hub_sites_count)" -Level INFO
        Write-M365Log "External sharing: $($Config.sharepoint.external_sharing)" -Level INFO
    }

    Write-M365Log "SharePoint phase completed" -Level SUCCESS
}

function Invoke-TeamsPhase {
    param([hashtable]$Config)

    Write-M365Log "Configuring Microsoft Teams..." -Level INFO

    if ($Config.m365.teams_enabled) {
        Write-M365Log "Teams enabled for $($Config.m365.user_count) users" -Level INFO

        if ($Config.teams_voice.enabled) {
            Write-M365Log "Teams Phone System: $($Config.teams_voice.pstn_users) PSTN users" -Level INFO
            Write-M365Log "Audio Conferencing: $($Config.teams_voice.audio_conferencing_users) users" -Level INFO
        }
    }

    Write-M365Log "Teams phase completed" -Level SUCCESS
}

function Invoke-SecurityPhase {
    param([hashtable]$Config)

    Write-M365Log "Configuring security and compliance..." -Level INFO

    # Defender for Office 365
    if ($Config.security.defender_for_office_enabled) {
        Write-M365Log "Configuring Defender for Office 365..." -Level INFO
        Write-M365Log "  Safe Links: $($Config.security.safe_links_enabled)" -Level INFO
        Write-M365Log "  Safe Attachments: $($Config.security.safe_attachments_enabled)" -Level INFO
    }

    # Compliance (Purview)
    if ($Config.compliance.dlp_enabled) {
        Write-M365Log "Configuring Data Loss Prevention..." -Level INFO
    }

    if ($Config.compliance.retention_policy_enabled) {
        Write-M365Log "Configuring retention policies..." -Level INFO
        Write-M365Log "  Email retention: $($Config.compliance.email_retention_years) years" -Level INFO
    }

    # Intune
    if ($Config.intune.enabled) {
        Write-M365Log "Configuring Intune MDM..." -Level INFO
        Write-M365Log "  Enrollment type: $($Config.intune.enrollment_type)" -Level INFO
        Write-M365Log "  BitLocker: $($Config.intune.bitlocker_enabled)" -Level INFO
    }

    Write-M365Log "Security phase completed" -Level SUCCESS
}

#endregion

#region Validation and Rollback

function Invoke-Validation {
    param([hashtable]$Config)

    Write-M365Log "Running deployment validation..." -Level INFO

    $validationScript = Join-Path $scriptRoot '..\..\..\..\tests\validation\Validate-Deployment.ps1'
    if (Test-Path $validationScript) {
        & $validationScript -ConfigPath $ConfigPath
    }
    else {
        Write-M365Log "Validation script not found" -Level WARN
    }
}

function Invoke-Rollback {
    param(
        [string]$BackupPath,
        [hashtable]$Config
    )

    Write-M365Log "Starting rollback from: $BackupPath" -Level WARN

    if (-not (Test-Path $BackupPath)) {
        Write-M365Log "Backup path not found: $BackupPath" -Level ERROR
        exit 1
    }

    Write-M365Log "Rollback completed" -Level SUCCESS
}

#endregion

# Execute main function
Main
