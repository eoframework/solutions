---
document_title: Implementation Guide
solution_name: Microsoft CMMC GCC High Enclave
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: microsoft
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the Microsoft CMMC GCC High Enclave using the Infrastructure as Code (IaC) automation framework included in this delivery. The guide follows a logical progression from prerequisite validation through CMMC Level 2 certification, with each phase directly referencing the scripts and ARM/Terraform modules in the `delivery/scripts/` folder.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying M365 GCC High, Azure Government resources, CAC/PIV authentication, and Microsoft Sentinel SIEM to achieve CMMC Level 2 certification for 50 CUI-handling users.

## Implementation Approach

The implementation follows a three-phase approach over 6 months: Gap Assessment & Design (Months 1-2), GCC High Deployment (Months 3-4), and CMMC Preparation (Months 5-6). The approach ensures all 110 NIST 800-171 controls are implemented before C3PAO assessment.

## Automation Framework Overview

The following automation technologies are included in this delivery and referenced throughout this guide.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| ARM Templates | Azure Government provisioning | `scripts/arm/` | Azure CLI, Azure Gov subscription |
| Terraform | Infrastructure as Code | `scripts/terraform/` | Terraform 1.6+, Azure CLI |
| PowerShell | M365 GCC High configuration | `scripts/powershell/` | PowerShell 7+, M365 modules |
| Azure Policy | Compliance enforcement | `scripts/policies/` | Azure Government access |
| Sentinel Playbooks | Incident response automation | `scripts/sentinel/` | Sentinel workspace |

## Scope Summary

### In Scope

The following components are deployed using the automation framework.

- M365 GCC High tenant provisioning and configuration
- Azure Government subscription and resource deployment
- CAC/PIV smart card authentication integration
- Microsoft Sentinel SIEM with 100GB/month ingestion
- Defender for Cloud security posture management
- User migration from commercial M365 (50 users)

### Out of Scope

The following items are excluded from automated deployment.

- On-premises infrastructure modifications (client responsibility)
- Physical security controls for client facilities
- Background check processing for personnel security
- C3PAO engagement and assessment scheduling

## Timeline Overview

The implementation follows a three-phase deployment approach with validation gates at each stage.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Gap Assessment, SSP drafting, design finalization | Months 1-2 | NIST 800-171 gap assessment complete |
| 2 | GCC High deployment, user migration, Sentinel setup | Months 3-4 | 50 users migrated, Sentinel operational |
| 3 | C3PAO assessment, certification, hypercare | Months 5-6 | CMMC Level 2 certified |

# Prerequisites

This section documents all requirements that must be satisfied before GCC High deployment can begin. The prerequisite validation script automates verification of these requirements.

## Tool Installation

The following tools must be installed on the deployment workstation before proceeding.

### Required Tools Checklist

Use the following checklist to verify all required tools are installed.

- [ ] **Azure CLI** >= 2.50.0 - Azure Government authentication and management
- [ ] **PowerShell** >= 7.3 - M365 GCC High administration scripts
- [ ] **Terraform** >= 1.6.0 - Infrastructure as Code deployment
- [ ] **Microsoft Graph PowerShell SDK** - Azure AD and M365 management
- [ ] **Exchange Online PowerShell v3** - Exchange administration
- [ ] **Git** - Source code management for IaC templates

### Azure CLI Installation

Install Azure CLI and configure for Azure Government.

```bash
# macOS (using Homebrew)
brew install azure-cli

# Windows (using Chocolatey)
choco install azure-cli

# Linux (Debian/Ubuntu)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Configure for Azure Government
az cloud set --name AzureUSGovernment

# Verify installation
az --version
```

### PowerShell Module Installation

Install required PowerShell modules for M365 GCC High administration.

```powershell
# Install Microsoft Graph PowerShell SDK
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Install Exchange Online PowerShell v3
Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force

# Install Azure AD Preview (for CAC/PIV configuration)
Install-Module AzureADPreview -Scope CurrentUser -Force

# Install Microsoft 365 Defender module
Install-Module Microsoft.Graph.Security -Scope CurrentUser -Force

# Verify installation
Get-InstalledModule | Where-Object {$_.Name -like "*Graph*" -or $_.Name -like "*Exchange*"}
```

## Azure Government Configuration

Configure authentication for Azure Government before running Terraform or ARM deployments.

### Azure Government Authentication

Configure Azure CLI for Azure Government and authenticate.

