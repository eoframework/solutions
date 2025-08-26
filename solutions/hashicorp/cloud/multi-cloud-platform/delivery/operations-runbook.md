# Operations Runbook: HashiCorp Multi-Cloud Infrastructure Management Platform

## Overview

This operations runbook provides comprehensive procedures for operating and maintaining the HashiCorp Multi-Cloud Infrastructure Management Platform. It covers day-to-day operations, maintenance procedures, troubleshooting, and emergency response protocols.

## Table of Contents
1. [System Architecture Overview](#system-architecture-overview)
2. [Daily Operations](#daily-operations)
3. [Monitoring and Alerting](#monitoring-and-alerting)
4. [Maintenance Procedures](#maintenance-procedures)
5. [Backup and Recovery](#backup-and-recovery)
6. [Troubleshooting](#troubleshooting)
7. [Emergency Procedures](#emergency-procedures)
8. [Performance Optimization](#performance-optimization)
9. [Security Operations](#security-operations)
10. [Change Management](#change-management)

## System Architecture Overview

### Component Layout
```
Multi-Cloud Architecture
├── AWS Region (us-west-2) - Primary
│   ├── Consul Cluster (5 nodes)
│   ├── Vault Cluster (3 nodes)
│   ├── Nomad Cluster (5 servers + clients)
│   └── Boundary Workers (3 nodes)
├── Azure Region (West US 2) - Secondary
│   ├── Consul Cluster (5 nodes)
│   ├── Vault Cluster (3 nodes)
│   ├── Nomad Cluster (5 servers + clients)
│   └── Boundary Workers (3 nodes)
├── GCP Region (us-west1) - Secondary
│   ├── Consul Cluster (5 nodes)
│   ├── Vault Cluster (3 nodes)
│   ├── Nomad Cluster (5 servers + clients)
│   └── Boundary Workers (3 nodes)
└── Management Layer
    ├── Monitoring (Prometheus/Grafana)
    ├── Log Aggregation (ELK Stack)
    ├── Backup Systems
    └── Boundary Controllers
```

### Service Endpoints
| Service | Primary URL | Health Check |
|---------|-------------|--------------|
| Consul | https://consul.hashicorp.yourdomain.com:8500 | `/v1/status/leader` |
| Vault | https://vault.hashicorp.yourdomain.com:8200 | `/v1/sys/health` |
| Nomad | https://nomad.hashicorp.yourdomain.com:4646 | `/v1/status/leader` |
| Boundary | https://boundary.hashicorp.yourdomain.com:9200 | `/v1/scopes` |
| Grafana | https://grafana.hashicorp.yourdomain.com | `/api/health` |

## Daily Operations

### Morning Health Check Procedure

#### 1. Platform Status Verification
```bash
#!/bin/bash
# Daily health check script

echo "=== HashiCorp Multi-Cloud Platform Health Check ==="
echo "Date: $(date)"
echo

# Check Consul health
echo "Checking Consul clusters..."
curl -s https://consul.hashicorp.yourdomain.com:8500/v1/status/leader
curl -s https://consul-azure.hashicorp.yourdomain.com:8500/v1/status/leader
curl -s https://consul-gcp.hashicorp.yourdomain.com:8500/v1/status/leader

# Check Vault health
echo "Checking Vault clusters..."
curl -s https://vault.hashicorp.yourdomain.com:8200/v1/sys/health | jq '.sealed'
curl -s https://vault-azure.hashicorp.yourdomain.com:8200/v1/sys/health | jq '.sealed'
curl -s https://vault-gcp.hashicorp.yourdomain.com:8200/v1/sys/health | jq '.sealed'

# Check Nomad health
echo "Checking Nomad clusters..."
curl -s https://nomad.hashicorp.yourdomain.com:4646/v1/status/leader
curl -s https://nomad-azure.hashicorp.yourdomain.com:4646/v1/status/leader
curl -s https://nomad-gcp.hashicorp.yourdomain.com:4646/v1/status/leader

# Check cross-cloud connectivity
echo "Testing cross-cloud connectivity..."
ping -c 3 10.2.1.10  # AWS to Azure
ping -c 3 10.3.1.10  # AWS to GCP
```

#### 2. Resource Utilization Check
```bash
# Check resource utilization across clouds
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Azure resource check
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-hashicorp/solutions/Microsoft.Compute/virtualMachines/consul-01 \
  --metric "Percentage CPU" \
  --interval PT5M

# GCP resource check
gcloud monitoring read \
  --filter='resource.type="gce_instance" AND metric.type="compute.googleapis.com/instance/cpu/utilization"' \
  --interval=300s
```

#### 3. Backup Verification
```bash
# Verify recent backups
aws s3 ls s3://hashicorp-backups/consul/ --recursive | tail -5
aws s3 ls s3://hashicorp-backups/vault/ --recursive | tail -5
aws s3 ls s3://hashicorp-backups/nomad/ --recursive | tail -5
```

### End-of-Day Operations

#### Security Review
- Review failed authentication attempts
- Check for unusual access patterns
- Verify certificate expiration dates
- Review audit logs for anomalies

#### Capacity Planning
- Review resource utilization trends
- Check storage capacity across clouds
- Monitor network bandwidth usage
- Plan for upcoming capacity needs

## Monitoring and Alerting

### Key Metrics Dashboard

#### System Health Metrics
| Metric | Normal Range | Warning Threshold | Critical Threshold |
|--------|--------------|-------------------|-------------------|
| Consul CPU Usage | < 60% | > 70% | > 85% |
| Vault Memory Usage | < 70% | > 80% | > 90% |
| Nomad API Response Time | < 100ms | > 500ms | > 1000ms |
| Cross-Cloud Latency | < 50ms | > 100ms | > 200ms |
| Disk Usage | < 70% | > 80% | > 90% |

#### Business Metrics
| Metric | Normal Range | Warning Threshold | Critical Threshold |
|--------|--------------|-------------------|-------------------|
| Application Deployments/Hour | 10-50 | < 5 or > 100 | < 1 or > 200 |
| Infrastructure Provision Time | < 5 min | > 10 min | > 20 min |
| Policy Compliance Rate | 100% | < 95% | < 90% |
| Cross-Cloud Sync Time | < 30s | > 60s | > 120s |

### Alert Escalation Matrix

#### Severity Levels
| Severity | Response Time | Escalation | Notification Method |
|----------|---------------|------------|-------------------|
| P0 - Critical | 15 minutes | Immediate | Phone + SMS + Slack |
| P1 - High | 1 hour | 30 minutes | SMS + Slack |
| P2 - Medium | 4 hours | 2 hours | Slack + Email |
| P3 - Low | Next business day | 24 hours | Email |

#### On-Call Rotation
```
Week 1: Primary Engineer (John Doe)
Week 2: Secondary Engineer (Jane Smith)
Week 3: Platform Engineer (Bob Johnson)
Week 4: Senior Engineer (Alice Brown)
```

### Alert Response Procedures

#### P0 - Platform Down
1. **Immediate Actions (0-5 minutes)**
   - Acknowledge alert in PagerDuty
   - Open incident bridge/war room
   - Notify management via escalation path
   - Begin initial assessment

2. **Assessment Phase (5-15 minutes)**
   ```bash
   # Check overall platform status
   curl -f https://consul.hashicorp.yourdomain.com:8500/v1/status/leader
   curl -f https://vault.hashicorp.yourdomain.com:8200/v1/sys/health
   curl -f https://nomad.hashicorp.yourdomain.com:4646/v1/status/leader
   
   # Check infrastructure status
   aws ec2 describe-instances --filters "Name=tag:Project,Values=hashicorp-multicloud"
   az vm list --resource-group rg-hashicorp-multicloud
   gcloud compute instances list --filter="labels.project:hashicorp-multicloud"
   ```

3. **Resolution Actions**
   - Implement immediate fixes
   - Activate disaster recovery if needed
   - Communicate status updates
   - Document incident timeline

#### P1 - Service Degradation
1. **Response Actions (0-30 minutes)**
   - Identify affected components
   - Check recent changes
   - Review monitoring dashboards
   - Implement temporary workarounds

2. **Investigation Steps**
   ```bash
   # Check service logs
   kubectl logs -n consul consul-server-0
   vault operator step-down -address=https://vault.hashicorp.yourdomain.com:8200
   nomad monitor -address=https://nomad.hashicorp.yourdomain.com:4646
   
   # Check resource constraints
   kubectl top nodes
   kubectl top pods -A
   ```

## Maintenance Procedures

### Scheduled Maintenance Windows
- **Primary Window**: Saturdays 2:00 AM - 6:00 AM UTC
- **Emergency Window**: Weekdays 10:00 PM - 2:00 AM UTC
- **Quarterly Maintenance**: First Saturday of each quarter (extended window)

### HashiCorp Product Updates

#### Consul Update Procedure
```bash
# 1. Pre-update checks
consul operator raft list-peers -http-addr=https://consul.hashicorp.yourdomain.com:8500
consul members -http-addr=https://consul.hashicorp.yourdomain.com:8500

# 2. Take snapshot
consul snapshot save pre-upgrade-$(date +%Y%m%d).snap \
  -http-addr=https://consul.hashicorp.yourdomain.com:8500

# 3. Update secondary datacenters first
# Update Azure datacenter
kubectl set image deployment/consul-server consul=consul:1.17.0 -n consul-azure
kubectl rollout status deployment/consul-server -n consul-azure

# Update GCP datacenter  
kubectl set image deployment/consul-server consul=consul:1.17.0 -n consul-gcp
kubectl rollout status deployment/consul-server -n consul-gcp

# 4. Update primary datacenter (AWS)
kubectl set image deployment/consul-server consul=consul:1.17.0 -n consul-aws
kubectl rollout status deployment/consul-server -n consul-aws

# 5. Post-update verification
consul members -http-addr=https://consul.hashicorp.yourdomain.com:8500
consul operator raft list-peers -http-addr=https://consul.hashicorp.yourdomain.com:8500
```

#### Vault Update Procedure
```bash
# 1. Pre-update checks
vault status -address=https://vault.hashicorp.yourdomain.com:8200
vault operator raft list-peers -address=https://vault.hashicorp.yourdomain.com:8200

# 2. Take snapshot
vault operator raft snapshot save pre-upgrade-$(date +%Y%m%d).snap \
  -address=https://vault.hashicorp.yourdomain.com:8200

# 3. Update standby nodes first
kubectl set image deployment/vault-standby vault=vault:1.15.0 -n vault

# 4. Step down active node
vault operator step-down -address=https://vault.hashicorp.yourdomain.com:8200

# 5. Update active node
kubectl set image deployment/vault-active vault=vault:1.15.0 -n vault

# 6. Verify functionality
vault status -address=https://vault.hashicorp.yourdomain.com:8200
vault auth -address=https://vault.hashicorp.yourdomain.com:8200
```

#### Nomad Update Procedure
```bash
# 1. Pre-update checks
nomad server members -address=https://nomad.hashicorp.yourdomain.com:4646
nomad node status -address=https://nomad.hashicorp.yourdomain.com:4646

# 2. Update clients first (rolling update)
nomad node drain -enable -yes <node-id> -address=https://nomad.hashicorp.yourdomain.com:4646

# Wait for jobs to reschedule, then update client
kubectl set image deployment/nomad-client nomad=nomad:1.7.0 -n nomad

# Re-enable client
nomad node drain -disable <node-id> -address=https://nomad.hashicorp.yourdomain.com:4646

# 3. Update servers (one at a time)
# Transfer leadership first
nomad operator raft transfer-leadership -address=https://nomad.hashicorp.yourdomain.com:4646

# Update non-leader servers first
kubectl set image deployment/nomad-server nomad=nomad:1.7.0 -n nomad

# 4. Post-update verification
nomad server members -address=https://nomad.hashicorp.yourdomain.com:4646
nomad job status -address=https://nomad.hashicorp.yourdomain.com:4646
```

### Infrastructure Maintenance

#### Certificate Renewal
```bash
# Check certificate expiration
echo | openssl s_client -servername consul.hashicorp.yourdomain.com -connect consul.hashicorp.yourdomain.com:8500 2>/dev/null | openssl x509 -noout -dates

# Renew Let's Encrypt certificates
certbot renew --quiet

# Update certificates in Kubernetes
kubectl create secret tls consul-tls --cert=consul.crt --key=consul.key -n consul --dry-run=client -o yaml | kubectl apply -f -
```

#### Database Maintenance
```bash
# PostgreSQL maintenance for Boundary
kubectl exec -it postgres-0 -n boundary -- psql -U boundary -c "VACUUM ANALYZE;"
kubectl exec -it postgres-0 -n boundary -- psql -U boundary -c "REINDEX DATABASE boundary;"

# Check database performance
kubectl exec -it postgres-0 -n boundary -- psql -U boundary -c "SELECT * FROM pg_stat_activity;"
```

## Backup and Recovery

### Automated Backup Procedures

#### Daily Backup Script
```bash
#!/bin/bash
# Daily backup script for HashiCorp products

DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_BASE="/opt/backups"
S3_BUCKET="hashicorp-backups"

# Consul snapshots
echo "Taking Consul snapshots..."
for dc in aws azure gcp; do
    consul snapshot save ${BACKUP_BASE}/consul/consul-${dc}-${DATE}.snap \
      -datacenter=${dc} -http-addr=https://consul.hashicorp.yourdomain.com:8500
    aws s3 cp ${BACKUP_BASE}/consul/consul-${dc}-${DATE}.snap s3://${S3_BUCKET}/consul/
done

# Vault snapshots
echo "Taking Vault snapshots..."
for cluster in primary azure gcp; do
    vault operator raft snapshot save ${BACKUP_BASE}/vault/vault-${cluster}-${DATE}.snap \
      -address=https://vault-${cluster}.hashicorp.yourdomain.com:8200
    aws s3 cp ${BACKUP_BASE}/vault/vault-${cluster}-${DATE}.snap s3://${S3_BUCKET}/vault/
done

# Nomad state backup
echo "Backing up Nomad state..."
nomad operator snapshot save ${BACKUP_BASE}/nomad/nomad-${DATE}.snap \
  -address=https://nomad.hashicorp.yourdomain.com:4646
aws s3 cp ${BACKUP_BASE}/nomad/nomad-${DATE}.snap s3://${S3_BUCKET}/nomad/

# Boundary database backup
echo "Backing up Boundary database..."
kubectl exec -it postgres-0 -n boundary -- pg_dump boundary > ${BACKUP_BASE}/boundary/boundary-${DATE}.sql
aws s3 cp ${BACKUP_BASE}/boundary/boundary-${DATE}.sql s3://${S3_BUCKET}/boundary/

# Clean up local files older than 7 days
find ${BACKUP_BASE} -type f -mtime +7 -delete

echo "Backup completed at $(date)"
```

### Disaster Recovery Procedures

#### Complete Platform Recovery
```bash
#!/bin/bash
# Disaster recovery script

echo "=== DISASTER RECOVERY PROCEDURE ==="
echo "Starting platform recovery at $(date)"

# 1. Verify infrastructure is available
terraform plan -var-file="terraform.tfvars"
terraform apply -auto-approve -var-file="terraform.tfvars"

# 2. Restore Vault first (required for other services)
echo "Restoring Vault cluster..."
VAULT_BACKUP="vault-primary-latest.snap"
aws s3 cp s3://hashicorp-backups/vault/${VAULT_BACKUP} /tmp/

# Initialize new Vault cluster
vault operator init -address=https://vault.hashicorp.yourdomain.com:8200 > /tmp/vault-init.txt

# Unseal and restore
vault operator unseal -address=https://vault.hashicorp.yourdomain.com:8200 $(grep "Unseal Key 1" /tmp/vault-init.txt | cut -d' ' -f4)
vault operator unseal -address=https://vault.hashicorp.yourdomain.com:8200 $(grep "Unseal Key 2" /tmp/vault-init.txt | cut -d' ' -f4)
vault operator unseal -address=https://vault.hashicorp.yourdomain.com:8200 $(grep "Unseal Key 3" /tmp/vault-init.txt | cut -d' ' -f4)

# Restore from snapshot
vault operator raft snapshot restore /tmp/${VAULT_BACKUP} -address=https://vault.hashicorp.yourdomain.com:8200

# 3. Restore Consul clusters
echo "Restoring Consul clusters..."
for dc in aws azure gcp; do
    CONSUL_BACKUP="consul-${dc}-latest.snap"
    aws s3 cp s3://hashicorp-backups/consul/${CONSUL_BACKUP} /tmp/
    consul snapshot restore /tmp/${CONSUL_BACKUP} -http-addr=https://consul-${dc}.hashicorp.yourdomain.com:8500
done

# 4. Restore Nomad cluster
echo "Restoring Nomad cluster..."
NOMAD_BACKUP="nomad-latest.snap"
aws s3 cp s3://hashicorp-backups/nomad/${NOMAD_BACKUP} /tmp/
nomad operator snapshot restore /tmp/${NOMAD_BACKUP} -address=https://nomad.hashicorp.yourdomain.com:4646

# 5. Restore Boundary
echo "Restoring Boundary database..."
BOUNDARY_BACKUP="boundary-latest.sql"
aws s3 cp s3://hashicorp-backups/boundary/${BOUNDARY_BACKUP} /tmp/
kubectl exec -i postgres-0 -n boundary -- psql boundary < /tmp/${BOUNDARY_BACKUP}

# 6. Verify all services
echo "Verifying service health..."
./health-check.sh

echo "Disaster recovery completed at $(date)"
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Consul Cluster Issues

**Symptom**: Consul UI inaccessible or returning errors
```bash
# Check Consul server status
consul members -http-addr=https://consul.hashicorp.yourdomain.com:8500

# Check Raft peers
consul operator raft list-peers -http-addr=https://consul.hashicorp.yourdomain.com:8500

# Check logs
kubectl logs consul-server-0 -n consul
```

**Solutions**:
- If quorum is lost: Restore from snapshot
- If single node failed: Replace node and rejoin cluster
- If network partition: Wait for partition to heal or manually intervene

#### 2. Vault Sealed State

**Symptom**: Vault returns 503 Service Unavailable
```bash
# Check seal status
vault status -address=https://vault.hashicorp.yourdomain.com:8200

# If sealed, unseal with keys
vault operator unseal -address=https://vault.hashicorp.yourdomain.com:8200 <unseal-key>
```

#### 3. Cross-Cloud Connectivity Issues

**Symptom**: Services in different clouds cannot communicate
```bash
# Check VPN tunnel status
aws ec2 describe-vpn-connections --filters "Name=state,Values=available"

# Test connectivity
ping 10.2.1.10  # Test Azure connectivity from AWS
ping 10.3.1.10  # Test GCP connectivity from AWS

# Check route tables
aws ec2 describe-route-tables --filters "Name=tag:Project,Values=hashicorp-multicloud"
```

**Solutions**:
- Restart VPN tunnels if down
- Check security group rules
- Verify route table configurations
- Test DNS resolution

#### 4. Performance Issues

**Symptom**: High response times or timeouts
```bash
# Check resource utilization
kubectl top nodes
kubectl top pods -A

# Check database performance
kubectl exec -it postgres-0 -n boundary -- psql -U boundary -c "SELECT * FROM pg_stat_activity WHERE state = 'active';"

# Check network latency
ping -c 10 consul.hashicorp.yourdomain.com
```

### Log Analysis

#### Centralized Log Collection
```bash
# View aggregated logs in Elasticsearch
curl -X GET "elasticsearch.hashicorp.yourdomain.com:9200/_search?q=level:ERROR&pretty"

# Query specific service logs
curl -X GET "elasticsearch.hashicorp.yourdomain.com:9200/consul-*/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        {"range": {"@timestamp": {"gte": "now-1h"}}},
        {"match": {"level": "ERROR"}}
      ]
    }
  }
}'
```

#### Common Log Patterns
| Pattern | Meaning | Action Required |
|---------|---------|-----------------|
| `connection refused` | Service unavailable | Check service status |
| `context deadline exceeded` | Timeout issue | Check network/performance |
| `leadership lost` | Cluster failover | Monitor for stability |
| `failed to heartbeat` | Node communication issue | Check network connectivity |

## Emergency Procedures

### Incident Response Plan

#### Severity Classification
- **SEV-0**: Complete platform outage affecting all users
- **SEV-1**: Major functionality impacted, affecting >50% users
- **SEV-2**: Limited functionality impact, affecting <50% users
- **SEV-3**: Minor issues with workarounds available

#### Emergency Contacts
```
Role                    | Primary           | Secondary         | Phone
Platform Team Lead      | John Doe          | Jane Smith        | +1-555-0101
Infrastructure Lead     | Bob Johnson       | Alice Brown       | +1-555-0102
Security Lead          | Charlie Wilson    | Diana Davis       | +1-555-0103
Management Escalation  | Eve Miller        | Frank Anderson    | +1-555-0104
```

### Emergency Response Procedures

#### SEV-0: Complete Outage
1. **Immediate Response (0-15 minutes)**
   - Activate incident command center
   - Notify all stakeholders via emergency channels
   - Begin triage and impact assessment
   - Implement emergency communication plan

2. **Assessment and Containment (15-30 minutes)**
   - Identify root cause
   - Implement immediate containment measures
   - Activate disaster recovery if necessary
   - Provide regular status updates

3. **Resolution and Recovery (30 minutes - 4 hours)**
   - Execute recovery procedures
   - Verify service restoration
   - Conduct post-incident review
   - Document lessons learned

#### Emergency Runbooks

**Emergency Vault Unseal**
```bash
#!/bin/bash
# Emergency Vault unseal procedure

echo "EMERGENCY: Unsealing Vault clusters"

# Unseal primary cluster
for i in {1..3}; do
    read -s -p "Enter unseal key $i: " key
    vault operator unseal -address=https://vault.hashicorp.yourdomain.com:8200 $key
done

# Verify unsealed
vault status -address=https://vault.hashicorp.yourdomain.com:8200
```

**Emergency Consul Recovery**
```bash
#!/bin/bash
# Emergency Consul cluster recovery

echo "EMERGENCY: Recovering Consul cluster"

# Check current cluster state
consul operator raft list-peers -http-addr=https://consul.hashicorp.yourdomain.com:8500

# If quorum lost, restore from snapshot
LATEST_SNAPSHOT=$(aws s3 ls s3://hashicorp-backups/consul/ | grep consul-aws | tail -1 | awk '{print $4}')
aws s3 cp s3://hashicorp-backups/consul/$LATEST_SNAPSHOT /tmp/emergency-restore.snap

# Restore snapshot
consul snapshot restore /tmp/emergency-restore.snap -http-addr=https://consul.hashicorp.yourdomain.com:8500
```

## Performance Optimization

### Performance Monitoring

#### Key Performance Metrics
```bash
# Monitor Consul performance
consul monitor -log-level=INFO -http-addr=https://consul.hashicorp.yourdomain.com:8500

# Check Consul KV performance
time consul kv put test/perf-$(date +%s) "test-value" -http-addr=https://consul.hashicorp.yourdomain.com:8500

# Monitor Vault performance
vault audit list -address=https://vault.hashicorp.yourdomain.com:8200
vault read sys/metrics -address=https://vault.hashicorp.yourdomain.com:8200

# Monitor Nomad performance
nomad operator api /v1/metrics -address=https://nomad.hashicorp.yourdomain.com:4646
```

### Optimization Procedures

#### Database Optimization
```sql
-- PostgreSQL optimization for Boundary
VACUUM ANALYZE;
REINDEX DATABASE boundary;

-- Check database statistics
SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del, n_live_tup, n_dead_tup 
FROM pg_stat_user_tables 
ORDER BY n_dead_tup DESC;

-- Optimize slow queries
EXPLAIN ANALYZE SELECT * FROM sessions WHERE created_time > NOW() - INTERVAL '1 day';
```

#### Network Optimization
```bash
# Optimize cross-cloud network performance
# Tune TCP parameters
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 87380 16777216' >> /etc/sysctl.conf
sysctl -p

# Monitor network latency
mtr --report --report-cycles 10 consul-azure.hashicorp.yourdomain.com
```

## Security Operations

### Security Monitoring

#### Daily Security Checks
```bash
#!/bin/bash
# Daily security audit script

echo "=== Security Audit - $(date) ==="

# Check for failed authentication attempts
echo "Failed authentication attempts in last 24 hours:"
curl -s "https://elasticsearch.hashicorp.yourdomain.com:9200/auth-*/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        {"range": {"@timestamp": {"gte": "now-24h"}}},
        {"match": {"event": "auth_failure"}}
      ]
    }
  },
  "aggs": {
    "by_source_ip": {
      "terms": {"field": "source_ip"}
    }
  }
}'

# Check certificate expiration
echo "Certificate expiration check:"
for service in consul vault nomad boundary; do
    echo "$service: $(echo | openssl s_client -servername $service.hashicorp.yourdomain.com -connect $service.hashicorp.yourdomain.com:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter)"
done

# Check Vault audit logs for anomalies
echo "Vault audit anomalies:"
curl -s "https://elasticsearch.hashicorp.yourdomain.com:9200/vault-audit-*/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        {"range": {"@timestamp": {"gte": "now-24h"}}},
        {"terms": {"response.auth.policies": ["admin", "root"]}}
      ]
    }
  }
}'
```

#### Security Incident Response
1. **Detection**: Automated alerts or manual identification
2. **Containment**: Isolate affected systems
3. **Eradication**: Remove threat and vulnerabilities
4. **Recovery**: Restore services to normal operation
5. **Lessons Learned**: Document and improve procedures

### Compliance Monitoring

#### SOC 2 Compliance Checks
```bash
# Generate compliance report
echo "SOC 2 Compliance Report - $(date)"

