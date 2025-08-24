# HashiCorp Terraform Enterprise Operations Runbook

## Overview
This runbook provides comprehensive operational procedures for managing the HashiCorp Terraform Enterprise platform in production environments. It covers daily operations, monitoring, incident response, and maintenance procedures.

## Daily Operations

### Morning Health Check (9:00 AM)
**Frequency**: Daily  
**Owner**: Platform Operations Team  
**Duration**: 20 minutes

#### Checklist
- [ ] Review Terraform Enterprise dashboard for system health
- [ ] Check active workspace runs and any failed executions
- [ ] Validate database connectivity and performance metrics
- [ ] Monitor EKS cluster health and node status
- [ ] Review overnight backup completion
- [ ] Check SSL certificate expiration status
- [ ] Validate VCS integration connectivity

#### Commands
```bash
# Check TFE application health
kubectl get pods -n terraform-enterprise
kubectl describe pod -n terraform-enterprise

# Check database connectivity
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT version();"

# Monitor workspace activity
curl -s -H "Authorization: Bearer $TFE_TOKEN" \
  https://tfe.company.com/api/v2/runs | jq '.data[] | select(.attributes.status != "applied")'
```

### Evening Backup Verification (6:00 PM)
**Frequency**: Daily  
**Owner**: Platform Operations Team  
**Duration**: 15 minutes

#### Checklist
- [ ] Verify automated database backups completed
- [ ] Check Terraform state backup integrity
- [ ] Validate cross-region backup replication
- [ ] Review backup storage utilization

## Weekly Operations

### Performance Review (Monday 2:00 PM)
**Frequency**: Weekly  
**Owner**: Platform Engineering Team  
**Duration**: 1 hour

#### Activities
1. **Resource Utilization Analysis**
   - CPU, memory, and disk usage trends
   - Database performance metrics review
   - Network bandwidth consumption analysis

2. **Workspace Analytics**
   - Most active workspaces identification
   - Average run duration analysis
   - Policy violation trends

3. **Cost Optimization Review**
   - AWS infrastructure cost analysis
   - Resource rightsizing recommendations
   - Unused resource identification

### Security Review (Wednesday 10:00 AM)  
**Frequency**: Weekly
**Owner**: Security Team
**Duration**: 1.5 hours

#### Activities
1. **Access Review**
   - User access audit and cleanup
   - Service account permission validation
   - SSO integration health check

2. **Policy Compliance**
   - Sentinel policy effectiveness review
   - Failed policy enforcement analysis
   - New policy requirements assessment

3. **Vulnerability Assessment**
   - Container image security scanning
   - Infrastructure vulnerability checks
   - SSL/TLS certificate validation

## Incident Response Procedures

### Severity Levels
- **P0 (Critical)**: TFE completely unavailable, affecting all users
- **P1 (High)**: Major functionality impacted, significant user impact  
- **P2 (Medium)**: Limited functionality impacted, some users affected
- **P3 (Low)**: Minor issues, minimal user impact

### P0 Incident Response
**Response Time**: 15 minutes  
**Resolution Target**: 2 hours

#### Immediate Actions (0-15 minutes)
1. **Assessment**
   - Confirm TFE service availability
   - Check EKS cluster status
   - Validate database connectivity
   - Review monitoring dashboards

2. **Communication**
   - Alert incident response team
   - Create incident ticket
   - Notify affected users via status page
   - Escalate to HashiCorp support if needed

3. **Initial Response**
   - Activate incident bridge
   - Assign incident commander
   - Begin troubleshooting procedures
   - Implement emergency fixes if available

#### Troubleshooting Steps
```bash
# Check TFE pod status
kubectl get pods -n terraform-enterprise -o wide
kubectl logs -n terraform-enterprise -l app=terraform-enterprise

# Check database connectivity
kubectl exec -it -n terraform-enterprise deployment/terraform-enterprise -- \
  psql $TFE_DATABASE_URL -c "SELECT COUNT(*) FROM workspaces;"

# Check load balancer health
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN

# Review recent configuration changes
terraform show -json | jq '.values.root_module.resources[] | select(.mode == "managed")'
```

## Monitoring and Alerting

### Critical Alerts (Immediate Response Required)
```yaml
# Critical system alerts
alerts:
  - name: "TFE Service Down"
    condition: "HTTP check failure for >3 minutes"
    notification: "SMS + Call + Slack"
    
  - name: "Database Connection Failed" 
    condition: "PostgreSQL connection failure"
    notification: "SMS + Call + Slack"
    
  - name: "EKS Cluster Unhealthy"
    condition: "Node failure or cluster API unreachable"
    notification: "SMS + Call + Slack"
    
  - name: "SSL Certificate Expiring"
    condition: "Certificate expires in <7 days"
    notification: "Email + Slack"
```

### Warning Alerts (Business Hours Response)
```yaml
# System degradation alerts  
alerts:
  - name: "High CPU Usage"
    condition: "CPU >80% for >15 minutes"
    notification: "Email + Slack"
    
  - name: "High Memory Usage"  
    condition: "Memory >85% for >10 minutes"
    notification: "Email + Slack"
    
  - name: "Long Running Workspaces"
    condition: "Workspace run >60 minutes"
    notification: "Slack"
```

## Maintenance Procedures

