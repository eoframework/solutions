# Juniper SRX Firewall Platform Configuration Templates

## Overview

This document provides comprehensive configuration templates for Juniper SRX Firewall Platform deployment. Templates are organized by functional area and include security policies, network configurations, and advanced security services setup.

---

## Basic System Configuration

### Initial System Setup
```bash
# Hostname and Domain Configuration
set system host-name srx-firewall-01
set system domain-name company.local
set system time-zone America/New_York

# Root Authentication
set system root-authentication encrypted-password "$6$encrypted_password_hash"

# Management Interface Configuration
set interfaces fxp0 unit 0 family inet address 192.168.100.10/24
set routing-options static route 0.0.0.0/0 next-hop 192.168.100.1

# DNS Configuration
set system name-server 8.8.8.8
set system name-server 8.8.4.4

# NTP Configuration
set system ntp server 0.pool.ntp.org
set system ntp server 1.pool.ntp.org
```

### User Management
```bash
# Local User Accounts
set system login user admin uid 2000
set system login user admin class super-user
set system login user admin authentication encrypted-password "$6$admin_password_hash"

set system login user security-analyst uid 2001
set system login user security-analyst class security-analyst
set system login user security-analyst authentication encrypted-password "$6$analyst_password_hash"

# Custom Login Classes
set system login class security-analyst permissions [ clear network reset trace view ]
set system login class security-analyst allow-commands "show security"
set system login class security-analyst deny-commands "request system"
```

---

## Network Interface Configuration

### Physical Interface Setup
```bash
# Trust Zone Interface (Internal Network)
set interfaces ge-0/0/1 unit 0 family inet address 10.0.1.1/24
set interfaces ge-0/0/1 unit 0 family inet address 10.0.1.1/24 preferred

# Untrust Zone Interface (External Network)
set interfaces ge-0/0/0 unit 0 family inet dhcp-client

# DMZ Interface
set interfaces ge-0/0/2 unit 0 family inet address 192.168.10.1/24

# Management Interface (Out-of-Band)
set interfaces ge-0/0/3 unit 0 family inet address 192.168.100.10/24
```

### VLAN Configuration
```bash
# VLAN Interface Configuration
set interfaces ge-0/0/1 vlan-tagging
set interfaces ge-0/0/1 unit 100 vlan-id 100
set interfaces ge-0/0/1 unit 100 family inet address 10.1.100.1/24
set interfaces ge-0/0/1 unit 200 vlan-id 200
set interfaces ge-0/0/1 unit 200 family inet address 10.1.200.1/24

# VLAN Descriptions
set interfaces ge-0/0/1 unit 100 description "User Network VLAN"
set interfaces ge-0/0/1 unit 200 description "Server Network VLAN"
```

### High Availability Interface Configuration
```bash
# Chassis Cluster Interfaces
set interfaces fab0 fabric-options member-interfaces ge-0/0/5
set interfaces fab1 fabric-options member-interfaces ge-0/0/6

# Redundant Ethernet Interfaces
set interfaces reth0 description "Trust Zone Redundant Interface"
set interfaces reth0 redundant-ether-options redundancy-group 1
set interfaces reth0 unit 0 family inet address 10.0.1.1/24

set interfaces reth1 description "Untrust Zone Redundant Interface"
set interfaces reth1 redundant-ether-options redundancy-group 1
set interfaces reth1 unit 0 family inet dhcp-client

# Member Interface Assignment
set chassis cluster reth-count 2
set interfaces ge-0/0/1 ether-options redundant-parent reth0
set interfaces ge-1/0/1 ether-options redundant-parent reth0
set interfaces ge-0/0/0 ether-options redundant-parent reth1
set interfaces ge-1/0/0 ether-options redundant-parent reth1
```

---

## Security Zone Configuration

