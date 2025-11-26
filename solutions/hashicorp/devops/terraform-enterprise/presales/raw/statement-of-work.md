---
document_title: Statement of Work
technology_provider: HashiCorp
project_name: Terraform Enterprise Implementation
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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing HashiCorp Terraform Enterprise for [Client Name]. This engagement will deliver enterprise-grade infrastructure as code capabilities through centralized workspace management, VCS-driven workflows, and Sentinel policy enforcement to transform manual infrastructure provisioning into automated, policy-compliant infrastructure operations.

**Project Duration:** 6 months

---

---

# Background & Objectives

## Current State

[Client Name] currently uses Terraform Open Source across development teams with manual workflows, distributed state files, and inconsistent infrastructure configurations. Key challenges include:
- **Fragmented Terraform Usage:** Teams using Terraform OSS independently with no centralized collaboration or governance
- **State Management Issues:** Distributed state files in S3 causing locking conflicts and version control problems
- **No Policy Enforcement:** Manual code reviews for infrastructure changes with inconsistent security and compliance validation
- **Manual Approval Workflows:** Infrastructure changes requiring email approvals taking 3-5 days per environment
- **Configuration Drift:** No automated drift detection allowing infrastructure to diverge from code over time
- **Compliance Risk:** No automated policy enforcement increasing audit exposure and security misconfigurations

## Business Objectives

The following objectives define the key business outcomes this engagement will deliver:

- **Centralize Infrastructure as Code:** Implement Terraform Enterprise for unified workspace management with centralized state storage, eliminating locking conflicts and enabling team collaboration
- **Automate Policy Enforcement:** Deploy Sentinel policies for automated security, compliance, and cost governance enforced before infrastructure changes reach production environments
- **Enable Self-Service Provisioning:** Implement VCS-driven workflows with approval gates enabling self-service infrastructure provisioning while maintaining governance controls
- **Reduce Provisioning Time:** Reduce infrastructure provisioning time by 80% through automated workflows and GitOps integration eliminating manual approval bottlenecks
- **Lower Operational Costs:** Reduce infrastructure operations costs by 70% through automation and policy-driven governance freeing teams from manual configuration reviews
- **Ensure Compliance:** Achieve 100% policy compliance across all infrastructure changes through mandatory Sentinel policy enforcement with audit trail

## Success Metrics

The following metrics will be used to measure project success:

- 80%+ reduction in infrastructure provisioning time (from baseline 5 days to 1 day)
- 100% policy compliance rate across all infrastructure changes
- 70% reduction in infrastructure operations costs within 12 months
- Migrate 50+ Terraform workspaces to centralized platform
- Zero security incidents from misconfigured infrastructure
- 99.9% platform uptime for Terraform Enterprise

---

---

# Scope of Work

## In Scope
The following services and deliverables are included in this SOW:
- Infrastructure as code assessment and Terraform Enterprise platform design
- Terraform Enterprise deployment on Kubernetes with high availability
- Migration of existing Terraform workspaces and state files from OSS to Enterprise
- Sentinel policy development for security, compliance, and cost governance
- VCS integration with GitHub for GitOps workflows and automated runs
- Private module registry implementation for infrastructure code reusability
- HashiCorp Vault integration for secrets management and dynamic credentials
- Integration with CI/CD pipelines and monitoring systems
- Testing, validation, and policy compliance verification
- Knowledge transfer and operational documentation

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*


## Activities

### Phase 1 – Foundation & Migration
During this initial phase, the Vendor will deploy Terraform Enterprise on Kubernetes, establish VCS integration with GitHub, and migrate the first wave of Terraform workspaces from OSS to the centralized platform. This includes implementing RBAC, remote state migration, and foundational workflows.

Key activities:
- Current state Terraform usage assessment and inventory of existing workspaces
- Terraform Enterprise deployment on AWS EKS with high availability configuration
- PostgreSQL database deployment for state backend with encryption
- VCS integration with GitHub for automated Terraform runs via webhooks
- RBAC implementation for workspace access control and team management
- Migration of 50 workspaces from Terraform OSS to Terraform Enterprise
- Remote state migration from local/S3 backends to Terraform Enterprise
- Workspace organization strategy including naming conventions and team assignments
- Cost estimation integration for infrastructure change impact analysis
- CloudWatch monitoring and alerting setup for platform health

This phase concludes with a fully operational Terraform Enterprise platform processing automated infrastructure runs via VCS webhooks with 50 migrated workspaces and centralized state management.

### Phase 2 – Governance & Integration
In this phase, Sentinel policies are developed and deployed for automated security, compliance, and cost governance. HashiCorp Vault integration provides dynamic credentials, and CI/CD pipeline integration enables automated infrastructure deployment workflows.

