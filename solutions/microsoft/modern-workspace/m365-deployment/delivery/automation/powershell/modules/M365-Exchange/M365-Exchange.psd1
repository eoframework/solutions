@{
    RootModule        = 'M365-Exchange.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'd3e4f5a6-b7c8-9012-3456-7890abcdef12'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'Exchange Online configuration and migration for M365 Deployment'
    PowerShellVersion = '7.0'
    RequiredModules   = @('ExchangeOnlineManagement')
    FunctionsToExport = @(
        'Set-M365ExchangeBaseline',
        'New-M365TransportRule',
        'Set-M365AntiSpamPolicy',
        'Start-M365MailboxMigration',
        'Get-M365MigrationStatus'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('M365', 'Exchange', 'Migration', 'Email')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of M365 Exchange module'
        }
    }
}
