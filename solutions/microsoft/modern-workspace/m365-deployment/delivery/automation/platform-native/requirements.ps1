#Requires -Version 7.0
<#
.SYNOPSIS
    Installs required PowerShell modules for Microsoft 365 Enterprise Deployment.

.DESCRIPTION
    This script installs all required PowerShell modules for deploying and configuring
    Microsoft 365 E5 with Exchange Online, SharePoint, Teams, and security services.

.EXAMPLE
    .\requirements.ps1
    Installs all required modules in CurrentUser scope.

.EXAMPLE
    .\requirements.ps1 -Scope AllUsers
    Installs all required modules for all users (requires admin).

.NOTES
    Author: EO Framework
    Version: 1.0.0
    Last Updated: 2025-12-04
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser',

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Required modules with minimum versions
$RequiredModules = @(
    @{ Name = 'Microsoft.Graph'; MinVersion = '2.0.0' }
    @{ Name = 'Microsoft.Graph.Authentication'; MinVersion = '2.0.0' }
    @{ Name = 'Microsoft.Graph.Users'; MinVersion = '2.0.0' }
    @{ Name = 'Microsoft.Graph.Groups'; MinVersion = '2.0.0' }
    @{ Name = 'Microsoft.Graph.Identity.DirectoryManagement'; MinVersion = '2.0.0' }
    @{ Name = 'Microsoft.Graph.Identity.SignIns'; MinVersion = '2.0.0' }
    @{ Name = 'Microsoft.Graph.DeviceManagement'; MinVersion = '2.0.0' }
    @{ Name = 'ExchangeOnlineManagement'; MinVersion = '3.0.0' }
    @{ Name = 'Microsoft.Online.SharePoint.PowerShell'; MinVersion = '16.0.0' }
    @{ Name = 'MicrosoftTeams'; MinVersion = '5.0.0' }
    @{ Name = 'Az.Accounts'; MinVersion = '2.0.0' }
    @{ Name = 'Pester'; MinVersion = '5.0.0' }
)

Write-Host "Microsoft 365 Enterprise Deployment - Module Installation" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "PowerShell 7+ is recommended for full compatibility."
    Write-Warning "Current version: $($PSVersionTable.PSVersion)"
}

# Install modules
$installedCount = 0
$skippedCount = 0
$failedCount = 0

foreach ($module in $RequiredModules) {
    $moduleName = $module.Name
    $minVersion = [version]$module.MinVersion

    Write-Host "Checking $moduleName..." -NoNewline

    try {
        $installed = Get-Module -Name $moduleName -ListAvailable |
            Sort-Object Version -Descending |
            Select-Object -First 1

        if ($installed -and $installed.Version -ge $minVersion -and -not $Force) {
            Write-Host " v$($installed.Version) (installed)" -ForegroundColor Green
            $skippedCount++
        }
        else {
            if ($installed) {
                Write-Host " upgrading from v$($installed.Version)..." -ForegroundColor Yellow -NoNewline
            }
            else {
                Write-Host " installing..." -ForegroundColor Yellow -NoNewline
            }

            Install-Module -Name $moduleName -Scope $Scope -Force -AllowClobber -MinimumVersion $minVersion
            Write-Host " done" -ForegroundColor Green
            $installedCount++
        }
    }
    catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Warning "  Error: $($_.Exception.Message)"
        $failedCount++
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Installed/Updated: $installedCount" -ForegroundColor $(if ($installedCount -gt 0) { 'Green' } else { 'Gray' })
Write-Host "  Already Current:   $skippedCount" -ForegroundColor $(if ($skippedCount -gt 0) { 'Green' } else { 'Gray' })
Write-Host "  Failed:            $failedCount" -ForegroundColor $(if ($failedCount -gt 0) { 'Red' } else { 'Gray' })
Write-Host ""

if ($failedCount -gt 0) {
    Write-Warning "Some modules failed to install. You may need to run as Administrator or check your internet connection."
    exit 1
}

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Connect to Microsoft Graph:" -ForegroundColor White
Write-Host "     Connect-MgGraph -Scopes 'User.ReadWrite.All','Group.ReadWrite.All'" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Connect to Exchange Online:" -ForegroundColor White
Write-Host "     Connect-ExchangeOnline" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Connect to SharePoint Online:" -ForegroundColor White
Write-Host "     Connect-SPOService -Url https://[tenant]-admin.sharepoint.com" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Connect to Microsoft Teams:" -ForegroundColor White
Write-Host "     Connect-MicrosoftTeams" -ForegroundColor Gray
Write-Host ""
Write-Host "  5. Run deployment:" -ForegroundColor White
Write-Host "     .\powershell\scripts\prod\Deploy-M365.ps1 -ConfigPath .\powershell\config\prod.psd1" -ForegroundColor Gray
Write-Host ""