Key activities:
- Sentinel policy development for security controls (network rules, encryption, IAM permissions)
- Sentinel policy development for cost governance (resource sizing limits, tagging enforcement)
- Sentinel policy development for compliance frameworks (SOC2, ISO27001, HIPAA if applicable)
- HashiCorp Vault integration for dynamic AWS credentials and secrets management
- Private module registry setup for Terraform module sharing and versioning
- CI/CD pipeline integration (GitHub Actions, Jenkins, GitLab CI, etc.)
- Self-service provisioning workflows with approval gates for production changes
- Drift detection configuration for infrastructure compliance monitoring
- API integration with monitoring and alerting systems
- Run notifications configuration (Slack, email, webhooks)

By the end of this phase, the Client will have comprehensive policy enforcement across all infrastructure changes with self-service provisioning capabilities and full integration with development workflows.

### Phase 3 – Optimization & Enablement
Implementation concludes with advanced automation features, performance optimization, and comprehensive knowledge transfer. Teams are trained on Terraform Enterprise operations, policy development, and best practices for infrastructure as code.

Key activities:
- Advanced automation features (scheduled runs, drift remediation, run tasks)
- Performance optimization and workspace organization refinement
- Monitoring dashboard customization for infrastructure KPIs
- Operational runbook development with troubleshooting procedures
- Administrator training on Terraform Enterprise management and operations
- Sentinel policy development training for infrastructure teams
- Module development best practices and private registry usage training
- Documentation delivery including architecture diagrams and SOPs
- 30-day hypercare support and optimization

After each phase, the Vendor will coordinate validation and sign-off with the Client before proceeding.

---

## Out of Scope

These items are not in scope unless added via change control:
- AWS account setup or billing management
- Application code development or refactoring
- Legacy infrastructure decommissioning or migration to Terraform
- Historical infrastructure audit or compliance remediation
- Ongoing operational support beyond 30-day warranty period
- Custom Terraform provider development for proprietary systems
- Infrastructure provisioning beyond scope parameters (additional AWS accounts, regions)
- End-user training beyond platform administrator and infrastructure team knowledge transfer
- AWS service costs (billed directly by AWS to client)
- HashiCorp Terraform Enterprise license costs (billed directly by HashiCorp or reseller to client)

---

---

# Deliverables & Timeline

## Deliverables

The following table summarizes the key deliverables for this engagement:

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | Requirements Specification | Document/CSV | Month 1 | [Client Lead] |
| 2 | Terraform Enterprise Architecture | Document | Month 1 | [Technical Lead] |
| 3 | Implementation Plan | Project Plan | Month 1 | [Project Sponsor] |
| 4 | Terraform Enterprise Platform | System | Month 2 | [Technical Lead] |
| 5 | Migrated Workspaces (50) | System | Month 3 | [Infrastructure Lead] |
| 6 | Sentinel Policy Library | System | Month 4 | [Compliance Lead] |
| 7 | Vault Integration | System | Month 4 | [Security Lead] |
| 8 | Private Module Registry | System | Month 5 | [DevOps Lead] |
| 9 | Test Plan & Results | Document | Month 5 | [QA Lead] |
| 10 | User Training Materials | Document/Video | Month 6 | [Training Lead] |
| 11 | Operations Runbook | Document | Month 6 | [Ops Lead] |
| 12 | As-Built Documentation | Document | Month 6 | [Client Lead] |
| 13 | Knowledge Transfer Sessions | Training | Month 6 | [Client Team] |

---

## Project Milestones

The following milestones represent key checkpoints throughout the project lifecycle:

<!-- TABLE_CONFIG: widths=[20, 50, 30] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 | Assessment Complete | Month 1 |
| M2 | Terraform Enterprise Operational | Month 2 |
| M3 | 50 Workspaces Migrated | Month 3 |
| M4 | Sentinel Policies Deployed | Month 4 |
| M5 | Vault Integration Complete | Month 4 |
| M6 | Private Registry Operational | Month 5 |
| Go-Live | Full Platform Operational | Month 6 |
| Hypercare End | Support Period Complete | Month 7 |

---

---

# Roles & Responsibilities

This section outlines the roles and responsibilities for both the Vendor and Client teams throughout the HashiCorp Terraform Enterprise implementation. Clear accountability ensures effective collaboration and successful project delivery.

## RACI Matrix

