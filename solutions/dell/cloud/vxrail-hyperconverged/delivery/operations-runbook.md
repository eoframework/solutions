# Dell VXRail Operations Runbook

## Overview

This operations runbook provides comprehensive procedures for day-to-day management, monitoring, and maintenance of Dell VXRail Hyperconverged Infrastructure. It serves as the primary operational reference for administrators, operators, and support teams.

## Daily Operations

### Daily Health Checks

#### Morning Health Check Routine
```bash
#!/bin/bash
# Daily VxRail health check script

LOG_FILE="/var/log/vxrail/daily-health-$(date +%Y%m%d).log"
echo "=== VxRail Daily Health Check - $(date) ===" | tee $LOG_FILE

# 1. Cluster Health Check
echo "1. Checking cluster health..." | tee -a $LOG_FILE
esxcli vsan cluster get | tee -a $LOG_FILE

# 2. Node Status Check
echo "2. Checking node status..." | tee -a $LOG_FILE
for node in vxrail-{01..04}; do
    ping -c 1 $node.corp.company.com >/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ $node: Online" | tee -a $LOG_FILE
    else
        echo "✗ $node: Offline" | tee -a $LOG_FILE
    fi
done

# 3. vSAN Health Check
echo "3. Checking vSAN health..." | tee -a $LOG_FILE
esxcli vsan health cluster list | tee -a $LOG_FILE

# 4. Storage Capacity Check
echo "4. Checking storage capacity..." | tee -a $LOG_FILE
df -h /vmfs/volumes/vsanDatastore | tee -a $LOG_FILE

# 5. CloudIQ Alerts Check
echo "5. Checking CloudIQ alerts..." | tee -a $LOG_FILE
curl -s "https://cloudiq.dell.com/api/v1/alerts?system=vxrail-prod" | jq '.[] | select(.severity=="Critical" or .severity=="Warning")' | tee -a $LOG_FILE

echo "=== Daily Health Check Complete ===" | tee -a $LOG_FILE
```

#### Performance Monitoring Dashboard
```python
#!/usr/bin/env python3
# Daily performance monitoring script

import subprocess
import json
from datetime import datetime, timedelta

def check_cpu_utilization():
    """Monitor CPU utilization across cluster"""
    cpu_stats = {
        "cluster_avg_cpu": 0,
        "peak_cpu_usage": 0,
        "hosts_over_threshold": []
    }
    
    # Collect CPU stats from each host
    hosts = ["vxrail-01", "vxrail-02", "vxrail-03", "vxrail-04"]
    
    for host in hosts:
        # Simulate CPU monitoring (replace with actual monitoring calls)
        cpu_usage = 45  # Example value
        
        if cpu_usage > 80:
            cpu_stats["hosts_over_threshold"].append(host)
        
        cpu_stats["cluster_avg_cpu"] += cpu_usage
        if cpu_usage > cpu_stats["peak_cpu_usage"]:
            cpu_stats["peak_cpu_usage"] = cpu_usage
    
    cpu_stats["cluster_avg_cpu"] /= len(hosts)
    return cpu_stats

def check_memory_utilization():
    """Monitor memory utilization"""
    memory_stats = {
        "cluster_avg_memory": 0,
        "memory_ballooning": False,
        "swap_usage": 0
    }
    
    # Memory monitoring logic here
    return memory_stats

def check_storage_performance():
    """Monitor storage performance metrics"""
    storage_stats = {
        "average_latency_ms": 1.2,
        "current_iops": 48000,
        "throughput_mbps": 192,
        "congestion_detected": False
    }
    
    # Storage performance monitoring logic here
    return storage_stats

def generate_daily_report():
    """Generate daily performance report"""
    report = {
        "report_date": datetime.now().isoformat(),
        "cpu_metrics": check_cpu_utilization(),
        "memory_metrics": check_memory_utilization(),
        "storage_metrics": check_storage_performance()
    }
    
    # Save report
    with open(f"/var/log/vxrail/daily-report-{datetime.now().strftime('%Y%m%d')}.json", "w") as f:
        json.dump(report, f, indent=2)
    
    return report

if __name__ == "__main__":
    print("Generating daily performance report...")
    report = generate_daily_report()
    print("Daily report generated successfully")
```

### Weekly Maintenance Tasks

