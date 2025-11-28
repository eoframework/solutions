---
document_title: Detailed Design Document
solution_name: Google Cloud Landing Zone
document_version: "1.0"
author: Solution Architect
last_updated: 2025-11-27
technology_provider: google
client_name: "[Client Name]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

## Document Purpose

This Detailed Design Document provides comprehensive technical specifications for the Google Cloud Landing Zone implementation. It defines the architecture, security controls, network design, and governance framework required to establish a secure, scalable multi-project foundation on Google Cloud Platform.

## Scope and Audience

This document is intended for technical architects, platform engineers, security specialists, and operations teams responsible for implementing and maintaining the GCP landing zone. It covers organization structure, network architecture, security baseline, automation framework, and operational procedures for a 10-project foundation supporting 5 application teams.

## Assumptions

The following assumptions apply to this design:

- Client has approved GCP Organization creation or will provide existing Organization Admin access
- Dedicated Interconnect ISP coordination can be completed within 6 weeks of project start
- Cloud Identity Premium licenses are available for all administrators requiring GCP access
- On-premises network team is available for Interconnect and BGP configuration
- Security and compliance teams will participate in organization policy definition

## References

<!-- TABLE_CONFIG: widths=[30, 50, 20] -->
| Document | Description | Version |
|----------|-------------|---------|
| Statement of Work | Scope, timeline, deliverables for landing zone engagement | 1.0 |
| Solution Briefing | Architecture overview and business value proposition | 1.0 |
| GCP Cloud Foundation Toolkit | Google best practices for landing zone automation | Latest |
| CIS Google Cloud Foundation Benchmark | Security baseline compliance requirements | 2.0 |

# Business Context

## Business Drivers

The landing zone implementation addresses critical business needs identified during discovery:

- **Inconsistent Security Controls**: Each team implements security differently, creating audit gaps and compliance risks. The landing zone enforces consistent security through organization policies.
- **Manual Project Provisioning**: 6-8 week delays for new project creation blocking innovation and team velocity. The landing zone enables self-service provisioning in under 1 hour.
- **No Centralized Governance**: Lack of organization policies, billing controls, and resource management. The landing zone provides centralized governance with distributed execution.
- **Shadow IT Risk**: Teams creating ungoverned projects outside enterprise standards. The landing zone ensures all projects follow security and compliance requirements.
- **Hybrid Connectivity Gaps**: No standardized path to on-premises systems requiring ad-hoc VPN configurations. The landing zone provides Dedicated Interconnect with consistent connectivity.

## Business Outcomes

The landing zone delivers measurable business value:

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Outcome | Target | Measurement |
|---------|--------|-------------|
| Project Provisioning Speed | 95% reduction (6 weeks to <1 hour) | Time from request to operational project |
| Security Compliance | 100% SOC 2 and PCI-DSS controls | Security Command Center findings |
| Policy Enforcement | Zero misconfigurations | Organization policy violations |
| Team Onboarding | 5 teams in 90 days | Projects deployed and operational |
| Hybrid Connectivity | 99.9% uptime, <5ms latency | Interconnect monitoring metrics |
| Platform Self-Sufficiency | 30 days post-go-live | Client team handling operations independently |

## Service Level Agreements

The landing zone platform targets the following SLAs:

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Service | Availability | Latency | Recovery |
|---------|--------------|---------|----------|
| Shared VPC Network | 99.99% | N/A | N/A |
| Dedicated Interconnect | 99.9% | <5ms to on-prem | 4-hour RTO |
| Project Provisioning | 99% success rate | <1 hour | Manual retry |
| Security Monitoring | 99.9% | Real-time alerting | N/A |
| Cloud Logging | 99.9% | <5 min ingestion | 1-hour RPO |

## Compliance Requirements

The landing zone supports the following compliance frameworks:

- **SOC 2 Type II**: Security, availability, and processing integrity controls through organization policies and SCC Premium
- **PCI-DSS**: Payment card industry compliance through network segmentation, encryption, and access controls
- **Data Residency**: US-only resource location constraints through organization policy

## Success Criteria

The implementation succeeds when the following criteria are met:

- 10 GCP projects operational under Cloud Foundation Toolkit management
- 5 application teams self-service provisioning without manual intervention
- 50+ organization policies enforced with zero violations
- Dedicated Interconnect operational with <5ms latency validated
- Security Command Center Premium showing zero critical findings
- Platform team certified and self-sufficient within 30 days

# Current-State Assessment

## Existing GCP Environment

The client currently operates with limited GCP governance:

- **Organization Structure**: No formal GCP Organization; projects created ad-hoc under individual billing accounts
- **Network Architecture**: No Shared VPC; each project configures networking independently
- **Security Controls**: Inconsistent IAM policies; no organization-wide security baseline
- **Hybrid Connectivity**: Ad-hoc VPN connections with varying configurations
- **Monitoring**: Project-level logging only; no centralized observability

## Identified Gaps

The assessment identified the following gaps requiring remediation:

<!-- TABLE_CONFIG: widths=[25, 40, 35] -->
| Area | Current State | Target State |
|------|---------------|--------------|
| Organization | Ad-hoc projects | GCP Organization with folder hierarchy |
| Governance | Manual approval processes | Automated policy enforcement |
| Network | Per-project VPCs | Shared VPC hub-spoke |
| Connectivity | VPN tunnels | Dedicated Interconnect 10 Gbps |
| Security | Inconsistent controls | SCC Premium + Chronicle SIEM |
| Provisioning | 6-8 weeks manual | <1 hour automated |
| Compliance | Audit gaps | Continuous compliance monitoring |

## Migration Dependencies

The following dependencies affect migration planning:

- Existing workloads remain in current projects during Phase 1
- New workloads deploy to landing zone projects starting Week 11
- Legacy project cleanup scheduled for Phase 2 (post-go-live)
- IAM role mapping required before team onboarding

# Solution Architecture

## Target Architecture Overview

The Google Cloud Landing Zone implements a hub-spoke network architecture with centralized security and governance. The design enables 10 initial projects across 5 teams with a growth path to 75+ projects without re-architecture.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

The architecture comprises five layers:

1. **Organization Foundation**: GCP Organization, folder hierarchy, billing accounts
2. **Identity & Access**: Cloud Identity Premium, SAML SSO, directory sync
3. **Network Layer**: Shared VPC hub, Dedicated Interconnect, Cloud NAT
4. **Security Layer**: SCC Premium, Chronicle SIEM, Cloud Armor, organization policies
5. **Observability Layer**: Cloud Logging, Cloud Monitoring, FinOps dashboards

## Architecture Patterns

The landing zone follows Google Cloud best practices and Cloud Foundation Toolkit patterns:

- **Hub-Spoke Network**: Centralized network management with Shared VPC host project
- **Folder-Based Governance**: Environment separation (dev/staging/prod) through folder hierarchy
- **Policy-as-Code**: Organization policies deployed via Terraform for version control
- **Least Privilege IAM**: Role-based access with just-in-time privileged access
- **Defense in Depth**: Multiple security layers from network to application

## Component Architecture

### Organization Structure

The GCP Organization implements a 3-tier folder hierarchy:

```
Organization (example.com)
├── folders/
│   ├── development/
│   │   └── projects/ (dev workloads)
│   ├── staging/
│   │   └── projects/ (staging workloads)
│   └── production/
│       └── projects/ (prod workloads)
├── shared-services/
│   ├── host-vpc-project (Shared VPC host)
│   ├── logging-project (centralized logs)
│   ├── security-project (SCC, Chronicle)
│   └── automation-project (CI/CD, Terraform)
```

### Network Architecture

The Shared VPC hub-spoke design provides centralized network management:

<!-- TABLE_CONFIG: widths=[20, 25, 25, 30] -->
| Component | Region | CIDR | Purpose |
|-----------|--------|------|---------|
| Hub VPC | us-central1 | 10.0.0.0/16 | Shared VPC host |
| Subnet - Dev | us-central1 | 10.0.1.0/24 | Development workloads |
| Subnet - Staging | us-central1 | 10.0.2.0/24 | Staging workloads |
| Subnet - Prod | us-central1 | 10.0.3.0/24 | Production workloads |
| Subnet - Shared | us-central1 | 10.0.10.0/24 | Shared services |
| Hub VPC | us-east1 | 10.1.0.0/16 | DR region |
| Hub VPC | us-west1 | 10.2.0.0/16 | West region |