The following matrix defines the responsibility assignments for key project activities:

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO Sales Eng | EO Eng (DevOps) | Client IT | Client Security | SME |
|-----------|-------|----------------|--------------|-----------------|-----------|-----------------|-----|
| Discovery & Requirements | A | R | R | C | C | C | C |
| Solution Architecture | C | A | R | I | I | C | I |
| Platform Deployment | C | A | C | R | C | I | I |
| Workspace Migration | C | R | C | A | C | I | A |
| Policy Development | C | R | R | A | I | A | I |
| Vault Integration | C | R | C | A | C | A | I |
| Testing & Validation | R | C | R | R | A | A | I |
| Security Configuration | C | R | I | A | I | A | I |
| Knowledge Transfer | A | R | R | R | C | C | I |
| Hypercare Support | A | R | R | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

The following personnel will be assigned to this engagement:

**Vendor Team:**
- EO Project Manager: Overall delivery accountability and stakeholder management
- EO Quarterback: Technical design oversight and Terraform Enterprise architecture
- EO Sales Engineer: Solution architecture and pre-sales support
- EO Engineer (DevOps): Terraform Enterprise deployment, policy development, and automation

**Client Team:**
- IT Lead: Primary technical contact and AWS infrastructure access management
- Security Lead: Security requirements definition and Vault integration sign-off
- Infrastructure Team: Workspace migration support and operational knowledge transfer
- Operations Team: Platform management and ongoing administration

---

---

# Architecture & Design

## Architecture Overview
The HashiCorp Terraform Enterprise solution is designed as a **centralized, enterprise-grade infrastructure as code platform** providing workspace management, VCS-driven automation, and policy enforcement. The architecture delivers scalability, high availability, and comprehensive governance for Terraform workflows across the organization.

This architecture is designed for **small-scope deployment** supporting 50 workspaces and 25 users managing AWS infrastructure. The design prioritizes:
- **Centralized Collaboration:** Unified workspace management eliminating state file conflicts
- **Policy-Driven Governance:** Automated Sentinel enforcement before infrastructure changes
- **Scalability:** Can grow to medium scope (100+ workspaces) by adjusting resource limits

