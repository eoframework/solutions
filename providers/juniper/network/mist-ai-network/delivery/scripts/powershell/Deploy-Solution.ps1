#Requires -Version 5.1
<#
.SYNOPSIS
    Deploy Juniper Mist AI Network Platform Solution
    
.DESCRIPTION
    This PowerShell script automates the deployment of Juniper Mist AI Network Platform
    including site creation, WLAN configuration, device management, and validation.
    
.PARAMETER ConfigFile
    Path to the JSON configuration file containing deployment parameters
    
.PARAMETER ApiToken
    Mist Cloud API token for authentication
    
.PARAMETER Organization
    Organization name to deploy to
    
.PARAMETER ValidateOnly
    Switch to perform validation only without actual deployment
    
.PARAMETER LogFile
    Path to log file (optional, defaults to timestamped log in current directory)
    
.PARAMETER Force
    Skip confirmation prompts and force deployment
    
.EXAMPLE
    .\Deploy-Solution.ps1 -ConfigFile "config.json" -ApiToken "your-token-here"
    
.EXAMPLE
    .\Deploy-Solution.ps1 -ConfigFile "config.json" -ApiToken "your-token-here" -ValidateOnly
    
.EXAMPLE
    .\Deploy-Solution.ps1 -ConfigFile "config.json" -ApiToken "your-token-here" -LogFile "deployment.log" -Force

.NOTES
    Version:        1.0
    Author:         Mist Implementation Team
    Creation Date:  2024
    Purpose/Change: Initial deployment script for Mist AI Network Platform
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$ConfigFile,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiToken,
    
    [Parameter(Mandatory = $false)]
    [string]$Organization,
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory = $false)]
    [string]$LogFile,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Script configuration
$script:BaseUrl = "https://api.mist.com"
$script:ApiVersion = "v1"
$script:UserAgent = "Mist-PowerShell-Deploy/1.0"
$script:MaxRetries = 3
$script:RetryDelaySeconds = 5

# Initialize logging
if (-not $LogFile) {
    $LogFile = "MistDeployment_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

# Global variables for tracking deployment results
$script:DeploymentResults = @{
    SitesCreated = @()
    SitesUpdated = @()
    WLANsCreated = @()
    DevicesClaimed = @()
    DevicesConfigured = @()
    Errors = @()
}

function Write-Log {
    <#
    .SYNOPSIS
        Write log message to console and file
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to file
    Add-Content -Path $LogFile -Value $logEntry
    
    # Write to console with colors
    switch ($Level) {
        'Info' { Write-Host $logEntry -ForegroundColor White }
        'Warning' { Write-Host $logEntry -ForegroundColor Yellow }
        'Error' { Write-Host $logEntry -ForegroundColor Red }
        'Success' { Write-Host $logEntry -ForegroundColor Green }
    }
}

function Invoke-MistAPI {
    <#
    .SYNOPSIS
        Make authenticated API calls to Mist Cloud
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE')]
        [string]$Method = 'GET',
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Body,
        
        [Parameter(Mandatory = $false)]
        [int]$Timeout = 30
    )
    
    $headers = @{
        'Authorization' = "Token $ApiToken"
        'Content-Type' = 'application/json'
        'User-Agent' = $script:UserAgent
    }
    
    $requestParams = @{
        Uri = $Uri
        Method = $Method
        Headers = $headers
        TimeoutSec = $Timeout
    }
    
    if ($Body) {
        $requestParams['Body'] = ($Body | ConvertTo-Json -Depth 10)
    }
    
    $retryCount = 0
    $maxRetries = $script:MaxRetries
    
    do {
        try {
            Write-Log "Making $Method request to $Uri" -Level Info
            $response = Invoke-RestMethod @requestParams
            return $response
        }
        catch {
            $retryCount++
            $errorMessage = $_.Exception.Message
            
            if ($retryCount -le $maxRetries) {
                Write-Log "API call failed (attempt $retryCount/$maxRetries): $errorMessage. Retrying in $($script:RetryDelaySeconds) seconds..." -Level Warning
                Start-Sleep -Seconds $script:RetryDelaySeconds
            } else {
                Write-Log "API call failed after $maxRetries attempts: $errorMessage" -Level Error
                throw $_
            }
        }
    } while ($retryCount -le $maxRetries)
}

