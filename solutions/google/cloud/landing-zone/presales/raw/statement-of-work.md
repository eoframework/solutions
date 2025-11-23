---
document_title: Statement of Work
technology_provider: Google Cloud
project_name: Google Cloud Landing Zone
client_name: [Client Name]
client_contact: [Contact Name | Email | Phone]
consulting_company: Your Consulting Company
consultant_contact: [Consultant Name | Email | Phone]
opportunity_no: OPP-2025-001
document_date: November 22, 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing a Google Cloud Landing Zone for [Client Name]. This engagement will deliver a secure, scalable multi-project foundation with Cloud Foundation Toolkit automation, enabling 10+ application teams to deploy to GCP with built-in governance, security controls, and compliance.

**Project Duration:** 12 weeks

---

---

# Background & Objectives

## Current State

[Client Name] currently operates with limited GCP governance and fragmented project structures. Key challenges include:
- **Inconsistent Security Controls:** Each team implements security differently, creating audit gaps and compliance risks
- **Manual Project Provisioning:** 6-8 week delays for new project creation blocking innovation and team velocity
- **No Centralized Governance:** Lack of organization policies, billing controls, and resource management
- **Shadow IT Risk:** Teams creating ungoverned projects outside enterprise standards
- **Hybrid Connectivity Gaps:** No standardized path to on-premises systems requiring ad-hoc VPN configurations
- **Compliance Exposure:** Unable to demonstrate SOC 2 or PCI-DSS compliance without landing zone foundation

## Business Objectives
- **Establish Cloud Foundation:** Implement GCP Organization with folder hierarchy, Cloud Foundation Toolkit, and governance automation to enable secure multi-team adoption
- **Accelerate Project Provisioning:** Reduce project creation time from 6-8 weeks to under 1 hour using Terraform automation and self-service workflows
- **Enforce Security Baseline:** Deploy Security Command Center Premium, Chronicle SIEM, and organization policies to ensure 100% compliance with SOC 2 and PCI-DSS
- **Enable Team Self-Service:** Provide application teams with automated project provisioning while maintaining centralized governance and security controls
- **Standardize Hybrid Connectivity:** Build Shared VPC hub-spoke with Dedicated Interconnect (10 Gbps) for consistent on-premises integration
- **Foundation for Growth:** Enable platform supporting 10 initial projects scaling to 75+ projects across 20+ teams without re-architecture

## Success Metrics
- Project provisioning time reduced from 6-8 weeks to <1 hour (95% reduction)
- 100% compliance with SOC 2 and PCI-DSS security controls within 90 days
- Zero security misconfigurations through enforced organization policies and Cloud Foundation Toolkit
- 10 projects onboarded in first 90 days with 5 application teams productive
- Dedicated Interconnect operational with <5ms latency to on-premises datacenter
- Platform team self-sufficient in operations within 30 days post-go-live

---

---

# Scope of Work

## In Scope
The following services and deliverables are included in this SOW:
- GCP Organization setup and folder hierarchy design
- Cloud Foundation Toolkit Terraform module development
- Shared VPC hub-spoke network with Dedicated Interconnect
- Security baseline with SCC Premium, Chronicle, Cloud Armor, Cloud IDS
- Organization policies and governance automation
- Identity integration with Cloud Identity and SAML SSO
- Centralized logging, monitoring, and FinOps dashboards
- Pilot team onboarding and knowledge transfer

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Number of GCP Projects | 10 projects managed |
| Solution Scope | Team Count | 5 application teams |
| Integration | Hybrid Connectivity | Dedicated Interconnect 10 Gbps |
| Integration | Network Architecture | Shared VPC hub-spoke |
| User Base | Platform Admins | 8 administrators |
| User Base | Folder Structure | By environment (dev/staging/prod) |
| Data Volume | Logging Volume | 500 GB/month centralized |
| Data Volume | Project Provisioning | Manual with Terraform modules |
| Technical Environment | Deployment Regions | 3 GCP regions (multi-regional) |
| Technical Environment | Availability Requirements | Standard (99.9%) |
| Technical Environment | Infrastructure Complexity | Hub-spoke VPC with Interconnect |
| Security & Compliance | Security Requirements | SCC Premium Chronicle SIEM |
| Security & Compliance | Compliance Frameworks | SOC 2 PCI-DSS |
| Performance | Project Provisioning Time | 1 hour with automation |
| Performance | Security Baseline | Cloud Foundation Toolkit |
| Environment | Shared Services | Logging Monitoring Security VPN |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*


