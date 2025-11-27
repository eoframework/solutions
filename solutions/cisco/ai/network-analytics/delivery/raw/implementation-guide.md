---
document_title: Implementation Guide
solution_name: Cisco DNA Center Network Analytics
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: cisco
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the Cisco DNA Center Network Analytics solution. The guide covers DNA Center HA deployment, device onboarding, AI analytics configuration, and integration setup with ServiceNow and NetBox.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying the DNA Center Network Analytics solution. All commands and procedures have been validated against target environments.

## Implementation Approach

The implementation follows a phased deployment methodology with DNA Center HA setup first, followed by pilot device onboarding (50 devices), full deployment (150 additional devices), and integration configuration. The approach ensures repeatable, auditable deployments with validation gates.

## Automation Framework Overview

The following automation technologies are included in this delivery.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| DNA Center PnP | Device provisioning | Built-in | Device credentials |
| DNA Center Templates | Configuration automation | Template Hub | Template design |
| REST APIs | Integration connectivity | Platform APIs | API tokens |

## Scope Summary

### In Scope

The following components are deployed using this guide.

- DNA Center HA deployment (2x DN2-HW-APL appliances)
- Device onboarding for 200 network devices
- AI Network Analytics configuration
- Policy template deployment (VLAN, ACL, compliance)
- Active Directory integration
- ServiceNow ITSM integration
- NetBox IPAM integration
- Monitoring and alerting setup

### Out of Scope

The following items are excluded from this deployment.

- SD-Access fabric deployment (optional Phase 2)
- SD-WAN integration (separate initiative)
- Custom AI model development
- End-user application training

## Timeline Overview

The implementation follows a phased deployment approach with validation gates.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Foundation Setup | 4 weeks | DNA Center HA operational |
| 2 | AI Analytics Deployment | 4 weeks | 200 devices, baselines established |
| 3 | Integration Setup | 4 weeks | ServiceNow/NetBox operational |
| 4 | Testing & Training | 4 weeks | UAT complete, team trained |

**Total Implementation:** 16 weeks + 4 weeks hypercare

# Prerequisites

This section documents all requirements that must be satisfied before deployment can begin.

## Tool Installation

The following tools must be available before proceeding.

### Required Tools Checklist

Use the following checklist to verify all required tools are available.

- [ ] **SSH Client** - For DNA Center CLI access
- [ ] **Web Browser** - Chrome or Firefox for DNA Center GUI
- [ ] **CIMC Access** - For appliance initial configuration
- [ ] **Network Access** - Management VLAN connectivity

### DNA Center Appliance Access

Verify appliance accessibility before deployment.

```bash
# Verify CIMC access (initial setup)
ping 10.100.1.100  # CIMC IP for primary
ping 10.100.1.101  # CIMC IP for secondary

# After initial setup, verify DNA Center access
ping 10.100.1.10   # Primary management IP
ping 10.100.1.11   # Secondary management IP
```

## Network Configuration

Configure network prerequisites for DNA Center deployment.

### Management Network Requirements

- VLAN 100 configured for management traffic
- Subnet: 10.100.1.0/24 available
- Gateway: 10.100.1.1 reachable
- DNS servers: 10.100.5.10, 10.100.5.11
- NTP servers: 10.100.4.10, 10.100.4.11

### Firewall Rules

Ensure the following ports are permitted.

- TCP 22: SSH to DNA Center
- TCP 443: HTTPS to DNA Center
- TCP 830: NETCONF to devices
- UDP 161: SNMP to devices
- TCP 389/636: LDAP to Active Directory

## Active Directory Prerequisites

Prepare Active Directory before deployment.

### Service Account Creation

Create service account for LDAP binding.

- Username: svc_dnac_ldap
- Password: [Secure password per policy]
- Permissions: Read access to user and group objects
- OU: CN=ServiceAccounts,DC=client,DC=local

### Group Creation

Create AD groups for RBAC.

