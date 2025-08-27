# Azure Virtual WAN Global - Requirements Questionnaire

## Overview

This comprehensive questionnaire is designed to capture all technical, business, and operational requirements for Azure Virtual WAN Global implementations. The information gathered will inform solution design, sizing, implementation planning, and business case development.

## Instructions for Use

### Preparation
- Schedule dedicated sessions with key stakeholders (2-4 hours recommended)
- Prepare current network documentation and diagrams
- Gather performance metrics and cost information from existing systems
- Include representatives from IT, Security, Operations, and Business teams

### Completion Guidelines
- Answer all applicable questions thoroughly
- Provide specific metrics and numbers where possible
- Include documentation references and attachments
- Mark items as "Unknown" if information is not available rather than guessing
- Schedule follow-up sessions for complex technical discussions

---

## Section 1: Organization and Business Context

### 1.1 Organization Profile

**Q1.1** Organization Name and Industry Sector:
- Organization: ________________________________
- Industry: ________________________________
- Primary Business Activities: ________________________________

**Q1.2** Current IT Environment Scale:
- Number of office locations: ________________________________
- Number of users (total): ________________________________
- Number of remote workers: ________________________________
- Geographic regions served: ________________________________

**Q1.3** Business Growth Projections:
- Expected growth in locations over next 3 years: ________________________________
- Expected growth in users over next 3 years: ________________________________
- Planned mergers, acquisitions, or expansions: ________________________________
- New market entry plans: ________________________________

### 1.2 Strategic Business Objectives

**Q1.4** Digital Transformation Initiatives:
- Cloud adoption strategy (Azure, multi-cloud, hybrid): ________________________________
- Digital workplace initiatives: ________________________________
- Application modernization plans: ________________________________
- Data analytics and AI initiatives: ________________________________

**Q1.5** Business Drivers for Network Modernization:
- [ ] Cost reduction requirements
- [ ] Performance improvement needs
- [ ] Security enhancement requirements
- [ ] Operational simplification goals
- [ ] Scalability for growth
- [ ] Compliance and regulatory requirements
- [ ] User experience improvement
- [ ] Business continuity and disaster recovery

**Q1.6** Success Criteria and Key Performance Indicators:
- Network cost reduction target (%): ________________________________
- Performance improvement target: ________________________________
- User experience metrics: ________________________________
- Security posture improvements: ________________________________
- Operational efficiency gains: ________________________________

---

## Section 2: Current Network Infrastructure

### 2.1 Network Topology and Architecture

**Q2.1** Current WAN Architecture:
- [ ] Hub and spoke with central data center
- [ ] Full mesh connectivity
- [ ] Partial mesh with regional hubs
- [ ] Point-to-point connections
- [ ] MPLS-based network
- [ ] Internet-based VPN
- [ ] SD-WAN solution (specify vendor: ________________)
- [ ] Hybrid architecture (describe: ________________)

**Q2.2** Site Classification and Connectivity:
| Site Type | Count | Typical Bandwidth | Connectivity Type | Critical Applications |
|-----------|-------|------------------|------------------|---------------------|
| Headquarters | ___ | _____________ | _______________ | _________________ |
| Regional Offices | ___ | _____________ | _______________ | _________________ |
| Branch Offices | ___ | _____________ | _______________ | _________________ |
| Retail Locations | ___ | _____________ | _______________ | _________________ |
| Manufacturing | ___ | _____________ | _______________ | _________________ |
| Warehouses | ___ | _____________ | _______________ | _________________ |
| Remote Workers | ___ | _____________ | _______________ | _________________ |

**Q2.3** Data Centers and Cloud Connectivity:
- Primary data center location(s): ________________________________
- Backup/DR data center location(s): ________________________________
- Cloud providers currently used: ________________________________
- Cloud connectivity methods: ________________________________
- ExpressRoute circuits (if any): ________________________________

### 2.2 Network Services and Infrastructure

**Q2.4** Current Network Service Providers:
| Provider | Services | Contract Terms | Monthly Cost | Satisfaction (1-5) |
|----------|----------|---------------|--------------|-------------------|
| _______ | ________ | _____________ | ____________ | _________________ |
| _______ | ________ | _____________ | ____________ | _________________ |
| _______ | ________ | _____________ | ____________ | _________________ |