### Basic Security Zones
```bash
# Trust Zone Configuration
set security zones security-zone trust tcp-rst
set security zones security-zone trust host-inbound-traffic system-services all
set security zones security-zone trust host-inbound-traffic protocols all
set security zones security-zone trust interfaces ge-0/0/1.0

# Untrust Zone Configuration
set security zones security-zone untrust screen untrust-screen
set security zones security-zone untrust interfaces ge-0/0/0.0 host-inbound-traffic system-services dhcp

# DMZ Zone Configuration
set security zones security-zone dmz tcp-rst
set security zones security-zone dmz host-inbound-traffic system-services ping
set security zones security-zone dmz host-inbound-traffic system-services ssh
set security zones security-zone dmz interfaces ge-0/0/2.0
```

### Advanced Zone Configuration
```bash
# Management Zone
set security zones security-zone management host-inbound-traffic system-services all
set security zones security-zone management host-inbound-traffic protocols all
set security zones security-zone management interfaces ge-0/0/3.0

# Functional Zones
set security zones functional-zone management interfaces ge-0/0/3.0
```

### Screen Configuration
```bash
# Screen Options for Untrust Zone
set security screen ids-option untrust-screen icmp ping-death
set security screen ids-option untrust-screen icmp fragment
set security screen ids-option untrust-screen ip source-route-option
set security screen ids-option untrust-screen ip tear-drop
set security screen ids-option untrust-screen tcp syn-flood alarm-threshold 1024
set security screen ids-option untrust-screen tcp syn-flood attack-threshold 200
set security screen ids-option untrust-screen tcp syn-flood source-threshold 1024
set security screen ids-option untrust-screen tcp syn-flood destination-threshold 2048
set security screen ids-option untrust-screen tcp syn-flood timeout 20
set security screen ids-option untrust-screen tcp land
```

---

## Security Policy Templates

### Basic Security Policies
```bash
# Internet Access Policy
set security policies from-zone trust to-zone untrust policy internet-access
set security policies from-zone trust to-zone untrust policy internet-access match source-address any
set security policies from-zone trust to-zone untrust policy internet-access match destination-address any
set security policies from-zone trust to-zone untrust policy internet-access match application any
set security policies from-zone trust to-zone untrust policy internet-access then permit
set security policies from-zone trust to-zone untrust policy internet-access then log session-init
set security policies from-zone trust to-zone untrust policy internet-access then log session-close

# DMZ Web Server Access
set security policies from-zone untrust to-zone dmz policy web-server-access
set security policies from-zone untrust to-zone dmz policy web-server-access match source-address any
set security policies from-zone untrust to-zone dmz policy web-server-access match destination-address web-servers
set security policies from-zone untrust to-zone dmz policy web-server-access match application [ junos-http junos-https ]
set security policies from-zone untrust to-zone dmz policy web-server-access then permit
set security policies from-zone untrust to-zone dmz policy web-server-access then log session-init
```

### Application-Based Policies
```bash
# Social Media Blocking Policy
set security policies from-zone trust to-zone untrust policy block-social-media
set security policies from-zone trust to-zone untrust policy block-social-media match source-address internal-users
set security policies from-zone trust to-zone untrust policy block-social-media match destination-address any
set security policies from-zone trust to-zone untrust policy block-social-media match application [ junos-facebook junos-twitter ]
set security policies from-zone trust to-zone untrust policy block-social-media then deny
set security policies from-zone trust to-zone untrust policy block-social-media then log session-init

# Business Application Allow Policy
set security policies from-zone trust to-zone untrust policy business-apps
set security policies from-zone trust to-zone untrust policy business-apps match source-address internal-users
set security policies from-zone trust to-zone untrust policy business-apps match destination-address any
set security policies from-zone trust to-zone untrust policy business-apps match application [ junos-office365 junos-salesforce ]
set security policies from-zone trust to-zone untrust policy business-apps then permit
```