```bash
# Set cloud to Azure Government
az cloud set --name AzureUSGovernment

# Login to Azure Government
az login --tenant [GOV-TENANT-ID]

# Set active subscription
az account set --subscription [GOV-SUBSCRIPTION-ID]

# Verify authentication
az account show
```

### M365 GCC High Authentication

Connect to M365 GCC High PowerShell modules.

```powershell
# Connect to Microsoft Graph GCC High
Connect-MgGraph -Environment USGov -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Policy.ReadWrite.All"

# Connect to Exchange Online GCC High
Connect-ExchangeOnline -ExchangeEnvironmentName O365USGovGCCHigh

# Verify connections
Get-MgContext
Get-OrganizationConfig | Select-Object Name
```

## Prerequisite Validation

Run the prerequisite validation script to verify all requirements are met.

```bash
# Navigate to scripts directory
cd delivery/scripts/

# Run prerequisite validation
./validate-prerequisites.sh

# Or manually verify each component
az --version
pwsh --version
terraform version
```

### Validation Checklist

Complete this checklist before proceeding to environment setup.

- [ ] Azure CLI installed and configured for Azure Government
- [ ] PowerShell 7+ installed with required modules
- [ ] Terraform 1.6+ installed and accessible in PATH
- [ ] Azure Government subscription active and accessible
- [ ] M365 GCC High tenant provisioned by Microsoft
- [ ] ExpressRoute circuit ordered (4-week lead time)
- [ ] CAC/PIV smart cards validated for all 50 users

# Phase 1: Gap Assessment & Design

This section covers the NIST 800-171 gap assessment and System Security Plan (SSP) development during Months 1-2.

## NIST 800-171 Gap Assessment

Execute the gap assessment to identify control implementation requirements.

### Assessment Scope

The gap assessment evaluates all 110 NIST 800-171 controls across 14 families.

```bash
# Navigate to assessment scripts
cd delivery/scripts/assessment/

# Run automated gap assessment
./run-gap-assessment.ps1 -TenantId [TENANT-ID] -OutputPath ./reports/

# Generate SPRS score baseline
./calculate-sprs-score.ps1 -AssessmentResults ./reports/gap-assessment.json
```

### Control Family Assessment

Assess each control family against current state.

<!-- TABLE_CONFIG: widths=[20, 15, 30, 35] -->
| Control Family | Controls | Assessment Method | Documentation Required |
|----------------|----------|-------------------|----------------------|
| Access Control (AC) | 22 | Azure AD configuration review | RBAC policies, Conditional Access |
| Awareness & Training (AT) | 3 | Training program review | Training records, completion reports |
| Audit & Accountability (AU) | 9 | Log management review | SIEM configuration, retention policies |
| Configuration Mgmt (CM) | 9 | Baseline configuration review | Azure Policy, compliance reports |
| Identification & Auth (IA) | 11 | Authentication mechanism review | CAC/PIV configuration, MFA policies |
| Incident Response (IR) | 3 | IR plan review | Playbooks, escalation procedures |
| Maintenance (MA) | 6 | Change management review | Patch management, maintenance logs |
| Media Protection (MP) | 9 | Data protection review | Encryption policies, DLP configuration |
| Physical Protection (PE) | 6 | Facility security review | Client attestation required |
| Personnel Security (PS) | 2 | HR process review | Background check procedures |
| Risk Assessment (RA) | 3 | Risk management review | Vulnerability scan reports |
| Security Assessment (CA) | 4 | Assessment program review | POA&M tracking procedures |
| System & Comm Protection (SC) | 16 | Network security review | Encryption, boundary protection |
| System & Info Integrity (SI) | 7 | Malware protection review | Defender configuration, patch status |

## System Security Plan Development

Develop the SSP documenting control implementations for C3PAO assessment.

### SSP Structure

The SSP follows the NIST 800-171 format with the following sections.

```powershell
# Navigate to SSP templates
cd delivery/docs/ssp-templates/

# Generate SSP skeleton from gap assessment
./generate-ssp.ps1 -GapAssessment ./reports/gap-assessment.json -OutputPath ./ssp/

# Populate control narratives
./populate-control-narratives.ps1 -SSPPath ./ssp/ -ControlMappings ./mappings/
```

### Control Narrative Template

Document each control implementation using this template structure.

```
Control ID: [NIST 800-171 Control Number]
Control Name: [Control Title]
Implementation Status: [Implemented | Partially Implemented | Planned | Not Applicable]
Responsible Party: [Client | Vendor | Shared]

Implementation Description:
[Detailed narrative of how the control is implemented in the GCC High environment]

Evidence Artifacts:
- [List of evidence documents, screenshots, configuration exports]

Testing Procedures:
[Procedures to validate control effectiveness]
```