# Access control review
echo "1. Access Control Review:"
vault auth list -address=https://vault.hashicorp.yourdomain.com:8200
consul acl policy list -http-addr=https://consul.hashicorp.yourdomain.com:8500

# Audit log verification
echo "2. Audit Log Verification:"
vault audit list -address=https://vault.hashicorp.yourdomain.com:8200

# Encryption verification
echo "3. Encryption Status:"
vault status -address=https://vault.hashicorp.yourdomain.com:8200 | grep "Storage Type"
```

## Change Management

### Change Request Process

#### Change Categories
1. **Emergency Changes**: Security patches, critical fixes (0-4 hours)
2. **Standard Changes**: Pre-approved, low-risk changes (24-48 hours)
3. **Normal Changes**: Require CAB approval (5-7 days)
4. **Major Changes**: Significant impact, extended planning (2-4 weeks)

#### Change Implementation Checklist
- [ ] Change request documented and approved
- [ ] Impact assessment completed
- [ ] Rollback plan prepared
- [ ] Testing completed in staging environment
- [ ] Maintenance window scheduled
- [ ] Stakeholders notified
- [ ] Change implemented
- [ ] Verification testing completed
- [ ] Change closed and documented

### Deployment Procedures

#### Rolling Updates
```bash
# Rolling update procedure for Kubernetes deployments
kubectl set image deployment/consul-server consul=consul:1.17.0 -n consul
kubectl rollout status deployment/consul-server -n consul

# Verify deployment
kubectl get pods -n consul
kubectl logs -l app=consul-server -n consul --tail=50
```

#### Blue-Green Deployments
```bash
# Blue-green deployment for critical services
# Deploy to green environment
kubectl apply -f green-deployment.yaml

# Test green environment
./test-green-environment.sh

# Switch traffic to green
kubectl patch service vault-service -p '{"spec":{"selector":{"version":"green"}}}'

# Monitor and rollback if necessary
kubectl patch service vault-service -p '{"spec":{"selector":{"version":"blue"}}}'
```

## Documentation Maintenance

### Runbook Updates
- Review and update procedures monthly
- Update contact information quarterly
- Validate emergency procedures semi-annually
- Update architecture diagrams after major changes

### Knowledge Base
- Maintain troubleshooting guides
- Document common issues and resolutions
- Keep escalation procedures current
- Update performance baselines regularly

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Next Review**: [Date + 3 months]  
**Owner**: Platform Engineering Team