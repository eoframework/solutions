# Google Cloud Landing Zone Operations Runbook

## Overview
This runbook provides comprehensive operational procedures for managing the Google Cloud Landing Zone infrastructure. It includes routine maintenance tasks, incident response procedures, monitoring guidelines, and troubleshooting steps.

## Daily Operations

### Morning Health Check (9:00 AM)
**Frequency**: Daily  
**Owner**: Platform Operations Team  
**Duration**: 30 minutes

#### Checklist
- [ ] Review overnight alerts and incidents
- [ ] Check system health dashboards
- [ ] Validate backup completion status
- [ ] Monitor resource utilization trends
- [ ] Review security notifications
- [ ] Check budget alerts and cost anomalies

#### Commands
```bash
# Check overall system health
gcloud logging read 'severity>=ERROR AND timestamp>="2024-01-01T08:00:00Z"' --limit=50

# Review resource quotas
gcloud compute project-info describe --project=${PROJECT_ID}

# Check VPC connectivity
gcloud compute networks list
gcloud compute networks peerings list --network=hub-vpc

# Validate DNS resolution
nslookup internal.company.com
```

### Evening Backup Verification (6:00 PM)
**Frequency**: Daily  
**Owner**: Platform Operations Team  
**Duration**: 15 minutes

#### Checklist
- [ ] Verify all scheduled backups completed
- [ ] Check backup integrity and accessibility
- [ ] Review backup storage consumption
- [ ] Validate cross-region replication status

#### Commands
```bash
# List recent snapshots
gcloud compute snapshots list --filter="creationTimestamp>-P1D" --sort-by=~creationTimestamp

# Check backup bucket status
gsutil ls -L gs://backup-bucket-name/

# Verify database backups
gcloud sql backups list --instance=production-db
```

## Weekly Operations

### Security Review (Monday 10:00 AM)
**Frequency**: Weekly  
**Owner**: Security Team  
**Duration**: 2 hours

#### Activities
1. **Security Command Center Review**
   - Review active findings and recommendations
   - Validate security policy compliance
   - Check for new vulnerabilities

2. **Access Review**
   - Audit IAM permissions and role assignments
   - Review service account usage
   - Validate MFA enforcement

3. **Network Security Assessment**
   - Review firewall rule effectiveness
   - Analyze VPC flow logs for anomalies
   - Check for unauthorized network access

#### Commands
```bash
# Security Command Center findings
gcloud scc findings list --organization=${ORG_ID} --filter="state=ACTIVE"

# IAM policy audit
gcloud projects get-iam-policy ${PROJECT_ID} --format=json

# Firewall rules review
gcloud compute firewall-rules list --filter="disabled=false" --sort-by=priority

# VPC flow logs analysis
gcloud logging read 'resource.type="gce_subnetwork" AND jsonPayload.connection.dest_port!=443' --limit=100
```

### Performance Review (Wednesday 2:00 PM)
**Frequency**: Weekly  
**Owner**: Platform Engineering Team  
**Duration**: 1 hour

#### Activities
1. **Resource Utilization Analysis**
   - CPU, memory, and disk utilization trends
   - Network bandwidth consumption
   - Storage growth patterns

2. **Performance Optimization**
   - Identify overprovisioned resources
   - Review auto-scaling configurations
   - Analyze slow-performing queries

3. **Capacity Planning**
   - Forecast resource needs
   - Plan scaling activities
   - Review quota requirements

### Cost Optimization Review (Friday 4:00 PM)
**Frequency**: Weekly  
**Owner**: FinOps Team  
**Duration**: 1.5 hours

#### Activities
1. **Cost Analysis**
   - Review weekly spending trends
   - Identify cost anomalies
   - Analyze cost by service and project

2. **Optimization Opportunities**
   - Review committed use discounts
   - Identify unused resources
   - Optimize storage classes

3. **Budget Management**
   - Update budget forecasts
   - Review alert thresholds
   - Plan cost allocation

## Monthly Operations

### Disaster Recovery Testing (First Saturday)
**Frequency**: Monthly  
**Owner**: Platform Operations Team  
**Duration**: 4 hours

#### Test Scenarios
1. **Database Failover Test**
   - Simulate primary database failure
   - Validate failover to secondary region
   - Test application connectivity
   - Verify data consistency

2. **Network Connectivity Test**
   - Simulate VPN connection failure
   - Test backup connectivity paths
   - Validate DNS failover
   - Check routing table updates

3. **Backup Restoration Test**
   - Restore from recent backup
   - Validate data integrity
   - Test application functionality
   - Document restoration time