function Test-ApiToken {
    <#
    .SYNOPSIS
        Validate the API token
    #>
    try {
        Write-Log "Validating API token..." -Level Info
        $response = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/self"
        Write-Log "API token validated successfully" -Level Success
        return $true
    }
    catch {
        Write-Log "API token validation failed: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Get-Organizations {
    <#
    .SYNOPSIS
        Get list of organizations
    #>
    try {
        Write-Log "Retrieving organizations..." -Level Info
        $organizations = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/orgs"
        Write-Log "Retrieved $($organizations.Count) organizations" -Level Info
        return $organizations
    }
    catch {
        Write-Log "Failed to retrieve organizations: $($_.Exception.Message)" -Level Error
        throw $_
    }
}

function Find-Organization {
    <#
    .SYNOPSIS
        Find organization by name
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName
    )
    
    $organizations = Get-Organizations
    $org = $organizations | Where-Object { $_.name -eq $OrganizationName }
    
    if ($org) {
        Write-Log "Found organization: $OrganizationName (ID: $($org.id))" -Level Success
        return $org
    } else {
        Write-Log "Organization '$OrganizationName' not found" -Level Error
        return $null
    }
}

function Get-Sites {
    <#
    .SYNOPSIS
        Get sites for an organization
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgId
    )
    
    try {
        Write-Log "Retrieving sites for organization $OrgId..." -Level Info
        $sites = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/orgs/$OrgId/sites"
        Write-Log "Retrieved $($sites.Count) sites" -Level Info
        return $sites
    }
    catch {
        Write-Log "Failed to retrieve sites: $($_.Exception.Message)" -Level Error
        throw $_
    }
}

function New-Site {
    <#
    .SYNOPSIS
        Create a new site
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgId,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$SiteConfig
    )
    
    try {
        Write-Log "Creating site: $($SiteConfig.name)" -Level Info
        $site = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/orgs/$OrgId/sites" -Method POST -Body $SiteConfig
        Write-Log "Successfully created site: $($site.name) (ID: $($site.id))" -Level Success
        $script:DeploymentResults.SitesCreated += $site
        return $site
    }
    catch {
        $errorMessage = "Failed to create site '$($SiteConfig.name)': $($_.Exception.Message)"
        Write-Log $errorMessage -Level Error
        $script:DeploymentResults.Errors += $errorMessage
        throw $_
    }
}

function Update-Site {
    <#
    .SYNOPSIS
        Update an existing site
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$SiteId,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$SiteConfig
    )
    
    try {
        Write-Log "Updating site: $($SiteConfig.name)" -Level Info
        $site = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/sites/$SiteId" -Method PUT -Body $SiteConfig
        Write-Log "Successfully updated site: $($site.name)" -Level Success
        $script:DeploymentResults.SitesUpdated += $site
        return $site
    }
    catch {
        $errorMessage = "Failed to update site '$($SiteConfig.name)': $($_.Exception.Message)"
        Write-Log $errorMessage -Level Error
        $script:DeploymentResults.Errors += $errorMessage
        throw $_
    }
}

function Get-WLANs {
    <#
    .SYNOPSIS
        Get WLANs for a site
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$SiteId
    )
    
    try {
        Write-Log "Retrieving WLANs for site $SiteId..." -Level Info
        $wlans = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/sites/$SiteId/wlans"
        Write-Log "Retrieved $($wlans.Count) WLANs" -Level Info
        return $wlans
    }
    catch {
        Write-Log "Failed to retrieve WLANs: $($_.Exception.Message)" -Level Error
        throw $_
    }
}

function New-WLAN {
    <#
    .SYNOPSIS
        Create a new WLAN
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$SiteId,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$WlanConfig
    )
    
    try {
        Write-Log "Creating WLAN: $($WlanConfig.ssid)" -Level Info
        $wlan = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/sites/$SiteId/wlans" -Method POST -Body $WlanConfig
        Write-Log "Successfully created WLAN: $($wlan.ssid) (ID: $($wlan.id))" -Level Success
        $script:DeploymentResults.WLANsCreated += $wlan
        return $wlan
    }
    catch {
        $errorMessage = "Failed to create WLAN '$($WlanConfig.ssid)': $($_.Exception.Message)"
        Write-Log $errorMessage -Level Error
        $script:DeploymentResults.Errors += $errorMessage
        throw $_
    }
}