#### Weekly System Maintenance
```bash
#!/bin/bash
# Weekly VxRail maintenance script

WEEK_OF=$(date +%Y-W%U)
LOG_FILE="/var/log/vxrail/weekly-maintenance-$WEEK_OF.log"

echo "=== Weekly Maintenance - Week of $WEEK_OF ===" | tee $LOG_FILE

# 1. Log Rotation and Cleanup
echo "1. Performing log cleanup..." | tee -a $LOG_FILE
find /var/log/vxrail -name "*.log" -mtime +30 -delete
logrotate /etc/logrotate.d/vxrail

# 2. Certificate Expiration Check
echo "2. Checking certificate expiration..." | tee -a $LOG_FILE
for cert in /opt/vmware/share/vami/certs/*.crt; do
    expiry_date=$(openssl x509 -in $cert -noout -enddate | cut -d= -f2)
    echo "Certificate $cert expires: $expiry_date" | tee -a $LOG_FILE
done

# 3. CloudIQ Data Sync
echo "3. Synchronizing with CloudIQ..." | tee -a $LOG_FILE
/opt/vmware/vxrail/bin/cloudiq-sync.sh

# 4. Performance Baseline Update
echo "4. Updating performance baseline..." | tee -a $LOG_FILE
esxtop -b -n 12 -d 300 > /var/log/vxrail/weekly-baseline-$WEEK_OF.csv

# 5. Backup Validation
echo "5. Validating backup jobs..." | tee -a $LOG_FILE
# Add backup validation commands here

echo "=== Weekly Maintenance Complete ===" | tee -a $LOG_FILE
```

## Monitoring and Alerting

### CloudIQ Integration Management

#### CloudIQ Alert Management
```python
#!/usr/bin/env python3
# CloudIQ alert management script

import requests
import json
import smtplib
from email.mime.text import MIMEText
from datetime import datetime

class CloudIQManager:
    def __init__(self, api_token):
        self.api_token = api_token
        self.base_url = "https://cloudiq.dell.com/api/v1"
        self.headers = {"Authorization": f"Bearer {api_token}"}
    
    def get_active_alerts(self):
        """Retrieve active alerts from CloudIQ"""
        response = requests.get(
            f"{self.base_url}/alerts", 
            headers=self.headers,
            params={"status": "active", "system": "vxrail-prod"}
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Failed to retrieve alerts: {response.status_code}")
            return []
    
    def get_system_health(self):
        """Get overall system health score"""
        response = requests.get(
            f"{self.base_url}/systems/vxrail-prod/health",
            headers=self.headers
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Failed to retrieve health data: {response.status_code}")
            return None
    
    def acknowledge_alert(self, alert_id, comment):
        """Acknowledge an alert"""
        payload = {
            "status": "acknowledged",
            "comment": comment,
            "acknowledged_by": "Operations Team"
        }
        
        response = requests.patch(
            f"{self.base_url}/alerts/{alert_id}",
            headers=self.headers,
            json=payload
        )
        
        return response.status_code == 200

def process_critical_alerts():
    """Process and respond to critical alerts"""
    cloudiq = CloudIQManager("YOUR_API_TOKEN")
    alerts = cloudiq.get_active_alerts()
    
    critical_alerts = [alert for alert in alerts if alert['severity'] == 'Critical']
    
    for alert in critical_alerts:
        print(f"Processing critical alert: {alert['description']}")
        
        # Auto-acknowledge informational alerts
        if alert['type'] == 'informational':
            cloudiq.acknowledge_alert(alert['id'], "Auto-acknowledged by operations script")
        
        # Send notifications for hardware alerts
        elif alert['type'] == 'hardware':
            send_alert_notification(alert)
        
        # Log all critical alerts
        log_alert(alert)

def send_alert_notification(alert):
    """Send email notification for critical alerts"""
    msg = MIMEText(f"""
    Critical Alert: {alert['description']}
    System: {alert['system']}
    Time: {alert['timestamp']}
    Severity: {alert['severity']}
    
    Please investigate immediately.
    """)
    
    msg['Subject'] = f"VxRail Critical Alert: {alert['description']}"
    msg['From'] = "vxrail-alerts@company.com"
    msg['To'] = "ops-team@company.com"
    
    # Send email (configure SMTP settings)
    # smtp_server.send_message(msg)

def log_alert(alert):
    """Log alert to operations log"""
    with open("/var/log/vxrail/alerts.log", "a") as f:
        f.write(f"{datetime.now().isoformat()}: {alert['severity']} - {alert['description']}\n")

if __name__ == "__main__":
    process_critical_alerts()
```

### Performance Monitoring