#### Procedures
```bash
# Database failover simulation
gcloud sql instances failover ${INSTANCE_NAME} --async

# Test network connectivity
ping -c 4 ${SECONDARY_REGION_IP}
traceroute ${SECONDARY_REGION_IP}

# Backup restoration
gcloud compute disks create test-restore-disk --source-snapshot=${SNAPSHOT_NAME}
```

### Security Audit (Third Thursday)
**Frequency**: Monthly  
**Owner**: Security Team  
**Duration**: Full day

#### Audit Areas
1. **Access Controls**
   - Service account permissions
   - User access reviews
   - Privileged access validation

2. **Network Security**
   - Firewall rule effectiveness
   - VPN configuration review
   - Network segmentation validation

3. **Data Protection**
   - Encryption implementation
   - Data classification compliance
   - Backup security validation

4. **Compliance Assessment**
   - SOC 2 control validation
   - GDPR compliance check
   - Industry-specific requirements

## Incident Response Procedures

### Severity Levels
- **P0 (Critical)**: Complete service outage affecting all users
- **P1 (High)**: Major functionality impacted, significant user impact
- **P2 (Medium)**: Limited functionality impacted, some users affected
- **P3 (Low)**: Minor issues, minimal user impact

### P0 Incident Response
**Response Time**: 15 minutes  
**Resolution Target**: 4 hours

#### Immediate Actions (0-15 minutes)
1. **Assessment**
   - Confirm incident severity
   - Identify affected services
   - Assess user impact
   - Check monitoring dashboards

2. **Communication**
   - Alert incident response team
   - Create incident ticket
   - Notify stakeholders
   - Update status page

3. **Initial Response**
   - Activate incident bridge
   - Assign incident commander
   - Begin troubleshooting
   - Implement emergency fixes

#### Investigation (15-60 minutes)
```bash
# Check system health
gcloud compute instances list --filter="status!=RUNNING"
gcloud compute instance-groups managed list

# Network connectivity verification
gcloud compute networks list
gcloud compute vpn-tunnels list --filter="status!=ESTABLISHED"

# Database health check
gcloud sql instances list --filter="state!=RUNNABLE"

# Load balancer status
gcloud compute backend-services list
gcloud compute health-checks list
```

#### Resolution (1-4 hours)
1. **Root Cause Analysis**
   - Analyze logs and metrics
   - Identify failure point
   - Determine fix strategy

2. **Implementation**
   - Deploy fixes carefully
   - Monitor impact
   - Validate resolution
   - Confirm service restoration

3. **Verification**
   - Test all functionality
   - Monitor for recurrence
   - Validate performance
   - Close incident

### P1 Incident Response
**Response Time**: 30 minutes  
**Resolution Target**: 8 hours

#### Common P1 Scenarios
- Single region outage
- Database performance degradation
- Security breach detected
- Major network connectivity issues

### P2/P3 Incident Response
**Response Time**: 2 hours  
**Resolution Target**: 24-72 hours

## Monitoring and Alerting

### Critical Alerts (P0/P1)
```yaml
# Critical system alerts requiring immediate response
alerts:
  - name: "Service Unavailable"
    condition: "Uptime check failure for >5 minutes"
    notification: "Immediate SMS + Call"
    
  - name: "Database Down"
    condition: "Database connection failure"
    notification: "Immediate SMS + Call"
    
  - name: "Security Breach"
    condition: "Multiple failed login attempts"
    notification: "Immediate SMS + Email to Security Team"
```

### Warning Alerts (P2/P3)
```yaml
# System degradation alerts
alerts:
  - name: "High CPU Usage"
    condition: "CPU >80% for >10 minutes"
    notification: "Email + Slack"
    
  - name: "Disk Space Low"
    condition: "Disk usage >85%"
    notification: "Email"
    
  - name: "Network Latency High"
    condition: "Response time >500ms for >5 minutes"
    notification: "Slack"
```

### Dashboard Monitoring
#### Primary Dashboard URLs
- **System Overview**: https://console.cloud.google.com/monitoring/dashboards/custom/[DASHBOARD_ID]
- **Network Health**: https://console.cloud.google.com/networking/[PROJECT_ID]
- **Security Center**: https://console.cloud.google.com/security/command-center/