## Activities

### Phase 1 – Discovery & Assessment
During this initial phase, the Vendor will perform a comprehensive assessment of the Client's current GCP environment, governance requirements, and hybrid connectivity needs. This includes analyzing existing projects, identifying security gaps, determining organization structure, and designing the optimal landing zone architecture.

Key activities:
- Requirements gathering for GCP organization structure and governance
- Current GCP environment assessment and project inventory
- Hybrid connectivity requirements and network architecture planning
- Security and compliance requirements analysis (SOC 2, PCI-DSS, data residency)
- Identity provider integration planning (Cloud Identity, SAML SSO, directory sync)
- Folder hierarchy and project factory design
- Cloud Foundation Toolkit module selection and customization strategy
- Implementation planning and resource allocation

This phase concludes with an Assessment Report that outlines the proposed landing zone architecture, organization hierarchy, network design, security controls, automation approach, risks, and project timeline.

### Phase 2 – Foundation Design & Planning
In this phase, the GCP landing zone foundation is designed based on Google Cloud best practices and Cloud Foundation Toolkit patterns. This includes organization setup, folder structure, network architecture, security baseline, and automation framework.

Key activities:
- GCP Organization and billing account configuration
- Folder hierarchy creation (dev, staging, production)
- Shared VPC hub-spoke network design with Cloud NAT and load balancers
- Dedicated Interconnect planning and VLAN attachment design
- Security baseline design (SCC Premium, Chronicle SIEM, Cloud Armor, Cloud IDS)
- Organization policy constraints definition for compliance and governance
- Cloud Foundation Toolkit Terraform module development
- Centralized logging architecture (Cloud Logging sinks, BigQuery exports)
- Cloud Monitoring dashboards and alerting configuration
- FinOps cost allocation and budget alert design

By the end of this phase, the Client will have a comprehensive landing zone design ready for implementation.

### Phase 3 – Implementation & Deployment
Implementation will occur in well-defined phases following infrastructure-as-code best practices. Each phase builds upon the foundation, with automated testing and validation for consistency and risk reduction.

Key activities:
- GCP Organization and billing account setup
- Cloud Foundation Toolkit implementation for project factory
- Shared VPC network deployment across 3 regions
- Dedicated Interconnect provisioning and BGP configuration
- Security Command Center Premium and Chronicle SIEM deployment
- Organization policy implementation and validation
- Cloud Identity integration with SAML SSO setup
- Directory sync configuration (GCDS) for automated user provisioning
- Centralized logging sink configuration and BigQuery exports
- Cloud Monitoring dashboard creation and alerting policies
- Cloud KMS customer-managed encryption key setup
- Cost allocation labels and FinOps dashboard deployment

After each phase, the Vendor will coordinate validation and sign-off with the Client before proceeding.

### Phase 4 – Testing & Validation
In the Testing and Validation phase, the landing zone undergoes thorough functional, security, and compliance validation to ensure it meets required standards and SLAs. Test cases will be executed based on Client-defined acceptance criteria.

Key activities:
- Infrastructure testing with Terraform validation and Terratest
- Project provisioning testing through automated workflows
- Network connectivity testing (Shared VPC, Interconnect, Cloud NAT)
- Security baseline validation (SCC findings, policy compliance)
- Organization policy testing for constraint enforcement
- Hybrid connectivity testing with on-premises systems
- IAM and access control validation
- Compliance validation (SOC 2, PCI-DSS controls)
- Performance testing for project provisioning workflows
- User Acceptance Testing (UAT) with pilot team
- Go-live readiness review and cutover planning

Cutover will be coordinated with all relevant stakeholders and executed during an approved maintenance window, with well-documented rollback procedures in place.

### Phase 5 – Handover & Post-Implementation Support
Following successful implementation and pilot team onboarding, the focus shifts to ensuring operational continuity and knowledge transfer. The Vendor will provide a period of hypercare support and equip the Client's platform team with the documentation, tools, and processes needed for ongoing operations.

