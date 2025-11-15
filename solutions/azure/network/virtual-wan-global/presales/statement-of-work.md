# Azure Virtual WAN Global Network - Statement of Work

**Document Date:** November 15, 2025
**Solution:** Azure Virtual WAN for unified global network connectivity
**Engagement Type:** Design, Implementation, Migration, and Training

---

## Executive Summary

This Statement of Work outlines the professional services engagement to design, implement, and optimize an Azure Virtual WAN solution connecting 10 branch offices across 2 geographic regions (US and EU). The solution consolidates legacy MPLS circuits and manual cloud networking into a unified, cloud-native hub-and-spoke architecture with centralized security.

**Engagement Scope:** 10 weeks | **Investment:** $128,190 (Year 1 net) | **Team:** 4-5 specialists

---

## 1. Objectives & Success Criteria

### Primary Objectives
1. Design and deploy a production-grade Virtual WAN hub infrastructure (US + EU regions)
2. Migrate 10 branch office VPN connections with zero unplanned downtime
3. Establish secure connectivity to 2 on-premises data centers via ExpressRoute
4. Implement centralized Azure Firewall Premium threat protection
5. Achieve 99.5%+ network uptime and <100ms intra-region latency
6. Reduce operational complexity and WAN costs by 40-50%

### Success Criteria
- All 10 branch sites migrated and operational (pilot + production phases)
- End-to-end latency measured and optimized (<100ms target)
- Zero security policy violations or configuration inconsistencies
- 100% failover testing completed and documented
- IT staff trained and certified on Virtual WAN operations
- Post-implementation review with stakeholder sign-off

---

## 2. Scope of Work

### Phase 1: Design & Assessment (Weeks 1-2) | 40 hours

**Network Discovery:**
- Current WAN topology mapping (MPLS, Internet, legacy cloud links)
- Traffic analysis: Branch-to-branch, branch-to-cloud, inter-datacenter flows
- Performance baseline: Latency, jitter, packet loss measurements
- Security policy audit: Current firewall rules, IDS/IPS rules, encryption standards
- Azure environment assessment: Existing VNets, resource groups, peering relationships
- Compliance review: HIPAA, PCI-DSS, audit logging requirements

**Architecture Design:**
- Virtual WAN hub sizing (throughput, connection limits per hub)
- Hub placement strategy: US-East (primary), EU-West (secondary)
- Routing design: Route tables, custom routes, inter-hub backbone routing
- Security policy design: Azure Firewall rules, TLS inspection, IDPS tuning
- ExpressRoute circuit design: Microsoft peering, customer peering, redundancy
- Disaster recovery design: Failover scenarios, 48-hour recovery capability

**Design Documentation:**
- Network topology diagrams (logical and physical)
- Hub configuration specifications
- Security architecture document
- Traffic engineering plan
- Compliance mapping document

---

### Phase 2: Pilot Deployment (Weeks 3-4) | 60 hours

**Infrastructure Provisioning:**
- Virtual WAN resource creation (Standard SKU)
- Virtual Hub configuration (US-East + EU-West)
- VPN Gateway deployment (redundant)
- Azure Firewall Premium instances (2x)
- ExpressRoute gateway setup (data center connectivity)

**Branch Connectivity (Pilot Sites):**
- Select 2-3 pilot branch offices (geographically diverse)
- Download and configure VPN client packages
- Establish VPN connections and validate tunnel health
- Performance testing: Bandwidth, latency, failover response

**Data Center Integration:**
- ExpressRoute circuit activation (validate Microsoft and customer peering)
- Virtual hub to data center routing configuration
- BGP route advertisement validation
- Latency and throughput measurement

**Security Implementation:**
- Azure Firewall Premium policy creation
- Threat intelligence enable (TLS inspection, IDPS)
- Network rules: Inter-hub, branch-to-cloud, data center flows
- Application rules: DNS filtering, certificate validation
- Diagnostics logging configuration

**Lab Testing:**
- Failover testing: Hub failure, VPN connection loss, ExpressRoute failure
- Performance testing: Peak load simulation, inter-region latency
- Security testing: Threat detection, rule enforcement, logging validation
- Recovery testing: RTO/RPO validation

---

### Phase 3: Migration & Rollout (Weeks 5-8) | 80 hours

