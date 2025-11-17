---
document_title: Statement of Work
project_name: Enterprise Solution Implementation
client_name: '[Client Name]'
client_contact: '[Contact Name | Email | Phone]'
consulting_company: Your Consulting Company
consultant_contact: '[Consultant Name | Email | Phone]'
opportunity_no: OPP-2025-001
document_date: November 15, 2025
version: '1.0'
client_logo: assets/logos/client_logo.png
vendor_logo: assets/logos/consulting_company_logo.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing a **secure, scalable Azure Enterprise Landing Zone** for [Client Name]. This engagement will deliver a foundational cloud infrastructure designed to support enterprise-scale workloads while maintaining centralized governance, security controls, and cost optimization.

The Azure Enterprise Landing Zone architecture implements Azure's Cloud Adoption Framework (CAF) best practices, establishing a multi-subscription environment with management groups, hub-spoke networking, identity and access management, security baselines, and policy-driven governance.

**Enterprise-Scale Deployment:**
- **Multi-subscription Architecture:** Up to 20 application subscriptions with centralized management
- **User Base:** 100+ IT administrators, cloud operators, and application teams
- **Deployment Model:** Multi-region capable with centralized governance and security policies
- **Compliance Scope:** Enterprise-wide security controls and compliance enforcement
- **Total Investment:** $469,060 over 3 years ($245,020 Year 1 implementation)

**Key Outcomes:**
- Secure foundation for enterprise cloud operations using Azure best practices
- Automated policy enforcement and governance across all subscriptions
- Hub-spoke network topology enabling secure inter-subscription communication
- Centralized identity and access management via Azure AD with Conditional Access
- Complete security baseline including Azure Sentinel, Defender for Cloud, and Azure Firewall
- Operational dashboards and monitoring for cloud infrastructure and security posture
- Foundation for autonomous team operations within governance guardrails

**Expected Benefits:**
- Accelerated deployment of new workloads through self-service subscription vending
- 50%+ reduction in security incident response time through centralized SIEM (Sentinel)
- Improved compliance audit readiness with automated policy enforcement
- 30%+ cost optimization through chargeback models and resource governance
- Elimination of ad-hoc cloud deployments and shadow IT
- Enterprise-grade security posture from day one

---

---

# Background & Objectives

## Background

[Client Name] is pursuing a cloud-first strategy to modernize operations, improve agility, and enhance security. However, deploying workloads to Azure without a proper landing zone foundation creates significant risks:

- Governance Gaps: Uncontrolled resource deployment leads to compliance violations and audit findings
- Security Vulnerabilities: Inconsistent security controls and missing threat detection
- Identity Chaos: Fragmented access management across subscriptions without centralized control
- Cost Overruns: Lack of chargeback models and resource governance drives uncontrolled spending
- Operational Complexity: No standardized monitoring, logging, or incident response procedures
- Network Sprawl: Ad-hoc network designs without proper segmentation or hybrid connectivity

An enterprise landing zone provides the structured foundation needed to prevent these issues while enabling teams to move fast within well-defined guardrails.

## Objectives

- Establish Foundation: Implement Azure Enterprise-Scale Landing Zone architecture per Cloud Adoption Framework best practices
- Design Governance: Create management group hierarchy and Azure Policy framework for automated compliance enforcement
- Implement Networking: Deploy hub-spoke topology with Azure Firewall, ExpressRoute, and Private DNS for secure communication
- Secure Identity: Configure Azure AD integration with Conditional Access policies and role-based access control (RBAC)
- Activate Threat Detection: Deploy Azure Sentinel and Defender for Cloud for comprehensive security monitoring
- Enable Self-Service: Design subscription vending automation for application teams
- Establish Monitoring: Configure centralized logging with Azure Log Analytics and dashboards for operational visibility
- Transfer Knowledge: Provide comprehensive training and operational runbooks for day-2 operations

## Success Metrics

- Management group hierarchy deployed with clear ownership and policy assignment
- Azure Policy framework enforces 95%+ compliance across all subscriptions
- Hub-spoke network operational with <50ms latency between regional hubs
- Azure Sentinel receives and correlates logs from 100%+ of Azure services
- Identity governance implemented with zero orphaned access accounts
- Subscription vending process enables application team deployment in <48 hours
- Cost chargeback model in place with <5% variance from actual usage
- 99.9%+ uptime for hub services (firewall, DNS, connectivity)
- Zero security policy exceptions in first 90 days post-implementation
- All operations team staff successfully complete landing zone management training

