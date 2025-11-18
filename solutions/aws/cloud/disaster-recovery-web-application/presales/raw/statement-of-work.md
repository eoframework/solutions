---
document_title: Statement of Work
technology_provider: AWS
project_name: Disaster Recovery Web Application Solution
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

This Statement of Work (SOW) defines the scope, deliverables, roles, and terms for implementing an AWS Disaster Recovery solution for [Client Name]. This engagement will deliver comprehensive business continuity capabilities through automated failover, cross-region replication, and disaster recovery procedures following AWS best practices for highly available architectures.

**Project Duration:** 6 months

**Key Objectives:**
- Implement automated disaster recovery with cross-region failover capabilities for critical web applications
- Achieve defined RTO (Recovery Time Objective) and RPO (Recovery Point Objective) targets
- Establish comprehensive DR testing, validation, and runbook procedures
- Enable business continuity assurance through proven AWS multi-region architecture
- Reduce disaster recovery risk and meet compliance requirements for business continuity

---

# Background & Objectives

## Current State

[Client Name] currently operates critical web applications in a single AWS region without formal disaster recovery capabilities. Key challenges include:
- No documented disaster recovery plan or runbooks for critical applications
- Single point of failure with no automated failover capabilities
- Unacceptable business risk exposure from potential regional outages
- Manual recovery processes requiring hours or days to restore operations
- Compliance gaps for business continuity and disaster recovery requirements
- Limited visibility into recovery readiness and testing capabilities

## Business Objectives

- Implement AWS-native disaster recovery solution with pilot light strategy for 5-10 critical applications
- Achieve 4-hour RTO and 1-hour RPO through cross-region replication and automated backup
- Establish automated failover capabilities with DNS-based traffic management (Route 53)
- Reduce business continuity risk through regular DR testing and validation (quarterly drills)
- Meet compliance requirements for documented and tested disaster recovery procedures
- Enable foundation for expanding DR coverage to additional applications and workloads

## Success Metrics

- 4-hour RTO and 1-hour RPO validated through quarterly disaster recovery testing
- 95% success rate on planned DR failover exercises
- Zero data loss during controlled failover tests
- Documented and tested disaster recovery runbooks for all in-scope applications
- Automated backup validation with weekly verification reports
- Operations team trained and certified on DR procedures

---

# Scope of Work

## In Scope

The following disaster recovery services and deliverables are included in this SOW:
- Business impact assessment and critical application prioritization
- AWS disaster recovery architecture design (pilot light strategy)
- Secondary AWS region setup and cross-region networking
- Database replication configuration (RDS/Aurora cross-region replication)
- Application deployment to DR region with automated synchronization
- Data replication and backup strategy implementation
- Automated failover configuration with Route 53 health checks
- DR monitoring dashboard and alerting system
- Comprehensive disaster recovery testing and validation
- DR runbook creation and operations training
- 30-day hypercare support period

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

## Out of Scope

These items are not in scope unless added via change control:
- Legacy application re-architecture or modernization beyond DR requirements
- Third-party software licensing for DR environments
- Physical hardware procurement or on-premises data center setup
- Network infrastructure modifications outside AWS environments
- Historical data migration or back-file conversion for non-critical systems
- Application performance optimization unrelated to disaster recovery
- Ongoing operational support beyond 30-day hypercare period
- Compliance audit services or regulatory reporting
- End-user training (technical operations team only)

## Activities

### Phase 1 – Discovery & Assessment (Weeks 1-3)

During this initial phase, the Vendor will perform a comprehensive business impact assessment and disaster recovery requirements analysis.

Key activities:
- Business impact assessment and critical application identification
- Current state disaster recovery capability evaluation
- RTO/RPO requirements analysis and validation with business stakeholders
- Compliance and regulatory requirement assessment (SOC 2, HIPAA, etc.)
- Disaster scenario modeling and risk assessment
- Application dependency mapping and failover sequencing
- DR architecture design with pilot light strategy
- Implementation planning and resource allocation

**Deliverable:** Business Impact Assessment & DR Architecture Document

### Phase 2 – Solution Design & Environment Setup (Weeks 4-7)

In this phase, the secondary AWS region infrastructure is provisioned and configured based on disaster recovery best practices.

Key activities:
- Secondary AWS region account setup and configuration
- Cross-region VPC peering and networking connectivity
- Database replication configuration (Aurora Global Database or RDS cross-region replication)
- Application server AMI preparation and DR deployment
- Route 53 health checks and DNS failover configuration
- S3 cross-region replication for static assets and backups
- Security baseline configuration (IAM, KMS, encryption)
- Backup strategies and retention policies

**Deliverable:** DR Environment & Replication Infrastructure

### Phase 3 – Implementation & Execution (Weeks 8-11)

Implementation will occur in well-defined phases based on application priority and complexity.

Key activities:
- Web application deployment to DR region with minimal standby capacity
- Real-time database replication setup and synchronization validation
- Application configuration management and environment parity
- File system and static content cross-region replication
- Load balancer configuration in DR region
- Automated failover trigger development and testing
- Monitoring and alerting integration (CloudWatch, third-party tools)
- Incremental validation and troubleshooting