**Branch Migration (Waves 1-3):**
- Wave 1 (4 sites): Weeks 5-6, validate pilot learnings
- Wave 2 (4 sites): Weeks 6-7, accelerated migration
- Wave 3 (2 sites): Week 8, final migration window
- Per-site activities:
  - VPN client deployment and configuration
  - Tunnel establishment and validation
  - User acceptance testing (application functionality)
  - Cutover and failback procedures
  - Performance measurement post-migration

**Azure VNet Integration:**
- Virtual hub gateway configuration (Azure VNet connections)
- Automatic inter-VNet routing validation
- Existing peering migration: Remove manual peering, use hub routing
- Network security group (NSG) updates: Service tag validation
- Application gateway/load balancer integration (if needed)

**Legacy System Decommissioning:**
- MPLS circuit shutdown schedule (coordinated with carrier)
- VPN failover capability validation (48-hour dual-run period)
- Legacy firewall rule archival
- Network monitoring transition from legacy tools

**Traffic Engineering & Optimization:**
- Route table fine-tuning based on observed traffic patterns
- Custom routing rules for critical applications
- Quality of Service (QoS) configuration for bandwidth-sensitive apps
- Inter-region traffic cost optimization

---

### Phase 4: Optimization & Handoff (Weeks 9-10) | 40 hours

**Performance Optimization:**
- Network analyzer review of traffic patterns
- Hub route table optimization
- Firewall rule effectiveness analysis
- Latency and jitter remediation
- Bandwidth utilization reporting

**Security Hardening:**
- Firewall policy effectiveness review
- Threat detection testing
- Compliance audit: HIPAA, PCI-DSS alignment
- Incident response playbook creation

**Operational Handoff:**
- Operations team training (2-3 days on-site)
- Runbook creation: Daily operations, troubleshooting, failover procedures
- Monitoring dashboard setup: Azure Network Watcher, Application Insights integration
- Escalation procedures and support contact tree
- Disaster recovery procedures documentation

**Knowledge Transfer:**
- Architecture deep-dive session with IT leadership
- Virtual WAN administration workshop (hub management, routing, security)
- ExpressRoute troubleshooting and optimization session
- Azure Firewall advanced rules and policy management
- Certification exam preparation (Azure Administrator AZ-104 Virtual WAN module)

---

## 3. Deliverables

### Design Phase (Weeks 1-2)
1. Current State Network Diagram (legacy MPLS/Internet topology)
2. Proposed Architecture Diagram (Virtual WAN hub-and-spoke with 6-8 components)
3. Network Discovery Report (traffic analysis, performance baseline, compliance matrix)
4. Virtual WAN Hub Specification Document
5. Security Architecture & Policy Document
6. Traffic Engineering Plan
7. Risk Assessment & Mitigation Strategies
8. Compliance Mapping Document (HIPAA, PCI-DSS requirements)

### Pilot Phase (Weeks 3-4)
1. Virtual WAN Hub Configuration (exportable ARM template)
2. Pilot Site VPN Configuration (VPN client packages, connection profiles)
3. ExpressRoute Configuration (peering details, route advertisements)
4. Azure Firewall Rule Set (firewall policy definitions)
5. Lab Test Results Report
6. Failover Testing Procedures & Results
7. Performance Baseline Report
8. Pilot Phase Go/No-Go Assessment

### Migration Phase (Weeks 5-8)
1. Detailed Migration Runbook (per-site procedures)
2. Cutover Checklist & Timeline
3. Weekly Migration Status Reports
4. Post-Migration Validation Checklist
5. Traffic Engineering Optimization Report
6. Azure VNet Integration Guide
7. Legacy System Decommissioning Plan
8. Final Migration Sign-off Report

### Handoff Phase (Weeks 9-10)
1. Operations Runbook (daily operations, troubleshooting, failover)
2. Architecture Documentation (high-level, technical deep-dives)
3. Monitoring Dashboard Configuration (Azure Monitor, Network Watcher)
4. Incident Response Playbook
5. Disaster Recovery Procedures
6. Training Materials (slides, hands-on labs, video recordings)
7. Knowledge Transfer Sign-off
8. Post-Implementation Optimization Report