function Get-Devices {
    <#
    .SYNOPSIS
        Get devices for a site
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$SiteId
    )
    
    try {
        Write-Log "Retrieving devices for site $SiteId..." -Level Info
        $devices = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/sites/$SiteId/devices"
        $accessPoints = $devices | Where-Object { $_.type -eq 'ap' }
        Write-Log "Retrieved $($accessPoints.Count) access points" -Level Info
        return $accessPoints
    }
    catch {
        Write-Log "Failed to retrieve devices: $($_.Exception.Message)" -Level Error
        throw $_
    }
}

function Add-ClaimCodes {
    <#
    .SYNOPSIS
        Claim devices using claim codes
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgId,
        
        [Parameter(Mandatory = $true)]
        [array]$ClaimCodes
    )
    
    try {
        Write-Log "Claiming $($ClaimCodes.Count) devices..." -Level Info
        $claimedDevices = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/orgs/$OrgId/inventory" -Method POST -Body $ClaimCodes
        Write-Log "Successfully claimed $($ClaimCodes.Count) devices" -Level Success
        $script:DeploymentResults.DevicesClaimed += $claimedDevices
        return $claimedDevices
    }
    catch {
        $errorMessage = "Failed to claim devices: $($_.Exception.Message)"
        Write-Log $errorMessage -Level Error
        $script:DeploymentResults.Errors += $errorMessage
        throw $_
    }
}

function Set-DeviceToSite {
    <#
    .SYNOPSIS
        Assign device to a site
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgId,
        
        [Parameter(Mandatory = $true)]
        [string]$DeviceId,
        
        [Parameter(Mandatory = $true)]
        [string]$SiteId
    )
    
    try {
        Write-Log "Assigning device $DeviceId to site $SiteId..." -Level Info
        $body = @{ site_id = $SiteId }
        $result = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/orgs/$OrgId/inventory/$DeviceId" -Method PUT -Body $body
        Write-Log "Successfully assigned device $DeviceId to site" -Level Success
        return $result
    }
    catch {
        $errorMessage = "Failed to assign device $DeviceId to site: $($_.Exception.Message)"
        Write-Log $errorMessage -Level Error
        $script:DeploymentResults.Errors += $errorMessage
        throw $_
    }
}

function Update-DeviceConfig {
    <#
    .SYNOPSIS
        Update device configuration
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$SiteId,
        
        [Parameter(Mandatory = $true)]
        [string]$DeviceId,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$DeviceConfig
    )
    
    try {
        Write-Log "Updating configuration for device $DeviceId..." -Level Info
        $device = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/sites/$SiteId/devices/$DeviceId" -Method PUT -Body $DeviceConfig
        Write-Log "Successfully updated device configuration" -Level Success
        $script:DeploymentResults.DevicesConfigured += $device
        return $device
    }
    catch {
        $errorMessage = "Failed to update device $DeviceId configuration: $($_.Exception.Message)"
        Write-Log $errorMessage -Level Error
        $script:DeploymentResults.Errors += $errorMessage
        throw $_
    }
}