**Q2.5** Network Equipment Inventory:
- WAN routers (make/model/age): ________________________________
- Switches (core/distribution/access): ________________________________
- Firewalls and security appliances: ________________________________
- SD-WAN appliances: ________________________________
- Load balancers: ________________________________
- Network monitoring tools: ________________________________

**Q2.6** IP Addressing and Network Segmentation:
- Current IP addressing scheme: ________________________________
- VLAN/subnet structure: ________________________________
- Network segmentation approach: ________________________________
- IP address space availability: ________________________________
- Overlapping IP issues: ________________________________

---

## Section 3: Performance and Capacity Requirements

### 3.1 Bandwidth and Traffic Analysis

**Q3.1** Current Bandwidth Utilization:
| Location/Link | Current Capacity | Peak Utilization | Average Utilization | Growth Rate |
|---------------|-----------------|-----------------|-------------------|-------------|
| ____________ | _______________ | _______________ | _________________ | ___________ |
| ____________ | _______________ | _______________ | _________________ | ___________ |
| ____________ | _______________ | _______________ | _________________ | ___________ |

**Q3.2** Application Traffic Patterns:
- Primary business applications and bandwidth requirements: ________________________________
- Peak usage periods (time of day, seasonal): ________________________________
- Inter-site traffic patterns: ________________________________
- Internet traffic patterns: ________________________________
- Cloud application traffic: ________________________________

**Q3.3** Performance Requirements:
- Required uptime/availability (%): ________________________________
- Maximum acceptable latency: ________________________________
- Jitter requirements: ________________________________
- Packet loss tolerance: ________________________________
- Quality of Service (QoS) requirements: ________________________________

### 3.2 Scalability and Growth Planning

**Q3.4** Growth Projections:
- Bandwidth growth rate (annual %): ________________________________
- New site addition timeline: ________________________________
- User growth projections: ________________________________
- Application growth plans: ________________________________
- Data volume growth expectations: ________________________________

**Q3.5** Capacity Planning Requirements:
- Peak capacity planning headroom (%): ________________________________
- Burst capacity requirements: ________________________________
- Disaster recovery capacity needs: ________________________________
- Special event capacity requirements: ________________________________

---

## Section 4: Security Requirements

### 4.1 Security Architecture and Policies

**Q4.1** Current Security Framework:
- Security frameworks followed (NIST, ISO 27001, etc.): ________________________________
- Network security architecture: ________________________________
- Zero Trust implementation status: ________________________________
- Current firewall deployment model: ________________________________

**Q4.2** Threat Protection Requirements:
- [ ] Advanced Threat Protection (ATP)
- [ ] Intrusion Detection/Prevention (IDS/IPS)
- [ ] Web Application Firewall (WAF)
- [ ] DNS security and filtering
- [ ] Anti-malware and sandboxing
- [ ] Threat intelligence integration
- [ ] User and Entity Behavior Analytics (UEBA)

**Q4.3** Network Security Controls:
- Network segmentation requirements: ________________________________
- Microsegmentation needs: ________________________________
- East-west traffic inspection: ________________________________
- SSL/TLS inspection requirements: ________________________________
- Data loss prevention (DLP): ________________________________

### 4.2 Compliance and Regulatory Requirements

**Q4.4** Compliance Frameworks:
- [ ] PCI DSS
- [ ] HIPAA
- [ ] SOX
- [ ] GDPR
- [ ] SOC 2
- [ ] FedRAMP
- [ ] Industry-specific regulations: ________________________________

**Q4.5** Data Governance and Privacy:
- Data classification levels: ________________________________
- Data residency requirements: ________________________________
- Privacy protection requirements: ________________________________
- Audit and logging requirements: ________________________________
- Data encryption requirements: ________________________________

### 4.3 Identity and Access Management

**Q4.6** Identity Integration Requirements:
- Current identity provider: ________________________________
- Multi-factor authentication (MFA) requirements: ________________________________
- Single sign-on (SSO) requirements: ________________________________
- Privileged access management: ________________________________
- Network access control: ________________________________

---

## Section 5: Operational Requirements

### 5.1 Management and Operations

**Q5.1** Current Network Operations:
- Network operations center (NOC) model: ________________________________
- Staffing levels and skill sets: ________________________________
- Hours of operation/support: ________________________________
- Escalation procedures: ________________________________
- Change management processes: ________________________________

**Q5.2** Monitoring and Management Tools:
- Current network monitoring tools: ________________________________
- Performance management tools: ________________________________
- Configuration management tools: ________________________________
- Asset management systems: ________________________________
- ITSM/ticketing systems: ________________________________