# Phase 2: GCC High Deployment

This section covers the M365 GCC High and Azure Government deployment during Months 3-4.

## M365 GCC High Tenant Configuration

Configure the GCC High tenant after Microsoft provisioning is complete.

### Tenant Setup Directory Structure

The tenant configuration automation is located in `delivery/scripts/m365/`.

```
delivery/scripts/m365/
├── tenant-setup.ps1           # Primary tenant configuration
├── conditional-access.ps1     # Conditional Access policies
├── sensitivity-labels.ps1     # CUI classification labels
├── dlp-policies.ps1          # Data Loss Prevention policies
├── exchange-config.ps1       # Exchange Online settings
├── sharepoint-config.ps1     # SharePoint Online settings
└── config/
    ├── ca-policies.json      # Conditional Access definitions
    ├── labels.json           # Sensitivity label definitions
    └── dlp-rules.json        # DLP policy definitions
```

### Tenant Configuration Execution

Execute the tenant configuration scripts in sequence.

```powershell
# Navigate to M365 scripts
cd delivery/scripts/m365/

# Connect to GCC High tenant
Connect-MgGraph -Environment USGov -TenantId [GOV-TENANT-ID]

# Execute tenant setup
./tenant-setup.ps1 -ConfigPath ./config/tenant-config.json

# Configure Conditional Access for CAC/PIV
./conditional-access.ps1 -ConfigPath ./config/ca-policies.json

# Deploy sensitivity labels for CUI
./sensitivity-labels.ps1 -ConfigPath ./config/labels.json

# Configure DLP policies
./dlp-policies.ps1 -ConfigPath ./config/dlp-rules.json
```

### Conditional Access Configuration

Configure Conditional Access policies for CAC/PIV authentication.

```powershell
# CAC/PIV authentication policy
$CACPolicy = @{
    DisplayName = "Require CAC/PIV for CUI Access"
    State = "enabled"
    Conditions = @{
        Applications = @{ IncludeApplications = "All" }
        Users = @{ IncludeGroups = "[CUI-USERS-GROUP-ID]" }
    }
    GrantControls = @{
        BuiltInControls = @("mfa", "compliantDevice")
        AuthenticationStrength = "phishingResistant"
    }
}

# Create policy
New-MgIdentityConditionalAccessPolicy -BodyParameter $CACPolicy
```

### Tenant Configuration Validation

Verify tenant configuration completed successfully.

```powershell
# Verify Conditional Access policies
Get-MgIdentityConditionalAccessPolicy | Format-Table DisplayName, State

# Verify sensitivity labels published
Get-Label | Format-Table DisplayName, Priority, IsActive

# Verify DLP policies enabled
Get-DlpCompliancePolicy | Format-Table Name, Mode, Enabled

# Verify Exchange configuration
Get-TransportRule | Format-Table Name, State
```

## Azure Government Deployment

Deploy Azure Government resources using Terraform.

### Terraform Directory Structure

The Terraform automation follows a modular structure.

```
delivery/scripts/terraform/
├── environments/
│   └── production/
│       ├── terraform.tf        # Backend configuration
│       ├── providers.tf        # Azure Government provider
│       ├── main.tf            # Resource deployment
│       ├── variables.tf       # Variable definitions
│       ├── outputs.tf         # Output values
│       └── config/
│           ├── project.tfvars # Project settings
│           └── network.tfvars # Network configuration
├── modules/
│   ├── networking/            # VNet, subnets, NSGs
│   ├── compute/               # VMs, availability sets
│   ├── security/              # Key Vault, encryption
│   └── monitoring/            # Sentinel, Log Analytics
└── scripts/
    └── init-backend.sh        # Backend initialization
```

### Backend State Configuration

Initialize Terraform backend in Azure Government.

```bash
# Navigate to Terraform scripts
cd delivery/scripts/terraform/scripts/

# Initialize backend storage
./init-backend.sh cmmc-enclave usgovvirginia production

# Expected output:
# - Storage account created in Azure Government
# - Container created for state files
# - State locking enabled via blob lease
```

### Environment Configuration

Configure environment-specific settings before deployment.

```bash
# Navigate to production environment
cd delivery/scripts/terraform/environments/production/

# Edit project configuration
vim config/project.tfvars
```

