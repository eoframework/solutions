---
# Document Metadata (Simplified)
document_title: Statement of Work
technology_provider: Cisco Systems
project_name: Cisco SD-WAN Enterprise
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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for the Cisco SD-WAN Enterprise project for [Client Name]. This engagement will transform WAN operations by replacing expensive MPLS circuits with cloud-ready SD-WAN, reducing WAN costs by 60% and enabling 95% faster site deployment through zero-touch provisioning.

**Project Duration:** 16 weeks

---

# Background & Objectives

## Current State

[Client Name] currently operates a traditional MPLS-based WAN with 25 branch offices. Key challenges include:
- **High WAN Costs:** $300K annual MPLS circuit costs with limited bandwidth and long-term contracts
- **Slow Site Deployment:** New branch offices take 8 weeks to provision MPLS circuits
- **Poor Cloud Performance:** Cloud applications (Office 365, Salesforce) backhauled through data center
- **Limited Bandwidth:** MPLS provides only 10-50 Mbps per site constraining business growth
- **Complex Management:** Separate management for MPLS, internet, and routing policies

## Business Objectives

- **Reduce WAN Costs:** Achieve 60% cost reduction by replacing $300K MPLS with $176K SD-WAN (broadband + LTE)
- **Accelerate Site Deployment:** Enable 95% faster provisioning (2 hours vs 8 weeks) with zero-touch router deployment
- **Optimize Cloud Access:** Direct internet breakout improving Office 365 performance by 50%
- **Increase Bandwidth:** 10x bandwidth increase (10-50 Mbps MPLS → 100 Mbps broadband) at lower cost
- **Simplify Management:** Centralized vManage dashboard replacing CLI on 27 routers
- **Enable Flexibility:** Agile WAN with dual circuits (broadband + LTE) and automatic failover

## Success Metrics

- 60% WAN cost reduction ($300K → $176K annually)
- 95% faster site deployment (8 weeks → 2 hours)
- 50% improvement in cloud application performance
- 99.9% WAN uptime with dual circuits and LTE backup
- ROI realization within 18 months

---

# Scope of Work

## In Scope

- Current WAN assessment (MPLS circuits, bandwidth, application analysis)
- SD-WAN architecture design with hub-spoke topology
- Circuit availability analysis (broadband and LTE at 25 sites)
- Application-aware routing policy design for SaaS and business apps
- vManage, vSmart, vBond controller deployment
- Hub router configuration (2x ISR 4451 at data centers)
- Branch router deployment (25x ISR 4331 with zero-touch provisioning)
- Application routing and SLA policy configuration
- Security policy setup (firewall, VPN, cloud integration)
- Lab validation (GNS3 or CML testing)
- Pilot deployment (3 sites for validation)
- Production rollout (22 sites in 2 waves)
- MPLS circuit decommissioning after validation
- Team training on vManage operations (24 hours)
- 4-week hypercare support period

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Primary Features/Capabilities | SD-WAN for 25 branch offices |
| Solution Scope | Customization Level | Standard SD-WAN deployment |
| Integration | External System Integrations | 2 systems (cloud + monitoring) |
| Integration | Data Sources | WAN telemetry only |
| User Base | Total Users | 5 network engineers |
| User Base | User Roles | 2 roles (admin + operator) |
| Data Volume | Data Processing Volume | 25 sites WAN traffic |
| Data Volume | Data Storage Requirements | 200 GB (90-day logs) |
| Technical Environment | Deployment Regions | Single region |
| Technical Environment | Availability Requirements | Standard (99.5%) |
| Technical Environment | Infrastructure Complexity | Basic hub-spoke WAN |
| Security & Compliance | Security Requirements | Basic VPN encryption |
| Security & Compliance | Compliance Frameworks | Basic logging |
| Performance | Performance Requirements | Standard application routing |
| Environment | Deployment Environments | Production only |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*

## Out of Scope

These items are not in scope unless added via change control:
- Hardware procurement beyond ISR routers and controllers
- WAN circuit procurement (client responsibility)
- Legacy router decommissioning and disposal
- Application optimization beyond routing policies
- Managed services post-hypercare period
- SD-WAN security advanced features (Umbrella, ThousandEyes)

