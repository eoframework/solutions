---
document_title: Detailed Design Document
solution_name: Google Workspace Migration
document_version: "1.0"
author: Solution Architect
last_updated: 2025-11-27
technology_provider: google
client_name: "[Client Name]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

## Document Purpose

This Detailed Design Document provides comprehensive technical specifications for the Google Workspace Business Plus migration. It defines the architecture, security controls, identity integration, and migration approach required to transition 500 users from on-premises Exchange 2016 to Google Workspace with zero data loss.

## Scope and Audience

This document is intended for technical architects, identity engineers, security specialists, and migration teams responsible for implementing the Google Workspace deployment. It covers tenant configuration, Azure AD SSO integration, directory sync, security policies, and wave-based migration for 500 users across 5 departments.

## Assumptions

The following assumptions apply to this design:

- Client has procured 500 Google Workspace Business Plus licenses
- Azure AD is available and configured for SAML SSO integration
- Exchange 2016 Server administrative access is available for GWMT migration
- Network connectivity to Google services is unrestricted (ports 443, 587)
- 4-week coexistence period is acceptable during migration waves

## References

<!-- TABLE_CONFIG: widths=[30, 50, 20] -->
| Document | Description | Version |
|----------|-------------|---------|
| Statement of Work | Scope, timeline, deliverables for Workspace migration | 1.0 |
| Solution Briefing | Architecture overview and business value proposition | 1.0 |
| Google Workspace Admin Guide | Configuration and management procedures | Latest |
| Azure AD SAML Integration Guide | SSO configuration with Google Workspace | Latest |

# Business Context

## Business Drivers

The Google Workspace migration addresses critical business needs identified during discovery:

- **Aging Exchange Infrastructure**: On-premises Exchange 2016 approaching end of support, requiring infrastructure refresh or migration. Cloud-based Google Workspace eliminates hardware and software maintenance.
- **Limited Collaboration**: Exchange and file servers lack real-time collaboration, with documents emailed as attachments creating version control issues. Google Workspace enables simultaneous editing.
- **Mobile Access Gaps**: Current mobile access is limited and difficult to secure. Google Workspace provides native mobile apps with comprehensive MDM controls.
- **Storage Constraints**: File server capacity limitations and backup challenges. Google Drive provides 5 TB per user with automatic redundancy.
- **Compliance Requirements**: 7-year email retention requirements difficult to meet with current archive solution. Google Vault provides unified retention and eDiscovery.

## Business Outcomes

The migration delivers measurable business value:

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Outcome | Target | Measurement |
|---------|--------|-------------|
| Email Migration | 100% of 500 mailboxes migrated | Zero data loss validation |
| File Migration | 100% of 3 TB files migrated | Permission and structure preserved |
| User Productivity | 90% adoption within 30 days | Active user metrics in Admin Console |
| Mobile Enablement | 300+ managed devices enrolled | MDM enrollment dashboard |
| Compliance | 7-year retention enforced | Vault retention rule verification |
| Training Completion | 95%+ attendance | Training session records |

## Service Level Agreements

The Google Workspace platform targets the following SLAs:

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Service | Availability | Latency | Recovery |
|---------|--------------|---------|----------|
| Gmail | 99.9% SLA | <30 sec internal delivery | Google-managed |
| Google Drive | 99.9% SLA | <5 min sync | Google-managed |
| Google Meet | 99.9% SLA | <5 sec join time | Google-managed |
| Admin Console | 99.9% SLA | Real-time | Google-managed |

## Compliance Requirements

The migration supports the following compliance frameworks:

- **Data Retention**: 7-year email and file retention through Google Vault with legal hold capabilities
- **Data Loss Prevention**: PII and financial data detection with automatic blocking for external sharing
- **Access Logging**: Complete audit trail for admin and user activities exportable for compliance review
- **Device Security**: Managed device requirements with encryption, passcode, and remote wipe capabilities

## Success Criteria

The implementation succeeds when the following criteria are met:

- 500 mailboxes migrated with zero data loss (2.5 TB email)
- 3 TB of files migrated with permissions preserved
- Azure AD SSO operational for all users with 2-Step Verification enforced
- DLP policies detecting and blocking sensitive data patterns
- 7-year retention rules active in Google Vault
- IT team self-sufficient on administration within 30 days

# Current-State Assessment

## Existing Infrastructure

### Email Environment

The current email environment consists of:

- **Exchange Server 2016**: On-premises deployment with 500 mailboxes
- **Total Mailbox Data**: 2.5 TB across all mailboxes (average 5 GB per user)
- **Distribution Lists**: 150 distribution lists requiring conversion to Google Groups
- **Calendar Data**: Appointments, recurring meetings, and room reservations
- **Public Folders**: Limited usage, to be evaluated for migration

### File Storage Environment

The current file storage consists of:

- **File Servers**: Network shares with 3 TB of department and user data
- **Access Controls**: NTFS permissions mapped to Active Directory security groups
- **Folder Structure**: Department-based hierarchy with personal home drives
- **Backup Strategy**: Nightly incremental, weekly full backups

### Identity Environment

The current identity infrastructure includes:

- **Active Directory**: On-premises directory with 500+ user accounts
- **Azure AD**: Cloud identity provider for SSO to other applications
- **Authentication**: Password-based with no MFA enforcement
- **Group Structure**: Security and distribution groups for access control

## Current-State Challenges

### Technical Challenges

- Exchange 2016 approaching end of extended support
- File server capacity limitations requiring hardware refresh
- No real-time collaboration on documents
- Limited mobile access to email and files
- Complex backup and disaster recovery procedures

### Operational Challenges

- Manual processes for user onboarding and offboarding
- Difficulty enforcing consistent security policies
- Limited visibility into data sharing and access patterns
- No unified retention or eDiscovery capability

# Solution Architecture

## Architecture Overview

The Google Workspace migration architecture provides a complete cloud-based collaboration platform for 500 users. The solution integrates Azure AD for federated identity, implements GCDS for directory synchronization, and deploys comprehensive security controls including DLP, Vault retention, and MDM.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Google Workspace Migration Architecture                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────┐                      ┌────────────────────────────────┐ │
│  │  Azure AD      │◄────SAML 2.0 SSO────►│  Google Workspace              │ │
│  │  (Identity)    │                       │  Business Plus                 │ │
│  └───────┬────────┘                       │                                │ │
│          │                                │  ├─ Gmail (500 mailboxes)      │ │
│          │ Directory                      │  ├─ Drive (5 TB/user)          │ │
│          │ Services                       │  ├─ Meet (Recording enabled)   │ │
│          ▼                                │  ├─ Chat (Spaces enabled)      │ │
│  ┌────────────────┐     GCDS Sync        │  └─ Calendar                   │ │
│  │  Active        │◄────(4-hour)─────────►│                                │ │
│  │  Directory     │                       └────────────────────────────────┘ │
│  └───────┬────────┘                                                          │
│          │                                                                   │
│          ▼                                                                   │
│  ┌────────────────┐                      ┌────────────────────────────────┐ │
│  │  Exchange 2016 │──────GWMT───────────►│  Migration (2.5 TB email)      │ │
│  │  (Source)      │      Migration        │  + 3 TB files                  │ │
│  └────────────────┘                       └────────────────────────────────┘ │
│                                                                              │
│  Security Controls:                                                          │
│  ├─ 2-Step Verification (Enforced)                                          │
│  ├─ DLP Policies (PII, Financial data)                                      │
│  ├─ Google Vault (7-year retention)                                         │
│  └─ MDM (Advanced management, 300 devices)                                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Architecture Components

### Identity Layer

- **Azure AD**: Primary identity provider for SAML-based SSO
- **GCDS**: Google Cloud Directory Sync for user provisioning
- **2SV**: 2-Step Verification enforced for all users

### Application Layer

- **Gmail**: Enterprise email with 30 GB per user
- **Google Drive**: 5 TB pooled storage with Shared Drives
- **Google Meet**: Video conferencing with recording
- **Google Chat**: Team messaging with Spaces
- **Google Calendar**: Scheduling with resource booking

### Security Layer

- **DLP**: Data Loss Prevention for PII and financial data
- **Vault**: 7-year retention with legal hold capabilities
- **MDM**: Advanced mobile device management
- **Audit**: Comprehensive logging and alerting

### Migration Layer

- **GWMT**: Google Workspace Migration Tool for Exchange
- **File Migration**: Preserving permissions and structure
- **Coexistence**: 4-week parallel operation period

## Architecture Diagram

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

# Security & Compliance

## Security Architecture

### Identity Security

The identity security model leverages Azure AD federation:

- **SAML 2.0 SSO**: Azure AD as primary identity provider for all Google Workspace authentication
- **2-Step Verification**: Enforced for all 500 users with flexible method options (phone, security key, authenticator)
- **Session Management**: 14-day maximum session duration with re-authentication on sensitive actions
- **Conditional Access**: Azure AD policies can enforce device compliance before Google access

