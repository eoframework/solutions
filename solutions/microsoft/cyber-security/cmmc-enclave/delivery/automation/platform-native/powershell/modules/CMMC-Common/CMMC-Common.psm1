#Requires -Version 7.0
<#
.SYNOPSIS
    Common functions and utilities for CMMC GCC High Enclave deployment.

.DESCRIPTION
    This module provides shared functions used across all CMMC deployment scripts
    including logging, configuration loading, and common helper functions.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

#region Logging Functions

function Write-CMCLog {
    <#
    .SYNOPSIS
        Writes a log message with timestamp and severity level.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS', 'DEBUG')]
        [string]$Level = 'INFO',

        [Parameter()]
        [string]$LogFile
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"

    # Console output with color
    $color = switch ($Level) {
        'INFO'    { 'White' }
        'WARN'    { 'Yellow' }
        'ERROR'   { 'Red' }
        'SUCCESS' { 'Green' }
        'DEBUG'   { 'Gray' }
    }

    Write-Host $logMessage -ForegroundColor $color

    # File output
    if ($LogFile) {
        $logMessage | Out-File -FilePath $LogFile -Append -Encoding utf8
    }
}

function Start-CMCLogSession {
    <#
    .SYNOPSIS
        Starts a new logging session with a unique log file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SessionName,

        [Parameter()]
        [string]$LogDirectory = '.\logs'
    )

    if (-not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $logFile = Join-Path $LogDirectory "$SessionName-$timestamp.log"

    $script:CurrentLogFile = $logFile

    Write-CMCLog "Starting session: $SessionName" -Level INFO -LogFile $logFile
    Write-CMCLog "Log file: $logFile" -Level INFO -LogFile $logFile

    return $logFile
}

#endregion

#region Configuration Functions