function Test-Configuration {
    <#
    .SYNOPSIS
        Validate deployment configuration
    #>
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )
    
    Write-Log "Validating deployment configuration..." -Level Info
    
    $isValid = $true
    
    # Check required sections
    $requiredSections = @('organization', 'sites')
    foreach ($section in $requiredSections) {
        if (-not $Config.ContainsKey($section)) {
            Write-Log "Missing required configuration section: $section" -Level Error
            $isValid = $false
        }
    }
    
    # Validate organization
    if ($Config.ContainsKey('organization') -and -not $Config.organization.ContainsKey('name')) {
        Write-Log "Organization name not specified in configuration" -Level Error
        $isValid = $false
    }
    
    # Validate sites
    if ($Config.ContainsKey('sites')) {
        if ($Config.sites.Count -eq 0) {
            Write-Log "No sites specified in configuration" -Level Error
            $isValid = $false
        }
        
        foreach ($siteName in $Config.sites.Keys) {
            $siteConfig = $Config.sites.$siteName
            $requiredSiteKeys = @('address', 'timezone')
            
            foreach ($key in $requiredSiteKeys) {
                if (-not $siteConfig.ContainsKey($key)) {
                    Write-Log "Site '$siteName' missing required key: $key" -Level Error
                    $isValid = $false
                }
            }
            
            # Validate WLANs if present
            if ($siteConfig.ContainsKey('wlans')) {
                foreach ($wlanName in $siteConfig.wlans.Keys) {
                    $wlanConfig = $siteConfig.wlans.$wlanName
                    $requiredWlanKeys = @('ssid', 'auth')
                    
                    foreach ($key in $requiredWlanKeys) {
                        if (-not $wlanConfig.ContainsKey($key)) {
                            Write-Log "WLAN '$wlanName' in site '$siteName' missing required key: $key" -Level Error
                            $isValid = $false
                        }
                    }
                    
                    # Validate auth configuration
                    if ($wlanConfig.ContainsKey('auth')) {
                        if (-not $wlanConfig.auth.ContainsKey('type')) {
                            Write-Log "WLAN '$wlanName' auth type not specified" -Level Error
                            $isValid = $false
                        }
                        elseif ($wlanConfig.auth.type -eq 'psk' -and -not $wlanConfig.auth.ContainsKey('psk')) {
                            Write-Log "WLAN '$wlanName' PSK not specified for PSK auth" -Level Error
                            $isValid = $false
                        }
                    }
                }
            }
        }
    }
    
    if ($isValid) {
        Write-Log "Configuration validation passed" -Level Success
    } else {
        Write-Log "Configuration validation failed" -Level Error
    }
    
    return $isValid
}

function Deploy-Sites {
    <#
    .SYNOPSIS
        Deploy site configurations
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgId,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )
    
    Write-Log "Deploying sites..." -Level Info
    
    # Get existing sites
    $existingSites = @{}
    try {
        $sites = Get-Sites -OrgId $OrgId
        foreach ($site in $sites) {
            $existingSites[$site.name] = $site
        }
    }
    catch {
        Write-Log "Failed to get existing sites: $($_.Exception.Message)" -Level Error
        return $false
    }
    
    # Deploy each site
    foreach ($siteName in $Config.sites.Keys) {
        try {
            $siteConfig = $Config.sites.$siteName
            $siteConfig['name'] = $siteName
            
            if ($existingSites.ContainsKey($siteName)) {
                # Update existing site
                $existingSite = $existingSites[$siteName]
                Update-Site -SiteId $existingSite.id -SiteConfig $siteConfig
            } else {
                # Create new site
                New-Site -OrgId $OrgId -SiteConfig $siteConfig
            }
        }
        catch {
            Write-Log "Failed to deploy site '$siteName': $($_.Exception.Message)" -Level Error
        }
    }
    
    return $true
}

function Deploy-WLANs {
    <#
    .SYNOPSIS
        Deploy WLAN configurations
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgId,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )
    
    Write-Log "Deploying WLANs..." -Level Info
    
    # Get current sites
    $sites = Get-Sites -OrgId $OrgId
    $siteMap = @{}
    foreach ($site in $sites) {
        $siteMap[$site.name] = $site
    }
    
    foreach ($siteName in $Config.sites.Keys) {
        $siteConfig = $Config.sites.$siteName
        
        if (-not $siteConfig.ContainsKey('wlans')) {
            continue
        }
        
        if (-not $siteMap.ContainsKey($siteName)) {
            Write-Log "Site '$siteName' not found, skipping WLAN deployment" -Level Warning
            continue
        }
        
        $site = $siteMap[$siteName]
        
        # Get existing WLANs
        $existingWlans = @{}
        try {
            $wlans = Get-WLANs -SiteId $site.id
            foreach ($wlan in $wlans) {
                $existingWlans[$wlan.ssid] = $wlan
            }
        }
        catch {
            Write-Log "Failed to get existing WLANs for site '$siteName': $($_.Exception.Message)" -Level Error
            continue
        }
        
        # Deploy each WLAN
        foreach ($wlanName in $siteConfig.wlans.Keys) {
            try {
                $wlanConfig = $siteConfig.wlans.$wlanName
                $ssid = $wlanConfig.ssid
                
                if ($existingWlans.ContainsKey($ssid)) {
                    Write-Log "WLAN '$ssid' already exists in site '$siteName', skipping" -Level Info
                    continue
                }
                
                New-WLAN -SiteId $site.id -WlanConfig $wlanConfig
            }
            catch {
                Write-Log "Failed to deploy WLAN '$wlanName' in site '$siteName': $($_.Exception.Message)" -Level Error
            }
        }
    }
    
    return $true
}

