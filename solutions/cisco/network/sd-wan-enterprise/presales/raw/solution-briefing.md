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
  - 25x Cisco ISR 4331 branch routers with dual WAN and integrated security
  - 2x Cisco ISR 4451 hub routers providing redundant data center aggregation
  - vManage, vSmart, vBond controllers for centralized orchestration
- **Technology Stack**
  - Platform: Cisco ISR 4300/4400 SD-WAN with dual broadband and LTE backup
  - Application Routing: SLA-based policies for Office 365, VoIP, and ERP
  - Security: Integrated firewall, VPN encryption, and Umbrella DNS

---

### Implementation Approach
**layout:** eo_single_column

**Proven Deployment Methodology**

- **Phase 1: Design & Infrastructure (Weeks 1-8)**
  - WAN assessment, SD-WAN architecture design, and circuit availability validation
  - Controller deployment (vManage, vSmart, vBond) and hub router configuration
  - Application routing policies and security configuration for SaaS and business apps
- **Phase 2: Site Deployment (Weeks 9-13)**
  - Lab validation and pilot with 3 low-risk sites
  - Production deployment in 2 waves: 22 sites with zero-touch provisioning
  - Application SLA validation and MPLS cutover coordination
- **Phase 3: Optimization & Training (Weeks 14-16)**
  - MPLS circuit decommissioning and performance testing
  - Team training on vManage operations and troubleshooting (24 hours)
  - Hypercare support and operational handoff

**SPEAKER NOTES:**

*Risk Mitigation:*
- Circuit availability confirmed through pre-deployment survey verifying broadband and LTE at all 25 sites
- Pilot deployment with 3 low-risk sites validates application SLA performance before full rollout
- Automated LTE failover tested during migration ensuring business continuity
- All site cutovers during maintenance windows with documented rollback to MPLS if needed

*Success Factors:*
- Team readiness ensured with 24 hours vManage training and hands-on lab exercises
- Executive sponsorship secured with pilot demonstrating measurable WAN cost savings
- Vendor-led implementation minimizes internal resource demands on network team
- Clear milestones with hardware and circuit lead times managed proactively (6-12 weeks)

*Talking Points:*
- Pilot in Phase 2 with 3 sites validates zero-touch provisioning before full rollout
- Phased deployment (2 waves totaling 22 sites) reduces risk with progressive MPLS decommissioning
- 16-week deployment delivers immediate cost savings as MPLS circuits disconnect
- vManage centralized management replaces CLI configuration on 27 distributed routers

---

### Timeline & Milestones
**layout:** eo_table

**Path to Value Realization**

<!-- TABLE_CONFIG: widths=[10, 25, 15, 50] -->
| Phase No | Phase Description | Timeline | Key Deliverables |
|----------|-------------------|----------|------------------|
| Phase 1 | Design & Planning | Weeks 1-4 | WAN assessment complete (80 hrs), Architecture designed, Circuit availability validated |
| Phase 2 | Infrastructure Deployment | Weeks 5-8 | Controllers deployed, Hub routers configured (40 hrs), Policies configured (100 hrs) |
| Phase 3 | Site Deployment | Weeks 9-12 | Lab validated (32 hrs), Pilot (3 sites), Wave 1 (10 sites), Wave 2 (12 sites) |
| Phase 4 | Optimization | Weeks 13-16 | MPLS decommissioned (40 hrs), Performance tested (64 hrs), Team trained (24 hrs) |

**SPEAKER NOTES:**

*Quick Wins:*
- SD-WAN controllers and hubs operational by Week 8 ready for site deployment
- First 3 pilot sites online by Week 10 proving zero-touch provisioning and cost savings
- 50% of sites migrated by Week 11 with measurable MPLS circuit decommissioning savings

*Talking Points:*
- Design phase in Weeks 1-4 runs parallel to hardware and circuit procurement maximizing efficiency
- Controller deployment in Weeks 5-8 establishes centralized orchestration platform
- Phased site deployment in Weeks 9-12 delivers progressive WAN cost savings with each wave
- Full cost realization by Week 16 with all MPLS circuits decommissioned and $124K annual savings

---

### Success Stories
**layout:** eo_single_column

- **Client Success: Regional Retail Chain**
  - **Client:** Retail chain with 30 stores across distributed locations
  - **Challenge:** $320K MPLS costs. 8-12 week provisioning delays. Cloud app performance suffering from backhauling.
  - **Solution:** SD-WAN with 30 ISR routers, dual broadband plus LTE, vManage orchestration.
  - **Results:** 65% cost reduction ($320K to $112K). 97% faster deployment (2 hours vs 8 weeks). $208K annual savings, 15-month ROI.
  - **Testimonial:** "SD-WAN slashed our WAN costs by two-thirds. We open new stores in hours instead of months, and cloud performance is phenomenal." — **James Wilson**, VP of IT Operations

---

### Our Partnership Advantage
**layout:** eo_two_column

**Why Partner with Us for Cisco SD-WAN**