Configure the following in `config/project.tfvars`:

```hcl
# Project Identity
project_name     = "cmmc-enclave"
environment      = "production"
owner_email      = "isso@client.com"
cmmc_level       = "Level2"

# Azure Government Configuration
azure_subscription_id = "[GOV-SUBSCRIPTION-ID]"
azure_tenant_id       = "[GOV-TENANT-ID]"
azure_location        = "usgovvirginia"

# Network Configuration
vnet_cidr             = "10.100.0.0/16"
management_subnet     = "10.100.1.0/24"
cui_workload_subnet   = "10.100.10.0/24"
private_endpoint_subnet = "10.100.20.0/24"
```

### Infrastructure Deployment

Execute Terraform deployment for Azure Government resources.

```bash
# Navigate to production environment
cd delivery/scripts/terraform/environments/production/

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -var-file=config/project.tfvars -out=tfplan

# Review plan output for:
# - azurerm_resource_group.cmmc
# - azurerm_virtual_network.cmmc
# - azurerm_subnet.management
# - azurerm_subnet.cui_workload
# - azurerm_key_vault.cmmc
# - azurerm_log_analytics_workspace.sentinel

# Apply deployment
terraform apply tfplan
```

### Deployment Validation

Verify Azure Government deployment completed successfully.

```bash
# Verify resource group created
az group show --name prod-cmmc-security-rg --output table

# Verify VNet created
az network vnet show --resource-group prod-cmmc-security-rg --name prod-cmmc-vnet --output table

# Verify Key Vault created with FIPS 140-2
az keyvault show --name [KEY-VAULT-NAME] --query properties.sku

# Verify Log Analytics workspace
az monitor log-analytics workspace show \
  --resource-group prod-cmmc-security-rg \
  --workspace-name cmmc-sentinel-workspace \
  --output table
```

## Microsoft Sentinel Deployment

Deploy and configure Microsoft Sentinel for SIEM capabilities.

### Sentinel Configuration

Enable Sentinel and configure data connectors.

```powershell
# Navigate to Sentinel scripts
cd delivery/scripts/sentinel/

# Enable Sentinel on Log Analytics workspace
./enable-sentinel.ps1 -WorkspaceName "cmmc-sentinel-workspace" -ResourceGroup "prod-cmmc-security-rg"

# Configure data connectors
./configure-connectors.ps1 -ConfigPath ./config/connectors.json

# Deploy analytics rules
./deploy-analytics-rules.ps1 -RulesPath ./rules/

# Deploy incident response playbooks
./deploy-playbooks.ps1 -PlaybooksPath ./playbooks/
```

### Data Connector Configuration

Enable required data connectors for NIST 800-171 AU controls.

```powershell
# Required data connectors for CMMC compliance
$Connectors = @(
    "AzureActiveDirectory",      # Azure AD sign-in and audit logs
    "Office365",                 # M365 unified audit logs
    "MicrosoftDefenderAdvancedThreatProtection",  # Defender for Endpoint
    "MicrosoftCloudAppSecurity", # Defender for Cloud Apps
    "AzureActivity",             # Azure resource activity
    "SecurityEvents"             # Windows security events
)

foreach ($Connector in $Connectors) {
    Enable-AzSentinelDataConnector -WorkspaceName "cmmc-sentinel-workspace" `
        -ResourceGroupName "prod-cmmc-security-rg" `
        -Kind $Connector
}
```

### Sentinel Validation

Verify Sentinel deployment and data ingestion.

```powershell
# Verify Sentinel enabled
Get-AzSentinel -WorkspaceName "cmmc-sentinel-workspace" -ResourceGroupName "prod-cmmc-security-rg"

# Verify data connectors enabled
Get-AzSentinelDataConnector -WorkspaceName "cmmc-sentinel-workspace" -ResourceGroupName "prod-cmmc-security-rg"

# Check log ingestion (allow 15-30 minutes for initial data)
$Query = "union * | summarize count() by Type | order by count_ desc"
Invoke-AzOperationalInsightsQuery -WorkspaceId [WORKSPACE-ID] -Query $Query
```

## User Migration

Migrate 50 users from commercial M365 to GCC High.

### Migration Preparation

Prepare for user migration with pilot validation.

```powershell
# Navigate to migration scripts
cd delivery/scripts/migration/

# Validate source mailboxes
./validate-source-mailboxes.ps1 -UserList ./config/users.csv

# Generate migration batch files
./create-migration-batches.ps1 -UserList ./config/users.csv -BatchSize 10

# Output:
# - batch-1-pilot.csv (10 users)
# - batch-2-wave1.csv (20 users)
# - batch-3-wave2.csv (20 users)
```

