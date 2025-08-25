# Juniper SRX Firewall Platform Training Materials

## Overview

This comprehensive training guide provides structured learning materials for security professionals implementing and managing Juniper SRX Firewall Platform. Training covers fundamental concepts through advanced security operations, including hands-on exercises and real-world scenarios.

---

## Module 1: SRX Fundamentals

### Learning Objectives
- Understand SRX platform architecture and capabilities
- Master Junos OS navigation and basic configuration
- Configure zones, interfaces, and basic security policies

### 1.1 SRX Platform Architecture

**Hardware Platform Overview**
```yaml
SRX Series Comparison:
  SRX300 Series:
    - Target: Branch offices and small business
    - Throughput: 1-5 Gbps
    - Sessions: 64K-512K concurrent
    - Use Cases: Remote office connectivity, basic security
    
  SRX1500 Series:
    - Target: Medium enterprise, campus
    - Throughput: 10-20 Gbps
    - Sessions: 2M concurrent
    - Use Cases: Campus security, distributed enterprise
    
  SRX4000 Series:
    - Target: Data center, large enterprise
    - Throughput: 40-100 Gbps
    - Sessions: 16M concurrent
    - Use Cases: Data center security, high-performance requirements
    
  SRX5000 Series:
    - Target: Service provider, carrier
    - Throughput: 100-200+ Gbps
    - Sessions: 50M+ concurrent
    - Use Cases: Carrier-grade security, massive scale deployment
```

**Junos OS Architecture**
```
┌─────────────────────────────────┐
│         Management Plane        │
├─────────────────────────────────┤
│         Control Plane           │
│  ┌─────────────┬──────────────┐ │
│  │  Routing    │   Security   │ │
│  │  Engine     │   Services   │ │
│  └─────────────┴──────────────┘ │
├─────────────────────────────────┤
│         Data Plane              │
│  ┌─────────────────────────────┐ │
│  │    Packet Forwarding        │ │
│  │         Engine              │ │
│  └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### 1.2 Initial Device Access and Navigation

**First-Time Login Process**
```bash
# Console connection (default credentials)
login: root
password: [no password initially]

# Set root password
root% cli
root> configure
[edit]
root# set system root-authentication plain-text-password
New password: [enter secure password]
Retype new password: [confirm password]
[edit]
root# commit
```

**Junos CLI Basics**
```bash
# CLI modes
user@srx> show version                    # Operational mode
user@srx> configure                       # Enter configuration mode
[edit]
user@srx# show interfaces                 # Configuration mode
[edit]
user@srx# exit                           # Return to operational mode

# Navigation shortcuts
user@srx> show ?                         # Available commands
user@srx> show interfaces | match "up"   # Filter output
user@srx> show configuration | display set | match interface
```

**Configuration Management**
```bash
# Configuration states
show | compare                           # Compare current with committed
commit                                   # Commit changes
commit check                            # Validate without committing
commit confirmed 10                     # Auto-rollback in 10 minutes
rollback 1                              # Rollback to previous config

# Configuration saving
show configuration | display set > /var/tmp/config-backup.txt
save /var/tmp/current-config.conf
```

### 1.3 Security Zones and Interfaces

**Zone Concept and Implementation**
```bash
# Basic zone configuration
set security zones security-zone trust
set security zones security-zone trust tcp-rst
set security zones security-zone trust host-inbound-traffic system-services all
set security zones security-zone trust host-inbound-traffic protocols all

set security zones security-zone untrust
set security zones security-zone untrust screen untrust-screen

set security zones security-zone dmz
set security zones security-zone dmz tcp-rst
set security zones security-zone dmz host-inbound-traffic system-services ping
```

**Interface Assignment to Zones**
```bash
# Interface configuration
set interfaces ge-0/0/0 unit 0 family inet dhcp-client
set interfaces ge-0/0/1 unit 0 family inet address 192.168.1.1/24
set interfaces ge-0/0/2 unit 0 family inet address 192.168.10.1/24

# Zone assignments
set security zones security-zone untrust interfaces ge-0/0/0.0
set security zones security-zone trust interfaces ge-0/0/1.0
set security zones security-zone dmz interfaces ge-0/0/2.0
```

### Lab Exercise 1: Basic SRX Setup

**Objective**: Configure a basic three-zone SRX setup with internet connectivity.

**Lab Topology**:
```
Internet ── [ge-0/0/0] SRX [ge-0/0/1] ── Internal LAN (192.168.1.0/24)
                       │
                   [ge-0/0/2]
                       │
                   DMZ Network (192.168.10.0/24)
```

**Step-by-Step Configuration**:
```bash
# Step 1: Basic system configuration
configure
set system host-name srx-lab-01
set system domain-name lab.local
set system time-zone America/New_York

# Step 2: Interface configuration
set interfaces ge-0/0/0 unit 0 family inet dhcp-client
set interfaces ge-0/0/1 unit 0 family inet address 192.168.1.1/24
set interfaces ge-0/0/2 unit 0 family inet address 192.168.10.1/24

# Step 3: Security zone configuration
set security zones security-zone untrust interfaces ge-0/0/0.0
set security zones security-zone trust interfaces ge-0/0/1.0
set security zones security-zone dmz interfaces ge-0/0/2.0

# Step 4: Basic security policies
set security policies from-zone trust to-zone untrust policy allow-internet
set security policies from-zone trust to-zone untrust policy allow-internet match source-address any
set security policies from-zone trust to-zone untrust policy allow-internet match destination-address any
set security policies from-zone trust to-zone untrust policy allow-internet match application any
set security policies from-zone trust to-zone untrust policy allow-internet then permit