### Advanced Security Policies
```bash
# Time-Based Access Control
set security policies from-zone trust to-zone untrust policy time-restricted-access
set security policies from-zone trust to-zone untrust policy time-restricted-access match source-address guest-users
set security policies from-zone trust to-zone untrust policy time-restricted-access match destination-address any
set security policies from-zone trust to-zone untrust policy time-restricted-access match application any
set security policies from-zone trust to-zone untrust policy time-restricted-access then permit
set security policies from-zone trust to-zone untrust policy time-restricted-access then count

# Scheduler Configuration
set schedulers scheduler business-hours daily start-time 08:00:00 stop-time 18:00:00
set schedulers scheduler business-hours monday
set schedulers scheduler business-hours tuesday
set schedulers scheduler business-hours wednesday
set schedulers scheduler business-hours thursday
set schedulers scheduler business-hours friday
```

---

## Address and Service Objects

### Address Book Configuration
```bash
# Trust Zone Address Book
set security zones security-zone trust address-book address internal-network 10.0.0.0/8
set security zones security-zone trust address-book address internal-servers 10.0.1.0/24
set security zones security-zone trust address-book address user-network 10.0.2.0/24
set security zones security-zone trust address-book address admin-network 10.0.10.0/24

# Address Sets
set security zones security-zone trust address-book address-set internal-users address internal-network
set security zones security-zone trust address-book address-set internal-users address user-network
set security zones security-zone trust address-book address-set critical-servers address internal-servers
set security zones security-zone trust address-book address-set critical-servers address admin-network

# DMZ Zone Address Book
set security zones security-zone dmz address-book address web-server-1 192.168.10.10/32
set security zones security-zone dmz address-book address web-server-2 192.168.10.11/32
set security zones security-zone dmz address-book address mail-server 192.168.10.20/32

set security zones security-zone dmz address-book address-set web-servers address web-server-1
set security zones security-zone dmz address-book address-set web-servers address web-server-2
set security zones security-zone dmz address-book address-set email-servers address mail-server
```

### Custom Application Definition
```bash
# Custom Applications
set applications application mysql-custom protocol tcp destination-port 3306
set applications application oracle-db protocol tcp destination-port 1521
set applications application custom-app-1 protocol tcp destination-port 8080-8090

# Application Sets
set applications application-set database-apps application mysql-custom
set applications application-set database-apps application oracle-db
set applications application-set database-apps application junos-ms-sql

set applications application-set web-apps application junos-http
set applications application-set web-apps application junos-https
set applications application-set web-apps application custom-app-1
```

---

## NAT Configuration Templates

### Source NAT Configuration
```bash
# Interface-based Source NAT
set security nat source rule-set trust-to-untrust from zone trust
set security nat source rule-set trust-to-untrust to zone untrust
set security nat source rule-set trust-to-untrust rule trust-nat-rule match source-address 10.0.0.0/8
set security nat source rule-set trust-to-untrust rule trust-nat-rule then source-nat interface

# Pool-based Source NAT
set security nat source pool nat-pool-1 address 203.0.113.10/32 to 203.0.113.20/32
set security nat source rule-set trust-to-untrust rule pool-nat-rule match source-address 10.0.1.0/24
set security nat source rule-set trust-to-untrust rule pool-nat-rule then source-nat pool nat-pool-1
```

### Destination NAT Configuration
```bash
# Static Destination NAT for Web Server
set security nat destination pool web-server-pool address 192.168.10.10/32
set security nat destination rule-set untrust-inbound from zone untrust
set security nat destination rule-set untrust-inbound rule web-server-dnat match destination-address 203.0.113.100/32
set security nat destination rule-set untrust-inbound rule web-server-dnat match destination-port 80
set security nat destination rule-set untrust-inbound rule web-server-dnat then destination-nat pool web-server-pool

# Port Translation
set security nat destination pool mail-server-pool address 192.168.10.20/32 port 25
set security nat destination rule-set untrust-inbound rule mail-server-dnat match destination-address 203.0.113.100/32
set security nat destination rule-set untrust-inbound rule mail-server-dnat match destination-port 587
set security nat destination rule-set untrust-inbound rule mail-server-dnat then destination-nat pool mail-server-pool
```

