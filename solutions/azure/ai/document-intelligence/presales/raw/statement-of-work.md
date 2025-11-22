---
document_title: Statement of Work
technology_provider: Azure
project_name: Azure Document Intelligence Solution
client_name: [Client Name]
client_contact: [Contact Name | Email | Phone]
consulting_company: Your Consulting Company
consultant_contact: [Consultant Name | Email | Phone]
opportunity_no: OPP-2025-001
document_date: November 15, 2025
version: 1.0
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing an Azure Document Intelligence solution for [Client Name]. This engagement will deliver automated document processing capabilities through Azure AI services including Azure Document Intelligence, Azure Cognitive Services Text Analytics, and automated workflows to transform manual document workflows into intelligent, automated processes.

**Project Duration:** [X] months

---

---

# Background & Objectives

## Current State

[Client Name] currently processes approximately [X,000] documents manually each [month/year] across multiple business functions. Key challenges include:
- **Manual Processing Bottlenecks:** Hours of staff time required per document
- **High Error Rates:** 5-10% error rate in manual data entry requiring costly rework
- **Scalability Limitations:** Cannot handle volume fluctuations or business growth
- **Resource Intensive:** [Y] FTE dedicated to repetitive, low-value data entry tasks
- **Compliance Risk:** Manual processes increase audit exposure and data security concerns

## Business Objectives
- **Automate Document Processing:** Implement automated document processing using Azure AI services (Document Intelligence, Text Analytics) to eliminate manual data entry and classification
- **Improve Accuracy:** Achieve 95%+ data extraction accuracy through AI and human-in-the-loop review, reducing costly rework and compliance risks
- **Reduce Processing Time:** Reduce manual processing time by 80-90% through intelligent automation, improving throughput from hours to minutes per document
- **Lower Operational Costs:** Reduce document operations costs by 70% through automation, freeing staff from repetitive tasks to focus on higher-value work
- **Enable Scalability:** Build scalable serverless architecture supporting flexible document volumes without proportional cost increase
- **Foundation for Growth:** Enable foundation for expanding automation across additional document types and business processes beyond initial scope

## Success Metrics
- 95%+ data extraction accuracy measured against validation dataset
- 90% reduction in document processing time (from baseline)
- 70% reduction in document operations costs within 12 months
- Process [target volume] documents per month with <1% error rate
- 99.5% system uptime for document processing services
- Successful integration with [X] existing business systems

---

---

# Scope of Work

## In Scope
The following services and deliverables are included in this SOW:
- Document workflow analysis and AI/ML solution design
- Azure infrastructure provisioning and configuration
- AI model development and training for document classification and extraction
- Document processing pipeline implementation
- API and web interface development
- Integration with existing business systems
- Testing, validation, and accuracy verification
- Knowledge transfer and documentation

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Parameter | Scope |
|----------|-----------|-------|
| Solution Scope | Document Types | 3 document types (invoices receipts forms) |
| Solution Scope | AI/ML Complexity | Azure Document Intelligence pre-built |
| Integration | External System Integrations | 2 REST APIs (CRM ERP) |
| Integration | Data Sources | Blob Storage and SharePoint |
| User Base | Total Users | 75 users |
| User Base | User Roles | 3 roles (submitter reviewer admin) |
| Data Volume | Document Processing Volume | 2000 docs/month |
| Data Volume | Data Storage Requirements | 250 GB |
| Technical Environment | Deployment Regions | Single Azure region (East US) |
| Technical Environment | Availability Requirements | Standard (99.5%) |
| Technical Environment | Infrastructure Complexity | Serverless (Functions Blob Doc Intel) |
| Security & Compliance | Security Requirements | RBAC encryption at rest/transit |
| Security & Compliance | Compliance Frameworks | SOC2 |
| Performance | Accuracy Requirements | 95%+ extraction accuracy |
| Performance | Processing Speed | Batch processing |
| Environment | Deployment Environments | 2 environments (dev prod) |

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment.*


## Activities

### Phase 1 – Discovery & Assessment
During this initial phase, the Vendor will perform a comprehensive assessment of the Client's current document processing workflows and requirements. This includes analyzing existing processes, identifying document types, determining data extraction requirements, and designing the optimal Azure AI solution approach.

