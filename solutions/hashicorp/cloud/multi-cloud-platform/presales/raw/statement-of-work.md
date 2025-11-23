---
document_title: Statement of Work
technology_provider: HashiCorp
project_name: Multi-Cloud Platform Implementation
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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing a HashiCorp Multi-Cloud Platform for [Client Name]. This engagement will deliver unified infrastructure automation across AWS, Azure, and GCP through HashiCorp Terraform Cloud, HashiCorp Vault, and HashiCorp Consul to transform fragmented multi-cloud provisioning into intelligent, policy-driven infrastructure as code with centralized governance and security controls.

**Project Duration:** 9 months

---

---

# Background & Objectives

## Current State

[Client Name] currently manages infrastructure across AWS, Azure, and GCP using a combination of manual processes, cloud-native tools (CloudFormation, ARM templates, GCP Deployment Manager), and basic Terraform OSS. Key challenges include:
- **Fragmented Tooling:** Different infrastructure-as-code approaches per cloud creating inconsistent configurations and operational overhead
- **No Centralized Governance:** Manual policy enforcement and lack of automated compliance checks across cloud providers
- **State Management Challenges:** Distributed Terraform state files causing locking conflicts and collaboration issues
- **Security Gaps:** No centralized secrets management or dynamic credential rotation across cloud platforms
- **Manual Workflows:** Infrastructure changes requiring manual approval processes taking 3-5 days per environment
- **Compliance Risk:** No automated policy enforcement increasing audit exposure and configuration drift

## Business Objectives
- **Unify Multi-Cloud Infrastructure:** Implement HashiCorp Terraform Cloud for centralized infrastructure as code across AWS, Azure, and GCP with consistent workflows, eliminating cloud-specific tooling fragmentation
- **Automate Policy Enforcement:** Deploy Sentinel policies for automated governance, security, and cost controls enforcing compliance across all cloud environments before infrastructure changes reach production
- **Centralize Secrets Management:** Implement HashiCorp Vault for unified secrets management with dynamic cloud credentials, automated rotation, and encryption as a service across all platforms
- **Reduce Provisioning Time:** Reduce infrastructure provisioning time by 75% through self-service capabilities and automated approval workflows improving time-to-market
- **Lower Operational Costs:** Reduce infrastructure operations costs by 60% through automation and policy-driven cost governance freeing teams from manual configuration and compliance checks
- **Enable Service Mesh:** Deploy HashiCorp Consul service mesh for secure cross-cloud service discovery and communication enabling future hybrid and multi-cloud application architectures

## Success Metrics
- 75%+ reduction in infrastructure provisioning time (from baseline 5-7 days to 1-2 days)
- 95%+ policy compliance rate across all cloud environments measured monthly
- 60% reduction in infrastructure operations costs within 18 months
- Migrate 100+ Terraform workspaces to centralized platform
- Zero security incidents from misconfigured infrastructure
- 99.9% platform uptime for Terraform Cloud and Vault

---

---

# Scope of Work

## In Scope
The following services and deliverables are included in this SOW:
- Multi-cloud infrastructure assessment and HashiCorp platform design
- Terraform Cloud deployment and workspace migration strategy
- HashiCorp Vault implementation for secrets management
- HashiCorp Consul deployment for service mesh (optional Phase 3)
- Sentinel policy development for governance and compliance
- VCS integration with GitHub for GitOps workflows
- Migration of existing Terraform workspaces and state files
- Integration with CI/CD pipelines and monitoring systems
- Testing, validation, and policy compliance verification
- Knowledge transfer and operational documentation

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Managed Cloud Providers | 3 clouds (AWS Azure GCP) |
| Solution Scope | Infrastructure Resources | 2500 total resources |
| Solution Scope | Terraform Workspaces | 100 workspaces |
| Integration | External System Integrations | 4 integrations (GitHub Datadog Slack ServiceNow) |
| Integration | VCS Platform | GitHub |
| User Base | Total Platform Users | 50 users |
| User Base | User Roles | 5 roles (viewer operator admin security auditor) |
| Data Volume | Concurrent Infrastructure Runs | 15 concurrent runs |
| Data Volume | State Storage Volume | 2 TB |
| Technical Environment | Deployment Regions | Multi-region (us-east-1 eu-west-1 ap-southeast-1) |
| Technical Environment | Availability Requirements | High (99.9%) |
| Technical Environment | Infrastructure Complexity | Multi-cloud with networking |
| Security & Compliance | Security Requirements | Enterprise (Vault SSO RBAC) |
| Security & Compliance | Compliance Frameworks | SOC2 ISO27001 |
| Performance | Policy Governance | 50 Sentinel policies |
| Performance | Processing Mode | Self-service with approvals |
| Environment | Deployment Environments | 3 environments (dev staging prod) |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*


