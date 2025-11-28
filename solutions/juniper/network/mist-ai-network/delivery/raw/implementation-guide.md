---
document_title: Implementation Guide
solution_name: Juniper Mist AI Network
document_version: 1.0
version: 1.0
last_updated: "[DATE]"
author: Wireless Implementation Team
prepared_by: Wireless Implementation Team
client_name: "[CLIENT]"
classification: Client Confidential
---

# Implementation Guide
## Juniper Mist AI Network

---

# Executive Summary

This Implementation Guide provides step-by-step procedures for deploying the Juniper Mist AI Network solution, including 50 AP45 WiFi 6E access points, 4 EX4400 PoE switches, and Mist Cloud AI services. The guide covers all phases from prerequisites through production handover, ensuring a successful wireless network transformation with Marvis AI-powered management and location services.

---

# Prerequisites

This section outlines all technical and organizational prerequisites that must be in place before implementation activities can begin.

## Technical Requirements

### Network Infrastructure
- Layer 2/3 switching infrastructure operational with VLAN trunking capability
- DHCP server configured for wireless client VLANs (Corporate, Guest, IoT)
- DNS servers accessible from management and client networks
- NTP server synchronized for accurate timestamping across all components
- Internet connectivity for Mist Cloud communication (HTTPS 443)

### Authentication Infrastructure
- RADIUS server operational (FreeRADIUS, Cisco ISE, or Microsoft NPS)
- Active Directory or LDAP accessible for 802.1X authentication
- Service account created for AP RADIUS authentication
- Certificate infrastructure for EAP-TLS (if required)

### Physical Infrastructure
- Structured cabling installed to AP mounting locations (Cat6 minimum)
- PoE switches deployed with sufficient power budget (30W per AP)
- Ceiling access available for AP mounting (drop ceiling or hard mount)
- Building floor plans in PDF or CAD format for RF planning

### Mist Cloud Access
- Mist Cloud organization created with administrator account
- Mist subscription licenses activated (WiFi Assurance, Marvis VNA)
- Site created within organization with correct timezone and country code
- Floor plans uploaded with scale calibration completed

## Organizational Readiness

### Team Availability
- Wireless administrator available for configuration and testing (40 hours/week)
- Network engineer available for switch configuration and VLAN setup (20 hours/week)
- Facilities coordinator available for AP installation scheduling (10 hours/week)
- IT manager available for acceptance testing and signoff (5 hours/week)

### Approvals and Access
- Change management approval for network modifications
- Building access authorization for installation team
- Maintenance window approval for legacy AP cutover
- Security team approval for RADIUS integration

### Documentation Ready
- Current network topology diagrams
- VLAN assignment spreadsheet with IP ranges
- RADIUS server configuration details
- Existing wireless configuration (for migration reference)

---

# Environment Setup

This section covers the configuration of the Mist Cloud environment and supporting infrastructure required for the deployment.

## Mist Cloud Configuration

### Organization Setup

1. Log into Mist Cloud portal at https://manage.mist.com
2. Navigate to Organization > Settings
3. Configure organization details:
   - Organization Name: [CLIENT_NAME]
   - Country Code: [COUNTRY]
   - Timezone: [TIMEZONE]
4. Enable required services under Organization > Subscriptions:
   - WiFi Assurance (required)
   - Marvis VNA (required)
   - Location Services (optional)
   - Wired Assurance (for EX switches)

### Site Creation

1. Navigate to Organization > Site Configuration
2. Create new site with the following parameters:
   - Site Name: [BUILDING_NAME]
   - Address: [PHYSICAL_ADDRESS]
   - Country Code: [COUNTRY]
   - Timezone: [TIMEZONE]
3. Configure site settings:
   - Enable Auto Upgrade for firmware management
   - Set upgrade schedule for low-traffic hours (2:00 AM - 6:00 AM)
   - Enable Marvis for site-level AI insights

### Floor Plan Upload

