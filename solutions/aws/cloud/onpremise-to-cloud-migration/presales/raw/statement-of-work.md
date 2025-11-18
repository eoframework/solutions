---
document_title: Statement of Work
technology_provider: AWS
project_name: On-Premise to Cloud Migration Solution
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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing an AWS Cloud Migration for [Client Name]. This engagement will transform your organization's capabilities by delivering a comprehensive, enterprise-grade migration of on-premise workloads to AWS cloud infrastructure following the AWS Migration Acceleration Program (MAP) methodology.

**Project Duration:** 9 months (as detailed in Timeline & Milestones section)

**Key Objectives:**
- Execute phased migration of production workloads to AWS using proven migration patterns
- Establish AWS landing zone foundation with multi-account architecture and governance controls
- Achieve 30-40% infrastructure cost reduction through right-sizing and cloud optimization
- Enable cloud-native scalability and operational agility across migrated applications
- Implement security, compliance, and operational excellence following AWS Well-Architected Framework

---

---

# Background & Objectives

## Current State

[Client Name] currently operates critical business applications on aging on-premise infrastructure with significant maintenance burden. Key challenges include:
- Infrastructure Limitations: Aging hardware approaching end-of-life with costly refresh cycles
- Capacity Constraints: Limited ability to scale compute and storage to meet growing business demands
- Capital Expense Burden: High upfront infrastructure costs and extended procurement cycles
- Operational Overhead: Significant IT resources dedicated to infrastructure maintenance vs innovation
- Business Continuity Risk: Single data center architecture with limited disaster recovery capabilities
- Compliance Challenges: Difficulty maintaining audit-ready compliance controls across legacy systems

## Business Objectives

- Migrate Production Workloads: Move 5-10 core applications to AWS using lift-and-shift and replatform strategies
- Reduce Infrastructure Costs: Achieve 30-40% cost savings through cloud economics and right-sizing
- Improve Operational Agility: Enable rapid provisioning and scaling of resources to support business growth
- Enhance Business Continuity: Implement multi-AZ architecture with automated backup and disaster recovery
- Accelerate Innovation: Free IT resources from infrastructure management to focus on business value
- Establish Cloud Foundation: Deploy AWS landing zone as platform for future cloud-native development
- Modernize Operations: Implement DevOps practices with Infrastructure-as-Code and automated deployment

## Success Metrics

- Complete migration of all in-scope applications within 9 months with zero data loss
- Achieve 30-40% infrastructure cost reduction within 12 months of migration completion
- Meet or exceed current application performance baselines post-migration
- Achieve 99.9% availability for business-critical applications through AWS multi-AZ architecture
- Complete knowledge transfer enabling client operations team to manage AWS environment independently
- Obtain security and compliance sign-offs for SOC 2 controls in AWS environment
- Zero critical security findings during migration and post-migration security assessments

---

---

# Scope of Work

## In Scope

**layout:** single

**Proven AWS Migration Methodology**

This engagement follows the AWS Migration Acceleration Program (MAP) framework with three distinct phases:

- **Phase 1: Discovery & Assessment (Months 1-2)**
  - Application discovery using AWS Application Discovery Service and dependency mapping tools
  - Migration readiness assessment evaluating 7R strategies (rehost, replatform, refactor, retire, retain, relocate, repurchase)
  - Wave planning prioritizing applications by complexity, business criticality, and interdependencies
  - AWS landing zone design with Control Tower multi-account structure
  - Cost analysis and TCO modeling using AWS Migration Evaluator
  - Network connectivity design (Direct Connect or Site-to-Site VPN)
- **Phase 2: Migration Execution (Months 3-7)**
  - Landing zone deployment with security baselines, IAM policies, and governance controls
  - Hybrid connectivity establishment via AWS Direct Connect or VPN
  - Wave 1: Non-critical applications for pattern validation and team learning
  - Wave 2: Business-critical applications using proven migration patterns and runbooks
  - Wave 3: Complex/legacy applications requiring replatforming or modernization
  - Database migration using AWS DMS with continuous data replication
  - Server migration using AWS MGN (CloudEndure Migration) for live workload replication
  - Application validation and performance testing in AWS environment
- **Phase 3: Optimization & Handoff (Months 8-9)**
  - Right-sizing based on CloudWatch metrics and AWS Compute Optimizer recommendations
  - Cost optimization through Reserved Instances, Savings Plans, and S3 lifecycle policies
  - Security hardening with AWS Security Hub, GuardDuty, and compliance validation
  - Operations runbook development and knowledge transfer to client team
  - Hypercare support during stabilization period

### Scope Parameters

This engagement is sized based on the following parameters:

<!-- SCOPE_SIZING_TABLE -->
<!-- TABLE_CONFIG: widths=[18, 29, 5, 18, 30] -->
| Category | Parameter | Unit | Quantity/Value | Rationale/Notes |
|----------|-----------|------|----------------|-----------------|
| **WORKLOAD SCOPE** | | | | |
| Applications to Migrate | Total applications in migration scope | Count | 5-10 | Core business applications identified for Wave 1-3 migration |
| Virtual Machines | Total VMs/instances to migrate | Count | 25-50 | Includes app servers, DB servers, and supporting infrastructure |
| Databases | Database instances requiring migration | Count | 2-5 | MySQL, PostgreSQL, SQL Server using AWS DMS or native tools |
| Data Volume | Total data to migrate to AWS | TB | 0.5-1.0 | Includes application data, databases, and file storage |
| **MIGRATION STRATEGY** | | | | |
| Primary Strategy | Migration approach for majority of workloads | Type | Rehost (Lift-Shift) | 70% rehost, 20% replatform, 10% retain/retire |
| Secondary Strategy | Alternative migration patterns | Type | Replatform | Optimize databases to RDS, containerize select apps |
| **AWS INFRASTRUCTURE** | | | | |
| AWS Regions | Primary deployment region(s) | Count | 1 (us-east-1) | Single region with multi-AZ for HA |
| Availability Zones | AZs for production workloads | Count | 2-3 | Multi-AZ deployment for business-critical apps |
| Target Services | Core AWS services in scope | Type | EC2, RDS, S3, VPC | Standard IaaS/PaaS services for lift-shift migration |
| Compute Instances | Estimated EC2 instance footprint | Count | 30-60 | Right-sized based on on-premise resource utilization |
| **HYBRID CONNECTIVITY** | | | | |
| Network Connectivity | Connection type to on-premise datacenter | Type | Direct Connect | 1Gbps dedicated connection with VPN backup |
| Bandwidth | Hybrid network bandwidth | Gbps | 1 | Sufficient for migration data transfer and post-migration hybrid ops |
| **SECURITY & COMPLIANCE** | | | | |
| Compliance Framework | Primary compliance requirements | Standard | SOC 2 | Maintain existing compliance posture in AWS |
| Security Controls | AWS security services | Type | IAM, Security Groups, KMS | Standard cloud security baseline |
| **USERS & ACCESS** | | | | |
| Application Users | End users of migrated applications | Count | 100-500 | Existing user base, no migration impact |
| Administrative Users | IT staff managing AWS environment | Count | 5-10 | Client operations team receiving training |
| User Roles | IAM roles and access levels | Count | 3-5 | Admin, operator, read-only roles |
| **MIGRATION WINDOWS** | | | | |
| Cutover Windows | Available maintenance windows for migration | Type | Weekend/Off-hours | Minimize business disruption during cutover |
| Downtime Tolerance | Maximum acceptable downtime per application | Hours | 4-8 | Varies by application criticality |
| **ENVIRONMENTS** | | | | |
| Deployment Environments | AWS environments to provision | Count | 2-3 | Dev, Staging, Production (optional pilot environment) |

Table: Engagement Scope Parameters

*Note: Changes to these parameters may require scope adjustment and additional investment. The AWS landing zone architecture supports expansion beyond initial scope.*

<!-- /SCOPE_SIZING_TABLE -->

## Activities

### Phase 1 – Discovery & Assessment (Months 1-2)

During this initial phase, the Vendor will perform a comprehensive assessment of the Client's on-premise infrastructure and applications. This includes analyzing existing workloads, identifying dependencies, determining migration strategies, and designing the optimal AWS landing zone architecture.

Key activities:
- Application discovery using AWS Application Discovery Service and dependency mapping
- Migration readiness assessment evaluating 7R strategies (rehost, replatform, refactor, retire, retain, relocate, repurchase)
- Wave planning prioritizing applications by complexity, business criticality, and interdependencies
- AWS landing zone design with Control Tower multi-account structure
- Cost analysis and TCO modeling using AWS Migration Evaluator
- Network connectivity design (Direct Connect or Site-to-Site VPN)
- Security and compliance requirements analysis (SOC 2 controls mapping)
- Implementation planning and resource allocation

This phase concludes with a Migration Assessment Report outlining the proposed migration approach, wave assignments, AWS architecture, cost estimates, risks, and project timeline.

### Phase 2 – Migration Execution (Months 3-7)

In this phase, the AWS landing zone is deployed and applications are migrated in planned waves. Each wave follows a repeatable process with validated runbooks for risk reduction.

Key activities:
- Landing zone deployment with security baselines, IAM policies, and governance controls
- Hybrid connectivity establishment via AWS Direct Connect or Site-to-Site VPN
- Wave 1 migration: Non-critical applications for pattern validation and team learning
- Wave 2 migration: Business-critical applications using proven migration patterns and runbooks
- Wave 3 migration: Complex/legacy applications requiring replatforming or modernization
- Database migration using AWS DMS with continuous data replication
- Server migration using AWS MGN (CloudEndure Migration) for live workload replication
- Application validation and performance testing in AWS environment
- Integration testing with on-premise and third-party systems

By the end of this phase, all in-scope applications are successfully migrated to AWS with validated functionality and performance.

### Phase 3 – Optimization & Handoff (Months 8-9)

Following successful migration, focus shifts to optimization and knowledge transfer ensuring operational readiness.

Key activities:
- Right-sizing based on CloudWatch metrics and AWS Compute Optimizer recommendations
- Cost optimization through Reserved Instances, Savings Plans, and S3 lifecycle policies
- Security hardening with AWS Security Hub, GuardDuty, and compliance validation
- Operations runbook development and knowledge transfer to client team
- Hypercare support during stabilization period (4 weeks per wave)
- Performance tuning and auto-scaling policy adjustments
- Backup and disaster recovery testing
- Final as-built documentation delivery

After each phase, the Vendor will coordinate validation and sign-off with the Client before proceeding.

## Out of Scope

