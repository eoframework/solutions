---
document_title: Implementation Guide
solution_name: Microsoft 365 Enterprise Deployment
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

This Implementation Guide provides comprehensive deployment procedures for the Microsoft 365 Enterprise Deployment. The guide covers M365 tenant configuration, Azure AD Connect setup, email and file migration, Teams deployment, and security hardening for 500 users.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying Exchange Online, SharePoint, Teams, and enterprise security controls.

## Implementation Approach

The implementation follows a five-phase approach over 4 months: Foundation & Pilot (Weeks 1-6), Email & SharePoint (Weeks 7-12), Teams & Phone (Weeks 13-14), Security Hardening (Week 15), and Hypercare (Weeks 16-19).

## Automation Framework Overview

The following tools are used throughout the implementation.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| PowerShell | M365 configuration | `scripts/powershell/` | PowerShell 7+ |
| Azure AD Connect | Identity sync | On-premises server | Windows Server |
| ShareGate | File migration | Migration workstation | Licensed copy |
| Teams Admin Center | Teams configuration | admin.teams.microsoft.com | Global Admin |

## Scope Summary

### In Scope

- M365 E5 tenant provisioning and domain verification
- Azure AD Connect deployment and configuration
- Exchange Online migration (500 users, 250GB)
- SharePoint and OneDrive deployment (5TB)
- Teams with Phone System (150 users) and Audio Conferencing (200 users)
- Defender for Office 365 and Purview configuration
- Intune MDM for 500 endpoints

### Out of Scope

- Network infrastructure modifications
- Hardware procurement
- Custom SharePoint development
- Third-party application migrations

## Timeline Overview

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Foundation Setup & Pilot | Weeks 1-6 | 50 pilot users migrated |
| 2 | Email & SharePoint Deployment | Weeks 7-12 | 500 users migrated |
| 3 | Teams & Phone Deployment | Weeks 13-14 | Teams operational |
| 4 | Security Hardening | Week 15 | Defender/Purview live |
| 5 | Hypercare | Weeks 16-19 | Support transitioned |

# Prerequisites

This section documents all requirements before M365 deployment begins.

## Tool Installation

### Required Tools Checklist

- [ ] **PowerShell 7+** - M365 administration scripts
- [ ] **Microsoft Graph PowerShell SDK** - Azure AD management
- [ ] **Exchange Online PowerShell v3** - Exchange administration
- [ ] **SharePoint Online Management Shell** - SharePoint configuration
- [ ] **Azure AD Connect** - Identity synchronization
- [ ] **ShareGate** - File migration tool

### PowerShell Module Installation

```powershell
# Install Microsoft Graph PowerShell SDK
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Install Exchange Online PowerShell v3
Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force

# Install SharePoint Online Management Shell
Install-Module Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force

# Install Teams PowerShell
Install-Module MicrosoftTeams -Scope CurrentUser -Force

# Verify installation
Get-InstalledModule | Where-Object {$_.Name -like "*Microsoft*" -or $_.Name -like "*Teams*"}
```

## M365 Authentication

### Connect to M365 Services

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Policy.ReadWrite.All"

# Connect to Exchange Online
Connect-ExchangeOnline

# Connect to SharePoint Online
Connect-SPOService -Url https://[tenant]-admin.sharepoint.com

# Connect to Teams
Connect-MicrosoftTeams

# Verify connections
Get-MgContext
Get-OrganizationConfig | Select-Object Name
```

## Prerequisite Validation

Complete this checklist before proceeding.

- [ ] M365 E5 licenses procured for 500 users
- [ ] Custom domain available for verification
- [ ] On-premises Exchange accessible
- [ ] On-premises AD accessible
- [ ] Network bandwidth verified (100 Mbps minimum)
- [ ] Azure AD Connect server provisioned

# Phase 1: Foundation Setup & Pilot

This section covers tenant configuration, Azure AD Connect, and pilot migration.

## M365 Tenant Configuration

### Domain Verification

```powershell
# Navigate to M365 Admin Center
# admin.microsoft.com > Settings > Domains

# Add custom domain
# Follow DNS verification steps:
# 1. Add TXT record to DNS
# 2. Verify domain ownership
# 3. Configure MX, CNAME, TXT records for email

# Verify domain via PowerShell
Get-MgDomain | Select-Object Id, IsVerified
```

### License Assignment

```powershell
# Get available licenses
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits, PrepaidUnits