---

---

# Scope of Work

## In Scope

The following services and deliverables are included in this SOW:

- Enterprise landing zone architecture design and documentation
- Management group hierarchy design and implementation
- Azure Policy framework creation and enforcement
- Hub-spoke network topology design and implementation
- Azure Firewall and Network Security Group configuration
- Azure AD and RBAC design and implementation
- Conditional Access policy configuration
- Azure Sentinel and Defender for Cloud activation and tuning
- Log Analytics Workspace setup and monitoring dashboard creation
- ExpressRoute and Private Endpoint implementation
- Subscription vending automation design and initial setup
- Operational runbooks and procedures documentation
- Knowledge transfer and training for operations teams

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Management Groups | 3-tier hierarchy |
| Solution Scope | Subscriptions | 5-10 subscriptions |
| Integration | Hybrid Connectivity | ExpressRoute circuit |
| Integration | Identity Federation | Azure AD Connect sync |
| User Base | Total Users | 500 Azure users |
| User Base | User Roles | 10 custom RBAC roles |
| Data Volume | Workloads to Onboard | 20-30 applications |
| Data Volume | Policy Assignments | 50 policy assignments |
| Technical Environment | Target Azure Regions | 2 regions (East US West US) |
| Technical Environment | Availability Requirements | Standard (99.9%) |
| Technical Environment | Infrastructure Complexity | Hub-spoke network topology |
| Security & Compliance | Security Requirements | Azure Defender Standard |
| Security & Compliance | Compliance Frameworks | SOC2 ISO27001 |
| Performance | Cost Management | Azure Cost Management |
| Performance | Governance Automation | Policy-driven governance |
| Environment | Deployment Environments | Landing zones for dev staging prod |

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*


## Activities

### Phase 1 – Discovery & Architecture Design (Weeks 1-4)

During this initial phase, the Vendor will perform a comprehensive assessment of the Client's current cloud environment, organizational structure, and requirements. This phase establishes the foundation for the landing zone design.

Key activities:

- Current state assessment: Cloud adoption status, existing subscriptions, resource inventory
- Organizational assessment: Teams, business units, reporting structure, autonomy requirements
- Compliance and governance analysis: Regulatory requirements, audit findings, policy gaps
- Network topology assessment: Hybrid connectivity requirements, ExpressRoute readiness
- Identity and access assessment: Current Azure AD configuration, group structure, license status
- Security maturity assessment: Current security controls, threat landscape, incident response capability
- Cost analysis: Current spending patterns, chargeback model requirements, optimization opportunities
- Stakeholder interviews: IT operations, security, business units, finance teams
- Enterprise-Scale Landing Zone architecture design: Management groups, subscription strategy, network design
- Network architecture design: Hub-spoke topology, firewall policies, Private DNS zones
- Identity and access strategy: Azure AD design, RBAC structure, Conditional Access policies
- Security baseline design: Defender for Cloud, Sentinel workspace, monitoring strategy
- Implementation roadmap: Sequencing, dependencies, risk mitigation

This phase concludes with an Architecture Design Document that outlines the proposed enterprise landing zone structure, network topology, identity strategy, security baseline, and implementation approach.

### Phase 2 – Platform Foundation & Security (Weeks 5-8)

In this phase, the core landing zone infrastructure is deployed and security controls are activated. This includes the management group hierarchy, core Azure services, and security baseline.

Key activities:

- Management group structure creation with policy assignment hierarchy
- Subscription creation and organization under management groups
- Azure Policy framework implementation for governance and compliance
- Role-based access control (RBAC) design and implementation
- Azure AD configuration for application team integration
- Azure Virtual WAN setup for hub-spoke topology
- Hub Virtual Network creation and configuration
- Azure Firewall deployment and rule configuration
- ExpressRoute circuit provisioning and configuration
- Private DNS zones creation for hybrid name resolution
- Azure Bastion deployment for secure administrative access
- Azure DDoS Protection activation
- Log Analytics Workspace creation and configuration
- Azure Sentinel deployment and data connector activation
- Defender for Cloud enablement and policy configuration
- Diagnostic settings configuration for centralized logging

By the end of this phase, the foundational landing zone infrastructure is operational with core security controls in place.

### Phase 3 – Identity, Monitoring & Automation (Weeks 9-12)

In the final phase, identity systems are integrated, monitoring and alerting are fully configured, and automation for ongoing operations is established.

Key activities:

- Azure AD Conditional Access policy configuration
- Azure AD integration with hybrid identity (if applicable)
- Multi-factor authentication (MFA) enforcement
- Privileged Access Workstation (PAW) configuration
- Just-In-Time (JIT) access configuration for Azure resources
- Azure Monitor dashboard creation for operational metrics
- Sentinel analytics rules and threat detection configuration
- Alert and incident response workflow setup
- Subscription vending automation initial implementation
- Cost management and chargeback automation setup
- Operational runbook creation for day-2 operations
- Knowledge transfer to operations team
- Testing and validation of all systems
- Hypercare support and optimization

---

## Out of Scope

## Exclusions

These items are not in scope unless added via change control:

- Application migration or deployment to Azure (handled separately under CAF Migrate phase)
- Development of custom applications or workloads
- Azure Stack or hybrid infrastructure installation
- Ongoing managed services beyond 12-week implementation period
- Employee end-user training (IT operators and administrators only)
- Third-party security tools or integrations beyond native Azure services
- Azure AI/ML solution implementation or optimization
- Historical cost data analysis or back-billing analysis
- Custom Azure Policy development beyond standard CAF templates
- ExpressRoute direct integration with third-party carriers beyond provisioning

---

---

# Deliverables & Timeline

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | Current State Assessment Report | Document | Week 2 | [IT Director] |
| 2 | Enterprise Landing Zone Architecture Document | Document | Week 4 | [Cloud Lead] |
| 3 | Network Topology & Design Document | Document | Week 4 | [Network Lead] |
| 4 | Implementation Plan | Project Plan | Week 4 | [Project Sponsor] |
| 5 | Azure Management Group Structure | System | Week 6 | [Governance Lead] |
| 6 | Azure Policy Framework | System | Week 7 | [Compliance Lead] |
| 7 | Hub-Spoke Network Topology | System | Week 8 | [Network Lead] |
| 8 | Azure Firewall & Network Security | System | Week 8 | [Security Lead] |
| 9 | Azure Sentinel Configuration | System | Week 9 | [Security Lead] |
| 10 | Defender for Cloud Setup | System | Week 9 | [Security Lead] |
| 11 | Identity & Access Management Configuration | System | Week 10 | [Identity Lead] |
| 12 | Operational Dashboards & Monitoring | System | Week 10 | [Ops Lead] |
| 13 | Operational Runbooks | Document | Week 11 | [Ops Manager] |
| 14 | Cost Chargeback Model | Document/System | Week 11 | [Finance Lead] |
| 15 | As-Built Documentation | Document | Week 12 | [IT Director] |
| 16 | Training Materials & Recordings | Document/Video | Week 12 | [Training Manager] |
| 17 | Knowledge Transfer Sessions | Training | Weeks 11-12 | [IT Team] |

---

## Project Milestones

## Milestones

<!-- TABLE_CONFIG: widths=[20, 50, 30] -->
| Milestone | Description | Target Week |
|-----------|-------------|-------------|
| M1 | Assessment and Design Complete | Week 4 |
| M2 | Management Groups & Policies Deployed | Week 7 |
| M3 | Network & Security Foundation Ready | Week 8 |
| M4 | Identity & Monitoring Operational | Week 10 |
| M5 | Testing & Validation Complete | Week 11 |
| Go-Live | Enterprise Landing Zone in Production | Week 12 |
| Hypercare End | Post-Implementation Support Complete | Week 16 |

---

---

# Roles & Responsibilities

<!-- TABLE_CONFIG: widths=[24, 10, 10, 10, 10, 10, 10, 8, 8] -->
| Task/Role | Vendor PM | Vendor Architect | Vendor Security | Vendor Network | Vendor Developer | Client IT | Client Security | Client Network |
|-----------|-----------|------------------|-----------------|-----------------|-----------------|-----------|-----------------|--------------|
| Assessment | A | R | C | C | I | C | C | C |
| Architecture Design | C | A | R | R | C | I | I | I |
| Management Groups | C | R | C | C | C | A | I | I |
| Policy Framework | C | R | A | C | C | C | I | C |
| Network Design | C | R | C | A | C | I | I | A |
| Firewall Config | C | C | A | R | C | I | I | C |
| Identity Setup | C | C | A | C | C | C | A | I |
| Security Ops | C | C | R | C | C | C | A | I |
| Monitoring | R | C | C | C | R | A | I | I |
| Training | A | R | R | R | R | C | C | C |
| Hypercare | A | R | R | R | R | C | I | I |

