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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for a **small-scope, lift-and-shift** migration of 15-25 workloads from on-premise infrastructure to Amazon Web Services (AWS).

**Small Scope Migration:**
- **Workloads:** 15-25 VMs/applications
- **Migration Strategy:** Lift-and-shift (rehost) - not refactoring
- **Infrastructure:** 3x t3.large EC2, db.t3.large RDS Multi-AZ, 1TB storage
- **Timeline:** 4-6 months from discovery to cutover
- **Total Investment:** $167,448 over 3 years ($139,316 Year 1)

**Key Outcomes:**
- Eliminate data center costs for migrated workloads
- 61% cost reduction vs. keeping on-premise
- Cloud scalability and AWS managed services benefits
- Foundation to expand migration to additional workloads

---

---

# Background & Objectives

## Background  
Client currently hosts **[#] applications** on **[VMware/Hyper-V/Physical servers]** across **[#] environments**. Challenges include:  
- [e.g., scaling]  
- [e.g., end-of-life hardware]  
- [e.g., data center contract expiration]

## Objectives  
- Migrate **[#] workloads** to AWS using proven tooling such as AWS MGN and DMS.  
- Improve security posture using VPC segmentation, IAM controls, GuardDuty, etc.  
- Reduce TCO by leveraging managed services (e.g., RDS, ECS Fargate).  
- Enable DR across AZs or regions where applicable.  

## Success Metrics  
- Zero high-severity issues during cutover  
- App latency < [X ms] post-migration  
- 99.9% uptime during the stabilization period  
- 20–35% cost reduction vs. on-prem within 12 months

---

---

# Scope of Work

### In Scope  
- Workload discovery & dependency analysis (via AWS Application Discovery Service)  
- AWS Landing Zone deployment (Control Tower or Terraform)  
- VPC, subnet, routing, and shared services setup  
- Workload migration using AWS MGN / CloudEndure  
- RDS migration (if part of replatform strategy)  
- Cutover, DNS updates, and validation  
- Knowledge transfer and documentation  

### Activities  

### Phase 1 – Discovery & Assessment  
During this initial phase, the Vendor will perform a comprehensive assessment of the Client’s infrastructure and application landscape. This includes analyzing existing workloads, identifying dependencies, and determining the most appropriate migration strategy for each workload.

Key activities:
- Comprehensive infrastructure discovery and inventory  
- Application portfolio analysis and dependency mapping  
- Migration readiness assessment using AWS MAP framework  
- AWS architecture design and landing zone planning  
- Migration wave planning and prioritization  
- Cost estimation and right-sizing recommendations  

This phase concludes with a Migration Assessment Report that outlines the proposed plan, scope, risks, and timeline.

### Phase 2 – Landing Zone & Infrastructure Deployment  
In this phase, the foundational AWS infrastructure is provisioned and configured based on AWS best practices. This includes account structure, network setup, security controls, monitoring, and access management.

Key activities:
- AWS Landing Zone implementation with account provisioning  
- Network connectivity setup using VPN or Direct Connect  
- Centralized logging and monitoring via CloudWatch, CloudTrail, and security services  
- IAM roles, SSO, MFA policies based on least-privilege model  
- Baseline security configuration using AWS Config, GuardDuty, and SCPs  
- Implementation of automated backup strategies and disaster recovery setup  

By the end of this phase, the Client will have a secure, production-ready AWS environment for hosting migrated workloads.

### Phase 3 – Migration Execution (in waves)  
Migration of workloads will occur in well-defined waves based on business priority and workload complexity. Each wave follows a repeatable factory approach with automated processes for consistency and risk reduction.

Key activities:
- Migration factory setup with CI/CD and automation tooling  
- Database migrations using AWS DMS or native tools (e.g., RMAN, SQL)  
- Application migration via rehost, replatform, or refactor strategies  
- Incremental or real-time data sync between source and target systems  
- DNS updates, endpoint reconfiguration  
- Resource right-sizing and performance optimization  

After each wave, the Vendor will coordinate validation and sign-off with the Client before proceeding.

### Phase 4 – Testing & Cutover  
In the Testing and Cutover phase, migrated workloads undergo thorough functional, performance, and failover validation to ensure they meet required SLAs and compliance standards. Test cases and scripts will be executed based on Client-defined acceptance criteria.

Key activities:
- Smoke testing and sanity checks for each migrated workload  
- Performance benchmarking vs. on-premise baselines  
- Failover and resiliency testing (Multi-AZ, DR)  
- Final synchronization of data (if using DMS)  
- DNS cutover, user acceptance testing (UAT), and go-live readiness review  

Cutover will be coordinated with all relevant stakeholders and executed during an approved maintenance window, with well-documented rollback procedures in place.

### Phase 5 – Handover & Post-Migration Support  
Following successful migration and cutover, the focus shifts to ensuring operational continuity and knowledge transfer. The Vendor will provide a period of hypercare support and equip the Client’s team with the documentation, tools, and processes needed for ongoing maintenance and optimization.

Activities include:
- Delivery of as-built documentation (including architecture diagrams, IAM permissions, monitoring setup, etc.)  
- Runbook and SOPs for day-to-day operations  
- Live or recorded knowledge transfer sessions for Ops and Application teams  
- Cost optimization recommendations (based on AWS Trusted Advisor and Cost Explorer)  
- Optional transition to a managed services model for 24/7 support, if contracted  

---

## Out of Scope

## Exclusions
These items are not in scope unless added via change control:
- Application refactoring (code-level changes)  
- On-prem hardware recycling or disposal  
- Managed services post-migration (unless separately contracted)  
- Training for non-IT end users  

---

---

# Deliverables & Timeline

## Deliverables

| # | Deliverable                          | Type         | Due Date     | Acceptance By   |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | Migration Assessment Report          | Document     | [Date]       | [Client Lead]   |
| 2 | AWS Landing Zone Source Code         | IaC/Code     | [Date]       | [AWS Architect] |
| 3 | Migration Runbook & Cutover Plan     | Document     | [Date]       | [Ops Lead]      |
| 4 | As-Built Diagrams & Documentation    | Document     | [Date]       | [Client Lead]   |
| 5 | Knowledge Transfer Sessions          | Live/Recorded| [Date]       | [Client Team]   |

---

## Project Milestones

## Milestones
- M1: Assessment Complete — [Date]  
- M2: Landing Zone Ready — [Date]  
- M3: Wave 1 App Migration — [Date]  
- Go-Live — [Date]  
- Hypercare End — [Date]  

---

---

# Roles & Responsibilities

| Task/Role                                | Vendor PM | Vendor Arch | Vendor DevOps | Client IT | Client Sec | AWS SA |
|------------------------------------------|-----------|-------------|---------------|-----------|------------|--------|
| Discovery & Dependency Mapping           | A         | R           | R             | C         | I          | I      |
| AWS Account & Landing Zone               | C         | A           | R             | I         | I          | C      |
| Network Setup (VPC, Routing)             | C         | A           | R             | C         | C          | C      |
| Migration Wave Design                    | A         | R           | C             | R         | C          | I      |
| Database Migration                       | C         | R           | R             | C         | I          | I      |
| Application Cutover Execution            | R         | R           | R             | A         | C          | I      |
| IAM & Security Configuration             | C         | C           | R             | I         | A          | C      |
| Monitoring Configuration (CW, X-Ray)     | C         | R           | R             | C         | I          | I      |
| Hypercare Post-Migration Support         | A         | R           | R             | C         | I          | I      |
| Knowledge Transfer                       | R         | R           | C             | A         | I          | I      |

Legend:  
**R** = Responsible | **A** = Accountable | **C** = Consulted | **I** = Informed

---

---

# Architecture & Design



---

# Security & Compliance

## Environments & Access

## Environments  
- Dev, QA, Stage, Prod

## Access Policies  
- MFA required  
- SSO federation preferred  
- No direct SSH — use SSM Session Manager  

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the migration lifecycle to ensure functionality, performance, security, and resilience of all workloads on AWS.

## Functional Validation  
- End-to-end application validation via UI, API, or batch-level testing  
- Validation against business workflows and user stories  

## Performance & Load Testing  
- Benchmark comparison between on-prem and AWS target states  
- Stress testing using tools like JMeter or Locust  

## Security Testing  
- Validation of IAM policies, encryption, and compliance requirements  
- Optional penetration testing and vulnerability scanning  

## Disaster Recovery & Resilience Tests  
- Failover testing (Multi-AZ, Multi-region if applicable)  
- RTO/RPO validation  

## User Acceptance Testing (UAT)  
- Performed in coordination with Client stakeholders  
- Test data and environment setup managed by Vendor  

## Go-Live Readiness  
A Go-Live Readiness Checklist will be delivered including:
- Security and compliance sign-offs  
- Functional benchmark validation  
- Data integrity checks  
- Issue log closure  

---

## Cutover Plan

## Cutover Checklist  
- DNS switch sequencing  
- Disable legacy database writes  
- Application and endpoint reconfiguration  
- Health check monitoring  

## Rollback Strategy  
- Reverse DNS  
- Re-enable legacy data writes  
- Rollback to earlier snapshot or AMI  

---

---

# Handover & Support

## Handover Artifacts  
- As-Built documentation  
- Cloud cost estimation & optimization recommendations  
- IAM and account governance model  
- Monitoring & alert setup reference  

## Knowledge Transfer  
- [X] live sessions  
- Recorded materials hosted in shared portal  

---

## Assumptions

### General Assumptions  
- Client provides timely access to applications, SMEs, and target systems.  
- IAM roles are provisioned with appropriate permissions before migration waves start.  
- On-prem network connectivity will be handled via DX or VPN.  
- All required AWS accounts are permitted for project use.

---

## Dependencies

## Project Dependencies  
- Approval for AWS Organizations setup  
- Third-party application vendor support (if required for migration)  
- DNS access and domain control during cutover  
- Required firewall/NAT rules established prior to migration  

---

## AWS Security, Compliance & Governance

The migration and target AWS environment will be architected and validated to meet the Client’s security, compliance, and governance requirements. Vendor will adhere to AWS's Shared Responsibility Model and industry-standard security frameworks during implementation.

### Identity & Access Management  
- IAM roles designed using least-privilege access  
- Role-based access control (RBAC) aligned with Client’s internal teams  
- Optional identity federation integration (e.g. Azure AD, Okta)

### Monitoring & Threat Detection  
- GuardDuty enabled across accounts for real-time threat detection  
- AWS Config and CloudTrail enabled for audit logging and change detection  
- Optional integration with SIEM tools like Splunk, Datadog, or ELK  

### Compliance & Auditing  
- Policies configured for adherence to standards such as SOC2, ISO27001, HIPAA, etc.  
- Continuous assessment using Security Hub and Trusted Advisor  
- Optional support for GovCloud for regulatory compliance  

### Encryption & Key Management  
- KMS-managed keys for in-transit and at-rest encryption  
- Optional BYOK or CloudHSM deployment  
- TLS enforcement for all data channels  

### Governance  
- Use of Service Control Policies (SCPs) to enforce mandatory security posture  
- AWS tagging strategy applied for cost allocation, ownership, and automation  
- IaC policy enforcement using tools such as Conftest or AWS CodePipeline  

---

---

# Investment Summary

**Small Scope Implementation:** This pricing reflects a lift-and-shift migration of 15-25 workloads. For larger migrations (50+ workloads) or refactoring/modernization, please request medium or large scope pricing.

## Total Investment

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 23, 13, 10, 10, 12] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|---------|---------|--------------|
| Professional Services | $125,150 | ($22,000) | $103,150 | $0 | $0 | $103,150 |
| Cloud Infrastructure | $9,572 | ($8,117) | $1,455 | $9,472 | $9,472 | $20,399 |
| Software Licenses & Subscriptions | $3,132 | $0 | $3,132 | $3,132 | $3,132 | $9,396 |
| Support & Maintenance | $1,462 | $0 | $1,462 | $1,462 | $1,462 | $4,386 |
| **TOTAL INVESTMENT** | **$139,316** | **($30,117)** | **$109,199** | **$14,066** | **$14,066** | **$137,331** |
<!-- END COST_SUMMARY_TABLE -->

## AWS Migration Acceleration Program (MAP) Credits

**Year 1 Credits Applied:** $30,117 (22% reduction)
- **AWS MAP Assessment Credit:** $12,000 - 100% funding for migration discovery and application inventory
- **AWS MAP Mobilize/Migrate Credit:** $10,000 - Partial funding for migration wave planning and execution
- **AWS MAP Consumption Credit:** $8,117 - 35% of Year 1 cloud infrastructure costs
- Credits are real AWS promotional credits, applied automatically through AWS Migration Hub
- MAP credits are Year 1 only; Years 2-3 reflect standard AWS pricing

**Investment Comparison:**
- **Year 1 Net Investment:** $109,199 (after MAP credits) vs. $139,316 list price
- **3-Year Total Cost of Ownership:** $137,331
- **On-Premise Comparison:** $420K (3-year on-prem cost for 25 VMs) - **Net Savings: $283K (67% reduction)**

## Cost Components

**Professional Services** ($125,150 - 548 hours): Labor costs for migration assessment, wave planning, AWS landing zone, application/database migration, testing, cutover, and knowledge transfer. Breakdown:
- Assessment & Planning (140 hours): Discovery, migration strategy, AWS landing zone setup
- Migration Execution (330 hours): Application migration, database migration, security, testing, cutover coordination
- Training & Support (78 hours): Knowledge transfer, documentation, 60-day hypercare

**Cloud Infrastructure** ($9,572 Year 1, $9,472 Years 2-3): AWS services for migrated workloads:
- Amazon EC2 (3x t3.large), RDS (db.t3.large Multi-AZ), S3 (1TB), EBS, ALB, VPN, caching
- Single region deployment with standard availability
- Year 1 includes $100 one-time data transfer costs

**Software Licenses & Subscriptions** ($3,132/year): Monitoring and incident management:
- Datadog Pro (6 hosts): $1,656/year
- PagerDuty Professional (3 users): $1,476/year

**Support & Maintenance** ($1,462/year): Ongoing managed services (15% of cloud infrastructure):
- Monthly cost optimization reviews
- AWS service management
- Performance tuning

Detailed breakdown including AWS service consumption, migration tasks, and cost comparison is provided in cost-breakdown.xlsx.

---

## Payment Terms

### Pricing Model
- Fixed price or Time & Materials (T&M)
- Milestone-based payments per Deliverables table

### Payment Schedule
- 25% upon SOW execution and project kickoff
- 30% upon completion of Assessment and Wave 1 migration
- 30% upon completion of Wave 2-3 migrations
- 15% upon successful cutover and hypercare completion  

---

## Invoicing & Expenses

### Invoicing
- Monthly invoicing
- Net 30 payment terms

### Expenses  
- Reimbursable at cost with prior approval  

---

## Terms & Conditions

All migration services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

### Scope Changes  
- Change Requests required for any scope, schedule, or cost adjustments  

### Intellectual Property  
- Client retains all ownership of migrated assets, applications, and cloud configs  
- Vendor retains proprietary scripts and accelerators unless otherwise agreed  

### Service Levels  
- Deliverables based on best effort unless otherwise specified in SLAs  
- Hypercare period of [X] weeks included with option to extend via managed services  

### Liability  
- Liability caps as agreed in MSA  
- Excludes confidentiality or IP infringement breach  

### Confidentiality  
- All exchanged artifacts under NDA protection  

### Termination  
- Mutually terminable per MSA terms, subject to payment for completed work  

### Governing Law  
- Agreement governed under the laws of [State/Region]  

---

---

# Terms & Conditions



---

# Sign-Off

**Client Authorized Signatory:**  
Name: __________________________  
Title: __________________________  
Signature: ______________________  
Date: __________________________  

**Vendor Authorized Signatory:**  
Name: __________________________  
Title: __________________________  
Signature: ______________________  
Date: __________________________  

---

*This Statement of Work constitutes the complete agreement between the parties for the cloud migration services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter.*
