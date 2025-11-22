---
document_title: Statement of Work
technology_provider: IBM Red Hat
project_name: Ansible Automation Platform Implementation
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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing Red Hat Ansible Automation Platform for [Client Name]. This engagement will deliver IT automation capabilities managing 500 servers and 100 network devices, enabling standardized configuration management, automated provisioning, and event-driven remediation to eliminate manual operations and reduce costs.

**Project Duration:** 6 months (24 weeks)

---

---

# Background & Objectives

## Current State

[Client Name] currently relies on manual server configuration and network device management processes that consume significant IT resources. A single server configuration takes 4-8 hours of manual effort, and network changes require 2-day maintenance windows. Key challenges include:
- **Manual Configuration Overhead:** 4-8 hours per server configuration with 500 servers requiring ongoing management
- **Configuration Drift:** 30% of support tickets caused by configuration inconsistencies across infrastructure
- **Slow Network Changes:** Network device updates requiring 2-day maintenance windows blocking deployments
- **Scalability Limitations:** Cannot efficiently manage infrastructure growth due to manual processes
- **Knowledge Silos:** Critical infrastructure knowledge concentrated in few individuals creating operational risk
- **Compliance Challenges:** Manual audit processes and inconsistent security configurations

## Business Objectives
- **Automate IT Operations:** Implement Ansible Automation Platform for 500 servers and 100 network devices with 100 custom playbooks eliminating manual configuration tasks
- **Eliminate Configuration Drift:** Achieve zero configuration drift violations through standardized automation and continuous compliance
- **Accelerate Network Operations:** Reduce network configuration time from 2 days to 30 minutes through automated device management
- **Reduce Labor Costs:** Achieve 90% reduction in manual effort and $400K annual labor cost avoidance
- **Enable Self-Service:** Provide infrastructure self-service capabilities for development and operations teams
- **Improve Compliance:** Automate compliance validation and remediation for security and regulatory requirements

## Success Metrics
- 90% reduction in manual configuration effort measured by task time
- Zero configuration drift violations across managed infrastructure
- 95% reduction in network change implementation time (2 days to 30 minutes)
- $400K annual labor cost savings from eliminated manual tasks
- 100 production-ready automation playbooks covering server, network, and cloud operations
- 99.5% automation execution success rate for scheduled jobs

---

---

# Scope of Work

## In Scope
The following services and deliverables are included in this SOW:
- Infrastructure automation assessment and Ansible platform design
- Ansible Automation Platform deployment and configuration (HA controller cluster)
- Automation content development (100 custom playbooks for servers and network devices)
- ServiceNow integration for ticket-driven automation workflows
- Event-driven automation configuration with monitoring integration
- Self-service automation portal for operations teams
- Testing, validation, and production rollout
- Knowledge transfer and documentation

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Server Count | 500 servers (Linux/Windows) |
| Solution Scope | Network Device Count | 100 network devices |
| Solution Scope | Playbook Count | 100 custom automation playbooks |
| Integration | ITSM Integration | ServiceNow ticket-driven workflows |
| Integration | External Systems | Monitoring systems + credential vault |
| User Base | Automation Users | 50 operations staff |
| User Base | User Roles | 5 roles (operator admin developer approver auditor) |
| Data Volume | Automation Executions | 10000+ job runs per month |
| Data Volume | Inventory Management | 600 managed nodes total |
| Technical Environment | Deployment Platform | AWS/Azure cloud infrastructure |
| Technical Environment | Availability Requirements | HA controller cluster (99.5% uptime) |
| Technical Environment | Infrastructure Complexity | Controller HA + distributed execution nodes |
| Security & Compliance | Security Requirements | RBAC + credential vault integration |
| Security & Compliance | Compliance Frameworks | SOC2 ISO 27001 |
| Performance | Execution Capacity | 100 concurrent job executions |
| Performance | Automation Orchestration | Event-driven automation + scheduled jobs |
| Environment | Deployment Environments | 2 environments (dev/staging + prod) |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*


## Activities

### Phase 1 – Discovery & Assessment
During this initial phase, the Vendor will perform a comprehensive assessment of the Client's current IT operations and automation opportunities. This includes analyzing manual processes, identifying high-value automation use cases, determining platform requirements, and designing the optimal Ansible architecture.