### Planned Maintenance Windows
- **Monthly**: First Saturday 10:00 PM - 2:00 AM EST
- **Quarterly**: TBD based on HashiCorp release schedule  
- **Emergency**: As needed with 4-hour notice

### Pre-Maintenance Checklist
- [ ] Schedule maintenance window with stakeholders
- [ ] Create maintenance plan and rollback procedures
- [ ] Backup all critical data and configurations
- [ ] Test rollback procedures in staging environment
- [ ] Prepare emergency contact list
- [ ] Update status page with maintenance notice

### HashiCorp Terraform Enterprise Updates
```bash
# Pre-update backup
kubectl create backup terraform-enterprise-backup-$(date +%Y%m%d)

# Update Helm chart
helm repo update hashicorp
helm upgrade terraform-enterprise hashicorp/terraform-enterprise \
  --namespace terraform-enterprise \
  --values tfe-production-values.yaml

# Post-update validation
kubectl rollout status deployment/terraform-enterprise -n terraform-enterprise
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue: Workspace Runs Stuck in "Planning" State
**Symptoms**: Terraform runs not progressing beyond planning phase

**Investigation**:
```bash
# Check worker capacity
kubectl top nodes
kubectl describe nodes

# Check pod resources
kubectl top pods -n terraform-enterprise
kubectl describe pod -n terraform-enterprise
```

**Resolution**:
1. Scale up worker nodes if resource constrained
2. Restart TFE pods if necessary
3. Check for stuck Terraform processes
4. Review workspace configuration for issues

#### Issue: Database Connection Timeouts  
**Symptoms**: 502/503 errors, slow response times

**Investigation**:
```bash
# Check database performance
aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_ID
aws cloudwatch get-metric-statistics --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=$DB_INSTANCE_ID
```

**Resolution**:
1. Review database connection pool settings
2. Scale database instance if needed  
3. Optimize slow queries
4. Check for connection leaks in application

#### Issue: SSL Certificate Problems
**Symptoms**: HTTPS connection errors, certificate warnings

**Investigation**:
```bash
# Check certificate details
openssl s_client -connect tfe.company.com:443 -servername tfe.company.com
kubectl get certificate -n terraform-enterprise
```

**Resolution**:
1. Verify certificate expiration date
2. Check DNS resolution for certificate validation
3. Update certificate if expired
4. Validate ingress configuration

## Backup and Recovery

### Backup Procedures
```bash
#!/bin/bash
# Daily backup script

# Database backup
pg_dump -h $TFE_DATABASE_HOST -U $TFE_DATABASE_USER $TFE_DATABASE_NAME | \
  gzip > tfe-db-backup-$(date +%Y%m%d).sql.gz

# Upload to S3
aws s3 cp tfe-db-backup-$(date +%Y%m%d).sql.gz \
  s3://$BACKUP_BUCKET/database/

# Terraform state backup  
aws s3 sync s3://$TFE_STATE_BUCKET s3://$BACKUP_BUCKET/terraform-state/

# Configuration backup
kubectl get configmap -n terraform-enterprise -o yaml > \
  tfe-configmaps-$(date +%Y%m%d).yaml
```

### Recovery Procedures
```bash
#!/bin/bash
# Recovery script

# Restore database
gunzip -c tfe-db-backup-$BACKUP_DATE.sql.gz | \
  psql -h $TFE_DATABASE_HOST -U $TFE_DATABASE_USER $TFE_DATABASE_NAME

# Restore Terraform state
aws s3 sync s3://$BACKUP_BUCKET/terraform-state/ s3://$TFE_STATE_BUCKET/

# Restart TFE services
kubectl rollout restart deployment/terraform-enterprise -n terraform-enterprise
```

## Performance Optimization

### Database Optimization
- Regular VACUUM and ANALYZE operations
- Index optimization for frequently accessed tables
- Connection pooling configuration
- Read replica implementation for reporting

### Application Optimization  
- Horizontal pod autoscaling configuration
- Resource request and limit tuning
- Persistent volume performance optimization
- Load balancer configuration tuning

### Infrastructure Optimization
- EKS node group optimization
- Network performance tuning
- Storage class optimization
- Cost optimization through reserved instances

## Security Procedures

### Access Management
- Regular user access review and cleanup
- Service account rotation procedures  
- API token lifecycle management
- SSH key rotation for worker nodes

### Vulnerability Management
- Regular security scanning of container images
- Operating system patching procedures
- Dependency vulnerability assessment
- Security policy updates and testing

## Contact Information

### Internal Contacts
- **Platform Team Lead**: [NAME] - [PHONE] - [EMAIL]
- **Database Administrator**: [NAME] - [PHONE] - [EMAIL]  
- **Security Team Lead**: [NAME] - [PHONE] - [EMAIL]
- **Network Operations**: [NAME] - [PHONE] - [EMAIL]

### External Contacts
- **HashiCorp Support**: [SUPPORT_EMAIL] - [SUPPORT_PHONE]
- **AWS Technical Account Manager**: [NAME] - [EMAIL]
- **On-call Escalation**: [ESCALATION_PHONE]

---
**Operations Runbook Version**: 1.0  
**Last Updated**: 2024-01-15  
**Next Review Date**: 2024-04-15  
**Document Owner**: Platform Operations Team