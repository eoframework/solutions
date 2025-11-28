---
document_title: Detailed Design Document
solution_name: Microsoft CMMC GCC High Enclave
document_version: "1.0"
author: "[ARCHITECT]"
last_updated: "[DATE]"
technology_provider: microsoft
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This document provides the comprehensive technical design for the Microsoft CMMC GCC High Enclave implementation. It covers the target-state architecture for Microsoft 365 GCC High, Azure Government, security controls implementing all 110 NIST 800-171 requirements, and the CAC/PIV authentication framework required for CMMC Level 2 certification.

## Purpose

Define the technical architecture and design specifications that will guide the implementation team through deployment, configuration, and validation of the GCC High enclave and CMMC Level 2 compliance controls for 50 CUI-handling users.

## Scope

**In-scope:**
- Microsoft 365 GCC High tenant configuration and migration
- Azure Government subscription and resource deployment
- CAC/PIV smart card authentication integration
- Microsoft Sentinel SIEM deployment (100GB/month)
- Defender for Cloud security posture management
- NIST 800-171 control implementation for CMMC Level 2

**Out-of-scope:**
- CMMC Level 3 controls (future phase if required)
- On-premises infrastructure modifications beyond ExpressRoute connectivity
- Third-party application integrations not specified in SOW
- Physical security controls for client facilities

## Assumptions & Constraints

The following assumptions underpin the design and must be validated during implementation.

- Client has DoD-approved ExpressRoute connectivity or will provision within Phase 1
- All 50 CUI users possess valid CAC or PIV smart cards with current certificates
- Client organization is registered in DoD CMMC Marketplace prior to C3PAO assessment
- Azure Government subscription eligibility verified (US persons requirement met)
- M365 GCC High licensing available (E5 for all 50 users)

## References

This document should be read in conjunction with the following related materials.

- Statement of Work (SOW) - Microsoft CMMC GCC High Enclave
- NIST SP 800-171 Rev 2 - Protecting CUI in Nonfederal Systems
- CMMC Level 2 Assessment Guide v2.0
- Microsoft 365 GCC High Service Description
- Azure Government Compliance Documentation

# Business Context

This section establishes the business drivers, success criteria, and compliance requirements that shape the technical design decisions for the CMMC enclave.

## Business Drivers

The solution addresses the following key business objectives identified during discovery.

- **DoD Contract Eligibility:** Enable pursuit of DoD contracts requiring CMMC Level 2 certification for CUI handling
- **Compliance Mandate:** Implement all 110 NIST 800-171 controls required for CMMC Level 2
- **Time to Certification:** Achieve certification within 6 months using cloud-based approach versus 18+ months for on-premises
- **Cost Optimization:** Avoid $500K+ capital expenditure through GCC High cloud model

## Workload Criticality & SLA Expectations

The following service level targets define the operational requirements for the GCC High environment and guide infrastructure sizing decisions.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Availability | 99.9% | M365 Admin Center SLA | Critical |
| Sentinel Alert Response | <15 minutes | MTTR from alert to acknowledgment | Critical |
| Vulnerability Remediation (Critical) | 24 hours | Time to patch/mitigate | Critical |
| Recovery Time Objective | 4 hours | DR testing validation | High |

## Compliance & Regulatory Factors

The solution must adhere to the following regulatory and compliance requirements.

- CMMC Level 2 certification with all 110 NIST 800-171 controls
- FedRAMP High authorization (inherited from GCC High)
- FIPS 140-2 validated cryptographic modules for data protection
- DFARS 252.204-7012 compliance for CUI safeguarding
- DoD IL4 data handling capability (GCC High baseline)

## Success Criteria

Project success will be measured against the following criteria at go-live.

- CMMC Level 2 certification achieved with zero open POA&Ms
- SPRS score of +110 (maximum achievable)
- All 50 CUI users successfully migrated to GCC High with CAC/PIV authentication
- Sentinel SIEM operational with <15 minute alert response capability
- C3PAO assessment passed with zero critical findings

# Current-State Assessment

This section documents the existing environment that the GCC High enclave will integrate with or replace.

## Application Landscape

The current environment consists of commercial Microsoft 365 and on-premises systems that will be migrated or integrated with the new GCC High solution.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Status |
|-------------|---------|------------|--------|
| Commercial M365 | Current email and collaboration | M365 E3 Commercial | To be migrated |
| On-premises AD | Identity management | Windows Server 2019 | Integration point |
| File Servers | CUI document storage | Windows File Services | To be migrated |
| VPN Gateway | Remote access | Cisco ASA | Integration point |