## Activities

### Phase 1 – Foundation & Migration
During this initial phase, the Vendor will deploy Terraform Cloud, implement Vault for secrets management, and migrate the first wave of Terraform workspaces from local/OSS to the centralized platform. This includes establishing RBAC, VCS integration, and foundational workflows.

Key activities:
- Multi-cloud infrastructure assessment and current state documentation
- Terraform Cloud deployment on Kubernetes (EKS) with high availability configuration
- HashiCorp Vault deployment with auto-unseal and PostgreSQL backend
- VCS integration with GitHub for automated Terraform runs
- RBAC implementation for workspace access control
- Migration of 25 pilot workspaces from Terraform OSS to Terraform Cloud
- Remote state migration from S3/local to Terraform Cloud backend
- Workspace organization strategy and naming conventions
- Cost estimation integration for infrastructure changes
- CloudWatch monitoring and alerting setup

This phase concludes with a functional Terraform Cloud platform processing automated infrastructure runs via VCS webhooks with centralized state management and 25 migrated workspaces validating the platform approach.

### Phase 2 – Expansion & Governance
In this phase, the platform is expanded to support 100+ workspaces across all cloud environments. Sentinel policies are developed and deployed for security, compliance, and cost governance. Integration with CI/CD pipelines enables automated infrastructure deployment.

Key activities:
- Workspace migration expansion to 100+ total workspaces across AWS, Azure, GCP
- Sentinel policy development for security controls (network rules, encryption, IAM)
- Sentinel policy development for cost governance (resource sizing, tagging enforcement)
- Sentinel policy development for compliance frameworks (SOC2, ISO27001)
- HashiCorp Vault integration for dynamic cloud credentials (AWS, Azure, GCP)
- CI/CD pipeline integration (GitHub Actions, Jenkins, etc.)
- Private module registry setup for infrastructure code reusability
- Self-service provisioning workflows with approval gates
- API integration with ServiceNow for change management
- Drift detection and remediation automation

By the end of this phase, the Client will have comprehensive policy enforcement across all cloud environments with self-service infrastructure provisioning capabilities and full CI/CD integration.

### Phase 3 – Optimization & Service Mesh
Implementation will expand to include HashiCorp Consul for service mesh capabilities enabling secure cross-cloud service discovery and communication. Advanced automation features including drift remediation and scheduled runs are enabled.

Key activities:
- HashiCorp Consul deployment for service mesh across cloud environments
- Service discovery configuration for cross-cloud application communication
- Consul Connect for encrypted service-to-service communication
- Advanced automation features (drift detection, scheduled runs, notifications)
- Performance optimization and cost analysis
- Monitoring dashboard customization for business KPIs
- Operational runbook development
- Knowledge transfer sessions for platform administrators
- Documentation delivery and training completion
- 30-day hypercare support and optimization

After each phase, the Vendor will coordinate validation and sign-off with the Client before proceeding.

### Phase 4 – Training & Handover
Following successful implementation, the focus shifts to ensuring operational continuity and knowledge transfer. The Vendor will provide hypercare support and equip the Client's team with documentation, tools, and processes needed for ongoing platform management.

Activities include:
- Delivery of as-built documentation (architecture diagrams, configurations, policies)
- Operations runbook and SOPs for day-to-day platform management
- HashiCorp platform management training (Terraform Cloud, Vault, Consul)
- Sentinel policy development and maintenance training
- Live or recorded knowledge transfer sessions for administrators and users
- Performance optimization recommendations
- 30-day warranty support for issue resolution
- Optional transition to a managed services model for ongoing support, if contracted

---

## Out of Scope

These items are not in scope unless added via change control:
- Cloud provider account setup or billing management
- Application code development or refactoring
- Legacy infrastructure decommissioning or migration
- Historical infrastructure audit or compliance remediation
- Ongoing operational support beyond 30-day warranty period
- Custom Terraform provider development
- Infrastructure provisioning beyond scope parameters (additional clouds, regions)
- End-user training beyond platform administrator knowledge transfer
- Cloud service costs (billed directly by AWS, Azure, GCP to client)
- HashiCorp license costs (billed directly by HashiCorp or reseller to client)

---

---