Activities include:
- Delivery of as-built documentation (architecture diagrams, Terraform code, configurations)
- Operations runbook and SOPs for project provisioning and platform management
- Cloud Foundation Toolkit training for platform administrators
- Google Admin Console and IAM management training
- Terraform module customization and maintenance training
- Live or recorded knowledge transfer sessions for administrators
- FinOps dashboard usage and cost optimization training
- 30-day warranty support for issue resolution
- Optional transition to a managed services model for ongoing support, if contracted

---

## Out of Scope

These items are not in scope unless added via change control:
- Application migration or workload deployment
- Third-party software licensing beyond GCP services
- Legacy system decommissioning or data migration
- Historical project cleanup or billing reconciliation
- Ongoing operational support beyond 30-day warranty period
- Custom development for application-specific requirements
- Manual security audits or penetration testing services
- End-user training beyond platform administrator knowledge transfer
- GCP service costs (billed directly by Google Cloud to client)

---

---

# Deliverables & Timeline

## Deliverables

The following deliverables will be provided throughout the engagement to ensure successful implementation of the Google Cloud Landing Zone. Each deliverable includes clear acceptance criteria and ownership.

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | Requirements Specification | Document/CSV | Week 2 | [Client Lead] |
| 2 | Landing Zone Architecture Document | Document | Week 3 | [Technical Lead] |
| 3 | Implementation Plan | Project Plan | Week 3 | [Project Sponsor] |
| 4 | GCP Organization & Folder Structure | System | Week 5 | [Technical Lead] |
| 5 | Cloud Foundation Toolkit Modules | Code | Week 7 | [Platform Lead] |
| 6 | Shared VPC Network Infrastructure | System | Week 7 | [Network Lead] |
| 7 | Dedicated Interconnect Connection | System | Week 8 | [Network Lead] |
| 8 | Security Baseline (SCC, Chronicle) | System | Week 9 | [Security Lead] |
| 9 | Organization Policies | System | Week 9 | [Compliance Lead] |
| 10 | Centralized Logging & Monitoring | System | Week 10 | [Ops Lead] |
| 11 | Test Plan & Results | Document | Week 11 | [QA Lead] |
| 12 | Administrator Training Materials | Document/Video | Week 12 | [Training Lead] |
| 13 | Operations Runbook | Document | Week 12 | [Ops Lead] |
| 14 | As-Built Documentation | Document | Week 12 | [Client Lead] |
| 15 | Knowledge Transfer Sessions | Training | Week 11-12 | [Client Team] |

---

## Project Milestones

Key milestones mark critical decision points and completion gates throughout the 12-week implementation. Each milestone requires formal sign-off before proceeding to the next phase.

<!-- TABLE_CONFIG: widths=[20, 50, 30] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 | Assessment Complete | Week 3 |
| M2 | Foundation Deployed | Week 7 |
| M3 | Security Baseline Active | Week 9 |
| M4 | Automation Complete | Week 10 |
| M5 | Testing Complete | Week 11 |
| Go-Live | Pilot Teams Onboarded | Week 12 |
| Hypercare End | Support Period Complete | Week 16 |

---

---

# Roles & Responsibilities

## RACI Matrix

The RACI matrix defines roles and responsibilities for each major task category. This ensures clear accountability and effective collaboration between Vendor and Client teams throughout the landing zone implementation.

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO Sales Eng | EO Eng (GCP) | Client IT | Client Security | SME |
|-----------|-------|----------------|--------------|-------------|-----------|-----------------|-----|
| Discovery & Requirements | A | R | R | C | C | R | C |
| Landing Zone Architecture | C | A | R | I | I | C | I |
| Cloud Foundation Toolkit Dev | C | C | R | A | I | I | I |
| Network Infrastructure | C | A | C | R | C | I | I |
| Security Baseline Deploy | C | R | C | A | C | A | I |
| Organization Policy Config | C | R | I | A | C | A | I |
| Testing & Validation | R | C | R | R | A | A | I |
| Knowledge Transfer | A | R | R | R | C | C | I |
| Hypercare Support | A | R | R | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- EO Project Manager: Overall delivery accountability
- EO Quarterback: Technical design and oversight
- EO Sales Engineer: Solution architecture and pre-sales support
- EO Engineer (GCP): Landing zone implementation and automation

