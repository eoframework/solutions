# Azure Virtual WAN Global - Training Materials

## Overview

This document provides comprehensive training materials for Azure Virtual WAN Global connectivity solutions. The training programs are designed for different audiences and skill levels to ensure successful adoption and operation of the solution.

## Table of Contents

1. [Training Program Overview](#training-program-overview)
2. [Administrator Training](#administrator-training)
3. [Operations Team Training](#operations-team-training)
4. [End User Training](#end-user-training)
5. [Security Team Training](#security-team-training)
6. [Executive Briefing](#executive-briefing)
7. [Hands-on Labs](#hands-on-labs)
8. [Certification and Assessment](#certification-and-assessment)

## Training Program Overview

### Target Audiences

| Audience | Training Focus | Duration | Delivery Method |
|----------|---------------|----------|-----------------|
| **IT Administrators** | Configuration and management | 16 hours | Instructor-led + Labs |
| **Network Operations** | Monitoring and troubleshooting | 12 hours | Instructor-led + Labs |
| **Security Team** | Security controls and policies | 8 hours | Instructor-led |
| **End Users** | Basic usage and best practices | 2 hours | Self-paced online |
| **Executives** | Business value and strategy | 1 hour | Presentation |

### Learning Objectives

By the end of the training program, participants will be able to:
- Understand Azure Virtual WAN architecture and components
- Deploy and configure Virtual WAN solutions
- Monitor and troubleshoot network connectivity issues
- Implement security best practices
- Optimize performance and costs
- Plan for disaster recovery and business continuity

## Administrator Training

### Module 1: Azure Virtual WAN Fundamentals (4 hours)

#### Learning Objectives
- Understand Virtual WAN architecture and benefits
- Identify key components and their relationships
- Compare Virtual WAN to traditional networking models

#### Content Outline

**1.1 Introduction to Azure Virtual WAN**
- What is Azure Virtual WAN?
- Business drivers for adoption
- Comparison with hub-and-spoke architectures
- Global network backbone benefits

**1.2 Virtual WAN Components**
- Virtual WAN resource
- Virtual Hubs and hub types
- VPN and ExpressRoute gateways
- Azure Firewall integration
- Route tables and routing

**1.3 Network Topologies**
- Any-to-any connectivity
- Hub-and-spoke with Virtual WAN
- Multi-region deployments
- Hybrid cloud connectivity

**1.4 Planning Considerations**
- Hub placement strategy
- IP address planning
- Bandwidth requirements
- Security requirements

#### Hands-on Lab 1.1: Virtual WAN Architecture Review
```
Objective: Analyze existing network topology and plan Virtual WAN implementation

Tasks:
1. Review current network architecture diagram
2. Identify optimal hub locations
3. Plan IP addressing scheme
4. Document connectivity requirements
5. Create Virtual WAN design proposal

Duration: 60 minutes
```

#### Assessment Questions
1. What are the main benefits of Azure Virtual WAN over traditional hub-and-spoke?
2. How many Virtual Hubs can be deployed in a single Virtual WAN?
3. What is the difference between Basic and Standard Virtual WAN?
4. How does routing work in Virtual WAN?

### Module 2: Deployment and Configuration (6 hours)

#### Learning Objectives
- Deploy Virtual WAN and Virtual Hubs
- Configure VPN and ExpressRoute connectivity
- Set up routing and firewall policies
- Validate deployment success

#### Content Outline

**2.1 Virtual WAN Deployment**
- Creating Virtual WAN resource
- Configuring basic settings
- Regional considerations
- Resource group organization

**2.2 Virtual Hub Configuration**
- Creating Virtual Hubs
- Hub addressing and scale units
- Gateway deployment
- Hub peering configuration

**2.3 Site Connectivity**
- VPN site configuration
- Device-specific settings
- Connection establishment
- ExpressRoute integration

**2.4 Security Configuration**
- Azure Firewall deployment
- Security policies and rules
- Network security groups
- Route table configuration

#### Hands-on Lab 2.1: Deploy Virtual WAN Foundation
```powershell
# Lab 2.1: Deploy Virtual WAN Foundation
# Duration: 90 minutes

# Step 1: Create Virtual WAN
$vwan = New-AzVirtualWan -ResourceGroupName "lab-vwan-rg" -Name "lab-vwan" -Location "East US" -Type "Standard"

# Step 2: Create Virtual Hub
$hub = New-AzVirtualHub -ResourceGroupName "lab-vwan-rg" -Name "lab-hub-eastus" -Location "East US" -VirtualWan $vwan -AddressPrefix "10.0.0.0/24"

# Step 3: Deploy VPN Gateway
$vpnGw = New-AzVpnGateway -ResourceGroupName "lab-vwan-rg" -Name "lab-vpngw" -Location "East US" -VirtualHub $hub -VpnGatewayScaleUnit 1

# Step 4: Verify deployment
Get-AzVirtualWan -ResourceGroupName "lab-vwan-rg"
Get-AzVirtualHub -ResourceGroupName "lab-vwan-rg"
Get-AzVpnGateway -ResourceGroupName "lab-vwan-rg"
```

#### Hands-on Lab 2.2: Configure Site Connectivity
```bash
#!/bin/bash
# Lab 2.2: Configure Site Connectivity
# Duration: 120 minutes

# Step 1: Create VPN Site
az network vpn-site create \
    --resource-group "lab-vwan-rg" \
    --name "lab-site-branch1" \
    --location "East US" \
    --virtual-wan "lab-vwan" \
    --ip-address "203.0.113.1" \
    --address-prefixes "192.168.1.0/24" \
    --device-vendor "Cisco" \
    --device-model "ISR4321"

# Step 2: Create VPN Connection
az network vpn-gateway connection create \
    --resource-group "lab-vwan-rg" \
    --gateway-name "lab-vpngw" \
    --name "branch1-connection" \
    --vpn-site "lab-site-branch1"

# Step 3: Verify connection status
az network vpn-gateway connection show \
    --resource-group "lab-vwan-rg" \
    --gateway-name "lab-vpngw" \
    --name "branch1-connection"
```

### Module 3: Advanced Configuration (4 hours)

#### Learning Objectives
- Configure custom routing scenarios
- Implement advanced security features
- Set up monitoring and logging
- Optimize performance settings

#### Content Outline

**3.1 Advanced Routing**
- Custom route tables
- Route propagation and association
- Internet breakout scenarios
- Route filtering

**3.2 Security Advanced Features**
- Threat intelligence integration
- Custom firewall rules
- Application rules and FQDN filtering
- Intrusion detection integration

**3.3 Monitoring and Diagnostics**
- Azure Monitor integration
- Log Analytics configuration
- Performance monitoring
- Troubleshooting tools

#### Hands-on Lab 3.1: Custom Routing Configuration
```powershell
# Lab 3.1: Custom Routing Configuration
# Duration: 90 minutes

# Create custom route table
$routeTable = New-AzVirtualHubRouteTable -ResourceGroupName "lab-vwan-rg" -VirtualHubName "lab-hub-eastus" -Name "CustomRouteTable"

# Add routes for internet breakout through firewall
$route1 = New-AzVirtualHubRoute -AddressPrefix @("0.0.0.0/0") -NextHopType "ResourceId" -NextHop "/subscriptions/.../azureFirewalls/lab-firewall"

# Associate route table with connections
Set-AzVirtualHubRouteTable -ResourceGroupName "lab-vwan-rg" -VirtualHubName "lab-hub-eastus" -Name "CustomRouteTable" -Route @($route1)
```

### Module 4: Operations and Maintenance (2 hours)

#### Learning Objectives
- Understand operational procedures
- Learn troubleshooting methodologies
- Plan for scaling and optimization
- Implement change management

#### Content Outline

**4.1 Daily Operations**
- Health monitoring procedures
- Performance metrics review
- Security log analysis
- Capacity planning

**4.2 Troubleshooting**
- Common connectivity issues
- Performance problems
- Security incidents
- Diagnostic tools usage

**4.3 Change Management**
- Configuration change procedures
- Testing in non-production
- Rollback procedures
- Documentation requirements

## Operations Team Training

### Module 1: Virtual WAN Operations Overview (3 hours)

#### Learning Objectives
- Understand operational responsibilities
- Learn monitoring tools and dashboards
- Identify key performance indicators
- Understand escalation procedures

#### Content Outline

**1.1 Operations Model**
- Roles and responsibilities
- Daily operational tasks
- Weekly and monthly procedures
- Incident response workflows

**1.2 Monitoring and Alerting**
- Azure Monitor dashboards
- Key metrics and thresholds
- Alert configuration
- Notification procedures

**1.3 Performance Management**
- Bandwidth utilization monitoring
- Latency and packet loss tracking
- Application performance correlation
- Capacity planning procedures

#### Hands-on Lab: Operations Dashboard Setup
```json
{
    "dashboard": {
        "id": "vwan-operations-dashboard",
        "displayName": "Virtual WAN Operations Dashboard",
        "tiles": [
            {
                "name": "VPN Connection Status",
                "query": "AzureDiagnostics | where ResourceType == 'VPNGATEWAYS' | summarize ConnectedSites = countif(Status_s == 'Connected')"
            },
            {
                "name": "Bandwidth Utilization",
                "query": "AzureMetrics | where MetricName == 'TunnelBandwidth' | summarize avg(Average) by bin(TimeGenerated, 5m)"
            },
            {
                "name": "Firewall Threats Blocked",
                "query": "AzureDiagnostics | where ResourceType == 'AZUREFIREWALLS' | where msg_s contains 'Deny' | count"
            }
        ]
    }
}
```

### Module 2: Troubleshooting Procedures (4 hours)

#### Learning Objectives
- Learn systematic troubleshooting approach
- Use diagnostic tools effectively
- Escalate issues appropriately
- Document resolutions

#### Content Outline

**2.1 Troubleshooting Methodology**
- Problem identification and scoping
- Data collection and analysis
- Root cause analysis
- Solution implementation

**2.2 Common Issues and Resolutions**
- VPN connectivity problems
- Performance degradation
- Routing issues
- Security policy conflicts

**2.3 Diagnostic Tools**
- Azure Network Watcher
- Connection Monitor
- VPN diagnostics
- Log Analytics queries

#### Troubleshooting Scenarios

**Scenario 1: Site-to-Site VPN Down**
```
Problem: Branch office reports complete connectivity loss
Symptoms: No traffic flowing, VPN tunnel shows disconnected
Troubleshooting steps:
1. Check VPN connection status in Azure portal
2. Verify on-premises device configuration
3. Check for configuration changes
4. Test basic connectivity to public IP
5. Review VPN diagnostic logs
6. Reset VPN connection if necessary
```

**Scenario 2: Performance Degradation**
```
Problem: Users report slow application performance
Symptoms: High latency, occasional timeouts
Troubleshooting steps:
1. Check bandwidth utilization metrics
2. Verify routing configuration
3. Test network latency between sites
4. Review firewall processing times
5. Check for DDoS or security incidents
6. Analyze application-specific metrics
```

### Module 3: Incident Response (3 hours)

#### Learning Objectives
- Understand incident classification
- Follow response procedures
- Communicate effectively with stakeholders
- Document incidents properly

#### Content Outline

**3.1 Incident Classification**
- Severity levels and definitions
- Response time requirements
- Escalation criteria
- Communication protocols

**3.2 Response Procedures**
- Initial assessment and triage
- Technical response actions
- Stakeholder communication
- Resolution and closure

**3.3 Post-Incident Activities**
- Root cause analysis
- Lessons learned documentation
- Process improvements
- Follow-up actions

### Module 4: Capacity Planning and Optimization (2 hours)

#### Learning Objectives
- Monitor capacity trends
- Plan for growth
- Optimize costs and performance
- Recommend improvements

#### Content Outline

**4.1 Capacity Monitoring**
- Bandwidth utilization trends
- Connection growth tracking
- Performance baseline establishment
- Forecasting methodologies

**4.2 Optimization Opportunities**
- Gateway scale unit optimization
- Route table consolidation
- Cost optimization strategies
- Performance tuning

## End User Training

### Module 1: Using Azure Virtual WAN (1 hour)

#### Learning Objectives
- Understand the user experience
- Learn about connectivity expectations
- Know how to report issues
- Follow security best practices

#### Content Outline

**1.1 What is Virtual WAN?**
- Simple explanation of Virtual WAN
- Benefits to end users
- What changes for users
- What stays the same

**1.2 Connectivity Experience**
- Transparent connectivity
- Performance expectations
- Failover behavior
- Mobile and remote access

**1.3 Best Practices**
- Security awareness
- Bandwidth conservation
- Issue reporting procedures
- Support contact information

### Module 2: Security Awareness (1 hour)

#### Learning Objectives
- Understand security implications
- Follow security policies
- Recognize security threats
- Report security incidents

#### Content Outline

**2.1 Network Security**
- Firewall protection
- Traffic monitoring
- Access controls
- Data encryption

**2.2 User Responsibilities**
- Acceptable use policies
- Password and authentication
- Software installation restrictions
- Data handling procedures

**2.3 Threat Recognition**
- Phishing attempts
- Malware indicators
- Suspicious network activity
- Incident reporting procedures

## Security Team Training

### Module 1: Virtual WAN Security Architecture (4 hours)

#### Learning Objectives
- Understand security components
- Learn security best practices
- Configure security policies
- Monitor security events

#### Content Outline

**1.1 Security Architecture**
- Defense in depth strategy
- Azure Firewall integration
- Network security groups
- Route-based security

**1.2 Security Policies**
- Firewall rule configuration
- Application and network rules
- Threat intelligence integration
- Security policy management

**1.3 Monitoring and Response**
- Security event monitoring
- Log analysis procedures
- Incident response integration
- Compliance reporting

#### Hands-on Lab: Security Configuration
```powershell
# Security Lab: Configure Firewall Policies
# Duration: 120 minutes

# Create firewall policy
$policy = New-AzFirewallPolicy -ResourceGroupName "lab-vwan-rg" -Name "lab-fw-policy" -Location "East US"

# Create network rule collection
$networkRule = New-AzFirewallPolicyNetworkRule -Name "AllowHTTPS" -Protocol TCP -SourceAddress "*" -DestinationAddress "*" -DestinationPort 443
$networkCollection = New-AzFirewallPolicyNetworkRuleCollection -Name "NetworkRules" -Priority 200 -ActionType Allow -Rule $networkRule

# Create application rule collection  
$appRule = New-AzFirewallPolicyApplicationRule -Name "AllowMicrosoft" -SourceAddress "*" -Protocol "https:443" -TargetFqdn "*.microsoft.com"
$appCollection = New-AzFirewallPolicyApplicationRuleCollection -Name "ApplicationRules" -Priority 300 -ActionType Allow -Rule $appRule

# Apply rules to policy
$ruleGroup = New-AzFirewallPolicyRuleCollectionGroup -Name "DefaultRules" -Priority 200 -FirewallPolicyObject $policy -NetworkRuleCollection $networkCollection -ApplicationRuleCollection $appCollection
```

### Module 2: Threat Detection and Response (4 hours)

#### Learning Objectives
- Configure threat detection
- Analyze security logs
- Respond to security incidents
- Implement security improvements

#### Content Outline

**2.1 Threat Detection**
- Azure Security Center integration
- Azure Sentinel configuration
- Custom detection rules
- Automated response actions

**2.2 Log Analysis**
- Firewall log analysis
- VPN authentication logs
- Network flow analysis
- Anomaly detection

**2.3 Incident Response**
- Security incident classification
- Investigation procedures
- Containment and mitigation
- Recovery and lessons learned

## Executive Briefing

### Executive Overview (1 hour)

#### Agenda
1. **Business Context** (15 minutes)
   - Current networking challenges
   - Digital transformation requirements
   - Competitive landscape

2. **Azure Virtual WAN Solution** (20 minutes)
   - Solution overview and benefits
   - Architecture and capabilities
   - Implementation approach

3. **Business Impact** (15 minutes)
   - Cost savings and ROI
   - Performance improvements
   - Risk mitigation

4. **Implementation Plan** (10 minutes)
   - Timeline and milestones
   - Resource requirements
   - Success metrics

#### Key Messages
- **Cost Reduction**: Up to 40% reduction in WAN costs
- **Performance**: 3x improvement in application performance
- **Simplification**: 80% reduction in network management complexity
- **Scale**: Support for thousands of branch locations
- **Security**: Built-in enterprise-grade security

#### Executive Summary Slide Deck

**Slide 1: Current State Challenges**
- High WAN costs with limited scalability
- Complex multi-vendor management
- Inconsistent security policies
- Performance bottlenecks

**Slide 2: Azure Virtual WAN Solution**
- Cloud-native global network backbone
- Automated branch connectivity
- Integrated security and routing
- Simplified operations

**Slide 3: Business Benefits**
- 40% cost reduction through internet breakout
- 3x performance improvement via global backbone
- 80% operational simplification
- Enhanced security and compliance

**Slide 4: Implementation Approach**
- Phased rollout minimizes risk
- Minimal disruption to operations  
- Comprehensive training program
- 24/7 support during transition

**Slide 5: Success Metrics**
- Network performance KPIs
- Cost savings tracking
- Security incident reduction
- User satisfaction scores

## Hands-on Labs

### Lab Environment Setup

#### Prerequisites
- Azure subscription with contributor access
- Visual Studio Code or PowerShell ISE
- Azure PowerShell module
- Azure CLI (optional)

#### Lab Environment Configuration
```powershell
# Lab Setup Script
param(
    [string]$LabPrefix = "vwanlab",
    [string]$Location = "East US"
)

# Create lab resource group
$rgName = "$LabPrefix-rg"
New-AzResourceGroup -Name $rgName -Location $Location

# Create lab Virtual WAN
$vwanName = "$LabPrefix-vwan"
New-AzVirtualWan -ResourceGroupName $rgName -Name $vwanName -Location $Location -Type "Standard"

Write-Output "Lab environment created successfully"
Write-Output "Resource Group: $rgName"
Write-Output "Virtual WAN: $vwanName"
```

### Lab 1: Virtual WAN Basics (2 hours)

#### Objectives
- Create Virtual WAN and Virtual Hub
- Deploy VPN Gateway
- Configure basic routing

#### Tasks
1. **Setup Virtual WAN** (30 minutes)
   - Create Virtual WAN resource
   - Configure basic settings
   - Verify deployment

2. **Create Virtual Hub** (45 minutes)
   - Deploy hub in East US
   - Configure address space
   - Deploy VPN gateway

3. **Configure VPN Site** (30 minutes)
   - Create VPN site
   - Configure device parameters
   - Establish connection

4. **Test Connectivity** (15 minutes)
   - Verify connection status
   - Test basic routing
   - Review monitoring data

### Lab 2: Multi-Hub Deployment (3 hours)

#### Objectives
- Deploy multiple Virtual Hubs
- Configure hub-to-hub connectivity
- Test global routing

#### Tasks
1. **Deploy Secondary Hub** (60 minutes)
2. **Configure Inter-Hub Routing** (60 minutes)
3. **Add Multiple Sites** (45 minutes)
4. **Validate Global Connectivity** (15 minutes)

### Lab 3: Security Configuration (2 hours)

#### Objectives
- Deploy Azure Firewall
- Configure security policies
- Test security controls

#### Tasks
1. **Deploy Azure Firewall** (45 minutes)
2. **Configure Firewall Policies** (60 minutes)
3. **Test Security Rules** (30 minutes)
4. **Review Security Logs** (5 minutes)

## Certification and Assessment

### Skills Assessment Framework

#### Administrator Certification Levels

**Level 1: Associate Administrator**
- Basic Virtual WAN concepts
- Simple deployment scenarios
- Standard troubleshooting
- **Passing Score**: 70%

**Level 2: Expert Administrator**  
- Advanced configuration scenarios
- Complex troubleshooting
- Performance optimization
- **Passing Score**: 80%

**Level 3: Architect**
- Solution design and planning
- Multi-region deployments
- Enterprise integration
- **Passing Score**: 85%

### Assessment Methods

#### Written Examination (50%)
- Multiple choice questions
- Scenario-based problems
- Best practice identification
- Configuration validation

#### Practical Demonstration (30%)
- Hands-on deployment tasks
- Troubleshooting exercises
- Configuration optimization
- Documentation requirements

#### Project Portfolio (20%)
- Real-world implementation
- Case study analysis
- Lessons learned presentation
- Peer review feedback

### Sample Assessment Questions

#### Administrator Level Questions

**Question 1**: What is the maximum number of Virtual Hubs that can be deployed in a single Virtual WAN?
a) 10
b) 50
c) 100
d) No limit

**Question 2**: Which routing scenario requires custom route tables?
a) Basic any-to-any connectivity
b) Internet breakout through Azure Firewall
c) Hub-to-hub communication
d) Site-to-site connectivity

#### Scenario-Based Question
```
Scenario: A company has deployed Virtual WAN with hubs in East US and West Europe. 
Branch offices in New York connect to East US hub, while London offices connect to 
West Europe hub. Users report that connections between New York and London offices 
are slow.

Question: What is the most likely cause and solution?
a) Insufficient bandwidth - upgrade VPN gateways
b) Suboptimal routing - enable hub-to-hub optimization  
c) Firewall bottleneck - scale Azure Firewall
d) DNS resolution issues - update DNS configuration
```

### Certification Maintenance

#### Continuing Education Requirements
- Annual recertification exam
- Attend 2 training updates per year
- Complete 1 advanced scenario lab
- Participate in knowledge sharing

#### Professional Development
- Azure networking certifications
- Industry conference attendance
- Technical community participation
- Mentor junior team members

---

**Training Materials Version**: 1.0  
**Last Updated**: August 2024  
**Next Review Date**: February 2025