Key activities:
- Document workflow analysis and requirements gathering
- Document type classification and data extraction field identification
- Azure environment assessment and AI services readiness evaluation
- Training data requirements and labeling strategy
- Security and compliance requirements analysis (HIPAA, GDPR, SOC 2, etc.)
- Integration requirements with existing business systems
- Solution architecture design (Document Intelligence, Text Analytics, Functions, Cosmos DB)
- Implementation planning and resource allocation

This phase concludes with an Assessment Report that outlines the proposed Document Intelligence architecture, document processing workflow, AI model strategy, integration approach, risks, and project timeline.

### Phase 2 – Solution Design & Environment Setup
In this phase, the Azure infrastructure is provisioned and configured based on AI/ML best practices. This includes environment setup, document processing pipeline design, security controls, monitoring, and access management.

Key activities:
- Azure infrastructure provisioning (Blob Storage, Functions, API Management)
- AI services configuration (Document Intelligence, Text Analytics, automated review workflows)
- Document processing pipeline development (ingestion, classification, extraction, validation)
- Security baseline configuration (encryption, managed identities, Key Vault, private endpoints)
- Integration framework setup (REST APIs, webhooks, event triggers)
- Azure Monitor and Application Insights setup
- Backup strategies and disaster recovery setup

By the end of this phase, the Client will have a secure, production-ready Azure AI Document Intelligence environment for document processing.

### Phase 3 – Implementation & Execution
Implementation will occur in well-defined phases based on document type complexity and business priority. Each phase follows a repeatable process with automated workflows for consistency and risk reduction.

Key activities:
- Custom AI model development for document classification (if required)
- Data extraction logic implementation for structured and unstructured documents
- Validation rules and business logic configuration
- API development for document submission and results retrieval
- Web interface development for document upload and results review
- Integration implementation with existing business systems (ERP, CRM, databases)
- Human review workflow configuration
- Incremental testing and validation with sample documents

After each phase, the Vendor will coordinate validation and sign-off with the Client before proceeding.

### Phase 4 – Testing & Validation
In the Testing and Validation phase, the Document Intelligence solution undergoes thorough functional, performance, and accuracy validation to ensure it meets required SLAs and compliance standards. Test cases will be executed based on Client-defined acceptance criteria.

Key activities:
- Unit testing of all processing components
- Document processing testing with various formats and quality levels
- AI model accuracy validation against test dataset
- Performance benchmarking and load testing
- Security and compliance validation
- Integration testing with business systems
- User Acceptance Testing (UAT) coordination
- Go-live readiness review and cutover planning

Cutover will be coordinated with all relevant stakeholders and executed during an approved maintenance window, with well-documented rollback procedures in place.

### Phase 5 – Handover & Post-Implementation Support
Following successful implementation and cutover, the focus shifts to ensuring operational continuity and knowledge transfer. The Vendor will provide a period of hypercare support and equip the Client's team with the documentation, tools, and processes needed for ongoing maintenance and optimization.

Activities include:
- Delivery of as-built documentation (architecture diagrams, configurations, model details)
- Operations runbook and SOPs for day-to-day document processing management
- Azure service management training (Document Intelligence, Text Analytics, Functions, Cosmos DB)
- AI model monitoring and maintenance training
- Live or recorded knowledge transfer sessions for administrators and users
- Performance optimization recommendations
- 30-day warranty support for issue resolution
- Optional transition to a managed services model for ongoing support, if contracted

---

## Out of Scope

## Exclusions
These items are not in scope unless added via change control:
- Hardware procurement or on-premises infrastructure
- Third-party software licensing beyond Azure services
- Legacy document system decommissioning or data archive migration
- Historical document processing or back-file conversion
- Ongoing operational support beyond 30-day warranty period
- Custom development for document types not specified in requirements
- Manual document digitization, scanning, or data labeling services
- End-user training beyond initial knowledge transfer sessions
- Azure service costs (billed directly by Azure to client)

---

---