#### Real-time Performance Monitoring
```bash
#!/bin/bash
# Real-time performance monitoring script

MONITOR_DURATION=3600  # Monitor for 1 hour
SAMPLE_INTERVAL=60     # Sample every minute
OUTPUT_DIR="/var/log/vxrail/performance"

mkdir -p $OUTPUT_DIR

echo "Starting real-time performance monitoring..."
echo "Duration: $MONITOR_DURATION seconds"
echo "Interval: $SAMPLE_INTERVAL seconds"

# Start monitoring processes
esxtop -b -d $SAMPLE_INTERVAL -n $((MONITOR_DURATION/SAMPLE_INTERVAL)) > $OUTPUT_DIR/realtime-$(date +%Y%m%d-%H%M).csv &

# Monitor vSAN performance
vsan.disks_stats -i $SAMPLE_INTERVAL -c $((MONITOR_DURATION/SAMPLE_INTERVAL)) > $OUTPUT_DIR/vsan-realtime-$(date +%Y%m%d-%H%M).log &

# Monitor network performance
while [ $MONITOR_DURATION -gt 0 ]; do
    esxcli network nic stats get > $OUTPUT_DIR/network-stats-$(date +%Y%m%d-%H%M%S).log
    sleep $SAMPLE_INTERVAL
    MONITOR_DURATION=$((MONITOR_DURATION - SAMPLE_INTERVAL))
done

echo "Real-time monitoring completed"
```

## Maintenance Procedures

### Planned Maintenance Windows

#### Pre-Maintenance Checklist
```yaml
pre_maintenance_checklist:
  planning:
    - "Maintenance window scheduled and approved"
    - "Change request submitted and approved" 
    - "Backup validation completed within 24 hours"
    - "Rollback procedures documented and tested"
    - "Stakeholders notified of maintenance window"
    
  system_validation:
    - "All nodes healthy and accessible"
    - "vSAN cluster health green"
    - "No critical alerts in CloudIQ"
    - "Performance baselines within normal range"
    - "Storage capacity sufficient (>25% free)"
    
  preparation:
    - "Maintenance mode procedures reviewed"
    - "Emergency contact list updated"
    - "Rollback plan validated"
    - "Required patches/updates downloaded"
    - "Test lab validation completed"
```

#### Maintenance Mode Procedures
```bash
#!/bin/bash
# VxRail maintenance mode script

NODE_NAME=${1:-"vxrail-01"}
ACTION=${2:-"enter"}  # enter or exit

echo "Managing maintenance mode for $NODE_NAME - Action: $ACTION"

if [ "$ACTION" == "enter" ]; then
    echo "Entering maintenance mode for $NODE_NAME..."
    
    # 1. Migrate VMs off the host
    echo "Migrating VMs..."
    govc host.maintenance.enter -host $NODE_NAME.corp.company.com
    
    # 2. Verify no VMs remain on host
    VM_COUNT=$(govc host.info -host $NODE_NAME.corp.company.com | grep "Virtual machines" | awk '{print $3}')
    if [ "$VM_COUNT" -eq 0 ]; then
        echo "✓ All VMs successfully migrated"
    else
        echo "✗ $VM_COUNT VMs remain on host - manual intervention required"
        exit 1
    fi
    
    # 3. Enter maintenance mode
    govc host.maintenance.enter -host $NODE_NAME.corp.company.com
    echo "✓ $NODE_NAME entered maintenance mode successfully"
    
elif [ "$ACTION" == "exit" ]; then
    echo "Exiting maintenance mode for $NODE_NAME..."
    
    # 1. Exit maintenance mode
    govc host.maintenance.exit -host $NODE_NAME.corp.company.com
    
    # 2. Verify host is healthy
    HOST_STATUS=$(govc host.info -host $NODE_NAME.corp.company.com | grep "State" | awk '{print $2}')
    if [ "$HOST_STATUS" == "connected" ]; then
        echo "✓ $NODE_NAME exited maintenance mode successfully"
    else
        echo "✗ Host status: $HOST_STATUS - manual verification required"
        exit 1
    fi
    
    # 3. Enable DRS recommendations
    echo "Enabling DRS load balancing..."
    # Add DRS commands here
    
else
    echo "Invalid action: $ACTION. Use 'enter' or 'exit'"
    exit 1
fi

echo "Maintenance mode operation completed for $NODE_NAME"
```

### Firmware and Software Updates