1. Navigate to Location > Live View for the site
2. Upload floor plan images (PNG, JPEG, or PDF)
3. Calibrate floor plan scale:
   - Click two known points on the floor plan
   - Enter the actual distance between points
   - Verify scale accuracy with a third measurement
4. Set floor plan orientation (North alignment)
5. Repeat for each floor in the building

## Network Infrastructure

### VLAN Configuration

Configure the following VLANs on distribution switches:

| VLAN ID | Name | Purpose | IP Range | DHCP Scope |
|---------|------|---------|----------|------------|
| 100 | MGMT | AP Management | 10.10.100.0/24 | 10.10.100.50-200 |
| 200 | Corporate | Employee WiFi | 10.10.200.0/23 | 10.10.200.50-250 |
| 300 | Guest | Guest WiFi | 10.10.300.0/24 | 10.10.300.50-200 |
| 400 | IoT | IoT Devices | 10.10.400.0/24 | 10.10.400.50-200 |

### Switch Port Configuration

Configure access ports for APs on EX4400 switches:

```junos
set interfaces ge-0/0/0 description "AP45-F1-001"
set interfaces ge-0/0/0 unit 0 family ethernet-switching interface-mode trunk
set interfaces ge-0/0/0 unit 0 family ethernet-switching vlan members MGMT
set interfaces ge-0/0/0 unit 0 family ethernet-switching vlan members Corporate
set interfaces ge-0/0/0 unit 0 family ethernet-switching vlan members Guest
set interfaces ge-0/0/0 unit 0 family ethernet-switching vlan members IoT
set interfaces ge-0/0/0 native-vlan-id 100
set poe interface ge-0/0/0
```

### DNS Configuration

Create DNS records for Mist Cloud communication:
- Verify resolution of `ep-terminator.mistsys.net`
- Verify resolution of `manage.mist.com`
- Configure internal DNS for AP hostnames (optional)

---

# Infrastructure Deployment

This section covers the physical deployment of wireless infrastructure components.

## Phase 1: Networking Layer

### EX4400 Switch Deployment

Deploy 4 EX4400-48P switches in distribution closets:

1. **Physical Installation**
   - Mount switches in designated rack locations
   - Connect power cables (dual power supplies for redundancy)
   - Install optics for uplink connections
   - Label all ports according to naming convention

2. **Base Configuration**
   - Configure hostname and management IP
   - Set root password and create admin accounts
   - Configure NTP and DNS servers
   - Enable SNMP for monitoring

3. **VLAN Configuration**
   - Create VLANs for wireless networks (100, 200, 300, 400)
   - Configure trunk ports to upstream distribution
   - Set native VLAN for AP management (VLAN 100)
   - Enable spanning-tree with appropriate priority

4. **PoE Configuration**
   - Verify PoE budget (1440W available per switch)
   - Enable PoE on access ports (802.3bt for AP45)
   - Set PoE priority for critical APs if budget constrained
   - Monitor power consumption during AP deployment

### Uplink Connectivity

1. Configure 10G uplinks to core switches
2. Set LACP for link aggregation if dual-homed
3. Verify VLAN trunking on uplink ports
4. Test connectivity to DHCP, DNS, and internet

## Phase 2: Security Layer

### RADIUS Integration

Configure RADIUS server for 802.1X authentication:

1. **Create Service Account**
   - Add Mist APs as RADIUS clients
   - Configure shared secret (minimum 32 characters)
   - Set NAS-IP-Address for each AP subnet

2. **Configure Authentication Policy**
   - Enable EAP-PEAP or EAP-TLS authentication
   - Map AD groups to VLAN assignments
   - Configure MAC authentication bypass (MAB) for IoT devices

3. **Test Configuration**
   - Verify RADIUS connectivity from AP management subnet
   - Test authentication with sample user accounts
   - Validate VLAN assignment based on group membership

### Firewall Rules

Configure firewall rules for Mist Cloud communication:

| Source | Destination | Port | Protocol | Purpose |
|--------|-------------|------|----------|---------|
| AP Subnet | ep-terminator.mistsys.net | 443 | TCP | Mist Cloud |
| AP Subnet | NTP Server | 123 | UDP | Time Sync |
| AP Subnet | DNS Server | 53 | UDP/TCP | Name Resolution |
| AP Subnet | RADIUS Server | 1812-1813 | UDP | Authentication |

## Phase 3: Compute Layer

### Access Point Deployment

Deploy 50 AP45 WiFi 6E access points across 5 floors:

1. **Pre-Installation Verification**
   - Verify cable connectivity at each AP location
   - Test PoE power delivery from switch
   - Confirm mounting hardware compatibility
   - Validate AP serial numbers against inventory

2. **Physical Installation**
   - Mount AP using ceiling tile clip or wall bracket
   - Connect Ethernet cable to AP
   - Verify LED status (solid green = cloud connected)
   - Apply asset tag with AP name and location

3. **Cloud Claiming**
   - Navigate to Organization > Inventory
   - Add APs by claim code or serial number
   - Assign APs to site and floor plan location
   - Drag AP icons to correct floor plan positions

4. **Floor-by-Floor Deployment**

| Floor | AP Count | Switch | Completion Target |
|-------|----------|--------|-------------------|
| Floor 1 | 10 | IDF1-EX4400 | Day 1-2 |
| Floor 2 | 10 | IDF2-EX4400 | Day 3-4 |
| Floor 3 | 10 | IDF2-EX4400 | Day 5-6 |
| Floor 4 | 10 | IDF3-EX4400 | Day 7-8 |
| Floor 5 | 10 | IDF4-EX4400 | Day 9-10 |

## Phase 4: Monitoring Layer

### Wired Assurance Activation

Enable Wired Assurance for EX4400 switches:

1. Navigate to Organization > Wired > Switch Templates
2. Create switch template with:
   - VLAN configurations matching deployment
   - Port profiles for AP connections
   - Uplink port configurations
3. Claim switches to Mist Cloud inventory
4. Assign switches to site and apply template
5. Verify switch connectivity in Mist dashboard

### Marvis AI Configuration

1. Navigate to Organization > Marvis
2. Enable Marvis Actions for automated remediation
3. Configure alert thresholds:
   - Failed connection SLE: < 95%
   - Coverage SLE: < 90%
   - Capacity SLE: < 90%
4. Set notification preferences for critical alerts

---

# Application Configuration

This section covers the wireless network configuration and AI services enablement.

## WLAN Configuration

### SSID Creation

Create wireless networks in Mist Cloud:

**Corporate SSID (802.1X)**

1. Navigate to Site > WLANs > Add WLAN
2. Configure SSID parameters:
   - SSID Name: [CLIENT]-Corporate
   - Security: WPA2/WPA3 Enterprise
   - Authentication: 802.1X (RADIUS)
   - VLAN: 200 (Corporate)
3. Configure RADIUS servers:
   - Primary: [RADIUS_IP]:1812
   - Secondary: [RADIUS_IP_BACKUP]:1812
   - Shared Secret: [RADIUS_SECRET]
4. Advanced settings:
   - Band: 2.4 GHz + 5 GHz + 6 GHz
   - Client inactivity timeout: 300 seconds
   - Enable 802.11r (Fast Transition)
   - Enable 802.11k (Radio Resource Management)

**Guest SSID (Captive Portal)**

1. Navigate to Site > WLANs > Add WLAN
2. Configure SSID parameters:
   - SSID Name: [CLIENT]-Guest
   - Security: Open with captive portal
   - Authentication: Web portal with terms acceptance
   - VLAN: 300 (Guest)
3. Configure guest portal:
   - Portal type: Terms of Service
   - Session duration: 8 hours
   - Bandwidth limit: 10 Mbps down / 5 Mbps up