Legend:
**R** = Responsible | **A** = Accountable | **C** = Consulted | **I** = Informed

---

---

# Architecture & Design

## Architecture Overview

The Azure Enterprise Landing Zone is designed as a **multi-subscription, multi-management group architecture** leveraging Azure's Cloud Adoption Framework (CAF) best practices. The architecture provides a secure, scalable, and auditable foundation for enterprise cloud operations.

This architecture is designed for **enterprise-scale deployment** supporting multiple business units, teams, and application workloads with centralized governance and decentralized operations. The design prioritizes:

- **Security:** Multiple layers of protection including network segmentation, identity controls, and threat detection
- **Governance:** Automated policy enforcement and compliance across all subscriptions
- **Scalability:** Designed to grow with business needs from 20 to 100+ subscriptions
- **Cost Management:** Chargeback models and resource governance for cost optimization
- **Operational Excellence:** Centralized monitoring, logging, and alerting for visibility

![Figure 1: Enterprise Landing Zone Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Enterprise Landing Zone Architecture Diagram** - High-level overview of the Azure Enterprise Landing Zone architecture

## Architecture Type

The deployment follows a **multi-subscription, hub-spoke network topology** with centralized management and policy enforcement. This approach enables:

- Clear separation of concerns between platform teams and application teams
- Autonomous deployment of workloads within governance guardrails
- Centralized security controls and threat detection across all subscriptions
- Efficient resource utilization and cost optimization
- Simplified hybrid connectivity through hub-based architecture

Key architectural components include:

- Management Group Hierarchy (root, platform, landing zones)
- Policy & Governance Layer (Azure Policy, Azure Blueprints)
- Identity & Access Layer (Azure AD, RBAC, Conditional Access)
- Network Platform (hub-spoke, Azure Firewall, ExpressRoute)
- Security & Monitoring (Sentinel, Defender for Cloud, Log Analytics)
- Subscription Vending Automation (for application team self-service)

## Enterprise-Scale Specifications

**Compute & Scalability:**
- Multi-subscription architecture supporting 20+ application subscriptions initially, expanding to 100+
- Multi-region capable with hub per region (minimum 2 regions)
- Scale-out networking with additional spoke subscriptions as needed

**Management & Governance:**
- Management group hierarchy: Root > Platform > Landing Zones (Corp, Online)
- Azure Policy: 50+ policies for compliance and governance enforcement
- Azure Blueprints: Templates for automated subscription provisioning

**Network & Connectivity:**
- Hub Virtual Networks in 2+ Azure regions
- Spoke Virtual Networks for application workloads (10+ initial capacity)
- Azure Virtual WAN Premium tier for global connectivity
- ExpressRoute (1 Gbps) for hybrid on-premises connectivity
- Azure Firewall Premium tier with advanced threat protection
- Private DNS zones (20+) for private endpoint name resolution
- Azure DDoS Protection Standard for network-wide DDoS protection

**Identity & Access:**
- Azure AD with 100+ cloud users and groups
- Multi-factor authentication (MFA) enforcement
- Conditional Access policies (10+ policies)
- Role-based access control (RBAC) with custom roles
- Privileged Access Workstations (PAW) for administrative access
- Just-In-Time (JIT) access for Azure resources

**Security & Monitoring:**
- Azure Sentinel with data connectors from 15+ sources
- Defender for Cloud Standard tier with continuous assessment
- Azure Log Analytics Workspace with 500 GB/month capacity
- Azure Monitor with custom dashboards and alerting
- Network Security Groups with application-level rules
- Azure Bastion for secure administrative access (2 instances)

**Support & Optimization:**
- Azure Support Professional Direct plan (24/7 support)
- Monthly governance and optimization reviews
- Quarterly cost optimization analysis
- Monthly security threat hunting and reviews

## Application Hosting

Application hosting on Azure includes:

- Virtual Machines in spoke subscriptions with disk encryption
- App Service for web and API applications
- Azure Kubernetes Service (AKS) for containerized workloads
- Azure Database services (SQL, MySQL, PostgreSQL)
- Storage accounts with encryption and access controls
- All resources follow landing zone policies for naming, tagging, and security

## Networking

The networking architecture follows Azure CAF best practices:

- Hub Virtual Network hosting centralized services (Firewall, Gateway, Bastion)
- Spoke Virtual Networks for workload isolation and organizational alignment
- Hub-spoke peering with hub routing enabled
- Network Security Groups for subnet-level access control
- User-defined routes for traffic inspection through Azure Firewall
- Azure Firewall with application and network rules
- Private Endpoints for private connectivity to Azure PaaS services
- Private DNS zones for private endpoint name resolution
- ExpressRoute for secure hybrid connectivity
- Service Endpoints for additional access control options

## Observability

Comprehensive observability ensures operational excellence and security:

- Azure Monitor for infrastructure and application monitoring
- Log Analytics Workspace for centralized log ingestion and analysis
- Application Insights for application performance monitoring
- Azure Sentinel for security information and event management (SIEM)
- Defender for Cloud for continuous compliance and threat assessment
- Custom dashboards showing operational KPIs and security metrics
- Alert rules for proactive notification of issues
- Diagnostic settings configured on all Azure resources

## Backup & Disaster Recovery

All critical data and configurations are protected through:

- Azure Backup for virtual machines and databases
- Managed disk snapshots for rapid recovery
- Geo-redundant storage (GRS) for data durability
- Azure Site Recovery for workload replication
- Backup policies: Daily snapshots, 7-day retention minimum
- RTO: 2-4 hours | RPO: 1 hour
- Quarterly disaster recovery testing

---

## Technical Implementation Strategy

The implementation approach follows Azure Cloud Adoption Framework (CAF) best practices and proven methodologies for enterprise landing zones.

## Implementation Approach

- Phased deployment: Foundation (weeks 1-4), Platform (weeks 5-8), Operations (weeks 9-12)
- Iterative design with stakeholder feedback at each phase milestone
- Risk mitigation: Change control process for all deployments
- Communication: Weekly status updates and stakeholder reviews

## Tooling Overview

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| Infrastructure | Terraform, ARM Templates | Infrastructure-as-code for landing zone deployment |
| Policy Enforcement | Azure Policy, Azure Blueprints | Governance and compliance automation |
| Monitoring | Azure Monitor, Log Analytics | Centralized logging and monitoring |
| Security | Azure Sentinel, Defender for Cloud | SIEM and threat detection |
| Network | Azure Virtual WAN, Firewall | Network architecture and security |
| Identity | Azure AD, Conditional Access | Identity and access management |
| CI/CD | Azure DevOps, GitHub Actions | Policy and infrastructure deployment |
| Dashboarding | Power BI, Azure Monitor | Operational and business metrics |

---

## Data Management

## Data Strategy

- Centralized logging via Log Analytics Workspace
- Diagnostic settings configured on all Azure resources
- Activity Logs captured for audit trail
- Metrics collected for performance monitoring
- Cost data captured for chargeback and optimization
- Data retention: Logs retained for 90 days minimum, archival to storage after 90 days
- Data classification applied to sensitive resources

## Security & Compliance

- Encryption enabled for all data at rest and in transit
- Personally identifiable information (PII) handling per compliance requirements
- Data residency controls ensuring data remains in required regions
- Audit trail for all administrative access to data
- Secure deletion capabilities for GDPR/data privacy compliance
- Data access reviews on quarterly basis
- Backup and recovery procedures documented and tested

---

---

# Security & Compliance

The implementation and target environment will be architected and validated to meet the Client's security, compliance, and governance requirements. Vendor will adhere to Azure and industry-standard security frameworks.

## Identity & Access Management

- Azure AD-based identity for all users and service principals
- Multi-factor authentication (MFA) required for all administrative access
- Conditional Access policies enforcing access requirements by location, device, and risk
- Role-based access control (RBAC) with principle of least privilege
- Privileged Access Workstations (PAW) for administrative activities
- Just-In-Time (JIT) access to virtual machines and privileged resources
- Regular access reviews and removal of inactive accounts
- Service principal and managed identity usage for application authentication

## Monitoring & Threat Detection

- Azure Sentinel SIEM with 15+ data connectors activated
- Defender for Cloud continuous compliance and threat assessment
- Azure Monitor alerting on security events and anomalies
- Network traffic analysis through Azure Firewall logs
- Azure AD sign-in and audit logging
- Automated incident response playbooks in Sentinel
- Integration with SOC tools and ITSM systems
- Threat hunting activities on monthly basis

## Compliance & Auditing

- Azure Policy enforces compliance across all subscriptions
- Defender for Cloud compliance benchmarks: CIS, PCI-DSS, SOC 2
- Audit logging of all administrative activities via Azure Activity Logs
- Compliance assessments and reporting
- Regulatory compliance: SOC 2, PCI-DSS, HIPAA (if applicable)
- Continuous monitoring and automated remediation of policy violations
- Annual compliance audits and certification

## Encryption & Key Management

- Encryption at rest using Azure Storage Service Encryption (SSE) and transparent data encryption (TDE)
- Encryption in transit using TLS 1.2+ for all data movement
- Azure Key Vault for centralized key and secret management
- Customer-managed encryption keys (CMEK) option for sensitive workloads
- Encryption key rotation policies and automated rotation
- Key access auditing and monitoring

## Governance

- Azure Policy framework with 50+ policies for enforcement
- Change control: All infrastructure changes require formal change request
- Naming convention enforcement via Azure Policy
- Tagging strategy for cost allocation and resource management
- Resource groups organized by team and project
- Subscription governance with clear ownership and chargeback
- Regular governance reviews and policy updates
- Incident response procedures for security events

---

## Environments & Access

## Environments

<!-- TABLE_CONFIG: widths=[25, 35, 20, 20] -->
| Environment | Purpose | Azure Region | Lifecycle |
|-------------|---------|------------|-----------------|
| Management | Enterprise landing zone services | Primary Region | Persistent |
| Platform | Shared platform services | Primary & Secondary | Persistent |
| Production | Live application workloads | Multi-region | Persistent |
| Staging | Pre-production application testing | Primary Region | Persistent |
| Development | Development and testing | Primary Region | Ephemeral |

## Access Policies

- Multi-factor authentication (MFA) required for all Azure portal access
- API access via Azure AD managed identities or service principals
- Role-based access control with predefined roles:
  - Owner: Full management capabilities
  - Contributor: Deployment and management of resources
  - Reader: Read-only access for auditing
  - Network Contributor: Network management tasks
  - Security Admin: Security configuration and monitoring
  - Subscription Contributor: Subscription-level operations
- Custom roles for specialized operations (DevOps, Database Admin, etc.)
- Privileged Identity Management (PIM) for eligible role assignment

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the implementation lifecycle to ensure functionality, security, and operational readiness of the enterprise landing zone.

## Functional Validation

- Management group hierarchy deployed correctly with policy assignment
- Azure Policy rules enforcing compliance across subscriptions
- Hub-spoke network connectivity functioning with expected latency
- Azure Firewall rules routing traffic correctly
- Private DNS zones resolving names for private endpoints
- Conditional Access policies enforcing security requirements
- MFA enrollment and enforcement working as expected
- Backup and restore procedures functioning correctly

## Security & Compliance Testing

- Validation of encryption (data at rest and in transit)
- Access control testing (RBAC policies, Conditional Access)
- Compliance validation against industry standards (CIS, SOC 2, PCI-DSS)
- Network segmentation testing to ensure isolation
- Firewall rule validation for expected traffic flows
- Sentinel alert validation for security event detection
- Threat detection testing in Defender for Cloud
- Data privacy and residency controls verification

## Performance & Capacity Testing

- Network latency between hubs and spokes (<50ms target)
- Firewall throughput and rule processing performance
- Log Analytics Workspace ingestion and query performance
- Azure Monitor dashboard responsiveness
- Sentinel correlation and detection latency
- Failover testing for hub redundancy

## Operational Readiness Testing

- Operational runbook procedures tested by operations team
- Alert escalation procedures validated
- Incident response playbook execution tested
- Cost chargeback calculation accuracy verified
- Backup and restore tested on sample workloads
- Administrative access procedures validated

## User Acceptance Testing (UAT)

- IT operations team validates landing zone management procedures
- Security team validates threat detection and incident response
- Network team validates connectivity and network management
- Finance team validates cost tracking and chargeback accuracy

## Go-Live Readiness

A Go-Live Readiness Checklist will be delivered including:

- Security and compliance sign-offs from security team
- Operations team sign-off on runbooks and procedures
- Network connectivity and performance validation
- Backup and disaster recovery testing completion
- Knowledge transfer completion with staff certification
- Documentation delivery and portal access
- Hypercare support plan confirmation

---

## Cutover Plan

## Cutover Checklist

- Pre-cutover validation: Final testing and operational team certification
- Stakeholder approval for production deployment
- Hypercare support team mobilized and on-call
- Communication plan executed: All stakeholders notified of go-live
- Monitoring dashboards validated and active
- Alert escalation procedures confirmed
- Incident response team trained and available
- Rollback procedures documented and rehearsed

## Rollback Strategy

- Documented rollback triggers: Policy enforcement failure, network connectivity loss, security controls failure
- Rollback procedures: Terraform/ARM template rollback, policy suspension with approval, resource recreation
- Root cause analysis and fix validation before retry
- Communication plan for stakeholders
- Preserve all logs and audit data for analysis
- Maximum 2-hour RTO for critical issues

---

---

# Handover & Support

## Handover Artifacts

- As-Built documentation including architecture diagrams and configurations
- Management group and policy framework documentation
- Network topology and firewall rule documentation
- Identity configuration and conditional access policy documentation
- Azure Sentinel and Defender for Cloud configuration
- Operational dashboards and alerting configuration
- Cost optimization recommendations and chargeback model
- Runbook repository with troubleshooting procedures
- Training materials and recorded sessions

## Knowledge Transfer

- Live knowledge transfer sessions for administrators and operations team
- Azure platform management training (management groups, policies, subscriptions)
- Network operations training (hub-spoke management, firewall rules, connectivity)
- Security operations training (Sentinel, Defender for Cloud, incident response)
- Cost management and chargeback training
- Recorded training materials hosted in client portal
- Documentation portal with searchable content
- Post-implementation support availability for questions

---

## Assumptions

## General Assumptions

- Client will provide current state information for assessment (resource inventory, organizational structure, compliance requirements)
- Azure AD is deployed and available for identity configuration
- Client technical team will be available for requirements validation, testing, and approvals
- Azure account access and appropriate permissions will be provided within 1 week of project start
- Azure subscriptions (minimum 3: management, platform, connectivity) will be available for landing zone deployment
- ExpressRoute circuit capacity is available and can be provisioned within project timeline
- Network policies and requirements are stable during implementation
- Security and compliance approval processes will not delay critical path activities
- Client will handle ongoing Azure cost directly with Azure (estimated $8,500-$12,000/month post-implementation)
- Sufficient staff capacity exists for knowledge transfer and operations transition
- Hybrid connectivity (ExpressRoute) is required and budget is approved

---

## Dependencies

## Project Dependencies

- Azure Account Access: Client provides Azure account with appropriate permissions (Owner/Contributor on root management group)
- Subscription Quota: Azure subscription limits are sufficient for landing zone design (minimum 50 subscriptions capacity)
- Network Planning: Client provides network design requirements, IP addressing scheme, hybrid connectivity details
- Azure AD Configuration: Client Azure AD tenant is ready for configuration and integration
- Organizational Structure: Client provides organizational chart and team structure for management group design
- Compliance Requirements: Client provides list of compliance requirements (SOC 2, PCI-DSS, HIPAA, regulatory standards)
- Security Requirements: Client defines threat model, incident response requirements, and security standards
- Integration Endpoints: Client identifies systems that require integration with landing zone (ITSM, CMDB, SIEM)
- Stakeholder Availability: Business, security, network, and IT operations stakeholders available for review sessions
- Change Approval Process: Client change control board available for approvals
- Go-Live Approval: Business and technical authority available for production deployment decision

---

---

# Investment Summary

**Enterprise-Scale Implementation:** This pricing reflects an enterprise-scale deployment designed to support multiple business units and 20+ application subscriptions with centralized governance and security. For pilot or smaller deployments, please request small scope pricing.

## Total Investment

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 23, 13, 10, 10, 12] -->
| Cost Category | Year 1 List | Azure Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|---------|---------|--------------|
| Professional Services | $134,000 | ($15,000) | $119,000 | $0 | $0 | $119,000 |
| Cloud Infrastructure | $75,520 | ($10,000) | $65,520 | $75,520 | $75,520 | $216,560 |
| Software Licenses & Subscriptions | $30,600 | ($5,000) | $25,600 | $30,600 | $30,600 | $86,800 |
| Support & Maintenance | $24,800 | $0 | $24,800 | $24,800 | $24,800 | $74,400 |
| **TOTAL INVESTMENT** | **$265,020** | **($30,000)** | **$245,020** | **$131,020** | **$131,020** | **$497,060** |
| **Billing Adjustment** | - | - | **($28,000)** | - | - | **($28,000)** |
| **ADJUSTED TOTAL INVESTMENT** | **$265,020** | **($30,000)** | **$217,020** | **$131,020** | **$131,020** | **$469,060** |
<!-- END COST_SUMMARY_TABLE -->