**Q5.3** Automation and Orchestration:
- Current automation level: ________________________________
- Desired automation capabilities: ________________________________
- Orchestration platform preferences: ________________________________
- DevOps/Infrastructure as Code maturity: ________________________________

### 5.2 Support and Maintenance

**Q5.4** Support Requirements:
- Required support hours: ________________________________
- Response time requirements: ________________________________
- Resolution time requirements: ________________________________
- Escalation requirements: ________________________________
- Preferred support channels: ________________________________

**Q5.5** Maintenance and Updates:
- Maintenance window preferences: ________________________________
- Change control requirements: ________________________________
- Testing and validation procedures: ________________________________
- Rollback requirements: ________________________________

---

## Section 6: Technical Integration Requirements

### 6.1 Application and Workload Integration

**Q6.1** Critical Applications:
| Application | Location | Users | Bandwidth | Latency Req | Availability Req |
|-------------|----------|-------|-----------|-------------|------------------|
| ___________ | ________ | _____ | _________ | ___________ | ________________ |
| ___________ | ________ | _____ | _________ | ___________ | ________________ |
| ___________ | ________ | _____ | _________ | ___________ | ________________ |

**Q6.2** Cloud Integration Requirements:
- Azure services currently used: ________________________________
- Multi-cloud requirements (AWS, GCP): ________________________________
- SaaS applications (Office 365, Salesforce, etc.): ________________________________
- Hybrid cloud connectivity requirements: ________________________________

**Q6.3** Integration Points:
- ERP systems integration: ________________________________
- CRM systems integration: ________________________________
- Database connectivity requirements: ________________________________
- File sharing and collaboration tools: ________________________________
- Backup and disaster recovery systems: ________________________________

### 6.2 Migration and Transition Requirements

**Q6.4** Migration Planning:
- Preferred migration approach (big bang, phased): ________________________________
- Migration timeline constraints: ________________________________
- Business continuity requirements: ________________________________
- Rollback requirements: ________________________________
- Pilot site preferences: ________________________________

**Q6.5** Legacy System Support:
- Legacy applications requiring special consideration: ________________________________
- Legacy protocols and services: ________________________________
- End-of-life systems and timelines: ________________________________
- Vendor dependencies and constraints: ________________________________

---

## Section 7: Financial and Business Requirements

### 7.1 Budget and Financial Constraints

**Q7.1** Current Network Costs:
- Annual MPLS/WAN costs: ________________________________
- Internet connectivity costs: ________________________________
- Equipment maintenance costs: ________________________________
- Staff costs (network operations): ________________________________
- Total annual network spend: ________________________________

**Q7.2** Budget Parameters:
- Capital expenditure budget: ________________________________
- Operational expenditure budget: ________________________________
- Budget approval process: ________________________________
- Financial approval authority: ________________________________
- Preferred payment model (CapEx/OpEx): ________________________________

**Q7.3** Financial Success Criteria:
- Target cost reduction (%): ________________________________
- Required ROI timeline: ________________________________
- Total cost of ownership considerations: ________________________________
- Budget variance tolerance: ________________________________

### 7.2 Procurement and Vendor Management

**Q7.4** Procurement Requirements:
- Procurement process and timeline: ________________________________
- Vendor qualification requirements: ________________________________
- Contract terms and conditions: ________________________________
- Service level agreement requirements: ________________________________

**Q7.5** Vendor Relationship Preferences:
- Preferred vendor relationship model: ________________________________
- Support and professional services needs: ________________________________
- Training and certification requirements: ________________________________
- Ongoing relationship management: ________________________________

---

## Section 8: Implementation and Timeline

### 8.1 Project Timeline and Constraints

**Q8.1** Implementation Timeline:
- Desired go-live date: ________________________________
- Key milestone dates: ________________________________
- Business constraints (fiscal year-end, busy seasons): ________________________________
- Regulatory compliance deadlines: ________________________________

**Q8.2** Resource Availability:
- Internal project team availability: ________________________________
- Key stakeholder availability: ________________________________
- Network maintenance window availability: ________________________________
- Testing environment availability: ________________________________

### 8.2 Change Management and Training

**Q8.3** Change Management:
- Change management process maturity: ________________________________
- Stakeholder communication requirements: ________________________________
- User training requirements: ________________________________
- Documentation requirements: ________________________________

