# Juniper SRX Firewall Platform Operations Runbook

## Overview

This operations runbook provides comprehensive procedures for daily operations, maintenance, and troubleshooting of the Juniper SRX Firewall Platform. It covers routine monitoring tasks, emergency response procedures, and preventive maintenance activities.

---

## Daily Operations Procedures

### Morning Health Checks

**System Status Verification**
```bash
# Check system status
show chassis hardware
show chassis environment
show chassis alarms

# Verify cluster status (if applicable)
show chassis cluster status
show chassis cluster interfaces

# Check interface status
show interfaces terse
show interfaces diagnostics optics

# Memory and CPU utilization
show chassis routing-engine
show security monitoring performance spu
```

**Security Service Status**
```bash
# IDP Service Status
show security idp status
show security idp counters

# Application identification status
show services application-identification status
show services application-identification statistics

# UTM Services Status
show security utm status
show security utm web-filtering statistics
```

**Traffic and Session Analysis**
```bash
# Session table status
show security flow session summary
show security monitoring performance session
show security flow session count by-destination

# Policy hit counters
show security policies hit-count
show security policies detail | match count

# NAT translation status
show security nat source summary
show security nat destination summary
```

### Security Monitoring Tasks

**Threat Detection Review**
```bash
# Recent security events
show log messages | match "IDP\|UTM\|RT_FLOW"
show log security-trace

# Attack statistics
show security idp attack table
show security idp counters packet-drops

# Top talkers analysis
show security monitoring top-sessions source-ip
show security monitoring top-sessions destination-ip
```

**Policy Compliance Verification**
```bash
# Unused security policies
show security policies unused-policies

# Policy utilization statistics
show security policies global statistics

# Address book utilization
show security zones security-zone trust address-book summary
```

---

## Weekly Maintenance Tasks

### Performance Analysis

**Throughput and Latency Monitoring**
```bash
# Interface statistics
show interfaces extensive | match "Input rate\|Output rate\|Errors"

# SPU performance metrics
show security monitoring performance spu extensive
show security monitoring performance services

# Memory utilization trends
show system memory
show security monitoring memory
```

**Session Analysis**
```bash
# Session distribution analysis
show security flow session statistics
show security flow session application-statistics

# Connection tracking
show security monitoring performance session extensive
show security flow session count by-application
```

### Security Policy Review

**Policy Effectiveness Analysis**
```python
#!/usr/bin/env python3
"""
Weekly Security Policy Analysis Script
Analyzes policy hit counts and identifies optimization opportunities
"""

import paramiko
import re
from datetime import datetime, timedelta

class SRXPolicyAnalyzer:
    def __init__(self, host, username, password):
        self.host = host
        self.username = username
        self.password = password
        self.ssh_client = None
        
    def connect(self):
        """Establish SSH connection to SRX device"""
        self.ssh_client = paramiko.SSHClient()
        self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh_client.connect(
            hostname=self.host,
            username=self.username,
            password=self.password
        )
        
    def get_policy_statistics(self):
        """Retrieve policy hit count statistics"""
        stdin, stdout, stderr = self.ssh_client.exec_command(
            "show security policies hit-count"
        )
        return stdout.read().decode()
    
    def analyze_unused_policies(self):
        """Identify policies with zero hit counts"""
        policy_stats = self.get_policy_statistics()
        unused_policies = []
        
        for line in policy_stats.split('\n'):
            if re.search(r'\s+0\s+\d+\s*$', line):
                policy_name = line.split()[0]
                unused_policies.append(policy_name)
        
        return unused_policies
    
    def generate_weekly_report(self):
        """Generate weekly policy analysis report"""
        report = f"""
SRX Policy Analysis Report - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
====================================================================

Unused Policies (Zero Hit Count):
{chr(10).join(self.analyze_unused_policies())}

Recommendations:
- Review unused policies for potential removal
- Consider consolidating similar policies
- Update documentation for policy changes
        """
        return report

# Usage example
# analyzer = SRXPolicyAnalyzer('10.0.1.1', 'admin', 'password')
# analyzer.connect()
# print(analyzer.generate_weekly_report())
```

### Log Analysis and Archival

**Security Log Processing**
```bash
# Archive and compress old logs
tar -czf /var/log/archive/security-logs-$(date +%Y%m%d).tar.gz /var/log/security/

# Log rotation verification
show log files
show log messages | last 100

# SIEM integration status
show system syslog status
show security log stream status
```

