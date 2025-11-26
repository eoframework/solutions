---
document_title: Statement of Work
technology_provider: GitHub
project_name: GitHub Actions Enterprise CI/CD Implementation
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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing GitHub Actions Enterprise CI/CD for [Client Name]. This engagement will deliver modern cloud-native CI/CD capabilities through GitHub's integrated automation platform to accelerate software delivery, reduce deployment failures, and eliminate legacy Jenkins infrastructure complexity.

**Project Duration:** 6 months

---

---

# Background & Objectives

This section outlines [Client Name]'s current CI/CD platform challenges, the strategic business objectives driving this GitHub Actions implementation, and the key success metrics that will define project outcomes.

## Current State

[Client Name] currently operates a legacy Jenkins CI/CD infrastructure supporting approximately [X] developers across [Y] applications. Key challenges include:
- **Slow Deployment Velocity:** Weekly deployments vs industry standard daily deployments, limiting business agility and time-to-market
- **High CI/CD Infrastructure Costs:** $800K+ annually for Jenkins servers, maintenance, plugins, and dedicated administrators
- **Deployment Failures:** 30%+ deployment failure rate requiring rollbacks and emergency fixes
- **Jenkins Complexity:** Groovy pipelines and XML configuration requiring specialized Jenkins expertise
- **Limited Scalability:** Cannot handle concurrent builds during peak periods, creating developer bottlenecks
- **Manual Processes:** Significant manual intervention required for deployments and troubleshooting

## Business Objectives

The following objectives define the key business outcomes this engagement will deliver:

- **Accelerate Delivery:** Ship to production daily instead of weekly through automated GitHub Actions pipelines integrated with source control
- **Reduce Infrastructure Costs:** Achieve 60% cost reduction vs cloud-only runners through self-hosted runner infrastructure in AWS VPC
- **Improve Deployment Success:** Increase deployment success rate from 70% to 95%+ through automated testing and quality gates
- **Simplify CI/CD:** Replace complex Groovy/XML Jenkins configuration with simple YAML workflows developers can maintain
- **Enable Self-Service:** Empower developers with self-service deployments eliminating wait times and manual approvals
- **Foundation for Scale:** Build scalable platform supporting 10x growth in build volume without proportional cost increase

## Success Metrics

The following metrics will be used to measure project success:

- Deploy to production daily with 95%+ success rate
- Reduce pipeline execution time from 45 minutes to <10 minutes (10x faster)
- Eliminate $200K annually in Jenkins infrastructure and maintenance costs
- 100% of applications migrated to GitHub Actions from Jenkins
- 99.9% uptime for CI/CD platform
- Developer satisfaction score 8+ out of 10

---

---

# Scope of Work

This section defines the specific services, activities, and deliverables included in this engagement, along with the parameters that size the implementation scope and the items explicitly excluded from this SOW.

## In Scope
The following services and deliverables are included in this SOW:
- CI/CD platform assessment and GitHub Actions readiness evaluation
- Jenkins/GitLab CI pipeline analysis and migration planning
- GitHub Actions workflow design and implementation
- Self-hosted runner infrastructure in AWS VPC with auto-scaling
- Reusable workflow template library for standardization
- OIDC integration for keyless AWS authentication
- Container registry integration (GitHub Packages, AWS ECR)
- Kubernetes deployment automation (AWS EKS)
- Security scanning integration (CodeQL, Dependabot)
- Testing, validation, and performance optimization
- Knowledge transfer and documentation

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Active Developers | 100 developers |
| Solution Scope | Development Teams | 8-10 teams |
| Integration | Applications with CI/CD | 20-50 applications |
| Integration | Builds Per Day | 200 builds/day |
| Integration | Migration Source | Jenkins GitLab CI |
| Integration | Deployment Targets | AWS (EC2 ECS EKS Lambda) |
| User Base | Self-Hosted Runners | 20 runners (c5.2xlarge) |
| User Base | Runner OS | Linux + Windows |
| Data Volume | Average Build Duration | 20 minutes |
| Data Volume | Reusable Workflows | 15 workflow templates |
| Technical Environment | Technology Stack | .NET Node.js Python Docker |
| Technical Environment | Container Registries | GitHub Packages + AWS ECR |
| Technical Environment | Kubernetes | AWS EKS clusters |
| Security & Compliance | OIDC Integration | AWS Azure keyless auth |
| Security & Compliance | Security Scanning | CodeQL Dependabot |
| Performance | Deployment Environments | Dev test staging production |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*