- DNA-Center-Admins: Full administrative access
- DNA-Center-Viewers: Read-only dashboard access

## Prerequisite Validation

Complete this checklist before proceeding to environment setup.

- [ ] Management VLAN configured (VLAN 100)
- [ ] IP addresses allocated (10.100.1.10-12)
- [ ] DNS entries created for DNA Center FQDN
- [ ] NTP servers accessible
- [ ] Active Directory service account created
- [ ] AD groups created (Admins, Viewers)
- [ ] ServiceNow integration user created
- [ ] NetBox API token generated
- [ ] SSL certificate obtained (optional)

# Environment Setup

This section covers the initial setup of DNA Center appliances and environment configuration.

## DNA Center Deployment Architecture

The deployment consists of two DN2-HW-APL appliances in HA configuration.

- Primary Appliance: 10.100.1.10
- Secondary Appliance: 10.100.1.11
- Virtual IP (VIP): 10.100.1.12
- FQDN: dnac.client.local

## Appliance Physical Installation

### Rack Installation

1. Install both DN2-HW-APL appliances in data center rack
2. Connect redundant power supplies per appliance
3. Connect 10GbE management interfaces to management switch
4. Connect cluster interfaces between appliances (direct or via switch)
5. Verify power LED and status indicators

### CIMC Configuration

1. Access CIMC web interface for primary appliance
2. Configure CIMC IP, DNS, and NTP
3. Verify BIOS settings (virtualization enabled)
4. Repeat for secondary appliance

## Environment Configuration Files

### Primary Appliance Configuration

Configure the following settings during Maglev installation.

```
Hostname: dnac-primary
Management IP: 10.100.1.10/24
Gateway: 10.100.1.1
DNS Servers: 10.100.5.10, 10.100.5.11
NTP Servers: 10.100.4.10, 10.100.4.11
Admin Password: [Secure password]
```

### Secondary Appliance Configuration

```
Hostname: dnac-secondary
Management IP: 10.100.1.11/24
Gateway: 10.100.1.1
DNS Servers: 10.100.5.10, 10.100.5.11
NTP Servers: 10.100.4.10, 10.100.4.11
Admin Password: [Same as primary]
```

# Infrastructure Deployment

This section covers the phased deployment of DNA Center infrastructure.

## Deployment Overview

Infrastructure deployment follows a dependency-ordered sequence.

<!-- TABLE_CONFIG: widths=[15, 25, 35, 25] -->
| Phase | Layer | Components | Dependencies |
|-------|-------|------------|--------------|
| 1 | Networking | Management VLAN, IP allocation | None |
| 2 | Security | Active Directory, credentials | Networking |
| 3 | Compute | DNA Center appliances, HA | Security |
| 4 | Monitoring | Assurance, alerting, dashboards | Compute |

## Phase 1: Networking Layer

Deploy the foundational networking infrastructure for DNA Center.

### Management Network Configuration

Configure the management VLAN and IP addressing.

1. Create VLAN 100 for management traffic
2. Assign subnet 10.100.1.0/24 to management VLAN
3. Allocate IPs: Primary (10.100.1.10), Secondary (10.100.1.11), VIP (10.100.1.12)
4. Configure routing to all managed device subnets

### Firewall Rules Configuration

Ensure the following firewall rules are in place.

```bash
# Required inbound to DNA Center
TCP 443 (HTTPS)
TCP 22 (SSH)

# Required outbound from DNA Center
TCP 830 (NETCONF)
TCP 22 (SSH to devices)
UDP 161 (SNMP)
TCP 636 (LDAPS to AD)
```

### Network Verification

```bash
# Verify management VLAN connectivity
ping 10.100.1.1  # Gateway

# Verify DNS resolution
nslookup dnac.client.local

# Verify NTP synchronization
ntpdate -q 10.100.4.10
```

## Phase 2: Security Layer

Deploy security controls including IAM and credential management.

### Active Directory Preparation