**Deliverable:** Operational DR System with Active Replication

### Phase 4 – Testing & Validation (Weeks 12-14)

The DR solution undergoes thorough functional, performance, and resilience validation.

Key activities:
- DR testing framework and procedures development
- Planned failover testing from primary to DR region
- Database consistency validation after failover
- Application functionality testing in DR environment
- Performance benchmarking in DR region
- Full disaster simulation exercises with controlled failback
- RTO/RPO validation against requirements
- Business process validation in DR mode

**Deliverable:** DR Test Results Report & Validated Runbooks

### Phase 5 – Handover & Support (Weeks 15-18)

Following successful implementation, focus shifts to ensuring operational continuity.

Key activities:
- DR runbook documentation with step-by-step procedures
- Operations team training on failover and recovery procedures
- 24/7 monitoring setup and incident response procedures
- Executive disaster response briefing and communication plans
- Hands-on failover simulation training exercises
- Ongoing DR testing schedule and maintenance planning
- 30-day hypercare support with on-call assistance
- Knowledge transfer and documentation delivery

**Deliverable:** DR Operations Runbook & Knowledge Transfer

---

# Deliverables & Timeline

## Deliverables

<!-- TABLE_CONFIG: widths=[8, 40, 12, 20, 20] -->
| # | Deliverable | Type | Due Date | Acceptance By |
|---|-------------|------|----------|---------------|
| 1 | Business Impact Assessment | Document | Week 3 | Client Sponsor |
| 2 | DR Architecture Document | Document | Week 3 | Technical Lead |
| 3 | DR Implementation Plan | Project Plan | Week 3 | Client Sponsor |
| 4 | DR Environment & Infrastructure | System | Week 7 | Technical Lead |
| 5 | Replication & Failover System | System | Week 11 | Technical Lead |
| 6 | DR Test Plan & Results | Document | Week 14 | QA Lead |
| 7 | DR Operations Runbook | Document | Week 15 | Operations Lead |
| 8 | DR Monitoring Dashboard | System | Week 15 | Operations Lead |
| 9 | Training Materials | Document/Video | Week 16 | Training Lead |
| 10 | As-Built Documentation | Document | Week 18 | Client IT Lead |
| 11 | Knowledge Transfer Sessions | Training | Week 16-18 | Client Team |

## Project Milestones

<!-- TABLE_CONFIG: widths=[20, 55, 25] -->
| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| M1 - Assessment Complete | Business impact analysis and DR architecture approved | Week 3 |
| M2 - DR Environment Ready | Secondary region infrastructure provisioned | Week 7 |
| M3 - Replication Active | Database and application replication operational | Week 11 |
| M4 - Testing Complete | DR validation exercises passed | Week 14 |
| Go-Live | DR system operational with monitoring | Week 15 |
| Hypercare End | Support period complete | Week 18 |

---

# Roles & Responsibilities

## RACI Matrix

<!-- TABLE_CONFIG: widths=[28, 11, 11, 11, 11, 9, 9, 10] -->
| Task/Role | EO PM | EO Quarterback | EO Sales Eng | EO Eng (DR) | Client IT | Client Sponsor | SME |
|-----------|-------|----------------|--------------|-------------|-----------|----------------|-----|
| Discovery & BIA | A | R | R | C | C | R | C |
| DR Architecture Design | C | A | R | I | I | C | I |
| Infrastructure Setup | C | A | C | R | C | I | I |
| Replication Configuration | C | R | C | A | C | I | I |
| Failover Automation | C | R | C | A | C | I | I |
| Testing & Validation | R | R | C | R | A | C | I |
| Runbook Development | A | R | C | R | C | I | I |
| Knowledge Transfer | A | R | R | C | C | I | I |

**Legend:** R = Responsible | A = Accountable | C = Consulted | I = Informed

## Key Personnel

**Vendor Team:**
- EO Project Manager: Overall delivery accountability and timeline management
- EO Quarterback: Technical design, architecture oversight, and quality assurance
- EO Sales Engineer: Solution architecture, pre-sales support, and stakeholder engagement
- EO Engineer (DR): DR infrastructure implementation, replication, and failover configuration

**Client Team:**
- IT Lead: Primary technical contact and AWS access management
- Business Sponsor: Executive oversight and business continuity requirements validation
- Operations Team: Knowledge transfer recipients and ongoing DR management
- Subject Matter Experts: Application requirements and DR validation

---

# Architecture & Design

## Architecture Overview

The AWS Disaster Recovery solution implements a pilot light, multi-region architecture designed for cost-effective business continuity with 4-hour RTO and 1-hour RPO. The architecture provides automated cross-region replication, health monitoring, and DNS-based failover to ensure rapid recovery from regional disasters.

![Solution Architecture Diagram](assets/diagrams/architecture-diagram.png)

**Figure 1: AWS Pilot Light DR Architecture** - High-level overview of the multi-region disaster recovery architecture

