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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing a **small-scope, pilot light** AWS Disaster Recovery solution for [CLIENT_NAME]'s web application infrastructure. The project will deliver business continuity assurance for 5-10 critical applications through automated failover capabilities, cross-region backups, and comprehensive disaster recovery procedures.

**Small Scope DR Deployment:**
- **DR Strategy:** Pilot light (cost-optimized standby with on-demand recovery)
- **RTO Target:** 4 hours (time to restore operations after disaster)
- **RPO Target:** 1 hour (acceptable data loss window)
- **Application Scope:** 5-10 critical web applications
- **Total Investment:** $133,229 over 3 years ($106,743 Year 1 implementation)

## Business Objectives

- **Primary Goal:** Achieve 4-hour RTO and 1-hour RPO for critical web applications through pilot light DR
- **Success Metrics:** Documented and tested recovery procedures, 95% success rate on quarterly DR tests, automated backup validation
- **Expected ROI:** Risk mitigation - compare $107K investment to cost of 4+ hours downtime for revenue-generating applications

## Project Duration

**Start Date:** [PROJECT_START_DATE]
**End Date:** [PROJECT_END_DATE]
**Total Duration:** 6 months

---

---

# Background & Objectives

Background information and business objectives.

---

# Scope of Work

## In-Scope Activities

The following disaster recovery services and deliverables are included in this SOW:

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Application Tiers | 3-tier web application |
| Solution Scope | RTO/RPO Requirements | RTO 4 hours RPO 1 hour |
| Integration | Database Replication | Aurora Global Database |
| Integration | Data Sources | Primary app database + S3 |
| User Base | Total Users | 200 concurrent users |
| User Base | User Roles | 3 roles (end-user admin ops) |
| Data Volume | Database Size | 50 GB |
| Data Volume | Backup Retention | 30 days retention |
| Technical Environment | Primary AWS Region | us-east-1 |
| Technical Environment | DR AWS Region | us-west-2 |
| Technical Environment | Infrastructure Complexity | Pilot Light DR |
| Security & Compliance | Security Requirements | Encryption at rest/transit IAM |
| Security & Compliance | Compliance Frameworks | SOC2 Type II |
| Performance | Failover Requirements | Automated failover <15 min |
| Performance | Recovery Testing | Quarterly DR drills |
| Environment | Deployment Environments | 3 environments (dev staging prod) |

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*

### Discovery & Business Continuity Planning Phase

- Business impact assessment and critical application prioritization
- Current state disaster recovery capability evaluation
- RTO/RPO requirements analysis and validation
- Compliance and regulatory requirement assessment
- Disaster scenario modeling and risk assessment
- DR architecture design and multi-region strategy

### Infrastructure Implementation Phase

- Secondary AWS region setup and configuration
- Cross-region networking and VPN connectivity
- Database replication configuration (RDS/Aurora cross-region)
- Application server deployment in DR region
- Load balancer and DNS failover configuration
- Storage replication and backup strategy implementation

### Application & Data Replication Phase

- Web application deployment to DR environment
- Real-time and scheduled data replication setup
- Database synchronization and consistency validation
- File system and static content replication
- Configuration management and environment parity
- Application dependency mapping and replication

### Monitoring & Automation Phase

- DR monitoring dashboard and alerting system
- Automated failover trigger configuration
- Health check and availability monitoring
- Performance monitoring in DR environment
- Automated backup verification and testing
- Incident response automation and notifications

### Testing & Validation Phase

- DR testing framework development
- Planned failover testing and validation
- Performance testing in DR environment
- Data integrity and consistency validation
- Full disaster simulation exercises
- Business process validation in DR mode

### Operations & Handover Phase

- DR runbook creation and documentation
- Operations team training on DR procedures
- 24/7 monitoring and support procedures
- Incident response and escalation procedures
- Ongoing DR testing and maintenance planning

## Out-of-Scope Activities

The following activities are explicitly excluded from this SOW:

- Legacy application re-architecture or modernization
- Third-party software licensing for DR environments
- Physical hardware procurement or data center setup
- Network infrastructure modifications outside AWS
- Ongoing operational support beyond the warranty period
- Application performance optimization unrelated to DR
- Data migration from non-AWS environments
- Compliance audit services or regulatory reporting

---

---

# Deliverables & Timeline

## Deliverables

## Documentation Deliverables