# Assign M365 E5 license to users
$Users = Import-Csv "users.csv"
$LicenseSku = Get-MgSubscribedSku | Where-Object {$_.SkuPartNumber -eq "SPE_E5"}

foreach ($User in $Users) {
    Set-MgUserLicense -UserId $User.UserPrincipalName -AddLicenses @{SkuId = $LicenseSku.SkuId} -RemoveLicenses @()
}
```

## Azure AD Connect Deployment

### Azure AD Connect Installation

```powershell
# Prerequisites on Azure AD Connect server
# - Windows Server 2016/2019/2022
# - .NET Framework 4.7.2+
# - TLS 1.2 enabled
# - Outbound connectivity to Azure AD

# Download Azure AD Connect
# https://www.microsoft.com/en-us/download/details.aspx?id=47594

# Install with Express Settings for standard deployment
# Or Custom Settings for:
# - Password hash sync (recommended)
# - Seamless SSO
# - Device writeback
```

### Verify Synchronization

```powershell
# Check sync status
Get-ADSyncScheduler

# Force manual sync
Start-ADSyncSyncCycle -PolicyType Delta

# Verify users in Azure AD
Get-MgUser -Filter "onPremisesSyncEnabled eq true" -Top 10 | Select-Object DisplayName, UserPrincipalName
```

## Hybrid Exchange Configuration

### Configure Hybrid Exchange

```powershell
# On-premises Exchange Server
# Run Hybrid Configuration Wizard (HCW)

# Prerequisites:
# - Exchange 2010 SP3 RU30+ / 2013 CU23+ / 2016 CU12+
# - Certificate for mail flow
# - Firewall rules for EWS

# HCW configures:
# - Organization relationship
# - Mail flow connectors
# - OAuth authentication
# - Free/busy sharing
```

### Validate Hybrid Configuration

```powershell
# Test mail flow
Send-MailMessage -From "test@domain.com" -To "clouduser@domain.com" -Subject "Test" -SmtpServer "mail.domain.com"

# Verify organization relationship
Get-OrganizationRelationship | Select-Object Name, TargetOwaUrl
```

## Pilot Migration (50 Users)

### Pilot User Selection

```powershell
# Export pilot user list
$PilotUsers = @(
    "finance1@domain.com",
    "finance2@domain.com",
    # ... 10 users per department across 5 departments
)

# Create migration batch
New-MigrationBatch -Name "Pilot-Wave1" -SourceEndpoint "HybridEndpoint" -CSVData ([System.IO.File]::ReadAllBytes("pilot-users.csv")) -AutoStart
```

### Validate Pilot Migration

```powershell
# Check migration status
Get-MigrationBatch "Pilot-Wave1" | Select-Object Identity, Status, TotalCount, SyncedCount

# Verify mailbox access
Get-EXOMailbox -Identity "pilotuser@domain.com" | Select-Object DisplayName, RecipientTypeDetails, ArchiveStatus
```

# Phase 2: Email & SharePoint Deployment

This section covers production email migration and SharePoint deployment.

## Production Email Migration

### Migration Wave Planning

```powershell
# Wave schedule (90 users per wave)
# Wave 1: Finance (Week 7)
# Wave 2: Sales (Week 8)
# Wave 3: Operations (Week 9)
# Wave 4: Engineering (Week 10)
# Wave 5: Marketing + Remaining (Weeks 11-12)

# Create migration batch per wave
$WaveUsers = Import-Csv "wave1-finance.csv"
New-MigrationBatch -Name "Production-Wave1-Finance" -SourceEndpoint "HybridEndpoint" -CSVData ([System.IO.File]::ReadAllBytes("wave1-finance.csv")) -TargetDeliveryDomain "[tenant].mail.onmicrosoft.com"
```

### Migration Validation

```powershell
# Monitor migration progress
Get-MigrationUser -BatchId "Production-Wave1-Finance" | Group-Object Status