The proposed architecture provides:
- **Primary Region (us-east-1):** Full production capacity with 3-tier web application
- **DR Region (us-west-2):** Minimal standby infrastructure with automated scaling on failover
- **Continuous Replication:** Aurora Global Database for real-time data replication
- **Automated Failover:** Route 53 health checks with DNS-based traffic management
- **Cost Optimization:** Pilot light strategy minimizes idle DR infrastructure costs

## Architecture Type

This solution follows a **pilot light disaster recovery** architecture pattern. Key characteristics:

- **Scaling Approach:** Minimal DR capacity that auto-scales on failover activation
- **Deployment Model:** Multi-region AWS with active-passive configuration
- **Component Distribution:** Primary region active, DR region standby with rapid activation
- **Communication Patterns:** Cross-region replication, health monitoring, and automated failover

The architecture is designed to support the scope parameters defined in this SOW, balancing cost optimization with business continuity requirements.

## Scope Specifications

This engagement is scoped for a **Small (1x)** pilot light deployment. The following table outlines resource specifications for different scope levels:

**DR Strategy & RTO/RPO:**
- Small (1x): Pilot light | RTO 4 hours | RPO 1 hour | 5-10 applications
- Medium (2x): Warm standby | RTO 1 hour | RPO 15 minutes | 10-25 applications
- Large (3x): Hot standby | RTO 15 minutes | RPO 5 minutes | 25+ applications, mission-critical

**Compute & Application:**
- Small (1x): 2-4 EC2 instances in DR (minimal standby), auto-scale on failover
- Medium (2x): 5-10 EC2 instances in DR (reduced capacity), faster recovery
- Large (3x): Full capacity in DR region (active-active), near-instant failover

**Database & Storage:**
- Small (1x): Aurora Global Database (cross-region replication) | 50-100 GB
- Medium (2x): Multi-region Aurora with read replicas | 100-500 GB
- Large (3x): Active-active database with conflict resolution | 500+ GB

**Network & Failover:**
- Small (1x): Route 53 health checks with DNS failover (60-second TTL)
- Medium (2x): Global Accelerator for faster failover (<30 seconds)
- Large (3x): Traffic management with automatic traffic splitting

**Availability & Cost:**
- Small (1x): Cost-optimized pilot light | ~15% of primary region costs
- Medium (2x): Balanced warm standby | ~40% of primary region costs
- Large (3x): Full hot standby | ~100% of primary region costs (2x total)

Changes to scope level will require adjustment to DR infrastructure, testing frequency, and investment.

## Application Hosting

All application logic will be hosted using AWS managed services in both regions:

**Primary Region (us-east-1) - Production:**
- EC2 Auto Scaling groups for web and application tiers
- Application Load Balancer (ALB) for traffic distribution
- Aurora MySQL or PostgreSQL for relational database
- ElastiCache for session management and caching
- S3 for static assets and backups

**DR Region (us-west-2) - Standby:**
- Minimal EC2 instances (pilot light) with launch templates for rapid scaling
- Pre-configured ALB with health checks (inactive until failover)
- Aurora Global Database read replica (promoted to primary on failover)
- S3 with cross-region replication enabled
- CloudWatch alarms and automated scaling policies

**Deployment Approach:**
- Infrastructure-as-Code (CloudFormation/Terraform) for consistent multi-region deployment
- AMI baking with application code for rapid DR instance launch
- Automated DNS failover using Route 53 health checks

## Networking

The networking architecture follows AWS best practices for multi-region disaster recovery:

**Network Topology:**
- VPC in both primary and DR regions with identical CIDR structure
- VPC peering for cross-region connectivity (if required for replication)
- Private subnets for application and database tiers
- Public subnets for load balancers and NAT gateways

**Connectivity:**
- Route 53 for DNS management and health-based failover
- VPN or Direct Connect for hybrid connectivity (if applicable)
- VPC endpoints for private AWS service access
- Cross-region VPC peering for management and monitoring

**Security Controls:**
- Network ACLs for subnet-level security in both regions
- Security Groups for instance-level firewall rules
- AWS WAF for application layer protection
- DDoS protection with AWS Shield Standard

## Observability

Comprehensive observability ensures operational excellence and rapid disaster detection:

**Logging:**
- CloudWatch Logs for centralized logging across both regions
- Structured logging with correlation IDs for cross-region tracing
- Log retention aligned with compliance requirements (30 days)
- Real-time log analysis for failover triggers

**Monitoring:**
- CloudWatch Dashboards showing health across both regions
- Application performance metrics (response time, error rates, throughput)
- Infrastructure metrics (CPU, memory, network, replication lag)
- Business KPIs (uptime, failover status, DR readiness)

**Alerting:**
- CloudWatch Alarms for primary region health degradation
- Route 53 health checks triggering automated failover
- PagerDuty integration for incident escalation
- SMS and email notifications for disaster scenarios

## Backup & Disaster Recovery

All critical data and configurations are protected through comprehensive backup and DR strategies:

**Backup Strategy:**
- Aurora automated backups with 30-day retention
- Aurora snapshots copied to DR region daily
- S3 versioning and cross-region replication for static assets
- AMI snapshots for rapid EC2 instance recovery
- Regular backup restoration testing (monthly)