**Total Deliverables:** 32 documents and configurations

---

## 4. Resource Requirements

### Microsoft & Partner Team
- **Solution Architect (Lead):** 10 weeks, 40 hrs/week (design, risk management)
- **Network Engineer:** 10 weeks, 30 hrs/week (pilot, migration, optimization)
- **Security Engineer:** 8 weeks, 20 hrs/week (firewall, compliance, threat detection)
- **Cloud Operations Specialist:** 6 weeks, 20 hrs/week (Azure infrastructure, monitoring)
- **Training Specialist:** 2 weeks, 20 hrs/week (operations training, documentation)

**Total Effort:** 470 billable hours

### Customer Team
- **IT Manager/Project Sponsor:** 20 hrs (executive oversight, decision-making)
- **Network Engineer (Onsite):** 80 hrs (current state knowledge, site coordination)
- **IT Support/Field Technician:** 60 hrs (VPN client deployment, on-site testing)
- **Security/Compliance Officer:** 20 hrs (policy alignment, compliance validation)
- **IT Training Coordinator:** 20 hrs (training logistics, staff scheduling)

**Total Effort:** 200 hours (customer commitment)

---

## 5. Investment Summary

### Professional Services Fees

| Service | Effort | Rate | Cost |
|---------|--------|------|------|
| Network Design & Architecture | 40 hrs | $600/hr | $24,000 |
| Implementation (Pilot + Migration) | 140 hrs | $600/hr | $40,000 |
| Migration Execution & Cutover | 80 hrs | $600/hr | $18,000 |
| Training & Knowledge Transfer | 40 hrs | $600/hr | $10,000 |
| **Subtotal Services** | **300 hrs** | | **$92,000** |
| **Partner Services Credit** | | | **-$12,000** |
| **Net Services Cost** | | | **$80,000** |

### Azure Service Costs (Year 1, based on standard pricing)

| Component | Qty | Unit Cost | Annual Cost |
|-----------|-----|-----------|-------------|
| Azure Virtual WAN (Standard) | 2 hubs | $2,190/month | $4,380 |
| VPN Gateway Connections | 10 sites | $438/month | $4,380 |
| ExpressRoute Circuits | 2 circuits | $9,000/month | $18,000 |
| Azure Firewall Premium | 2 instances | $7,665/month | $15,330 |
| Data Transfer (inter-region) | Variable | | $6,000 |
| **Total Azure Services Year 1** | | | **$48,090** |

### Year 1 Investment Summary

| Category | Amount | Notes |
|----------|--------|-------|
| Professional Services (Gross) | $92,000 | Design, implementation, migration, training |
| Partner Services Credit | -$12,000 | Applied toward implementation costs |
| **Services (Net)** | **$80,000** | |
| Azure Services (Year 1) | $48,090 | Operations, data transfer, connections |
| **Year 1 Total (List)** | **$140,190** | |
| **Year 1 Total (with Credits)** | **$128,190** | |

### Year 2+ Investment

| Category | Amount | Notes |
|----------|--------|-------|
| Azure Services | $48,090 | Ongoing operations (same as Year 1) |
| Professional Services | $0 | One-time design/implementation cost |
| **Year 2+ Annual Cost** | **$48,090** | |

### Financial Comparison

**Before (Legacy MPLS + Manual Cloud):**
- Annual WAN costs: ~$180,000
- Cloud networking costs: ~$20,000
- **Total:** ~$200,000/year

**After (Azure Virtual WAN):**
- Year 1: $128,190 (includes $80K services)
- Year 2+: $48,090 (services complete)
- **5-Year Savings:** ~$400,000 vs. staying on MPLS

---

## 6. Assumptions & Constraints

### Assumptions
- Customer has existing Azure subscription and primary IT infrastructure
- ExpressRoute circuits can be provisioned within 4-6 weeks
- All 10 branch office locations have Internet connectivity (broadband or better)
- VPN clients can be deployed via existing IT management tools
- Migration window available: Weekends or low-traffic periods
- 2 on-premises data centers have network operations staff available
- Decision-making authority available during weeks 1-4

