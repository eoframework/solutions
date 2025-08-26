# Juniper SRX Firewall Platform Troubleshooting Guide

## Overview

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common issues with Juniper SRX Firewall Platform deployments. The guide covers connectivity issues, performance problems, security service failures, and advanced troubleshooting techniques.

---

## General Troubleshooting Methodology

### Systematic Approach

**Problem Resolution Framework**
```
1. Problem Identification
   ├─ Gather symptoms and error messages
   ├─ Identify affected systems and users
   └─ Determine impact scope and priority

2. Information Gathering
   ├─ Collect system logs and configurations
   ├─ Review recent changes
   └─ Check monitoring alerts and metrics

3. Problem Analysis
   ├─ Isolate the issue to specific components
   ├─ Compare with baseline configurations
   └─ Identify potential root causes

4. Solution Implementation
   ├─ Apply targeted fixes
   ├─ Test and validate resolution
   └─ Document solution and prevention

5. Follow-up and Prevention
   ├─ Monitor for recurrence
   ├─ Update procedures and documentation
   └─ Implement preventive measures
```

**Basic Diagnostic Commands**
```bash
# System health check
show chassis hardware
show chassis environment
show chassis alarms
show system uptime
show version

# Interface status
show interfaces terse
show interfaces extensive ge-0/0/0
show interfaces diagnostics optics

# Security status
show security zones
show security policies
show security flow session summary
show security monitoring performance spu
```

---

## Connectivity Issues

### Network Layer Connectivity

**Basic Connectivity Troubleshooting**
```bash
# Layer 3 connectivity tests
ping 8.8.8.8 source 192.168.1.1
ping 8.8.8.8 source 192.168.1.1 count 100 size 1472
traceroute 8.8.8.8 source 192.168.1.1

# Interface troubleshooting
show interfaces extensive ge-0/0/0
show interfaces statistics ge-0/0/0
show route
show route extensive 8.8.8.8
```

**Common Connectivity Issues and Solutions**

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| No Internet Access | Cannot reach external sites | Check default route, NAT config | Configure proper routing and NAT |
| Interface Down | Physical link down | Check cables, optics, switch ports | Replace cables, check switch config |
| High Latency | Slow response times | Monitor interface utilization | Check for congestion, upgrade bandwidth |
| Packet Loss | Intermittent connectivity | Check error counters, logs | Identify and fix error sources |

**Advanced Connectivity Diagnostics**
```bash
# ARP table inspection
show arp no-resolve
show arp hostname

# Routing table analysis
show route forwarding-table
show route advertising-protocol bgp 203.0.113.1
show ospf neighbor
show bgp summary

# Interface statistics deep dive
show interfaces extensive | match "Input rate\|Output rate\|Errors"
clear interfaces statistics all
# Wait and recheck for new errors

# VLAN troubleshooting
show vlans extensive
show ethernet-switching table
show bridge mac-table
```

### Security Policy Connectivity Issues

**Policy-Related Connectivity Problems**
```bash
# Policy troubleshooting commands
show security policies hit-count
show security policies detail | match count
show security match-policies from-zone trust to-zone untrust source-ip 192.168.1.100 destination-ip 8.8.8.8 protocol tcp destination-port 80

# Session troubleshooting
show security flow session destination-ip 8.8.8.8
show security flow session source-prefix 192.168.1.0/24
show security flow session extensive destination-ip 8.8.8.8

# Clear specific sessions for testing
clear security flow session destination-ip 8.8.8.8
clear security flow session source-prefix 192.168.1.0/24
```

