---
# Document Metadata (Simplified)
document_title: Statement of Work
technology_provider: Cisco Systems
project_name: Cisco HyperFlex Hybrid Infrastructure
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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for the Cisco HyperFlex Hybrid Infrastructure project for [Client Name]. This engagement will deliver a hyperconverged infrastructure platform to consolidate 40+ servers and SAN storage, reducing data center footprint by 70% and achieving 90% faster VM provisioning through integrated compute and storage.

**Project Duration:** 12 weeks

---

# Background & Objectives

## Current State

[Client Name] currently operates traditional 3-tier infrastructure with separate compute, storage, and network silos. Key challenges include:
- **Large Data Center Footprint:** 40+ rack-mounted servers and dedicated SAN consuming 42U of rack space
- **Slow VM Provisioning:** New virtual machine deployment takes 4-8 hours with manual configuration
- **High Capital Costs:** Traditional 3-tier infrastructure requires $600K investment vs $294K for hyperconverged
- **Management Complexity:** Separate management tools for compute (vCenter), storage (SAN), and network
- **Limited Scalability:** Difficulty scaling compute and storage independently

## Business Objectives

- **Consolidate Infrastructure:** Reduce data center footprint by 70% from 42U to 8U rack space with 4-node HyperFlex cluster
- **Accelerate VM Provisioning:** Enable 90% faster deployments (10 minutes vs 4-8 hours) with integrated platform
- **Reduce Capital Costs:** Achieve 50% CapEx savings ($294K HyperFlex vs $600K traditional)
- **Simplify Management:** Unified Cisco Intersight management reducing 75% management time
- **Improve Efficiency:** Realize $85K annual savings from reduced power/cooling and $45K from simplified operations
- **Enable Growth:** Scalable platform supporting 200-400 VMs with room for expansion

## Success Metrics

- 70% data center space reduction (42U → 8U)
- 90% faster VM provisioning (4-8 hours → 10 minutes)
- 50% CapEx savings vs traditional infrastructure
- 30-month ROI through consolidation and efficiency
- 99.9% availability with N+1 fault tolerance

---

# Scope of Work

## In Scope

- Infrastructure assessment and VM workload analysis
- HyperFlex sizing and architecture design with HA redundancy
- Network integration planning and migration strategy
- HyperFlex 4-node all-flash cluster deployment
- VMware vSphere 8 installation and configuration
- Cisco Intersight cloud management integration
- Phased VM migration in 4 waves (pilot → Wave 1 → Wave 2 → Wave 3)
- Veeam backup integration with snapshot-based backups
- Performance tuning and optimization
- Team training (24 hours) on HyperFlex operations
- Hypercare support (60 hours) over 4 weeks
- Legacy infrastructure decommission planning

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Primary Features/Capabilities | HyperFlex 4-node for 200-300 VMs |
| Solution Scope | Customization Level | Standard HyperFlex deployment |
| Integration | External System Integrations | 2 systems (vCenter + backup) |
| Integration | Data Sources | VM inventory only |
| User Base | Total Users | 10 infrastructure admins |
| User Base | User Roles | 2 roles (admin + operator) |
| Data Volume | Data Processing Volume | 200-300 VMs workload |
| Data Volume | Data Storage Requirements | 20 TB usable storage |
| Technical Environment | Deployment Regions | Single data center |
| Technical Environment | Availability Requirements | Standard (99.5%) |
| Technical Environment | Infrastructure Complexity | Basic 3-tier compute storage network |
| Security & Compliance | Security Requirements | Basic encryption and RBAC |
| Security & Compliance | Compliance Frameworks | Basic logging |
| Performance | Performance Requirements | Standard IOPS and latency |
| Environment | Deployment Environments | Production only |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*

## Out of Scope

These items are not in scope unless added via change control:
- Hardware procurement beyond HyperFlex nodes and fabric interconnects
- Network switch upgrades or replacements
- Disaster recovery site deployment (optional add-on)
- Application refactoring or optimization
- End-user training (infrastructure team only)
- Managed services post-hypercare period
- Legacy hardware decommissioning and disposal