---

## Monthly Maintenance Procedures

### Software Updates and Patching

**Update Assessment Process**
```bash
# Check current software version
show version

# Download and verify updates
request system software add package-url https://download.juniper.net/software/junos/...
request system software add validate package-name junos-srx-xx.xRx.x-domestic.tgz

# Backup current configuration
request system snapshot slice alternate
file copy /config/juniper.conf.gz ftp://backup-server/config-backup-$(date +%Y%m%d).gz
```

**Update Installation Process**
```bash
# Install software update
request system software add package-name junos-srx-xx.xRx.x-domestic.tgz reboot

# Post-update verification
show version
show chassis alarms
show security idp status
show security utm status
```

### Certificate Management

**SSL Certificate Renewal**
```bash
# Generate certificate signing request
request security pki generate-key-pair certificate-id server-cert size 2048
request security pki generate-certificate-request certificate-id server-cert domain-name firewall.company.com

# Install renewed certificate
request security pki ca-certificate load ca-profile internal-ca filename ca-cert.pem
request security pki local-certificate load certificate-id server-cert filename server-cert.pem
```

### Performance Optimization Review

**Monthly Performance Analysis Script**
```python
#!/usr/bin/env python3
"""
Monthly SRX Performance Analysis and Optimization Report
"""

import paramiko
import json
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
import pandas as pd

class SRXPerformanceAnalyzer:
    def __init__(self, host, username, password):
        self.host = host
        self.username = username  
        self.password = password
        self.performance_data = {}
        
    def collect_performance_metrics(self):
        """Collect comprehensive performance metrics"""
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(hostname=self.host, username=self.username, password=self.password)
        
        commands = {
            'spu_utilization': 'show security monitoring performance spu',
            'session_stats': 'show security flow session statistics',
            'memory_usage': 'show security monitoring memory',
            'interface_stats': 'show interfaces terse | match "up/up"'
        }
        
        for metric, command in commands.items():
            stdin, stdout, stderr = ssh_client.exec_command(command)
            self.performance_data[metric] = stdout.read().decode()
            
        ssh_client.close()
        
    def analyze_spu_utilization(self):
        """Analyze SPU utilization patterns"""
        # Parse SPU utilization data and identify bottlenecks
        spu_data = self.performance_data.get('spu_utilization', '')
        utilization_values = []
        
        for line in spu_data.split('\n'):
            if 'CPU utilization' in line:
                util = int(line.split()[-1].rstrip('%'))
                utilization_values.append(util)
                
        avg_utilization = sum(utilization_values) / len(utilization_values) if utilization_values else 0
        
        return {
            'average_cpu_utilization': avg_utilization,
            'max_cpu_utilization': max(utilization_values) if utilization_values else 0,
            'spu_count': len(utilization_values),
            'recommendation': self.get_spu_recommendation(avg_utilization)
        }
    
    def get_spu_recommendation(self, avg_util):
        """Provide SPU optimization recommendations"""
        if avg_util > 80:
            return "High CPU utilization detected. Consider load balancing or hardware upgrade."
        elif avg_util > 60:
            return "Moderate CPU utilization. Monitor trends and prepare for scaling."
        else:
            return "CPU utilization within normal parameters."
    
    def generate_monthly_report(self):
        """Generate comprehensive monthly performance report"""
        self.collect_performance_metrics()
        spu_analysis = self.analyze_spu_utilization()
        
        report = f"""
SRX Monthly Performance Report - {datetime.now().strftime('%Y-%m')}
================================================================

SPU Performance Analysis:
- Average CPU Utilization: {spu_analysis['average_cpu_utilization']:.1f}%
- Peak CPU Utilization: {spu_analysis['max_cpu_utilization']}%
- Active SPU Count: {spu_analysis['spu_count']}
- Recommendation: {spu_analysis['recommendation']}

Session Analysis:
- Active Sessions: [Parsed from session stats]
- Session Rate: [Calculated from trends]
- Memory Utilization: [Parsed from memory stats]

Optimization Recommendations:
1. Review high-utilization periods and traffic patterns
2. Consider policy optimization for frequently hit rules
3. Evaluate session timeout configurations
4. Monitor interface utilization for bottlenecks

Next Steps:
- Schedule performance review meeting
- Plan capacity expansion if needed
- Update monitoring thresholds based on trends
        """
        
        return report

# Usage
# analyzer = SRXPerformanceAnalyzer('10.0.1.1', 'admin', 'password')
# print(analyzer.generate_monthly_report())
```

