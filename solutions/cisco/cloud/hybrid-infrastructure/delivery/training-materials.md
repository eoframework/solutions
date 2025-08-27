# Cisco Hybrid Infrastructure Training Materials

## Overview

This comprehensive training curriculum is designed to enable customer IT teams to effectively operate and maintain the Cisco Hybrid Cloud Infrastructure solution. The training covers all aspects from basic concepts to advanced troubleshooting and optimization.

## Training Program Structure

### Training Tracks

1. **Administrator Track** - System administrators and engineers
2. **Operations Track** - NOC and operations teams
3. **Executive Track** - Management and decision makers
4. **Specialist Track** - Advanced technical specialists

### Delivery Methods

- **Instructor-Led Training (ILT)** - On-site or virtual classroom sessions
- **Hands-On Labs** - Practical exercises in lab environment
- **E-Learning Modules** - Self-paced online training
- **Documentation Review** - Guided study of technical documentation

## Table of Contents

1. [Course Catalog](#course-catalog)
2. [Administrator Track](#administrator-track)
3. [Operations Track](#operations-track)
4. [Executive Track](#executive-track)
5. [Hands-On Lab Exercises](#hands-on-lab-exercises)
6. [Assessment and Certification](#assessment-and-certification)
7. [Training Resources](#training-resources)
8. [Ongoing Education](#ongoing-education)

## Course Catalog

### Foundation Courses

**HI-101: Cisco Hybrid Infrastructure Overview**
- Duration: 4 hours
- Format: ILT + E-Learning
- Audience: All tracks
- Prerequisites: Basic networking knowledge

**HI-102: HyperFlex Fundamentals**
- Duration: 8 hours
- Format: ILT + Hands-On Lab
- Audience: Administrator, Operations
- Prerequisites: HI-101

**HI-103: ACI Network Fabric Basics**
- Duration: 6 hours
- Format: ILT + Hands-On Lab
- Audience: Administrator, Operations
- Prerequisites: HI-101

**HI-104: VMware Integration Essentials**
- Duration: 6 hours
- Format: ILT + Hands-On Lab
- Audience: Administrator, Operations
- Prerequisites: VMware vSphere knowledge

### Advanced Courses

**HI-201: Advanced HyperFlex Administration**
- Duration: 16 hours (2 days)
- Format: ILT + Extensive Labs
- Audience: Administrator, Specialist
- Prerequisites: HI-102

**HI-202: ACI Policy Management**
- Duration: 12 hours
- Format: ILT + Hands-On Lab
- Audience: Administrator, Specialist
- Prerequisites: HI-103

**HI-203: Intersight Cloud Operations**
- Duration: 8 hours
- Format: ILT + Hands-On Lab
- Audience: Administrator, Operations
- Prerequisites: HI-102

**HI-204: Performance Optimization and Troubleshooting**
- Duration: 12 hours
- Format: ILT + Hands-On Lab
- Audience: Administrator, Specialist
- Prerequisites: HI-201

### Specialized Courses

**HI-301: Security and Compliance**
- Duration: 8 hours
- Format: ILT + Workshop
- Audience: Administrator, Specialist
- Prerequisites: HI-201, HI-202

**HI-302: Automation and Orchestration**
- Duration: 12 hours
- Format: ILT + Hands-On Lab
- Audience: Specialist
- Prerequisites: Programming basics, HI-201

**HI-303: Disaster Recovery and Business Continuity**
- Duration: 8 hours
- Format: ILT + Hands-On Lab
- Audience: Administrator, Operations
- Prerequisites: HI-201

## Administrator Track

### Track Overview
**Duration**: 5 days (40 hours)  
**Target Audience**: System administrators, infrastructure engineers  
**Prerequisites**: Basic networking, virtualization, and storage concepts

### Day 1: Foundation and HyperFlex Basics

**Morning Session (4 hours): Introduction and Overview**

```
Module 1.1: Cisco Hybrid Infrastructure Overview (1 hour)
- Solution architecture and components
- Business benefits and use cases
- Integration with existing infrastructure
- Licensing and support model

Module 1.2: HyperFlex Architecture Deep Dive (1.5 hours)
- Hyperconverged infrastructure concepts
- HyperFlex cluster architecture
- Storage data services
- Network architecture

Module 1.3: Hardware Components (1.5 hours)
- UCS server platforms
- Storage and networking components
- Hardware monitoring and management
- Replacement procedures
```

**Afternoon Session (4 hours): HyperFlex Management**

```
Module 1.4: HyperFlex Connect (1 hour)
- Installation and initial configuration
- Cluster deployment wizard
- Network configuration
- Storage configuration

Module 1.5: HyperFlex CLI (1.5 hours)
- Command structure and syntax
- Common administrative commands
- Scripting and automation
- Best practices

Lab Exercise 1.1: HyperFlex Cluster Deployment (1.5 hours)
- Deploy test cluster using HyperFlex Connect
- Configure network settings
- Validate cluster health
- Perform basic administrative tasks
```

### Day 2: VMware Integration and Management

**Morning Session (4 hours): vCenter Integration**

```
Module 2.1: VMware Integration Architecture (1 hour)
- vCenter integration methods
- Distributed switch configuration
- Storage integration
- VMware feature compatibility

Module 2.2: vCenter Configuration (1.5 hours)
- Adding HyperFlex to vCenter
- Datastore configuration
- Resource pool setup
- DRS and HA configuration

Lab Exercise 2.1: vCenter Integration (1.5 hours)
- Connect HyperFlex cluster to vCenter
- Configure distributed switches
- Create datastores
- Deploy test VMs
```

**Afternoon Session (4 hours): VM Lifecycle Management**

```
Module 2.3: VM Provisioning and Management (1.5 hours)
- VM templates and cloning
- Resource allocation
- Snapshot management
- Migration procedures

Module 2.4: Storage Management (1.5 hours)
- Datastore operations
- Storage policies
- Capacity planning
- Performance monitoring

Lab Exercise 2.2: VM Lifecycle Operations (1 hour)
- Create VM templates
- Deploy multiple VMs
- Configure storage policies
- Perform vMotion operations
```

### Day 3: Network Management with ACI

**Morning Session (4 hours): ACI Fundamentals**

```
Module 3.1: ACI Architecture Overview (1.5 hours)
- Policy-based networking
- APIC controller
- Fabric discovery and initialization
- Tenant model

Module 3.2: Basic ACI Configuration (1.5 hours)
- Tenant creation
- VRFs and bridge domains
- Application profiles and EPGs
- Contract configuration

Lab Exercise 3.1: ACI Basic Configuration (1 hour)
- Create tenant and VRF
- Configure bridge domains
- Set up application profiles
- Test connectivity
```

**Afternoon Session (4 hours): Advanced ACI Operations**

```
Module 3.3: Advanced ACI Features (1.5 hours)
- Service chaining
- Load balancing integration
- External connectivity
- Multi-site considerations

Module 3.4: ACI Monitoring and Troubleshooting (1.5 hours)
- Fabric health monitoring
- Traffic flow analysis
- Common issues and resolution
- Best practices

Lab Exercise 3.2: ACI Troubleshooting (1 hour)
- Diagnose connectivity issues
- Use fabric health tools
- Implement policy changes
- Validate traffic flows
```

### Day 4: Management and Monitoring

**Morning Session (4 hours): Intersight Management**

```
Module 4.1: Intersight Overview (1 hour)
- Cloud operations platform
- Account setup and licensing
- Target registration
- Dashboard overview

Module 4.2: Server Profile Management (1.5 hours)
- Profile templates
- Policy configuration
- Deployment and updates
- Compliance monitoring

Lab Exercise 4.1: Intersight Configuration (1.5 hours)
- Set up Intersight account
- Register HyperFlex cluster
- Create server profiles
- Monitor infrastructure
```

**Afternoon Session (4 hours): Performance and Monitoring**

```
Module 4.3: Performance Monitoring (1.5 hours)
- Key performance indicators
- Monitoring tools and dashboards
- Alert configuration
- Trend analysis

Module 4.4: Capacity Planning (1.5 hours)
- Growth projections
- Resource utilization analysis
- Expansion planning
- Cost optimization

Lab Exercise 4.2: Monitoring Setup (1 hour)
- Configure SNMP monitoring
- Set up performance alerts
- Create custom dashboards
- Generate capacity reports
```

### Day 5: Operations and Troubleshooting

**Morning Session (4 hours): Maintenance Operations**

```
Module 5.1: Routine Maintenance (1.5 hours)
- Backup procedures
- Software updates
- Hardware maintenance
- Configuration management

Module 5.2: Troubleshooting Methodology (1.5 hours)
- Problem identification
- Data collection techniques
- Escalation procedures
- Documentation requirements

Lab Exercise 5.1: Maintenance Procedures (1 hour)
- Perform cluster backup
- Execute software update
- Validate system health
- Document changes
```

**Afternoon Session (4 hours): Advanced Troubleshooting**

```
Module 5.3: Common Issues and Solutions (1.5 hours)
- Storage performance issues
- Network connectivity problems
- VM operational issues
- Hardware failures

Module 5.4: Advanced Diagnostics (1.5 hours)
- Log analysis techniques
- Performance troubleshooting
- Network diagnostics
- Support case management

Final Lab Exercise: Comprehensive Troubleshooting (1 hour)
- Diagnose simulated issues
- Implement solutions
- Document resolution steps
- Present findings
```

## Operations Track

### Track Overview
**Duration**: 3 days (24 hours)  
**Target Audience**: NOC operators, level 1/2 support staff  
**Prerequisites**: Basic IT operations knowledge

### Day 1: Operations Fundamentals

**Morning Session: System Overview and Monitoring**

```
Module O-1.1: Infrastructure Overview (2 hours)
- Component identification
- Normal operating parameters
- Alert categories and severity
- Escalation procedures

Module O-1.2: Daily Operations (2 hours)
- Health check procedures
- Log review processes
- Performance monitoring
- Incident documentation
```

**Afternoon Session: Basic Troubleshooting**

```
Module O-1.3: Level 1 Troubleshooting (2 hours)
- Common alerts and responses
- Basic diagnostic commands
- When to escalate
- Documentation requirements

Lab Exercise O-1.1: Operations Simulation (2 hours)
- Respond to simulated alerts
- Execute troubleshooting procedures
- Practice escalation processes
- Complete incident reports
```

### Day 2: Monitoring and Response

**Morning Session: Advanced Monitoring**

```
Module O-2.1: Monitoring Tools (2 hours)
- SNMP monitoring setup
- Dashboard configuration
- Alert correlation
- Trend analysis

Module O-2.2: Performance Analysis (2 hours)
- Key performance indicators
- Baseline establishment
- Anomaly detection
- Reporting procedures
```

**Afternoon Session: Incident Management**

```
Module O-2.3: Incident Response (2 hours)
- Incident classification
- Response procedures
- Communication protocols
- Post-incident review

Lab Exercise O-2.1: Incident Response Simulation (2 hours)
- Handle multiple incident types
- Practice communication procedures
- Execute response playbooks
- Conduct post-incident analysis
```

### Day 3: Operational Excellence

**Morning Session: Preventive Operations**

```
Module O-3.1: Preventive Maintenance (2 hours)
- Scheduled maintenance procedures
- Proactive monitoring
- Capacity planning basics
- Change management

Module O-3.2: Documentation and Knowledge Management (2 hours)
- Operational documentation
- Knowledge base management
- Procedure updates
- Training coordination
```

**Afternoon Session: Continuous Improvement**

```
Module O-3.3: Process Improvement (2 hours)
- Metrics and KPIs
- Process optimization
- Feedback mechanisms
- Best practices sharing

Final Assessment and Certification (2 hours)
- Practical examination
- Scenario-based testing
- Certification requirements
- Continuing education planning
```

## Executive Track

### Track Overview
**Duration**: 1 day (8 hours)  
**Target Audience**: IT managers, directors, executives  
**Prerequisites**: General IT management experience

### Morning Session: Strategic Overview

```
Module E-1: Business Value and ROI (2 hours)
- Total cost of ownership analysis
- Operational efficiency gains
- Risk reduction benefits
- Competitive advantages

Module E-2: Technology Architecture (2 hours)
- High-level solution overview
- Integration with business processes
- Scalability and future-proofing
- Technology roadmap alignment
```

### Afternoon Session: Operational Excellence

```
Module E-3: Operational Model (2 hours)
- Resource requirements
- Skills development needs
- Organizational impact
- Change management

Module E-4: Success Metrics and Governance (2 hours)
- Key performance indicators
- Success measurement framework
- Governance structure
- Continuous improvement processes
```

## Hands-On Lab Exercises

### Lab Environment Specifications

**Infrastructure Requirements:**
- 4-node HyperFlex cluster (lab configuration)
- VMware vCenter server
- ACI fabric (virtual or physical)
- Intersight account access
- Student workstations with required software

### Core Lab Exercises

#### Lab 1: HyperFlex Cluster Management

**Objective**: Master basic HyperFlex cluster operations

**Duration**: 3 hours

**Exercises**:
1. **Cluster Health Assessment**
   ```bash
   # Students will execute and interpret results
   hxcli cluster info
   hxcli node list
   hxcli datastore list
   hxcli cluster network-test
   ```

2. **Storage Operations**
   ```bash
   # Create and manage datastores
   hxcli datastore create --name Lab-Datastore --size 500GB
   hxcli datastore resize --name Lab-Datastore --size 750GB
   hxcli datastore snapshot --name Lab-Datastore --snapshot-name backup-001
   ```

3. **Performance Monitoring**
   ```bash
   # Monitor cluster performance
   hxcli cluster iostat
   hxcli node iostat --node-ip 192.168.1.10
   hxcli cluster cpu-usage
   hxcli cluster memory-usage
   ```

**Lab Deliverable**: Complete cluster health report with recommendations

#### Lab 2: VMware Integration and Management

**Objective**: Integrate HyperFlex with vCenter and manage VMs

**Duration**: 4 hours

**Exercises**:
1. **vCenter Integration**
   - Connect HyperFlex cluster to vCenter
   - Configure distributed switches
   - Create datacenter and cluster objects
   - Validate integration

2. **VM Lifecycle Management**
   ```powershell
   # PowerCLI exercises for students
   Connect-VIServer -Server vcenter.lab.local
   
   # Create VM from template
   New-VM -Name "Lab-VM-01" -Template "Windows-2019-Template" -Datastore "HX-Datastore"
   
   # Configure VM resources
   Set-VM -VM "Lab-VM-01" -MemoryGB 8 -NumCpu 4
   
   # Create VM snapshot
   New-Snapshot -VM "Lab-VM-01" -Name "Baseline" -Description "Initial configuration"
   
   # Perform vMotion
   Move-VM -VM "Lab-VM-01" -Destination (Get-VMHost "esx02.lab.local")
   ```

3. **Storage Policy Management**
   - Create VM storage policies
   - Apply policies to VMs
   - Monitor compliance

**Lab Deliverable**: Deployed and configured multi-tier application

#### Lab 3: ACI Network Configuration

**Objective**: Configure ACI fabric for HyperFlex integration

**Duration**: 3 hours

**Exercises**:
1. **Basic ACI Configuration**
   - Create tenant structure
   - Configure VRFs and bridge domains
   - Set up application profiles and EPGs

2. **Policy Implementation**
   - Create and apply contracts
   - Configure service contracts
   - Implement security policies

3. **Integration Testing**
   - Validate network connectivity
   - Test security policies
   - Monitor traffic flows

**Lab Deliverable**: Functional multi-tier network with security policies

#### Lab 4: Monitoring and Troubleshooting

**Objective**: Implement comprehensive monitoring and resolve issues

**Duration**: 3 hours

**Exercises**:
1. **Monitoring Setup**
   - Configure SNMP monitoring
   - Set up performance alerts
   - Create monitoring dashboards

2. **Troubleshooting Scenarios**
   - Diagnose storage performance issues
   - Resolve network connectivity problems
   - Troubleshoot VM operational issues

3. **Documentation and Reporting**
   - Create incident reports
   - Document resolution procedures
   - Generate performance reports

**Lab Deliverable**: Comprehensive monitoring setup with troubleshooting documentation

## Assessment and Certification

### Assessment Methods

**1. Knowledge Assessments**
- Multiple choice questions
- Scenario-based questions
- Diagram interpretation
- Best practices identification

**2. Practical Assessments**
- Hands-on lab exercises
- Troubleshooting simulations
- Configuration tasks
- Documentation reviews

**3. Certification Requirements**

#### Cisco Hybrid Infrastructure Associate (CHIA)
- **Prerequisites**: Complete Administrator Track
- **Assessment**: 2-hour practical exam
- **Passing Score**: 80%
- **Validity**: 2 years
- **Renewal**: 16 hours continuing education or re-examination

#### Cisco Hybrid Infrastructure Operations (CHIO)
- **Prerequisites**: Complete Operations Track
- **Assessment**: 1.5-hour practical exam
- **Passing Score**: 75%
- **Validity**: 2 years
- **Renewal**: 12 hours continuing education or re-examination

#### Cisco Hybrid Infrastructure Expert (CHIE)
- **Prerequisites**: CHIA certification + Specialist courses
- **Assessment**: 4-hour practical exam + project presentation
- **Passing Score**: 85%
- **Validity**: 3 years
- **Renewal**: 24 hours continuing education or re-examination

### Sample Assessment Questions

**Knowledge Assessment Sample:**

```
1. Which command provides cluster-wide storage performance statistics?
   a) hxcli node iostat
   b) hxcli cluster iostat
   c) hxcli datastore performance
   d) hxcli storage stats

2. In ACI, what is the primary purpose of a contract?
   a) Define VLAN assignments
   b) Control communication between EPGs
   c) Configure load balancing
   d) Set up routing protocols

3. What is the recommended maximum storage utilization threshold?
   a) 70%
   b) 80%
   c) 90%
   d) 95%
```

**Practical Assessment Sample:**

```
Scenario: A HyperFlex cluster is experiencing slow VM boot times.

Tasks:
1. Identify potential causes (10 minutes)
2. Gather diagnostic information (15 minutes)
3. Implement resolution steps (20 minutes)
4. Validate solution effectiveness (10 minutes)
5. Document findings and recommendations (5 minutes)

Deliverables:
- Diagnostic report
- Resolution steps taken
- Performance validation data
- Recommendations for prevention
```

## Training Resources

### Documentation Library

**Technical Documentation**
- Solution architecture guides
- Installation and configuration guides
- Operations and maintenance guides
- Troubleshooting guides
- Best practices documentation

**Reference Materials**
- Command reference guides
- Configuration templates
- Troubleshooting flowcharts
- Performance tuning guides
- Security hardening guides

### Digital Resources

**E-Learning Platform**
- Interactive course modules
- Video demonstrations
- Virtual labs
- Progress tracking
- Certification preparation

**Knowledge Base**
- Searchable technical articles
- FAQ database
- Known issues and solutions
- Community contributions
- Regular updates

### Training Tools

**Simulation Environment**
- Virtual HyperFlex cluster
- Simulated network fabric
- Fault injection capabilities
- Performance monitoring tools
- Scenario-based training

**Mobile Learning App**
- Quick reference guides
- Flashcards for certification prep
- Video tutorials
- Offline capability
- Progress synchronization

## Ongoing Education

### Continuous Learning Program

**Monthly Webinars**
- New feature demonstrations
- Best practices sharing
- Case study presentations
- Q&A sessions with experts

**Quarterly Updates**
- Technology roadmap updates
- New training materials
- Certification program changes
- Industry trend discussions

**Annual Conference**
- Advanced training sessions
- Hands-on workshops
- Networking opportunities
- Vendor presentations

### Professional Development

**Certification Maintenance**
- Required continuing education hours
- Online course completion
- Conference attendance credits
- Professional contribution recognition

**Career Advancement**
- Skill assessment tools
- Career path guidance
- Mentorship programs
- Leadership development

### Community and Support

**User Community**
- Online forums
- Regional user groups
- Best practices sharing
- Peer-to-peer support

**Expert Support**
- Access to technical experts
- Office hours sessions
- Escalation support
- Custom training requests

## Training Schedule Template

### Sample 5-Day Administrator Training Schedule

```
Week 1: Cisco Hybrid Infrastructure Administrator Training

Day 1: Foundation and HyperFlex Basics
08:00 - 08:30    Registration and Welcome
08:30 - 10:00    Module 1.1: Solution Overview
10:00 - 10:15    Break
10:15 - 11:45    Module 1.2: HyperFlex Architecture
11:45 - 12:45    Lunch
12:45 - 14:15    Module 1.3: Hardware Components
14:15 - 14:30    Break
14:30 - 16:00    Module 1.4: HyperFlex Connect
16:00 - 17:30    Lab 1.1: Cluster Deployment

Day 2: VMware Integration
08:30 - 10:00    Module 2.1: Integration Architecture
10:00 - 10:15    Break
10:15 - 11:45    Module 2.2: vCenter Configuration
11:45 - 12:45    Lunch
12:45 - 14:15    Lab 2.1: vCenter Integration
14:15 - 14:30    Break
14:30 - 16:00    Module 2.3: VM Management
16:00 - 17:30    Lab 2.2: VM Operations

[Continue for Days 3-5...]
```

## Training Metrics and KPIs

### Success Metrics

**Training Effectiveness**
- Course completion rates: Target >95%
- Assessment pass rates: Target >85%
- Participant satisfaction: Target >4.5/5.0
- Knowledge retention: Target >80% after 6 months

**Operational Impact**
- Reduction in support tickets: Target 30% reduction
- Faster issue resolution: Target 40% improvement
- Increased system uptime: Target 99.9%
- Improved operational efficiency: Target 25% improvement

**Business Value**
- Time to competency: Target <30 days
- Training ROI: Target 300% within 12 months
- Certification achievement: Target 80% of participants
- Knowledge transfer success: Target 100% coverage

### Feedback and Improvement

**Feedback Collection**
- Daily session evaluations
- Course completion surveys
- 30-day post-training surveys
- 90-day effectiveness assessments

**Continuous Improvement**
- Monthly training review meetings
- Quarterly curriculum updates
- Annual program assessment
- Industry best practices integration

---

**Training Materials Version**: 1.0  
**Last Updated**: [Date]  
**Next Review**: [Date + 90 days]  
**Training Coordinator**: training@company.com