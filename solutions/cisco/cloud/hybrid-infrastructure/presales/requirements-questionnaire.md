# Cisco Hybrid Infrastructure Requirements Questionnaire

## Purpose

This comprehensive questionnaire helps gather essential information for designing and sizing a Cisco Hybrid Cloud Infrastructure solution. Please complete all sections that apply to your organization.

## Section 1: Organization Information

### 1.1 Company Profile
**Company Name:** _____________________
**Industry:** _____________________
**Annual Revenue:** _____________________
**Number of Employees:** _____________________
**Number of Locations:** _____________________
**Primary Contact:** _____________________
**Title:** _____________________
**Email:** _____________________
**Phone:** _____________________

### 1.2 Business Objectives
What are your primary business drivers for this infrastructure project? (Check all that apply)

- [ ] Reduce operational costs
- [ ] Improve application performance
- [ ] Increase infrastructure agility
- [ ] Enhance disaster recovery capabilities
- [ ] Simplify management
- [ ] Prepare for cloud adoption
- [ ] Support business growth
- [ ] Improve security posture
- [ ] Meet compliance requirements
- [ ] Other: _____________________

### 1.3 Success Criteria
How will you measure the success of this project?

**Performance Metrics:**
- Target uptime percentage: _____%
- Acceptable backup/recovery time: _____ hours
- Maximum acceptable downtime: _____ minutes/month

**Financial Metrics:**
- Expected ROI timeframe: _____ months
- Target cost reduction: _____%
- Budget range: $ _____ to $ _____

## Section 2: Current Environment Assessment

### 2.1 Compute Infrastructure
**Total number of physical servers:** _____
**Total number of virtual machines:** _____
**Primary hypervisor:** 
- [ ] VMware vSphere (Version: _____)
- [ ] Microsoft Hyper-V (Version: _____)
- [ ] Red Hat KVM/RHEV (Version: _____)
- [ ] Citrix XenServer (Version: _____)
- [ ] Other: _____________________

**Server Hardware:**
| Vendor | Model | Quantity | CPU Cores | RAM (GB) | Age (Years) |
|--------|--------|----------|-----------|----------|--------------|
| | | | | | |
| | | | | | |
| | | | | | |

**Virtualization Ratios:**
- Current VM-to-host ratio: _____:1
- Average CPU utilization: _____%
- Average memory utilization: _____%

### 2.2 Storage Infrastructure
**Primary storage type:**
- [ ] SAN (Vendor: _____, Model: _____)
- [ ] NAS (Vendor: _____, Model: _____)
- [ ] DAS (Direct Attached Storage)
- [ ] Hyperconverged Infrastructure
- [ ] Cloud Storage
- [ ] Other: _____________________

**Storage Capacity:**
- Total storage capacity: _____ TB
- Used storage capacity: _____ TB
- Storage utilization: _____%
- Annual growth rate: _____%

**Storage Performance:**
- Average IOPS: _____
- Peak IOPS: _____
- Average latency: _____ ms
- Backup window: _____ hours

### 2.3 Network Infrastructure
**Data Center Network:**
- Core switch vendor/model: _____________________
- Access switch vendor/model: _____________________
- Network bandwidth: _____ Gbps
- Number of VLANs: _____
- Network virtualization: 
  - [ ] None
  - [ ] VMware NSX
  - [ ] Cisco ACI
  - [ ] Other: _____________________

**WAN Connectivity:**
- Internet bandwidth: _____ Mbps
- MPLS connectivity: 
  - [ ] Yes (Bandwidth: _____ Mbps)
  - [ ] No
- Cloud connectivity:
  - [ ] AWS Direct Connect
  - [ ] Azure ExpressRoute
  - [ ] Google Cloud Interconnect
  - [ ] None

## Section 3: Application Requirements

### 3.1 Application Inventory
Please provide details for your top 10 critical applications:

| Application Name | Type | Users | Criticality | Performance Req | Compliance |
|------------------|------|-------|-------------|-----------------|------------|
| | | | High/Med/Low | | |
| | | | | | |
| | | | | | |

**Application Types:**
- [ ] Email (Exchange, Gmail, etc.)
- [ ] ERP (SAP, Oracle, etc.)
- [ ] CRM (Salesforce, etc.)
- [ ] Database servers
- [ ] Web applications
- [ ] File servers
- [ ] Development/test environments
- [ ] Analytics/BI platforms
- [ ] Other: _____________________

### 3.2 Database Requirements
**Database platforms in use:**
- [ ] Microsoft SQL Server (Version: _____)
- [ ] Oracle Database (Version: _____)
- [ ] MySQL (Version: _____)
- [ ] PostgreSQL (Version: _____)
- [ ] MongoDB (Version: _____)
- [ ] Other: _____________________

**Database sizing:**
- Total database storage: _____ TB
- Largest database: _____ GB
- Number of databases: _____
- Peak concurrent users: _____

### 3.3 Performance Requirements
**Response Time Requirements:**
- Web applications: _____ seconds
- Database queries: _____ milliseconds
- File access: _____ seconds
- Email response: _____ seconds

**Availability Requirements:**
- Business hours: _____ AM to _____ PM
- Maintenance windows: _____ (day/time)
- Planned downtime acceptable: _____ hours/month
- Unplanned downtime acceptable: _____ minutes/month

## Section 4: Growth and Capacity Planning

### 4.1 Growth Projections
**Next 12 months:**
- Expected VM growth: _____%
- Storage growth: _____ TB
- User growth: _____%
- New applications: _____

**Next 3 years:**
- Expected VM growth: _____%
- Storage growth: _____ TB
- User growth: _____%
- Major initiatives: _____________________

### 4.2 Future Requirements
**Planned initiatives:**
- [ ] Cloud migration
- [ ] Digital transformation projects
- [ ] Big data/analytics projects
- [ ] IoT implementations
- [ ] AI/ML workloads
- [ ] Container adoption
- [ ] Other: _____________________

**Technology preferences:**
- [ ] Hybrid cloud approach
- [ ] Multi-cloud strategy
- [ ] On-premises only
- [ ] Cloud-first strategy

## Section 5: Technical Requirements

### 5.1 Integration Requirements
**Existing tools that must integrate:**
- Backup solution: _____________________
- Monitoring tools: _____________________
- Security tools: _____________________
- Management tools: _____________________
- ITSM platform: _____________________

**Directory services:**
- [ ] Microsoft Active Directory
- [ ] LDAP
- [ ] Azure AD
- [ ] Other: _____________________

### 5.2 Management Requirements
**Management preferences:**
- [ ] Single pane of glass management
- [ ] Cloud-based management
- [ ] On-premises management only
- [ ] Mobile management capabilities
- [ ] API access required

**Automation requirements:**
- [ ] Automated provisioning
- [ ] Self-service portals
- [ ] Workflow automation
- [ ] Configuration management
- [ ] Patch management automation

## Section 6: Security and Compliance

### 6.1 Security Requirements
**Security priorities:**
- [ ] Data encryption at rest
- [ ] Data encryption in transit
- [ ] Multi-factor authentication
- [ ] Network segmentation
- [ ] Intrusion detection/prevention
- [ ] Security monitoring and SIEM
- [ ] Vulnerability management

**Access control:**
- [ ] Role-based access control (RBAC)
- [ ] Privileged account management
- [ ] Single sign-on (SSO)
- [ ] Regular access reviews

### 6.2 Compliance Requirements
**Regulatory compliance:**
- [ ] SOX (Sarbanes-Oxley)
- [ ] HIPAA (Healthcare)
- [ ] PCI DSS (Payment Card)
- [ ] GDPR (Data Protection)
- [ ] FISMA (Federal)
- [ ] ISO 27001
- [ ] Other: _____________________