# Step 5: NAT configuration
set security nat source rule-set trust-nat from zone trust
set security nat source rule-set trust-nat to zone untrust
set security nat source rule-set trust-nat rule nat-rule match source-address 0.0.0.0/0
set security nat source rule-set trust-nat rule nat-rule then source-nat interface

# Step 6: Commit and verify
commit
exit
show interfaces terse
show security zones
ping 8.8.8.8 source 192.168.1.1
```

---

## Module 2: Security Policy Management

### Learning Objectives
- Design effective security policy frameworks
- Implement application-based security policies
- Configure address books and service objects
- Troubleshoot policy-related issues

### 2.1 Security Policy Architecture

**Policy Processing Flow**
```
Incoming Packet → Zone Identification → Address Lookup → 
Application Identification → Policy Match → Action (Permit/Deny) → 
Logging → Session Creation → Packet Forwarding
```

**Policy Components**
```bash
# Policy structure
set security policies from-zone <source> to-zone <destination> policy <name>
set security policies from-zone <source> to-zone <destination> policy <name> match source-address <address>
set security policies from-zone <source> to-zone <destination> policy <name> match destination-address <address>
set security policies from-zone <source> to-zone <destination> policy <name> match application <application>
set security policies from-zone <source> to-zone <destination> policy <name> then <action>
```

### 2.2 Address Book Management

**Address Object Creation**
```bash
# Individual addresses
set security zones security-zone trust address-book address web-server-1 192.168.10.10/32
set security zones security-zone trust address-book address mail-server 192.168.10.20/32
set security zones security-zone trust address-book address user-network 192.168.1.0/24

# Address ranges
set security zones security-zone trust address-book address server-range range-address 192.168.10.10
set security zones security-zone trust address-book address server-range range-address 192.168.10.50

# Address sets (groups)
set security zones security-zone trust address-book address-set critical-servers address web-server-1
set security zones security-zone trust address-book address-set critical-servers address mail-server
```

### 2.3 Application Identification and Control

**Built-in Applications**
```bash
# View available applications
show services application-identification application-system-cache

# Common applications
junos-http          # HTTP traffic
junos-https         # HTTPS traffic
junos-ssh           # SSH traffic
junos-ftp           # FTP traffic
junos-dns-udp       # DNS over UDP
junos-smtp          # Email SMTP
```

**Custom Application Definition**
```bash
# Custom applications
set applications application mysql-custom protocol tcp destination-port 3306
set applications application web-alt protocol tcp destination-port 8080
set applications application custom-udp protocol udp destination-port 5000-5010

# Application sets
set applications application-set database-apps application mysql-custom
set applications application-set database-apps application junos-mysql
set applications application-set web-services application junos-http
set applications application-set web-services application junos-https
set applications application-set web-services application web-alt
```

### Lab Exercise 2: Advanced Policy Configuration

**Scenario**: Configure granular security policies for a corporate environment with different user groups and server access requirements.

**Requirements**:
- Executive users: Full internet access
- General users: Limited internet access (no social media)
- Guest users: Basic web access only
- DMZ servers: Inbound access from internet

**Implementation**:
```bash
# Address book configuration for user groups
set security zones security-zone trust address-book address executive-network 192.168.1.0/26
set security zones security-zone trust address-book address general-users 192.168.1.64/26
set security zones security-zone trust address-book address guest-network 192.168.1.128/26

set security zones security-zone dmz address-book address web-server 192.168.10.10/32
set security zones security-zone dmz address-book address mail-server 192.168.10.20/32

# Application sets for different access levels
set applications application-set social-media application junos-facebook
set applications application-set social-media application junos-twitter
set applications application-set social-media application junos-youtube

set applications application-set basic-web application junos-http
set applications application-set basic-web application junos-https
set applications application-set basic-web application junos-dns-udp

# Executive policy (full access)
set security policies from-zone trust to-zone untrust policy executive-full-access
set security policies from-zone trust to-zone untrust policy executive-full-access match source-address executive-network
set security policies from-zone trust to-zone untrust policy executive-full-access match destination-address any
set security policies from-zone trust to-zone untrust policy executive-full-access match application any
set security policies from-zone trust to-zone untrust policy executive-full-access then permit
set security policies from-zone trust to-zone untrust policy executive-full-access then log session-init

# General user policy (limited access)
set security policies from-zone trust to-zone untrust policy general-user-access
set security policies from-zone trust to-zone untrust policy general-user-access match source-address general-users
set security policies from-zone trust to-zone untrust policy general-user-access match destination-address any
set security policies from-zone trust to-zone untrust policy general-user-access match application basic-web
set security policies from-zone trust to-zone untrust policy general-user-access then permit

# Block social media for general users
set security policies from-zone trust to-zone untrust policy block-social-media
set security policies from-zone trust to-zone untrust policy block-social-media match source-address general-users
set security policies from-zone trust to-zone untrust policy block-social-media match destination-address any
set security policies from-zone trust to-zone untrust policy block-social-media match application-set social-media
set security policies from-zone trust to-zone untrust policy block-social-media then deny
set security policies from-zone trust to-zone untrust policy block-social-media then log session-init

# Guest access (basic web only)
set security policies from-zone trust to-zone untrust policy guest-access
set security policies from-zone trust to-zone untrust policy guest-access match source-address guest-network
set security policies from-zone trust to-zone untrust policy guest-access match destination-address any
set security policies from-zone trust to-zone untrust policy guest-access match application-set basic-web
set security policies from-zone trust to-zone untrust policy guest-access then permit

