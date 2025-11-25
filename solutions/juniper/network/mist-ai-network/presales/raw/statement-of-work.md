---
document_title: Statement of Work
technology_provider: Juniper
project_name: Mist AI Network Implementation
client_name: [Client Name]
client_contact: [Contact Name | Email | Phone]
consulting_company: Your Consulting Company
consultant_contact: [Consultant Name | Email | Phone]
opportunity_no: OPP-2025-001
document_date: November 15, 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This section provides a high-level overview of the project scope, business objectives, expected outcomes, and timeline for the Juniper Mist AI Network implementation.

## Project Overview

This Statement of Work (SOW) outlines the scope, deliverables, timeline, and terms for the implementation of Juniper Mist AI Network for [CLIENT_NAME]. The project will deliver AI-driven wireless network delivering 99.9% uptime and 90% troubleshooting time reduction through deployment of Juniper Mist cloud-managed WiFi 6E infrastructure with predictive analytics.

## Business Objectives

- **Primary Goal:** Deploy AI-powered wireless network with 50 WiFi 6E access points, Marvis virtual assistant, and location services to eliminate manual WiFi troubleshooting and achieve 99.9% uptime
- **Success Metrics:** 99.9% wireless uptime with AI anomaly detection, 60% reduction in wireless helpdesk tickets through Marvis AI, zero manual RF optimization with automated tuning, real-time client experience tracking
- **Expected ROI:** 60% reduction in wireless operations costs through AI-driven automation, 75% reduction in troubleshooting time, and measurable improvements in user experience and satisfaction

## Project Duration

**Start Date:** [PROJECT_START_DATE]
**End Date:** [PROJECT_END_DATE]
**Total Duration:** 8 weeks

---

# Background & Objectives

This section outlines the current state of the Client's wireless infrastructure, defines the business objectives driving this initiative, and establishes measurable success metrics for project evaluation.

## Current State

[Client Name] currently operates wireless infrastructure with poor WiFi coverage, manual troubleshooting processes, and no visibility into client experience. Key challenges include:
- **Manual Troubleshooting Bottlenecks:** Hours of staff time required per WiFi incident with packet captures and trial-and-error diagnostics
- **Limited Visibility:** No real-time insights into client connectivity, roaming performance, or application experience
- **RF Optimization Complexity:** Manual channel and power tuning requiring specialized expertise and ongoing maintenance
- **Helpdesk Overload:** Wireless connectivity complaints consuming significant helpdesk resources
- **Scalability Limitations:** Controller-based architecture cannot easily scale across multiple locations

## Business Objectives

- **Eliminate Manual Troubleshooting:** Implement Marvis AI virtual assistant to automatically diagnose and resolve WiFi issues, reducing troubleshooting time by 90%
- **Achieve 99.9% Uptime:** Deploy cloud-managed WiFi 6E infrastructure with AI-driven proactive anomaly detection before user impact
- **Enable Location Services:** Implement virtual Bluetooth LE for indoor wayfinding and asset tracking without physical beacon hardware
- **Reduce Helpdesk Tickets:** Achieve 60% reduction in wireless helpdesk tickets through AI-driven self-service troubleshooting
- **Automate RF Optimization:** Eliminate manual RF tuning with AI algorithms that automatically adjust channels and power for optimal performance
- **Foundation for Growth:** Enable foundation for expanding wireless infrastructure across additional buildings and locations

## Success Metrics

- 99.9% wireless uptime with AI-driven predictive maintenance
- 60% reduction in wireless helpdesk tickets within 6 months
- Zero manual RF optimization with automated channel and power tuning
- 99% successful connection SLE (Service Level Expectation) for client devices
- Real-time client experience tracking with measurable performance improvements
- 90% reduction in time-to-resolution for wireless incidents

---

# Scope of Work

This section defines the detailed scope of work for the Mist AI Network implementation, including all in-scope activities, deliverables, and explicitly excluded items to ensure clear expectations and project boundaries.

## In Scope