These items are not in scope unless added via change control:

- Application refactoring or custom development beyond migration and replatforming
- Hardware decommissioning or on-premise data center closure activities
- End-user training (technical operations team training only)
- Ongoing managed services post-hypercare period (available under separate contract)
- Third-party software licensing or SaaS subscriptions
- Migration of applications identified for retirement or retain strategies
- Legacy system integration beyond existing architecture
- Historical data archive migration beyond defined retention requirements
- On-premise network infrastructure upgrades
- AWS service costs (billed directly by AWS to client account)

---

---

# Deliverables & Timeline

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Migration Assessment Report | Document | Month 1 | Client IT Lead |
| 2 | AWS Landing Zone Infrastructure | IaC/Code | Month 2 | AWS Architect |
| 3 | Network Connectivity (Direct Connect/VPN) | System | Month 3 | Network Lead |
| 4 | Migration Wave 1 Runbooks | Document | Month 3 | Operations Lead |
| 5 | Wave 1 Application Migration Complete | System | Month 4 | Client IT Lead |
| 6 | Wave 2 Application Migration Complete | System | Month 6 | Client IT Lead |
| 7 | Wave 3 Application Migration Complete | System | Month 7 | Client IT Lead |
| 8 | Cost Optimization Report | Document | Month 8 | Client Management |
| 9 | As-Built Documentation | Document | Month 9 | Client IT Lead |
| 10 | Operations Runbooks | Document | Month 9 | Operations Team |
| 11 | Knowledge Transfer Sessions | Training | Month 9 | Technical Team |

## Project Milestones

<!-- TABLE_CONFIG: widths=[10, 25, 15, 50] -->
| Phase No | Phase Description | Timeline | Key Deliverables |
|----------|-------------------|----------|------------------|
| Phase 1 | Discovery & Assessment | Months 1-2 | Application inventory complete, Dependencies mapped, Migration waves planned, Landing zone designed |
| Phase 2 | Migration Execution | Months 3-7 | Landing zone operational, Direct Connect established, Waves 1-3 migrated, Applications validated |
| Phase 3 | Optimization & Handoff | Months 8-9 | Resources right-sized, Cost optimization active, Security hardened, Operations handoff complete |

---

---

# Roles & Responsibilities

## RACI Matrix

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO Sales Eng | EO Eng (Migration) | Client PM | Client Tech Lead | Client Ops |
|-----------|-------|----------------|--------------|--------------------|-----------|--------------------|------------|
| Discovery & Dependency Mapping | A | R | R | C | C | R | I |
| Migration Strategy & Wave Planning | A | R | R | C | C | R | I |
| AWS Landing Zone Design | C | A | R | I | I | C | I |
| Landing Zone Deployment | C | A | C | R | C | C | I |
| Network Connectivity (Direct Connect) | C | R | C | A | C | A | I |
| Migration Runbook Development | A | R | C | R | C | C | C |
| Database Migration (AWS DMS) | C | R | C | A | C | C | I |
| Server Migration (AWS MGN) | C | R | C | A | C | C | I |
| Application Cutover | R | R | C | R | A | A | C |
| IAM & Security Configuration | C | R | I | R | I | C | I |
| Cost Optimization | C | A | R | R | I | C | I |
| Performance Testing | R | R | C | R | A | A | C |
| Operations Documentation | C | R | R | R | C | A | A |
| Knowledge Transfer | A | R | R | R | C | C | A |
| Hypercare Support | A | R | C | R | C | C | A |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- EO Project Manager (EO PM): Overall delivery accountability, milestone tracking, stakeholder communication
- EO Quarterback: Technical design and oversight, architecture decisions, risk management
- EO Sales Engineer (EO Sales Eng): Solution architecture and pre-sales support, TCO analysis
- EO Engineer - Migration Specialist (EO Eng Migration): Hands-on migration execution, AWS service configuration, cutover management

**Client Team:**
- Client Project Manager (Client PM): Client-side project coordination and approvals
- Client Technical Lead (Client Tech Lead): Primary technical contact, architecture validation, security approval
- Client Operations Team (Client Ops): Day-to-day operations, knowledge transfer recipients, post-migration support
- Application SMEs: Application-specific knowledge, testing validation, cutover support

---

---

# Architecture & Design

## Architecture Overview

The AWS Cloud Migration architecture follows AWS Well-Architected Framework principles with proven migration patterns and enterprise-grade security controls. The architecture provides a secure, scalable, and compliant foundation for current workloads and future cloud-native development.

![Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: AWS Cloud Migration Architecture** - Comprehensive view of the AWS landing zone, migration services, and target application architecture

The migration architecture consists of four key layers:

- **Migration Services Layer**
  - AWS Application Discovery Service: Automated discovery and dependency mapping of on-premise applications
  - AWS Migration Hub: Centralized tracking and progress monitoring across all migration waves
  - AWS Database Migration Service (DMS): Continuous database replication with minimal downtime
  - AWS Application Migration Service (MGN/CloudEndure): Live server replication and cutover automation
  - AWS DataSync: High-performance data transfer for file storage and NAS migration
- **AWS Landing Zone Foundation**
  - Multi-account structure using AWS Control Tower and AWS Organizations for governance
  - Centralized security logging and monitoring via AWS CloudTrail, Config, and Security Hub
  - Identity federation with on-premise Active Directory via AWS SSO or IAM Identity Center
  - Network architecture with Transit Gateway, VPC design, and subnet segregation
- **Hybrid Connectivity Layer**
  - AWS Direct Connect: Dedicated 1Gbps network connection to on-premise data center
  - Site-to-Site VPN: Redundant encrypted backup connectivity for hybrid operations
  - Route 53: DNS management supporting hybrid name resolution and traffic routing
  - Transit Gateway: Centralized connectivity hub for multi-VPC and on-premise routing
- **Target Application Architecture**
  - Compute: Auto Scaling EC2 instances across multiple Availability Zones for high availability
  - Database: Amazon RDS with Multi-AZ deployment, automated backups, and read replicas
  - Storage: Amazon S3 for object storage, EBS for block storage, EFS for shared file systems
  - Content Delivery: CloudFront CDN for global content delivery and edge caching
  - Load Balancing: Application Load Balancers distributing traffic across availability zones
  - Security: VPC security groups, network ACLs, AWS WAF, GuardDuty threat detection

## Architecture Type

This solution follows a **hybrid cloud migration architecture** transitioning from on-premise infrastructure to AWS cloud-native services. Key characteristics:

- **Migration Pattern:** Phased wave-based migration with parallel operation during transition
- **Deployment Model:** Multi-account AWS landing zone with hybrid connectivity during migration, fully cloud-native post-migration
- **Scaling Approach:** Auto-scaling based on CloudWatch metrics and demand patterns
- **High Availability:** Multi-AZ deployment for production workloads with automated failover
- **Disaster Recovery:** Cross-region backup replication with documented recovery procedures (RTO: 4 hours, RPO: 1 hour)

The architecture is designed to support the scope parameters defined in this SOW, with the landing zone foundation enabling expansion to additional workloads and cloud-native services post-migration.

## Scope Specifications

This engagement is scoped for a **Standard Enterprise Migration (5-10 applications, 25-50 VMs)**. The following specifications define the migration scope and AWS infrastructure footprint:

**Migration Scope:**
- Applications: 5-10 business applications across 3 migration waves
- Virtual Machines: 25-50 VMs/instances (app servers, database servers, supporting infrastructure)
- Databases: 2-5 database instances (MySQL, PostgreSQL, SQL Server) migrated to RDS or EC2
- Data Volume: 0.5-1.0 TB total data migration
- Users: 100-500 application end users, 5-10 administrative users

**AWS Infrastructure (Target State):**
- Region: Single AWS region (us-east-1) with 2-3 Availability Zones
- Compute: 30-60 EC2 instances (t3/m5/c5 families) with Auto Scaling groups
- Database: 2-5 RDS instances with Multi-AZ deployment
- Storage: S3 Standard/IA tiers, EBS gp3 volumes, EFS for shared file systems
- Network: VPC with public/private subnets, Transit Gateway, NAT Gateways
- Load Balancing: Application Load Balancers with health checks and auto-scaling integration

**Hybrid Connectivity:**
- AWS Direct Connect: 1Gbps dedicated connection to on-premise data center
- Site-to-Site VPN: Redundant backup connectivity with BGP routing
- Bandwidth: Sufficient for migration data transfer (average 100-200 Mbps during migration) and ongoing hybrid operations

**Security & Compliance:**
- Compliance Framework: SOC 2 controls maintained from on-premise to AWS
- Encryption: All data encrypted in-transit (TLS 1.2+) and at-rest (KMS with customer-managed keys)
- Security Services: IAM Identity Center, Security Groups, NACLs, AWS WAF, GuardDuty, Security Hub
- Access Management: Role-based access control (RBAC) with least-privilege principles

**Scalability Path:**
- Current scope supports 100-500 application users with standard performance
- Landing zone architecture enables expansion to additional applications and AWS regions
- Auto-scaling capabilities allow dynamic response to variable workload demands
- Reserved Instance and Savings Plans recommendations for cost optimization at scale

Changes to scope level (adding applications, increasing infrastructure footprint, or expanding to multiple regions) will require adjustment to resources, timeline, and investment.

## Application Hosting

All migrated applications will be hosted on AWS compute services following migration best practices:

**Compute Services:**
- Amazon EC2 instances for lift-and-shift migrations (matching or right-sizing on-premise VM specifications)
- Auto Scaling groups for dynamic capacity adjustment based on CloudWatch metrics
- Application Load Balancers for traffic distribution and health-based routing
- AWS Systems Manager for patch management and operational automation

**Database Services:**
- Amazon RDS for managed relational databases (MySQL, PostgreSQL, SQL Server) with Multi-AZ deployment
- Option to run databases on EC2 for applications requiring specific configurations
- Read replicas for performance optimization and disaster recovery

**Storage Services:**
- Amazon EBS for application and database block storage (gp3 volumes for cost-performance balance)
- Amazon S3 for object storage, backups, and application artifacts with lifecycle policies
- Amazon EFS for shared file systems requiring NFS access across instances

**Deployment Approach:**
- Infrastructure-as-Code using AWS CloudFormation or Terraform for repeatability
- AWS Systems Manager for configuration management and automated patching
- Blue-green deployment patterns for zero-downtime updates post-migration
- CloudWatch monitoring and auto-scaling policies for operational efficiency

## Networking

The networking architecture follows AWS best practices for hybrid cloud connectivity and enterprise security:

**Network Topology:**
- Multi-VPC architecture: Separate VPCs for production, non-production, and shared services
- Subnet strategy: Public subnets for load balancers/NAT, private subnets for application/database tiers
- Transit Gateway: Centralized connectivity hub connecting VPCs and on-premise network
- Network segmentation: Security group and NACL rules enforcing least-privilege network access

**Hybrid Connectivity:**
- AWS Direct Connect: Dedicated 1Gbps connection from on-premise data center to AWS
  - Primary connectivity method for production data transfer during and after migration
  - Private virtual interfaces (VIFs) connecting to Transit Gateway
  - Resilient configuration with redundant Direct Connect locations (optional)
- Site-to-Site VPN: Encrypted backup connectivity over internet
  - BGP routing for automatic failover if Direct Connect experiences issues
  - Used as secondary path during migration for non-production traffic
- Hybrid DNS: Route 53 Resolver endpoints enabling DNS resolution between on-premise and AWS

**Internet Connectivity:**
- Internet Gateway for public subnet internet access (load balancers, NAT gateways)
- NAT Gateways in public subnets enabling private subnet outbound internet access
- Elastic IPs for static public addressing where required

**Security Controls:**
- VPC Flow Logs capturing all network traffic for security analysis and compliance
- Network ACLs providing stateless subnet-level filtering
- Security Groups providing stateful instance-level firewall rules
- AWS WAF protecting public-facing applications from common web exploits
- AWS Network Firewall for advanced traffic inspection (optional)

**DNS & Load Balancing:**
- Route 53: Primary DNS service with public and private hosted zones
- Application Load Balancers: Layer 7 load balancing with path-based routing
- Network Load Balancers: Layer 4 load balancing for high-performance TCP/UDP applications (if required)

## Observability

Comprehensive observability ensures operational excellence and proactive issue detection throughout migration and post-migration operations:

**Logging:**
- CloudWatch Logs: Centralized log aggregation for all EC2 instances, RDS, Lambda, and AWS services
- CloudTrail: API audit logging for all AWS account activity with cross-region replication
- VPC Flow Logs: Network traffic logging for security analysis and troubleshooting
- S3 Access Logs: Detailed access logging for compliance and security monitoring
- Log retention: 90 days hot storage in CloudWatch, long-term archive in S3 with lifecycle policies

**Monitoring:**
- CloudWatch Metrics: Infrastructure and application performance monitoring
  - CPU, memory, disk, network utilization across all EC2 instances
  - RDS database performance metrics (connections, latency, IOPS)
  - Custom application metrics via CloudWatch agent or API
- CloudWatch Dashboards: Role-based dashboards for operations, management, and application teams
- AWS Compute Optimizer: Right-sizing recommendations based on actual resource utilization
- AWS Cost Explorer: Cost monitoring and optimization recommendations

**Alerting:**
- CloudWatch Alarms: Proactive alerting for performance degradation and operational issues
  - Critical: EC2/RDS instance failures, Auto Scaling issues, high error rates (immediate notification)
  - Warning: Resource utilization approaching thresholds, elevated latency (15-minute notification)
  - Info: Deployment events, scaling activities, backup completions (daily digest)
- SNS Topics: Alert notification routing to email, SMS, PagerDuty, or incident management systems
- EventBridge: Event-driven automation for auto-remediation of common issues

**Performance Tracking:**
- Application Performance Monitoring: CloudWatch Application Insights or third-party APM (optional)
- Synthetic Monitoring: CloudWatch Synthetics for continuous availability validation
- Real User Monitoring: Application-level instrumentation for user experience tracking (optional)

**Compliance & Security Monitoring:**
- AWS Security Hub: Centralized security findings from GuardDuty, Config, IAM Access Analyzer
- AWS Config: Continuous compliance monitoring and resource configuration tracking
- GuardDuty: Threat detection analyzing CloudTrail, VPC Flow Logs, and DNS logs

## Backup & Disaster Recovery

All critical data and configurations are protected through comprehensive backup and disaster recovery strategies aligned with business continuity requirements:

**Backup Strategy:**
- Automated daily backups of all RDS databases with 7-day retention (configurable to 35 days)
- EC2 instance snapshots using AWS Backup with policy-based scheduling
- EBS volume snapshots with 30-day retention for recovery flexibility
- S3 cross-region replication for critical data protection against regional failures
- Backup validation: Monthly restoration testing to verify backup integrity and RTO/RPO compliance

**Disaster Recovery:**
- Recovery Time Objective (RTO): 4 hours for business-critical applications
- Recovery Point Objective (RPO): 1 hour for databases, 24 hours for file data
- DR Strategy: Pilot Light approach with minimal infrastructure in secondary region (us-west-2)
  - Core infrastructure and networking pre-provisioned in DR region
  - Database replication via RDS Read Replicas in secondary region
  - Automated failover using Route 53 health checks and DNS failover routing
- DR Testing: Quarterly disaster recovery drills validating failover and recovery procedures
- Runbook Documentation: Detailed DR procedures with step-by-step recovery instructions

**High Availability:**
- Multi-AZ deployment for all production RDS databases with automatic failover
- Auto Scaling groups spanning multiple Availability Zones for application tier redundancy
- Application Load Balancers with cross-AZ health checks and traffic distribution
- EFS with automatic replication across multiple Availability Zones

**Data Protection:**
- Point-in-time recovery for RDS databases enabling restoration to any second within retention period
- EBS snapshots with lifecycle policies for cost-optimized long-term retention
- S3 versioning for object storage protecting against accidental deletion
- AWS Backup centralized backup management with compliance reporting
- Immutable backups with S3 Object Lock preventing ransomware attacks (optional)

## Technical Implementation Strategy

The migration deployment follows AWS Migration Acceleration Program (MAP) methodology with proven migration patterns for risk mitigation and business continuity:

**Migration Wave Strategy:**
- Wave 1 (Month 4): Non-critical applications for pattern validation
  - 1-2 applications with minimal dependencies and lower business impact
  - Validates migration tooling, runbooks, and team processes
  - Lessons learned incorporated into subsequent waves
- Wave 2 (Months 5-6): Business-critical applications using proven patterns
  - 3-5 applications following validated migration approach
  - Scheduled cutover windows with comprehensive testing
  - Parallel operation period allowing safe rollback if issues arise
- Wave 3 (Month 7): Complex/legacy applications requiring replatforming
  - 1-2 applications with modernization requirements (e.g., migrate to RDS, containerization)
  - Extended validation period with performance benchmarking
  - Phased user migration supporting gradual transition

**Migration Patterns:**
- Rehost (Lift-and-Shift): 70% of applications using AWS Application Migration Service (MGN)
  - Minimal changes during migration for fast, low-risk transition
  - Live replication from on-premise to AWS with point-in-time cutover
  - Right-sizing occurs post-migration based on CloudWatch metrics
- Replatform: 20% of applications optimizing database tier
  - Migrate databases from on-premise to Amazon RDS for operational efficiency
  - Modernize select applications to containerized deployment (ECS/EKS) if appropriate
  - Leverage managed AWS services reducing operational overhead
- Retain/Retire: 10% of applications staying on-premise or decommissioned
  - Applications with compliance restrictions or near end-of-life remain on-premise temporarily
  - Obsolete systems identified for retirement avoiding unnecessary migration costs

**Risk Mitigation:**
- Parallel Operation: Maintain on-premise systems operational during initial AWS validation period
- Incremental Cutover: Migrate applications individually with validated rollback procedures
- Pilot Testing: Test migration approach with non-critical application before production workloads
- Data Validation: Automated data integrity verification comparing source and target datasets
- Performance Baseline: Establish on-premise performance metrics for AWS comparison and optimization

**Infrastructure as Code:**
- All AWS infrastructure deployed using CloudFormation or Terraform for consistency and repeatability
- Version-controlled IaC enabling audit trail and change management
- Environment parity ensuring development, staging, and production consistency
- Automated deployment pipelines for future infrastructure changes

## Example Implementation Patterns

**Phased Rollout Approach:**
- Discovery Sprint (Weeks 1-2): Inventory all applications, map dependencies, identify integration points
- Design Sprint (Weeks 3-4): Document target AWS architecture, network connectivity, security controls
- Landing Zone Build (Weeks 5-8): Deploy multi-account foundation, establish Direct Connect, implement security baseline
- Wave 1 Migration (Weeks 9-12): Migrate pilot application, validate tooling, refine runbooks
- Wave 2 Migration (Weeks 13-20): Migrate business-critical applications using proven patterns
- Wave 3 Migration (Weeks 21-28): Complete complex migrations with replatforming
- Optimization Phase (Weeks 29-36): Right-size resources, implement Reserved Instances, finalize operations handoff

**Database Migration Pattern (AWS DMS):**
1. Pre-Migration: Assess database compatibility, schema conversion (AWS SCT if needed)
2. Initial Replication: Full load of database to RDS with continuous change data capture (CDC)
3. Validation: Compare row counts, checksums, and sample data between source and target
4. Cutover Preparation: Reduce DNS TTL, notify users, prepare rollback procedures
5. Cutover Window: Stop application writes, final sync, switch connection strings, validate application
6. Post-Cutover: Monitor performance, decommission source database after validation period

**Server Migration Pattern (AWS MGN):**
1. Agent Installation: Deploy AWS MGN replication agent on source servers
2. Initial Replication: Full disk replication to AWS staging area (low-priority bandwidth)
3. Continuous Sync: Ongoing replication of block-level changes with minimal impact
4. Testing: Launch test instances in AWS, validate application functionality and performance
5. Cutover: Launch production instances from latest replication, update DNS, decommission source servers

**Hybrid Operation Pattern:**
- Maintain hybrid connectivity (Direct Connect + VPN) for 3-6 months post-migration
- Support applications requiring temporary on-premise integration during transition
- Enable gradual migration of tightly coupled application groups
- Provide fallback path if unexpected issues require temporary repatriation

## Tooling Overview

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Primary Tools | Purpose |
|----------|---------------|---------|
| Migration Planning | AWS Migration Hub, Migration Evaluator | Centralized tracking, TCO analysis, wave planning |
| Discovery & Assessment | Application Discovery Service, CloudScape | Automated dependency mapping, inventory management |
| Database Migration | AWS Database Migration Service (DMS) | Continuous database replication with minimal downtime |
| Server Migration | AWS Application Migration Service (MGN) | Live server replication for lift-and-shift migrations |
| Data Transfer | AWS DataSync, AWS Transfer Family | High-performance file/NAS migration, SFTP integration |
| Infrastructure as Code | AWS CloudFormation, Terraform | Landing zone deployment, reproducible infrastructure |
| Network Connectivity | AWS Direct Connect, Site-to-Site VPN | Dedicated hybrid connectivity with encrypted backup |
| Security & Compliance | AWS Config, Security Hub, GuardDuty | Continuous compliance monitoring, threat detection |
| Monitoring & Logging | CloudWatch, CloudTrail, VPC Flow Logs | Centralized observability and audit logging |
| Cost Optimization | AWS Cost Explorer, Compute Optimizer | Cost visibility, right-sizing recommendations |

## Data Management

**Data Migration Strategy:**
- Database Migration: AWS DMS with continuous replication and minimal cutover downtime
  - Full load followed by ongoing CDC (Change Data Capture) for real-time sync
  - Schema conversion using AWS Schema Conversion Tool (SCT) if changing database engines
  - Data validation comparing row counts, checksums, and sample queries between source/target
- File/Storage Migration: AWS DataSync for high-performance bulk data transfer
  - NFS/SMB file shares migrated to Amazon EFS or FSx
  - Object storage migrated to Amazon S3 with lifecycle policies
  - Scheduled incremental transfers minimizing impact to production systems
- Application Data: Included in server migration via AWS MGN (block-level replication)

**Data Validation:**
- Automated integrity checks verifying data consistency post-migration
- Reconciliation reports comparing source and target datasets (row counts, checksums, sample data)
- Application-level validation ensuring business processes function correctly with migrated data
- Performance benchmarking comparing query response times and throughput vs on-premise baseline

**Data Lifecycle & Governance:**
- S3 Lifecycle Policies: Automated transition to S3 Intelligent-Tiering or Glacier for cost optimization
- Data Retention: Policies aligned with regulatory requirements (7-year retention for financial data, etc.)
- Data Classification: Tagging strategy identifying sensitive data (PII, PHI, PCI) for appropriate controls
- Backup & Archival: Automated backup policies with cross-region replication for disaster recovery
- Secure Deletion: Cryptographic erasure and versioning controls supporting GDPR and data privacy requirements

**Data Security:**
- Encryption: All data encrypted in-transit (TLS 1.2+) and at-rest (KMS customer-managed keys)
- Key Management: AWS KMS with automatic key rotation and audit logging via CloudTrail
- Access Controls: S3 bucket policies, IAM policies, and VPC endpoints enforcing least-privilege access
- Data Loss Prevention: S3 versioning, MFA delete, and Object Lock preventing accidental or malicious deletion

---

---

# Security & Compliance

The AWS cloud environment will be architected and validated to meet the Client's security, compliance, and governance requirements following AWS Well-Architected Framework security pillar best practices.

## Identity & Access Management

- AWS IAM Identity Center (successor to AWS SSO): Centralized identity management with federation to on-premise Active Directory
- Role-Based Access Control (RBAC): Least-privilege IAM roles and policies for all users and AWS services
- Multi-Factor Authentication (MFA): Required for all AWS console access and privileged operations
- Service Accounts: IAM roles for EC2 instances and AWS services eliminating long-lived credentials
- Access Keys Rotation: Automated 90-day rotation policy with CloudWatch alarms for expiring credentials
- Cross-Account Access: IAM roles enabling secure access between AWS accounts in landing zone
- Third-Party Integration: SAML 2.0 federation for SSO with existing enterprise identity provider
- Privileged Access Management: Break-glass emergency access procedures with comprehensive audit logging

## Monitoring & Threat Detection

- AWS CloudTrail: Comprehensive API audit logging for all AWS account activity
  - Multi-region trail capturing all management and data events
  - Log file integrity validation with digital signatures
  - CloudWatch Logs integration for real-time analysis and alerting
  - Long-term archive in S3 with encryption and lifecycle policies
- Amazon GuardDuty: Intelligent threat detection analyzing CloudTrail, VPC Flow Logs, and DNS logs
  - Automated detection of reconnaissance, instance compromise, account compromise threats
  - Integration with Security Hub for centralized security findings
  - Automated remediation via EventBridge and Lambda for common threats
- AWS Security Hub: Centralized security posture management and compliance dashboard
  - Automated security checks against CIS AWS Foundations Benchmark
  - Aggregated findings from GuardDuty, Config, IAM Access Analyzer, and third-party tools
  - Compliance reporting for SOC 2, PCI DSS, HIPAA frameworks
- VPC Flow Logs: Network traffic analysis for security monitoring and forensics
  - Capture all network traffic at VPC, subnet, or ENI level
  - Integration with CloudWatch Logs Insights for query and analysis
  - Anomaly detection for unusual traffic patterns or data exfiltration attempts
- CloudWatch Alarms: Proactive alerting for security events and policy violations
  - Failed authentication attempts, IAM policy changes, security group modifications
  - Root account usage, MFA disabled, access key age exceeding 90 days
  - Unusual API call patterns or resource configuration changes

## Compliance & Auditing

- Compliance Frameworks: SOC 2 Type II controls maintained from on-premise to AWS environment
- AWS Config: Continuous compliance monitoring and resource configuration tracking
  - Automated evaluation of AWS Config Rules against compliance standards
  - Configuration history for all resources supporting audit and forensic analysis
  - Compliance dashboards showing conformance to SOC 2, CIS, and custom policies
  - Remediation runbooks for non-compliant resources
- Audit Trail: Comprehensive logging of all system changes and user activity
  - CloudTrail capturing all API calls and management operations
  - Database audit logging for RDS instances
  - Application logs with user activity and data access tracking
  - Log retention aligned with regulatory requirements (7 years for financial records)
- Compliance Reporting: Automated evidence collection and compliance attestation
  - AWS Artifact: Access to AWS compliance reports and certifications
  - Security Hub compliance scores and findings reports
  - Custom compliance dashboards for management and auditor review
- Regular Assessments: Quarterly compliance reviews and annual penetration testing
  - Internal vulnerability scanning using AWS Inspector or third-party tools
  - External penetration testing coordinated with AWS and approved testers
  - Compliance gap analysis and remediation tracking

## Governance

**Change Management:**
- Formal change request process for all production environment modifications
- Impact assessment and approval workflows via ServiceNow or ITSM platform
- Change Advisory Board (CAB) review for high-risk changes
- Maintenance windows and blackout periods aligned with business calendar
- Post-change validation and automated rollback procedures

**Policy Enforcement:**
- AWS Organizations Service Control Policies (SCPs): Preventive guardrails blocking non-compliant actions
  - Restrict unapproved AWS regions preventing data residency violations
  - Prevent disabling of security services (CloudTrail, GuardDuty, Config)
  - Enforce encryption for S3 buckets and EBS volumes
  - Require MFA for privileged operations
- Infrastructure Drift Detection: Automated detection and remediation of manual changes
  - CloudFormation drift detection comparing actual vs expected state
  - AWS Config Rules flagging resources not matching compliance baselines
  - Automated remediation using Systems Manager Automation or Lambda
- Security Baseline Enforcement: Standardized security configurations across all accounts
  - CIS AWS Foundations Benchmark controls applied via AWS Config
  - Security group rules limiting SSH/RDP access to bastion hosts
  - S3 bucket encryption and public access blocking enforced by default
  - Patch management via Systems Manager ensuring OS and application updates

**Access Reviews:**
- Quarterly review of IAM users, roles, and permissions
  - Automated access certification workflows via Identity Governance tool
  - Removal of unused credentials and excessive permissions
  - Validation of access aligned with job responsibilities and separation of duties
- Privileged Access Management: Just-in-time access provisioning for elevated permissions
  - Time-bound access grants with automatic expiration
  - Approval workflows for privileged access requests
  - Session recording and monitoring for compliance and forensics
- Service Account Management: Periodic review of IAM roles and application credentials
  - Rotation of application secrets via AWS Secrets Manager
  - Validation of least-privilege permissions for service roles
  - Removal of unused service accounts and applications

**Resource Governance:**
- Tagging Strategy: Mandatory tags for cost allocation and resource management
  - Environment (production, staging, development)
  - Application/Workload, Cost Center, Owner, Compliance Scope
  - Automated enforcement via AWS Organizations tag policies
  - Tag compliance monitoring and remediation
- Cost Governance: Budget alerts and anomaly detection preventing cost overruns
  - AWS Budgets with email/SNS notifications for threshold exceedance
  - Cost anomaly detection using machine learning to identify unusual spending
  - Reserved Instance and Savings Plans optimization reviews
- Capacity Management: Proactive monitoring and planning for AWS service limits
  - Service Quotas dashboard tracking current usage vs limits
  - Automated alerts when approaching soft limits (EC2 instances, VPC resources)
  - Quarterly capacity planning reviews forecasting growth and limit increase requests

## Encryption & Key Management

**Data Encryption:**
- Data at Rest: All storage encrypted using AWS KMS with customer-managed keys (CMKs)
  - EBS volumes: Encrypted by default with per-volume unique keys
  - S3 buckets: Server-side encryption (SSE-KMS) with bucket default encryption
  - RDS databases: Encryption enabled for data, logs, and automated backups
  - EFS file systems: Encryption at rest using KMS integration
- Data in Transit: TLS 1.2+ encryption for all network communications
  - HTTPS/TLS for all API calls and application traffic
  - VPN encryption for hybrid connectivity (IPsec with AES-256-GCM)
  - Direct Connect with MACsec encryption for dedicated network connection (optional)
  - Database connections using TLS/SSL certificates

**Key Management:**
- AWS Key Management Service (KMS): Centralized cryptographic key management
  - Customer-managed CMKs providing full control over key lifecycle and access policies
  - Automatic annual key rotation enabled for all CMKs
  - Key usage audit logging via CloudTrail for compliance and forensics
  - Multi-region keys enabling encrypted data replication across regions
- Key Policies and Access Control: Least-privilege access to encryption keys
  - Separate keys per environment (production, non-production) and workload
  - IAM policies and KMS key policies restricting decryption operations
  - Grants enabling temporary key access for specific operations
- Secrets Management: AWS Secrets Manager for application credentials and API keys
  - Automatic rotation of database credentials and API keys
  - Versioning and audit logging of secret access
  - Integration with RDS for database credential management
  - VPC endpoints for private network access to Secrets Manager

**Encryption Standards:**
- Algorithm: AES-256 encryption for data at rest
- TLS Version: TLS 1.2 minimum, TLS 1.3 preferred for data in transit
- Key Length: 256-bit encryption keys, 2048-bit RSA keys minimum
- Cipher Suites: Only strong cipher suites enabled, weak/deprecated ciphers disabled
- Certificate Management: AWS Certificate Manager (ACM) for SSL/TLS certificates with automated renewal

## Environments & Access

### Environment Strategy

<!-- TABLE_CONFIG: widths=[20, 25, 25, 30] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | Feature development, testing migration patterns | Development team, migration engineers | Anonymized/synthetic data for testing |
| Staging | Integration testing, UAT, pre-production validation | Project team, testers, business users | Production-like data (masked PII) |
| Production | Live operational environment for migrated applications | Operations team, authorized application users | Production data |

### Access Policies

**Administrative Access:**
- Multi-factor authentication (MFA) required for all AWS console access
- Privileged access management (PAM) for elevated permissions with time-bound grants
- Session recording and monitoring for audit compliance via CloudTrail
- Break-glass emergency access procedures with comprehensive logging

**Migration Team Access:**
- Full access to development and staging environments for migration execution
- Controlled access to production for cutover events and troubleshooting
- VPN or Direct Connect connectivity for secure hybrid operations
- Code and infrastructure changes via Infrastructure-as-Code with approval workflows

**Operations Team Access:**
- Limited production access for day-to-day operations and monitoring
- Read-only access to CloudWatch, CloudTrail, and operational dashboards
- Automated deployment pipelines reducing manual intervention
- Incident response procedures with documented escalation paths

**End User Access:**
- Application-level authentication via existing identity provider (federated SSO)
- No direct AWS console access for application end users
- Application access controls unchanged from on-premise (transparent migration)

---

---

# Testing & Validation

Comprehensive testing and validation occur throughout the migration lifecycle to ensure functionality, performance, security, and business continuity of migrated applications.

## Functional Validation

Comprehensive functional testing ensures all applications work as designed in AWS environment:

**End-to-End Testing:**
- Complete business workflow validation for each migrated application
- User journey testing across integrated systems and dependencies
- Data flow verification ensuring information passes correctly between components
- API integration testing with dependent systems (on-premise and cloud)

**Component Testing:**
- Application functionality validation against requirements and test cases
- Database query and transaction testing verifying data integrity
- Authentication and authorization testing confirming user access controls
- Batch job and scheduled task validation ensuring automated processes function correctly

**Acceptance Criteria:**
- All business functions operational matching or exceeding on-premise capabilities
- Data integrity verified with reconciliation reports comparing source and target
- Integration points validated with end-to-end transaction testing
- User acceptance sign-off obtained from application owners and business stakeholders

**Migration Wave Validation:**
- Wave 1: Extended validation period (2 weeks) establishing baseline for subsequent waves
- Wave 2: Standard validation period (1 week) following proven test plans
- Wave 3: Enhanced validation for replatformed applications requiring performance benchmarking

## Performance & Load Testing

Performance validation ensures migrated applications meet or exceed on-premise baselines and handle expected production loads:

**Load Testing:**
- Baseline Performance Testing: Validate migrated applications match or exceed on-premise response times
  - Application response time benchmarking under typical load conditions
  - Database query performance comparison against on-premise metrics
  - Network latency measurement between application tiers and integrated systems
- Sustained Load Testing: Verify system stability under expected production traffic
  - Run at 100% of expected peak traffic for extended duration (4-8 hours)
  - Monitor resource utilization (CPU, memory, disk, network) across all components
  - Validate auto-scaling triggers and behavior under sustained load
- Concurrent User Testing: Simulate realistic user access patterns
  - Multiple users performing typical workflows simultaneously
  - Verify system responsiveness under realistic concurrency levels

**Stress Testing:**
- Peak Capacity Testing: Validate auto-scaling and performance at 2x expected peak traffic
  - Identify resource bottlenecks and scaling limitations
  - Verify Auto Scaling policies respond appropriately to demand increases
  - Ensure graceful degradation rather than catastrophic failure under extreme load
- Resource Exhaustion Scenarios: Test system behavior when resources are constrained
  - CPU/memory saturation on EC2 instances
  - Database connection pool exhaustion on RDS
  - Network bandwidth saturation
  - Storage IOPS limits on EBS volumes

**Benchmarking:**
- Response Time Validation: Target response times aligned with on-premise baselines
  - API endpoint response times (target: < on-premise baseline or 200ms)
  - Page load times for web applications
  - Database query execution times
  - Batch job completion times
- Throughput Measurement: Transactions per second and data processing rates
  - Compare AWS throughput to on-premise capacity
  - Validate headroom for business growth and peak events
- Resource Utilization: CPU, memory, disk, and network utilization profiling
  - Identify over-provisioned resources for cost optimization
  - Flag under-provisioned resources requiring scaling

## Security Testing

Comprehensive security validation ensuring migrated applications meet security requirements and compliance standards:

**Vulnerability Assessment:**
- Automated Vulnerability Scanning: AWS Inspector or third-party tools scanning all EC2 instances
  - OS-level vulnerability detection with CVE mapping and severity scoring
  - Network reachability analysis identifying unintended exposure
  - Software composition analysis detecting vulnerable libraries and dependencies
- Security Baseline Validation: CIS Benchmarks and AWS security best practices compliance
  - Automated Config Rules evaluating security configuration standards
  - Security Hub compliance checks against industry frameworks
- Remediation: Prioritized vulnerability remediation based on severity and exploitability
  - Critical/High vulnerabilities addressed before production cutover
  - Medium/Low vulnerabilities tracked for post-migration remediation

**Access Control Testing:**
- IAM Policy Validation: Verify least-privilege access controls
  - Test user access to AWS console and API operations
  - Validate service roles have only required permissions
  - Confirm cross-account access roles function correctly
- Authentication Testing: MFA enforcement and SSO integration validation
  - Verify MFA required for console access and privileged operations
  - Test SSO integration with corporate identity provider
  - Validate session timeout and re-authentication policies
- Authorization Testing: Application-level RBAC and data access controls
  - Verify users can only access authorized applications and data
  - Test role-based access control within migrated applications
  - Confirm API authentication and authorization mechanisms

**Encryption Validation:**
- Data at Rest: Verify all storage encrypted using KMS customer-managed keys
  - EBS volume encryption validation
  - S3 bucket encryption and bucket policy enforcement
  - RDS database encryption for data and backups
- Data in Transit: Confirm TLS encryption for all network communications
  - HTTPS/TLS for application traffic and API calls
  - TLS for database connections from application tier
  - VPN/Direct Connect encryption for hybrid connectivity
- Key Management: Audit key access and rotation policies
  - CloudTrail logs showing key usage and access patterns
  - Automated key rotation enabled and functioning

**Compliance Validation:**
- SOC 2 Controls: Validate controls maintained from on-premise to AWS
  - Access controls, change management, monitoring, incident response
  - Evidence collection for annual audit
- Penetration Testing (Optional): Third-party security assessment
  - Coordinated with AWS (permission required for some testing activities)
  - OWASP Top 10 vulnerability testing for web applications
  - Network penetration testing identifying attack vectors
  - Social engineering assessment testing user awareness (optional)

## Disaster Recovery & Resilience Tests

Validation of backup, recovery, and failover capabilities ensuring business continuity requirements are met:

**Backup Validation:**
- Backup Creation Verification: Confirm automated backups executing on schedule
  - RDS automated daily backups with 7-day retention
  - EBS snapshot policies via AWS Backup
  - S3 cross-region replication for critical data
- Restore Testing: Validate backups are recoverable and complete
  - Monthly restore testing to validate backup integrity
  - RDS point-in-time recovery validation
  - EC2 instance restoration from AMI snapshots
  - File-level restoration from S3 or EBS snapshots
- Backup Encryption: Verify all backups encrypted at rest
  - RDS backup encryption using KMS
  - EBS snapshot encryption matching source volume
  - S3 backup encryption with bucket default settings

**Failover Testing:**
- RDS Multi-AZ Failover: Validate automated database failover
  - Trigger RDS failover event monitoring application behavior
  - Measure failover duration and application reconnection time
  - Verify no data loss during failover event
- Auto Scaling Failover: Test application tier resilience with instance termination
  - Terminate running instances verifying Auto Scaling launches replacements
  - Validate load balancer health checks remove failed instances from rotation
  - Confirm zero customer impact during instance replacement
- Cross-Region DR Failover (if configured): Test disaster recovery procedures
  - Manual failover to DR region following documented runbooks
  - DNS failover using Route 53 health checks and routing policies
  - Validation of DR environment functionality and data freshness

**RTO/RPO Verification:**
- Timed Recovery Exercises: Measure actual recovery times against targets
  - RTO Target: 4 hours for business-critical applications
  - RPO Target: 1 hour for databases, 24 hours for file data
- Scenario Testing: Validate recovery procedures for different failure types
  - Single instance failure (Auto Scaling replacement)
  - Availability Zone failure (Multi-AZ failover)
  - Regional failure (Cross-region DR failover)
- Dependency Mapping: Identify recovery sequencing for dependent applications
  - Database tier must be recovered before application tier
  - Shared services and networking before application-specific resources
- Runbook Validation: Execute recovery procedures verifying documentation accuracy
  - Step-by-step execution of documented recovery processes
  - Identification of gaps or outdated procedures
  - Runbook updates based on lessons learned

## User Acceptance Testing (UAT)

UAT is performed in coordination with Client business stakeholders to validate that migrated applications meet business requirements and user expectations:

**UAT Approach:**
- UAT Environment: Dedicated AWS environment provisioned with production-like data
  - Masked production data or representative synthetic data
  - Network connectivity to integrated systems (production or test endpoints)
  - Full application functionality available for testing
- Test Cases: Derived from business requirements and typical user workflows
  - Critical business processes and high-volume transactions
  - Edge cases and error handling scenarios
  - Integration scenarios with dependent systems
- User Participation: Business users and application owners execute test scenarios
  - Training provided on accessing AWS-hosted applications (if different from on-premise)
  - Defect tracking and issue reporting process
  - Daily standup meetings during UAT period for issue triage

**Acceptance Criteria:**
- All critical business workflows validated by application owners
- Performance meets or exceeds on-premise baseline (response times, throughput)
- User interface and experience approved by end users (no degradation)
- Integration with business systems verified through end-to-end transactions
- Data integrity confirmed with reconciliation reports
- Security and compliance requirements met

**Sign-Off:**
- Formal UAT sign-off document obtained from business stakeholders
- Known issues and workarounds documented and accepted
- Go-live readiness determination based on UAT results
- Stakeholder approval to proceed with production migration

## Go-Live Readiness

A comprehensive readiness assessment conducted before each migration wave cutover to production:

**Readiness Checklist:**
- [ ] All functional tests passed with zero critical defects
- [ ] Performance benchmarks met or exceeded on-premise baseline
- [ ] Security testing completed with all critical/high vulnerabilities remediated
- [ ] UAT sign-off obtained from application owners and business stakeholders
- [ ] Data integrity verified through reconciliation reports
- [ ] Backup and recovery procedures tested and validated
- [ ] Monitoring and alerting operational with dashboards configured
- [ ] CloudWatch alarms configured for critical metrics
- [ ] Runbooks documented for operations team with troubleshooting procedures
- [ ] Rollback procedures documented and rehearsed
- [ ] Change approval obtained from Change Advisory Board (CAB)
- [ ] Stakeholder communication completed (notification of cutover window)
- [ ] Operations team trained and prepared for production support
- [ ] Hypercare support plan activated with 24/7 on-call coverage
- [ ] DNS TTL reduced to enable fast failback if needed
- [ ] Direct Connect or VPN connectivity validated for hybrid operations

**Sign-Off Approval:**
- Technical Lead: Infrastructure readiness and technical validation
- Security Lead: Security testing and compliance approval
- Application Owner: Functional validation and business readiness
- Project Sponsor: Final go/no-go decision and cutover authorization

## Cutover Plan

The production cutover is carefully planned and executed to minimize risk and downtime for each migration wave:

**Pre-Cutover (T-7 days):**
- Final cutover plan review and approval from all stakeholders
- Cutover team assignments and responsibility matrix (RACI)
- Communication sent to all stakeholders with cutover schedule and contact information
- Change Advisory Board (CAB) approval obtained for production change
- DNS TTL reduction initiated to enable fast DNS propagation during cutover

**Pre-Cutover (T-1 day):**
- Final data synchronization from on-premise to AWS (DMS, MGN, DataSync)
- Pre-cutover backup of on-premise systems for rollback capability
- Validation of AWS environment readiness (all resources healthy, monitoring operational)
- Support team briefed and on standby for cutover execution
- Rollback procedures reviewed and validated
- Stakeholder reminder communication with cutover start time and duration

**Cutover Window (Migration Night):**
- **T0 (Start):** Maintenance window begins, application access disabled for users
- **T+15 min:** Final data synchronization completes, source systems placed in read-only mode
- **T+30 min:** AWS environment health checks validated, all resources green
- **T+45 min:** DNS updated pointing to AWS application endpoints
- **T+60 min:** DNS propagation monitored, traffic gradually shifting to AWS
- **T+90 min:** Smoke testing of critical application paths in production environment
- **T+120 min:** Application access re-enabled for users, monitoring for errors and performance
- **T+180 min:** Maintenance window ends (if no critical issues), stakeholder notification sent

**Post-Cutover (T+1 day):**
- Daily health check meetings with operations team (first 2 weeks)
- Issue log reviewed and prioritized for resolution
- Performance metrics validated against baseline (response time, throughput, error rates)
- Customer feedback collected and documented
- On-premise systems kept operational for rollback capability (1-2 weeks)

**Post-Cutover (T+2 weeks):**
- Decommission on-premise systems after successful stabilization period
- Right-sizing analysis based on actual CloudWatch metrics
- Cost optimization recommendations (Reserved Instances, Savings Plans)
- Transition from hypercare to standard operations support

## Cutover Checklist

Detailed step-by-step checklist for cutover execution ensuring no critical steps are missed:

**T-7 Days (One Week Before):**
- [ ] Cutover plan review and approval completed
- [ ] Cutover team roles and responsibilities assigned (RACI matrix)
- [ ] Communication sent to all stakeholders with cutover schedule
- [ ] Change Advisory Board (CAB) approval obtained
- [ ] DNS TTL reduced to 60 seconds for fast failback capability
- [ ] War room (physical or virtual) scheduled for cutover night
- [ ] Escalation contacts and communication channels confirmed

**T-1 Day (Day Before):**
- [ ] Final data sync completed (DMS, MGN, DataSync)
- [ ] Pre-cutover backup of on-premise systems verified
- [ ] AWS environment health checks validated (all resources healthy)
- [ ] Support team briefed and on standby
- [ ] Rollback procedures reviewed and rehearsed
- [ ] Stakeholder reminder communication sent
- [ ] Cutover runbook printed and distributed to team

**Cutover Day (Migration Night):**
- [ ] Maintenance window begins, user access disabled
- [ ] Application monitoring paused to avoid false alarms during cutover
- [ ] Final incremental data sync executed
- [ ] Source systems placed in read-only mode or shut down
- [ ] AWS environment final health check (EC2, RDS, Load Balancers all healthy)
- [ ] DNS records updated pointing to AWS endpoints
- [ ] DNS propagation monitored (dig/nslookup validation)
- [ ] Smoke tests executed for critical application paths
- [ ] Application monitoring re-enabled in AWS environment
- [ ] User access re-enabled for production use
- [ ] Initial user login and transaction validation
- [ ] Stakeholder notification: cutover complete and successful
- [ ] On-premise systems kept operational for rollback (48-hour window)

**T+1 Day (Day After):**
- [ ] Daily health check meeting completed
- [ ] Issue log reviewed (all critical issues resolved or workarounds in place)
- [ ] Performance metrics validated against baseline
- [ ] Error rate monitoring (target: <0.1% of transactions)
- [ ] Customer feedback collected and documented
- [ ] Hypercare support activated with 24/7 on-call coverage

**T+1 Week:**
- [ ] Week 1 hypercare review and lessons learned
- [ ] Performance optimization recommendations identified
- [ ] Decision on decommissioning on-premise systems (if stable)
- [ ] Right-sizing analysis initiated based on CloudWatch data

## Rollback Strategy

Comprehensive rollback procedures in case of critical issues during cutover ensuring business continuity:

**Rollback Triggers:**
- Critical functionality failure affecting primary business operations
- Data integrity issues discovered (missing or corrupted data)
- Performance degradation exceeding acceptable thresholds (2x baseline response time)
- Security incident or breach detected during cutover
- Unresolved critical defects blocking core business processes
- Stakeholder decision to abort cutover due to business impact

**Rollback Decision Process:**
- Decision Point: Within 30-60 minutes of issue detection
- Decision Makers: Project Manager, Technical Lead, Application Owner, Executive Sponsor
- Go/No-Go Assessment: Severity, impact, time to resolution, risk of continued operation in AWS
- Communication: Immediate notification to all stakeholders of rollback decision

**Rollback Procedures:**
1. **DNS Revert:** Update DNS records to redirect traffic back to on-premise systems
   - Execute within 5 minutes of rollback decision
   - Monitor DNS propagation using dig/nslookup validation
   - Validate on-premise systems are healthy and accepting traffic
2. **Database Rollback:** Restore database from pre-cutover backup if data changes occurred in AWS
   - Point-in-time recovery to pre-cutover state
   - Validate data integrity and completeness
   - Sync any critical transactions entered during brief AWS operation (manual reconciliation)
3. **Application Rollback:** Reactivate on-premise application servers
   - Restart application services on on-premise infrastructure
   - Validate application functionality and connectivity to database
   - Re-enable monitoring and alerting for on-premise environment
4. **User Notification:** Communicate rollback status to stakeholders and end users
   - Acknowledge issue and rollback action
   - Provide ETA for resolution and rescheduled cutover
5. **Validation:** Confirm on-premise systems fully operational
   - End-to-end transaction testing
   - User access and authentication validation
   - Performance and error rate monitoring

**Rollback Timeline:**
- Decision Point: Within 30-60 minutes of critical issue detection
- Execution Time: Maximum 2 hours to complete full rollback to on-premise
- Validation: 1 hour to verify on-premise system stability and user access

**Post-Rollback:**
- Root Cause Analysis: Detailed investigation of rollback trigger
  - Issue reproduction in non-production environment
  - Identification of root cause and contributing factors
  - Lessons learned documentation
- Remediation Plan: Corrective actions and validation approach
  - Fix implementation and testing in non-production
  - Regression testing ensuring fix resolves issue without side effects
  - Validation with stakeholders before rescheduling cutover
- Revised Cutover Date: Determination of new migration date
  - Coordination with business for acceptable maintenance window
  - Communication of new cutover schedule to all stakeholders
  - Additional rehearsal of cutover procedures addressing lessons learned

---

---

# Handover & Support

## Handover Artifacts

Upon successful migration completion, the following artifacts will be delivered to the Client for ongoing operations:

**Documentation Deliverables:**
- As-Built Architecture Documentation
  - Comprehensive AWS architecture diagrams (network, application, security, data flow)
  - Landing zone account structure and organizational units
  - VPC design with subnet allocation, routing tables, and connectivity
  - Security group and NACL configurations
  - IAM roles, policies, and identity federation setup
- Infrastructure-as-Code Repositories
  - CloudFormation templates or Terraform configurations for all AWS resources
  - Version-controlled IaC with change history and documentation
  - Deployment procedures and environment management
- Migration Documentation
  - Application inventory with dependencies and migration wave assignments
  - Migration runbooks for each application with step-by-step procedures
  - Cutover checklists and validation procedures
  - Lessons learned and best practices from migration execution

**Operational Deliverables:**
- Operations Runbooks and Standard Operating Procedures (SOPs)
  - Daily operations checklist for health monitoring and routine tasks
  - Incident response procedures for common issues (EC2 failures, RDS failover, connectivity issues)
  - Troubleshooting guides with diagnostic steps and resolution procedures
  - Change management procedures for infrastructure and application updates
- Monitoring and Alerting Configuration
  - CloudWatch dashboard configurations for different stakeholder views
  - Alert definitions with severity levels and escalation procedures
  - Log analysis queries for common troubleshooting scenarios
- Performance Tuning and Optimization Recommendations
  - Right-sizing analysis based on post-migration CloudWatch metrics
  - Reserved Instance and Savings Plans purchase recommendations
  - Auto Scaling policy tuning based on actual traffic patterns
  - Storage optimization recommendations (S3 lifecycle, EBS volume types)
- Backup and Disaster Recovery Procedures
  - Backup validation and restore procedures
  - Disaster recovery runbook with step-by-step failover instructions
  - RTO/RPO validation and testing schedule

**Knowledge Assets:**
- Training Materials
  - Recorded knowledge transfer sessions with Q&A
  - AWS service reference guides tailored to implemented architecture
  - Video demonstrations of common operational tasks
- Configuration Management Repository
  - Centralized repository with all configuration files and scripts
  - Access credentials documentation and key management procedures
  - Third-party integration configurations and API documentation
- Support Contacts and Escalation
  - AWS Support contact information and case management procedures
  - Third-party vendor support contacts (if applicable)
  - Internal escalation paths for critical issues

## Knowledge Transfer

Knowledge transfer ensures the Client operations team can effectively manage and optimize the AWS environment:

**Training Sessions:**
- Session 1: AWS Landing Zone and Infrastructure Overview (4 hours)
  - AWS account structure, Organizations, and Control Tower governance
  - VPC networking, Direct Connect/VPN connectivity, and hybrid architecture
  - EC2 instance management, Auto Scaling, and load balancing
  - Hands-on: Navigate AWS console, review architecture, perform common tasks
- Session 2: Application Operations and Monitoring (4 hours)
  - Application architecture and dependencies for migrated workloads
  - CloudWatch monitoring, dashboards, and alerting configuration
  - Log analysis using CloudWatch Logs Insights
  - Performance monitoring and troubleshooting methodology
  - Hands-on: Review application dashboards, create custom metrics, analyze logs
- Session 3: Security, Compliance, and Incident Response (4 hours)
  - IAM Identity Center, roles, policies, and access management
  - Security Hub, GuardDuty, and security monitoring
  - Compliance monitoring with AWS Config and automated remediation
  - Incident response procedures and escalation paths
  - Hands-on: Review security findings, investigate CloudTrail logs, respond to sample incident
- Session 4: Database Management and Backup/Recovery (4 hours)
  - RDS database management, Multi-AZ failover, and read replicas
  - Backup and restore procedures for RDS and EC2
  - Disaster recovery runbook walkthrough
  - Performance tuning and query optimization
  - Hands-on: Trigger RDS failover, restore from backup, review DR procedures
- Session 5: Cost Management and Optimization (3 hours)
  - AWS Cost Explorer and cost allocation reporting
  - Right-sizing recommendations using Compute Optimizer
  - Reserved Instances and Savings Plans analysis
  - S3 storage optimization with lifecycle policies
  - Hands-on: Analyze cost reports, identify optimization opportunities

**Documentation Package:**
- Operations Manual: Comprehensive guide for day-to-day AWS management
- Architecture Diagrams: Visual reference for network, application, and security architecture
- Runbooks: Step-by-step procedures for common operational tasks
- Troubleshooting Guide: Diagnostic steps for common issues and error messages
- Optimization Playbook: Strategies for ongoing cost and performance optimization
- Security and Compliance Guide: Maintaining security posture and compliance standards

**Training Format:**
- Live Interactive Sessions: Conducted via video conference with screen sharing
- Hands-On Labs: Participants perform tasks in AWS console with guidance
- Recorded Sessions: All sessions recorded and provided for future reference
- Q&A and Office Hours: Follow-up sessions for questions and clarifications
- Documentation Portal: Centralized location for all training materials and recordings

## Hypercare Support

Post-migration hypercare support ensures smooth transition to Client-managed operations:

**Duration:** 4 weeks post-go-live (per migration wave, 12 weeks total for 3 waves)

**Coverage:**
- Business Hours Support: Monday-Friday, 8 AM - 6 PM local time
- Extended Hours: On-call support for critical issues (24/7 for first 2 weeks of each wave)
- Response Time: 4-hour response for critical issues, 1-business day for non-critical
- Daily Health Checks: First 2 weeks include daily health check calls with operations team
- Weekly Status Meetings: Progress reviews, issue tracking, optimization discussions

**Scope:**
- Issue Investigation and Resolution
  - Troubleshooting application issues, performance degradation, or errors
  - AWS service configuration issues or unexpected behavior
  - Integration problems between AWS and on-premise or third-party systems
  - Security alerts and incident response assistance
- Performance Tuning
  - Right-sizing recommendations based on CloudWatch metrics
  - Auto Scaling policy adjustments based on actual traffic patterns
  - Database performance optimization (RDS parameter tuning, query optimization)
  - Network latency investigation and optimization
- Configuration Adjustments
  - Security group or NACL rule modifications for approved requirements
  - CloudWatch alarm threshold adjustments to reduce false positives
  - Backup policy refinements based on operational experience
  - Monitoring dashboard enhancements for improved visibility
- Knowledge Transfer Continuation
  - On-the-job training during issue resolution
  - Additional training sessions for topics requiring deeper coverage
  - Best practices guidance for emerging operational scenarios
  - Transition planning for post-hypercare operations

**Exclusions:**
- New feature development or application enhancements
- Infrastructure expansion beyond migrated scope
- Training for additional staff beyond initial knowledge transfer
- Ongoing managed services (available under separate contract)

## Managed Services Transition (Optional)

Post-hypercare, Client may transition to ongoing managed services for continuous support and optimization:

**Managed Services Options:**
- **24/7 Monitoring and Support:** Round-the-clock infrastructure and application monitoring
  - Proactive issue detection and resolution before business impact
  - Incident response and escalation management
  - Root cause analysis and corrective action implementation
- **Proactive Optimization:** Continuous performance and cost optimization
  - Monthly right-sizing reviews with implementation recommendations
  - Reserved Instance and Savings Plans optimization (quarterly reviews)
  - Storage lifecycle optimization and data archival
  - Performance bottleneck identification and remediation
- **Patch Management:** Automated OS and application patching
  - Monthly patch cycles with testing and validation
  - Vulnerability remediation based on security scanning results
  - Rollback procedures for failed patches
- **Capacity Planning:** Forecasting and proactive resource scaling
  - Quarterly capacity planning reviews forecasting 6-12 month growth
  - AWS service limit monitoring and increase requests
  - Performance trend analysis identifying future constraints
- **Continuous Improvement:** Ongoing architecture optimization
  - Adoption of new AWS services and features providing business value
  - Architecture reviews aligning with evolving AWS best practices
  - Quarterly business reviews with optimization roadmap

**Transition Approach:**
- Evaluation Phase (during hypercare): Assess managed services requirements
  - Review operational capabilities and gaps in Client team
  - Determine appropriate level of managed services (basic, standard, premium)
  - Define custom service level agreements (SLAs) aligned with business needs
- Service Level Agreement (SLA) Definition
  - Response times: Critical (30 min), High (2 hours), Medium (1 day), Low (3 days)
  - Availability targets: 99.9% for production environment
  - Performance targets: Application response time, database query performance
  - Escalation procedures and communication protocols
- Separate Managed Services Contract and Pricing
  - Tiered pricing models based on scope and service levels
  - Fixed monthly fee or consumption-based pricing
  - Annual contracts with quarterly business reviews
- Seamless Transition: No disruption during handoff from hypercare to managed services
  - Same team continuity for first 90 days of managed services
  - Gradual expansion of services based on Client needs
  - Flexible scaling up/down based on changing requirements

---

---

# Investment Summary

## Total Investment

This section provides a comprehensive overview of the total investment required for this AWS Cloud Migration engagement, broken down by cost category and displayed across a 3-year period.

The investment includes all professional services for migration execution, AWS infrastructure consumption, software tools and subscriptions, and ongoing support. Partner credits and migration program benefits are applied to reduce Year 1 costs.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[20, 12, 23, 13, 10, 10, 12] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Cloud Infrastructure | $0 | $0 | $0 | $0 | $0 | $0 |
| Professional Services | $0 | $0 | $0 | $0 | $0 | $0 |
| Software Licenses | $0 | $0 | $0 | $0 | $0 | $0 |
| Support & Maintenance | $0 | $0 | $0 | $0 | $0 | $0 |
| **TOTAL INVESTMENT** | **$0** | **$0** | **$0** | **$0** | **$0** | **$0** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** Partner and AWS Migration Acceleration Program (MAP) credits reduce initial investment

Credits represent real AWS account credits, partner services discounts, or MAP program benefits applied to reduce Year 1 costs:

**Credit Breakdown:**
- **AWS MAP Credit:** Applied to professional services for migration execution following MAP methodology
- **AWS Infrastructure Credit:** Applied to Year 1 AWS consumption (EC2, RDS, S3, networking services)
- **Partner Services Credit:** Applied to consulting services for assessment, migration, and optimization

**Credit Terms:**
- Credits are one-time Year 1 benefits; Years 2-3 reflect standard pricing
- AWS MAP credits require participation in AWS Migration Acceleration Program with milestone tracking
- Credits are automatically applied as services are consumed through AWS billing
- Unused AWS credits may expire per AWS MAP program terms

**Investment Comparison:**
- **Year 1 Net Investment:** Reflects professional services, AWS infrastructure, and software after credits applied
- **3-Year Total Cost of Ownership:** Includes all costs for migration and 2 years of ongoing AWS operations
- **Expected ROI:** 12-18 month payback based on infrastructure cost reduction and eliminated data center costs

## Cost Components

**Professional Services:** Migration consulting services for assessment, execution, and knowledge transfer
- Discovery & Assessment: Application inventory, dependency mapping, wave planning, TCO analysis
- Migration Execution: Landing zone deployment, network connectivity, wave migrations, validation
- Optimization & Training: Right-sizing, cost optimization, security hardening, knowledge transfer
- Hypercare Support: 4 weeks post-migration support per wave ensuring successful stabilization

**Cloud Infrastructure:** AWS consumption for hosting migrated applications
- Compute (EC2): Right-sized instances based on on-premise resource utilization analysis
- Database (RDS): Managed database services with Multi-AZ deployment and automated backups
- Storage (S3, EBS): Object and block storage with lifecycle policies for cost optimization
- Networking: Direct Connect, VPN, Transit Gateway, load balancers for hybrid connectivity
- Security & Monitoring: CloudWatch, GuardDuty, Security Hub, CloudTrail logging

**Software Licenses:** Third-party tools and AWS subscriptions
- Migration Tools: AWS Application Migration Service (MGN), Database Migration Service (DMS)
- Monitoring & Management: Third-party APM, ITSM integration, backup solutions (if required)
- Security Tools: Vulnerability scanning, compliance automation (beyond native AWS services)

**Support & Maintenance:** Ongoing AWS Support plan and optional managed services
- AWS Support: Business or Enterprise Support plan for AWS technical assistance
- Managed Services (Optional): Post-hypercare ongoing operations support under separate contract

Detailed breakdown including AWS service consumption estimates, right-sizing analysis, and line-item pricing is provided in infrastructure-costs.xlsx.

---

# Terms & Conditions

## Assumptions

### General Assumptions

This AWS Cloud Migration engagement is based on the following assumptions:

**Client Responsibilities:**
- Client will provide timely access to on-premise systems, environments, documentation, and infrastructure for discovery
- Client technical team and application SMEs will be available for requirements validation, testing, UAT, and approvals per project schedule
- Client will provide application subject matter experts (SMEs) with deep knowledge of application architecture, dependencies, and business logic
- Client will handle internal change management, stakeholder communication, and end-user notifications
- Client will obtain necessary approvals and sign-offs per internal governance processes (CAB, security, compliance)
- Client will maintain on-premise systems operational during migration for rollback capability
- Client will provide AWS account access with appropriate service limits and permissions within 1 week of project start

**On-Premise Infrastructure:**
- On-premise infrastructure is documented with current architecture diagrams, network topology, and application dependencies
- Virtual machines are running supported operating systems compatible with AWS MGN (Windows Server 2008 R2+, modern Linux distributions)
- Databases are running versions compatible with AWS RDS or migration to RDS-supported versions is acceptable
- Network bandwidth is sufficient for migration data transfer (minimum 100 Mbps available during migration windows)
- Application source code and configurations are available for validation and troubleshooting
- Sufficient on-premise storage available for pre-migration backups and rollback capability

**Technical Environment:**
- Existing infrastructure meets minimum requirements for migration to AWS (hardware, OS versions, database compatibility)
- Applications are compatible with AWS cloud environment (no hard-coded dependencies on on-premise infrastructure)
- Network connectivity supports hybrid operation during migration (Direct Connect or VPN with sufficient bandwidth)
- Databases support replication technologies for minimal-downtime migration (native replication, AWS DMS compatibility)
- Integration endpoints and APIs for dependent systems are documented and accessible

**Project Execution:**
- Migration scope (5-10 applications, 25-50 VMs) and requirements remain stable during implementation
- Resources (both Vendor and Client) are available per project plan and RACI matrix
- No major organizational changes, application upgrades, or infrastructure changes during migration execution
- Security and compliance approval processes will not delay critical path activities
- Cutover maintenance windows are available per planned schedule (weekends or off-hours)
- On-premise systems can tolerate 4-8 hour downtime windows for cutover (varies by application)

**AWS Environment:**
- AWS account is provisioned with required service limits and quotas (EC2 instances, VPCs, Direct Connect)
- Client has signed AWS Customer Agreement or Enterprise Agreement enabling AWS service consumption
- AWS service availability and performance meet SLAs during migration and post-migration
- AWS Direct Connect circuit can be provisioned within 4-6 weeks (or VPN used as interim connectivity)
- No AWS region restrictions or data residency requirements beyond standard AWS service availability

**Timeline:**
- Project start date is confirmed with resources committed by both parties
- Milestone dates are based on continuous progress without extended delays or resource unavailability
- Client approvals and decisions provided within 5 business days of request
- Testing and UAT cycles completed within allocated timeframes (1-2 weeks per wave)

## Dependencies

### Project Dependencies

Critical dependencies that must be satisfied for successful migration execution:

**Access & Infrastructure:**
- AWS account access with Administrator or PowerUser permissions provided within 1 week of project start
- On-premise infrastructure access (vCenter, ESXi, physical servers) for discovery and migration agent installation
- Network connectivity to on-premise environment for migration tooling and data transfer
- Direct Connect circuit provisioning completed by Month 3 (or interim VPN established)
- DNS and domain management access for cutover to AWS-hosted applications

**Discovery & Assessment:**
- Application inventory with business owners, criticality, and dependencies provided by Client
- Representative data samples and environment access for discovery and assessment activities
- Application SME availability for interviews, dependency mapping, and requirements validation (2-4 hours per application)
- Network diagrams, application architecture documentation, and integration specifications provided
- Database schemas, data dictionaries, and data volume estimates provided for migration planning

**Migration Execution:**
- Cutover maintenance windows scheduled and communicated to business stakeholders (per wave)
- Application SMEs available during migration windows for validation and troubleshooting
- On-premise infrastructure team available for migration support (network, storage, virtualization)
- Database administrators available for database migration and validation
- Security and compliance approvals obtained on schedule to avoid implementation delays

**Testing & Validation:**
- Test data and test cases provided by Client for UAT and functional validation
- Business users available for UAT execution per planned schedule (1-2 weeks per wave)
- Performance baseline metrics from on-premise environment for comparison
- Integration test environments for dependent systems (if migration phased)
- Sign-off authority available for UAT approval and production cutover authorization

**Post-Migration:**
- Client operations team available for knowledge transfer sessions (5 sessions x 3-4 hours each)
- Hypercare support participation for daily health checks and issue triage
- Decision authority for post-migration optimization and cost optimization recommendations
- Budget approval for Reserved Instances and Savings Plans purchases (cost optimization)

**External Factors:**
- No major changes to on-premise systems or integrated applications during migration waves
- AWS service availability and support responsiveness per AWS Support SLAs
- Third-party vendor support for migration tooling or integrated systems (if applicable)
- Regulatory or compliance requirement changes communicated with sufficient lead time for adaptation

---

## Payment Terms

### Pricing Model

**Fixed Price with Milestone-Based Payments:** Professional services delivered on fixed-price basis with payment milestones aligned to project phases and deliverables. AWS infrastructure costs billed separately per actual consumption.

**Payment Schedule:**
- 25% upon SOW execution and project kickoff
- 25% upon completion of Phase 1 - Discovery & Assessment (Month 2)
- 30% upon completion of Phase 2 - Migration Execution (Month 7)
- 20% upon successful completion and project acceptance (Month 9)

**Invoicing:** Monthly invoicing based on milestones completed. Net 30 payment terms from invoice date.

**Expenses:** AWS infrastructure costs billed directly by AWS to Client account. Travel and incidental expenses reimbursable at cost with prior written approval.

## Invoicing & Expenses

### Invoicing Process

**Invoice Submission:**
- Invoices submitted upon milestone completion and formal acceptance by Client
- Invoices include detailed breakdown of services delivered and milestone evidence
- Supporting documentation provided (deliverable sign-offs, timesheets, expense reports)
- AWS infrastructure costs billed separately by AWS (not included in Vendor invoicing)

**Payment Terms:**
- Net 30 days from invoice date
- Payment via ACH, wire transfer, or check per agreed payment method
- Late payment fees may apply per Master Services Agreement (MSA) terms
- Invoice disputes must be raised within 10 business days of receipt

**Invoice Review:**
- Client has 10 business days to review and approve/dispute invoices
- Disputes resolved within 15 business days through joint review meeting
- Undisputed invoice portions paid on schedule per payment terms

### Reimbursable Expenses

**Travel Expenses (if applicable):**
- On-site presence may be required for kickoff, cutover events, and knowledge transfer
- Airfare: Economy class for domestic travel, premium economy for international
- Lodging: Standard business hotel rates (government per diem or equivalent)
- Ground transportation: Rental car or taxi/rideshare for on-site travel
- Meals: Per diem rates per Vendor company policy

**Other Expenses:**
- Shipping and courier services for hardware (if physical appliances required)
- Third-party software licenses or AWS Marketplace products purchased on Client's behalf
- Training materials, documentation printing, and supplies
- Co-location or data center access fees (if required for on-premise work)

**Expense Policy:**
- All travel requires prior written approval with estimated costs
- Receipts required for individual expenses over $75
- Monthly expense reports submitted with invoices
- Client approval required for expenses exceeding budgeted amounts
- Vendor absorbs expenses without prior approval

---

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) between Vendor and Client. This Statement of Work is governed by the terms and conditions of the MSA.