- **What We Bring**
  - 10+ years delivering Cisco SD-WAN solutions with proven enterprise deployments
  - 35+ successful SD-WAN implementations across retail, healthcare, finance, manufacturing sectors
  - Cisco Gold Partner with Advanced Enterprise Networks Architecture Specialization
  - Certified SD-WAN experts and CCIE-level network architects on staff
- **Value to You**
  - Pre-built SD-WAN design templates and application routing policies accelerate deployment
  - Proven circuit migration methodology minimizes risk with dual-run and rollback procedures
  - Best practices from 35+ implementations avoiding common policy and failover pitfalls
  - Ongoing support for policy optimization and troubleshooting as WAN needs evolve

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

**Cisco Partner Credits (Year 1 Only):**
- Router Trade-In Credit: $8,000 applied to ISR hardware purchase for legacy router trade-in
- SD-WAN License Promotion: $15,000 discount on vManage and SD-WAN software licensing
- Circuit Installation Waiver: $12,000 waived broadband installation fees (carrier promotion)
- Total Credits: $35,000 reducing Year 1 investment by 9%

**SPEAKER NOTES:**

*Value Positioning:*
- Lead with credits: You qualify for $35K in trade-in, license, and circuit installation credits
- Net Year 1 investment of $360.9K vs. current $300K annual MPLS spend (1.2x payback in Year 1)
- 3-year TCO of $719.3K vs. $900K for MPLS (3-year savings of $180.7K)
- Annual recurring cost of $179.2K vs. current $300K MPLS ($124K annual savings)

*Credit Program Talking Points:*
- Real trade-in, SD-WAN license, and circuit installation credits applied
- Router trade-in program handles logistics and hardware valuation
- Cisco SD-WAN license promotion confirmed through partnership
- Circuit installation waiver through carrier partner network relationships

*Handling Objections:*
- What about MPLS reliability? Dual broadband plus LTE backup provides 99.9% uptime with SLA monitoring
- Can broadband support our apps? Pre-deployment circuit survey confirms bandwidth and performance
- Are credits guaranteed? Yes, trade-in subject to hardware condition, license promotion confirmed, circuit waiver carrier-dependent
- What about ongoing costs? Years 2-3 are $179.2K/year (circuits + software + support) vs. $300K MPLS

---

### Next Steps
**layout:** eo_bullet_points

**Your Path Forward**

- **Decision:** Executive approval for $360.9K Year 1 investment by [specific date]
- **Hardware & Circuit Procurement:** Order ISR routers (6-8 week lead time) and broadband circuits (8-12 week provisioning)
- **Team Formation:** Assign technical lead, network team, and coordinate with carrier account managers
- **Week 1-4:** Design phase with WAN assessment (80 hrs), architecture design, and circuit availability validation
- **Week 5-16:** Deployment and optimization with controllers, pilot (3 sites), phased rollout (22 sites), and training

**SPEAKER NOTES:**

*Transition from Investment:*
- Now that we have covered the investment and proven ROI, let us talk about getting started
- Emphasize dual lead times: hardware (6-8 weeks) and circuits (8-12 weeks) require decision within 2 weeks
- Show how MPLS cost savings begin immediately as sites cutover to SD-WAN

*Walking Through Next Steps:*
- Decision needed for Year 1 investment covering services, hardware, software, circuits, and support
- Hardware and circuit procurement are critical path with longest lead times (8-12 weeks for circuits)
- Design phase in Weeks 1-4 runs parallel to procurement maximizing deployment efficiency
- Pilot with 3 sites validates zero-touch provisioning before committing to full 22-site rollout

*Call to Action:*
- Schedule executive approval meeting to review $360.9K investment and WAN transformation business case
- Begin circuit availability survey for all 25 sites confirming broadband and LTE options
- Identify technical lead and network team members for WAN assessment and migration planning
- Request current MPLS contract details, circuit costs, and application traffic patterns for analysis

---

### Thank You
**layout:** eo_thank_you

- **Your Account Manager:** [Name, Title] | [Email] | [Phone]

**SPEAKER NOTES:**

*Closing Strong:*
- Thank them for their time and consideration of Cisco SD-WAN investment
- Reiterate the WAN transformation opportunity with measurable cost savings and application performance gains
- Introduce SD-WAN team members who will support migration and ongoing operations
- Make yourself available for technical deep-dive on SD-WAN architecture or circuit migration strategy

*Call to Action:*
- "What questions do you have about SD-WAN and MPLS replacement?"
- "Which branch sites would be best for the pilot phase - smallest, newest, or most problematic?"
- "Would you like to see a demo of vManage centralized orchestration or application routing capabilities?"
- Offer to schedule technical architecture review with their network and WAN teams

*Handling Q&A:*
- Listen to specific WAN challenges and address with SD-WAN cost savings and performance features
- Be prepared to discuss circuit options, failover scenarios, and application SLA requirements
- Emphasize pilot approach with 3 sites reduces risk and validates MPLS replacement viability
- Address circuit lead time concerns and offer to expedite carrier orders if decision made promptly
