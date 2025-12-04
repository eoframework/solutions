@{
    RootModule = 'CMMC-Common.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'EO Framework'
    CompanyName = 'EO Framework'
    Copyright = '(c) 2025 EO Framework. All rights reserved.'
    Description = 'Common functions and utilities for CMMC GCC High Enclave deployment'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Write-CMCLog',
        'Start-CMCLogSession',
        'Import-CMCConfiguration',
        'Get-CMCSecretFromKeyVault',
        'Connect-CMCAzureGovernment',
        'Connect-CMCGraphGCCHigh',
        'Backup-CMCConfiguration',
        'Restore-CMCConfiguration',
        'Test-CMCPrerequisites'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('CMMC', 'GCCHigh', 'Azure', 'Government', 'Security')
            ProjectUri = 'https://github.com/eo-framework/solutions'
        }
    }
}