Key activities:
- IT operations workflow analysis and automation opportunity assessment
- Server and network device inventory and standardization evaluation
- Ansible platform requirements gathering (controller sizing, execution capacity)
- Automation use case prioritization (provisioning, configuration, compliance, remediation)
- Security and compliance requirements analysis (RBAC, credential management, audit trails)
- Integration requirements with existing systems (ServiceNow, monitoring, credential vaults)
- Solution architecture design (HA controller cluster, execution nodes, automation hub)
- Implementation planning and resource allocation

This phase concludes with an Assessment Report that outlines the proposed Ansible architecture, automation playbook roadmap, integration approach, risks, and project timeline.

### Phase 2 – Solution Design & Environment Setup
In this phase, the Ansible Automation Platform infrastructure is provisioned and configured based on Red Hat best practices. This includes controller deployment, execution node configuration, security baseline, and integration framework setup.

Key activities:
- Infrastructure provisioning (AWS/Azure VMs for automation controller and execution nodes)
- Ansible Automation Controller deployment (HA cluster with 2+ controller nodes)
- Private Automation Hub configuration for organization content management
- Execution node deployment for scalable job processing (4+ execution nodes)
- Security baseline configuration (RBAC, Teams, Organizations, Credentials)
- LDAP/AD integration for SSO and team-based access control
- Credential vault integration (HashiCorp Vault or CyberArk for secret management)
- ServiceNow integration framework for ticket-driven automation
- Monitoring and logging setup for automation platform observability

By the end of this phase, the Client will have a secure, production-ready Ansible Automation Platform environment.

### Phase 3 – Implementation & Execution
Implementation will occur in well-defined phases based on automation complexity and business impact. The focus is on developing 100 custom playbooks covering server provisioning, network configuration, compliance validation, and automated remediation.

Key activities:
- Automation playbook development (50 server playbooks + 30 network playbooks + 20 cloud/compliance playbooks)
- Server provisioning automation (OS installation, patching, configuration, application deployment)
- Network device automation (configuration templates, change management, compliance validation)
- Compliance automation (security hardening, vulnerability remediation, audit reporting)
- ServiceNow integration workflows (ticket-driven job execution and status updates)
- Event-driven automation (monitoring system webhooks triggering auto-remediation)
- Self-service automation catalog for operations teams
- Git integration for playbook version control and collaboration
- Incremental testing and validation with pilot systems

After each phase, the Vendor will coordinate validation and sign-off with the Client before proceeding.

### Phase 4 – Testing & Validation
In the Testing and Validation phase, the Ansible platform and automation playbooks undergo thorough functional, performance, and security validation to ensure they meet required SLAs and compliance standards. Test cases will be executed based on Client-defined acceptance criteria.

Key activities:
- Unit testing of individual automation playbooks with test inventory
- Integration testing with ServiceNow, monitoring systems, and credential vaults
- Performance benchmarking (concurrent job execution, scaling validation)
- Security validation (RBAC policies, credential handling, audit logging)
- Idempotency testing (playbook re-execution safety and convergence)
- Rollback and error handling validation for production readiness
- User Acceptance Testing (UAT) coordination with operations teams
- Go-live readiness review and production rollout planning

Production rollout will be coordinated with all relevant stakeholders and executed with phased automation enablement, with well-documented rollback procedures in place.

### Phase 5 – Handover & Post-Implementation Support
Following successful implementation and production rollout, the focus shifts to ensuring operational continuity and knowledge transfer. The Vendor will provide a period of hypercare support and equip the Client's team with the documentation, tools, and processes needed for ongoing automation platform management.

Activities include:
- Delivery of as-built documentation (architecture diagrams, playbook catalog, runbooks)
- Operations runbook and SOPs for day-to-day automation platform management
- Ansible platform administration training (controller management, playbook development, troubleshooting)
- Automation developer training (playbook authoring, testing, Git workflows, best practices)
- Live or recorded knowledge transfer sessions for administrators and automation developers
- Performance optimization recommendations and capacity planning guidance
- 30-day warranty support for issue resolution
- Optional transition to a managed services model for ongoing automation support, if contracted

---

## Out of Scope