**Q8.4** Knowledge Transfer:
- Technical team training needs: ________________________________
- Operations team training needs: ________________________________
- End-user training requirements: ________________________________
- Preferred training delivery methods: ________________________________

---

## Section 9: Risk Assessment and Mitigation

### 9.1 Risk Factors

**Q9.1** Business Risks:
- [ ] Service disruption during migration
- [ ] User productivity impact
- [ ] Application performance degradation
- [ ] Security vulnerabilities during transition
- [ ] Budget overruns
- [ ] Timeline delays
- [ ] Vendor dependency risks
- [ ] Skills gap and training needs

**Q9.2** Technical Risks:
- [ ] Legacy system compatibility
- [ ] Network performance issues
- [ ] Security control gaps
- [ ] Integration complexity
- [ ] Scalability limitations
- [ ] Disaster recovery concerns
- [ ] Monitoring and management gaps

### 9.2 Risk Mitigation Requirements

**Q9.3** Risk Mitigation Strategies:
- Risk tolerance level: ________________________________
- Required mitigation measures: ________________________________
- Contingency planning requirements: ________________________________
- Rollback strategies: ________________________________

**Q9.4** Business Continuity:
- Maximum acceptable downtime: ________________________________
- Disaster recovery requirements: ________________________________
- Business impact assessment completion: ________________________________
- Critical business process protection: ________________________________

---

## Section 10: Success Measurement and KPIs

### 10.1 Success Criteria

**Q10.1** Technical Success Metrics:
- Network performance improvements: ________________________________
- Reliability and availability targets: ________________________________
- Security posture enhancements: ________________________________
- Operational efficiency gains: ________________________________

**Q10.2** Business Success Metrics:
- Cost reduction achievements: ________________________________
- User experience improvements: ________________________________
- Business agility enhancements: ________________________________
- Innovation enablement: ________________________________

### 10.2 Measurement and Reporting

**Q10.3** Reporting Requirements:
- Reporting frequency: ________________________________
- Key stakeholders for reporting: ________________________________
- Dashboard and visualization needs: ________________________________
- Performance baseline requirements: ________________________________

---

## Section 11: Additional Information

### 11.1 Special Requirements

**Q11.1** Unique Business Requirements:
- Industry-specific needs: ________________________________
- Regulatory or compliance specifics: ________________________________
- Integration with partner networks: ________________________________
- Special security or privacy requirements: ________________________________

**Q11.2** Technology Preferences:
- Preferred technology vendors: ________________________________
- Technology restrictions or mandates: ________________________________
- Open source vs. proprietary preferences: ________________________________
- Cloud-first policies or restrictions: ________________________________

### 11.2 Stakeholder Information

**Q11.3** Key Stakeholders:
| Role | Name | Department | Contact | Decision Authority |
|------|------|------------|---------|-------------------|
| Project Sponsor | _______ | ________ | _______ | ________________ |
| Technical Lead | _______ | ________ | _______ | ________________ |
| Security Lead | _______ | ________ | _______ | ________________ |
| Network Lead | _______ | ________ | _______ | ________________ |
| Business Owner | _______ | ________ | _______ | ________________ |

---

## Document Control

**Questionnaire Completion Information:**
- Completed by: ________________________________
- Date completed: ________________________________
- Review date: ________________________________
- Next update required: ________________________________

**Version Control:**
- Document version: 1.0
- Last updated: August 2024
- Next review: November 2024

**Attachments and Supporting Documents:**
- [ ] Current network diagrams
- [ ] Performance reports
- [ ] Security assessments
- [ ] Compliance documentation
- [ ] Financial reports
- [ ] Vendor contracts
- [ ] Other: ________________________________

---

## Next Steps

Upon completion of this questionnaire:

1. **Review and Validation** (1-2 days)
   - Internal stakeholder review
   - Technical validation session
   - Gap identification and follow-up

2. **Solution Design** (1-2 weeks)
   - Architecture design based on requirements
   - Sizing and capacity planning
   - Integration design

3. **Business Case Development** (1 week)
   - Cost-benefit analysis
   - ROI calculation
   - Financial justification

4. **Proposal Preparation** (1 week)
   - Technical proposal development
   - Commercial terms preparation
   - Presentation preparation

**Contact Information:**
- Lead Solution Architect: [Name/Email]
- Project Manager: [Name/Email]
- Account Manager: [Name/Email]