# Deliverables & Timeline

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | Requirements Specification | Document/CSV | Month 1 | [Client Lead] |
| 2 | Multi-Cloud Platform Architecture | Document | Month 1 | [Technical Lead] |
| 3 | Implementation Plan | Project Plan | Month 1 | [Project Sponsor] |
| 4 | Terraform Cloud Platform | System | Month 3 | [Technical Lead] |
| 5 | HashiCorp Vault Deployment | System | Month 3 | [Security Lead] |
| 6 | Sentinel Policy Library | System | Month 6 | [Compliance Lead] |
| 7 | Migrated Workspaces (100+) | System | Month 6 | [Infrastructure Lead] |
| 8 | Consul Service Mesh | System | Month 9 | [Technical Lead] |
| 9 | Test Plan & Results | Document | Month 8 | [QA Lead] |
| 10 | User Training Materials | Document/Video | Month 9 | [Training Lead] |
| 11 | Operations Runbook | Document | Month 9 | [Ops Lead] |
| 12 | As-Built Documentation | Document | Month 9 | [Client Lead] |
| 13 | Knowledge Transfer Sessions | Training | Month 9 | [Client Team] |

---

## Project Milestones

<!-- TABLE_CONFIG: widths=[20, 50, 30] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 | Assessment Complete | Month 1 |
| M2 | Terraform Cloud Operational | Month 3 |
| M3 | 25 Workspaces Migrated | Month 3 |
| M4 | Vault Integration Complete | Month 4 |
| M5 | Sentinel Policies Deployed | Month 6 |
| M6 | 100 Workspaces Migrated | Month 6 |
| M7 | Consul Service Mesh Live | Month 9 |
| Go-Live | Full Platform Operational | Month 9 |
| Hypercare End | Support Period Complete | Month 10 |

---

---

# Roles & Responsibilities

This section outlines the roles and responsibilities for both the Vendor and Client teams throughout the HashiCorp Multi-Cloud Platform implementation. Clear accountability ensures effective collaboration and successful project delivery.

## RACI Matrix

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO Sales Eng | EO Eng (DevOps) | Client IT | Client Security | SME |
|-----------|-------|----------------|--------------|-----------------|-----------|-----------------|-----|
| Discovery & Requirements | A | R | R | C | C | C | C |
| Solution Architecture | C | A | R | I | I | C | I |
| Platform Deployment | C | A | C | R | C | I | I |
| Vault Implementation | C | R | C | A | C | A | I |
| Policy Development | C | R | R | A | I | A | I |
| Workspace Migration | C | R | C | A | C | I | A |
| Testing & Validation | R | C | R | R | A | A | I |
| Security Configuration | C | R | I | A | I | A | I |
| Knowledge Transfer | A | R | R | R | C | C | I |
| Hypercare Support | A | R | R | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- EO Project Manager: Overall delivery accountability and stakeholder management
- EO Quarterback: Technical design oversight and HashiCorp architecture
- EO Sales Engineer: Solution architecture and pre-sales support
- EO Engineer (DevOps): HashiCorp platform deployment, policy development, and automation

**Client Team:**
- IT Lead: Primary technical contact and cloud infrastructure access management
- Security Lead: Security requirements definition and Vault integration sign-off
- Infrastructure Team: Workspace migration support and operational knowledge transfer
- Operations Team: Platform management and ongoing administration

---

---

# Architecture & Design

## Architecture Overview
The HashiCorp Multi-Cloud Platform solution is designed as a **centralized, policy-driven infrastructure automation platform** leveraging HashiCorp Terraform Cloud, Vault, and Consul. The architecture provides unified multi-cloud provisioning, enterprise-grade security, and automated governance for infrastructure as code workflows.

This architecture is designed for **medium-scope deployment** supporting 100 workspaces and 50 users across 3 cloud providers (AWS, Azure, GCP). The design prioritizes:
- **Unified Workflows:** Consistent infrastructure provisioning across all cloud providers
- **Policy Enforcement:** Automated governance through Sentinel before changes reach production
- **Scalability:** Can grow to large scope (250+ workspaces) by adjusting resource limits