**Security Policy Troubleshooting Script**
```python
#!/usr/bin/env python3
"""
SRX Policy Troubleshooting Tool
Automated diagnosis of connectivity issues related to security policies
"""

import paramiko
import re
from ipaddress import ip_address, ip_network

class SRXPolicyTroubleshooter:
    def __init__(self, device_ip, username, password):
        self.device_ip = device_ip
        self.username = username
        self.password = password
        self.ssh_client = None
        
    def connect(self):
        """Establish SSH connection"""
        self.ssh_client = paramiko.SSHClient()
        self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh_client.connect(
            hostname=self.device_ip,
            username=self.username,
            password=self.password
        )
    
    def execute_command(self, command):
        """Execute command and return output"""
        stdin, stdout, stderr = self.ssh_client.exec_command(command)
        return stdout.read().decode(), stderr.read().decode()
    
    def diagnose_connectivity(self, source_ip, destination_ip, destination_port=80, protocol='tcp'):
        """Diagnose connectivity issues for specific flow"""
        print(f"Diagnosing connectivity: {source_ip} -> {destination_ip}:{destination_port}/{protocol}")
        
        # Check if flow matches any policies
        match_cmd = f"show security match-policies from-zone trust to-zone untrust source-ip {source_ip} destination-ip {destination_ip} protocol {protocol} destination-port {destination_port}"
        policy_output, _ = self.execute_command(match_cmd)
        
        if "Policy:" in policy_output:
            print("✓ Traffic matches security policy")
            self.analyze_policy_match(policy_output)
        else:
            print("✗ No matching security policy found")
            self.suggest_policy_creation(source_ip, destination_ip, destination_port, protocol)
        
        # Check for existing sessions
        session_cmd = f"show security flow session destination-ip {destination_ip}"
        session_output, _ = self.execute_command(session_cmd)
        
        if destination_ip in session_output:
            print("✓ Active sessions found")
            self.analyze_sessions(session_output)
        else:
            print("✗ No active sessions found")
        
        # Check NAT configuration
        self.check_nat_configuration()
        
        # Check routing
        self.check_routing(destination_ip)
    
    def analyze_policy_match(self, policy_output):
        """Analyze matched policy details"""
        lines = policy_output.split('\n')
        for line in lines:
            if 'Policy:' in line:
                policy_name = line.split('Policy:')[1].strip()
                print(f"  Matched Policy: {policy_name}")
            elif 'Action:' in line:
                action = line.split('Action:')[1].strip()
                print(f"  Action: {action}")
                if action.lower() != 'permit':
                    print("  ⚠️  Policy denies traffic")
    
    def suggest_policy_creation(self, source_ip, destination_ip, destination_port, protocol):
        """Suggest policy configuration"""
        print("\n📋 Suggested Policy Configuration:")
        print(f"set security policies from-zone trust to-zone untrust policy allow-{protocol}-{destination_port}")
        print(f"set security policies from-zone trust to-zone untrust policy allow-{protocol}-{destination_port} match source-address {source_ip}")
        print(f"set security policies from-zone trust to-zone untrust policy allow-{protocol}-{destination_port} match destination-address {destination_ip}")
        print(f"set security policies from-zone trust to-zone untrust policy allow-{protocol}-{destination_port} match application junos-{protocol}-{destination_port}")
        print(f"set security policies from-zone trust to-zone untrust policy allow-{protocol}-{destination_port} then permit")
    
    def analyze_sessions(self, session_output):
        """Analyze session information"""
        session_count = session_output.count('Session ID:')
        print(f"  Active sessions: {session_count}")
        
        # Look for session states
        if 'Established' in session_output:
            print("  ✓ Sessions in established state")
        elif 'Invalid' in session_output:
            print("  ⚠️  Invalid sessions detected")
        elif 'Close' in session_output:
            print("  ⚠️  Sessions closing/closed")
    
    def check_nat_configuration(self):
        """Check NAT configuration"""
        nat_output, _ = self.execute_command("show security nat source summary")
        
        if "rule-set" in nat_output:
            print("✓ Source NAT configured")
        else:
            print("⚠️  No source NAT configuration found")
            print("  Consider configuring source NAT for internet access")
    
    def check_routing(self, destination_ip):
        """Check routing to destination"""
        route_output, _ = self.execute_command(f"show route {destination_ip}")
        
        if destination_ip in route_output or "0.0.0.0/0" in route_output:
            print("✓ Route to destination exists")
        else:
            print("✗ No route to destination")
            print("  Check default route configuration")
    
    def generate_report(self):
        """Generate troubleshooting report"""
        report = f"""
SRX Connectivity Troubleshooting Report
======================================
Device: {self.device_ip}
Timestamp: {self.get_timestamp()}

Diagnostic Summary:
- Policy Analysis: [Results above]
- Session Analysis: [Results above]  
- NAT Configuration: [Results above]
- Routing Check: [Results above]

Recommendations:
1. Review and update security policies as needed
2. Monitor session establishment and termination
3. Verify NAT configuration for outbound traffic
4. Confirm routing table entries
        """
        return report
    
    def get_timestamp(self):
        """Get current timestamp from device"""
        timestamp_output, _ = self.execute_command("show system uptime")
        # Parse timestamp from output
        return timestamp_output.split('\n')[0] if timestamp_output else "Unknown"

# Usage example:
# troubleshooter = SRXPolicyTroubleshooter('10.0.1.1', 'admin', 'password')
# troubleshooter.connect()
# troubleshooter.diagnose_connectivity('192.168.1.100', '8.8.8.8', 80, 'tcp')
```

