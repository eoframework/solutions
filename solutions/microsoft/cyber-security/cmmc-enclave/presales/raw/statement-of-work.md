---
document_title: Statement of Work
technology_provider: Microsoft
project_name: CMMC GCC High Enclave
client_name: [Client Name]
client_contact: [Contact Name | Email | Phone]
consulting_company: [Consulting Company Name]
consultant_contact: [Contact Name | Email | Phone]
opportunity_no: [OPP-YYYY-###]
document_date: [Month DD, YYYY]
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing a Microsoft CMMC GCC High Enclave for [Client Name]. This engagement will deliver a FedRAMP High authorized cloud environment enabling CMMC Level 2 certification for DoD contractors handling Controlled Unclassified Information (CUI) through Microsoft 365 GCC High and Azure Government infrastructure.

**Project Duration:** 6 months

---

---

# Background & Objectives

## Current State

[Client Name] is pursuing DoD contracts requiring CMMC Level 2 certification for handling Controlled Unclassified Information (CUI). The organization currently lacks the FedRAMP High cloud infrastructure and NIST 800-171 security controls necessary for CMMC compliance. Key challenges include:
- **CMMC Compliance Gap:** No FedRAMP High cloud environment meeting 110 NIST 800-171 security requirements
- **CUI Handling Risk:** On-premises systems cannot meet DoD security standards for CUI processing and storage
- **Contract Eligibility:** Cannot pursue $8M+ DoD contracts without CMMC Level 2 certification
- **Assessment Timeline:** C3PAO assessment required within 6 months to maintain contract timeline
- **Security Control Implementation:** Need comprehensive security baseline including CAC/PIV authentication, encryption, audit logging, and incident response

## Business Objectives

The following objectives define the key business outcomes this engagement will deliver:

- **Achieve CMMC Level 2 Certification:** Implement FedRAMP High cloud environment meeting all 110 NIST 800-171 security requirements enabling DoD contract pursuit
- **Deploy GCC High Enclave:** Establish Microsoft 365 GCC High tenant with Exchange Online, SharePoint Online, Teams, and OneDrive for secure CUI collaboration
- **Implement Azure Government Infrastructure:** Deploy Azure Government cloud infrastructure for CUI workloads with compute, storage, networking, and security services
- **Enable CAC/PIV Authentication:** Integrate DoD smart card (CAC/PIV) authentication with Azure AD GCC High for compliant identity and access management
- **Deploy Security Monitoring:** Implement Sentinel SIEM and Defender for Cloud for continuous security monitoring, threat detection, and compliance validation
- **Pass C3PAO Assessment:** Successfully complete independent CMMC Third-Party Assessment Organization evaluation and achieve certification

## Success Metrics

The following metrics will be used to measure project success:

- CMMC Level 2 certification achieved within 6 months enabling DoD contract pursuit
- All 110 NIST 800-171 security requirements implemented and validated with automated compliance monitoring
- 50 users onboarded to GCC High with zero CUI data loss during migration from commercial systems
- CAC/PIV smart card authentication operational with 100% user coverage and MFA enforcement
- Sentinel SIEM deployed with 100GB/month log ingestion, automated incident response playbooks, and <15 minute alert response time
- Azure Government infrastructure operational with 99.9% uptime SLA and FedRAMP High compliance validated

---

---

# Scope of Work

## In Scope
The following services and deliverables are included in this SOW to implement a CMMC-compliant GCC High environment:
- NIST 800-171 gap assessment across all 14 security control families
- Microsoft 365 GCC High architecture design and tenant deployment
- Azure Government infrastructure provisioning and security configuration
- Email and file migration from commercial M365 or on-premises to GCC High
- CAC/PIV smart card authentication integration with Azure AD GCC High
- Sentinel SIEM deployment with automated compliance monitoring and incident response
- Microsoft Defender for Cloud deployment for security posture management
- C3PAO assessment support, remediation coordination, and certification completion
- Knowledge transfer and CMMC compliance operations documentation

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| CMMC Requirements | CMMC Level | Level 2 (Advanced Cyber Hygiene) |
| CMMC Requirements | NIST 800-171 Controls | 110 security requirements |
| User Base | CUI User Count | 50 users accessing CUI |
| User Base | User Roles | 3 roles (CUI processor admin reviewer) |
| M365 GCC High | M365 Tenant | GCC High (FedRAMP High) |
| M365 GCC High | M365 Services | Exchange SharePoint Teams OneDrive Purview |
| M365 GCC High | Email Migration Volume | 100 GB total mailbox data |
| M365 GCC High | File Migration Volume | 500 GB SharePoint and OneDrive |
| Azure Government | Azure Gov Resources | 5 VMs 2TB storage VNet ExpressRoute |
| Azure Government | Sentinel Capacity | 100GB/month log ingestion |
| Azure Government | Defender Coverage | All Azure resources and M365 workloads |
| Security & Compliance | Authentication | CAC/PIV smart card with MFA |
| Security & Compliance | Identity Platform | Azure AD GCC High with SSO |
| Security & Compliance | Data Encryption | FIPS 140-2 encryption at rest and transit |
| Technical Environment | Availability Requirements | 99.9% (GCC High SLA) |
| Technical Environment | Infrastructure Complexity | Azure Gov + M365 GCC High hybrid |
| Technical Environment | Deployment Regions | Single Azure Gov region (us-gov-virginia) |
| C3PAO Assessment | Assessment Timeline | Month 6 C3PAO assessment |
| Environment | Deployment Environments | 2 environments (dev prod) |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*


## Activities

### Phase 1 – NIST 800-171 Gap Assessment & Design
During this initial phase, the Vendor will perform a comprehensive NIST 800-171 gap assessment evaluating the organization's current security posture across all 14 control families. This assessment identifies gaps, calculates the current SPRS score, and determines the roadmap for achieving full compliance with CMMC Level 2 requirements.

Key activities:
- Comprehensive NIST 800-171 gap assessment across 14 control families (Access Control, Awareness Training, Audit Logging, Configuration Management, Identification & Authentication, Incident Response, Maintenance, Media Protection, Personnel Security, Physical Protection, Risk Assessment, Security Assessment, System & Communications Protection, System & Information Integrity)
- Current SPRS score calculation and compliance gap analysis
- Microsoft 365 GCC High architecture design (Exchange Online, SharePoint, Teams, OneDrive, Purview)
- Azure Government infrastructure design (compute, storage, networking, ExpressRoute, security services)
- CAC/PIV authentication architecture and Azure AD GCC High integration design
- Sentinel SIEM architecture design with log sources, retention policies, and incident response playbooks
- C3PAO selection criteria, vendor evaluation, and engagement planning
- System Security Plan (SSP) outline and CMMC documentation framework

This phase concludes with a Gap Assessment Report outlining current compliance state, proposed GCC High/Azure Government architecture, security control implementation roadmap, C3PAO assessment timeline, and project plan.

### Phase 2 – GCC High Deployment & Migration
In this phase, the Microsoft 365 GCC High tenant is provisioned and configured based on FedRAMP High security requirements. This includes tenant setup, service configuration, security baseline implementation, and migration of email and files from commercial M365 or on-premises systems.

Key activities:
- Microsoft 365 GCC High tenant provisioning and domain verification
- Exchange Online GCC High deployment with 10-year archiving and eDiscovery configuration
- SharePoint Online and Teams deployment for secure CUI collaboration
- OneDrive for Business deployment with Known Folder Move for file sync
- Email migration from commercial M365 or on-premises Exchange (100GB mailbox data)
- File migration to SharePoint and OneDrive (500GB total)
- Microsoft Purview deployment for DLP, information protection, and retention policies
- Security baseline configuration (encryption, access controls, audit logging)
- Initial compliance posture assessment and gap remediation

By the end of this phase, the Client will have a fully operational GCC High environment with all CUI users migrated and security controls configured.

### Phase 3 – Azure Government & CAC/PIV Authentication
Implementation of Azure Government cloud infrastructure for CUI workloads, integrated with GCC High for comprehensive security monitoring. CAC/PIV smart card authentication is deployed for DoD-compliant identity and access management.

Key activities:
- Azure Government subscription setup and networking configuration (VNet, subnets, NSGs, ExpressRoute)
- Virtual machine deployment and configuration (5 VMs for CUI workloads)
- Storage account deployment with FIPS 140-2 encryption (2TB total)
- CAC/PIV smart card authentication integration with Azure AD GCC High
- Conditional Access policies for device compliance, location restrictions, and MFA enforcement
- Sentinel SIEM deployment with 100GB/month log ingestion capacity
- Defender for Cloud deployment with compliance posture monitoring
- Integration between GCC High and Azure Government for unified security monitoring
- Security control validation across access control, encryption, and audit logging families

After this phase, the environment supports secure CUI processing with DoD-compliant authentication and comprehensive security monitoring.

### Phase 4 – Security Hardening & Compliance Validation
In the Security Hardening phase, all remaining NIST 800-171 security controls are implemented and validated. Automated compliance monitoring is configured to provide continuous validation of security posture and streamline the C3PAO assessment process.

Key activities:
- Sentinel incident response playbooks for automated threat detection and response
- Defender for Cloud security baseline and vulnerability management configuration
- Microsoft Purview DLP policies for CUI data protection (prevent unauthorized sharing, enforce encryption)
- Retention policies and eDiscovery configuration for compliance and audit requirements
- Network security controls (network segmentation, VPN access, ExpressRoute encryption)
- Endpoint security with Intune MDM for device compliance and app protection
- Continuous compliance monitoring with automated NIST 800-171 control validation
- Security Assessment and Authorization (SA&A) documentation preparation
- Internal compliance audit against all 110 NIST 800-171 requirements
- System Security Plan (SSP) completion with architecture diagrams, security controls, and evidence artifacts

Cutover will be coordinated with business stakeholders to ensure zero disruption to CUI processing workflows during final security hardening.

### Phase 5 – C3PAO Assessment & Certification
Following successful implementation and internal compliance validation, the focus shifts to C3PAO assessment support and CMMC certification completion. The Vendor will coordinate with the selected C3PAO, provide assessment evidence, support finding remediation, and ensure successful certification.

Activities include:
- C3PAO assessment coordination and evidence artifact preparation
- Assessment readiness review (validate all 110 NIST 800-171 controls implemented)
- C3PAO assessment support (interviews, system demonstrations, technical evidence)
- Finding remediation and control gap closure
- Final certification documentation and DoD CMMC Marketplace registration
- ISSO/ISSM training for ongoing CMMC compliance management
- Security operations training for Sentinel SIEM and Defender for Cloud
- Operations runbook delivery (incident response, vulnerability management, compliance monitoring)
- Knowledge transfer sessions for administrators and security team
- 30-day hypercare support for post-certification optimization

---

## Out of Scope

These items are not in scope unless added via change control:
- Hardware procurement or on-premises infrastructure
- Third-party software licensing beyond Microsoft GCC High and Azure Government
- Historical data migration or back-file conversion beyond 100GB email and 500GB files
- Ongoing operational support beyond 30-day hypercare period
- Custom development for CUI workloads not specified in requirements
- Additional CMMC levels (Level 3, 4, or 5) requiring advanced security controls
- DoD IL5 or IL6 environments requiring Azure Government Secret or Top Secret regions
- Annual CMMC recertification support (available under separate managed services agreement)
- Microsoft GCC High and Azure Government service costs (billed directly by Microsoft to client)

---

---

# Deliverables & Timeline

## Deliverables

The following deliverables will be provided throughout the CMMC GCC High Enclave implementation to ensure comprehensive documentation, system deployment, and successful certification.

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | NIST 800-171 Gap Assessment Report | Document | Week 4 | [Client Lead] |
| 2 | GCC High Architecture Document | Document | Week 4 | [Technical Lead] |
| 3 | Azure Government Design Document | Document | Week 4 | [Technical Lead] |
| 4 | Implementation Plan | Project Plan | Week 4 | [Project Sponsor] |
| 5 | M365 GCC High Environment | System | Week 12 | [Technical Lead] |
| 6 | Azure Government Infrastructure | System | Week 16 | [Technical Lead] |
| 7 | CAC/PIV Authentication | System | Week 16 | [Security Lead] |
| 8 | Sentinel SIEM | System | Week 18 | [Security Lead] |
| 9 | System Security Plan (SSP) | Document | Week 20 | [ISSO/ISSM] |
| 10 | Compliance Validation Report | Document | Week 22 | [Security Lead] |
| 11 | C3PAO Assessment Support | Service | Week 24 | [ISSO/ISSM] |
| 12 | CMMC Certification | Certification | Week 26 | [Client Lead] |
| 13 | Operations Runbook | Document | Week 26 | [Ops Lead] |
| 14 | Knowledge Transfer Sessions | Training | Week 25-26 | [Client Team] |

---

## Project Milestones

The project is structured around key milestones that track progress from initial gap assessment through final CMMC Level 2 certification.

<!-- TABLE_CONFIG: widths=[20, 50, 30] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 | Gap Assessment Complete | Week 4 |
| M2 | GCC High Environment Ready | Week 12 |
| M3 | Azure Government Deployed | Week 16 |
| M4 | Security Controls Implemented | Week 20 |
| M5 | Internal Compliance Audit Complete | Week 22 |
| C3PAO Assessment | C3PAO Assessment Complete | Week 24-25 |
| Certification | CMMC Level 2 Certified | Week 26 |

---

---

# Roles & Responsibilities

## RACI Matrix

The following RACI matrix defines roles and responsibilities for all major project activities ensuring clear accountability and effective coordination between Vendor and Client teams.

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO Sales Eng | EO Eng (CMMC) | Client IT | Client ISSO | C3PAO |
|-----------|-------|----------------|--------------|---------------|-----------|-------------|-------|
| NIST Gap Assessment | A | R | R | C | C | R | I |
| GCC High Architecture | C | A | R | I | I | C | I |
| Azure Gov Infrastructure | C | A | C | R | C | I | I |
| CAC/PIV Integration | C | R | C | A | C | R | I |
| Sentinel SIEM Deployment | C | R | C | A | C | I | I |
| Security Controls Implementation | C | R | R | A | C | R | I |
| Compliance Validation | R | C | R | R | A | A | I |
| System Security Plan | C | R | I | A | C | A | C |
| C3PAO Assessment Support | A | R | R | R | C | A | R |
| Knowledge Transfer | A | R | R | R | C | C | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

The following personnel will be assigned to this engagement:

**Vendor Team:**
- EO Project Manager: Overall delivery accountability and C3PAO coordination
- EO Quarterback: Technical design and CMMC architecture oversight
- EO Sales Engineer: GCC High and Azure Government solution architecture
- EO Engineer (CMMC): Security controls implementation and compliance validation

**Client Team:**
- IT Lead: Primary technical contact and Azure/M365 access management
- ISSO/ISSM: CMMC compliance lead and System Security Plan owner
- Security Lead: Security controls validation and C3PAO liaison
- Operations Team: Knowledge transfer recipients for ongoing compliance management

---

---

# Architecture & Design

## Architecture Overview
The Microsoft CMMC GCC High Enclave is designed as a **FedRAMP High authorized hybrid cloud architecture** leveraging Microsoft 365 GCC High for CUI collaboration and Azure Government for CUI workloads. The architecture provides comprehensive NIST 800-171 security controls, continuous compliance monitoring, and DoD-compliant identity management for CMMC Level 2 certification.

This architecture is designed for **small-scope deployment** supporting 50 CUI users with Level 2 compliance requirements. The design prioritizes:
- **CMMC Compliance:** All 110 NIST 800-171 security controls implemented and validated
- **FedRAMP High Authorization:** GCC High and Azure Government environments meet DoD security standards
- **Cost Efficiency:** Right-sized infrastructure for 50-user organization with minimal overhead

![Figure 1: Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Solution Architecture Diagram** - High-level overview of the Microsoft CMMC GCC High Enclave architecture

## Architecture Type
The deployment follows a **hybrid cloud architecture** integrating Microsoft 365 GCC High (SaaS) with Azure Government (IaaS/PaaS) for comprehensive CUI protection. This approach enables:
- Secure CUI collaboration through Exchange Online, SharePoint, Teams, and OneDrive (GCC High)
- Custom CUI workload hosting on Azure Government virtual machines and storage
- Unified identity and access management with Azure AD GCC High and CAC/PIV integration
- Centralized security monitoring with Sentinel SIEM and Defender for Cloud

Key architectural components include:
- Identity Layer (Azure AD GCC High, CAC/PIV authentication, Conditional Access)
- Collaboration Layer (M365 GCC High: Exchange, SharePoint, Teams, OneDrive)
- Compute Layer (Azure Government VMs, storage accounts, networking)
- Security Layer (Sentinel SIEM, Defender for Cloud, Microsoft Purview)
- Compliance Layer (CMMC controls monitoring, audit logging, incident response)

## Scope Specifications

This engagement is scoped according to the following specifications:

**Microsoft 365 GCC High:**
- 50 user licenses (M365 E5 GCC High)
- Exchange Online: 100GB mailbox storage, 10-year archiving, eDiscovery
- SharePoint Online: 500GB CUI document storage with versioning and DLP
- Teams: Secure collaboration with external sharing controls
- Microsoft Purview: DLP, information protection, retention policies

**Azure Government Cloud:**
- 5 virtual machines (Standard_D4s_v3) for CUI workload hosting
- 2TB premium SSD storage with FIPS 140-2 encryption
- VNet with network segmentation and ExpressRoute connectivity
- Sentinel SIEM: 100GB/month log ingestion, 90-day retention
- Defender for Cloud: All Azure resources and M365 workloads covered

**Identity & Access:**
- Azure AD GCC High with CAC/PIV smart card integration
- Conditional Access policies (MFA, device compliance, location restrictions)
- Role-based access control (3 roles: CUI processor, admin, reviewer)

**Security & Monitoring:**
- Sentinel incident response playbooks for automated threat detection
- Defender for Cloud vulnerability assessment and compliance posture monitoring
- CloudWatch-equivalent logging with 90-day retention for NIST 800-171 audit requirements

**Scalability Path:**
- Medium scope: Scale to 100-200 users with additional GCC High licenses
- Large scope: Expand to 300+ users with multi-region Azure Government deployment
- Level 3 CMMC: Add advanced threat protection and supply chain risk management controls

## Application Hosting
All CUI workloads will be hosted using Microsoft GCC High and Azure Government services:
- Microsoft 365 GCC High for email, collaboration, and document management (SaaS)
- Azure Government virtual machines for custom CUI applications (IaaS)
- Azure Government storage accounts for CUI data with FIPS 140-2 encryption
- All services deployed using infrastructure-as-code (ARM templates or Terraform)

## Networking
The networking architecture follows Azure Government and GCC High best practices for CUI protection:
- Azure Government VNet with network segmentation (CUI workload subnet, management subnet)
- ExpressRoute connectivity for private, dedicated connection to Azure Government
- Network security groups (NSGs) enforcing least-privilege access
- Azure Firewall for egress filtering and threat intelligence
- VPN access for remote administrators with CAC/PIV authentication

## Observability
Comprehensive observability ensures CMMC compliance and operational excellence:
- Sentinel SIEM for centralized logging from GCC High and Azure Government resources
- Defender for Cloud for security posture monitoring and vulnerability assessment
- Azure Monitor for infrastructure health and performance metrics
- Automated alerts for security incidents, compliance violations, and performance degradation
- Custom dashboards showing CMMC compliance status and NIST 800-171 control validation

## Backup & Disaster Recovery
All CUI data and configurations are protected through:
- Exchange Online: Native redundancy and 10-year archiving
- SharePoint/OneDrive: Versioning and recycle bin with 93-day retention
- Azure VM backups: Daily automated backups with 30-day retention
- Azure storage: Geo-redundant storage (GRS) for disaster recovery
- RTO: 4 hours | RPO: 1 hour

---

## Technical Implementation Strategy

The implementation approach follows CMMC compliance best practices and NIST 800-171 control implementation methodologies.

## Example Implementation Patterns

The following patterns will guide the implementation approach:

- Phased security control implementation: Identity → Encryption → Monitoring → Incident Response
- Parallel commercial and GCC High operation during migration validation period
- Iterative compliance validation: Internal audit before C3PAO assessment

## Tooling Overview

The CMMC GCC High Enclave implementation leverages Microsoft cloud services and infrastructure-as-code tools to ensure consistent, repeatable, and compliant deployments.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|-----------------------|------------------------------|-------------------------------|
| Infrastructure | ARM Templates, Terraform | Infrastructure provisioning and configuration |
| Collaboration | M365 GCC High (Exchange, SharePoint, Teams) | CUI email, document management, secure collaboration |
| Compute | Azure Government VMs | CUI workload hosting |
| Security Monitoring | Sentinel SIEM, Defender for Cloud | Threat detection, compliance monitoring |
| Identity | Azure AD GCC High, CAC/PIV | DoD-compliant authentication and access control |
| Compliance | Microsoft Purview, Compliance Manager | DLP, information protection, NIST 800-171 validation |
| Encryption | Azure Key Vault, KMS | FIPS 140-2 encryption key management |

---

## Data Management

### Data Strategy

The data management approach follows industry best practices:

- CUI classification and labeling using Microsoft Purview sensitivity labels
- Automated DLP policies preventing unauthorized CUI sharing
- Email and file migration from commercial M365 with CUI validation
- Lifecycle management with retention policies aligned to DoD requirements
- eDiscovery capabilities for audit and legal hold requirements

### Data Security & Compliance
- FIPS 140-2 encryption for all CUI data at rest and in transit
- CUI access controls enforced through Azure AD roles and Conditional Access
- Audit logging for all CUI access via Sentinel SIEM (90-day retention minimum)
- Automated incident response for CUI data exfiltration attempts
- Secure deletion capabilities meeting NIST 800-88 media sanitization standards

---

---

# Security & Compliance

The implementation and target environment will be architected and validated to meet CMMC Level 2 requirements, implementing all 110 NIST 800-171 security controls. Vendor will adhere to FedRAMP High security standards and DoD cybersecurity frameworks.

## Identity & Access Management

The solution implements comprehensive identity and access controls:

- Azure AD GCC High with CAC/PIV smart card authentication (NIST 800-171 IA family)
- Multi-factor authentication (MFA) enforced for all users via Conditional Access
- Role-based access control (RBAC) with least-privilege access (3 roles: CUI processor, admin, reviewer)
- Privileged access management with Azure AD Privileged Identity Management (PIM)
- Account lifecycle management with automated provisioning and deprovisioning

## Monitoring & Threat Detection

Security monitoring capabilities include:

- Sentinel SIEM with 100GB/month log ingestion for comprehensive security monitoring
- Automated incident response playbooks for common threat scenarios
- Defender for Cloud continuous compliance monitoring and vulnerability assessment
- Integration with DoD Cyber Crime Center (DC3) for threat intelligence sharing
- Security alerts delivered via email, SMS, and Teams notifications (<15 minute response time)

## Compliance & Auditing

The solution supports the following compliance frameworks:

- CMMC Level 2 compliance: All 110 NIST 800-171 security requirements implemented
- FedRAMP High: GCC High and Azure Government environments meet DoD authorization standards
- NIST SP 800-53 Rev 5: Moderate impact baseline controls implemented
- Continuous compliance monitoring with automated NIST 800-171 control validation
- Audit logging for all CUI access, configuration changes, and administrative actions (90-day retention)

## Encryption & Key Management

Data protection is implemented through encryption at all layers:

- FIPS 140-2 validated encryption for all CUI data at rest and in transit
- Azure Key Vault for centralized encryption key management
- TLS 1.2+ for all network communications
- Email encryption with S/MIME for CUI email protection
- Encryption key rotation policies aligned to NIST SP 800-57 requirements

## Governance

Governance processes ensure consistent management of the solution:

- Change control: All security control changes require ISSO approval and C3PAO notification
- Incident response: Documented procedures for security incidents aligned to NIST SP 800-61
- Vulnerability management: Monthly vulnerability scans with 30-day remediation SLA for high/critical findings
- Configuration management: Baseline configurations documented in System Security Plan
- Continuous monitoring: Automated compliance validation with monthly NIST 800-171 scorecard

---

## Environments & Access

### Environment Strategy

| Environment | Purpose | Cloud Platform | Access |
|-------------|---------|------------|--------|
| Development | Security control testing, configuration validation | M365 GCC High Dev Tenant | Development team, ISSO |
| Production | Live CUI processing and storage | M365 GCC High + Azure Gov | CUI users, administrators, ISSO |

### Access Policies

Access control policies are defined as follows:

- CAC/PIV smart card authentication required for all users (no username/password access)
- MFA enforced via Conditional Access for all cloud access
- Administrator Access: Full M365 and Azure access for implementation team during project
- CUI Processor Access: Limited access to Exchange, SharePoint, Teams for CUI handling
- ISSO Access: Security monitoring, compliance validation, and audit capabilities

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the implementation lifecycle to ensure NIST 800-171 security controls are properly implemented and CMMC Level 2 requirements are met.

## Functional Validation

Functional testing ensures all features work as designed:

- End-to-end CUI workflow validation (email, document collaboration, file sharing)
- CAC/PIV authentication validation across all M365 and Azure services
- Conditional Access policy testing (MFA, device compliance, location restrictions)
- DLP policy validation (prevent unauthorized CUI sharing)
- eDiscovery and retention policy functional testing

## Performance & Load Testing

Performance validation ensures the solution meets SLA requirements:

- Email migration performance (100GB mailbox data)
- File migration throughput (500GB SharePoint/OneDrive)
- Sentinel log ingestion capacity (100GB/month sustained load)
- Concurrent user capacity (50 users)

## Security Testing

Security validation ensures protection against threats:

- NIST 800-171 control validation (all 110 security requirements)
- Penetration testing of Azure Government VMs and network perimeter
- CAC/PIV authentication bypass testing
- Encryption validation (data at rest and in transit)
- Vulnerability scanning of all Azure resources

## Disaster Recovery & Resilience Tests

DR testing validates backup and recovery capabilities:

- Azure VM backup and restore validation
- Exchange Online mailbox recovery testing
- SharePoint document recovery from recycle bin
- RTO/RPO validation (4-hour RTO, 1-hour RPO targets)

## User Acceptance Testing (UAT)

UAT is performed in coordination with Client business stakeholders:

- Performed in coordination with CUI users and business stakeholders
- Test environment provided by Vendor (GCC High pilot tenant)
- CAC/PIV authentication user experience validation
- Email and file access validation from various devices (Windows, Mac, mobile)

## Go-Live Readiness
A Go-Live Readiness Checklist will be delivered including:
- All 110 NIST 800-171 controls implemented and validated
- Internal compliance audit complete with no open findings
- CAC/PIV authentication operational for all users
- Sentinel SIEM and Defender for Cloud monitoring operational
- C3PAO pre-assessment readiness review complete
- System Security Plan (SSP) complete and approved
- Knowledge transfer sessions complete

---

## Cutover Plan

The cutover to Microsoft 365 GCC High and Azure Government will be executed using a controlled, phased approach to minimize business disruption and ensure zero CUI data loss during migration from commercial M365 or on-premises systems.

**Cutover Approach:**

The implementation follows a **pilot-then-production** strategy where a small group of CUI users (5-10) will migrate first to validate migration quality, CAC/PIV authentication, and CUI workflows before full production cutover.

1. **Pilot Phase (Week 1):** Migrate 5-10 CUI users to GCC High. Validate email/file migration quality, CAC/PIV authentication, Teams collaboration, and DLP policies. Monitor for issues with zero production impact.

2. **Validation Period (Week 2):** Pilot users operate in GCC High for 2 weeks while remaining users continue on commercial M365. Collect feedback, adjust configurations, and validate CUI workflows meet NIST 800-171 requirements.

3. **Production Migration (Week 3-4):** Migrate remaining 40-45 users in departmental waves:
   - Week 3: 20 users (Department A and B)
   - Week 4: 20-25 users (Department C and D)
   - Each wave includes weekend migration window with validation on Monday

4. **Hypercare Period (4 weeks post-cutover):** Daily health checks, rapid issue resolution, and user support to ensure smooth transition to GCC High environment.

The cutover will be executed during pre-approved weekend maintenance windows with documented rollback procedures available if critical migration issues arise.

## Cutover Checklist

The following checklist will guide the cutover execution:

- Pre-cutover validation: All security controls implemented, internal audit complete
- GCC High environment validated and CAC/PIV authentication operational
- Rollback procedures documented and rehearsed
- User communication completed (migration schedule, CAC/PIV instructions)
- Enable email routing to GCC High Exchange Online
- Monitor first batch of migrated mailboxes for delivery issues
- Verify file access from SharePoint/OneDrive with zero data loss
- Daily monitoring during hypercare period (4 weeks)

## Rollback Strategy

Comprehensive rollback procedures in case of critical issues:

- Documented rollback triggers (>5% data loss, CAC/PIV authentication failure, critical security control failure)
- Rollback procedures: Revert email routing to source system, restore file access
- Root cause analysis and fix validation before retry
- Communication plan for stakeholders and CUI users
- Preserve all migration logs and audit trails for C3PAO assessment evidence

---

---

# Handover & Support

## Handover Artifacts

The following artifacts will be delivered upon project completion:

- As-Built documentation including GCC High architecture, Azure Government infrastructure, and security control implementation
- System Security Plan (SSP) with NIST 800-171 control narratives and evidence artifacts
- Operations runbook with incident response procedures, vulnerability management, and compliance monitoring
- Sentinel SIEM playbook documentation and alert configuration reference
- Microsoft 365 and Azure Government cost optimization recommendations
- C3PAO assessment evidence package and certification documentation

## Knowledge Transfer

Knowledge transfer ensures the Client team can effectively operate the solution:

- Live knowledge transfer sessions for ISSO/ISSM and security operations team
- Microsoft 365 GCC High administration training (Exchange, SharePoint, Teams, Purview)
- Azure Government infrastructure management training
- Sentinel SIEM monitoring and incident response training
- CAC/PIV authentication troubleshooting and user support training
- Recorded training materials hosted in SharePoint document library

## Hypercare Support

Post-implementation support to ensure smooth transition to Client CMMC compliance operations:

**Duration:** 4 weeks post-certification (30 days)

**Coverage:**
- Business hours support (8 AM - 6 PM EST)
- 4-hour response time for critical security incidents
- Daily health check calls (first 2 weeks)
- Weekly CMMC compliance review meetings

**Scope:**
- Security incident investigation and response
- Compliance monitoring and NIST 800-171 control validation
- Configuration adjustments and optimization
- Knowledge transfer continuation for ISSO/ISSM
- C3PAO finding remediation support

## Managed Services Transition (Optional)

Post-hypercare, Client may transition to ongoing CMMC managed services:

**Managed Services Options:**
- 24/7 security monitoring and incident response for Sentinel SIEM
- Continuous NIST 800-171 compliance monitoring and validation
- Monthly vulnerability scanning and remediation coordination
- Annual CMMC recertification support and C3PAO coordination
- Quarterly security posture reviews and optimization recommendations

**Transition Approach:**
- Evaluation of managed services requirements during hypercare
- Service Level Agreement (SLA) definition for CMMC compliance operations
- Separate managed services contract and pricing
- Seamless transition from hypercare to managed services

---

## Assumptions

### General Assumptions

This engagement is based on the following general assumptions:

- Client will provide representative CUI documents for DLP policy configuration and migration testing
- Existing user identities can be synchronized to Azure AD GCC High (no complex multi-forest Active Directory)
- CAC/PIV smart cards are available for all 50 CUI users with certificates issued by DoD PKI
- Business requirements for CUI handling will remain stable during implementation (no additional document types or workflows)
- Client technical team will be available for requirements validation, testing, and C3PAO assessment support
- Azure Government and M365 GCC High subscriptions will be provisioned within 2 weeks of project start
- C3PAO will be selected and engaged by Month 4 to enable Month 6 assessment completion
- Security and compliance approval processes will not delay critical path activities beyond 2-week windows
- Client will handle Microsoft GCC High and Azure Government service costs directly (estimated $15,000-$20,000/month)

---

## Dependencies

### Project Dependencies

The following dependencies must be satisfied for successful project execution:

- Azure/M365 Access: Client provides Global Administrator access to M365 tenant and Azure subscription for GCC High and Azure Government provisioning
- CAC/PIV Cards: All 50 CUI users have valid CAC/PIV smart cards issued by DoD PKI (certificates not expired)
- CUI Migration Data: Client provides access to source email and file systems for migration (commercial M365 or on-premises Exchange/file servers)
- C3PAO Selection: Client selects and engages CMMC Third-Party Assessment Organization by Month 4 (Vendor provides selection criteria and evaluation support)
- ISSO/ISSM Availability: Designated ISSO/ISSM available for System Security Plan development, control validation, and C3PAO assessment
- Security Approvals: Authority to Operate (ATO) or equivalent security approval obtained on schedule to avoid deployment delays
- Network Access: ExpressRoute connectivity (if required) provisioned by Month 3 for Azure Government integration
- Testing Resources: CUI users available for pilot migration, UAT, and CAC/PIV authentication validation
- Change Freeze: No major organizational changes (mergers, acquisitions, compliance framework changes) during C3PAO assessment period
- Go-Live Approval: Executive and ISSO approval authority available for production cutover and C3PAO assessment decisions

---

---

# Investment Summary

This section provides a comprehensive overview of the engagement investment:

**Small Scope Implementation:** This pricing reflects a 50-user CMMC Level 2 deployment designed for small defense contractors pursuing DoD contracts. For larger organizations (100-200 users or Level 3 requirements), please request medium or large scope pricing.

## Total Investment

The following table summarizes the 3-year total cost of ownership for the CMMC GCC High Enclave implementation including professional services, cloud infrastructure, software licenses, and ongoing support.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 18, 14, 12, 11, 13] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $0 | $0 | $0 | $0 | $0 | $0 |
| Cloud Services | $47,640 | $0 | $47,640 | $47,640 | $47,640 | $142,920 |
| Software Licenses | $87,600 | $0 | $87,600 | $87,600 | $87,600 | $262,800 |
| Support & Maintenance | $18,000 | $0 | $18,000 | $18,000 | $18,000 | $54,000 |
| **TOTAL INVESTMENT** | **$153,240** | **$0** | **$153,240** | **$153,240** | **$153,240** | **$459,720** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $0
- No Microsoft partner credits available for GCC High government licensing
- Microsoft 365 GCC High and Azure Government use government-only pricing (no commercial discounts)
- Credits are Year 1 only; Years 2-3 reflect standard government pricing

**Investment Comparison:**
- **Year 1 Net Investment:** $178,040 (enables DoD contract pursuit immediately)
- **3-Year Total Cost of Ownership:** $534,120
- **Expected ROI:** 3-6 month payback based on $8M DoD contract opportunity

## Cost Components

**Professional Services** ($0 - labor costs included in estimate): Labor costs for gap assessment, architecture, implementation, C3PAO support, and knowledge transfer. Breakdown:
- Discovery & Architecture (112 hours): NIST gap assessment, GCC High design, Azure Government architecture
- Implementation (480 hours): GCC High deployment, Azure Government provisioning, CAC/PIV integration, Sentinel SIEM, security controls
- C3PAO Support & Training (64 hours): C3PAO coordination, ISSO/ISSM training, knowledge transfer

**Cloud Infrastructure** ($178,040/year): Microsoft 365 GCC High and Azure Government services sized for 50 users with Level 2 compliance:
- Microsoft 365 GCC High E5 (50 users @ $35/user/month): $21,000/year
- Azure Government compute, storage, networking: $84,000/year
- Sentinel SIEM (100GB/month log ingestion): $36,000/year
- ExpressRoute connectivity (1 Gbps): $37,040/year

**Software Licenses & Subscriptions** ($0/year): No additional licenses required (included in GCC High E5)

**Support & Maintenance** ($0/year): 30-day hypercare support included in professional services
- Post-hypercare managed services available under separate contract (optional)
- Estimated $12,000/year for ongoing CMMC compliance monitoring and annual recertification support

---

## Payment Terms

### Pricing Model
- Fixed price for professional services (NIST gap assessment, implementation, C3PAO support)
- Microsoft GCC High and Azure Government costs billed directly by Microsoft (pass-through)

### Payment Schedule
- 25% upon SOW execution and project kickoff
- 30% upon completion of GCC High deployment (Milestone M2)
- 30% upon completion of Azure Government and security controls (Milestone M4)
- 15% upon CMMC Level 2 certification completion (Milestone: Certification)

---

## Invoicing & Expenses

Invoicing and expense policies for this engagement:

### Invoicing
- Milestone-based invoicing per Payment Terms above
- Net 30 payment terms
- Invoices submitted upon milestone completion and acceptance

### Expenses
- Microsoft GCC High and Azure Government costs billed directly by Microsoft to Client
- Small scope sizing: $178,040/year = ~$14,837/month for 50 users with Level 2 compliance
- Costs scale with user count and Azure Government resource usage
- Travel and on-site expenses reimbursable at cost with prior approval (remote-first delivery model)

---

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

## Scope Changes

Change control procedures for this engagement:

- Changes to CMMC level (Level 3/4/5), user count, CUI workload scope, or security requirements require formal change requests
- Change requests may impact project timeline, budget, and C3PAO assessment schedule

## Intellectual Property

Intellectual property rights are defined as follows:

- Client retains ownership of all CUI data and business information
- Vendor retains ownership of proprietary CMMC implementation methodologies and frameworks
- GCC High and Azure Government configurations become Client property upon final payment
- System Security Plan (SSP) and compliance documentation transfer to Client upon certification

## Service Levels

Service level commitments for this engagement:

- CMMC Level 2 certification: All 110 NIST 800-171 controls implemented and validated
- C3PAO assessment: Pass all assessment objectives with zero open findings (POA&Ms acceptable per CMMC requirements)
- System uptime: 99.9% for GCC High and Azure Government (per Microsoft SLA)
- 30-day hypercare support for post-certification optimization
- Post-hypercare managed services available under separate agreement

## Liability

Liability terms and limitations:

- CMMC certification timeline dependent on C3PAO availability and DoD Cyber AB approval processes
- Performance may vary based on CUI document types and complexity beyond initial scope
- Ongoing compliance monitoring recommended as NIST 800-171 requirements evolve
- Liability caps as agreed in MSA

## Confidentiality

Confidentiality obligations for both parties:

- Both parties agree to maintain strict confidentiality of CUI data, business information, and CMMC implementation details
- All exchanged artifacts under NDA protection and NIST 800-171 safeguarding requirements

## Termination

Termination provisions for this engagement:

- Mutually terminable per MSA terms, subject to payment for completed work and C3PAO commitments

## Governing Law

This agreement shall be governed by the laws of [State/Region].

- Agreement governed under the laws of [State/Region]

---

---

# Sign-Off

By signing below, both parties agree to the scope, approach, and terms outlined in this Statement of Work.

**Client Authorized Signatory:**
Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Service Provider Authorized Signatory:**
Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

---

*This Statement of Work constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter.*