**Disaster Recovery:**
- Recovery Time Objective (RTO): 4 hours (time to restore operations)
- Recovery Point Objective (RPO): 1 hour (acceptable data loss)
- DR region: us-west-2 (geographically separated from primary)
- Automated failover via Route 53 health checks (<15 minutes detection)
- Documented failover and failback procedures in DR runbook
- Quarterly DR drills with full failover validation

**Data Protection:**
- Aurora Global Database for continuous cross-region replication (lag <1 second)
- Point-in-time recovery for databases up to 30 days
- Infrastructure-as-Code version control in Git
- Immutable S3 backups with object lock to prevent ransomware

## Technical Implementation Strategy

The deployment will follow a phased disaster recovery implementation approach with incremental validation.

**Implementation Patterns:**
- Pilot light strategy: Minimal DR resources that scale on-demand during failover
- Cross-region replication: Aurora Global Database and S3 CRR for data consistency
- Automated failover: Route 53 health checks detect primary region failure and redirect traffic
- Infrastructure parity: CloudFormation templates ensure consistent configuration across regions

**Infrastructure as Code:**
All infrastructure will be deployed using CloudFormation/Terraform for consistency, version control, and rapid DR environment rebuild if needed.

## Example Implementation Patterns

**Phased Rollout:**
- Phase 1: Implement DR for highest-priority application (pilot)
- Phase 2: Expand to remaining critical applications
- Phase 3: Conduct full DR test with controlled failover and failback

**Testing Approaches:**
- Quarterly planned failover exercises to validate RTO/RPO
- Monthly backup restoration validation
- Automated health checks and synthetic monitoring
- Tabletop exercises for disaster response procedures

**Risk Mitigation:**
- Blue-green deployment for DR infrastructure changes
- Automated rollback on critical alarm triggers
- Shadow traffic testing to DR region before live failover
- Comprehensive runbooks with step-by-step procedures

## Tooling Overview

<!-- TABLE_CONFIG: widths=[30, 35, 35] -->
| Category | Primary Tools | Alternative Options |
|----------|---------------|---------------------|
| Infrastructure | CloudFormation/Terraform | AWS CDK, Pulumi |
| Database Replication | Aurora Global Database | DMS, native replication |
| DNS Failover | Route 53 Health Checks | Global Accelerator |
| Monitoring | CloudWatch | Datadog, New Relic |
| Incident Management | PagerDuty | Opsgenie, VictorOps |
| Backup Management | AWS Backup | Native service backups |

## Data Management

**Data Replication Strategy:**
- Aurora Global Database for real-time cross-region database replication (<1 second lag)
- S3 Cross-Region Replication for static assets and backups
- Data validation and integrity checks during failover
- Encryption for data in-transit (TLS) and at-rest (KMS)

**Data Lifecycle:**
- Automated backup retention policies (30 days)
- Cross-region backup replication for disaster scenarios
- Compliance-aligned data retention per regulatory requirements

**Data Consistency:**
- Transaction validation during database replication
- Reconciliation checks after failover to DR region
- Point-in-time recovery capability for data loss scenarios

---

# Security & Compliance

## Identity & Access Management

- IAM roles and policies with least-privilege access in both regions
- Multi-factor authentication (MFA) required for AWS console access
- Role-based access control (RBAC) for DR operations
- Cross-region IAM replication for consistent access controls
- Emergency break-glass procedures for disaster scenarios

## Monitoring & Threat Detection

- CloudTrail logging enabled in both regions for audit trail
- AWS Config for configuration compliance monitoring
- CloudWatch monitoring for security metrics and anomalies
- GuardDuty for threat detection (optional)
- Automated alerts for unauthorized access attempts

## Compliance & Auditing

- SOC 2 Type II compliance requirements addressed
- HIPAA controls (if applicable) implemented in both regions
- Regular compliance assessments and DR audit readiness
- Comprehensive audit trail for all system changes and failover events

**Audit Capabilities:**
- CloudTrail logs for all API calls and DR operations
- Compliance reporting for failover tests and DR readiness
- Evidence collection for annual audits
- Regular DR testing documentation for audit requirements

## Governance

**Change Management:**
- Formal change request process for DR infrastructure modifications
- Impact assessment for primary and DR regions
- Change calendar and blackout periods for DR testing
- Post-change validation in both regions

**Policy Enforcement:**
- AWS Config rules for DR compliance checking
- Infrastructure drift detection in DR region
- Security baseline enforcement across regions
- Configuration management with version control

**Access Reviews:**
- Quarterly review of DR access permissions
- Privileged access management for disaster scenarios
- Emergency access procedures with approval workflows

## Encryption & Key Management

- KMS encryption for data at-rest (EBS, RDS, S3) in both regions
- TLS 1.2+ for data in-transit between regions
- Cross-region KMS key replication for DR scenarios
- Automated key rotation policies

## Environments & Access

### Environment Strategy

<!-- TABLE_CONFIG: widths=[20, 25, 25, 30] -->
| Environment | Purpose | Access Control | Data |
|-------------|---------|----------------|------|
| Development | DR testing and runbook development | Development team | Synthetic test data |
| Staging | Pre-production DR validation | Project team, testers | Production-like data (masked) |
| Production (Primary) | Live operational environment | Operations team, authorized users | Production data |
| Production (DR) | Disaster recovery standby | Operations team, emergency access | Replicated production data |