The following services and deliverables are included in this SOW:
- Wireless requirements assessment and RF site survey
- Mist Cloud architecture design and configuration
- WiFi 6E access point deployment and installation
- Switch infrastructure deployment and wired assurance
- Marvis AI activation and optimization
- Location services implementation with vBLE
- Integration with existing authentication systems
- Testing, validation, and performance verification
- Knowledge transfer and documentation

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | WiFi 6E Access Points | 50 Juniper AP45 APs |
| Solution Scope | Wired Assurance | 4 EX4400 PoE switches |
| Integration | SSIDs and VLANs | 3-5 wireless networks |
| Integration | External System Integrations | 2 integrations |
| Integration | Location Services | Indoor positioning enabled |
| User Base | Concurrent Wireless Users | 500-1000 concurrent users |
| User Base | Network Administrators | 3 wireless administrators |
| Data Volume | Access Point Count | 50 access points |
| Data Volume | Client Device Count | 2000 total devices |
| Technical Environment | Building Types | Office commercial building |
| Technical Environment | Deployment Locations | Single building multi-floor |
| Technical Environment | RF Environment | Standard office construction |
| Security & Compliance | Authentication Methods | 802.1X RADIUS |
| Security & Compliance | Compliance Frameworks | Basic security SOC 2 |
| Performance | Coverage Requirements | Standard office coverage |
| Performance | Client Experience SLEs | 99% successful connects |
| Environment | Deployment Environments | 2 environments (staging prod) |
<!-- END SCOPE_PARAMETERS_TABLE -->

*Note: Changes to these parameters may require scope adjustment and additional investment.*

## Activities

### Phase 1 – Discovery & Planning (Weeks 1-2)

During this initial phase, the Vendor will perform a comprehensive assessment of the Client's current wireless infrastructure and requirements. This includes analyzing existing WiFi coverage, identifying coverage gaps, determining client device requirements, and designing the optimal Mist AI wireless solution approach.

Key activities:
- Wireless requirements assessment analyzing current WiFi coverage, performance, and pain points
- Facility assessment reviewing building layouts, construction materials, and coverage requirements
- RF site survey using Mist AI planning tools for predictive coverage modeling and AP placement design
- WLAN architecture design with SSID strategy, VLAN segmentation, and security policies
- Location services design for vBLE indoor positioning, wayfinding maps, and asset tracking
- Authentication requirements analysis (802.1X, RADIUS, Active Directory integration)
- Wired infrastructure assessment for PoE switch requirements and uplink connectivity
- Implementation planning and resource allocation with detailed timeline

This phase concludes with a Design Document that outlines the proposed Mist AI wireless architecture, AP placement design, WLAN configuration, integration approach, and project timeline.

### Phase 2 – Infrastructure Deployment (Weeks 3-5)

In this phase, the wireless infrastructure is deployed and configured based on AI-driven wireless best practices. This includes switch deployment, access point installation, Mist Cloud configuration, and initial RF optimization.

Key activities:
- EX4400 PoE switch deployment at distribution closets with uplink connectivity
- AP45 WiFi 6E access point mounting and cabling (50 access points)
- Mist Cloud organization setup with site configuration and floor plan uploads
- WLAN configuration (SSIDs, VLANs, security policies, authentication)
- RF policy configuration for auto-channel assignment and power optimization
- Access point claiming and assignment to Mist Cloud organization
- Initial RF validation with coverage heatmaps and signal strength verification
- Network connectivity testing and VLAN validation across all SSIDs

By the end of this phase, the Client will have operational WiFi 6E infrastructure with basic wireless connectivity.

### Phase 3 – AI Services Enablement (Week 6)

Implementation of advanced Mist AI services including Marvis virtual assistant, location services, and wired assurance for comprehensive network management.

Key activities:
- Marvis AI activation and baseline establishment for anomaly detection
- Location services configuration with vBLE for indoor positioning
- Wayfinding map creation for mobile application and web portal
- Wired Assurance enablement for EX4400 switches with unified dashboard
- Authentication integration with RADIUS or Active Directory for 802.1X
- Guest WiFi portal configuration (if required)
- Client experience SLE configuration (successful connects, coverage, capacity, roaming)
- Performance baseline establishment with AI-driven insights

After this phase, all advanced AI services are operational and monitoring client experience.

### Phase 4 – Testing & Validation (Week 7)

In the Testing and Validation phase, the Mist AI Network undergoes thorough functional, performance, and user experience validation to ensure it meets required SLAs and client expectations. Test cases will be executed based on Client-defined acceptance criteria.