![Figure 1: Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Solution Architecture Diagram** - High-level overview of the HashiCorp Multi-Cloud Platform architecture

## Architecture Type
The deployment follows a centralized platform architecture with distributed execution. This approach enables:
- Centralized state management eliminating locking conflicts and improving collaboration
- Policy-driven automation ensuring compliance before infrastructure changes are applied
- Self-service provisioning with approval workflows reducing operational bottlenecks
- Multi-cloud abstraction through unified Terraform workflows

Key architectural components include:
- Infrastructure Automation Layer (Terraform Cloud with workspaces and remote execution)
- Secrets Management Layer (HashiCorp Vault with dynamic credentials and encryption)
- Service Mesh Layer (HashiCorp Consul for service discovery and secure communication)
- Governance Layer (Sentinel policies for security, compliance, and cost controls)
- Integration Layer (VCS, CI/CD, monitoring, and change management systems)

## Scope Specifications

**Platform Infrastructure:**
- Terraform Cloud: Kubernetes-based deployment on AWS EKS (3 nodes, t3.xlarge)
- HashiCorp Vault: High availability deployment with auto-unseal (3 nodes)
- HashiCorp Consul: Service mesh deployment across cloud environments
- PostgreSQL: RDS instance for Terraform state and Vault backend (db.t3.large)

**Multi-Cloud Coverage:**
- AWS: VPC, EC2, RDS, EKS, S3, IAM provisioning
- Azure: Virtual Networks, VMs, AKS, Storage, RBAC provisioning
- GCP: VPC, Compute Engine, GKE, Cloud Storage, IAM provisioning
- 3 deployment regions across clouds (us-east-1, eu-west-1, ap-southeast-1)

**Workspaces & Users:**
- 100 Terraform workspaces across development, staging, production environments
- 50 platform users with role-based access control
- 5 user roles (viewer, operator, admin, security, auditor)
- 15 concurrent Terraform runs supported

**Governance & Policy:**
- 50 Sentinel policies for security, compliance, and cost governance
- Policy sets organized by framework (SOC2, ISO27001)
- Automated policy enforcement on all infrastructure changes
- Cost estimation and approval workflows for changes above thresholds

**Scalability Path:**
- Medium scope: Current configuration supports 100 workspaces, 50 users
- Large scope: Scale to 250+ workspaces by increasing Kubernetes nodes and RDS instance
- No architectural changes required - only resource scaling

## Application Hosting
All platform components will be hosted on AWS infrastructure:
- Terraform Cloud on Amazon EKS for high availability and scalability
- HashiCorp Vault on EC2 instances with auto-unseal via AWS KMS
- PostgreSQL backend on Amazon RDS with automated backups
- HashiCorp Consul on EKS for service mesh capabilities
- Application Load Balancer for high availability and TLS termination

All services are deployed using infrastructure-as-code (Terraform).

## Networking
The networking architecture follows HashiCorp best practices for multi-cloud platforms:
- VPC deployment with private subnets for platform components
- VPN or Direct Connect for secure connectivity to Azure and GCP
- VPC endpoints for private AWS service access (S3, KMS, CloudWatch)
- Network policies for pod-to-pod communication in EKS
- TLS encryption for all platform communication
- HashiCorp Consul service mesh for encrypted service-to-service communication

## Observability
Comprehensive observability ensures operational excellence:
- CloudWatch Logs for centralized logging from all platform components
- CloudWatch Metrics for platform health, workspace runs, policy enforcement
- Datadog integration for advanced monitoring and alerting
- Terraform Cloud audit logging for all infrastructure changes
- HashiCorp Vault audit logging for all secrets access
- Custom dashboards showing business KPIs (workspaces, runs, policy compliance, costs)

## Backup & Disaster Recovery
All critical data and configurations are protected through:
- RDS automated backups with 7-day retention for Terraform state
- HashiCorp Vault auto-unseal with encrypted snapshots
- Terraform Cloud workspace backup via API automation
- Cross-region replication for disaster recovery
- RTO: 4 hours | RPO: 1 hour

---

## Technical Implementation Strategy

The implementation approach follows HashiCorp best practices and proven methodologies for multi-cloud platform deployments.

## Example Implementation Patterns
- Phased workspace migration: Pilot with 25 workspaces, validate, then expand to 100+
- Parallel operation: Run Terraform Cloud alongside existing OSS during transition
- Progressive policy enforcement: Start with advisory policies, transition to mandatory
- Iterative optimization: Continuous improvement based on platform usage patterns

## Tooling Overview

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|-----------------------|------------------------------|-------------------------------|
| Infrastructure | Terraform, Kubernetes, EKS | Platform hosting and orchestration |
| HashiCorp Stack | Terraform Cloud, Vault, Consul | Multi-cloud automation, secrets, service mesh |
| Version Control | GitHub Enterprise | GitOps workflows and collaboration |
| Monitoring | CloudWatch, Datadog | Centralized logging, metrics, alerting |
| CI/CD | GitHub Actions, Jenkins | Automated deployment pipelines |
| Security | Vault, KMS, Sentinel | Secrets management, encryption, policy enforcement |
| Change Management | ServiceNow | Integration for approval workflows |

---

## Data Management

### Data Strategy
- Centralized Terraform state storage in Terraform Cloud with encryption
- State locking and consistency guarantees eliminating conflicts
- Workspace isolation with granular RBAC for state access
- State versioning and rollback capabilities
- Terraform Cloud API for programmatic state management and reporting

### Data Security & Compliance
- Encryption enabled for state data at-rest using AWS KMS
- TLS encryption for all state data in-transit
- HashiCorp Vault for secrets encryption and dynamic credentials
- Sensitive variable masking in Terraform Cloud logs
- Audit trail for all state access via Terraform Cloud and CloudTrail
- Compliance controls for SOC2 and ISO27001 frameworks

---

---

# Security & Compliance

The implementation and target environment will be architected and validated to meet the Client's security, compliance, and governance requirements. Vendor will adhere to industry-standard security frameworks and HashiCorp platform best practices.

## Identity & Access Management
- Role-based access control (RBAC) for all Terraform Cloud workspaces
- Integration with SSO/SAML for centralized authentication
- HashiCorp Vault dynamic credentials for cloud provider access (AWS, Azure, GCP)
- Multi-factor authentication (MFA) required for platform access
- Principle of least privilege for all platform users and service accounts
- API token management with expiration and rotation policies

## Monitoring & Threat Detection
- Comprehensive audit logging in Terraform Cloud for all infrastructure changes
- HashiCorp Vault audit logs for all secrets access and authentication
- CloudWatch monitoring for platform health and security metrics
- Integration with SIEM systems for security event correlation
- Automated alerts for policy violations and unauthorized access attempts
- Drift detection for infrastructure configuration compliance

## Compliance & Auditing
- SOC2 compliance: HashiCorp products are SOC2 certified, platform architecture follows SOC2 principles
- ISO27001 compliance: Security controls aligned with ISO27001 framework requirements
- Sentinel policies enforcing regulatory compliance requirements
- Continuous compliance monitoring through automated policy enforcement
- Audit trail preservation for all infrastructure changes (minimum 1 year retention)

## Encryption & Key Management
- All Terraform state encrypted at rest using AWS KMS customer-managed keys
- All platform communication encrypted in transit using TLS 1.3
- HashiCorp Vault encryption as a service for application secrets
- Vault auto-unseal using AWS KMS for secure initialization
- Encryption key rotation policies implemented and automated
- Secure key management using AWS KMS with audit logging via CloudTrail

## Governance
- Sentinel policies enforcing infrastructure standards across all cloud providers
- Mandatory policy checks before infrastructure changes are applied
- Cost governance policies preventing resource over-provisioning
- Workspace approval workflows for production environment changes
- Quarterly access reviews for RBAC and workspace permissions
- Incident response procedures for security events and policy violations
- Resource tagging enforcement for cost allocation and compliance tracking

---

## Environments & Access

### Environment Strategy

The HashiCorp Multi-Cloud Platform will support three primary workspace environments aligned with the Client's SDLC processes. Each environment has distinct access controls and approval requirements to ensure appropriate governance and change management.

| Environment | Purpose | Cloud Coverage | Access |
|-------------|---------|----------------|--------|
| Development | Infrastructure experimentation and module development | AWS, Azure, GCP | Development team, automated runs |
| Staging | Pre-production validation, integration testing | AWS, Azure, GCP | Project team, testers, automated runs |
| Production | Live infrastructure provisioning | AWS, Azure, GCP | Operations team, approval-gated runs |

### Access Policies
- Single Sign-On (SSO) via SAML for all Terraform Cloud access
- Multi-factor authentication (MFA) required for all users
- API access via team tokens with automatic expiration
- Administrator Access: Full platform administration for Vendor during implementation
- Workspace Manager: Create and manage workspaces, modify settings
- Workspace Operator: Trigger runs, apply changes within assigned workspaces
- Viewer: Read-only access to workspace runs and state (no apply capability)
- HashiCorp Vault dynamic credentials for automated cloud provider access

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the implementation lifecycle to ensure functionality, performance, security, and policy compliance of the HashiCorp Multi-Cloud Platform.

## Functional Validation
- End-to-end workspace execution across all cloud providers (AWS, Azure, GCP)
- VCS-triggered run validation via GitHub webhooks
- Sentinel policy enforcement testing across all policy sets
- HashiCorp Vault dynamic credential generation and rotation validation
- Approval workflow testing for production workspace changes
- Private module registry functionality and version management
- Cost estimation accuracy for infrastructure changes

## Performance & Load Testing
- Concurrent run capacity testing (15 simultaneous runs)
- State locking and consistency validation under concurrent access
- Workspace migration performance benchmarking
- Platform response time for API operations
- HashiCorp Vault performance under load

## Security Testing
- RBAC validation across all user roles and workspace permissions
- Vault dynamic credential security and rotation testing
- TLS encryption verification for all platform communication
- Sentinel policy bypass prevention testing
- Audit log completeness and integrity validation
- Penetration testing of platform infrastructure (optional)

## Policy Compliance Testing
- Sentinel policy effectiveness testing across security, cost, and compliance domains
- Policy violation detection and enforcement validation
- Compliance framework alignment verification (SOC2, ISO27001)
- Cost governance policy accuracy testing
- Tagging enforcement validation

## Multi-Cloud Integration Testing
- Infrastructure provisioning validation across AWS, Azure, GCP
- Cross-cloud networking and Consul service mesh connectivity
- Cloud provider credential rotation and dynamic generation
- Region-specific deployment validation
- Integration with cloud-native services (IAM, RBAC, networking)

## User Acceptance Testing (UAT)
- Performed in coordination with Client infrastructure and security teams
- Test workspaces and sample Terraform configurations provided by Vendor
- Policy compliance validation against business-defined acceptance criteria
- Integration testing with CI/CD and change management systems

## Go-Live Readiness
A Go-Live Readiness Checklist will be delivered including:
- Security and compliance sign-offs
- Policy enforcement validation completion
- Performance testing completion (15 concurrent runs)
- Integration testing completion (VCS, CI/CD, monitoring)
- 100 workspace migration completion
- Issue log closure (all critical/high issues resolved)
- Training completion and documentation delivery

---

## Cutover Plan

The cutover to the HashiCorp Multi-Cloud Platform will be executed using a phased workspace migration approach to minimize business disruption and ensure seamless transition from Terraform OSS or cloud-native tooling. The migration will occur in waves with validation gates between phases.

**Cutover Approach:**

The implementation follows a **progressive migration** strategy where workspaces are migrated in waves while existing tools remain operational during transition. This approach allows for:

1. **Pilot Wave (Weeks 1-2):** Migrate 25 non-production workspaces to Terraform Cloud for validation. Monitor state migration, run execution, and policy enforcement with zero impact to production infrastructure. Gather feedback and refine migration process.

2. **Expansion Wave (Weeks 3-6):** Progressively migrate additional workspaces across all environments:
   - Week 3-4: 50 development and staging workspaces (cumulative: 75 total)
   - Week 5-6: 25 production workspaces with approval gates (cumulative: 100 total)
   - Parallel operation: Existing Terraform OSS processes remain available as fallback

3. **Production Cutover (Week 7-8):** Full platform operational across all cloud providers:
   - All 100 workspaces migrated and operational
   - Sentinel policies enforced across all environments
   - Vault integration complete for dynamic credentials
   - VCS-driven workflows fully automated
   - Legacy Terraform OSS processes decommissioned

4. **Hypercare Period (4 weeks post-cutover):** Daily monitoring, rapid issue resolution, and optimization to ensure stable operations.

The cutover will be coordinated with Client infrastructure teams with documented rollback procedures available for each migration wave if critical issues arise.

## Cutover Checklist
- Pre-migration validation: Workspace inventory, state file integrity checks
- Terraform Cloud platform validated and monitoring operational
- Vault integration tested with dynamic credential generation
- Rollback procedures documented and rehearsed for each workspace wave
- Stakeholder communication completed for migration schedule
- Execute pilot wave migration (25 workspaces)
- Monitor pilot workspace runs for 1 week minimum before expansion
- Execute expansion wave migration (75 additional workspaces)
- Verify policy enforcement and approval workflows
- Daily monitoring during hypercare period (4 weeks)

## Rollback Strategy
- Documented rollback triggers (persistent run failures, state corruption, security incident)
- Rollback procedures: Restore Terraform OSS state files, revert to local/S3 backend
- Root cause analysis and platform fixes before retry
- Communication plan for stakeholders on rollback events
- Preserve all Terraform Cloud state versions and audit logs for analysis

---

---

# Handover & Support

## Handover Artifacts
- As-built documentation including architecture diagrams, platform configurations, and network topology
- Sentinel policy library with documentation on policy logic and enforcement rules
- Workspace organization documentation with naming conventions and RBAC model
- Operations runbook with troubleshooting procedures for common platform issues
- HashiCorp platform administration guides (Terraform Cloud, Vault, Consul)
- Monitoring and alert configuration reference with escalation procedures
- Multi-cloud cost optimization recommendations based on platform usage data
- Integration documentation for VCS, CI/CD, monitoring, and change management systems

## Knowledge Transfer
- Live knowledge transfer sessions for platform administrators and DevOps teams (3 full-day sessions)
- HashiCorp Terraform Cloud administration training with workspace management, RBAC, and monitoring
- HashiCorp Vault administration training covering secrets engines, dynamic credentials, and policies
- Sentinel policy development training with hands-on exercises
- Recorded training materials hosted in client documentation portal
- Documentation portal with searchable content and platform runbooks

## Hypercare Support

Post-implementation support to ensure smooth transition to Client operations:

**Duration:** 30 days post-go-live

**Coverage:**
- Business hours support (8 AM - 6 PM EST, Monday-Friday)
- 4-hour response time for critical platform issues
- Daily health check calls (first 2 weeks)
- Weekly status meetings throughout hypercare period

**Scope:**
- Platform issue investigation and resolution
- Workspace migration assistance for stragglers
- Performance tuning and optimization
- Sentinel policy adjustments based on operational feedback
- Configuration troubleshooting and guidance
- Knowledge transfer continuation

## Managed Services Transition (Optional)

Post-hypercare, Client may transition to ongoing managed services:

**Managed Services Options:**
- 24/7 platform monitoring and support for Terraform Cloud, Vault, Consul
- Proactive optimization and cost management recommendations
- Sentinel policy updates and new policy development
- Platform scaling and capacity management
- Monthly platform performance and cost optimization reviews
- HashiCorp version upgrades and patch management

**Transition Approach:**
- Evaluation of managed services requirements during hypercare
- Service Level Agreement (SLA) definition for platform availability
- Separate managed services contract and pricing
- Seamless transition from hypercare to managed services

---

## Assumptions

### General Assumptions
- Client will provide access to AWS, Azure, GCP environments with appropriate permissions for platform deployment
- Existing Terraform code is compatible with Terraform Cloud (OSS versions 0.12+)
- Client technical team will be available for requirements validation, workspace migration support, and approvals
- GitHub Enterprise or GitHub.com access and appropriate repository permissions will be provided
- Network connectivity between on-premises systems and cloud platforms meets platform requirements
- Security and compliance approval processes will not delay critical path activities
- Client will handle HashiCorp license procurement directly with HashiCorp or authorized reseller
- Cloud infrastructure costs will be handled by Client directly with AWS, Azure, GCP

---

## Dependencies

### Project Dependencies
- Cloud Access: Client provides AWS, Azure, GCP account access with appropriate permissions for Terraform, Vault, Consul deployment
- Terraform Code: Client provides existing Terraform configurations and state files for migration assessment
- VCS Access: GitHub repository access and webhook configuration permissions
- Kubernetes Cluster: EKS cluster provisioned or access for Vendor to deploy (if not existing)
- Network Connectivity: VPN or Direct Connect established for multi-cloud access if required
- SME Availability: Infrastructure and security teams available for requirements clarification and policy validation
- Security Approvals: Security and compliance approvals obtained on schedule to avoid implementation delays
- HashiCorp Licenses: Terraform Cloud, Vault, Consul licenses procured and activated
- Change Freeze: No major changes to cloud infrastructure or IAM policies during migration phases
- Go-Live Approval: Business and technical approval authority available for production workspace migration

---

---

# Investment Summary

**Medium Scope Implementation:** This pricing reflects an enterprise deployment designed for 100 Terraform workspaces across 3 cloud providers (AWS, Azure, GCP) with 50 platform users and comprehensive governance. For smaller department-level or larger enterprise deployments, please request small or large scope pricing.

## Total Investment

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 18, 14, 12, 11, 13] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $165,000 | $0 | $165,000 | $0 | $0 | $165,000 |
| Cloud Infrastructure | $47,918 | ($12,700) | $35,218 | $47,918 | $47,918 | $131,054 |
| HashiCorp Licenses | $71,250 | ($15,000) | $56,250 | $71,250 | $71,250 | $198,750 |
| Software Licenses | $18,360 | $0 | $18,360 | $18,360 | $18,360 | $55,080 |
| Support & Maintenance | $84,900 | $0 | $84,900 | $84,900 | $84,900 | $254,700 |
| **TOTAL INVESTMENT** | **$387,428** | **($27,700)** | **$359,728** | **$222,428** | **$222,428** | **$804,584** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $27,700 (8% reduction)
- **AWS Services Credit:** $12,700 applied to EKS, RDS, and infrastructure costs
- **HashiCorp Partner Services Credit:** $15,000 applied to professional services
- Credits are real account credits, automatically applied as services are consumed
- Credits are Year 1 only; Years 2-3 reflect standard pricing