#### VxRail Lifecycle Management
```python
#!/usr/bin/env python3
# VxRail lifecycle management script

import requests
import json
import time
from datetime import datetime

class VxRailLCM:
    def __init__(self, manager_ip, username, password):
        self.manager_ip = manager_ip
        self.username = username
        self.password = password
        self.base_url = f"https://{manager_ip}/rest/vxm/v1"
        self.session = requests.Session()
        self.session.verify = False
        
    def authenticate(self):
        """Authenticate with VxRail Manager"""
        auth_data = {
            "username": self.username,
            "password": self.password
        }
        
        response = self.session.post(
            f"{self.base_url}/auth/login",
            json=auth_data
        )
        
        if response.status_code == 200:
            token = response.json()['access_token']
            self.session.headers.update({'Authorization': f'Bearer {token}'})
            return True
        return False
    
    def check_available_updates(self):
        """Check for available updates"""
        response = self.session.get(f"{self.base_url}/lcm/updates")
        
        if response.status_code == 200:
            return response.json()
        return None
    
    def download_updates(self, bundle_id):
        """Download update bundle"""
        download_payload = {
            "bundle_id": bundle_id,
            "download_now": True
        }
        
        response = self.session.post(
            f"{self.base_url}/lcm/updates/download",
            json=download_payload
        )
        
        if response.status_code == 202:
            return response.json()['request_id']
        return None
    
    def apply_updates(self, bundle_id, maintenance_mode=True):
        """Apply updates to cluster"""
        update_payload = {
            "bundle_id": bundle_id,
            "maintenance_mode": maintenance_mode,
            "auto_witness_upgrade": True,
            "skip_precheck": False
        }
        
        response = self.session.post(
            f"{self.base_url}/lcm/updates/apply",
            json=update_payload
        )
        
        if response.status_code == 202:
            return response.json()['request_id']
        return None
    
    def monitor_update_progress(self, request_id):
        """Monitor update progress"""
        while True:
            response = self.session.get(f"{self.base_url}/requests/{request_id}")
            
            if response.status_code == 200:
                status = response.json()
                print(f"Update status: {status['state']} - {status.get('progress', 0)}%")
                
                if status['state'] in ['COMPLETED', 'FAILED']:
                    return status
                    
            time.sleep(60)  # Check every minute

def perform_cluster_update():
    """Perform complete cluster update"""
    lcm = VxRailLCM("10.1.1.100", "administrator", "password")
    
    if not lcm.authenticate():
        print("Authentication failed")
        return
    
    print("Checking for available updates...")
    updates = lcm.check_available_updates()
    
    if updates and len(updates) > 0:
        latest_bundle = updates[0]['bundle_id']
        print(f"Found update bundle: {latest_bundle}")
        
        # Download updates
        print("Downloading updates...")
        download_id = lcm.download_updates(latest_bundle)
        if download_id:
            download_status = lcm.monitor_update_progress(download_id)
            
            if download_status['state'] == 'COMPLETED':
                print("Download completed successfully")
                
                # Apply updates
                print("Applying updates...")
                apply_id = lcm.apply_updates(latest_bundle)
                if apply_id:
                    apply_status = lcm.monitor_update_progress(apply_id)
                    
                    if apply_status['state'] == 'COMPLETED':
                        print("Updates applied successfully")
                    else:
                        print("Update application failed")
                else:
                    print("Failed to initiate update application")
            else:
                print("Update download failed")
        else:
            print("Failed to initiate update download")
    else:
        print("No updates available")

if __name__ == "__main__":
    perform_cluster_update()
```

## Backup and Recovery Operations

### Backup Management

#### Daily Backup Validation
```bash
#!/bin/bash
# Daily backup validation script

BACKUP_LOG="/var/log/vxrail/backup-validation-$(date +%Y%m%d).log"
BACKUP_SERVER="backup.corp.company.com"

echo "=== Daily Backup Validation - $(date) ===" | tee $BACKUP_LOG

# 1. Check backup job completion
echo "1. Validating backup job completion..." | tee -a $BACKUP_LOG
ssh backup-admin@$BACKUP_SERVER 'powerprotect-cli job list --status completed --date today' | tee -a $BACKUP_LOG

# 2. Verify backup sizes
echo "2. Checking backup sizes..." | tee -a $BACKUP_LOG
EXPECTED_SIZE="500GB"  # Adjust based on environment
ACTUAL_SIZE=$(ssh backup-admin@$BACKUP_SERVER 'du -sh /backups/vxrail/$(date +%Y%m%d)' | awk '{print $1}')

echo "Expected backup size: $EXPECTED_SIZE" | tee -a $BACKUP_LOG
echo "Actual backup size: $ACTUAL_SIZE" | tee -a $BACKUP_LOG

# 3. Test restore capability
echo "3. Testing restore capability..." | tee -a $BACKUP_LOG
# Create test VM and restore validation
govc vm.create -c 1 -m 1024 -disk 10GB -net "VM-Production" backup-test-vm
VM_UUID=$(govc vm.info backup-test-vm | grep UUID | awk '{print $2}')

# Simulate backup restore test
echo "Test VM UUID: $VM_UUID" | tee -a $BACKUP_LOG

# Clean up test VM
govc vm.destroy backup-test-vm

# 4. Verify offsite replication
echo "4. Checking offsite replication..." | tee -a $BACKUP_LOG
REPLICATION_STATUS=$(ssh backup-admin@$BACKUP_SERVER 'replication-status --site dr-site')
echo "Replication status: $REPLICATION_STATUS" | tee -a $BACKUP_LOG

echo "=== Backup Validation Complete ===" | tee -a $BACKUP_LOG
```