Key activities:
- RF validation testing with coverage verification across all areas
- Client connectivity testing with various device types (laptops, tablets, smartphones)
- Roaming performance testing with mobility between access points
- Throughput testing with high-bandwidth applications (video conferencing, file transfers)
- Location services testing for positioning accuracy and wayfinding validation
- SLE validation confirming 99% successful connection rates
- High-density testing with concurrent client loads
- User Acceptance Testing (UAT) coordination with IT and business users
- Go-live readiness review and legacy AP cutover planning

Cutover will be coordinated with all relevant stakeholders and executed during an approved maintenance window, with documented rollback procedures in place.

### Phase 5 – Handover & Post-Implementation Support (Week 8)

Following successful implementation and cutover, the focus shifts to ensuring operational continuity and knowledge transfer. The Vendor will provide a period of hypercare support and equip the Client's team with the documentation, tools, and processes needed for ongoing maintenance and optimization.

Activities include:
- Delivery of as-built documentation (RF coverage maps, WLAN configuration, AP locations)
- Operations runbook and SOPs for day-to-day wireless network management
- Mist dashboard training covering wireless monitoring, Marvis AI, and location services
- AI-driven troubleshooting training using Marvis conversational interface
- Live or recorded knowledge transfer sessions for administrators and helpdesk staff
- SLE monitoring and optimization recommendations based on real-world usage
- 30-day warranty support for issue resolution and performance tuning
- Optional transition to a managed services model for ongoing support, if contracted

---

## Out of Scope

These items are not in scope unless added via change control:
- Hardware procurement for access points and switches (Client responsible)
- Structured cabling installation or conduit work for AP mounting locations
- Power infrastructure upgrades or PoE switch power capacity expansion
- Legacy wireless controller decommissioning or AP removal
- Historical wireless analytics or back-file data migration
- Ongoing operational support beyond 30-day warranty period
- Custom development for location-based applications beyond standard wayfinding
- End-user device configuration or troubleshooting
- Mobile application development for wayfinding (standard Mist app provided)
- Mist Cloud subscription costs (billed directly by Juniper to client)

---

# Deliverables & Timeline

This section details all project deliverables including documentation, system components, knowledge transfer activities, project milestones, critical dependencies, and timeline for successful completion of the Mist AI Network implementation.

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Wireless Requirements Assessment | Document | Week 2 | Network Manager |
| 2 | RF Site Survey and Design Document | Document | Week 2 | Network Manager |
| 3 | WLAN Architecture Design | Document | Week 2 | Security Lead |
| 4 | AP Placement Map with Coverage Heatmaps | Diagram | Week 2 | Network Manager |
| 5 | Mist Cloud Configuration (SSIDs VLANs RFs) | System | Week 5 | Network Team |
| 6 | 50x AP45 WiFi 6E Access Points Deployed | System | Week 5 | Network Team |
| 7 | 4x EX4400 PoE Switches Deployed | System | Week 5 | Network Team |
| 8 | Marvis AI Activated and Operational | System | Week 6 | IT Manager |
| 9 | Location Services with vBLE Enabled | System | Week 6 | Facilities Team |
| 10 | Wired Assurance for Unified Management | System | Week 6 | Network Team |
| 11 | RF Validation Test Results | Document | Week 7 | Network Manager |
| 12 | Performance Testing Report (Throughput SLEs) | Document | Week 7 | IT Manager |
| 13 | As-Built Documentation and Diagrams | Document | Week 8 | Network Manager |
| 14 | Operations Runbook and SOPs | Document | Week 8 | Operations Team |
| 15 | Administrator Training Completion | Training | Week 8 | IT Manager |
| 16 | Knowledge Transfer Sessions (Recorded) | Training | Week 8 | IT Manager |

Table: Project Deliverables and Acceptance Criteria

## Project Milestones

| Phase | Duration | Start Date | End Date | Key Milestones |
|-------|----------|------------|----------|----------------|
| **Discovery & Planning** | 2 weeks | [DATE] | [DATE] | Requirements approved, RF design completed, Mist Cloud configured |
| **Infrastructure Deployment** | 3 weeks | [DATE] | [DATE] | Switches deployed, 50 APs installed, Wireless operational |
| **AI Services Enablement** | 1 week | [DATE] | [DATE] | Marvis AI activated, Location services enabled, Wired Assurance operational |
| **Testing & Validation** | 1 week | [DATE] | [DATE] | RF validation completed, UAT approved, Legacy AP cutover |
| **Handover & Support** | 1 week | [DATE] | [DATE] | Training completed, Documentation delivered, Production handoff |

### Critical Milestones

