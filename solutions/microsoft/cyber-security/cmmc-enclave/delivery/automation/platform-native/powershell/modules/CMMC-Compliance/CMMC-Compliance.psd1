@{
    RootModule        = 'CMMC-Compliance.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'f3e9c5d6-7a8b-9012-cdef-234567890abc'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'Purview compliance and data protection for CMMC GCC High Enclave'
    PowerShellVersion = '7.0'
    RequiredModules   = @('ExchangeOnlineManagement')
    FunctionsToExport = @(
        'New-CMCDLPPolicy',
        'New-CMCSensitivityLabel',
        'New-CMCRetentionPolicy',
        'Enable-CMCeDiscovery',
        'Get-CMCComplianceScore',
        'Export-CMCComplianceReport'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('CMMC', 'Compliance', 'GCCHigh', 'Purview', 'DLP')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of CMMC Compliance module'
        }
    }
}
