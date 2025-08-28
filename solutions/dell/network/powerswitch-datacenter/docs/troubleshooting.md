# Dell PowerSwitch Datacenter Troubleshooting Guide

## Executive Summary

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common issues in Dell PowerSwitch datacenter networking environments. It covers hardware, software, protocol, and performance-related problems with detailed resolution procedures.

## Table of Contents

1. [Troubleshooting Methodology](#troubleshooting-methodology)
2. [Hardware Issues](#hardware-issues)
3. [Software and Configuration Issues](#software-and-configuration-issues)
4. [Protocol and Connectivity Issues](#protocol-and-connectivity-issues)
5. [Performance Issues](#performance-issues)
6. [VXLAN and EVPN Issues](#vxlan-and-evpn-issues)
7. [Management and Monitoring Issues](#management-and-monitoring-issues)
8. [Common Error Messages](#common-error-messages)
9. [Diagnostic Tools and Commands](#diagnostic-tools-and-commands)
10. [Emergency Procedures](#emergency-procedures)

## Troubleshooting Methodology

### Systematic Approach

#### Problem Classification Framework

```
Troubleshooting Classification:
┌─────────────────────────────────────────────────────────────────┐
│                    Problem Classification                       │
├─────────────────────────────────────────────────────────────────┤
│  Severity Level    │ Impact          │ Response Time           │
│  ─────────────────┼─────────────────┼─────────────────────────│
│  Critical (P1)     │ Service Down    │ Immediate (15 minutes) │
│  High (P2)         │ Major Impact    │ 2 hours                 │
│  Medium (P3)       │ Minor Impact    │ 8 hours                 │
│  Low (P4)          │ Enhancement     │ 24-48 hours             │
└─────────────────────────────────────────────────────────────────┘

Problem Categories:
1. Hardware failures and errors
2. Software bugs and configuration issues
3. Protocol convergence and routing problems
4. Performance degradation and bottlenecks
5. Security and access issues
6. Management and monitoring problems
```

#### Diagnostic Process

```
Standard Diagnostic Workflow:

1. Problem Identification
   ├── Gather symptoms and error messages
   ├── Identify affected systems and users
   ├── Determine timeline of issue onset
   └── Collect baseline performance data

2. Information Gathering
   ├── Review system logs and alerts
   ├── Check recent changes and deployments
   ├── Verify hardware status indicators
   └── Assess network topology impact

3. Root Cause Analysis
   ├── Isolate problem domain
   ├── Test hypotheses systematically
   ├── Use diagnostic tools and commands
   └── Correlate multiple data sources

4. Solution Implementation
   ├── Plan remediation approach
   ├── Implement fixes incrementally
   ├── Verify resolution effectiveness
   └── Document solution for future reference

5. Post-Resolution Activities
   ├── Conduct post-mortem analysis
   ├── Update documentation and procedures
   ├── Implement preventive measures
   └── Communicate resolution to stakeholders
```

### Essential Diagnostic Commands

#### Basic System Information

```bash
# Switch basic information
show version
show system brief
show inventory
show environment

# Interface status and statistics
show interface status
show interface brief
show interface counters
show interface errors

# Protocol status
show ip route summary
show bgp summary
show bgp evpn summary
show vxlan interface

# System resources
show processes cpu
show processes memory
show system resources
show logging
```

## Hardware Issues

### Power and Environmental

#### Power Supply Problems

```
Power Supply Troubleshooting:

Symptoms:
- Switch unexpectedly powers off
- Power LED indicators showing faults
- Partial system functionality
- Environmental alarms

Diagnostic Commands:
dell(config)# show environment psu
dell(config)# show environment power
dell(config)# show environment fan
dell(config)# show logging | grep -i power

Common Causes and Solutions:

1. Power Supply Unit (PSU) Failure
   Symptoms: PSU status LED red, error messages in logs
   Resolution:
   ├── Check power cable connections
   ├── Verify power source voltage and capacity
   ├── Replace faulty PSU (hot-swappable)
   └── Monitor environmental logs post-replacement

2. Insufficient Power Capacity
   Symptoms: Random shutdowns under load, performance issues
   Resolution:
   ├── Calculate total power requirements
   ├── Check power budget vs consumption
   ├── Upgrade power infrastructure if needed
   └── Implement power monitoring

3. Power Distribution Problems
   Symptoms: Intermittent power issues, voltage fluctuations
   Resolution:
   ├── Check PDU and circuit breaker capacity
   ├── Verify power cable integrity
   ├── Balance load across multiple power feeds
   └── Install UPS for power quality improvement

Power Monitoring Commands:
dell(config)# show environment power detail
dell(config)# show environment power history
dell(config)# show system power-consumption
```

#### Cooling and Temperature Issues

```
Temperature Management Troubleshooting:

Symptoms:
- High temperature alarms
- Fan speed increasing significantly
- System performance throttling
- Unexpected shutdowns

Diagnostic Approach:
1. Check Environmental Status
   dell(config)# show environment temperature
   dell(config)# show environment fan
   dell(config)# show environment airflow

2. Identify Hot Spots
   - Check ambient temperature
   - Verify airflow direction
   - Inspect for obstructions
   - Monitor per-component temperatures

Common Issues and Resolutions:

1. Blocked Airflow
   Symptoms: High inlet/outlet temperature differential
   Resolution:
   ├── Clear cable management obstructions
   ├── Ensure proper rack spacing
   ├── Verify hot/cold aisle containment
   └── Check for dust accumulation

2. Fan Failure
   Symptoms: Fan speed alarms, localized hot spots
   Resolution:
   ├── Identify failed fan modules
   ├── Replace faulty fan units
   ├── Verify fan direction and operation
   └── Monitor temperature post-replacement

3. Datacenter HVAC Issues
   Symptoms: Ambient temperature too high, humidity issues
   Resolution:
   ├── Check datacenter environmental systems
   ├── Verify HVAC setpoints and operation
   ├── Implement supplemental cooling if needed
   └── Coordinate with facilities team

Temperature Thresholds:
- Normal operation: 0°C to 45°C (32°F to 113°F)
- Warning threshold: 50°C (122°F)
- Critical threshold: 65°C (149°F)
- Shutdown threshold: 70°C (158°F)
```

### Interface and Connectivity Issues

#### Port and Link Problems

```
Interface Troubleshooting Workflow:

Physical Layer Issues:
1. Link Down Problems
   Symptoms: Interface status shows "down/down"
   
   Diagnostic Commands:
   dell(config)# show interface ethernet 1/1/1 status
   dell(config)# show interface ethernet 1/1/1 counters
   dell(config)# show interface ethernet 1/1/1 transceiver
   
   Resolution Steps:
   ├── Check physical cable connections
   ├── Verify cable type and specifications
   ├── Test with known good cable
   ├── Check SFP/QSFP module status
   ├── Verify port configuration matches requirements
   └── Check for hardware port failures

2. Link Flapping Issues
   Symptoms: Interface goes up/down repeatedly
   
   Diagnostic Approach:
   ├── Monitor link state changes
   ├── Check error counters and statistics
   ├── Verify power levels on optical connections
   ├── Test cable integrity
   └── Check for electromagnetic interference

   Commands for Link Flapping:
   dell(config)# show interface ethernet 1/1/1 counters errors
   dell(config)# show logging | grep "Interface.*up\|Interface.*down"
   dell(config)# show interface ethernet 1/1/1 transceiver detail

3. Speed and Duplex Mismatches
   Symptoms: High collision rates, poor performance
   
   Resolution:
   ├── Verify auto-negotiation settings
   ├── Manually configure speed/duplex if needed
   ├── Check connected device configuration
   └── Use consistent settings on both ends

Speed/Duplex Configuration:
dell(config)# interface ethernet 1/1/1
dell(config-if)# speed 10000
dell(config-if)# negotiation auto
dell(config-if)# no shutdown
```

#### Transceiver and Optics Issues

```
Optical Transceiver Troubleshooting:

Common Optical Issues:
1. SFP/QSFP Module Problems
   Symptoms: No link light, high error rates
   
   Diagnostic Commands:
   dell(config)# show interface transceiver
   dell(config)# show interface ethernet 1/1/1 transceiver detail
   dell(config)# show interface ethernet 1/1/1 optical-power
   
   Resolution Steps:
   ├── Check module compatibility and certification
   ├── Verify insertion and seating
   ├── Clean optical connectors
   ├── Check power levels (Tx/Rx)
   ├── Replace module if faulty
   └── Verify fiber patch cable quality

2. Optical Power Issues
   Symptoms: Link errors, intermittent connectivity
   
   Power Level Analysis:
   - Check transmitted power (Tx Power)
   - Verify received power (Rx Power)
   - Compare against module specifications
   - Calculate link budget and loss

   Acceptable Power Ranges (typical):
   ┌─────────────────────────────────────────────────────────────────┐
   │                    Optical Power Specifications                 │
   ├─────────────────────────────────────────────────────────────────┤
   │  Module Type      │ Tx Power (dBm) │ Rx Sensitivity (dBm)     │
   │  ────────────────┼────────────────┼─────────────────────────│
   │  1000Base-SX      │ -9.5 to -3     │ -17 to -3               │
   │  1000Base-LX      │ -9.5 to -3     │ -19 to -3               │
   │  10GBase-SR       │ -7.3 to -1     │ -11.1 to 0.5            │
   │  10GBase-LR       │ -8.2 to 0.5    │ -14.4 to 0.5            │
   │  25GBase-SR       │ -6 to 2.4      │ -10.3 to 2.4            │
   │  100GBase-SR4     │ -7.5 to 2.4    │ -9.9 to 2.4             │
   └─────────────────────────────────────────────────────────────────┘

3. Fiber Optic Cable Issues
   Symptoms: Intermittent errors, performance degradation
   
   Cable Testing Procedure:
   ├── Visual inspection for damage
   ├── Optical power meter testing
   ├── OTDR (Optical Time Domain Reflectometer) analysis
   ├── Connector cleanliness verification
   └── End-to-end continuity testing

Cleaning Procedure for Optical Connectors:
1. Power down interfaces
2. Remove patch cables
3. Inspect connectors with magnification
4. Clean with optical-grade cleaning supplies
5. Re-terminate if necessary
6. Verify cleanliness before reconnection
```

### Hardware Monitoring and Diagnostics

#### Hardware Health Monitoring

```
Proactive Hardware Monitoring:

Environmental Monitoring Setup:
dell(config)# snmp-server enable
dell(config)# snmp-server community public ro
dell(config)# logging server 192.168.1.100
dell(config)# environment temperature threshold warning 45
dell(config)# environment temperature threshold critical 55

System Health Checks:
1. Daily Health Check Commands
   #!/bin/bash
   # Daily hardware health script
   
   echo "=== Dell PowerSwitch Health Check ==="
   date
   
   echo "Environment Status:"
   show environment | grep -E "(FAIL|ERROR|WARN)"
   
   echo "Interface Status:"
   show interface brief | grep -v "up.*up"
   
   echo "System Resources:"
   show processes cpu | head -10
   show processes memory | head -10
   
   echo "Error Summary:"
   show logging | grep -i error | tail -20

2. Automated Monitoring Integration
   ├── SNMP monitoring for environmental data
   ├── Syslog integration for real-time alerts
   ├── REST API for custom monitoring solutions
   └── Dell OpenManage integration

Critical SNMP OIDs for Monitoring:
┌─────────────────────────────────────────────────────────────────┐
│                    Hardware Monitoring OIDs                    │
├─────────────────────────────────────────────────────────────────┤
│  Component        │ OID                    │ Description        │
│  ────────────────┼────────────────────────┼────────────────────│
│  Temperature      │ 1.3.6.1.4.1.674.10895.│ Chassis temp       │
│  Fan Status       │ 1.3.6.1.4.1.674.10895.│ Fan operational    │
│  Power Supply     │ 1.3.6.1.4.1.674.10895.│ PSU status         │
│  Interface Status │ 1.3.6.1.2.1.2.2.1.8   │ Interface state    │
│  CPU Utilization  │ 1.3.6.1.4.1.674.10895.│ CPU usage          │
└─────────────────────────────────────────────────────────────────┘
```

## Software and Configuration Issues

### Operating System Issues

#### Dell OS10 Boot Problems

```
Boot and System Issues:

1. Boot Failure Scenarios
   Symptoms: Switch not booting, stuck at boot prompt
   
   Recovery Procedures:
   ├── ONIE (Open Network Install Environment) recovery
   ├── USB-based OS installation
   ├── TFTP-based network boot
   └── Factory reset procedures

   ONIE Recovery Steps:
   1. Access ONIE boot menu during startup
   2. Select "ONIE: Rescue" option
   3. Use network or USB installation method
   4. Restore configuration from backup

2. Configuration Corruption
   Symptoms: Configuration commands not working, unexpected behavior
   
   Resolution Approach:
   ├── Boot to previous working configuration
   ├── Factory reset and restore from backup
   ├── Incremental configuration restoration
   └── Validate configuration syntax

   Configuration Recovery Commands:
   dell# copy startup-config backup-config
   dell# erase startup-config
   dell# reload
   dell# copy backup-config startup-config

3. Software Upgrade Issues
   Symptoms: Boot failures after upgrade, feature not working
   
   Upgrade Recovery:
   ├── Boot to previous firmware version
   ├── Verify image integrity and compatibility
   ├── Perform clean installation if needed
   └── Restore configuration carefully

   Firmware Management:
   dell# show boot
   dell# boot system primary
   dell# boot system secondary
   dell# copy running-config startup-config
```

#### Configuration Management Problems

```
Configuration Issues and Resolution:

1. Syntax Errors and Invalid Commands
   Symptoms: Configuration commands rejected, parsing errors
   
   Diagnostic Approach:
   ├── Use configuration validation tools
   ├── Check command syntax in documentation
   ├── Test configuration changes incrementally
   └── Maintain configuration version control

   Validation Commands:
   dell(config)# do show running-config | display set
   dell(config)# validate
   dell(config)# commit check

2. Configuration Conflicts
   Symptoms: Features not working as expected, conflicting settings
   
   Resolution Steps:
   ├── Review configuration for conflicts
   ├── Check feature compatibility matrix
   ├── Resolve resource allocation conflicts
   └── Apply configuration in proper order

   Common Conflicts:
   - VLAN ID conflicts across features
   - IP address overlaps
   - Resource allocation conflicts
   - Feature interdependency issues

3. Configuration Loss or Corruption
   Symptoms: Configuration reverted, partial loss of settings
   
   Prevention and Recovery:
   ├── Regular configuration backups
   ├── Version control system integration
   ├── Configuration change tracking
   └── Automated restoration procedures

   Backup and Restore Procedures:
   # Automated backup script
   #!/bin/bash
   DATE=$(date +%Y%m%d_%H%M%S)
   BACKUP_DIR="/var/backups/switch-configs"
   
   # Create backup directory
   mkdir -p $BACKUP_DIR
   
   # Backup configuration
   scp admin@switch-ip:/mnt/flash/startup-config \
       $BACKUP_DIR/switch-config-$DATE.cfg
   
   # Verify backup
   if [ $? -eq 0 ]; then
       echo "Backup successful: $BACKUP_DIR/switch-config-$DATE.cfg"
   else
       echo "Backup failed for switch-ip"
   fi
```

### License and Feature Issues

#### Software Licensing Problems

```
Licensing Troubleshooting:

1. License Validation Issues
   Symptoms: Features disabled, license warnings
   
   Diagnostic Commands:
   dell# show license
   dell# show license status
   dell# show license usage
   dell# show feature
   
   Resolution Steps:
   ├── Verify license installation
   ├── Check license expiration dates
   ├── Validate license compatibility
   └── Contact Dell licensing support

2. Feature Availability Problems
   Symptoms: Commands not available, feature disabled messages
   
   Feature Verification:
   dell# show feature-set
   dell# show license feature
   dell# show version | grep -i features
   
   Common Feature Requirements:
   ┌─────────────────────────────────────────────────────────────────┐
   │                    Feature Licensing Matrix                     │
   ├─────────────────────────────────────────────────────────────────┤
   │  Feature              │ License Required   │ Dependencies       │
   │  ────────────────────┼────────────────────┼────────────────────│
   │  BGP                  │ Advanced           │ Base routing       │
   │  VXLAN                │ Advanced           │ Base L2            │
   │  BGP EVPN             │ Advanced           │ BGP + VXLAN        │
   │  SmartFabric Services │ Premium            │ Advanced features  │
   │  Flow Monitoring      │ Advanced           │ Base switching     │
   └─────────────────────────────────────────────────────────────────┘

3. License Installation and Activation
   Symptoms: New licenses not recognized, activation failures
   
   Installation Procedure:
   ├── Obtain license file from Dell
   ├── Transfer license to switch
   ├── Install and activate license
   └── Verify license functionality

   License Installation Commands:
   dell# copy scp://user@server/path/license.xml license:
   dell# license install license:license.xml
   dell# license activate
   dell# reload
```

## Protocol and Connectivity Issues

### BGP and Routing Problems

#### BGP Session Issues

```
BGP Troubleshooting Methodology:

1. BGP Session Establishment Problems
   Symptoms: BGP neighbors not establishing, stuck in Active/Connect state
   
   Diagnostic Commands:
   dell# show bgp summary
   dell# show bgp neighbors 10.1.1.1 detail
   dell# show bgp neighbors 10.1.1.1 advertised-routes
   dell# show bgp neighbors 10.1.1.1 received-routes
   dell# debug bgp events
   dell# debug bgp keepalive
   
   Common Issues and Solutions:
   
   a) TCP Connectivity Problems
      Verification Steps:
      ├── Test Layer 3 connectivity (ping)
      ├── Check TCP port 179 accessibility
      ├── Verify firewall rules
      └── Check routing to BGP neighbor
      
      dell# ping 10.1.1.1 source 10.1.1.2
      dell# telnet 10.1.1.1 179
      dell# show ip route 10.1.1.1
   
   b) BGP Configuration Mismatches
      Common Mismatches:
      ├── AS number mismatch
      ├── Authentication failures
      ├── Incorrect neighbor IP addresses
      └── Timer inconsistencies
      
      Configuration Verification:
      dell# show running-config | section bgp
      dell# show bgp neighbors | grep "remote AS"
      dell# show bgp neighbors | grep -i authentication

2. BGP Route Advertisement Issues
   Symptoms: Routes not being advertised or received properly
   
   Diagnostic Approach:
   ├── Check BGP table contents
   ├── Verify route-map and filter configurations
   ├── Examine BGP attributes
   └── Validate network statements
   
   Route Analysis Commands:
   dell# show bgp ipv4 unicast
   dell# show bgp ipv4 unicast 192.168.1.0/24
   dell# show bgp neighbors 10.1.1.1 routes
   dell# show bgp neighbors 10.1.1.1 advertised-routes
   dell# show ip route bgp

BGP Configuration Example:
router bgp 65001
 bgp router-id 10.255.255.1
 neighbor 10.1.1.2 remote-as 65100
 neighbor 10.1.1.2 description "Spine-01"
 neighbor 10.1.1.2 timers 3 9
 neighbor 10.1.1.2 maximum-paths 4
 !
 address-family ipv4 unicast
  neighbor 10.1.1.2 activate
  network 10.255.255.1/32
  maximum-paths 4
 exit-address-family
```

#### BGP EVPN Troubleshooting

```
BGP EVPN Specific Issues:

1. EVPN Session Problems
   Symptoms: EVPN routes not exchanged, L2/L3 VPN services failing
   
   EVPN Diagnostic Commands:
   dell# show bgp l2vpn evpn summary
   dell# show bgp l2vpn evpn
   dell# show bgp l2vpn evpn route-type 2
   dell# show bgp l2vpn evpn route-type 5
   dell# show bgp l2vpn evpn rd 10.255.255.1:100
   
   Common EVPN Issues:
   
   a) Address Family Configuration
      Verify EVPN address family configuration:
      router bgp 65001
       neighbor 10.1.1.2 remote-as 65100
       !
       address-family l2vpn evpn
        neighbor 10.1.1.2 activate
        neighbor 10.1.1.2 send-community extended
       exit-address-family
   
   b) Route Distinguisher and Route Target Issues
      Common Problems:
      ├── Duplicate RD values
      ├── Missing or incorrect RT values
      ├── Import/export policy mismatches
      └── VNI to RD/RT mapping errors
      
      Verification Commands:
      dell# show bgp l2vpn evpn rd
      dell# show evpn vni
      dell# show evpn mac vni 10100

2. VXLAN Integration Problems
   Symptoms: VXLAN tunnels not forming, traffic not forwarding
   
   VXLAN Diagnostics:
   dell# show vxlan interface
   dell# show vxlan tunnel
   dell# show vxlan address-table
   dell# show interface vxlan 1
   
   Integration Verification:
   ├── Confirm VTEP configuration
   ├── Verify VNI assignments
   ├── Check NVE interface status
   └── Validate EVPN-VXLAN binding

EVPN VXLAN Configuration Example:
interface nve 1
 source-interface loopback 0
 member vni 10100
  ingress-replication protocol bgp
 member vni 10200
  ingress-replication protocol bgp

router bgp 65001
 address-family l2vpn evpn
  advertise-all-vni
```

### VXLAN and EVPN Issues

#### VXLAN Tunnel Problems

```
VXLAN Troubleshooting Guide:

1. VTEP Connectivity Issues
   Symptoms: VXLAN tunnels not establishing, no remote VTEP discovery
   
   Diagnostic Steps:
   ├── Verify underlay connectivity between VTEPs
   ├── Check VTEP IP address reachability
   ├── Validate UDP port 4789 connectivity
   └── Confirm multicast group configuration
   
   VTEP Diagnostic Commands:
   dell# show vxlan tunnel
   dell# show vxlan vtep
   dell# show interface nve 1
   dell# ping 10.254.254.2 source 10.254.254.1
   dell# show ip route 10.254.254.2

2. VNI and VLAN Mapping Issues
   Symptoms: Traffic not switching between VNIs, VLAN mapping problems
   
   Verification Commands:
   dell# show vxlan vni
   dell# show evpn vni detail
   dell# show bridge domain
   dell# show mac address-table
   dell# show evpn mac vni 10100
   
   Common Mapping Problems:
   ├── VNI to VLAN inconsistencies
   ├── Bridge domain configuration errors
   ├── EVPN instance mismatches
   └── MAC learning issues

VNI Configuration Example:
interface vlan 100
 description "Web Servers VLAN"
 
evpn
 vni 10100 l2
  rd 10.255.255.1:100
  route-target import 100:100
  route-target export 100:100
  
interface nve 1
 member vni 10100 associate-vrf
  suppress-arp
  mcast-group 239.1.1.100

3. MAC Address Learning Problems
   Symptoms: MAC addresses not learned, traffic flooding excessively
   
   MAC Learning Diagnostics:
   dell# show mac address-table
   dell# show mac address-table vni 10100
   dell# show evpn mac vni 10100 detail
   dell# show bgp l2vpn evpn route-type 2
   
   Resolution Approaches:
   ├── Verify MAC learning configuration
   ├── Check for MAC mobility issues
   ├── Validate ARP suppression settings
   └── Monitor MAC advertisement in BGP
```

#### EVPN Route Issues

```
EVPN Route Type Troubleshooting:

1. Type 2 Route Issues (MAC/IP Advertisement)
   Symptoms: Host MAC/IP not advertised, reachability problems
   
   Diagnostic Commands:
   dell# show bgp l2vpn evpn route-type 2
   dell# show bgp l2vpn evpn route-type 2 [mac-address]
   dell# show evpn mac vni [vni-id]
   dell# show arp vrf [vrf-name]
   
   Common Problems:
   ├── MAC address not learned locally
   ├── ARP entry missing or incorrect
   ├── Route target filtering issues
   └── BGP EVPN session problems

2. Type 3 Route Issues (Inclusive Multicast Ethernet Tag)
   Symptoms: BUM traffic not handled properly, flooding issues
   
   Verification:
   dell# show bgp l2vpn evpn route-type 3
   dell# show vxlan flood vtep
   dell# show evpn vni [vni-id] detail
   
   Resolution Steps:
   ├── Verify ingress replication configuration
   ├── Check multicast group assignments
   ├── Validate VTEP list for flooding
   └── Monitor BUM traffic patterns

3. Type 5 Route Issues (IP Prefix Route)
   Symptoms: Inter-VNI routing not working, subnet isolation
   
   Diagnostic Approach:
   dell# show bgp l2vpn evpn route-type 5
   dell# show ip route vrf [vrf-name]
   dell# show evpn vrf [vrf-name]
   dell# show interface vlan [vlan-id]
   
   Common Causes:
   ├── L3 VNI not configured properly
   ├── VRF import/export RT mismatch
   ├── IRB interface issues
   └── Anycast gateway problems

EVPN Type 5 Configuration:
vrf context tenant-1
 rd 10.255.255.1:1001
 route-target import 1001:1001
 route-target export 1001:1001
 address-family ipv4 unicast
  route-target import 1001:1001
  route-target export 1001:1001

evpn
 vni 50001 l3
  rd 10.255.255.1:50001
  route-target import 50001:50001
  route-target export 50001:50001

interface nve 1
 member vni 50001 associate-vrf tenant-1
```

## Performance Issues

### Network Performance Degradation

#### Throughput Problems

```
Performance Troubleshooting Methodology:

1. Bandwidth Utilization Analysis
   Symptoms: Slow network performance, timeouts, packet loss
   
   Performance Monitoring Commands:
   dell# show interface ethernet 1/1/1 counters
   dell# show interface ethernet 1/1/1 counters rate
   dell# show processes cpu
   dell# show processes memory
   dell# show qos interface ethernet 1/1/1
   
   Utilization Thresholds:
   ┌─────────────────────────────────────────────────────────────────┐
   │                    Performance Thresholds                       │
   ├─────────────────────────────────────────────────────────────────┤
   │  Metric               │ Normal    │ Warning  │ Critical          │
   │  ────────────────────┼───────────┼──────────┼───────────────────│
   │  Interface Util       │ <70%      │ 70-85%   │ >85%              │
   │  CPU Utilization      │ <60%      │ 60-80%   │ >80%              │
   │  Memory Utilization   │ <70%      │ 70-85%   │ >85%              │
   │  Packet Loss Rate     │ <0.01%    │ 0.01-0.1%│ >0.1%             │
   │  Buffer Utilization   │ <60%      │ 60-80%   │ >80%              │
   └─────────────────────────────────────────────────────────────────┘

2. Latency Issues
   Symptoms: High response times, application timeouts
   
   Latency Measurement:
   ├── End-to-end ping tests
   ├── Traceroute analysis
   ├── Application-specific timing
   └── Hardware latency measurement
   
   Latency Diagnostic Commands:
   dell# ping 10.1.1.2 repeat 100
   dell# traceroute 10.1.1.2
   dell# show interface ethernet 1/1/1 counters detail
   dell# show hardware forwarding latency

3. Packet Loss Investigation
   Symptoms: Retransmissions, connection drops, poor application performance
   
   Packet Loss Analysis:
   dell# show interface counters errors
   dell# show interface counters drops
   dell# show qos interface statistics
   dell# show hardware buffers
   
   Common Causes:
   ├── Interface errors (CRC, framing)
   ├── Buffer overflows
   ├── QoS policy drops
   └── Hardware forwarding limitations
```

#### Quality of Service Issues

```
QoS Troubleshooting:

1. Traffic Classification Problems
   Symptoms: Priority traffic not handled correctly, wrong queue assignment
   
   QoS Verification:
   dell# show qos interface ethernet 1/1/1 policy-map
   dell# show qos interface ethernet 1/1/1 statistics
   dell# show class-map
   dell# show policy-map
   
   Classification Debug:
   dell# debug qos packet ethernet 1/1/1
   dell# show qos interface ethernet 1/1/1 class [class-name]

2. Queue Management Issues
   Symptoms: Queue congestion, unfair bandwidth distribution
   
   Queue Analysis:
   dell# show qos interface ethernet 1/1/1 queue-stats
   dell# show hardware queue statistics
   dell# show interface ethernet 1/1/1 priority-flow-control
   
   Buffer Management:
   dell# show hardware buffers interface ethernet 1/1/1
   dell# show qos interface ethernet 1/1/1 buffer-usage

QoS Configuration Example:
class-map match-any VOICE-TRAFFIC
 match dscp ef
 
class-map match-any VIDEO-TRAFFIC
 match dscp af41
 
policy-map QOS-POLICY
 class VOICE-TRAFFIC
  priority
  police cir 100000000
 class VIDEO-TRAFFIC
  bandwidth percent 30
 class class-default
  bandwidth percent 40

interface ethernet 1/1/1
 service-policy input QOS-POLICY
 service-policy output QOS-POLICY

3. Congestion Management
   Symptoms: Buffer overflows, tail drops, performance degradation
   
   Congestion Analysis:
   ├── Monitor buffer utilization
   ├── Check queue depth and drops
   ├── Analyze traffic patterns
   └── Implement congestion avoidance

   Congestion Avoidance Configuration:
   dell(config)# interface ethernet 1/1/1
   dell(config-if)# random-detect
   dell(config-if)# queue-limit 1000
```

### CPU and Memory Issues

#### High CPU Utilization

```
CPU Performance Troubleshooting:

1. Process Analysis
   Symptoms: Slow CLI response, delayed convergence, timeouts
   
   CPU Monitoring:
   dell# show processes cpu
   dell# show processes cpu detail
   dell# show processes cpu history
   dell# top
   
   Process Investigation:
   ├── Identify high CPU processes
   ├── Determine if temporary or persistent
   ├── Correlate with network events
   └── Check for software bugs

2. Interrupt and Context Switching
   Symptoms: High interrupt rates, context switching overhead
   
   System Analysis:
   dell# show hardware interrupts
   dell# show processes cpu | grep -i interrupt
   dell# show hardware cpu utilization
   
   Common Causes:
   ├── High packet processing load
   ├── Frequent BGP updates
   ├── Intensive SNMP polling
   └── Software-based forwarding

CPU Optimization Steps:
1. Reduce unnecessary processes
2. Optimize polling intervals  
3. Implement hardware acceleration
4. Upgrade to newer software versions
5. Load balance across multiple devices

High CPU Resolution:
# Reduce BGP update frequency
router bgp 65001
 bgp dampening

# Optimize SNMP polling
snmp-server enable
snmp-server community readonly ro 192.168.1.0/24

# Rate limit control plane traffic
control-plane
 service-policy input COPP-POLICY
```

#### Memory Management Issues

```
Memory Troubleshooting:

1. Memory Leak Detection
   Symptoms: Gradual memory increase, eventual system instability
   
   Memory Monitoring:
   dell# show processes memory
   dell# show processes memory detail
   dell# show memory summary
   dell# show system resources

2. Memory Allocation Problems
   Symptoms: Out of memory errors, process crashes
   
   Memory Analysis:
   dell# show memory heap
   dell# show memory buffers
   dell# show memory pools
   
   Critical Memory Areas:
   ├── Route table memory
   ├── MAC address table memory
   ├── Buffer pool memory
   └── Process heap memory

Memory Management:
┌─────────────────────────────────────────────────────────────────┐
│                    Memory Usage Guidelines                      │
├─────────────────────────────────────────────────────────────────┤
│  Memory Type          │ Normal    │ Warning  │ Critical          │
│  ────────────────────┼───────────┼──────────┼───────────────────│
│  System Memory        │ <70%      │ 70-85%   │ >85%              │
│  Route Table          │ <80%      │ 80-90%   │ >90%              │
│  MAC Table            │ <80%      │ 80-90%   │ >90%              │
│  Buffer Pool          │ <75%      │ 75-90%   │ >90%              │
│  Control Plane        │ <60%      │ 60-80%   │ >80%              │
└─────────────────────────────────────────────────────────────────┘

Memory Optimization:
1. Regular memory monitoring
2. Implement memory limits where possible
3. Clear unnecessary data structures
4. Optimize buffer allocation
5. Plan for memory growth

dell# clear mac address-table dynamic
dell# clear arp-cache
dell# clear bgp * soft
```

## Management and Monitoring Issues

### SNMP and Monitoring Problems

#### SNMP Configuration Issues

```
SNMP Troubleshooting:

1. SNMP Agent Problems
   Symptoms: No SNMP response, timeouts, incorrect data
   
   SNMP Diagnostics:
   dell# show snmp
   dell# show snmp community
   dell# show snmp user
   dell# debug snmp packet
   
   Configuration Verification:
   dell# show running-config | section snmp
   
   Common Issues:
   ├── SNMP agent not enabled
   ├── Community string mismatches
   ├── Access control list restrictions
   └── Version compatibility problems

2. SNMPv3 Authentication Issues
   Symptoms: Authentication failures, access denied
   
   SNMPv3 Configuration:
   dell(config)# snmp-server user admin auth md5 password123 priv des password456
   dell(config)# snmp-server group admin v3 auth
   dell(config)# snmp-server view full iso included
   dell(config)# snmp-server group admin v3 auth read full write full
   
   Verification:
   dell# show snmp user
   dell# show snmp group

SNMP Configuration Example:
snmp-server enable
snmp-server community public ro
snmp-server community private rw 192.168.1.0/24
snmp-server location "Datacenter 1, Rack A1"
snmp-server contact "Network Team <network@company.com>"
snmp-server trap-source loopback 0
snmp-server enable traps
```

#### Logging and Syslog Issues

```
Logging Troubleshooting:

1. Log Message Problems
   Symptoms: Missing log messages, excessive logging, wrong severity
   
   Logging Configuration:
   dell# show logging
   dell# show logging buffer
   dell# show logging server
   dell# show running-config | section logging
   
   Log Level Configuration:
   dell(config)# logging console warnings
   dell(config)# logging buffer informational
   dell(config)# logging server 192.168.1.100 debugging
   dell(config)# logging facility local1

2. Remote Syslog Server Issues
   Symptoms: Logs not reaching remote server, network connectivity
   
   Syslog Verification:
   ├── Test network connectivity to syslog server
   ├── Verify UDP port 514 accessibility  
   ├── Check syslog server configuration
   └── Monitor log message format

   Network Testing:
   dell# ping 192.168.1.100 source loopback 0
   dell# telnet 192.168.1.100 514
   dell# show logging server status

Logging Best Practices:
1. Centralized log collection
2. Appropriate log levels
3. Log rotation and retention
4. Security event logging
5. Performance metric logging

dell(config)# logging server 192.168.1.100 vrf management
dell(config)# logging source-interface loopback 0
dell(config)# logging buffered 10000 informational
dell(config)# no logging console
```

### Configuration Management Issues

#### Version Control Problems

```
Configuration Management Troubleshooting:

1. Configuration Backup Issues
   Symptoms: Backup failures, incomplete configurations, corruption
   
   Backup Verification:
   dell# show running-config | file bootflash:backup.cfg
   dell# copy running-config scp://user@server/path/backup.cfg
   dell# dir bootflash: | grep backup
   
   Automated Backup Script:
   #!/bin/bash
   # Switch configuration backup automation
   
   SWITCHES="10.1.1.1 10.1.1.2 10.1.1.3"
   BACKUP_DIR="/backup/switches"
   DATE=$(date +%Y%m%d_%H%M%S)
   
   for switch in $SWITCHES; do
       sshpass -p 'password' ssh admin@$switch \
           "show running-config" > \
           $BACKUP_DIR/switch-$switch-$DATE.cfg
       
       if [ $? -eq 0 ]; then
           echo "Backup successful for $switch"
       else
           echo "Backup failed for $switch"
       fi
   done

2. Configuration Restore Problems  
   Symptoms: Restore failures, partial configurations, compatibility issues
   
   Restore Procedures:
   dell# copy scp://user@server/path/backup.cfg running-config
   dell# configure replace bootflash:backup.cfg
   dell# copy bootflash:backup.cfg running-config
   
   Verification Steps:
   ├── Validate configuration syntax
   ├── Check for version compatibility
   ├── Test configuration incrementally
   └── Verify all features work correctly

Configuration Management Best Practices:
1. Regular automated backups
2. Version control integration
3. Change tracking and approval
4. Testing before deployment
5. Rollback procedures

# Git-based configuration management
git init /backup/switches
cd /backup/switches
git add .
git commit -m "Switch configuration backup $(date)"
git push origin main
```

## Common Error Messages

### Interface and Hardware Errors

#### Physical Layer Error Messages

```
Common Interface Error Messages and Solutions:

1. "Interface Ethernet X/Y/Z is down"
   Possible Causes:
   ├── Physical cable disconnection
   ├── SFP/QSFP module failure  
   ├── Port hardware failure
   └── Administrative shutdown
   
   Resolution:
   dell# show interface ethernet X/Y/Z status
   dell# show interface ethernet X/Y/Z transceiver
   dell# no shutdown (if administratively down)

2. "Link flap detected on interface Ethernet X/Y/Z"
   Possible Causes:
   ├── Faulty cable or connector
   ├── Duplex/speed mismatch
   ├── SFP module instability
   └── Electrical interference
   
   Resolution:
   dell# show interface ethernet X/Y/Z counters errors
   dell# interface ethernet X/Y/Z
   dell(config-if)# link debounce time 5000

3. "SFP module not recognized in port X/Y/Z"
   Possible Causes:
   ├── Incompatible SFP module
   ├── Module not properly seated
   ├── Faulty SFP module
   └── Port hardware issue
   
   Resolution:
   ├── Verify SFP compatibility with Dell documentation
   ├── Reseat the SFP module
   ├── Test with known good SFP
   └── Check port status and errors

Error Message Examples:
%LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet1/1/1, changed state to down
%LINK-3-UPDOWN: Interface Ethernet1/1/1, changed state to down
%SFF-4-SFPINVALID: SFP validation failed on interface Ethernet1/1/1
%HARDWARE-2-FANFAIL: Fan module 1 has failed
```

#### Protocol Error Messages

```
BGP and Routing Error Messages:

1. "BGP: %BGP-3-NOTIFICATION: received from neighbor X.X.X.X"
   Common Notifications:
   ├── Unsupported version number
   ├── Bad peer AS number
   ├── Authentication failure
   └── Hold time expired
   
   Diagnostic Commands:
   dell# show bgp neighbors X.X.X.X
   dell# debug bgp events
   dell# clear bgp X.X.X.X

2. "%BGP-4-ADJCHANGE: neighbor X.X.X.X Down - Hold Timer Expired"
   Possible Causes:
   ├── Network connectivity issues
   ├── High CPU utilization
   ├── BGP process problems
   └── Timer mismatches
   
   Resolution:
   dell# show bgp neighbors X.X.X.X | grep Timer
   dell# show processes cpu | grep bgp
   dell# ping X.X.X.X source Y.Y.Y.Y

3. "EVPN: Route import failed for VNI XXXXX"
   Possible Causes:
   ├── Route target mismatch
   ├── VNI configuration errors
   ├── Memory limitations
   └── BGP EVPN session issues
   
   Resolution:
   dell# show evpn vni XXXXX detail
   dell# show bgp l2vpn evpn summary
   dell# show bgp l2vpn evpn vni XXXXX

VXLAN Error Messages:
"%VXLAN-4-VNI_ADD_FAILED: Addition of VNI XXXXX failed"
"%VXLAN-3-VTEP_UNREACHABLE: VTEP X.X.X.X is unreachable"
"%EVPN-4-MAC_MOVE: MAC address move detected for XXXX.XXXX.XXXX"
```

### System Error Messages

#### Boot and System Errors

```
System Error Messages and Resolution:

1. "BOOT: Unable to locate configuration file"
   Causes and Solutions:
   ├── startup-config file missing or corrupted
   ├── Filesystem corruption
   ├── Storage device failure
   └── Configuration file path incorrect
   
   Recovery Steps:
   dell# dir bootflash:
   dell# copy tftp://server/config.cfg startup-config
   dell# write memory

2. "MEMORY: System running low on memory"  
   Impact and Resolution:
   ├── Monitor memory usage trends
   ├── Identify memory-intensive processes
   ├── Clear unnecessary tables
   └── Plan for memory upgrade
   
   Commands:
   dell# show processes memory sorted
   dell# show memory summary
   dell# clear mac address-table dynamic

3. "CPU: High CPU utilization detected"
   Causes and Mitigation:
   ├── Excessive control plane traffic
   ├── Software processing overhead
   ├── Routing protocol instability
   └── Management traffic storms
   
   Analysis:
   dell# show processes cpu sorted
   dell# show hardware cpu utilization
   dell# show control-plane interface statistics

System Resource Monitoring:
# Automated system health check
#!/bin/bash
SWITCH_IP="10.1.1.1"
WARNING_THRESHOLD=80
CRITICAL_THRESHOLD=90

# CPU utilization check
CPU_USAGE=$(ssh admin@$SWITCH_IP "show processes cpu" | awk '/CPU utilization/ {print $6}' | sed 's/%//')

if [ $CPU_USAGE -gt $CRITICAL_THRESHOLD ]; then
    echo "CRITICAL: CPU usage is ${CPU_USAGE}%"
    # Send alert
elif [ $CPU_USAGE -gt $WARNING_THRESHOLD ]; then
    echo "WARNING: CPU usage is ${CPU_USAGE}%"
    # Log warning
fi

# Memory utilization check  
MEMORY_USAGE=$(ssh admin@$SWITCH_IP "show memory summary" | grep "Percent used" | awk '{print $3}' | sed 's/%//')

if [ $MEMORY_USAGE -gt $CRITICAL_THRESHOLD ]; then
    echo "CRITICAL: Memory usage is ${MEMORY_USAGE}%"
elif [ $MEMORY_USAGE -gt $WARNING_THRESHOLD ]; then
    echo "WARNING: Memory usage is ${MEMORY_USAGE}%"
fi
```

## Diagnostic Tools and Commands

### Built-in Diagnostic Tools

#### Network Connectivity Testing

```
Comprehensive Network Diagnostics:

1. Basic Connectivity Tests
   # Layer 3 connectivity testing
   dell# ping 10.1.1.2
   dell# ping 10.1.1.2 repeat 1000
   dell# ping 10.1.1.2 size 1500
   dell# ping 10.1.1.2 source loopback 0
   
   # Path discovery
   dell# traceroute 10.1.1.2
   dell# traceroute 10.1.1.2 source loopback 0
   
   # DNS resolution testing
   dell# nslookup server.company.com
   dell# nslookup server.company.com 8.8.8.8

2. Advanced Connectivity Diagnostics
   # TCP connectivity testing
   dell# telnet 10.1.1.2 22
   dell# telnet 10.1.1.2 179 (BGP)
   dell# telnet 10.1.1.2 161 (SNMP)
   
   # UDP connectivity testing (requires extended diagnostics)
   dell# test udp-connectivity 10.1.1.2 port 4789
   
   # MTU path discovery
   dell# ping 10.1.1.2 df-bit size 1500
   dell# ping 10.1.1.2 df-bit size 9000

Network Connectivity Test Script:
#!/bin/bash
# Comprehensive network connectivity test

TARGET="10.1.1.2"
SOURCE_IP="10.1.1.1"

echo "=== Network Connectivity Test for $TARGET ==="
date

# Basic ping test
echo "1. Basic Connectivity:"
ping -c 5 $TARGET
PING_RESULT=$?

if [ $PING_RESULT -eq 0 ]; then
    echo "✓ Basic connectivity successful"
else
    echo "✗ Basic connectivity failed"
fi

# Extended ping test
echo "2. Extended Ping Test:"
ping -c 100 -i 0.1 $TARGET | tail -2

# MTU discovery
echo "3. MTU Path Discovery:"
for size in 1500 4000 9000; do
    ping -c 1 -M do -s $size $TARGET > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ MTU $size bytes: OK"
    else
        echo "✗ MTU $size bytes: Failed"
    fi
done

# Service connectivity
echo "4. Service Port Tests:"
SERVICES="22 179 161 514"
for port in $SERVICES; do
    timeout 3 bash -c "</dev/tcp/$TARGET/$port" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ Port $port: Open"
    else
        echo "✗ Port $port: Closed/Filtered"
    fi
done
```

#### Protocol State Analysis

```
Protocol Diagnostic Commands:

1. BGP State Analysis
   # BGP neighbor status
   dell# show bgp summary
   dell# show bgp neighbors
   dell# show bgp neighbors 10.1.1.2 detail
   dell# show bgp neighbors 10.1.1.2 advertised-routes
   dell# show bgp neighbors 10.1.1.2 received-routes
   
   # BGP table analysis
   dell# show bgp ipv4 unicast summary
   dell# show bgp ipv4 unicast 192.168.1.0/24 longer-prefixes
   dell# show bgp ipv4 unicast dampened-paths
   
   # EVPN specific diagnostics
   dell# show bgp l2vpn evpn summary
   dell# show bgp l2vpn evpn route-type 2
   dell# show bgp l2vpn evpn route-type 5

2. VXLAN State Verification
   # VXLAN interface status
   dell# show vxlan interface
   dell# show interface nve 1
   dell# show interface nve 1 detail
   
   # VXLAN tunnel information  
   dell# show vxlan tunnel
   dell# show vxlan tunnel detail
   dell# show vxlan vtep
   
   # VNI and bridge domain status
   dell# show vxlan vni
   dell# show evpn vni detail
   dell# show bridge domain

Protocol Health Check Script:
#!/bin/bash
# Protocol health monitoring script

echo "=== Protocol Health Check ==="
date

# BGP Status Check
echo "1. BGP Neighbor Status:"
show bgp summary | awk '
/^[0-9]/ {
    if ($10 == "Established" || $10 ~ /^[0-9]+$/) {
        print "✓ " $1 " - " $3 " - Established (" $10 " routes)"
    } else {
        print "✗ " $1 " - " $3 " - " $10
    }
}'

# EVPN Status Check  
echo "2. EVPN Status:"
BGP_EVPN_PEERS=$(show bgp l2vpn evpn summary | grep -c "Established")
echo "EVPN Established Peers: $BGP_EVPN_PEERS"

# VXLAN Status Check
echo "3. VXLAN Status:"
VTEP_COUNT=$(show vxlan vtep | wc -l)
VNI_COUNT=$(show vxlan vni | wc -l)
echo "Active VTEPs: $VTEP_COUNT"
echo "Configured VNIs: $VNI_COUNT"

# Interface Status Summary
echo "4. Critical Interface Status:"
show interface brief | grep -E "(down|error)" || echo "All interfaces operational"
```

### External Diagnostic Tools

#### Network Analysis Tools

```
External Tool Integration:

1. Traffic Analysis Tools
   # Packet capture integration
   dell# monitor capture interface ethernet 1/1/1 both file bootflash:capture.pcap
   dell# no monitor capture interface ethernet 1/1/1
   dell# copy bootflash:capture.pcap scp://user@server/captures/
   
   # Flow monitoring setup
   dell(config)# flow record NETFLOW-RECORD
   dell(config-flow-record)# match ipv4 source address
   dell(config-flow-record)# match ipv4 destination address
   dell(config-flow-record)# collect counter bytes
   dell(config-flow-record)# collect counter packets
   
   dell(config)# flow monitor NETFLOW-MONITOR
   dell(config-flow-monitor)# record NETFLOW-RECORD
   dell(config-flow-monitor)# exporter NETFLOW-EXPORTER
   
   dell(config)# interface ethernet 1/1/1
   dell(config-if)# ip flow monitor NETFLOW-MONITOR input

2. Performance Monitoring Integration
   # SNMP monitoring setup for external tools
   dell(config)# snmp-server enable traps
   dell(config)# snmp-server host 192.168.1.100 version 2c public
   dell(config)# snmp-server host 192.168.1.100 version 3 auth admin
   
   # Syslog integration for SIEM
   dell(config)# logging server 192.168.1.101 debugging
   dell(config)# logging facility local1
   dell(config)# logging source-interface loopback 0

Network Monitoring Integration:
# Integrate with Prometheus for metrics collection
# /etc/prometheus/prometheus.yml

global:
  scrape_interval: 30s

scrape_configs:
  - job_name: 'dell-switches'
    static_configs:
      - targets: ['10.1.1.1:161', '10.1.1.2:161']
    scrape_interval: 30s
    metrics_path: '/snmp'
    params:
      module: [dell_switch]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 192.168.1.100:9116  # SNMP exporter address

# Custom monitoring dashboard queries
# Interface utilization
rate(ifHCInOctets[5m]) * 8 / ifHighSpeed * 100

# BGP neighbor status
bgpPeerState == 6  # Established state

# CPU utilization
hrProcessorLoad

# Memory utilization  
hrStorageUsed / hrStorageSize * 100
```

#### Automation and Testing Tools

```
Automated Diagnostic Tools:

1. Network Validation Scripts
   #!/bin/bash
   # Automated network validation
   
   SWITCHES=(
       "10.1.1.1:spine-01"
       "10.1.1.2:spine-02"  
       "10.1.1.11:leaf-01"
       "10.1.1.12:leaf-02"
   )
   
   echo "=== Network Infrastructure Validation ==="
   
   for switch_info in "${SWITCHES[@]}"; do
       IFS=':' read -r ip hostname <<< "$switch_info"
       echo "Testing $hostname ($ip)..."
       
       # Connectivity test
       ping -c 3 -W 2 $ip > /dev/null 2>&1
       if [ $? -eq 0 ]; then
           echo "  ✓ Connectivity: OK"
       else
           echo "  ✗ Connectivity: FAILED"
           continue
       fi
       
       # SSH accessibility
       timeout 10 ssh -o ConnectTimeout=5 -o BatchMode=yes admin@$ip "show version" > /dev/null 2>&1
       if [ $? -eq 0 ]; then
           echo "  ✓ SSH Access: OK"
       else
           echo "  ✗ SSH Access: FAILED"
           continue
       fi
       
       # BGP status check
       BGP_PEERS=$(ssh admin@$ip "show bgp summary" 2>/dev/null | grep -c "Established")
       echo "  ✓ BGP Peers: $BGP_PEERS established"
       
       # Interface status check  
       DOWN_INTERFACES=$(ssh admin@$ip "show interface brief" 2>/dev/null | grep -c "down")
       if [ $DOWN_INTERFACES -eq 0 ]; then
           echo "  ✓ Interfaces: All operational"
       else
           echo "  ! Interfaces: $DOWN_INTERFACES down"
       fi
       
       echo ""
   done

2. Performance Testing Automation
   #!/usr/bin/python3
   # Performance monitoring automation
   
   import subprocess
   import json
   import time
   from datetime import datetime
   
   def get_interface_stats(switch_ip, interface):
       """Get interface statistics via SSH"""
       try:
           cmd = f"ssh admin@{switch_ip} 'show interface {interface} counters'"
           result = subprocess.run(cmd.split(), capture_output=True, text=True)
           return result.stdout
       except Exception as e:
           print(f"Error getting stats: {e}")
           return None
   
   def calculate_utilization(stats1, stats2, time_diff):
       """Calculate interface utilization between two measurements"""
       # Parse statistics and calculate rates
       # Implementation depends on output format
       pass
   
   # Monitor critical interfaces
   switches = [
       {"ip": "10.1.1.1", "interfaces": ["ethernet 1/1/1", "ethernet 1/1/2"]},
       {"ip": "10.1.1.2", "interfaces": ["ethernet 1/1/1", "ethernet 1/1/2"]}
   ]
   
   while True:
       timestamp = datetime.now().isoformat()
       
       for switch in switches:
           for interface in switch["interfaces"]:
               stats = get_interface_stats(switch["ip"], interface)
               if stats:
                   # Process and store statistics
                   print(f"{timestamp} - {switch['ip']} {interface}: Stats collected")
       
       time.sleep(300)  # 5-minute intervals
```

## Emergency Procedures

### System Recovery Procedures

#### Emergency Access Procedures

```
Emergency Access Protocols:

1. Console Access Procedures
   When network access is unavailable:
   
   Physical Console Connection:
   ├── Connect to console port using serial cable
   ├── Configure terminal: 9600 baud, 8-N-1
   ├── Power cycle device if necessary
   └── Access ONIE recovery if needed
   
   Console Commands:
   # Reset to factory defaults
   dell# write erase
   dell# reload
   
   # Boot to recovery mode
   # During boot, press Ctrl+C to interrupt
   # Select ONIE rescue mode
   
   # Emergency network configuration
   dell(config)# interface mgmt 1/1/1
   dell(config-if)# ip address 192.168.1.100/24
   dell(config-if)# no shutdown

2. Password Recovery Procedures
   When administrative passwords are lost:
   
   Console Recovery Steps:
   ├── Boot to ONIE rescue mode
   ├── Mount file system
   ├── Reset password or configuration
   └── Reboot to normal operation
   
   Password Reset Process:
   # In ONIE rescue mode
   mkdir /mnt/flash
   mount /dev/sda1 /mnt/flash
   
   # Edit configuration to remove password
   vi /mnt/flash/startup-config
   
   # Remove or modify username lines
   # Save and reboot
   umount /mnt/flash
   reboot

Emergency Contact Information:
┌─────────────────────────────────────────────────────────────────┐
│                    Emergency Contacts                           │
├─────────────────────────────────────────────────────────────────┤
│  Role                 │ Contact Information                     │
│  ────────────────────┼─────────────────────────────────────────│
│  Network Operations   │ +1-xxx-xxx-xxxx (24/7)                │
│  Dell Support         │ 1-800-WWW-DELL                        │
│  Emergency Escalation│ Director: +1-xxx-xxx-xxxx              │
│  Facilities Team      │ +1-xxx-xxx-xxxx                       │
│  Security Team        │ security@company.com                   │
└─────────────────────────────────────────────────────────────────┘
```

#### Disaster Recovery Procedures

```
Disaster Recovery Protocols:

1. Site Failure Recovery
   Complete site outage scenarios:
   
   Recovery Priorities:
   ├── Assess extent of failure and safety
   ├── Activate alternate site if available
   ├── Coordinate with business continuity team
   └── Begin systematic recovery procedures
   
   Site Recovery Checklist:
   □ Verify power and environmental systems
   □ Check physical infrastructure integrity
   □ Test console and out-of-band access
   □ Verify network connectivity to other sites
   □ Restore critical network services first
   □ Validate end-to-end connectivity
   □ Monitor system stability
   □ Document lessons learned

2. Configuration Corruption Recovery
   Mass configuration loss or corruption:
   
   Recovery Steps:
   ├── Stop making changes immediately
   ├── Assess scope of corruption
   ├── Locate most recent good backups
   └── Plan systematic restoration
   
   Restoration Process:
   # Parallel restoration script
   #!/bin/bash
   
   BACKUP_SERVER="192.168.100.10"
   BACKUP_PATH="/backup/switches"
   SWITCHES="switch1 switch2 switch3 switch4"
   
   # Function to restore single switch
   restore_switch() {
       local switch_ip=$1
       local switch_name=$2
       
       echo "Restoring $switch_name ($switch_ip)..."
       
       # Find latest backup
       BACKUP_FILE=$(ssh backup@$BACKUP_SERVER \
           "ls -t $BACKUP_PATH/$switch_name-*.cfg | head -1")
       
       if [ -n "$BACKUP_FILE" ]; then
           # Copy backup to switch
           scp backup@$BACKUP_SERVER:$BACKUP_FILE /tmp/restore.cfg
           scp /tmp/restore.cfg admin@$switch_ip:/bootflash/
           
           # Apply configuration
           ssh admin@$switch_ip "configure replace bootflash:restore.cfg"
           
           if [ $? -eq 0 ]; then
               echo "✓ $switch_name restored successfully"
           else
               echo "✗ $switch_name restoration failed"
           fi
       else
           echo "✗ No backup found for $switch_name"
       fi
   }
   
   # Restore switches in parallel
   for switch in $SWITCHES; do
       restore_switch $switch &
   done
   
   # Wait for all restorations to complete
   wait
   
   echo "All restoration processes completed"

3. Hardware Failure Recovery
   Critical hardware component failures:
   
   Hardware Replacement Procedure:
   ├── Identify failed component
   ├── Assess impact and priority
   ├── Obtain replacement hardware
   └── Execute replacement with minimal downtime
   
   Switch Replacement Process:
   # Pre-replacement preparation
   1. Document current configuration
   2. Prepare replacement switch
   3. Stage configuration files
   4. Plan cable migration
   5. Schedule maintenance window
   
   # During replacement
   1. Power down failed switch
   2. Document cable connections
   3. Install replacement switch
   4. Apply configuration
   5. Test functionality
   6. Update documentation

Disaster Recovery Communication:
# Emergency notification script
#!/bin/bash

INCIDENT_TYPE=$1
SEVERITY=$2
DESCRIPTION=$3

# Define notification lists
CRITICAL_CONTACTS="ops-team@company.com network-admin@company.com"
MANAGEMENT_CONTACTS="it-director@company.com cto@company.com"

# Send notifications based on severity
case $SEVERITY in
    "critical")
        # Page operations team
        echo "CRITICAL: Network incident - $DESCRIPTION" | \
            mail -s "CRITICAL Network Alert" $CRITICAL_CONTACTS
        
        # SMS alert (if configured)
        echo "CRITICAL network incident: $DESCRIPTION" | \
            send_sms.sh $CRITICAL_PHONE_LIST
        ;;
    "high")
        echo "HIGH: Network incident - $DESCRIPTION" | \
            mail -s "HIGH Network Alert" $CRITICAL_CONTACTS
        ;;
    "medium")
        echo "MEDIUM: Network incident - $DESCRIPTION" | \
            mail -s "Network Alert" $CRITICAL_CONTACTS
        ;;
esac

# Log incident
echo "$(date): $SEVERITY - $INCIDENT_TYPE - $DESCRIPTION" >> \
    /var/log/network-incidents.log
```

### Business Continuity Procedures

#### Service Continuity Plans

```
Service Continuity Framework:

1. Critical Service Identification
   Business-Critical Services:
   ├── Primary data services (Priority 1)
   ├── Voice and communication (Priority 1)  
   ├── Internet connectivity (Priority 2)
   └── Management services (Priority 3)
   
   Service Priority Matrix:
   ┌─────────────────────────────────────────────────────────────────┐
   │                    Service Priority Classification               │
   ├─────────────────────────────────────────────────────────────────┤
   │  Priority │ RTO    │ RPO    │ Services                          │
   │  ────────┼────────┼────────┼───────────────────────────────────│
   │  P1       │ 15 min │ 0      │ Core network, critical apps       │
   │  P2       │ 2 hours│ 15 min │ Email, web services, VoIP         │
   │  P3       │ 8 hours│ 1 hour │ File shares, backup services      │
   │  P4       │ 24hours│ 4 hours│ Development, test environments    │
   └─────────────────────────────────────────────────────────────────┘

2. Failover Procedures
   Automatic and manual failover processes:
   
   Network Path Failover:
   #!/bin/bash
   # Automated failover script
   
   PRIMARY_PATH="10.1.1.1"    # Primary spine switch
   BACKUP_PATH="10.1.1.2"     # Secondary spine switch
   TEST_TARGET="8.8.8.8"      # Internet connectivity test
   
   # Function to test connectivity
   test_connectivity() {
       local gateway=$1
       ping -c 3 -W 2 $TEST_TARGET -I $gateway > /dev/null 2>&1
       return $?
   }
   
   # Monitor and failover logic
   while true; do
       if test_connectivity $PRIMARY_PATH; then
           echo "$(date): Primary path operational"
           # Ensure primary path is active
           ip route replace default via $PRIMARY_PATH
       else
           echo "$(date): Primary path failed, activating backup"
           # Failover to backup path
           ip route replace default via $BACKUP_PATH
           
           # Send alert
           echo "Network failover activated at $(date)" | \
               mail -s "Network Failover Alert" ops-team@company.com
       fi
       
       sleep 30
   done

3. Service Recovery Procedures
   Systematic service restoration:
   
   Recovery Sequence:
   1. Infrastructure Layer (Power, cooling, physical)
   2. Network Layer (Switches, routing, connectivity)
   3. Platform Layer (Servers, storage, virtualization)
   4. Application Layer (Business applications, databases)
   5. User Access Layer (Authentication, authorization)
   
   Service Recovery Script:
   #!/bin/bash
   # Service recovery orchestration
   
   SERVICES=(
       "network-infrastructure"
       "core-routing" 
       "application-services"
       "user-authentication"
   )
   
   recovery_network_infrastructure() {
       echo "Recovering network infrastructure..."
       # Check switch connectivity
       # Verify BGP adjacencies
       # Test VXLAN tunnels
   }
   
   recovery_core_routing() {
       echo "Recovering core routing..."
       # Verify routing tables
       # Check route advertisements
       # Test inter-VLAN routing
   }
   
   recovery_application_services() {
       echo "Recovering application services..."
       # Start critical applications
       # Verify database connectivity
       # Test application endpoints
   }
   
   recovery_user_authentication() {
       echo "Recovering user authentication..."
       # Verify AD connectivity
       # Test RADIUS/TACACS
       # Validate user access
   }
   
   # Execute recovery sequence
   for service in "${SERVICES[@]}"; do
       recovery_$service
       
       # Wait for service stabilization
       sleep 30
       
       # Verify service health
       if verify_service_health $service; then
           echo "✓ $service recovered successfully"
       else
           echo "✗ $service recovery failed"
           exit 1
       fi
   done
   
   echo "All services recovered successfully"

Business Continuity Communication Plan:
1. Incident Command Structure
   ├── Incident Commander (IT Director)
   ├── Technical Lead (Network Manager)  
   ├── Communications Lead (Help Desk Manager)
   └── Business Liaison (Operations Manager)

2. Communication Channels
   ├── Primary: Corporate email system
   ├── Secondary: Personal email addresses
   ├── Emergency: Mobile phone/SMS
   └── Backup: Instant messaging platform

3. Status Update Procedures
   ├── Initial notification within 15 minutes
   ├── Status updates every 30 minutes
   ├── Resolution notification immediately
   └── Post-incident report within 24 hours
```

---

**Document Control**
- **Version**: 1.0  
- **Last Updated**: Current Date
- **Review Schedule**: Quarterly
- **Owner**: Network Operations Team
- **Distribution**: IT Staff, Operations Team, Management

**Related Documents**
- Dell PowerSwitch Hardware Documentation
- Dell OS10 Configuration Guide  
- Network Architecture Documentation
- Emergency Response Procedures
- Business Continuity Plan