# Inbound access to DMZ servers
set security policies from-zone untrust to-zone dmz policy web-server-access
set security policies from-zone untrust to-zone dmz policy web-server-access match source-address any
set security policies from-zone untrust to-zone dmz policy web-server-access match destination-address web-server
set security policies from-zone untrust to-zone dmz policy web-server-access match application [ junos-http junos-https ]
set security policies from-zone untrust to-zone dmz policy web-server-access then permit
```

---

## Module 3: Network Address Translation (NAT)

### Learning Objectives
- Configure source NAT for internal users
- Implement destination NAT for server publishing
- Troubleshoot NAT-related connectivity issues
- Optimize NAT performance

### 3.1 Source NAT Configuration

**Interface-Based Source NAT**
```bash
# Basic interface NAT
set security nat source rule-set trust-to-untrust from zone trust
set security nat source rule-set trust-to-untrust to zone untrust
set security nat source rule-set trust-to-untrust rule interface-nat match source-address 0.0.0.0/0
set security nat source rule-set trust-to-untrust rule interface-nat then source-nat interface
```

**Pool-Based Source NAT**
```bash
# NAT pool configuration
set security nat source pool external-pool address 203.0.113.10/32 to 203.0.113.20/32
set security nat source pool external-pool overflow-pool interface

# Pool-based rule
set security nat source rule-set trust-to-untrust rule pool-nat match source-address 192.168.1.0/24
set security nat source rule-set trust-to-untrust rule pool-nat then source-nat pool external-pool
```

### 3.2 Destination NAT Configuration

**Basic Server Publishing**
```bash
# Destination NAT pool
set security nat destination pool web-server-pool address 192.168.10.10/32

# Destination NAT rule
set security nat destination rule-set untrust-inbound from zone untrust
set security nat destination rule-set untrust-inbound rule web-server-dnat match destination-address 203.0.113.100/32
set security nat destination rule-set untrust-inbound rule web-server-dnat match destination-port 80
set security nat destination rule-set untrust-inbound rule web-server-dnat then destination-nat pool web-server-pool
```

**Port Forwarding**
```bash
# SSH port forwarding
set security nat destination pool ssh-server-pool address 192.168.10.30/32 port 22
set security nat destination rule-set untrust-inbound rule ssh-forward match destination-address 203.0.113.100/32
set security nat destination rule-set untrust-inbound rule ssh-forward match destination-port 2222
set security nat destination rule-set untrust-inbound rule ssh-forward then destination-nat pool ssh-server-pool
```

### Lab Exercise 3: NAT Implementation

**Scenario**: Configure NAT for a multi-server environment with load balancing and port forwarding.

**Requirements**:
- Internal users need internet access via source NAT
- Web servers need inbound access on ports 80 and 443
- SSH access to management server on alternate port
- Load balancing between two web servers

**Configuration**:
```bash
# Source NAT for internal users
set security nat source rule-set internal-nat from zone trust
set security nat source rule-set internal-nat to zone untrust
set security nat source rule-set internal-nat rule trust-nat match source-address 192.168.0.0/16
set security nat source rule-set internal-nat rule trust-nat then source-nat interface

# Web server load balancing pools
set security nat destination pool web-pool-1 address 192.168.10.10/32
set security nat destination pool web-pool-2 address 192.168.10.11/32

# Round-robin distribution
set security nat destination pool web-servers address 192.168.10.10/32
set security nat destination pool web-servers address 192.168.10.11/32
set security nat destination pool web-servers algorithm round-robin

# Web server publishing
set security nat destination rule-set public-services from zone untrust
set security nat destination rule-set public-services rule web-http match destination-address 203.0.113.100/32
set security nat destination rule-set public-services rule web-http match destination-port 80
set security nat destination rule-set public-services rule web-http then destination-nat pool web-servers

set security nat destination rule-set public-services rule web-https match destination-address 203.0.113.100/32
set security nat destination rule-set public-services rule web-https match destination-port 443
set security nat destination rule-set public-services rule web-https then destination-nat pool web-servers

# SSH port forwarding to management server
set security nat destination pool mgmt-ssh address 192.168.10.100/32 port 22
set security nat destination rule-set public-services rule ssh-mgmt match destination-address 203.0.113.100/32
set security nat destination rule-set public-services rule ssh-mgmt match destination-port 2222
set security nat destination rule-set public-services rule ssh-mgmt then destination-nat pool mgmt-ssh

# Required security policies for NAT flows
set security policies from-zone untrust to-zone dmz policy web-inbound
set security policies from-zone untrust to-zone dmz policy web-inbound match source-address any
set security policies from-zone untrust to-zone dmz policy web-inbound match destination-address [ web-pool-1 web-pool-2 ]
set security policies from-zone untrust to-zone dmz policy web-inbound match application [ junos-http junos-https ]
set security policies from-zone untrust to-zone dmz policy web-inbound then permit

# Verification commands
show security nat source summary
show security nat destination summary
show security nat source rule all
show security flow session destination-port 80
```

---

## Module 4: Advanced Threat Protection

### Learning Objectives
- Configure and tune IDP (Intrusion Detection and Prevention)
- Implement application security and control
- Deploy UTM services (anti-malware, web filtering)
- Monitor and analyze security events

### 4.1 Intrusion Detection and Prevention (IDP)

**IDP License and Updates**
```bash
# Check IDP status
show security idp status
show security idp security-package-version

# Update IDP signatures
request security idp security-package download check-server
request security idp security-package download install

# Enable automatic updates
set security idp security-package automatic start-time "02:00:00 +0000"
set security idp security-package automatic enable
```

**IDP Policy Configuration**
```bash
# Basic IDP policy
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical match from-zone any
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical match to-zone any
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical match attacks predefined-attacks "Critical"
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical then action drop-packet
set security idp idp-policy comprehensive-protection rulebase-ips rule block-critical then notification log-attacks