**Audit requirements:**
- [ ] Change tracking and logging
- [ ] Configuration compliance
- [ ] Regular security assessments
- [ ] Compliance reporting

## Section 7: Backup and Disaster Recovery

### 7.1 Current Backup Solution
**Backup software:** _____________________
**Backup targets:**
- [ ] Tape
- [ ] Disk
- [ ] Cloud
- [ ] Hybrid

**Current metrics:**
- Backup window: _____ hours
- Recovery time objective (RTO): _____ hours
- Recovery point objective (RPO): _____ hours
- Backup success rate: _____%

### 7.2 Disaster Recovery Requirements
**DR strategy:**
- [ ] Active-active
- [ ] Active-passive
- [ ] Cloud-based DR
- [ ] Traditional DR site
- [ ] No formal DR

**DR requirements:**
- RTO target: _____ hours
- RPO target: _____ hours
- DR site distance: _____ miles
- DR testing frequency: _____

## Section 8: Budget and Timeline

### 8.1 Budget Information
**Budget range:** $_____ to $_____
**Budget type:**
- [ ] Capital expenditure (CapEx)
- [ ] Operational expenditure (OpEx)
- [ ] Hybrid (CapEx + OpEx)
- [ ] Lease/financing

**Funding timeline:**
- Budget approval date: _____
- Preferred start date: _____
- Required completion date: _____

### 8.2 Project Timeline
**Project phases:**
- Planning and design: _____ weeks
- Implementation: _____ weeks
- Migration: _____ weeks
- Testing and go-live: _____ weeks

**Constraints:**
- [ ] Seasonal business restrictions
- [ ] Regulatory deadlines
- [ ] Contract renewals
- [ ] Other: _____________________

## Section 9: Organizational Readiness

### 9.1 IT Team Structure
**Current IT staff:**
- IT Director/Manager: _____
- System Administrators: _____
- Network Engineers: _____
- Storage Administrators: _____
- Virtualization Engineers: _____
- Security Specialists: _____

**Skill levels:**
- VMware expertise: Beginner / Intermediate / Advanced
- Cisco networking: Beginner / Intermediate / Advanced
- Storage management: Beginner / Intermediate / Advanced
- Cloud technologies: Beginner / Intermediate / Advanced

### 9.2 Change Management
**Change approval process:**
- [ ] Formal change control board
- [ ] Manager approval required
- [ ] IT team approval only
- [ ] Informal process

**Communication preferences:**
- [ ] Regular status meetings
- [ ] Email updates
- [ ] Project portal/dashboard
- [ ] Weekly reports

## Section 10: Additional Information

### 10.1 Special Requirements
**Unique requirements or constraints:**
_____________________
_____________________
_____________________

**Previous experiences:**
Have you implemented hyperconverged infrastructure before?
- [ ] Yes (Vendor: _____, Experience: _____)
- [ ] No

**Vendor relationships:**
Existing relationships with:
- [ ] Cisco (Contact: _____)
- [ ] VMware (Contact: _____)
- [ ] Other vendors: _____________________

### 10.2 Decision Criteria
**Most important factors in vendor selection:**
1. _____________________
2. _____________________
3. _____________________
4. _____________________
5. _____________________

**Decision timeline:**
- Vendor selection: _____
- Purchase approval: _____
- Implementation start: _____

**Decision makers:**
- Primary decision maker: _____________________
- Technical influencers: _____________________
- Budget approver: _____________________

---

## Questionnaire Completion

**Completed by:** _____________________
**Title:** _____________________
**Date:** _____________________
**Signature:** _____________________

**Next steps:**
- [ ] Technical assessment meeting
- [ ] Solution design workshop
- [ ] Proof of concept planning
- [ ] Business case development

---

**Document Version**: 1.0  
**Last Updated**: [Date]  
**For questions contact**: [Sales Engineer] - [Email] - [Phone]