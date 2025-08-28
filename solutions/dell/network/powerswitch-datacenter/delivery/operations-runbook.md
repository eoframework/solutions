# Dell PowerSwitch Datacenter Operations Runbook

## Overview

This operations runbook provides comprehensive procedures for day-to-day management, monitoring, and maintenance of Dell PowerSwitch datacenter networking infrastructure. It includes standard operating procedures, troubleshooting guides, and emergency response protocols.

## Table of Contents

1. [Daily Operations](#daily-operations)
2. [Monitoring and Alerting](#monitoring-and-alerting)
3. [Maintenance Procedures](#maintenance-procedures)
4. [Troubleshooting](#troubleshooting)
5. [Change Management](#change-management)
6. [Incident Response](#incident-response)
7. [Performance Management](#performance-management)
8. [Capacity Planning](#capacity-planning)

## Daily Operations

### Morning Health Checks

#### System Status Verification
```bash
# Daily health check script
#!/bin/bash
# Daily Dell PowerSwitch Health Check

echo "Dell PowerSwitch Daily Health Check - $(date)"
echo "=============================================="

# Check all switches in the fabric
SWITCHES="leaf-01 leaf-02 leaf-03 leaf-04 spine-01 spine-02"

for SWITCH in $SWITCHES; do
    echo "Checking $SWITCH..."
    
    # Basic connectivity test
    ping -c 3 $SWITCH.datacenter.local > /dev/null
    if [ $? -eq 0 ]; then
        echo "  ✓ Management connectivity: OK"
    else
        echo "  ✗ Management connectivity: FAILED"
        continue
    fi
    
    # SSH and execute commands
    ssh admin@$SWITCH.datacenter.local << 'EOF'
        # Check system resources
        show system resources
        
        # Check interface status
        show interface status | grep -E "(Down|Error)"
        
        # Check BGP status
        show bgp summary | grep -E "(Idle|Connect)"
        
        # Check EVPN status
        show bgp l2vpn evpn summary
        
        # Check temperature and power
        show environment temperature
        show environment power
EOF
done
```

#### Interface Status Check
```bash
# Check for interface errors and utilization
show interface counters errors
show interface counters rate

# Identify high utilization interfaces (>80%)
show interface status | include "80\|90\|100"

# Check for CRC errors or drops
show interface ethernet 1/1/1 detail | include -i "error\|drop\|crc"
```

#### BGP Health Verification
```bash
# Verify BGP underlay status
show bgp summary
show bgp neighbors | grep -E "(Idle|Connect|Active)"

# Verify EVPN overlay status
show bgp l2vpn evpn summary
show bgp l2vpn evpn neighbors

# Check for missing routes
show ip route summary
show bgp l2vpn evpn route type 2 | count
```

#### VXLAN Tunnel Status
```bash
# Check VXLAN tunnel health
show nve interface nve 1
show nve peers
show evpn vni detail

# Verify MAC learning
show mac address-table count
show evpn mac
```

### Routine Maintenance Tasks

#### Configuration Backup
```bash
# Automated daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR="/backups/dell-switches"

for SWITCH in leaf-01 leaf-02 leaf-03 leaf-04 spine-01 spine-02; do
    echo "Backing up $SWITCH configuration..."
    
    ssh admin@$SWITCH.datacenter.local "show running-config" > \
        $BACKUP_DIR/${SWITCH}-config-${DATE}.cfg
    
    # Copy to remote backup location
    scp $BACKUP_DIR/${SWITCH}-config-${DATE}.cfg \
        backup-server:/backups/network/
done

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -name "*.cfg" -mtime +30 -delete
```

#### Log File Rotation and Analysis
```bash
# Check system logs for errors
show logging | grep -i "error\|critical\|warning"

# Review recent BGP events
show logging | grep -i "bgp\|neighbor"

# Check for interface flaps
show logging | grep -i "interface\|link"

# Monitor environmental alerts
show logging | grep -i "temperature\|power\|fan"
```

#### License Monitoring
```bash
# Check license status and expiration
show os10-license status
show os10-license usage

# Alert if licenses expire within 30 days
show os10-license status | grep -E "expires\|remaining" | \
    awk '/[0-9]+ days/ {if ($NF < 30) print "WARNING: License expires in " $NF " days"}'
```

## Monitoring and Alerting

### SNMP Monitoring Setup

#### Critical OIDs for Monitoring
```bash
# Interface status monitoring
Interface Operational Status: 1.3.6.1.2.1.2.2.1.8
Interface Admin Status: 1.3.6.1.2.1.2.2.1.7
Interface Utilization: 1.3.6.1.2.1.2.2.1.10, 1.3.6.1.2.1.2.2.1.16

# System health monitoring
CPU Utilization: 1.3.6.1.4.1.674.10895.5000.2.6132.1.1.1.1.4
Memory Utilization: 1.3.6.1.4.1.674.10895.5000.2.6132.1.1.1.1.5
Temperature: 1.3.6.1.4.1.674.10895.5000.2.6132.1.1.1.1.14

# BGP monitoring
BGP Peer State: 1.3.6.1.2.1.15.3.1.2
BGP Peer Admin Status: 1.3.6.1.2.1.15.3.1.3
```

#### Nagios/Zabbix Monitoring Templates
```bash
# Create monitoring template for Dell OS10 switches
define host{
    use                     dell-os10-switch
    host_name               leaf-01
    alias                   Dell PowerSwitch Leaf-01
    address                 192.168.100.10
    check_command           check-host-alive
    max_check_attempts      3
    check_interval          5
    retry_interval          1
    notification_interval   60
}

# Service checks
define service{
    use                     generic-service
    host_name               leaf-01
    service_description     Interface Status
    check_command           check_snmp_interface
    max_check_attempts      3
    normal_check_interval   5
    retry_check_interval    2
}

define service{
    use                     generic-service
    host_name               leaf-01
    service_description     BGP Status
    check_command           check_bgp_neighbors
    max_check_attempts      2
    normal_check_interval   5
    retry_check_interval    1
}
```

### sFlow/NetFlow Configuration

#### sFlow Setup for Traffic Analysis
```bash
# Configure sFlow on all switches
interface range ethernet 1/1/1-1/1/54
 sflow enable
 exit

sflow agent-address 192.168.100.10
sflow collector 192.168.1.100 port 6343
sflow polling-interval 20
sflow sampling-rate 1024
sflow enable
```

#### Performance Baseline Monitoring
```bash
# Monitor key performance metrics
Baseline Metrics:
- Interface utilization: <70% normal operations
- BGP convergence time: <2 seconds
- End-to-end latency: <1ms intra-rack, <5ms inter-rack
- Packet loss: 0% under normal conditions
- CPU utilization: <50% average
- Memory utilization: <70% average
```

## Maintenance Procedures

### Planned Maintenance Windows

#### Pre-Maintenance Checklist
```bash
# Pre-maintenance verification checklist
1. Review change request and approval
2. Verify maintenance window scheduling
3. Notify stakeholders of planned downtime
4. Create configuration backup
5. Verify rollback procedures
6. Prepare communication templates
7. Ensure emergency contact availability
```

#### Software Upgrade Procedures
```bash
# OS10 upgrade procedure (per switch)
1. Download new image to switch
   image download https://downloads.dell.com/OS10-Enterprise-10.5.3.bin

2. Verify image integrity
   show image status
   
3. Install new image
   image install OS10-Enterprise-10.5.3.bin
   
4. Verify installation
   show boot detail
   
5. Schedule reload during maintenance window
   reload in 10  # Reload in 10 minutes
   
6. Cancel reload if needed
   reload cancel
   
7. Post-upgrade verification
   show version
   show bgp summary
   show evpn vni
```

#### Configuration Changes
```bash
# Standard configuration change procedure
1. Create configuration backup
   copy running-config startup-config
   copy running-config tftp://backup-server/pre-change-backup.cfg

2. Apply configuration changes
   configure terminal
   [configuration commands]
   exit

3. Verify changes
   show running-config | grep [changed_section]
   
4. Test functionality
   [validation commands]
   
5. Save configuration if successful
   copy running-config startup-config
   
6. Document changes in change management system
```

### Hardware Maintenance

#### Fan and Power Supply Replacement
```bash
# Check hardware status before replacement
show environment
show environment fans
show environment power-supplies

# Fan replacement procedure
1. Identify failed fan unit
   show environment fans
   
2. Prepare replacement fan
   - Verify correct part number
   - Check compatibility matrix
   
3. Hot-swap procedure (no downtime required)
   - Remove failed fan module
   - Install replacement fan module
   - Verify operation: show environment fans

# Power supply replacement (with redundancy)
1. Verify redundant power supply operational
   show environment power-supplies
   
2. Remove failed power supply
3. Install replacement power supply
4. Verify operation: show environment power-supplies
```

#### Port/Optic Replacement
```bash
# Interface troubleshooting and replacement
1. Identify problematic interface
   show interface ethernet 1/1/1 detail
   show interface counters errors
   
2. Test with different cable/optic
3. Clean optical connections
4. Replace optic if necessary
5. Verify post-replacement
   show interface ethernet 1/1/1 status
   show interface ethernet 1/1/1 counters
```

## Troubleshooting

### BGP Issues

#### BGP Neighbor Down
```bash
# Troubleshooting steps for BGP neighbor issues
1. Check interface status
   show interface ethernet 1/1/49 detail
   
2. Verify IP connectivity
   ping 10.1.1.0 source-interface ethernet 1/1/49
   
3. Check BGP configuration
   show bgp neighbors 10.1.1.0
   
4. Review BGP logs
   show logging | grep bgp
   
5. Check routing table
   show ip route 10.1.1.0
   
6. Clear BGP session if needed
   clear bgp neighbor 10.1.1.0 soft-reconfiguration inbound
```

#### EVPN Route Issues
```bash
# EVPN troubleshooting procedures
1. Check EVPN neighbor status
   show bgp l2vpn evpn summary
   
2. Verify VNI configuration
   show evpn vni detail
   
3. Check route advertisements
   show bgp l2vpn evpn route type 2
   show bgp l2vpn evpn route type 3
   
4. Verify VXLAN tunnel status
   show nve interface nve 1 detail
   show nve peers
   
5. Check MAC learning
   show mac address-table
   show evpn mac
```

### VXLAN Issues

#### VXLAN Tunnel Problems
```bash
# VXLAN tunnel troubleshooting
1. Check NVE interface status
   show nve interface nve 1
   
2. Verify source interface
   show interface loopback1
   
3. Check VXLAN peers
   show nve peers
   
4. Verify UDP port 4789 connectivity
   telnet 10.254.254.11 4789
   
5. Check VNI mapping
   show vlan brief | grep vn-segment
   
6. Debug VXLAN packets (use with caution)
   debug vxlan packet
```

#### MAC Address Learning Issues
```bash
# MAC learning troubleshooting
1. Check MAC address table
   show mac address-table vlan 100
   
2. Verify EVPN MAC advertisements
   show evpn mac vni 10100
   
3. Check for MAC moves or flapping
   show logging | grep -i "mac\|flap"
   
4. Clear MAC addresses if needed
   clear mac address-table vlan 100
   
5. Verify server connectivity
   show mac address-table interface ethernet 1/1/1
```

### Performance Issues

#### High Interface Utilization
```bash
# High utilization troubleshooting
1. Identify high utilization interfaces
   show interface counters rate
   
2. Check for traffic patterns
   show interface ethernet 1/1/1 counters detail
   
3. Verify QoS policies
   show policy-map interface ethernet 1/1/1
   
4. Check for broadcast/multicast storms
   show interface counters | grep -i broadcast
   
5. Implement storm control if needed
   interface ethernet 1/1/1
   storm-control broadcast level 10
```

#### Latency Issues
```bash
# Latency troubleshooting steps
1. Measure end-to-end latency
   ping 10.100.1.10 -t 1000  # Extended ping test
   
2. Check interface queuing
   show interface ethernet 1/1/1 queues
   
3. Verify QoS configuration
   show class-map
   show policy-map
   
4. Check for congestion
   show interface counters drops
   
5. Review traffic patterns
   # Use sFlow data for analysis
```

## Change Management

### Change Request Process

#### Standard Change Procedure
```bash
Change Management Workflow:
1. Submit change request in ticketing system
2. Technical review and approval
3. Schedule maintenance window
4. Create rollback plan
5. Execute change during maintenance window
6. Validate change success
7. Update documentation
8. Close change request
```

#### Emergency Change Procedure
```bash
Emergency Change Process:
1. Assess severity and impact
2. Obtain emergency approval
3. Create rapid rollback plan
4. Execute emergency change
5. Document actions taken
6. Follow up with post-change review
```

### Configuration Version Control

#### Git-Based Configuration Management
```bash
# Configuration version control process
1. Export current configurations
   for switch in leaf-01 leaf-02 spine-01 spine-02; do
       ssh admin@$switch "show running-config" > configs/$switch.cfg
   done

2. Commit to version control
   git add configs/*.cfg
   git commit -m "Weekly configuration backup $(date +%Y-%m-%d)"
   git push origin main

3. Track configuration changes
   git diff HEAD~1 configs/leaf-01.cfg

4. Rollback if needed
   scp configs/leaf-01.cfg admin@leaf-01:/tmp/
   ssh admin@leaf-01 "copy /tmp/leaf-01.cfg running-config"
```

## Incident Response

### Severity Classification

#### Severity 1 - Critical
```bash
Definition: Complete network outage or major service impact
Response Time: 15 minutes
Examples:
- All spine switches down
- Complete BGP/EVPN control plane failure
- Datacenter-wide connectivity loss

Escalation:
- Immediate notification to on-call engineer
- Engage vendor support within 30 minutes
- Notify management within 1 hour
```

#### Severity 2 - High
```bash
Definition: Significant service impact with redundancy failure
Response Time: 1 hour
Examples:
- Single spine switch failure
- Partial EVPN route loss
- Multiple leaf switch issues

Escalation:
- Notify on-call engineer within 1 hour
- Engage vendor support within 2 hours
- Update stakeholders every 2 hours
```

#### Severity 3 - Medium
```bash
Definition: Service degradation with functional redundancy
Response Time: 4 hours
Examples:
- Single leaf switch failure
- Individual link failures
- Non-critical interface errors

Escalation:
- Address during business hours
- Engage vendor support if needed
- Document resolution
```

### Emergency Response Procedures

#### Network Outage Response
```bash
# Network outage response checklist
1. Immediate Assessment (0-15 minutes)
   - Verify outage scope and impact
   - Check monitoring systems
   - Identify potential root cause
   - Notify incident response team

2. Initial Response (15-30 minutes)
   - Execute emergency rollback if recent change
   - Check physical connectivity
   - Verify power and environmental systems
   - Begin vendor support engagement

3. Investigation and Resolution (30+ minutes)
   - Detailed troubleshooting based on symptoms
   - Coordinate with vendor support
   - Implement temporary workarounds
   - Document all actions taken

4. Recovery and Validation
   - Verify full service restoration
   - Conduct post-incident review
   - Update procedures based on lessons learned
```

## Performance Management

### Capacity Planning

#### Interface Utilization Trending
```bash
# Weekly capacity report generation
#!/bin/bash
# Generate weekly interface utilization report

echo "Dell PowerSwitch Weekly Capacity Report - $(date)"
echo "=================================================="

for SWITCH in leaf-01 leaf-02 leaf-03 leaf-04; do
    echo "Switch: $SWITCH"
    ssh admin@$SWITCH.datacenter.local << 'EOF'
        show interface counters rate | grep -E "(ethernet|In|Out)"
        show interface status | grep -v "Down"
EOF
    echo ""
done

# Check for interfaces >70% utilization
echo "High Utilization Interfaces (>70%):"
# Additional monitoring logic here
```

#### Growth Planning
```bash
# Capacity planning metrics
Current Utilization Thresholds:
- Interface: 70% warning, 85% critical
- CPU: 60% warning, 80% critical
- Memory: 70% warning, 85% critical
- MAC Table: 80% of maximum capacity

Growth Planning Timeline:
- Monthly: Review utilization trends
- Quarterly: Assess capacity requirements
- Annually: Plan infrastructure expansion
```

### Performance Optimization

#### BGP Optimization
```bash
# BGP performance tuning
router bgp 65001
 # Optimize BGP timers for faster convergence
 neighbor SPINE-EVPN timers 10 30
 
 # Enable BFD for sub-second failure detection
 neighbor 10.1.1.0 fall-over bfd
 
 # Optimize route processing
 bgp suppress-fib-pending
 exit

# Configure BFD
bfd
 interval 300 min-rx 300 multiplier 3
 exit

interface ethernet 1/1/49
 bfd enable
 exit
```

#### QoS Optimization
```bash
# QoS performance tuning
# Increase buffer sizes for high-throughput applications
interface ethernet 1/1/1
 priority-flow-control mode on
 priority-flow-control priority 3 no-drop
 exit

# Optimize queue scheduling
policy-map OPTIMIZED-QOS
 class CRITICAL-TRAFFIC
  priority level 1
  police cir 1000000000 bc 125000000
  exit
 class BULK-TRAFFIC
  bandwidth remaining percent 20
  random-detect
  exit
 exit
```

## Documentation Maintenance

### Runbook Updates
```bash
# Monthly runbook review checklist
1. Review and update contact information
2. Validate emergency procedures
3. Update monitoring thresholds
4. Review and test backup procedures
5. Update troubleshooting procedures based on incidents
6. Verify configuration templates
7. Update capacity planning data
```

### Knowledge Management
```bash
# Maintain operational knowledge base
1. Document all incident resolutions
2. Create knowledge articles for common issues
3. Update troubleshooting decision trees
4. Maintain vendor contact information
5. Update escalation procedures
6. Review and update training materials
```

This operations runbook provides comprehensive procedures for managing Dell PowerSwitch datacenter infrastructure, ensuring reliable operations and rapid issue resolution.