# Apply IDP policy to security policies
set security policies from-zone trust to-zone untrust policy internet-access then permit application-services idp-policy comprehensive-protection
```

**Custom Attack Signatures**
```bash
# Custom signature for SQL injection
set security idp custom-attack sql-injection-custom attack-type signature
set security idp custom-attack sql-injection-custom protocol tcp
set security idp custom-attack sql-injection-custom protocol-binding application http
set security idp custom-attack sql-injection-custom signature ".*union.*select.*from.*"
set security idp custom-attack sql-injection-custom signature context http-url-decoded-uri

# Include custom attack in policy
set security idp idp-policy comprehensive-protection rulebase-ips rule custom-attacks match attacks custom-attack sql-injection-custom
set security idp idp-policy comprehensive-protection rulebase-ips rule custom-attacks then action drop-packet
```

### 4.2 Application Security (AppSecure)

**Application Identification**
```bash
# Enable application identification
set services application-identification

# Application firewall configuration
set security application-firewall rule-sets web-protection rule block-p2p match dynamic-application bittorrent
set security application-firewall rule-sets web-protection rule block-p2p then deny
set security application-firewall rule-sets web-protection rule block-p2p then log

# Apply to security policy
set security policies from-zone trust to-zone untrust policy internet-access then permit application-services application-firewall rule-set web-protection
```

### 4.3 Unified Threat Management (UTM)

**Anti-Malware Configuration**
```bash
# Anti-malware profile
set security utm anti-malware mime-whitelist [ "image/*" "text/plain" ]
set security utm anti-malware mime-blacklist "application/x-msdownload"
set security utm anti-malware uri-whitelist "*juniper.net/*"
set security utm anti-malware fallback-options default block
set security utm anti-malware fallback-options timeout block

# Apply anti-malware to policy
set security policies from-zone trust to-zone untrust policy internet-access then permit application-services anti-malware-policy anti-malware
```

**Web Filtering**
```bash
# Web filtering profile
set security utm web-filtering profile web-filter category Gambling action deny
set security utm web-filtering profile web-filter category "Social-Networking" action permit
set security utm web-filtering profile web-filter category Adult action deny
set security utm web-filtering profile web-filter default-action permit

# Custom URL categories
set security utm custom-objects url-category business-apps value "*.salesforce.com"
set security utm custom-objects url-category business-apps value "*.office365.com"

# Apply web filtering
set security policies from-zone trust to-zone untrust policy internet-access then permit application-services web-filtering-policy web-filter
```

### Lab Exercise 4: Comprehensive Security Services

**Objective**: Deploy a complete advanced threat protection solution with IDP, application control, and UTM services.

**Scenario**: Corporate network requiring protection from advanced threats, malware, and inappropriate web content.

**Configuration Steps**:
```bash
# 1. IDP Configuration
set security idp idp-policy corporate-protection rulebase-ips rule critical-threats
set security idp idp-policy corporate-protection rulebase-ips rule critical-threats match attacks predefined-attacks "Critical"
set security idp idp-policy corporate-protection rulebase-ips rule critical-threats match attacks predefined-attacks "High"
set security idp idp-policy corporate-protection rulebase-ips rule critical-threats then action drop-packet
set security idp idp-policy corporate-protection rulebase-ips rule critical-threats then notification log-attacks

# 2. Application Firewall
set security application-firewall rule-sets corporate-apps rule allow-business match dynamic-application salesforce
set security application-firewall rule-sets corporate-apps rule allow-business match dynamic-application office365
set security application-firewall rule-sets corporate-apps rule allow-business then permit

set security application-firewall rule-sets corporate-apps rule block-entertainment match dynamic-application facebook
set security application-firewall rule-sets corporate-apps rule block-entertainment match dynamic-application youtube
set security application-firewall rule-sets corporate-apps rule block-entertainment then deny
set security application-firewall rule-sets corporate-apps rule block-entertainment then log

# 3. Web Filtering
set security utm web-filtering profile corporate-web category Adult action deny
set security utm web-filtering profile corporate-web category Gambling action deny
set security utm web-filtering profile corporate-web category "Social-Networking" action deny
set security utm web-filtering profile corporate-web category "File-Sharing" action deny
set security utm web-filtering profile corporate-web default-action permit

# 4. Anti-Malware
set security utm anti-malware corporate-malware mime-whitelist [ "text/*" "image/*" ]
set security utm anti-malware corporate-malware fallback-options default block
set security utm anti-malware corporate-malware fallback-options timeout block

# 5. Integrate all services into security policy
set security policies from-zone trust to-zone untrust policy internet-access
set security policies from-zone trust to-zone untrust policy internet-access match source-address any
set security policies from-zone trust to-zone untrust policy internet-access match destination-address any
set security policies from-zone trust to-zone untrust policy internet-access match application any
set security policies from-zone trust to-zone untrust policy internet-access then permit application-services idp-policy corporate-protection
set security policies from-zone trust to-zone untrust policy internet-access then permit application-services application-firewall rule-set corporate-apps
set security policies from-zone trust to-zone untrust policy internet-access then permit application-services web-filtering-policy corporate-web
set security policies from-zone trust to-zone untrust policy internet-access then permit application-services anti-malware-policy corporate-malware
set security policies from-zone trust to-zone untrust policy internet-access then log session-init