These items are not in scope unless added via change control:
- Hardware procurement or on-premises infrastructure beyond specified platform sizing
- Third-party software licensing beyond Ansible Automation Platform subscriptions
- Server or network device decommissioning or infrastructure remediation
- Application-level automation or database management automation
- Ongoing operational support beyond 30-day warranty period
- Custom development beyond specified 100 automation playbooks
- Network infrastructure modifications or bandwidth upgrades
- End-user training beyond initial knowledge transfer sessions
- Red Hat Ansible Automation Platform subscription costs (billed directly by Red Hat to client)

---

---

# Deliverables & Timeline

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | Requirements Specification | Document/CSV | Week 2 | [Client Lead] |
| 2 | Ansible Platform Architecture | Document | Week 3 | [Technical Lead] |
| 3 | Implementation Plan | Project Plan | Week 3 | [Project Sponsor] |
| 4 | Ansible Platform Environment | System | Week 6 | [Technical Lead] |
| 5 | Automation Playbooks (100) | System | Week 16 | [Operations Lead] |
| 6 | ServiceNow Integration | System | Week 12 | [Integration Lead] |
| 7 | Self-Service Automation Portal | System | Week 14 | [Operations Lead] |
| 8 | Event-Driven Automation | System | Week 14 | [Operations Lead] |
| 9 | Test Plan & Results | Document | Week 18 | [QA Lead] |
| 10 | User Training Materials | Document/Video | Week 20 | [Training Lead] |
| 11 | Operations Runbook | Document | Week 22 | [Ops Lead] |
| 12 | As-Built Documentation | Document | Week 24 | [Client Lead] |
| 13 | Knowledge Transfer Sessions | Training | Week 21-24 | [Client Team] |

---

## Project Milestones

<!-- TABLE_CONFIG: widths=[20, 50, 30] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 | Assessment Complete | Week 3 |
| M2 | Platform Deployed | Week 6 |
| M3 | 50 Playbooks Operational | Week 12 |
| M4 | 100 Playbooks Complete | Week 16 |
| M5 | Testing Complete | Week 18 |
| Go-Live | Production Rollout | Week 20 |
| Hypercare End | Support Period Complete | Week 24 |

---

---

# Roles & Responsibilities

## RACI Matrix

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO Sales Eng | EO Eng | Client IT | Client Ops | SME |
|-----------|-------|----------------|--------------|--------|-----------|------------|-----|
| Discovery & Requirements | A | R | R | C | C | R | C |
| Solution Architecture | C | A | R | I | I | C | I |
| Platform Deployment | C | A | C | R | C | I | I |
| Infrastructure Setup | C | R | C | A | C | I | I |
| Playbook Development | C | R | C | A | C | R | I |
| Integration Implementation | C | R | C | A | C | R | I |
| Testing & Validation | R | C | R | R | A | A | I |
| Security Configuration | C | R | I | A | I | A | I |
| Knowledge Transfer | A | R | R | R | C | C | I |
| Hypercare Support | A | R | R | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- EO Project Manager: Overall delivery accountability
- EO Quarterback: Technical design and oversight
- EO Sales Engineer: Solution architecture and pre-sales support
- EO Engineer: Ansible platform deployment and playbook development

**Client Team:**
- IT Lead: Primary technical contact and infrastructure access management
- Operations Lead: Automation requirements and workflow coordination
- Automation Administrator: Platform operations and knowledge transfer recipient
- Operations Teams: Playbook validation and UAT participation

---

---

# Architecture & Design

## Architecture Overview
The Red Hat Ansible Automation Platform solution is designed as an **enterprise IT automation platform** with centralized control, distributed execution, and event-driven capabilities. The architecture provides high availability, scalability, and enterprise-grade security for automated infrastructure management.

This architecture is designed for **small-scope deployment** supporting 50 operations staff automating 500 servers and 100 network devices with 100 custom playbooks. The design prioritizes:
- **High Availability:** HA controller cluster with load balancing for platform resilience
- **Scalability:** Distributed execution nodes for parallel job processing
- **Integration:** ServiceNow and event-driven automation for operational workflows