- **Week 1:** Requirements gathering completed with building floor plans and existing network documentation
- **Week 2:** RF site survey completed with predictive coverage modeling and AP placement finalized
- **Week 4:** First access points deployed and operational with initial wireless connectivity
- **Week 5:** All 50 access points deployed with complete building coverage
- **Week 6:** Marvis AI operational with proactive anomaly detection and location services enabled
- **Week 7:** RF validation completed confirming 99% successful connection SLE
- **Week 8:** Project acceptance and production handoff with administrator training completed

### Critical Dependencies

- Client provides timely access to building facilities, floor plans, and existing network documentation
- IT and network teams available for requirements gathering, testing, and cutover activities
- Maintenance windows approved for legacy AP cutover during off-peak hours
- AP and switch hardware delivered with 2-week lead time from project kickoff
- Authentication system access (RADIUS Active Directory) for 802.1X integration
- Network infrastructure (VLANs, DHCP, DNS) configured to support wireless requirements
- Facilities coordination for AP mounting locations and access to ceiling spaces

---

# Roles & Responsibilities

This section defines the roles, responsibilities, and accountability for both Vendor and Client teams throughout the Mist AI Network implementation project. Clear definition of responsibilities ensures effective collaboration, timely decision-making, and successful project delivery.

### Vendor Responsibilities ([VENDOR_NAME])

- **Project Manager:** Overall project coordination, timeline management, and stakeholder communication
- **Wireless Architect:** Wireless design, RF site survey, and architecture oversight
- **Senior Implementation Engineer:** Mist Cloud configuration, AP deployment, and AI services enablement
- **Network Engineer:** Switch deployment, VLAN configuration, and integration with existing network
- **Training Specialist:** Administrator and helpdesk training delivery and knowledge transfer
- **Support Engineer:** Post-deployment support during 30-day warranty period

### Client Responsibilities ([CLIENT_NAME])

- **Project Sponsor:** Executive oversight, business decision authority, and resource allocation
- **Network Manager:** Infrastructure coordination, change approvals, and technical escalation
- **Wireless Lead:** Requirements validation, RF design review, and acceptance testing
- **Wireless Administrators:** Hands-on participation in deployment, testing, and knowledge transfer
- **Facilities Team:** Building access coordination, AP mounting locations, and ceiling access
- **Operations Team:** Post-deployment system administration and ongoing maintenance

### Shared Responsibilities

- Risk management and issue escalation procedures
- Change control and maintenance window coordination
- Quality assurance and acceptance testing validation
- Communication and stakeholder management throughout project lifecycle

---

# Architecture & Design

This section outlines the technical architecture, design principles, and infrastructure components for the Mist AI Network implementation.

## Architecture Overview

The solution implements a cloud-managed WiFi 6E architecture with 50 Juniper AP45 access points delivering 9.6 Gbps tri-band throughput per AP. The Mist Cloud AI engine provides machine learning-based anomaly detection, automated RF optimization, and predictive analytics for proactive issue resolution. Marvis Virtual Network Assistant offers conversational troubleshooting with natural language queries like "Why is WiFi slow in Building A?". Location services leverage virtual Bluetooth LE (vBLE) for indoor positioning without requiring physical beacon hardware, enabling wayfinding, asset tracking, and occupancy analytics. Wired assurance provides unified management for 4 EX4400 PoE switches through a single Mist dashboard. The architecture supports 802.1X RADIUS authentication, multiple SSID profiles for different user groups, and real-time client experience monitoring through Service Level Expectations (SLEs) tracking successful connections, coverage, capacity, and roaming performance.

---

# Security & Compliance

This section describes the security controls, compliance frameworks, and regulatory requirements that the Mist AI Network implementation will address.

## Security Framework

The solution implements enterprise wireless security controls including 802.1X RADIUS authentication for secure user access, WPA3 encryption for advanced WiFi security, role-based access control (RBAC) for administrator privileges, and VLAN segmentation for network isolation between user groups. Guest WiFi portal provides captive portal authentication with terms acceptance and sponsored guest access. The platform meets SOC 2 compliance requirements through comprehensive audit logging, security event monitoring, and integration with existing security information and event management (SIEM) systems. Cloud-based architecture eliminates on-premises wireless controller vulnerabilities while providing always-up-to-date security patches and threat intelligence from Mist AI cloud services.

---

# Testing & Validation