### Data Protection

Data protection controls include multiple layers:

- **Encryption at Rest**: AES-256 encryption for all data stored in Google services
- **Encryption in Transit**: TLS 1.3 for all data transmission
- **DLP Policies**: Automated detection of PII, financial data, and custom patterns
- **External Sharing Controls**: Allowlisted domains only for Drive sharing
- **Vault Retention**: 7-year retention with legal hold capabilities

### Network Security

Network controls for Google Workspace access:

- **Context-Aware Access**: Can restrict access based on device state, IP, and location
- **API Access Control**: OAuth scopes limited to approved applications
- **Admin API Security**: Super Admin actions require 2SV and audit logging

## Data Loss Prevention Configuration

DLP policies protect sensitive data across Gmail and Drive:

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Policy Name | Detection Pattern | Action | Scope |
|-------------|-------------------|--------|-------|
| PII Protection | SSN, Driver License | Warn and Block | Gmail, Drive |
| Financial Data | Credit Card, Bank Account | Block External | All Apps |
| Healthcare Data | PHI, Medical Records | Block and Alert | Gmail, Drive |
| Confidential Markers | Keywords: CONFIDENTIAL, INTERNAL | Warn | Drive |

## Mobile Device Security

Mobile Device Management ensures device compliance:

- **Enrollment Required**: Corporate data access requires MDM enrollment
- **Passcode Policy**: 6+ character passcode required
- **Encryption Required**: Device encryption mandatory for enrollment
- **Remote Wipe**: Enabled for lost or stolen devices
- **App Management**: Google Workspace apps must be managed versions

## Compliance Controls

### Google Vault Configuration

Vault provides retention and eDiscovery:

- **Email Retention**: 7-year (2555 days) retention for all Gmail data
- **Drive Retention**: 7-year retention for all Drive files including Shared Drives
- **Meet Retention**: 7-year retention for recordings and attendance reports
- **Legal Hold**: Indefinite preservation override for litigation matters

### Audit Logging

Comprehensive audit logging captures:

- **Admin Activity**: All Admin Console changes with administrator identity
- **User Activity**: Login, file access, sharing, and deletion events
- **Security Events**: Failed logins, suspicious activity, device events
- **Data Export**: BigQuery export available for long-term analysis

# Data Architecture

## Data Migration Strategy

### Email Migration Approach

Email migration uses Google Workspace Migration Tool (GWMT):

- **Source Connection**: Service account access to Exchange 2016
- **Migration Type**: Full migration including all mail, calendar, and contacts
- **Date Range**: All historical data, no date cutoff
- **Batch Processing**: 95 users per wave over 5 migration waves

### File Migration Approach

File migration preserves structure and permissions:

- **Source Mapping**: File server shares mapped to Shared Drives and My Drive
- **Permission Translation**: NTFS permissions converted to Drive sharing settings
- **Folder Hierarchy**: Department structure preserved in Shared Drives
- **Personal Files**: Home drives migrated to individual My Drive

## Data Flow Architecture

### Email Flow

Post-migration email routing:

```
External Mail → MX (Google) → Gmail → Spam Filter → DLP Scan → Inbox
Internal Mail → Gmail → DLP Scan → Recipient Inbox
```

### File Sync Architecture

Drive File Stream provides local access:

```
Local Files ↔ Drive File Stream ↔ Google Drive ↔ Web/Mobile Access
```

## Data Retention

### Retention Matrix

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Data Type | Retention Period | Location | Purge Behavior |
|-----------|------------------|----------|----------------|
| Gmail | 7 years | Vault | Auto-purge after retention |
| Drive Files | 7 years | Vault | Auto-purge after retention |
| Meet Recordings | 7 years | Vault | Auto-purge after retention |
| Chat Messages | 7 years | Vault | Auto-purge after retention |
| Deleted Items | 25-30 days | Trash | Then to Vault retention |

# Integration Design

## Identity Integration

### Azure AD SAML SSO

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Identity Architecture                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐     SAML 2.0      ┌──────────────────────────────┐   │
│  │   Azure AD   │◄─────────────────►│    Google Workspace          │   │
│  │  (Primary    │                    │    (Service Provider)        │   │
│  │   IdP)       │                    │                              │   │
│  └──────┬───────┘                    └──────────────────────────────┘   │
│         │                                                                │
│         │ Directory                                                      │
│         │ Services                                                       │
│         ▼                                                                │
│  ┌──────────────┐     GCDS Sync     ┌──────────────────────────────┐   │
│  │  Active      │◄─────────────────►│    Google Admin Console      │   │
│  │  Directory   │   (4-hour cycle)   │    (User/Group Management)   │   │
│  │  On-Premises │                    │                              │   │
│  └──────────────┘                    └──────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### SAML Configuration Parameters