![Figure 1: Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Solution Architecture Diagram** - High-level overview of the Ansible Automation Platform architecture

## Architecture Type
The deployment follows a centralized automation platform architecture with distributed execution. This approach enables:
- Centralized automation control with web UI, API, and CLI interfaces
- Distributed job execution across multiple execution nodes for scalability
- Event-driven automation triggered by monitoring systems and service tickets
- Credential management with external vault integration for security
- RBAC-based access control for team-based automation governance

Key architectural components include:
- Automation Controller Layer (2+ controller nodes in HA cluster with PostgreSQL database)
- Execution Infrastructure Layer (4+ execution nodes for distributed job processing)
- Automation Content Layer (Private Automation Hub for playbooks, roles, collections)
- Integration Layer (ServiceNow connector, monitoring webhooks, credential vault)
- Observability Layer (Job logging, metrics collection, audit trail)

## Scope Specifications

**Automation Controller:**
- Controller Nodes: 2 nodes (8 vCPU, 16GB RAM each) in HA cluster
- PostgreSQL Database: Managed database service or dedicated DB node (HA configuration)
- Web UI + API + CLI interfaces for automation management
- Deployment platform: AWS/Azure cloud infrastructure

**Execution Infrastructure:**
- Execution Nodes: 4 nodes (8 vCPU, 16GB RAM each) for job processing
- Concurrent job capacity: 100 concurrent executions
- Auto-scaling support for burst workload handling
- Geographic distribution for latency optimization (optional)

**Automation Content:**
- Private Automation Hub for organization content management
- 100 custom playbooks (50 server + 30 network + 20 cloud/compliance)
- 2000+ certified Ansible collections from Red Hat and partners
- Git integration for playbook version control and CI/CD

**Integration:**
- ServiceNow integration for ticket-driven automation workflows
- Monitoring system webhooks for event-driven auto-remediation
- Credential vault integration (HashiCorp Vault or CyberArk)
- LDAP/AD integration for SSO and team-based access control

**Managed Infrastructure:**
- 500 servers (Linux RHEL/Ubuntu + Windows Server)
- 100 network devices (Cisco, Juniper, Arista routers/switches/firewalls)
- Cloud resources (AWS, Azure provisioning and configuration)
- Compliance and security automation across all managed nodes

**Scalability Path:**
- Medium scope: Add execution nodes to support 1000+ servers and 200+ network devices
- Large scope: Multi-region deployment with federated automation hubs
- No architectural changes required - only execution node additions and content expansion

## Application Hosting
The Ansible Automation Platform will be hosted on cloud infrastructure:
- Automation Controller and execution nodes deployed as cloud VMs (AWS EC2 or Azure VMs)
- PostgreSQL database using managed cloud database service (RDS or Azure Database)
- Private Automation Hub deployed as dedicated cloud VM or container
- Load balancer for HA controller access (cloud load balancer service)

All infrastructure deployed using infrastructure-as-code (Terraform or CloudFormation).

## Networking
The networking architecture follows Ansible Automation Platform best practices:
- VPC/VNet deployment with public and private subnets for security
- Load balancer for HA controller access with SSL/TLS termination
- Execution nodes in private subnet with outbound access to managed infrastructure
- SSH/WinRM connectivity to managed servers (port 22 for Linux, 5986 for Windows)
- API access to network devices (NETCONF, RESTCONF, vendor APIs)
- Webhook endpoints for event-driven automation triggers
- VPN or private connectivity to on-premises infrastructure (if applicable)

## Observability
Comprehensive observability ensures operational excellence:
- Job execution logs for all automation runs with detailed output
- Platform metrics (job success rate, execution time, queue depth)
- Audit trail for all user actions and automation changes
- Integration with external monitoring systems (Datadog, Splunk, ELK)
- Custom dashboards showing automation KPIs (jobs per day, success rate, time savings)
- Alerting for failed jobs, platform issues, and capacity thresholds

## Backup & Disaster Recovery
All critical data and configurations are protected through:
- PostgreSQL database automated backups (daily snapshots with point-in-time recovery)
- Automation content backup (playbooks, inventories, credentials exported daily)
- Configuration backup for controller settings and RBAC policies
- Git repository backup for all playbook source code
- RTO: 4 hours | RPO: 1 hour

---

## Technical Implementation Strategy

The implementation approach follows Red Hat best practices and proven methodologies for Ansible deployments.

## Example Implementation Patterns
- Phased playbook development: Start with read-only tasks, then configuration changes
- Pilot-first approach: Validate automation with test systems before production rollout
- Check mode validation: Dry-run all playbooks before execution for safety

## Tooling Overview

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|-----------------------|------------------------------|-------------------------------|
| Automation Platform | Red Hat Ansible Automation Platform | Enterprise automation with controller and execution nodes |
| Content Management | Private Automation Hub | Organization playbook and collection repository |
| Version Control | Git (GitLab/GitHub) | Playbook source control and collaboration |
| ITSM Integration | ServiceNow Connector | Ticket-driven automation workflows |
| Credential Management | HashiCorp Vault / CyberArk | Secure credential storage and rotation |
| Monitoring | Datadog / Splunk | Platform observability and job analytics |
| Event-Driven | Ansible Event-Driven Ansible | Monitoring webhook triggers and auto-remediation |
| Testing | Molecule, Ansible Lint | Playbook testing and quality validation |

---

## Data Management

### Data Strategy
- Centralized inventory management for all managed servers and network devices
- Dynamic inventory integration with CMDBs and cloud providers
- Credential management with vault integration for secret protection
- Job execution history retention for audit and troubleshooting (90-day retention)
- Automation content versioning with Git for change tracking

### Data Security & Compliance
- Encryption for all credentials and secrets at rest and in transit
- RBAC for access control to automation content and managed infrastructure
- Audit logging for all automation executions and platform changes
- Compliance validation playbooks for SOC2 and ISO 27001 controls
- Network segmentation for execution node access to production infrastructure

---

---

# Security & Compliance

The implementation and target environment will be architected and validated to meet the Client's security, compliance, and governance requirements. Vendor will adhere to industry-standard security frameworks and Red Hat Ansible best practices.

## Identity & Access Management
- Role-Based Access Control (RBAC) with Teams, Organizations, and granular permissions
- LDAP/AD integration for Single Sign-On (SSO) with enterprise directory
- OAuth and API token authentication for programmatic access
- Credential delegation without exposing secrets to users
- Multi-factor authentication (MFA) for administrative access (if required)
- Service account management for automation integrations

## Monitoring & Threat Detection
- Audit logging for all automation executions and configuration changes
- Job execution monitoring with success/failure alerting
- Credential access tracking and rotation monitoring
- Integration with SIEM systems for security event correlation (if required)
- Anomalous automation pattern detection and alerting

## Compliance & Auditing
- SOC 2 compliant Ansible platform, architecture follows SOC 2 security principles
- ISO 27001 compliance: Access controls, audit logging, change management
- GDPR compliance (if applicable): Data handling controls, audit trail
- HIPAA compliance (if applicable): Credential protection, encryption, audit logging
- Compliance validation playbooks for automated security checks

## Encryption & Key Management
- All credentials encrypted at rest in PostgreSQL database
- External credential vault integration (HashiCorp Vault or CyberArk)
- SSH key management for Linux server authentication
- Certificate-based authentication for network devices
- API token encryption for service integrations
- TLS 1.2+ for all API and web UI communication

## Governance
- Change control: All playbook changes require Git commit and approval workflow
- Playbook governance: Code review and testing before production deployment
- Access reviews: Quarterly review of RBAC policies and user permissions
- Incident response: Documented procedures for automation failures and security incidents
- Resource tagging strategy for automation tracking and cost allocation

---

## Environments & Access

### Environment Strategy

| Environment | Purpose | Platform | Access |
|-------------|---------|----------|--------|
| Development | Playbook development and testing | Dev/staging cluster or shared controller | Automation developers |
| Production | Live automation operations | Production HA controller cluster | Operations team, authorized automation users |

### Access Policies
- Multi-factor authentication (MFA) required for administrator access
- API access via OAuth tokens with RBAC permissions
- Administrator Access: Full platform admin rights for automation team during project
- Developer Access: Playbook development and testing access with limited production permissions
- Operator Access: Job execution permissions for approved playbooks and inventories
- Auditor Access: Read-only access for audit and compliance reviews

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the implementation lifecycle to ensure functionality, performance, security, and reliability of the Ansible Automation Platform.

## Functional Validation
- End-to-end automation workflow validation (job submission to completion)
- Playbook idempotency testing (re-execution safety and convergence)
- ServiceNow integration testing (ticket-driven job triggers and status updates)
- Event-driven automation testing (monitoring webhook triggers and auto-remediation)
- Self-service portal functional testing (job templates and workflows)
- Credential management testing (vault integration and secret handling)

## Performance & Load Testing
- Benchmark testing with target concurrent job capacity (100 concurrent executions)
- Stress testing to identify platform capacity limits
- Job execution performance validation (execution time and resource utilization)
- Execution node scaling validation (adding nodes for increased capacity)
- Database performance testing (job history queries and reporting)

## Security Testing
- Validation of RBAC policies and team-based access controls
- Credential handling and vault integration testing
- SSH/WinRM authentication testing for managed infrastructure
- API authentication and authorization testing
- Audit logging validation for compliance requirements

## Disaster Recovery & Resilience Tests
- PostgreSQL database backup and restore validation
- Controller node failure testing and HA failover
- Execution node failure and job rescheduling validation
- Playbook repository recovery testing
- RTO/RPO validation

## User Acceptance Testing (UAT)
- Performed in coordination with Client operations teams
- Test environment and sample automation workflows provided by Vendor
- Automation workflow validation (provisioning, configuration, compliance)
- Platform administration testing (user management, job monitoring, troubleshooting)

## Go-Live Readiness
A Go-Live Readiness Checklist will be delivered including:
- Security and compliance sign-offs
- Performance testing completion (job capacity and execution time)
- High availability testing completion
- Integration testing completion (ServiceNow, monitoring, credential vault)
- Playbook validation (100 playbooks tested and approved)
- Training completion (administrators and automation developers)
- Documentation delivery (runbooks, playbook catalog, architecture)

---

## Cutover Plan

The cutover to the Ansible Automation Platform will be executed using a controlled, phased approach to minimize operational disruption and ensure seamless transition from manual processes. The production rollout will occur with gradual automation enablement and stakeholder communication.

**Cutover Approach:**

The implementation follows a **progressive automation enablement** strategy where automation is introduced incrementally by use case complexity and risk profile. This approach allows for:

1. **Pilot Phase (Week 1-2):** Enable read-only automation playbooks for infrastructure discovery and compliance reporting. Zero operational risk with validation of platform capabilities.

2. **Low-Risk Automation (Week 3-6):** Enable configuration management playbooks for non-critical systems:
   - Week 3-4: Server patching and package management automation (non-production systems)
   - Week 5-6: Network device configuration backups and compliance checks
   - Each category monitored for 1 week before proceeding

3. **Medium-Risk Automation (Week 7-12):** Enable provisioning and configuration playbooks for production infrastructure:
   - Week 7-8: Server provisioning automation (new system deployments)
   - Week 9-10: Application configuration and deployment automation
   - Week 11-12: Network device configuration changes with approval workflows

4. **Advanced Automation (Week 13-16):** Enable event-driven and remediation automation:
   - Week 13-14: Event-driven auto-remediation for monitoring alerts
   - Week 15-16: Self-service automation portal for operations teams

5. **Hypercare Period (4 weeks post-rollout):** Daily monitoring, rapid issue resolution, and automation optimization to ensure stable operations.

The rollout will be coordinated during approved change windows (recommended: off-hours deployments for production automation) with documented rollback procedures available if issues arise.

## Cutover Checklist
- Pre-rollout validation: Final UAT sign-off, playbook testing completion, security approval
- Production automation platform validated and monitoring operational
- Rollback procedures documented for each automation category
- Stakeholder communication completed (operations teams, management, application owners)
- Enable automation playbooks in phased approach per rollout plan
- Monitor first automation executions in production environment
- Verify automation success rate and operational impact
- Daily monitoring during hypercare period (4 weeks)

## Rollback Strategy
- Documented rollback triggers (high failure rate, operational impact, security incident)
- Rollback procedures: Disable automation playbooks, revert to manual processes
- Root cause analysis and playbook fixes before re-enablement
- Communication plan for stakeholders on rollback decisions
- Preserve all logs and execution data for post-incident analysis

---

---

# Handover & Support

## Handover Artifacts
- As-Built documentation including architecture diagrams and platform configurations
- Platform administration documentation (controller management, user administration, troubleshooting)
- Operations runbook with troubleshooting procedures and escalation paths
- Playbook catalog with usage documentation and dependencies
- Monitoring and alert configuration reference with recommended thresholds
- Integration documentation (ServiceNow, credential vault, monitoring systems)
- Automation best practices guide and development standards

## Knowledge Transfer
- Live knowledge transfer sessions for platform administrators and automation developers
- Ansible platform administration training (32 hours covering platform management, RBAC, monitoring, troubleshooting)
- Automation developer training (32 hours covering playbook development, testing, Git workflows, best practices)
- Recorded training materials hosted in shared portal or learning management system
- Documentation portal with searchable playbook catalog and runbooks
- Hands-on lab exercises for administrator and developer skill development

## Hypercare Support

Post-implementation support to ensure smooth transition to Client operations:

**Duration:** 4 weeks post-go-live (30 days)

**Coverage:**
- Business hours support (8 AM - 6 PM local time)
- 4-hour response time for critical platform issues
- Daily health check calls (first 2 weeks)
- Weekly status meetings with operations and automation leadership

**Scope:**
- Platform issue investigation and resolution
- Playbook troubleshooting and optimization
- Performance tuning and capacity optimization
- Configuration adjustments based on production workload patterns
- Knowledge transfer continuation and skill development
- Best practices guidance for automation operations

## Managed Services Transition (Optional)

Post-hypercare, Client may transition to ongoing managed services:

**Managed Services Options:**
- 24/7 monitoring and support for automation platform
- Proactive playbook development and optimization
- Platform upgrades and security patching
- Capacity management and execution node scaling support
- Monthly automation performance and cost optimization reviews
- New playbook development support for additional automation use cases

**Transition Approach:**
- Evaluation of managed services requirements during hypercare
- Service Level Agreement (SLA) definition for platform availability and automation success rate
- Separate managed services contract and pricing
- Seamless transition from hypercare to managed services

---

## Assumptions

### General Assumptions
- Client will provide access to infrastructure (AWS/Azure cloud or on-premises) for platform deployment
- Existing infrastructure meets network and firewall requirements for Ansible automation (SSH, WinRM, API access)
- SSH/WinRM access and credentials available for managed servers and network devices
- LDAP/AD directory is available for SSO integration with appropriate credentials
- Client technical team will be available for requirements validation, testing, and approvals
- Server and network device configurations allow for automation (no hardened lockdowns preventing Ansible access)
- Operations teams available for playbook validation, testing, and knowledge transfer
- Security and compliance approval processes will not delay critical path activities
- Client will handle Red Hat Ansible Automation Platform subscription costs directly with Red Hat

---

## Dependencies

### Project Dependencies
- Infrastructure Access: Client provides AWS/Azure cloud access or on-premises infrastructure for platform deployment within 1 week of project start
- Network Connectivity: Network team configures firewall rules for automation controller and execution node access to managed infrastructure
- LDAP/AD Integration: Client provides LDAP/AD connection details and service account for SSO integration
- Server Access: Operations teams provide SSH/WinRM credentials and access for managed servers
- Network Device Access: Network team provides API credentials and access for network devices (CLI, NETCONF, REST API)
- ServiceNow Integration: ServiceNow administrator provides instance details, API credentials, and workflow configuration support
- Credential Vault: HashiCorp Vault or CyberArk administrator provides API access and integration credentials (if using external vault)
- Testing Infrastructure: Client identifies and provides access to test servers and network devices for playbook validation
- SME Availability: Infrastructure subject matter experts available for automation requirements and playbook validation
- Security Approvals: Security and compliance approvals obtained on schedule to avoid implementation delays
- Infrastructure Readiness: Cloud environment meets capacity requirements for automation platform
- Change Freeze: No major changes to managed infrastructure during playbook development and testing phases
- Go-Live Approval: Business and technical approval authority available for production automation enablement decision

---

---

# Investment Summary

**Small Scope Implementation:** This pricing reflects a department-level deployment designed for automation platform managing 500 servers and 100 network devices with 100 custom playbooks. For larger enterprise deployments, please request medium or large scope pricing.

## Total Investment

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 18, 14, 12, 11, 13] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $73,600 | ($3,000) | $70,600 | $0 | $0 | $70,600 |
| Cloud Infrastructure | $26,520 | ($2,000) | $24,520 | $26,520 | $26,520 | $77,560 |
| Software Licenses | $115,000 | ($10,000) | $105,000 | $115,000 | $115,000 | $335,000 |
| Support & Maintenance | $17,652 | $0 | $17,652 | $17,652 | $17,652 | $52,956 |
| **TOTAL INVESTMENT** | **$232,772** | **($15,000)** | **$217,772** | **$159,172** | **$159,172** | **$536,116** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $15,000 (6% reduction)
- **Red Hat Partner Discount:** $10,000 on first year Ansible Automation Platform subscriptions through Advanced Partner program
- **Training Voucher Credits:** $3,000 for Red Hat training courses and certifications
- **AWS/Azure Promotional Credit:** $2,000 for new cloud workloads and infrastructure
- Credits are real Red Hat and cloud partner incentives, automatically applied to subscriptions and services
- Credits are Year 1 only; Years 2-3 reflect standard pricing

