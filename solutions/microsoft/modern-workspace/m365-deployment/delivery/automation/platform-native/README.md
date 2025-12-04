# Microsoft 365 Enterprise Deployment - Platform-Native Automation

PowerShell-based automation for deploying and configuring Microsoft 365 E5 with Exchange Online, SharePoint, Teams, and comprehensive security.

## Overview

This automation implements a complete Microsoft 365 enterprise deployment using:
- **Microsoft Graph PowerShell SDK** for M365 configuration
- **Exchange Online Management** for email and hybrid configuration
- **SharePoint Online Management** for site provisioning
- **Microsoft Teams PowerShell** for Teams configuration

## Prerequisites

### PowerShell Modules

```powershell
# Run requirements.ps1 to install all required modules
.\requirements.ps1

# Or install manually:
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser
Install-Module Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser
Install-Module MicrosoftTeams -Scope CurrentUser
```

### Required Permissions

| Service | Permissions Required |
|---------|---------------------|
| Azure AD | Global Administrator or User Administrator |
| Exchange Online | Exchange Administrator, Organization Management |
| SharePoint | SharePoint Administrator |
| Teams | Teams Administrator |
| Intune | Intune Administrator |

### Environment Variables

Create a `.env` file or set environment variables:

```bash
AZURE_TENANT_ID=<your-tenant-id>
M365_TENANT_DOMAIN=<company>.onmicrosoft.com
M365_ADMIN_UPN=admin@company.com
```

## Directory Structure

```
platform-native/
├── README.md                           # This file
├── requirements.ps1                    # Module installation script
├── powershell/
│   ├── modules/
│   │   ├── M365-Common/               # Shared functions and utilities
│   │   │   ├── M365-Common.psd1
│   │   │   └── M365-Common.psm1
│   │   ├── M365-Identity/             # Azure AD and authentication
│   │   │   ├── M365-Identity.psd1
│   │   │   └── M365-Identity.psm1
│   │   ├── M365-Exchange/             # Exchange Online configuration
│   │   │   ├── M365-Exchange.psd1
│   │   │   └── M365-Exchange.psm1
│   │   ├── M365-SharePoint/           # SharePoint Online configuration
│   │   │   ├── M365-SharePoint.psd1
│   │   │   └── M365-SharePoint.psm1
│   │   ├── M365-Teams/                # Teams and voice configuration
│   │   │   ├── M365-Teams.psd1
│   │   │   └── M365-Teams.psm1
│   │   └── M365-Security/             # Security and compliance
│   │       ├── M365-Security.psd1
│   │       └── M365-Security.psm1
│   ├── scripts/
│   │   ├── prod/
│   │   │   ├── Deploy-M365.ps1         # Main deployment orchestrator
│   │   │   ├── Configure-Identity.ps1   # Azure AD and MFA
│   │   │   ├── Configure-Exchange.ps1   # Exchange Online setup
│   │   │   ├── Configure-SharePoint.ps1 # SharePoint provisioning
│   │   │   ├── Configure-Teams.ps1      # Teams and voice
│   │   │   ├── Configure-Security.ps1   # Defender and compliance
│   │   │   ├── Migrate-Email.ps1        # Email migration
│   │   │   └── Migrate-Files.ps1        # File migration
│   │   ├── test/
│   │   │   └── Deploy-M365.ps1
│   │   └── dr/
│   │       └── Deploy-M365.ps1
│   └── config/
│       ├── prod.psd1                   # Production configuration
│       ├── test.psd1                   # Test configuration
│       └── dr.psd1                     # DR configuration
├── config/
│   ├── conditional-access/
│   │   ├── CA001-RequireMFA-AllUsers.json
│   │   ├── CA002-BlockLegacyAuth.json
│   │   ├── CA003-RequireCompliantDevice.json
│   │   └── CA004-SessionTimeout.json
│   ├── intune/
│   │   ├── device-compliance-windows.json
│   │   ├── device-compliance-ios.json
│   │   ├── device-compliance-android.json
│   │   └── app-protection-policy.json
│   ├── defender/
│   │   ├── safe-links-policy.json
│   │   ├── safe-attachments-policy.json
│   │   └── anti-phishing-policy.json
│   ├── purview/
│   │   ├── dlp-pii-policy.json
│   │   ├── retention-policy-email.json
│   │   ├── retention-policy-files.json
│   │   └── sensitivity-labels.json
│   ├── sharepoint/
│   │   ├── hub-sites.json
│   │   ├── site-templates.json
│   │   └── sharing-policy.json
│   └── teams/
│       ├── governance-policy.json
│       ├── meeting-policy.json
│       └── calling-policy.json
└── tests/
    ├── Pester/
    │   ├── M365-Identity.Tests.ps1
    │   ├── M365-Exchange.Tests.ps1
    │   ├── M365-SharePoint.Tests.ps1
    │   └── M365-Teams.Tests.ps1
    └── validation/
        └── Validate-Deployment.ps1
```