### Constraints
- ExpressRoute provisioning lead time: 4-6 weeks (start immediately)
- Migration window: <4 hours per site cutover (requires careful planning)
- Data center technical resources: Limited availability (coordinate schedule)
- Azure subscription: Must have sufficient permissions for resource deployment
- Security policies: Subject to customer change control and compliance review
- Training: Scheduled during business hours, 2 weeks dedicated effort

### Out of Scope
- Customer network infrastructure upgrades (bandwidth, hardware)
- Third-party WAN optimization tools (integration only if customer-provided)
- Legacy application modifications to work with new network
- Extended training beyond 2 weeks (billable separately)
- 24/7 break/fix support (separate Premier Support contract)
- Custom Azure DevOps integration (separate engagement)

---

## 7. Timeline & Milestones

| Week | Phase | Key Activities | Deliverables |
|------|-------|-----------------|--------------|
| 1 | Design | Network discovery, architecture design kick-off | Current state diagram, design doc draft |
| 2 | Design | Design finalization, security policy design | Architecture diagram, firewall policy, risk assessment |
| 3 | Pilot | Hub provisioning, firewall setup | VWan hub config, firewall rules, lab ready |
| 4 | Pilot | Pilot VPN connections, ExpressRoute activation | Pilot sites online, ER circuit active, test results |
| 5 | Migration | Wave 1: Sites 1-4 migration, VNet integration begins | Wave 1 sign-off, integration plan |
| 6 | Migration | Wave 2: Sites 5-8 migration, routing optimization | Wave 2 sign-off, routing report |
| 7 | Migration | Wave 3: Sites 9-10, legacy MPLS decommission planning | Migration complete, decom plan |
| 8 | Migration | Final cutover, traffic engineering, legacy cleanup | Final sign-off, traffic report |
| 9 | Handoff | Operations training, runbook finalization | Training completion, runbooks, dashboards |
| 10 | Handoff | Final optimization, knowledge transfer completion | Optimization report, sign-off |

**Critical Milestone:** Week 1 - Immediate decision on ExpressRoute circuit provisioning (4-6 week lead time)

---

## 8. Support & Escalation

### During Engagement (Weeks 1-10)
- Daily standups (15 minutes, M-F)
- Weekly steering committee meetings (1 hour)
- On-site presence: Weeks 3-4 (pilot), Weeks 5-8 (migration), Weeks 9-10 (training)
- 24/7 emergency support (migration weeks 5-8 only)

### Post-Engagement (Year 1+)
- 30-day warranty: Critical issues fixed at no charge
- Azure Premier Support Subscription (separate): Microsoft 24/7 support
- Optional managed services: Monthly optimization, security reviews (TBD)

### Escalation Path
1. **Level 1:** Partner support team (response: 1 hour)
2. **Level 2:** Microsoft Enterprise Support (response: 30 minutes)
3. **Level 3:** Customer success manager + Solution architect (response: 15 minutes for critical issues)

---

## 9. Terms & Conditions

**Payment Terms:**
- 30% upon SOW signature and project kick-off ($24,000)
- 50% upon pilot completion (Week 4) ($40,000)
- 20% upon final sign-off and knowledge transfer completion (Week 10) ($16,000)

**Schedule:**
- Start date: [TBD - upon SOW signature]
- Duration: 10 weeks (May adjust ±2 weeks based on customer availability)
- Key dates: ExpressRoute provisioning must start in Week 1

**Cancellation Policy:**
- Weeks 1-2: Full refund minus $5,000 (design costs)
- Weeks 3-4: 70% refund (pilot in progress)
- Weeks 5+: No refund (migration underway)

**Approval Authority:**
This Statement of Work is approved and authorized by:

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Customer CTO/VP IT | [Name] | [Date] | _____________ |
| Partner Engagement Manager | [Name] | [Date] | _____________ |

---

## Appendix A: Detailed Architecture Diagrams

### Diagram 1: Current State (Legacy MPLS)
[See: current-state-diagram.md]

### Diagram 2: Proposed Virtual WAN Architecture
[See: virtual-wan-architecture-diagram.md]

### Diagram 3: Hub & Spoke Topology
[See: hub-spoke-topology.md]

### Diagram 4: Security Architecture
[See: security-architecture-diagram.md]

---

**End of Statement of Work**

**For questions or clarifications, contact:**
Enterprise Architecture Team | [email] | [phone]