### Access Policies

**Administrative Access:**
- Multi-factor authentication (MFA) required for all AWS console access
- Privileged access management (PAM) for DR infrastructure changes
- Session recording and monitoring for audit compliance
- Time-bound access grants with automatic expiration

**Operations Access:**
- Read-only access to DR region during normal operations
- Elevated access granted automatically during disaster scenarios
- CloudWatch and monitoring access for health checks
- Incident response procedures with escalation paths

**Emergency Access:**
- Break-glass procedures for rapid DR activation
- Emergency contact list and escalation procedures
- Post-incident access review and audit

---

# Testing & Validation

## Functional Validation

Comprehensive functional testing ensures all DR capabilities work as designed:

**End-to-End DR Testing:**
- Complete failover workflow validation (primary to DR)
- Failback workflow validation (DR to primary)
- Application functionality testing in DR region
- Database consistency verification after failover
- Integration testing with dependent systems

**Component Testing:**
- Route 53 health check and DNS failover validation
- Aurora Global Database promotion and replication lag
- Auto Scaling group activation in DR region
- Load balancer health checks and traffic routing
- S3 cross-region replication validation

**Acceptance Criteria:**
- All business-critical workflows functional in DR region
- Zero data loss during planned failover tests
- RTO and RPO requirements validated
- Automated failover triggers working correctly

## Performance & Load Testing

Performance validation ensures the DR solution meets SLA requirements:

**Load Testing:**
- Sustained load testing in DR region at expected capacity
- Database performance validation after failover
- Network latency measurement between regions
- Application response time in DR environment

**Stress Testing:**
- Failover testing under peak load conditions
- Auto-scaling validation in DR region
- Resource capacity planning and bottleneck identification
- Graceful degradation scenarios

**Benchmarking:**
- Response time validation (target: <500ms in DR)
- Database query performance in DR region
- Replication lag measurement (<1 second target)
- Comparison of primary vs. DR performance

## Security Testing

Comprehensive security validation to ensure DR maintains security posture:

**Vulnerability Assessment:**
- Security scanning of DR infrastructure
- Configuration security review in both regions
- IAM policy validation for least-privilege access
- Compliance with security baselines

**Compliance Validation:**
- Encryption validation (data in-transit and at-rest)
- Access control verification in DR region
- Audit logging completeness
- DR-specific compliance requirements (SOC 2, HIPAA)

## Disaster Recovery & Resilience Tests

Validation of backup, recovery, and failover capabilities:

**Backup Validation:**
- Automated backup creation and cross-region replication
- Restore testing from Aurora snapshots
- S3 backup integrity checks
- Recovery time measurement for backup restoration

**Failover Testing:**
- Automated failover triggered by Route 53 health check failure
- Manual failover procedures and runbook validation
- Aurora Global Database promotion to primary
- DNS propagation and traffic redirection validation

**RTO/RPO Verification:**
- Timed recovery exercises to validate 4-hour RTO
- Data loss analysis to validate 1-hour RPO
- Application dependency sequencing for recovery
- Comprehensive DR testing every quarter

## User Acceptance Testing (UAT)

UAT is performed in coordination with Client business stakeholders to validate DR readiness:

**UAT Approach:**
- DR environment provisioned and application deployed
- Business users validate functionality post-failover
- Critical business workflows tested in DR region
- Performance and user experience validation

**Acceptance Criteria:**
- All critical business workflows functional in DR
- Performance meets business expectations in DR region
- Data integrity verified after failover
- Operations team trained and confident in DR procedures

**Sign-Off:**
- Formal UAT sign-off document
- Known limitations and workarounds documented
- DR readiness determination for production

## Go-Live Readiness

A comprehensive readiness assessment will be conducted before DR system activation:

**Readiness Checklist:**
- [ ] All functional tests passed in DR region
- [ ] RTO and RPO validated through testing
- [ ] Security sign-off for DR infrastructure
- [ ] Data replication operational with <1 second lag
- [ ] DR runbooks documented and tested
- [ ] Failover and failback procedures validated
- [ ] Stakeholder approval obtained for DR go-live
- [ ] Monitoring and alerting operational in both regions
- [ ] Operations team trained on DR procedures
- [ ] Support team on standby for hypercare period
- [ ] Communication plan executed for DR activation
- [ ] Quarterly DR testing schedule established

## Cutover Plan

The DR system activation will be carefully planned and executed:

**Pre-Activation (1 week before):**
- Final DR infrastructure validation
- Database replication lag verification (<1 second)
- Route 53 health check configuration review
- Stakeholder communication and DR activation announcement
- Support team on standby for hypercare

**Activation Window:**
- Enable Route 53 health checks for primary region
- Validate automated failover triggers
- Monitor replication lag and health metrics
- Conduct final smoke testing in DR region
- Confirm monitoring dashboards operational

**Post-Activation:**
- 30-day hypercare support activation
- Daily health checks and replication monitoring
- Weekly DR status reviews with stakeholders
- Issue tracking and rapid response

