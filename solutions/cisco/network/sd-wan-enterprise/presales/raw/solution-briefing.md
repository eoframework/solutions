---
presentation_title: Solution Briefing
solution_name: Cisco SD-WAN Enterprise
presenter_name: [Presenter Name]
client_logo: ../../assets/logos/client_logo.png
footer_logo_left: ../../assets/logos/consulting_company_logo.png
footer_logo_right: ../../assets/logos/eo-framework-logo-real.png
---

# Cisco SD-WAN Enterprise - Solution Briefing

## Slide Deck Structure
**10 Slides - Fixed Format**

---

### Slide 1: Title Slide
**layout:** eo_title_slide

**Presentation Title:** Solution Briefing
**Subtitle:** Cisco SD-WAN Enterprise
**Presenter:** [Presenter Name] | [Current Date]

---

### Business Opportunity
**layout:** eo_two_column

**Transform WAN with Cloud-Ready SD-WAN Architecture**

- **Opportunity**
  - Eliminate expensive MPLS circuits reducing WAN costs by 60% with broadband and LTE
  - Accelerate cloud application performance with direct internet breakout and SaaS optimization
  - Deploy new sites in 2 hours vs 8 weeks with zero-touch provisioning
- **Success Criteria**
  - 60% WAN cost reduction through MPLS replacement with dual broadband circuits
  - 95% faster site deployment via zero-touch router provisioning
  - ROI realization within 18 months through circuit savings and operational efficiency

---

### Engagement Scope
**layout:** eo_table

**Sizing Parameters for This Engagement**

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_SIZING_TABLE -->
<!-- TABLE_CONFIG: widths=[18, 29, 5, 18, 30] -->
| Parameter | Scope | | Parameter | Scope |
|-----------|-------|---|-----------|-------|
| **Primary Features/Capabilities** | SD-WAN for 25 branch offices | | **Availability Requirements** | Standard (99.5%) |
| **Customization Level** | Standard SD-WAN deployment | | **Infrastructure Complexity** | Basic hub-spoke WAN |
| **External System Integrations** | 2 systems (cloud + monitoring) | | **Security Requirements** | Basic VPN encryption |
| **Data Sources** | WAN telemetry only | | **Compliance Frameworks** | Basic logging |
| **Total Users** | 5 network engineers | | **Performance Requirements** | Standard application routing |
| **User Roles** | 2 roles (admin + operator) | | **Deployment Environments** | Production only |
| **Data Processing Volume** | 25 sites WAN traffic | |  |  |
| **Data Storage Requirements** | 200 GB (90-day logs) | |  |  |
| **Deployment Regions** | Single region | |  |  |
<!-- END SCOPE_SIZING_TABLE -->

*Note: Changes to these parameters may require scope adjustment and additional investment.*

---

### Solution Overview
**layout:** eo_visual_content

**Cloud-Optimized SD-WAN for 25 Branch Offices**

![Architecture Diagram](assets/diagrams/architecture-diagram.png)

- **Key Components**
  - 25x Cisco ISR 4331 branch routers with dual WAN ports and integrated security
  - 2x Cisco ISR 4451 hub routers at data centers providing redundant aggregation
  - vManage, vSmart, vBond virtual controllers for centralized orchestration
- **Technology Stack**
  - Edge Platform: Cisco ISR 4300/4400 series routers with SD-WAN software
  - Controllers: vManage (management), vSmart (control), vBond (orchestration)
  - WAN Transport: Dual broadband (100 Mbps) + LTE backup per site
  - Application Routing: SLA-based policies for Office 365, VoIP, ERP traffic
  - Security: Integrated firewall, VPN encryption, Umbrella DNS (optional)

---

### Implementation Approach
**layout:** eo_single_column

**Proven 4-Phase Deployment Methodology**

- **Phase 1: Design & Planning (Weeks 1-4)**
  - Current WAN assessment: MPLS circuits, bandwidth, and application analysis
  - SD-WAN architecture design with hub-spoke topology and redundancy
  - Circuit availability analysis: broadband and LTE feasibility at 25 sites
  - Application-aware routing policy design for SaaS and business-critical apps
- **Phase 2: Infrastructure Deployment (Weeks 5-8)**
  - vManage, vSmart, vBond controller deployment in data center or cloud
  - Hub router configuration: 2x ISR 4451 with HA at data centers (40 hours)
  - Application routing and SLA policy configuration (60 hours)
  - Security policy setup: firewall rules, VPN, and cloud integration (40 hours)
- **Phase 3: Site Deployment (Weeks 9-12)**
  - Lab validation: test policies in GNS3 or CML environment (32 hours)
  - Pilot deployment: 3 low-risk sites for validation and testing (60 hours)
  - Production Wave 1: deploy 10 sites with zero-touch provisioning (60 hours)
  - Production Wave 2: deploy remaining 12 sites with MPLS cutover (60 hours)
- **Phase 4: Optimization (Weeks 13-16)**
  - MPLS circuit decommissioning after SD-WAN validation (40 hours)
  - Performance testing: application SLA compliance and failover scenarios (64 hours)
  - Team training on vManage operations and troubleshooting (24 hours)
  - Hypercare support for 4 weeks post-deployment (60 hours)

---

### Business Value Delivered
**layout:** eo_two_column

**Measurable WAN Cost Reduction and Agility**

