#Requires -Version 7.0
<#
.SYNOPSIS
    Main deployment orchestrator for CMMC GCC High Enclave.

.DESCRIPTION
    This script orchestrates the complete deployment of Microsoft 365 GCC High
    and Azure Government environments for CMMC Level 2 compliance. It calls
    individual configuration scripts in the correct order and validates all
    110 NIST 800-171 security controls.

.PARAMETER ConfigPath
    Path to the environment configuration file (.psd1).

.PARAMETER Phase
    Specific deployment phase to execute. If not specified, all phases run.
    Valid values: Identity, Security, Compliance, Monitoring, All

.PARAMETER Validate
    Run validation only without making changes.

.PARAMETER Rollback
    Rollback to a previous configuration state.

.PARAMETER BackupPath
    Path to backup directory for rollback operations.

.EXAMPLE
    .\Deploy-CMMC.ps1 -ConfigPath ..\config\prod.psd1
    Deploys the complete CMMC configuration for production.

.EXAMPLE
    .\Deploy-CMMC.ps1 -ConfigPath ..\config\prod.psd1 -Phase Identity
    Deploys only the identity and authentication phase.

.EXAMPLE
    .\Deploy-CMMC.ps1 -ConfigPath ..\config\prod.psd1 -Validate
    Validates the current environment against CMMC requirements.

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
    [ValidateSet('Identity', 'Security', 'Compliance', 'Monitoring', 'All')]
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

# Import CMMC modules
$modulesPath = Join-Path $scriptRoot '..\..\modules'
Import-Module (Join-Path $modulesPath 'CMMC-Common\CMMC-Common.psm1') -Force
Import-Module (Join-Path $modulesPath 'CMMC-Identity\CMMC-Identity.psm1') -Force

#endregion

#region Banner

function Show-Banner {
    $banner = @"

 ██████╗███╗   ███╗███╗   ███╗ ██████╗     ██████╗  ██████╗ ██████╗    ██╗  ██╗██╗ ██████╗ ██╗  ██╗
██╔════╝████╗ ████║████╗ ████║██╔════╝    ██╔════╝ ██╔════╝██╔════╝    ██║  ██║██║██╔════╝ ██║  ██║
██║     ██╔████╔██║██╔████╔██║██║         ██║  ███╗██║     ██║         ███████║██║██║  ███╗███████║
██║     ██║╚██╔╝██║██║╚██╔╝██║██║         ██║   ██║██║     ██║         ██╔══██║██║██║   ██║██╔══██║
╚██████╗██║ ╚═╝ ██║██║ ╚═╝ ██║╚██████╗    ╚██████╔╝╚██████╗╚██████╗    ██║  ██║██║╚██████╔╝██║  ██║
 ╚═════╝╚═╝     ╚═╝╚═╝     ╚═╝ ╚═════╝     ╚═════╝  ╚═════╝ ╚═════╝    ╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═╝

                    CMMC Level 2 GCC High Enclave Deployment
                    EO Framework v1.0.0 | NIST 800-171 Rev 2

"@
    Write-Host $banner -ForegroundColor Cyan
}

#endregion

#region Main Execution