**Client Team:**
- IT Lead: Primary technical contact and GCP access management
- Platform Lead: Landing zone operations and project provisioning
- Security Lead: Security baseline and compliance validation
- Network Lead: Hybrid connectivity and on-premises coordination
- Operations Team: Knowledge transfer recipients

---

---

# Architecture & Design

## Architecture Overview
The Google Cloud Landing Zone is designed as a **secure, multi-project foundation** leveraging Cloud Foundation Toolkit and GCP best practices. The architecture provides scalability, governance automation, and enterprise-grade security for multi-team cloud adoption.

This architecture is designed for **10 projects across 5 teams** with future growth to 75+ projects and 20+ teams. The design prioritizes:
- **Security-first:** Organization policies, SCC Premium, and Chronicle SIEM from day 1
- **Automation:** Cloud Foundation Toolkit for repeatable, consistent project provisioning
- **Scalability:** Hub-spoke network design supporting 100+ projects without re-architecture

![Figure 1: Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Solution Architecture Diagram** - High-level overview of the Google Cloud Landing Zone architecture

## Architecture Type
The deployment follows a hub-spoke network architecture with centralized security and governance. This approach enables:
- Centralized network management with shared VPC hosting projects
- Consistent security controls through organization policies and Cloud Foundation Toolkit
- Clear separation between shared services and application projects
- Hybrid connectivity through dedicated hub for on-premises integration
- Scalable automation supporting rapid project provisioning

Key architectural components include:
- Organization Foundation (GCP Organization, Folder Hierarchy, Billing Accounts)
- Identity & Access Layer (Cloud Identity Premium, SAML SSO, Directory Sync)
- Network Layer (Shared VPC Hub, Dedicated Interconnect, Cloud NAT)
- Security Layer (SCC Premium, Chronicle, Cloud Armor, Cloud IDS)
- Governance Layer (Organization Policies, Cloud Foundation Toolkit)
- Observability Layer (Cloud Logging, Cloud Monitoring, FinOps Dashboards)

## Scope Specifications

**Organization & Governance:**
- GCP Organization with 3-tier folder hierarchy (dev/staging/prod)
- 10 initial projects managed through Cloud Foundation Toolkit
- 8 platform administrators with role-based access control
- Organization policies enforcing 50+ security and compliance constraints

**Networking:**
- Shared VPC hub deployed across 3 GCP regions (us-central1, us-east1, us-west1)
- Dedicated Interconnect 10 Gbps to on-premises datacenter
- 4 VLAN attachments for redundant hybrid connectivity
- Cloud NAT gateways for internet egress across all regions
- Internal HTTP(S) load balancers for shared services

**Security & Compliance:**
- Security Command Center Premium for continuous threat detection
- Chronicle SIEM (100 GB/month) for advanced security analytics
- Cloud Armor for DDoS protection and WAF
- Cloud IDS (3 endpoints) for network intrusion detection
- 100 customer-managed encryption keys via Cloud KMS

**Logging & Monitoring:**
- Centralized Cloud Logging (500 GB/month ingestion)
- BigQuery log exports for compliance and analytics
- Cloud Monitoring with SLO dashboards and budget alerts
- VPC Flow Logs (200 GB/month) for network visibility

**Scalability Path:**
- Medium scope: Expand to 30 projects and 15 teams
- Large scope: Scale to 75+ projects and 20+ teams
- No architectural changes required - only folder and project expansion

## Application Hosting
All application workloads will be deployed to service projects attached to Shared VPC:
- Compute Engine VMs, GKE clusters, Cloud Run services
- Private Google Access for API connectivity without internet egress
- VPC Service Controls for data exfiltration prevention
- Centralized logging and monitoring for all workloads

Infrastructure-as-code (Terraform) for all provisioning.

## Networking
The networking architecture follows GCP best practices for enterprise landing zones:
- Shared VPC hub-spoke with centralized network management
- VPC peering for spoke projects consuming shared services
- Cloud Router for dynamic BGP routing with on-premises
- Private Service Connect for managed services connectivity
- Cloud DNS private zones for internal service discovery
- Cloud Armor and Cloud CDN for internet-facing services

## Observability
Comprehensive observability ensures operational excellence:
- Cloud Logging for centralized log aggregation from all projects
- Cloud Monitoring for metrics, dashboards, and alerting
- Cloud Trace for distributed tracing (optional)
- Error Reporting for application error tracking
- Custom dashboards showing platform KPIs (projects created, policy compliance, costs)

## Backup & Disaster Recovery
All critical configurations are protected through:
- Infrastructure-as-code in Git for version control and rollback
- Organization policy backups and change tracking
- Multi-region deployment for network resilience
- Dedicated Interconnect with redundant connections
- RTO: 4 hours | RPO: 1 hour for platform services

---

## Technical Implementation Strategy

The implementation approach follows GCP landing zone best practices and Cloud Foundation Toolkit patterns.

## Example Implementation Patterns
- Phased rollout: Foundation → Security → Automation → Team Onboarding
- Parallel environments: Build dev/staging/prod folders simultaneously
- Pilot-then-scale: Onboard 2 teams, validate, then expand to all teams

## Tooling Overview

The implementation leverages Google Cloud-native tools, Terraform automation, and enterprise-grade security monitoring to deliver a scalable, secure landing zone. All tools are industry-standard and validated for enterprise deployments.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|-----------------------|------------------------------|-------------------------------|
| Infrastructure | Terraform, Cloud Foundation Toolkit | Project factory and infrastructure automation |
| Networking | Shared VPC, Cloud Router, Interconnect | Hub-spoke network and hybrid connectivity |
| Security | SCC Premium, Chronicle, Cloud Armor | Threat detection and security monitoring |
| Identity | Cloud Identity Premium, GCDS | SSO and directory synchronization |
| Governance | Organization Policies, Resource Manager | Compliance and resource constraints |
| Observability | Cloud Logging, Cloud Monitoring | Centralized logging and monitoring |
| FinOps | BigQuery, Data Studio, Budget Alerts | Cost visibility and optimization |

---

## Data Management

### Data Strategy
- Centralized log aggregation via Cloud Logging sinks
- BigQuery exports for long-term retention and analytics
- VPC Flow Logs for network traffic analysis
- Audit logs for all administrative actions via Cloud Audit Logs
- Data classification labels for cost allocation and compliance

### Data Security & Compliance
- Encryption at rest using customer-managed keys (CMEK) via Cloud KMS
- Encryption in transit using TLS 1.2+ for all communications
- Data residency controls through organization policy constraints
- Audit trail for all data access via Cloud Audit Logs
- Secure deletion capabilities for GDPR compliance

---

---

# Security & Compliance

The implementation and target environment will be architected and validated to meet the Client's security, compliance, and governance requirements. Vendor will adhere to Google Cloud security frameworks and enterprise best practices.

## Identity & Access Management
- Cloud Identity Premium with SAML SSO integration
- Multi-factor authentication (2SV/MFA) required for all administrator access
- Role-based access control (RBAC) with principle of least privilege
- Service accounts with workload identity for application authentication
- Organization-level IAM policies with folder inheritance
- Just-in-time access for privileged operations

## Monitoring & Threat Detection
- Security Command Center Premium for continuous security monitoring
- Chronicle SIEM for advanced threat detection and incident response
- Cloud Audit Logs enabled for all administrative and data access events
- Cloud Monitoring for security metrics and compliance dashboards
- Automated alerts for policy violations and security findings
- Integration with SIEM for centralized security operations

## Compliance & Auditing
- SOC 2 compliance through enforced organization policies and security controls
- PCI DSS compliance for payment data workloads with network segmentation
- GDPR compliance: Data residency controls, right-to-deletion, audit trail
- Continuous compliance monitoring using Security Command Center
- Policy-as-code validation with Open Policy Agent (optional)
- Quarterly compliance reviews and audit support

## Encryption & Key Management
- All data encrypted at rest using customer-managed encryption keys (CMEK)
- Cloud KMS for centralized key management with automatic rotation
- All data encrypted in transit using TLS 1.2+
- VPC Service Controls for data exfiltration prevention
- Encryption key access logging via Cloud Audit Logs
- Hardware security modules (Cloud HSM) for sensitive workloads (optional)

## Governance
- Organization policies enforcing 50+ security and compliance constraints
- Resource location restrictions for data residency requirements
- Service enablement controls preventing unauthorized API usage
- VPC Service Controls for sensitive data protection perimeters
- Change control: All infrastructure changes through Terraform with peer review
- Incident response: Documented procedures for security events and outages
- Resource tagging strategy for cost allocation and compliance tracking

---

## Environments & Access

### Environment Strategy

| Environment | Purpose | GCP Folder | Access |
|-------------|---------|------------|--------|
| Development | Application development and testing | development/ | Development teams |
| Staging | Integration testing and UAT | staging/ | Project teams, testers |
| Production | Live production workloads | production/ | Operations team, authorized users |

### Access Policies
- Multi-factor authentication (2SV) required for all Google Cloud console access
- API access via service accounts with workload identity
- Administrator Access: Full organization access for platform team during project
- Developer Access: Project-level access to dev/staging folders
- Operator Access: Read-only monitoring access, limited production management
- Audit Access: Read-only access to logs and compliance reports

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the implementation lifecycle to ensure functionality, security, compliance, and scalability of the landing zone foundation.

## Functional Validation
- End-to-end project provisioning workflow testing
- Shared VPC network connectivity validation
- Hybrid connectivity testing via Dedicated Interconnect
- Organization policy enforcement validation
- IAM role and permission testing
- Cloud Foundation Toolkit module validation

## Performance & Load Testing
- Project provisioning performance (target: <1 hour)
- Network throughput testing (Interconnect 10 Gbps validation)
- Concurrent project creation testing
- Logging ingestion capacity testing (500 GB/month)

## Security Testing
- Validation of organization policy constraints
- Security Command Center findings review
- IAM privilege escalation testing
- Network segmentation validation
- Encryption verification (data at rest and in transit)
- Compliance validation (SOC 2, PCI-DSS controls)

## Disaster Recovery & Resilience Tests
- Infrastructure-as-code rollback testing
- Interconnect failover validation
- Multi-region network resilience testing
- RTO/RPO validation

## User Acceptance Testing (UAT)
- Performed in coordination with Client platform team
- Pilot team project provisioning validation
- Security and compliance sign-off
- Operations runbook validation

## Go-Live Readiness
A Go-Live Readiness Checklist will be delivered including:
- Security and compliance sign-offs
- Network connectivity validation
- Policy enforcement validation
- Automation testing completion
- Issue log closure (all critical/high issues resolved)
- Training completion
- Documentation delivery

---

## Cutover Plan

The cutover to the Google Cloud Landing Zone will be executed using a controlled, phased approach to minimize business disruption and ensure seamless onboarding of application teams.

**Cutover Approach:**

The implementation follows a **pilot-then-scale** strategy where 2 application teams will validate the landing zone before broader rollout:

1. **Foundation Deployment (Week 1-10):** Build organization structure, network, security baseline, and automation without impacting existing projects.

2. **Pilot Team Onboarding (Week 11):** Onboard 2 pilot teams with new projects provisioned through Cloud Foundation Toolkit:
   - Week 11: Provision 4 projects (2 teams × dev + prod)
   - Monitor project creation workflow, network connectivity, security controls
   - Validate IAM, logging, monitoring, and Interconnect functionality

3. **Validation Period (Week 12):** Pilot teams validate applications run successfully:
   - Deploy sample workloads to validate network and security
   - Test hybrid connectivity to on-premises systems
   - Verify logging, monitoring, and cost allocation
   - Collect feedback for tuning before broader rollout

4. **Hypercare Period (4 weeks post-go-live):** Daily monitoring, rapid issue resolution, and optimization for stable operations.

The cutover will be executed during a pre-approved maintenance window (recommended: weekend) with documented rollback procedures available if critical issues arise.

## Cutover Checklist
- Pre-cutover validation: Final UAT sign-off, security validation
- Foundation environment validated and monitoring operational
- Rollback procedures documented (Terraform destroy, folder cleanup)
- Stakeholder communication completed
- Provision pilot team projects via Terraform
- Monitor first project deployments
- Verify network connectivity and security controls
- Daily monitoring during hypercare period (4 weeks)

## Rollback Strategy
- Documented rollback triggers (security violation, critical infrastructure failure)
- Rollback procedures: Terraform destroy, organization cleanup
- Root cause analysis and fix validation before retry
- Communication plan for stakeholders
- Preserve all logs and configurations for analysis

---

---

# Handover & Support

## Handover Artifacts
- As-Built documentation including architecture diagrams and Terraform code
- Cloud Foundation Toolkit module documentation with customization guide
- Operations runbook with troubleshooting procedures
- Monitoring and alert configuration reference
- FinOps cost optimization recommendations
- Organization policy documentation and compliance mapping
- Network diagrams showing Shared VPC and Interconnect topology

## Knowledge Transfer
- Live knowledge transfer sessions for platform administrators
- Google Admin Console and IAM management training
- Cloud Foundation Toolkit customization and module development training
- Terraform workflow and GitOps best practices
- FinOps dashboard usage and cost optimization techniques
- Recorded training materials hosted in shared portal
- Documentation portal with searchable content

## Hypercare Support

Post-implementation support to ensure smooth transition to Client operations:

**Duration:** 4 weeks post-go-live (30 days)

**Coverage:**
- Business hours support (8 AM - 6 PM local time)
- 4-hour response time for critical issues
- Daily health check calls (first 2 weeks)
- Weekly status meetings

**Scope:**
- Issue investigation and resolution
- Project provisioning troubleshooting
- Network connectivity support
- Security and compliance questions
- Terraform module assistance
- Cost optimization recommendations

## Managed Services Transition (Optional)

Post-hypercare, Client may transition to ongoing managed services:

**Managed Services Options:**
- 24/7 monitoring and support for landing zone platform
- Proactive optimization and cost management
- Organization policy updates and governance support
- GCP service limit management and quota increases
- Monthly performance and FinOps reviews
- Cloud Foundation Toolkit module maintenance

**Transition Approach:**
- Evaluation of managed services requirements during hypercare
- Service Level Agreement (SLA) definition for platform operations
- Separate managed services contract and pricing
- Seamless transition from hypercare to managed services

---

## Assumptions

### General Assumptions
- Client will provide access to existing GCP Organization or approve creation of new organization
- On-premises network team available for Interconnect coordination and testing
- Client technical team available for requirements validation, testing, and approvals
- GCP account access and appropriate IAM permissions provided within 1 week of project start
- Cloud Identity licenses available for administrators and users requiring GCP access
- Integration endpoints for on-premises systems documented and accessible
- Security and compliance approval processes will not delay critical path activities
- Client will handle GCP service costs directly with Google Cloud
- ISP coordination for Dedicated Interconnect completed within 4 weeks

---

## Dependencies

### Project Dependencies
- GCP Organization Access: Client provides organization admin access or approves creation of new organization
- Billing Account: Client provides billing account for GCP resource provisioning
- Network Planning: On-premises network team provides IP addressing, BGP ASN, and Interconnect requirements
- Identity Provider: Client provides SAML metadata for SSO integration and directory sync credentials
- Security Approvals: Security and compliance teams available for baseline approval and policy validation
- Pilot Teams: 2 application teams identified and available for pilot onboarding in Week 11-12
- Infrastructure Readiness: ISP coordination complete for Dedicated Interconnect provisioning
- Change Freeze: No major changes to on-premises network during Interconnect cutover
- Go-Live Approval: Business and technical approval authority available for production deployment

---

---

# Investment Summary

**Small-Medium Scope Implementation:** This pricing reflects a foundation deployment designed for 10 projects across 5 teams with future growth to 30+ projects. For larger enterprise deployments (75+ projects), please request large scope pricing.

## Total Investment

The following table summarizes the total investment required for Google Cloud Landing Zone implementation and ongoing operations over a 3-year period. Year 1 includes partner credits reducing the net investment by $15,000.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 18, 14, 12, 11, 13] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $65,000 | ($5,000) | $60,000 | $0 | $0 | $60,000 |
| Cloud Infrastructure | $49,948 | ($10,000) | $39,948 | $51,547 | $53,092 | $144,587 |
| Software Licenses | $48,000 | $0 | $48,000 | $48,000 | $48,000 | $144,000 |
| Support & Maintenance | $18,000 | $0 | $18,000 | $18,540 | $19,096 | $55,636 |
| **TOTAL INVESTMENT** | **$180,948** | **($15,000)** | **$165,948** | **$118,087** | **$120,188** | **$404,223** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $15,000 (8% reduction)
- **GCP Migration Credit:** $10,000 applied to Year 1 infrastructure consumption (20% discount)
- **Partner Implementation Credit:** $5,000 applied to professional services
- Credits are real GCP account credits, automatically applied as services are consumed
- Credits are Year 1 only; Years 2-3 reflect standard GCP pricing