---

## Emergency Response Procedures

### Security Incident Response

**Immediate Response Checklist**
1. **Assess Threat Level**
   - Identify attack type and source
   - Evaluate potential impact scope
   - Determine response priority level

2. **Containment Actions**
   ```bash
   # Block malicious IP addresses
   set security policies from-zone untrust to-zone trust policy emergency-block
   set security policies from-zone untrust to-zone trust policy emergency-block match source-address 192.0.2.100/32
   set security policies from-zone untrust to-zone trust policy emergency-block then deny
   set security policies from-zone untrust to-zone trust policy emergency-block then log
   commit
   
   # Enable additional logging for forensics
   set security log mode event
   set security log report
   commit
   ```

3. **Evidence Collection**
   ```bash
   # Capture current session information
   show security flow session extensive | save /var/tmp/incident-sessions-$(date +%Y%m%d-%H%M%S).log
   
   # Export security logs
   show log messages | match "attack\|intrusion\|malware" | save /var/tmp/security-events-$(date +%Y%m%d-%H%M%S).log
   
   # Network traffic analysis
   monitor traffic interface ge-0/0/0 matching "host 192.0.2.100" | save /var/tmp/suspicious-traffic.pcap
   ```

### System Failure Recovery

**High Availability Failover**
```bash
# Manual failover procedures
request chassis cluster failover redundancy-group 1 node 0

# Verify failover status
show chassis cluster status
show chassis cluster interfaces

# Monitor failover events
monitor start messages
show log messages | match "cluster\|failover"
```

**Configuration Recovery**
```bash
# Rollback to previous configuration
rollback 1
commit confirm 10

# Restore from backup
file copy ftp://backup-server/config-backup.gz /config/juniper.conf.gz
request system configuration rescue save
load rescue
commit
```

### Network Connectivity Issues

**Interface Troubleshooting**
```bash
# Physical layer diagnostics
show interfaces diagnostics optics ge-0/0/0
show interfaces extensive ge-0/0/0

# Link layer analysis
show ethernet-switching table
show arp no-resolve

# Network layer connectivity
ping 8.8.8.8 source 10.0.1.1 count 5
traceroute 8.8.8.8 source 10.0.1.1
```

**Routing Issues**
```bash
# Routing table analysis
show route extensive
show route forwarding-table

# BGP/OSPF troubleshooting (if applicable)
show bgp summary
show ospf neighbor
show ospf database
```

---

## Troubleshooting Procedures

### Common Issues and Solutions

**Session Table Exhaustion**
```bash
# Symptoms check
show security monitoring performance session
show security flow session summary

# Temporary mitigation
set security flow session-table maximum-sessions 1000000
set security flow tcp-session time-wait 5
commit

# Long-term solution analysis
show security flow session count by-source-ip
show security flow session count by-destination-ip
```

**High CPU Utilization**
```bash
# Identify CPU consumers
show security monitoring performance spu
show security monitoring fpc detail

# Analyze traffic patterns
show security monitoring top-sessions
show interfaces statistics

# Mitigation strategies
set security flow advanced-options drop-matching-reserved-ip-address
set security forwarding-options family inet6 mode packet-based
```

**IDP Service Issues**
```bash
# IDP status verification
show security idp status detail
show security idp counters

# Signature database check
request security idp security-package download check-server
request security idp security-package download install

# Performance optimization
set security idp sensor-configuration log suppression disable
set security idp sensor-configuration packet-log total-memory 200
```

### Performance Degradation Analysis

