# IBM Ansible Automation Platform - Operations Runbook

## Document Information
**Solution**: Red Hat Ansible Automation Platform  
**Version**: 2.4  
**Date**: January 2025  
**Audience**: Operations Teams, Platform Administrators, On-call Engineers  

---

## Overview

This operations runbook provides comprehensive procedures for managing, monitoring, and troubleshooting the Red Hat Ansible Automation Platform in production environments. It covers day-to-day operations, emergency procedures, and maintenance tasks.

### Platform Architecture Overview
```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  Automation         │    │  Automation         │    │  Event-Driven       │
│  Controller         │    │  Hub                │    │  Ansible           │
│  (3 replicas)       │    │  (2 replicas)       │    │  (2 replicas)       │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
           │                           │                           │
           └───────────────────────────┼───────────────────────────┘
                                      │
              ┌─────────────────────────┴─────────────────────────┐
              │            PostgreSQL Database                    │
              │              (High Availability)                 │
              └───────────────────────────────────────────────────┘
```

---

## Daily Operations

### Morning Health Check

#### Platform Status Verification
```bash
#!/bin/bash
# daily-health-check.sh

echo "=== Ansible Automation Platform Health Check ==="
echo "Date: $(date)"
echo

# Check namespace and project status
echo "1. Checking namespace status..."
oc project ansible-automation-platform
oc get all -n ansible-automation-platform

# Check pod health
echo "2. Checking pod health..."
UNHEALTHY_PODS=$(oc get pods -n ansible-automation-platform --field-selector=status.phase!=Running --no-headers | wc -l)
if [ $UNHEALTHY_PODS -gt 0 ]; then
    echo "WARNING: $UNHEALTHY_PODS unhealthy pods detected"
    oc get pods -n ansible-automation-platform --field-selector=status.phase!=Running
else
    echo "✓ All pods are healthy"
fi

# Check service endpoints
echo "3. Checking service endpoints..."
CONTROLLER_URL=$(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')
HUB_URL=$(oc get route automation-hub -n ansible-automation-platform -o jsonpath='{.spec.host}')
EDA_URL=$(oc get route eda-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')

curl -s -k -o /dev/null -w "Controller Status: %{http_code}\n" https://${CONTROLLER_URL}/api/v2/ping/
curl -s -k -o /dev/null -w "Hub Status: %{http_code}\n" https://${HUB_URL}/pulp/api/v3/status/
curl -s -k -o /dev/null -w "EDA Status: %{http_code}\n" https://${EDA_URL}/api/eda/v1/status/

# Check database connectivity
echo "4. Checking database connectivity..."
oc exec postgresql-0 -n ansible-automation-platform -- pg_isready -U controller

# Check storage usage
echo "5. Checking storage usage..."
oc exec postgresql-0 -n ansible-automation-platform -- df -h /var/lib/postgresql/data
```

#### Resource Monitoring
```bash
# Check resource utilization
echo "=== Resource Utilization ==="

# Node resource usage
oc top nodes

# Pod resource usage
oc top pods -n ansible-automation-platform --sort-by=cpu
oc top pods -n ansible-automation-platform --sort-by=memory

# Persistent volume usage
oc get pvc -n ansible-automation-platform -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,CAPACITY:.status.capacity.storage,USED:.status.conditions[0].message
```

### Job Queue Monitoring

#### Check Active Jobs and Queue
```bash
# Monitor job execution
echo "=== Job Queue Status ==="

# Get API token (replace with service account token)
API_TOKEN="your-api-token"
CONTROLLER_URL="https://$(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')"

# Check running jobs
curl -s -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/jobs/?status=running" | \
  jq -r '.results[] | "\(.id) - \(.name) - Started: \(.started)"'

# Check pending jobs
curl -s -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/jobs/?status=pending" | \
  jq -r '.results[] | "\(.id) - \(.name) - Created: \(.created)"'

# Check recent failed jobs
curl -s -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/jobs/?status=failed&page_size=10" | \
  jq -r '.results[] | "\(.id) - \(.name) - Failed: \(.finished) - \(.job_explanation)"'
```

---

## Monitoring and Alerting

### Key Metrics to Monitor