## Activities

### Phase 1 – Discovery & Assessment
During this initial phase, the Vendor will perform a comprehensive assessment of the Client's current CI/CD workflows, Jenkins/GitLab infrastructure, and GitHub Actions readiness. This includes analyzing existing pipelines, identifying migration complexity, determining infrastructure requirements, and designing the optimal GitHub Actions deployment approach.

Key activities:
- CI/CD platform assessment and current state analysis
- Jenkins/GitLab pipeline inventory and complexity assessment
- Application technology stack analysis (.NET, Node.js, Python, Docker)
- Build performance baseline and optimization opportunities
- Deployment workflow analysis (AWS EC2, ECS, EKS, Lambda)
- Self-hosted runner infrastructure sizing and AWS VPC design
- GitHub Actions migration strategy (pilot, phased migration, cutover)
- Reusable workflow template requirements
- Implementation planning and resource allocation

This phase concludes with an Assessment Report that outlines the proposed GitHub Actions architecture, migration strategy, infrastructure design, integration approach, risks, and project timeline.

### Phase 2 – Foundation & Pilot
In this phase, GitHub Actions infrastructure is deployed and pilot pipelines are migrated to validate performance, developer experience, and migration approach.

Key activities:
- GitHub Enterprise Cloud configuration for CI/CD
- Self-hosted runner infrastructure deployment in AWS VPC
- Auto-scaling group configuration for dynamic runner capacity
- OIDC configuration for keyless AWS authentication
- Pilot application pipeline migration (5-10 applications)
- Reusable workflow template development (initial set)
- Container registry integration (GitHub Packages, AWS ECR)
- Security scanning integration (CodeQL, Dependabot)
- Performance testing and optimization
- Developer feedback collection and process refinement

By the end of this phase, the Client will have validated GitHub Actions capabilities and confirmed migration approach before full rollout.

### Phase 3 – Scale & Integration
Implementation will expand GitHub Actions to all applications following the proven pilot approach. Advanced features including deployment strategies, monitoring, and governance will be configured.

Key activities:
- Migration of remaining 40-45 application pipelines from Jenkins
- Complete reusable workflow template library (15 templates)
- Advanced deployment strategies (blue-green, canary, feature flags)
- Kubernetes deployment automation for AWS EKS
- Monitoring and observability integration (Datadog, New Relic)
- Notification configuration (Slack, Teams, email, PagerDuty)
- Environment protection rules and deployment gates
- Workflow approval workflows for production deployments
- Cost optimization through caching and artifact management
- Incremental testing and validation across all applications

After each migration wave, the Vendor will coordinate validation and sign-off with the Client before proceeding.

### Phase 4 – Testing & Validation
In the Testing and Validation phase, GitHub Actions undergoes thorough functional, performance, and reliability validation to ensure it meets required SLAs and business objectives.

Key activities:
- End-to-end workflow validation for all technology stacks
- Performance testing and pipeline execution time verification
- Concurrent build capacity testing (20+ parallel builds)
- Deployment success rate validation (95%+ target)
- Security scanning integration validation
- Kubernetes deployment testing across environments
- Monitoring and alerting validation
- Disaster recovery and rollback testing
- User Acceptance Testing (UAT) coordination with DevOps team
- Go-live readiness review and Jenkins decommissioning planning

Cutover will be coordinated with all relevant stakeholders and executed with documented rollback procedures to Jenkins if needed.

### Phase 5 – Handover & Post-Implementation Support
Following successful implementation and Jenkins decommissioning, the focus shifts to ensuring operational continuity and knowledge transfer. The Vendor will provide hypercare support and equip the Client's team with documentation, tools, and processes for ongoing platform operations.

Activities include:
- Delivery of as-built documentation (architecture, workflows, runner infrastructure)
- Operations runbook and SOPs for CI/CD platform management
- GitHub Actions administration training for platform team
- Workflow development training for DevOps engineers
- Self-hosted runner management and troubleshooting training
- Live or recorded knowledge transfer sessions
- Performance optimization recommendations
- 30-day warranty support for issue resolution
- Optional transition to managed services model for ongoing support

---

## Out of Scope

