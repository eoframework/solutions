---
document_title: Detailed Design Document
solution_name: HashiCorp Multi-Cloud Platform
document_version: "1.0"
author: "[ARCHITECT]"
last_updated: "[DATE]"
technology_provider: hashicorp
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This document provides the comprehensive technical design for the HashiCorp Multi-Cloud Platform implementation. It covers the target-state architecture leveraging HashiCorp Terraform Cloud for infrastructure automation, HashiCorp Vault for secrets management, and HashiCorp Consul for service mesh capabilities across AWS, Azure, and GCP environments.

## Purpose

Define the technical architecture and design specifications that will guide the implementation team through deployment, configuration, and validation of the unified multi-cloud infrastructure automation platform.

## Scope

**In-scope:**
- Terraform Cloud deployment on AWS EKS with high availability
- HashiCorp Vault implementation for centralized secrets management
- HashiCorp Consul deployment for service mesh capabilities
- Sentinel policy development for governance and compliance
- Workspace migration from Terraform OSS to Terraform Cloud
- VCS integration with GitHub for GitOps workflows
- Integration with CI/CD pipelines and monitoring systems
- Security controls and compliance implementation

**Out-of-scope:**
- End-user training (covered in Implementation Guide)
- Ongoing support procedures (covered in Operations Runbook)
- Custom Terraform provider development
- Cloud provider account setup or billing management
- Application code development or refactoring

## Assumptions & Constraints

The following assumptions underpin the design and must be validated during implementation.

- AWS account with appropriate permissions for EKS, RDS, and EC2 deployment established
- Azure and GCP accounts with service principal/account credentials available
- GitHub Enterprise or GitHub.com access with webhook configuration permissions
- Existing Terraform code compatible with Terraform Cloud (OSS versions 0.12+)
- Network connectivity between platform and target cloud environments available
- 4-hour RTO, 1-hour RPO requirements apply for disaster recovery

## References

This document should be read in conjunction with the following related materials.

- Statement of Work (SOW)
- Solution Briefing presentation
- HashiCorp Terraform Cloud documentation
- HashiCorp Vault documentation
- AWS Well-Architected Framework

# Business Context

This section establishes the business drivers, success criteria, and compliance requirements that shape the technical design decisions.

## Business Drivers

The solution addresses the following key business objectives identified during discovery.

- **Unified Infrastructure:** Eliminate fragmented multi-cloud tooling and establish consistent provisioning across AWS, Azure, and GCP
- **Automated Governance:** Deploy Sentinel policies for automated security, compliance, and cost controls before changes reach production
- **Centralized Secrets:** Implement HashiCorp Vault for unified secrets management with dynamic cloud credentials and automated rotation
- **Reduced Provisioning Time:** Reduce infrastructure provisioning from 5-7 days to 1-2 days through self-service capabilities
- **Lower Operational Costs:** Reduce infrastructure operations costs by 60% through automation and policy-driven governance

## Workload Criticality & SLA Expectations

The following service level targets define the operational requirements for the production environment and guide infrastructure sizing decisions.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Platform Availability | 99.9% | CloudWatch uptime monitoring | Critical |
| Workspace Run Success | > 98% | Terraform Cloud metrics | High |
| Policy Compliance | > 95% | Sentinel enforcement metrics | Critical |
| Concurrent Runs | 15 runs | Terraform Cloud capacity | High |
| RTO | 4 hours | DR testing validation | High |
| RPO | 1 hour | Backup verification | High |

## Compliance & Regulatory Factors

The solution must adhere to the following regulatory and compliance requirements.

- SOC 2 Type II compliance required for platform handling infrastructure state
- ISO 27001 compliance alignment for security controls
- Encryption at rest (AES-256) and in transit (TLS 1.2+) mandatory
- Audit logging required for all infrastructure changes and secrets access
- Policy enforcement for regulatory compliance frameworks via Sentinel

## Success Criteria

Project success will be measured against the following criteria at go-live.