### Disaster Recovery Testing

#### Monthly DR Test
```bash
#!/bin/bash
# Monthly disaster recovery test

DR_TEST_LOG="/var/log/vxrail/dr-test-$(date +%Y%m).log"
DR_SITE="dr.corp.company.com"

echo "=== Monthly DR Test - $(date) ===" | tee $DR_TEST_LOG

# 1. Pre-test validation
echo "1. Performing pre-test validation..." | tee -a $DR_TEST_LOG
ping -c 3 $DR_SITE >/dev/null
if [ $? -eq 0 ]; then
    echo "✓ DR site connectivity confirmed" | tee -a $DR_TEST_LOG
else
    echo "✗ DR site connectivity failed" | tee -a $DR_TEST_LOG
    exit 1
fi

# 2. Initiate test failover
echo "2. Initiating test failover..." | tee -a $DR_TEST_LOG
# Add SRM or replication failover commands here

# 3. Validate test environment
echo "3. Validating test environment..." | tee -a $DR_TEST_LOG
TEST_VMS=("web-server-test" "db-server-test" "app-server-test")

for vm in "${TEST_VMS[@]}"; do
    VM_STATUS=$(govc vm.info -dc=DR-Datacenter $vm | grep "Power state" | awk '{print $3}')
    if [ "$VM_STATUS" == "poweredOn" ]; then
        echo "✓ $vm: Running" | tee -a $DR_TEST_LOG
    else
        echo "✗ $vm: Not running" | tee -a $DR_TEST_LOG
    fi
done

# 4. Application connectivity test
echo "4. Testing application connectivity..." | tee -a $DR_TEST_LOG
curl -f http://web-server-test.corp.company.com/health >/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Web application accessible" | tee -a $DR_TEST_LOG
else
    echo "✗ Web application not accessible" | tee -a $DR_TEST_LOG
fi

# 5. Cleanup test environment
echo "5. Cleaning up test environment..." | tee -a $DR_TEST_LOG
# Add cleanup commands here

echo "=== DR Test Complete ===" | tee -a $DR_TEST_LOG
```

## Troubleshooting Procedures

### Common Issue Resolution

#### Node Connectivity Issues
```bash
#!/bin/bash
# Node connectivity troubleshooting script

NODE_NAME=${1:-"vxrail-01"}
echo "Troubleshooting connectivity for $NODE_NAME..."

# 1. Basic connectivity test
echo "1. Testing basic connectivity..."
ping -c 3 $NODE_NAME.corp.company.com
PING_STATUS=$?

if [ $PING_STATUS -eq 0 ]; then
    echo "✓ Node is responding to ping"
else
    echo "✗ Node is not responding to ping"
    
    # Check switch connectivity
    echo "Checking switch port status..."
    # Add switch status commands here
fi

# 2. SSH connectivity test
echo "2. Testing SSH connectivity..."
ssh -o ConnectTimeout=5 root@$NODE_NAME.corp.company.com 'echo "SSH OK"' >/dev/null
SSH_STATUS=$?

if [ $SSH_STATUS -eq 0 ]; then
    echo "✓ SSH connectivity working"
else
    echo "✗ SSH connectivity failed"
    echo "Check ESXi shell access and firewall settings"
fi

# 3. vCenter connectivity test
echo "3. Testing vCenter connectivity..."
govc host.info $NODE_NAME.corp.company.com >/dev/null
VCENTER_STATUS=$?

if [ $VCENTER_STATUS -eq 0 ]; then
    echo "✓ vCenter can communicate with host"
else
    echo "✗ vCenter communication failed"
    echo "Check host agent and vpxa service status"
fi

# 4. Generate diagnostic information
echo "4. Collecting diagnostic information..."
if [ $SSH_STATUS -eq 0 ]; then
    ssh root@$NODE_NAME.corp.company.com 'esxcli system version get' > /tmp/${NODE_NAME}-diagnostics.log
    ssh root@$NODE_NAME.corp.company.com 'esxcli network ip connection list' >> /tmp/${NODE_NAME}-diagnostics.log
    ssh root@$NODE_NAME.corp.company.com 'esxcli system stats installtime get' >> /tmp/${NODE_NAME}-diagnostics.log
    echo "Diagnostic information saved to /tmp/${NODE_NAME}-diagnostics.log"
fi
```