**Investment Comparison:**
- **Year 1 Net Investment:** $359,728 (after credits) vs. $387,428 list price
- **3-Year Total Cost of Ownership:** $804,584
- **Expected ROI:** 16-18 month payback based on typical infrastructure operations cost savings from automation

## Cost Components

**Professional Services** ($165,000 - 620 hours): Labor costs for assessment, architecture, implementation, testing, and knowledge transfer. Breakdown:
- Discovery & Architecture (120 hours): Multi-cloud assessment, HashiCorp platform design, documentation
- Implementation (440 hours): Platform deployment, workspace migration, policy development, integration, testing
- Training & Support (60 hours): Knowledge transfer and 30-day post-launch hypercare

**Cloud Infrastructure** ($47,918/year): AWS infrastructure hosting for HashiCorp platform sized for medium scope (100 workspaces):
- Amazon EKS cluster for Terraform Cloud (3 nodes, t3.xlarge): $15,768/year
- Amazon RDS PostgreSQL for state backend (db.t3.large): $10,950/year
- HashiCorp Vault EC2 instances (3 nodes, t3.medium): $7,884/year
- Networking, storage, KMS, backups: $13,316/year
- Scales with workspace count and concurrent run requirements

**HashiCorp Licenses** ($71,250/year): HashiCorp product licensing sized for medium scope:
- Terraform Cloud Business (50 users @ $85/user/month): $51,000/year
- HashiCorp Vault Plus (3 clusters @ $4,500/cluster/year): $13,500/year
- HashiCorp Consul Enterprise (8 nodes @ $850/node/year): $6,750/year