- 100 Terraform workspaces migrated to centralized platform
- 50 Sentinel policies deployed and enforced across all environments
- 75%+ reduction in infrastructure provisioning time validated
- 95%+ policy compliance rate achieved
- Operations team trained and capable of independent platform management
- HashiCorp Vault dynamic credentials operational for all three clouds

# Current-State Assessment

This section documents the existing environment that the solution will integrate with or replace.

## Application Landscape

The current environment consists of fragmented infrastructure tooling that will be unified.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Application | Purpose | Technology | Status |
|-------------|---------|------------|--------|
| Terraform OSS | Infrastructure provisioning | Terraform CLI | To be migrated |
| CloudFormation | AWS-specific IaC | AWS native | To be replaced |
| ARM Templates | Azure-specific IaC | Azure native | To be replaced |
| Manual Provisioning | GCP resources | Console/gcloud | To be automated |

## Infrastructure Inventory

The current infrastructure consists of the following components that will be managed by the new platform.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| AWS Resources | ~1000 | VPC, EC2, RDS, EKS, S3, IAM | Primary cloud environment |
| Azure Resources | ~800 | VNet, VMs, AKS, Storage | Secondary cloud |
| GCP Resources | ~700 | VPC, Compute, GKE, Storage | Tertiary cloud |
| State Files | 100+ | S3, local, Azure Blob | To be centralized |

## Dependencies & Integration Points

The current environment has the following external dependencies that must be considered.

- GitHub Enterprise for version control and webhooks
- Datadog for monitoring integration
- Slack for notifications
- ServiceNow for change management approval workflows
- Active Directory for SSO authentication

## Network Topology

Current multi-cloud network architecture:
- AWS: Multiple VPCs across us-east-1, eu-west-1, ap-southeast-1
- Azure: Virtual Networks in corresponding regions
- GCP: VPCs with cross-cloud connectivity
- VPN/Direct Connect for hybrid connectivity

## Security Posture

The current security controls provide a baseline that will be enhanced in the target architecture.

- Cloud-native IAM with manual credential management
- No centralized secrets rotation
- Manual policy enforcement through reviews
- Inconsistent compliance across cloud providers
- Ad-hoc audit logging per cloud

## Performance Baseline

Current infrastructure provisioning metrics establish the baseline for improvement targets.

- Average provisioning time: 5-7 days per environment
- Manual approval chain: 2-3 days
- Configuration drift: Unknown, no automated detection
- Compliance rate: ~60-70% (estimated)

# Solution Architecture

The target architecture leverages HashiCorp products to deliver unified multi-cloud infrastructure automation with centralized governance, secrets management, and service mesh capabilities.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

## Architecture Principles

The following principles guide all architectural decisions throughout the solution design.

- **Centralized Platform:** Single platform for all infrastructure provisioning across cloud providers
- **Policy-Driven Automation:** Sentinel policies enforce governance before changes reach production
- **Secrets as Code:** Dynamic credentials via Vault eliminate static credential management
- **Infrastructure as Code:** All platform infrastructure defined in Terraform and version-controlled
- **GitOps Workflows:** VCS-driven automation ensures audit trail and collaboration
- **High Availability:** Multi-node deployment with automatic failover

## Architecture Patterns

The solution implements the following architectural patterns to address scalability and reliability requirements.

- **Primary Pattern:** Centralized platform with distributed execution across cloud providers
- **State Pattern:** Centralized state management in Terraform Cloud with locking
- **Secrets Pattern:** Dynamic short-lived credentials via Vault secrets engines
- **Governance Pattern:** Policy as code with Sentinel for pre-apply validation
- **Mesh Pattern:** Consul service discovery for cross-cloud service communication

## Component Design