function Deploy-Devices {
    <#
    .SYNOPSIS
        Deploy device configurations
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgId,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )
    
    Write-Log "Deploying devices..." -Level Info
    
    if (-not $Config.ContainsKey('devices')) {
        Write-Log "No devices section in configuration, skipping device deployment" -Level Info
        return $true
    }
    
    $devicesConfig = $Config.devices
    
    # Claim devices if claim codes provided
    if ($devicesConfig.ContainsKey('claim_codes')) {
        try {
            $claimCodes = $devicesConfig.claim_codes
            Add-ClaimCodes -OrgId $OrgId -ClaimCodes $claimCodes
        }
        catch {
            Write-Log "Failed to claim devices: $($_.Exception.Message)" -Level Error
            return $false
        }
    }
    
    # Assign devices to sites if assignments provided
    if ($devicesConfig.ContainsKey('assignments')) {
        # Get site mapping
        $sites = Get-Sites -OrgId $OrgId
        $siteMap = @{}
        foreach ($site in $sites) {
            $siteMap[$site.name] = $site.id
        }
        
        foreach ($assignment in $devicesConfig.assignments) {
            try {
                $deviceId = $assignment.device_id
                $siteName = $assignment.site
                
                if (-not $siteMap.ContainsKey($siteName)) {
                    Write-Log "Site '$siteName' not found for device assignment" -Level Error
                    continue
                }
                
                $siteId = $siteMap[$siteName]
                Set-DeviceToSite -OrgId $OrgId -DeviceId $deviceId -SiteId $siteId
            }
            catch {
                Write-Log "Failed to assign device: $($_.Exception.Message)" -Level Error
            }
        }
    }
    
    return $true
}

function Test-Deployment {
    <#
    .SYNOPSIS
        Verify deployment status
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgId
    )
    
    Write-Log "Verifying deployment..." -Level Info
    
    $verificationPassed = $true
    
    # Check created and updated sites
    $allSites = $script:DeploymentResults.SitesCreated + $script:DeploymentResults.SitesUpdated
    
    foreach ($site in $allSites) {
        try {
            Write-Log "Checking site: $($site.name)" -Level Info
            
            # Get devices for the site
            $devices = Get-Devices -SiteId $site.id
            Write-Log "Site '$($site.name)' has $($devices.Count) access points" -Level Info
            
            # Check device connectivity (basic check)
            foreach ($device in $devices) {
                try {
                    $deviceStatus = Invoke-MistAPI -Uri "$script:BaseUrl/api/$script:ApiVersion/sites/$($site.id)/stats/devices/$($device.id)"
                    
                    if ($deviceStatus.status -ne 'connected') {
                        Write-Log "Device $($device.name) not connected (Status: $($deviceStatus.status))" -Level Warning
                        $verificationPassed = $false
                    } else {
                        Write-Log "Device $($device.name) is connected" -Level Success
                    }
                }
                catch {
                    Write-Log "Could not check status for device $($device.name): $($_.Exception.Message)" -Level Warning
                }
            }
        }
        catch {
            Write-Log "Failed to verify site '$($site.name)': $($_.Exception.Message)" -Level Error
            $verificationPassed = $false
        }
    }
    
    return $verificationPassed
}

function Show-DeploymentSummary {
    <#
    .SYNOPSIS
        Display deployment summary
    #>
    
    Write-Host "`n" + "="*60
    Write-Host "DEPLOYMENT SUMMARY" -ForegroundColor Cyan
    Write-Host "="*60
    
    Write-Host "`nSites Created: $($script:DeploymentResults.SitesCreated.Count)" -ForegroundColor Green
    foreach ($site in $script:DeploymentResults.SitesCreated) {
        Write-Host "  - $($site.name) (ID: $($site.id))" -ForegroundColor White
    }
    
    Write-Host "`nSites Updated: $($script:DeploymentResults.SitesUpdated.Count)" -ForegroundColor Green
    foreach ($site in $script:DeploymentResults.SitesUpdated) {
        Write-Host "  - $($site.name) (ID: $($site.id))" -ForegroundColor White
    }
    
    Write-Host "`nWLANs Created: $($script:DeploymentResults.WLANsCreated.Count)" -ForegroundColor Green
    foreach ($wlan in $script:DeploymentResults.WLANsCreated) {
        Write-Host "  - $($wlan.ssid) (ID: $($wlan.id))" -ForegroundColor White
    }
    
    Write-Host "`nDevices Claimed: $($script:DeploymentResults.DevicesClaimed.Count)" -ForegroundColor Green
    Write-Host "Devices Configured: $($script:DeploymentResults.DevicesConfigured.Count)" -ForegroundColor Green
    
    if ($script:DeploymentResults.Errors.Count -gt 0) {
        Write-Host "`nErrors ($($script:DeploymentResults.Errors.Count)):" -ForegroundColor Red
        foreach ($error in $script:DeploymentResults.Errors) {
            Write-Host "  - $error" -ForegroundColor Red
        }
    }
    
    Write-Host "`n" + "="*60
}

