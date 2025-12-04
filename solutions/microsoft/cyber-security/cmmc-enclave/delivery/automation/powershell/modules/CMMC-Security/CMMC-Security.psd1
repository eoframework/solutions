@{
    RootModule        = 'CMMC-Security.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'e2d8b3c4-5f6a-7890-bcde-123456789abc'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'Security controls and Defender configuration for CMMC GCC High Enclave'
    PowerShellVersion = '7.0'
    RequiredModules   = @('Microsoft.Graph.Security')
    FunctionsToExport = @(
        'Enable-CMCDefenderForCloud',
        'Enable-CMCDefenderForOffice',
        'Set-CMCThreatProtection',
        'New-CMCSecurityBaseline',
        'Get-CMCSecurityScore',
        'Export-CMCSecurityReport'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('CMMC', 'Security', 'GCCHigh', 'Defender')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of CMMC Security module'
        }
    }
}
