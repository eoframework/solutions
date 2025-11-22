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
  - Cisco ISE 3615 appliances (primary + secondary HA) supporting 3000 concurrent endpoints
  - 802.1X authentication with Active Directory integration for corporate users
  - TrustSec micro-segmentation with security group tags and policy matrix
- **Technology Stack**
  - Identity Platform: Cisco Identity Services Engine (ISE) Plus
  - Authentication: 802.1X wired/wireless, MAB for non-supplicant devices
  - Authorization: TrustSec security groups with policy-based access control
  - BYOD: Self-service onboarding with certificate provisioning for iOS/Android
  - Guest: Sponsor-based workflow with time-limited access

---

### Implementation Approach
**layout:** eo_single_column

**Proven 4-Phase Deployment Methodology**

- **Phase 1: Foundation (Weeks 1-4)**
  - Network assessment for 802.1X readiness and switch/WLC compatibility
  - ISE appliance deployment with primary and secondary HA configuration
  - Active Directory integration with LDAP and identity source setup
- **Phase 2: Policy Development (Weeks 5-8)**
  - Authentication and authorization policy framework design
  - 802.1X wired and wireless configuration with fallback MAB
  - BYOD self-service portal configuration for iOS and Android
  - Guest portal setup with sponsor workflow and approval process
- **Phase 3: TrustSec & Integration (Weeks 9-12)**
  - TrustSec security group tag (SGT) design and matrix configuration
  - Network infrastructure integration: switches and WLCs configured for 802.1X
  - Lab validation with end-to-end authentication testing
- **Phase 4: Deployment (Weeks 13-16)**
  - Pilot deployment with IT department (50-100 users) for validation
  - Phased production rollout: wired authentication, then wireless and BYOD
  - Guest WiFi enablement with portal and sponsor workflows
  - TrustSec policy enforcement and hypercare support (4 weeks)

---

### Business Value Delivered
**layout:** eo_two_column

**Measurable Security Enhancement and Operational Efficiency**

- **Operational Excellence**
  - 70% reduction in helpdesk tickets: self-service BYOD onboarding eliminates manual provisioning
  - 100% network visibility: all devices authenticated and profiled for compliance
  - Automated compliance: continuous posture assessment ensures policy adherence
- **Financial Impact**
  - $65K annual savings from reduced security incidents and faster breach detection
  - $28K helpdesk savings from automated BYOD onboarding workflows
  - 24-month payback period with ongoing security risk reduction
- **Risk Mitigation**
  - 90% reduction in unauthorized access through mandatory 802.1X authentication
  - 85% reduction in lateral threat movement via TrustSec micro-segmentation
  - Complete audit trail showing who connected what device where and when

---

### Technical Architecture
**layout:** eo_single_column

**Scalable Zero Trust Access Platform**

- **ISE Infrastructure**
  - Primary ISE 3615 appliance (3000 endpoint capacity) with policy service node (PSN)
  - Secondary ISE 3615 for high availability and failover protection
  - Hosted in data center with redundant power and network connectivity
- **Software Licensing**
  - ISE Plus (3000 endpoints): includes TrustSec, profiling, BYOD, guest access
  - Device Admin (500 devices): TACACS+ for network device administration (optional)
  - Active Directory Connector: LDAP integration for identity source
- **Authentication Methods**
  - 802.1X with EAP-TLS or PEAP-MSCHAPv2 for corporate devices
  - MAC Authentication Bypass (MAB) for printers, IoT, and legacy devices
  - Guest authentication with portal-based credential management
- **TrustSec Segmentation**
  - Security Group Tags (SGT) for dynamic classification
  - Policy matrix for group-based access control without VLANs
  - Inline tagging on switches and enforcement at network edge

---

### Risk Mitigation Strategy
**layout:** eo_single_column

**Comprehensive Approach to Project Success**

- **Technical Risk Mitigation**
  - Device compatibility: Pre-implementation audit confirms 802.1X supplicant support
  - Phased rollout: Pilot validates process with low-risk IT department first
  - Fallback mechanisms: MAB and guest access ensure legacy device connectivity
- **Organizational Risk Mitigation**
  - Team readiness: 40 hours training for administrators and helpdesk staff
  - Change resistance: Executive sponsorship secured; pilot demonstrates value
  - User impact: Self-service BYOD minimizes helpdesk burden and user friction
- **Implementation Risk Mitigation**
  - Timeline delays: Clear milestones with pilot validation before production
  - Production disruption: All changes during maintenance windows with rollback plans
  - Authentication failures: Monitoring dashboards detect issues before user impact

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

**Year 1 includes:** $10K ISE license promotion credit (20% discount)

**Annual recurring cost:** $106K/year (software licenses and support)

---

### Next Steps
**layout:** eo_single_column

**Path to Deployment Success**

1. **Executive Approval (Week 0)**
   - Review and approve $258.2K Year 1 investment
   - Assign technical lead and security team
   - Secure budget and resources for implementation

2. **Hardware Procurement (Weeks 1-2)**
   - Order ISE 3615 appliances (4-6 week lead time)
   - Plan data center rack space, power, and network connectivity
   - Coordinate delivery and installation logistics

3. **Discovery Phase (Weeks 1-4)**
   - Network infrastructure assessment (40 hours) for 802.1X readiness
   - Active Directory structure analysis and identity planning
   - Security requirements gathering and policy framework design

4. **Development Phase (Weeks 5-12)**
   - Deploy ISE appliances with HA configuration (80 hours)
   - Configure authentication, BYOD, and guest policies (140 hours)
   - Integrate with Active Directory and network infrastructure (80 hours)

5. **Deployment (Weeks 13-16)**
   - Pilot deployment with IT department for validation
   - Phased production rollout: wired, wireless, BYOD, guest access
   - TrustSec enforcement and hypercare support (60 hours)

**Recommended decision date:** Within 2 weeks to meet hardware lead time and Q4 deployment target