<!-- TABLE_CONFIG: widths=[30, 70] -->
| Parameter | Value |
|-----------|-------|
| Entity ID | google.com |
| Reply URL | https://www.google.com/a/[domain.com]/acs |
| Sign-on URL | https://www.google.com/a/[domain.com]/ServiceLogin |
| Certificate | Azure AD SAML signing certificate |

### Google Cloud Directory Sync

GCDS synchronizes users and groups from Active Directory:

- **Sync Interval**: Every 4 hours
- **User Scope**: All users in designated OUs
- **Group Scope**: Distribution lists and security groups
- **Attribute Mapping**: sAMAccountName to primaryEmail, department to OU path

## Exchange Coexistence

### 4-Week Coexistence Period

During migration waves, both systems operate in parallel:

- **Mail Forwarding**: Exchange forwards to Gmail for migrated users
- **Free/Busy Lookup**: Cross-system calendar availability
- **GAL Synchronization**: Unified address book during transition
- **MX Records**: Exchange primary until final cutover

### Mail Flow During Coexistence

```
Inbound (Exchange Users): Internet → MX → Exchange → Mailbox
Inbound (Gmail Users):    Internet → MX → Exchange → Forward → Gmail
Internal (Mixed):         Exchange ↔ Forwarding Rules ↔ Gmail
```

## Third-Party Integrations

<!-- TABLE_CONFIG: widths=[25, 25, 50] -->
| System | Integration Type | Purpose |
|--------|------------------|---------|
| Azure AD | SAML 2.0 SSO | Primary authentication |
| Active Directory | GCDS | User and group provisioning |
| Exchange 2016 | GWMT | Email and calendar migration |
| File Servers | Migration Tool | File and permission migration |

# Infrastructure & Operations

## Google Workspace Configuration

### Organizational Structure

```
Google Workspace Directory
└── [domain.com]
    ├── /Sales (95 users)
    ├── /Marketing (95 users)
    ├── /Operations (95 users)
    ├── /Finance (95 users)
    └── /Executive (95 users)
```

### Application Configuration

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Application | Configuration | Notes |
|-------------|---------------|-------|
| Gmail | Enabled, 30 GB per user | DLP scanning enabled |
| Drive | Enabled, 5 TB pooled | External sharing restricted |
| Meet | Enabled with recording | Attendance reports enabled |
| Chat | Enabled with Spaces | History retained |
| Calendar | Enabled | Resource booking available |

### Shared Drives Configuration

15 Shared Drives configured for team collaboration:

<!-- TABLE_CONFIG: widths=[30, 40, 30] -->
| Shared Drive | Purpose | Access |
|--------------|---------|--------|
| Sales-Team | Sales documents and resources | Sales OU |
| Marketing-Team | Marketing assets and campaigns | Marketing OU |
| Operations-Team | Operations procedures | Operations OU |
| Finance-Team | Financial documents | Finance OU (restricted) |
| Executive-Team | Executive communications | Executive OU |
| All-Company | Company-wide resources | All users |
| Templates | Document templates | All users |

## Network Requirements

### Connectivity Requirements

Ensure outbound access to Google services:

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Service | Protocol | Ports | Direction |
|---------|----------|-------|-----------|
| Gmail SMTP | TLS | 587 | Outbound |
| All Google Services | HTTPS | 443 | Outbound |
| GCDS Sync | HTTPS | 443 | Outbound |
| Meet Video | UDP | 19302-19309 | Bidirectional |

### Bandwidth Requirements

Recommended bandwidth for 500 users:

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Activity | Per User | Total |
|----------|----------|-------|
| Email Sync | 50 Kbps | 25 Mbps |
| Drive Sync | 200 Kbps | 100 Mbps |
| Meet Video (50 concurrent) | 3.2 Mbps | 160 Mbps |
| Migration Burst | N/A | 500 Mbps recommended |

## Operations Model

### Admin Roles and Responsibilities

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Role | Scope | Permissions |
|------|-------|-------------|
| Super Admin | Full console access | All administrative functions |
| User Admin | User management | Create, modify, suspend users |
| Groups Admin | Group management | Create and manage groups |
| Help Desk | Password resets | Reset passwords, view user info |
| Vault Admin | eDiscovery | Search, export, legal holds |