The solution comprises the following logical components, each with specific responsibilities and scaling characteristics.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| Terraform Cloud | Infrastructure orchestration | Kubernetes on EKS | RDS, S3, KMS | Horizontal |
| HashiCorp Vault | Secrets management | EC2 HA cluster | KMS, RDS | Horizontal |
| Consul Server | Service mesh control plane | EKS deployment | Vault | Horizontal |
| Sentinel | Policy enforcement | Terraform Cloud | Policy repository | N/A |
| API Gateway | External access | ALB | Terraform Cloud | Managed |
| Monitoring | Observability | CloudWatch, Datadog | All components | Managed |

## Technology Stack

The technology stack has been selected based on requirements for multi-cloud automation, security, and operational excellence.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Infrastructure Automation | Terraform Cloud Business | Centralized state, RBAC, Sentinel policies |
| Secrets Management | HashiCorp Vault Plus | Dynamic credentials, encryption as a service |
| Service Mesh | HashiCorp Consul Enterprise | Cross-cloud service discovery and security |
| Container Orchestration | Amazon EKS | High availability, managed Kubernetes |
| Database | Amazon RDS PostgreSQL | Terraform Cloud and Vault backend storage |
| Monitoring | CloudWatch + Datadog | Comprehensive metrics, logs, alerting |
| Notifications | Slack, PagerDuty | Real-time alerts and incident management |

# Security & Compliance

This section details the security controls, compliance mappings, and governance mechanisms implemented in the solution.

## Identity & Access Management

Access control follows a zero-trust model with centralized identity management.

- **Authentication:** SSO via SAML 2.0 with enterprise identity provider
- **Authorization:** Role-based access control (RBAC) for all Terraform Cloud workspaces
- **MFA:** Required for all platform access
- **Service Accounts:** HashiCorp Vault dynamic credentials for cloud provider access
- **API Security:** Team API tokens with automatic expiration

### Role Definitions

The following roles define access levels within the system, following the principle of least privilege.

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| Admin | Full platform administration | All workspaces and settings |
| Security | Policy management, Vault administration | Security-related resources |
| Operator | Workspace management, trigger runs | Assigned workspaces |
| Viewer | Read-only access to runs and state | Assigned workspaces |
| Auditor | Read-only access, audit logs | All workspaces (no apply) |

## Secrets Management

All sensitive credentials are managed through HashiCorp Vault.

- Centralized Vault cluster for all secrets across clouds
- Dynamic credential generation for AWS, Azure, GCP
- Automatic credential rotation (1-hour default TTL)
- Encryption as a service for sensitive configuration data
- No static credentials in code or environment variables
- Audit logging for all secrets access

## Network Security

Network security implements defense-in-depth with multiple layers of protection.

- **VPC Isolation:** Platform deployed in dedicated VPC with private subnets
- **Security Groups:** Restrictive inbound/outbound rules for all components
- **VPC Endpoints:** Private connectivity to AWS services (S3, KMS, RDS)
- **TLS:** All communication encrypted with TLS 1.2+
- **Network Policies:** Kubernetes network policies for pod isolation

## Data Protection

Data protection controls ensure confidentiality and integrity throughout the data lifecycle.

- **State Encryption:** All Terraform state encrypted at rest with KMS
- **Transit Encryption:** TLS 1.2+ for all platform communication
- **Vault Auto-Unseal:** AWS KMS for secure Vault initialization
- **Sensitive Variable Masking:** Credentials masked in Terraform Cloud logs
- **Backup Encryption:** All backups encrypted with customer-managed keys

## Compliance Mappings

The following table maps compliance requirements to specific implementation controls.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| SOC 2 | Access control | RBAC, SSO, MFA, audit logging |
| SOC 2 | Encryption | KMS encryption, TLS 1.2+ |
| SOC 2 | Change management | Sentinel policies, approval workflows |
| ISO 27001 | Asset management | Resource tagging enforcement |
| ISO 27001 | Access control | Least privilege, dynamic credentials |

## Audit Logging & SIEM Integration

Comprehensive audit logging supports security monitoring and compliance requirements.