## Cost Components

**Professional Services** ($134,000 - 520 hours): Labor costs for discovery, architecture, implementation, testing, and knowledge transfer. Breakdown:

- Enterprise Architecture & Design (120 hours @ $225/hr): $27,000
- Landing Zone Implementation (240 hours @ $200/hr): $48,000
- Security & Compliance Setup (80 hours @ $200/hr): $16,000
- Network Architecture Implementation (120 hours @ $200/hr): $24,000
- Identity & Access Management (60 hours @ $200/hr): $12,000
- Azure Training & Knowledge Transfer (40 hours @ $175/hr): $7,000

**Cloud Infrastructure** ($75,520/year): Azure services for enterprise landing zone:

- Azure Virtual WAN Premium tier (2 hubs): $5,200/year
- Azure Firewall Premium (2 instances): $15,000/year
- Azure DDoS Protection Standard: $3,000/year
- Private DNS Zones (20 zones): $120/year
- Azure Bastion (2 instances): $1,800/year
- Log Analytics Workspace (500 GB/month): $13,500/year
- ExpressRoute Circuit (1 Gbps): $18,000/year
- Network vNets and peering: $18,900/year

**Software Licenses & Subscriptions** ($30,600/year): Operational and monitoring tools:

- Azure Monitor: $3,600/year
- Azure Sentinel (200 GB/month): $18,000/year
- Microsoft Defender for Cloud Standard: $9,000/year