![Figure 1: Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Solution Architecture Diagram** - High-level overview of the HashiCorp Terraform Enterprise architecture

## Architecture Type
The deployment follows a centralized platform architecture with remote execution. This approach enables:
- Centralized state management eliminating locking conflicts and enabling collaboration
- VCS-driven automation triggering Terraform runs on code commits
- Policy enforcement ensuring compliance before infrastructure changes are applied
- Self-service provisioning with approval workflows for production environments

Key architectural components include:
- Workspace Management Layer (Terraform Enterprise with remote execution and state storage)
- Policy Enforcement Layer (Sentinel policies for security, compliance, and cost controls)
- Secrets Management Layer (HashiCorp Vault integration for dynamic credentials)
- Version Control Integration (GitHub webhooks for GitOps workflows)
- Module Registry (Private module registry for infrastructure code reusability)

## Scope Specifications

This engagement is scoped according to the following specifications:

**Platform Infrastructure:**
- Terraform Enterprise: Kubernetes-based deployment on AWS EKS (3 nodes, t3.large)
- PostgreSQL: RDS instance for state backend with encryption (db.t3.medium)
- HashiCorp Vault: Integration with existing Vault deployment or new deployment
- Load Balancer: Application Load Balancer for high availability and TLS termination

**Workspace Coverage:**
- 50 Terraform workspaces across AWS infrastructure
- Development, staging, and production environment workspaces
- 25 platform users with role-based access control
- 5 user roles (viewer, plan-only, operator, admin, security-reviewer)
- 10 concurrent Terraform runs supported

**Policy & Governance:**
- 40 Sentinel policies for security, compliance, and cost governance
- Policy sets organized by environment (dev, staging, prod) and framework (SOC2)
- Mandatory policy enforcement on production workspaces
- Advisory policies on development workspaces for learning
- Cost estimation with approval thresholds for production changes

**AWS Integration:**
- AWS account coverage: Single AWS account with multiple VPCs or organization with member accounts
- Deployment regions: Primary region (us-east-1) with optional secondary region
- AWS services: VPC, EC2, RDS, EKS, S3, IAM, Lambda, and other managed services
- Dynamic AWS credentials via HashiCorp Vault integration

**Scalability Path:**
- Small scope: Current configuration supports 50 workspaces, 25 users
- Medium scope: Scale to 100+ workspaces by increasing EKS nodes and RDS instance
- No architectural changes required - only resource scaling

## Application Hosting
All platform components will be hosted on AWS infrastructure:
- Terraform Enterprise on Amazon EKS for high availability and scalability
- PostgreSQL backend on Amazon RDS with Multi-AZ deployment for resilience
- HashiCorp Vault on EC2 instances or integrated with existing Vault deployment
- Application Load Balancer for TLS termination and health checking
- S3 buckets for Terraform run artifacts and backup storage

All services are deployed using infrastructure-as-code (Terraform).

## Networking
The networking architecture follows HashiCorp best practices for enterprise platforms:
- VPC deployment with private subnets for Terraform Enterprise components
- VPC endpoints for private AWS service access (S3, KMS, CloudWatch, RDS)
- Network policies for pod-to-pod communication security in EKS
- TLS 1.3 encryption for all platform communication
- AWS PrivateLink for secure access to Terraform Enterprise from on-premises networks
- Security groups restricting access to Terraform Enterprise and RDS instances

## Observability
Comprehensive observability ensures operational excellence:
- CloudWatch Logs for centralized logging from all Terraform Enterprise components
- CloudWatch Metrics for platform health, workspace runs, and policy enforcement
- Terraform Enterprise audit logging for all infrastructure changes and state access
- CloudWatch Alarms for proactive alerting on platform issues
- Custom dashboards showing infrastructure KPIs (workspaces, runs, policy compliance, costs)
- Integration with existing monitoring platforms (Datadog, Splunk, etc.)

## Backup & Disaster Recovery
All critical data and configurations are protected through:
- RDS automated backups with 7-day retention for Terraform state
- RDS Multi-AZ deployment for high availability
- S3 versioning for Terraform run artifacts
- Terraform Enterprise configuration backups via automation
- Cross-region replication for disaster recovery (optional)
- RTO: 4 hours | RPO: 1 hour

---

## Technical Implementation Strategy

The implementation approach follows HashiCorp best practices and proven methodologies for Terraform Enterprise deployments.

## Example Implementation Patterns

The following patterns will guide the implementation approach:

- Phased workspace migration: Pilot with non-production workspaces, validate, then migrate production
- Parallel operation: Run Terraform Enterprise alongside existing OSS during transition period
- Progressive policy enforcement: Start with advisory policies, transition to mandatory after team training
- Iterative optimization: Continuous improvement based on platform usage and feedback

## Tooling Overview

The following table outlines the recommended tooling stack for this implementation:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|-----------------------|------------------------------|-------------------------------|
| Infrastructure | Terraform, Kubernetes, EKS | Platform hosting and orchestration |
| HashiCorp Stack | Terraform Enterprise, Vault | Infrastructure automation and secrets management |
| Version Control | GitHub Enterprise | GitOps workflows and collaboration |
| Monitoring | CloudWatch, Datadog | Centralized logging, metrics, alerting |
| CI/CD | GitHub Actions, Jenkins | Automated deployment pipelines |
| Security | Vault, KMS, Sentinel | Secrets management, encryption, policy enforcement |

---

## Data Management

### Data Strategy

The data management approach follows industry best practices:

- Centralized Terraform state storage in Terraform Enterprise with encryption at rest
- State locking and consistency guarantees eliminating concurrent modification conflicts
- Workspace isolation with granular RBAC for state access control
- State versioning with rollback capabilities for recovery
- Terraform Enterprise API for programmatic state management and reporting

### Data Security & Compliance
- Encryption enabled for state data at-rest using AWS KMS customer-managed keys
- TLS 1.3 encryption for all state data in-transit
- HashiCorp Vault for secrets encryption and dynamic AWS credential generation
- Sensitive variable masking in Terraform Enterprise logs and UI
- Comprehensive audit trail for all state access via Terraform Enterprise audit logs
- Compliance controls aligned with SOC2 and ISO27001 frameworks

---

---

# Security & Compliance

The implementation and target environment will be architected and validated to meet the Client's security, compliance, and governance requirements. Vendor will adhere to industry-standard security frameworks and HashiCorp Terraform Enterprise best practices.

## Identity & Access Management

The solution implements comprehensive identity and access controls:

- Role-based access control (RBAC) for all Terraform Enterprise workspaces and operations
- Integration with SSO/SAML for centralized authentication and identity management
- HashiCorp Vault dynamic AWS credentials for automated infrastructure provisioning
- Multi-factor authentication (MFA) required for all platform access
- Principle of least privilege for all platform users and service accounts
- API token management with expiration policies and rotation requirements

## Monitoring & Threat Detection

Security monitoring capabilities include:

- Comprehensive audit logging in Terraform Enterprise for all infrastructure changes
- HashiCorp Vault audit logs for all secrets access and dynamic credential generation
- CloudWatch monitoring for platform health, performance, and security metrics
- Integration with SIEM systems for security event correlation and analysis
- Automated alerts for Sentinel policy violations and unauthorized access attempts
- Drift detection for infrastructure configuration compliance monitoring

## Compliance & Auditing

The solution supports the following compliance frameworks:

- SOC2 compliance: Terraform Enterprise is SOC2 certified, platform architecture follows SOC2 principles
- ISO27001 compliance: Security controls aligned with ISO27001 framework requirements
- Sentinel policies enforcing regulatory compliance requirements (HIPAA, PCI DSS if applicable)
- Continuous compliance monitoring through automated Sentinel policy enforcement
- Audit trail preservation for all infrastructure changes (minimum 1 year retention)

## Encryption & Key Management

Data protection is implemented through encryption at all layers:

- All Terraform state encrypted at rest using AWS KMS customer-managed keys
- All platform communication encrypted in transit using TLS 1.3
- HashiCorp Vault encryption as a service for application secrets
- RDS encryption enabled for PostgreSQL state backend
- Encryption key rotation policies implemented and automated
- Secure key management using AWS KMS with audit logging via CloudTrail

## Governance

Governance processes ensure consistent management of the solution:

- Sentinel policies enforcing infrastructure standards across all AWS deployments
- Mandatory policy checks before infrastructure changes are applied to production
- Cost governance policies preventing resource over-provisioning and budget overruns
- Workspace approval workflows for production environment changes
- Quarterly access reviews for RBAC and workspace permissions
- Incident response procedures for security events and policy violations
- Resource tagging enforcement for cost allocation, compliance tracking, and lifecycle management

---

## Environments & Access

### Environment Strategy

The HashiCorp Terraform Enterprise platform will support three primary workspace environments aligned with the Client's SDLC processes. Each environment has distinct access controls, policy enforcement levels, and approval requirements to ensure appropriate governance.

| Environment | Purpose | AWS Scope | Access |
|-------------|---------|-----------|--------|
| Development | Infrastructure experimentation and module development | Dev AWS account or VPCs | Development team, automated runs |
| Staging | Pre-production validation and integration testing | Staging AWS account or VPCs | Project team, testers, automated runs |
| Production | Live infrastructure provisioning and changes | Production AWS account or VPCs | Operations team, approval-gated runs |

### Access Policies

Access control policies are defined as follows:

- Single Sign-On (SSO) via SAML for all Terraform Enterprise access
- Multi-factor authentication (MFA) required for all users
- API access via team tokens with automatic expiration and rotation
- Administrator Access: Full platform administration for Vendor during implementation
- Workspace Manager: Create and manage workspaces, modify workspace settings
- Workspace Operator: Trigger runs, apply changes within assigned workspaces
- Plan-Only User: Trigger plan operations but cannot apply changes
- Viewer: Read-only access to workspace runs, state, and variables
- HashiCorp Vault dynamic credentials for automated AWS API access

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the implementation lifecycle to ensure functionality, performance, security, and policy compliance of the HashiCorp Terraform Enterprise platform.

## Functional Validation

Functional testing ensures all features work as designed:

- End-to-end workspace execution for AWS infrastructure provisioning
- VCS-triggered run validation via GitHub webhooks and pull request workflows
- Sentinel policy enforcement testing across all policy sets and severity levels
- HashiCorp Vault dynamic AWS credential generation and rotation validation
- Approval workflow testing for production workspace changes
- Private module registry functionality including versioning and dependency management
- Cost estimation accuracy for infrastructure changes
- Drift detection and notification functionality

## Performance & Load Testing

Performance validation ensures the solution meets SLA requirements:

- Concurrent run capacity testing (10 simultaneous runs)
- State locking and consistency validation under concurrent workspace access
- Workspace migration performance benchmarking for state file transfers
- Platform response time for API operations and UI interactions
- RDS performance under Terraform state read/write load

## Security Testing

Security validation ensures protection against threats:

- RBAC validation across all user roles and workspace permissions
- Vault dynamic credential security, scoping, and rotation testing
- TLS encryption verification for all platform communication
- Sentinel policy bypass prevention testing (hardened enforcement)
- Audit log completeness and integrity validation
- Penetration testing of platform infrastructure (optional)

## Policy Compliance Testing

Policy compliance testing validates adherence to security standards:

- Sentinel policy effectiveness testing across security, cost, and compliance domains
- Policy violation detection and enforcement validation (hard mandatory vs advisory)
- Compliance framework alignment verification (SOC2, ISO27001)
- Cost governance policy accuracy testing with sample infrastructure changes
- Tagging enforcement validation for resource compliance

## AWS Integration Testing

AWS integration testing validates cloud service connectivity:

- Infrastructure provisioning validation across AWS services (VPC, EC2, RDS, EKS, etc.)
- Dynamic AWS credential generation and permission scoping via Vault
- Multi-account AWS deployment validation (if applicable)
- Region-specific deployment validation
- Integration with AWS-native services (IAM, CloudWatch, CloudTrail)

## User Acceptance Testing (UAT)

UAT is performed in coordination with Client business stakeholders:

- Performed in coordination with Client infrastructure and DevOps teams
- Test workspaces and sample Terraform configurations provided by Vendor
- Policy compliance validation against business-defined acceptance criteria
- Integration testing with CI/CD pipelines and development workflows

## Go-Live Readiness
A Go-Live Readiness Checklist will be delivered including:
- Security and compliance sign-offs from Client security team
- Policy enforcement validation completion with 100% success rate
- Performance testing completion (10 concurrent runs sustained)
- Integration testing completion (VCS, CI/CD, monitoring, Vault)
- 50 workspace migration completion with state integrity verification
- Issue log closure (all critical/high issues resolved)
- Training completion and documentation delivery

---

## Cutover Plan

The cutover to the HashiCorp Terraform Enterprise platform will be executed using a phased workspace migration approach to minimize business disruption and ensure seamless transition from Terraform OSS. The migration will occur in waves with validation gates between phases.

**Cutover Approach:**

The implementation follows a **progressive migration** strategy where workspaces are migrated in waves while existing Terraform OSS processes remain operational during transition. This approach allows for:

1. **Pilot Wave (Week 1):** Migrate 10 non-production development workspaces to Terraform Enterprise for validation. Monitor state migration, VCS-triggered runs, and policy enforcement with zero impact to production infrastructure. Gather team feedback and refine migration process.

2. **Development Wave (Week 2-3):** Migrate remaining development and staging workspaces:
   - Week 2: 20 additional development workspaces (cumulative: 30 total)
   - Week 3: 10 staging workspaces (cumulative: 40 total)
   - Parallel operation: Existing Terraform OSS processes remain available as fallback

3. **Production Wave (Week 4-5):** Migrate production workspaces with enhanced validation:
   - Week 4: 5 low-risk production workspaces with approval gates (cumulative: 45 total)
   - Week 5: 5 high-risk production workspaces with change windows (cumulative: 50 total)
   - Full testing and validation before each production workspace migration

4. **Platform Cutover (Week 6):** Full platform operational:
   - All 50 workspaces migrated and operational on Terraform Enterprise
   - Sentinel policies enforced across all environments
   - Vault integration complete for dynamic AWS credentials
   - VCS-driven workflows fully automated
   - Legacy Terraform OSS state files archived and decommissioned

5. **Hypercare Period (4 weeks post-cutover):** Daily monitoring, rapid issue resolution, and optimization to ensure stable operations.

The cutover will be coordinated with Client infrastructure teams with documented rollback procedures available for each migration wave if critical issues arise.

## Cutover Checklist

The following checklist will guide the cutover execution:

- Pre-migration validation: Complete workspace inventory and state file integrity checks
- Terraform Enterprise platform validated and monitoring operational
- Vault integration tested with dynamic AWS credential generation
- Rollback procedures documented and rehearsed for each workspace wave
- Stakeholder communication completed for migration schedule and impacts
- Execute pilot wave migration (10 development workspaces)
- Monitor pilot workspace runs for 1 week minimum before expansion
- Execute development wave migration (30 additional workspaces)
- Execute staging wave migration (10 staging workspaces)
- Execute production wave migration (10 production workspaces with approval gates)
- Verify Sentinel policy enforcement and approval workflows
- Daily monitoring during hypercare period (4 weeks)

## Rollback Strategy

Comprehensive rollback procedures in case of critical issues:

- Documented rollback triggers (persistent run failures, state corruption, data loss, security incident)
- Rollback procedures: Restore Terraform OSS state files to original S3/local locations, revert workspace configurations
- Root cause analysis and platform fixes required before migration retry
- Communication plan for stakeholders on rollback events and timeline
- Preserve all Terraform Enterprise state versions and audit logs for forensic analysis

---

---

# Handover & Support

## Handover Artifacts

The following artifacts will be delivered upon project completion:

- As-built documentation including architecture diagrams, platform configurations, and network topology
- Sentinel policy library with detailed documentation on policy logic, enforcement rules, and exceptions
- Workspace organization documentation with naming conventions, team assignments, and RBAC model
- Operations runbook with troubleshooting procedures for common platform issues and escalation paths
- Terraform Enterprise administration guide covering workspace management, policy updates, and user management
- Monitoring and alert configuration reference with escalation procedures and on-call runbooks
- AWS cost optimization recommendations based on Terraform Enterprise usage patterns
- Integration documentation for VCS, CI/CD, monitoring, and HashiCorp Vault

## Knowledge Transfer

Knowledge transfer ensures the Client team can effectively operate the solution:

- Live knowledge transfer sessions for platform administrators and infrastructure teams (2 full-day sessions)
- Terraform Enterprise administration training covering workspace management, RBAC, VCS integration, and monitoring
- Sentinel policy development training with hands-on exercises for creating and testing policies
- Private module registry usage training for infrastructure code reusability and versioning
- HashiCorp Vault integration training for dynamic credential management
- Recorded training materials hosted in client documentation portal for ongoing reference
- Documentation portal with searchable content, platform runbooks, and troubleshooting guides

## Hypercare Support

Post-implementation support to ensure smooth transition to Client operations:

**Duration:** 30 days post-go-live

**Coverage:**
- Business hours support (8 AM - 6 PM EST, Monday-Friday)
- 4-hour response time for critical platform issues affecting production workspaces
- Daily health check calls (first 2 weeks)
- Weekly status meetings throughout hypercare period

**Scope:**
- Platform issue investigation and resolution
- Workspace migration assistance for any remaining stragglers
- Performance tuning and optimization based on usage patterns
- Sentinel policy adjustments based on operational feedback and edge cases
- Configuration troubleshooting and guidance
- Knowledge transfer continuation and on-the-job training

## Managed Services Transition (Optional)

Post-hypercare, Client may transition to ongoing managed services:

**Managed Services Options:**
- 24/7 platform monitoring and support for Terraform Enterprise
- Proactive optimization and cost management recommendations
- Sentinel policy updates and new policy development for evolving requirements
- Platform scaling and capacity management as workspace count grows
- Monthly platform performance and cost optimization reviews
- Terraform Enterprise version upgrades and patch management

**Transition Approach:**
- Evaluation of managed services requirements during hypercare period
- Service Level Agreement (SLA) definition for platform availability and response times
- Separate managed services contract and pricing based on scope
- Seamless transition from hypercare to managed services with continuity of support

---

## Assumptions

### General Assumptions

This engagement is based on the following general assumptions:

- Client will provide access to AWS environment with appropriate permissions for Terraform Enterprise deployment
- Existing Terraform code is compatible with Terraform Enterprise (Terraform version 0.12+)
- Client technical team will be available for requirements validation, workspace migration support, and approvals
- GitHub repository access and webhook configuration permissions will be provided
- Network connectivity meets Terraform Enterprise requirements for AWS API access
- Security and compliance approval processes will not delay critical path activities
- Client will handle HashiCorp Terraform Enterprise license procurement directly with HashiCorp or authorized reseller
- AWS infrastructure costs will be handled by Client directly with AWS

---

## Dependencies

### Project Dependencies

The following dependencies must be satisfied for successful project execution:

- AWS Access: Client provides AWS account access with appropriate permissions for EKS, RDS, S3, KMS, IAM provisioning
- Terraform Code: Client provides existing Terraform configurations and state files for migration assessment
- VCS Access: GitHub repository access and webhook configuration permissions for automated runs
- Kubernetes Cluster: EKS cluster provisioned or access for Vendor to deploy if not existing
- HashiCorp Vault: Existing Vault deployment or access for Vendor to deploy new Vault instance
- SME Availability: Infrastructure and DevOps teams available for requirements clarification and workspace migration
- Security Approvals: Security and compliance approvals obtained on schedule to avoid implementation delays
- HashiCorp License: Terraform Enterprise license procured and activated before deployment
- Change Freeze: No major changes to AWS infrastructure or IAM policies during migration phases
- Go-Live Approval: Business and technical approval authority available for production workspace migration decisions

---

---

# Investment Summary

This section provides a comprehensive overview of the engagement investment:

**Small Scope Implementation:** This pricing reflects a department-level deployment designed for 50 Terraform workspaces managing AWS infrastructure with 25 platform users and comprehensive governance. For larger enterprise deployments, please request medium or large scope pricing.

## Total Investment

The following table provides a comprehensive overview of the total investment required for this engagement:

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 18, 14, 12, 11, 13] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $0 | $0 | $0 | $0 | $0 | $0 |
| Cloud Services | $35,916 | ($12,000) | $23,916 | $35,916 | $35,916 | $95,748 |
| Software Licenses | $34,260 | $0 | $34,260 | $34,260 | $34,260 | $102,780 |
| Support & Maintenance | $58,400 | $0 | $58,400 | $58,400 | $58,400 | $175,200 |
| **TOTAL INVESTMENT** | **$128,576** | **($12,000)** | **$116,576** | **$128,576** | **$128,576** | **$373,728** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $22,000 (8% reduction)
- **AWS Services Credit:** $12,000 applied to EKS, RDS, and infrastructure costs
- **HashiCorp Partner Services Credit:** $10,000 applied to professional services
- Credits are real account credits, automatically applied as services are consumed
- Credits are Year 1 only; Years 2-3 reflect standard pricing