#### Storage Performance Issues
```python
#!/usr/bin/env python3
# Storage performance troubleshooting

import subprocess
import json
from datetime import datetime

def check_vsan_health():
    """Check vSAN cluster health"""
    try:
        result = subprocess.run(['esxcli', 'vsan', 'health', 'cluster', 'list'], 
                              capture_output=True, text=True)
        
        health_status = result.stdout
        print("vSAN Health Status:")
        print(health_status)
        
        # Check for specific issues
        if "ERROR" in health_status:
            print("❌ vSAN health issues detected")
            return False
        elif "WARNING" in health_status:
            print("⚠️  vSAN warnings detected")
            return True
        else:
            print("✅ vSAN health is good")
            return True
            
    except Exception as e:
        print(f"Failed to check vSAN health: {e}")
        return False

def check_disk_performance():
    """Check individual disk performance"""
    try:
        result = subprocess.run(['vsan.disks_stats', '-i', '10', '-c', '6'], 
                              capture_output=True, text=True)
        
        disk_stats = result.stdout
        print("Disk Performance Stats:")
        print(disk_stats)
        
        # Analyze for performance issues
        lines = disk_stats.split('\n')
        for line in lines:
            if 'latency' in line.lower() and any(float(x) > 20 for x in line.split() if x.replace('.', '').isdigit()):
                print("❌ High disk latency detected")
                return False
        
        print("✅ Disk performance within normal range")
        return True
        
    except Exception as e:
        print(f"Failed to check disk performance: {e}")
        return False

def check_network_performance():
    """Check vSAN network performance"""
    try:
        result = subprocess.run(['esxcli', 'vsan', 'network', 'list'], 
                              capture_output=True, text=True)
        
        network_info = result.stdout
        print("vSAN Network Configuration:")
        print(network_info)
        
        # Check for network issues
        if "down" in network_info.lower():
            print("❌ vSAN network interfaces down")
            return False
        else:
            print("✅ vSAN network interfaces operational")
            return True
            
    except Exception as e:
        print(f"Failed to check network performance: {e}")
        return False

def generate_performance_report():
    """Generate comprehensive performance troubleshooting report"""
    report = {
        "timestamp": datetime.now().isoformat(),
        "vsan_health": check_vsan_health(),
        "disk_performance": check_disk_performance(),
        "network_performance": check_network_performance(),
        "recommendations": []
    }
    
    # Generate recommendations based on findings
    if not report["vsan_health"]:
        report["recommendations"].append("Investigate vSAN health issues immediately")
    
    if not report["disk_performance"]:
        report["recommendations"].append("Check for disk failures or high utilization")
    
    if not report["network_performance"]:
        report["recommendations"].append("Verify vSAN network configuration and connectivity")
    
    # Save report
    with open(f"/var/log/vxrail/performance-troubleshooting-{datetime.now().strftime('%Y%m%d-%H%M')}.json", "w") as f:
        json.dump(report, f, indent=2)
    
    return report

if __name__ == "__main__":
    print("Starting storage performance troubleshooting...")
    report = generate_performance_report()
    
    if all([report["vsan_health"], report["disk_performance"], report["network_performance"]]):
        print("✅ All storage performance checks passed")
    else:
        print("❌ Storage performance issues detected - check recommendations")
        for rec in report["recommendations"]:
            print(f"  - {rec}")
```

## Emergency Procedures

### Critical Alert Response

#### Critical System Alert Response
```bash
#!/bin/bash
# Critical alert response script

ALERT_TYPE=${1:-"unknown"}
ALERT_SEVERITY=${2:-"critical"}
ALERT_MESSAGE=${3:-"No details provided"}

echo "=== CRITICAL ALERT RESPONSE ===" | tee -a /var/log/vxrail/critical-alerts.log
echo "Alert Type: $ALERT_TYPE" | tee -a /var/log/vxrail/critical-alerts.log
echo "Severity: $ALERT_SEVERITY" | tee -a /var/log/vxrail/critical-alerts.log
echo "Message: $ALERT_MESSAGE" | tee -a /var/log/vxrail/critical-alerts.log
echo "Timestamp: $(date)" | tee -a /var/log/vxrail/critical-alerts.log

case $ALERT_TYPE in
    "node_down")
        echo "Executing node down response..." | tee -a /var/log/vxrail/critical-alerts.log
        # Immediate node health check
        /opt/vmware/vxrail/bin/node-health-check.sh
        # Notify on-call team
        echo "Node down alert: $ALERT_MESSAGE" | mail -s "CRITICAL: VxRail Node Down" oncall@company.com
        ;;
        
    "storage_failure")
        echo "Executing storage failure response..." | tee -a /var/log/vxrail/critical-alerts.log
        # Check vSAN health
        esxcli vsan health cluster list
        # Generate diagnostic bundle
        /opt/vmware/vxrail/bin/collect_logs.sh
        # Escalate to Dell support
        echo "Storage failure: $ALERT_MESSAGE" | mail -s "CRITICAL: VxRail Storage Failure" dellsupport@company.com
        ;;
        
    "cluster_partition")
        echo "Executing cluster partition response..." | tee -a /var/log/vxrail/critical-alerts.log
        # Check network connectivity
        /opt/vmware/vxrail/bin/network-diagnostics.sh
        # Verify witness connectivity
        /opt/vmware/vxrail/bin/witness-check.sh
        # Emergency escalation
        echo "Cluster partition: $ALERT_MESSAGE" | mail -s "EMERGENCY: VxRail Cluster Partition" emergency@company.com
        ;;
        
    *)
        echo "Unknown alert type - executing general response..." | tee -a /var/log/vxrail/critical-alerts.log
        # General health check
        /opt/vmware/vxrail/bin/health-check.sh
        # Log for investigation
        echo "Unknown alert: $ALERT_MESSAGE" | mail -s "ALERT: VxRail Unknown Issue" ops@company.com
        ;;
esac

echo "=== ALERT RESPONSE COMPLETE ===" | tee -a /var/log/vxrail/critical-alerts.log
```