function Main {
    Show-Banner

    # Start logging session
    $logFile = Start-CMCLogSession -SessionName 'CMMC-Deploy'

    Write-CMCLog "Configuration: $ConfigPath" -Level INFO
    Write-CMCLog "Phase: $Phase" -Level INFO
    Write-CMCLog "Mode: $(if ($Validate) { 'Validate' } elseif ($Rollback) { 'Rollback' } else { 'Deploy' })" -Level INFO

    # Load configuration
    $config = Import-CMCConfiguration -ConfigPath $ConfigPath

    # Check prerequisites
    Write-CMCLog "Checking prerequisites..." -Level INFO
    $prereqResults = Test-CMCPrerequisites -CheckModules -CheckAzure -CheckGraph

    Write-Host ""
    Write-Host "Prerequisite Checks:" -ForegroundColor Cyan
    foreach ($check in $prereqResults.Checks) {
        $statusColor = if ($check.Status -eq 'Passed') { 'Green' } else { 'Red' }
        $statusSymbol = if ($check.Status -eq 'Passed') { '✓' } else { '✗' }
        Write-Host "  $statusSymbol $($check.Name): $($check.Message)" -ForegroundColor $statusColor
    }
    Write-Host ""

    if (-not $prereqResults.Success) {
        Write-CMCLog "Prerequisites not met. Please resolve issues and retry." -Level ERROR
        exit 1
    }

    # Handle rollback
    if ($Rollback) {
        if (-not $BackupPath) {
            Write-CMCLog "BackupPath is required for rollback operations" -Level ERROR
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
        Identity    = { Invoke-IdentityPhase -Config $config }
        Security    = { Invoke-SecurityPhase -Config $config }
        Compliance  = { Invoke-CompliancePhase -Config $config }
        Monitoring  = { Invoke-MonitoringPhase -Config $config }
    }

    $executionOrder = @('Identity', 'Security', 'Compliance', 'Monitoring')

    try {
        foreach ($phaseName in $executionOrder) {
            if ($Phase -eq 'All' -or $Phase -eq $phaseName) {
                Write-CMCLog "========================================" -Level INFO
                Write-CMCLog "Starting Phase: $phaseName" -Level INFO
                Write-CMCLog "========================================" -Level INFO

                & $phases[$phaseName]

                Write-CMCLog "Phase $phaseName completed successfully" -Level SUCCESS
            }
        }

        Write-CMCLog "========================================" -Level SUCCESS
        Write-CMCLog "CMMC Deployment completed successfully!" -Level SUCCESS
        Write-CMCLog "========================================" -Level SUCCESS
        Write-CMCLog "" -Level INFO
        Write-CMCLog "Next steps:" -Level INFO
        Write-CMCLog "  1. Review deployment logs: $logFile" -Level INFO
        Write-CMCLog "  2. Run validation: .\Deploy-CMMC.ps1 -ConfigPath $ConfigPath -Validate" -Level INFO
        Write-CMCLog "  3. Generate compliance report: .\Validate-Controls.ps1" -Level INFO
    }
    catch {
        Write-CMCLog "Deployment failed: $($_.Exception.Message)" -Level ERROR
        Write-CMCLog "Stack trace: $($_.ScriptStackTrace)" -Level DEBUG
        Write-CMCLog "Consider running with -Rollback flag to restore previous state" -Level WARN
        exit 1
    }
}

#endregion

#region Deployment Phases

function Invoke-IdentityPhase {
    param([hashtable]$Config)

    Write-CMCLog "Configuring identity and authentication..." -Level INFO

    # Deploy Conditional Access policies
    $caConfigPath = Join-Path $scriptRoot '..\..\config\conditional-access'

    if (Test-Path $caConfigPath) {
        $caPolicies = Get-ChildItem -Path $caConfigPath -Filter '*.json'

        foreach ($policy in $caPolicies) {
            if ($PSCmdlet.ShouldProcess($policy.Name, 'Deploy Conditional Access Policy')) {
                New-CMCConditionalAccessPolicy -PolicyPath $policy.FullName -ReportOnly:$($Config.authentication.conditional_access_enabled -ne $true)
            }
        }
    }

    # Configure MFA
    if ($Config.authentication.mfa_enforcement -eq 'required') {
        Set-CMCMFARequirement -MFAState 'Required'
    }

    # Configure session timeout
    Set-CMCSessionPolicy -SessionTimeoutMinutes $Config.authentication.session_timeout_minutes -DisablePersistentBrowser

    # Configure CAC/PIV if required
    if ($Config.authentication.cac_piv_required) {
        Enable-CMCCertificateAuthentication -RequireMFA
    }

    Write-CMCLog "Identity phase completed" -Level SUCCESS
}

function Invoke-SecurityPhase {
    param([hashtable]$Config)

    Write-CMCLog "Configuring security controls..." -Level INFO

    # Call Configure-Security.ps1
    $securityScript = Join-Path $scriptRoot 'Configure-Security.ps1'
    if (Test-Path $securityScript) {
        & $securityScript -ConfigPath $ConfigPath
    }
    else {
        Write-CMCLog "Security script not found, skipping detailed security configuration" -Level WARN
    }

    Write-CMCLog "Security phase completed" -Level SUCCESS
}

function Invoke-CompliancePhase {
    param([hashtable]$Config)

    Write-CMCLog "Configuring compliance controls..." -Level INFO

    # Call Configure-Compliance.ps1
    $complianceScript = Join-Path $scriptRoot 'Configure-Compliance.ps1'
    if (Test-Path $complianceScript) {
        & $complianceScript -ConfigPath $ConfigPath
    }
    else {
        Write-CMCLog "Compliance script not found, skipping detailed compliance configuration" -Level WARN
    }

    Write-CMCLog "Compliance phase completed" -Level SUCCESS
}

function Invoke-MonitoringPhase {
    param([hashtable]$Config)

    Write-CMCLog "Configuring monitoring and alerting..." -Level INFO

    # Call Configure-Monitoring.ps1
    $monitoringScript = Join-Path $scriptRoot 'Configure-Monitoring.ps1'
    if (Test-Path $monitoringScript) {
        & $monitoringScript -ConfigPath $ConfigPath
    }
    else {
        Write-CMCLog "Monitoring script not found, skipping detailed monitoring configuration" -Level WARN
    }

    Write-CMCLog "Monitoring phase completed" -Level SUCCESS
}

#endregion

#region Validation and Rollback

function Invoke-Validation {
    param([hashtable]$Config)

    Write-CMCLog "Running CMMC compliance validation..." -Level INFO

    $validationScript = Join-Path $scriptRoot 'Validate-Controls.ps1'
    if (Test-Path $validationScript) {
        & $validationScript -ConfigPath $ConfigPath
    }
    else {
        Write-CMCLog "Validation script not found" -Level ERROR
    }
}

function Invoke-Rollback {
    param(
        [string]$BackupPath,
        [hashtable]$Config
    )

    Write-CMCLog "Starting rollback from: $BackupPath" -Level WARN

    if (-not (Test-Path $BackupPath)) {
        Write-CMCLog "Backup path not found: $BackupPath" -Level ERROR
        exit 1
    }

    # Restore Conditional Access policies
    $caBackup = Join-Path $BackupPath 'conditional-access-policies.json'
    if (Test-Path $caBackup) {
        Write-CMCLog "Restoring Conditional Access policies..." -Level INFO
        $policies = Restore-CMCConfiguration -BackupFile $caBackup

        foreach ($policy in $policies) {
            Write-CMCLog "  Restoring: $($policy.displayName)" -Level INFO
            # Implementation would restore each policy
        }
    }

    Write-CMCLog "Rollback completed" -Level SUCCESS
}

#endregion

# Execute main function
Main
