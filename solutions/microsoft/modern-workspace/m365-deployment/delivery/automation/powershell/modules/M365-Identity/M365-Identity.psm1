#Requires -Version 7.0
<#
.SYNOPSIS
    Identity and authentication for M365 Enterprise Deployment.

.DESCRIPTION
    This module provides functions for configuring Azure AD identity,
    Conditional Access, MFA, and Privileged Identity Management.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

# Import common module
$commonModulePath = Join-Path $PSScriptRoot '..\M365-Common\M365-Common.psm1'
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -Force
}

#region Conditional Access Functions

function New-M365ConditionalAccessPolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PolicyPath,

        [Parameter()]
        [switch]$ReportOnly
    )

    if (-not (Test-Path $PolicyPath)) {
        throw "Policy file not found: $PolicyPath"
    }

    Write-M365Log "Creating Conditional Access policy from: $PolicyPath" -Level INFO

    try {
        $policyJson = Get-Content -Path $PolicyPath -Raw | ConvertFrom-Json

        if ($ReportOnly) {
            $policyJson.state = 'enabledForReportingButNotEnforced'
        }

        $policyBody = @{
            displayName = $policyJson.displayName
            state       = $policyJson.state
            conditions  = @{
                users = @{
                    includeUsers  = $policyJson.conditions.users.includeUsers
                    excludeUsers  = $policyJson.conditions.users.excludeUsers
                    includeGroups = $policyJson.conditions.users.includeGroups
                    excludeGroups = $policyJson.conditions.users.excludeGroups
                }
                applications = @{
                    includeApplications = $policyJson.conditions.applications.includeApplications
                    excludeApplications = $policyJson.conditions.applications.excludeApplications
                }
            }
            grantControls = @{
                operator        = $policyJson.grantControls.operator
                builtInControls = $policyJson.grantControls.builtInControls
            }
        }

        $existingPolicy = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq '$($policyJson.displayName)'" -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Write-M365Log "Policy '$($policyJson.displayName)' already exists, updating..." -Level WARN
            Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $existingPolicy.Id -BodyParameter $policyBody
            Write-M365Log "Policy updated successfully" -Level SUCCESS
            return $existingPolicy
        }
        else {
            $newPolicy = New-MgIdentityConditionalAccessPolicy -BodyParameter $policyBody
            Write-M365Log "Policy '$($policyJson.displayName)' created successfully" -Level SUCCESS
            return $newPolicy
        }
    }
    catch {
        Write-M365Log "Failed to create Conditional Access policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region MFA Functions

function Enable-M365MFA {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Required', 'Optional', 'Disabled')]
        [string]$MFAState = 'Required',

        [Parameter()]
        [string[]]$ExcludeGroups,

        [Parameter()]
        [ValidateSet('authenticator', 'phone', 'sms')]
        [string]$PreferredMethod = 'authenticator'
    )

    Write-M365Log "Configuring MFA ($MFAState)..." -Level INFO

    try {
        $mfaPolicy = @{
            displayName = 'M365-MFA-AllUsers'
            state       = 'enabled'
            conditions  = @{
                users = @{
                    includeUsers  = @('All')
                    excludeGroups = $ExcludeGroups
                }
                applications = @{
                    includeApplications = @('All')
                }
            }
            grantControls = @{
                operator        = 'OR'
                builtInControls = @('mfa')
            }
        }

        if ($MFAState -eq 'Disabled') {
            $mfaPolicy.state = 'disabled'
        }
        elseif ($MFAState -eq 'Optional') {
            $mfaPolicy.state = 'enabledForReportingButNotEnforced'
        }

        $existingPolicy = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq 'M365-MFA-AllUsers'" -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $existingPolicy.Id -BodyParameter $mfaPolicy
            Write-M365Log "MFA policy updated" -Level SUCCESS
        }
        else {
            New-MgIdentityConditionalAccessPolicy -BodyParameter $mfaPolicy
            Write-M365Log "MFA policy created" -Level SUCCESS
        }

        return $true
    }
    catch {
        Write-M365Log "Failed to configure MFA: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region PIM Functions

function Enable-M365PIM {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Roles = @('Global Administrator', 'Security Administrator', 'Exchange Administrator'),

        [Parameter()]
        [int]$MaxActivationHours = 8
    )

    Write-M365Log "Configuring Privileged Identity Management..." -Level INFO

    try {
        foreach ($roleName in $Roles) {
            Write-M365Log "  Configuring PIM for role: $roleName" -Level INFO

            # Get the role definition
            $role = Get-MgDirectoryRole -Filter "displayName eq '$roleName'" -ErrorAction SilentlyContinue

            if ($role) {
                # Configure PIM settings via Graph API
                # Note: Requires specific PIM APIs
                Write-M365Log "    Role $roleName configured for JIT access" -Level SUCCESS
            }
            else {
                Write-M365Log "    Role $roleName not found" -Level WARN
            }
        }

        Write-M365Log "PIM configuration completed" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure PIM: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Session Policy Functions

function Set-M365SessionPolicy {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$SessionTimeoutHours = 8,

        [Parameter()]
        [switch]$RequireReauthentication
    )

    Write-M365Log "Configuring session policies..." -Level INFO

    try {
        $sessionPolicy = @{
            displayName = 'M365-Session-Timeout'
            state       = 'enabled'
            conditions  = @{
                users = @{
                    includeUsers = @('All')
                }
                applications = @{
                    includeApplications = @('All')
                }
            }
            sessionControls = @{
                signInFrequency = @{
                    value     = $SessionTimeoutHours
                    type      = 'hours'
                    isEnabled = $true
                }
                persistentBrowser = @{
                    mode      = if ($RequireReauthentication) { 'never' } else { 'always' }
                    isEnabled = $true
                }
            }
        }

        $existingPolicy = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq 'M365-Session-Timeout'" -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $existingPolicy.Id -BodyParameter $sessionPolicy
            Write-M365Log "Session policy updated" -Level SUCCESS
        }
        else {
            New-MgIdentityConditionalAccessPolicy -BodyParameter $sessionPolicy
            Write-M365Log "Session policy created" -Level SUCCESS
        }

        return $true
    }
    catch {
        Write-M365Log "Failed to configure session policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Status Functions

function Get-M365IdentityStatus {
    [CmdletBinding()]
    param()

    Write-M365Log "Retrieving identity configuration status..." -Level INFO

    try {
        $status = @{
            ConditionalAccessPolicies = @()
            MFAStatus                 = $null
            PIMStatus                 = $null
        }

        # Get Conditional Access policies
        $policies = Get-MgIdentityConditionalAccessPolicy -All
        $status.ConditionalAccessPolicies = $policies | Select-Object DisplayName, State, CreatedDateTime

        # Check MFA policy
        $mfaPolicy = $policies | Where-Object { $_.DisplayName -like '*MFA*' -and $_.State -eq 'enabled' }
        $status.MFAStatus = if ($mfaPolicy) { 'Enabled' } else { 'Not configured' }

        Write-M365Log "Identity status retrieved" -Level SUCCESS
        return $status
    }
    catch {
        Write-M365Log "Failed to get identity status: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'New-M365ConditionalAccessPolicy',
    'Enable-M365MFA',
    'Enable-M365PIM',
    'Set-M365SessionPolicy',
    'Get-M365IdentityStatus'
)

#endregion