#### Platform Health Metrics
```yaml
# Key metrics for monitoring dashboard
metrics:
  platform_availability:
    - controller_api_response_time
    - hub_api_response_time
    - eda_api_response_time
  
  resource_utilization:
    - cpu_usage_percentage
    - memory_usage_percentage
    - storage_usage_percentage
    - network_io_rate
  
  job_execution:
    - jobs_running_count
    - jobs_pending_count
    - jobs_success_rate
    - jobs_failure_rate
    - average_job_duration
  
  database_performance:
    - db_connection_count
    - db_query_performance
    - db_replication_lag
```

#### Alert Thresholds
```yaml
# Monitoring alert thresholds
alert_thresholds:
  critical:
    - platform_down_for: 5_minutes
    - cpu_usage_over: 90%
    - memory_usage_over: 95%
    - storage_usage_over: 90%
    - job_failure_rate_over: 50%
  
  warning:
    - cpu_usage_over: 80%
    - memory_usage_over: 85%
    - storage_usage_over: 80%
    - job_queue_size_over: 100
    - database_connections_over: 80%
```

### Prometheus Queries

#### Essential Monitoring Queries
```promql
# Platform availability
up{job="automation-controller"} == 0

# High CPU usage
rate(container_cpu_usage_seconds_total{namespace="ansible-automation-platform"}[5m]) > 0.8

# High memory usage
container_memory_usage_bytes{namespace="ansible-automation-platform"} / container_spec_memory_limit_bytes > 0.85

# Job failure rate
rate(ansible_job_failures_total[5m]) > 0.1

# Database connection count
pg_stat_database_numbackends{namespace="ansible-automation-platform"} > 80
```

---

## Incident Response Procedures

### Incident Severity Levels

#### Severity 1 - Critical (Platform Down)
**Response Time**: 15 minutes  
**Definition**: Complete platform unavailability affecting all users

**Immediate Actions**:
```bash
# Check platform status
oc get pods -n ansible-automation-platform
oc get routes -n ansible-automation-platform

# Check controller accessibility
CONTROLLER_URL=$(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')
curl -k https://${CONTROLLER_URL}/api/v2/ping/

# Check database connectivity
oc exec postgresql-0 -n ansible-automation-platform -- pg_isready

# Review recent events
oc get events -n ansible-automation-platform --sort-by='.lastTimestamp' | tail -20

# Scale up replicas if needed
oc scale deployment automation-controller --replicas=3 -n ansible-automation-platform
```

#### Severity 2 - Major (Degraded Performance)
**Response Time**: 1 hour  
**Definition**: Significant performance degradation or partial functionality loss

**Actions**:
```bash
# Check resource utilization
oc top nodes
oc top pods -n ansible-automation-platform

# Check job queue backlog
# (Use API calls from monitoring section)

# Check database performance
oc exec postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "
SELECT query, calls, mean_exec_time, stddev_exec_time 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 10;"
```

### Common Incident Resolution

#### Platform Pods Not Starting
```bash
# Diagnostic steps
echo "=== Pod Startup Troubleshooting ==="

# Check pod status and events
POD_NAME="automation-controller-xyz"
oc describe pod $POD_NAME -n ansible-automation-platform

# Check resource quotas
oc describe resourcequota -n ansible-automation-platform
oc describe limits -n ansible-automation-platform

# Check persistent volume claims
oc get pvc -n ansible-automation-platform
oc describe pvc postgres-storage -n ansible-automation-platform

# Check security context constraints
oc get scc ansible-automation-scc -o yaml

# Resolution steps
# 1. Delete and recreate problematic pods
oc delete pod $POD_NAME -n ansible-automation-platform

# 2. Check and fix resource constraints
oc edit deployment automation-controller -n ansible-automation-platform

# 3. Verify storage availability
oc get pv | grep Available
```

#### Database Connection Issues
```bash
# Database connectivity troubleshooting
echo "=== Database Connectivity Issues ==="

# Check PostgreSQL pod status
oc get pods -l app=postgresql -n ansible-automation-platform

# Test database connectivity
oc exec postgresql-0 -n ansible-automation-platform -- pg_isready -U controller

# Check connection count
oc exec postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "
SELECT count(*) as connection_count 
FROM pg_stat_activity 
WHERE state = 'active';"

# Check for long-running queries
oc exec postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "
SELECT pid, now() - pg_stat_activity.query_start AS duration, query 
FROM pg_stat_activity 
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';"

# Resolution steps
# 1. Restart PostgreSQL if needed
oc rollout restart statefulset postgresql -n ansible-automation-platform

# 2. Terminate long-running queries
oc exec postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid = <problematic_pid>;"

# 3. Scale controller replicas to reset connections
oc scale deployment automation-controller --replicas=0 -n ansible-automation-platform
sleep 30
oc scale deployment automation-controller --replicas=3 -n ansible-automation-platform
```