4. Advanced settings:
   - Band: 2.4 GHz + 5 GHz
   - Client isolation: Enabled
   - Block LAN access: Enabled

**IoT SSID (PSK)**

1. Navigate to Site > WLANs > Add WLAN
2. Configure SSID parameters:
   - SSID Name: [CLIENT]-IoT
   - Security: WPA2 PSK
   - Passphrase: [IoT_PSK]
   - VLAN: 400 (IoT)
3. Advanced settings:
   - Band: 2.4 GHz only
   - Hidden SSID: Optional
   - MAC filtering: Optional

## RF Policy Configuration

### Radio Settings

1. Navigate to Site > Radio Management
2. Configure 2.4 GHz settings:
   - Channel width: 20 MHz
   - Allowed channels: 1, 6, 11
   - Power range: 8-18 dBm
   - Enable auto channel and power

3. Configure 5 GHz settings:
   - Channel width: 40/80 MHz
   - Allowed channels: UNII-1 and UNII-3
   - Power range: 10-23 dBm
   - Enable DFS channels

4. Configure 6 GHz settings:
   - Channel width: 80/160 MHz
   - Power range: 12-24 dBm
   - PSC (Preferred Scanning Channel) enabled

## AI Services Enablement

### Marvis Virtual Network Assistant

1. Navigate to Organization > Marvis
2. Enable Marvis AI for the site
3. Configure conversational queries:
   - Access Marvis from dashboard search bar
   - Test query: "Why is WiFi slow in Floor 2?"
   - Test query: "Which clients failed to connect today?"

### Service Level Expectations (SLEs)

1. Navigate to Site > SLE
2. Configure SLE targets:
   - Successful Connect: 99%
   - Coverage: 95%
   - Capacity: 95%
   - Roaming: 95%
   - Throughput: 95%
3. Set baseline period: 7 days
4. Enable SLE alerts for threshold violations

### Location Services (vBLE)

1. Navigate to Site > Location > Live View
2. Enable vBLE location services
3. Configure location settings:
   - SDK token generation for mobile apps
   - Accuracy target: 3-5 meters
   - Wayfinding destination points
4. Create wayfinding maps:
   - Mark key destinations (entrances, elevators, conference rooms)
   - Generate wayfinding links for QR codes

---

# Integration Testing

This section covers the testing procedures to validate the deployment meets requirements.

## RF Validation Testing

### Coverage Verification

1. Perform walk test with survey tool (Ekahau or AirMagnet)
2. Verify signal strength meets minimum thresholds:
   - Primary coverage: > -67 dBm
   - Secondary coverage: > -72 dBm
3. Check for coverage gaps or dead zones
4. Verify appropriate AP overlap for roaming (15-20%)

### Interference Analysis

1. Review spectrum analysis in Mist dashboard
2. Identify and document interference sources
3. Adjust channel assignments if needed
4. Verify DFS channel utilization (if applicable)

## Connectivity Testing

### Client Connectivity

Test connectivity with representative devices:

| Device Type | Corporate SSID | Guest SSID | IoT SSID |
|-------------|----------------|------------|----------|
| Windows Laptop | ✓ | ✓ | N/A |
| MacBook | ✓ | ✓ | N/A |
| iPhone | ✓ | ✓ | N/A |
| Android Phone | ✓ | ✓ | N/A |
| IoT Sensor | N/A | N/A | ✓ |

### Roaming Performance

1. Configure test client for roaming validation
2. Walk predetermined path across AP boundaries
3. Monitor roaming events in Mist dashboard
4. Verify handoff time < 150ms for voice/video
5. Validate 802.11r fast transition (if enabled)

### Throughput Testing

1. Connect test client to Corporate SSID
2. Run iPerf3 throughput test:
   - Single stream: > 500 Mbps (5 GHz)
   - Multi-stream: > 1 Gbps (5 GHz)
   - 6 GHz: > 1.5 Gbps