These items are not in scope unless added via change control:
- Jenkins infrastructure decommissioning (client responsibility)
- Historical build data migration from Jenkins
- Application code refactoring or modernization
- Custom development for unsupported deployment targets
- GitHub Enterprise Server (on-premises) deployment
- Network infrastructure provisioning beyond runner VPC
- Third-party tool licensing beyond GitHub
- End-user training beyond DevOps engineer enablement
- Ongoing operational support beyond 30-day warranty period
- GitHub and AWS service costs (billed directly to client)

---

---

# Deliverables & Timeline

This section provides a comprehensive view of all project deliverables, their due dates, acceptance criteria, and key implementation milestones throughout the engagement lifecycle.

## Deliverables

The following table summarizes the key deliverables for this engagement:

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | CI/CD Platform Assessment | Document | Week 2 | [DevOps Lead] |
| 2 | GitHub Actions Architecture | Document | Week 3 | [Technical Lead] |
| 3 | Implementation Plan | Project Plan | Week 3 | [Project Sponsor] |
| 4 | Self-Hosted Runner Infrastructure | System | Week 6 | [Infrastructure Lead] |
| 5 | Pilot Pipeline Migration | System | Week 8 | [DevOps Lead] |
| 6 | Reusable Workflow Templates | System | Week 12 | [DevOps Lead] |
| 7 | Organization-Wide Migration | System | Week 16 | [DevOps Lead] |
| 8 | Monitoring & Observability | System | Week 16 | [SRE Lead] |
| 9 | Test Plan & Results | Document | Week 18 | [QA Lead] |
| 10 | DevOps Engineer Training | Training | Week 20 | [Development Leads] |
| 11 | Operations Runbook | Document | Week 22 | [Platform Team] |
| 12 | As-Built Documentation | Document | Week 24 | [DevOps Lead] |
| 13 | Knowledge Transfer Sessions | Training | Week 22-24 | [Platform Team] |

---

## Project Milestones

The following milestones represent key checkpoints throughout the project lifecycle:

<!-- TABLE_CONFIG: widths=[20, 50, 30] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 | Assessment Complete | Week 3 |
| M2 | Infrastructure Ready | Week 6 |
| M3 | Pilot Migration Complete | Week 8 |
| M4 | Organization-Wide Migration Complete | Week 16 |
| M5 | Testing Complete | Week 20 |
| Go-Live | Production Launch | Week 22 |
| Hypercare End | Support Period Complete | Week 26 |

---

---

# Roles & Responsibilities

This section defines the roles, responsibilities, and accountability for all project stakeholders using a RACI framework, along with key personnel assignments from both Vendor and Client teams.

## RACI Matrix

The following RACI matrix clarifies decision-making authority and task ownership across all project activities:

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO Sales Eng | EO Eng (DevOps) | Client IT | Client DevOps | SME |
|-----------|-------|----------------|--------------|-----------------|-----------|---------------|-----|
| Discovery & Requirements | A | R | R | C | C | R | C |
| CI/CD Architecture | C | A | R | I | I | C | I |
| Workflow Development | C | C | R | A | I | C | I |
| Infrastructure Setup | C | A | C | R | C | I | I |
| Pipeline Migration | C | R | C | A | C | I | I |
| Integration Configuration | C | R | C | A | C | C | I |
| Testing & Validation | R | C | R | R | A | A | I |
| Deployment Automation | C | R | I | A | I | A | I |
| Knowledge Transfer | A | R | R | R | C | C | I |
| Hypercare Support | A | R | R | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

The following personnel will be assigned to this engagement:

**Vendor Team:**
- EO Project Manager: Overall delivery accountability
- EO Quarterback: Technical design and oversight
- EO Sales Engineer: Solution architecture and pre-sales support
- EO Engineer (DevOps): GitHub Actions configuration and workflow development

**Client Team:**
- DevOps Lead: Primary CI/CD contact and platform ownership
- Infrastructure Lead: AWS VPC and runner infrastructure
- SRE Lead: Monitoring integration and reliability
- Development Team Leads: Pipeline migration coordination
- Platform Team: Ongoing GitHub Actions administration

---

---

# Architecture & Design

This section describes the GitHub Actions Enterprise CI/CD solution architecture, technical specifications, implementation patterns, integration approach, and data management strategy.