<!-- TABLE_CONFIG: widths=[25, 40, 15, 20] -->
| Deliverable | Description | Due Date | Format |
|-------------|-------------|----------|---------|
| **DR Requirements Specification** | Detailed RTO/RPO requirements and business continuity needs | [DATE] | CSV/Excel |
| **DR Architecture Document** | Multi-region DR architecture and technical specifications | [DATE] | PDF |
| **DR Implementation Plan** | Detailed project timeline and resource allocation | [DATE] | MS Project |
| **DR Test Plan & Results** | Comprehensive testing strategy and execution results | [DATE] | PDF |
| **DR Operations Runbook** | Step-by-step disaster recovery procedures and protocols | [DATE] | PDF |
| **DR Training Materials** | Operations team training guides and simulation exercises | [DATE] | PDF/Video |
| **DR Monitoring Guide** | Monitoring dashboard configuration and alert procedures | [DATE] | PDF |
| **As-Built DR Documentation** | Final DR system configuration and architecture | [DATE] | PDF |

## System Deliverables

<!-- TABLE_CONFIG: widths=[30, 40, 30] -->
| Component | Description | Acceptance Criteria |
|-----------|-------------|---------------------|
| **Primary Production Environment** | Fully configured primary region with DR monitoring | Passes all acceptance tests |
| **DR Production Environment** | Fully operational secondary region environment | Successful failover demonstration |
| **Data Replication System** | Real-time database and file replication | RPO compliance validation |
| **Failover Automation** | Automated failover triggers and procedures | RTO compliance demonstration |
| **Monitoring & Alerting** | 24/7 DR monitoring and incident alerting | Functional dashboards and alerts |
| **Backup & Recovery Validation** | Automated backup testing and verification | Successful recovery demonstrations |

## Knowledge Transfer Deliverables

- DR operations training (3 days, up to 15 participants)
- Executive disaster response briefing (4 hours, up to 10 participants)
- Hands-on failover simulation exercises
- 24/7 emergency response procedures training
- Recorded training sessions and DR simulation scenarios

---

## Project Milestones

## Milestones

| Phase | Duration | Start Date | End Date | Key Milestones |
|-------|----------|------------|----------|----------------|
| **Discovery & Planning** | 3 weeks | [DATE] | [DATE] | BIA completed, DR architecture approved |
| **Infrastructure Setup** | 4 weeks | [DATE] | [DATE] | DR region configured, networking established |
| **Application & Data Replication** | 3 weeks | [DATE] | [DATE] | Applications deployed, replication active |
| **Monitoring & Automation** | 2 weeks | [DATE] | [DATE] | Monitoring operational, automation configured |
| **Testing & Validation** | 3 weeks | [DATE] | [DATE] | DR tests passed, failover validated |
| **Operations & Handover** | 2 weeks | [DATE] | [DATE] | Training completed, documentation delivered |

## Critical Dependencies

- Client provides access to current production environment and configurations
- Business stakeholders available for BIA and requirements validation
- AWS account access and appropriate permissions for multi-region deployment
- Network connectivity approvals for cross-region traffic
- Maintenance windows available for DR testing and validation
- Operations team availability for training and knowledge transfer

---

---

# Roles & Responsibilities

## RACI Matrix

<!-- TABLE_CONFIG: widths=[34, 11, 11, 11, 11, 11, 11] -->
| Task/Deliverable | Vendor PM | Vendor Arch | Vendor Eng | Client IT | Client Mgmt | SME |
|------------------|-----------|-------------|------------|-----------|-------------|-----|
| DR Requirements Analysis | A | R | C | C | I | R |
| DR Architecture Design | C | A | R | C | I | C |
| Infrastructure Deployment | C | R | A | C | I | I |
| Data Replication Setup | C | R | R | C | I | I |
| Failover Automation | C | A | R | C | I | I |
| Testing & Validation | R | R | R | A | I | C |
| Runbook Development | A | R | R | C | I | I |
| Knowledge Transfer | R | R | C | A | I | I |
| Project Management | A | I | I | C | R | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- Project Manager: Overall delivery accountability
- Solution Architect: Technical design and oversight
- Engineers: Implementation and configuration
- Support Specialist: Training and hypercare

**Client Team:**
- IT Lead: Primary technical contact
- Management Sponsor: Executive oversight
- Operations Team: Knowledge transfer recipients
- Subject Matter Experts: Requirements validation

---

---

# Architecture & Design

## Architecture Overview

The AWS Disaster Recovery solution implements a multi-region, active-standby architecture designed for high availability and rapid failover. The architecture provides automated failover capabilities, continuous data replication, and comprehensive monitoring to ensure business continuity.

![Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Solution Architecture Diagram** - High-level overview of the multi-region DR architecture

## Architecture Type

The deployment follows a warm standby DR strategy with active-passive multi-region deployment. This approach enables:

- RTO (Recovery Time Objective): 15 minutes
- RPO (Recovery Point Objective): 5 minutes
- Automated health checks and DNS failover via Route 53
- Continuous cross-region replication for databases and storage
- Cost optimization through reduced capacity in standby region

---

---

# Security & Compliance



---

# Testing & Validation



---

# Handover & Support



---

# Investment Summary

**Small Scope Implementation:** This pricing reflects a pilot light DR strategy for 5-10 critical applications with 4-hour RTO and 1-hour RPO targets. For warm/hot standby or enterprise-scale DR, please request medium or large scope pricing.

## Total Investment

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 23, 13, 10, 10, 12] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|---------|---------|--------------|
| Professional Services | $93,500 | ($8,000) | $85,500 | $0 | $0 | $85,500 |
| Cloud Infrastructure | $8,644 | ($4,369) | $4,275 | $8,644 | $8,644 | $21,563 |
| Software Licenses & Subscriptions | $3,132 | $0 | $3,132 | $3,132 | $3,132 | $9,396 |
| Support & Maintenance | $1,467 | $0 | $1,467 | $1,467 | $1,467 | $4,401 |
| **TOTAL INVESTMENT** | **$106,743** | **($12,369)** | **$94,374** | **$13,243** | **$13,243** | **$120,860** |
<!-- END COST_SUMMARY_TABLE -->

## AWS Partner Credits

**Year 1 Credits Applied:** $12,369 (12% reduction)
- **AWS Partner DR Services Credit:** $8,000 applied to DR architecture design and testing validation
- **AWS DR Infrastructure Credit:** $4,369 applied to pilot light DR region costs in Year 1
- Credits are real AWS account credits, automatically applied as services are consumed
- Credits are Year 1 only; Years 2-3 reflect standard AWS pricing

**Investment Comparison:**
- **Year 1 Net Investment:** $94,374 (after credits) vs. $106,743 list price
- **3-Year Total Cost of Ownership:** $120,860
- **Expected Value:** Risk mitigation - compare $95K Year 1 investment to cost of 4+ hours downtime for critical applications

## Cost Components

**Professional Services** ($93,500 - 450 hours): Labor costs for discovery, DR architecture design, infrastructure deployment, testing, runbook development, and knowledge transfer. Breakdown:
- Discovery & DR design (120 hours): Business impact analysis, RTO/RPO requirements, architecture design, runbook development
- Implementation (280 hours): AWS DR environment setup, replication configuration, DR testing, automation
- Training & support (50 hours): Operations team training and 30-day hypercare

**Cloud Infrastructure** ($8,644/year): AWS services for primary region and pilot light DR:
- Primary region (EC2, RDS Multi-AZ, ALB, EBS): $6,644/year
- DR region (automated backups, Route53, minimal compute for testing): $2,000/year
- Pilot light strategy minimizes ongoing costs while maintaining DR capability

**Software Licenses & Subscriptions** ($3,132/year): Operational tooling for small scope:
- Datadog Pro monitoring (6 hosts - primary + DR): $1,656/year
- PagerDuty Professional incident management (3 users): $1,476/year

**Support & Maintenance** ($1,467/year): Ongoing managed services (15% of cloud infrastructure):
- Quarterly DR testing and validation
- Monthly backup verification
- DR runbook updates

Detailed breakdown including primary/DR infrastructure, AWS service consumption, and quarterly testing is provided in cost-breakdown.xlsx.

---

## Payment Terms

### Payment Schedule

- 30% upon SOW execution and project kickoff
- 25% upon completion of DR infrastructure setup
- 25% upon successful DR testing and validation
- 20% upon training completion and project acceptance

---

---

# Terms & Conditions

## Intellectual Property

- Client retains ownership of all business data and application configurations
- Vendor retains ownership of DR methodologies and automation tools
- DR configuration and procedures become client property upon final payment

## Confidentiality

Both parties agree to maintain strict confidentiality of business continuity plans, system configurations, and sensitive data throughout the project and beyond.

## Warranty & Support

- 90-day warranty on all DR deliverables from go-live date
- DR system defect resolution included at no additional cost during warranty period
- Post-warranty DR support available under separate maintenance agreement

## Limitation of Liability

Vendor's liability is limited to the total contract value. Neither party shall be liable for indirect, incidental, or consequential damages related to DR implementation.

## Governing Law

Agreement governed under the laws of [State/Region]

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

*This Statement of Work constitutes the complete agreement between the parties for the disaster recovery services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter.*