---

## Performance Issues

### High CPU Utilization

**CPU Performance Diagnostics**
```bash
# Check overall system performance
show chassis routing-engine
show security monitoring performance spu
show security monitoring performance services

# Identify high CPU processes
show system processes extensive
show security flow session statistics
show security monitoring fpc detail

# Check for security service load
show security idp counters
show security utm statistics
show services application-identification statistics
```

**CPU Performance Optimization**
```bash
# Session optimization
set security flow tcp-session time-wait 5
set security flow tcp-session fin-wait 5
set security flow tcp-session close-wait 5

# Flow processing optimization
set security flow advanced-options drop-matching-reserved-ip-address
set security flow advanced-options drop-matching-link-local-address
set security flow advanced-options reverse-route-packet-mode loose

# Security service tuning
set security idp sensor-configuration log suppression disable
set security idp sensor-configuration packet-log total-memory 200
```

### Session Exhaustion

**Session Table Analysis**
```bash
# Check session table utilization
show security flow session summary
show security monitoring performance session

# Analyze session distribution
show security flow session count by-source-ip
show security flow session count by-destination-ip
show security flow session count by-application

# Session troubleshooting
show security flow session source-prefix 192.168.1.0/24
show security flow session destination-prefix 8.8.8.0/24
```

**Session Optimization Script**
```python
#!/usr/bin/env python3
"""
SRX Session Optimization Tool
Analyzes session patterns and provides optimization recommendations
"""

import paramiko
import re
from collections import defaultdict

class SRXSessionOptimizer:
    def __init__(self, device_ip, username, password):
        self.device_ip = device_ip
        self.username = username
        self.password = password
        self.ssh_client = None
        
    def connect(self):
        """Establish SSH connection"""
        self.ssh_client = paramiko.SSHClient()
        self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh_client.connect(
            hostname=self.device_ip,
            username=self.username,
            password=self.password
        )
    
    def execute_command(self, command):
        """Execute command and return output"""
        stdin, stdout, stderr = self.ssh_client.exec_command(command)
        return stdout.read().decode()
    
    def analyze_session_distribution(self):
        """Analyze session distribution patterns"""
        # Get session counts by source IP
        source_output = self.execute_command("show security flow session count by-source-ip")
        source_sessions = self.parse_session_counts(source_output)
        
        # Get session counts by application
        app_output = self.execute_command("show security flow session count by-application")
        app_sessions = self.parse_session_counts(app_output)
        
        return source_sessions, app_sessions
    
    def parse_session_counts(self, output):
        """Parse session count output"""
        session_data = {}
        lines = output.split('\n')
        
        for line in lines:
            # Look for pattern: IP/App followed by session count
            match = re.search(r'(\S+)\s+(\d+)', line)
            if match:
                key, count = match.groups()
                session_data[key] = int(count)
        
        return session_data
    
    def identify_session_hogs(self, session_data, threshold=1000):
        """Identify sources/apps with high session counts"""
        session_hogs = {}
        for key, count in session_data.items():
            if count > threshold:
                session_hogs[key] = count
        
        return dict(sorted(session_hogs.items(), key=lambda x: x[1], reverse=True))
    
    def get_session_summary(self):
        """Get overall session table summary"""
        summary_output = self.execute_command("show security flow session summary")
        
        # Parse session summary
        summary_data = {}
        for line in summary_output.split('\n'):
            if 'Active sessions:' in line:
                summary_data['active'] = int(line.split(':')[1].strip())
            elif 'Maximum sessions:' in line:
                summary_data['maximum'] = int(line.split(':')[1].strip())
            elif 'Session creation rate:' in line:
                summary_data['creation_rate'] = line.split(':')[1].strip()
        
        return summary_data
    
    def generate_optimization_recommendations(self, source_sessions, app_sessions, summary):
        """Generate optimization recommendations"""
        recommendations = []
        
        # Check session table utilization
        if summary.get('active', 0) > summary.get('maximum', 100000) * 0.8:
            recommendations.append({
                'priority': 'HIGH',
                'issue': 'Session table near capacity',
                'recommendation': 'Increase session table size or optimize timeouts',
                'config': 'set security flow session-table maximum-sessions 2000000'
            })
        
        # Check for session concentration
        source_hogs = self.identify_session_hogs(source_sessions, 500)
        if source_hogs:
            recommendations.append({
                'priority': 'MEDIUM',
                'issue': f'High session count sources: {list(source_hogs.keys())[:5]}',
                'recommendation': 'Investigate high-session sources for potential issues',
                'config': 'Consider implementing connection limits per source'
            })
        
        # Check application distribution
        app_hogs = self.identify_session_hogs(app_sessions, 1000)
        if app_hogs:
            recommendations.append({
                'priority': 'MEDIUM',
                'issue': f'High session applications: {list(app_hogs.keys())[:5]}',
                'recommendation': 'Optimize application-specific timeouts',
                'config': 'set security flow tcp-session time-wait 10'
            })
        
        return recommendations
    
    def generate_report(self):
        """Generate comprehensive session analysis report"""
        source_sessions, app_sessions = self.analyze_session_distribution()
        summary = self.get_session_summary()
        recommendations = self.generate_optimization_recommendations(
            source_sessions, app_sessions, summary
        )
        
        report = f"""
SRX Session Analysis Report
==========================
Device: {self.device_ip}

Session Summary:
- Active Sessions: {summary.get('active', 'Unknown')}
- Maximum Sessions: {summary.get('maximum', 'Unknown')}
- Utilization: {(summary.get('active', 0) / max(summary.get('maximum', 1), 1) * 100):.1f}%

Top Session Sources:
"""
        # Add top 10 sources
        top_sources = dict(sorted(source_sessions.items(), key=lambda x: x[1], reverse=True)[:10])
        for source, count in top_sources.items():
            report += f"  {source}: {count} sessions\n"
        
        report += "\nTop Session Applications:\n"
        # Add top 10 applications
        top_apps = dict(sorted(app_sessions.items(), key=lambda x: x[1], reverse=True)[:10])
        for app, count in top_apps.items():
            report += f"  {app}: {count} sessions\n"
        
        report += "\nOptimization Recommendations:\n"
        for i, rec in enumerate(recommendations, 1):
            report += f"{i}. [{rec['priority']}] {rec['issue']}\n"
            report += f"   Recommendation: {rec['recommendation']}\n"
            report += f"   Configuration: {rec['config']}\n\n"
        
        return report

# Usage example:
# optimizer = SRXSessionOptimizer('10.0.1.1', 'admin', 'password')
# optimizer.connect()
# print(optimizer.generate_report())
```