**Support & Maintenance** ($24,800/year): Ongoing support and governance:

- Azure Support Professional Direct plan: $12,000/year
- Ongoing Governance & Optimization (40 hrs/year @ $200/hr): $8,000/year
- Security Operations Support (24 hrs/year @ $200/hr): $4,800/year

Detailed breakdown including Azure service consumption and sizing is provided in cost-breakdown.csv.

---

## Payment Terms

### Pricing Model

- Fixed price for professional services
- Variable pricing for cloud infrastructure based on Azure consumption
- Milestone-based payments aligned with project phases and deliverables

### Payment Schedule

- 25% upon SOW execution and project kickoff ($65,625 on Year 1 list, $54,255 net after Year 1 credit)
- 30% upon completion of Discovery & Architecture phase ($79,506 on list, $63,006 net)
- 30% upon completion of Platform Implementation phase ($79,506 on list, $63,006 net)
- 15% upon successful go-live and knowledge transfer ($39,753 on list, $31,503 net)

---

## Invoicing & Expenses

### Invoicing

- Milestone-based invoicing per Payment Terms above
- Net 30 payment terms from invoice date
- Invoices submitted upon milestone completion and acceptance
- Invoice amounts reflect Azure credits and billing adjustments as agreed

### Expenses

- Cloud Infrastructure costs are included in pricing ($75,520/year estimates Azure consumption)
- Enterprise-scale sizing: 20+ subscriptions, multi-region capable deployment
- Costs scale with actual Azure consumption based on workload deployment
- Professional services travel (if any): Reimbursable at cost with prior approval (remote-first delivery model)
- Staffing for knowledge transfer and training: Included in Professional Services
- Post-implementation support (Years 2-3): Additional Azure subscription costs only, no professional services