# Validate message counts
Get-EXOMailboxStatistics -Identity "user@domain.com" | Select-Object ItemCount, TotalItemSize
```

## SharePoint Online Deployment

### Create Department Sites

```powershell
# Create SharePoint sites for each department
$Sites = @(
    @{Name="Finance"; Url="https://[tenant].sharepoint.com/sites/Finance"; Template="STS#3"},
    @{Name="Sales"; Url="https://[tenant].sharepoint.com/sites/Sales"; Template="STS#3"},
    @{Name="Operations"; Url="https://[tenant].sharepoint.com/sites/Operations"; Template="STS#3"},
    @{Name="Engineering"; Url="https://[tenant].sharepoint.com/sites/Engineering"; Template="STS#3"},
    @{Name="Marketing"; Url="https://[tenant].sharepoint.com/sites/Marketing"; Template="STS#3"}
)

foreach ($Site in $Sites) {
    New-SPOSite -Title $Site.Name -Url $Site.Url -Template $Site.Template -Owner "admin@domain.com" -StorageQuota 1048576
}
```

### File Migration with ShareGate

```powershell
# ShareGate migration steps:
# 1. Connect to source file server
# 2. Connect to SharePoint Online destination
# 3. Map source folders to SharePoint document libraries
# 4. Configure permission mapping
# 5. Run pre-migration report
# 6. Execute migration with incremental sync
# 7. Validate file counts and permissions
```

## OneDrive Deployment

### Known Folder Move Configuration

```powershell
# Configure Known Folder Move via Intune
# Group Policy settings:
# - Silently move Windows known folders to OneDrive
# - Prevent users from redirecting known folders

# Intune Configuration Profile:
# - Device Configuration > Administrative Templates
# - OneDrive settings for Known Folder Move
```

# Phase 3: Teams & Phone Deployment

This section covers Microsoft Teams and Phone System deployment.

## Teams Deployment

### Teams Governance Policies

```powershell
# Configure Teams policies
# Messaging policy
New-CsTeamsMessagingPolicy -Identity "Standard" -AllowGiphy $true -GiphyRatingType "Moderate"

# Meeting policy
New-CsTeamsMeetingPolicy -Identity "Standard" -AllowMeetNow $true -AllowCloudRecording $true

# Apply policies to users
Grant-CsTeamsMessagingPolicy -Identity "user@domain.com" -PolicyName "Standard"
```

### Create Department Teams

```powershell
# Create Teams for each department
$Teams = @("Finance", "Sales", "Operations", "Engineering", "Marketing")

foreach ($Team in $Teams) {
    New-Team -DisplayName "$Team Team" -Description "$Team department team" -Visibility "Private"
}
```

## Teams Phone System

### Configure Direct Routing

```powershell
# Add SBC to Teams
New-CsOnlinePSTNGateway -Fqdn "sbc.domain.com" -SipSignalingPort 5067 -ForwardCallHistory $true

# Create voice routing policy
New-CsOnlineVoiceRoutingPolicy -Identity "USCalling" -OnlinePstnUsages "USUsage"

# Assign phone numbers to users
Set-CsPhoneNumberAssignment -Identity "user@domain.com" -PhoneNumber "+15551234567" -PhoneNumberType DirectRouting
```

### Audio Conferencing

```powershell
# Enable audio conferencing for 200 users
$AudioUsers = Import-Csv "audio-conferencing-users.csv"