### Interface Performance Issues

**Interface Performance Diagnostics**
```bash
# Interface utilization and errors
show interfaces extensive ge-0/0/0
show interfaces statistics ge-0/0/0
show interfaces diagnostics optics ge-0/0/0

# Traffic analysis
monitor traffic interface ge-0/0/0
monitor traffic interface ge-0/0/0 matching "host 192.168.1.100"

# QoS and traffic shaping
show class-of-service interface
show class-of-service forwarding-class
```

---

## Security Service Issues

### IDP Service Problems

**IDP Troubleshooting Commands**
```bash
# IDP service status
show security idp status
show security idp status detail
show security idp counters

# Signature database status
show security idp security-package-version
show security idp security-package-status

# Attack detection analysis
show security idp attack table
show security idp counters packet-drops
show log messages | match IDP
```

**Common IDP Issues and Solutions**

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| IDP Not Running | Status shows "Not running" | Check licensing, resources | Enable IDP license, restart services |
| Signature Updates Failing | Old signature version | Check internet connectivity | Fix DNS/proxy, manual download |
| High False Positives | Excessive IDP alerts | Review attack table, logs | Tune IDP policies, whitelist legitimate traffic |
| Performance Impact | High CPU, low throughput | Check IDP processing load | Optimize IDP rules, selective processing |

**IDP Optimization Configuration**
```bash
# Selective IDP processing
set security idp sensor-configuration log suppression disable
set security idp sensor-configuration packet-log total-memory 200
set security idp sensor-configuration security-package automatic enable
set security idp sensor-configuration security-package automatic start-time "02:00:00 +0000"

# Performance tuning
set security idp sensor-configuration detector tcp reassembly enable
set security idp sensor-configuration detector tcp reassembly maximum-packet-count 50
```

### UTM Service Issues

**UTM Troubleshooting**
```bash
# UTM service status
show security utm status
show security utm web-filtering statistics
show security utm anti-malware statistics

# UTM license status
show system license

# UTM configuration verification
show security utm web-filtering profile
show security utm anti-malware
```

