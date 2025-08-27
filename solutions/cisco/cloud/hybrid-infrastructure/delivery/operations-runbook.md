# Cisco Hybrid Infrastructure Operations Runbook

## Overview

This operations runbook provides comprehensive procedures for the day-to-day management, monitoring, and troubleshooting of the Cisco Hybrid Cloud Infrastructure solution. It serves as the primary operational reference for IT teams managing the environment.

## Table of Contents

1. [Daily Operations](#daily-operations)
2. [Monitoring and Alerting](#monitoring-and-alerting)
3. [Maintenance Procedures](#maintenance-procedures)
4. [Backup and Recovery](#backup-and-recovery)
5. [Troubleshooting](#troubleshooting)
6. [Emergency Procedures](#emergency-procedures)
7. [Capacity Management](#capacity-management)
8. [Security Operations](#security-operations)

## Daily Operations

### 1.1 Morning Health Checks

**Daily System Status Verification**

```bash
#!/bin/bash
# Daily health check script - run at 8:00 AM

LOGFILE="/var/log/daily-healthcheck-$(date +%Y%m%d).log"
echo "=== Daily Health Check - $(date) ===" >> $LOGFILE

# HyperFlex Cluster Health
echo "Checking HyperFlex cluster status..." >> $LOGFILE
hxcli cluster info >> $LOGFILE 2>&1

if hxcli cluster info | grep -q "Cluster Status: ONLINE"; then
    echo "✓ HyperFlex cluster is ONLINE" >> $LOGFILE
else
    echo "✗ HyperFlex cluster issue detected" >> $LOGFILE
    # Send alert
    mail -s "ALERT: HyperFlex Cluster Issue" admin@company.com < $LOGFILE
fi

# Storage Capacity Check
echo "Checking storage capacity..." >> $LOGFILE
STORAGE_USAGE=$(hxcli datastore list | grep "Space Used" | awk '{print $3}' | sed 's/%//')
if [ $STORAGE_USAGE -gt 80 ]; then
    echo "⚠ WARNING: Storage usage is ${STORAGE_USAGE}%" >> $LOGFILE
    mail -s "WARNING: High Storage Usage" admin@company.com < $LOGFILE
else
    echo "✓ Storage usage is acceptable: ${STORAGE_USAGE}%" >> $LOGFILE
fi

# VMware vCenter Status
echo "Checking vCenter connectivity..." >> $LOGFILE
if curl -s -k https://<VCENTER-IP>/ui/ > /dev/null; then
    echo "✓ vCenter is accessible" >> $LOGFILE
else
    echo "✗ vCenter connectivity issue" >> $LOGFILE
    mail -s "ALERT: vCenter Connectivity Issue" admin@company.com < $LOGFILE
fi

# Network Connectivity
echo "Testing network connectivity..." >> $LOGFILE
CRITICAL_HOSTS=("8.8.8.8" "<DOMAIN-CONTROLLER-IP>" "<PRIMARY-DNS>")
for host in "${CRITICAL_HOSTS[@]}"; do
    if ping -c 3 $host > /dev/null 2>&1; then
        echo "✓ $host is reachable" >> $LOGFILE
    else
        echo "✗ $host is unreachable" >> $LOGFILE
        mail -s "ALERT: Network Connectivity Issue" admin@company.com < $LOGFILE
    fi
done

echo "=== Health Check Complete ===" >> $LOGFILE
```

**Checklist Items:**
- [ ] HyperFlex cluster status: ONLINE
- [ ] Storage capacity < 80%
- [ ] vCenter accessibility confirmed
- [ ] Critical network connectivity verified
- [ ] ACI fabric health confirmed
- [ ] Backup job status reviewed
- [ ] Security alerts reviewed
- [ ] Performance metrics within baseline

### 1.2 System Monitoring Dashboard

**Key Metrics to Monitor:**

| Component | Metric | Normal Range | Alert Threshold |
|-----------|--------|--------------|-----------------|
| HyperFlex Cluster | CPU Utilization | 0-70% | >85% |
| HyperFlex Cluster | Memory Usage | 0-80% | >90% |
| Storage | Capacity Usage | 0-80% | >85% |
| Storage | IOPS | Varies | <Baseline-20% |
| Network | Bandwidth Usage | 0-70% | >85% |
| VMware | VM Count | Baseline ±10% | >Capacity-10% |
| ACI Fabric | Interface Status | All UP | Any DOWN |

### 1.3 Log Review Procedures

**Critical Logs to Review Daily:**

```bash
# HyperFlex logs
tail -n 100 /var/log/springpath/hxcli.log | grep -i error
tail -n 100 /var/log/springpath/controller.log | grep -i "critical\|error"

# VMware ESXi logs
ssh root@<ESX-HOST> "tail -n 50 /var/log/vmkernel.log | grep -i error"

# vCenter logs (from vCenter shell)
tail -n 50 /var/log/vmware/vpxd/vpxd.log | grep -i error
```

## Monitoring and Alerting

### 2.1 Alert Configuration

**Critical Alerts (Severity 1):**
- HyperFlex cluster offline
- Storage capacity >95%
- Network connectivity loss
- Hardware failure detected
- Security breach indicators

**Warning Alerts (Severity 2):**
- Storage capacity >80%
- Performance degradation >20%
- Certificate expiration <30 days
- Backup job failures
- Configuration changes

**Information Alerts (Severity 3):**
- Scheduled maintenance reminders
- Capacity planning notifications
- Software update availability
- Performance trend reports

### 2.2 SNMP Monitoring Setup

**SNMP Configuration Commands:**

```bash
# Configure SNMP on HyperFlex
hxcli snmp enable \
  --version v3 \
  --username monitoring_user \
  --auth-protocol SHA \
  --auth-password <AUTH_PASSWORD> \
  --priv-protocol AES128 \
  --priv-password <PRIV_PASSWORD>

# Add monitoring server
hxcli snmp trap-destination add \
  --host <MONITORING_SERVER_IP> \
  --port 162 \
  --version v3 \
  --username monitoring_user
```

**Key SNMP OIDs to Monitor:**

```
# System Information
1.3.6.1.2.1.1.1.0    # System Description
1.3.6.1.2.1.1.3.0    # System Uptime

# CPU Usage
1.3.6.1.4.1.9.9.109.1.1.1.1.5   # CPU 5-minute average

# Memory Usage
1.3.6.1.4.1.9.9.48.1.1.1.5      # Memory Pool Used

# Interface Statistics
1.3.6.1.2.1.2.2.1.10             # Interface Inbound Octets
1.3.6.1.2.1.2.2.1.16             # Interface Outbound Octets
```

### 2.3 Performance Monitoring

**Performance Data Collection Script:**

```python
#!/usr/bin/env python3
# Performance monitoring script
import subprocess
import json
import time
import datetime
from influxdb import InfluxDBClient

def collect_hyperflex_metrics():
    """Collect HyperFlex performance metrics"""
    metrics = []
    
    # CPU metrics
    cpu_cmd = ["hxcli", "cluster", "cpu-usage", "--json"]
    try:
        cpu_output = subprocess.check_output(cpu_cmd)
        cpu_data = json.loads(cpu_output.decode())
        
        for node in cpu_data:
            point = {
                "measurement": "cpu_usage",
                "tags": {
                    "node": node["node_ip"],
                    "cluster": "HX-Cluster-01"
                },
                "fields": {
                    "usage_percent": float(node["cpu_usage"])
                },
                "time": datetime.datetime.utcnow()
            }
            metrics.append(point)
    except Exception as e:
        print(f"Error collecting CPU metrics: {e}")
    
    # Memory metrics
    mem_cmd = ["hxcli", "cluster", "memory-usage", "--json"]
    try:
        mem_output = subprocess.check_output(mem_cmd)
        mem_data = json.loads(mem_output.decode())
        
        for node in mem_data:
            point = {
                "measurement": "memory_usage",
                "tags": {
                    "node": node["node_ip"],
                    "cluster": "HX-Cluster-01"
                },
                "fields": {
                    "usage_percent": float(node["memory_usage"]),
                    "total_gb": float(node["total_memory"]),
                    "used_gb": float(node["used_memory"])
                },
                "time": datetime.datetime.utcnow()
            }
            metrics.append(point)
    except Exception as e:
        print(f"Error collecting memory metrics: {e}")
    
    return metrics

# Main execution
if __name__ == "__main__":
    # InfluxDB connection
    client = InfluxDBClient(host='localhost', port=8086, database='hyperflex')
    
    # Collect and store metrics
    metrics = collect_hyperflex_metrics()
    if metrics:
        client.write_points(metrics)
        print(f"Stored {len(metrics)} metric points")
```

## Maintenance Procedures

### 3.1 Scheduled Maintenance

**Monthly Maintenance Tasks:**
- [ ] Update HyperFlex software (if available)
- [ ] Review and rotate certificates
- [ ] Validate backup procedures
- [ ] Review capacity utilization
- [ ] Update documentation
- [ ] Security patch assessment

**Quarterly Maintenance Tasks:**
- [ ] Disaster recovery testing
- [ ] Performance baseline review
- [ ] Security compliance audit
- [ ] Hardware health assessment
- [ ] Network topology review
- [ ] Training needs assessment

### 3.2 Software Updates

**HyperFlex Update Procedure:**

```bash
# Pre-update checklist
echo "=== Pre-Update Checklist ==="
echo "1. Schedule maintenance window: [Date/Time]"
echo "2. Notify stakeholders: [Complete]"
echo "3. Backup configurations: [Complete]"
echo "4. Verify cluster health: [Complete]"

# Download and stage update
hxcli update download --version <TARGET_VERSION>
hxcli update stage --version <TARGET_VERSION>

# Perform update (during maintenance window)
hxcli update install --version <TARGET_VERSION> --confirm

# Post-update validation
hxcli cluster info
hxcli cluster health-check
hxcli datastore list
```

**VMware Update Procedure:**

```bash
# Update ESXi hosts (one at a time)
esxcli software profile update -p <PROFILE_NAME> -d <DEPOT_URL>

# Update vCenter (planned maintenance window)
# Use vCenter Update Manager or manual ISO update

# Validate updates
vmware-cmd -l  # List all VMs
vim-cmd hostsvc/hostsummary  # Host status
```

### 3.3 Configuration Backup

**Automated Backup Script:**

```bash
#!/bin/bash
# Configuration backup script - run daily

BACKUP_DIR="/backup/cisco-hybrid/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# HyperFlex configuration backup
echo "Backing up HyperFlex configuration..."
hxcli cluster export-config --file $BACKUP_DIR/hx-config.json

# VMware configuration backup
echo "Backing up VMware configuration..."
ssh root@<VCENTER_IP> "backup.sh" > $BACKUP_DIR/vcenter-backup.log

# ACI configuration backup
echo "Backing up ACI configuration..."
curl -k -X POST https://<APIC_IP>/api/node/mo/uni/backupst/snapshots-<DATE>.xml

# Intersight configurations (API backup)
python3 /scripts/intersight-backup.py --output $BACKUP_DIR/intersight-config.json

# Compress and store
tar -czf $BACKUP_DIR.tar.gz $BACKUP_DIR
rm -rf $BACKUP_DIR

echo "Backup completed: $BACKUP_DIR.tar.gz"
```

## Backup and Recovery

### 4.1 VM Backup Procedures

**Veeam Backup Configuration:**

```powershell
# PowerCLI script for Veeam backup job configuration
Add-PSSnapin VeeamPSSnapin

# Create backup job for critical VMs
$Job = Add-VBRViJob -Name "Critical-VMs-Daily" -ViEntity (Find-VBRViEntity -Name "Critical-*")
$Job | Set-VBRJobOptions -RetentionPolicy Days -RetainCycles 30
$Job | Set-VBRJobScheduleOptions -Type Daily -At "02:00" -DailyKind Everyday

# Enable encryption
$Job | Set-VBRJobOptions -EncryptionEnabled:$true -EncryptionKey (Get-VBREncryptionKey -Description "Production")

# Start backup job
Start-VBRJob -Job $Job
```

### 4.2 Disaster Recovery Procedures

**HyperFlex Disaster Recovery:**

```bash
# Site failover procedure
echo "=== Disaster Recovery Procedure ==="

# 1. Assess primary site status
echo "1. Assessing primary site availability..."
if ! ping -c 3 <PRIMARY_SITE_IP> > /dev/null; then
    echo "Primary site is unreachable - proceeding with failover"
    
    # 2. Activate secondary site
    echo "2. Activating secondary site..."
    hxcli replication activate-site --remote-site <SECONDARY_SITE>
    
    # 3. Start critical VMs
    echo "3. Starting critical virtual machines..."
    CRITICAL_VMS=("DC-01" "DB-01" "WEB-01")
    for vm in "${CRITICAL_VMS[@]}"; do
        vim-cmd vmsvc/power.on $(vim-cmd vmsvc/getallvms | grep $vm | awk '{print $1}')
    done
    
    # 4. Validate services
    echo "4. Validating critical services..."
    # Add service validation checks here
    
else
    echo "Primary site is reachable - manual intervention required"
fi
```

### 4.3 Recovery Testing

**Monthly DR Test Script:**

```bash
#!/bin/bash
# Monthly disaster recovery test

TEST_DATE=$(date +%Y%m%d)
TEST_LOG="/var/log/dr-test-$TEST_DATE.log"

echo "=== DR Test - $TEST_DATE ===" > $TEST_LOG

# Test backup restoration
echo "Testing backup restoration..." >> $TEST_LOG
LATEST_BACKUP=$(ls -t /backup/cisco-hybrid/*.tar.gz | head -1)
tar -tf $LATEST_BACKUP >> $TEST_LOG 2>&1

# Test replication status
echo "Testing replication status..." >> $TEST_LOG
hxcli replication status >> $TEST_LOG 2>&1

# Test network connectivity to DR site
echo "Testing DR site connectivity..." >> $TEST_LOG
ping -c 5 <DR_SITE_IP> >> $TEST_LOG 2>&1

# Generate test report
echo "DR test completed. Review log: $TEST_LOG"
mail -s "DR Test Report - $TEST_DATE" admin@company.com < $TEST_LOG
```

## Troubleshooting

### 5.1 Common Issues

**Issue: HyperFlex Node Not Responding**

```bash
# Diagnosis steps
echo "=== HyperFlex Node Troubleshooting ==="

# 1. Check node status
hxcli node list | grep <NODE_IP>

# 2. Check network connectivity
ping -c 5 <NODE_IP>
ssh admin@<NODE_IP> "df -h"

# 3. Check cluster membership
hxcli cluster info | grep -A 10 "Node Information"

# 4. Check hardware status
ipmitool -I lanplus -H <BMC_IP> -U <BMC_USER> -P <BMC_PASSWORD> sdr list

# Recovery actions
if [ "$NODE_STATUS" = "OFFLINE" ]; then
    echo "Attempting node recovery..."
    hxcli node power-cycle --node-ip <NODE_IP>
    sleep 300  # Wait 5 minutes
    hxcli node status --node-ip <NODE_IP>
fi
```

**Issue: Storage Performance Degradation**

```bash
# Performance diagnosis
echo "=== Storage Performance Analysis ==="

# 1. Check current IOPS and latency
hxcli datastore iostat

# 2. Identify high-usage VMs
hxcli vm iostat | sort -k3 -nr | head -10

# 3. Check storage network
for node in $(hxcli node list | grep ONLINE | awk '{print $2}'); do
    echo "Testing storage network to $node"
    iperf3 -c $node -p 5201 -t 10
done

# 4. Review historical performance
grep "$(date +%Y-%m-%d)" /var/log/hyperflex/performance.log | tail -50
```

**Issue: vCenter Connectivity Problems**

```powershell
# PowerCLI troubleshooting script
try {
    Connect-VIServer -Server <VCENTER_IP> -ErrorAction Stop
    Write-Host "✓ vCenter connection successful"
    
    # Check service status
    $Services = Get-VIServiceInstance
    $Services.Content.About | Format-List
    
    # Check ESXi host connectivity
    $Hosts = Get-VMHost
    foreach ($Host in $Hosts) {
        if ($Host.ConnectionState -eq "Connected") {
            Write-Host "✓ Host $($Host.Name) is connected"
        } else {
            Write-Host "✗ Host $($Host.Name) connection issue: $($Host.ConnectionState)"
        }
    }
    
} catch {
    Write-Host "✗ vCenter connection failed: $($_.Exception.Message)"
    
    # Basic network tests
    Test-NetConnection -ComputerName <VCENTER_IP> -Port 443
    Test-NetConnection -ComputerName <VCENTER_IP> -Port 80
}
```

### 5.2 Performance Troubleshooting

**Performance Analysis Toolkit:**

```python
#!/usr/bin/env python3
# Performance troubleshooting toolkit

import subprocess
import json
import datetime

class PerformanceAnalyzer:
    def __init__(self):
        self.timestamp = datetime.datetime.now()
        
    def analyze_cpu_usage(self):
        """Analyze CPU utilization patterns"""
        cmd = ["hxcli", "cluster", "cpu-usage", "--json"]
        try:
            output = subprocess.check_output(cmd)
            data = json.loads(output.decode())
            
            high_cpu_nodes = []
            for node in data:
                if float(node['cpu_usage']) > 80:
                    high_cpu_nodes.append({
                        'node': node['node_ip'],
                        'usage': node['cpu_usage']
                    })
            
            if high_cpu_nodes:
                print("⚠ High CPU usage detected:")
                for node in high_cpu_nodes:
                    print(f"  Node {node['node']}: {node['usage']}%")
                    
            return high_cpu_nodes
            
        except Exception as e:
            print(f"Error analyzing CPU usage: {e}")
            return []
    
    def analyze_storage_performance(self):
        """Analyze storage I/O performance"""
        cmd = ["hxcli", "datastore", "iostat"]
        try:
            output = subprocess.check_output(cmd)
            print("Current Storage Performance:")
            print(output.decode())
            
            # Check for performance issues
            lines = output.decode().split('\n')
            for line in lines[1:]:  # Skip header
                if line.strip():
                    fields = line.split()
                    if len(fields) >= 4:
                        latency = float(fields[3])  # Assuming latency is 4th field
                        if latency > 20:  # 20ms threshold
                            print(f"⚠ High latency detected: {latency}ms")
                            
        except Exception as e:
            print(f"Error analyzing storage performance: {e}")
    
    def check_network_performance(self):
        """Check network performance between nodes"""
        cmd = ["hxcli", "cluster", "network-test"]
        try:
            output = subprocess.check_output(cmd)
            print("Network Performance Test Results:")
            print(output.decode())
            
        except Exception as e:
            print(f"Error testing network performance: {e}")

# Run analysis
if __name__ == "__main__":
    analyzer = PerformanceAnalyzer()
    print(f"=== Performance Analysis - {analyzer.timestamp} ===")
    
    analyzer.analyze_cpu_usage()
    analyzer.analyze_storage_performance()
    analyzer.check_network_performance()
```

## Emergency Procedures

### 6.1 Incident Response

**Severity 1 Incident Response:**

```bash
#!/bin/bash
# Severity 1 incident response script

INCIDENT_ID="INC-$(date +%Y%m%d-%H%M%S)"
INCIDENT_LOG="/var/log/incidents/$INCIDENT_ID.log"

echo "=== SEVERITY 1 INCIDENT RESPONSE ===" > $INCIDENT_LOG
echo "Incident ID: $INCIDENT_ID" >> $INCIDENT_LOG
echo "Timestamp: $(date)" >> $INCIDENT_LOG
echo "Initiated by: $USER" >> $INCIDENT_LOG

# Immediate actions
echo "1. Gathering system status..." >> $INCIDENT_LOG
hxcli cluster info >> $INCIDENT_LOG 2>&1
vim-cmd hostsvc/hostsummary >> $INCIDENT_LOG 2>&1

# Notification
echo "2. Sending notifications..." >> $INCIDENT_LOG
STAKEHOLDERS=("admin@company.com" "oncall@company.com" "manager@company.com")
for email in "${STAKEHOLDERS[@]}"; do
    mail -s "SEVERITY 1 INCIDENT: $INCIDENT_ID" $email < $INCIDENT_LOG
done

# Open conference bridge
echo "3. Conference bridge information:" >> $INCIDENT_LOG
echo "   Bridge: +1-555-CONF (2663)" >> $INCIDENT_LOG
echo "   Code: 12345#" >> $INCIDENT_LOG

echo "Incident response initiated. Continue with troubleshooting procedures."
```

### 6.2 Emergency Contacts

| Role | Contact | Phone | Email |
|------|---------|-------|--------|
| On-Call Engineer | John Smith | +1-555-0123 | oncall@company.com |
| Systems Manager | Jane Doe | +1-555-0124 | manager@company.com |
| Cisco TAC | Support | 1-800-553-2447 | N/A |
| VMware Support | Support | 1-877-486-9273 | N/A |
| Network Operations | Team | +1-555-0125 | netops@company.com |

### 6.3 Service Restoration Priority

**Priority 1 Services:**
1. Domain Controllers
2. Email Services
3. Database Servers
4. Web Applications
5. File Servers

**Recovery Time Objectives (RTO):**
- Priority 1: 4 hours
- Priority 2: 8 hours
- Priority 3: 24 hours

## Capacity Management

### 7.1 Capacity Monitoring

**Automated Capacity Report:**

```python
#!/usr/bin/env python3
# Capacity management reporting script

import subprocess
import json
import datetime
import matplotlib.pyplot as plt
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
import smtplib

def generate_capacity_report():
    """Generate comprehensive capacity report"""
    report_date = datetime.datetime.now().strftime('%Y-%m-%d')
    report = {
        'date': report_date,
        'storage': {},
        'compute': {},
        'network': {},
        'recommendations': []
    }
    
    # Storage capacity
    try:
        cmd = ['hxcli', 'datastore', 'list', '--json']
        output = subprocess.check_output(cmd)
        storage_data = json.loads(output.decode())
        
        for datastore in storage_data:
            usage_pct = (datastore['used_space'] / datastore['total_space']) * 100
            report['storage'][datastore['name']] = {
                'total_gb': round(datastore['total_space'] / (1024**3), 2),
                'used_gb': round(datastore['used_space'] / (1024**3), 2),
                'usage_pct': round(usage_pct, 2),
                'free_gb': round((datastore['total_space'] - datastore['used_space']) / (1024**3), 2)
            }
            
            # Generate recommendations
            if usage_pct > 80:
                report['recommendations'].append(f"Storage {datastore['name']} is {usage_pct:.1f}% full - consider expansion")
            elif usage_pct > 70:
                report['recommendations'].append(f"Storage {datastore['name']} is {usage_pct:.1f}% full - monitor closely")
                
    except Exception as e:
        print(f"Error collecting storage data: {e}")
    
    # Compute capacity
    try:
        cmd = ['hxcli', 'cluster', 'resource-summary', '--json']
        output = subprocess.check_output(cmd)
        compute_data = json.loads(output.decode())
        
        cpu_usage = compute_data.get('cpu_usage_pct', 0)
        memory_usage = compute_data.get('memory_usage_pct', 0)
        
        report['compute'] = {
            'cpu_usage_pct': cpu_usage,
            'memory_usage_pct': memory_usage,
            'vm_count': compute_data.get('vm_count', 0),
            'host_count': compute_data.get('host_count', 0)
        }
        
        if cpu_usage > 75:
            report['recommendations'].append(f"CPU utilization is {cpu_usage}% - consider adding compute capacity")
        if memory_usage > 80:
            report['recommendations'].append(f"Memory utilization is {memory_usage}% - consider adding memory")
            
    except Exception as e:
        print(f"Error collecting compute data: {e}")
    
    return report

def create_capacity_charts(report):
    """Create capacity visualization charts"""
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(12, 8))
    
    # Storage usage chart
    if report['storage']:
        datastores = list(report['storage'].keys())
        usage_pcts = [report['storage'][ds]['usage_pct'] for ds in datastores]
        
        ax1.bar(datastores, usage_pcts, color='lightblue')
        ax1.set_title('Storage Capacity Usage (%)')
        ax1.set_ylabel('Usage Percentage')
        ax1.axhline(y=80, color='red', linestyle='--', label='80% Threshold')
        ax1.legend()
    
    # Compute utilization
    if report['compute']:
        categories = ['CPU', 'Memory']
        values = [report['compute']['cpu_usage_pct'], report['compute']['memory_usage_pct']]
        
        ax2.bar(categories, values, color='lightgreen')
        ax2.set_title('Compute Resource Utilization (%)')
        ax2.set_ylabel('Usage Percentage')
        ax2.axhline(y=80, color='red', linestyle='--', label='80% Threshold')
        ax2.legend()
    
    plt.tight_layout()
    plt.savefig('/tmp/capacity_report.png', dpi=150, bbox_inches='tight')
    plt.close()

def send_capacity_report(report):
    """Send capacity report via email"""
    create_capacity_charts(report)
    
    msg = MIMEMultipart()
    msg['From'] = 'monitoring@company.com'
    msg['To'] = 'admin@company.com'
    msg['Subject'] = f'Weekly Capacity Report - {report["date"]}'
    
    # Email body
    body = f"""
    Weekly Capacity Report - {report['date']}
    
    Storage Summary:
    """
    
    for ds_name, ds_data in report['storage'].items():
        body += f"    {ds_name}: {ds_data['used_gb']}GB / {ds_data['total_gb']}GB ({ds_data['usage_pct']}%)\n"
    
    body += f"""
    
    Compute Summary:
        CPU Utilization: {report['compute'].get('cpu_usage_pct', 'N/A')}%
        Memory Utilization: {report['compute'].get('memory_usage_pct', 'N/A')}%
        VM Count: {report['compute'].get('vm_count', 'N/A')}
        Host Count: {report['compute'].get('host_count', 'N/A')}
    
    Recommendations:
    """
    
    for rec in report['recommendations']:
        body += f"    • {rec}\n"
    
    msg.attach(MIMEText(body, 'plain'))
    
    # Attach chart
    with open('/tmp/capacity_report.png', 'rb') as attachment:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(attachment.read())
        part.add_header(
            'Content-Disposition',
            'attachment; filename="capacity_report.png"'
        )
        msg.attach(part)
    
    # Send email (configure SMTP settings)
    # smtp_server = smtplib.SMTP('localhost', 587)
    # smtp_server.send_message(msg)
    # smtp_server.quit()
    
    print("Capacity report generated and would be sent via email")

# Main execution
if __name__ == "__main__":
    report = generate_capacity_report()
    send_capacity_report(report)
    print("Weekly capacity report completed")
```

## Security Operations

### 8.1 Security Monitoring

**Daily Security Checks:**

```bash
#!/bin/bash
# Daily security monitoring script

SECURITY_LOG="/var/log/security-check-$(date +%Y%m%d).log"
echo "=== Daily Security Check - $(date) ===" > $SECURITY_LOG

# Check for failed login attempts
echo "Checking authentication logs..." >> $SECURITY_LOG
grep "Failed" /var/log/auth.log | tail -20 >> $SECURITY_LOG

# Verify certificate expiration
echo "Checking certificate expiration..." >> $SECURITY_LOG
openssl x509 -in /etc/ssl/certs/hyperflex.crt -noout -dates >> $SECURITY_LOG

# Check for unauthorized configuration changes
echo "Checking configuration changes..." >> $SECURITY_LOG
hxcli audit list --since yesterday >> $SECURITY_LOG

# Network security scan
echo "Running network security scan..." >> $SECURITY_LOG
nmap -sS -O localhost >> $SECURITY_LOG 2>&1

# Review security alerts
if [ -s $SECURITY_LOG ]; then
    mail -s "Daily Security Report" security@company.com < $SECURITY_LOG
fi
```

### 8.2 Access Control Management

**User Account Audit:**

```bash
#!/bin/bash
# Monthly user account audit

echo "=== User Account Audit - $(date) ==="

# HyperFlex user accounts
echo "HyperFlex user accounts:"
hxcli user list

# VMware user accounts
echo -e "\nVMware user accounts:"
ssh root@<VCENTER_IP> "vim-cmd vimsvc/auth/entity_list"

# Review inactive accounts
echo -e "\nInactive accounts (>90 days):"
lastlog | awk '$2 == "**Never" || $4 == "never" {print $1}'

# Password expiration check
echo -e "\nAccounts with passwords expiring in 30 days:"
for user in $(cut -d: -f1 /etc/passwd); do
    expiry=$(chage -l $user 2>/dev/null | grep "Password expires" | cut -d: -f2)
    if [[ "$expiry" != *"never"* ]] && [[ -n "$expiry" ]]; then
        echo "$user: $expiry"
    fi
done
```

---

**Operations Runbook Version**: 1.0  
**Last Updated**: [Date]  
**Next Review**: [Date + 30 days]  
**On-Call Contact**: oncall@company.com