### Pilot Migration (Week 1)

Execute pilot migration with 10 users.

```powershell
# Execute pilot migration
./execute-migration.ps1 -Batch "batch-1-pilot.csv" -MigrationEndpoint [GCC-HIGH-ENDPOINT]

# Monitor migration status
./monitor-migration.ps1 -Batch "batch-1-pilot"

# Validate pilot users
./validate-migration.ps1 -Batch "batch-1-pilot.csv"
```

### Production Migration (Weeks 2-4)

Execute remaining user migrations after pilot validation.

```powershell
# Wave 1 migration (20 users)
./execute-migration.ps1 -Batch "batch-2-wave1.csv" -MigrationEndpoint [GCC-HIGH-ENDPOINT]

# Wave 2 migration (20 users)
./execute-migration.ps1 -Batch "batch-3-wave2.csv" -MigrationEndpoint [GCC-HIGH-ENDPOINT]

# Final validation
./validate-migration.ps1 -Batch "all-users.csv" -GenerateReport
```

### CAC/PIV Enrollment

Configure CAC/PIV authentication for all migrated users.

```powershell
# Navigate to CAC scripts
cd delivery/scripts/cac-piv/

# Import user certificate mappings
./import-certificate-mappings.ps1 -MappingFile ./config/cac-upn-mappings.csv

# Configure certificate-based authentication
./configure-cba.ps1 -TenantId [GOV-TENANT-ID]

# Validate CAC authentication
./test-cac-auth.ps1 -TestUser "pilot-user@client.gov"
```

# Phase 3: CMMC Preparation

This section covers C3PAO assessment preparation and certification activities during Months 5-6.

## Pre-Assessment Validation

Validate all controls before C3PAO engagement.

### Automated Control Validation

Run automated control validation scripts.

```bash
# Navigate to validation scripts
cd delivery/scripts/validation/

# Run comprehensive control validation
./validate-all-controls.ps1 -OutputPath ./reports/

# Generate compliance evidence package
./generate-evidence-package.ps1 -ControlFamily "ALL" -OutputPath ./evidence/

# Calculate final SPRS score
./calculate-sprs-score.ps1 -ValidationResults ./reports/validation-results.json
```

### Control Validation Checklist

Complete this checklist before C3PAO assessment.

- [ ] All 110 NIST 800-171 controls documented in SSP
- [ ] Evidence artifacts collected for each control
- [ ] SPRS score calculated and submitted to SPRS portal
- [ ] Sentinel alerting operational with <15 min response
- [ ] All 50 users migrated and authenticating via CAC/PIV
- [ ] POA&M empty (no open items)

## C3PAO Assessment Support

Support C3PAO during assessment week.

### Assessment Environment Access

Provide C3PAO with required access.

```powershell
# Create C3PAO read-only accounts
./create-assessor-accounts.ps1 -AssessorEmail "assessor@c3pao.com" -AccessLevel "ReadOnly"

# Grant access to compliance dashboards
./grant-dashboard-access.ps1 -UserEmail "assessor@c3pao.com"

# Generate system inventory export
./export-system-inventory.ps1 -OutputPath ./evidence/system-inventory.xlsx
```

### Evidence Package Structure

Organize evidence for C3PAO review.

```
delivery/evidence/
├── AC/                        # Access Control evidence
│   ├── ac-1-policy.pdf       # Access control policy
│   ├── ac-2-account-management.xlsx  # Account inventory
│   └── ac-3-conditional-access.png   # CA policy screenshots
├── AU/                        # Audit evidence
│   ├── au-2-audit-events.xlsx # Auditable events
│   ├── au-6-sentinel-config.png # SIEM configuration
│   └── au-11-retention-policy.pdf # Log retention
├── IA/                        # Identification evidence
│   ├── ia-2-cac-config.pdf   # CAC/PIV configuration
│   └── ia-2-1-mfa-policy.png # MFA enforcement
└── SSP/
    └── system-security-plan.docx # Complete SSP
```

# Operational Handover

This section covers the transition from implementation to ongoing operations.

## Monitoring Dashboard Access

Provide access to operational dashboards.

### Sentinel Dashboard

Access the Sentinel SIEM dashboard for security monitoring.