**UTM Performance Optimization**
```bash
# Web filtering optimization
set security utm web-filtering profile web-filter fallback-settings default permit
set security utm web-filtering profile web-filter fallback-settings server-connectivity permit
set security utm web-filtering profile web-filter fallback-settings timeout permit

# Anti-malware optimization
set security utm anti-malware fallback-options default permit
set security utm anti-malware fallback-options timeout permit
set security utm anti-malware fallback-options too-many-requests permit
```

---

## High Availability Issues

### Chassis Cluster Problems

**Cluster Troubleshooting Commands**
```bash
# Cluster status verification
show chassis cluster status
show chassis cluster statistics
show chassis cluster interfaces

# Redundancy group status
show chassis cluster redundancy-group
show chassis cluster failover-time

# Control and fabric link status
show chassis cluster control-plane statistics
show chassis cluster data-plane statistics
```

**Common HA Issues and Solutions**

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| Split Brain | Both nodes primary | Check control links | Fix control link connectivity |
| Frequent Failovers | Cluster instability | Check heartbeat, thresholds | Tune failover parameters |
| Session Sync Issues | Session loss on failover | Check fabric links | Verify fabric link configuration |
| Interface Inconsistency | reth interface problems | Check member interfaces | Verify physical interface status |

**HA Troubleshooting Script**
```python
#!/usr/bin/env python3
"""
SRX High Availability Troubleshooting Tool
Diagnoses cluster issues and provides remediation guidance
"""

import paramiko
import re
import time

class SRXHATroubleshooter:
    def __init__(self, primary_ip, secondary_ip, username, password):
        self.primary_ip = primary_ip
        self.secondary_ip = secondary_ip
        self.username = username
        self.password = password
        
    def connect_node(self, node_ip):
        """Connect to cluster node"""
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(hostname=node_ip, username=self.username, password=self.password)
        return ssh_client
    
    def execute_command(self, ssh_client, command):
        """Execute command on node"""
        stdin, stdout, stderr = ssh_client.exec_command(command)
        return stdout.read().decode()
    
    def check_cluster_status(self):
        """Check overall cluster status"""
        try:
            primary_ssh = self.connect_node(self.primary_ip)
            status_output = self.execute_command(primary_ssh, "show chassis cluster status")
            primary_ssh.close()
            
            # Parse cluster status
            cluster_info = self.parse_cluster_status(status_output)
            return cluster_info
            
        except Exception as e:
            return {'error': f"Failed to connect to primary node: {e}"}
    
    def parse_cluster_status(self, status_output):
        """Parse cluster status output"""
        cluster_info = {
            'cluster_id': None,
            'node0_status': None,
            'node1_status': None,
            'redundancy_groups': {}
        }
        
        lines = status_output.split('\n')
        current_rg = None
        
        for line in lines:
            if 'Cluster ID:' in line:
                cluster_info['cluster_id'] = line.split(':')[1].strip()
            elif 'Node 0' in line and 'status:' in line:
                cluster_info['node0_status'] = line.split('status:')[1].strip()
            elif 'Node 1' in line and 'status:' in line:
                cluster_info['node1_status'] = line.split('status:')[1].strip()
            elif 'Redundancy group:' in line:
                rg_num = line.split(':')[1].strip()
                current_rg = f"RG{rg_num}"
                cluster_info['redundancy_groups'][current_rg] = {}
            elif current_rg and ('primary' in line.lower() or 'secondary' in line.lower()):
                if 'node 0' in line.lower():
                    cluster_info['redundancy_groups'][current_rg]['node0'] = 'primary' if 'primary' in line.lower() else 'secondary'
                elif 'node 1' in line.lower():
                    cluster_info['redundancy_groups'][current_rg]['node1'] = 'primary' if 'primary' in line.lower() else 'secondary'
        
        return cluster_info
    
    def diagnose_cluster_issues(self):
        """Diagnose common cluster issues"""
        cluster_info = self.check_cluster_status()
        issues = []
        
        if 'error' in cluster_info:
            issues.append({
                'severity': 'CRITICAL',
                'issue': 'Cluster Status Check Failed',
                'description': cluster_info['error'],
                'recommendation': 'Check network connectivity to cluster nodes'
            })
            return issues
        
        # Check for split brain
        for rg_name, rg_info in cluster_info['redundancy_groups'].items():
            if rg_info.get('node0') == 'primary' and rg_info.get('node1') == 'primary':
                issues.append({
                    'severity': 'CRITICAL',
                    'issue': f'Split Brain Detected in {rg_name}',
                    'description': 'Both nodes showing as primary',
                    'recommendation': 'Check control link connectivity and configuration'
                })
        
        # Check node status
        if cluster_info['node0_status'] != 'Hold' or cluster_info['node1_status'] != 'Hold':
            issues.append({
                'severity': 'HIGH',
                'issue': 'Node Status Issue',
                'description': f"Node 0: {cluster_info['node0_status']}, Node 1: {cluster_info['node1_status']}",
                'recommendation': 'Investigate node health and heartbeat connectivity'
            })
        
        # Check for missing redundancy groups
        if len(cluster_info['redundancy_groups']) < 2:
            issues.append({
                'severity': 'MEDIUM',
                'issue': 'Insufficient Redundancy Groups',
                'description': 'Less than 2 redundancy groups configured',
                'recommendation': 'Configure redundancy groups for proper failover'
            })
        
        return issues
    
    def check_interface_consistency(self):
        """Check interface consistency across cluster nodes"""
        try:
            primary_ssh = self.connect_node(self.primary_ip)
            interfaces_output = self.execute_command(primary_ssh, "show chassis cluster interfaces")
            primary_ssh.close()
            
            # Parse interface status
            interface_issues = []
            lines = interfaces_output.split('\n')
            
            for line in lines:
                if 'reth' in line and ('down' in line.lower() or 'failed' in line.lower()):
                    interface_issues.append({
                        'severity': 'HIGH',
                        'issue': 'Redundant Interface Down',
                        'description': line.strip(),
                        'recommendation': 'Check physical interface status and configuration'
                    })
            
            return interface_issues
            
        except Exception as e:
            return [{'severity': 'HIGH', 'issue': 'Interface Check Failed', 'description': str(e)}]
    
    def generate_ha_report(self):
        """Generate comprehensive HA troubleshooting report"""
        cluster_issues = self.diagnose_cluster_issues()
        interface_issues = self.check_interface_consistency()
        
        all_issues = cluster_issues + interface_issues
        
        report = f"""
SRX High Availability Troubleshooting Report
===========================================
Primary Node: {self.primary_ip}
Secondary Node: {self.secondary_ip}

Issue Summary:
- Critical Issues: {len([i for i in all_issues if i['severity'] == 'CRITICAL'])}
- High Priority Issues: {len([i for i in all_issues if i['severity'] == 'HIGH'])}
- Medium Priority Issues: {len([i for i in all_issues if i['severity'] == 'MEDIUM'])}

Detailed Issues:
"""
        
        for i, issue in enumerate(all_issues, 1):
            report += f"\n{i}. [{issue['severity']}] {issue['issue']}\n"
            report += f"   Description: {issue['description']}\n"
            report += f"   Recommendation: {issue['recommendation']}\n"
        
        if not all_issues:
            report += "\n✓ No critical issues detected in cluster configuration\n"
        
        return report

# Usage example:
# ha_troubleshooter = SRXHATroubleshooter('10.0.1.1', '10.0.1.2', 'admin', 'password')
# print(ha_troubleshooter.generate_ha_report())
```