- Terraform Cloud audit logs for all infrastructure changes
- HashiCorp Vault audit logs for all secrets access and authentication
- CloudWatch Logs for platform component logging
- CloudTrail for AWS API calls
- Log retention: 90 days hot, 1 year cold storage

# Data Architecture

This section defines the data model, storage strategy, and governance controls for the solution.

## Data Model

### Conceptual Model

The solution manages the following core data entities:
- **Workspaces:** Terraform workspace configurations and settings
- **State Files:** Infrastructure state representing managed resources
- **Secrets:** Dynamic and static credentials for cloud access
- **Policies:** Sentinel policies for governance enforcement
- **Audit Logs:** All platform activity for compliance

### Logical Model

The logical data model defines the primary entities and their relationships within the system.

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| Workspace | ID, name, VCS config, variables | Has many Runs, State versions | 100+ |
| State | ID, workspace_id, version, resources | Belongs to Workspace | 2 TB |
| Secret | Path, type, TTL, metadata | Belongs to Secrets Engine | 500+ |
| Policy Set | ID, name, policies, workspaces | Has many Policies, Workspaces | 50+ |
| Audit Event | ID, timestamp, user, action, resource | References all entities | 10M/year |

## Data Flow Design

1. **Infrastructure Request:** Developer commits Terraform code to GitHub
2. **VCS Webhook:** GitHub triggers Terraform Cloud run
3. **Credential Retrieval:** Terraform Cloud fetches dynamic credentials from Vault
4. **Policy Check:** Sentinel policies evaluated before plan/apply
5. **Execution:** Terraform provisions/modifies infrastructure
6. **State Update:** State stored in Terraform Cloud with versioning
7. **Notification:** Results sent to Slack/ServiceNow

## Data Migration Strategy

Data migration follows a phased approach to minimize risk and ensure integrity.

- **Approach:** Phased workspace migration with parallel run validation
- **State Migration:** Remote state migration from S3/local to Terraform Cloud
- **Validation:** Resource count verification, drift detection
- **Rollback:** State versioning enables rollback if needed

## Data Governance

Data governance policies ensure proper handling, retention, and quality management.

- **Classification:** State files contain infrastructure secrets (Confidential)
- **Retention:** State versions retained per workspace policy
- **Access:** RBAC controls state access per workspace
- **Backup:** Daily encrypted backups with 7-day retention

# Integration Design

This section documents the integration patterns, APIs, and external system connections.

## External System Integrations

The solution integrates with the following external systems using standardized protocols and error handling.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| GitHub | VCS | Webhooks | JSON | Retry with backoff | 99.9% |
| Datadog | Monitoring | REST API | JSON | Circuit breaker | 99.9% |
| Slack | Notifications | Webhooks | JSON | Dead letter queue | 99.9% |
| ServiceNow | Change Mgmt | REST API | JSON | Retry with backoff | 99.5% |

## API Design

Terraform Cloud and Vault provide REST APIs for integration.

- **Terraform Cloud API:** Workspace management, run triggers, state access
- **Vault API:** Secrets retrieval, authentication, audit queries
- **Authentication:** API tokens with team-based access control
- **Rate Limiting:** Configurable per organization

### API Endpoints

The following REST API endpoints provide programmatic access to core system functionality.

<!-- TABLE_CONFIG: widths=[15, 30, 20, 35] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | /api/v2/workspaces | Bearer | List organization workspaces |
| POST | /api/v2/runs | Bearer | Queue a new Terraform run |
| GET | /api/v2/runs/{id} | Bearer | Get run status and details |
| GET | /v1/secret/data/{path} | Vault Token | Retrieve secret from Vault |

## Authentication & SSO Flows

Single sign-on provides seamless authentication across all platform components.

- SAML 2.0 federation with enterprise identity provider
- Terraform Cloud organization-level SSO enforcement
- Vault authentication via OIDC or LDAP
- Team membership synced from identity provider groups

## Messaging & Event Patterns