```powershell
# Get Sentinel dashboard URL
$WorkspaceId = (Get-AzOperationalInsightsWorkspace -Name "cmmc-sentinel-workspace" -ResourceGroupName "prod-cmmc-security-rg").CustomerId
$DashboardUrl = "https://portal.azure.us/#blade/Microsoft_Azure_Security_Insights/MainMenuBlade/0/subscriptionId/[SUB-ID]/resourceGroup/prod-cmmc-security-rg/workspaceName/cmmc-sentinel-workspace"
Write-Output "Sentinel Dashboard: $DashboardUrl"
```

### Key Metrics to Monitor

The following metrics should be monitored continuously.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Failed CAC Logins | >5 in 10 min | Critical | Account lockout review |
| CUI Access Anomaly | Deviation >2 std dev | High | User activity investigation |
| Compliance Score | <95% | High | Control remediation |
| Sentinel Alert Response | >15 min MTTR | Warning | SOC process review |

## Training Program

Deliver training to client operations team.

### Training Schedule

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | GCC High Architecture | ISSO/ISSM | 2 | ILT | None |
| TRN-002 | Sentinel SIEM Operations | SOC Team | 3 | Hands-On | TRN-001 |
| TRN-003 | CAC/PIV Troubleshooting | IT Support | 2 | Hands-On | None |
| TRN-004 | Compliance Monitoring | ISSO | 2 | ILT | TRN-001 |
| TRN-005 | C3PAO Reassessment Prep | ISSO/ISSM | 2 | ILT | TRN-004 |

## Support Transition

Transition support responsibilities to client team.

### Support Model

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | CAC authentication issues, password resets | IT Help Desk | 15 minutes |
| L2 | Sentinel alert triage, policy exceptions | Security Team | 1 hour |
| L3 | Complex security incidents, config changes | Vendor Support | 4 hours |
| L4 | Architecture changes, C3PAO support | Vendor Engineering | Next business day |

# Appendices

## Appendix A: Script Reference

This appendix provides a reference to all automation scripts.

### Script Inventory

<!-- TABLE_CONFIG: widths=[30, 40, 30] -->
| Script | Path | Purpose |
|--------|------|---------|
| validate-prerequisites.sh | scripts/ | Verify tool installation |
| tenant-setup.ps1 | scripts/m365/ | GCC High tenant configuration |
| conditional-access.ps1 | scripts/m365/ | Conditional Access policies |
| init-backend.sh | scripts/terraform/scripts/ | Terraform backend setup |
| enable-sentinel.ps1 | scripts/sentinel/ | Sentinel enablement |
| execute-migration.ps1 | scripts/migration/ | User migration execution |
| validate-all-controls.ps1 | scripts/validation/ | NIST 800-171 validation |

## Appendix B: Troubleshooting Guide

### Common Issues and Resolutions

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| CAC authentication fails | Certificate expired or not mapped | Verify certificate in Azure AD, check UPN mapping |
| Sentinel not ingesting logs | Data connector not enabled | Re-enable connector, check permissions |
| Migration stuck | Network connectivity | Verify ExpressRoute, check migration endpoint |
| Conditional Access blocking | Policy misconfiguration | Review CA policy conditions, check exclusions |

### Diagnostic Commands

```powershell
# Check Azure AD sign-in logs for CAC failures
Get-MgAuditLogSignIn -Filter "authenticationDetails/any(a:a/authenticationMethod eq 'X509Certificate')" -Top 50

# Check Sentinel data ingestion
Invoke-AzOperationalInsightsQuery -WorkspaceId [WORKSPACE-ID] -Query "Heartbeat | summarize count() by Computer"

# Check migration status
Get-MigrationBatch | Format-Table Identity, Status, TotalCount, SyncedCount

# Check Conditional Access policy evaluation
Get-MgIdentityConditionalAccessPolicy | Format-Table DisplayName, State, Conditions
```

## Appendix C: Contact Information

### Implementation Team

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Project Manager | [NAME] | pm@company.com | [PHONE] |
| Security Architect | [NAME] | architect@company.com | [PHONE] |
| M365 Engineer | [NAME] | m365@company.com | [PHONE] |
| Azure Engineer | [NAME] | azure@company.com | [PHONE] |

### Vendor Support

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Support Level | Contact | Email | Response |
|---------------|---------|-------|----------|
| Microsoft GCC High | Premier Support | [Portal] | 4 hours |
| C3PAO | [C3PAO Name] | support@c3pao.com | Next business day |
| Consulting | On-Call | oncall@company.com | Immediate |