---

## VPN Troubleshooting

### IPsec VPN Issues

**IPsec Troubleshooting Commands**
```bash
# IKE status and troubleshooting
show security ike security-associations
show security ike security-associations detail
show security ike statistics

# IPsec tunnel status
show security ipsec security-associations
show security ipsec security-associations detail
show security ipsec statistics

# VPN logs and debugging
show log messages | match "KMD\|IKE\|IPSEC"
set security ike traceoptions file ike-debug
set security ike traceoptions flag all
```

**Common IPsec Issues and Solutions**

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| Phase 1 Failure | No IKE SA established | Check IKE policy, PSK, connectivity | Fix IKE configuration, verify PSK |
| Phase 2 Failure | IKE SA present, no IPsec SA | Check IPsec policy, proxy IDs | Fix IPsec policy configuration |
| Traffic Not Flowing | Tunnel up, no data transfer | Check routing, policies | Configure proper routing and security policies |
| Frequent Disconnections | Tunnel instability | Check keepalives, DPD | Configure proper keepalive and DPD settings |

### SSL VPN Issues

**SSL VPN Troubleshooting**
```bash
# SSL VPN status
show security ssl-vpn sessions
show security ssl-vpn sessions detail

# SSL VPN configuration verification
show security ssl-vpn profile
show security ssl-vpn resource-profile

# SSL VPN logs
show log messages | match "SSL-VPN\|SSLVPN"
```

---

## Log Analysis and Monitoring

### Security Event Analysis