function Start-Deployment {
    <#
    .SYNOPSIS
        Main deployment orchestration function
    #>
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Config,
        
        [Parameter(Mandatory = $false)]
        [bool]$ValidateOnly = $false
    )
    
    Write-Log "Starting Mist AI Network Platform deployment" -Level Info
    
    # Validate configuration
    if (-not (Test-Configuration -Config $Config)) {
        Write-Log "Configuration validation failed" -Level Error
        return $false
    }
    
    if ($ValidateOnly) {
        Write-Log "Validation-only mode: Configuration is valid" -Level Success
        return $true
    }
    
    # Find organization
    $orgName = $Config.organization.name
    if ($Organization) {
        $orgName = $Organization
    }
    
    $org = Find-Organization -OrganizationName $orgName
    if (-not $org) {
        Write-Log "Failed to find organization: $orgName" -Level Error
        return $false
    }
    
    # Deploy components
    if (-not (Deploy-Sites -OrgId $org.id -Config $Config)) {
        Write-Log "Site deployment failed" -Level Error
        return $false
    }
    
    if (-not (Deploy-WLANs -OrgId $org.id -Config $Config)) {
        Write-Log "WLAN deployment failed" -Level Error
        return $false
    }
    
    if (-not (Deploy-Devices -OrgId $org.id -Config $Config)) {
        Write-Log "Device deployment failed" -Level Error
        return $false
    }
    
    # Verify deployment
    $verificationPassed = Test-Deployment -OrgId $org.id
    
    # Show summary
    Show-DeploymentSummary
    
    if ($script:DeploymentResults.Errors.Count -gt 0) {
        Write-Log "Deployment completed with $($script:DeploymentResults.Errors.Count) errors" -Level Error
        return $false
    }
    
    Write-Log "Deployment completed successfully" -Level Success
    return $verificationPassed
}

# Main execution
try {
    Write-Log "Mist AI Network Platform Deployment Script v1.0" -Level Info
    Write-Log "Log file: $LogFile" -Level Info
    
    # Validate API token
    if (-not (Test-ApiToken)) {
        Write-Log "API token validation failed. Exiting." -Level Error
        exit 1
    }
    
    # Load configuration
    Write-Log "Loading configuration from: $ConfigFile" -Level Info
    $config = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json -AsHashtable
    Write-Log "Configuration loaded successfully" -Level Success
    
    # Confirmation prompt (unless Force is specified)
    if (-not $Force -and -not $ValidateOnly) {
        Write-Host "`nDeployment Configuration:" -ForegroundColor Yellow
        Write-Host "- Organization: $($config.organization.name)" -ForegroundColor White
        Write-Host "- Sites to deploy: $($config.sites.Keys.Count)" -ForegroundColor White
        Write-Host "- Log file: $LogFile" -ForegroundColor White
        
        $confirmation = Read-Host "`nProceed with deployment? (y/N)"
        if ($confirmation -notmatch '^[yY]$') {
            Write-Log "Deployment cancelled by user" -Level Info
            exit 0
        }
    }
    
    # Start deployment
    $success = Start-Deployment -Config $config -ValidateOnly:$ValidateOnly
    
    if ($success) {
        Write-Log "Script completed successfully" -Level Success
        exit 0
    } else {
        Write-Log "Script completed with errors" -Level Error
        exit 1
    }
}
catch {
    Write-Log "Unhandled error: $($_.Exception.Message)" -Level Error
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}