**Investment Comparison:**
- **Year 1 Net Investment:** $217,772 (after credits) vs. $232,772 list price
- **3-Year Total Cost of Ownership:** $536,116
- **Expected ROI:** 12-15 month payback based on $400K annual labor cost savings

## Cost Components

**Professional Services** ($73,600 - 460 hours): Labor costs for discovery, architecture, implementation, testing, and knowledge transfer. Breakdown:
- Discovery & Architecture (80 hours): Requirements analysis, platform design, playbook roadmap
- Implementation (300 hours): Platform deployment, playbook development (100 playbooks), integration setup, testing
- Training & Support (80 hours): Administrator/developer training and 30-day hypercare

**Cloud Infrastructure** ($26,520/year): AWS/Azure infrastructure for automation platform:
- Automation Controller (2 VMs, 8 vCPU 16GB each): $11,520/year
- Execution Nodes (4 VMs, 8 vCPU 16GB each): $10,800/year
- PostgreSQL Database (managed service, HA): $3,600/year
- Load Balancer and networking: $600/year
- Scales with execution node additions for capacity growth

**Software Licenses** ($115,000/year): Red Hat Ansible Automation Platform subscriptions:
- Ansible Automation Platform (500 managed nodes): $100,000/year
- Private Automation Hub: $10,000/year
- Event-Driven Ansible: $5,000/year
- Full platform subscription with Red Hat support and updates