## Deployment

### Quick Start

```powershell
# 1. Install prerequisites
.\requirements.ps1

# 2. Connect to Microsoft 365
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Policy.ReadWrite.ConditionalAccess"
Connect-ExchangeOnline
Connect-SPOService -Url https://[tenant]-admin.sharepoint.com

# 3. Deploy to production
.\powershell\scripts\prod\Deploy-M365.ps1 -ConfigPath .\powershell\config\prod.psd1

# 4. Validate deployment
.\tests\validation\Validate-Deployment.ps1
```

### Phased Deployment

1. **Foundation Setup (Week 1-4)**
   ```powershell
   .\powershell\scripts\prod\Configure-Identity.ps1 -ConfigPath .\powershell\config\prod.psd1
   ```
   - Azure AD Connect deployment
   - Single Sign-On configuration
   - Conditional Access policies
   - MFA enrollment

2. **Pilot Migration (Week 4-6)**
   ```powershell
   .\powershell\scripts\prod\Migrate-Email.ps1 -ConfigPath .\powershell\config\prod.psd1 -Pilot
   ```
   - 50 pilot users
   - Hybrid Exchange validation
   - OneDrive Known Folder Move

3. **Production Migration (Week 7-12)**
   ```powershell
   .\powershell\scripts\prod\Migrate-Email.ps1 -ConfigPath .\powershell\config\prod.psd1 -Wave 1
   ```
   - 5 waves of 90 users
   - Weekend migration windows
   - Department-by-department

4. **Teams & Security (Week 12-15)**
   ```powershell
   .\powershell\scripts\prod\Configure-Teams.ps1 -ConfigPath .\powershell\config\prod.psd1
   .\powershell\scripts\prod\Configure-Security.ps1 -ConfigPath .\powershell\config\prod.psd1
   ```
   - Teams deployment
   - Phone System configuration
   - Defender for Office 365
   - Purview DLP policies

## Migration

### Email Migration

```powershell
# Pilot migration (50 users)
.\powershell\scripts\prod\Migrate-Email.ps1 -ConfigPath .\config\prod.psd1 -Pilot

# Production wave 1 (90 users)
.\powershell\scripts\prod\Migrate-Email.ps1 -ConfigPath .\config\prod.psd1 -Wave 1

# Check migration status
.\powershell\scripts\prod\Migrate-Email.ps1 -ConfigPath .\config\prod.psd1 -Status
```

### File Migration

```powershell
# Migrate department files to SharePoint
.\powershell\scripts\prod\Migrate-Files.ps1 -ConfigPath .\config\prod.psd1 -Department "Finance"

# Enable OneDrive Known Folder Move
.\powershell\scripts\prod\Migrate-Files.ps1 -ConfigPath .\config\prod.psd1 -EnableKFM
```

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
Invoke-Pester -Path .\tests\Pester\M365-Identity.Tests.ps1 -Output Detailed
```

### Validate Deployment

```powershell
# Generate deployment report
.\tests\validation\Validate-Deployment.ps1 -OutputFormat HTML -OutputPath .\reports\

# Check specific service
.\tests\validation\Validate-Deployment.ps1 -Service Exchange -Verbose
```

## Compliance Framework Mapping

| Framework | Controls | Automation Component |
|-----------|----------|---------------------|
| SOC 2 | Trust Services Criteria | DLP, retention, access controls |
| GDPR | Data protection | Purview DLP, sensitivity labels |
| HIPAA | Security Rule | Encryption, access controls, audit logging |

## Rollback

Each deployment script supports rollback:

```powershell
# Rollback Conditional Access policies
.\powershell\scripts\prod\Configure-Identity.ps1 -Rollback -BackupPath .\backups\2025-12-04\

# Rollback Exchange configuration
.\powershell\scripts\prod\Configure-Exchange.ps1 -Rollback -BackupPath .\backups\2025-12-04\
```

## Support

For issues or questions:
- Review [Microsoft 365 documentation](https://docs.microsoft.com/en-us/microsoft-365/)
- Check [Exchange Online migration guide](https://docs.microsoft.com/en-us/exchange/mailbox-migration/mailbox-migration)
- Review [Teams deployment guide](https://docs.microsoft.com/en-us/microsoftteams/deploy-overview)
