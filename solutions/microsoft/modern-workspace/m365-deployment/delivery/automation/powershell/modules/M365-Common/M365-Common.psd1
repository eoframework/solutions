@{
    RootModule        = 'M365-Common.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b1c2d3e4-f5a6-7890-1234-567890abcdef'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'Common functions and utilities for M365 Enterprise Deployment'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Write-M365Log',
        'Start-M365LogSession',
        'Import-M365Configuration',
        'Connect-M365Services',
        'Test-M365Prerequisites',
        'Backup-M365Configuration',
        'Restore-M365Configuration'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('M365', 'Microsoft365', 'Deployment', 'Common')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of M365 Common module'
        }
    }
}
