@{
    RootModule        = 'M365-Identity.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'c2d3e4f5-a6b7-8901-2345-67890abcdef1'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'Identity and authentication for M365 Enterprise Deployment'
    PowerShellVersion = '7.0'
    RequiredModules   = @('Microsoft.Graph.Identity.SignIns')
    FunctionsToExport = @(
        'New-M365ConditionalAccessPolicy',
        'Enable-M365MFA',
        'Enable-M365PIM',
        'Set-M365SessionPolicy',
        'Get-M365IdentityStatus'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('M365', 'Identity', 'ConditionalAccess', 'MFA')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of M365 Identity module'
        }
    }
}