**Systematic Performance Investigation**
```python
#!/usr/bin/env python3
"""
SRX Performance Degradation Analysis Tool
"""

class SRXPerformanceTroubleshooter:
    def __init__(self, device_ip, username, password):
        self.device_ip = device_ip
        self.username = username
        self.password = password
        self.baseline_metrics = {}
        self.current_metrics = {}
        
    def collect_baseline_metrics(self):
        """Collect baseline performance metrics during normal operation"""
        metrics_commands = {
            'cpu_utilization': 'show chassis routing-engine',
            'spu_utilization': 'show security monitoring performance spu',
            'session_count': 'show security flow session summary',
            'memory_usage': 'show system memory',
            'interface_utilization': 'show interfaces extensive'
        }
        
        # Implementation would collect metrics via SSH
        pass
    
    def analyze_performance_delta(self):
        """Compare current metrics against baseline"""
        performance_report = {
            'cpu_delta': 0,
            'memory_delta': 0,
            'session_delta': 0,
            'recommendations': []
        }
        
        # Analysis logic would compare metrics and generate recommendations
        
        if performance_report['cpu_delta'] > 20:
            performance_report['recommendations'].append(
                "High CPU utilization increase detected. Check for policy inefficiencies."
            )
            
        if performance_report['memory_delta'] > 30:
            performance_report['recommendations'].append(
                "Memory usage spike detected. Analyze session table and flow caching."
            )
            
        return performance_report
    
    def generate_troubleshooting_steps(self, issue_type):
        """Generate specific troubleshooting steps based on issue type"""
        troubleshooting_guides = {
            'high_cpu': [
                "1. Check SPU utilization: show security monitoring performance spu",
                "2. Analyze top sessions: show security monitoring top-sessions",
                "3. Review security policy efficiency",
                "4. Consider policy optimization or hardware scaling"
            ],
            'session_exhaustion': [
                "1. Check current session count limits",
                "2. Analyze session distribution by application",
                "3. Review session timeout configurations",
                "4. Implement connection limiting if necessary"
            ],
            'memory_issues': [
                "1. Monitor memory usage trends",
                "2. Check for memory leaks in processes",
                "3. Analyze flow table size and optimization",
                "4. Consider memory upgrade if persistent"
            ]
        }
        
        return troubleshooting_guides.get(issue_type, ["Generic troubleshooting steps"])

# Usage example:
# troubleshooter = SRXPerformanceTroubleshooter('10.0.1.1', 'admin', 'password')
# print(troubleshooter.generate_troubleshooting_steps('high_cpu'))
```

---

## Maintenance Scheduling

### Planned Maintenance Windows

**Pre-Maintenance Checklist**
- [ ] Schedule approved by change management board
- [ ] Backup current configuration and system state
- [ ] Notify stakeholders of maintenance window
- [ ] Prepare rollback procedures
- [ ] Verify high availability configuration (if applicable)

**Maintenance Execution Process**
1. **Pre-change verification**
   ```bash
   show system uptime
   show chassis alarms
   show security policies hit-count
   request system snapshot slice alternate
   ```

2. **Change implementation**
   ```bash
   configure
   # Implement required changes
   commit confirmed 10
   # Verify changes are working correctly
   commit
   ```

3. **Post-change validation**
   ```bash
   show chassis alarms
   show security idp status
   show interfaces terse
   ping 8.8.8.8 source 10.0.1.1
   ```

### Preventive Maintenance Tasks

**Quarterly Tasks**
- Security signature database updates
- Certificate expiration review and renewal
- Performance baseline documentation
- Disaster recovery testing
- Security policy audit and optimization

**Annual Tasks**
- Hardware warranty and support contract renewal
- Security compliance audit
- Disaster recovery plan review and testing
- Security team training and certification updates
- Infrastructure capacity planning review

---

## Monitoring and Alerting

### Key Performance Indicators (KPIs)

**System Health Metrics**
- CPU utilization (target: <70% average)
- Memory utilization (target: <80%)
- Session table utilization (target: <80% of maximum)
- Interface utilization (target: <80% of capacity)

**Security Effectiveness Metrics**
- Threat detection rate (target: >99%)
- False positive rate (target: <5%)
- Incident response time (target: <15 minutes)
- Policy compliance score (target: >95%)

**Alert Thresholds**
```bash
# SNMP alert configuration
set snmp trap-group critical-alerts targets 10.0.1.100
set snmp trap-group critical-alerts categories chassis
set snmp trap-group critical-alerts categories routing
set snmp trap-group critical-alerts categories security

# System resource alerts
set event-options generate-event cpu-high time-interval 300
set event-options policy cpu-alert events cpu-high
set event-options policy cpu-alert then execute-commands commands "show chassis routing-engine"
```

This comprehensive operations runbook provides the foundation for effective day-to-day management of the Juniper SRX Firewall Platform, ensuring optimal security posture and operational efficiency.