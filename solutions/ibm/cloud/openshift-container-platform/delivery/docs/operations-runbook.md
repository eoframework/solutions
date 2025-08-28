# IBM OpenShift Container Platform Operations Runbook

## Table of Contents
1. [Daily Operations](#daily-operations)
2. [Health Monitoring](#health-monitoring)
3. [Maintenance Procedures](#maintenance-procedures)
4. [Incident Response](#incident-response)
5. [Performance Optimization](#performance-optimization)
6. [Capacity Management](#capacity-management)
7. [Security Operations](#security-operations)
8. [Backup and Recovery Operations](#backup-and-recovery-operations)
9. [Change Management](#change-management)
10. [Automation and Scripts](#automation-and-scripts)

## Daily Operations

### Morning Health Checks

#### 1. Cluster Status Verification
```bash
#!/bin/bash
# Daily cluster health check script

echo "=== OpenShift Cluster Health Check - $(date) ==="

# Check cluster operators status
echo "Cluster Operators Status:"
oc get co --no-headers | awk '$3!="True" || $4!="False" || $5!="False" {print $0}'

# Check node status
echo "Node Status:"
oc get nodes --no-headers | awk '$2!="Ready" {print $0}'

# Check critical namespaces
echo "Critical Namespace Pod Status:"
for ns in openshift-kube-apiserver openshift-etcd openshift-authentication openshift-oauth-apiserver; do
    echo "Namespace: $ns"
    oc get pods -n $ns --no-headers | awk '$3!="Running" && $3!="Completed" {print $0}'
done

# Check persistent volume status
echo "PersistentVolume Issues:"
oc get pv --no-headers | awk '$5!="Bound" {print $0}'

# Check certificate expiration (within 30 days)
echo "Certificate Expiration Check:"
oc get secrets -A -o json | jq -r '.items[] | select(.type=="kubernetes.io/tls") | select(.metadata.annotations["cert-manager.io/certificate-name"]) | "\(.metadata.namespace)/\(.metadata.name) expires: \(.data."tls.crt" | @base64d | split("\n") | map(select(startswith("-----BEGIN CERTIFICATE-----"))) | .[0] | @base64 | @base64d | split("\n")[1])"' 2>/dev/null

echo "=== Health Check Complete ==="
```

#### 2. IBM Cloud Resource Monitoring
```bash
#!/bin/bash
# IBM Cloud resource monitoring

echo "=== IBM Cloud Resources Check - $(date) ==="

# Check VPC instances
ibmcloud is instances --output json | jq -r '.[] | "\(.name): \(.status)"'

# Check load balancer status
ibmcloud is load-balancers --output json | jq -r '.[] | "\(.name): \(.provisioning_status) - \(.operating_status)"'

# Check VPC quotas
ibmcloud is quotas --output json | jq '.[] | select(.limit - .used < .limit * 0.2) | "\(.resource_type): \(.used)/\(.limit) (\((.used/.limit)*100|floor)% used)"'

# Check IBM Cloud Object Storage usage
ibmcloud cos config list --output json

echo "=== IBM Cloud Resources Check Complete ==="
```

#### 3. Performance Baseline Collection
```bash
#!/bin/bash
# Collect daily performance baselines

echo "=== Performance Baseline Collection - $(date) ==="

# CPU and Memory utilization
kubectl top nodes > /tmp/node-utilization-$(date +%Y%m%d).txt
kubectl top pods -A > /tmp/pod-utilization-$(date +%Y%m%d).txt

# Storage utilization
df -h > /tmp/storage-utilization-$(date +%Y%m%d).txt

# Network statistics
oc get pods -n openshift-sdn -l app=sdn -o jsonpath='{.items[*].metadata.name}' | xargs -I {} oc exec {} -n openshift-sdn -- ss -tuln > /tmp/network-stats-$(date +%Y%m%d).txt

echo "=== Baseline Collection Complete ==="
```

### End-of-Day Tasks

#### 1. Log Aggregation and Analysis
```bash
#!/bin/bash
# End of day log analysis

# Generate daily summary report
oc adm node-logs --role=master --since=24h | grep -E "(ERROR|FATAL|WARNING)" > /tmp/master-issues-$(date +%Y%m%d).log
oc adm node-logs --role=worker --since=24h | grep -E "(ERROR|FATAL|WARNING)" > /tmp/worker-issues-$(date +%Y%m%d).log

# Check for authentication failures
oc logs -n openshift-authentication --since=24h | grep -i "authentication failed" > /tmp/auth-failures-$(date +%Y%m%d).log

# Resource constraint issues
oc get events -A --since=24h | grep -E "(FailedScheduling|OutOfMemory|DiskPressure)" > /tmp/resource-issues-$(date +%Y%m%d).log
```

#### 2. Backup Verification
```bash
#!/bin/bash
# Verify daily backups completed successfully

# Check etcd backup status
if [ -f "/var/lib/etcd-backup/$(date +%Y%m%d)/backup.tar.gz" ]; then
    echo "etcd backup completed successfully"
else
    echo "ALERT: etcd backup missing for $(date +%Y%m%d)"
fi

# Check Velero backup status
oc get backups -n velero --sort-by='.metadata.creationTimestamp' | tail -1
```

## Health Monitoring

### Critical Metrics Dashboard

#### 1. Cluster Health Indicators
```yaml
# PrometheusRule for critical cluster metrics
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cluster-health-alerts
  namespace: openshift-monitoring
spec:
  groups:
  - name: cluster-health
    rules:
    - alert: NodeNotReady
      expr: kube_node_status_condition{condition="Ready",status="true"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Node {{ $labels.node }} is not ready"
        
    - alert: EtcdHighLatency
      expr: histogram_quantile(0.99, rate(etcd_disk_backend_commit_duration_seconds_bucket[5m])) > 0.25
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "etcd high commit latency on {{ $labels.instance }}"
        
    - alert: APIServerHighLatency
      expr: histogram_quantile(0.99, rate(apiserver_request_duration_seconds_bucket[5m])) > 1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "API server high latency: {{ $value }}s"
        
    - alert: ClusterOperatorDegraded
      expr: cluster_operator_conditions{condition="Degraded",status="true"} == 1
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: "Cluster operator {{ $labels.name }} is degraded"
```

#### 2. IBM Cloud Integration Monitoring
```bash
#!/bin/bash
# Monitor IBM Cloud integration components

# Check IBM Cloud Controller Manager
kubectl get pods -n kube-system -l app=ibm-cloud-controller-manager

# Check IBM VPC Block CSI Driver
kubectl get pods -n kube-system -l app=ibm-vpc-block-csi-controller

# Check IBM Cloud monitoring agent
kubectl get pods -n ibm-observe -l app=logdna-agent

# Monitor IBM Key Protect connectivity
kubectl get pods -n ibm-system -l app=key-protect-operator
```

#### 3. Application Health Monitoring
```yaml
# ServiceMonitor for application health
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: application-health
  namespace: production
spec:
  selector:
    matchLabels:
      monitoring: enabled
  endpoints:
  - port: health
    path: /health
    interval: 30s
    healthCheck:
      path: /health
```

### Automated Health Reporting

#### 1. Slack Integration for Alerts
```yaml
# AlertManager configuration for Slack notifications
global:
  slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#openshift-alerts'
    username: 'OpenShift AlertManager'
    title: 'OpenShift Alert'
    text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
    send_resolved: true
```

#### 2. Email Reporting
```bash
#!/bin/bash
# Daily health report via email

cat > /tmp/daily-report.html << EOF
<html>
<head><title>OpenShift Daily Health Report - $(date)</title></head>
<body>
<h1>OpenShift Daily Health Report</h1>
<h2>Cluster Status</h2>
<pre>$(oc get co)</pre>
<h2>Node Status</h2>
<pre>$(oc get nodes)</pre>
<h2>Resource Utilization</h2>
<pre>$(kubectl top nodes)</pre>
<h2>Recent Events</h2>
<pre>$(oc get events -A --since=24h | grep -E "(Warning|Error)" | tail -20)</pre>
</body>
</html>
EOF

# Send email using mail command or SMTP relay
mail -s "OpenShift Daily Health Report - $(date)" -a "Content-Type: text/html" operations@company.com < /tmp/daily-report.html
```

## Maintenance Procedures

### Scheduled Maintenance

#### 1. Node Maintenance
```bash
#!/bin/bash
# Node maintenance procedure

NODE_NAME=$1
if [ -z "$NODE_NAME" ]; then
    echo "Usage: $0 <node-name>"
    exit 1
fi

echo "Starting maintenance on node: $NODE_NAME"

# Drain node
oc adm drain $NODE_NAME --ignore-daemonsets --delete-emptydir-data --force

# Wait for pods to be rescheduled
sleep 60

# Perform maintenance tasks
echo "Node $NODE_NAME is ready for maintenance"
echo "Remember to uncordon the node after maintenance:"
echo "oc adm uncordon $NODE_NAME"
```

#### 2. Cluster Updates
```bash
#!/bin/bash
# Cluster update procedure

# Check current version
CURRENT_VERSION=$(oc version -o json | jq -r '.openshiftVersion')
echo "Current cluster version: $CURRENT_VERSION"

# List available updates
oc adm upgrade --include-not-recommended

# Apply update (example to specific version)
read -p "Enter target version: " TARGET_VERSION
oc adm upgrade --to=$TARGET_VERSION

# Monitor update progress
watch "oc get clusterversion; oc get co; oc get nodes"
```

#### 3. Certificate Rotation
```bash
#!/bin/bash
# Certificate rotation procedures

# Force certificate rotation for all certificates
oc patch kubeapiserver cluster -p='{"spec":{"forceRedeploymentReason":"certificate-rotation-$(date +%s)"}}' --type=merge

# Monitor certificate rotation progress
watch "oc get pods -n openshift-kube-apiserver"

# Verify new certificates
oc get secrets -A | grep serving-cert
```

### Emergency Procedures

#### 1. Master Node Recovery
```bash
#!/bin/bash
# Master node recovery procedure

FAILED_MASTER=$1
echo "Recovering master node: $FAILED_MASTER"

# Remove failed master from etcd cluster
oc get pods -n openshift-etcd -l app=etcd -o jsonpath='{.items[*].metadata.name}' | xargs -I {} oc exec {} -n openshift-etcd -- etcdctl member list

# Follow documented recovery procedures based on the scenario:
# - Single master failure: Restore from backup
# - Multiple master failures: Disaster recovery
# - etcd corruption: Restore from etcd snapshot

echo "Refer to Red Hat documentation for specific recovery procedures"
```

#### 2. Storage Recovery
```bash
#!/bin/bash
# Storage recovery procedures

# Check persistent volume issues
oc get pv | grep -v Bound

# Force delete stuck terminating PVs
kubectl patch pv <pv-name> -p '{"metadata":{"finalizers":null}}'

# Recreate storage classes if missing
oc apply -f /path/to/storage-class-definitions.yaml
```

## Incident Response

### Incident Classification

#### Severity 1 (Critical)
- Complete cluster outage
- Multiple master nodes down
- Data corruption or loss
- Security breach

#### Severity 2 (High)
- Single master node failure
- Critical application unavailable
- Performance severely degraded
- Authentication system failure

#### Severity 3 (Medium)
- Worker node failures
- Non-critical service degradation
- Storage performance issues
- Minor security vulnerabilities

#### Severity 4 (Low)
- Monitoring alerts
- Documentation updates
- Performance optimization
- Scheduled maintenance

### Incident Response Procedures

#### 1. Initial Response
```bash
#!/bin/bash
# Incident response initial assessment

echo "=== Incident Response Assessment - $(date) ==="

# Gather cluster state information
oc get nodes -o wide > /tmp/incident-nodes-$(date +%s).txt
oc get co > /tmp/incident-operators-$(date +%s).txt
oc get pods -A | grep -v Running > /tmp/incident-pods-$(date +%s).txt

# Check recent events
oc get events -A --sort-by='.lastTimestamp' | tail -50 > /tmp/incident-events-$(date +%s).txt

# Collect logs from problematic components
kubectl logs -n openshift-kube-apiserver -l app=kube-apiserver --tail=100 > /tmp/incident-apiserver-logs-$(date +%s).txt

echo "Initial assessment complete. Files saved to /tmp/"
```

#### 2. Communication Template
```text
INCIDENT NOTIFICATION

Severity: [1-4]
Start Time: [YYYY-MM-DD HH:MM UTC]
Affected Services: [List of affected services]
Impact: [Description of business impact]
Status: [Investigating/Mitigating/Resolved]

Current Actions:
- [Action 1]
- [Action 2]

Next Update: [Time of next update]

War Room: [Slack channel/Bridge number]
Incident Commander: [Name]
```

#### 3. Post-Incident Review Template
```text
POST-INCIDENT REVIEW

Incident ID: [INC-YYYY-MMDD-###]
Date: [YYYY-MM-DD]
Duration: [Time to resolution]
Severity: [1-4]

SUMMARY:
[Brief description of what happened]

TIMELINE:
[Detailed timeline of events]

ROOT CAUSE:
[Technical root cause analysis]

IMPACT:
[Business and technical impact]

RESOLUTION:
[How the incident was resolved]

ACTION ITEMS:
1. [Action item 1] - Owner: [Name] - Due: [Date]
2. [Action item 2] - Owner: [Name] - Due: [Date]

LESSONS LEARNED:
[What we learned and how to prevent recurrence]
```

## Performance Optimization

### Resource Optimization

#### 1. Node Resource Tuning
```bash
#!/bin/bash
# Node performance tuning

# Apply machine config for performance tuning
cat << EOF | oc apply -f -
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 99-worker-performance-tuning
spec:
  config:
    ignition:
      version: 3.2.0
    systemd:
      units:
      - name: tuned-performance.service
        enabled: true
        contents: |
          [Unit]
          Description=Tuned Performance Profile
          After=tuned.service
          
          [Service]
          Type=oneshot
          ExecStart=/usr/sbin/tuned-adm profile throughput-performance
          RemainAfterExit=yes
          
          [Install]
          WantedBy=multi-user.target
EOF
```

#### 2. Application Performance Tuning
```yaml
# Performance-optimized deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: high-performance-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: high-performance-app
  template:
    metadata:
      labels:
        app: high-performance-app
    spec:
      containers:
      - name: app
        image: myapp:latest
        resources:
          requests:
            cpu: "2"
            memory: "4Gi"
          limits:
            cpu: "4"
            memory: "8Gi"
        env:
        - name: GOMAXPROCS
          valueFrom:
            resourceFieldRef:
              resource: limits.cpu
      nodeSelector:
        node-role.kubernetes.io/worker: ""
      tolerations:
      - key: "high-performance"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
```

#### 3. Storage Performance Optimization
```yaml
# High-performance storage class
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ibm-vpc-block-performance
provisioner: vpc.block.csi.ibm.io
parameters:
  profile: custom
  iops: "10000"
  csi.storage.k8s.io/fstype: ext4
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

### Network Optimization

#### 1. Network Policy Optimization
```yaml
# Optimized network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: optimized-network-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
```

#### 2. Load Balancer Optimization
```bash
#!/bin/bash
# Optimize IBM Cloud Load Balancer settings

# Update load balancer with optimized settings
ibmcloud is load-balancer-pool-member-update <lb-id> <pool-id> <member-id> \
  --weight 100 \
  --port 8080

# Configure health check optimization
ibmcloud is load-balancer-pool-update <lb-id> <pool-id> \
  --health-monitor-delay 10 \
  --health-monitor-max-retries 3 \
  --health-monitor-timeout 5 \
  --health-monitor-type http \
  --health-monitor-url-path /health
```

## Capacity Management

### Resource Planning

#### 1. Capacity Monitoring Script
```bash
#!/bin/bash
# Capacity monitoring and forecasting

echo "=== Capacity Report - $(date) ==="

# Node resource utilization
echo "Node Resource Utilization:"
kubectl top nodes

# Persistent Volume usage
echo "Storage Utilization:"
kubectl get pv -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,STATUS:.status.phase,CLAIM:.spec.claimRef.name

# Namespace resource consumption
echo "Namespace Resource Consumption:"
kubectl top pods -A --sort-by=cpu | head -20

# IBM Cloud quota usage
echo "IBM Cloud Quotas:"
ibmcloud is quotas | grep -E "(instances|volumes|load_balancers)"

# Generate utilization trends
oc query 'node:node_cpu_utilisation:avg1m' --since=24h
oc query 'node:node_memory_utilisation:' --since=24h
```

#### 2. Scaling Recommendations
```bash
#!/bin/bash
# Generate scaling recommendations

# Check for resource-constrained pods
echo "Resource-Constrained Pods:"
kubectl top pods -A --sort-by=memory | awk 'NR>1 && $3~/Mi$/ {mem=substr($3,1,length($3)-2); if(mem>7000) print $0}'

# Check for underutilized nodes
echo "Node Utilization Analysis:"
kubectl top nodes | awk 'NR>1 {
    cpu_percent=substr($3,1,length($3)-1)
    mem_percent=substr($5,1,length($5)-1)
    if(cpu_percent < 20 && mem_percent < 20) 
        print $1 " is underutilized: CPU " $3 ", Memory " $5
}'
```

### Autoscaling Configuration

#### 1. Cluster Autoscaler
```yaml
# Cluster Autoscaler configuration
apiVersion: "autoscaling.openshift.io/v1"
kind: "ClusterAutoscaler"
metadata:
  name: "default"
spec:
  podPriorityThreshold: -10
  resourceLimits:
    maxNodesTotal: 24
    cores:
      min: 8
      max: 96
    memory:
      min: 32
      max: 384
  scaleDown:
    enabled: true
    delayAfterAdd: 10m
    delayAfterDelete: 10s
    delayAfterFailure: 30s
    unneededTime: 10m
```

#### 2. Machine Autoscaler
```yaml
# Machine Autoscaler for worker nodes
apiVersion: "autoscaling.openshift.io/v1beta1"
kind: "MachineAutoscaler"
metadata:
  name: "worker-autoscaler"
  namespace: "openshift-machine-api"
spec:
  minReplicas: 3
  maxReplicas: 10
  scaleTargetRef:
    apiVersion: machine.openshift.io/v1beta1
    kind: MachineSet
    name: openshift-cluster-worker-us-south-1
```

## Security Operations

### Security Monitoring

#### 1. Security Event Monitoring
```bash
#!/bin/bash
# Security event monitoring script

echo "=== Security Events Report - $(date) ==="

# Failed authentication attempts
echo "Authentication Failures (last 24h):"
oc logs -n openshift-authentication --since=24h | grep -i "authentication failed" | wc -l

# Privileged container attempts
echo "Privileged Container Creation Attempts:"
oc get events -A --field-selector reason=FailedCreate | grep -i "privileged"

# Security policy violations
echo "Security Policy Violations:"
oc get events -A | grep -E "(SecurityPolicy|PodSecurityPolicy)" | tail -10

# Suspicious network activity
echo "Network Policy Violations:"
oc logs -n openshift-sdn --since=24h | grep -i "denied"
```

#### 2. Compliance Scanning
```yaml
# ComplianceScan for security compliance
apiVersion: compliance.openshift.io/v1alpha1
kind: ComplianceScan
metadata:
  name: nist-scan
  namespace: openshift-compliance
spec:
  profile: xccdf_org.ssgproject.content_profile_moderate
  content: ssg-rhcos4-ds.xml
  nodeSelector:
    node-role.kubernetes.io/worker: ""
  scanType: Node
```

#### 3. Vulnerability Assessment
```bash
#!/bin/bash
# Container vulnerability scanning

# Scan container images for vulnerabilities
oc adm registry info
oc get images -o json | jq -r '.items[].dockerImageReference' | head -10 | while read image; do
    echo "Scanning image: $image"
    oc adm catalog validate-bundle $image 2>&1 | grep -E "(HIGH|CRITICAL)" || echo "No critical vulnerabilities found"
done
```

### Access Management

#### 1. RBAC Audit
```bash
#!/bin/bash
# RBAC access audit

echo "=== RBAC Audit Report - $(date) ==="

# List all cluster role bindings
echo "Cluster Role Bindings:"
oc get clusterrolebindings -o custom-columns=NAME:.metadata.name,ROLE:.roleRef.name,SUBJECTS:.subjects[*].name

# List users with cluster-admin access
echo "Cluster Administrators:"
oc get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name=="cluster-admin") | .subjects[]?.name' | sort -u

# Review service account permissions
echo "Service Account Permissions Review:"
oc get sa -A -o json | jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' | while read sa; do
    ns=$(echo $sa | cut -d'/' -f1)
    name=$(echo $sa | cut -d'/' -f2)
    oc get rolebindings,clusterrolebindings -A -o json | jq -r --arg ns "$ns" --arg name "$name" '.items[] | select(.subjects[]?.name==$name and .subjects[]?.namespace==$ns) | "\($ns)/\($name) has \(.roleRef.name)"'
done | head -20
```

#### 2. User Activity Monitoring
```bash
#!/bin/bash
# User activity monitoring

# Track API server access logs
oc logs -n openshift-kube-apiserver -l app=kube-apiserver --since=24h | grep -E "user:|verb:" | tail -50

# Monitor authentication events
oc get events -A --field-selector reason=Authentication | tail -20

# Check for suspicious user behavior
oc logs -n openshift-authentication --since=24h | grep -E "(failed|error|denied)" | tail -20
```

## Backup and Recovery Operations

### Backup Procedures

#### 1. etcd Backup
```bash
#!/bin/bash
# Automated etcd backup with IBM Cloud Object Storage

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/lib/etcd-backup/${BACKUP_DATE}"
BUCKET_NAME="openshift-etcd-backups"

# Create backup directory
mkdir -p ${BACKUP_DIR}

# Create etcd snapshot
oc debug node/$(oc get nodes -l node-role.kubernetes.io/master --no-headers | head -1 | awk '{print $1}') -- chroot /host /usr/local/bin/cluster-backup.sh ${BACKUP_DIR}

# Compress backup
tar -czf ${BACKUP_DIR}.tar.gz -C ${BACKUP_DIR} .

# Upload to IBM Cloud Object Storage
ibmcloud cos object-put \
    --bucket ${BUCKET_NAME} \
    --key "etcd-backup-${BACKUP_DATE}.tar.gz" \
    --body "${BACKUP_DIR}.tar.gz"

# Cleanup local files older than 7 days
find /var/lib/etcd-backup -type d -mtime +7 -exec rm -rf {} \;

echo "Backup completed: etcd-backup-${BACKUP_DATE}.tar.gz"
```

#### 2. Application Data Backup
```yaml
# Velero backup schedule
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
  namespace: velero
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  template:
    includedNamespaces:
    - production
    - staging
    excludedResources:
    - events
    - events.events.k8s.io
    storageLocation: default
    ttl: 720h  # 30 days
    snapshotVolumes: true
```

#### 3. Configuration Backup
```bash
#!/bin/bash
# Backup cluster configuration

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
CONFIG_BACKUP_DIR="/tmp/openshift-config-${BACKUP_DATE}"

mkdir -p ${CONFIG_BACKUP_DIR}

# Backup cluster operators
oc get co -o yaml > ${CONFIG_BACKUP_DIR}/cluster-operators.yaml

# Backup cluster configuration
oc get clusterversion -o yaml > ${CONFIG_BACKUP_DIR}/cluster-version.yaml
oc get oauth cluster -o yaml > ${CONFIG_BACKUP_DIR}/oauth.yaml
oc get network.operator cluster -o yaml > ${CONFIG_BACKUP_DIR}/network-operator.yaml

# Backup custom resources
oc get crd -o yaml > ${CONFIG_BACKUP_DIR}/custom-resources.yaml

# Create archive and upload to storage
tar -czf ${CONFIG_BACKUP_DIR}.tar.gz -C /tmp openshift-config-${BACKUP_DATE}
ibmcloud cos object-put --bucket openshift-config-backups --key "config-backup-${BACKUP_DATE}.tar.gz" --body "${CONFIG_BACKUP_DIR}.tar.gz"

# Cleanup
rm -rf ${CONFIG_BACKUP_DIR} ${CONFIG_BACKUP_DIR}.tar.gz

echo "Configuration backup completed: config-backup-${BACKUP_DATE}.tar.gz"
```

### Recovery Procedures

#### 1. etcd Recovery
```bash
#!/bin/bash
# etcd cluster recovery procedure

BACKUP_FILE=$1
if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file>"
    exit 1
fi

echo "Starting etcd recovery from: $BACKUP_FILE"

# Download backup from IBM Cloud Object Storage
ibmcloud cos object-get --bucket openshift-etcd-backups --key $BACKUP_FILE --output /tmp/etcd-restore.tar.gz

# Extract backup
mkdir -p /tmp/etcd-restore
tar -xzf /tmp/etcd-restore.tar.gz -C /tmp/etcd-restore

# Follow Red Hat documentation for etcd restoration
echo "Backup downloaded and extracted to /tmp/etcd-restore"
echo "Follow Red Hat OpenShift documentation for etcd cluster restore procedures"
echo "https://docs.openshift.com/container-platform/4.x/backup_and_restore/control_plane_backup_and_restore/disaster_recovery/scenario-2-restoring-cluster-state.html"
```

#### 2. Application Recovery
```bash
#!/bin/bash
# Application data recovery using Velero

BACKUP_NAME=$1
TARGET_NAMESPACE=${2:-"production"}

if [ -z "$BACKUP_NAME" ]; then
    echo "Available backups:"
    oc get backups -n velero
    exit 1
fi

echo "Starting restoration of backup: $BACKUP_NAME"

# Create restore
oc create -f - <<EOF
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-$(date +%s)
  namespace: velero
spec:
  backupName: $BACKUP_NAME
  includedNamespaces:
  - $TARGET_NAMESPACE
  restorePVs: true
EOF

# Monitor restore progress
watch "oc get restore -n velero --sort-by=.metadata.creationTimestamp"
```

## Change Management

### Change Control Process

#### 1. Change Request Template
```text
CHANGE REQUEST FORM

Change ID: CHG-YYYY-MMDD-###
Requested By: [Name]
Date: [YYYY-MM-DD]
Priority: [Low/Medium/High/Emergency]
Category: [Infrastructure/Application/Security/Process]

CHANGE DESCRIPTION:
[Detailed description of the change]

BUSINESS JUSTIFICATION:
[Why this change is needed]

RISK ASSESSMENT:
Risk Level: [Low/Medium/High]
Potential Impact: [Description of potential impact]
Mitigation Plan: [How risks will be mitigated]

IMPLEMENTATION PLAN:
[Step-by-step implementation plan]

ROLLBACK PLAN:
[Detailed rollback procedure if change fails]

TESTING PLAN:
[How the change will be tested]

APPROVALS:
Technical Lead: [Name] - [Date]
Security Team: [Name] - [Date] (if security-related)
Change Manager: [Name] - [Date]
```

#### 2. Pre-Change Checklist
```bash
#!/bin/bash
# Pre-change verification checklist

echo "=== Pre-Change Verification Checklist ==="

# Verify cluster health
echo "1. Cluster Health Check:"
oc get co --no-headers | awk '$3!="True" || $4!="False" || $5!="False" {print "FAIL: " $0; exit 1}' && echo "PASS: All cluster operators healthy"

# Verify backup completion
echo "2. Backup Verification:"
if [ -f "/var/lib/etcd-backup/$(date +%Y%m%d)/backup.tar.gz" ]; then
    echo "PASS: Recent etcd backup exists"
else
    echo "FAIL: No recent etcd backup found"
    exit 1
fi

# Check maintenance window
echo "3. Maintenance Window Check:"
CURRENT_HOUR=$(date +%H)
if [ $CURRENT_HOUR -ge 2 ] && [ $CURRENT_HOUR -le 6 ]; then
    echo "PASS: Within maintenance window (02:00-06:00 UTC)"
else
    echo "WARN: Outside standard maintenance window"
fi

# Verify resource availability
echo "4. Resource Availability:"
kubectl top nodes | awk 'NR>1 {cpu=substr($3,1,length($3)-1); mem=substr($5,1,length($5)-1); if(cpu>80 || mem>80) print "WARN: High utilization on " $1}'

echo "=== Pre-Change Verification Complete ==="
```

#### 3. Post-Change Validation
```bash
#!/bin/bash
# Post-change validation

echo "=== Post-Change Validation ==="

# Wait for cluster to stabilize
echo "Waiting for cluster stabilization..."
sleep 300

# Verify cluster operators
echo "1. Cluster Operators Status:"
oc get co --no-headers | awk '$3!="True" || $4!="False" || $5!="False" {print "FAIL: " $0; failed=1} END {if(!failed) print "PASS: All operators healthy"}'

# Verify node status
echo "2. Node Status:"
oc get nodes --no-headers | awk '$2!="Ready" {print "FAIL: " $0; failed=1} END {if(!failed) print "PASS: All nodes ready"}'

# Test application connectivity
echo "3. Application Connectivity Test:"
# Add specific tests for your applications
curl -k https://api.$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}')/healthz && echo "PASS: API server accessible"

# Verify monitoring and logging
echo "4. Monitoring and Logging:"
oc get pods -n openshift-monitoring | grep -v Running | grep -v Completed && echo "WARN: Some monitoring pods not running" || echo "PASS: Monitoring pods healthy"

echo "=== Post-Change Validation Complete ==="
```

## Automation and Scripts

### Daily Automation

#### 1. Comprehensive Health Check Script
```bash
#!/bin/bash
# Comprehensive daily health check with reporting

LOG_FILE="/var/log/openshift-health-$(date +%Y%m%d).log"
REPORT_FILE="/tmp/openshift-health-report-$(date +%Y%m%d).html"
ALERT_THRESHOLD=3

exec > >(tee -a ${LOG_FILE})
exec 2>&1

echo "Starting comprehensive health check at $(date)"

# Initialize counters
CRITICAL_ISSUES=0
WARNING_ISSUES=0

# Function to check and report issues
check_and_report() {
    local check_name="$1"
    local command="$2"
    local expected_result="$3"
    local severity="$4"  # CRITICAL or WARNING
    
    echo "Checking: $check_name"
    result=$(eval $command)
    
    if [ "$result" != "$expected_result" ]; then
        echo "[$severity] $check_name: $result"
        if [ "$severity" = "CRITICAL" ]; then
            ((CRITICAL_ISSUES++))
        else
            ((WARNING_ISSUES++))
        fi
    else
        echo "[OK] $check_name"
    fi
}

# Run health checks
check_and_report "Cluster Operators" "oc get co --no-headers | grep -v 'True.*False.*False' | wc -l" "0" "CRITICAL"
check_and_report "Node Status" "oc get nodes --no-headers | grep -v Ready | wc -l" "0" "CRITICAL"
check_and_report "Failed Pods" "oc get pods -A --no-headers | grep -E '(Error|CrashLoopBackOff|ImagePullBackOff)' | wc -l" "0" "WARNING"

# Generate HTML report
cat > ${REPORT_FILE} << EOF
<html>
<head><title>OpenShift Health Report - $(date +%Y-%m-%d)</title></head>
<body>
<h1>OpenShift Health Report</h1>
<p>Generated: $(date)</p>
<h2>Summary</h2>
<p style="color: red;">Critical Issues: ${CRITICAL_ISSUES}</p>
<p style="color: orange;">Warning Issues: ${WARNING_ISSUES}</p>
<h2>Detailed Results</h2>
<pre>$(cat ${LOG_FILE})</pre>
</body>
</html>
EOF

# Send alerts if issues found
if [ $CRITICAL_ISSUES -ge $ALERT_THRESHOLD ]; then
    echo "ALERT: ${CRITICAL_ISSUES} critical issues found!"
    # Send to monitoring system or email
fi

echo "Health check completed at $(date)"
echo "Report generated: ${REPORT_FILE}"
```

#### 2. Automated Capacity Planning
```bash
#!/bin/bash
# Automated capacity planning and forecasting

METRICS_FILE="/var/log/openshift-capacity-$(date +%Y%m%d).json"

# Collect current metrics
{
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"cluster_info\": {"
    echo "    \"nodes\": $(oc get nodes --no-headers | wc -l),"
    echo "    \"pods\": $(oc get pods -A --no-headers | wc -l),"
    echo "    \"namespaces\": $(oc get namespaces --no-headers | wc -l)"
    echo "  },"
    echo "  \"resource_utilization\": {"
    
    # Node resource utilization
    echo "    \"nodes\": ["
    oc get nodes --no-headers | while read node status roles age version; do
        cpu_usage=$(kubectl top node $node --no-headers | awk '{print $2}' | sed 's/m//')
        mem_usage=$(kubectl top node $node --no-headers | awk '{print $4}' | sed 's/Mi//')
        echo "      {\"name\": \"$node\", \"cpu_usage_m\": $cpu_usage, \"memory_usage_mi\": $mem_usage},"
    done | sed '$ s/,$//'
    echo "    ],"
    
    # Storage utilization
    echo "    \"storage\": ["
    oc get pv -o json | jq -r '.items[] | @json'
    echo "    ]"
    echo "  }"
    echo "}"
} > ${METRICS_FILE}

# Generate capacity forecast (simple linear projection)
python3 << EOF
import json
import datetime
from datetime import timedelta

with open('${METRICS_FILE}', 'r') as f:
    data = json.load(f)

# Simple capacity forecasting logic
nodes = data['cluster_info']['nodes']
pods = data['cluster_info']['pods']
pods_per_node = pods / nodes if nodes > 0 else 0

# Forecast for next 30 days (assuming 10% monthly growth)
forecast_date = datetime.datetime.now() + timedelta(days=30)
forecast_pods = pods * 1.1
forecast_nodes_needed = int(forecast_pods / 50)  # Assuming 50 pods per node capacity

print(f"Current: {nodes} nodes, {pods} pods")
print(f"Forecast ({forecast_date.strftime('%Y-%m-%d')}): {forecast_nodes_needed} nodes needed, {int(forecast_pods)} pods")

if forecast_nodes_needed > nodes:
    print(f"RECOMMENDATION: Plan to add {forecast_nodes_needed - nodes} nodes")
EOF
```

#### 3. Security Automation
```bash
#!/bin/bash
# Automated security checks and hardening

SECURITY_LOG="/var/log/openshift-security-$(date +%Y%m%d).log"

# Function to log security findings
log_security() {
    echo "$(date -Iseconds) [$1] $2" >> ${SECURITY_LOG}
    echo "[$1] $2"
}

# Check for privileged containers
PRIVILEGED_PODS=$(oc get pods -A -o json | jq -r '.items[] | select(.spec.containers[]?.securityContext.privileged==true) | "\(.metadata.namespace)/\(.metadata.name)"')
if [ -n "$PRIVILEGED_PODS" ]; then
    log_security "WARNING" "Privileged containers found: $PRIVILEGED_PODS"
fi

# Check for containers running as root
ROOT_CONTAINERS=$(oc get pods -A -o json | jq -r '.items[] | select(.spec.containers[]?.securityContext.runAsUser==0 or (.spec.containers[]?.securityContext.runAsUser==null and .spec.securityContext.runAsUser==null)) | "\(.metadata.namespace)/\(.metadata.name)"')
if [ -n "$ROOT_CONTAINERS" ]; then
    log_security "WARNING" "Containers running as root: $ROOT_CONTAINERS"
fi

# Check for pods without resource limits
NO_LIMITS=$(oc get pods -A -o json | jq -r '.items[] | select(.spec.containers[] | .resources.limits==null) | "\(.metadata.namespace)/\(.metadata.name)"')
if [ -n "$NO_LIMITS" ]; then
    log_security "INFO" "Pods without resource limits: $NO_LIMITS"
fi

# Check for expired certificates
CERT_CHECK=$(oc get secrets -A -o json | jq -r '.items[] | select(.type=="kubernetes.io/tls") | select(.data."tls.crt") | "\(.metadata.namespace)/\(.metadata.name)"' | head -10)
log_security "INFO" "Certificate check completed for secrets"

# Generate security report
log_security "INFO" "Security scan completed. Check ${SECURITY_LOG} for details."
```

### Weekly Maintenance Automation

#### 1. Automated Cleanup Tasks
```bash
#!/bin/bash
# Weekly cleanup automation

echo "Starting weekly maintenance tasks - $(date)"

# Clean up completed pods
echo "Cleaning up completed pods..."
oc get pods -A --field-selector=status.phase=Succeeded | grep -v NAME | awk '{print $2 " -n " $1}' | xargs -r -L1 oc delete pod

# Clean up failed pods older than 7 days
echo "Cleaning up old failed pods..."
oc get pods -A --field-selector=status.phase=Failed -o json | jq -r '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - 604800)) | "\(.metadata.name) -n \(.metadata.namespace)"' | xargs -r -L1 oc delete pod

# Clean up unused PVCs (be careful with this!)
echo "Identifying unused PVCs..."
oc get pvc -A -o json | jq -r '.items[] | select(.status.phase=="Bound") | select(.spec.volumeName as $pv | [.metadata.namespace + "/" + .metadata.name] | length == 0) | "\(.metadata.namespace)/\(.metadata.name)"'

# Clean up old image tags
echo "Cleaning up old image tags..."
oc adm prune images --confirm --registry-url=$(oc get route -n openshift-image-registry | grep image-registry | awk '{print $2}')

# Update node labels for maintenance
echo "Updating maintenance labels..."
oc label nodes -l node-role.kubernetes.io/worker maintenance.last-updated=$(date +%Y%m%d) --overwrite

echo "Weekly maintenance tasks completed - $(date)"
```

### Emergency Response Automation

#### 1. Automated Incident Response
```bash
#!/bin/bash
# Automated incident response script

INCIDENT_ID="INC-$(date +%Y%m%d-%H%M%S)"
INCIDENT_LOG="/var/log/incident-${INCIDENT_ID}.log"

# Function to log with timestamp
log_incident() {
    echo "$(date -Iseconds) $1" | tee -a ${INCIDENT_LOG}
}

log_incident "Starting automated incident response: ${INCIDENT_ID}"

# Collect immediate diagnostic information
log_incident "Collecting cluster state information..."
oc get nodes -o wide > /tmp/incident-nodes-${INCIDENT_ID}.txt
oc get co > /tmp/incident-operators-${INCIDENT_ID}.txt
oc get pods -A | grep -v Running > /tmp/incident-pods-${INCIDENT_ID}.txt

# Check for common issues and attempt automated remediation
log_incident "Checking for common issues..."

# Restart failed pods
FAILED_PODS=$(oc get pods -A --no-headers | grep -E '(Error|CrashLoopBackOff|ImagePullBackOff)')
if [ -n "$FAILED_PODS" ]; then
    log_incident "Found failed pods, attempting restart..."
    echo "$FAILED_PODS" | awk '{print $2 " -n " $1}' | while read pod_name namespace; do
        oc delete pod $pod_name -n $namespace
        log_incident "Restarted pod: $namespace/$pod_name"
    done
fi

# Check disk space and clean up if needed
log_incident "Checking node disk space..."
oc get nodes -o json | jq -r '.items[].metadata.name' | while read node; do
    disk_usage=$(oc debug node/$node -- df /host/var/lib/containers | grep -v Filesystem | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 85 ]; then
        log_incident "High disk usage on $node ($disk_usage%), attempting cleanup..."
        oc debug node/$node -- chroot /host docker system prune -f
    fi
done

# Generate incident report
log_incident "Generating incident report..."
cat > /tmp/incident-report-${INCIDENT_ID}.html << EOF
<html>
<head><title>Incident Report: ${INCIDENT_ID}</title></head>
<body>
<h1>Automated Incident Response Report</h1>
<h2>Incident ID: ${INCIDENT_ID}</h2>
<h2>Timestamp: $(date)</h2>
<h2>Actions Taken</h2>
<pre>$(cat ${INCIDENT_LOG})</pre>
<h2>System State</h2>
<h3>Nodes</h3>
<pre>$(cat /tmp/incident-nodes-${INCIDENT_ID}.txt)</pre>
<h3>Cluster Operators</h3>
<pre>$(cat /tmp/incident-operators-${INCIDENT_ID}.txt)</pre>
<h3>Failed Pods</h3>
<pre>$(cat /tmp/incident-pods-${INCIDENT_ID}.txt)</pre>
</body>
</html>
EOF

log_incident "Incident response completed. Report: /tmp/incident-report-${INCIDENT_ID}.html"

# Trigger alert to operations team
# curl -X POST -H 'Content-type: application/json' \
#     --data '{"text":"Automated incident response completed for '${INCIDENT_ID}'. Check logs for details."}' \
#     $SLACK_WEBHOOK_URL
```

This comprehensive operations runbook provides detailed procedures for managing an IBM OpenShift Container Platform deployment on a day-to-day basis. The included scripts and procedures should be customized based on your specific environment and requirements.