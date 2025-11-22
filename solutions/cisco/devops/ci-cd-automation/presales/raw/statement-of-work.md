---
# Document Metadata (Simplified)
document_title: Statement of Work
technology_provider: Cisco Systems
project_name: Cisco Network CI/CD Automation
client_name: [Client Name]
client_contact: [Contact Name | Email | Phone]
consulting_company: [Consulting Company Name]
consultant_contact: [Contact Name | Email | Phone]
opportunity_no: [OPP-YYYY-###]
document_date: [Month DD, YYYY]
version: [1.0]
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for the Cisco Network CI/CD Automation project for [Client Name]. This engagement will deliver Infrastructure as Code (IaC) automation for network operations, reducing configuration errors by 85% and accelerating device provisioning from 4-6 hours to 15 minutes through GitOps workflows.

**Project Duration:** 16 weeks

---

# Background & Objectives

## Current State

[Client Name] currently operates network infrastructure with manual CLI-based configuration and change management. Key challenges include:
- **Manual Configuration Errors:** 15% configuration error rate due to manual CLI changes
- **Slow Provisioning:** Network device deployment takes 4-6 hours per device with manual configuration
- **Limited Audit Trails:** Difficulty tracking who made what changes and when for compliance
- **Configuration Drift:** Inconsistent configurations across 100+ network devices
- **Deployment Risk:** No testing or validation before production changes

## Business Objectives

- **Eliminate Manual Errors:** Reduce configuration error rate from 15% to under 2% through automated validation
- **Accelerate Provisioning:** Enable 95% faster device provisioning (15 minutes vs 4-6 hours) with zero-touch deployment
- **Achieve Compliance:** Implement complete Git audit trails meeting PCI DSS and compliance requirements
- **Standardize Configurations:** Ensure 100% configuration consistency through standardized templates
- **Enable GitOps:** Implement Infrastructure as Code with CI/CD pipelines for network automation
- **Reduce Labor Costs:** Save $47K annually through automated deployment and reduced troubleshooting

## Success Metrics

- 85% reduction in configuration errors (15% → <2%)
- 95% faster device provisioning (4-6 hours → 15 minutes)
- 100% configuration audit trail through Git
- ROI realization within 24 months
- 60% faster troubleshooting with complete change history

---

# Scope of Work

## In Scope

- Network automation assessment and tool selection
- GitLab deployment and CI/CD runner infrastructure
- NetBox IPAM deployment and device inventory import
- Development of 6 core Ansible playbooks (VLAN, ACL, interface, routing, QoS, compliance)
- CI/CD pipeline configuration with syntax validation
- Secrets management implementation (Vault or GitLab)
- Terraform module development for ACI/DCNM/Meraki (optional)
- ServiceNow integration for change management (optional)
- Lab testing environment setup (GNS3 or CML)
- Team training on Ansible, Git workflows, and CI/CD (40 hours)
- Pilot deployment with 10 devices
- Phased rollout to remaining 90 devices
- 4-week hypercare support period

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_PARAMETERS_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Primary Features/Capabilities | Ansible + GitLab CI/CD for 100 devices |
| Solution Scope | Customization Level | Standard playbooks and templates |
| Integration | External System Integrations | 2 systems (Git + NetBox) |
| Integration | Data Sources | Network device configs |
| User Base | Total Users | 5 network engineers |
| User Base | User Roles | 2 roles (developer + operator) |
| Data Volume | Data Processing Volume | 100 device configs |
| Data Volume | Data Storage Requirements | 50 GB (Git + backups) |
| Technical Environment | Deployment Regions | Single data center |
| Technical Environment | Availability Requirements | Standard (99%) |
| Technical Environment | Infrastructure Complexity | Basic network (single platform) |
| Security & Compliance | Security Requirements | Basic Git auth and secrets |
| Security & Compliance | Compliance Frameworks | Change tracking only |
| Performance | Performance Requirements | Standard deployment speed |
| Environment | Deployment Environments | Production only |
<!-- END SCOPE_PARAMETERS_TABLE -->

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*

## Out of Scope

These items are not in scope unless added via change control:
- Hardware procurement for servers or network devices
- Network design or re-architecture
- Application-specific automation beyond core network functions
- Managed services post-hypercare period
- Third-party software licenses (GitLab, NetBox, Ansible AWX)
- Custom development beyond 6 core playbooks

## Activities

### Phase 1 – Foundation (Weeks 1-4)

During this initial phase, the automation platform foundation is deployed.

Key activities:
- Automation assessment and current state analysis
- Tool selection and architecture design
- GitLab deployment with CI/CD runner infrastructure
- NetBox IPAM deployment and initial device inventory import
- Git workflow design and approval process definition

**Deliverable:** Automation Assessment Report and Platform Architecture

### Phase 2 – Playbook Development (Weeks 5-8)

Core Ansible playbooks are developed and tested.

Key activities:
- Develop 6 core Ansible playbooks (VLAN, ACL, interface, routing, QoS, compliance)
- CI/CD pipeline configuration with syntax validation and testing
- Secrets management implementation with Vault or GitLab secrets
- Template development for Cisco IOS-XE, NX-OS, and ASA
- Lab testing with GNS3 or CML for validation

**Deliverable:** Ansible Playbook Repository and CI/CD Pipelines

### Phase 3 – Advanced Automation (Weeks 9-10)

Advanced capabilities and integrations are implemented.

Key activities:
- Terraform module development for ACI, DCNM, Meraki (optional)
- ServiceNow integration for change management automation
- Advanced validation and compliance checking
- Lab testing with complex scenarios

**Deliverable:** Terraform Modules and Integration Documentation

### Phase 4 – Training & Rollout (Weeks 11-16)

The team is trained and automation is rolled out to production.

Key activities:
- Team training on Ansible, Git workflows, and CI/CD (40 hours)
- Pilot deployment with 10 devices for validation
- Phased rollout to remaining 90 devices
- Runbook creation and documentation
- Hypercare support activation

**Deliverable:** Training Materials and Operational Runbooks

---

# Deliverables & Timeline

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Automation Assessment Report | Document | Week 4 | Client IT Lead |
| 2 | Ansible Playbook Repository | Code | Week 8 | Network Lead |
| 3 | Integration Documentation | Document | Week 10 | Operations Lead |
| 4 | Training Materials | Document | Week 12 | Network Team |
| 5 | Operational Runbooks | Document | Week 16 | Client IT Lead |

## Project Milestones

<!-- TABLE_CONFIG: widths=[20, 55, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 - Platform Ready | GitLab NetBox and runners deployed | Week 4 |
| M2 - Playbooks Complete | 6 core playbooks developed and tested | Week 8 |
| M3 - Integrations Live | Terraform and ServiceNow integrated | Week 10 |
| M4 - Pilot Success | 10-device pilot validated | Week 12 |
| M5 - Go-Live | All 100 devices automated | Week 16 |
| Hypercare End | Support period complete | Week 20 |

---

# Roles & Responsibilities

## RACI Matrix

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO DevOps | EO Network | Client Net | Client Ops | SME |
|-----------|-------|----------------|-----------|------------|------------|------------|-----|
| Discovery & Requirements | A | R | R | C | C | I | C |
| Platform Deployment | C | A | R | C | C | I | I |
| Playbook Development | C | R | A | R | C | I | I |
| CI/CD Pipeline Config | C | A | R | C | I | C | I |
| Integration Setup | C | R | R | C | I | A | I |
| Testing & Validation | R | R | C | R | A | C | I |
| Knowledge Transfer | A | R | R | R | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- EO Project Manager: Overall delivery accountability
- EO Quarterback: Technical design and architecture oversight
- EO DevOps Engineer: GitLab and CI/CD pipeline development
- EO Network Automation Engineer: Ansible playbook development

**Client Team:**
- Network Lead: Primary technical contact and playbook validation
- Operations Lead: Day-to-day operations and runbook validation
- DevOps SME: CI/CD and GitOps workflow guidance
- Security Lead: Secrets management and compliance approval

---

# Architecture & Design

## Architecture Overview

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

**Figure 1: Network CI/CD Automation Architecture** - GitOps workflow for infrastructure as code

The proposed architecture provides a modern GitOps workflow for network automation. Key components include:

- **Version Control:** GitLab Premium with merge request workflows
- **Automation Engine:** Ansible for configuration management
- **CI/CD:** GitLab runners for automated testing and deployment
- **Source of Truth:** NetBox IPAM for network inventory
- **Secrets Management:** Vault or GitLab secrets for credential management

## Architecture Type

This solution follows a **GitOps** architecture pattern. Key characteristics:

- **Deployment Model:** On-premises GitLab with self-hosted runners
- **Automation Approach:** Declarative configuration with Ansible and Terraform
- **Workflow:** Git-based with merge requests and CI/CD pipelines
- **Testing:** Automated validation in lab before production deployment

The architecture supports 100 devices with scalability to 500+ devices.

## Technical Implementation Strategy

The deployment follows a crawl-walk-run approach:

**Crawl Phase:**
- Pilot with 10 devices and simple use cases (VLAN provisioning)
- Manual approval gates for all changes
- Extensive testing and validation

**Walk Phase:**
- Expand to 50 devices with additional playbooks
- Automated approval for low-risk changes
- Self-service for common operations

**Run Phase:**
- All 100 devices with full automation
- Automated deployment for validated changes
- Continuous improvement and optimization

---

# Security & Compliance

## Identity & Access Management

- Role-based access control (RBAC) in GitLab
- SSH key-based authentication for Git operations
- Multi-factor authentication (MFA) for privileged access
- Integration with Active Directory/LDAP

## Secrets Management

- HashiCorp Vault or GitLab secrets for credentials
- Encrypted secrets at rest and in-transit
- Automatic credential rotation
- Audit logging for all secret access

## Compliance & Auditing

- Complete Git audit trail (who, what, when, why)
- Change tracking and approval workflows
- Compliance reporting for PCI DSS or SOC 2
- Configuration backup and version control

---

# Testing & Validation

## Functional Validation

Comprehensive testing ensures automation works correctly:

**Playbook Testing:**
- Syntax validation (ansible-lint, yamllint)
- Idempotency testing (multiple runs produce same result)
- Error handling and rollback validation
- End-to-end workflow testing

**CI/CD Pipeline Testing:**
- Automated syntax checks on merge requests
- Lab testing before production deployment
- Approval gates and notification workflows

## Security Testing

Security validation for compliance:

**Vulnerability Assessment:**
- Credential encryption verification
- Access control validation (RBAC)
- Audit logging completeness

**Compliance Validation:**
- Git audit trail verification
- Change approval workflow testing
- Secrets management validation

## User Acceptance Testing (UAT)

UAT performed with network team:

**UAT Approach:**
- Hands-on training with real playbooks
- Pilot deployment with low-risk devices
- Workflow validation (Git, merge requests, CI/CD)

**Acceptance Criteria:**
- Team can independently create and deploy changes
- Playbooks work as documented
- Rollback procedures validated

---

# Handover & Support

## Handover Artifacts

Upon successful implementation:

**Documentation Deliverables:**
- As-built architecture diagrams
- Ansible playbook documentation
- CI/CD pipeline configuration guide
- NetBox integration documentation
- Git workflow and branching strategy

**Operational Deliverables:**
- Operations runbooks for common tasks
- Troubleshooting guides
- Playbook development guide
- Secrets management procedures

**Code Repositories:**
- Ansible playbook repository
- Terraform module repository
- CI/CD pipeline configurations
- Custom scripts and tools

## Knowledge Transfer

**Training Sessions:**
- 40 hours of hands-on training
- Ansible fundamentals and best practices
- Git workflows and merge requests
- CI/CD pipeline operation
- Playbook development and testing

**Documentation Package:**
- Playbook developer guide
- Operations runbooks
- Architecture documentation
- Troubleshooting guide

## Hypercare Support

**Duration:** 4 weeks post-go-live

**Coverage:**
- Business hours support (8 AM - 6 PM local time)
- 4-hour response time for critical issues
- Daily check-ins (first 2 weeks)
- Weekly status meetings

**Scope:**
- Issue investigation and resolution
- Playbook optimization
- Workflow adjustments
- Knowledge transfer continuation

## Assumptions

### General Assumptions

**Client Responsibilities:**
- Client will provide access to network devices and lab environment
- Client network team will be available for training and validation
- Client will provide NetBox and ServiceNow integration credentials (if applicable)
- Client will handle internal change management approvals

**Technical Environment:**
- Network devices support Ansible (SSH, NETCONF, or API access)
- Lab environment (GNS3 or CML) available for testing
- Servers available for GitLab and NetBox deployment
- Network connectivity between automation platform and devices

**Project Execution:**
- Project scope and requirements remain stable
- Resources available per project plan
- No major network changes during pilot and rollout
- Security and compliance approvals timely

---

# Investment Summary

## Total Investment

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 12, 15, 11, 11, 11] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $86,250 | $0 | $86,250 | $0 | $0 | $86,250 |
| Cloud Infrastructure | $5,580 | ($1,000) | $4,580 | $5,580 | $5,580 | $15,740 |
| Software | $1,427 | $0 | $1,427 | $1,427 | $1,427 | $4,281 |
| Support | $500 | $0 | $500 | $500 | $500 | $1,500 |
| **TOTAL INVESTMENT** | **$93,757** | **($1,000)** | **$92,757** | **$7,507** | **$7,507** | **$107,771** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $1,000 (cloud hosting credit)

**Annual Recurring Cost:** $7,507/year (software, infrastructure, support)

## Payment Terms

**Pricing Model:** Fixed price with milestone-based payments

**Payment Schedule:**
- 30% upon SOW execution and project kickoff ($27,827)
- 30% upon completion of Phase 2 - Playbooks Complete ($27,827)
- 25% upon completion of Phase 4 - Pilot Success ($23,189)
- 15% upon successful go-live and project acceptance ($13,914)

**Invoicing:** Monthly invoicing based on milestones completed. Net 30 payment terms.

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) between Vendor and Client.

## Scope Changes

Any changes to scope, schedule, or cost require a formal Change Request approved by both parties.

## Intellectual Property

- Client retains ownership of playbooks, templates, and configurations
- Vendor retains proprietary methodologies and accelerators
- Open source tools used under their respective licenses

## Confidentiality

- All artifacts under NDA protection
- Client credentials and data secured per security requirements
- No disclosure to third parties without consent

---

# Sign-Off

By signing below, both parties agree to the scope, approach, and terms outlined in this Statement of Work.

**Client Authorized Signatory:**

Name: ______________________________

Title: ______________________________

Signature: __________________________

Date: ______________________________

**Service Provider Authorized Signatory:**

Name: ______________________________

Title: ______________________________

Signature: __________________________

Date: ______________________________

---