#### Job Execution Failures
```bash
# Job execution troubleshooting
echo "=== Job Execution Troubleshooting ==="

# Check execution environment pods
oc get pods -l app.kubernetes.io/name=execution-environment -n ansible-automation-platform

# Check node resources for job execution
oc top nodes
oc describe node | grep -A 10 "Non-terminated Pods"

# Check for stuck jobs
curl -s -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/jobs/?status=running" | \
  jq -r '.results[] | select((now - (.started | fromdateiso8601)) > 3600) | "\(.id) - \(.name) - Running for: \((now - (.started | fromdateiso8601))/60) minutes"'

# Resolution steps
# 1. Cancel stuck jobs via API
curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/jobs/{job_id}/cancel/"

# 2. Check and restart execution nodes
oc get nodes -l node-role.kubernetes.io/worker=
oc cordon node-name  # if needed
oc drain node-name --ignore-daemonsets  # if needed
```

---

## Maintenance Procedures

### Weekly Maintenance

#### Database Maintenance
```bash
#!/bin/bash
# weekly-db-maintenance.sh

echo "=== Weekly Database Maintenance ==="
echo "Date: $(date)"

# Database statistics update
oc exec postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "
ANALYZE;
VACUUM (VERBOSE, ANALYZE);
REINDEX DATABASE automationcontroller;"

# Check database size
oc exec postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;"

# Clean old job history (older than 30 days)
curl -X DELETE -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/jobs/?finished__lt=$(date -d '30 days ago' -Iseconds)"
```

#### Log Management
```bash
# Log rotation and cleanup
echo "=== Log Management ==="

# Check log sizes in pods
oc exec postgresql-0 -n ansible-automation-platform -- du -sh /var/log/
oc exec automation-controller-xyz -n ansible-automation-platform -- du -sh /var/log/

# Archive old logs (if not using centralized logging)
oc exec postgresql-0 -n ansible-automation-platform -- find /var/log -name "*.log" -mtime +7 -exec gzip {} \;
oc exec postgresql-0 -n ansible-automation-platform -- find /var/log -name "*.log.gz" -mtime +30 -delete
```

### Monthly Maintenance

#### Security Updates and Patches
```bash
#!/bin/bash
# monthly-security-updates.sh

echo "=== Monthly Security Maintenance ==="

# Check for operator updates
oc get csv -n ansible-automation-platform

# Check image vulnerabilities (if using registry scanning)
oc get images -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.dockerImageMetadata.Config.Image}{"\n"}{end}' | grep automation

# Update execution environment images
oc patch automationcontroller automation-controller -n ansible-automation-platform --type='merge' -p='
{
  "spec": {
    "image": "quay.io/ansible/automation-controller:latest"
  }
}'

# Verify TLS certificates
echo | openssl s_client -servername $(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}') -connect $(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}'):443 2>/dev/null | openssl x509 -noout -dates
```

#### Performance Optimization
```bash
# Performance tuning review
echo "=== Performance Optimization ==="

# Check resource utilization trends
oc top nodes
oc top pods -n ansible-automation-platform

# Review database performance
oc exec postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_tup_hot_upd as hot_updates,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM pg_stat_user_tables 
ORDER BY seq_tup_read DESC
LIMIT 10;"

# Adjust resource allocations if needed
oc edit deployment automation-controller -n ansible-automation-platform
# Update CPU and memory requests/limits based on usage patterns
```

---

## Backup and Recovery

### Backup Procedures

