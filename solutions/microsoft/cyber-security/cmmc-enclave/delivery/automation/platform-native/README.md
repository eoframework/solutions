# CMMC GCC High Enclave - Platform-Native Automation

PowerShell-based automation for deploying and configuring Microsoft 365 GCC High and Azure Government environments for CMMC Level 2 compliance.

## Overview

This automation implements all 110 NIST 800-171 security controls required for CMMC Level 2 certification using:
- **Microsoft Graph PowerShell SDK** for M365 GCC High configuration
- **Azure PowerShell** for Azure Government infrastructure
- **JSON templates** for Conditional Access and Intune policies

## Prerequisites

### PowerShell Modules

```powershell
# Run requirements.ps1 to install all required modules
.\requirements.ps1

# Or install manually:
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module Az -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser
```

### Required Permissions

| Service | Permissions Required |
|---------|---------------------|
| Azure AD | Global Administrator or Privileged Role Administrator |
| M365 GCC High | Security Administrator, Compliance Administrator |
| Azure Government | Owner or Contributor on subscription |
| Sentinel | Microsoft Sentinel Contributor |

### Environment Variables

Create a `.env` file or set environment variables:

```bash
AZURE_GOV_TENANT_ID=<your-gov-tenant-id>
AZURE_GOV_SUBSCRIPTION_ID=<your-gov-subscription-id>
M365_GCC_HIGH_TENANT=<tenant>.onmicrosoft.us
```

## Directory Structure

```
platform-native/
├── README.md                           # This file
├── requirements.ps1                    # Module installation script
├── powershell/
│   ├── modules/
│   │   ├── CMMC-Common/               # Shared functions and utilities
│   │   │   ├── CMMC-Common.psd1
│   │   │   └── CMMC-Common.psm1
│   │   ├── CMMC-Identity/             # Azure AD and authentication
│   │   │   ├── CMMC-Identity.psd1
│   │   │   └── CMMC-Identity.psm1
│   │   ├── CMMC-Security/             # Security controls and Defender
│   │   │   ├── CMMC-Security.psd1
│   │   │   └── CMMC-Security.psm1
│   │   ├── CMMC-Compliance/           # Purview and compliance
│   │   │   ├── CMMC-Compliance.psd1
│   │   │   └── CMMC-Compliance.psm1
│   │   └── CMMC-Monitoring/           # Sentinel and monitoring
│   │       ├── CMMC-Monitoring.psd1
│   │       └── CMMC-Monitoring.psm1
│   ├── scripts/
│   │   ├── prod/
│   │   │   ├── Deploy-CMMC.ps1        # Main deployment orchestrator
│   │   │   ├── Configure-Identity.ps1  # CAC/PIV and Conditional Access
│   │   │   ├── Configure-Security.ps1  # Defender and security controls
│   │   │   ├── Configure-Compliance.ps1 # Purview DLP and retention
│   │   │   ├── Configure-Monitoring.ps1 # Sentinel and alerts
│   │   │   └── Validate-Controls.ps1   # NIST 800-171 validation
│   │   ├── test/
│   │   │   └── Deploy-CMMC.ps1
│   │   └── dr/
│   │       └── Deploy-CMMC.ps1
│   └── config/
│       ├── prod.psd1                   # Production configuration
│       ├── test.psd1                   # Test configuration
│       └── dr.psd1                     # DR configuration
├── config/
│   ├── conditional-access/
│   │   ├── CA001-RequireMFAAdmins.json
│   │   ├── CA002-BlockLegacyAuth.json
│   │   ├── CA003-RequireCompliantDevice.json
│   │   ├── CA004-RequireCACPIV.json
│   │   └── CA005-BlockHighRiskSignIn.json
│   ├── intune/
│   │   ├── device-compliance-windows.json
│   │   ├── device-compliance-mobile.json
│   │   └── app-protection-policy.json
│   ├── purview/
│   │   ├── dlp-cui-policy.json
│   │   ├── retention-policy.json
│   │   └── sensitivity-labels.json
│   └── sentinel/
│       ├── analytics-rules/
│       │   ├── cui-data-exfiltration.json
│       │   ├── failed-authentication.json
│       │   └── privilege-escalation.json
│       └── playbooks/
│           ├── incident-response.json
│           └── block-compromised-user.json
└── tests/
    ├── Pester/
    │   ├── CMMC-Identity.Tests.ps1
    │   ├── CMMC-Security.Tests.ps1
    │   └── CMMC-Compliance.Tests.ps1
    └── validation/
        └── Validate-NIST800171.ps1
```

## Deployment

### Quick Start

