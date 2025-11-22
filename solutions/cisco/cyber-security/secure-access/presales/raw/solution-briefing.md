---
presentation_title: Solution Briefing
solution_name: Cisco ISE Secure Network Access
presenter_name: [Presenter Name]
client_logo: ../../assets/logos/client_logo.png
footer_logo_left: ../../assets/logos/consulting_company_logo.png
footer_logo_right: ../../assets/logos/eo-framework-logo-real.png
---

# Cisco ISE Secure Network Access - Solution Briefing

## Slide Deck Structure
**10 Slides - Fixed Format**

---

### Slide 1: Title Slide
**layout:** eo_title_slide

**Presentation Title:** Solution Briefing
**Subtitle:** Cisco ISE Secure Network Access
**Presenter:** [Presenter Name] | [Current Date]

---

### Business Opportunity
**layout:** eo_two_column

**Secure Network Access with Zero Trust Architecture**

- **Opportunity**
  - Eliminate unauthorized network access reducing security breaches by 90% with 802.1X authentication
  - Achieve micro-segmentation with TrustSec reducing lateral threat movement by 85%
  - Automate BYOD onboarding reducing helpdesk tickets by 70% with self-service provisioning
- **Success Criteria**
  - 100% device authentication compliance across wired and wireless networks
  - 90% reduction in network security incidents through policy enforcement
  - ROI realization within 24 months through reduced security incidents and helpdesk costs

---

### Engagement Scope
**layout:** eo_table

**Sizing Parameters for This Engagement**

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_SIZING_TABLE -->
<!-- TABLE_CONFIG: widths=[18, 29, 5, 18, 30] -->
| Parameter | Scope | | Parameter | Scope |
|-----------|-------|---|-----------|-------|
| **Primary Features/Capabilities** | ISE for 1000 users 2000 devices | | **Availability Requirements** | Standard (99.5%) |
| **Customization Level** | Standard ISE deployment | | **Infrastructure Complexity** | Basic campus network |
| **External System Integrations** | 2 systems (AD + switches) | | **Security Requirements** | Basic 802.1X authentication |
| **Data Sources** | User identity only | | **Compliance Frameworks** | Basic logging |
| **Total Users** | 1000 employees and guests | | **Performance Requirements** | Standard authentication speed |
| **User Roles** | 2 roles (employee + guest) | | **Deployment Environments** | Production only |
| **Data Processing Volume** | 2000 endpoint authentications | |  |  |
| **Data Storage Requirements** | 100 GB (90-day logs) | |  |  |
| **Deployment Regions** | Single site | |  |  |
<!-- END SCOPE_SIZING_TABLE -->

*Note: Changes to these parameters may require scope adjustment and additional investment.*

---

### Solution Overview
**layout:** eo_visual_content

**Zero Trust Network Access for 1000 Users and 2000 Devices**

![Architecture Diagram](assets/diagrams/architecture-diagram.png)

- **Key Components**
  - Cisco ISE 3615 appliances in HA configuration supporting 3000 endpoints
  - 802.1X authentication with Active Directory integration for users
  - TrustSec micro-segmentation with security group tags and policy matrix
- **Technology Stack**
  - Platform: Cisco ISE Plus with 802.1X, MAB, BYOD, and guest access
  - Authorization: TrustSec security groups with policy-based access control
  - Integration: Active Directory LDAP and certificate-based authentication

---

### Implementation Approach
**layout:** eo_single_column

**Proven Deployment Methodology**

- **Phase 1: Foundation & Policy (Weeks 1-8)**
  - ISE HA deployment, Active Directory integration, and 802.1X readiness assessment
  - Authentication policy framework design with 802.1X and MAB configuration
  - BYOD and guest portal setup with sponsor workflows
- **Phase 2: Integration & Testing (Weeks 9-13)**
  - TrustSec security group tag design and policy matrix configuration
  - Network infrastructure integration with switches and WLCs
  - Lab validation and pilot deployment with IT department (50-100 users)
- **Phase 3: Production Rollout (Weeks 14-16)**
  - Phased production rollout: wired, wireless, BYOD, and guest access
  - TrustSec policy enforcement across network infrastructure
  - Hypercare support and operational handoff

**SPEAKER NOTES:**