1. Create service account svc_dnac_ldap in AD
2. Create AD groups: DNA-Center-Admins, DNA-Center-Viewers
3. Grant service account read permissions to user/group objects
4. Test LDAP connectivity from management network

### Device Credentials Setup

1. Create network_admin user on all 200 devices
2. Configure SNMP v3 credentials on devices
3. Enable NETCONF on IOS-XE devices (16.12+)
4. Document enable secret for privileged access

### Security Verification

```bash
# Test LDAP connectivity
ldapsearch -H ldaps://10.100.2.10:636 \
  -D "CN=svc_dnac_ldap,OU=ServiceAccounts,DC=client,DC=local" \
  -W -b "DC=client,DC=local" "(sAMAccountName=testuser)"

# Test device SSH access
ssh network_admin@[device_ip]
```

## Phase 3: Compute Layer

Install DNA Center platform on the appliances.

### Primary Appliance Installation

Install DNA Center on the primary appliance.

```bash
# Access CIMC and boot from installation media
# Follow Maglev installer prompts

# After installation, verify services
ssh maglev@10.100.1.10
maglev-config services status

# Verify all services are running
maglev-config system status
```

### Secondary Appliance Installation

Install DNA Center on the secondary appliance for HA.

```bash
# Install DNA Center on secondary appliance
# During installation, select "Join existing cluster"

# On primary, initiate HA configuration
maglev-config ha configure --secondary 10.100.1.11

# Configure VIP
maglev-config ha vip configure --ip 10.100.1.12

# Verify HA status
maglev-config ha status
```

### Compute Verification

```bash
# Verify DNA Center web UI accessible
curl -k https://10.100.1.12/dna/home

# Check cluster status
maglev-config cluster status

# Verify services
maglev-config services list | grep -E "RUNNING|STOPPED"

# Verify data replication
maglev-config ha replication status
```

## Phase 4: Monitoring Layer

Deploy monitoring, alerting, and dashboards.

### DNA Center Assurance Setup

1. Navigate to Assurance > Health Dashboard
2. Verify all onboarded devices show in health view
3. Configure health score thresholds
4. Enable AI analytics (after 14-day baseline)

### Alerting Configuration

1. Configure SMTP settings for email alerts
2. Set up alert thresholds for critical metrics
3. Configure ServiceNow integration for auto-ticketing
4. Test alert flow end-to-end

### Dashboard Configuration

1. Create operational dashboard for NOC
2. Configure executive summary dashboard
3. Set up AI analytics dashboard
4. Verify all dashboards display correctly

### Monitoring Verification

```bash
# Verify syslog forwarding
# Check syslog server for DNA Center logs

# Verify alerting
# Generate test alert and verify email delivery

# Verify ServiceNow integration
# Confirm test ticket created
```

## Phase 5: Active Directory Integration

Configure LDAP authentication with Active Directory.

### AD Configuration Steps

