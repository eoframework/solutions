#Requires -Version 7.0
<#
.SYNOPSIS
    SharePoint Online configuration for M365 Deployment.

.DESCRIPTION
    This module provides functions for configuring SharePoint Online,
    hub sites, external sharing, and file migrations.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

# Import common module
$commonModulePath = Join-Path $PSScriptRoot '..\M365-Common\M365-Common.psm1'
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -Force
}

#region Baseline Configuration

function Set-M365SharePointBaseline {
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Config
    )

    Write-M365Log "Configuring SharePoint Online baseline..." -Level INFO

    try {
        # Configure tenant settings
        Set-SPOTenant `
            -NoAccessRedirectUrl '' `
            -SharingCapability 'ExternalUserSharingOnly' `
            -ShowEveryoneClaim $false `
            -ShowAllUsersClaim $false `
            -ShowEveryoneExceptExternalUsersClaim $true `
            -DefaultSharingLinkType 'Internal' `
            -PreventExternalUsersFromResharing $true `
            -RequireAcceptingAccountMatchInvitedAccount $true `
            -ExternalUserExpirationRequired $true `
            -ExternalUserExpireInDays 30 `
            -OneDriveStorageQuota ($Config.sharepoint.storage_quota_tb * 1024 * 1024) `
            -EnableGuestSignInAcceleration $false

        # Configure versioning default
        Set-SPOTenant `
            -EnableAutoNewsDigest $true `
            -SpecialCharactersStateInFileFolderNames 'Allowed'

        Write-M365Log "SharePoint baseline configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure SharePoint baseline: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Hub Sites

function New-M365HubSite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter()]
        [string]$Owner,

        [Parameter()]
        [string]$Template = 'SITEPAGEPUBLISHING#0'
    )

    Write-M365Log "Creating hub site: $Title" -Level INFO

    try {
        # Check if site exists
        $existingSite = Get-SPOSite -Identity $Url -ErrorAction SilentlyContinue

        if (-not $existingSite) {
            # Create the site first
            $site = New-SPOSite `
                -Url $Url `
                -Owner $Owner `
                -Title $Title `
                -Template $Template `
                -StorageQuota 1024

            Write-M365Log "  Site created: $Url" -Level INFO
        }
        else {
            Write-M365Log "  Site already exists: $Url" -Level WARN
        }

        # Register as hub site
        $hubSite = Get-SPOHubSite -Identity $Url -ErrorAction SilentlyContinue

        if (-not $hubSite) {
            Register-SPOHubSite -Site $Url
            Write-M365Log "  Registered as hub site" -Level SUCCESS
        }
        else {
            Write-M365Log "  Already registered as hub site" -Level WARN
        }

        return Get-SPOHubSite -Identity $Url
    }
    catch {
        Write-M365Log "Failed to create hub site: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region External Sharing

function Set-M365ExternalSharing {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Disabled', 'ExistingExternalUserSharingOnly', 'ExternalUserSharingOnly', 'ExternalUserAndGuestSharing')]
        [string]$SharingCapability = 'ExternalUserSharingOnly',

        [Parameter()]
        [string[]]$AllowedDomains,

        [Parameter()]
        [string[]]$BlockedDomains
    )

    Write-M365Log "Configuring external sharing ($SharingCapability)..." -Level INFO

    try {
        $sharingParams = @{
            SharingCapability = $SharingCapability
        }

        if ($AllowedDomains) {
            $sharingParams['SharingDomainRestrictionMode'] = 'AllowList'
            $sharingParams['SharingAllowedDomainList'] = $AllowedDomains -join ' '
        }
        elseif ($BlockedDomains) {
            $sharingParams['SharingDomainRestrictionMode'] = 'BlockList'
            $sharingParams['SharingBlockedDomainList'] = $BlockedDomains -join ' '
        }

        Set-SPOTenant @sharingParams

        Write-M365Log "External sharing configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure external sharing: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Migration

function Start-M365FileMigration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [string]$TargetSiteUrl,

        [Parameter()]
        [string]$TargetLibrary = 'Documents',

        [Parameter()]
        [switch]$IncludeVersionHistory
    )

    Write-M365Log "Starting file migration to $TargetSiteUrl" -Level INFO

    try {
        # Note: Full migration requires SharePoint Migration Tool or Migration Manager
        # This function provides the framework for automation

        $migrationConfig = @{
            SourcePath              = $SourcePath
            TargetSiteUrl           = $TargetSiteUrl
            TargetLibrary           = $TargetLibrary
            IncludeVersionHistory   = $IncludeVersionHistory.IsPresent
            StartTime               = Get-Date
        }

        Write-M365Log "Migration configuration created" -Level INFO
        Write-M365Log "Note: Use SharePoint Migration Tool or Migration Manager for actual migration" -Level WARN

        return $migrationConfig
    }
    catch {
        Write-M365Log "Failed to start file migration: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Status

function Get-M365SharePointStatus {
    [CmdletBinding()]
    param()

    Write-M365Log "Retrieving SharePoint status..." -Level INFO

    try {
        $tenant = Get-SPOTenant
        $sites = Get-SPOSite -Limit All
        $hubSites = Get-SPOHubSite

        $status = @{
            TenantStorageQuota   = $tenant.StorageQuota
            TenantStorageUsed    = $tenant.StorageQuotaAllocated
            SharingCapability    = $tenant.SharingCapability
            TotalSites           = $sites.Count
            HubSites             = $hubSites.Count
            Sites                = $sites | Select-Object Title, Url, Status, StorageUsageCurrent
        }

        Write-M365Log "SharePoint status retrieved" -Level SUCCESS
        return $status
    }
    catch {
        Write-M365Log "Failed to get SharePoint status: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'Set-M365SharePointBaseline',
    'New-M365HubSite',
    'Set-M365ExternalSharing',
    'Start-M365FileMigration',
    'Get-M365SharePointStatus'
)

#endregion