## Cutover Checklist

Detailed steps for DR activation:

**T-7 Days:**
- [ ] DR activation plan review and approval
- [ ] Team assignments and responsibilities confirmed
- [ ] Communication sent to all stakeholders

**T-1 Day:**
- [ ] Final DR infrastructure validation
- [ ] Replication lag verification (<1 second)
- [ ] Support team briefed and on standby
- [ ] Rollback procedures reviewed

**Activation Day:**
- [ ] Enable Route 53 health checks
- [ ] Validate automated failover configuration
- [ ] Monitor dashboards for both regions
- [ ] Conduct smoke testing in DR region
- [ ] Stakeholder notification sent

**T+1 Week:**
- [ ] Daily health check completed
- [ ] Replication lag monitored
- [ ] Performance metrics validated
- [ ] Operations team feedback collected

## Rollback Strategy

Comprehensive rollback procedures in case of critical issues:

**Rollback Triggers:**
- Critical replication failure or excessive lag (>5 minutes)
- Security incident or breach in DR infrastructure
- Stakeholder decision to abort DR activation
- Infrastructure configuration errors in DR region

**Rollback Procedures:**
1. Disable Route 53 health checks to prevent unwanted failover
2. Review and resolve identified issues
3. Re-validate DR infrastructure and replication
4. Conduct additional testing before retry
5. Communicate rollback status to stakeholders

**Rollback Timeline:**
- Decision point: Within 4 hours of issue detection
- Execution time: Maximum 1 hour to disable automated failover
- Root cause analysis and remediation plan within 1 week
- Revised DR activation date determination

**Post-Rollback:**
- Root cause analysis of issues
- Remediation plan development and validation
- Additional testing before re-activation
- Lessons learned documentation

---

# Handover & Support

## Handover Artifacts

Upon successful implementation, the following artifacts will be delivered to the Client:

**Documentation Deliverables:**
- As-built DR architecture diagrams for both regions
- Infrastructure-as-Code (CloudFormation/Terraform) repositories
- Network diagrams and cross-region connectivity documentation
- Database replication configuration and monitoring guide
- Route 53 health check and failover configuration

**Operational Deliverables:**
- Disaster Recovery Runbook with step-by-step failover procedures
- Failback procedures and validation steps
- Monitoring and alerting configuration guide
- Incident response playbooks for disaster scenarios
- Troubleshooting guides for common DR issues
- DR testing procedures and quarterly validation schedule

**Knowledge Assets:**
- Recorded training sessions on DR operations
- DR infrastructure management documentation
- AWS service configuration guides (Aurora, Route 53, S3)
- Emergency contact list and escalation procedures
- Vendor and AWS support contact information

## Knowledge Transfer

Knowledge transfer ensures the Client team can effectively manage and operate the DR solution:

**Training Sessions:**
- 3x live knowledge transfer sessions (recorded)
- DR runbook walkthrough and hands-on exercises
- Monitoring and alerting procedures
- Failover and failback procedures
- Quarterly DR testing procedures

**Documentation Package:**
- As-built DR architecture documentation
- Operations runbook and standard operating procedures
- Troubleshooting guide and common issue resolution
- DR testing schedule and validation procedures
- Performance tuning and optimization recommendations

**Training Topics:**
- Multi-region DR architecture and component overview
- Day-to-day DR monitoring and health checks
- Disaster response and failover procedures
- Failback procedures and primary region restoration
- Quarterly DR testing and validation
- Backup verification and restoration procedures
- Security management and compliance for DR
- Cost optimization for pilot light infrastructure

## Hypercare Support

Post-implementation support to ensure smooth transition to Client operations:

**Duration:** 30 days post-activation

**Coverage:**
- Business hours support (8 AM - 6 PM EST)
- 4-hour response time for critical DR issues
- Daily health check calls (first 2 weeks)
- Weekly status meetings

**Scope:**
- DR issue investigation and resolution
- Replication lag monitoring and optimization
- Configuration adjustments and tuning
- Knowledge transfer continuation
- Assistance with first quarterly DR test

## Managed Services Transition (Optional)

Post-hypercare, Client may transition to ongoing managed services:

**Managed Services Options:**
- 24/7 monitoring and support for DR infrastructure
- Quarterly DR testing and validation
- Monthly replication and backup verification
- Proactive optimization and cost management
- Runbook updates and continuous improvement

**Transition Approach:**
- Evaluation of managed services requirements during hypercare
- Service Level Agreement (SLA) definition for DR operations
- Separate managed services contract and pricing
- Seamless transition from hypercare to managed services

## Assumptions

### General Assumptions

This engagement is based on the following assumptions:

**Client Responsibilities:**
- Client will provide timely access to AWS accounts, environments, and documentation
- Client technical team available for requirements validation, testing, and approvals
- Client will provide application subject matter experts (SMEs) for DR validation
- Client will handle internal change management and stakeholder communication
- Client will obtain necessary approvals and sign-offs per internal processes

**Technical Environment:**
- Existing AWS infrastructure meets minimum requirements for DR implementation
- Network connectivity and bandwidth sufficient for cross-region replication
- Client security policies and compliance requirements are clearly documented
- Application architecture supports multi-region deployment without major refactoring
- Database size and transaction volume within scope parameters (50 GB, moderate TPS)