### Support Model

<!-- TABLE_CONFIG: widths=[20, 25, 55] -->
| Level | Response Time | Scope |
|-------|---------------|-------|
| L1 Helpdesk | <15 minutes | Password resets, basic troubleshooting |
| L2 IT Admin | <1 hour | Configuration changes, complex issues |
| L3 Google Support | <4 hours | Platform issues, escalations |

# Implementation Approach

## Migration Phases

### Phase Overview

The migration executes in 5 phases over 12 weeks:

- **Planning (Weeks 1-2)**: Assessment, wave planning, communication strategy
- **Setup (Weeks 3-4)**: Tenant configuration, SSO, GCDS, security policies
- **Pilot (Weeks 5-6)**: 25 pilot users, validation, training refinement
- **Migration (Weeks 6-10)**: 5 waves of 95 users each
- **Closure (Weeks 11-12)**: MX cutover, documentation, training completion

### Wave Migration Schedule

<!-- TABLE_CONFIG: widths=[15, 25, 15, 25, 20] -->
| Wave | Department | Users | Timeline | Status |
|------|------------|-------|----------|--------|
| Pilot | Mixed | 25 | Week 5 | Pending |
| Wave 1 | Sales | 95 | Week 6 | Pending |
| Wave 2 | Marketing | 95 | Week 7 | Pending |
| Wave 3 | Operations | 95 | Week 8 | Pending |
| Wave 4 | Finance | 95 | Week 9 | Pending |
| Wave 5 | Executive | 95 | Week 10 | Pending |

## Migration Architecture

### Email Migration Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     Email Migration Flow                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐                   ┌────────────────────────┐      │
│  │   Exchange 2016  │                   │    Google Workspace    │      │
│  │   On-Premises    │                   │        Gmail           │      │
│  │                  │                   │                        │      │
│  │  500 Mailboxes   │    GWMT Tool      │    500 Accounts        │      │
│  │  2.5 TB Data     │──────────────────►│    2.5 TB Data         │      │
│  │  150 DLs         │                   │    150 Groups          │      │
│  └──────────────────┘                   └────────────────────────┘      │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Cutover Sequence

MX record cutover executes in Week 10:

1. Verify all mailboxes migrated successfully
2. Complete delta sync for final mail capture
3. Update MX records to Google
4. Update SPF, DKIM, DMARC records
5. Monitor mail flow for 24 hours
6. Decommission Exchange forwarding rules

## Risk Mitigation

### Migration Risks

<!-- TABLE_CONFIG: widths=[25, 40, 35] -->
| Risk | Mitigation | Contingency |
|------|------------|-------------|
| Data loss during migration | Pre-migration validation, checksums | Rollback to Exchange |
| SSO authentication failure | Staged rollout, bypass accounts | Direct Google login |
| User adoption resistance | Training, change champions | Extended support |
| Network bandwidth saturation | Off-hours migration, throttling | Staggered migration |

### Rollback Plan

Rollback triggers and procedures:

- **Trigger**: >10% users unable to access email for >4 hours
- **Decision**: Project manager with executive sponsor approval
- **Procedure**: Revert MX records, disable forwarding, communicate to users
- **Timeline**: 4-hour maximum rollback execution

# Appendices

## Architecture Diagram

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

## Glossary

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| GCDS | Google Cloud Directory Sync - tool for synchronizing AD to Google |
| GWMT | Google Workspace Migration Tool - email migration utility |
| DLP | Data Loss Prevention - automated sensitive data detection |
| Vault | Google Vault - retention and eDiscovery service |
| MDM | Mobile Device Management - device security controls |
| SSO | Single Sign-On - federated authentication |
| 2SV | 2-Step Verification - multi-factor authentication |

## Configuration Checklist

### Pre-Migration

- [ ] Domain verified in Google Admin Console
- [ ] Organizational units created for 5 departments
- [ ] Azure AD SSO configured and tested
- [ ] GCDS installed and sync verified
- [ ] DLP policies created and tested
- [ ] Vault retention rules configured
- [ ] MDM policies configured

### Post-Migration

- [ ] All 500 mailboxes migrated
- [ ] MX records updated to Google
- [ ] SPF, DKIM, DMARC configured
- [ ] Training delivered to all users
- [ ] Admin documentation complete
- [ ] Hypercare support active

---

**Document Version**: 1.0
**Last Updated**: 2025-11-27
**Review Status**: Approved by Solution Architecture Team
