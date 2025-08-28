# Dell PowerSwitch Datacenter Configuration Templates

## Overview

This document provides comprehensive configuration templates for Dell PowerSwitch datacenter networking deployments. These templates are designed to accelerate implementation while ensuring consistency, best practices, and optimal performance across the entire fabric.

## Table of Contents

1. [Configuration Standards](#configuration-standards)
2. [Base System Configuration](#base-system-configuration)
3. [Spine Switch Configuration](#spine-switch-configuration)
4. [Leaf Switch Configuration](#leaf-switch-configuration)
5. [VXLAN and EVPN Configuration](#vxlan-and-evpn-configuration)
6. [Quality of Service Configuration](#quality-of-service-configuration)
7. [Security Configuration](#security-configuration)
8. [Management Configuration](#management-configuration)
9. [Monitoring Configuration](#monitoring-configuration)
10. [Automation Templates](#automation-templates)

---

## Configuration Standards

### 1.1 Naming Conventions

#### Device Naming Standard
```
Device Naming Convention:
┌─────────────────────────────────────────────────────────────────┐
│  Device Type    │ Format                  │ Example             │
├─────────────────────────────────────────────────────────────────┤
│  Spine Switches │ [SITE]-SP-[##]          │ DC1-SP-01           │
│  Leaf Switches  │ [SITE]-LF-[ROW][RACK]   │ DC1-LF-A01          │
│  Management     │ [SITE]-MGT-[##]         │ DC1-MGT-01          │
└─────────────────────────────────────────────────────────────────┘
```

#### Interface Naming Standard
```
Interface Description Format:
- Uplinks: "UPLINK_TO_[HOSTNAME]_[INTERFACE]"
- Downlinks: "DOWNLINK_TO_[HOSTNAME]_[INTERFACE]"
- Server Connections: "SRV_[HOSTNAME]_[NIC]"
- Management: "MGMT_[FUNCTION]"

Examples:
- "UPLINK_TO_DC1-SP-01_ETH1/1/1"
- "SRV_WEB01_NIC1"
- "MGMT_OOB"
```

### 1.2 IP Address Allocation

#### IP Address Schema
```
IP Address Allocation Framework:
┌─────────────────────────────────────────────────────────────────┐
│  Network Type           │ IP Range            │ Subnet Mask     │
├─────────────────────────────────────────────────────────────────┤
│  Spine Loopbacks        │ 10.255.255.0/24    │ /32             │
│  Leaf Loopbacks         │ 10.255.254.0/24    │ /32             │
│  VTEP Addresses         │ 10.254.254.0/24    │ /32             │
│  P2P Links              │ 10.1.0.0/16         │ /31             │
│  Management             │ 192.168.100.0/24   │ /24             │
│  Server Networks        │ 10.10.0.0/16       │ /24 per VLAN    │
│  Storage Networks       │ 10.20.0.0/16       │ /24 per VLAN    │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 VLAN and VNI Assignment

#### VLAN/VNI Mapping Standard
```
VLAN/VNI Assignment Framework:
┌─────────────────────────────────────────────────────────────────┐
│  VLAN Range    │ Purpose              │ VNI Range             │
├─────────────────────────────────────────────────────────────────┤
│  1-99          │ Infrastructure       │ N/A                   │
│  100-199       │ Production (Tenant A)│ 10100-10199          │
│  200-299       │ Development          │ 10200-10299          │
│  300-399       │ Testing              │ 10300-10399          │
│  400-499       │ DMZ                  │ 10400-10499          │
│  500-599       │ Storage              │ 10500-10599          │
│  600-699       │ Management           │ 10600-10699          │
│  700-799       │ Voice/Video          │ 10700-10799          │
│  800-899       │ Guest                │ 10800-10899          │
│  900-999       │ Reserved             │ 10900-10999          │
│  1000+         │ L3 VNI               │ 50001-59999          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Base System Configuration

### 2.1 Global Configuration Template

#### System-Wide Settings
```bash
# Global Configuration Template for Dell PowerSwitch OS10
# File: base-system-config.txt

# System Information
hostname [HOSTNAME]
boot system primary
boot system secondary

# Enable Required Features
feature bgp
feature evpn
feature vxlan
feature interface-vlan

# Global Configuration
service password-encryption
ip domain-name company.local
ip name-server 8.8.8.8
ip name-server 8.8.4.4

# NTP Configuration
ntp server 192.168.100.10 prefer
ntp server 192.168.100.11
ntp authenticate
ntp authentication-key 1 md5 encrypted [KEY]
ntp trusted-key 1

# DNS Configuration
ip domain-lookup
ip domain-name company.local

# Logging Configuration
logging buffered 10240 informational
logging server 192.168.100.20 debugging
logging source-interface management 1/1/1
logging facility local1
logging timestamp

# SNMP Configuration
snmp-server community public ro
snmp-server community private rw 192.168.100.0/24
snmp-server location "Datacenter 1, Rack [RACK]"
snmp-server contact "Network Operations <netops@company.com>"
snmp-server enable traps
snmp-server host 192.168.100.30 version 2c public

# Banner Configuration
banner motd "
*****************************************************************
*                    AUTHORIZED ACCESS ONLY                    *
*  This device is property of [COMPANY NAME]                   *
*  Unauthorized access is prohibited and will be prosecuted    *
*  All activities are monitored and logged                     *
*****************************************************************
"

# User Account Configuration
username admin privilege 15 password encrypted [PASSWORD]
username netop privilege 10 password encrypted [PASSWORD]
username readonly privilege 5 password encrypted [PASSWORD]

# SSH Configuration
ip ssh server enable
ip ssh server version 2
line ssh
  login authentication default
  authorization exec default

# Console Configuration
line console
  logging synchronous

# VTY Configuration  
line vty 0 4
  transport input ssh
  login authentication default
  authorization exec default
```

### 2.2 Interface Configuration Standards

#### Standard Interface Configuration
```bash
# Interface Configuration Standards

# Management Interface Template
interface management 1/1/1
  description "OUT_OF_BAND_MANAGEMENT"
  no shutdown
  ip address [MGMT_IP]/24
  ipv6 address autoconfig
  
# Loopback Interface Template
interface loopback 0
  description "BGP_ROUTER_ID_VTEP"
  ip address [LOOPBACK_IP]/32
  
# Physical Interface Template (Server Access)
interface ethernet 1/1/1
  description "[INTERFACE_DESCRIPTION]"
  no shutdown
  mtu 9216
  speed auto
  duplex auto
  flowcontrol receive on
  flowcontrol transmit on
  switchport
  switchport mode trunk
  switchport trunk allowed vlan [VLAN_LIST]
  spanning-tree port type edge
  spanning-tree bpduguard enable

# Physical Interface Template (Fabric Links)
interface ethernet 1/1/49
  description "[UPLINK_DESCRIPTION]"
  no shutdown
  no switchport
  mtu 9216
  ip address [P2P_IP]/31
  ip ospf network point-to-point
  ip ospf area 0.0.0.0
  
# Link Aggregation Template (LAG)
interface port-channel 1
  description "[LAG_DESCRIPTION]"
  no shutdown
  switchport
  switchport mode trunk
  switchport trunk allowed vlan [VLAN_LIST]
  mtu 9216
  
# LAG Member Interface
interface ethernet 1/1/1
  description "[MEMBER_DESCRIPTION]"
  no shutdown
  channel-group 1 mode active
  no spanning-tree port type edge
```

---

## Spine Switch Configuration

### 3.1 Spine Switch Base Configuration

#### Complete Spine Configuration Template
```bash
# Spine Switch Configuration Template
# File: spine-config-template.txt
# Device: Dell S5248F-ON or S5296F-ON

# System Configuration
hostname [SITE]-SP-[##]
boot system primary
boot system secondary

# Feature Configuration
feature bgp
feature evpn
feature interface-vlan

# Interface Configuration
interface loopback 0
  description "BGP_ROUTER_ID"
  ip address 10.255.255.[SPINE_ID]/32

interface management 1/1/1
  description "OUT_OF_BAND_MANAGEMENT"
  no shutdown
  ip address 192.168.100.[10+SPINE_ID]/24

# Fabric Interface Configuration (Downlinks to Leaf Switches)
interface ethernet 1/1/1
  description "DOWNLINK_TO_DC1-LF-01_ETH1/1/49"
  no shutdown
  no switchport
  mtu 9216
  ip address 10.1.1.0/31
  
interface ethernet 1/1/2
  description "DOWNLINK_TO_DC1-LF-01_ETH1/1/50"
  no shutdown
  no switchport
  mtu 9216
  ip address 10.1.1.2/31

# Continue for all leaf connections...
# [Additional interface configurations for each leaf switch]

# BGP Configuration
router bgp [SPINE_ASN]
  router-id 10.255.255.[SPINE_ID]
  log-neighbor-changes
  
  # BGP Neighbors (Leaf Switches)
  neighbor 10.1.1.1 remote-as [LEAF_ASN_BASE + 1]
  neighbor 10.1.1.1 description "DC1-LF-01"
  neighbor 10.1.1.1 timers 3 9
  neighbor 10.1.1.1 maximum-paths 8
  
  neighbor 10.1.1.3 remote-as [LEAF_ASN_BASE + 2]
  neighbor 10.1.1.3 description "DC1-LF-02"
  neighbor 10.1.1.3 timers 3 9
  neighbor 10.1.1.3 maximum-paths 8
  
  # Continue for all leaf neighbors...
  
  # IPv4 Unicast Address Family
  address-family ipv4 unicast
    network 10.255.255.[SPINE_ID]/32
    maximum-paths 8
    neighbor 10.1.1.1 activate
    neighbor 10.1.1.3 activate
    # Continue for all neighbors...
  
  # L2VPN EVPN Address Family  
  address-family l2vpn evpn
    neighbor 10.1.1.1 activate
    neighbor 10.1.1.1 send-community extended
    neighbor 10.1.1.1 route-reflector-client
    
    neighbor 10.1.1.3 activate
    neighbor 10.1.1.3 send-community extended
    neighbor 10.1.1.3 route-reflector-client
    
    # Continue for all neighbors...

# Route-map Configuration
route-map LOOPBACK_ONLY permit 10
  match interface loopback 0

# Prefix-list Configuration
ip prefix-list LOOPBACK_NETWORKS seq 10 permit 10.255.255.0/24 le 32

# Access Control Lists
ip access-list extended MANAGEMENT_ACCESS
  10 permit tcp 192.168.100.0/24 any eq 22
  20 permit tcp 192.168.100.0/24 any eq 161
  30 permit icmp any any
  40 deny ip any any log
  
# Apply ACL to management interface
interface management 1/1/1
  ip access-group MANAGEMENT_ACCESS in
```

### 3.2 Spine High Availability Configuration

#### Multi-Spine Redundancy
```bash
# Spine Redundancy Configuration
# For environments with multiple spine switches

# BGP Configuration with Multiple Spines
router bgp [SPINE_ASN]
  # Spine-to-Spine peering (if required)
  neighbor 10.255.255.[OTHER_SPINE_ID] remote-as [SPINE_ASN]
  neighbor 10.255.255.[OTHER_SPINE_ID] update-source loopback 0
  neighbor 10.255.255.[OTHER_SPINE_ID] description "SPINE_PEER"
  
  address-family ipv4 unicast
    neighbor 10.255.255.[OTHER_SPINE_ID] activate
    neighbor 10.255.255.[OTHER_SPINE_ID] next-hop-self
  
  address-family l2vpn evpn
    neighbor 10.255.255.[OTHER_SPINE_ID] activate
    neighbor 10.255.255.[OTHER_SPINE_ID] send-community extended

# BFD Configuration for Fast Failure Detection
router bgp [SPINE_ASN]
  neighbor [NEIGHBOR_IP] fall-over bfd
  
interface ethernet 1/1/1
  ip bfd interval 300 min-rx 300 multiplier 3
  no ip bfd echo

# Load Balancing Configuration
router bgp [SPINE_ASN]
  maximum-paths 8
  maximum-paths ibgp 8
  bgp bestpath as-path multipath-relax
```

---

## Leaf Switch Configuration

### 4.1 Leaf Switch Base Configuration

#### Complete Leaf Configuration Template
```bash
# Leaf Switch Configuration Template  
# File: leaf-config-template.txt
# Device: Dell S4148F-ON or S4128F-ON

# System Configuration
hostname [SITE]-LF-[LOCATION]
boot system primary
boot system secondary

# Feature Configuration
feature bgp
feature evpn
feature vxlan
feature interface-vlan
feature lacp

# VLAN Configuration
vlan 100
  name "PROD_WEB_TIER"
  
vlan 101  
  name "PROD_APP_TIER"
  
vlan 102
  name "PROD_DB_TIER"
  
vlan 200
  name "DEV_WEB_TIER"
  
vlan 201
  name "DEV_APP_TIER"

# Interface Configuration
interface loopback 0
  description "BGP_ROUTER_ID_VTEP"
  ip address 10.255.254.[LEAF_ID]/32

interface management 1/1/1
  description "OUT_OF_BAND_MANAGEMENT"  
  no shutdown
  ip address 192.168.100.[100+LEAF_ID]/24

# Server-Facing Interfaces
interface ethernet 1/1/1
  description "SRV_WEB01_NIC1"
  no shutdown
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 100,200
  mtu 9216
  spanning-tree port type edge
  spanning-tree bpduguard enable
  
interface ethernet 1/1/2
  description "SRV_WEB01_NIC2"
  no shutdown
  switchport
  switchport mode trunk  
  switchport trunk allowed vlan 100,200
  mtu 9216
  spanning-tree port type edge
  spanning-tree bpduguard enable

# Server Port Channel (Dual-homed servers)
interface port-channel 1
  description "SRV_WEB01_LACP"
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 100,200
  mtu 9216
  lacp mode active
  
interface ethernet 1/1/1
  channel-group 1 mode active
  
interface ethernet 1/1/2  
  channel-group 1 mode active

# Fabric Uplinks (to Spine Switches)
interface ethernet 1/1/49
  description "UPLINK_TO_DC1-SP-01_ETH1/1/1"
  no shutdown
  no switchport
  mtu 9216
  ip address 10.1.1.1/31
  
interface ethernet 1/1/50
  description "UPLINK_TO_DC1-SP-02_ETH1/1/1" 
  no shutdown
  no switchport
  mtu 9216
  ip address 10.1.2.1/31

# NVE Interface Configuration
interface nve 1
  no shutdown
  source-interface loopback 0
  
  # L2 VNI Members
  member vni 10100
    ingress-replication protocol bgp
  member vni 10101  
    ingress-replication protocol bgp
  member vni 10102
    ingress-replication protocol bgp
  member vni 10200
    ingress-replication protocol bgp
  member vni 10201
    ingress-replication protocol bgp
    
  # L3 VNI Members  
  member vni 50001 associate-vrf TENANT_A
  member vni 50002 associate-vrf TENANT_B

# SVI Configuration  
interface vlan 100
  description "PROD_WEB_TIER_GATEWAY"
  no shutdown
  vrf member TENANT_A
  ip address 10.10.1.1/24
  fabric forwarding mode anycast-gateway
  
interface vlan 101
  description "PROD_APP_TIER_GATEWAY"
  no shutdown
  vrf member TENANT_A  
  ip address 10.10.2.1/24
  fabric forwarding mode anycast-gateway
  
interface vlan 102
  description "PROD_DB_TIER_GATEWAY"
  no shutdown
  vrf member TENANT_A
  ip address 10.10.3.1/24
  fabric forwarding mode anycast-gateway

interface vlan 200
  description "DEV_WEB_TIER_GATEWAY"
  no shutdown
  vrf member TENANT_B
  ip address 10.20.1.1/24
  fabric forwarding mode anycast-gateway
  
interface vlan 201
  description "DEV_APP_TIER_GATEWAY" 
  no shutdown
  vrf member TENANT_B
  ip address 10.20.2.1/24
  fabric forwarding mode anycast-gateway

# Anycast Gateway Configuration
fabric forwarding anycast-gateway-mac 0000.1111.2222

# VRF Configuration
vrf context TENANT_A
  vni 50001
  rd auto
  address-family ipv4 unicast
    route-target import auto
    route-target export auto
    route-target import auto evpn
    route-target export auto evpn
    
vrf context TENANT_B
  vni 50002
  rd auto  
  address-family ipv4 unicast
    route-target import auto
    route-target export auto
    route-target import auto evpn
    route-target export auto evpn

# BGP Configuration
router bgp [LEAF_ASN]
  router-id 10.255.254.[LEAF_ID]
  log-neighbor-changes
  
  # Spine Neighbors
  neighbor 10.1.1.0 remote-as [SPINE_ASN]
  neighbor 10.1.1.0 description "DC1-SP-01"
  neighbor 10.1.1.0 timers 3 9
  
  neighbor 10.1.2.0 remote-as [SPINE_ASN]  
  neighbor 10.1.2.0 description "DC1-SP-02"
  neighbor 10.1.2.0 timers 3 9
  
  # IPv4 Unicast Address Family
  address-family ipv4 unicast
    network 10.255.254.[LEAF_ID]/32
    maximum-paths 4
    neighbor 10.1.1.0 activate
    neighbor 10.1.2.0 activate
    
  # L2VPN EVPN Address Family
  address-family l2vpn evpn
    neighbor 10.1.1.0 activate
    neighbor 10.1.1.0 send-community extended
    neighbor 10.1.2.0 activate  
    neighbor 10.1.2.0 send-community extended
    
  # VRF Tenant A Configuration
  vrf TENANT_A
    address-family ipv4 unicast
      network 10.10.1.0/24
      network 10.10.2.0/24
      network 10.10.3.0/24
      advertise l2vpn evpn
      
  # VRF Tenant B Configuration
  vrf TENANT_B  
    address-family ipv4 unicast
      network 10.20.1.0/24
      network 10.20.2.0/24
      advertise l2vpn evpn
```

### 4.2 Leaf Switch Advanced Features

#### Multi-Homing and Redundancy
```bash
# MLAG Configuration (Multi-Chassis Link Aggregation)
# Note: Dell OS10 uses VLTi (Virtual Link Trunking interconnect)

# VLTi Configuration  
interface ethernet 1/1/51
  description "VLTI_PEER_LINK_1"
  no shutdown
  no switchport
  
interface ethernet 1/1/52
  description "VLTI_PEER_LINK_2"
  no shutdown
  no switchport
  
interface port-channel 100
  description "VLTI_PEER_LINK"
  no shutdown
  no switchport
  
interface ethernet 1/1/51
  channel-group 100 mode active
  
interface ethernet 1/1/52
  channel-group 100 mode active

# VLT Domain Configuration
vlt domain 1
  peer-link port-channel 100
  system-mac 00:01:02:03:04:05
  unit-id 1
  
# VLT Port Channel for Server Connection
interface port-channel 10
  description "VLT_SRV_CONNECTION"
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 100-102,200-201
  vlt-port-channel 10
```

---

## VXLAN and EVPN Configuration

### 5.1 EVPN Service Configuration

#### L2 EVPN Services Configuration
```bash
# EVPN L2 Services Configuration Template
# File: evpn-l2-services-config.txt

# EVPN Instance Configuration
evpn
  # L2 VNI Configuration
  vni 10100 l2
    rd auto
    route-target import auto  
    route-target export auto
    
  vni 10101 l2
    rd auto
    route-target import auto
    route-target export auto
    
  vni 10102 l2  
    rd auto
    route-target import auto
    route-target export auto

# VLAN to VNI Mapping
vlan 100
  vn-segment 10100
  
vlan 101
  vn-segment 10101
  
vlan 102
  vn-segment 10102

# Suppress ARP for Broadcast Reduction  
interface nve 1
  member vni 10100
    suppress-arp
  member vni 10101
    suppress-arp
  member vni 10102
    suppress-arp
```

#### L3 EVPN Services Configuration  
```bash
# EVPN L3 Services Configuration Template
# File: evpn-l3-services-config.txt

# L3 VNI Configuration
evpn
  vni 50001 l3
    rd auto
    route-target import auto
    route-target export auto
    
  vni 50002 l3
    rd auto  
    route-target import auto
    route-target export auto

# VRF to VNI Association
interface nve 1
  member vni 50001 associate-vrf TENANT_A
  member vni 50002 associate-vrf TENANT_B

# Inter-VRF Route Leaking (Controlled Communication)
vrf context TENANT_A
  address-family ipv4 unicast
    import vrf TENANT_B map TENANT_B_TO_A
    
route-map TENANT_B_TO_A permit 10
  match ip address prefix-list ALLOWED_NETWORKS
  
ip prefix-list ALLOWED_NETWORKS seq 10 permit 10.20.1.0/24
```

### 5.2 VXLAN Advanced Features

#### Multicast Configuration
```bash
# Multicast Configuration for BUM Traffic
# Alternative to Ingress Replication

# Enable PIM
feature pim
  
# Configure Multicast Group Range
vxlan multicast group 239.1.1.0 to 239.1.1.255

# Interface Configuration for Multicast  
interface ethernet 1/1/49
  ip pim sparse-mode
  
interface ethernet 1/1/50
  ip pim sparse-mode
  
interface loopback 0
  ip pim sparse-mode

# RP Configuration
ip pim rp-address 10.255.255.100 group-list 239.0.0.0/8

# NVE Interface Multicast Configuration
interface nve 1
  member vni 10100
    mcast-group 239.1.1.100
  member vni 10101
    mcast-group 239.1.1.101
```

#### MAC Address Learning Optimization
```bash
# MAC Address Learning Configuration

# Global MAC Aging Timer
mac address-table aging-time 300

# Per-VLAN MAC Limits  
vlan 100
  mac address limit 1000
  
vlan 101
  mac address limit 2000

# Static MAC Entries (for critical servers)
mac address-table static 0050.5685.14a5 vlan 100 interface ethernet 1/1/1

# MAC Address Notification
mac address-table notification change
mac address-table notification mac-move
```

---

## Quality of Service Configuration

### 6.1 QoS Policy Framework

#### Traffic Classification
```bash
# QoS Configuration Template
# File: qos-config-template.txt

# Class Map Definitions
class-map type qos match-any VOICE_TRAFFIC
  match dscp ef
  match cos 5

class-map type qos match-any VIDEO_TRAFFIC  
  match dscp af41
  match dscp af42
  match dscp af43
  match cos 4

class-map type qos match-any CRITICAL_DATA
  match dscp af31
  match dscp af32  
  match dscp af33
  match cos 3

class-map type qos match-any BUSINESS_DATA
  match dscp af21
  match dscp af22
  match dscp af23
  match cos 2

class-map type qos match-any SCAVENGER
  match dscp cs1
  match cos 1

# Policy Map Definition  
policy-map type qos DATACENTER_QOS_POLICY
  class VOICE_TRAFFIC
    priority level 1
    police cir 100000000 bc 8000000 conform-action transmit exceed-action drop
    
  class VIDEO_TRAFFIC
    bandwidth percent 20
    random-detect dscp-based
    
  class CRITICAL_DATA
    bandwidth percent 25
    random-detect dscp-based
    
  class BUSINESS_DATA  
    bandwidth percent 30
    random-detect dscp-based
    
  class SCAVENGER
    bandwidth percent 5
    
  class class-default
    bandwidth percent 20
    random-detect

# Interface QoS Application
interface ethernet 1/1/1
  service-policy type qos input DATACENTER_QOS_POLICY
  service-policy type qos output DATACENTER_QOS_POLICY
  priority-flow-control mode on
  priority-flow-control priority 3 no-drop
```

### 6.2 Buffer and Queuing Configuration

#### Advanced Buffer Management
```bash
# Buffer Pool Configuration
system qos

# Queue Configuration
interface ethernet 1/1/1
  priority-group 0 bandwidth percent 60
  priority-group 1 bandwidth percent 40
  
# Priority Flow Control
priority-flow-control mode on
priority-flow-control priority 3 no-drop
priority-flow-control priority 4 no-drop

# Congestion Management
random-detect dscp-based
random-detect dscp af11 minimum-threshold 40 maximum-threshold 64 drop-probability 10
random-detect dscp af12 minimum-threshold 32 maximum-threshold 64 drop-probability 20
random-detect dscp af13 minimum-threshold 24 maximum-threshold 64 drop-probability 50
```

---

## Security Configuration

### 7.1 Access Control Configuration

#### Port Security and Access Control
```bash
# Security Configuration Template
# File: security-config-template.txt

# Global Security Settings
service password-encryption
security passwords min-length 8
security passwords complexity character-sets 3

# Port Security Configuration
interface ethernet 1/1/1
  switchport port-security
  switchport port-security maximum 2
  switchport port-security violation restrict
  switchport port-security mac-address sticky
  
# 802.1X Configuration  
dot1x system-auth-control

interface ethernet 1/1/1
  dot1x pae authenticator
  dot1x authentication order dot1x mab
  dot1x authentication priority dot1x mab
  dot1x authentication timer reauthenticate 3600
  dot1x mac-auth-bypass
  dot1x guest-vlan 999
  dot1x auth-fail-vlan 998

# DHCP Snooping Configuration
ip dhcp snooping
ip dhcp snooping vlan 100-102,200-201
ip dhcp snooping information option

interface ethernet 1/1/1
  ip dhcp snooping trust
  
# Dynamic ARP Inspection
ip arp inspection vlan 100-102,200-201
ip arp inspection validate src-mac dst-mac ip

interface ethernet 1/1/1
  ip arp inspection trust

# IP Source Guard
interface ethernet 1/1/1  
  ip verify source
  ip verify source port-security
```

### 7.2 Access Control Lists

#### Comprehensive ACL Configuration
```bash
# Access Control List Configuration

# Management Access ACL
ip access-list extended MANAGEMENT_ACCESS
  10 remark "Allow SSH from management network"
  10 permit tcp 192.168.100.0/24 any eq 22
  20 remark "Allow SNMP from monitoring servers"  
  20 permit udp 192.168.100.0/24 any eq 161
  30 remark "Allow ICMP for troubleshooting"
  30 permit icmp any any
  40 remark "Allow NTP"
  40 permit udp any eq 123 any eq 123
  50 remark "Deny all other traffic"
  50 deny ip any any log

# Inter-VLAN Access Control
ip access-list extended INTER_VLAN_ACL  
  10 remark "Allow web tier to app tier"
  10 permit tcp 10.10.1.0/24 10.10.2.0/24 eq 80
  20 permit tcp 10.10.1.0/24 10.10.2.0/24 eq 443
  30 remark "Allow app tier to database tier"  
  30 permit tcp 10.10.2.0/24 10.10.3.0/24 eq 3306
  40 permit tcp 10.10.2.0/24 10.10.3.0/24 eq 5432
  50 remark "Deny inter-VLAN by default"
  50 deny ip any any log

# Apply ACLs
interface vlan 100
  ip access-group INTER_VLAN_ACL in
  
interface management 1/1/1
  ip access-group MANAGEMENT_ACCESS in
```

---

## Management Configuration

### 8.1 SNMP Configuration

#### Comprehensive SNMP Setup
```bash
# SNMP Configuration Template
# File: snmp-config-template.txt

# SNMP Community Configuration
snmp-server community readonly ro
snmp-server community readwrite rw 192.168.100.0/24

# SNMP System Information
snmp-server location "Datacenter 1, Row A, Rack 15"
snmp-server contact "Network Operations Team <netops@company.com>"

# SNMP Trap Configuration  
snmp-server enable traps
snmp-server enable traps bgp
snmp-server enable traps interface
snmp-server enable traps link
snmp-server enable traps system

# SNMP Trap Destinations
snmp-server host 192.168.100.20 version 2c public
snmp-server host 192.168.100.21 version 2c public

# SNMPv3 Configuration (Recommended)
snmp-server user admin auth sha SecurePassword123 priv aes128 PrivateKey456
snmp-server group admin-group v3 auth
snmp-server group admin-group v3 auth read all write all notify all

snmp-server view all iso included
snmp-server group admin-group v3 auth read all write all
```

### 8.2 Syslog Configuration

#### Centralized Logging Setup
```bash
# Syslog Configuration Template  
# File: syslog-config-template.txt

# Local Logging Configuration
logging buffered 16384 informational
logging monitor warnings
logging console critical

# Remote Syslog Servers
logging server 192.168.100.30 debugging vrf management
logging server 192.168.100.31 debugging vrf management

# Syslog Source Interface
logging source-interface management 1/1/1

# Syslog Facility and Severity
logging facility local1
logging timestamp

# Specific Service Logging
logging level bgp 6
logging level interface 6  
logging level system 6
logging level spanning-tree 5

# Rate Limiting to Prevent Log Flooding
logging rate-limit console 10 except critical
logging rate-limit monitor 100 except warnings
```

### 8.3 Network Time Protocol

#### NTP Configuration
```bash
# NTP Configuration Template
# File: ntp-config-template.txt

# NTP Server Configuration  
ntp server 192.168.100.10 prefer
ntp server 192.168.100.11
ntp server pool.ntp.org

# NTP Authentication (Recommended)
ntp authenticate  
ntp authentication-key 1 md5 encrypted [ENCRYPTED_KEY]
ntp authentication-key 2 md5 encrypted [ENCRYPTED_KEY]
ntp trusted-key 1
ntp trusted-key 2

# NTP Server with Authentication
ntp server 192.168.100.10 key 1
ntp server 192.168.100.11 key 2

# NTP Access Control
ntp access-group serve-only RESTRICT_NTP

ip access-list standard RESTRICT_NTP
  10 permit 192.168.100.0/24
  20 deny any

# NTP Source Interface  
ntp source management 1/1/1

# Clock Configuration
clock timezone EST -5
clock summer-time EDT recurring
```

---

## Monitoring Configuration

### 9.1 Flow Monitoring

#### NetFlow/sFlow Configuration
```bash
# Flow Monitoring Configuration Template
# File: flow-monitoring-config.txt

# sFlow Configuration (Recommended for Dell OS10)
sflow enable
sflow collector ip 192.168.100.40 port 6343 vrf management
sflow collector ip 192.168.100.41 port 6343 vrf management

# sFlow Agent Configuration
sflow agent ip 192.168.100.[SWITCH_ID] vrf management

# sFlow Interface Configuration  
interface ethernet 1/1/1
  sflow enable
  
interface ethernet 1/1/49
  sflow enable
  
interface ethernet 1/1/50  
  sflow enable

# Flow Sampling Rate (adjust based on traffic volume)
sflow sample-rate 4096

# Alternative: NetFlow Configuration
# Note: Available on select platforms
flow record NETFLOW_RECORD
  match ipv4 source address
  match ipv4 destination address  
  match transport source-port
  match transport destination-port
  match ipv4 protocol
  collect counter bytes
  collect counter packets
  
flow monitor NETFLOW_MONITOR
  record NETFLOW_RECORD
  exporter NETFLOW_EXPORTER
  
flow exporter NETFLOW_EXPORTER
  destination 192.168.100.40 vrf management
  transport udp 9996
  template refresh timeout 60
```

### 9.2 Performance Monitoring

#### Interface and System Monitoring
```bash
# Performance Monitoring Configuration

# Interface Statistics Collection
interface ethernet 1/1/1
  load-interval 30
  
# Hardware Monitoring  
environment monitor fan
environment monitor temperature
environment monitor power

# CPU and Memory Monitoring
process monitor cpu enable
process monitor memory enable

# Custom Monitoring Scripts (Python)
feature python
python bootflash:/scripts/monitor_fabric.py

# SPAN Configuration for Traffic Analysis  
monitor session 1 type local
monitor session 1 source interface ethernet 1/1/1 both
monitor session 1 destination interface ethernet 1/1/48
monitor session 1 enable
```

---

## Automation Templates

### 10.1 Zero Touch Provisioning

#### ZTP Configuration Template
```bash
# Zero Touch Provisioning Template
# File: ztp-config-template.txt

# DHCP Options for ZTP
# Configure on DHCP server:
# Option 67: bootfile name "http://192.168.100.50/ztp/[MODEL]-config.py"
# Option 150: TFTP server IP

# ZTP Python Script Template
#!/usr/bin/env python3
"""
Dell PowerSwitch ZTP Configuration Script
Automatically configures switch based on model and serial number
"""

import sys
import json
import urllib.request

def get_switch_info():
    """Get switch model and serial number"""
    # Implementation to retrieve switch information
    return {
        'model': 'S4148F-ON',
        'serial': 'ABC123456789',
        'hostname': 'DC1-LF-01'
    }

def download_config(switch_info):
    """Download configuration from central server"""
    config_url = f"http://192.168.100.50/configs/{switch_info['hostname']}.cfg"
    try:
        with urllib.request.urlopen(config_url) as response:
            return response.read().decode('utf-8')
    except Exception as e:
        print(f"Error downloading config: {e}")
        return None

def apply_config(config_text):
    """Apply configuration to switch"""
    # Write config to startup-config
    with open('/mnt/flash/startup-config', 'w') as f:
        f.write(config_text)
    
    # Restart switch to apply configuration
    import os
    os.system('reboot')

def main():
    switch_info = get_switch_info()
    config = download_config(switch_info)
    
    if config:
        apply_config(config)
        print(f"Configuration applied to {switch_info['hostname']}")
    else:
        print("Failed to download configuration")

if __name__ == "__main__":
    main()
```

### 10.2 Ansible Configuration Templates

#### Ansible Playbook for Configuration
```yaml
# Ansible Configuration Playbook
# File: deploy-powerswitch-config.yml

---
- name: Configure Dell PowerSwitch Datacenter Fabric
  hosts: dell_switches
  gather_facts: no
  vars:
    ansible_network_os: dellos10
    ansible_connection: network_cli
    
  tasks:
    - name: Configure base system settings
      dellos10_config:
        lines:
          - hostname {{ inventory_hostname }}
          - boot system primary
          - feature bgp
          - feature evpn
          - feature vxlan
          
    - name: Configure loopback interface
      dellos10_config:
        lines:
          - interface loopback 0
          - description "BGP_ROUTER_ID_VTEP"  
          - ip address {{ loopback_ip }}/32
          
    - name: Configure management interface
      dellos10_config:
        lines:
          - interface management 1/1/1
          - no shutdown
          - ip address {{ mgmt_ip }}/24
          
    - name: Configure VLANs
      dellos10_config:
        lines:
          - vlan {{ item.vlan_id }}
          - name "{{ item.name }}"
          - vn-segment {{ item.vni }}
      loop: "{{ vlans }}"
      when: device_type == "leaf"
      
    - name: Configure BGP
      dellos10_config:
        lines:
          - router bgp {{ bgp_asn }}
          - router-id {{ loopback_ip }}
          - neighbor {{ item.neighbor_ip }} remote-as {{ item.remote_asn }}
          - neighbor {{ item.neighbor_ip }} description "{{ item.description }}"
      loop: "{{ bgp_neighbors }}"
      
    - name: Save configuration
      dellos10_config:
        save_when: always
```

### 10.3 Configuration Validation Scripts

#### Python Configuration Validator
```python
#!/usr/bin/env python3
"""
Dell PowerSwitch Configuration Validator
Validates configuration against best practices and standards
"""

import re
import sys
from typing import List, Dict

class ConfigValidator:
    def __init__(self, config_file: str):
        with open(config_file, 'r') as f:
            self.config_lines = f.readlines()
    
    def validate_naming_convention(self) -> List[str]:
        """Validate hostname follows naming convention"""
        errors = []
        hostname_pattern = r'^hostname\s+[A-Z0-9]+-[A-Z]{2}-[0-9]{2}$'
        
        for line in self.config_lines:
            if line.strip().startswith('hostname'):
                if not re.match(hostname_pattern, line.strip()):
                    errors.append(f"Hostname doesn't follow naming convention: {line.strip()}")
                    
        return errors
    
    def validate_interface_descriptions(self) -> List[str]:
        """Validate all interfaces have descriptions"""
        errors = []
        in_interface = False
        interface_name = ""
        has_description = False
        
        for line in self.config_lines:
            line = line.strip()
            
            if line.startswith('interface'):
                if in_interface and not has_description:
                    errors.append(f"Interface {interface_name} missing description")
                
                in_interface = True
                interface_name = line
                has_description = False
                
            elif in_interface and line.startswith('description'):
                has_description = True
                
            elif line.startswith('exit') or (line.startswith('interface') and in_interface):
                if in_interface and not has_description:
                    errors.append(f"Interface {interface_name} missing description")
                in_interface = False
                
        return errors
    
    def validate_bgp_configuration(self) -> List[str]:
        """Validate BGP configuration"""
        errors = []
        has_router_id = False
        
        for line in self.config_lines:
            if 'router-id' in line:
                has_router_id = True
                break
                
        if not has_router_id:
            errors.append("BGP configuration missing router-id")
            
        return errors
    
    def run_all_validations(self) -> Dict[str, List[str]]:
        """Run all validations and return results"""
        return {
            'naming_convention': self.validate_naming_convention(),
            'interface_descriptions': self.validate_interface_descriptions(),
            'bgp_configuration': self.validate_bgp_configuration()
        }

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 config_validator.py <config_file>")
        sys.exit(1)
        
    validator = ConfigValidator(sys.argv[1])
    results = validator.run_all_validations()
    
    total_errors = 0
    for validation_type, errors in results.items():
        if errors:
            print(f"\n{validation_type.upper()} ERRORS:")
            for error in errors:
                print(f"  - {error}")
                total_errors += 1
    
    if total_errors == 0:
        print("Configuration validation passed!")
        sys.exit(0)
    else:
        print(f"\nTotal errors found: {total_errors}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

---

## Configuration Management Best Practices

### 11.1 Version Control Integration

#### Git-based Configuration Management
```bash
# Git Repository Structure for Configuration Management
# Repository: dell-powerswitch-configs

configs/
├── templates/
│   ├── spine-template.j2
│   ├── leaf-template.j2
│   └── common-config.j2
├── inventory/
│   ├── production/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── staging/
│       ├── hosts.yml
│       └── group_vars/
├── generated/
│   ├── production/
│   │   ├── DC1-SP-01.cfg
│   │   ├── DC1-SP-02.cfg  
│   │   ├── DC1-LF-01.cfg
│   │   └── DC1-LF-02.cfg
│   └── staging/
├── scripts/
│   ├── generate-configs.py
│   ├── deploy-configs.py
│   └── validate-configs.py
└── docs/
    ├── standards.md
    └── procedures.md
```

### 11.2 Change Management Process

#### Configuration Change Workflow
```bash
#!/bin/bash
# Configuration Change Management Script
# File: change-management.sh

# 1. Create feature branch
git checkout -b "feature/add-new-vlan-$(date +%Y%m%d)"

# 2. Modify configuration templates
vim templates/leaf-template.j2

# 3. Generate configurations
python3 scripts/generate-configs.py --environment staging

# 4. Validate configurations  
python3 scripts/validate-configs.py generated/staging/

# 5. Commit changes
git add .
git commit -m "Add VLAN 300 for new application deployment"

# 6. Create pull request
git push origin feature/add-new-vlan-$(date +%Y%m%d)

# 7. Deploy to staging after approval
ansible-playbook -i inventory/staging/hosts.yml deploy-configs.yml

# 8. Deploy to production after testing
ansible-playbook -i inventory/production/hosts.yml deploy-configs.yml

# 9. Merge to main branch
git checkout main
git merge feature/add-new-vlan-$(date +%Y%m%d)
```

---

**Document Information**
- **Version**: 1.0
- **Last Updated**: Current Date
- **Owner**: Network Engineering Team
- **Review Cycle**: Quarterly or with major OS updates
- **Distribution**: Implementation teams, operations staff

**Usage Guidelines**
1. Always customize placeholder values before deployment
2. Test all configurations in lab environment first
3. Follow change management procedures for production deployments
4. Keep configuration templates updated with best practices
5. Document any deviations from standard templates

**Related Documents**
- Dell PowerSwitch Hardware Documentation
- Dell OS10 Configuration Guide
- Network Architecture Design Document
- Security Policy Framework
- Change Management Procedures

*These configuration templates are provided as a starting point and should be customized for specific environment requirements. Always validate configurations before production deployment.*