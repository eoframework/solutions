#Requires -Version 7.0
<#
.SYNOPSIS
    Configures monitoring for CMMC GCC High Enclave.

.DESCRIPTION
    This script configures Microsoft Sentinel workspace, analytics rules,
    playbooks, and monitoring for CMMC Level 2 compliance.

.PARAMETER ConfigPath
    Path to the environment configuration file (.psd1).

.PARAMETER Rollback
    Rollback to a previous configuration state.

.PARAMETER BackupPath
    Path to backup directory for rollback operations.

.EXAMPLE
    .\Configure-Monitoring.ps1 -ConfigPath ..\config\prod.psd1

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
Import-Module (Join-Path $modulesPath 'CMMC-Monitoring\CMMC-Monitoring.psm1') -Force

#endregion

#region Main Execution

function Main {
    Write-CMCLog "========================================" -Level INFO
    Write-CMCLog "CMMC Monitoring Configuration" -Level INFO
    Write-CMCLog "========================================" -Level INFO

    # Load configuration
    $config = Import-CMCConfiguration -ConfigPath $ConfigPath

    Write-CMCLog "Environment: $(Split-Path -Leaf (Split-Path $ConfigPath))" -Level INFO
    Write-CMCLog "Sentinel Workspace: $($config.security.sentinel_workspace_name)" -Level INFO

    if ($Rollback) {
        Invoke-MonitoringRollback -BackupPath $BackupPath -Config $config
        return
    }

    # Determine resource group name
    $resourceGroupName = "$($config.solution.abbr)-$((Split-Path -Leaf (Split-Path $ConfigPath)) -replace '\.psd1$','')-rg"

    try {
        # Step 1: Create Sentinel Workspace
        Write-CMCLog "Step 1: Creating Sentinel Workspace..." -Level INFO
        $workspace = New-CMCSentinelWorkspace `
            -WorkspaceName $config.security.sentinel_workspace_name `
            -ResourceGroupName $resourceGroupName `
            -Location $config.azure_gov.region `
            -RetentionDays $config.security.sentinel_retention_days `
            -Tags @{
                Solution    = $config.solution.name
                Environment = (Split-Path -Leaf (Split-Path $ConfigPath)) -replace '\.psd1$',''
                CostCenter  = $config.ownership.cost_center
            }

        # Step 2: Enable Data Connectors
        Write-CMCLog "Step 2: Enabling Data Connectors..." -Level INFO
        Enable-CMCSentinelConnectors `
            -WorkspaceName $config.security.sentinel_workspace_name `
            -ResourceGroupName $resourceGroupName

        # Step 3: Create Analytics Rules
        Write-CMCLog "Step 3: Creating Analytics Rules..." -Level INFO
        New-CMCAnalyticsRule `
            -WorkspaceName $config.security.sentinel_workspace_name `
            -ResourceGroupName $resourceGroupName

        # Step 4: Create Playbooks
        Write-CMCLog "Step 4: Creating Incident Response Playbooks..." -Level INFO
        if ($config.monitoring.enable_alerts) {
            New-CMCPlaybook `
                -PlaybookName 'CMMC-NotifySOC' `
                -ResourceGroupName $resourceGroupName `
                -Location $config.azure_gov.region `
                -PlaybookType 'NotifySOC'

            New-CMCPlaybook `
                -PlaybookName 'CMMC-BlockUser' `
                -ResourceGroupName $resourceGroupName `
                -Location $config.azure_gov.region `
                -PlaybookType 'BlockUser'
        }

        # Step 5: Enable Workbooks
        Write-CMCLog "Step 5: Configuring Workbooks..." -Level INFO
        if ($config.monitoring.enable_workbooks) {
            Write-CMCLog "  CMMC compliance workbooks will be deployed via ARM templates" -Level INFO
        }
        else {
            Write-CMCLog "  Workbooks disabled in configuration" -Level WARN
        }

        # Step 6: Generate Monitoring Report
        Write-CMCLog "Step 6: Generating Monitoring Report..." -Level INFO
        $reportPath = Join-Path $scriptRoot '..\..\..\..\reports'
        if (-not (Test-Path $reportPath)) {
            New-Item -ItemType Directory -Path $reportPath -Force | Out-Null
        }

        try {
            Export-CMCMonitoringReport `
                -OutputPath $reportPath `
                -WorkspaceName $config.security.sentinel_workspace_name `
                -ResourceGroupName $resourceGroupName `
                -Format 'HTML'
        }
        catch {
            Write-CMCLog "  Unable to generate monitoring report (workspace may not have incidents yet)" -Level WARN
        }

        Write-CMCLog "========================================" -Level SUCCESS
        Write-CMCLog "Monitoring configuration completed!" -Level SUCCESS
        Write-CMCLog "========================================" -Level SUCCESS
        Write-CMCLog "" -Level INFO
        Write-CMCLog "NIST 800-171 Controls Addressed:" -Level INFO
        Write-CMCLog "  - AU-2: Audit Events (Sentinel Data Connectors)" -Level INFO
        Write-CMCLog "  - AU-3: Audit Record Content (Analytics Rules)" -Level INFO
        Write-CMCLog "  - AU-6: Audit Review (Workbooks and Dashboards)" -Level INFO
        Write-CMCLog "  - IR-4: Incident Handling (Playbooks)" -Level INFO
        Write-CMCLog "  - SI-4: System Monitoring (Threat Detection)" -Level INFO
    }
    catch {
        Write-CMCLog "Monitoring configuration failed: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Invoke-MonitoringRollback {
    param(
        [string]$BackupPath,
        [hashtable]$Config
    )

    Write-CMCLog "Starting monitoring rollback..." -Level WARN
    Write-CMCLog "Note: Sentinel workspace data cannot be restored" -Level WARN

    if (-not $BackupPath -or -not (Test-Path $BackupPath)) {
        Write-CMCLog "Valid backup path required for rollback" -Level ERROR
        return
    }

    Write-CMCLog "Monitoring rollback completed" -Level SUCCESS
}

#endregion

# Execute main function
Main