## Scope Changes

Any changes to migration scope (additional applications, infrastructure expansion), schedule, or cost require a formal Change Request approved by both parties.

**Change Request Process:**
- Change requests submitted in writing describing proposed modification and business justification
- Impact assessment provided by Vendor within 5 business days addressing timeline, cost, and risk implications
- Mutual approval required before change implementation
- Change control log maintained tracking all approved changes

**Common Change Scenarios:**
- Adding applications or VMs beyond initial scope (impacts timeline and cost)
- Changing migration strategy (rehost to replatform increases complexity and duration)
- Expanding AWS regions or availability zones (impacts network architecture and cost)
- Adding security or compliance requirements beyond initial scope
- Accelerating timeline requiring additional resources or overtime work

## Intellectual Property

- **Client IP:** Client retains ownership of all business data, application code, configurations, and documentation specific to their environment
- **Vendor IP:** Vendor retains ownership of proprietary migration methodologies, frameworks, tools, accelerators, and pre-existing IP
- **Developed IP:** Custom configurations, Infrastructure-as-Code, scripts, and documentation developed during engagement transfer to Client upon final payment
- **AWS IP:** AWS service configurations and console access remain Client property; AWS terms govern AWS service usage
- **Pre-existing IP:** All pre-existing intellectual property remains with original owner; no transfer of ownership implied