## Architecture Overview
The GitHub Actions Enterprise CI/CD solution is designed as a **cloud-native automation platform** leveraging GitHub's integrated workflow engine with self-hosted runner infrastructure. The architecture provides scalable, cost-optimized CI/CD automation with seamless integration into existing AWS deployment infrastructure.

This architecture is designed for **medium-scope deployment** supporting 100 developers with 20-50 applications and 200 builds per day. The design prioritizes:
- **Performance:** 10x faster pipeline execution through self-hosted runners and parallelization
- **Cost Efficiency:** 60% infrastructure cost reduction through self-hosted runners vs cloud-only
- **Scalability:** Can grow to large-scope deployment by adding runners (no re-architecture)

![Figure 1: Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Solution Architecture Diagram** - High-level overview of the GitHub Actions Enterprise CI/CD solution architecture

## Architecture Type
The deployment follows a hybrid cloud architecture with GitHub-managed control plane and self-hosted compute infrastructure. This approach enables:
- Automated workflow execution for every commit and pull request
- Self-hosted runner infrastructure in AWS VPC for private builds and AWS resource access
- Reusable workflow templates for standardization across teams
- Environment protection rules for safe production deployments
- Integration with existing AWS services (ECS, EKS, ECR, Lambda)

Key architectural components include:
- Workflow Orchestration Layer (GitHub Actions managed service)
- Compute Layer (Self-Hosted Runners in AWS VPC)
- Artifact Storage Layer (GitHub Packages, AWS ECR)
- Deployment Layer (AWS EC2, ECS, EKS, Lambda)
- Observability Layer (Datadog, New Relic, CloudWatch)

## Scope Specifications

This engagement is scoped according to the following specifications:

**GitHub Platform:**
- GitHub Enterprise Cloud with Actions enabled
- 100 GitHub Enterprise user licenses
- 50,000 Actions minutes included per month
- Organization-wide workflow templates and policies

**Self-Hosted Runner Infrastructure:**
- 20x c5.2xlarge EC2 instances (8 vCPU, 16GB RAM each)
- Auto-scaling groups for dynamic capacity (scale 10-30 runners)
- Linux and Windows runner support
- Deployed in AWS VPC with private subnet access
- CloudWatch monitoring and alerting

**Workflow Features:**
- YAML-based workflow definitions (.github/workflows)
- Matrix builds for multi-platform testing
- Reusable workflow templates for .NET, Node.js, Python, Docker
- Composite actions for common operations
- Environment protection rules with manual approvals
- Deployment gates and required reviewers

**Integration:**
- OIDC authentication for keyless AWS access (no static credentials)
- Container registry integration (GitHub Packages, AWS ECR)
- Kubernetes deployment via kubectl and Helm (AWS EKS)
- Security scanning (CodeQL, Dependabot)
- Monitoring integration (Datadog, New Relic, CloudWatch)
- Notification channels (Slack, Teams, Email, PagerDuty)

**Scalability Path:**
- Medium scope: Current deployment (100 users, 200 builds/day, 20 runners)
- Large scope: Scale to 500+ users, 1000+ builds/day with 50-100 runners
- No architectural changes required - only infrastructure scaling

## Application Hosting
CI/CD workflow orchestration hosted by GitHub's managed platform:
- GitHub Actions workflow engine (fully managed SaaS)
- Self-hosted runners in AWS VPC (client-managed infrastructure)
- Artifact storage in GitHub Packages and AWS ECR
- Deployment targets in AWS (EC2, ECS, EKS, Lambda)

All workflow definitions version-controlled in GitHub repositories alongside application code.

## Integration Architecture
The integration architecture connects GitHub Actions with AWS deployment infrastructure:
- OIDC federation provides keyless authentication to AWS services
- Workflows deploy to AWS EC2, ECS, EKS, and Lambda without static credentials
- Container images pushed to GitHub Packages and AWS ECR
- Kubernetes deployments via kubectl with EKS cluster access
- CloudWatch logs and metrics for deployment observability

## Observability
Comprehensive observability ensures CI/CD platform reliability:
- GitHub Actions workflow logs and execution history
- Self-hosted runner health monitoring and auto-scaling metrics
- Build duration trends and performance analytics
- Deployment success/failure rate dashboards
- Custom metrics for build queue depth and runner utilization

## Runner Management
Self-hosted runner infrastructure managed through:
- Auto-scaling groups maintaining 10-30 active runners based on queue depth
- Automated runner registration and configuration
- Health check monitoring and automatic replacement of unhealthy runners
- Secure runner image management with automated security patching
- Cost optimization through spot instances (optional)

---

## Technical Implementation Strategy

The implementation approach follows GitHub Actions best practices and proven methodologies for CI/CD migration from Jenkins and GitLab.

## Example Implementation Patterns

The following patterns will guide the implementation approach:

- Phased migration: Pilot with 5-10 applications, then migrate in waves
- Parallel operation: Run GitHub Actions alongside Jenkins during transition
- Iterative optimization: Continuous workflow tuning based on performance data

## Tooling Overview

The following table outlines the recommended tooling stack for this implementation:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|-----------------------|------------------------------|-------------------------------|
| CI/CD Platform | GitHub Actions | Workflow orchestration and automation |
| Compute Infrastructure | AWS EC2 Auto-Scaling | Self-hosted runner infrastructure |
| Container Registries | GitHub Packages, AWS ECR | Container image storage |
| Deployment Targets | AWS EC2, ECS, EKS, Lambda | Application hosting |
| Security Scanning | CodeQL, Dependabot | Vulnerability detection |
| Monitoring | Datadog, New Relic, CloudWatch | Observability and alerting |
| Notifications | Slack, Teams, PagerDuty | Build and deployment alerts |

---

## Data Management

### Data Strategy

The data management approach follows industry best practices:

- Workflow definitions stored in .github/workflows in each repository
- Build artifacts stored in GitHub Packages (retention: 90 days)
- Container images stored in GitHub Packages and AWS ECR
- Workflow logs retained per GitHub retention policies
- Runner infrastructure managed as cattle (immutable, auto-replaced)

### Data Security & Compliance
- All workflow execution within GitHub's SOC 2 certified infrastructure
- Self-hosted runners isolated in AWS VPC with private subnets
- OIDC authentication eliminates static AWS credentials in workflows
- Secrets encrypted at rest in GitHub Secrets vault
- Audit logging for all workflow executions and runner activity

---

---

# Security & Compliance

The implementation and target environment will be architected and validated to meet the Client's security, compliance, and governance requirements. Vendor will adhere to industry-standard security frameworks and GitHub Actions best practices.

## Identity & Access Management

The solution implements comprehensive identity and access controls:

- SAML SSO integration with existing identity provider
- GitHub organization and team-based access control
- OIDC federation for keyless AWS authentication (no static credentials)
- IAM roles for self-hosted runners with least-privilege policies
- Multi-factor authentication (MFA) required for all GitHub access

## Monitoring & Threat Detection

Security monitoring capabilities include:

- GitHub audit log monitoring for workflow and runner activity
- CloudWatch monitoring for runner infrastructure health
- Automated alerts for failed deployments and security scan findings
- Integration with existing SOC for incident response
- Workflow approval gates for high-risk deployments

## Compliance & Auditing

The solution supports the following compliance frameworks:

- SOC 2 compliance: GitHub Enterprise Cloud is SOC 2 Type II certified
- Audit trail: GitHub audit log provides complete workflow execution history
- Deployment audit logging with approval records
- Continuous security scanning via CodeQL and Dependabot
- Change control through pull request workflows

## Encryption & Key Management

Data protection is implemented through encryption at all layers:

- All data encrypted in transit using TLS 1.2+
- GitHub Secrets encrypted at rest with AES-256
- OIDC tokens short-lived (no persistent credentials)
- Container images signed and verified
- AWS KMS integration for sensitive data encryption

## Governance

Governance processes ensure consistent management of the solution:

- Change control: All workflow changes via pull request review
- Workflow governance: Organization-wide workflow templates and policies
- Access reviews: Quarterly review of GitHub organization access
- Deployment gates: Required approvals for production deployments
- Cost governance: Monitoring and alerting on Actions minutes consumption

---

## Environments & Access

### Environment Strategy

| Environment | Purpose | AWS Account | Access |
|-------------|---------|-------------|--------|
| Development | Feature development and testing | dev-account | Development teams |
| Staging | Integration testing and UAT | staging-account | DevOps, QA teams |
| Production | Production deployments | prod-account | DevOps, approved deployers |

### Access Policies

Access control policies are defined as follows:

- SAML SSO required for all GitHub access
- Multi-factor authentication (MFA) enforced for all users
- Organization Owner Access: Full GitHub administration (limited to 2-3 administrators)
- Platform Team Access: Runner infrastructure management and workflow administration
- Developer Access: Repository access per team membership with workflow authoring
- Deployer Access: Production deployment approval authority

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the implementation lifecycle to ensure functionality, performance, reliability, and deployment success of the GitHub Actions CI/CD platform.

## Functional Validation

Functional testing ensures all features work as designed:

- End-to-end workflow execution for all technology stacks (.NET, Node.js, Python, Docker)
- Container build and push to GitHub Packages and AWS ECR
- Kubernetes deployment to AWS EKS across environments
- Lambda deployment validation
- Security scanning integration (CodeQL, Dependabot)
- Deployment gate and approval workflow validation

## Performance & Load Testing

Performance validation ensures the solution meets SLA requirements:

- Pipeline execution time validation (<10 minutes target)
- Concurrent build capacity testing (20+ parallel builds)
- Auto-scaling validation for runner infrastructure
- Build queue monitoring under peak load

## Security Testing

Security validation ensures protection against threats:

- OIDC authentication validation for AWS access
- Secrets management and encryption verification
- CodeQL and Dependabot integration validation
- Runner infrastructure security hardening verification
- Audit logging completeness validation

## Integration Testing

Integration testing validates connectivity and data flow between systems:

- AWS deployment validation (EC2, ECS, EKS, Lambda)
- Container registry integration (GitHub Packages, AWS ECR)
- Monitoring integration (Datadog, New Relic, CloudWatch)
- Notification delivery (Slack, Teams, Email, PagerDuty)

## User Acceptance Testing (UAT)

UAT is performed in coordination with Client business stakeholders:

- Performed in coordination with Client DevOps team and developers
- Pilot applications and workflows provided by Vendor
- Performance validation against business-defined acceptance criteria
- Developer experience assessment

## Go-Live Readiness
A Go-Live Readiness Checklist will be delivered including:
- All application pipelines migrated and validated
- Performance meets targets (10 minutes, 95%+ success rate)
- Self-hosted runner infrastructure stable and auto-scaling
- Monitoring and alerting operational
- Integration testing complete (AWS, registries, monitoring)
- Issue log closure (all critical/high issues resolved)
- DevOps team training completion
- Documentation delivery

---

## Cutover Plan

The cutover from Jenkins to GitHub Actions will be executed using a controlled, phased approach to minimize disruption and ensure deployment continuity.

**Cutover Approach:**

The implementation follows a **parallel operation then gradual migration** strategy where GitHub Actions runs alongside Jenkins during transition:

1. **Pilot Phase (Weeks 1-8):** Deploy GitHub Actions infrastructure and migrate 5-10 pilot applications. Validate performance, developer experience, and deployment automation. Keep Jenkins operational for all other applications.

2. **Migration Waves (Weeks 9-16):** Migrate remaining applications in waves of 5-10 applications per week. Each application runs on GitHub Actions while Jenkins pipeline disabled. Monitor for issues before proceeding to next wave.

3. **Validation Phase (Weeks 17-20):** All applications running on GitHub Actions. Jenkins maintained as backup but not actively used. Performance and reliability monitoring to ensure stability.

4. **Jenkins Decommissioning (Week 21+):** Client decommissions Jenkins infrastructure after 30-day validation period. Vendor provides support during transition.

## Cutover Checklist

The following checklist will guide the cutover execution:

- Pre-cutover validation: Pilot applications meet performance and reliability targets
- Self-hosted runner infrastructure stable with auto-scaling operational
- All deployment targets validated (AWS EC2, ECS, EKS, Lambda)
- Monitoring and alerting configured
- Stakeholder communication completed
- Enable GitHub Actions workflows per migration wave schedule
- Monitor first production deployments for each application
- Verify deployment success rate and performance
- Daily monitoring during migration waves

## Rollback Strategy

Comprehensive rollback procedures in case of critical issues:

- Documented rollback triggers (deployment failures, performance issues, critical bugs)
- Rollback procedures: Re-enable Jenkins pipeline, disable GitHub Actions workflow
- Root cause analysis and resolution before retry
- Communication plan for stakeholders
- Preserve all workflow logs and deployment history for analysis

---

---

# Handover & Support

This section outlines the knowledge transfer approach, handover artifacts, post-implementation support model, and optional managed services transition to ensure successful operational ownership by the Client team.

## Handover Artifacts

The following artifacts will be delivered upon project completion:

- As-Built documentation including architecture diagrams and runner infrastructure
- Reusable workflow template library with documentation
- Operations runbook with troubleshooting procedures
- Self-hosted runner management guide
- Monitoring dashboard configuration
- Integration documentation for AWS, registries, monitoring

## Knowledge Transfer

Knowledge transfer ensures the Client team can effectively operate the solution:

- Live knowledge transfer sessions for platform team and DevOps engineers
- GitHub Actions administration training (runners, workflows, policies)
- Workflow development workshop for advanced automation
- Self-hosted runner management and troubleshooting training
- Recorded training materials hosted in shared portal
- Documentation portal with searchable content

## Hypercare Support

Post-implementation support to ensure smooth transition to Client platform operations:

**Duration:** 4 weeks post-migration (30 days)

**Coverage:**
- Business hours support (8 AM - 6 PM local time)
- 4-hour response time for critical deployment issues
- Daily health check calls (first 2 weeks)
- Weekly status meetings

**Scope:**
- Issue investigation and resolution
- Workflow optimization and performance tuning
- Runner infrastructure troubleshooting
- Knowledge transfer continuation
- CI/CD metrics review and optimization

## Managed Services Transition (Optional)

Post-hypercare, Client may transition to ongoing managed services:

**Managed Services Options:**
- 24/7 platform monitoring and support
- Proactive workflow optimization and cost management
- Runner infrastructure management and scaling
- Monthly performance and cost optimization reviews
- Continuous improvement and new feature adoption

**Transition Approach:**
- Evaluation of managed services requirements during hypercare
- Service Level Agreement (SLA) definition for platform availability
- Separate managed services contract and pricing
- Seamless transition from hypercare to managed services

---

## Assumptions

### General Assumptions

This engagement is based on the following general assumptions:

- Client has GitHub Enterprise Cloud subscription or will procure as part of this engagement
- All application source code is hosted on GitHub (or will be migrated)
- Development teams use Git and pull request workflows
- Client DevOps team available for pipeline requirements and validation
- AWS account access with appropriate permissions for runner infrastructure
- Jenkins/GitLab pipelines documented or source code available
- AWS deployment targets accessible from runner VPC
- Network connectivity between runner VPC and deployment targets established
- Security and compliance approval processes will not delay critical path
- Client will handle GitHub and AWS service costs directly

---

## Dependencies

### Project Dependencies

The following dependencies must be satisfied for successful project execution:

- GitHub Organization Access: Client provides GitHub organization owner access
- AWS Account Access: IAM permissions for VPC, EC2, auto-scaling, OIDC provider
- Jenkins/GitLab Access: Admin access for pipeline export and analysis
- Application Inventory: Complete list of applications requiring CI/CD migration
- Technology Stack Documentation: Programming languages, frameworks, build tools
- DevOps Team Availability: Engineers available for requirements and validation
- AWS Infrastructure: VPC, subnets, security groups for runner deployment
- Container Registry Access: Credentials for GitHub Packages and AWS ECR
- Deployment Credentials: AWS OIDC federation or IAM roles for deployments
- Go-Live Approval: DevOps and development leadership approval for migration waves

---

---

# Investment Summary

This section provides a comprehensive overview of the engagement investment:

**Medium Scope Implementation:** This pricing reflects an enterprise deployment designed for 100 developers with 20-50 applications and 200 builds per day. For smaller team deployments or larger enterprise-wide rollouts, please request small or large scope pricing.

## Total Investment

The following table provides a comprehensive overview of the total investment required for this engagement:

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 18, 14, 12, 11, 13] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $0 | $0 | $0 | $0 | $0 | $0 |
| **TOTAL INVESTMENT** | **$0** | **$0** | **$0** | **$0** | **$0** | **$0** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $0 (no credits available)
- GitHub Actions pricing is standard for Enterprise Cloud
- Self-hosted runners use client AWS account (client pays AWS directly)
- Professional services discounts may be available based on engagement size