#### Key Metrics to Monitor
- System availability and uptime
- Response time and latency
- Error rates and failure counts
- Resource utilization (CPU, memory, disk)
- Network throughput and connectivity
- Security events and anomalies

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue: VPC Peering Connection Failed
**Symptoms**: Cannot communicate between VPCs  
**Investigation Steps**:
```bash
# Check peering status
gcloud compute networks peerings list --network=${NETWORK_NAME}

# Verify routing
gcloud compute routes list --filter="network=${NETWORK_NAME}"

# Check firewall rules
gcloud compute firewall-rules list --filter="network=${NETWORK_NAME}"
```

**Resolution**:
1. Verify peering configuration matches on both sides
2. Check IP range overlaps
3. Validate firewall rules allow traffic
4. Confirm custom route propagation settings

#### Issue: VPN Tunnel Down
**Symptoms**: Cannot connect to on-premises resources  
**Investigation Steps**:
```bash
# Check VPN tunnel status
gcloud compute vpn-tunnels list --filter="status!=ESTABLISHED"

# Review VPN logs
gcloud logging read 'resource.type="vpn_gateway"' --limit=50

# Check routing
gcloud compute routes list --filter="nextHopVpnTunnel"
```

**Resolution**:
1. Verify shared secret configuration
2. Check IKE policy settings
3. Validate routing configuration
4. Confirm firewall rules
5. Contact network provider if needed

#### Issue: High Database CPU Usage
**Symptoms**: Application slow response, database timeouts  
**Investigation Steps**:
```bash
# Check database performance
gcloud sql instances describe ${INSTANCE_NAME}

# Review slow queries
gcloud logging read 'resource.type="cloudsql_database" AND severity>=WARNING'

# Monitor connections
gcloud sql operations list --instance=${INSTANCE_NAME}
```

**Resolution**:
1. Identify slow-running queries
2. Optimize database indexes
3. Scale database instance if needed
4. Implement query caching
5. Consider read replicas for read-heavy workloads

#### Issue: Storage Bucket Access Denied
**Symptoms**: Applications cannot read/write to Cloud Storage  
**Investigation Steps**:
```bash
# Check bucket permissions
gsutil iam get gs://${BUCKET_NAME}

# Verify service account permissions
gcloud projects get-iam-policy ${PROJECT_ID}

# Test access
gsutil ls gs://${BUCKET_NAME}
```

**Resolution**:
1. Verify service account has appropriate roles
2. Check bucket-level IAM policies
3. Validate object-level permissions
4. Confirm service account key is valid
5. Review any bucket-specific conditions

## Maintenance Procedures

### Planned Maintenance Windows
- **Weekly**: Sunday 2:00 AM - 4:00 AM (Non-production)
- **Monthly**: First Saturday 10:00 PM - 2:00 AM (Production)
- **Quarterly**: Schedule based on business requirements

### Pre-Maintenance Checklist
- [ ] Create maintenance plan document
- [ ] Notify stakeholders 72 hours in advance
- [ ] Backup all critical data
- [ ] Test rollback procedures
- [ ] Prepare emergency contacts
- [ ] Update status page

### Post-Maintenance Checklist
- [ ] Validate all services are operational
- [ ] Run health checks and monitoring
- [ ] Update documentation
- [ ] Communicate completion to stakeholders
- [ ] Conduct post-maintenance review

## Escalation Procedures

### Internal Escalation
1. **Level 1**: On-call engineer
2. **Level 2**: Platform team lead
3. **Level 3**: Engineering manager
4. **Level 4**: Director of Engineering

### External Escalation
1. **Google Cloud Support**: Create support ticket
2. **Network Provider**: Contact for connectivity issues
3. **Third-party Vendors**: Engage for tool-specific problems
4. **Security Partners**: For security incident response

### Contact Information
```
Platform Team Lead: [NAME] - [PHONE] - [EMAIL]
Security Team Lead: [NAME] - [PHONE] - [EMAIL]
Network Operations: [NAME] - [PHONE] - [EMAIL]
Google Cloud TAM: [NAME] - [PHONE] - [EMAIL]
```

## Documentation and Change Management

### Required Documentation
- All changes must be documented in change management system
- Update runbooks after significant changes
- Maintain architecture diagrams current
- Document lessons learned from incidents

### Change Approval Process
1. **Standard Changes**: Pre-approved, low-risk changes
2. **Normal Changes**: Require change board approval
3. **Emergency Changes**: Post-implementation approval

### Version Control
- All infrastructure code in Git repositories
- Use semantic versioning for releases
- Maintain change logs for major updates
- Tag releases for easy rollback

---
**Operations Runbook Version**: 1.0  
**Last Updated**: [DATE]  
**Next Review Date**: [QUARTERLY_REVIEW_DATE]  
**Document Owner**: Platform Operations Team