## Infrastructure Inventory

The current infrastructure consists of the following components that will be integrated with the new GCC High solution.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Domain Controllers | 2 | Windows Server 2019, 4 vCPU, 16GB | AD DS for on-premises identity |
| CAC Middleware Servers | 1 | ActivClient, Windows Server 2019 | Smart card authentication |
| File Servers | 2 | Windows Server 2019, 500GB each | CUI document storage |
| Network Firewall | 1 | Cisco ASA 5525-X | Perimeter security |

## Dependencies & Integration Points

The current environment has the following external dependencies that must be considered during migration.

- On-premises Active Directory for user identity synchronization to Azure AD
- DoD PKI infrastructure for CAC/PIV certificate validation
- ExpressRoute circuit for private connectivity to Azure Government
- Existing VPN infrastructure for remote user access

## Network Topology

Current network uses traditional hub-and-spoke topology with:
- DMZ for public-facing services
- Internal network segment for workstations and servers
- Site-to-site VPN for branch office connectivity (if applicable)
- No current Azure connectivity (to be provisioned)

## Security Posture

The current security controls provide a baseline that will be enhanced in the GCC High architecture.

- On-premises Active Directory with password-based authentication
- Commercial antivirus on endpoints
- Perimeter firewall with basic IDS
- Annual security awareness training
- No current SIEM or centralized log management

## Performance Baseline

Current system performance metrics establish the baseline for improvement targets.

- Email users: 50 active users
- Mailbox average size: 2GB per user
- SharePoint/file storage: 500GB total CUI documents
- Daily email volume: ~1,000 messages
- Peak concurrent users: 40

# Solution Architecture

The target architecture leverages Microsoft's FedRAMP High authorized GCC High platform to deliver CMMC Level 2 compliance with inherited security controls.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

## Architecture Principles

The following principles guide all architectural decisions throughout the solution design.

- **Compliance by Design:** Leverage FedRAMP High inherited controls from GCC High platform
- **Zero Trust Security:** Implement CAC/PIV authentication with Conditional Access policies
- **Defense in Depth:** Layer security controls across identity, network, and data planes
- **Cloud-Native Operations:** Utilize Sentinel SIEM and Defender for Cloud for security operations
- **Separation of Duties:** Enforce RBAC with distinct roles for admin, user, and auditor access

## Architecture Patterns

The solution implements the following architectural patterns to address compliance and security requirements.

- **Primary Pattern:** FedRAMP High authorized cloud services (M365 GCC High + Azure Government)
- **Identity Pattern:** Federated identity with CAC/PIV smart card authentication
- **Security Pattern:** Zero Trust with Conditional Access and continuous verification
- **Monitoring Pattern:** Centralized SIEM with automated incident response playbooks

## Component Design

The solution comprises the following logical components, each with specific responsibilities and compliance mappings.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | NIST Controls |
|-----------|---------|------------|--------------|---------------|
| GCC High Tenant | Secure M365 environment | M365 GCC High E5 | Azure AD | AC, IA, SC |
| Azure Government | CUI workload hosting | Azure Gov us-gov-virginia | ExpressRoute | AC, SC, CM |
| Azure AD GCC High | Identity management | Azure AD Premium P2 | DoD PKI | IA, AC |
| Sentinel SIEM | Security monitoring | Microsoft Sentinel | Log sources | AU, IR, SI |
| Defender for Cloud | Security posture | Defender CSPM | Azure resources | CM, RA, SI |
| ExpressRoute | Private connectivity | Azure ExpressRoute | ISP circuit | SC |

## Technology Stack

The technology stack has been selected based on requirements for CMMC Level 2 compliance, FedRAMP High authorization, and alignment with DoD security standards.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Email & Collaboration | M365 GCC High (Exchange, SharePoint, Teams) | FedRAMP High, DoD IL4 authorized |
| Identity | Azure AD GCC High with CAC/PIV | DoD PKI integration, MFA requirement |
| Compute | Azure Government (us-gov-virginia) | FedRAMP High, ITAR compliant |
| Security Monitoring | Microsoft Sentinel | Cloud-native SIEM, NIST 800-171 AU controls |
| Compliance | Defender for Cloud | Continuous CMMC posture assessment |
| Encryption | Azure Key Vault (FIPS 140-2) | NIST SC-12, SC-13 controls |

