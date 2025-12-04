#Requires -Version 7.0
<#
.SYNOPSIS
    Common functions and utilities for M365 Enterprise Deployment.

.DESCRIPTION
    This module provides shared functions used across all M365 deployment scripts
    including logging, configuration loading, and service connections.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

#region Logging Functions

function Write-M365Log {
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

    $color = switch ($Level) {
        'INFO'    { 'White' }
        'WARN'    { 'Yellow' }
        'ERROR'   { 'Red' }
        'SUCCESS' { 'Green' }
        'DEBUG'   { 'Gray' }
    }

    Write-Host $logMessage -ForegroundColor $color

    if ($LogFile) {
        $logMessage | Out-File -FilePath $LogFile -Append -Encoding utf8
    }
}

function Start-M365LogSession {
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

    Write-M365Log "Starting session: $SessionName" -Level INFO -LogFile $logFile
    Write-M365Log "Log file: $logFile" -Level INFO -LogFile $logFile

    return $logFile
}

#endregion

#region Configuration Functions

function Import-M365Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ConfigPath
    )

    if (-not (Test-Path $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath"
    }

    Write-M365Log "Loading configuration from: $ConfigPath" -Level INFO

    try {
        $config = Import-PowerShellDataFile -Path $ConfigPath
        Write-M365Log "Configuration loaded successfully" -Level SUCCESS
        return $config
    }
    catch {
        Write-M365Log "Failed to load configuration: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Connection Functions

function Connect-M365Services {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$TenantId,

        [Parameter()]
        [switch]$ConnectGraph,

        [Parameter()]
        [switch]$ConnectExchange,

        [Parameter()]
        [switch]$ConnectSharePoint,

        [Parameter()]
        [switch]$ConnectTeams,

        [Parameter()]
        [string]$SharePointAdminUrl
    )

    $connectionResults = @{
        Graph      = $false
        Exchange   = $false
        SharePoint = $false
        Teams      = $false
    }

    if ($ConnectGraph) {
        Write-M365Log "Connecting to Microsoft Graph..." -Level INFO
        try {
            $graphParams = @{
                Scopes = @(
                    'User.ReadWrite.All',
                    'Group.ReadWrite.All',
                    'Policy.ReadWrite.ConditionalAccess',
                    'DeviceManagementConfiguration.ReadWrite.All'
                )
            }
            if ($TenantId) { $graphParams['TenantId'] = $TenantId }

            Connect-MgGraph @graphParams | Out-Null
            $connectionResults.Graph = $true
            Write-M365Log "Connected to Microsoft Graph" -Level SUCCESS
        }
        catch {
            Write-M365Log "Failed to connect to Graph: $($_.Exception.Message)" -Level ERROR
        }
    }

    if ($ConnectExchange) {
        Write-M365Log "Connecting to Exchange Online..." -Level INFO
        try {
            Connect-ExchangeOnline -ShowBanner:$false | Out-Null
            $connectionResults.Exchange = $true
            Write-M365Log "Connected to Exchange Online" -Level SUCCESS
        }
        catch {
            Write-M365Log "Failed to connect to Exchange: $($_.Exception.Message)" -Level ERROR
        }
    }

    if ($ConnectSharePoint -and $SharePointAdminUrl) {
        Write-M365Log "Connecting to SharePoint Online..." -Level INFO
        try {
            Connect-SPOService -Url $SharePointAdminUrl | Out-Null
            $connectionResults.SharePoint = $true
            Write-M365Log "Connected to SharePoint Online" -Level SUCCESS
        }
        catch {
            Write-M365Log "Failed to connect to SharePoint: $($_.Exception.Message)" -Level ERROR
        }
    }

    if ($ConnectTeams) {
        Write-M365Log "Connecting to Microsoft Teams..." -Level INFO
        try {
            Connect-MicrosoftTeams | Out-Null
            $connectionResults.Teams = $true
            Write-M365Log "Connected to Microsoft Teams" -Level SUCCESS
        }
        catch {
            Write-M365Log "Failed to connect to Teams: $($_.Exception.Message)" -Level ERROR
        }
    }

    return $connectionResults
}

#endregion

#region Prerequisites Functions

function Test-M365Prerequisites {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$CheckModules,

        [Parameter()]
        [switch]$CheckConnections
    )

    $results = @{
        Success = $true
        Checks  = @()
    }

    if ($CheckModules) {
        $requiredModules = @(
            'Microsoft.Graph',
            'ExchangeOnlineManagement',
            'Microsoft.Online.SharePoint.PowerShell',
            'MicrosoftTeams'
        )

        foreach ($module in $requiredModules) {
            $installed = Get-Module -Name $module -ListAvailable
            $results.Checks += @{
                Name    = "Module: $module"
                Status  = if ($installed) { 'Passed' } else { 'Failed' }
                Message = if ($installed) { "v$($installed[0].Version)" } else { 'Not installed' }
            }
            if (-not $installed) { $results.Success = $false }
        }
    }

    if ($CheckConnections) {
        # Check Graph connection
        $graphContext = Get-MgContext -ErrorAction SilentlyContinue
        $results.Checks += @{
            Name    = 'Microsoft Graph Connection'
            Status  = if ($graphContext) { 'Passed' } else { 'Failed' }
            Message = if ($graphContext) { "Connected as $($graphContext.Account)" } else { 'Not connected' }
        }
        if (-not $graphContext) { $results.Success = $false }
    }

    return $results
}

#endregion

#region Backup Functions

function Backup-M365Configuration {
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

    Write-M365Log "Creating backup: $backupFile" -Level INFO

    try {
        $Configuration | ConvertTo-Json -Depth 10 | Out-File -FilePath $backupFile -Encoding utf8
        Write-M365Log "Backup created successfully" -Level SUCCESS
        return $backupFile
    }
    catch {
        Write-M365Log "Failed to create backup: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Restore-M365Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$BackupFile
    )

    if (-not (Test-Path $BackupFile)) {
        throw "Backup file not found: $BackupFile"
    }

    Write-M365Log "Restoring from backup: $BackupFile" -Level INFO

    try {
        $config = Get-Content -Path $BackupFile -Raw | ConvertFrom-Json
        Write-M365Log "Configuration restored successfully" -Level SUCCESS
        return $config
    }
    catch {
        Write-M365Log "Failed to restore configuration: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'Write-M365Log',
    'Start-M365LogSession',
    'Import-M365Configuration',
    'Connect-M365Services',
    'Test-M365Prerequisites',
    'Backup-M365Configuration',
    'Restore-M365Configuration'
)

#endregion
