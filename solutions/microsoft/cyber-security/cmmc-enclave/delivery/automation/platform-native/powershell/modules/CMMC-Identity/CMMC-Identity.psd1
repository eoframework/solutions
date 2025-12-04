@{
    RootModule = 'CMMC-Identity.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b2c3d4e5-f6a7-8901-bcde-f12345678901'
    Author = 'EO Framework'
    CompanyName = 'EO Framework'
    Copyright = '(c) 2025 EO Framework. All rights reserved.'
    Description = 'Identity and authentication functions for CMMC GCC High Enclave'
    PowerShellVersion = '7.0'
    RequiredModules = @(
        @{ ModuleName = 'Microsoft.Graph.Identity.SignIns'; ModuleVersion = '2.0.0' }
    )
    FunctionsToExport = @(
        'New-CMCConditionalAccessPolicy',
        'Get-CMCConditionalAccessPolicies',
        'Remove-CMCConditionalAccessPolicy',
        'Enable-CMCCertificateAuthentication',
        'Set-CMCMFARequirement',
        'Set-CMCSessionPolicy'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('CMMC', 'Identity', 'ConditionalAccess', 'CAC', 'PIV', 'MFA')
            ProjectUri = 'https://github.com/eo-framework/solutions'
        }
    }
}
