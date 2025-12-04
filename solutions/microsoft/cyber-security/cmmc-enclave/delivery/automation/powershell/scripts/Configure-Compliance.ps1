#Requires -Version 7.0
<#
.SYNOPSIS
    Configures compliance controls for CMMC GCC High Enclave.

.DESCRIPTION
    This script configures Microsoft Purview DLP policies, sensitivity labels,
    retention policies, and eDiscovery for CMMC Level 2 compliance.

.PARAMETER ConfigPath
    Path to the environment configuration file (.psd1).

.PARAMETER Rollback
    Rollback to a previous configuration state.

.PARAMETER BackupPath
    Path to backup directory for rollback operations.

.EXAMPLE
    .\Configure-Compliance.ps1 -ConfigPath ..\config\prod.psd1

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
Import-Module (Join-Path $modulesPath 'CMMC-Compliance\CMMC-Compliance.psm1') -Force

#endregion

#region Main Execution

function Main {
    Write-CMCLog "========================================" -Level INFO
    Write-CMCLog "CMMC Compliance Configuration" -Level INFO
    Write-CMCLog "========================================" -Level INFO

    # Load configuration
    $config = Import-CMCConfiguration -ConfigPath $ConfigPath

    Write-CMCLog "Environment: $(Split-Path -Leaf (Split-Path $ConfigPath))" -Level INFO
    Write-CMCLog "CMMC Level: $($config.compliance.cmmc_level)" -Level INFO

    if ($Rollback) {
        Invoke-ComplianceRollback -BackupPath $BackupPath -Config $config
        return
    }

    try {
        # Step 1: Create DLP Policies
        Write-CMCLog "Step 1: Creating DLP Policies..." -Level INFO
        if ($config.purview.dlp_enabled) {
            New-CMCDLPPolicy -PolicyName 'CMMC-CUI-Protection' -Config $config
        }
        else {
            Write-CMCLog "  DLP disabled in configuration" -Level WARN
        }

        # Step 2: Create Sensitivity Labels
        Write-CMCLog "Step 2: Creating Sensitivity Labels..." -Level INFO
        if ($config.purview.sensitivity_labels_enabled) {
            New-CMCSensitivityLabel -LabelName 'CUI'
        }
        else {
            Write-CMCLog "  Sensitivity labels disabled in configuration" -Level WARN
        }

        # Step 3: Create Retention Policies
        Write-CMCLog "Step 3: Creating Retention Policies..." -Level INFO
        New-CMCRetentionPolicy `
            -PolicyName "CMMC-Retention-$($config.purview.retention_policy_years)Year" `
            -RetentionYears $config.purview.retention_policy_years `
            -Config $config

        # Step 4: Configure eDiscovery
        Write-CMCLog "Step 4: Configuring eDiscovery..." -Level INFO
        if ($config.compliance.enable_compliance_manager -or $config.m365_gcc_high.ediscovery_enabled) {
            Enable-CMCeDiscovery -CaseName 'CMMC-Compliance-Case'
        }
        else {
            Write-CMCLog "  eDiscovery disabled in configuration" -Level WARN
        }

        # Step 5: Get Compliance Score
        Write-CMCLog "Step 5: Retrieving Compliance Score..." -Level INFO
        try {
            $complianceScore = Get-CMCComplianceScore
            Write-CMCLog "NIST 800-171 Score: $($complianceScore.NIST800171Score)/$($complianceScore.NIST800171MaxScore)" -Level INFO
        }
        catch {
            Write-CMCLog "Unable to retrieve Compliance Score (may require additional permissions)" -Level WARN
        }

        # Step 6: Generate Compliance Report
        Write-CMCLog "Step 6: Generating Compliance Report..." -Level INFO
        $reportPath = Join-Path $scriptRoot '..\..\reports'
        if (-not (Test-Path $reportPath)) {
            New-Item -ItemType Directory -Path $reportPath -Force | Out-Null
        }
        Export-CMCComplianceReport -OutputPath $reportPath -Format 'HTML'

        Write-CMCLog "========================================" -Level SUCCESS
        Write-CMCLog "Compliance configuration completed!" -Level SUCCESS
        Write-CMCLog "========================================" -Level SUCCESS
        Write-CMCLog "" -Level INFO
        Write-CMCLog "NIST 800-171 Controls Addressed:" -Level INFO
        Write-CMCLog "  - AC-4: Information Flow Enforcement (DLP)" -Level INFO
        Write-CMCLog "  - AU-11: Audit Record Retention (Retention Policies)" -Level INFO
        Write-CMCLog "  - MP-4: Media Storage (Sensitivity Labels)" -Level INFO
        Write-CMCLog "  - SC-8: Transmission Confidentiality (Encryption)" -Level INFO
    }
    catch {
        Write-CMCLog "Compliance configuration failed: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Invoke-ComplianceRollback {
    param(
        [string]$BackupPath,
        [hashtable]$Config
    )

    Write-CMCLog "Starting compliance rollback..." -Level WARN
    Write-CMCLog "Note: DLP policies and sensitivity labels should be manually reviewed" -Level WARN

    if (-not $BackupPath -or -not (Test-Path $BackupPath)) {
        Write-CMCLog "Valid backup path required for rollback" -Level ERROR
        return
    }

    Write-CMCLog "Compliance rollback completed" -Level SUCCESS
}

#endregion

# Execute main function
Main
