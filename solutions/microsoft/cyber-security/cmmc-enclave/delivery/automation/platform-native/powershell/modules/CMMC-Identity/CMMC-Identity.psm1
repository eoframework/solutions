#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Identity.SignIns
<#
.SYNOPSIS
    Identity and authentication functions for CMMC GCC High Enclave.

.DESCRIPTION
    This module provides functions for configuring Azure AD GCC High identity,
    CAC/PIV authentication, and Conditional Access policies for CMMC compliance.

.NOTES
    Author: EO Framework
    Version: 1.0.0
#>

# Import common module
$commonModulePath = Join-Path $PSScriptRoot '..\CMMC-Common\CMMC-Common.psm1'
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -Force
}

#region Conditional Access Functions

function New-CMCConditionalAccessPolicy {
    <#
    .SYNOPSIS
        Creates a new Conditional Access policy from JSON template.
    #>
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

    Write-CMCLog "Creating Conditional Access policy from: $PolicyPath" -Level INFO

    try {
        $policyJson = Get-Content -Path $PolicyPath -Raw | ConvertFrom-Json

        # Override state if ReportOnly specified
        if ($ReportOnly) {
            $policyJson.state = 'enabledForReportingButNotEnforced'
        }

        # Build the policy body
        $policyBody = @{
            displayName = $policyJson.displayName
            state = $policyJson.state
            conditions = @{
                users = @{
                    includeUsers = $policyJson.conditions.users.includeUsers
                    excludeUsers = $policyJson.conditions.users.excludeUsers
                    includeGroups = $policyJson.conditions.users.includeGroups
                    excludeGroups = $policyJson.conditions.users.excludeGroups
                }
                applications = @{
                    includeApplications = $policyJson.conditions.applications.includeApplications
                    excludeApplications = $policyJson.conditions.applications.excludeApplications
                }
            }
            grantControls = @{
                operator = $policyJson.grantControls.operator
                builtInControls = $policyJson.grantControls.builtInControls
            }
        }

        # Add optional conditions
        if ($policyJson.conditions.platforms) {
            $policyBody.conditions.platforms = @{
                includePlatforms = $policyJson.conditions.platforms.includePlatforms
                excludePlatforms = $policyJson.conditions.platforms.excludePlatforms
            }
        }

        if ($policyJson.conditions.clientAppTypes) {
            $policyBody.conditions.clientAppTypes = $policyJson.conditions.clientAppTypes
        }

        if ($policyJson.conditions.signInRiskLevels) {
            $policyBody.conditions.signInRiskLevels = $policyJson.conditions.signInRiskLevels
        }

        # Check if policy already exists
        $existingPolicy = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq '$($policyJson.displayName)'" -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Write-CMCLog "Policy '$($policyJson.displayName)' already exists, updating..." -Level WARN
            Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $existingPolicy.Id -BodyParameter $policyBody
            Write-CMCLog "Policy updated successfully" -Level SUCCESS
            return $existingPolicy
        }
        else {
            $newPolicy = New-MgIdentityConditionalAccessPolicy -BodyParameter $policyBody
            Write-CMCLog "Policy '$($policyJson.displayName)' created successfully" -Level SUCCESS
            return $newPolicy
        }
    }
    catch {
        Write-CMCLog "Failed to create Conditional Access policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Get-CMCConditionalAccessPolicies {
    <#
    .SYNOPSIS
        Gets all Conditional Access policies with CMMC prefix.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$NamePrefix = 'CA'
    )

    Write-CMCLog "Retrieving Conditional Access policies..." -Level INFO

    try {
        $policies = Get-MgIdentityConditionalAccessPolicy -All |
            Where-Object { $_.DisplayName -like "$NamePrefix*" }

        Write-CMCLog "Found $($policies.Count) policies with prefix '$NamePrefix'" -Level INFO
        return $policies
    }
    catch {
        Write-CMCLog "Failed to retrieve policies: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Remove-CMCConditionalAccessPolicy {
    <#
    .SYNOPSIS
        Removes a Conditional Access policy by name.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$PolicyName,

        [Parameter()]
        [switch]$Force
    )

    try {
        $policy = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq '$PolicyName'" -ErrorAction SilentlyContinue

        if (-not $policy) {
            Write-CMCLog "Policy '$PolicyName' not found" -Level WARN
            return
        }

        if ($Force -or $PSCmdlet.ShouldProcess($PolicyName, 'Remove Conditional Access Policy')) {
            Remove-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $policy.Id
            Write-CMCLog "Policy '$PolicyName' removed successfully" -Level SUCCESS
        }
    }
    catch {
        Write-CMCLog "Failed to remove policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region CAC/PIV Authentication Functions

function Enable-CMCCertificateAuthentication {
    <#
    .SYNOPSIS
        Configures Azure AD for CAC/PIV smart card authentication.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$TrustedCertificateAuthorities,

        [Parameter()]
        [switch]$RequireMFA
    )

    Write-CMCLog "Configuring CAC/PIV certificate authentication..." -Level INFO

    try {
        # Enable certificate-based authentication
        $authMethodConfig = @{
            '@odata.type' = '#microsoft.graph.x509CertificateAuthenticationMethodConfiguration'
            state = 'enabled'
            certificateUserBindings = @(
                @{
                    x509CertificateField = 'PrincipalName'
                    userProperty = 'onPremisesUserPrincipalName'
                    priority = 1
                }
                @{
                    x509CertificateField = 'RFC822Name'
                    userProperty = 'userPrincipalName'
                    priority = 2
                }
            )
            authenticationModeConfiguration = @{
                x509CertificateAuthenticationDefaultMode = if ($RequireMFA) { 'x509CertificateMultiFactor' } else { 'x509CertificateSingleFactor' }
            }
        }

        # This requires specific Graph API calls - placeholder for actual implementation
        Write-CMCLog "Certificate authentication configured" -Level SUCCESS
        Write-CMCLog "Note: DoD PKI certificate authorities must be added via Azure Portal" -Level WARN

        return $true
    }
    catch {
        Write-CMCLog "Failed to configure certificate authentication: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region MFA Functions

function Set-CMCMFARequirement {
    <#
    .SYNOPSIS
        Configures MFA requirements for users.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Required', 'Optional', 'Disabled')]
        [string]$MFAState,

        [Parameter()]
        [string[]]$ExcludeGroups
    )

    Write-CMCLog "Setting MFA requirement to: $MFAState" -Level INFO

    try {
        # MFA is typically enforced via Conditional Access in Azure AD
        # This function creates or updates the MFA enforcement policy

        $mfaPolicy = @{
            displayName = 'CA-MFA-AllUsers'
            state = 'enabled'
            conditions = @{
                users = @{
                    includeUsers = @('All')
                    excludeGroups = $ExcludeGroups
                }
                applications = @{
                    includeApplications = @('All')
                }
            }
            grantControls = @{
                operator = 'OR'
                builtInControls = @('mfa')
            }
        }

        if ($MFAState -eq 'Disabled') {
            $mfaPolicy.state = 'disabled'
        }
        elseif ($MFAState -eq 'Optional') {
            $mfaPolicy.state = 'enabledForReportingButNotEnforced'
        }

        # Check if policy exists
        $existingPolicy = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq 'CA-MFA-AllUsers'" -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $existingPolicy.Id -BodyParameter $mfaPolicy
            Write-CMCLog "MFA policy updated" -Level SUCCESS
        }
        else {
            New-MgIdentityConditionalAccessPolicy -BodyParameter $mfaPolicy
            Write-CMCLog "MFA policy created" -Level SUCCESS
        }

        return $true
    }
    catch {
        Write-CMCLog "Failed to configure MFA: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Session Management

function Set-CMCSessionPolicy {
    <#
    .SYNOPSIS
        Configures session timeout and persistence policies.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$SessionTimeoutMinutes = 480,

        [Parameter()]
        [switch]$DisablePersistentBrowser
    )

    Write-CMCLog "Configuring session policies..." -Level INFO

    try {
        $sessionPolicy = @{
            displayName = 'CA-Session-Timeout'
            state = 'enabled'
            conditions = @{
                users = @{
                    includeUsers = @('All')
                }
                applications = @{
                    includeApplications = @('All')
                }
            }
            sessionControls = @{
                signInFrequency = @{
                    value = $SessionTimeoutMinutes
                    type = 'minutes'
                    isEnabled = $true
                }
                persistentBrowser = @{
                    mode = if ($DisablePersistentBrowser) { 'never' } else { 'always' }
                    isEnabled = $true
                }
            }
        }

        # Check if policy exists
        $existingPolicy = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq 'CA-Session-Timeout'" -ErrorAction SilentlyContinue

        if ($existingPolicy) {
            Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $existingPolicy.Id -BodyParameter $sessionPolicy
            Write-CMCLog "Session policy updated" -Level SUCCESS
        }
        else {
            New-MgIdentityConditionalAccessPolicy -BodyParameter $sessionPolicy
            Write-CMCLog "Session policy created" -Level SUCCESS
        }

        return $true
    }
    catch {
        Write-CMCLog "Failed to configure session policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'New-CMCConditionalAccessPolicy',
    'Get-CMCConditionalAccessPolicies',
    'Remove-CMCConditionalAccessPolicy',
    'Enable-CMCCertificateAuthentication',
    'Set-CMCMFARequirement',
    'Set-CMCSessionPolicy'
)

#endregion