---

## VPN Configuration Templates

### IPsec Site-to-Site VPN
```bash
# IKE Policy Configuration
set security ike policy ike-pol-1 mode main
set security ike policy ike-pol-1 proposal-set standard
set security ike policy ike-pol-1 pre-shared-key ascii-text "shared-secret-key"

# IKE Gateway Configuration
set security ike gateway branch-office-gw ike-policy ike-pol-1
set security ike gateway branch-office-gw address 203.0.113.200
set security ike gateway branch-office-gw external-interface ge-0/0/0.0
set security ike gateway branch-office-gw version v2-only

# IPsec Policy Configuration
set security ipsec policy ipsec-pol-1 perfect-forward-secrecy keys group14
set security ipsec policy ipsec-pol-1 proposal-set standard

# IPsec VPN Configuration
set security ipsec vpn branch-office-vpn bind-interface st0.0
set security ipsec vpn branch-office-vpn ike gateway branch-office-gw
set security ipsec vpn branch-office-vpn ike ipsec-policy ipsec-pol-1
```

### SSL VPN Configuration
```bash
# SSL VPN Profile
set security ssl-vpn profile ssl-vpn-profile authentication-server internal
set security ssl-vpn profile ssl-vpn-profile web-session idle-timeout 30
set security ssl-vpn profile ssl-vpn-profile web-session session-timeout 480

# SSL VPN Resource Policy
set security ssl-vpn resource-profile internal-resources web-bookmark internal-portal url https://internal.company.com
set security ssl-vpn resource-profile internal-resources web-bookmark internal-portal description "Internal Company Portal"
set security ssl-vpn resource-profile internal-resources application file-server host 10.0.1.100 path /shared
```

---

## Advanced Security Services

### Intrusion Detection and Prevention (IDP)
```bash
# IDP Policy Configuration
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical match attacks predefined-attacks "Critical"
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical then action drop-packet
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical then notification log-attacks

set security idp idp-policy comprehensive-protection rulebase-ips rule log-high
set security idp idp-policy comprehensive-protection rulebase-ips rule log-high match attacks predefined-attacks "High"
set security idp idp-policy comprehensive-protection rulebase-ips rule log-high then action no-action
set security idp idp-policy comprehensive-protection rulebase-ips rule log-high then notification log-attacks

# Custom Attack Signatures
set security idp custom-attack sql-injection attack-type signature
set security idp custom-attack sql-injection protocol tcp
set security idp custom-attack sql-injection protocol-binding application http
set security idp custom-attack sql-injection signature ".*union.*select.*from.*"
set security idp custom-attack sql-injection signature context http-url-decoded-header
```

### Application Security (AppSecure)
```bash
# Application Identification
set security application-identification application facebook signature signature-1 protocol tcp
set security application-identification application facebook signature signature-1 port-range 80,443
set security application-identification application facebook signature signature-1 pattern "facebook"

# Application Firewall Rules
set security application-firewall rule-sets web-protection rule block-social-media match dynamic-application facebook
set security application-firewall rule-sets web-protection rule block-social-media then deny
set security application-firewall rule-sets web-protection rule block-social-media then log

# Web Filtering Configuration
set security utm web-filtering profile web-filter-profile category Social-Networking action deny
set security utm web-filtering profile web-filter-profile category Gambling action deny
set security utm web-filtering profile web-filter-profile default-action permit
```

---

## Monitoring and Logging Configuration

### System Logging
```bash
# Local Logging Configuration
set system syslog user * any emergency
set system syslog host 10.0.1.50 any info
set system syslog host 10.0.1.50 authorization info
set system syslog host 10.0.1.50 interactive-commands info
set system syslog host 10.0.1.50 structured-data

# Security Event Logging
set security log mode stream
set security log format sd-syslog
set security log source-address 10.0.1.1
set security log stream security-events host 10.0.1.50
set security log stream security-events port 514
set security log stream security-events severity info
```