**Support & Maintenance** ($17,652/year): Ongoing operational support:
- Monitoring tools (Datadog, PagerDuty): $5,652/year
- Platform administration support (optional managed services): $12,000/year

---

## Payment Terms

### Pricing Model
- Fixed price for professional services ($73,600)
- Time & Materials option available for scope expansions
- Milestone-based payments per Deliverables table

### Payment Schedule
- 25% upon SOW execution and project kickoff ($18,400)
- 30% upon completion of Discovery & Planning phase ($22,080)
- 30% upon completion of Implementation and Testing ($22,080)
- 15% upon successful go-live and project acceptance ($11,040)

---

## Invoicing & Expenses

### Invoicing
- Milestone-based invoicing per Payment Terms above
- Net 30 payment terms from invoice date
- Invoices submitted upon milestone completion and client acceptance

### Expenses
- Cloud infrastructure costs invoiced monthly based on actual usage ($2,210/month average)
- Software license costs billed annually by Red Hat (direct client relationship)
- Travel and on-site expenses reimbursable at cost with prior approval (remote-first delivery model)
- No markup on third-party software or cloud infrastructure costs

---

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

## Scope Changes
- Changes to managed node count, playbook count, integration scope, or timeline require formal change requests
- Change requests may impact project timeline and budget
- All change requests require written approval from both parties before implementation