**Investment Comparison:**
- **Year 1 Net Investment:** $1,136,468 vs. current Jenkins costs $800K+ annually
- **3-Year Total Cost of Ownership:** $3,244,924
- **Expected ROI:** 18 month payback based on Jenkins elimination and productivity gains

## Cost Components

**Professional Services** ($80,200 - 268 hours): Labor costs for assessment, migration, infrastructure setup, integration, and knowledge transfer. Breakdown:
- Discovery & Assessment (50 hours): CI/CD assessment, pipeline analysis, architecture design
- Implementation (180 hours): Infrastructure setup, pipeline migration, workflow development, integration
- Training & Support (38 hours): DevOps enablement and 30-day hypercare support

**Software Licenses** ($212,040 Year 1, $210,000 Years 2-3): GitHub Enterprise with Actions:
- GitHub Enterprise Cloud: 100 users @ $2,100/user/year ($210,000)
- GitHub Actions: 50,000 minutes included, additional minutes @ $0.008/minute ($2,040 for overages)

**Cloud Infrastructure** ($760,248/year): Self-hosted runner infrastructure in AWS:
- AWS EC2 runners: 20x c5.2xlarge 24x7 @ $0.34/hour ($59,568/year)
- AWS EBS storage: 20x 100GB volumes @ $0.10/GB-month ($2,400/year)
- AWS data transfer: 10TB/month @ $0.09/GB ($10,800/year)
- AWS VPC and networking: NAT Gateway, VPC endpoints ($7,680/year)
- Note: Sizing assumes 200 builds/day averaging 20 minutes each

