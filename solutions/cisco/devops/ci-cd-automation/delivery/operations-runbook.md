# Cisco CI/CD Automation Operations Runbook

## Table of Contents

1. [Overview](#overview)
2. [Daily Operations](#daily-operations)
3. [Monitoring and Alerting](#monitoring-and-alerting)
4. [Maintenance Procedures](#maintenance-procedures)
5. [Incident Response](#incident-response)
6. [Change Management](#change-management)
7. [Backup and Recovery](#backup-and-recovery)
8. [Performance Optimization](#performance-optimization)
9. [Security Operations](#security-operations)
10. [Troubleshooting Guide](#troubleshooting-guide)

## Overview

This operations runbook provides comprehensive procedures for the day-to-day management and maintenance of the Cisco CI/CD automation solution. It serves as the primary reference for network operations teams responsible for maintaining automated network infrastructure.

### Operational Scope

- Cisco DNA Center management and monitoring
- Network Services Orchestrator (NSO) operations
- Ansible Automation Platform maintenance
- CI/CD pipeline management
- Network device automation workflows
- Compliance and security monitoring

### Key Metrics and SLAs

| Metric | Target | Measurement |
|--------|---------|-------------|
| Automation Success Rate | >95% | Daily |
| Configuration Drift Detection | <1 hour | Continuous |
| Incident Response Time | <15 minutes | Per incident |
| Service Provisioning Time | <30 minutes | Per request |
| System Availability | 99.9% | Monthly |

## Daily Operations

### Morning Health Check (08:00 - 09:00)

**Objective:** Verify system health and identify any overnight issues.

#### 1. Platform Health Verification

```bash
# Check Cisco DNA Center status
curl -k -X GET "https://dnac.company.com/dna/system/api/v1/health" \
  -H "X-Auth-Token: $DNAC_TOKEN" | jq '.response[].healthScore'

# Verify NSO status
ncs --status

# Check Ansible Automation Platform
systemctl status automation-controller
systemctl status automation-hub
systemctl status receptor
```

#### 2. Automation Job Review

```bash
# Check overnight automation jobs
ansible-runner list /var/lib/awx/projects/

# Review failed jobs from last 24 hours
awx-cli job list --status failed --created__gte=$(date -d '24 hours ago' --iso-8601)

# Check GitLab CI pipeline status
gitlab-ci-multi-runner status
```

#### 3. Device Connectivity Check

```bash
# Ping test all managed devices
ansible all -m ping -f 50 > /tmp/connectivity-check.log 2>&1

# Check devices with connectivity issues
grep "UNREACHABLE" /tmp/connectivity-check.log | \
  awk '{print $1}' | sort | uniq > /tmp/unreachable-devices.txt

# Generate connectivity report
if [ -s /tmp/unreachable-devices.txt ]; then
  echo "ALERT: Unreachable devices found:"
  cat /tmp/unreachable-devices.txt
  # Send notification to operations team
  mail -s "Network Device Connectivity Issues" ops-team@company.com < /tmp/unreachable-devices.txt
fi
```

#### 4. Configuration Drift Detection

```bash
# Run configuration drift detection
ansible-playbook playbooks/configuration-drift-check.yml \
  --extra-vars "check_date=$(date --iso-8601)"

# Review drift report
if [ -f reports/configuration-drift-$(date --iso-8601).json ]; then
  echo "Configuration drift detected. Review required."
  jq '.drifted_devices' reports/configuration-drift-$(date --iso-8601).json
fi
```

### Midday Operations Check (12:00 - 13:00)

#### 1. Performance Metrics Review

```bash
# Check DNA Center performance metrics
echo "DNA Center CPU and Memory Usage:"
curl -k -X GET "https://dnac.company.com/dna/system/api/v1/health" \
  -H "X-Auth-Token: $DNAC_TOKEN" | jq '.response[].cpuScore, .response[].memoryScore'

# Monitor automation job queue
echo "Current job queue status:"
awx-cli job list --status pending --status waiting --status running
```

#### 2. Network Health Assessment

```python
#!/usr/bin/env python3
# network_health_check.py

import requests
import json
from datetime import datetime

def check_network_health():
    """Perform comprehensive network health check"""
    
    health_report = {
        "timestamp": datetime.now().isoformat(),
        "device_status": {},
        "interface_utilization": {},
        "critical_alerts": []
    }
    
    # Check device reachability
    devices = get_managed_devices()
    for device in devices:
        try:
            response = ping_device(device['ip'])
            health_report['device_status'][device['hostname']] = 'UP' if response else 'DOWN'
        except Exception as e:
            health_report['critical_alerts'].append(f"Error checking {device['hostname']}: {str(e)}")
    
    # Generate report
    with open(f"/var/log/network-health-{datetime.now().strftime('%Y%m%d-%H%M')}.json", 'w') as f:
        json.dump(health_report, f, indent=2)
    
    return health_report

if __name__ == "__main__":
    report = check_network_health()
    print(f"Health check completed. Critical alerts: {len(report['critical_alerts'])}")
```

### Evening Operations Review (17:00 - 18:00)

#### 1. Daily Summary Report

```bash
# Generate daily operations summary
cat << EOF > /tmp/daily-summary-$(date --iso-8601).md
# Network Automation Daily Summary - $(date --iso-8601)

## Automation Jobs Executed
$(awx-cli job list --created__gte=$(date --iso-8601) --format json | jq -r '.results[] | "\(.name): \(.status)"')

## Device Status Summary
- Total Managed Devices: $(ansible all --list-hosts | wc -l)
- Unreachable Devices: $([ -f /tmp/unreachable-devices.txt ] && wc -l < /tmp/unreachable-devices.txt || echo 0)
- Configuration Drift Detected: $([ -f reports/configuration-drift-$(date --iso-8601).json ] && jq '.drifted_devices | length' reports/configuration-drift-$(date --iso-8601).json || echo 0)

## Critical Issues
$(grep "CRITICAL" /var/log/network-automation/*.log | tail -10 || echo "None reported")

EOF

# Email daily summary to operations team
mail -s "Daily Network Automation Summary - $(date --iso-8601)" \
  ops-team@company.com < /tmp/daily-summary-$(date --iso-8601).md
```

## Monitoring and Alerting

### Prometheus Monitoring Configuration

```yaml
# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'cisco-dna-center'
    static_configs:
      - targets: ['dnac.company.com:9090']
    scrape_interval: 30s
    metrics_path: /api/system/v1/metrics
    scheme: https
    tls_config:
      insecure_skip_verify: true
    basic_auth:
      username: monitoring
      password: monitoring_password

  - job_name: 'ansible-automation-platform'
    static_configs:
      - targets: ['aap-controller.company.com:80']
    metrics_path: /api/v2/metrics
    basic_auth:
      username: admin
      password: admin_password

  - job_name: 'network-devices'
    static_configs:
      - targets:
        - '10.1.1.10:9100'  # Switch 01
        - '10.1.1.11:9100'  # Switch 02
        - '10.1.1.20:9100'  # Router 01
    scrape_interval: 60s
```

### Alert Rules

```yaml
# /etc/prometheus/rules/network-automation.yml
groups:
  - name: network_automation
    rules:
      - alert: DeviceUnreachable
        expr: up{job="network-devices"} == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Network device {{ $labels.instance }} is unreachable"
          description: "Device {{ $labels.instance }} has been unreachable for more than 5 minutes"

      - alert: AutomationJobFailure
        expr: increase(ansible_job_failures_total[1h]) > 3
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "High automation job failure rate"
          description: "More than 3 automation jobs have failed in the last hour"

      - alert: ConfigurationDrift
        expr: configuration_drift_devices > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "Configuration drift detected"
          description: "{{ $value }} devices have configuration drift"

      - alert: DNACenterDown
        expr: up{job="cisco-dna-center"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Cisco DNA Center is down"
          description: "DNA Center has been unreachable for more than 2 minutes"
```

### Grafana Dashboards

```json
{
  "dashboard": {
    "title": "Network Automation Operations Dashboard",
    "panels": [
      {
        "id": 1,
        "title": "Device Connectivity Status",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"network-devices\"}",
            "legendFormat": "{{instance}}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "mappings": [
              {
                "options": {
                  "0": {
                    "text": "DOWN",
                    "color": "red"
                  },
                  "1": {
                    "text": "UP",
                    "color": "green"
                  }
                }
              }
            ]
          }
        }
      },
      {
        "id": 2,
        "title": "Automation Job Success Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(ansible_job_success_total[5m])",
            "legendFormat": "Success Rate"
          },
          {
            "expr": "rate(ansible_job_failures_total[5m])",
            "legendFormat": "Failure Rate"
          }
        ]
      },
      {
        "id": 3,
        "title": "DNA Center Health Score",
        "type": "gauge",
        "targets": [
          {
            "expr": "dnac_health_score",
            "legendFormat": "Health Score"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "min": 0,
            "max": 100,
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "yellow", "value": 70},
                {"color": "green", "value": 90}
              ]
            }
          }
        }
      }
    ]
  }
}
```

## Maintenance Procedures

### Weekly Maintenance (Sundays, 02:00 - 04:00)

#### 1. System Updates and Patches

```bash
#!/bin/bash
# weekly-maintenance.sh

# DNA Center maintenance
echo "Starting DNA Center maintenance..."
ssh maglev@dnac.company.com << 'EOF'
  sudo maglev-config backup --type config --path /backup/$(date +%Y%m%d)
  sudo yum update -y --security
EOF

# NSO maintenance
echo "Starting NSO maintenance..."
ncs --stop
cd $NCS_RUN_DIR
ncs-backup
yum update -y ncs
ncs

# Ansible Automation Platform maintenance
echo "Starting AAP maintenance..."
systemctl stop automation-controller
yum update -y ansible-automation-platform
systemctl start automation-controller

# Wait for services to stabilize
sleep 300

# Verify services are running
systemctl is-active automation-controller || exit 1
ncs --status || exit 1
```

#### 2. Database Maintenance

```bash
# PostgreSQL maintenance for AAP
sudo -u postgres psql << 'EOF'
  -- Vacuum and analyze AAP database
  \c awx
  VACUUM ANALYZE;
  
  -- Check database size
  SELECT pg_size_pretty(pg_database_size('awx'));
  
  -- Archive old job logs (older than 30 days)
  DELETE FROM main_job WHERE created < NOW() - INTERVAL '30 days';
EOF
```

#### 3. Log Rotation and Cleanup

```bash
# Rotate logs older than 30 days
find /var/log/network-automation -name "*.log" -type f -mtime +30 -delete
find /var/log/ansible -name "*.log" -type f -mtime +30 -delete

# Compress logs older than 7 days
find /var/log/network-automation -name "*.log" -type f -mtime +7 -exec gzip {} \;

# Clean up temporary files
find /tmp -name "ansible-tmp-*" -type d -mtime +1 -exec rm -rf {} \;
```

### Monthly Maintenance

#### 1. Certificate Renewal

```bash
#!/bin/bash
# certificate-renewal.sh

# Check certificate expiration (warn if < 30 days)
check_cert_expiration() {
    local cert_file=$1
    local host=$2
    
    expiry_date=$(openssl x509 -enddate -noout -in "$cert_file" | cut -d= -f2)
    expiry_epoch=$(date -d "$expiry_date" +%s)
    current_epoch=$(date +%s)
    days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))
    
    if [ $days_until_expiry -lt 30 ]; then
        echo "WARNING: Certificate for $host expires in $days_until_expiry days"
        # Send alert
        echo "Certificate renewal required for $host" | \
          mail -s "Certificate Expiration Alert" ops-team@company.com
    fi
}

# Check DNA Center certificate
check_cert_expiration "/opt/dnac/certs/dnac.crt" "DNA Center"

# Check AAP certificate
check_cert_expiration "/etc/tower/tower.cert" "Ansible Automation Platform"
```

#### 2. Performance Report Generation

```python
#!/usr/bin/env python3
# monthly_performance_report.py

import json
import psycopg2
from datetime import datetime, timedelta
import matplotlib.pyplot as plt

def generate_monthly_report():
    """Generate comprehensive monthly performance report"""
    
    # Connect to AAP database
    conn = psycopg2.connect(
        host="localhost",
        database="awx",
        user="awx",
        password="password"
    )
    cur = conn.cursor()
    
    # Query job statistics
    cur.execute("""
        SELECT 
            DATE(created) as job_date,
            status,
            COUNT(*) as job_count
        FROM main_job 
        WHERE created >= %s 
        GROUP BY DATE(created), status
        ORDER BY job_date;
    """, (datetime.now() - timedelta(days=30),))
    
    results = cur.fetchall()
    
    # Generate charts and reports
    report = {
        "period": f"{(datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')} to {datetime.now().strftime('%Y-%m-%d')}",
        "total_jobs": sum([r[2] for r in results]),
        "successful_jobs": sum([r[2] for r in results if r[1] == 'successful']),
        "failed_jobs": sum([r[2] for r in results if r[1] == 'failed']),
        "daily_statistics": results
    }
    
    # Save report
    with open(f"/var/reports/monthly-report-{datetime.now().strftime('%Y-%m')}.json", 'w') as f:
        json.dump(report, f, indent=2)
    
    conn.close()
    return report

if __name__ == "__main__":
    report = generate_monthly_report()
    print(f"Monthly report generated: {report['total_jobs']} jobs processed")
```

## Incident Response

### Incident Classification

| Severity | Definition | Response Time | Examples |
|----------|------------|---------------|----------|
| P1 - Critical | Complete service outage | 15 minutes | DNA Center down, All automation failed |
| P2 - High | Partial service impact | 30 minutes | Major device unreachable, Pipeline failures |
| P3 - Medium | Limited impact | 2 hours | Single device issues, Configuration drift |
| P4 - Low | Minor issues | 4 hours | Logging issues, Performance degradation |

### Incident Response Procedures

#### P1 - Critical Incidents

1. **Immediate Response (0-15 minutes)**
   ```bash
   # Execute emergency runbook
   /opt/scripts/emergency-response.sh
   
   # Check system status
   systemctl status automation-controller
   systemctl status postgresql
   systemctl status nginx
   
   # Verify DNA Center connectivity
   curl -k "https://dnac.company.com/dna/system/api/v1/health"
   
   # Send immediate notification
   echo "P1 Incident: Network Automation System Down" | \
     mail -s "CRITICAL: Network Automation P1 Incident" \
     ops-escalation@company.com
   ```

2. **Assessment and Containment (15-30 minutes)**
   ```bash
   # Gather system logs
   journalctl -u automation-controller --since "30 minutes ago" > /tmp/incident-logs.txt
   tail -100 /var/log/tower/tower.log >> /tmp/incident-logs.txt
   
   # Check resource utilization
   top -b -n 1 >> /tmp/incident-logs.txt
   df -h >> /tmp/incident-logs.txt
   ```

#### P2 - High Incidents

1. **Response Actions**
   ```bash
   # Isolate affected components
   ansible-playbook playbooks/isolate-failed-devices.yml \
     --extra-vars "failed_devices=$(cat /tmp/unreachable-devices.txt)"
   
   # Enable bypass procedures if needed
   ansible-playbook playbooks/enable-manual-mode.yml
   ```

### Recovery Procedures

#### Service Recovery Steps

1. **Identify Root Cause**
   ```bash
   # Analyze logs for error patterns
   grep -i error /var/log/tower/tower.log | tail -50
   grep -i failed /var/log/ansible/*.log | tail -50
   
   # Check system resources
   iostat -x 1 10
   vmstat 1 10
   ```

2. **Implement Fix**
   ```bash
   # Restart services if needed
   systemctl restart automation-controller
   systemctl restart nginx
   
   # Clear stuck jobs
   awx-cli job cancel $(awx-cli job list --status running --format json | \
     jq -r '.results[] | select(.elapsed > 3600) | .id')
   ```

3. **Verify Recovery**
   ```bash
   # Test automation functionality
   ansible-playbook playbooks/smoke-test.yml
   
   # Verify device connectivity
   ansible all -m ping -f 10
   ```

## Change Management

### Change Categories

| Type | Approval Required | Testing Required | Rollback Plan |
|------|------------------|------------------|---------------|
| Emergency | Post-implementation | Minimal | Automated |
| Standard | Yes | Full | Documented |
| Major | Change Board | Comprehensive | Validated |

### Change Implementation Process

#### Pre-Change Activities

```bash
#!/bin/bash
# pre-change-validation.sh

echo "Starting pre-change validation..."

# Backup current configuration
ansible-playbook playbooks/backup-configurations.yml

# Capture current state
ansible all -m setup --tree /tmp/pre-change-facts

# Run validation tests
ansible-playbook playbooks/pre-change-validation.yml

# Generate change readiness report
python3 scripts/generate-readiness-report.py > /tmp/change-readiness.html

echo "Pre-change validation complete"
```

#### Change Implementation

```yaml
# change-implementation.yml
---
- name: Implement Network Changes
  hosts: "{{ target_devices | default('all') }}"
  serial: "{{ batch_size | default('10%') }}"
  max_fail_percentage: "{{ max_failures | default('5') }}"
  
  pre_tasks:
    - name: Verify device connectivity
      wait_for_connection:
        timeout: 30
        
    - name: Create configuration backup
      cisco.ios.ios_config:
        backup: yes
        backup_options:
          filename: "{{ inventory_hostname }}-pre-change-{{ ansible_date_time.epoch }}.cfg"
          dir_path: "./backups/change-{{ change_id }}"
  
  tasks:
    - name: Apply configuration changes
      cisco.ios.ios_config:
        src: "templates/{{ change_template }}.j2"
        backup: yes
        match: line
      register: change_result
      
    - name: Validate changes
      include_tasks: tasks/validate-change.yml
      when: change_result.changed
      
  post_tasks:
    - name: Send change notification
      mail:
        to: "{{ ops_email }}"
        subject: "Change {{ change_id }} applied to {{ inventory_hostname }}"
        body: "Change implementation completed successfully"
      when: change_result.changed
      delegate_to: localhost
```

#### Post-Change Validation

```bash
# post-change-validation.sh

echo "Starting post-change validation..."

# Run comprehensive tests
ansible-playbook playbooks/post-change-validation.yml \
  --extra-vars "change_id=$CHANGE_ID"

# Compare before/after state
python3 scripts/compare-device-states.py \
  /tmp/pre-change-facts \
  /tmp/post-change-facts

# Generate change report
ansible-playbook playbooks/generate-change-report.yml \
  --extra-vars "change_id=$CHANGE_ID output_dir=/var/reports"

echo "Post-change validation complete"
```

## Backup and Recovery

### Backup Strategy

#### Daily Backups

```bash
#!/bin/bash
# daily-backup.sh

BACKUP_DATE=$(date +%Y%m%d)
BACKUP_DIR="/backups/$BACKUP_DATE"
mkdir -p "$BACKUP_DIR"

# Backup network device configurations
echo "Backing up device configurations..."
ansible-playbook playbooks/backup-configurations.yml \
  --extra-vars "backup_dir=$BACKUP_DIR/configs"

# Backup DNA Center
echo "Backing up DNA Center..."
ssh maglev@dnac.company.com "sudo maglev-config backup --path /backup/$BACKUP_DATE"

# Backup NSO
echo "Backing up NSO..."
ncs-backup > "$BACKUP_DIR/nso-backup.tar.gz"

# Backup AAP database
echo "Backing up AAP database..."
pg_dump awx > "$BACKUP_DIR/awx-database.sql"

# Backup automation playbooks and configurations
echo "Backing up automation code..."
git -C /opt/network-automation archive --format=tar.gz HEAD > "$BACKUP_DIR/automation-code.tar.gz"

# Cleanup old backups (keep 30 days)
find /backups -type d -mtime +30 -exec rm -rf {} \;

echo "Daily backup completed: $BACKUP_DIR"
```

#### Recovery Procedures

```bash
#!/bin/bash
# disaster-recovery.sh

RECOVERY_DATE=$1
BACKUP_DIR="/backups/$RECOVERY_DATE"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory $BACKUP_DIR not found"
    exit 1
fi

echo "Starting disaster recovery from $RECOVERY_DATE..."

# Restore AAP database
echo "Restoring AAP database..."
systemctl stop automation-controller
dropdb awx
createdb awx
psql awx < "$BACKUP_DIR/awx-database.sql"
systemctl start automation-controller

# Restore automation code
echo "Restoring automation code..."
cd /opt
tar -xzf "$BACKUP_DIR/automation-code.tar.gz" -C network-automation/

# Restore NSO
echo "Restoring NSO..."
ncs --stop
tar -xzf "$BACKUP_DIR/nso-backup.tar.gz" -C $NCS_RUN_DIR/
ncs

# Restore device configurations (if needed)
echo "Device configuration restoration available via:"
echo "ansible-playbook playbooks/restore-configurations.yml --extra-vars 'backup_dir=$BACKUP_DIR/configs'"

echo "Disaster recovery completed"
```

## Performance Optimization

### System Performance Monitoring

```python
#!/usr/bin/env python3
# performance-monitor.py

import psutil
import time
import json
from datetime import datetime

def collect_performance_metrics():
    """Collect comprehensive system performance metrics"""
    
    metrics = {
        "timestamp": datetime.now().isoformat(),
        "cpu": {
            "usage_percent": psutil.cpu_percent(interval=1),
            "count": psutil.cpu_count(),
            "load_avg": psutil.getloadavg()
        },
        "memory": {
            "total": psutil.virtual_memory().total,
            "available": psutil.virtual_memory().available,
            "used_percent": psutil.virtual_memory().percent
        },
        "disk": {
            "usage": psutil.disk_usage('/').percent,
            "io_counters": psutil.disk_io_counters()._asdict()
        },
        "network": {
            "io_counters": psutil.net_io_counters()._asdict()
        }
    }
    
    # Save metrics
    with open(f"/var/metrics/performance-{datetime.now().strftime('%Y%m%d%H%M')}.json", 'w') as f:
        json.dump(metrics, f, indent=2)
    
    return metrics

def check_performance_thresholds(metrics):
    """Check if performance metrics exceed thresholds"""
    
    alerts = []
    
    if metrics['cpu']['usage_percent'] > 80:
        alerts.append(f"High CPU usage: {metrics['cpu']['usage_percent']}%")
    
    if metrics['memory']['used_percent'] > 85:
        alerts.append(f"High memory usage: {metrics['memory']['used_percent']}%")
    
    if metrics['disk']['usage'] > 90:
        alerts.append(f"High disk usage: {metrics['disk']['usage']}%")
    
    return alerts

if __name__ == "__main__":
    metrics = collect_performance_metrics()
    alerts = check_performance_thresholds(metrics)
    
    if alerts:
        print("Performance alerts:")
        for alert in alerts:
            print(f"  - {alert}")
```

### Optimization Procedures

#### Ansible Performance Tuning

```bash
# Optimize Ansible performance
cat >> /etc/ansible/ansible.cfg << EOF

[defaults]
# Increase parallel processes
forks = 100

# Optimize SSH connections
[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s -o ServerAliveInterval=30
pipelining = True
control_path = ~/.ansible/cp/%%C

# Enable fact caching
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_fact_cache
fact_caching_timeout = 86400
EOF
```

#### Database Optimization

```sql
-- PostgreSQL optimization for AAP
-- /opt/scripts/optimize-database.sql

-- Tune PostgreSQL settings
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.7;

-- Reload configuration
SELECT pg_reload_conf();

-- Create indexes for frequently queried columns
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_main_job_created ON main_job(created);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_main_job_status ON main_job(status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_main_jobevent_job_id ON main_jobevent(job_id);

-- Update table statistics
ANALYZE;
```

## Security Operations

### Security Monitoring

```bash
#!/bin/bash
# security-monitor.sh

echo "Starting security monitoring scan..."

# Check for unauthorized configuration changes
ansible-playbook playbooks/security-compliance-check.yml \
  --extra-vars "compliance_profile=cisco_baseline"

# Monitor authentication logs
echo "Recent authentication events:"
grep -i "authentication" /var/log/tower/tower.log | tail -20

# Check for privilege escalation attempts
echo "Privilege escalation events:"
grep -i "become" /var/log/ansible/*.log | tail -10

# Scan for suspicious network activity
echo "Network security scan:"
nmap -sS -O 10.1.1.0/24 | grep -E "(open|filtered)" > /tmp/network-scan.txt

# Generate security report
python3 scripts/generate-security-report.py > /var/reports/security-$(date --iso-8601).html

echo "Security monitoring completed"
```

### Credential Management

```yaml
# credential-rotation.yml
---
- name: Rotate Network Device Credentials
  hosts: localhost
  tasks:
    - name: Generate new passwords
      set_fact:
        new_password: "{{ lookup('password', '/tmp/new_pass chars=ascii_letters,digits,punctuation length=16') }}"
    
    - name: Update device passwords
      cisco.ios.ios_user:
        name: automation
        configured_password: "{{ new_password }}"
        privilege: 15
      delegate_to: "{{ item }}"
      loop: "{{ groups['all'] }}"
      
    - name: Update AAP credentials
      awx.awx.credential:
        name: "Network Devices"
        credential_type: "Machine"
        inputs:
          username: automation
          password: "{{ new_password }}"
      
    - name: Test new credentials
      ansible.builtin.ping:
      delegate_to: "{{ item }}"
      loop: "{{ groups['all'] }}"
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue: High Automation Job Failure Rate

**Symptoms:**
- Multiple jobs failing with timeout errors
- Slow job execution times
- Resource exhaustion alerts

**Diagnosis:**
```bash
# Check job queue status
awx-cli job list --status failed --created__gte=$(date -d '1 hour ago' --iso-8601)

# Monitor system resources
top -b -n 1 | head -20
free -h
iostat -x 1 5
```

**Resolution:**
```bash
# Scale up automation resources
systemctl stop automation-controller
# Adjust memory allocation in /etc/tower/settings.py
echo "SYSTEM_TASK_ABS_MEM = 2048" >> /etc/tower/settings.py
systemctl start automation-controller

# Optimize job scheduling
echo "AWX_TASK_MAX_WORKERS = 20" >> /etc/tower/settings.py
```

#### Issue: Network Device Connectivity Problems

**Symptoms:**
- Devices showing as unreachable
- SSH connection timeouts
- NETCONF/RESTCONF failures

**Diagnosis:**
```bash
# Test basic connectivity
ping -c 4 10.1.1.10

# Test SSH connectivity
ssh -v automation@10.1.1.10

# Check NETCONF port
telnet 10.1.1.10 830

# Verify device configuration
ansible-playbook playbooks/device-connectivity-test.yml --limit 10.1.1.10
```

**Resolution:**
```bash
# Update SSH host keys
ssh-keyscan -H 10.1.1.10 >> ~/.ssh/known_hosts

# Reset device management interface
ansible-playbook playbooks/reset-management-interface.yml --limit 10.1.1.10

# Update device credentials
ansible-vault edit group_vars/all/vault.yml
```

### Emergency Procedures

#### Complete System Recovery

```bash
#!/bin/bash
# emergency-recovery.sh

echo "EMERGENCY: Starting complete system recovery..."

# Stop all automation services
systemctl stop automation-controller
systemctl stop nginx
systemctl stop postgresql

# Check filesystem integrity
fsck /dev/sda1

# Restore from last known good backup
LAST_BACKUP=$(ls -1t /backups/ | head -1)
echo "Restoring from backup: $LAST_BACKUP"

# Restore database
systemctl start postgresql
dropdb awx 2>/dev/null || true
createdb awx
psql awx < "/backups/$LAST_BACKUP/awx-database.sql"

# Restore application files
tar -xzf "/backups/$LAST_BACKUP/automation-code.tar.gz" -C /opt/network-automation/

# Restart services
systemctl start automation-controller
systemctl start nginx

# Verify system health
sleep 60
curl -k "https://localhost/api/v2/ping/" || echo "ERROR: System not responding"

echo "Emergency recovery completed"
```

---

## Contact Information

### Escalation Matrix

| Level | Role | Contact | Response Time |
|-------|------|---------|---------------|
| L1 | Operations Team | ops-team@company.com | 15 minutes |
| L2 | Senior Engineers | senior-ops@company.com | 30 minutes |
| L3 | Architecture Team | architects@company.com | 1 hour |
| L4 | Management | ops-manager@company.com | 2 hours |

### External Support

- **Cisco TAC**: 1-800-553-2447
- **Red Hat Support**: support.redhat.com
- **GitLab Support**: support.gitlab.com

---

**Document Version:** 1.0  
**Last Updated:** [Date]  
**Next Review:** [Date + 3 months]  
**Owner:** Network Operations Team