**Investment Comparison:**
- **Year 1 Net Investment:** $165,948 (after credits) vs. $180,948 list price
- **3-Year Total Cost of Ownership:** $404,223
- **Expected ROI:** 18-24 month payback based on reduced security incidents and team velocity improvements

## Cost Components

**Professional Services** ($65,000 - 260 hours): Labor costs for discovery, architecture, implementation, testing, and knowledge transfer. Breakdown:
- Discovery & Architecture (112 hours): Requirements analysis, landing zone design, documentation
- Implementation (104 hours): Organization setup, Terraform automation, network deployment, security baseline
- Training & Support (44 hours): Knowledge transfer and 30-day post-launch hypercare

**Cloud Infrastructure** ($49,948/year): GCP services sized for 10 projects across 5 teams:
- Shared VPC, Cloud NAT, Load Balancers: $5,040/year
- Dedicated Interconnect 10 Gbps + VLAN Attachments: $28,800/year
- Cloud Logging (500 GB/month) + Cloud Monitoring: $5,508/year
- VPC Flow Logs, Cloud DNS, Cloud KMS: $1,800/year
- Cloud Storage for logs and archives: $2,160/year
- Cloud Build and Artifact Registry: $900/year
- Data Transfer Out (internet egress): $1,440/year
- Scales with actual usage - can increase/decrease based on projects and volume