This section outlines the testing strategy, validation procedures, and acceptance criteria to ensure the Mist AI Network meets all functional, performance, and user experience requirements before production deployment.

## Testing Strategy

The implementation follows a comprehensive testing approach including predictive RF site survey validation before hardware purchase, physical RF validation after AP deployment to verify coverage and eliminate dead zones, client connectivity testing with laptops, tablets, and smartphones across all SSIDs, roaming performance testing to validate seamless handoffs between access points, throughput testing with high-bandwidth applications (video conferencing, file transfers) to confirm performance, location services accuracy testing for indoor positioning and wayfinding, SLE validation to confirm 99% successful connection rates and optimal client experience, high-density testing with concurrent client loads to validate capacity, and user acceptance testing with IT staff and business users. All testing is performed incrementally during deployment to identify and resolve issues before legacy AP cutover, minimizing risk and ensuring zero business disruption.

---

# Handover & Support

This section defines the knowledge transfer activities, training deliverables, documentation handover, and post-implementation support provided to ensure successful transition to Client operations team.

## Knowledge Transfer and Support

The handover phase includes comprehensive Mist dashboard training (1 day, up to 10 participants) covering wireless monitoring, RF analytics, client troubleshooting, and configuration management, Marvis AI training demonstrating conversational troubleshooting with natural language queries and automated root cause analysis, location services training for wayfinding map management and asset tracking configuration, complete as-built documentation including RF coverage maps, AP locations, WLAN configuration details, and network integration diagrams, operations runbook with standard operating procedures for common tasks (adding SSIDs, adjusting RF policies, troubleshooting client issues), and 30-day warranty support period for issue resolution, performance tuning, and optimization assistance. All training sessions will be recorded for future reference and new team member onboarding. SLE baselines will be established to measure ongoing wireless performance and identify optimization opportunities.

---

# Investment Summary

This section provides a detailed breakdown of project costs, payment terms, and ongoing annual expenses for the Mist AI Network implementation.

### Project Investment

| Category | Description | Amount |
|----------|-------------|--------|
| **Hardware & Equipment** | AP45 WiFi 6E access points, EX4400 PoE switches, power supplies, optics | $116,600 |
| **Software Licenses** | Mist Cloud AI, Wired Assurance, Location Services, Marvis VNA, Premium Analytics | $31,400 |
| **Support & Maintenance** | 24x7 JTAC support (Year 1) | $9,720 |
| **Professional Services** | RF site survey, installation, configuration, testing, training, project management | $81,000 |
| **Year 1 Credits** | Hardware, software, and support promotional discounts | ($15,996) |
| **TOTAL YEAR 1 INVESTMENT** | **Complete solution with implementation and first year support** | **$222,724** |

### Ongoing Annual Costs (Years 2-3)

| Category | Annual Cost | Description |
|----------|-------------|-------------|
| **Software Subscriptions** | $31,400 | Mist Cloud AI, Wired Assurance, Location Services, Marvis VNA annual renewals |
| **Support & Maintenance** | $9,720 | 24x7 JTAC support with 4-hour response for APs and switches |
| **TOTAL ANNUAL COST** | **$41,120** | **Recurring annual investment for Years 2-3** |

**3-Year Total Cost of Ownership:** $304,964

### Payment Terms

- **25%** upon SOW execution and project kickoff ($55,681)
- **25%** upon completion of Discovery & Planning phase with RF design approval ($55,681)
- **25%** upon infrastructure deployment completion with all APs operational ($55,681)
- **25%** upon successful project acceptance and production handoff ($55,681)

### Additional Services

Any additional services beyond the scope of this SOW will be quoted separately and require written approval from both parties. Examples include additional buildings, custom location-based application development, or extended post-deployment support.

---

# Terms & Conditions

This section establishes the contractual terms, acceptance criteria, assumptions, constraints, risk management approach, and legal provisions governing the Mist AI Network implementation.

## Acceptance Criteria

### Technical Acceptance

The solution will be considered technically accepted when:
- 50 AP45 WiFi 6E access points operational with complete building coverage
- All wireless networks (SSIDs) functional with client connectivity across device types
- 99% successful connection SLE achieved as measured by Mist Cloud analytics
- RF coverage validated with signal strength meeting minimum -67 dBm threshold
- Marvis AI operational with proactive anomaly detection and conversational troubleshooting
- Location services enabled with indoor positioning accuracy within 3-5 meters
- Wired Assurance operational with 4 EX4400 switches managed through Mist dashboard
- 802.1X authentication functional with RADIUS integration for secure access
- Performance baselines established meeting or exceeding specified requirements