*Risk Mitigation:*
- Device compatibility ensured through pre-implementation audit confirming 802.1X supplicant support
- Phased rollout strategy with IT pilot validates process before production deployment to users
- Fallback mechanisms (MAB and guest access) ensure legacy device connectivity during transition
- All configuration changes during maintenance windows with documented rollback procedures

*Success Factors:*
- Team readiness with 40 hours training for ISE administrators and helpdesk staff on support workflows
- Executive sponsorship secured with pilot demonstrating security value and BYOD cost savings
- Self-service BYOD portal minimizes helpdesk burden and user friction during onboarding
- Clear milestones with pilot validation reducing timeline and technical risk

*Talking Points:*
- Pilot in Phase 2 with IT department validates authentication before company-wide rollout
- Self-service BYOD eliminates manual provisioning reducing helpdesk tickets by 70%
- 16-week deployment delivers progressive security value with operational capabilities expanding
- TrustSec micro-segmentation provides zero trust without VLAN proliferation complexity

---

### Timeline & Milestones
**layout:** eo_table

**Path to Value Realization**

<!-- TABLE_CONFIG: widths=[10, 25, 15, 50] -->
| Phase No | Phase Description | Timeline | Key Deliverables |
|----------|-------------------|----------|------------------|
| Phase 1 | Foundation | Weeks 1-4 | ISE HA deployed, Active Directory integrated, 802.1X readiness validated |
| Phase 2 | Policy Development | Weeks 5-8 | Authentication policies configured, BYOD portal operational, Guest workflow ready |
| Phase 3 | TrustSec & Integration | Weeks 9-12 | TrustSec SGTs designed, Network infrastructure integrated, Lab validation complete |
| Phase 4 | Deployment | Weeks 13-16 | IT pilot validated (50-100 users), Production rollout complete (1000 users), TrustSec enforced |

**SPEAKER NOTES:**

*Quick Wins:*
- ISE infrastructure operational by Week 4 ready for authentication services
- BYOD self-service portal live by Week 8 eliminating manual device provisioning
- IT pilot with 50-100 users by Week 14 proving authentication and policy effectiveness

*Talking Points:*
- Foundation phase in Weeks 1-4 establishes ISE platform and Active Directory integration
- Policy development in Weeks 5-8 builds authentication framework for all use cases
- TrustSec integration in Weeks 9-12 enables micro-segmentation and zero trust architecture
- Full deployment by Week 16 with 1000 users authenticated and TrustSec policy enforced

---

### Success Stories
**layout:** eo_single_column

- **Client Success: Healthcare System**
  - **Client:** Multi-hospital system with 1200 users and 2500 devices
  - **Challenge:** Unauthorized access creating compliance risk. 150+ monthly BYOD tickets. Medical IoT lacking 802.1X support.
  - **Solution:** Cisco ISE with 802.1X, MAB for IoT, BYOD portal, TrustSec segmentation.
  - **Results:** 100% compliance. 78% ticket reduction (150 to 33). 92% fewer unauthorized access attempts. $82K savings, 22-month ROI.
  - **Testimonial:** "ISE gave us HIPAA compliance visibility. The BYOD portal eliminated helpdesk burden, and TrustSec protects patient data without VLAN complexity." — **Dr. Maria Rodriguez**, CISO

---

### Our Partnership Advantage
**layout:** eo_two_column

**Why Partner with Us for Cisco ISE**

- **What We Bring**
  - 12+ years delivering Cisco ISE and network security solutions with proven deployments
  - 45+ successful ISE implementations across healthcare, finance, education, government sectors
  - Cisco Gold Partner with Security Architecture Specialization and CCIE Security expertise
  - Deep experience with 802.1X, TrustSec, BYOD, and guest access workflows
- **Value to You**
  - Pre-built ISE policy templates for healthcare, finance, and enterprise accelerate deployment
  - Proven integration patterns for Active Directory, RADIUS, and certificate authorities
  - Best practices from 45+ implementations avoiding common authentication and policy pitfalls
  - Ongoing support for policy tuning and troubleshooting as security requirements evolve

---

### Investment Summary
**layout:** eo_table