```powershell
# 1. Install prerequisites
.\requirements.ps1

# 2. Connect to Azure Government and M365 GCC High
Connect-AzAccount -Environment AzureUSGovernment
Connect-MgGraph -Environment USGov -Scopes "Policy.ReadWrite.ConditionalAccess","DeviceManagementConfiguration.ReadWrite.All"

# 3. Deploy to production
.\powershell\scripts\prod\Deploy-CMMC.ps1 -ConfigPath .\powershell\config\prod.psd1

# 4. Validate NIST 800-171 controls
.\powershell\scripts\prod\Validate-Controls.ps1 -OutputPath .\reports\compliance-report.html
```

### Step-by-Step Deployment

1. **Configure Identity and Authentication**
   ```powershell
   .\powershell\scripts\prod\Configure-Identity.ps1 -ConfigPath .\powershell\config\prod.psd1
   ```
   - Deploys Conditional Access policies
   - Configures CAC/PIV authentication
   - Sets up MFA enforcement

2. **Configure Security Controls**
   ```powershell
   .\powershell\scripts\prod\Configure-Security.ps1 -ConfigPath .\powershell\config\prod.psd1
   ```
   - Deploys Defender for Office 365
   - Configures Defender for Cloud
   - Enables threat protection

3. **Configure Compliance**
   ```powershell
   .\powershell\scripts\prod\Configure-Compliance.ps1 -ConfigPath .\powershell\config\prod.psd1
   ```
   - Deploys DLP policies for CUI protection
   - Configures retention policies
   - Creates sensitivity labels

4. **Configure Monitoring**
   ```powershell
   .\powershell\scripts\prod\Configure-Monitoring.ps1 -ConfigPath .\powershell\config\prod.psd1
   ```
   - Deploys Sentinel workspace
   - Configures analytics rules
   - Sets up incident response playbooks

## NIST 800-171 Control Mapping

| Control Family | Controls | Automation Component |
|---------------|----------|---------------------|
| Access Control (AC) | 22 | CMMC-Identity module, Conditional Access policies |
| Awareness & Training (AT) | 3 | Manual + Defender attack simulation |
| Audit & Accountability (AU) | 9 | CMMC-Monitoring module, Sentinel |
| Configuration Management (CM) | 9 | Intune policies, Azure Policy |
| Identification & Authentication (IA) | 11 | CMMC-Identity module, CAC/PIV |
| Incident Response (IR) | 3 | Sentinel playbooks |
| Maintenance (MA) | 6 | Azure Update Management |
| Media Protection (MP) | 9 | Purview sensitivity labels, BitLocker |
| Personnel Security (PS) | 2 | Manual process |
| Physical Protection (PE) | 6 | Manual process (Azure datacenter) |
| Risk Assessment (RA) | 3 | Defender vulnerability assessment |
| Security Assessment (CA) | 4 | Validate-Controls.ps1 |
| System & Communications Protection (SC) | 16 | Network security, encryption policies |
| System & Information Integrity (SI) | 7 | Defender, Sentinel |

## Configuration Files

### Production Configuration (prod.psd1)

Generated from `delivery/raw/configuration.csv` - do not edit directly.

```powershell
# Regenerate configuration files:
python /mnt/c/projects/wsl/eof-tools/automation/scripts/generate-powershell-config.py \
    --input ../../../raw/configuration.csv \
    --output ./config/ \
    --environment prod
```

## Testing

### Run Pester Tests

```powershell
# Run all tests
Invoke-Pester -Path .\tests\Pester\ -Output Detailed

# Run specific test
Invoke-Pester -Path .\tests\Pester\CMMC-Identity.Tests.ps1 -Output Detailed
```

### Validate NIST 800-171 Compliance

```powershell
# Generate compliance report
.\tests\validation\Validate-NIST800171.ps1 -OutputFormat HTML -OutputPath .\reports\

# Check specific control family
.\tests\validation\Validate-NIST800171.ps1 -ControlFamily "AC" -Verbose
```

## Rollback

Each deployment script supports rollback:

```powershell
# Rollback Conditional Access policies
.\powershell\scripts\prod\Configure-Identity.ps1 -Rollback -BackupPath .\backups\2025-12-04\

# Rollback all changes
.\powershell\scripts\prod\Deploy-CMMC.ps1 -Rollback -BackupPath .\backups\2025-12-04\
```

## Support

For issues or questions:
- Review the [CMMC Level 2 Assessment Guide](https://www.acq.osd.mil/cmmc/)
- Check [Microsoft 365 GCC High documentation](https://docs.microsoft.com/en-us/office365/servicedescriptions/office-365-platform-service-description/office-365-us-government/gcc-high-and-dod)
- Review [NIST SP 800-171 Rev 2](https://csrc.nist.gov/publications/detail/sp/800-171/rev-2/final)