**Third-Party Tools** ($28,980/year): Monitoring and observability:
- Datadog monitoring (10 hosts): $13,800/year
- PagerDuty incident management (5 users): $2,460/year
- SonarQube code quality integration: $8,000/year
- Artifact storage (GitHub Packages): $4,720/year

**Support & Maintenance** ($55,000/year): Ongoing managed services (optional):
- Business hours runner infrastructure monitoring: $30,000/year
- Monthly cost optimization reviews: $15,000/year
- Workflow optimization and tuning: $10,000/year

---

## Payment Terms

### Pricing Model
- Fixed price for professional services
- Milestone-based payments per Deliverables table

### Payment Schedule
- 25% upon SOW execution and project kickoff
- 30% upon completion of Foundation & Pilot phase
- 30% upon completion of Organization-Wide Migration
- 15% upon successful go-live and project acceptance

---

## Invoicing & Expenses

Invoicing and expense policies for this engagement:

### Invoicing
- Milestone-based invoicing per Payment Terms above
- Net 30 payment terms
- Invoices submitted upon milestone completion and acceptance

### Expenses
- GitHub service costs billed directly by GitHub to client ($212,040 Year 1, $210,000 Years 2-3)
- AWS infrastructure costs billed directly by AWS to client ($760,248/year estimated)
- Medium scope sizing: 100 users, 200 builds/day, 20 self-hosted runners
- Costs scale with build volume and runner count
- Travel and on-site expenses reimbursable at cost with prior approval (remote-first delivery)

