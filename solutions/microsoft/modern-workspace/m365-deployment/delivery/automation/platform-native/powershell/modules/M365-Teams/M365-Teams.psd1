@{
    RootModule        = 'M365-Teams.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'f5a6b7c8-d9e0-1234-5678-90abcdef1234'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'Microsoft Teams configuration for M365 Deployment'
    PowerShellVersion = '7.0'
    RequiredModules   = @('MicrosoftTeams')
    FunctionsToExport = @(
        'Set-M365TeamsBaseline',
        'Set-M365TeamsMessagingPolicy',
        'Set-M365TeamsMeetingPolicy',
        'Enable-M365TeamsVoice',
        'Get-M365TeamsStatus'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('M365', 'Teams', 'Voice', 'Meetings')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of M365 Teams module'
        }
    }
}