# 6. Monitoring and verification
show security utm web-filtering statistics
show security utm anti-malware statistics
show security idp counters
show log messages | match "UTM\|IDP\|APP"
```

---

## Module 5: VPN Implementation

### Learning Objectives
- Configure IPsec site-to-site VPNs
- Implement SSL VPN for remote users
- Troubleshoot VPN connectivity issues
- Optimize VPN performance

### 5.1 IPsec Site-to-Site VPN

**Phase 1 (IKE) Configuration**
```bash
# IKE policy
set security ike policy ike-policy-branch mode main
set security ike policy ike-policy-branch proposal-set standard
set security ike policy ike-policy-branch pre-shared-key ascii-text "secure-shared-key"

# IKE gateway
set security ike gateway branch-office address 203.0.113.200
set security ike gateway branch-office ike-policy ike-policy-branch
set security ike gateway branch-office external-interface ge-0/0/0.0
set security ike gateway branch-office version v2-only
```

**Phase 2 (IPsec) Configuration**
```bash
# IPsec policy
set security ipsec policy ipsec-policy-branch perfect-forward-secrecy keys group14
set security ipsec policy ipsec-policy-branch proposal-set standard

# IPsec VPN
set security ipsec vpn branch-vpn bind-interface st0.0
set security ipsec vpn branch-vpn ike gateway branch-office
set security ipsec vpn branch-vpn ike ipsec-policy ipsec-policy-branch
set security ipsec vpn branch-vpn establish-tunnels immediately
```

**Tunnel Interface and Routing**
```bash
# Tunnel interface
set interfaces st0 unit 0 family inet address 169.254.1.1/30

# Zone assignment
set security zones security-zone vpn interfaces st0.0
set security zones security-zone vpn host-inbound-traffic system-services all
set security zones security-zone vpn host-inbound-traffic protocols all

# Static routes
set routing-options static route 192.168.200.0/24 next-hop st0.0
```

### 5.2 SSL VPN Configuration

**SSL VPN Profile**
```bash
# Basic SSL VPN profile
set security ssl-vpn profile remote-access authentication-server internal
set security ssl-vpn profile remote-access web-session idle-timeout 30
set security ssl-vpn profile remote-access web-session session-timeout 480

# Resource profiles
set security ssl-vpn resource-profile internal-resources web-bookmark company-portal url https://intranet.company.com
set security ssl-vpn resource-profile internal-resources web-bookmark company-portal description "Company Intranet"

set security ssl-vpn resource-profile internal-resources application file-share host 192.168.1.100 path /shared
set security ssl-vpn resource-profile internal-resources application file-share port 445
set security ssl-vpn resource-profile internal-resources application file-share description "Corporate File Share"
```

**User Authentication**
```bash
# Local users for SSL VPN
set system login user vpnuser1 uid 3001
set system login user vpnuser1 class remote-vpn
set system login user vpnuser1 authentication encrypted-password "$6$encrypted_hash"

# Custom login class
set system login class remote-vpn permissions view
set system login class remote-vpn allow-commands "show security ssl-vpn sessions"
set system login class remote-vpn deny-commands "clear"
```

### Lab Exercise 5: Hybrid VPN Solution

**Scenario**: Implement both site-to-site and remote access VPN solutions for a distributed organization.

**Requirements**:
- Site-to-site VPN between headquarters and branch office
- SSL VPN for remote workers
- Split tunneling for remote users
- VPN monitoring and logging

**Implementation**:
```bash
# Site-to-Site VPN Configuration
set security ike policy hq-to-branch mode main
set security ike policy hq-to-branch proposal ike-proposal authentication-method pre-shared-keys
set security ike policy hq-to-branch proposal ike-proposal dh-group group14
set security ike policy hq-to-branch proposal ike-proposal authentication-algorithm sha-256
set security ike policy hq-to-branch proposal ike-proposal encryption-algorithm aes-256-cbc
set security ike policy hq-to-branch pre-shared-key ascii-text "VerySecureSharedKey123!"

set security ike gateway branch-gateway address 203.0.113.150
set security ike gateway branch-gateway ike-policy hq-to-branch
set security ike gateway branch-gateway external-interface ge-0/0/0.0
set security ike gateway branch-gateway version v2-only

set security ipsec policy branch-ipsec perfect-forward-secrecy keys group14
set security ipsec policy branch-ipsec proposal ipsec-proposal protocol esp
set security ipsec policy branch-ipsec proposal ipsec-proposal authentication-algorithm hmac-sha-256-128
set security ipsec policy branch-ipsec proposal ipsec-proposal encryption-algorithm aes-256-cbc

set security ipsec vpn hq-branch-tunnel bind-interface st0.1
set security ipsec vpn hq-branch-tunnel ike gateway branch-gateway
set security ipsec vpn hq-branch-tunnel ike ipsec-policy branch-ipsec
set security ipsec vpn hq-branch-tunnel establish-tunnels immediately

# Tunnel interface and routing
set interfaces st0 unit 1 family inet address 169.254.2.1/30
set security zones security-zone branch-vpn interfaces st0.1
set routing-options static route 10.200.0.0/16 next-hop st0.1

# SSL VPN Configuration
set security ssl-vpn profile remote-workers authentication-server local
set security ssl-vpn profile remote-workers web-session idle-timeout 60
set security ssl-vpn profile remote-workers web-session session-timeout 720

# Split tunneling configuration
set security ssl-vpn resource-profile corporate-access network 192.168.0.0/16
set security ssl-vpn resource-profile corporate-access network 10.0.0.0/8
set security ssl-vpn resource-profile corporate-access web-bookmark intranet url https://intranet.company.com

# SSL VPN interface and pool
set interfaces st0 unit 2 family inet
set security zones security-zone ssl-vpn interfaces st0.2
set access address-assignment pool ssl-vpn-pool family inet network 192.168.100.0/24
set access address-assignment pool ssl-vpn-pool family inet range ssl-range low 192.168.100.10 high 192.168.100.100

