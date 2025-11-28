---
document_title: Implementation Guide
solution_name: Cisco SD-WAN Enterprise Implementation
document_version: "1.0"
author: "[ENGINEER]"
last_updated: "[DATE]"
technology_provider: cisco
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This implementation guide provides step-by-step procedures for deploying the Cisco SD-WAN Enterprise solution across 150 sites. The guide covers controller infrastructure deployment, policy configuration, edge device provisioning, and operational handoff procedures to ensure a successful SD-WAN transformation.

# Prerequisites

This section outlines the requirements that must be in place before beginning implementation.

## Technical Requirements

The following infrastructure must be available:

| Requirement | Specification | Validation |
|-------------|--------------|------------|
| VMware Environment | vSphere 6.7+ with 96 vCPU, 384GB RAM available | Confirmed |
| Network Connectivity | Management VLAN, transport circuits provisioned | Confirmed |
| DNS Entries | vManage, vSmart, vBond FQDNs registered | Confirmed |
| Certificates | Enterprise CA or Cisco cloud certificates | Confirmed |
| Smart Account | Cisco Smart Account with SD-WAN licenses | Confirmed |

## Software Versions

The following software versions are required:

| Component | Version | Notes |
|-----------|---------|-------|
| vManage | 20.9.1 | Cluster-capable version |
| vSmart | 20.9.1 | Matching controller version |
| vBond | 20.9.1 | Matching orchestrator version |
| vEdge (ISR) | 17.9.1a | IOS-XE SD-WAN image |
| VMware | 6.7 U3+ | Controller hosting |

## Credentials and Access

The following credentials are required:

| System | Access Type | Owner |
|--------|------------|-------|
| vManage | Admin credentials | Network Team |
| VMware vCenter | VM deployment rights | Infrastructure Team |
| Smart Account | Admin access | Licensing Team |
| DNS/DHCP | Zone edit permissions | Infrastructure Team |
| Firewall | Rule modification | Security Team |

# Environment Setup

This section describes the environment preparation procedures.

## Network Environment

Configure the network environment for SD-WAN deployment:

| Environment | Subnet | Purpose |
|-------------|--------|---------|
| Management | 10.100.1.0/24 | Controller management |
| Transport | 10.100.2.0/24 | SD-WAN transport |
| Services | 10.100.3.0/24 | Shared services |
| DMZ | 10.100.4.0/24 | vBond external access |

## DNS Configuration

Configure DNS entries for all controllers:

| Hostname | IP Address | Record Type |
|----------|------------|-------------|
| vmanage.client.local | 10.100.1.15 | A |
| vmanage-1.client.local | 10.100.1.10 | A |
| vmanage-2.client.local | 10.100.1.11 | A |
| vmanage-3.client.local | 10.100.1.12 | A |
| vsmart-1.client.local | 10.100.1.20 | A |
| vsmart-2.client.local | 10.100.1.21 | A |
| vbond.client.local | [PUBLIC_IP] | A |

## Firewall Rules

Configure firewall rules for SD-WAN traffic:

| Source | Destination | Port | Protocol | Purpose |
|--------|-------------|------|----------|---------|
| vEdge | vBond | 12346 | UDP | DTLS orchestration |
| vEdge | vSmart | 12346 | UDP | DTLS control |
| vEdge | vEdge | 12346 | UDP | IPsec data plane |
| vManage | vSmart | 443 | TCP | Management API |
| Admin | vManage | 443 | TCP | Web console |
| vManage | Smart Account | 443 | TCP | Licensing |

# Infrastructure Deployment

This section details the deployment of all infrastructure components required for the SD-WAN solution.

## Deployment Overview

The infrastructure deployment follows a four-phase approach:

| Phase | Layer | Components | Dependencies |
|-------|-------|------------|--------------|
| 1 | Networking | Transport VLANs, firewall rules, NAT policies | None |
| 2 | Security | Certificates, authentication, encryption keys | Phase 1 |
| 3 | Compute | vManage cluster, vSmart, vBond VMs | Phase 2 |
| 4 | Monitoring | Syslog, SNMP, dashboard configuration | Phase 3 |

## Phase 1: Networking Layer

### Networking Components

The networking layer establishes connectivity for the SD-WAN controllers.

#### Management Network Configuration

Configure the management VLAN for controller access:

| Parameter | Value | Purpose |
|-----------|-------|---------|
| VLAN ID | 100 | Management network |
| Subnet | 10.100.1.0/24 | Controller addressing |
| Gateway | 10.100.1.1 | Default gateway |
| DNS | 10.100.5.10 | Name resolution |
| NTP | 10.100.4.10 | Time synchronization |

