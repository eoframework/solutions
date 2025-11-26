---
document_title: Statement of Work
technology_provider: Cisco Systems
project_name: Cisco ISE Secure Network Access
client_name: [Client Name]
client_contact: [Contact Name | Email | Phone]
consulting_company: [Consulting Company Name]
consultant_contact: [Contact Name | Email | Phone]
opportunity_no: [OPP-YYYY-###]
document_date: [Month DD, YYYY]
version: [1.0]
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for the Cisco ISE Secure Network Access project for [Client Name]. This engagement will deliver a zero-trust network access solution with 802.1X authentication, TrustSec micro-segmentation, and BYOD support, reducing unauthorized access by 90% and eliminating 70% of helpdesk tickets through self-service provisioning.

**Project Duration:** 16 weeks

---

# Background & Objectives

## Current State

[Client Name] currently operates a network without centralized authentication and authorization. Key challenges include:
- **Unauthorized Access:** No authentication required for wired network access creating security risk
- **No Visibility:** Unable to identify who is connecting what device where and when
- **Manual BYOD Provisioning:** Helpdesk manually provisions certificates for iOS and Android devices
- **Compliance Gaps:** Difficulty meeting PCI DSS and HIPAA requirements for network access control
- **Lateral Threat Movement:** No segmentation allowing malware to spread across network

## Business Objectives

The following objectives define the key business outcomes this engagement will deliver:

- **Eliminate Unauthorized Access:** Deploy 802.1X authentication achieving 100% device authentication compliance
- **Enable Zero Trust:** Implement TrustSec micro-segmentation reducing lateral threat movement by 85%
- **Automate BYOD:** Self-service onboarding reducing helpdesk tickets by 70% and provisioning time to 5 minutes
- **Achieve Compliance:** Complete audit trails and access control meeting PCI DSS and HIPAA requirements
- **Improve Visibility:** Real-time visibility into all connected devices with profiling and classification
- **Reduce Security Incidents:** 90% reduction in network security breaches through mandatory authentication

## Success Metrics

Success will be measured against the following quantifiable metrics:

- 100% device authentication compliance (wired and wireless)
- 90% reduction in unauthorized access incidents
- 70% reduction in BYOD helpdesk tickets
- ROI realization within 24 months
- Complete who/what/when/where audit trail for compliance

---

# Scope of Work

## In Scope

The following items are included within the scope of this engagement:

- Network assessment for 802.1X readiness (switches and WLCs)
- ISE appliance deployment (primary + secondary HA)
- Active Directory integration with LDAP
- Authentication and authorization policy framework design
- 802.1X wired and wireless deployment
- BYOD self-service portal for iOS and Android
- Guest portal with sponsor-based workflow
- TrustSec security group tag (SGT) design and deployment
- Network infrastructure integration (switches and WLCs)
- Lab validation and pilot with IT department (50-100 users)
- Phased production rollout (wired → wireless → BYOD → guest)
- Team training (40 hours) for administrators and helpdesk
- 4-week hypercare support period

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Primary Features/Capabilities | ISE for 1000 users 2000 devices |
| Solution Scope | Customization Level | Standard ISE deployment |
| Integration | External System Integrations | 2 systems (AD + switches) |
| Integration | Data Sources | User identity only |
| User Base | Total Users | 1000 employees and guests |
| User Base | User Roles | 2 roles (employee + guest) |
| Data Volume | Data Processing Volume | 2000 endpoint authentications |
| Data Volume | Data Storage Requirements | 100 GB (90-day logs) |
| Technical Environment | Deployment Regions | Single site |
| Technical Environment | Availability Requirements | Standard (99.5%) |
| Technical Environment | Infrastructure Complexity | Basic campus network |
| Security & Compliance | Security Requirements | Basic 802.1X authentication |
| Security & Compliance | Compliance Frameworks | Basic logging |
| Performance | Performance Requirements | Standard authentication speed |
| Environment | Deployment Environments | Production only |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*

## Out of Scope

These items are not in scope unless added via change control:
- Hardware procurement beyond ISE 3615 appliances
- Network switch or wireless controller upgrades
- Certificate authority (CA) deployment (client-provided)
- Mobile Device Management (MDM) integration
- Posture assessment and compliance scanning (optional add-on)
- NAC for IoT devices beyond basic MAB (optional add-on)
- Managed services post-hypercare period

## Activities

### Phase 1 – Foundation (Weeks 1-4)

Network infrastructure is assessed and ISE foundation deployed.

Key activities:
- Network assessment for 802.1X readiness and switch/WLC compatibility
- ISE appliance deployment (primary + secondary HA configuration)
- Active Directory integration with LDAP and identity source setup
- Security requirements gathering and policy framework design
- BYOD and guest access requirements definition

**Deliverable:** Network Assessment Report and ISE Architecture Design

### Phase 2 – Policy Development (Weeks 5-8)

Authentication, authorization, and TrustSec policies are configured.

Key activities:
- Authentication and authorization policy framework implementation
- 802.1X wired and wireless configuration with fallback MAB
- BYOD self-service portal configuration for iOS and Android
- Guest portal setup with sponsor workflow and approval process
- Lab validation with end-to-end authentication testing

**Deliverable:** Policy Configuration Guide and Lab Test Results

### Phase 3 – TrustSec & Integration (Weeks 9-12)

TrustSec segmentation is deployed and network infrastructure integrated.

Key activities:
- TrustSec security group tag (SGT) design and matrix configuration
- Network infrastructure integration (switches and WLCs configured for 802.1X)
- Pilot deployment with IT department (50-100 users) for validation
- BYOD testing with iOS and Android devices
- Failover testing for ISE HA validation

**Deliverable:** TrustSec Configuration and Pilot Results Report

### Phase 4 – Deployment (Weeks 13-16)

Production rollout in phased waves with training and support.

Key activities:
- Production rollout Phase 1: Wired 802.1X deployment (60 hours)
- Production rollout Phase 2: Wireless 802.1X and BYOD (50 hours)
- Guest WiFi enablement with portal and sponsor workflows (24 hours)
- TrustSec policy enforcement activation (40 hours)
- Team training (40 hours) for administrators and helpdesk
- Hypercare support activation (60 hours over 4 weeks)

**Deliverable:** As-Built Documentation and Operational Runbooks

---

# Deliverables & Timeline

This section outlines the key deliverables, project milestones, and timeline for the ISE Secure Access implementation. All deliverables are subject to formal acceptance by designated client stakeholders before proceeding to subsequent phases.

## Deliverables

The following deliverables will be produced throughout the project lifecycle, with formal acceptance required from designated client stakeholders:

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Network Assessment Report | Document | Week 4 | Client IT Lead |
| 2 | Policy Configuration Guide | Document | Week 8 | Security Lead |
| 3 | Pilot Results Report | Document | Week 12 | Network Lead |
| 4 | As-Built Documentation | Document | Week 16 | Client IT Lead |
| 5 | Training Materials | Document | Week 16 | IT Team |

## Project Milestones

The project will be tracked against the following key milestones, representing major completion points and readiness gates for the next phase:

<!-- TABLE_CONFIG: widths=[20, 55, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 - Foundation Complete | ISE HA deployed with AD integration | Week 4 |
| M2 - Policies Configured | 802.1X and BYOD policies operational | Week 8 |
| M3 - Pilot Success | IT department authenticated via 802.1X | Week 12 |
| M4 - Go-Live | All users authenticated with TrustSec enabled | Week 16 |
| Hypercare End | Support period complete | Week 20 |

---

# Roles & Responsibilities

This section defines the roles, responsibilities, and accountabilities for both Vendor and Client teams throughout the project lifecycle using a RACI matrix framework.

## RACI Matrix

The following RACI matrix defines responsibility assignments for key project activities across Vendor and Client roles:

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO ISE Eng | EO Security | Client Net | Client Sec | SME |
|-----------|-------|----------------|------------|-------------|------------|------------|-----|
| Discovery & Requirements | A | R | R | C | C | C | C |
| ISE Deployment | C | A | R | C | C | I | I |
| Policy Configuration | C | A | R | R | C | C | I |
| Network Integration | C | R | A | C | A | I | I |
| TrustSec Configuration | C | R | R | A | I | A | I |
| Testing & Validation | R | R | C | R | A | C | I |
| Knowledge Transfer | A | R | R | C | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

The following personnel will be assigned to this engagement:

**Vendor Team:**
- EO Project Manager: Overall delivery accountability
- EO Quarterback: Technical design and architecture oversight
- EO ISE Engineer: ISE deployment and policy configuration
- EO Security Engineer: TrustSec and security policy design

**Client Team:**
- Network Lead: Primary technical contact and switch configuration
- Security Lead: Security policy approval and compliance
- Helpdesk Manager: User support and BYOD workflow training
- Operations Team: Day-to-day authentication operations

---

# Architecture & Design

## Architecture Overview

The following diagram illustrates the high-level architecture for the proposed solution:

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1: ISE Secure Network Access Architecture** - Zero-trust authentication and micro-segmentation

The proposed architecture provides centralized network access control with zero-trust principles. Key components include:

- **Identity Platform:** Cisco ISE 3615 appliances (primary + secondary HA)
- **Identity Source:** Active Directory integration with LDAP
- **Enforcement Points:** Catalyst switches and wireless LAN controllers
- **User Access:** 802.1X for corporate, BYOD self-service, guest portal

## Architecture Type

This solution follows a **Policy Service Node (PSN)** architecture pattern. Key characteristics:

- **Deployment Model:** Distributed PSN nodes with centralized policy administration
- **High Availability:** Primary and secondary nodes with automatic failover
- **Authentication Flow:** RADIUS-based with CoA for dynamic policy enforcement
- **Segmentation:** TrustSec security group tags (SGT) for micro-segmentation

The architecture supports 1000 users and 2000 endpoints with scalability to 3000+ users.

## Technical Implementation Strategy

The deployment follows a phased rollout approach:

**Pilot Phase (Week 12):**
- Deploy 802.1X to IT department (50-100 users)
- Validate authentication workflow and troubleshoot issues
- Refine policies based on pilot feedback

**Production Phases (Weeks 13-16):**
- Phase 1: Wired 802.1X deployment to all corporate users
- Phase 2: Wireless 802.1X and BYOD enablement
- Phase 3: Guest WiFi portal and sponsor workflow
- Phase 4: TrustSec enforcement with security group policies

**Change Management:**
- Communicate rollout schedule to users
- Helpdesk training before each phase
- Monitor authentication success rates
- Rapid response to authentication failures

---

# Security & Compliance

## Identity & Access Management

Identity and access controls ensure secure operations:

- 802.1X authentication with EAP-TLS or PEAP-MSCHAPv2
- Active Directory integration for centralized identity
- Multi-factor authentication (MFA) for administrative access to ISE
- Role-based access control (RBAC) for ISE administrators

## Authentication Methods

The solution supports the following authentication methods:

- **802.1X (EAP):** Corporate users and domain-joined devices
- **MAC Authentication Bypass (MAB):** Printers, IoT devices, legacy systems
- **Guest Authentication:** Portal-based with sponsor approval workflow
- **BYOD:** Self-service certificate provisioning for iOS and Android

## TrustSec Micro-Segmentation

The TrustSec micro-segmentation implementation includes the following components:

- Security Group Tags (SGT) for dynamic device classification
- Policy matrix for group-based access control
- Inline tagging on switches and enforcement at network edge
- Scalable segmentation without VLANs

## Compliance & Auditing

The solution addresses the following compliance and audit requirements:

- Complete audit trail (who, what device, when, where)
- Authentication success/failure logging
- Policy change tracking and approval workflows
- Compliance reporting for PCI DSS and HIPAA

---

# Testing & Validation

## Functional Validation

Comprehensive testing ensures authentication works correctly:

**Authentication Testing:**
- 802.1X wired authentication (domain computers)
- 802.1X wireless authentication (corporate SSID)
- MAB for printers and IoT devices
- Guest portal authentication and sponsor approval
- BYOD certificate provisioning for iOS and Android

**Policy Testing:**
- Authorization policies (VLANs, ACLs, SGTs)
- Fallback policies (MAB for non-supplicant devices)
- Failed authentication handling
- Session timeout and re-authentication

## Security Testing

Security validation for zero-trust compliance:

**Vulnerability Assessment:**
- ISE appliance security hardening verification
- Certificate validation and expiration monitoring
- Encrypted RADIUS communication (EAP-TLS)

**Compliance Validation:**
- Audit logging completeness
- Access control verification
- Authentication success rate monitoring

## User Acceptance Testing (UAT)

UAT performed with pilot users:

**UAT Approach:**
- IT department pilot (50-100 users)
- Corporate device authentication testing
- BYOD onboarding workflow validation
- Guest access workflow testing

**Acceptance Criteria:**
- Authentication success rate > 95%
- BYOD onboarding < 5 minutes
- Guest portal workflow functional
- Helpdesk can troubleshoot authentication issues

---

# Handover & Support

## Handover Artifacts

Upon successful implementation:

**Documentation Deliverables:**
- As-built architecture diagrams
- ISE configuration documentation
- Policy framework and authorization rules
- Network infrastructure 802.1X configuration
- TrustSec SGT matrix and policy documentation

**Operational Deliverables:**
- Operations runbooks for daily tasks
- Troubleshooting guides for authentication failures
- BYOD onboarding user guide
- Guest portal administration guide
- Helpdesk escalation procedures

**Knowledge Assets:**
- Recorded training sessions (40 hours)
- ISE administrator credentials
- Certificate templates and provisioning workflows
- Vendor support contacts

## Knowledge Transfer

Knowledge transfer ensures the Client team can effectively manage and operate the solution:

**Training Sessions:**
- 24 hours for ISE administrators
- 16 hours for helpdesk staff
- ISE operations and monitoring
- Policy management and troubleshooting
- BYOD and guest portal administration
- Authentication failure diagnosis

**Documentation Package:**
- As-built architecture documentation
- Configuration management guide
- Operational runbooks and SOPs
- Troubleshooting guide
- User guides for BYOD and guest access

## Hypercare Support

**Duration:** 4 weeks post-go-live

**Coverage:**
- Business hours support (8 AM - 6 PM local time)
- 4-hour response time for critical issues
- Daily check-ins (first 2 weeks)
- Weekly status meetings

**Scope:**
- Authentication issue investigation
- Policy adjustments and fine-tuning
- BYOD and guest portal optimization
- Knowledge transfer continuation

## Assumptions

### General Assumptions

The following general assumptions apply to this engagement:

**Client Responsibilities:**
- Client will provide access to switches and wireless LAN controllers
- Client network team available for 802.1X configuration
- Client Active Directory team available for LDAP integration
- Client will handle internal communication and change management

**Technical Environment:**
- Network switches support 802.1X and RADIUS authentication
- Wireless LAN controllers support 802.1X and dynamic VLAN assignment
- Active Directory operational with user accounts and OUs defined
- Data center rack space and power available for ISE appliances

**Project Execution:**
- Project scope and requirements remain stable
- Resources available per project plan
- No major network changes during pilot and rollout
- Security and compliance approvals timely

---

# Investment Summary

This section provides a comprehensive breakdown of the total investment required for the ISE Secure Access implementation, including professional services, hardware, software licensing, and ongoing support costs over a 3-year period.

## Total Investment

The following table summarizes the total cost of ownership for this engagement across all cost categories and years:

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 12, 15, 11, 11, 11] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $0 | $0 | $0 | $0 | $0 | $0 |
| Hardware | $80,000 | $0 | $80,000 | $0 | $0 | $80,000 |
| Software Licenses | $75,000 | ($10,000) | $65,000 | $75,000 | $75,000 | $215,000 |
| Support & Maintenance | $31,000 | $0 | $31,000 | $31,000 | $31,000 | $93,000 |
| **TOTAL INVESTMENT** | **$186,000** | **($10,000)** | **$176,000** | **$106,000** | **$106,000** | **$388,000** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $10,000 (ISE license promotion - 20% discount)

**Annual Recurring Cost:** $106,000/year (software licenses and support)

## Payment Terms

This section outlines the pricing model and payment schedule for the engagement:

**Pricing Model:** Fixed price with milestone-based payments

**Payment Schedule:**
- 30% upon SOW execution and project kickoff ($24,660)
- 30% upon completion of Phase 2 - Policies Configured ($24,660)
- 25% upon completion of Phase 3 - Pilot Success ($20,550)
- 15% upon successful go-live and project acceptance ($12,330)

**Invoicing:** Monthly invoicing based on milestones completed. Net 30 payment terms.

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) between Vendor and Client.

## Scope Changes

Any changes to scope, schedule, or cost require a formal Change Request approved by both parties.

## Intellectual Property

Intellectual property rights are allocated as follows:

- Client retains ownership of all deliverables and configurations
- Vendor retains proprietary methodologies and tools
- Pre-existing IP remains with original owner

## Confidentiality

Confidentiality obligations govern information exchanged during this engagement:

- All artifacts under NDA protection
- Client data handled per security requirements
- No disclosure to third parties without consent

---

# Sign-Off

By signing below, both parties agree to the scope, approach, and terms outlined in this Statement of Work.

**Client Authorized Signatory:**

Name: ______________________________

Title: ______________________________

Signature: __________________________

Date: ______________________________

**Service Provider Authorized Signatory:**

Name: ______________________________

Title: ______________________________

Signature: __________________________

Date: ______________________________

---