### Emergency Contact Information

```yaml
emergency_contacts:
  primary_oncall:
    name: "IT Operations Team"
    phone: "+1-555-123-4567"
    email: "oncall@company.com"
    escalation_time: "15 minutes"
    
  dell_support:
    level_1: "+1-800-DELL-VXR"
    level_2: "vxrail.support@dell.com"
    critical_escalation: "+1-800-DELL-EMG"
    account_manager: "am-vxrail@dell.com"
    
  vmware_support:
    technical_support: "+1-877-4-VMWARE"
    critical_escalation: "critical@vmware.com"
    
  infrastructure_team:
    network_team: "network-ops@company.com"
    storage_team: "storage-ops@company.com"
    security_team: "security-ops@company.com"
    
  management_escalation:
    it_manager: "it.manager@company.com"
    infrastructure_director: "infra.director@company.com"
    cio: "cio@company.com"
```

## Capacity Planning

### Growth Monitoring
```python
#!/usr/bin/env python3
# Capacity planning and growth monitoring

import json
import subprocess
from datetime import datetime, timedelta
import matplotlib.pyplot as plt

class CapacityPlanner:
    def __init__(self):
        self.metrics_history = "/var/log/vxrail/capacity-metrics.json"
        
    def collect_current_metrics(self):
        """Collect current capacity metrics"""
        metrics = {
            "timestamp": datetime.now().isoformat(),
            "storage": self.get_storage_metrics(),
            "compute": self.get_compute_metrics(),
            "network": self.get_network_metrics()
        }
        
        return metrics
    
    def get_storage_metrics(self):
        """Get storage capacity metrics"""
        # Simulate storage metrics collection
        return {
            "total_capacity_tb": 100,
            "used_capacity_tb": 65,
            "free_capacity_tb": 35,
            "utilization_percent": 65,
            "dedup_ratio": 2.5,
            "compression_ratio": 1.8
        }
    
    def get_compute_metrics(self):
        """Get compute capacity metrics"""
        return {
            "total_cpu_ghz": 800,
            "used_cpu_ghz": 320,
            "cpu_utilization_percent": 40,
            "total_memory_gb": 2048,
            "used_memory_gb": 1024,
            "memory_utilization_percent": 50,
            "vm_count": 250,
            "powered_on_vms": 230
        }
    
    def get_network_metrics(self):
        """Get network capacity metrics"""
        return {
            "total_bandwidth_gbps": 80,
            "peak_utilization_gbps": 32,
            "average_utilization_gbps": 16,
            "utilization_percent": 40
        }
    
    def save_metrics(self, metrics):
        """Save metrics to historical data"""
        try:
            with open(self.metrics_history, "r") as f:
                history = json.load(f)
        except FileNotFoundError:
            history = []
        
        history.append(metrics)
        
        # Keep only last 90 days
        cutoff_date = datetime.now() - timedelta(days=90)
        history = [m for m in history if datetime.fromisoformat(m['timestamp']) > cutoff_date]
        
        with open(self.metrics_history, "w") as f:
            json.dump(history, f, indent=2)
    
    def predict_growth(self):
        """Predict resource growth and capacity planning"""
        try:
            with open(self.metrics_history, "r") as f:
                history = json.load(f)
        except FileNotFoundError:
            return None
        
        if len(history) < 7:  # Need at least a week of data
            return None
        
        # Simple linear growth prediction
        recent_metrics = history[-30:]  # Last 30 days
        
        storage_growth = self.calculate_growth_rate(recent_metrics, 'storage', 'utilization_percent')
        compute_growth = self.calculate_growth_rate(recent_metrics, 'compute', 'cpu_utilization_percent')
        
        predictions = {
            "storage": {
                "current_utilization": recent_metrics[-1]['storage']['utilization_percent'],
                "monthly_growth_rate": storage_growth,
                "months_to_80_percent": self.calculate_time_to_threshold(
                    recent_metrics[-1]['storage']['utilization_percent'], 
                    storage_growth, 80
                )
            },
            "compute": {
                "current_utilization": recent_metrics[-1]['compute']['cpu_utilization_percent'],
                "monthly_growth_rate": compute_growth,
                "months_to_80_percent": self.calculate_time_to_threshold(
                    recent_metrics[-1]['compute']['cpu_utilization_percent'],
                    compute_growth, 80
                )
            }
        }
        
        return predictions
    
    def calculate_growth_rate(self, metrics, category, field):
        """Calculate monthly growth rate"""
        if len(metrics) < 2:
            return 0
        
        values = [m[category][field] for m in metrics]
        days = len(values)
        
        # Simple linear regression for growth rate
        growth_per_day = (values[-1] - values[0]) / days
        monthly_growth = growth_per_day * 30
        
        return monthly_growth
    
    def calculate_time_to_threshold(self, current_value, growth_rate, threshold):
        """Calculate months until threshold is reached"""
        if growth_rate <= 0:
            return float('inf')  # No growth or negative growth
        
        months_to_threshold = (threshold - current_value) / growth_rate
        return max(0, months_to_threshold)
    
    def generate_capacity_report(self):
        """Generate comprehensive capacity planning report"""
        current_metrics = self.collect_current_metrics()
        predictions = self.predict_growth()
        
        report = {
            "report_date": datetime.now().isoformat(),
            "current_capacity": current_metrics,
            "growth_predictions": predictions,
            "recommendations": []
        }
        
        # Generate recommendations
        if predictions:
            if predictions['storage']['months_to_80_percent'] < 6:
                report['recommendations'].append("Storage expansion recommended within 6 months")
            
            if predictions['compute']['months_to_80_percent'] < 6:
                report['recommendations'].append("Compute capacity expansion recommended within 6 months")
        
        # Save report
        with open(f"/var/log/vxrail/capacity-report-{datetime.now().strftime('%Y%m%d')}.json", "w") as f:
            json.dump(report, f, indent=2)
        
        return report

if __name__ == "__main__":
    planner = CapacityPlanner()
    
    # Collect and save current metrics
    current_metrics = planner.collect_current_metrics()
    planner.save_metrics(current_metrics)
    
    # Generate capacity report
    report = planner.generate_capacity_report()
    
    print("Capacity Planning Report Generated")
    if report['recommendations']:
        print("Recommendations:")
        for rec in report['recommendations']:
            print(f"  - {rec}")
```

