---
presentation_title: Solution Briefing
solution_name: Azure Virtual WAN Global Network
presenter_name: Alison Smith
technology_provider: Azure
client_logo: ../../assets/logos/client_logo.png
footer_logo_left: ../../assets/logos/consulting_company_logo.png
footer_logo_right: ../../assets/logos/eo-framework-logo-real.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Solution Briefing Template

## Slide Deck Structure for PowerPoint
**10 Slides**

### Slide 1: Title Slide
**layout:** eo_title_slide

**Presentation Title:** Solution Briefing
**Subtitle:** [Solution Name]
**Presenter:** [Presenter Name] | [Current Date]
**Logos:**
- Client Logo (top center)
- Consulting Company Logo (footer left)
- EO Framework Logo (footer right)

---

### Business Opportunity
**layout:** eo_two_column

**Simplifying Global Network Connectivity**

- **Opportunity**
  - Connect all branch offices to Azure and each other through a single managed network backbone
  - Replace complex VPN configurations with automated routing that scales as you add locations
  - Reduce network management overhead by 50-60% with centralized policy and monitoring
- **Success Criteria**
  - Connect all branch locations to Azure within 3 months with consistent security policies
  - Achieve 40% reduction in network management costs compared to traditional hub-spoke VPN
  - Deliver reliable connectivity with automatic failover and less than 100ms latency

---


### Engagement Scope
**layout:** eo_table

**Sizing Parameters for This Engagement**

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_SIZING_TABLE -->
<!-- TABLE_CONFIG: widths=[18, 29, 5, 18, 30] -->
| Parameter | Scope | | Parameter | Scope |
|-----------|-------|---|-----------|-------|
| **Virtual WAN Hubs** | 3 regional hubs | | **Availability Requirements** | High availability (99.95%) |
| **Connected Sites** | 10-15 branch locations | | **Infrastructure Complexity** | vWAN + Azure Firewall + routing |
| **VPN Connections** | Site-to-site IPsec VPN | | **Security Requirements** | Azure Firewall DDoS protection |
| **ExpressRoute Circuits** | 2 circuits (primary backup) | | **Compliance Frameworks** | SOC2 ISO27001 |
| **Total Users** | 1000 users across sites | | **Latency Requirements** | <50ms inter-region |
| **User Roles** | 3 roles (network ops security admin) | | **Routing Complexity** | BGP route propagation |
| **Bandwidth Requirements** | 1 Gbps aggregate | | **Deployment Environments** | 2 environments (non-prod prod) |
| **Traffic Volume** | 10 TB/month | |  |  |
| **Deployment Regions** | 3 Azure regions globally | |  |  |
<!-- END SCOPE_SIZING_TABLE -->

*Note: Changes to these parameters may require scope adjustment and additional investment.*

---

### Solution Overview
**layout:** eo_visual_content

**Azure Virtual WAN Architecture for Global Connectivity**

![Architecture Diagram](assets/diagrams/architecture-diagram.png)

- **Key Components**
  - **Virtual WAN Hub:** Microsoft-managed regional network hub that connects branches, VNets, and Azure services
  - **Branch Connectivity:** SD-WAN integration, site-to-site VPN, or ExpressRoute for office connections
  - **Security Services:** Azure Firewall and routing policies applied consistently across all traffic
- **Technology Stack**
  - Platform: Azure Virtual WAN Standard tier with automated BGP routing
  - Security: Azure Firewall Manager with centralized policies
  - Monitoring: Azure Network Watcher and traffic analytics

---

### Implementation Approach
**layout:** eo_single_column

**Proven Methodology for Global Network Deployment**

- **Phase 1: Network Assessment & Design** (Months 1-2)
  - Inventory all branch locations and current connectivity methods
  - Design hub placement based on user geography and latency requirements
  - Plan IP addressing, routing policies, and security rules
- **Phase 2: Hub Infrastructure Deployment** (Months 3-4)
  - Deploy Virtual WAN hubs in primary Azure regions
  - Configure Azure Firewall and routing policies
  - Connect Azure Virtual Networks to the WAN backbone
- **Phase 3: Branch Connectivity & Optimization** (Months 5-6)
  - Connect branch offices via SD-WAN, VPN, or ExpressRoute
  - Validate end-to-end connectivity and security policies
  - Optimize routing and monitor performance metrics

**SPEAKER NOTES:**

*Risk Mitigation:*
- Network Risks: Pilot with non-critical branch first to validate connectivity patterns
- Security Risks: All traffic flows through Azure Firewall for consistent inspection
- Performance Risks: Latency testing before and after migration to ensure SLA compliance