Event-driven integration enables loose coupling and reliable notification.

- **VCS Webhooks:** GitHub to Terraform Cloud for run triggers
- **Run Notifications:** Terraform Cloud to Slack for run status
- **Change Management:** Terraform Cloud to ServiceNow for approvals
- **Alerting:** CloudWatch/Datadog to PagerDuty for incidents

# Infrastructure & Operations

This section covers the infrastructure design, deployment architecture, and operational procedures.

## Network Design

The virtual network architecture provides isolation and security through segmentation.

- **VPC CIDR:** 10.100.0.0/16
- **Public Subnets:** 10.100.1.0/24, 10.100.2.0/24 (load balancers)
- **Private Subnets:** 10.100.10.0/24, 10.100.11.0/24 (EKS nodes)
- **Database Subnets:** 10.100.20.0/24, 10.100.21.0/24 (RDS)

## Compute Sizing

Instance sizing has been determined based on workload requirements and concurrent run capacity.

<!-- TABLE_CONFIG: widths=[25, 20, 20, 20, 15] -->
| Component | Instance Type | vCPU | Memory | Count |
|-----------|---------------|------|--------|-------|
| EKS Nodes | t3.xlarge | 4 | 16 GB | 3 |
| Vault Nodes | t3.medium | 2 | 4 GB | 3 |
| RDS | db.t3.large | 2 | 8 GB | 1 (Multi-AZ) |
| ALB | Managed | N/A | N/A | 1 |

## High Availability Design

The solution eliminates single points of failure through redundancy at every tier.

- Multi-AZ deployment for all platform components
- EKS cluster with auto-healing and node replacement
- Vault HA cluster with auto-unseal
- RDS Multi-AZ with automated failover
- ALB with health checks and automatic routing

## Disaster Recovery

Disaster recovery capabilities ensure business continuity in the event of regional failure.

- **RPO:** 1 hour (continuous replication)
- **RTO:** 4 hours (automated recovery procedures)
- **Backup:** Daily RDS snapshots, Vault auto-snapshots
- **DR Site:** Cross-region backup replication

## Monitoring & Alerting

Comprehensive monitoring provides visibility across infrastructure, applications, and business metrics.

- **Infrastructure:** CloudWatch metrics for EKS, RDS, EC2
- **Application:** Terraform Cloud run metrics, Vault audit logs
- **Business:** Workspace counts, policy compliance, run success rates
- **Alerting:** Datadog + PagerDuty with escalation policies

### Alert Definitions

The following alerts have been configured to ensure proactive incident detection and response.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| Platform Down | Uptime < 99% for 5 min | Critical | Page on-call |
| Run Queue Backlog | Queue > 50 for 15 min | Warning | Scale workers |
| Vault Unavailable | 3+ health check failures | Critical | Page on-call |
| Policy Failures | > 10% failure rate | Warning | Review policies |

## Logging & Observability

Centralized logging and distributed tracing enable rapid troubleshooting and analysis.

- CloudWatch Logs for all platform components
- Terraform Cloud audit logs for run history
- Vault audit logs for secrets access
- Custom dashboards in Datadog

## Cost Model

The estimated monthly infrastructure costs are based on production workload requirements.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Monthly Estimate | Optimization | Savings |
|----------|------------------|--------------|---------|
| EKS Cluster | $1,314 | Reserved instances | 30% |
| RDS | $912 | Reserved capacity | 25% |
| Vault (EC2) | $657 | Reserved instances | 30% |
| Networking | $300 | NAT optimization | 20% |

# Implementation Approach

This section outlines the deployment strategy, tooling, and sequencing for the implementation.

## Migration/Deployment Strategy

The deployment strategy minimizes risk through phased rollout with validation gates.

- **Approach:** Phased workspace migration with parallel operation
- **Pattern:** Pilot (25 workspaces) → Expand (75) → Full (100)
- **Validation:** State integrity verification at each phase
- **Rollback:** Terraform state versioning enables rollback