**Software Licenses & Subscriptions** ($18,360/year): Operational tooling for medium scope:
- Datadog monitoring (15 hosts): $10,800/year
- PagerDuty incident management (5 users): $3,540/year
- Slack notifications integration: $420/year
- Backup and monitoring tools: $3,600/year

**Support & Maintenance** ($84,900/year): Ongoing managed services (15% of infrastructure + licenses):
- Business hours monitoring and platform health checks
- Monthly cost optimization reviews and recommendations
- HashiCorp platform updates and patch management
- Incident response and troubleshooting support

---

## Payment Terms

### Pricing Model
- Fixed price for professional services ($165,000)
- Infrastructure and licensing costs at actuals

### Payment Schedule
- 25% upon SOW execution and project kickoff
- 30% upon completion of Foundation & Migration phase (Month 3)
- 30% upon completion of Expansion & Governance phase (Month 6)
- 15% upon successful go-live and project acceptance (Month 9)

---

## Invoicing & Expenses

### Invoicing
- Milestone-based invoicing per Payment Terms above
- Net 30 payment terms
- Invoices submitted upon milestone completion and acceptance

### Expenses
- AWS service costs are included in Cloud Infrastructure pricing ($47,918/year = ~$3,993/month)
- HashiCorp licenses included in HashiCorp Licenses pricing ($71,250/year = ~$5,938/month)
- Medium scope sizing: 100 workspaces, 50 users, 3 cloud providers
- Costs scale with actual usage - can increase/decrease based on workspace count
- Travel and on-site expenses reimbursable at cost with prior approval (remote-first delivery model)

---

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

## Scope Changes
- Changes to workspace count, cloud providers, policy requirements, or timeline require formal change requests
- Change requests may impact project timeline and budget

## Intellectual Property
- Client retains ownership of all Terraform configurations, infrastructure code, and business data
- Vendor retains ownership of proprietary HashiCorp implementation methodologies and frameworks
- Sentinel policies and platform configurations become Client property upon final payment
- HashiCorp platform infrastructure code transfers to Client

## Service Levels
- Platform uptime: 99.9% measured monthly
- 30-day warranty on all deliverables from go-live date
- Post-warranty support available under separate managed services agreement

## Liability
- Performance guarantees apply only to platform components within Vendor control
- HashiCorp product functionality and availability governed by HashiCorp SLAs
- Liability caps as agreed in MSA

## Confidentiality
- Both parties agree to maintain strict confidentiality of business data, infrastructure configurations, and proprietary implementation methodologies
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