1. Access DNA Center GUI via VIP (https://10.100.1.12)
2. Navigate to System > Settings > Authentication
3. Click "Add External Server"
4. Configure LDAP settings:

```
Server Type: Active Directory
Primary Server: 10.100.2.10
Secondary Server: 10.100.2.11
Port: 636 (LDAPS)
Bind DN: CN=svc_dnac_ldap,OU=ServiceAccounts,DC=client,DC=local
Base DN: DC=client,DC=local
```

5. Test connection with service account credentials
6. Configure group mappings:
   - DNA-Center-Admins → SUPER-ADMIN-ROLE
   - DNA-Center-Viewers → OBSERVER-ROLE
7. Enable external authentication
8. Test login with AD user

### AD Verification

```bash
# Test LDAP connectivity from DNA Center CLI
ssh maglev@10.100.1.12
ldapsearch -H ldaps://10.100.2.10:636 \
  -D "CN=svc_dnac_ldap,OU=ServiceAccounts,DC=client,DC=local" \
  -W -b "DC=client,DC=local" "(sAMAccountName=testuser)"
```

## Phase 4: Device Credentials Setup

Configure device credentials for network access.

### CLI Credentials

1. Navigate to Design > Network Settings > Device Credentials
2. Add CLI credentials:
   - Username: network_admin
   - Password: [Secure password]
   - Enable Password: [Secure enable password]
3. Test credentials on pilot device

### SNMP Credentials

1. Add SNMP credentials:
   - Version: SNMP v3
   - Username: dnac_snmp
   - Auth Protocol: SHA
   - Privacy Protocol: AES-256
2. Verify SNMP access to devices

# Application Configuration

This section covers post-infrastructure configuration for device onboarding and AI analytics.

## Pilot Device Onboarding (50 Devices)

### Discovery Configuration

1. Navigate to Discovery > Discovery
2. Create new discovery job:
   - Name: Pilot-Campus-Core
   - IP Range: [Pilot device IP ranges]
   - Credentials: Select configured credentials
   - Enable: SNMP, CLI, NETCONF
3. Run discovery
4. Monitor progress in Discovery Jobs

### Pilot Verification

```bash
# Verify devices in inventory
# Navigate to Provision > Network Devices > Inventory

# Check device health
# Navigate to Assurance > Health > Network Health

# Verify telemetry streaming
# Navigate to Assurance > Network Analytics
```

## Full Device Onboarding (150 Devices)

### Discovery Waves

Execute discovery in waves to manage risk.

**Wave 1: Campus Access Switches (60 devices)**
- IP Range: [Access switch ranges]
- Validate before proceeding

**Wave 2: Branch Routers (50 devices)**
- IP Range: [Router ranges]
- Validate before proceeding

**Wave 3: Wireless Controllers (10 devices)**
- IP Range: [Controller ranges]
- Validate before proceeding

**Wave 4: Data Center Switches (30 devices)**
- IP Range: [DC switch ranges]
- Validate before proceeding

## AI Network Analytics Configuration

### Enable AI Analytics

1. Navigate to Assurance > AI Analytics
2. Verify DNA Advantage license shows AI Analytics enabled
3. Enable analytics for all device types:
   - Switches: Enabled
   - Routers: Enabled
   - Wireless: Enabled

### Configure Baselines

1. Set baseline learning period: 14 days
2. Set anomaly sensitivity: Medium
3. Set prediction horizon: 14 days
4. Enable predictive insights

### AI Analytics Verification

```bash
# After 14-day baseline period:
# 1. Navigate to Assurance > AI-Driven Issues
# 2. Verify baselines established
# 3. Review initial predictions
# 4. Tune sensitivity if false positive rate > 5%
```

## Policy Template Configuration

### VLAN Provisioning Template

1. Navigate to Tools > Template Hub
2. Create new template: vlan-provisioning-v1
3. Configure template:

```
vlan ${vlan_id}
 name ${vlan_name}
!
interface Vlan${vlan_id}
 description ${vlan_description}
 ip address ${vlan_gateway} ${vlan_mask}
!
```

4. Save and test on pilot device

### ACL Policy Template

1. Create template: acl-standard-v1
2. Configure template:

```
ip access-list extended ${acl_name}
 permit tcp any any eq 22
 permit tcp any any eq 443
 deny ip any any log
!
```

3. Deploy to test devices

# Integration Testing

This section covers integration testing procedures.

## ServiceNow Integration Configuration

### DNA Center Configuration

1. Navigate to Platform > Bundles
2. Install ServiceNow bundle
3. Navigate to Platform > Configurations > ServiceNow
4. Configure connection:
   - Instance URL: https://[instance].service-now.com
   - Username: svc_dnac_snow
   - Password: [Secure password]
   - Table: incident
5. Configure priority mapping:
   - Critical → P1
   - High → P2
   - Medium → P3
   - Low → P4
6. Enable bidirectional sync

### ServiceNow Verification

```bash
# Generate test network event
# Navigate to Assurance > Issues
# Create manual test issue

# Verify incident created in ServiceNow
# Check incident table for new ticket

# Update status in ServiceNow
# Verify status syncs to DNA Center
```

## NetBox Integration Configuration

### Webhook Configuration

1. Navigate to Platform > Webhooks
2. Configure webhook for device events:
   - URL: https://netbox.client.local/api/dcim/devices/
   - Authentication: Token [api-token]
   - Events: Device Added, Device Updated
3. Map DNA Center fields to NetBox

### NetBox Verification

```bash
# Add new device to DNA Center
# Wait 15 minutes for sync

# Verify device in NetBox
curl -H "Authorization: Token [token]" \
  https://netbox.client.local/api/dcim/devices/?name=[device]
```

## Integration Test Execution

### Functional Tests

Execute integration tests from test plan:
- FT-008: Active Directory Integration
- FT-009: ServiceNow Ticket Creation
- FT-010: ServiceNow Bidirectional Sync
- FT-011: NetBox Inventory Sync

### Test Success Criteria

- [ ] AD authentication working for both roles
- [ ] ServiceNow tickets created automatically
- [ ] Status updates sync bidirectionally
- [ ] NetBox inventory synced within 15 minutes

# Security Validation

This section covers security validation procedures.

## Security Scan Execution

### Access Control Validation

```bash
# Test admin role permissions
# Login as DNA-Center-Admins member
# Verify full access to all features

# Test viewer role restrictions
# Login as DNA-Center-Viewers member
# Verify read-only access

# Verify local admin locked
# Attempt login with local admin
# Should be restricted to emergency use
```

### Encryption Validation

```bash
# Verify TLS configuration
curl -vvv https://10.100.1.12 2>&1 | grep "TLS"

# Verify certificate
openssl s_client -connect 10.100.1.12:443 </dev/null 2>&1 | \
  openssl x509 -noout -dates

# Verify device credentials encrypted
# Navigate to Design > Network Settings > Device Credentials
# Verify credentials are masked
```

## Compliance Validation

### Audit Logging Validation

```bash
# Perform administrative action
# Navigate to any configuration page and make change

# Verify audit log entry
# Navigate to System > Audit Logs
# Verify action logged with timestamp and user

# Verify syslog forwarding
# Check syslog server for DNA Center logs
```

## Security Validation Checklist

- [ ] RBAC enforced per AD group
- [ ] TLS 1.2+ for all web traffic
- [ ] Device credentials encrypted at rest
- [ ] Audit logging enabled and forwarding
- [ ] Session timeout enforced (30 min)
- [ ] Failed login attempts logged

# Migration & Cutover

This section covers production cutover procedures.

## Pre-Migration Checklist

- [ ] DNA Center HA operational
- [ ] All 200 devices onboarded
- [ ] AI analytics baselines established
- [ ] ServiceNow integration tested
- [ ] NetBox integration tested
- [ ] Security validation complete
- [ ] Team training complete
- [ ] Runbook documentation complete
- [ ] Stakeholder approval obtained

## Production Cutover

### Go-Live Steps

1. Verify all health checks passing
2. Enable production alerting
3. Switch primary monitoring to DNA Center
4. Notify stakeholders of go-live
5. Begin hypercare monitoring

### Post-Cutover Validation

```bash
# Verify device health
# Navigate to Assurance > Health > Network Health
# All devices should show green status

# Verify AI analytics operational
# Navigate to Assurance > AI-Driven Issues
# Check for any critical issues

# Verify integrations
# Check ServiceNow for automated tickets
# Verify NetBox sync current
```

## Rollback Procedures

If critical issues are identified, execute rollback.

### Device Rollback

```bash
# Remove problematic devices from DNA Center
# Navigate to Provision > Network Devices > Inventory
# Select device and click "Delete"

# Revert to manual management if needed
# Use direct CLI access for critical changes
```

### Integration Rollback

```bash
# Disable ServiceNow integration
# Navigate to Platform > Configurations > ServiceNow
# Disable integration

# Disable NetBox sync
# Remove webhook configuration
```

# Operational Handover

This section covers the transition to ongoing operations.

## Monitoring Dashboard Access

### DNA Center Dashboard

Access DNA Center dashboards for operational monitoring.

- Health Dashboard: https://10.100.1.12/dna/assurance/health
- AI Analytics: https://10.100.1.12/dna/assurance/analytics
- Issues: https://10.100.1.12/dna/assurance/issues

### Key Metrics to Monitor

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Device Unreachable | > 5 min | Critical | Investigate |
| AI Anomaly | Confidence > 85% | High | Review insights |
| Compliance Drift | Any violation | Medium | Remediate |
| Integration Failure | Sync failed | Medium | Check logs |

## Support Transition

### Support Model

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | Initial triage | Network Help Desk | 15 minutes |
| L2 | Technical troubleshooting | Network Operations | 1 hour |
| L3 | Complex issues | Cisco TAC | 4 hours |

### Escalation Contacts

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Network Lead | [NAME] | [EMAIL] | [PHONE] |
| NOC Manager | [NAME] | [EMAIL] | [PHONE] |
| Cisco TAC | SmartNet | [CONTRACT#] | [PHONE] |

# Training Program

This section documents the training program for the DNA Center solution.

## Training Overview

Training ensures all user groups achieve competency with DNA Center operations.

### Training Schedule

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | DNA Center Administration | IT Admins | 8 | ILT | None |
| TRN-002 | AI Analytics Operations | Network Ops | 8 | Hands-On | TRN-001 |
| TRN-003 | Policy Automation | Network Eng | 8 | Hands-On | TRN-001 |
| TRN-004 | Troubleshooting Workshop | Network Ops | 8 | Hands-On | TRN-002 |

## Training Materials

The following training materials are provided.

- Administrator Guide (PDF, 30 pages)
- Network Operations Guide (PDF, 20 pages)
- Quick Reference Cards
- Video recordings of all training sessions
- Hands-on lab exercises
- FAQ document

## Training Delivery

### Administrator Training (16 hours)

- Day 1: DNA Center fundamentals, navigation, user management
- Day 2: Backup/restore, HA operations, troubleshooting

### Operations Training (12 hours)

- Day 1: AI Analytics dashboards, interpreting insights
- Day 2: Alert investigation, root cause analysis
- Day 3: Policy deployment, compliance monitoring

### Advanced Training (4 hours)

- Template customization
- Integration management
- Custom dashboard creation

# Appendices

## Appendix A: Environment Reference

### Production Environment

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Parameter | Value | Description |
|-----------|-------|-------------|
| Environment Name | production | Primary production environment |
| DNA Center Primary | 10.100.1.10 | Primary appliance management IP |
| DNA Center Secondary | 10.100.1.11 | Secondary appliance management IP |
| DNA Center VIP | 10.100.1.12 | Virtual IP for access |
| Device Count | 200 | Total managed devices |

## Appendix B: Troubleshooting Guide

### Common Issues and Resolutions

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| Device not discovered | Connectivity or credentials | Verify reachability, check credentials |
| AI analytics not working | Baseline period not complete | Wait 14 days for baseline |
| ServiceNow sync failed | API credentials | Verify service account permissions |
| HA failover not working | Cluster network | Check cluster interface connectivity |

### Diagnostic Commands

```bash
# Check DNA Center services
ssh maglev@10.100.1.12
maglev-config services status

# Check HA status
maglev-config ha status

# Collect support bundle
maglev-config support bundle create

# Check cluster health
maglev-config cluster status
```

## Appendix C: Service Ports Reference

### DNA Center Ports

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Service | Port | Protocol | Direction |
|---------|------|----------|-----------|
| Web UI | 443 | TCP | Inbound |
| SSH | 22 | TCP | Inbound |
| NETCONF | 830 | TCP | Outbound |
| SNMP | 161 | UDP | Outbound |
| LDAPS | 636 | TCP | Outbound |