# Security policies for VPN zones
set security policies from-zone branch-vpn to-zone trust policy branch-access
set security policies from-zone branch-vpn to-zone trust policy branch-access match source-address any
set security policies from-zone branch-vpn to-zone trust policy branch-access match destination-address any
set security policies from-zone branch-vpn to-zone trust policy branch-access match application any
set security policies from-zone branch-vpn to-zone trust policy branch-access then permit

set security policies from-zone ssl-vpn to-zone trust policy remote-access
set security policies from-zone ssl-vpn to-zone trust policy remote-access match source-address any
set security policies from-zone ssl-vpn to-zone trust policy remote-access match destination-address any
set security policies from-zone ssl-vpn to-zone trust policy remote-access match application [ junos-http junos-https junos-ssh ]
set security policies from-zone ssl-vpn to-zone trust policy remote-access then permit

# VPN monitoring
set security log mode event
set system syslog host 192.168.1.50 any info
set security log stream vpn-events host 192.168.1.50
set security log stream vpn-events port 514

# Verification commands
show security ike security-associations
show security ipsec security-associations
show security ssl-vpn sessions
show log messages | match "VPN\|IKE\|IPSEC"
```

---

## Module 6: High Availability and Clustering

### Learning Objectives
- Configure chassis clustering for high availability
- Implement redundant ethernet interfaces
- Test and validate failover scenarios
- Monitor cluster health and performance

### 6.1 Chassis Cluster Setup

**Pre-Cluster Configuration**
```bash
# Both nodes must be configured separately before clustering
# Node 0 configuration
set chassis cluster cluster-id 1
set chassis cluster node 0 priority 100

# Node 1 configuration  
set chassis cluster cluster-id 1
set chassis cluster node 1 priority 50
```

**Redundancy Groups**
```bash
# Control plane redundancy (RG0)
set chassis cluster redundancy-group 0 node 0 priority 100
set chassis cluster redundancy-group 0 node 1 priority 50

# Data plane redundancy (RG1)
set chassis cluster redundancy-group 1 node 0 priority 100
set chassis cluster redundancy-group 1 node 1 priority 50
set chassis cluster redundancy-group 1 preempt
```

**Control and Fabric Links**
```bash
# Control links (management)
set chassis cluster control-ports fpc 0 port 0
set chassis cluster control-ports fpc 0 port 1

# Fabric links (data synchronization)
set chassis cluster fab0 member-interfaces ge-0/0/5
set chassis cluster fab1 member-interfaces ge-0/0/6
```

### 6.2 Redundant Ethernet (reth) Interfaces

**reth Interface Configuration**
```bash
# Define reth interfaces
set chassis cluster reth-count 4

# reth0 for trust zone
set interfaces reth0 description "Trust Zone Redundant Interface"
set interfaces reth0 redundant-ether-options redundancy-group 1
set interfaces reth0 unit 0 family inet address 192.168.1.1/24

# reth1 for untrust zone
set interfaces reth1 description "Untrust Zone Redundant Interface"
set interfaces reth1 redundant-ether-options redundancy-group 1
set interfaces reth1 unit 0 family inet dhcp-client

# Physical interface assignments
set interfaces ge-0/0/1 ether-options redundant-parent reth0
set interfaces ge-1/0/1 ether-options redundant-parent reth0
set interfaces ge-0/0/0 ether-options redundant-parent reth1
set interfaces ge-1/0/0 ether-options redundant-parent reth1
```

### 6.3 Cluster Monitoring and Maintenance

**Health Monitoring**
```bash
# Cluster status verification
show chassis cluster status
show chassis cluster statistics
show chassis cluster interfaces

# Failover testing
request chassis cluster failover redundancy-group 1 node 0
request chassis cluster failover reset redundancy-group 1

# Sync verification  
show chassis cluster status | match sync
```

### Lab Exercise 6: HA Cluster Implementation

**Objective**: Build and test a complete high-availability SRX cluster with automated failover.

**Prerequisites**: Two identical SRX devices with factory default configurations.

**Step-by-Step Implementation**:

**Phase 1: Initial Cluster Setup**
```bash
# On Node 0 (primary)
configure
set chassis cluster cluster-id 10
set chassis cluster node 0 priority 254
commit and-quit

# On Node 1 (secondary)  
configure
set chassis cluster cluster-id 10
set chassis cluster node 1 priority 1
commit and-quit

# Reboot both nodes - they will form cluster automatically
request system reboot
```

**Phase 2: Network Interface Configuration**
```bash
# After cluster formation, configure from primary node only
configure

# Set up reth interfaces
set chassis cluster reth-count 3
set interfaces reth0 redundant-ether-options redundancy-group 1
set interfaces reth0 unit 0 family inet address 192.168.1.1/24
set interfaces reth1 redundant-ether-options redundancy-group 1  
set interfaces reth1 unit 0 family inet dhcp-client
set interfaces reth2 redundant-ether-options redundancy-group 1
set interfaces reth2 unit 0 family inet address 192.168.10.1/24

# Assign physical interfaces
set interfaces ge-0/0/1 ether-options redundant-parent reth0
set interfaces ge-1/0/1 ether-options redundant-parent reth0
set interfaces ge-0/0/0 ether-options redundant-parent reth1
set interfaces ge-1/0/0 ether-options redundant-parent reth1
set interfaces ge-0/0/2 ether-options redundant-parent reth2
set interfaces ge-1/0/2 ether-options redundant-parent reth2