## Intellectual Property
- Client retains ownership of all business data, infrastructure configurations, and automation workflows
- Vendor retains ownership of proprietary automation methodologies and frameworks
- Custom automation playbooks and platform configurations transfer to Client upon final payment
- Ansible playbook source code becomes Client property

## Service Levels
- Ansible platform availability: 99.5% uptime SLA for production controller during business hours
- 30-day warranty on all deliverables from go-live date
- Defect resolution included at no additional cost during warranty period
- Post-warranty support available under separate managed services agreement

## Liability
- Automation success rate targets apply to validated playbooks on standard infrastructure configurations
- Performance may vary with non-standard infrastructure or configurations outside testing scope
- Ongoing playbook maintenance and updates recommended as infrastructure evolves
- Liability caps as agreed in Master Services Agreement

## Confidentiality
- Both parties agree to maintain strict confidentiality of business data, infrastructure details, and proprietary automation content
- All exchanged artifacts under NDA protection
- Red Hat intellectual property protected under Red Hat licensing terms

## Termination
- Mutually terminable per MSA terms, subject to payment for completed work and expenses incurred
- Client retains ownership of all work products and deliverables completed through termination date

## Governing Law
- Agreement governed under the laws of [State/Region]
- Disputes resolved per MSA dispute resolution procedures

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