## Activities

### Phase 1 – Design & Planning (Weeks 1-4)

Current WAN is assessed and SD-WAN solution designed.

Key activities:
- WAN assessment: MPLS circuits, bandwidth, costs, application analysis (80 hours)
- SD-WAN architecture design with hub-spoke topology and redundancy
- Circuit availability analysis: broadband and LTE feasibility at 25 sites
- Application-aware routing policy design for SaaS and business-critical apps
- Migration strategy with pilot sites and phased rollout plan

**Deliverable:** WAN Assessment Report and SD-WAN Architecture Design

### Phase 2 – Infrastructure Deployment (Weeks 5-8)

SD-WAN controllers and hub routers are deployed.

Key activities:
- vManage, vSmart, vBond controller deployment (data center or cloud) (40 hours)
- Hub router configuration: 2x ISR 4451 with HA at data centers (40 hours)
- Application routing and SLA policy configuration (60 hours)
- Security policy setup: firewall rules, VPN, cloud integration (40 hours)
- Lab validation with GNS3 or CML testing (32 hours)

**Deliverable:** SD-WAN Controllers and Hub Router Configuration

### Phase 3 – Site Deployment (Weeks 9-12)

Branch sites are deployed in pilot and production waves.

Key activities:
- Pilot deployment: 3 low-risk sites for validation (60 hours)
- Performance testing: application SLA compliance and failover scenarios (40 hours)
- Production Wave 1: deploy 10 sites with zero-touch provisioning (60 hours)
- Production Wave 2: deploy remaining 12 sites (60 hours)
- MPLS dual-run period with gradual traffic migration

**Deliverable:** Deployed SD-WAN Sites with Performance Test Results

### Phase 4 – Optimization (Weeks 13-16)

MPLS is decommissioned and operations team trained.

Key activities:
- MPLS circuit decommissioning after SD-WAN validation (40 hours)
- Performance optimization and policy fine-tuning (24 hours)
- Team training on vManage operations and troubleshooting (24 hours)
- Documentation and knowledge transfer
- Hypercare support activation (60 hours over 4 weeks)

**Deliverable:** As-Built Documentation and Operational Runbooks

---

# Deliverables & Timeline

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | WAN Assessment Report | Document | Week 4 | Client IT Lead |
| 2 | SD-WAN Architecture Design | Document | Week 4 | Network Lead |
| 3 | Hub Router Configuration | Infrastructure | Week 8 | Infrastructure Lead |
| 4 | Deployed SD-WAN Sites | Infrastructure | Week 12 | Operations Lead |
| 5 | As-Built Documentation | Document | Week 16 | Client IT Lead |

## Project Milestones