**Software Licenses & Subscriptions** ($48,000/year): Security and compliance tooling:
- Security Command Center Premium: $15,000/year
- Chronicle SIEM (100 GB/month): $30,000/year
- Cloud Identity Premium (100 users): $3,000/year

**Support & Maintenance** ($18,000/year): Google Cloud Support Enhanced (9% of cloud infrastructure)

---

## Payment Terms

### Pricing Model
- Fixed price for professional services
- Milestone-based payments per Deliverables table

### Payment Schedule
- 25% upon SOW execution and project kickoff
- 30% upon completion of Discovery & Planning phase
- 30% upon completion of Implementation and Testing
- 15% upon successful go-live and project acceptance

---

## Invoicing & Expenses

### Invoicing
- Milestone-based invoicing per Payment Terms above
- Net 30 payment terms
- Invoices submitted upon milestone completion and acceptance

### Expenses
- GCP service costs are included in Cloud Infrastructure pricing ($49,948/year = ~$4,162/month)
- Costs scale with actual usage - can increase/decrease based on project count and logging volume
- Travel and on-site expenses reimbursable at cost with prior approval (remote-first delivery model)

---

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

## Scope Changes
- Changes to project count, folder structure, network architecture, or timeline require formal change requests
- Change requests may impact project timeline and budget

