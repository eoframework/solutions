@{
    RootModule        = 'M365-SharePoint.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'e4f5a6b7-c8d9-0123-4567-890abcdef123'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'SharePoint Online configuration for M365 Deployment'
    PowerShellVersion = '7.0'
    RequiredModules   = @('Microsoft.Online.SharePoint.PowerShell')
    FunctionsToExport = @(
        'Set-M365SharePointBaseline',
        'New-M365HubSite',
        'Set-M365ExternalSharing',
        'Start-M365FileMigration',
        'Get-M365SharePointStatus'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('M365', 'SharePoint', 'Sites', 'Migration')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of M365 SharePoint module'
        }
    }
}