- **Operational Excellence**
  - 95% faster site deployment: new branches online in 2 hours vs 8-week MPLS provisioning
  - 80% improvement in cloud app performance: direct internet breakout eliminates backhauling
  - Centralized management: single vManage dashboard vs CLI on 27 routers
- **Financial Impact**
  - $124K annual WAN savings: broadband + LTE replaces $300K MPLS spend
  - $35K operational savings from simplified management and faster provisioning
  - 18-month payback period with ongoing WAN cost avoidance
- **Application Performance**
  - 50% reduction in Office 365 latency through local internet breakout
  - 99.9% uptime with dual circuits and automatic LTE failover
  - Application-aware routing ensures VoIP and ERP meet SLA requirements

---

### Technical Architecture
**layout:** eo_single_column

**Scalable SD-WAN Platform Architecture**

- **SD-WAN Controllers (Virtual)**
  - vManage: centralized configuration, monitoring, and policy orchestration
  - vSmart: control plane for routing and policy distribution
  - vBond: zero-touch provisioning and orchestration for branch routers
  - Hosted in data center VMs or cloud (AWS/Azure) with HA redundancy
- **Hub Router Configuration**
  - 2x Cisco ISR 4451 routers at data centers for redundant aggregation
  - Dual 1 Gbps WAN circuits (internet + MPLS/direct cloud)
  - IPsec VPN hub for secure overlay to all branch sites
- **Branch Router Configuration**
  - 25x Cisco ISR 4331 routers with dual WAN ports
  - Primary: 100 Mbps broadband (fiber or cable)
  - Backup: 10 GB LTE for automatic failover
  - Zero-touch provisioning via vBond orchestration
- **Application Policies**
  - Office 365/SaaS: direct internet breakout with SLA monitoring
  - VoIP: priority routing with <50ms latency and <1% loss
  - ERP/business apps: encrypted tunnel to data center over best path
  - Cloud on-ramps: direct connectivity to AWS/Azure (optional)

---

### Risk Mitigation Strategy
**layout:** eo_single_column

**Comprehensive Approach to Project Success**

- **Technical Risk Mitigation**
  - Circuit availability: pre-deployment survey confirms broadband and LTE at all sites
  - Performance concerns: pilot validates application SLA before full rollout
  - Failover testing: automated LTE backup tested during migration
- **Organizational Risk Mitigation**
  - Team readiness: 24 hours vManage training with hands-on lab exercises
  - Change resistance: executive sponsorship; pilot demonstrates cost savings
  - Resource constraints: vendor-led implementation minimizes internal demands
- **Implementation Risk Mitigation**
  - Timeline delays: hardware lead time managed (6-8 weeks); clear milestones
  - Migration failures: phased rollout with rollback to MPLS if needed
  - Business disruption: sites cutover during maintenance windows; dual-run period

---

### Investment Summary
**layout:** eo_table

**3-Year Total Cost of Ownership**

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 15, 15, 12, 12, 15] -->
| Cost Category | Year 1 List | Year 1 Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|----------------|------------|--------|--------|--------------|
| Professional Services | $80,200 | $0 | $80,200 | $0 | $0 | $80,200 |
| Hardware | $136,500 | ($8,000) | $128,500 | $0 | $0 | $128,500 |
| Software | $59,200 | ($15,000) | $44,200 | $59,200 | $59,200 | $162,600 |
| Support | $16,200 | $0 | $16,200 | $16,200 | $16,200 | $48,600 |
| WAN Circuits | $103,800 | ($12,000) | $91,800 | $103,800 | $103,800 | $299,400 |
| **TOTAL** | **$395,900** | **($35,000)** | **$360,900** | **$179,200** | **$179,200** | **$719,300** |
<!-- END COST_SUMMARY_TABLE -->

**Year 1 includes:** $35K in credits (router trade-in + SD-WAN license promotion + circuit installation waiver)

**Annual recurring cost:** $179.2K/year (WAN circuits, software licenses, support)

**MPLS replacement savings:** $124K/year (current $300K MPLS spend vs $176K SD-WAN recurring)

---

### Next Steps
**layout:** eo_single_column

**Path to Deployment Success**

1. **Executive Approval (Week 0)**
   - Review and approve $360.9K Year 1 investment
   - Assign technical lead and network team
   - Secure budget for hardware, circuits, and implementation

2. **Hardware Procurement & Circuit Orders (Weeks 1-2)**
   - Order 25 ISR 4331 and 2 ISR 4451 routers (6-8 week lead time)
   - Order broadband circuits for all 25 sites (8-12 week provisioning)
   - Order LTE backup circuits with SIM provisioning

3. **Design Phase (Weeks 1-4)**
   - WAN assessment and application traffic analysis (80 hours)
   - SD-WAN architecture design with hub-spoke topology
   - Application routing policy design for SaaS, VoIP, ERP

4. **Deployment Phase (Weeks 5-12)**
   - Controller deployment and hub router configuration (80 hours)
   - Policy configuration: routing, security, and cloud integration (130 hours)
   - Pilot: 3 sites for validation; then 22-site phased rollout (180 hours)

5. **Optimization & Training (Weeks 13-16)**
   - MPLS circuit decommissioning and cost realization (40 hours)
   - Team training on vManage operations (24 hours)
   - Hypercare support and performance optimization (60 hours)

**Recommended decision date:** Within 2 weeks to meet hardware and circuit lead times for Q4 deployment