### SNMP Configuration
```bash
# SNMP Community Configuration
set snmp community public authorization read-only
set snmp community private authorization read-write

# SNMP System Information
set snmp system-name srx-firewall-01
set snmp location "Data Center Rack A1"
set snmp contact "Network Security Team <security@company.com>"

# SNMP Trap Configuration
set snmp trap-options source-address 10.0.1.1
set snmp trap-group security-traps version v2
set snmp trap-group security-traps targets 10.0.1.60
set snmp trap-group security-traps categories security
```

---

## Performance Optimization

### Flow and Session Configuration
```bash
# TCP Session Optimization
set security flow tcp-session time-wait 10
set security flow tcp-session fin-wait 5
set security flow tcp-session close-wait 5
set security flow tcp-session syn-flood-protection-mode syn-cookie

# Flow Processing Optimization
set security flow advanced-options drop-matching-reserved-ip-address
set security flow advanced-options drop-matching-link-local-address
set security flow advanced-options reverse-route-packet-mode loose

# Session Table Optimization
set security flow session-table maximum-sessions 500000
set security flow session-table tcp-session maximum-sessions 400000
set security flow session-table udp-session maximum-sessions 100000
```

### Hardware Optimization
```bash
# Security Processing Unit (SPU) Configuration
set security forwarding-options family inet6 mode flow-based
set security forwarding-options family mpls mode packet-based

# Interface Optimization
set interfaces ge-0/0/1 fastether-options auto-negotiation
set interfaces ge-0/0/1 gigether-options loopback
set chassis pic fpc-slot 0 pic-slot 0 adaptive-services service-package layer-3
```

---

## Chassis Cluster Configuration

### Basic Cluster Setup
```bash
# Cluster Configuration (Node 0)
set chassis cluster cluster-id 1
set chassis cluster node 0 priority 100

# Redundancy Groups
set chassis cluster redundancy-group 0 node 0 priority 100
set chassis cluster redundancy-group 0 node 1 priority 50
set chassis cluster redundancy-group 1 node 0 priority 100
set chassis cluster redundancy-group 1 node 1 priority 50

# Control and Fabric Links
set chassis cluster control-ports fpc 0 port 0
set chassis cluster control-ports fpc 0 port 1
set chassis cluster fab0 member-interfaces ge-0/0/5
set chassis cluster fab1 member-interfaces ge-0/0/6
```

### Advanced Cluster Features
```bash
# Heartbeat Configuration
set chassis cluster heartbeat-interval 1000
set chassis cluster heartbeat-threshold 3

# Cluster Status Monitoring
set chassis cluster redundancy-group 0 gratuitous-arp-count 4
set chassis cluster redundancy-group 1 preempt delay 60
set chassis cluster redundancy-group 1 gratuitous-arp-count 4

# Manual Failover Commands (Operational)
# request chassis cluster failover redundancy-group 0 node 0
# request chassis cluster failover redundancy-group 1 node 0
```

---

## Template Usage Guidelines

### Configuration Validation
```bash
# Pre-commit Validation
commit check

# Configuration Comparison
show | compare rollback 1

# Configuration Rollback
rollback 1
commit
```

### Best Practices
1. **Always backup configurations** before making changes
2. **Use commit confirmed** for remote configurations
3. **Test policies** in a lab environment first
4. **Document all customizations** for future reference
5. **Regular configuration audits** to ensure compliance

### Template Customization
- Replace placeholder IP addresses with actual network addresses
- Modify zone names to match organizational requirements
- Adjust security policies based on business requirements
- Update logging destinations to match SIEM integration
- Configure authentication systems based on directory services

This configuration template library provides foundational configurations for comprehensive Juniper SRX deployment across various enterprise scenarios.