# Control and fabric links
set chassis cluster control-ports fpc 0 port 0
set chassis cluster control-ports fpc 1 port 0  
set chassis cluster fab0 member-interfaces ge-0/0/5
set chassis cluster fab1 member-interfaces ge-1/0/5

commit
```

**Phase 3: Security Configuration**
```bash
# Security zones
set security zones security-zone trust interfaces reth0.0
set security zones security-zone untrust interfaces reth1.0  
set security zones security-zone dmz interfaces reth2.0

# Basic security policies
set security policies from-zone trust to-zone untrust policy allow-internet
set security policies from-zone trust to-zone untrust policy allow-internet match source-address any
set security policies from-zone trust to-zone untrust policy allow-internet match destination-address any
set security policies from-zone trust to-zone untrust policy allow-internet match application any
set security policies from-zone trust to-zone untrust policy allow-internet then permit

# NAT configuration
set security nat source rule-set trust-nat from zone trust
set security nat source rule-set trust-nat to zone untrust
set security nat source rule-set trust-nat rule nat-rule match source-address 0.0.0.0/0
set security nat source rule-set trust-nat rule nat-rule then source-nat interface

commit
```

**Phase 4: Testing and Validation**
```bash
# Verify cluster status
show chassis cluster status
show chassis cluster interfaces  
show chassis cluster statistics

# Test failover
request chassis cluster failover redundancy-group 1 node 0

# Monitor during failover
monitor start chassis-control
ping 8.8.8.8 source 192.168.1.1 count 100

# Verify failover completed
show chassis cluster status
show chassis cluster failover-time

# Return to normal operation
request chassis cluster failover reset redundancy-group 1
```

---

## Module 7: Monitoring and Troubleshooting

### Learning Objectives
- Implement comprehensive monitoring solutions
- Analyze security logs and events
- Troubleshoot common connectivity and performance issues
- Create automated monitoring scripts

### 7.1 Logging and SIEM Integration

**System Logging Configuration**
```bash
# Local logging
set system syslog user * any emergency
set system syslog file messages any info
set system syslog file messages authorization info
set system syslog file security-events interactive-commands info

# Remote syslog (SIEM integration)
set system syslog host 192.168.1.100 any info
set system syslog host 192.168.1.100 port 514
set system syslog host 192.168.1.100 facility-override local0

# Security event logging
set security log mode stream
set security log format sd-syslog
set security log source-address 192.168.1.1
set security log stream security-stream host 192.168.1.100
set security log stream security-stream port 514
set security log stream security-stream severity info
```

**SNMP Monitoring**
```bash
# SNMP configuration
set snmp community public authorization read-only
set snmp community private authorization read-write
set snmp location "Data Center - Rack A1"
set snmp contact "Network Team <network@company.com>"

# SNMP trap configuration
set snmp trap-options source-address 192.168.1.1
set snmp trap-group monitoring version v2
set snmp trap-group monitoring targets 192.168.1.200
set snmp trap-group monitoring categories chassis
set snmp trap-group monitoring categories routing
set snmp trap-group monitoring categories security
```

### 7.2 Performance Monitoring

**Built-in Performance Tools**
```bash
# Interface statistics
show interfaces extensive ge-0/0/0
show interfaces statistics ge-0/0/0

# Security performance
show security monitoring performance spu
show security monitoring performance services
show security flow session summary
show security flow session statistics

# System performance
show chassis routing-engine
show system processes extensive
show system memory
```

**Custom Monitoring Script**
```python
#!/usr/bin/env python3
"""
SRX Health Monitoring Script
Automated monitoring and alerting for SRX devices
"""

import paramiko
import smtplib
import json
import time
from email.mime.text import MIMEText
from datetime import datetime