<!-- TABLE_CONFIG: widths=[20, 55, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 - Design Complete | SD-WAN architecture approved | Week 4 |
| M2 - Controllers Deployed | vManage vSmart vBond operational | Week 8 |
| M3 - Pilot Success | 3 sites validated on SD-WAN | Week 10 |
| M4 - Deployment Complete | All 25 sites on SD-WAN | Week 12 |
| M5 - MPLS Decommissioned | Legacy circuits disconnected | Week 16 |
| Hypercare End | Support period complete | Week 20 |

---

# Roles & Responsibilities

## RACI Matrix

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO WAN Eng | EO SD-WAN | Client Net | Client Ops | SME |
|-----------|-------|----------------|------------|-----------|------------|------------|-----|
| Discovery & Requirements | A | R | R | C | C | I | C |
| SD-WAN Architecture | C | A | R | R | C | I | I |
| Controller Deployment | C | A | C | R | C | I | I |
| Hub Router Config | C | R | A | R | C | I | I |
| Site Deployment | C | R | C | A | A | C | I |
| Testing & Validation | R | R | C | R | A | C | I |
| Knowledge Transfer | A | R | R | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- EO Project Manager: Overall delivery accountability
- EO Quarterback: Technical design and architecture oversight
- EO WAN Engineer: WAN assessment and architecture design
- EO SD-WAN Engineer: Controller and router deployment

**Client Team:**
- Network Lead: Primary technical contact and WAN coordination
- Operations Lead: Site coordination and circuit procurement
- Application SME: Application performance requirements
- Telecom Lead: Circuit orders and MPLS decommissioning

---

# Architecture & Design

## Architecture Overview

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1: SD-WAN Enterprise Architecture** - Cloud-optimized WAN with zero-touch provisioning

The proposed architecture replaces MPLS with a flexible SD-WAN overlay. Key components include:

- **Control Plane:** vManage (management), vSmart (control), vBond (orchestration)
- **Hub Routers:** 2x ISR 4451 at data centers with redundant WAN circuits
- **Branch Routers:** 25x ISR 4331 with dual circuits (broadband + LTE)
- **Transport:** Dual broadband (100 Mbps) + LTE backup per site

## Architecture Type

This solution follows a **hub-and-spoke SD-WAN** architecture pattern. Key characteristics:

- **Deployment Model:** Overlay SD-WAN with encrypted IPsec tunnels
- **Routing:** Application-aware routing with SLA policies
- **Transport:** Multi-circuit with automatic failover
- **Management:** Centralized vManage orchestration

The architecture supports 25 sites with scalability to 100+ sites.

## Technical Implementation Strategy

The deployment follows a conservative phased approach:

**Pilot Phase (Week 10):**
- Deploy 3 low-risk branch sites (small offices, non-critical apps)
- Validate zero-touch provisioning workflow
- Test application performance and SLA compliance
- Validate circuit failover (broadband → LTE)

**Production Waves (Weeks 11-12):**
- Wave 1: 10 medium-sized branches
- Wave 2: 12 remaining branches including critical sites
- Dual-run period with MPLS and SD-WAN
- Gradual traffic migration to SD-WAN
- Performance validation before MPLS disconnect

**MPLS Decommission (Weeks 13-16):**
- Site-by-site MPLS disconnection after SD-WAN validation
- Circuit contract termination coordination
- Cost savings realization

---

# Security & Compliance

## Identity & Access Management

- Role-based access control (RBAC) for vManage administrators
- Multi-factor authentication (MFA) for privileged access
- Integration with Active Directory/LDAP (optional)
- Audit logging for all configuration changes

## WAN Security

- IPsec encryption for all SD-WAN tunnels
- Zone-based firewall on branch routers
- Application visibility and control
- Umbrella DNS security (optional add-on)

## Compliance & Auditing

- Configuration change tracking via vManage
- Template-based deployment ensuring consistency
- Audit trails for all policy changes
- Compliance reporting for change management

---

# Testing & Validation

## Functional Validation

Comprehensive testing ensures SD-WAN works correctly:

**Controller Testing:**
- vManage orchestration and zero-touch provisioning
- vSmart routing policy distribution
- vBond device authentication and onboarding

**Routing Testing:**
- Application-aware routing (Office 365, VoIP, ERP)
- SLA policy enforcement and path selection
- Traffic steering and load balancing
- Automatic failover (broadband → LTE)

## Performance Testing

Performance validation ensures SLA requirements:

**Load Testing:**
- Application performance benchmarking (before/after)
- Office 365 latency and throughput testing
- VoIP call quality and jitter validation
- ERP application response time

**Failover Testing:**
- Primary circuit failure and LTE failover
- Failover time validation (target: < 1 second)
- Application session continuity during failover

## User Acceptance Testing (UAT)

UAT performed with pilot sites:

**UAT Approach:**
- Pilot sites: 3 low-risk branches
- Application performance validation
- User experience feedback
- Circuit failover validation

**Acceptance Criteria:**
- Application performance meets or exceeds MPLS baseline
- Failover occurs automatically without user impact
- Zero-touch provisioning works for new sites

---

# Handover & Support

## Handover Artifacts

Upon successful implementation:

**Documentation Deliverables:**
- As-built architecture diagrams
- SD-WAN controller configuration documentation
- Router templates and policy configurations
- Application routing policy documentation
- Circuit and connectivity documentation

**Operational Deliverables:**
- Operations runbooks for daily tasks
- Troubleshooting guides for common issues
- vManage dashboard and monitoring guide
- Incident response and escalation procedures
- Performance monitoring and capacity planning

**Knowledge Assets:**
- Recorded training sessions (24 hours)
- vManage administrator credentials
- Router access and management procedures
- Vendor support contacts

## Knowledge Transfer

**Training Sessions:**
- 24 hours of hands-on training
- vManage operations and monitoring
- Application-aware routing policies
- Troubleshooting and diagnostics
- Zero-touch provisioning for new sites
- Circuit failover and performance monitoring

**Documentation Package:**
- As-built architecture documentation
- Configuration management guide
- Operational runbooks and SOPs
- Troubleshooting guide

## Hypercare Support

**Duration:** 4 weeks post-go-live

**Coverage:**
- Business hours support (8 AM - 6 PM local time)
- 4-hour response time for critical issues
- Daily check-ins (first 2 weeks)
- Weekly status meetings

**Scope:**
- Issue investigation and resolution
- Performance tuning and optimization
- Policy adjustments and fine-tuning
- Knowledge transfer continuation

## Assumptions

### General Assumptions

**Client Responsibilities:**
- Client will order broadband and LTE circuits for all 25 sites (8-12 week lead time)
- Client will provide data center rack space and power for controllers
- Client network team available for validation and testing
- Client will coordinate MPLS circuit disconnections and contract terminations

**Technical Environment:**
- Broadband and LTE circuits available at all 25 branch locations
- Data center network connectivity available for hub routers and controllers
- Application SLA requirements documented
- No major application changes during deployment

**Project Execution:**
- Project scope and requirements remain stable
- Resources available per project plan
- Circuit orders placed within 2 weeks of project start
- Security and compliance approvals timely

## Dependencies

### Project Dependencies

**Access & Infrastructure:**
- Data center rack space and power for controllers and hub routers (Week 1)
- Broadband circuits installed at all 25 sites (by Week 9)
- LTE circuits provisioned with SIMs (by Week 9)
- Remote hands at branch sites for router installation

**Circuits & Connectivity:**
- Broadband circuit orders placed by Week 2 (8-12 week lead time)
- LTE SIM cards ordered and activated by Week 8
- MPLS circuits maintained until SD-WAN validation complete
- Circuit provider coordination for installation and cutover

---

# Investment Summary

## Total Investment

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 12, 15, 11, 11, 11] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $80,200 | $0 | $80,200 | $0 | $0 | $80,200 |
| Hardware | $136,500 | ($8,000) | $128,500 | $0 | $0 | $128,500 |
| Software | $59,200 | ($15,000) | $44,200 | $59,200 | $59,200 | $162,600 |
| Support | $16,200 | $0 | $16,200 | $16,200 | $16,200 | $48,600 |
| WAN Circuits | $103,800 | ($12,000) | $91,800 | $103,800 | $103,800 | $299,400 |
| **TOTAL INVESTMENT** | **$395,900** | **($35,000)** | **$360,900** | **$179,200** | **$179,200** | **$719,300** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $35,000 (router trade-in + SD-WAN license promotion + circuit installation waiver)

**Annual Recurring Cost:** $179,200/year (WAN circuits, software, support)

**MPLS Replacement Savings:** $124,000/year (current $300K MPLS vs $176K SD-WAN recurring)

## Payment Terms

**Pricing Model:** Fixed price with milestone-based payments

**Payment Schedule:**
- 30% upon SOW execution and project kickoff ($24,060)
- 30% upon completion of Phase 2 - Controllers Deployed ($24,060)
- 25% upon completion of Phase 3 - Deployment Complete ($20,050)
- 15% upon successful go-live and MPLS decommission ($12,030)

**Invoicing:** Monthly invoicing based on milestones completed. Net 30 payment terms.

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) between Vendor and Client.

## Scope Changes

Any changes to scope, schedule, or cost require a formal Change Request approved by both parties.

## Intellectual Property

- Client retains ownership of all deliverables and configurations
- Vendor retains proprietary methodologies and tools
- Pre-existing IP remains with original owner

## Confidentiality

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