#### Automated Daily Backup
```bash
#!/bin/bash
# daily-backup.sh

BACKUP_DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/backups/ansible-platform/$BACKUP_DATE"
mkdir -p $BACKUP_DIR

echo "Starting backup for Ansible Automation Platform - $BACKUP_DATE"

# Backup PostgreSQL databases
echo "Backing up databases..."
oc exec postgresql-0 -n ansible-automation-platform -- pg_dump -U controller -h localhost automationcontroller | gzip > $BACKUP_DIR/controller-db.sql.gz
oc exec postgresql-0 -n ansible-automation-platform -- pg_dump -U hub -h localhost automationhub | gzip > $BACKUP_DIR/hub-db.sql.gz
oc exec postgresql-0 -n ansible-automation-platform -- pg_dump -U eda -h localhost eda | gzip > $BACKUP_DIR/eda-db.sql.gz

# Backup configuration objects
echo "Backing up configurations..."
oc get automationcontroller automation-controller -n ansible-automation-platform -o yaml > $BACKUP_DIR/controller-config.yaml
oc get automationhub automation-hub -n ansible-automation-platform -o yaml > $BACKUP_DIR/hub-config.yaml
oc get edacontroller eda-controller -n ansible-automation-platform -o yaml > $BACKUP_DIR/eda-config.yaml

# Backup secrets
oc get secrets -n ansible-automation-platform -o yaml > $BACKUP_DIR/secrets.yaml

# Backup persistent volume claims
oc get pvc -n ansible-automation-platform -o yaml > $BACKUP_DIR/pvc.yaml

# Create backup manifest
cat > $BACKUP_DIR/backup-manifest.txt << EOF
Ansible Automation Platform Backup
Date: $(date)
Components:
- Automation Controller Database
- Automation Hub Database
- EDA Controller Database
- Platform Configurations
- Kubernetes Secrets
- Persistent Volume Claims

Backup Size: $(du -sh $BACKUP_DIR | cut -f1)
EOF

echo "Backup completed: $BACKUP_DIR"

# Clean up old backups (keep 30 days)
find /backups/ansible-platform -type d -name "20*" -mtime +30 -exec rm -rf {} \;
```

### Recovery Procedures

#### Database Recovery
```bash
#!/bin/bash
# database-recovery.sh

BACKUP_DIR="/backups/ansible-platform/20250115-120000"  # Replace with actual backup

echo "=== Database Recovery Procedure ==="

# Scale down platform to prevent data corruption
oc scale deployment automation-controller --replicas=0 -n ansible-automation-platform
oc scale deployment automation-hub --replicas=0 -n ansible-automation-platform
oc scale deployment eda-controller --replicas=0 -n ansible-automation-platform

# Wait for pods to terminate
sleep 60

# Drop and recreate databases
oc exec postgresql-0 -n ansible-automation-platform -- dropdb -U postgres automationcontroller
oc exec postgresql-0 -n ansible-automation-platform -- dropdb -U postgres automationhub
oc exec postgresql-0 -n ansible-automation-platform -- dropdb -U postgres eda

oc exec postgresql-0 -n ansible-automation-platform -- createdb -U postgres automationcontroller
oc exec postgresql-0 -n ansible-automation-platform -- createdb -U postgres automationhub
oc exec postgresql-0 -n ansible-automation-platform -- createdb -U postgres eda

# Restore databases
zcat $BACKUP_DIR/controller-db.sql.gz | oc exec -i postgresql-0 -n ansible-automation-platform -- psql -U controller automationcontroller
zcat $BACKUP_DIR/hub-db.sql.gz | oc exec -i postgresql-0 -n ansible-automation-platform -- psql -U hub automationhub
zcat $BACKUP_DIR/eda-db.sql.gz | oc exec -i postgresql-0 -n ansible-automation-platform -- psql -U eda eda

# Scale up platform
oc scale deployment automation-controller --replicas=3 -n ansible-automation-platform
oc scale deployment automation-hub --replicas=2 -n ansible-automation-platform
oc scale deployment eda-controller --replicas=2 -n ansible-automation-platform

echo "Database recovery completed"
```

#### Full Platform Recovery
```bash
#!/bin/bash
# full-platform-recovery.sh

BACKUP_DIR="/backups/ansible-platform/20250115-120000"

echo "=== Full Platform Recovery Procedure ==="

# Recreate namespace if needed
oc create namespace ansible-automation-platform

# Restore secrets
oc apply -f $BACKUP_DIR/secrets.yaml

# Restore persistent volume claims
oc apply -f $BACKUP_DIR/pvc.yaml

# Wait for PVCs to be bound
oc get pvc -n ansible-automation-platform -w

# Restore configurations
oc apply -f $BACKUP_DIR/controller-config.yaml
oc apply -f $BACKUP_DIR/hub-config.yaml
oc apply -f $BACKUP_DIR/eda-config.yaml

# Monitor recovery progress
oc get pods -n ansible-automation-platform -w
```