## Intellectual Property
- Client retains ownership of all business data and configurations
- Vendor retains ownership of proprietary methodologies and frameworks
- Cloud Foundation Toolkit modules and configurations become Client property upon final payment
- Infrastructure-as-code and Terraform modules transfer to Client

## Service Levels
- Project provisioning time: <1 hour for standard projects via Terraform automation
- Platform uptime: 99.9% during business hours (SLA from GCP services)
- 30-day warranty on all deliverables from go-live date
- Post-warranty support available under separate managed services agreement

## Liability
- Architecture follows Google Cloud best practices and Cloud Foundation Toolkit patterns
- Performance may vary based on GCP service availability and client network configuration
- Ongoing platform maintenance recommended as GCP services evolve
- Liability caps as agreed in MSA

## Confidentiality
- Both parties agree to maintain strict confidentiality of business data, configurations, and proprietary techniques
- All exchanged artifacts under NDA protection

## Termination
- Mutually terminable per MSA terms, subject to payment for completed work

## Governing Law
- Agreement governed under the laws of [State/Region]

---

---

# Sign-Off

By signing below, both parties agree to the scope, approach, and terms outlined in this Statement of Work.

**Client Authorized Signatory:**
Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

**Service Provider Authorized Signatory:**
Name: __________________________
Title: __________________________
Signature: ______________________
Date: __________________________

---

*This Statement of Work constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter.*
