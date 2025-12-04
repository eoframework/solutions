#Requires -Version 7.0
<#
.SYNOPSIS
    Exchange Online configuration and migration for M365 Deployment.

.DESCRIPTION
    This module provides functions for configuring Exchange Online,
    mail flow rules, anti-spam, and mailbox migrations.

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

function Set-M365ExchangeBaseline {
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Config
    )

    Write-M365Log "Configuring Exchange Online baseline..." -Level INFO

    try {
        # Configure organization settings
        Set-OrganizationConfig `
            -MailTipsAllTipsEnabled $true `
            -MailTipsExternalRecipientsTipsEnabled $true `
            -MailTipsGroupMetricsEnabled $true `
            -MailTipsLargeAudienceThreshold 25

        # Configure default sharing policy
        Set-SharingPolicy -Identity 'Default Sharing Policy' `
            -Enabled $true

        # Configure mobile device policy
        $existingPolicy = Get-MobileDeviceMailboxPolicy -Identity 'Default' -ErrorAction SilentlyContinue
        if ($existingPolicy) {
            Set-MobileDeviceMailboxPolicy -Identity 'Default' `
                -AllowSimplePassword $false `
                -MinPasswordLength 6 `
                -PasswordEnabled $true `
                -MaxPasswordFailedAttempts 10 `
                -AllowStorageCard $false `
                -DeviceEncryptionEnabled $true
        }

        Write-M365Log "Exchange baseline configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure Exchange baseline: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Transport Rules

function New-M365TransportRule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RuleName,

        [Parameter()]
        [ValidateSet('ExternalDisclaimer', 'SensitiveData', 'Encryption')]
        [string]$RuleType = 'ExternalDisclaimer'
    )

    Write-M365Log "Creating transport rule: $RuleName ($RuleType)" -Level INFO

    try {
        switch ($RuleType) {
            'ExternalDisclaimer' {
                $rule = New-TransportRule -Name $RuleName `
                    -FromScope 'InOrganization' `
                    -SentToScope 'NotInOrganization' `
                    -ApplyHtmlDisclaimerLocation 'Append' `
                    -ApplyHtmlDisclaimerText '<p style="font-size:10px;color:gray;">CONFIDENTIAL: This email and any attachments are for the exclusive and confidential use of the intended recipient.</p>' `
                    -ApplyHtmlDisclaimerFallbackAction 'Wrap'
            }
            'SensitiveData' {
                $rule = New-TransportRule -Name $RuleName `
                    -FromScope 'InOrganization' `
                    -SentToScope 'NotInOrganization' `
                    -MessageContainsDataClassifications @(@{Name='Credit Card Number'}, @{Name='U.S. Social Security Number (SSN)'}) `
                    -SetSCL 9 `
                    -NotifySender 'RejectMessage' `
                    -RejectMessageReasonText 'Emails containing sensitive data cannot be sent externally.'
            }
            'Encryption' {
                $rule = New-TransportRule -Name $RuleName `
                    -FromScope 'InOrganization' `
                    -SubjectOrBodyContainsWords @('[encrypt]', '[secure]') `
                    -ApplyOME $true
            }
        }

        Write-M365Log "Transport rule created successfully" -Level SUCCESS
        return $rule
    }
    catch {
        Write-M365Log "Failed to create transport rule: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Anti-Spam Configuration

function Set-M365AntiSpamPolicy {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Standard', 'Strict')]
        [string]$Level = 'Standard'
    )

    Write-M365Log "Configuring anti-spam policy (Level: $Level)..." -Level INFO

    try {
        $spamParams = @{
            Identity = 'Default'
        }

        if ($Level -eq 'Standard') {
            $spamParams += @{
                SpamAction                   = 'MoveToJmf'
                HighConfidenceSpamAction     = 'Quarantine'
                PhishSpamAction              = 'Quarantine'
                HighConfidencePhishAction    = 'Quarantine'
                BulkSpamAction               = 'MoveToJmf'
                BulkThreshold                = 6
                QuarantineRetentionPeriod    = 30
            }
        }
        else {
            $spamParams += @{
                SpamAction                   = 'Quarantine'
                HighConfidenceSpamAction     = 'Quarantine'
                PhishSpamAction              = 'Quarantine'
                HighConfidencePhishAction    = 'Quarantine'
                BulkSpamAction               = 'Quarantine'
                BulkThreshold                = 4
                QuarantineRetentionPeriod    = 30
            }
        }

        Set-HostedContentFilterPolicy @spamParams

        Write-M365Log "Anti-spam policy configured" -Level SUCCESS
        return $true
    }
    catch {
        Write-M365Log "Failed to configure anti-spam policy: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Migration Functions

function Start-M365MailboxMigration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$BatchName,

        [Parameter(Mandatory)]
        [string]$CSVFilePath,

        [Parameter()]
        [ValidateSet('ExchangeRemoteMove', 'Staged', 'Cutover', 'IMAP')]
        [string]$MigrationType = 'ExchangeRemoteMove',

        [Parameter()]
        [switch]$StartImmediately
    )

    Write-M365Log "Starting mailbox migration batch: $BatchName" -Level INFO

    try {
        if (-not (Test-Path $CSVFilePath)) {
            throw "CSV file not found: $CSVFilePath"
        }

        $migrationParams = @{
            Name            = $BatchName
            CSVData         = [System.IO.File]::ReadAllBytes($CSVFilePath)
            NotificationEmails = @($Config.monitoring.alert_email)
        }

        switch ($MigrationType) {
            'ExchangeRemoteMove' {
                $migrationParams['TargetDeliveryDomain'] = $Config.azure_ad.tenant_domain
                $batch = New-MigrationBatch @migrationParams
            }
            'Staged' {
                $migrationParams['SourceEndpoint'] = $Config.migration.source_endpoint
                $batch = New-MigrationBatch @migrationParams -SourceEndpoint $migrationParams.SourceEndpoint
            }
            'Cutover' {
                $batch = New-MigrationBatch @migrationParams
            }
            'IMAP' {
                $migrationParams['SourceEndpoint'] = $Config.migration.source_endpoint
                $batch = New-MigrationBatch @migrationParams
            }
        }

        if ($StartImmediately) {
            Start-MigrationBatch -Identity $BatchName
            Write-M365Log "Migration batch started" -Level SUCCESS
        }
        else {
            Write-M365Log "Migration batch created (not started)" -Level SUCCESS
        }

        return $batch
    }
    catch {
        Write-M365Log "Failed to start migration: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Get-M365MigrationStatus {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$BatchName
    )

    Write-M365Log "Retrieving migration status..." -Level INFO

    try {
        if ($BatchName) {
            $batches = Get-MigrationBatch -Identity $BatchName
        }
        else {
            $batches = Get-MigrationBatch
        }

        $status = foreach ($batch in $batches) {
            $users = Get-MigrationUser -BatchId $batch.Identity

            @{
                BatchName       = $batch.Identity
                Status          = $batch.Status
                TotalCount      = $users.Count
                SyncedCount     = ($users | Where-Object { $_.Status -eq 'Synced' }).Count
                FailedCount     = ($users | Where-Object { $_.Status -eq 'Failed' }).Count
                CreatedTime     = $batch.CreationDateTime
                CompleteAfter   = $batch.CompleteAfter
            }
        }

        return $status
    }
    catch {
        Write-M365Log "Failed to get migration status: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

#endregion

#region Export Functions

Export-ModuleMember -Function @(
    'Set-M365ExchangeBaseline',
    'New-M365TransportRule',
    'Set-M365AntiSpamPolicy',
    'Start-M365MailboxMigration',
    'Get-M365MigrationStatus'
)

#endregion