# Security & Compliance

This section details the security controls, NIST 800-171 mappings, and governance mechanisms implementing CMMC Level 2 requirements.

## Identity & Access Management

Access control follows a Zero Trust model with CAC/PIV smart card authentication for all CUI access.

- **Authentication:** CAC/PIV smart card with certificate-based authentication (NIST IA-2)
- **Authorization:** Azure AD RBAC with role-based access to CUI resources (NIST AC-2, AC-3)
- **MFA:** Enforced via Conditional Access for all access attempts (NIST IA-2(1), IA-2(2))
- **Service Accounts:** Managed identities for Azure resources, no shared credentials (NIST IA-4)

### Role Definitions

The following roles define access levels within the GCC High environment, implementing NIST AC-2 and AC-6 least privilege requirements.

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| CUI Processor | Read/write CUI documents, email, Teams | SharePoint CUI library, Exchange, Teams |
| Security Administrator | Sentinel SIEM, Defender for Cloud, policies | All security resources |
| ISSO/ISSM | Compliance dashboards, audit logs, SSP | Read-only security configuration |
| Global Administrator | Full tenant administration | GCC High tenant (2 accounts only) |

## Secrets Management

All sensitive credentials are managed through Azure Key Vault with FIPS 140-2 validation, implementing NIST SC-12 and SC-28.

- Azure Key Vault (HSM-backed) for all encryption keys
- Managed identities for Azure resource authentication (no stored secrets)
- 90-day automatic rotation for service principal credentials
- Certificate-based authentication for all administrative access

## Network Security

Network security implements defense-in-depth with multiple layers of protection, addressing NIST SC-7 boundary protection requirements.

- **Segmentation:** Azure VNet with separate subnets for management and CUI workloads
- **Connectivity:** ExpressRoute private peering (no public internet path for CUI)
- **Firewall:** Azure Firewall with deny-by-default rules (NIST SC-7(5))
- **DDoS Protection:** Azure DDoS Protection Standard enabled

## Data Protection

Data protection controls ensure confidentiality and integrity throughout the CUI lifecycle, implementing NIST SC-8 and SC-28.

- **Encryption at Rest:** AES-256 with Microsoft-managed keys (BitLocker, Azure Storage SSE)
- **Encryption in Transit:** TLS 1.2+ for all communications (NIST SC-8(1))
- **Key Management:** Azure Key Vault with FIPS 140-2 Level 2 validated HSMs
- **Data Classification:** Microsoft Purview sensitivity labels for CUI marking

## Compliance Mappings

The following table maps NIST 800-171 control families to specific implementation controls in the GCC High architecture.

<!-- TABLE_CONFIG: widths=[15, 20, 30, 35] -->
| Family | Controls | Implementation | Evidence |
|--------|----------|----------------|----------|
| AC | 22 controls | Azure AD RBAC, Conditional Access | Defender for Cloud policies |
| AT | 3 controls | Security awareness training portal | Training completion reports |
| AU | 9 controls | Sentinel SIEM, 90-day log retention | Log Analytics workspace |
| CM | 9 controls | Azure Policy, Defender for Cloud | Compliance dashboard |
| IA | 11 controls | CAC/PIV, Azure AD MFA | Azure AD sign-in logs |
| IR | 3 controls | Sentinel playbooks, incident response | Playbook execution logs |
| MA | 6 controls | Intune for device management | Compliance reports |
| MP | 9 controls | Sensitivity labels, DLP policies | Purview compliance center |
| PE | 6 controls | Client responsibility (physical) | Client attestation |
| PS | 2 controls | Background check process | HR documentation |
| RA | 3 controls | Defender vulnerability assessment | Vulnerability reports |
| CA | 4 controls | Defender for Cloud, POA&M tracking | Assessment documentation |
| SC | 16 controls | Encryption, network controls | Technical configuration |
| SI | 7 controls | Defender for Endpoint, updates | Patch compliance reports |

## Audit Logging & SIEM Integration

Comprehensive audit logging supports NIST AU control family requirements with centralized collection in Microsoft Sentinel.

