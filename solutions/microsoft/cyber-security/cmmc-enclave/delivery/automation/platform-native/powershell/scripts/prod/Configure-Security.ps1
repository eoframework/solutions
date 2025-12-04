#Requires -Version 7.0
<#
.SYNOPSIS
    Configures security controls for CMMC GCC High Enclave.

.DESCRIPTION
    This script configures Microsoft Defender for Cloud, Defender for Office 365,
    and other security controls required for CMMC Level 2 compliance.

.PARAMETER ConfigPath
    Path to the environment configuration file (.psd1).

.PARAMETER Rollback
    Rollback to a previous configuration state.

.PARAMETER BackupPath
    Path to backup directory for rollback operations.

.EXAMPLE
    .\Configure-Security.ps1 -ConfigPath ..\config\prod.psd1

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$ConfigPath,

    [Parameter()]
    [switch]$Rollback,

    [Parameter()]
    [string]$BackupPath
)

$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot

#region Module Imports

$modulesPath = Join-Path $scriptRoot '..\..\modules'
Import-Module (Join-Path $modulesPath 'CMMC-Common\CMMC-Common.psm1') -Force
Import-Module (Join-Path $modulesPath 'CMMC-Security\CMMC-Security.psm1') -Force

#endregion

#region Main Execution

function Main {
    Write-CMCLog "========================================" -Level INFO
    Write-CMCLog "CMMC Security Configuration" -Level INFO
    Write-CMCLog "========================================" -Level INFO

    # Load configuration
    $config = Import-CMCConfiguration -ConfigPath $ConfigPath

    Write-CMCLog "Environment: $(Split-Path -Leaf (Split-Path $ConfigPath))" -Level INFO
    Write-CMCLog "Subscription: $($config.azure_gov.subscription_id)" -Level INFO

    if ($Rollback) {
        Invoke-SecurityRollback -BackupPath $BackupPath -Config $config
        return
    }

    try {
        # Step 1: Configure Defender for Cloud
        Write-CMCLog "Step 1: Configuring Defender for Cloud..." -Level INFO
        if ($config.security.defender_for_cloud_enabled) {
            Enable-CMCDefenderForCloud `
                -SubscriptionId $config.azure_gov.subscription_id `
                -Tier 'Standard'

            Set-CMCSecurityContact `
                -Email $config.monitoring.alert_email `
                -AlertsToAdmins
        }
        else {
            Write-CMCLog "  Defender for Cloud disabled in configuration" -Level WARN
        }

        # Step 2: Configure Defender for Office 365
        Write-CMCLog "Step 2: Configuring Defender for Office 365..." -Level INFO
        if ($config.security.defender_for_office_enabled) {
            Enable-CMCDefenderForOffice -Config $config
        }
        else {
            Write-CMCLog "  Defender for Office 365 disabled in configuration" -Level WARN
        }

        # Step 3: Configure Threat Protection
        Write-CMCLog "Step 3: Configuring Threat Protection..." -Level INFO
        Set-CMCThreatProtection `
            -EnableThreatIntelligence:$config.security.enable_threat_intelligence

        # Step 4: Create Security Baseline
        Write-CMCLog "Step 4: Creating Security Baseline..." -Level INFO
        $baseline = New-CMCSecurityBaseline -Config $config

        # Backup baseline for potential rollback
        $backupDir = Join-Path $scriptRoot '..\..\..\..\backups' (Get-Date -Format 'yyyy-MM-dd')
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        Backup-CMCConfiguration -BackupName 'security-baseline' -Configuration $baseline -BackupDirectory (Split-Path $backupDir)

        # Step 5: Get and display Secure Score
        Write-CMCLog "Step 5: Retrieving Microsoft Secure Score..." -Level INFO
        try {
            $secureScore = Get-CMCSecurityScore
            Write-CMCLog "Current Secure Score: $($secureScore.CurrentScore)/$($secureScore.MaxScore) ($($secureScore.Percentage)%)" -Level INFO
        }
        catch {
            Write-CMCLog "Unable to retrieve Secure Score (may require additional permissions)" -Level WARN
        }

        Write-CMCLog "========================================" -Level SUCCESS
        Write-CMCLog "Security configuration completed!" -Level SUCCESS
        Write-CMCLog "========================================" -Level SUCCESS
    }
    catch {
        Write-CMCLog "Security configuration failed: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Invoke-SecurityRollback {
    param(
        [string]$BackupPath,
        [hashtable]$Config
    )

    Write-CMCLog "Starting security rollback..." -Level WARN

    if (-not $BackupPath -or -not (Test-Path $BackupPath)) {
        Write-CMCLog "Valid backup path required for rollback" -Level ERROR
        return
    }

    $baselineBackup = Join-Path $BackupPath 'security-baseline.json'
    if (Test-Path $baselineBackup) {
        Write-CMCLog "Restoring security baseline from backup..." -Level INFO
        $baseline = Restore-CMCConfiguration -BackupFile $baselineBackup
        Write-CMCLog "Security baseline restored" -Level SUCCESS
    }

    Write-CMCLog "Security rollback completed" -Level SUCCESS
}

#endregion

# Execute main function
Main