## Documentation and Reporting

### Monthly Operations Report
```bash
#!/bin/bash
# Monthly operations report generator

MONTH=$(date -d "last month" +%Y-%m)
REPORT_FILE="/var/log/vxrail/monthly-report-$MONTH.md"

echo "# VxRail Monthly Operations Report - $MONTH" > $REPORT_FILE
echo "" >> $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# System Uptime
echo "## System Uptime" >> $REPORT_FILE
for node in vxrail-{01..04}; do
    UPTIME=$(ssh root@$node.corp.company.com 'uptime' | awk '{print $3,$4}' | sed 's/,//')
    echo "- $node: $UPTIME" >> $REPORT_FILE
done
echo "" >> $REPORT_FILE

# Performance Summary
echo "## Performance Summary" >> $REPORT_FILE
echo "### Average Resource Utilization" >> $REPORT_FILE
echo "- CPU: 42%" >> $REPORT_FILE
echo "- Memory: 67%" >> $REPORT_FILE
echo "- Storage: 65%" >> $REPORT_FILE
echo "- Network: 38%" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Incident Summary
echo "## Incident Summary" >> $REPORT_FILE
CRITICAL_COUNT=$(grep -c "CRITICAL" /var/log/vxrail/alerts.log)
WARNING_COUNT=$(grep -c "WARNING" /var/log/vxrail/alerts.log)
echo "- Critical alerts: $CRITICAL_COUNT" >> $REPORT_FILE
echo "- Warning alerts: $WARNING_COUNT" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Maintenance Activities
echo "## Maintenance Activities" >> $REPORT_FILE
echo "- Firmware updates: 0" >> $REPORT_FILE
echo "- Planned maintenance windows: 2" >> $REPORT_FILE
echo "- Unplanned downtime: 0 hours" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Recommendations
echo "## Recommendations" >> $REPORT_FILE
echo "- Continue monitoring storage capacity growth" >> $REPORT_FILE
echo "- Schedule quarterly DR testing" >> $REPORT_FILE
echo "- Review CloudIQ recommendations monthly" >> $REPORT_FILE

echo "Monthly report generated: $REPORT_FILE"
```

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Owner**: Dell Technologies Professional Services  
**Classification**: Internal Use