## Activities

### Phase 1 – Design & Planning (Weeks 1-2)

During this phase, the current infrastructure is assessed and HyperFlex solution designed.

Key activities:
- Infrastructure assessment and VM workload analysis (72 hours)
- HyperFlex sizing and architecture design with HA redundancy
- Network integration planning for UCS fabric interconnects
- Migration strategy definition with application dependencies
- Data center preparation (rack space, power, cooling, network)

**Deliverable:** Infrastructure Assessment and HyperFlex Design Document

### Phase 2 – Infrastructure Deployment (Weeks 3-4)

HyperFlex cluster is deployed and integrated with network fabric.

Key activities:
- HyperFlex 4-node cluster deployment with HA configuration (80 hours)
- UCS 6454 Fabric Interconnect installation and configuration
- VMware vSphere 8 installation and cluster setup (72 hours)
- Cisco Intersight integration and monitoring configuration (20 hours)
- Network connectivity validation and performance baseline

**Deliverable:** Deployed HyperFlex Cluster and vSphere Environment

### Phase 3 – VM Migration (Weeks 5-8)

Virtual machines are migrated in phased waves with validation.

Key activities:
- Pilot migration: 20 non-critical VMs for validation (30 hours)
- Wave 1: 50 business application VMs via vMotion (40 hours)
- Wave 2: 50 critical VMs including databases (50 hours)
- Wave 3: Remaining VMs and final validation (40 hours)
- Application testing and validation after each wave
- Performance monitoring and troubleshooting

**Deliverable:** Migrated VM Workloads with Validation Reports

### Phase 4 – Optimization (Weeks 9-12)

The platform is optimized and operations team trained.

Key activities:
- Performance tuning and resource optimization (45 hours)
- Veeam backup integration with snapshot-based backups
- Team training on HyperFlex operations (24 hours)
- Knowledge transfer and documentation delivery
- Hypercare support (60 hours) over 4 weeks
- Legacy infrastructure decommission planning

**Deliverable:** As-Built Documentation and Operational Runbooks

---

# Deliverables & Timeline

This section outlines the key deliverables, project milestones, and timeline for the HyperFlex Hyperconverged Infrastructure implementation. All deliverables are subject to formal acceptance by designated client stakeholders before proceeding to subsequent phases.

## Deliverables

The following deliverables will be produced throughout the project lifecycle, with formal acceptance required from designated client stakeholders:

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Infrastructure Assessment | Document | Week 2 | Client IT Lead |
| 2 | HyperFlex Cluster Deployment | Infrastructure | Week 4 | Infrastructure Lead |
| 3 | VM Migration Reports | Document | Week 8 | Operations Lead |
| 4 | As-Built Documentation | Document | Week 12 | Client IT Lead |
| 5 | Training Sessions | Live/Recorded | Week 12 | Infrastructure Team |

## Project Milestones

The project will be tracked against the following key milestones, representing major completion points and readiness gates for the next phase:

<!-- TABLE_CONFIG: widths=[20, 55, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 - Design Complete | HyperFlex architecture approved | Week 2 |
| M2 - Cluster Deployed | HyperFlex cluster operational | Week 4 |
| M3 - Pilot Complete | 20 VMs migrated successfully | Week 5 |
| M4 - Migration Complete | All VMs migrated and validated | Week 8 |
| M5 - Go-Live | Production operational handoff | Week 12 |
| Hypercare End | Support period complete | Week 16 |

---

# Roles & Responsibilities

This section defines the roles, responsibilities, and accountabilities for both Vendor and Client teams throughout the project lifecycle using a RACI matrix framework.

## RACI Matrix

The following RACI matrix defines responsibility assignments for key project activities across Vendor and Client roles:

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO HCI Eng | EO Virtualization | Client Infra | Client Apps | SME |
|-----------|-------|----------------|------------|-------------------|--------------|-------------|-----|
| Discovery & Requirements | A | R | R | C | C | I | C |
| HyperFlex Design | C | A | R | C | C | I | I |
| Cluster Deployment | C | A | R | R | C | I | I |
| vSphere Configuration | C | R | C | A | C | I | I |
| VM Migration | R | R | C | A | C | A | I |
| Testing & Validation | R | R | C | R | A | A | I |
| Knowledge Transfer | A | R | R | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- EO Project Manager: Overall delivery accountability
- EO Quarterback: Technical design and architecture oversight
- EO HCI Engineer: HyperFlex deployment and configuration
- EO Virtualization Engineer: vSphere and VM migration

**Client Team:**
- Infrastructure Lead: Primary technical contact
- Virtualization Lead: vSphere administration and VM validation
- Application Owners: Application testing and validation
- Operations Team: Day-to-day operations and monitoring

---

# Architecture & Design

## Architecture Overview

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1: HyperFlex Hyperconverged Infrastructure Architecture** - Integrated compute and storage

The proposed architecture consolidates compute and storage into a unified HyperFlex platform. Key components include:

- **Compute Layer:** 4x HyperFlex HX240c M5 nodes with dual Xeon Gold processors
- **Storage Layer:** NVMe all-flash storage with inline deduplication and compression
- **Network Layer:** Cisco UCS 6454 Fabric Interconnects providing unified 25GbE fabric
- **Management Layer:** Cisco Intersight cloud-based management and VMware vCenter

## Architecture Type

This solution follows a **hyperconverged infrastructure (HCI)** architecture pattern. Key characteristics:

- **Scaling Approach:** Scale-out by adding nodes to cluster (linear scalability)
- **Deployment Model:** On-premises with cloud management (Intersight)
- **Storage Architecture:** Distributed data platform with erasure coding
- **Fault Tolerance:** N+1 redundancy (cluster survives single node failure)

The architecture supports 200-400 VMs with scalability to 8+ nodes.

## Scope Specifications

This engagement is scoped for a **Medium (4-node)** deployment:

**Cluster Configuration:**
- Medium (4-node): 256 vCPUs, 3 TB RAM, 20 TB usable storage
- Large (6-node): 384 vCPUs, 4.5 TB RAM, 30 TB usable storage
- Enterprise (8-node): 512 vCPUs, 6 TB RAM, 40 TB usable storage

**Performance Tier:**
- All-Flash NVMe: 30.7 TB raw capacity per cluster
- Hybrid (SSD+HDD): Lower cost with reduced performance
- All-NVMe: Maximum performance for latency-sensitive workloads

**Availability:**
- N+1 Fault Tolerance: Cluster survives single node failure
- N+2 Fault Tolerance: Requires 5+ nodes (optional)

## Technical Implementation Strategy

The deployment follows a conservative phased migration approach:

**Pilot Phase (Week 5):**
- Migrate 20 non-critical VMs (file servers, development)
- Validate vMotion process and application performance
- Establish rollback procedures

**Production Waves (Weeks 6-8):**
- Wave 1: 50 business application VMs
- Wave 2: 50 critical VMs (databases, ERP)
- Wave 3: Remaining VMs and edge cases
- Validation and performance testing after each wave

**Parallel Operation:**
- Dual-run period with legacy and HyperFlex
- Rollback capability maintained until validation complete
- Legacy decommission only after 4-week stabilization

---

# Security & Compliance

## Identity & Access Management

- Role-based access control (RBAC) for vCenter and Intersight
- Active Directory integration for authentication
- Multi-factor authentication (MFA) for administrative access
- Audit logging for all administrative actions

## Data Protection

- Self-encrypting NVMe drives for data-at-rest encryption
- VMware VM encryption for sensitive workloads
- Veeam backup with immutable snapshots
- Cross-site replication for disaster recovery (optional)

## Compliance & Auditing

- Configuration compliance scanning
- Audit trails for all infrastructure changes
- Compliance reporting for PCI DSS or HIPAA
- Automated vulnerability scanning

---

# Testing & Validation

## Functional Validation

Comprehensive testing ensures the platform works correctly:

**Infrastructure Testing:**
- Cluster formation and health validation
- Storage performance and deduplication testing
- Network fabric connectivity and failover
- vSphere integration and features

**VM Migration Testing:**
- vMotion live migration validation
- Application functionality post-migration
- Performance comparison (before/after)
- Data integrity verification

## Performance Testing

Performance validation ensures SLA requirements:

**Load Testing:**
- VM density testing (target: 200-300 VMs)
- Storage IOPS and throughput benchmarking
- Network bandwidth validation
- CPU and memory utilization profiling

**Benchmarking:**
- Application performance baselines
- Storage latency validation (target: < 5ms)
- vMotion duration for different VM sizes

## Resilience Testing

Disaster recovery and failover validation:

**Failure Scenarios:**
- Single node failure and automatic failover
- Network path failure and redundancy
- Disk failure and rebuild
- Power failure and UPS validation

**Backup/Restore:**
- Veeam backup job validation
- VM restore testing
- Recovery time validation

---

# Handover & Support

## Handover Artifacts

Upon successful implementation:

**Documentation Deliverables:**
- As-built architecture diagrams
- HyperFlex cluster configuration documentation
- vSphere configuration and VM inventory
- Network topology and fabric interconnect configuration
- Intersight integration and monitoring guide

**Operational Deliverables:**
- Operations runbooks for daily tasks
- Troubleshooting guides
- VM provisioning procedures
- Backup and restore procedures
- Performance monitoring and capacity planning guide

**Knowledge Assets:**
- Recorded training sessions
- HyperFlex and vSphere administrator credentials
- Intersight portal access
- Vendor support contacts and escalation paths

## Knowledge Transfer

**Training Sessions:**
- 24 hours of hands-on training
- HyperFlex architecture and operations
- vSphere administration on HyperFlex
- Intersight cloud management
- VM provisioning and migration
- Backup and restore operations
- Troubleshooting and performance tuning

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
- Daily health check calls (first 2 weeks)
- Weekly status meetings

**Scope:**
- Issue investigation and resolution
- Performance tuning and optimization
- Configuration adjustments
- Knowledge transfer continuation

## Assumptions

### General Assumptions

**Client Responsibilities:**
- Client will provide data center rack space, power, and cooling
- Client virtualization team available for VM migration and testing
- Client application owners available for post-migration validation
- Client will handle internal change approvals and stakeholder communication

**Technical Environment:**
- Data center meets power and cooling requirements (30A per node)
- Network infrastructure supports 25GbE connectivity
- vCenter Server compatible with vSphere 8 (or will be upgraded)
- Veeam Backup & Replication compatible with HyperFlex snapshots

**Project Execution:**
- Project scope and requirements remain stable
- Resources available per project plan
- Application downtime windows available for critical VM migrations
- Hardware delivery within 6-8 week lead time

---

# Investment Summary

This section provides a comprehensive breakdown of the total investment required for the HyperFlex Hyperconverged Infrastructure implementation, including professional services, hardware, software licensing, and ongoing support costs over a 3-year period.

## Total Investment

The following table summarizes the total cost of ownership for this engagement across all cost categories and years:

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 12, 15, 11, 11, 11] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $63,900 | $0 | $63,900 | $0 | $0 | $63,900 |
| Hardware | $294,000 | ($15,000) | $279,000 | $0 | $0 | $279,000 |
| Software | $106,000 | ($20,000) | $86,000 | $106,000 | $106,000 | $298,000 |
| Support | $52,000 | $0 | $52,000 | $52,000 | $52,000 | $156,000 |
| **TOTAL INVESTMENT** | **$515,900** | **($35,000)** | **$480,900** | **$158,000** | **$158,000** | **$796,900** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $35,000 (server trade-in + VMware ELA credit)

**Annual Recurring Cost:** $158,000/year (software licenses and support)

## Payment Terms

**Pricing Model:** Fixed price with milestone-based payments

**Payment Schedule:**
- 30% upon SOW execution and project kickoff ($19,170)
- 30% upon completion of Phase 2 - Cluster Deployed ($19,170)
- 25% upon completion of Phase 3 - Migration Complete ($15,975)
- 15% upon successful go-live and project acceptance ($9,585)

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