**Project Execution:**
- Project scope and requirements will remain stable during implementation
- Resources (both Vendor and Client) available per project plan
- No major organizational changes will impact project during execution
- Security and compliance approval processes will not delay critical path activities
- AWS service quotas and limits sufficient for DR infrastructure

**Timeline:**
- Project start date is confirmed and resources are committed
- Milestone dates based on continuous progress without extended delays
- Client approvals and decisions provided within defined timeframes
- Quarterly DR testing schedule can be established and maintained

## Dependencies

### Project Dependencies

Critical dependencies that must be satisfied for successful project execution:

**Access & Infrastructure:**
- Client provides AWS account access with appropriate IAM permissions within 1 week of project start
- AWS Organizations structure and account strategy defined for DR region
- Network connectivity (VPN/Direct Connect) available if required for hybrid architecture
- DNS and domain management access for Route 53 configuration
- Service quotas increased if needed for DR infrastructure (EC2, RDS, etc.)

**Data & Integration:**
- Current state architecture documentation and application inventory provided
- Database schemas and data dictionaries available for replication planning
- Application dependency mapping for failover sequencing
- Test data and synthetic transactions for DR validation
- Representative traffic patterns for load testing

**Resources & Expertise:**
- Client SMEs available for requirements gathering, validation, and UAT
- Security and compliance team available for DR approval and sign-offs
- Operations team available for knowledge transfer and training
- Executive sponsor available for critical decision-making and escalations
- Business stakeholders available for disaster scenario validation

**Approvals & Governance:**
- Security approvals obtained on schedule to avoid implementation delays
- Change Advisory Board (CAB) approvals for DR infrastructure deployment
- Budget approvals and purchase orders processed timely
- Maintenance windows available for DR testing (quarterly)

**External Factors:**
- AWS service availability and stability in both regions
- No major changes to application architecture during DR implementation
- Cloud provider service roadmap aligned with DR requirements
- Regulatory or compliance requirement changes communicated early

---

# Investment Summary

## Total Investment

This section provides a comprehensive overview of the total investment required for this engagement, broken down by cost category and displayed across a 3-year period.

**Small Scope Implementation:** This pricing reflects a pilot light DR strategy for 5-10 critical applications with 4-hour RTO and 1-hour RPO targets. For warm/hot standby or enterprise-scale DR, please request medium or large scope pricing.

The investment includes all professional services, infrastructure costs, software licenses, and support services required to successfully implement and operate the DR solution. Credits and discounts have been applied where applicable to reduce Year 1 costs.

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 15, 15, 10, 10, 10] -->
| Cost Category | Year 1 List | Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|---------|------------|--------|--------|--------------|
| Professional Services | $93,500 | ($8,000) | $85,500 | $0 | $0 | $85,500 |
| Cloud Infrastructure | $8,644 | ($4,369) | $4,275 | $8,644 | $8,644 | $21,563 |
| Software Licenses | $3,132 | $0 | $3,132 | $3,132 | $3,132 | $9,396 |
| Support & Maintenance | $1,467 | $0 | $1,467 | $1,467 | $1,467 | $4,401 |
| **TOTAL INVESTMENT** | **$106,743** | **($12,369)** | **$94,374** | **$13,243** | **$13,243** | **$120,860** |
<!-- END COST_SUMMARY_TABLE -->

## Partner Credits

**Year 1 Credits Applied:** $12,369 (12% reduction from list price)

Credits represent real AWS account credits or service discounts applied to reduce Year 1 costs:

**Credit Breakdown:**
- **AWS Partner DR Services Credit:** $8,000 applied to DR architecture design and testing validation
- **AWS DR Infrastructure Credit:** $4,369 applied to pilot light DR region infrastructure costs in Year 1

**Credit Terms:**
- Credits are one-time Year 1 benefits; Years 2-3 reflect standard pricing
- Infrastructure credits automatically applied as AWS services are consumed
- Unused credits do not roll over to subsequent years
- Credits valid for 12 months from DR activation date

**Investment Comparison:**
- **Year 1 Net Investment:** $94,374 (after credits) vs. $106,743 list price
- **3-Year Total Cost of Ownership:** $120,860
- **Average Annual Run Rate (Years 2-3):** $13,243/year
- **Expected Value:** Risk mitigation - compare $95K Year 1 investment to cost of 4+ hours downtime for critical revenue-generating applications

## Cost Components

**Professional Services (90% of Year 1 net):** Labor costs for business impact assessment, DR architecture design, infrastructure deployment, testing, runbook development, and knowledge transfer. Detailed breakdown provided in level-of-effort-estimate.xlsx.

Breakdown (450 hours total):
- Discovery & DR architecture design (120 hours): Business impact analysis, RTO/RPO requirements, multi-region architecture design, DR runbook development
- Implementation & deployment (280 hours): AWS DR environment setup, replication configuration, automated failover, DR testing and validation
- Training & hypercare support (50 hours): Operations team training, DR simulation exercises, and 30-day post-activation support