*Success Factors:*
- Complete inventory of branch locations and bandwidth requirements
- SD-WAN vendor compatibility validated during design phase
- Clear IP addressing plan to avoid routing conflicts

*Talking Points:*
- Each phase builds on the previous with tested connectivity
- Branch offices can be migrated incrementally without business disruption
- Centralized management reduces ongoing operational burden
- Automatic routing eliminates manual configuration errors

---

### Timeline & Milestones
**layout:** eo_table

**Path to Global Network Connectivity**

<!-- TABLE_CONFIG: widths=[10, 25, 15, 50] -->
| Phase No | Phase Description | Timeline | Key Deliverables |
|----------|-------------------|----------|-----------------|
| Phase 1 | Network Assessment & Design | Months 1-2 | Network inventory complete, Hub placement design approved, Routing policy documented |
| Phase 2 | Hub Infrastructure Deployment | Months 3-4 | Virtual WAN hubs operational, Azure Firewall configured, VNet connectivity verified |
| Phase 3 | Branch Connectivity & Optimization | Months 5-6 | All branches connected, Security policies enforced, Performance monitoring active |

**SPEAKER NOTES:**

*Quick Wins:*
- First hub operational and ready for connections - Week 6
- Pilot branch connected with validated routing - Month 4
- Network visibility dashboard showing traffic patterns - Month 5

*Talking Points:*
- Hub deployment provides immediate Azure connectivity for all VNets
- Branch migration happens incrementally with zero downtime
- Each connected branch immediately benefits from centralized security
- Full monitoring enables proactive issue detection before users report problems

---

### Success Stories
**layout:** eo_single_column

**Proven Results in Global Network Transformation**

- **Client Success: International Logistics Company**
  - **Client:** Logistics provider with 45 warehouse locations across three continents
  - **Challenge:** Managing 45 separate VPN tunnels to Azure, inconsistent security policies, 3-day average to add new locations, $180K annual network management costs
  - **Solution:** Deployed Azure Virtual WAN with three regional hubs, SD-WAN integration, centralized Azure Firewall policies, and automated routing
  - **Results:** 55% reduction in network management costs ($99K annual savings), new location connectivity reduced from 3 days to 4 hours, 99.95% network uptime, consistent security policies across all locations
  - **Testimonial:** "Azure Virtual WAN simplified our entire network architecture. Adding a new warehouse used to take days of VPN configuration. Now our team connects a new site in hours with automatic routing and security policies already in place." — **Robert Martinez, VP of IT Infrastructure**, Global Logistics Inc

---

### Our Partnership Advantage
**layout:** eo_two_column

**Why Partner with Us**

- **What We Bring**
  - Azure Network Specialty certification with SD-WAN integration expertise
  - 75+ Azure Virtual WAN deployments for multi-national organizations
  - Direct relationships with leading SD-WAN vendors (Cisco, VMware, Fortinet)
  - Pre-built automation templates for hub deployment and branch connectivity
- **Value to You**
  - Proven methodology reduces deployment risk and accelerates time-to-value
  - SD-WAN vendor partnerships ensure seamless branch integration
  - Experience with complex routing scenarios prevents connectivity issues
  - Knowledge transfer ensures your team manages the network confidently

---

### Investment Summary
**layout:** eo_table

**Total Investment & Value**

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 15, 15, 12, 12, 15] -->
| Cost Category | Year 1 List | Year 1 Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|----------------|------------|--------|--------|--------------|
| Professional Services | $90,500 | ($12,000) | $78,500 | $0 | $0 | $78,500 |
| Cloud Infrastructure | $50,496 | $0 | $50,496 | $50,496 | $50,496 | $151,488 |
| Software Licenses | $3,600 | $0 | $3,600 | $3,600 | $3,600 | $10,800 |
| Support & Maintenance | $11,448 | $0 | $11,448 | $11,448 | $11,448 | $34,344 |
| **TOTAL** | **$156,044** | **($12,000)** | **$144,044** | **$65,544** | **$65,544** | **$275,132** |
<!-- END COST_SUMMARY_TABLE -->

*Note: Actual costs will be calculated based on number of hubs, connected branches, and bandwidth requirements. Cloud Infrastructure includes Virtual WAN hub fees, Azure Firewall consumption, and VPN gateway charges.*

**SPEAKER NOTES:**

*Credit Program Talking Points:*
- Microsoft Partner Services Credit ($12,000) applied to network design and hub deployment
- Credits are real Azure account credits automatically applied as services are consumed
- Total Year 1 credits: $12,000 (8% reduction from list price)