**Security Log Categories**
```bash
# Security flow logs
show log messages | match RT_FLOW

# IDP attack logs  
show log messages | match IDP_ATTACK

# UTM security logs
show log messages | match "WEBFILTER\|ANTIMALWARE"

# VPN logs
show log messages | match "VPN\|IKE\|IPSEC"

# Authentication logs
show log messages | match "LOGIN\|AUTH"
```

**Automated Log Analysis Script**
```python
#!/usr/bin/env python3
"""
SRX Security Event Analysis Tool
Automated analysis of security logs for threat detection and troubleshooting
"""

import paramiko
import re
from collections import defaultdict, Counter
from datetime import datetime, timedelta

class SRXLogAnalyzer:
    def __init__(self, device_ip, username, password):
        self.device_ip = device_ip
        self.username = username
        self.password = password
        self.ssh_client = None
        
    def connect(self):
        """Establish SSH connection"""
        self.ssh_client = paramiko.SSHClient()
        self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh_client.connect(
            hostname=self.device_ip,
            username=self.username,
            password=self.password
        )
    
    def execute_command(self, command):
        """Execute command and return output"""
        stdin, stdout, stderr = self.ssh_client.exec_command(command)
        return stdout.read().decode()
    
    def analyze_security_events(self, hours_back=24):
        """Analyze security events from logs"""
        # Get security-related log entries
        log_commands = [
            "show log messages | match RT_FLOW | last 1000",
            "show log messages | match IDP_ATTACK | last 500", 
            "show log messages | match 'WEBFILTER\\|ANTIMALWARE' | last 500"
        ]
        
        all_events = []
        event_summary = {
            'flow_events': [],
            'idp_attacks': [],
            'utm_blocks': [],
            'summary_stats': defaultdict(int)
        }
        
        for command in log_commands:
            output = self.execute_command(command)
            events = self.parse_log_events(output)
            all_events.extend(events)
            
            # Categorize events
            if 'RT_FLOW' in command:
                event_summary['flow_events'] = events
            elif 'IDP_ATTACK' in command:
                event_summary['idp_attacks'] = events
            elif 'WEBFILTER' in command or 'ANTIMALWARE' in command:
                event_summary['utm_blocks'] = events
        
        # Generate statistics
        self.generate_event_statistics(all_events, event_summary['summary_stats'])
        
        return event_summary
    
    def parse_log_events(self, log_output):
        """Parse log events from output"""
        events = []
        lines = log_output.split('\n')
        
        for line in lines:
            if not line.strip():
                continue
                
            event = self.parse_single_event(line)
            if event:
                events.append(event)
        
        return events
    
    def parse_single_event(self, log_line):
        """Parse individual log event"""
        # Basic log parsing - extract timestamp, event type, source/dest IPs
        event = {
            'timestamp': None,
            'event_type': None,
            'source_ip': None,
            'dest_ip': None,
            'action': None,
            'raw_line': log_line
        }
        
        # Extract timestamp
        timestamp_match = re.search(r'(\w{3}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2})', log_line)
        if timestamp_match:
            event['timestamp'] = timestamp_match.group(1)
        
        # Extract source and destination IPs
        ip_pattern = r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'
        ip_matches = re.findall(ip_pattern, log_line)
        if len(ip_matches) >= 2:
            event['source_ip'] = ip_matches[0]
            event['dest_ip'] = ip_matches[1]
        
        # Determine event type and action
        if 'RT_FLOW_SESSION_CREATE' in log_line:
            event['event_type'] = 'session_create'
            event['action'] = 'allow'
        elif 'RT_FLOW_SESSION_DENY' in log_line:
            event['event_type'] = 'session_deny'
            event['action'] = 'deny'
        elif 'IDP_ATTACK' in log_line:
            event['event_type'] = 'idp_attack'
            event['action'] = 'block'
        elif 'WEBFILTER' in log_line:
            event['event_type'] = 'web_filter'
            event['action'] = 'block'
        elif 'ANTIMALWARE' in log_line:
            event['event_type'] = 'anti_malware'
            event['action'] = 'block'
        
        return event if event['event_type'] else None
    
    def generate_event_statistics(self, events, stats):
        """Generate event statistics"""
        for event in events:
            stats['total_events'] += 1
            stats[f"{event['event_type']}_count"] += 1
            stats[f"{event['action']}_count"] += 1
            
            if event['source_ip']:
                stats['unique_source_ips'] = len(set(e['source_ip'] for e in events if e['source_ip']))
            if event['dest_ip']:
                stats['unique_dest_ips'] = len(set(e['dest_ip'] for e in events if e['dest_ip']))
    
    def identify_security_patterns(self, events):
        """Identify security patterns and anomalies"""
        patterns = []
        
        # Count events by source IP
        source_ip_counts = Counter(e['source_ip'] for e in events if e['source_ip'])
        
        # Identify top talkers
        top_sources = source_ip_counts.most_common(10)
        if top_sources and top_sources[0][1] > 100:
            patterns.append({
                'type': 'high_volume_source',
                'description': f"High volume traffic from {top_sources[0][0]} ({top_sources[0][1]} events)",
                'severity': 'medium',
                'recommendation': 'Investigate source for potential security threat'
            })
        
        # Count blocked events by type
        blocked_events = [e for e in events if e['action'] == 'block']
        if len(blocked_events) > len(events) * 0.1:  # More than 10% blocked
            patterns.append({
                'type': 'high_block_rate',
                'description': f"High block rate: {len(blocked_events)}/{len(events)} events blocked",
                'severity': 'high',
                'recommendation': 'Review security policies and investigate blocked traffic'
            })
        
        # Check for attack patterns
        attack_events = [e for e in events if e['event_type'] == 'idp_attack']
        if len(attack_events) > 50:
            patterns.append({
                'type': 'multiple_attacks',
                'description': f"Multiple IDP attacks detected: {len(attack_events)} events",
                'severity': 'high',
                'recommendation': 'Investigate attack sources and implement additional protections'
            })
        
        return patterns
    
    def generate_security_report(self):
        """Generate comprehensive security analysis report"""
        event_summary = self.analyze_security_events()
        patterns = self.identify_security_patterns(
            event_summary['flow_events'] + 
            event_summary['idp_attacks'] + 
            event_summary['utm_blocks']
        )
        
        stats = event_summary['summary_stats']
        
        report = f"""
SRX Security Event Analysis Report
=================================
Device: {self.device_ip}
Analysis Period: Last 24 hours

Event Summary:
- Total Events: {stats['total_events']}
- Session Creates: {stats['session_create_count']}
- Session Denies: {stats['session_deny_count']}
- IDP Attacks: {stats['idp_attack_count']}
- Web Filter Blocks: {stats['web_filter_count']}
- Anti-malware Blocks: {stats['anti_malware_count']}

Traffic Statistics:
- Unique Source IPs: {stats['unique_source_ips']}
- Unique Destination IPs: {stats['unique_dest_ips']}
- Block Rate: {(stats['block_count'] / max(stats['total_events'], 1) * 100):.1f}%

Security Patterns Detected:
"""
        
        for i, pattern in enumerate(patterns, 1):
            report += f"\n{i}. [{pattern['severity'].upper()}] {pattern['type']}\n"
            report += f"   Description: {pattern['description']}\n"
            report += f"   Recommendation: {pattern['recommendation']}\n"
        
        if not patterns:
            report += "\n✓ No significant security patterns detected\n"
        
        return report

# Usage example:
# analyzer = SRXLogAnalyzer('10.0.1.1', 'admin', 'password')
# analyzer.connect()
# print(analyzer.generate_security_report())
```