# Deliverables & Timeline

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|--------------------------------------|--------------|--------------|-----------------|
| 1 | Requirements Specification | Document/CSV | Week 2 | [Client Lead] |
| 2 | Document Intelligence Solution Architecture | Document | Week 3 | [Technical Lead] |
| 3 | Implementation Plan | Project Plan | Week 3 | [Project Sponsor] |
| 4 | Azure Document Intelligence Environment | System | Week 11 | [Technical Lead] |
| 5 | Document Processing Pipeline | System | Week 11 | [Technical Lead] |
| 6 | Custom AI Models (if required) | System | Week 11 | [Data Science Lead] |
| 7 | API Interfaces | System | Week 11 | [Integration Lead] |
| 8 | Web Interface | System | Week 11 | [Business Lead] |
| 9 | Test Plan & Results | Document | Week 12 | [QA Lead] |
| 10 | User Training Materials | Document/Video | Week 14 | [Training Lead] |
| 11 | Operations Runbook | Document | Week 15 | [Ops Lead] |
| 12 | As-Built Documentation | Document | Week 16 | [Client Lead] |
| 13 | Knowledge Transfer Sessions | Training | Week 15-16 | [Client Team] |

---

## Project Milestones

## Milestones

<!-- TABLE_CONFIG: widths=[20, 50, 30] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 | Assessment Complete | Week 3 |
| M2 | Azure Environment Ready | Week 5 |
| M3 | AI Models Trained & Validated | Week 9 |
| M4 | Implementation Complete | Week 11 |
| M5 | Testing Complete | Week 14 |
| Go-Live | Production Launch | Week 15 |
| Hypercare End | Support Period Complete | Week 19 |

---

---

# Roles & Responsibilities

<!-- TABLE_CONFIG: widths=[34, 11, 11, 11, 11, 11, 11] -->
| Task/Role | Vendor PM | Vendor Architect | Vendor AI Engineer | Vendor Dev | Client IT | Client Business |
|-----------|-----------|------------------|-------------------|-----------|-----------|-----------------|
| Discovery & Requirements | A | R | C | C | C | R |
| Solution Architecture | C | A | R | C | I | C |
| AI Model Development | C | C | A | R | I | C |
| Infrastructure Setup | C | A | R | R | C | I |
| Pipeline Implementation | C | C | R | A | C | I |
| Integration Development | C | R | C | A | C | C |
| Testing & Validation | R | C | R | R | A | A |
| Security Configuration | C | R | C | R | A | I |
| Knowledge Transfer | A | R | R | R | C | C |
| Hypercare Support | A | R | R | R | C | I |

Legend:
**R** = Responsible | **A** = Accountable | **C** = Consulted | **I** = Informed

---

---

# Architecture & Design

## Architecture Overview
The Azure AI Document Intelligence solution is designed as a **serverless, event-driven architecture** leveraging Azure cognitive services and platform services. The architecture provides scalability, cost optimization, and enterprise-grade security for automated document processing workflows.

This architecture is designed for **small-scope deployment** supporting 50,000 pages/month with 50-100 department users. The design prioritizes:
- **Cost efficiency:** Right-sized Azure services for department-level volume
- **Simplicity:** Single-region deployment (East US) with essential availability
- **Scalability:** Can grow to medium/large scope by adjusting Azure service limits (no re-architecture)