### Business Acceptance

The project will be considered complete when:
- Business stakeholders sign-off on wireless connectivity meeting user expectations
- Administrator and helpdesk training completed with knowledge validation
- Documentation delivered and approved including RF maps, configuration guides, and runbooks
- System operational in production environment with 99% successful connection SLE validated
- 30-day warranty period completed with no unresolved critical issues

## Assumptions & Constraints

### Assumptions

- Client will provide building floor plans in CAD or PDF format for RF site survey
- Structured cabling and PoE power available at AP mounting locations or client will provide
- Network infrastructure (VLANs, DHCP, DNS) configured to support wireless requirements
- Maintenance windows available during off-peak hours for legacy AP cutover activities
- Client team members available for requirements gathering, testing, and knowledge transfer
- RADIUS or Active Directory accessible for 802.1X authentication integration
- Internet connectivity available for Mist Cloud management and AI services

### Constraints

- Project timeline assumes AP and switch hardware delivery within 2 weeks of purchase order
- AP deployment limited to standard ceiling or wall mounting; complex mounting requires additional time
- RF design based on standard office construction materials; dense materials may require additional APs
- Legacy AP cutover limited to approved maintenance windows (typically 4-hour blocks)
- All activities must comply with client change management and security approval processes
- Solution requires persistent internet connectivity for Mist Cloud management and AI services

## Risk Management

### Identified Risks

| Risk | Impact | Probability | Mitigation Strategy |
|------|--------|-------------|---------------------|
| **RF Coverage Gaps** | High | Medium | Predictive site survey with Mist AI planning tools validates coverage before purchase |
| **Hardware Delivery Delays** | Medium | Low | Order equipment immediately upon SOW execution with expedited shipping |
| **Maintenance Window Constraints** | Medium | Medium | Incremental deployment allows testing before legacy AP cutover |
| **Building Construction Challenges** | Medium | Medium | Physical RF validation after initial AP deployment identifies coverage issues early |
| **Integration Complexity (RADIUS)** | Low | Low | Early authentication testing validates compatibility before full deployment |
| **User Adoption Challenges** | Low | Low | Comprehensive training and documentation ensures smooth transition |

### Change Management

Any changes to project scope, timeline, or budget must be documented through formal change requests and approved by both parties before implementation. Examples include:
- Additional buildings or floors beyond single building specified in scope
- Custom location-based application development beyond standard wayfinding
- Extended post-deployment support beyond 30-day warranty period
- Network infrastructure modifications requiring additional design work

## Intellectual Property

- Client retains ownership of wireless configurations, floor plans, and business data
- Vendor retains ownership of proprietary implementation methodologies and automation tools
- Mist Cloud configurations and customizations become client property upon final payment
- Training materials may be used by client for internal purposes only

### Confidentiality

Both parties agree to maintain strict confidentiality of wireless network design, floor plans, and business data throughout the project and beyond. All project team members will sign non-disclosure agreements.

### Warranty & Support

- 30-day warranty on all deliverables from production handoff date
- Defect resolution included at no additional cost during warranty period (configuration errors, documentation gaps)
- Post-warranty support available under separate annual support agreement
- Hardware warranty per Juniper standard terms (typically 1 year with 24x7 JTAC support)

### Limitation of Liability

Vendor's liability is limited to the total contract value ($222,724). Neither party shall be liable for indirect, incidental, or consequential damages including business interruption or data loss.

---

# Sign-Off

This section provides formal approval signatures from authorized representatives of both Client and Vendor to execute this Statement of Work.

### Client Approval ([CLIENT_NAME])

**Name:** [CLIENT_AUTHORIZED_SIGNATORY]
**Title:** [TITLE]
**Signature:** ________________________________
**Date:** ________________

### Vendor Approval ([VENDOR_NAME])

**Name:** [VENDOR_AUTHORIZED_SIGNATORY]
**Title:** [TITLE]
**Signature:** ________________________________
**Date:** ________________

---

**Document Control:**
**File Name:** SOW_Juniper_Mist_AI_Network_{CLIENT_NAME}_{DATE}
**Version:** 1.0
**Last Modified:** [DATE]
**Next Review:** [REVIEW_DATE]

---

*This Statement of Work constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter.*