**Investment Comparison:**
- **Year 1 Net Investment:** $239,076 (after credits) vs. $261,076 list price
- **3-Year Total Cost of Ownership:** $577,228
- **Expected ROI:** 12-14 month payback based on typical infrastructure operations cost savings from automation

## Cost Components

**Professional Services** ($125,000 - 470 hours): Labor costs for assessment, architecture, implementation, testing, and knowledge transfer. Breakdown:
- Discovery & Architecture (80 hours): Terraform assessment, platform design, documentation
- Implementation (340 hours): Platform deployment, workspace migration, policy development, integration, testing
- Training & Support (50 hours): Knowledge transfer and 30-day post-launch hypercare

**Cloud Infrastructure** ($35,916/year): AWS infrastructure hosting for Terraform Enterprise sized for small scope (50 workspaces):
- Amazon EKS cluster for Terraform Enterprise (3 nodes, t3.large): $11,880/year
- Amazon RDS PostgreSQL for state backend (db.t3.medium): $7,446/year
- Networking, storage, KMS, backups, load balancer: $16,590/year
- Scales with workspace count and concurrent run requirements

**HashiCorp Licenses** ($29,500/year): HashiCorp Terraform Enterprise licensing sized for small scope:
- Terraform Enterprise (100 users @ $70/user/month): $29,500/year
- Includes workspace management, Sentinel policies, and private module registry