---

---

# Terms & Conditions

All services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

## Scope Changes

- Changes to management group structure, policy framework, network design, or timeline require formal change requests
- Change requests may impact project timeline and budget
- Azure resource additions (additional subscriptions, regions) are scope changes

## Intellectual Property

- Client retains ownership of all business data, applications, and workload content
- Vendor retains ownership of proprietary landing zone templates, policy frameworks, and methodologies
- Custom policies, runbooks, and configurations become Client property upon final payment
- Infrastructure code and automation scripts transfer to Client upon project completion

## Service Levels

- Azure platform availability: 99.9% for hub services (Firewall, DNS, routing)
- Azure Sentinel detection latency: <5 minutes for critical events
- Defender for Cloud assessment latency: <24 hours for resource compliance
- System uptime: 99.9% during business hours (24/7 monitoring, business hours support)
- 30-day warranty on all deliverables from go-live date
- Post-warranty support available under separate managed services agreement

## Liability

- Azure platform SLAs apply to cloud infrastructure components
- Policy and governance configuration warranty applies to CAF-aligned deployments
- Performance may vary with non-standard workload types or configurations
- Ongoing optimization recommended as cloud adoption matures
- Liability caps as agreed in MSA

## Confidentiality

- Both parties agree to maintain strict confidentiality of business data, organizational structure, and proprietary information
- All exchanged artifacts under NDA protection
- Security findings and recommendations treated as confidential

## Termination

- Mutually terminable per MSA terms, subject to payment for completed work and deliverables
- Client owns all completed infrastructure and configurations upon termination

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