---

## Performance Tuning

### Controller Optimization

#### Database Connection Tuning
```yaml
# controller-performance-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: controller-performance-settings
  namespace: ansible-automation-platform
data:
  DATABASE_MAX_CONNECTIONS: "100"
  DATABASE_CONN_MAX_AGE: "300"
  JOB_EVENT_BUFFER_SIZE: "1000"
  TASK_MANAGER_TIMEOUT: "300"
```

#### Resource Allocation Optimization
```yaml
# Update controller deployment resources
spec:
  resources:
    requests:
      cpu: "2000m"
      memory: "8Gi"
    limits:
      cpu: "4000m"
      memory: "16Gi"
```

### Database Performance Tuning

#### PostgreSQL Configuration
```sql
-- postgresql-performance-tuning.sql
-- Execute these on the PostgreSQL instance

-- Connection and memory settings
ALTER SYSTEM SET max_connections = '200';
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET work_mem = '4MB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';

-- Query optimization
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET default_statistics_target = '100';

-- WAL settings
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET checkpoint_completion_target = '0.7';
ALTER SYSTEM SET wal_writer_delay = '200ms';

-- Restart required for some settings
SELECT pg_reload_conf();
```

---

## Security Operations

### Access Management

#### User Access Audit
```bash
#!/bin/bash
# user-access-audit.sh

echo "=== User Access Audit ==="

# Get all users and their last login
curl -s -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/users/" | \
  jq -r '.results[] | "\(.username) - Last Login: \(.last_login // "Never") - Active: \(.is_active)"'

# Check administrative users
curl -s -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/users/?is_superuser=true" | \
  jq -r '.results[] | "\(.username) - \(.email) - Last Login: \(.last_login // "Never")"'

# Audit team memberships
curl -s -k -H "Authorization: Bearer $API_TOKEN" \
  "${CONTROLLER_URL}/api/v2/teams/" | \
  jq -r '.results[] | "\(.name) - Members: \(.summary_fields.user_capabilities | length)"'
```

#### Security Configuration Review
```bash
# Security settings audit
echo "=== Security Configuration Review ==="

# Check TLS configuration
echo | openssl s_client -servername $(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}') -connect $(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}'):443 2>/dev/null | openssl x509 -noout -text | grep -E "(Subject:|Issuer:|Not Before|Not After)"

# Check RBAC policies
oc get rolebindings,clusterrolebindings --all-namespaces | grep ansible

# Review network policies
oc get networkpolicy -n ansible-automation-platform

# Check security context constraints
oc get scc | grep ansible
```

---

## Contact Information and Escalation

### On-Call Escalation Matrix

#### Severity 1 - Critical
1. **Primary**: Platform Team Lead (Phone: +1-XXX-XXX-XXXX)
2. **Secondary**: Senior DevOps Engineer (Phone: +1-XXX-XXX-XXXX)
3. **Escalation**: Infrastructure Manager (Phone: +1-XXX-XXX-XXXX)

#### Severity 2 - Major
1. **Primary**: Platform Engineer (Email: platform-team@company.com)
2. **Secondary**: DevOps Team (Slack: #devops-team)

### External Contacts
- **Red Hat Support**: Case Portal (access.redhat.com)
- **OpenShift Support**: +1-XXX-XXX-XXXX
- **Cloud Provider Support**: [Provider-specific contact]

---

## Change Management

### Maintenance Windows
- **Regular Maintenance**: Every Sunday 02:00-06:00 UTC
- **Emergency Maintenance**: As needed with 2-hour notice
- **Security Updates**: Monthly, first Saturday 01:00-03:00 UTC

### Change Approval Process
1. **Standard Changes**: Platform team approval required
2. **Emergency Changes**: Manager approval required
3. **Major Changes**: Change Advisory Board approval required

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Next Review**: April 2025  
**Maintained By**: Platform Operations Team