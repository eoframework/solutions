#Requires -Version 7.0
<#
.SYNOPSIS
    Microsoft Teams configuration for M365 Deployment.

.DESCRIPTION
    This module provides functions for configuring Microsoft Teams,
    policies, meetings, and phone system.

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

function Set-M365TeamsBaseline {
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Config
    )

    Write-M365Log "Configuring Teams baseline..." -Level INFO

    try {
        # Configure tenant-wide settings
        Set-CsTeamsClientConfiguration -Identity Global `
            -AllowBox $false `
            -AllowDropBox $false `
            -AllowGoogleDrive $false `
            -AllowShareFile $false `
            -AllowEgnyte $false

        # Configure guest access
        Set-CsTeamsClientConfiguration -Identity Global `
            -AllowGuestUser $true

        # Configure external access
        Set-CsTenantFederationConfiguration `
            -AllowTeamsConsumer $false `
            -AllowPublicUsers $false

        Write-M365Log "Teams baseline configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure Teams baseline: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Messaging Policy

function Set-M365TeamsMessagingPolicy {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$PolicyName = 'Standard',

        [Parameter()]
        [switch]$AllowOwnerDeleteMessage,

        [Parameter()]
        [switch]$AllowUrlPreviews,

        [Parameter()]
        [switch]$AllowUserEditMessage
    )

    Write-M365Log "Configuring Teams messaging policy: $PolicyName" -Level INFO

    try {
        $existingPolicy = Get-CsTeamsMessagingPolicy -Identity $PolicyName -ErrorAction SilentlyContinue

        $policyParams = @{
            AllowOwnerDeleteMessage = $AllowOwnerDeleteMessage.IsPresent
            AllowUrlPreviews        = $AllowUrlPreviews.IsPresent
            AllowUserEditMessage    = $AllowUserEditMessage.IsPresent
            AllowUserDeleteMessage  = $true
            AllowGiphy              = $true
            GiphyRatingType         = 'Moderate'
            AllowMemes              = $true
            AllowStickers           = $true
            AllowUserTranslation    = $true
            ReadReceiptsEnabledType = 'UserPreference'
        }

        if ($existingPolicy) {
            Set-CsTeamsMessagingPolicy -Identity $PolicyName @policyParams
            Write-M365Log "Messaging policy updated" -Level SUCCESS
        }
        else {
            New-CsTeamsMessagingPolicy -Identity $PolicyName @policyParams
            Write-M365Log "Messaging policy created" -Level SUCCESS
        }

        return $true
    }
    catch {
        Write-M365Log "Failed to configure messaging policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Meeting Policy

function Set-M365TeamsMeetingPolicy {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$PolicyName = 'Global',

        [Parameter()]
        [switch]$AllowAnonymousUsers,

        [Parameter()]
        [ValidateSet('EveryoneInCompany', 'EveryoneInCompanyExcludingGuests', 'Everyone', 'OrganizerOnly')]
        [string]$AutoAdmittedUsers = 'EveryoneInCompanyExcludingGuests',

        [Parameter()]
        [switch]$AllowRecording
    )

    Write-M365Log "Configuring Teams meeting policy: $PolicyName" -Level INFO

    try {
        $policyParams = @{
            AllowAnonymousUsersToJoinMeeting  = $AllowAnonymousUsers.IsPresent
            AutoAdmittedUsers                 = $AutoAdmittedUsers
            AllowCloudRecording               = $AllowRecording.IsPresent
            AllowTranscription                = $true
            AllowIPAudio                      = $true
            AllowIPVideo                      = $true
            AllowParticipantGiveRequestControl = $true
            AllowExternalParticipantGiveRequestControl = $false
            AllowSharedNotes                  = $true
            AllowWhiteboard                   = $true
            AllowMeetNow                      = $true
            AllowPrivateMeetNow               = $true
            ScreenSharingMode                 = 'EntireScreen'
        }

        if ($PolicyName -eq 'Global') {
            Set-CsTeamsMeetingPolicy -Identity Global @policyParams
        }
        else {
            $existingPolicy = Get-CsTeamsMeetingPolicy -Identity $PolicyName -ErrorAction SilentlyContinue

            if ($existingPolicy) {
                Set-CsTeamsMeetingPolicy -Identity $PolicyName @policyParams
            }
            else {
                New-CsTeamsMeetingPolicy -Identity $PolicyName @policyParams
            }
        }

        Write-M365Log "Meeting policy configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure meeting policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Voice Configuration

function Enable-M365TeamsVoice {
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Config,

        [Parameter()]
        [ValidateSet('CallingPlan', 'DirectRouting', 'OperatorConnect')]
        [string]$VoiceType = 'CallingPlan'
    )

    Write-M365Log "Configuring Teams Phone System ($VoiceType)..." -Level INFO

    try {
        if (-not $Config.teams_voice.enabled) {
            Write-M365Log "Teams Voice disabled in configuration" -Level WARN
            return $false
        }

        switch ($VoiceType) {
            'CallingPlan' {
                # Configure calling plans
                Write-M365Log "  Calling Plans require license assignment via admin portal" -Level INFO

                # Set default calling policy
                Set-CsTeamsCallingPolicy -Identity Global `
                    -AllowPrivateCalling $true `
                    -AllowVoicemail 'UserOverride' `
                    -AllowCallGroups $true `
                    -AllowDelegation $true `
                    -AllowCallForwardingToUser $true `
                    -AllowCallForwardingToPhone $true `
                    -PreventTollBypass $false
            }
            'DirectRouting' {
                Write-M365Log "  Direct Routing requires SBC configuration" -Level INFO
                # Direct Routing configuration requires SBC setup
            }
            'OperatorConnect' {
                Write-M365Log "  Operator Connect requires operator relationship" -Level INFO
            }
        }

        # Configure voicemail if enabled
        if ($Config.teams_voice.voicemail_enabled) {
            Write-M365Log "  Configuring cloud voicemail" -Level INFO
            Set-CsOnlineVoicemailPolicy -Identity Global `
                -EnableTranscription $true `
                -EnableTranscriptionProfanityMasking $true
        }

        Write-M365Log "Teams Voice configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure Teams Voice: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Status

function Get-M365TeamsStatus {
    [CmdletBinding()]
    param()

    Write-M365Log "Retrieving Teams status..." -Level INFO

    try {
        $status = @{
            ClientConfiguration = Get-CsTeamsClientConfiguration -Identity Global
            MessagingPolicy     = Get-CsTeamsMessagingPolicy -Identity Global
            MeetingPolicy       = Get-CsTeamsMeetingPolicy -Identity Global
            CallingPolicy       = Get-CsTeamsCallingPolicy -Identity Global
            FederationConfig    = Get-CsTenantFederationConfiguration
        }

        Write-M365Log "Teams status retrieved" -Level SUCCESS
        return $status
    }
    catch {
        Write-M365Log "Failed to get Teams status: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'Set-M365TeamsBaseline',
    'Set-M365TeamsMessagingPolicy',
    'Set-M365TeamsMeetingPolicy',
    'Enable-M365TeamsVoice',
    'Get-M365TeamsStatus'
)

#endregion