![Figure 1: Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: Solution Architecture Diagram** - High-level overview of the Azure AI Document Intelligence solution architecture

## Architecture Type
The deployment follows a serverless microservices architecture with event-driven processing. This approach enables:
- Automatic scaling based on document volume (scales from 0 to peak load)
- Pay-per-use cost model with no idle infrastructure costs
- Clear separation of concerns for classification, extraction, validation, and integration
- High availability and fault tolerance through Azure managed services

Key architectural components include:
- Document Ingestion Layer (Blob Storage, API Management)
- AI Processing Layer (Azure AI Document Intelligence, Azure Cognitive Services Text Analytics)
- Orchestration Layer (Azure Functions, Azure Logic Apps)
- Data Storage Layer (Azure Blob Storage, Azure Cosmos DB)
- Integration Layer (Azure API Management, Azure Service Bus, Azure Event Grid)

## Small Scope Specifications

**Compute & Processing:**
- Azure Functions Premium: EP1 instance (1 instance base, auto-scale to 10)
- Azure Logic Apps: 100K workflow runs/month
- Single Azure region deployment (East US recommended)

**AI Services:**
- Azure AI Document Intelligence Layout API: 50K pages/month document analysis
- Azure AI Document Intelligence Prebuilt Models: 25K pages/month forms/tables
- Azure Cognitive Services Text Analytics: 25K units/month entity recognition

**Storage & Database:**
- Azure Blob Storage: 1TB storage (Hot tier for active documents, Cool tier for archives)
- Azure Cosmos DB: Serverless mode with 10GB storage, 50K RU/s capacity

**Networking & Integration:**
- Azure API Management: Consumption tier with 5M API requests/month
- Azure Service Bus: Standard tier with 10M messages/month
- Azure Event Grid: 2M events/month
- Single availability zone NAT Gateway (cost optimization)

**Monitoring & Operations:**
- Azure Monitor + Log Analytics: 50GB logs/month
- Azure Cache for Redis: Basic C1 (1GB)
- Business hours support coverage (not 24/7)

**Scalability Path:**
- Medium scope: Increase to 250K pages/month by adjusting service limits
- Large scope: Scale to 1M+ pages/month with multi-region deployment
- No architectural changes required - only Azure service limit increases

## Application Hosting
All application logic will be hosted using Azure serverless services:
- Azure Functions for all processing functions (classification, extraction, validation, integration)
- Azure API Management for REST API endpoints
- Azure Logic Apps for complex workflow orchestration
- Static web hosting for user interfaces (Blob Storage + Azure CDN)

All services are deployed using infrastructure-as-code (Bicep/Terraform).

## Networking
The networking architecture follows Azure best practices for AI workloads:
- Private endpoints for private connectivity to Azure services (Document Intelligence, Blob Storage, Cosmos DB)
- VNet integration for Azure Functions Premium
- API Management with virtual network integration or access policies for access control
- Azure Front Door for secure content delivery of web interfaces
- Network security groups (NSGs) for subnet-level security

## Observability
Comprehensive observability ensures operational excellence:
- Azure Monitor for centralized logging from all Azure Functions
- Application Insights for application performance monitoring and distributed tracing
- Custom metrics for processing volumes, accuracy rates, and latency
- Azure Monitor Alerts for proactive alerting on failures or performance issues
- Custom dashboards showing business KPIs (documents processed, accuracy, cost per document)

## Backup & Disaster Recovery
All critical data and configurations are protected through:
- Blob Storage with versioning enabled for document storage
- Cosmos DB continuous backup enabled
- Automated daily backups of Cosmos DB data
- Cross-region replication (optional) for disaster recovery
- RTO: 4 hours | RPO: 1 hour

---

## Technical Implementation Strategy

The implementation approach follows Azure AI best practices and proven methodologies for document processing solutions.

## Example Implementation Patterns
- Phased rollout: Pilot with single document type, then expand
- Parallel processing: Run Document Intelligence alongside manual processes before full cutover
- Iterative model training: Continuous improvement of AI models based on production data

## Tooling Overview

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|-----------------------|------------------------------|-------------------------------|
| Infrastructure | Azure Bicep, Terraform | Infrastructure provisioning and deployment |
| AI Services | Document Intelligence, Text Analytics | Document OCR, entity recognition, classification |
| Compute | Azure Functions | Serverless processing functions |
| Storage | Blob Storage, Cosmos DB | Document storage and metadata |
| Monitoring | Azure Monitor, App Insights | Centralized logging, metrics, tracing |
| CI/CD | Azure DevOps, GitHub Actions | Automated deployment pipeline |
| Security | Key Vault, Azure AD, Front Door | Encryption, access control, API protection |

---

## Data Management

## Data Strategy
- Document ingestion via multiple channels (Blob Storage upload, API, batch processing)
- Automated classification and extraction using Azure AI services
- Metadata storage in Cosmos DB for fast retrieval
- Lifecycle management with automated archival and deletion
- Data validation and quality checks at each processing stage

## Security & Compliance
- Encryption enabled for data in-transit and at-rest
- PII/PHI detection and masking using Azure Cognitive Services Text Analytics
- Document retention policies aligned with regulatory requirements
- Audit trail for all document access via Azure Monitor
- Secure deletion capabilities for GDPR/data privacy compliance

---

---

# Security & Compliance

The implementation and target environment will be architected and validated to meet the Client's security, compliance, and governance requirements. Vendor will adhere to industry-standard security frameworks and Azure AI best practices.

## Identity & Access Management
- Azure AD-based authentication with managed identities for service-to-service authentication
- Multi-factor authentication (MFA) required for Azure portal access
- Role-based access control (RBAC) with least-privilege access for all Azure services
- Private endpoints for private connectivity to AI services
- API authentication using Azure AD or managed identities

## Monitoring & Threat Detection
- Azure Monitor logging enabled for all API calls and document access
- Application Insights for system health and performance metrics
- Distributed tracing for document processing workflow analysis
- Automated alerts for anomalous processing patterns or unauthorized access attempts
- Integration with Microsoft Defender for Cloud for centralized security findings

## Compliance & Auditing
- SOC 2 certified Azure services, architecture follows SOC 2 security principles
- GDPR compliance: Data residency controls, right-to-deletion capabilities, audit trail
- HIPAA compliance (if applicable): HIPAA-eligible services, BAA with Microsoft, encryption, access controls
- PCI DSS (if applicable): Secure handling of payment documents, no plaintext storage of card numbers
- Continuous compliance monitoring using Azure Policy

## Encryption & Key Management
- All documents encrypted at rest using Azure Storage Service Encryption with Azure Key Vault
- All data encrypted in transit using TLS 1.2+
- Document storage in Blob Storage with server-side encryption enabled
- Encryption key rotation policies implemented
- Secure key management using Azure Key Vault with audit logging

## Governance
- Change control: All changes to document types, extraction rules, or integrations require formal change request
- AI model governance: Model versions tracked, performance monitored, retraining process documented
- Access reviews: Quarterly review of Azure RBAC roles and user access
- Incident response: Documented procedures for security incidents, data breaches, or system outages
- Resource tagging strategy for cost allocation and compliance tracking

---

## Environments & Access

## Environments

| Environment | Purpose | Azure Region | Access |
|-------------|---------|------------|--------|
| Development | AI model training, pipeline development | [Azure Region] | Development team |
| Staging | Integration testing, UAT, pre-production validation | [Azure Region] | Project team, testers |
| Production | Live document processing | [Azure Region] | Operations team, authorized users |

## Access Policies
- Multi-factor authentication (MFA) required for all Azure portal access
- API access via Azure AD authentication tokens or managed identities
- Administrator Access: Full Azure portal and API access for implementation team during project
- Developer Access: Read/write access to Functions, Blob Storage, API Management for development team
- Operator Access: Read-only access to Azure Monitor, limited management of document processing
- User Access: API access via authentication tokens for document submission and retrieval

---

---

# Testing & Validation

Comprehensive testing and validation will take place throughout the implementation lifecycle to ensure functionality, performance, security, and accuracy of the AI-powered document processing solution.

## Functional Validation
- End-to-end document processing workflow validation
- Validation of document classification accuracy across all document types
- Validation of data extraction accuracy against business requirements
- Human review workflow testing
- API endpoint functional testing
- Web interface functional testing

## Performance & Load Testing
- Benchmark testing with target document volumes ([X,000] documents/month)
- Stress testing to identify capacity limits and auto-scaling behavior
- Latency validation (target: <5 minutes per document)
- Concurrent processing capacity testing

## Security Testing
- Validation of encryption (data at rest and in transit)
- Access control testing (Azure RBAC policies, API authentication)
- Compliance validation (HIPAA, GDPR, SOC 2 as applicable)
- PII/PHI detection and masking validation
- Penetration testing (optional)

## Disaster Recovery & Resilience Tests
- Backup and restore validation
- Failover testing (if cross-region replication configured)
- RTO/RPO validation

## User Acceptance Testing (UAT)
- Performed in coordination with Client business stakeholders
- Test environment and sample documents provided by Vendor
- Accuracy validation against business-defined acceptance criteria
- Integration testing with client systems

## Go-Live Readiness
A Go-Live Readiness Checklist will be delivered including:
- Security and compliance sign-offs
- Accuracy validation completion (95%+ threshold)
- Performance testing completion
- Integration testing completion
- Data integrity checks
- Issue log closure (all critical/high issues resolved)
- Training completion
- Documentation delivery

---

## Cutover Plan

## Cutover Checklist
- Pre-cutover validation: Final UAT sign-off, accuracy validation (95%+)
- Production environment validated and monitoring operational
- Rollback procedures documented and rehearsed
- Stakeholder communication completed
- Enable document routing to Document Intelligence solution
- Monitor first batch of live documents
- Verify processing accuracy and performance
- Daily monitoring during hypercare period (4 weeks)

## Rollback Strategy
- Documented rollback triggers (accuracy <90%, critical integration failure, security incident)
- Rollback procedures: Disable Document Intelligence routing, revert to manual processing
- Root cause analysis and fix validation before retry
- Communication plan for stakeholders
- Preserve all logs and processed documents for analysis

---

---

# Handover & Support

## Handover Artifacts
- As-Built documentation including architecture diagrams and Azure service configurations
- AI model documentation (training data, accuracy metrics, version history)
- Operations runbook with troubleshooting procedures
- Monitoring and alert configuration reference
- Azure cost optimization recommendations
- Integration documentation and API specifications

## Knowledge Transfer
- Live knowledge transfer sessions for administrators and operations team
- Azure service management training (Document Intelligence, Text Analytics, Functions, Cosmos DB)
- AI model monitoring and maintenance training
- Recorded training materials hosted in shared portal
- Documentation portal with searchable content

---

## Assumptions

## General Assumptions
- Client will provide representative document samples for AI model training (minimum 1,000 documents per type)
- Document quality is sufficient for OCR and AI processing (readable text, minimum 150 DPI)
- Existing Azure infrastructure meets minimum requirements for AI services
- Business requirements for document types and extraction fields will remain stable during implementation
- Client technical team will be available for requirements validation, testing, and approvals
- Azure subscription access and appropriate permissions will be provided within 1 week of project start
- Document subject matter experts (SMEs) will be available for data labeling and validation
- Integration endpoints and API documentation for existing systems will be provided
- Security and compliance approval processes will not delay critical path activities
- Client will handle Azure service costs directly with Microsoft (estimated $1,500-$2,000/month)

---

## Dependencies

## Project Dependencies
- Azure Subscription Access: Client provides Azure subscription access with appropriate permissions (Document Intelligence, Cognitive Services, Functions, Blob Storage, Cosmos DB, API Management, Monitor)
- Document Samples: Client provides representative document samples across all document types for AI model training and testing
- Training Data Labeling: Client SMEs available to label documents and validate extraction rules
- Integration Endpoints: Client provides API documentation, test environments, and credentials for system integration
- Testing Document Library: Client provides comprehensive document library covering various formats, quality levels, and edge cases
- SME Availability: Document processing experts available for requirements clarification and accuracy validation
- Security Approvals: Security and compliance approvals obtained on schedule to avoid implementation delays
- Infrastructure Readiness: Client Azure environment meets service limits and VNet/networking requirements
- Change Freeze: No major changes to integration systems during testing and deployment phases
- Go-Live Approval: Business and technical approval authority available for production deployment decision

---

---

# Investment Summary

**Small Scope Implementation:** This pricing reflects a department-level deployment designed for 50,000 pages/month processing capacity with 50-100 users. For larger enterprise deployments, please request medium or large scope pricing.

## Total Investment

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 23, 13, 10, 10, 12] -->
| Cost Category | Year 1 List | AWS/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------------------|------------|--------|--------|--------------|
| Professional Services | $82,250 | ($10,000) | $72,250 | $0 | $0 | $72,250 |
| Cloud Infrastructure | $18,528 | ($3,690) | $14,838 | $18,528 | $18,528 | $51,894 |
| Software Licenses | $2,904 | $0 | $2,904 | $2,904 | $2,904 | $8,712 |
| Support & Maintenance | $2,676 | $0 | $2,676 | $2,676 | $2,676 | $8,028 |
| **TOTAL INVESTMENT** | **$106,358** | **($13,690)** | **$92,668** | **$24,108** | **$24,108** | **$140,884** |
<!-- END COST_SUMMARY_TABLE -->

