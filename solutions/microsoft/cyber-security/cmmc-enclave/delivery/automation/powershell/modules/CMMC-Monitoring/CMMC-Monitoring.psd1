@{
    RootModule        = 'CMMC-Monitoring.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a4b7c8d9-0e1f-2345-6789-abcdef012345'
    Author            = 'EO Framework'
    CompanyName       = 'EO Framework'
    Copyright         = '(c) 2025 EO Framework. All rights reserved.'
    Description       = 'Microsoft Sentinel and monitoring for CMMC GCC High Enclave'
    PowerShellVersion = '7.0'
    RequiredModules   = @('Az.SecurityInsights', 'Az.OperationalInsights')
    FunctionsToExport = @(
        'New-CMCSentinelWorkspace',
        'Enable-CMCSentinelConnectors',
        'New-CMCAnalyticsRule',
        'New-CMCPlaybook',
        'Get-CMCSecurityIncidents',
        'Export-CMCMonitoringReport'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('CMMC', 'Sentinel', 'GCCHigh', 'SIEM', 'Monitoring')
            ProjectUri   = 'https://github.com/eo-framework/solutions'
            ReleaseNotes = 'Initial release of CMMC Monitoring module'
        }
    }
}