---

## Advanced Troubleshooting Techniques

### Packet Capture and Analysis

**Traffic Monitoring Commands**
```bash
# Real-time traffic monitoring
monitor traffic interface ge-0/0/0
monitor traffic interface ge-0/0/0 size 1500
monitor traffic interface ge-0/0/0 matching "host 192.168.1.100"

# Capture to file
monitor traffic interface ge-0/0/0 write-file /var/tmp/capture.pcap
monitor traffic interface ge-0/0/0 write-file /var/tmp/capture.pcap matching "port 80"

# Traffic statistics
monitor traffic interface ge-0/0/0 count 100
monitor traffic interface ge-0/0/0 absolute-sequence
```

### Performance Profiling

**System Resource Monitoring**
```bash
# Real-time system monitoring
monitor start chassis-control
monitor start security
monitor start interface

# Historical performance data
show system statistics
show security monitoring statistics
show interfaces statistics detail
```

### Configuration Verification

**Configuration Consistency Checks**
```bash
# Configuration validation
commit check
load check terminal

# Configuration comparison
show | compare rollback 1
show | compare rollback 2

# Configuration archival
save /var/tmp/config-backup-$(date +%Y%m%d).conf
```

This comprehensive troubleshooting guide provides systematic approaches to identifying, diagnosing, and resolving issues with Juniper SRX Firewall Platform deployments, ensuring optimal performance and security effectiveness.