---

---

# Terms & Conditions

This section defines the contractual terms governing this engagement, including general terms, scope change procedures, intellectual property rights, service levels, liability, and confidentiality obligations.

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

## Scope Changes

Change control procedures for this engagement:

- Changes to application count, infrastructure sizing, or integration scope require formal change requests
- Change requests may impact project timeline and budget

## Intellectual Property

Intellectual property rights are defined as follows:

- Client retains ownership of all application code and workflow definitions
- Vendor retains ownership of proprietary CI/CD methodologies and frameworks
- Reusable workflow templates become Client property upon final payment
- Runner infrastructure and configurations transfer to Client

## Service Levels

Service level commitments for this engagement:

- Pipeline execution time: <10 minutes for typical applications
- Deployment success rate: 95%+ for production deployments
- Platform uptime: 99.9% for runner infrastructure
- 30-day warranty on all deliverables from go-live date
- Post-warranty support available under separate managed services agreement

## Liability

Liability terms and limitations:

- Performance guarantees apply to representative application workloads
- Actual performance may vary based on application complexity and size
- Ongoing optimization recommended as application requirements evolve
- Liability caps as agreed in MSA

## Confidentiality

Confidentiality obligations for both parties:

- Both parties agree to maintain strict confidentiality of application code, deployment configurations, and proprietary automation techniques
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