- All Azure AD authentication events logged (AU-2, AU-3)
- M365 unified audit log enabled for all workloads (AU-2)
- Azure activity logs forwarded to Sentinel (AU-6)
- Log retention: 90 days hot in Sentinel, 7 years in cold storage (AU-11)
- Real-time alerting for security events with <15 minute response (AU-6(1))

# Data Architecture

This section defines the data model, CUI handling procedures, migration approach, and governance controls.

## Data Model

### Data Classification

The solution implements the following data classification levels aligned with NIST 800-171 and DoD requirements.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Classification | Description | Handling Requirements |
|----------------|-------------|----------------------|
| CUI | Controlled Unclassified Information | GCC High only, encrypted, logged access |
| CUI//SP-CTI | CUI Specified - Controlled Technical Info | Additional marking, restricted sharing |
| Internal | Non-CUI business data | Standard M365 controls |
| Public | Publicly releasable information | No restrictions |

### Logical Model

The logical data model defines the primary data stores and their relationships within the GCC High environment.

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Data Store | Purpose | Volume | Retention |
|------------|---------|--------|-----------|
| Exchange Online | Email with CUI attachments | 100GB (50 users x 2GB) | 10 years |
| SharePoint Online | CUI document collaboration | 500GB | 7 years |
| OneDrive for Business | User file sync | 250GB (50 users x 5GB) | 7 years |
| Sentinel Logs | Security event data | 100GB/month | 90 days hot, 7 years cold |
| Azure SQL | CUI application data | 100GB | 7 years |

## Data Flow Design

1. **User Access:** Users authenticate via CAC/PIV to Azure AD GCC High
2. **Authorization:** Conditional Access validates device compliance and location
3. **Document Access:** CUI accessed via SharePoint/OneDrive with sensitivity labels
4. **Email:** Exchange Online routes CUI-marked messages with transport rules
5. **Logging:** All access events sent to Sentinel for correlation and alerting

## Data Migration Strategy

Data migration follows a phased approach to minimize risk and ensure CUI integrity.

- **Approach:** Pilot-then-production with 10 pilot users (Week 1) followed by 40 users (Weeks 2-4)
- **Validation:** Checksum validation for all migrated files, message count reconciliation
- **Rollback:** 14-day parallel operation with ability to restore commercial access
- **Cutover:** DNS cutover to GCC High after pilot validation complete

## Data Governance

Data governance policies ensure proper CUI handling, retention, and quality management per NIST MP control family.