foreach ($User in $AudioUsers) {
    Set-CsOnlineDialInConferencingUser -Identity $User.UserPrincipalName -ServiceNumber "+1-555-123-4567"
}
```

# Phase 4: Security Hardening

This section covers Conditional Access, Defender, and Purview configuration.

## Conditional Access Policies

### MFA for All Users

```powershell
# Create Conditional Access policy for MFA
$Params = @{
    DisplayName = "CA-MFA-AllUsers"
    State = "enabled"
    Conditions = @{
        Applications = @{ IncludeApplications = "All" }
        Users = @{ IncludeUsers = "All"; ExcludeUsers = @("BreakGlassAccount") }
    }
    GrantControls = @{
        BuiltInControls = @("mfa")
        Operator = "OR"
    }
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $Params
```

### Device Compliance Policy

```powershell
# Require compliant devices
$Params = @{
    DisplayName = "CA-RequireCompliantDevice"
    State = "enabled"
    Conditions = @{
        Applications = @{ IncludeApplications = "All" }
        Users = @{ IncludeUsers = "All" }
        Platforms = @{ IncludePlatforms = @("windows", "iOS", "android") }
    }
    GrantControls = @{
        BuiltInControls = @("compliantDevice")
    }
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $Params
```

## Defender for Office 365

### Safe Links Policy

```powershell
# Create Safe Links policy
New-SafeLinksPolicy -Name "Standard SafeLinks" -IsEnabled $true -ScanUrls $true -DeliverMessageAfterScan $true

# Apply to all users
New-SafeLinksRule -Name "Standard SafeLinks Rule" -SafeLinksPolicy "Standard SafeLinks" -RecipientDomainIs "domain.com"
```

### Safe Attachments Policy

```powershell
# Create Safe Attachments policy
New-SafeAttachmentPolicy -Name "Standard SafeAttachments" -Enable $true -Action "DynamicDelivery"

# Apply to all users
New-SafeAttachmentRule -Name "Standard SafeAttachments Rule" -SafeAttachmentPolicy "Standard SafeAttachments" -RecipientDomainIs "domain.com"
```

## Microsoft Purview

### DLP Policies

```powershell
# Create DLP policy for sensitive data
New-DlpCompliancePolicy -Name "Protect PII" -ExchangeLocation All -SharePointLocation All -OneDriveLocation All

# Add DLP rule
New-DlpComplianceRule -Name "Block PII External" -Policy "Protect PII" -ContentContainsSensitiveInformation @{Name="U.S. Social Security Number (SSN)"} -BlockAccess $true -NotifyUser "SiteAdmin"
```

### Retention Policies

```powershell
# Create retention policy for email
New-RetentionCompliancePolicy -Name "Email 7-Year Retention" -ExchangeLocation All

New-RetentionComplianceRule -Name "Retain 7 Years" -Policy "Email 7-Year Retention" -RetentionDuration 2555 -RetentionComplianceAction Keep
```

# Phase 5: Hypercare Support

This section covers post-deployment support and knowledge transfer.

## Daily Health Checks

### Service Health Monitoring

```powershell
# Check M365 service health
Get-MgServiceAnnouncementHealthOverview | Where-Object {$_.Status -ne "ServiceOperational"}

# Check Exchange Online
Get-TransportService | Test-ServiceHealth

# Check Teams
Get-CsOnlineUser | Where-Object {$_.InterpretedUserType -eq "HybridOnlineUser"} | Measure-Object
```

## Knowledge Transfer

### Training Schedule

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | Exchange Online Administration | IT Admin | 3 | Hands-On | None |
| TRN-002 | SharePoint Administration | IT Admin | 3 | Hands-On | None |
| TRN-003 | Teams Administration | IT Admin | 2 | Hands-On | None |
| TRN-004 | Defender for Office 365 | Security Team | 2 | ILT | None |
| TRN-005 | Purview Compliance | Compliance Team | 2 | ILT | None |
| TRN-006 | User Training (End Users) | All Users | 2 | Video | None |

## Support Transition

### Escalation Matrix

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | Password resets, basic questions | IT Help Desk | 15 minutes |
| L2 | M365 configuration, troubleshooting | M365 Admin Team | 1 hour |
| L3 | Complex issues, policy changes | Managed Services | 4 hours |
| L4 | Product issues, escalations | Microsoft Support | Next business day |

# Appendices

## Appendix A: Script Reference

### Script Inventory

<!-- TABLE_CONFIG: widths=[30, 40, 30] -->
| Script | Path | Purpose |
|--------|------|---------|
| Connect-M365Services.ps1 | scripts/powershell/ | Connect to all M365 services |
| New-MigrationBatch.ps1 | scripts/migration/ | Create email migration batch |
| New-SharePointSite.ps1 | scripts/sharepoint/ | Create department SharePoint site |
| Set-ConditionalAccess.ps1 | scripts/security/ | Configure Conditional Access |
| Enable-DefenderPolicies.ps1 | scripts/security/ | Enable Defender policies |

## Appendix B: Troubleshooting Guide

### Common Issues and Resolutions

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| Migration stuck | Network connectivity | Verify hybrid connector, check firewall |
| SSO not working | Azure AD Connect sync | Force sync, verify UPN matching |
| Teams call quality | Network bandwidth | Enable QoS, verify ExpressRoute |
| OneDrive not syncing | Known Folder Move conflict | Reset sync, check client version |

## Appendix C: Contact Information

### Implementation Team

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Project Manager | [NAME] | pm@company.com | [PHONE] |
| M365 Architect | [NAME] | architect@company.com | [PHONE] |
| Migration Lead | [NAME] | migration@company.com | [PHONE] |
| Security Engineer | [NAME] | security@company.com | [PHONE] |