**Software Licenses & Subscriptions** ($34,260/year): Operational tooling for small scope:
- Datadog monitoring (10 hosts): $7,200/year
- PagerDuty incident management (3 users): $2,124/year
- Slack notifications integration: $420/year
- GitHub Actions runners: $4,800/year
- Backup and monitoring tools: $19,716/year

**Support & Maintenance** ($58,400/year): Ongoing managed services (15% of infrastructure + licenses):
- Business hours monitoring and platform health checks
- Monthly cost optimization reviews and recommendations
- Terraform Enterprise updates and patch management
- Incident response and troubleshooting support

---

## Payment Terms

### Pricing Model
- Fixed price for professional services ($125,000)
- Infrastructure and licensing costs at actuals

### Payment Schedule
- 25% upon SOW execution and project kickoff
- 30% upon completion of Foundation & Migration phase (Month 2)
- 30% upon completion of Governance & Integration phase (Month 4)
- 15% upon successful go-live and project acceptance (Month 6)

---

## Invoicing & Expenses

Invoicing and expense policies for this engagement:

### Invoicing
- Milestone-based invoicing per Payment Terms above
- Net 30 payment terms
- Invoices submitted upon milestone completion and acceptance

### Expenses
- AWS service costs are included in Cloud Infrastructure pricing ($35,916/year = ~$2,993/month)
- HashiCorp licenses included in HashiCorp Licenses pricing ($29,500/year = ~$2,458/month)
- Small scope sizing: 50 workspaces, 25 users, AWS infrastructure
- Costs scale with actual usage - can increase/decrease based on workspace count
- Travel and on-site expenses reimbursable at cost with prior approval (remote-first delivery model)