- **Classification:** Sensitivity labels (CUI, CUI//SP-CTI, Internal, Public) applied automatically
- **Retention:** 7-year minimum for CUI per DFARS requirements
- **Access Logging:** All CUI access logged to Sentinel with user, timestamp, action
- **Disposal:** Secure deletion with cryptographic erasure verification

# Integration Design

This section documents the integration patterns, identity federation, and external system connections.

## External System Integrations

The solution integrates with the following external systems using standardized protocols and security controls.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Security | SLA |
|--------|------|----------|--------|----------|-----|
| On-premises AD | Real-time | LDAPS | Directory sync | Azure AD Connect | 99.9% |
| DoD PKI | Real-time | OCSP/CRL | Certificate validation | TLS 1.2 | 99.99% |
| ExpressRoute | Dedicated | BGP | Private peering | Encrypted circuit | 99.95% |
| C3PAO Portal | Periodic | HTTPS | Assessment data | Client cert auth | N/A |

## Identity Federation

Azure AD GCC High federates with on-premises Active Directory for hybrid identity.

- Azure AD Connect deployed for directory synchronization
- Password hash sync disabled (CAC/PIV only authentication)
- Cloud-only emergency access accounts for break-glass scenarios
- Seamless SSO for domain-joined devices accessing GCC High resources

### CAC/PIV Authentication Flow

Smart card authentication follows this flow for CUI access.

1. User inserts CAC/PIV card and enters PIN
2. Certificate extracted and validated against DoD PKI
3. Azure AD matches certificate to user principal name (UPN)
4. Conditional Access evaluates device compliance and location
5. Access token issued with group memberships for RBAC

## Messaging & Event Patterns

Asynchronous messaging enables security event processing and automated response.

- **Sentinel Alerts:** Real-time security event detection and alerting
- **Logic Apps:** Automated incident response playbooks
- **Event Grid:** Azure resource event routing to Sentinel
- **Service Bus:** Not required for this implementation

# Infrastructure & Operations

This section covers the Azure Government infrastructure design, deployment architecture, and operational procedures.

## Network Design

The Azure Government virtual network architecture provides isolation and security through segmentation.

- **VNet CIDR:** 10.100.0.0/16 (Azure Government)
- **Management Subnet:** 10.100.1.0/24 (Bastion, jump servers)
- **CUI Workload Subnet:** 10.100.10.0/24 (CUI processing VMs)
- **Private Endpoint Subnet:** 10.100.20.0/24 (PaaS private endpoints)
- **ExpressRoute Gateway Subnet:** 10.100.255.0/27

## Compute Sizing

Instance sizing has been determined based on CUI workload requirements and SOW specifications.

<!-- TABLE_CONFIG: widths=[25, 20, 20, 20, 15] -->
| Component | VM Size | vCPU | Memory | Count |
|-----------|---------|------|--------|-------|
| CUI Processing VMs | Standard_D4s_v3 | 4 | 16 GB | 5 |
| Bastion Host | Standard_B2s | 2 | 4 GB | 1 |
| Total Azure Compute | | 22 vCPU | 84 GB | 6 VMs |

## High Availability Design

The solution eliminates single points of failure through Azure platform redundancy.

- M365 GCC High: 99.9% SLA with geo-redundant services
- Azure Government: Availability zones in us-gov-virginia
- ExpressRoute: Redundant circuits recommended (client decision)
- Sentinel: Multi-region data replication for log durability

## Disaster Recovery

Disaster recovery capabilities ensure business continuity in the event of regional failure.

- **RPO:** 1 hour (M365 native replication, Azure backup)
- **RTO:** 4 hours (runbook-based recovery procedures)
- **Backup:** Azure Backup for VMs, M365 native retention for email/files
- **DR Site:** Azure Government us-gov-texas for geo-redundancy (optional enhancement)

## Monitoring & Alerting

Comprehensive monitoring provides visibility across the GCC High environment addressing NIST SI-4 requirements.

- **Security Events:** Sentinel SIEM with correlation rules
- **Compliance Posture:** Defender for Cloud CMMC dashboard
- **Infrastructure Health:** Azure Monitor for VM and network metrics
- **Alerting:** Sentinel rules with email/Teams notifications to SOC

### Alert Definitions

The following alerts have been configured to ensure proactive incident detection and response.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| Failed CAC Login | >5 failures in 10 min | Critical | Account lockout review |
| CUI Access Anomaly | Unusual file access pattern | High | User activity investigation |
| Malware Detection | Defender for Endpoint alert | Critical | Endpoint isolation |
| Compliance Drift | CMMC score <95% | High | Control remediation |

## Logging & Observability

Centralized logging and distributed tracing enable rapid troubleshooting and compliance evidence.

- Sentinel workspace: 100GB/month ingestion
- Log sources: Azure AD, M365 audit, Azure activity, Defender alerts
- Retention: 90 days hot, export to Azure Storage for 7-year cold retention
- Workbooks: CMMC compliance dashboard, incident response metrics

## Cost Model

The estimated monthly infrastructure costs are based on SOW specifications with Year 1 budget of $153,240.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Monthly | Annual | % of Total |
|----------|---------|--------|------------|
| M365 GCC High E5 (50 users @ $146/user) | $7,300 | $87,600 | 57% |
| Azure Government (VMs, storage, network) | $3,970 | $47,640 | 31% |
| Support & Maintenance | $1,500 | $18,000 | 12% |
| **Total** | **$12,770** | **$153,240** | **100%** |

# Implementation Approach

This section outlines the deployment strategy, tooling, and sequencing for the 6-month implementation.

## Migration/Deployment Strategy

The deployment strategy minimizes risk through phased rollout with compliance validation gates.

- **Approach:** Phased deployment with pilot validation before production migration
- **Pattern:** Lift-and-shift for email/files, new deployment for Azure resources
- **Validation:** NIST 800-171 control verification at each phase gate
- **Rollback:** 14-day parallel operation with documented rollback procedures

## Sequencing & Wave Planning

The implementation follows a three-phase approach with clear exit criteria aligned with the 6-month timeline.

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Gap Assessment & Design | Months 1-2 | NIST 800-171 gap assessment complete, SSP drafted |
| 2 | GCC High Deployment | Months 3-4 | Tenant configured, 50 users migrated, Sentinel operational |
| 3 | CMMC Preparation | Months 5-6 | C3PAO assessment passed, CMMC Level 2 certified |

## Tooling & Automation

The following tools provide the automation foundation for infrastructure provisioning, deployment, and operations.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | ARM Templates / Terraform | Azure Government resource provisioning |
| Configuration Management | Azure Policy | Compliance enforcement and drift detection |
| Identity Provisioning | Azure AD Connect | On-premises AD synchronization |
| Security Automation | Sentinel Playbooks | Automated incident response |
| Compliance Reporting | Defender for Cloud | CMMC posture dashboard |

## Cutover Approach

The cutover strategy balances risk mitigation with the 6-month certification timeline.

- **Type:** Phased cutover with pilot validation
- **Pilot Duration:** 1 week with 10 users
- **Production Migration:** 3 weeks for remaining 40 users in departmental waves
- **Decision Point:** Go/no-go after pilot validation complete

## Downtime Expectations

Service availability impacts during implementation have been minimized through careful planning.

- **Planned Downtime:** Zero downtime for email migration (cutover during off-hours)
- **User Impact:** 2-4 hours per user for CAC/PIV enrollment and workstation configuration
- **Mitigation:** Pre-staged CAC middleware, after-hours DNS cutover

## Rollback Strategy

Rollback procedures are documented and tested to enable rapid recovery if issues arise.

- Commercial M365 tenant retained for 14 days post-migration
- DNS rollback to commercial Exchange within 4 hours if needed
- Azure resources deployed via IaC enable full recreation
- Maximum rollback window: 14 days post-go-live

# Appendices

## Architecture Diagrams

The following diagrams provide visual representation of the solution architecture.

- Solution Architecture Diagram (included in Solution Architecture section)
- Network Topology Diagram
- CAC/PIV Authentication Flow Diagram
- Data Flow Diagram for CUI Handling

## Naming Conventions

All Azure Government resources follow standardized naming conventions for CMMC traceability.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Resource Group | `{env}-cmmc-{function}-rg` | `prod-cmmc-security-rg` |
| Virtual Network | `{env}-cmmc-vnet` | `prod-cmmc-vnet` |
| Subnet | `{env}-cmmc-{tier}-subnet` | `prod-cmmc-cui-subnet` |
| Virtual Machine | `{env}-cmmc-{function}-vm{n}` | `prod-cmmc-cui-vm01` |
| Key Vault | `{env}cmmckv{random}` | `prodcmmckva1b2c3` |
| Storage Account | `{env}cmmcst{random}` | `prodcmmcsta1b2c3` |

## Tagging Standards

Resource tagging enables cost allocation, compliance tracking, and operational automation.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Tag | Required | Example Values |
|-----|----------|----------------|
| Environment | Yes | dev, staging, prod |
| DataClassification | Yes | CUI, Internal, Public |
| CMMCLevel | Yes | Level2 |
| Owner | Yes | isso@client.com |
| CostCenter | Yes | CMMC-2024 |
| Compliance | Yes | NIST-800-171 |

## Risk Register

The following risks have been identified during the design phase with corresponding mitigation strategies.

<!-- TABLE_CONFIG: widths=[25, 15, 15, 45] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| ExpressRoute provisioning delay | Medium | High | Initiate provisioning Week 1, 4-week buffer |
| CAC certificate expiration during migration | Medium | Medium | Pre-validate all certificates before migration |
| C3PAO availability for assessment | Low | High | Engage C3PAO in Month 4, confirm schedule |
| DLP false positives blocking legitimate CUI | Medium | Medium | Start in monitoring mode, tune before enforcement |
| User resistance to CAC authentication | Low | Low | Communication plan, training before migration |

## Glossary

The following terms and acronyms are used throughout this document.

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| CAC | Common Access Card - DoD smart card for authentication |
| CMMC | Cybersecurity Maturity Model Certification |
| CUI | Controlled Unclassified Information |
| C3PAO | CMMC Third Party Assessment Organization |
| DFARS | Defense Federal Acquisition Regulation Supplement |
| FedRAMP | Federal Risk and Authorization Management Program |
| GCC High | Microsoft Government Community Cloud High |
| ISSO | Information System Security Officer |
| ISSM | Information System Security Manager |
| NIST | National Institute of Standards and Technology |
| PIV | Personal Identity Verification - federal smart card |
| POA&M | Plan of Action and Milestones |
| SPRS | Supplier Performance Risk System |
| SSP | System Security Plan |