**3-Year Total Cost of Ownership**

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 15, 15, 12, 12, 15] -->
| Cost Category | Year 1 List | Year 1 Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|----------------|------------|--------|--------|--------------|
| Professional Services | $82,200 | $0 | $82,200 | $0 | $0 | $82,200 |
| Hardware | $80,000 | $0 | $80,000 | $0 | $0 | $80,000 |
| Software | $75,000 | ($10,000) | $65,000 | $75,000 | $75,000 | $215,000 |
| Support | $31,000 | $0 | $31,000 | $31,000 | $31,000 | $93,000 |
| **TOTAL** | **$268,200** | **($10,000)** | **$258,200** | **$106,000** | **$106,000** | **$470,200** |
<!-- END COST_SUMMARY_TABLE -->

**Cisco Partner Credits (Year 1 Only):**
- ISE Plus License Promotion: $10,000 credit (20% discount on 3000-endpoint ISE Plus licenses)
- Applied directly to Cisco software purchase reducing Year 1 investment

**SPEAKER NOTES:**

*Value Positioning:*
- Lead with credits: You qualify for $10K in ISE Plus license promotion credits
- Net Year 1 investment of $258.2K after partner credits for complete zero trust access platform
- 3-year TCO of $470.2K vs. security incident costs of $200K-500K+ per breach
- Annual recurring cost of $106K covers ISE subscriptions and SmartNet support renewals

*Credit Program Talking Points:*
- Real ISE Plus license promotion credits applied to software purchase
- We handle all Cisco partner program paperwork and credit application
- 95% approval rate through our Cisco Gold Partner status
- Credits applied at time of purchase reducing Year 1 software investment

*Handling Objections:*
- Can we use open source? ISE integrates with Cisco switching/wireless and provides TrustSec capabilities
- Why not cloud NAC? ISE provides on-premises control with Intersight cloud management option
- Are credits guaranteed? Yes, subject to standard Cisco partner program approval and licensing
- What about ongoing costs? Years 2-3 are $106K/year (ISE subscriptions and support renewals)

---

### Next Steps
**layout:** eo_bullet_points

**Your Path Forward**

- **Decision:** Executive approval for $258.2K Year 1 investment by [specific date]
- **Hardware Procurement:** Order ISE 3615 appliances (4-6 week lead time) with data center preparation
- **Team Formation:** Assign security lead, network team, and coordinate with Active Directory administrators
- **Week 1-4:** Foundation phase with 802.1X readiness assessment, ISE deployment, and AD integration
- **Week 5-16:** Policy development and rollout with BYOD/guest configuration, pilot validation, and production deployment

**SPEAKER NOTES:**

*Transition from Investment:*
- Now that we have covered the investment and proven security ROI, let us talk about getting started
- Emphasize hardware lead time (4-6 weeks) requires decision within 2 weeks for Q4 deployment
- Show how pilot with IT department validates authentication before company-wide rollout

*Walking Through Next Steps:*
- Decision needed for Year 1 investment covering services, hardware, software, and support
- Hardware procurement critical path with 4-6 week Cisco factory lead time for ISE appliances
- Foundation phase in Weeks 1-4 runs parallel to hardware delivery maximizing efficiency
- Pilot with IT department (50-100 users) in Week 14 validates approach before production

*Call to Action:*
- Schedule executive approval meeting to review $258.2K investment and zero trust security business case
- Begin data center planning for ISE appliance rack space, power, and network connectivity
- Identify security lead and network team members for 802.1X readiness assessment
- Request Active Directory structure documentation and network switch inventory for integration planning

---

### Thank You
**layout:** eo_thank_you

- **Your Account Manager:** [Name, Title] | [Email] | [Phone]

**SPEAKER NOTES:**

*Closing Strong:*
- Thank them for their time and consideration of Cisco ISE zero trust network access investment
- Reiterate the network security opportunity with measurable breach reduction and compliance benefits
- Introduce security team members who will support implementation and ongoing policy management
- Make yourself available for technical deep-dive on 802.1X, TrustSec, or BYOD workflows

*Call to Action:*
- "What questions do you have about ISE and zero trust network access?"
- "Which user groups would be best for the pilot phase - IT department or specific business unit?"
- "Would you like to see a demo of the BYOD self-service portal or TrustSec segmentation capabilities?"
- Offer to schedule technical architecture review with their security and network teams

*Handling Q&A:*
- Listen to specific security challenges and address with ISE authentication and segmentation features
- Be prepared to discuss device compatibility, certificate requirements, and legacy device support (MAB)
- Emphasize pilot approach with IT department reduces risk and builds team confidence
- Address hardware lead time concerns and offer to expedite procurement if decision made promptly
