# Configuration Templates - Cisco SD-WAN Enterprise

## Overview

This document provides configuration templates for Cisco SD-WAN Enterprise deployment.

---

## vManage Configuration

### Initial Setup
```bash
# Basic system configuration
configure
system
 host-name vmanage01
 system-ip 192.168.1.1
 site-id 100
 organization-name "Company-SDWAN"
 vbond 198.51.100.1
commit
```

### Device Templates
```yaml
# Branch Router Template
template:
  name: "Branch-Router-Template"
  device_type: "vedge-cloud"
  variables:
    system_ip: "{{branch_system_ip}}"
    site_id: "{{branch_site_id}}"
    hostname: "{{branch_hostname}}"
  
  features:
    - vpn_interface_ethernet
    - ospf
    - security_policy
    - qos_policy
```

---

## vBond Configuration

### Orchestrator Setup
```bash
# vBond basic configuration
configure
system
 host-name vbond01
 system-ip 192.168.1.2
 site-id 100
 organization-name "Company-SDWAN"
 vbond 198.51.100.1 port 12346
commit
```

### Certificate Management
```bash
# Install root CA certificate
request root-cert-chain install /home/admin/rootCA.pem

# Generate CSR
request certificate install /home/admin/vbond.crt
```

---

## vSmart Configuration

### Controller Setup
```bash
# vSmart basic configuration
configure
system
 host-name vsmart01
 system-ip 192.168.1.3
 site-id 100
 organization-name "Company-SDWAN"
 vbond 198.51.100.1
commit
```

### Policy Configuration
```bash
# Application-aware routing policy
policy
 lists
  site-list BRANCH_SITES
   site-id 200-299
  !
  app-list VOICE_APPS
   app skype_for_business
   app webex
  !
 !
 application-visibility
 control-policy BRANCH_CONTROL
  sequence 10
   match
    site-list BRANCH_SITES
   !
   action accept
  !
 !
 data-policy VOICE_PRIORITY
  vpn-list VPN1
   sequence 10
    match
     app-list VOICE_APPS
    !
    action accept
     class voice
    !
   !
  !
 !
commit
```

---

## Branch Router Configuration

### WAN Interface Configuration
```bash
# Internet interface
vpn 0
 interface ge0/0
  ip address 203.0.113.10/24
  tunnel-interface
   encapsulation ipsec
   color biz-internet
   max-control-connections 2
   vmanage-connection-preference 5
   port-hop
   low-bandwidth-link
  !
  no shutdown
 !
 ip route 0.0.0.0/0 203.0.113.1
!

# MPLS interface
vpn 0
 interface ge0/1
  ip address 10.10.10.10/30
  tunnel-interface
   encapsulation ipsec
   color mpls
   max-control-connections 2
   vmanage-connection-preference 8
  !
  no shutdown
 !
 ip route 0.0.0.0/0 10.10.10.9
!
```

### LAN Interface Configuration
```bash
# LAN interface
vpn 1
 interface ge0/2
  ip address 192.168.100.1/24
  no shutdown
 !
 interface ge0/3
  ip address 192.168.101.1/24
  no shutdown
 !
!
```

### Security Configuration
```bash
# Zone-based firewall
security
 zonebind-service
 zone LAN_ZONE
  interface ge0/2
  interface ge0/3
 !
 zone WAN_ZONE
  interface ge0/0
  interface ge0/1
 !
 zone-pair LAN_WAN_ZONEPAIR
  source-zone LAN_ZONE
  destination-zone WAN_ZONE
  zone-policy LAN_WAN_POLICY
 !
 zone-policy LAN_WAN_POLICY
  sequence 1
   match
    source-data-prefix-list LAN_SUBNETS
   !
   action inspect
  !
 !
!
```

---

## QoS Configuration

### Traffic Classes
```bash
# QoS policy
policy
 class-map
  class voice
   match dscp 46
  !
  class video
   match dscp 34
  !
  class business
   match dscp 26
  !
 !
 policy-map QOS_POLICY
  class voice
   priority percent 20
  !
  class video
   bandwidth percent 30
  !
  class business
   bandwidth percent 25
  !
  class class-default
   bandwidth percent 25
  !
 !
!
```

### Application-Aware Routing
```bash
# App-route policy
policy
 app-route-policy BRANCH_APP_ROUTE
  vpn-list VPN1
   sequence 1
    match
     app-list VOICE_APPS
    !
    action
     sla-class VOICE_SLA
     preferred-color mpls
     backup-preferred-color biz-internet
    !
   !
   sequence 2
    match
     app-list VIDEO_APPS
    !
    action
     sla-class VIDEO_SLA
     preferred-color mpls biz-internet
    !
   !
  !
 !
!
```

---

## Monitoring Configuration

### SNMP Setup
```bash
# SNMP configuration
snmp
 version v3
 group ADMIN_GROUP v3 priv
 user admin ADMIN_GROUP v3 auth sha AdminAuth123 priv aes AdminPriv123
 target 192.168.1.100 vpn 1 user admin tag config
 community public view MIB_VIEW ro
 view MIB_VIEW oid 1 include
!
```

### Syslog Configuration
```bash
# Syslog configuration
logging
 disk enable
 disk file rotate 10
 disk file size 10
 server 192.168.1.200
  vpn 1
  source-interface ge0/2
  priority informational
 !
!
```

---

## High Availability Configuration

### vSmart Redundancy
```bash
# Multiple vSmart controllers
system
 vbond 198.51.100.1
 control-session-pps 300
 admin-tech-on-failure
 max-omp-sessions 10
!
```

### Site Redundancy
```bash
# Dual WAN configuration
vpn 0
 interface ge0/0
  tunnel-interface
   color biz-internet
   restrict
  !
 !
 interface ge0/1
  tunnel-interface
   color mpls
   restrict
  !
 !
!
```

---

## Integration Templates

### API Configuration
```python
# vManage API example
import requests
import json

class vManageAPI:
    def __init__(self, host, username, password):
        self.host = host
        self.username = username
        self.password = password
        self.session = requests.Session()
        self.login()
    
    def login(self):
        url = f"https://{self.host}/j_security_check"
        payload = {
            'j_username': self.username,
            'j_password': self.password
        }
        response = self.session.post(url, data=payload, verify=False)
        
    def get_devices(self):
        url = f"https://{self.host}/dataservice/device"
        response = self.session.get(url, verify=False)
        return response.json()
```

### Automation Scripts
```bash
#!/bin/bash
# Device onboarding script

VMANAGE_IP="192.168.1.1"
DEVICE_IP="$1"
SITE_ID="$2"

echo "Onboarding device $DEVICE_IP at site $SITE_ID"

# Generate bootstrap configuration
curl -k -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "deviceIP": "'$DEVICE_IP'",
    "siteId": "'$SITE_ID'",
    "templateName": "Branch-Router-Template"
  }' \
  "https://$VMANAGE_IP/dataservice/template/device/config/attachfeature"

echo "Device onboarding initiated"
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Network Engineering Team