class SRXMonitor:
    def __init__(self, config_file):
        with open(config_file, 'r') as f:
            self.config = json.load(f)
        
        self.devices = self.config['devices']
        self.thresholds = self.config['thresholds']
        self.alerts = self.config['alerts']
        self.monitoring_results = {}
        
    def connect_device(self, device_info):
        """Establish SSH connection to SRX device"""
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            hostname=device_info['ip'],
            username=device_info['username'],
            password=device_info['password'],
            timeout=10
        )
        return ssh
    
    def check_system_health(self, ssh, device_name):
        """Check system health metrics"""
        health_results = {}
        
        # CPU utilization
        stdin, stdout, stderr = ssh.exec_command("show chassis routing-engine")
        cpu_output = stdout.read().decode()
        
        # Parse CPU usage (simplified)
        for line in cpu_output.split('\n'):
            if 'CPU utilization' in line:
                cpu_percent = int(line.split()[-1].rstrip('%'))
                health_results['cpu_utilization'] = cpu_percent
                break
        
        # Memory utilization
        stdin, stdout, stderr = ssh.exec_command("show system memory")
        memory_output = stdout.read().decode()
        
        # Session count
        stdin, stdout, stderr = ssh.exec_command("show security flow session summary")
        session_output = stdout.read().decode()
        
        for line in session_output.split('\n'):
            if 'Active sessions:' in line:
                session_count = int(line.split(':')[1].strip())
                health_results['active_sessions'] = session_count
                break
        
        # Interface status
        stdin, stdout, stderr = ssh.exec_command("show interfaces terse | match up/up")
        interface_output = stdout.read().decode()
        up_interfaces = len(interface_output.split('\n')) - 1
        health_results['up_interfaces'] = up_interfaces
        
        self.monitoring_results[device_name] = health_results
        return health_results
    
    def check_security_services(self, ssh, device_name):
        """Check security services status"""
        security_results = {}
        
        # IDP status
        stdin, stdout, stderr = ssh.exec_command("show security idp status")
        idp_output = stdout.read().decode()
        
        if 'Running' in idp_output:
            security_results['idp_status'] = 'Running'
        else:
            security_results['idp_status'] = 'Not Running'
        
        # Get security events
        stdin, stdout, stderr = ssh.exec_command("show log messages | match 'RT_FLOW\\|IDP' | last 10")
        events_output = stdout.read().decode()
        recent_events = len(events_output.split('\n')) - 1
        security_results['recent_security_events'] = recent_events
        
        return security_results
    
    def evaluate_alerts(self, device_name, health_data):
        """Evaluate if any alerts should be triggered"""
        alerts_triggered = []
        
        # CPU threshold check
        if health_data.get('cpu_utilization', 0) > self.thresholds['cpu_threshold']:
            alerts_triggered.append({
                'type': 'cpu_high',
                'message': f"High CPU utilization: {health_data['cpu_utilization']}%",
                'severity': 'warning'
            })
        
        # Session count check
        if health_data.get('active_sessions', 0) > self.thresholds['session_threshold']:
            alerts_triggered.append({
                'type': 'session_high',
                'message': f"High session count: {health_data['active_sessions']}",
                'severity': 'warning'
            })
        
        return alerts_triggered
    
    def send_alert(self, device_name, alerts):
        """Send email alert for triggered conditions"""
        if not alerts:
            return
        
        smtp_config = self.alerts['smtp']
        
        # Compose alert email
        subject = f"SRX Alert - {device_name}"
        body = f"Alerts triggered for {device_name} at {datetime.now()}:\n\n"
        
        for alert in alerts:
            body += f"- {alert['severity'].upper()}: {alert['message']}\n"
        
        msg = MIMEText(body)
        msg['Subject'] = subject
        msg['From'] = smtp_config['from_email']
        msg['To'] = ', '.join(smtp_config['to_emails'])
        
        # Send email
        try:
            with smtplib.SMTP(smtp_config['server'], smtp_config['port']) as server:
                if smtp_config.get('use_tls'):
                    server.starttls()
                if smtp_config.get('username'):
                    server.login(smtp_config['username'], smtp_config['password'])
                server.send_message(msg)
            print(f"Alert sent for {device_name}")
        except Exception as e:
            print(f"Failed to send alert for {device_name}: {e}")
    
    def run_monitoring_cycle(self):
        """Execute complete monitoring cycle for all devices"""
        print(f"Starting monitoring cycle at {datetime.now()}")
        
        for device in self.devices:
            device_name = device['name']
            print(f"Monitoring {device_name}...")
            
            try:
                ssh = self.connect_device(device)
                
                # Collect metrics
                health_data = self.check_system_health(ssh, device_name)
                security_data = self.check_security_services(ssh, device_name)
                
                # Evaluate alerts
                alerts = self.evaluate_alerts(device_name, health_data)
                
                if alerts:
                    self.send_alert(device_name, alerts)
                
                ssh.close()
                print(f"Monitoring completed for {device_name}")
                
            except Exception as e:
                print(f"Monitoring failed for {device_name}: {e}")
                error_alert = [{
                    'type': 'monitoring_failure',
                    'message': f"Failed to monitor device: {e}",
                    'severity': 'critical'
                }]
                self.send_alert(device_name, error_alert)
    
    def generate_report(self):
        """Generate monitoring report"""
        report = f"""
SRX Monitoring Report - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
================================================================

"""
        for device_name, data in self.monitoring_results.items():
            report += f"{device_name}:\n"
            for metric, value in data.items():
                report += f"  {metric}: {value}\n"
            report += "\n"
        
        return report

# Configuration file example (config.json)
"""
{
  "devices": [
    {
      "name": "SRX-HQ-01",
      "ip": "192.168.1.10",
      "username": "monitor",
      "password": "monitor_password"
    }
  ],
  "thresholds": {
    "cpu_threshold": 80,
    "session_threshold": 500000,
    "interface_threshold": 90
  },
  "alerts": {
    "smtp": {
      "server": "smtp.company.com",
      "port": 587,
      "use_tls": true,
      "username": "alerts@company.com",
      "password": "smtp_password",
      "from_email": "srx-monitor@company.com",
      "to_emails": ["network-team@company.com"]
    }
  }
}
"""

# Usage:
# monitor = SRXMonitor('config.json')
# monitor.run_monitoring_cycle()
# print(monitor.generate_report())
```

### 7.3 Troubleshooting Common Issues

**Connectivity Troubleshooting**
```bash
# Basic connectivity tests
ping 8.8.8.8 source 192.168.1.1
traceroute 8.8.8.8 source 192.168.1.1

# Interface diagnostics
show interfaces diagnostics optics ge-0/0/0
show interfaces extensive ge-0/0/0

# Routing verification
show route
show route 8.8.8.8 extensive
```

**Security Policy Troubleshooting**
```bash
# Policy troubleshooting
show security policies hit-count
show security policies detail
show security match-policies from-zone trust to-zone untrust source-ip 192.168.1.100 destination-ip 8.8.8.8 protocol tcp destination-port 80

# Session troubleshooting
show security flow session destination-ip 8.8.8.8
show security flow session source-prefix 192.168.1.0/24
clear security flow session destination-ip 8.8.8.8
```

### Final Lab Exercise: End-to-End Implementation

**Comprehensive Scenario**: Deploy a complete SRX solution for a multi-site organization including all learned concepts.

**Requirements**:
- High-availability cluster
- Multiple security zones with granular policies
- VPN connectivity to branch offices
- Advanced threat protection
- Comprehensive monitoring and logging
- Performance optimization

This training program provides comprehensive coverage of Juniper SRX Firewall Platform implementation and management, preparing security professionals for real-world deployment scenarios.