## Service Levels

- **Migration Execution:** Deliverables provided per agreed milestone schedule with formal acceptance criteria
- **Hypercare Period:** 4 weeks per migration wave with defined response times (4-hour critical, 1-day non-critical)
- **Extended Support:** Available via managed services contract beyond hypercare period (separate agreement and pricing)
- **Best-Effort Basis:** Services provided on commercially reasonable best-effort basis unless specific SLAs defined in MSA

## Liability

- Liability capped as defined in Master Services Agreement
- Excludes gross negligence, willful misconduct, or intellectual property infringement claims
- Professional liability insurance maintained by Vendor covering services rendered
- AWS service availability and performance governed by AWS SLAs (not Vendor responsibility)

## Confidentiality

- All exchanged artifacts under NDA protection per MSA confidentiality terms
- Client data handled per security requirements and confidentiality obligations
- No disclosure to third parties without prior written consent (except as required by law)
- Vendor may reference Client as case study or reference (with Client approval)

## Termination

- Either party may terminate with 30 days written notice per MSA termination provisions
- Payment due for all completed work through termination date
- Deliverables and documentation transferred upon termination and final payment
- Transition assistance available for 30 days post-termination (at T&M rates)
- Return or destruction of confidential information per MSA requirements

## Governing Law

This Statement of Work shall be governed by the laws of the State specified in the Master Services Agreement, without regard to conflict of law principles.

---

---

# Sign-Off

By signing below, both parties agree to the scope, approach, roles, deliverables, timeline, and terms outlined in this Statement of Work.

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

*This Statement of Work constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter. This SOW is governed by the Master Services Agreement executed between the parties.*