**Cloud Infrastructure (5% of Year 1 net):** AWS services for primary region and pilot light DR infrastructure. Monthly estimates based on sizing analysis. Pilot light strategy minimizes costs while maintaining DR capability.

Components:
- Primary region (EC2, RDS Multi-AZ, ALB, EBS, S3): $6,644/year
- DR region (Aurora read replica, minimal EC2, Route 53, S3 CRR, automated backups): $2,000/year
- Costs scale with actual usage and can be optimized based on testing results

**Software Licenses (3% of Year 1 net):** Third-party operational tooling for small-scope DR monitoring and incident management.

Components:
- Datadog Pro monitoring (6 hosts - primary + DR regions): $1,656/year
- PagerDuty Professional incident management (3 users): $1,476/year

**Support & Maintenance (2% of Year 1 net):** Ongoing managed services (15% of cloud infrastructure costs) including quarterly DR testing, monthly backup verification, and DR runbook updates.

## Payment Terms

**Pricing Model:** Fixed price with milestone-based payments

**Payment Schedule:**
- 30% upon SOW execution and project kickoff ($28,312)
- 25% upon completion of Phase 2 - DR Environment Setup ($23,594)
- 25% upon completion of Phase 4 - Testing & Validation ($23,594)
- 20% upon successful DR activation and project acceptance ($18,875)

**Invoicing:** Monthly invoicing based on milestones completed. Net 30 payment terms.

**Expenses:** Travel and incidental expenses reimbursable at cost with prior written approval.

## Invoicing & Expenses

### Invoicing Process

**Invoice Submission:**
- Invoices submitted upon milestone completion and formal acceptance
- Invoices include detailed breakdown of services delivered
- Supporting documentation provided (timesheets, expense reports, deliverable evidence)

**Payment Terms:**
- Net 30 days from invoice date
- Payment via ACH, wire transfer, or check
- Late payment fees may apply per MSA terms

**Invoice Review:**
- Client has 10 business days to review and approve/dispute invoices
- Disputes resolved within 15 business days through joint review
- Undisputed portions paid on schedule

### Reimbursable Expenses

**Travel Expenses (if applicable):**
- Airfare: Economy class for domestic travel
- Lodging: Standard business hotel rates
- Ground transportation: Rental car or taxi/rideshare
- Meals: Per diem rates per company policy

**Other Expenses:**
- AWS service costs included in Cloud Infrastructure pricing
- Shipping and courier services for hardware (if required)
- Training materials and supplies for operations team
- Third-party tools or services purchased on Client's behalf

**Expense Policy:**
- All travel requires prior written approval
- Receipts required for expenses over $75
- Monthly expense reports submitted with invoices
- Client approval required for expenses exceeding budgeted amounts
- Remote-first delivery model minimizes travel expenses

---

# Terms & Conditions

## General Terms

All services will be delivered in accordance with the executed Master Services Agreement (MSA) between Vendor and Client.

## Scope Changes

Any changes to scope, schedule, or cost require a formal Change Request approved by both parties. Impact assessment will be provided within 5 business days.

Examples requiring change requests:
- Additional applications added to DR scope beyond 5-10 defined
- RTO/RPO requirements more stringent than 4 hours / 1 hour
- Additional AWS regions or multi-region failover scenarios
- Changes to database replication strategy or backup retention
- Extended hypercare support beyond 30 days

## Intellectual Property

- Client retains ownership of all business data, application code, and configurations
- Vendor retains proprietary DR methodologies, frameworks, and automation tools
- DR infrastructure configurations and runbooks become Client property upon final payment
- AWS Infrastructure-as-Code (CloudFormation/Terraform) transferred to Client repository
- Pre-existing IP remains with original owner

## Service Levels

- RTO and RPO guarantees apply only to in-scope applications and infrastructure
- DR testing success rate: 95%+ for planned quarterly exercises
- 30-day warranty on all deliverables from DR activation date
- Post-warranty DR support available under separate managed services agreement
- Hypercare period: 30 days with defined response times (4-hour SLA for critical issues)

## Liability

- Liability capped as defined in MSA
- RTO/RPO validation based on planned testing scenarios; actual disaster recovery times may vary
- Performance may be impacted by factors outside Vendor control (AWS service outages, network issues, etc.)
- Excludes gross negligence, willful misconduct, or IP infringement
- Professional liability insurance maintained per MSA requirements

## Confidentiality

- All exchanged artifacts under NDA protection
- DR plans and business continuity procedures considered highly confidential
- Client data handled per security requirements
- No disclosure to third parties without consent
- Confidentiality obligations survive contract termination

## Termination

- Either party may terminate with 30 days written notice
- Payment due for all completed work and accepted milestones
- Deliverables and DR infrastructure configurations transferred upon termination
- Transition assistance available upon request for knowledge transfer
- Client retains all DR infrastructure and configurations deployed in AWS account

## Governing Law

This agreement shall be governed by the laws of the State of [State], without regard to conflict of law principles.

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

*This Statement of Work constitutes the complete agreement between the parties for the services described herein and supersedes all prior negotiations, representations, or agreements relating to the subject matter.*