## Azure Partner Credits

**Year 1 Credits Applied:** $13,690 (13% reduction)
- **Microsoft Partner Services Credit:** $10,000 applied to solution architecture and AI model configuration
- **Azure AI Services Consumption Credit:** $3,690 applied to Year 1 Document Intelligence and Text Analytics usage (30% discount)
- Credits are real Azure account credits, automatically applied as services are consumed
- Credits are Year 1 only; Years 2-3 reflect standard Azure pricing

**Investment Comparison:**
- **Year 1 Net Investment:** $92,662 (after credits) vs. $106,352 list price
- **3-Year Total Cost of Ownership:** $140,866
- **Expected ROI:** 8-12 month payback based on typical labor cost savings from automation

## Cost Components

**Professional Services** ($82,250 - 310 hours): Labor costs for discovery, architecture, implementation, testing, and knowledge transfer. Breakdown:
- Discovery & Architecture (100 hours): Requirements analysis, Azure solution design, documentation
- Implementation (180 hours): Infrastructure deployment, AI integration, development, testing
- Training & Support (30 hours): Knowledge transfer and 30-day post-launch hypercare

**Cloud Infrastructure** ($18,068/year): Azure AI services sized for small scope (50K pages/month):
- Azure AI Document Intelligence (Layout + Prebuilt Models): $12,000/year
- Azure compute/storage (Functions, Blob Storage, Cosmos DB, API Management): $6,068/year
- Scales automatically with document volume - pay only for usage