### Dedicated Interconnect

Hybrid connectivity configuration:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Parameter | Value | Description |
|-----------|-------|-------------|
| Interconnect Capacity | 10 Gbps | Dedicated Interconnect circuit |
| VLAN Attachments | 4 | Redundant attachments for HA |
| BGP ASN (GCP) | 16550 | Google Cloud ASN |
| BGP ASN (On-prem) | [Client ASN] | Client router ASN |
| Advertised Routes | 10.0.0.0/8 | All GCP subnets |
| Target Latency | <5ms | Round-trip to on-premises |

## Scalability Design

The landing zone scales from 10 to 75+ projects without re-architecture:

- **Small (Current)**: 10 projects, 5 teams, 500 GB/month logging
- **Medium (6 months)**: 30 projects, 15 teams, 1.5 TB/month logging
- **Large (12 months)**: 75+ projects, 20+ teams, 5 TB/month logging

Scaling requires only folder creation and project provisioning via Cloud Foundation Toolkit.

# Security & Compliance

## Identity and Access Management

The IAM strategy implements least-privilege access with role-based controls:

### Authentication

- Cloud Identity Premium for all GCP users
- SAML SSO integration with corporate identity provider
- Multi-factor authentication (2SV) required for all admin access
- Service accounts with workload identity for applications

### Authorization

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Role | Scope | Permissions |
|------|-------|-------------|
| Organization Admin | Organization | Full organization management |
| Folder Admin | Environment folder | Folder and project management |
| Project Creator | Folder | Create projects within folder |
| Network Admin | Host VPC project | Shared VPC administration |
| Security Admin | Security project | SCC and Chronicle management |
| Platform Admin | Automation project | Terraform and CI/CD management |
| Developer | Service project | Application deployment |

## Security Controls

### Security Command Center Premium

SCC Premium provides continuous security monitoring:

- **Security Health Analytics**: Misconfiguration detection
- **Web Security Scanner**: Application vulnerability scanning
- **Container Threat Detection**: GKE security monitoring
- **Event Threat Detection**: Anomaly detection for audit logs
- **Compliance Monitoring**: CIS benchmark validation

### Chronicle SIEM

Chronicle provides advanced security analytics:

- **Log Ingestion**: 100 GB/month from Cloud Audit Logs
- **Threat Detection**: Pre-built detection rules for GCP
- **Incident Investigation**: Timeline analysis and correlation
- **Integration**: Security Command Center findings

### Organization Policies

50+ organization policy constraints enforce compliance:

<!-- TABLE_CONFIG: widths=[35, 30, 35] -->
| Policy | Constraint | Effect |
|--------|------------|--------|
| Resource Location | constraints/gcp.resourceLocations | US regions only |
| VM External IP | constraints/compute.vmExternalIpAccess | Deny external IPs |
| Service Account Keys | constraints/iam.disableServiceAccountKeyCreation | Block key creation |
| Uniform Bucket Access | constraints/storage.uniformBucketLevelAccess | Require uniform ACLs |
| VPC Peering | constraints/compute.restrictVpcPeering | Restrict to hub VPC |
| Shared VPC Projects | constraints/compute.restrictSharedVpcHostProjects | Limit host projects |

## Encryption

All data encryption uses customer-managed keys:

- **At Rest**: Cloud KMS with CMEK for all supported services
- **In Transit**: TLS 1.2+ for all communications
- **Key Rotation**: Automatic 90-day rotation
- **Key Hierarchy**: Separate keys per environment (dev/staging/prod)

## Compliance Mapping

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| SOC 2 CC6.1 | Logical access controls | IAM roles, organization policies |
| SOC 2 CC6.6 | System boundaries | VPC Service Controls, firewall rules |
| SOC 2 CC7.2 | Security monitoring | SCC Premium, Chronicle SIEM |
| PCI-DSS 1.3 | Network segmentation | Shared VPC subnets, firewall rules |
| PCI-DSS 3.4 | Data encryption | Cloud KMS CMEK |
| PCI-DSS 10.1 | Audit logging | Cloud Audit Logs, Cloud Logging |

# Data Architecture

## Data Model

The landing zone manages the following data types:

- **Infrastructure State**: Terraform state files in Cloud Storage
- **Audit Logs**: Admin activity, data access, system events
- **Security Findings**: SCC findings, Chronicle alerts
- **Metrics**: Cloud Monitoring time-series data
- **Cost Data**: Billing exports to BigQuery

## Data Storage

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Data Type | Storage | Retention | Encryption |
|-----------|---------|-----------|------------|
| Terraform State | Cloud Storage | Indefinite | CMEK |
| Audit Logs | Cloud Logging | 365 days | Google-managed |
| Log Exports | BigQuery | 7 years | CMEK |
| SCC Findings | SCC | 90 days | Google-managed |
| Chronicle Logs | Chronicle | 12 months | Google-managed |
| Metrics | Cloud Monitoring | 24 months | Google-managed |
| Billing Data | BigQuery | 3 years | CMEK |

## Data Governance

Data governance policies ensure proper data handling:

- **Classification**: All logs classified by sensitivity level
- **Access Control**: IAM policies restrict log access by role
- **Retention**: Automated lifecycle policies per data type
- **Audit**: Cloud Audit Logs track all data access

# Integration Design

## API Integrations

The landing zone integrates with external systems:

### Identity Provider Integration

- **Protocol**: SAML 2.0
- **Provider**: Corporate Active Directory via ADFS or Azure AD
- **Sync**: Google Cloud Directory Sync (GCDS) for user provisioning
- **Attributes**: Email, display name, group membership

### On-Premises Connectivity

- **Type**: Dedicated Interconnect
- **Bandwidth**: 10 Gbps
- **Protocol**: BGP for dynamic routing
- **Failover**: 4 VLAN attachments for redundancy

## Service Integrations

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Integration | Type | Direction | Purpose |
|-------------|------|-----------|---------|
| Cloud Identity | SAML SSO | Inbound | User authentication |
| GCDS | Directory Sync | Outbound | User provisioning |
| Dedicated Interconnect | BGP | Bidirectional | Hybrid connectivity |
| Cloud Logging | Export | Outbound | SIEM integration |
| BigQuery | Export | Outbound | Compliance analytics |

# Infrastructure & Operations

## Compute Resources

Landing zone infrastructure components:

<!-- TABLE_CONFIG: widths=[25, 20, 20, 35] -->
| Component | Type | Quantity | Purpose |
|-----------|------|----------|---------|
| Cloud NAT | Gateway | 3 | Internet egress per region |
| Cloud Router | Router | 6 | BGP routing (2 per region) |
| Internal LB | Load Balancer | 2 | Shared services |
| Cloud IDS | Endpoint | 3 | Intrusion detection |

## Network Infrastructure

Network components across 3 regions:

- **Shared VPC**: Host project with service project attachments
- **Cloud NAT**: Outbound internet access for private instances
- **Cloud DNS**: Private zones for internal service discovery
- **Cloud Armor**: DDoS protection for internet-facing services

## Monitoring Strategy

Comprehensive monitoring ensures operational visibility:

### Cloud Monitoring

- **Dashboards**: Platform health, network, security, costs
- **Alerting**: Critical alerts to PagerDuty/email
- **SLOs**: Uptime and latency tracking

### Alerting Policies

<!-- TABLE_CONFIG: widths=[25, 30, 20, 25] -->
| Alert | Condition | Severity | Notification |
|-------|-----------|----------|--------------|
| Interconnect Down | Uptime <99% | Critical | PagerDuty |
| SCC Critical Finding | Any critical finding | High | Email + Slack |
| Policy Violation | Organization policy denied | Medium | Email |
| Budget Exceeded | >80% of budget | Medium | Email |
| Log Ingestion Spike | >2x normal volume | Low | Email |

## High Availability

The landing zone implements HA at multiple levels:

- **Network**: Multi-region Shared VPC with Cloud NAT per region
- **Connectivity**: 4 VLAN attachments for Interconnect redundancy
- **Security**: Multi-region SCC and Chronicle deployment
- **State**: Terraform state in multi-region Cloud Storage bucket

## Disaster Recovery

Recovery procedures for landing zone components:

<!-- TABLE_CONFIG: widths=[25, 20, 20, 35] -->
| Component | RTO | RPO | Recovery Method |
|-----------|-----|-----|-----------------|
| Shared VPC | 1 hour | N/A | Terraform rebuild |
| Interconnect | 4 hours | N/A | VLAN failover |
| Organization Policies | 15 min | N/A | Terraform apply |
| Cloud Logging | 4 hours | 1 hour | Automatic recovery |
| Terraform State | 15 min | 1 hour | Object versioning |

## Cost Optimization

FinOps practices minimize cloud spend:

- **Committed Use Discounts**: 1-year CUDs for Interconnect
- **Budget Alerts**: Per-project and folder-level budgets
- **Cost Allocation**: Labels for chargeback to business units
- **Rightsizing**: Recommendations from SCC and Cost Management
- **Lifecycle Policies**: Automatic log archival to Coldline storage

# Implementation Approach

## Migration Strategy

The implementation follows a pilot-then-scale approach:

1. **Foundation Build (Weeks 1-10)**: Deploy organization, network, security without impacting existing workloads
2. **Pilot Onboarding (Week 11)**: 2 teams provision projects through Cloud Foundation Toolkit
3. **Validation (Week 12)**: Pilot teams validate applications, network, security
4. **Hypercare (Weeks 13-16)**: Daily support for stable operations

## Tooling

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | 1.5+ | Infrastructure as code |
| Cloud Foundation Toolkit | Latest | GCP best practice modules |
| Cloud Build | N/A | CI/CD for Terraform |
| Cloud Source Repositories | N/A | Git repository for IaC |
| Google Cloud CLI | Latest | Command-line operations |

## Implementation Sequence

Phase 1 (Weeks 1-4): Foundation

- GCP Organization setup
- Folder hierarchy creation
- Cloud Identity integration
- Shared VPC deployment

Phase 2 (Weeks 5-8): Security & Network

- SCC Premium configuration
- Chronicle SIEM integration
- Organization policies
- Dedicated Interconnect

Phase 3 (Weeks 9-12): Automation & Onboarding

- Cloud Foundation Toolkit modules
- Centralized logging
- Pilot team projects
- Training and handover

## Cutover Plan

Go-live execution follows a controlled approach:

- **Pre-Cutover**: Final UAT sign-off, security validation
- **Week 11**: Provision pilot team projects
- **Week 12**: Deploy sample workloads, validate connectivity
- **Hypercare**: Daily monitoring, rapid issue resolution

Rollback procedures documented in Operations Runbook.

# Appendices

## Architecture Diagrams

Additional diagrams are available in the assets folder:

- Network topology diagram
- Security architecture diagram
- IAM hierarchy diagram
- Data flow diagram

## Naming Conventions

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource | Pattern | Example |
|----------|---------|---------|
| Folder | {env} | development, staging, production |
| Project | {org}-{env}-{app}-{id} | acme-prod-app1-001 |
| VPC | {org}-{env}-vpc | acme-shared-vpc |
| Subnet | {org}-{env}-{region}-{purpose} | acme-prod-usc1-app |
| Service Account | {app}-{role}@{project} | app1-runner@acme-prod-app1-001 |
| KMS Key | {env}-{purpose}-key | prod-storage-key |

## Risk Register

<!-- TABLE_CONFIG: widths=[20, 30, 15, 35] -->
| Risk | Description | Probability | Mitigation |
|------|-------------|-------------|------------|
| ISP Delay | Interconnect provisioning exceeds 6 weeks | Medium | Early coordination, VPN fallback |
| IAM Resistance | Teams resist least-privilege model | Medium | Training, gradual rollout |
| Policy Conflicts | Organization policies block legitimate use | Low | Exception workflow, testing |
| Chronicle Noise | High false positive rate | Medium | Rule tuning, baseline period |
| Terraform State | State corruption or loss | Low | Versioning, backup, locking |

## Glossary

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| CFT | Cloud Foundation Toolkit - Google's Terraform modules for landing zones |
| CMEK | Customer-Managed Encryption Keys - encryption keys managed by customer |
| GCDS | Google Cloud Directory Sync - syncs users from AD to Cloud Identity |
| SCC | Security Command Center - GCP's security and risk management service |
| Shared VPC | Virtual Private Cloud shared across multiple projects |
| VLAN Attachment | Connection between Interconnect and Cloud Router |