function Import-CMCConfiguration {
    <#
    .SYNOPSIS
        Imports configuration from a PowerShell data file (.psd1).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ConfigPath
    )

    if (-not (Test-Path $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath"
    }

    Write-CMCLog "Loading configuration from: $ConfigPath" -Level INFO

    try {
        $config = Import-PowerShellDataFile -Path $ConfigPath
        Write-CMCLog "Configuration loaded successfully" -Level SUCCESS
        return $config
    }
    catch {
        Write-CMCLog "Failed to load configuration: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Get-CMCSecretFromKeyVault {
    <#
    .SYNOPSIS
        Retrieves a secret from Azure Key Vault.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$VaultName,

        [Parameter(Mandatory)]
        [string]$SecretName
    )

    try {
        $secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -AsPlainText
        return $secret
    }
    catch {
        Write-CMCLog "Failed to retrieve secret '$SecretName' from vault '$VaultName': $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Azure Government Functions

function Connect-CMCAzureGovernment {
    <#
    .SYNOPSIS
        Connects to Azure Government with validation.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$TenantId,

        [Parameter()]
        [string]$SubscriptionId
    )

    Write-CMCLog "Connecting to Azure Government..." -Level INFO

    try {
        $context = Get-AzContext -ErrorAction SilentlyContinue

        if ($context -and $context.Environment.Name -eq 'AzureUSGovernment') {
            Write-CMCLog "Already connected to Azure Government as $($context.Account.Id)" -Level SUCCESS

            if ($SubscriptionId -and $context.Subscription.Id -ne $SubscriptionId) {
                Write-CMCLog "Switching to subscription: $SubscriptionId" -Level INFO
                Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
            }
        }
        else {
            $connectParams = @{
                Environment = 'AzureUSGovernment'
            }

            if ($TenantId) { $connectParams['TenantId'] = $TenantId }
            if ($SubscriptionId) { $connectParams['SubscriptionId'] = $SubscriptionId }

            Connect-AzAccount @connectParams | Out-Null
            Write-CMCLog "Connected to Azure Government successfully" -Level SUCCESS
        }

        return Get-AzContext
    }
    catch {
        Write-CMCLog "Failed to connect to Azure Government: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Connect-CMCGraphGCCHigh {
    <#
    .SYNOPSIS
        Connects to Microsoft Graph in GCC High environment.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Scopes = @(
            'Policy.ReadWrite.ConditionalAccess',
            'DeviceManagementConfiguration.ReadWrite.All',
            'SecurityEvents.ReadWrite.All',
            'User.ReadWrite.All',
            'Group.ReadWrite.All'
        )
    )

    Write-CMCLog "Connecting to Microsoft Graph (GCC High)..." -Level INFO

    try {
        $context = Get-MgContext

        if ($context -and $context.Environment -eq 'USGov') {
            Write-CMCLog "Already connected to Graph GCC High as $($context.Account)" -Level SUCCESS
        }
        else {
            Connect-MgGraph -Environment USGov -Scopes $Scopes | Out-Null
            Write-CMCLog "Connected to Microsoft Graph GCC High successfully" -Level SUCCESS
        }

        return Get-MgContext
    }
    catch {
        Write-CMCLog "Failed to connect to Microsoft Graph: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Backup Functions

function Backup-CMCConfiguration {
    <#
    .SYNOPSIS
        Creates a backup of current configuration before making changes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$BackupName,

        [Parameter(Mandatory)]
        [object]$Configuration,

        [Parameter()]
        [string]$BackupDirectory = '.\backups'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd'
    $backupPath = Join-Path $BackupDirectory $timestamp

    if (-not (Test-Path $backupPath)) {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    }

    $backupFile = Join-Path $backupPath "$BackupName.json"

    Write-CMCLog "Creating backup: $backupFile" -Level INFO

    try {
        $Configuration | ConvertTo-Json -Depth 10 | Out-File -FilePath $backupFile -Encoding utf8
        Write-CMCLog "Backup created successfully" -Level SUCCESS
        return $backupFile
    }
    catch {
        Write-CMCLog "Failed to create backup: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Restore-CMCConfiguration {
    <#
    .SYNOPSIS
        Restores configuration from a backup file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$BackupFile
    )

    if (-not (Test-Path $BackupFile)) {
        throw "Backup file not found: $BackupFile"
    }

    Write-CMCLog "Restoring from backup: $BackupFile" -Level INFO

    try {
        $config = Get-Content -Path $BackupFile -Raw | ConvertFrom-Json
        Write-CMCLog "Configuration restored successfully" -Level SUCCESS
        return $config
    }
    catch {
        Write-CMCLog "Failed to restore configuration: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Validation Functions

function Test-CMCPrerequisites {
    <#
    .SYNOPSIS
        Validates all prerequisites are met before deployment.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$CheckAzure,

        [Parameter()]
        [switch]$CheckGraph,

        [Parameter()]
        [switch]$CheckModules
    )

    $results = @{
        Success = $true
        Checks = @()
    }

    if ($CheckModules) {
        $requiredModules = @('Microsoft.Graph', 'Az', 'ExchangeOnlineManagement')

        foreach ($module in $requiredModules) {
            $installed = Get-Module -Name $module -ListAvailable
            $results.Checks += @{
                Name = "Module: $module"
                Status = if ($installed) { 'Passed' } else { 'Failed' }
                Message = if ($installed) { "v$($installed[0].Version)" } else { 'Not installed' }
            }
            if (-not $installed) { $results.Success = $false }
        }
    }

    if ($CheckAzure) {
        $context = Get-AzContext -ErrorAction SilentlyContinue
        $results.Checks += @{
            Name = 'Azure Government Connection'
            Status = if ($context -and $context.Environment.Name -eq 'AzureUSGovernment') { 'Passed' } else { 'Failed' }
            Message = if ($context) { "Connected as $($context.Account.Id)" } else { 'Not connected' }
        }
        if (-not $context -or $context.Environment.Name -ne 'AzureUSGovernment') { $results.Success = $false }
    }

    if ($CheckGraph) {
        $graphContext = Get-MgContext -ErrorAction SilentlyContinue
        $results.Checks += @{
            Name = 'Microsoft Graph GCC High Connection'
            Status = if ($graphContext -and $graphContext.Environment -eq 'USGov') { 'Passed' } else { 'Failed' }
            Message = if ($graphContext) { "Connected as $($graphContext.Account)" } else { 'Not connected' }
        }
        if (-not $graphContext -or $graphContext.Environment -ne 'USGov') { $results.Success = $false }
    }

    return $results
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'Write-CMCLog',
    'Start-CMCLogSession',
    'Import-CMCConfiguration',
    'Get-CMCSecretFromKeyVault',
    'Connect-CMCAzureGovernment',
    'Connect-CMCGraphGCCHigh',
    'Backup-CMCConfiguration',
    'Restore-CMCConfiguration',
    'Test-CMCPrerequisites'
)

#endregion