#### NAT Configuration

Configure NAT for vBond public accessibility:

```
! NAT for vBond public IP
ip nat inside source static 10.100.1.30 [PUBLIC_IP]
ip nat inside source static 10.100.1.31 [PUBLIC_IP_2]
```

## Phase 2: Security Layer

### Security Components

The security layer establishes trust and encryption for the SD-WAN fabric.

#### Certificate Authority Setup

Configure enterprise CA integration or Cisco cloud certificates:

| Certificate Type | Issuer | Validity | Purpose |
|-----------------|--------|----------|---------|
| Controller Certificate | Enterprise CA | 2 years | Controller identity |
| Device Certificate | Cisco Cloud | 1 year | vEdge identity |
| WAN Edge Certificate | Enterprise CA | 1 year | Tunnel encryption |

#### Root CA Installation

Install the root CA certificate on vManage:

1. Navigate to Administration > Settings > Controller Certificate Authorization
2. Select "Enterprise Root Certificate"
3. Upload the root CA certificate (PEM format)
4. Click "Import"

#### Device Authentication Keys

Generate and distribute device authentication keys:

| Key Type | Length | Rotation | Storage |
|----------|--------|----------|---------|
| OMP Key | 256-bit | Annual | vSmart |
| Organization Key | 128-bit | N/A | All devices |
| WAN Edge Key | 256-bit | Per device | Device |

## Phase 3: Compute Layer

### Compute Components

The compute layer deploys the SD-WAN controller virtual machines.

#### vManage Cluster Deployment

Deploy the 3-node vManage cluster:

| Node | Hostname | IP Address | Role |
|------|----------|------------|------|
| Node 1 | vmanage-1.client.local | 10.100.1.10 | Primary |
| Node 2 | vmanage-2.client.local | 10.100.1.11 | Secondary |
| Node 3 | vmanage-3.client.local | 10.100.1.12 | Tertiary |
| VIP | vmanage.client.local | 10.100.1.15 | Cluster VIP |

**VM Specifications:**

| Resource | Value |
|----------|-------|
| vCPU | 16 |
| Memory | 32 GB |
| Disk | 500 GB |
| Network | 2 NICs (Management + Cluster) |

**Deployment Steps:**

1. Deploy OVA template to VMware
2. Configure VM with allocated resources
3. Power on and complete initial wizard
4. Configure cluster membership
5. Verify cluster synchronization

#### vSmart Controller Deployment

Deploy the vSmart HA pair:

| Node | Hostname | IP Address | Role |
|------|----------|------------|------|
| vSmart 1 | vsmart-1.client.local | 10.100.1.20 | Primary |
| vSmart 2 | vsmart-2.client.local | 10.100.1.21 | Secondary |

**VM Specifications:**

| Resource | Value |
|----------|-------|
| vCPU | 4 |
| Memory | 8 GB |
| Disk | 100 GB |
| Network | 2 NICs |

#### vBond Orchestrator Deployment

Deploy the vBond orchestrators:

| Node | Hostname | IP Address | Public IP |
|------|----------|------------|-----------|
| vBond 1 | vbond-1.client.local | 10.100.1.30 | [PUBLIC_IP_1] |
| vBond 2 | vbond-2.client.local | 10.100.1.31 | [PUBLIC_IP_2] |

**VM Specifications:**

| Resource | Value |
|----------|-------|
| vCPU | 2 |
| Memory | 4 GB |
| Disk | 50 GB |
| Network | 2 NICs |

## Phase 4: Monitoring Layer

### Monitoring Components

The monitoring layer establishes visibility into the SD-WAN fabric.

#### Syslog Configuration

Configure syslog forwarding from all controllers:

| Source | Destination | Port | Facility |
|--------|-------------|------|----------|
| vManage | 10.100.6.10 | 514 | local7 |
| vSmart | 10.100.6.10 | 514 | local7 |
| vBond | 10.100.6.10 | 514 | local7 |
| vEdge | 10.100.6.10 | 514 | local6 |

#### SNMP Configuration

Configure SNMP polling for infrastructure monitoring:

| Parameter | Value |
|-----------|-------|
| Version | SNMPv3 |
| Security Level | authPriv |
| Auth Protocol | SHA-256 |
| Privacy Protocol | AES-256 |
| Polling Interval | 60 seconds |

#### Dashboard Setup

Configure vManage dashboard widgets:

| Dashboard | Widgets | Refresh |
|-----------|---------|---------|
| Network Health | Device status, tunnel status, BFD | 60 sec |
| Application | App latency, jitter, loss | 60 sec |
| Security | Threats, blocks, compliance | 300 sec |
| WAN | Bandwidth, utilization, SLA | 60 sec |

# Application Configuration

This section provides detailed configuration procedures for the SD-WAN solution.

## Controller Configuration

### vManage Initial Setup

Complete the vManage initial configuration:

1. **Organization Settings**
   ```
   Organization Name: [CLIENT_ORG_NAME]
   vBond Address: vbond.client.local
   Certificate Authority: Enterprise
   ```

2. **Device Template Creation**
   - Navigate to Configuration > Templates
   - Create Device Template for each site type
   - Attach Feature Templates for system, VPN, interface settings

3. **Policy Configuration**
   - Navigate to Configuration > Policies
   - Create Centralized Policy for application-aware routing
   - Create Security Policy for zone-based firewall

### vSmart Configuration

Configure vSmart controller settings:

```
system
 system-ip             10.100.1.20
 site-id               1
 organization-name     [CLIENT_ORG_NAME]
 vbond vbond.client.local
!
omp
 no shutdown
 graceful-restart
!
```

### vBond Configuration

Configure vBond orchestrator settings:

```
system
 system-ip             10.100.1.30
 site-id               1
 organization-name     [CLIENT_ORG_NAME]
 vbond vbond.client.local local
!
vpn 0
 interface ge0/0
  ip address 10.100.1.30/24
  tunnel-interface
   encapsulation ipsec
   color default
   allow-service all
  !
 !
!
```

## Edge Device Configuration

### Template-Based Provisioning

Create device templates for automated provisioning:

| Template Name | Site Type | VPNs | Features |
|--------------|-----------|------|----------|
| DC-VEDGE-HA | Data Center | 0,1,2,3,512 | Full security, HA |
| HUB-VEDGE-HA | Hub Site | 0,1,2,512 | Full security, HA |
| REGIONAL-VEDGE | Regional | 0,1,2,512 | Full security |
| BRANCH-VEDGE | Branch | 0,1,512 | Basic security |

### Zero-Touch Provisioning

Configure ZTP for automated device onboarding:

1. Add device serial numbers to vManage
2. Assign device template and variables
3. Power on device with factory default
4. Device contacts vBond and downloads configuration

## Policy Configuration

### Application-Aware Routing

Configure application policies for traffic steering:

| Application | SLA Class | Preferred Path | Fallback |
|-------------|-----------|----------------|----------|
| Voice | Real-time | MPLS | Internet |
| Video | Real-time | MPLS | Internet |
| SAP | Business-critical | MPLS | None |
| Microsoft 365 | SaaS | Internet | MPLS |
| General | Best-effort | Any | Any |

### QoS Configuration

Configure QoS policies for traffic prioritization:

| Queue | DSCP | Bandwidth | Description |
|-------|------|-----------|-------------|
| 0 | EF (46) | 15% | Voice |
| 1 | AF41 (34) | 20% | Video |
| 2 | AF31 (26) | 25% | Critical Data |
| 3 | AF21 (18) | 20% | Transactional |
| 4 | Default (0) | 20% | Best Effort |

### Security Zone Configuration

Configure security zones for traffic segmentation:

| Zone | VPN | Allowed Traffic | Policy |
|------|-----|-----------------|--------|
| Corporate | 1 | Business apps | Permit intra-zone |
| Guest | 2 | Internet only | Deny to Corporate |
| IoT | 3 | Specific services | Restrict |
| Management | 512 | Admin traffic | Permit all |

# Integration Testing

This section outlines the integration testing procedures for the SD-WAN deployment.

## Controller Integration Tests

Verify controller integration and communication:

| Test | Description | Expected Result |
|------|-------------|-----------------|
| vManage-vSmart | Verify control connection | Connected with OMP active |
| vManage-vBond | Verify orchestrator connection | vBond registered and reachable |
| vSmart-vSmart | Verify HA synchronization | Routes synchronized between controllers |
| Certificate Chain | Validate certificate trust | All certificates valid and trusted |

## Site Integration Tests

Verify site connectivity and policy application:

| Test | Description | Expected Result |
|------|-------------|-----------------|
| vEdge Onboarding | ZTP device registration | Device receives template configuration |
| Tunnel Formation | IPsec tunnel establishment | Full mesh tunnels to all sites |
| Policy Download | Centralized policy receipt | All policies active on device |
| OMP Routes | Route advertisement | Full routing table via OMP |

## Application Integration Tests

Verify application-aware routing functionality:

| Test | Description | Expected Result |
|------|-------------|-----------------|
| Voice Routing | RTP traffic path selection | Traffic uses MPLS with QoS |
| SaaS Breakout | M365 direct internet access | Traffic exits locally |
| Failover | Transport failure handling | Automatic path switch |
| QoS Marking | DSCP preservation | Correct markings end-to-end |

# Security Validation

This section describes security validation procedures.

## Encryption Validation

Verify encryption on all traffic paths:

| Validation | Method | Expected Result |
|------------|--------|-----------------|
| IPsec Tunnels | show sdwan ipsec local-sa | AES-GCM-256 active |
| DTLS Control | show control connections | DTLS 1.2 encrypted |
| Management | Browser certificate | TLS 1.3 valid |

## Access Control Validation

Verify access control enforcement:

| Validation | Method | Expected Result |
|------------|--------|-----------------|
| RBAC | User login test | Correct role permissions |
| API Access | Token validation | OAuth2 working |
| Device Auth | Certificate check | PKI chain valid |

## Zone Security Validation

Verify security zone enforcement:

| Test | Traffic Flow | Expected Result |
|------|-------------|-----------------|
| Guest Isolation | Guest > Corporate | Blocked |
| IoT Restriction | IoT > Internet | Permitted |
| Corporate Access | Corporate > Any | Per policy |
| Management | Admin > Controllers | Permitted |

# Migration & Cutover

This section describes the migration and cutover procedures.

## Pre-Migration Checklist

Complete the following before migration:

| Item | Owner | Status |
|------|-------|--------|
| Circuit provisioning confirmed | Provider | Pending |
| vEdge devices staged | Network Team | Pending |
| Templates validated in lab | Network Team | Pending |
| Rollback procedure documented | Network Team | Pending |
| Change request approved | Change Board | Pending |

## Migration Waves

Execute migration in planned waves:

| Wave | Sites | Duration | Schedule |
|------|-------|----------|----------|
| Pilot | 5 sites | 5 days | Week 1 |
| Wave 1 | 10 hub sites | 5 days | Week 2 |
| Wave 2 | 35 regional | 7 days | Week 3-4 |
| Wave 3 | 50 branch | 10 days | Week 5-6 |
| Wave 4 | 50 branch | 10 days | Week 7-8 |

## Cutover Procedure

Execute cutover for each site:

1. **Pre-Cutover (T-1 day)**
   - Verify circuit readiness
   - Stage vEdge device
   - Prepare template variables

2. **Cutover (Maintenance Window)**
   - Install vEdge router
   - Connect transport circuits
   - Verify ZTP onboarding
   - Validate tunnel formation
   - Test application routing

3. **Post-Cutover Validation**
   - Verify all tunnels UP
   - Confirm policy application
   - Test user traffic
   - Monitor for 24 hours

## Rollback Procedure

Execute rollback if issues occur:

| Step | Action | Duration |
|------|--------|----------|
| 1 | Disconnect vEdge from network | 5 min |
| 2 | Reconnect legacy router | 10 min |
| 3 | Verify legacy routing | 5 min |
| 4 | Notify NOC of rollback | Immediate |
| 5 | Document issues for remediation | Post-window |

# Operational Handover

This section documents the handoff to operations teams.

## Documentation Deliverables

The following documentation is provided:

| Document | Description | Location |
|----------|-------------|----------|
| Detailed Design | Architecture and configuration design | SharePoint |
| Implementation Guide | This document | SharePoint |
| Runbook | Day-to-day operational procedures | ServiceNow |
| Troubleshooting Guide | Issue resolution procedures | ServiceNow |
| Training Materials | Administrator training content | LMS |

## Support Contacts

Key support contacts for the solution:

| Role | Name | Contact | Escalation |
|------|------|---------|------------|
| Project Manager | [PM_NAME] | [EMAIL] | Level 1 |
| Network Architect | [ARCH_NAME] | [EMAIL] | Level 2 |
| Cisco TAC | 24x7 Support | 1-800-553-2447 | Level 3 |

## Handover Checklist

Complete handover checklist:

| Item | Owner | Status |
|------|-------|--------|
| Documentation delivered | EO Team | Pending |
| Training completed | EO Team | Pending |
| Credentials transferred | EO Team | Pending |
| Monitoring enabled | Client NOC | Pending |
| Support contracts active | Procurement | Pending |

# Training Program

This section outlines the training program for operations teams.

## Training Schedule

The following training sessions are delivered:

| Session | Audience | Duration | Format |
|---------|----------|----------|--------|
| SD-WAN Administration | Network Engineers | 40 hours | Instructor-led |
| vManage Operations | NOC Operators | 32 hours | Instructor-led |
| Security Management | Security Team | 24 hours | Instructor-led |
| Policy Basics | Application Owners | 16 hours | Self-paced |