---

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

## Scope Changes

Change control procedures for this engagement:

- Changes to workspace count, policy requirements, AWS scope, or timeline require formal change requests
- Change requests may impact project timeline and budget

## Intellectual Property

Intellectual property rights are defined as follows:

- Client retains ownership of all Terraform configurations, infrastructure code, and business data
- Vendor retains ownership of proprietary Terraform Enterprise implementation methodologies and frameworks
- Sentinel policies and platform configurations become Client property upon final payment
- Terraform Enterprise infrastructure code and configurations transfer to Client

## Service Levels

Service level commitments for this engagement:

- Platform uptime: 99.9% measured monthly
- 30-day warranty on all deliverables from go-live date
- Post-warranty support available under separate managed services agreement

## Liability

Liability terms and limitations:

- Performance guarantees apply only to platform components within Vendor control
- HashiCorp Terraform Enterprise product functionality and availability governed by HashiCorp SLAs
- Liability caps as agreed in MSA

## Confidentiality

Confidentiality obligations for both parties:

- Both parties agree to maintain strict confidentiality of business data, infrastructure configurations, and proprietary implementation methodologies
- All exchanged artifacts under NDA protection

## Termination

Termination provisions for this engagement:

- Mutually terminable per MSA terms, subject to payment for completed work

## Governing Law

This agreement shall be governed by the laws of [State/Region].

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