*Value Positioning:*
- Compare total cost against current network management expenses
- Highlight 50-60% reduction in operational overhead
- Emphasize automatic failover and improved reliability

*Cost Breakdown Strategy:*
- Virtual WAN hub fees based on number of regional hubs needed
- Branch connectivity costs depend on VPN throughput or ExpressRoute circuits
- Azure Firewall consumption based on traffic volume processed
- Professional services are one-time implementation costs

*Handling Objections:*
- "We already have VPNs working" - Current solution requires manual management per site
- "SD-WAN vendor lock-in" - Virtual WAN supports multiple SD-WAN partners
- "Latency concerns" - Microsoft backbone optimizes traffic routing automatically

*Talking Points:*
- Transparent pricing with pay-per-use model for actual consumption
- No upfront hardware costs for hub infrastructure
- Costs scale predictably as you add more branches

---

### Next Steps
**layout:** eo_bullet_points

**Your Path Forward**

- **Network Inventory:** Compile list of all branch locations with current connectivity methods
- **Decision:** SOW approval and contract execution by [Target Date]
- **Kickoff:** Project initiation scheduled for [Start Date] with network team engaged
- **Week 1-2:** Network discovery, requirements workshop, hub placement design, and IP addressing plan
- **Week 3-4:** SD-WAN vendor coordination, compatibility verification, and pilot branch selection

**SPEAKER NOTES:**

*Call to Action:*
- "Let's schedule a follow-up meeting to review branch connectivity and finalize the SOW"
- "What questions can I answer to help you move forward with confidence?"
- "Our next available start date is [Date] - shall we reserve that slot for your team?"

*Transition from Investment:*
- "Now that we've covered the investment, let's discuss getting started"
- Network inventory is essential for accurate design and sizing
- Emphasize that discovery work can begin immediately

*Walking Through Next Steps:*
- Network inventory identifies all connectivity requirements upfront
- Hub placement design optimizes latency for user locations
- SD-WAN coordination ensures smooth branch integration
- Pilot branch allows validation before full rollout

*Talking Points:*
- Our team can start discovery immediately upon contract signature
- Pilot branch provides proof of concept before committing all locations
- Incremental migration minimizes business disruption
- You'll see first hub operational within 6 weeks

---

### Thank You
**layout:** eo_thank_you

- **Your Account Manager:** [Name, Title] | [Email] | [Phone]

**SPEAKER NOTES:**

*Closing Strong:*
- Thank them for their time and consideration
- Reiterate the network simplification opportunity
- Introduce team members who will support implementation
- Make yourself available for technical deep-dive questions

*Call to Action:*
- "What questions do you have about Virtual WAN capabilities?"
- "Which branch locations would make good candidates for pilot?"
- "Would you like to see a demo of the Azure network monitoring?"
- Offer to schedule technical architecture review with their network team

*Handling Q&A:*
- Listen to specific network concerns and address with Azure features
- Offer reference calls with similar customers if requested
- Schedule follow-up for detailed technical design discussion
- Send meeting summary with next steps within 24 hours

*Closing Techniques:*
- "Shall we schedule the network inventory workshop?"
- "Can we arrange a call with your SD-WAN vendor to discuss integration?"
- "Would next week work for a follow-up with your network engineers?"
- Confirm clear next steps and timeline before leaving

---

## Presentation Notes

**Speaking Points for Each Slide**

Slide 1 - Welcome and introduce yourself as their network modernization partner.

Slide 2 - Focus on eliminating VPN complexity and reducing network management burden.

Slide 3 - Show how Virtual WAN hub replaces traditional hub-spoke VPN architecture.

Slide 4 - Emphasize incremental migration with no downtime for branch offices.

Slide 5 - Highlight quick wins: first hub ready in 6 weeks, pilot branch connected by Month 4.

Slide 6 - Use logistics case study to show measurable cost savings and operational improvements.

Slide 7 - Stress SD-WAN vendor partnerships and network specialty certification.

Slide 8 - Walk through costs based on their specific number of hubs and branches.

Slide 9 - Network inventory is the critical first step - can start immediately.

Slide 10 - Offer technical architecture review with their network team as next step.

---

## Appendix Slides (If Needed)

A1: Detailed Hub Deployment Architecture
A2: SD-WAN Vendor Compatibility Matrix
A3: Azure Firewall Policy Examples
A4: Network Monitoring Dashboard Screenshots
A5: Branch Connectivity Options Comparison (VPN vs ExpressRoute)
A6: Pricing Calculator Based on Hubs and Branches