## Training Modules

### Network Engineer Training

Training modules for network engineers:

| Module | Topics | Duration |
|--------|--------|----------|
| Module 1 | SD-WAN Architecture and Components | 8 hours |
| Module 2 | vManage Administration | 8 hours |
| Module 3 | Template and Policy Configuration | 8 hours |
| Module 4 | Troubleshooting and Diagnostics | 8 hours |
| Module 5 | Advanced Features and Integration | 8 hours |

### NOC Operator Training

Training modules for NOC operators:

| Module | Topics | Duration |
|--------|--------|----------|
| Module 1 | Dashboard Navigation | 8 hours |
| Module 2 | Monitoring and Alerting | 8 hours |
| Module 3 | Basic Troubleshooting | 8 hours |
| Module 4 | Incident Response Procedures | 8 hours |

## Training Materials

The following materials are provided:

| Material | Format | Location |
|----------|--------|----------|
| Administrator Guide | PDF | SharePoint |
| Lab Exercises | Word | SharePoint |
| Quick Reference Cards | PDF | SharePoint |
| Video Recordings | MP4 | LMS |

# Troubleshooting

This section provides troubleshooting procedures for common issues.

## Common Issues

### Control Connection Failures

**Symptoms:** vEdge cannot establish control connection to vSmart

**Diagnostic Steps:**
1. Verify vBond reachability: `ping vbond.client.local`
2. Check certificate validity: `show certificate status`
3. Verify organization name matches across devices
4. Check firewall rules for UDP 12346

**Resolution:**
- Correct certificate configuration
- Update firewall rules
- Verify vBond public IP and NAT

### Tunnel Establishment Failures

**Symptoms:** IPsec tunnels not forming between sites

**Diagnostic Steps:**
1. Check BFD status: `show bfd sessions`
2. Verify TLOC status: `show sdwan tloc-paths`
3. Check IPsec SA: `show sdwan ipsec local-sa`
4. Verify underlay connectivity

**Resolution:**
- Correct TLOC color configuration
- Update firewall rules for ESP
- Verify MTU settings

### Application Performance Issues

**Symptoms:** Poor application performance despite active tunnels

**Diagnostic Steps:**
1. Check SLA status: `show sdwan app-route sla-class`
2. Verify policy application: `show sdwan policy from-vsmart`
3. Check QoS queuing: `show sdwan policy qos-map`
4. Review AppQoE metrics in vManage

**Resolution:**
- Adjust SLA thresholds
- Update application policy priorities
- Optimize QoS queue allocations

## Escalation Procedures

### Support Escalation Matrix

| Severity | Response Time | Escalation Path |
|----------|--------------|-----------------|
| P1 - Critical | 15 minutes | NOC > Network Engineer > TAC |
| P2 - High | 1 hour | NOC > Network Engineer |
| P3 - Medium | 4 hours | Ticket queue |
| P4 - Low | Next business day | Ticket queue |

### Cisco TAC Contact

For issues requiring vendor support:

| Support Level | Contact | Contract |
|--------------|---------|----------|
| 24x7 TAC | 1-800-553-2447 | SmartNet [CONTRACT_NUMBER] |
| Priority Support | tac@cisco.com | Premium Support |
| Online Portal | cisco.com/support | Self-service |

# Appendices

## Appendix A: CLI Reference

Common CLI commands for SD-WAN operations:

| Command | Purpose |
|---------|---------|
| show sdwan control connections | View control plane connections |
| show sdwan bfd sessions | View BFD session status |
| show sdwan omp routes | View OMP routing table |
| show sdwan ipsec local-sa | View IPsec security associations |
| show sdwan app-route statistics | View application route metrics |
| show sdwan policy from-vsmart | View downloaded policies |

## Appendix B: API Reference

vManage REST API endpoints:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /dataservice/device | GET | Get device list |
| /dataservice/template/device | GET | Get device templates |
| /dataservice/device/action/reboot | POST | Reboot device |
| /dataservice/statistics/interface | GET | Get interface statistics |
| /dataservice/alarms | GET | Get active alarms |

## Appendix C: Support Contacts

Key contacts for ongoing support:

| Role | Contact | Availability |
|------|---------|--------------|
| Client NOC | noc@client.local | 24x7 |
| Network Team | network-team@client.local | Business hours |
| Cisco TAC | 1-800-553-2447 | 24x7 |
| EO Support | support@eoconsulting.local | Business hours |
