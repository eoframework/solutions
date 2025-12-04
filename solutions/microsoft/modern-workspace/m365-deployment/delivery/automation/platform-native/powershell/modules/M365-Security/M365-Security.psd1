@{
    RootModule        = 'M365-Security.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a6b7c8d9-e0f1-2345-6789-0abcdef12345'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'Security and compliance for M365 Deployment'
    PowerShellVersion = '7.0'
    RequiredModules   = @('ExchangeOnlineManagement')
    FunctionsToExport = @(
        'Enable-M365DefenderForOffice',
        'New-M365DLPPolicy',
        'New-M365RetentionPolicy',
        'Get-M365SecurityStatus',
        'Export-M365ComplianceReport'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('M365', 'Security', 'Defender', 'Compliance')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of M365 Security module'
        }
    }
}