**Software Licenses & Subscriptions** ($2,904/year): Operational tooling for small scope:
- Azure AI Custom Vision for document classification: $600/year
- Datadog monitoring (3 hosts): $828/year
- PagerDuty incident management (3 users): $1,476/year

**Support & Maintenance** ($2,710/year): Ongoing managed services (15% of cloud infrastructure):
- Business hours monitoring and support
- Monthly cost optimization reviews
- Azure service limit management

---

## Payment Terms

### Pricing Model
- Fixed price or Time & Materials (T&M)
- Milestone-based payments per Deliverables table

### Payment Schedule
- 25% upon SOW execution and project kickoff
- 30% upon completion of Discovery & Planning phase
- 30% upon completion of Implementation and Testing
- 15% upon successful go-live and project acceptance

---

## Invoicing & Expenses

### Invoicing
- Milestone-based invoicing per Payment Terms above
- Net 30 payment terms
- Invoices submitted upon milestone completion and acceptance

### Expenses
- Azure service costs are included in Cloud Infrastructure pricing ($18,068/year = ~$1,506/month)
- Small scope sizing: 50K pages/month document processing capacity
- Costs scale with actual usage - can increase/decrease based on volume
- Travel and on-site expenses reimbursable at cost with prior approval (remote-first delivery model)

---

---

# Terms & Conditions

All services will be delivered in accordance with the executed Master Services Agreement (MSA) or equivalent contractual document between Vendor and Client.

## Scope Changes
- Changes to document types, extraction requirements, integration scope, or timeline require formal change requests
- Change requests may impact project timeline and budget

## Intellectual Property
- Client retains ownership of all business data and document content
- Vendor retains ownership of proprietary AI methodologies and frameworks
- Custom AI models and configurations become Client property upon final payment
- Azure service configurations and infrastructure code transfer to Client

## Service Levels
- Document processing accuracy: 95%+ on production dataset
- System uptime: 99.5% during business hours
- 30-day warranty on all deliverables from go-live date
- Post-warranty support available under separate managed services agreement

## Liability
- Model accuracy guarantees apply only to document types and quality levels within training dataset scope
- Performance may vary with significantly different document characteristics
- Ongoing model retraining recommended as document patterns evolve
- Liability caps as agreed in MSA

## Confidentiality
- Both parties agree to maintain strict confidentiality of business data, document content, and proprietary AI techniques
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