3. Test video conferencing quality (Webex, Teams, Zoom)
4. Verify QoS prioritization for voice/video traffic

## Integration Validation

### RADIUS Authentication

1. Test user authentication with valid credentials
2. Verify VLAN assignment based on group membership
3. Test authentication failure with invalid credentials
4. Validate certificate-based authentication (if using EAP-TLS)

### Location Services

1. Test indoor positioning accuracy
2. Verify wayfinding directions to key destinations
3. Validate location updates in mobile app
4. Test asset tracking (if applicable)

---

# Security Validation

This section covers security testing and validation procedures to ensure the wireless network meets security requirements.

## Authentication Security

### 802.1X Validation

1. Test user authentication with valid AD credentials
2. Verify authentication fails with invalid credentials
3. Test certificate-based authentication (EAP-TLS)
4. Validate session timeout and re-authentication

### Guest Portal Security

1. Verify captive portal SSL certificate validity
2. Test terms of service enforcement
3. Validate session duration limits
4. Confirm bandwidth restrictions are applied

## Network Segmentation

### VLAN Isolation Testing

1. Verify Corporate clients cannot reach Guest network
2. Verify Guest clients cannot reach internal resources
3. Verify IoT devices are isolated from user networks
4. Test firewall rules between wireless VLANs

### Access Control Validation

1. Validate RBAC permissions in Mist dashboard
2. Test admin account access restrictions
3. Verify audit logging captures all admin actions
4. Confirm API token permissions are appropriate

---

# Migration & Cutover

This section outlines the migration strategy and cutover procedures for transitioning from legacy wireless to Mist AI Network.

## Pre-Cutover Preparation

### Readiness Checklist

1. All 50 AP45 access points operational and cloud-connected
2. All SSIDs tested with client connectivity validated
3. 802.1X authentication verified for Corporate SSID
4. Guest portal functional with terms acceptance
5. RF coverage validated across all floors
6. SLE baselines established and meeting targets
7. Marvis AI operational with insights available
8. Administrator training completed

### Communication Plan

1. Notify IT staff of cutover schedule
2. Send user communication about WiFi changes
3. Update helpdesk with new SSID information
4. Prepare rollback procedures and contacts

## Cutover Execution

### Cutover Steps

1. **T-1 Hour:** Final RF validation and SLE check
2. **T-0:** Begin legacy AP shutdown (floor by floor)
3. **T+15 min:** Monitor client connections to new infrastructure
4. **T+30 min:** Verify SLE metrics remain stable
5. **T+1 Hour:** Complete legacy AP shutdown
6. **T+2 Hours:** Validate all areas with walk test
7. **T+4 Hours:** Declare cutover complete or initiate rollback

### Rollback Procedures

If critical issues occur during cutover:

1. Power on legacy APs for affected floors
2. Notify users to reconnect to legacy SSIDs
3. Document issues for root cause analysis
4. Schedule remediation before next cutover attempt

## Post-Cutover Validation

### Day 1 Activities

1. Monitor SLE dashboard for anomalies
2. Review Marvis alerts and insights
3. Respond to helpdesk tickets promptly
4. Document any configuration adjustments

### Week 1 Activities

1. Daily SLE health check reviews
2. Client experience surveys
3. Performance optimization as needed
4. Legacy AP decommissioning

---

# Operational Handover

This section covers the transition to operations and ongoing support procedures.

## Documentation Delivery

### As-Built Documentation

Deliver the following documentation:

1. **RF Coverage Maps**
   - Heat maps for each floor (2.4 GHz, 5 GHz, 6 GHz)
   - AP placement diagrams with serial numbers
   - Channel and power assignments

2. **Configuration Documentation**
   - WLAN configuration summary
   - RADIUS integration details
   - RF policy settings
   - Security configurations

3. **Network Diagrams**
   - Logical topology with VLANs
   - Physical connectivity diagrams
   - IP addressing scheme

### Operations Runbook

Deliver runbook covering:

1. **Daily Operations**
   - Dashboard health check procedures
   - SLE monitoring guidelines
   - Client troubleshooting using Marvis

2. **Common Tasks**
   - Adding new SSIDs
   - Modifying RF policies
   - Creating guest portals
   - Claiming new APs

3. **Troubleshooting Procedures**
   - Client connectivity issues
   - RF interference resolution
   - Performance degradation

## Support Transition

### Warranty Period

- 30-day warranty from production handoff
- Daily SLE health check reviews
- 4-hour response for critical issues
- Configuration assistance and optimization

### Steady-State Support

- Juniper JTAC 24x7 support
- 4-hour hardware replacement
- Mist Cloud subscription support
- Monthly SLE trend reviews

### Escalation Contacts

| Level | Contact | Response Time |
|-------|---------|---------------|
| L1 | Client NOC | 15 minutes |
| L2 | Client Network Team | 1 hour |
| L3 | Juniper JTAC | 4 hours (24x7) |
| Account Manager | am@consulting.com | Next business day |
| Emergency | 1-888-314-JTAC | Immediate |

---

# Training Program

This section covers the knowledge transfer and training activities.

## Administrator Training

### Mist Dashboard Training (4 hours)

Topics covered:
- Dashboard navigation and layout
- Site and floor plan management
- AP monitoring and health status
- WLAN configuration and management
- RF policy configuration
- Client troubleshooting workflows

### Marvis AI Training (2 hours)

Topics covered:
- Conversational query interface
- Natural language troubleshooting
- Automated root cause analysis
- Marvis Actions for remediation
- SLE interpretation and optimization

### Location Services Training (2 hours)

Topics covered:
- vBLE configuration and calibration
- Wayfinding map management
- Asset tracking setup
- Location analytics review
- Mobile app integration

## Training Schedule

The following table outlines the training schedule for all sessions during the handover phase:

| Session | Duration | Participants | Date |
|---------|----------|--------------|------|
| Mist Dashboard | 4 hours | Network Team | Week 8 |
| Marvis AI | 2 hours | Network Team | Week 8 |
| Location Services | 2 hours | Facilities Team | Week 8 |
| Helpdesk Overview | 1 hour | Helpdesk Staff | Week 8 |

All training sessions will be recorded for future reference.

---

# Appendices

## Appendix A: AP Naming Convention

Format: `AP-[FLOOR]-[SEQUENCE]`

Examples:
- AP-F1-001 (Floor 1, AP #1)
- AP-F2-015 (Floor 2, AP #15)
- AP-F5-050 (Floor 5, AP #50)

## Appendix B: VLAN Reference

The following table provides the VLAN configuration reference for the Mist AI Network deployment:

| VLAN ID | Name | Subnet | Gateway | DHCP Range |
|---------|------|--------|---------|------------|
| 100 | MGMT | 10.10.100.0/24 | 10.10.100.1 | .50-.200 |
| 200 | Corporate | 10.10.200.0/23 | 10.10.200.1 | .50-.250 |
| 300 | Guest | 10.10.300.0/24 | 10.10.300.1 | .50-.200 |
| 400 | IoT | 10.10.400.0/24 | 10.10.400.1 | .50-.200 |

## Appendix C: Mist Cloud URLs

The following URLs are required for Mist Cloud connectivity and management:

| URL | Purpose |
|-----|---------|
| https://manage.mist.com | Mist Cloud Management |
| https://ep-terminator.mistsys.net | AP Cloud Connectivity |
| https://api.mist.com | API Access |

## Appendix D: Troubleshooting Commands

### Verify AP Cloud Connectivity
```bash
# From Mist dashboard: Monitor > Access Points > [AP] > Utilities > Ping
ping ep-terminator.mistsys.net
```

### Check Client Authentication Logs
```
Marvis query: "Show failed authentications in the last hour"
```

### RF Channel Utilization
```
Navigate to: Site > Radio Management > Channel Utilization
```