## Sequencing & Wave Planning

The implementation follows a phased approach with clear exit criteria to ensure quality and minimize risk.

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Foundation: Platform deployment, Vault setup, 25 workspaces | 3 months | Platform operational, pilot validated |
| 2 | Expansion: 75 more workspaces, Sentinel policies | 3 months | 100 workspaces, policies enforced |
| 3 | Optimization: Consul mesh, advanced automation | 3 months | Full platform capabilities, training complete |

## Tooling & Automation

The following tools provide the automation foundation for infrastructure provisioning, deployment, and operations.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Infrastructure as Code | Terraform | Platform infrastructure provisioning |
| Configuration | Ansible | Vault and Consul configuration |
| CI/CD | GitHub Actions | Automated testing and deployment |
| Secrets | HashiCorp Vault | Credential management |
| Policy | Sentinel | Governance enforcement |

## Cutover Approach

The cutover strategy balances risk mitigation with project timeline requirements.

- **Type:** Progressive migration with parallel operation
- **Duration:** 2-week parallel run per workspace wave
- **Validation:** Resource count, state integrity verification
- **Decision Point:** Go/no-go after pilot wave validation

## Downtime Expectations

Service availability impacts during implementation have been minimized through careful planning.

- **Planned Downtime:** Zero infrastructure downtime during migration
- **Terraform OSS:** Remains operational during transition
- **Migration Window:** Workspaces switched during maintenance windows
- **Rollback:** Immediate rollback capability to original state backend

## Rollback Strategy

Rollback procedures are documented and tested to enable rapid recovery if issues arise.

- State file rollback via Terraform Cloud versioning
- Workspace rollback to Terraform OSS backend
- Vault rollback via auto-snapshots
- Maximum rollback window: 7 days post-migration

# Appendices

## Architecture Diagrams

The following diagrams provide visual representation of the solution architecture.

- Solution Architecture Diagram (included in Solution Architecture section)
- Network Topology Diagram
- Data Flow Diagram
- Security Architecture Diagram

## Naming Conventions

All cloud resources follow standardized naming conventions to ensure consistency and enable automated resource management.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Workspace | `{env}-{app}-{cloud}` | `prod-webapp-aws` |
| Sentinel Policy | `{domain}-{control}` | `security-require-encryption` |
| Vault Path | `{cloud}/{env}/{service}` | `aws/prod/rds` |
| EKS Cluster | `{project}-{env}-eks` | `tfc-prod-eks` |

## Tagging Standards

Resource tagging enables cost allocation, operational automation, and compliance reporting across the environment.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Tag | Required | Example Values |
|-----|----------|----------------|
| Environment | Yes | dev, staging, prod |
| Project | Yes | multi-cloud-platform |
| Owner | Yes | platform-team |
| CostCenter | Yes | CC-INFRA-001 |
| ManagedBy | Yes | terraform-cloud |

## Risk Register

The following risks have been identified during the design phase with corresponding mitigation strategies.

<!-- TABLE_CONFIG: widths=[25, 15, 15, 45] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| State corruption during migration | Low | High | Parallel validation, versioning, rollback plan |
| Policy breaks existing workflows | Medium | Medium | Advisory mode first, tuning period |
| Credential exposure | Low | Critical | Vault dynamic credentials, short TTL |
| Platform unavailability | Low | High | HA deployment, DR procedures |
| User adoption resistance | Medium | Medium | Training, self-service templates, demos |

## Glossary

The following terms and acronyms are used throughout this document.

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| GitOps | Operational framework using Git as single source of truth |
| HCL | HashiCorp Configuration Language |
| IaC | Infrastructure as Code |
| RBAC | Role-Based Access Control |
| Sentinel | HashiCorp policy-as-code framework |
| State | Terraform's record of managed infrastructure |
| TTL | Time To Live (credential expiration) |
| VCS | Version Control System |
| Workspace | Terraform Cloud unit of infrastructure management |
