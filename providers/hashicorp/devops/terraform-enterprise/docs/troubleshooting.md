# HashiCorp Terraform Enterprise - Troubleshooting Guide

## Overview
This guide provides comprehensive troubleshooting procedures for the HashiCorp Terraform Enterprise platform. It covers common issues, diagnostic procedures, and resolution strategies for production environments.

## General Troubleshooting Methodology

### Problem Identification Process
1. **Gather Symptoms**: Document exact error messages and observed behavior
2. **Check System Health**: Verify overall TFE platform status
3. **Review Recent Changes**: Identify any recent configuration or deployment changes
4. **Check Dependencies**: Validate database, storage, and network connectivity
5. **Analyze Logs**: Review application, system, and audit logs
6. **Isolate Components**: Determine which TFE component is affected
7. **Apply Solutions**: Implement targeted fixes based on diagnosis
8. **Verify Resolution**: Confirm issue is resolved and monitor for recurrence

### Essential Diagnostic Commands
```bash
#!/bin/bash
# TFE Health Check Script

echo "=== Terraform Enterprise Health Check ==="

# Check TFE application pods
echo "Checking TFE application status..."
kubectl get pods -n terraform-enterprise
kubectl describe pods -n terraform-enterprise

# Check TFE service endpoints
echo "Testing TFE endpoints..."
curl -I https://terraform.company.com/_health_check
curl -I https://terraform.company.com/admin/health-check

# Check database connectivity
echo "Testing database connectivity..."
kubectl exec -n terraform-enterprise deployment/terraform-enterprise -- \
  psql $TFE_DATABASE_URL -c "SELECT version();"

# Check object storage connectivity  
echo "Testing object storage..."
kubectl exec -n terraform-enterprise deployment/terraform-enterprise -- \
  aws s3 ls s3://$TFE_OBJECT_STORAGE_BUCKET/

# Check resource utilization
echo "Checking resource utilization..."
kubectl top nodes
kubectl top pods -n terraform-enterprise
```

## Application-Level Issues

### Issue: Terraform Enterprise UI Not Loading
**Symptoms**:
- Users cannot access TFE web interface
- Browser shows connection timeout or 502/503 errors
- Load balancer health checks failing

**Diagnostic Steps**:
```bash
# Check TFE pod status
kubectl get pods -n terraform-enterprise
kubectl describe pod terraform-enterprise-xxx -n terraform-enterprise

# Check ingress and load balancer
kubectl get ingress -n terraform-enterprise
kubectl describe ingress terraform-enterprise -n terraform-enterprise

# Test direct pod connectivity
kubectl port-forward -n terraform-enterprise terraform-enterprise-xxx 8080:8080
curl http://localhost:8080/_health_check

# Check service and endpoints
kubectl get svc -n terraform-enterprise
kubectl get endpoints -n terraform-enterprise
```

**Common Causes and Solutions**:

1. **Pod Not Running or Crashing**
   ```bash
   # Check pod logs
   kubectl logs terraform-enterprise-xxx -n terraform-enterprise
   
   # Check previous container logs if pod restarted
   kubectl logs terraform-enterprise-xxx -n terraform-enterprise --previous
   
   # Check resource constraints
   kubectl describe pod terraform-enterprise-xxx -n terraform-enterprise
   
   # Solution: Increase resource limits or fix configuration
   kubectl patch deployment terraform-enterprise -n terraform-enterprise \
     -p '{"spec":{"template":{"spec":{"containers":[{"name":"terraform-enterprise","resources":{"limits":{"memory":"8Gi","cpu":"4"}}}]}}}}'
   ```

2. **Database Connection Issues**
   ```bash
   # Test database connectivity from pod
   kubectl exec -it terraform-enterprise-xxx -n terraform-enterprise -- \
     psql $TFE_DATABASE_URL -c "SELECT 1;"
   
   # Check database status
   aws rds describe-db-instances --db-instance-identifier tfe-postgres
   
   # Solution: Verify database credentials and connectivity
   kubectl get secret tfe-database-credentials -n terraform-enterprise -o yaml
   ```

3. **Load Balancer Configuration Issues**
   ```bash
   # Check ALB target group health
   aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN
   
   # Check ingress annotations
   kubectl get ingress terraform-enterprise -n terraform-enterprise -o yaml
   
   # Solution: Fix ingress configuration
   kubectl annotate ingress terraform-enterprise -n terraform-enterprise \
     alb.ingress.kubernetes.io/healthcheck-path="/_health_check"
   ```

### Issue: Workspace Runs Failing or Stuck
**Symptoms**:
- Terraform runs not starting or getting stuck in "planning" state
- Runs failing with generic error messages
- Long queue times for workspace runs

**Diagnostic Steps**:
```bash
# Check TFE capacity and worker status
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  tfe-admin capacity status

# Check run queue
curl -H "Authorization: Bearer $TFE_TOKEN" \
  https://terraform.company.com/api/v2/runs | \
  jq '.data[] | select(.attributes.status | contains("pending"))'

# Check worker pod resources
kubectl top pods -n terraform-enterprise
kubectl describe nodes

# Check for stuck Terraform processes
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  ps aux | grep terraform
```

**Solutions**:

1. **Insufficient Worker Capacity**
   ```bash
   # Scale up TFE deployment
   kubectl scale deployment terraform-enterprise -n terraform-enterprise --replicas=5
   
   # Increase worker capacity configuration
   kubectl set env deployment/terraform-enterprise -n terraform-enterprise \
     TFE_CAPACITY_CONCURRENCY=30
   
   # Check auto-scaling configuration
   kubectl get hpa terraform-enterprise -n terraform-enterprise
   ```

2. **Resource Constraints**
   ```bash
   # Add more worker nodes
   aws eks update-nodegroup-config \
     --cluster-name tfe-cluster \
     --nodegroup-name tfe-nodes \
     --scaling-config minSize=5,maxSize=20,desiredSize=8
   
   # Increase pod resource limits
   kubectl patch deployment terraform-enterprise -n terraform-enterprise \
     -p '{"spec":{"template":{"spec":{"containers":[{"name":"terraform-enterprise","resources":{"requests":{"memory":"4Gi","cpu":"2"},"limits":{"memory":"8Gi","cpu":"4"}}}]}}}}'
   ```

3. **Stuck Terraform Processes**
   ```bash
   # Kill stuck processes (use with caution)
   kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
     pkill -f "terraform (plan|apply)"
   
   # Restart TFE deployment
   kubectl rollout restart deployment/terraform-enterprise -n terraform-enterprise
   ```

### Issue: VCS Integration Not Working
**Symptoms**:
- Webhooks not triggering runs
- Unable to connect to VCS repositories
- Repository content not syncing

**Diagnostic Steps**:
```bash
# Check VCS OAuth configuration
curl -H "Authorization: Bearer $TFE_TOKEN" \
  https://terraform.company.com/api/v2/organizations/myorg/oauth-tokens

# Test webhook delivery (check VCS provider logs)
# For GitHub: Settings > Webhooks > Recent Deliveries

# Check TFE logs for webhook processing
kubectl logs -n terraform-enterprise deployment/terraform-enterprise | \
  grep -i webhook

# Test repository access
curl -H "Authorization: Bearer $TFE_TOKEN" \
  https://terraform.company.com/api/v2/organizations/myorg/workspaces/myworkspace/current-configuration-version
```

**Solutions**:

1. **OAuth Token Issues**
   ```bash
   # Regenerate OAuth token in VCS provider
   # Update OAuth token in TFE
   curl -X PATCH \
     -H "Authorization: Bearer $TFE_TOKEN" \
     -H "Content-Type: application/vnd.api+json" \
     -d '{"data":{"type":"oauth-tokens","attributes":{"token":"new-token"}}}' \
     https://terraform.company.com/api/v2/oauth-tokens/$OAUTH_TOKEN_ID
   ```

2. **Webhook Configuration Issues**
   ```bash
   # Verify webhook URL is accessible from VCS
   # Check if corporate firewall is blocking webhooks
   # Test webhook endpoint manually
   curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"test": "payload"}' \
     https://terraform.company.com/webhooks/vcs/your-webhook-id
   ```

3. **Network Connectivity Issues**
   ```bash
   # Test outbound connectivity from TFE pods
   kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
     curl -I https://api.github.com
   
   # Check DNS resolution
   kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
     nslookup github.com
   
   # Verify security groups allow outbound HTTPS
   aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID
   ```

## Database-Related Issues

### Issue: Database Connection Pool Exhaustion
**Symptoms**:
- "too many connections" errors in logs
- Slow response times or timeouts
- New runs failing to start

**Diagnostic Steps**:
```bash
# Check current database connections
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  psql $TFE_DATABASE_URL -c "SELECT count(*) FROM pg_stat_activity;"

# Check connection pool configuration
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  env | grep TFE_DATABASE

# Check database performance metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=tfe-postgres \
  --start-time 2024-01-15T00:00:00Z \
  --end-time 2024-01-15T23:59:59Z \
  --period 300 \
  --statistics Average,Maximum
```

**Solutions**:
1. **Adjust Connection Pool Settings**
   ```bash
   # Increase connection pool size
   kubectl set env deployment/terraform-enterprise -n terraform-enterprise \
     TFE_DATABASE_POOL_SIZE=20
   
   # Set connection timeout
   kubectl set env deployment/terraform-enterprise -n terraform-enterprise \
     TFE_DATABASE_TIMEOUT=30
   ```

2. **Scale Database Instance**
   ```bash
   # Modify RDS instance class
   aws rds modify-db-instance \
     --db-instance-identifier tfe-postgres \
     --db-instance-class db.r5.2xlarge \
     --apply-immediately
   ```

3. **Implement Connection Pooling**
   ```bash
   # Deploy PgBouncer
   kubectl apply -f - <<EOF
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: pgbouncer
     namespace: terraform-enterprise
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: pgbouncer
     template:
       metadata:
         labels:
           app: pgbouncer
       spec:
         containers:
         - name: pgbouncer
           image: pgbouncer/pgbouncer:latest
           env:
           - name: DATABASES_HOST
             value: "tfe-postgres.rds.amazonaws.com"
           - name: DATABASES_PORT
             value: "5432"
           - name: DATABASES_USER
             value: "tfe"
           - name: DATABASES_PASSWORD
             valueFrom:
               secretKeyRef:
                 name: tfe-database-credentials
                 key: password
           - name: POOL_MODE
             value: "transaction"
           - name: DEFAULT_POOL_SIZE
             value: "20"
           - name: MAX_CLIENT_CONN
             value: "100"
   EOF
   ```

### Issue: Database Performance Degradation
**Symptoms**:
- Slow query performance
- High CPU utilization on database
- Timeout errors during runs

**Diagnostic Steps**:
```bash
# Check database performance insights
aws rds describe-db-instances --db-instance-identifier tfe-postgres \
  --query 'DBInstances[0].PerformanceInsightsEnabled'

# Check slow query log
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  psql $TFE_DATABASE_URL -c "SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# Check database size and growth
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  psql $TFE_DATABASE_URL -c "SELECT pg_database_size(current_database()) / 1024 / 1024 AS size_mb;"
```

**Solutions**:
1. **Optimize Database Configuration**
   ```bash
   # Increase shared_buffers (requires restart)
   aws rds modify-db-parameter-group \
     --db-parameter-group-name tfe-postgres-params \
     --parameters "ParameterName=shared_buffers,ParameterValue=2GB,ApplyMethod=pending-reboot"
   
   # Reboot database to apply changes
   aws rds reboot-db-instance --db-instance-identifier tfe-postgres
   ```

2. **Implement Read Replicas**
   ```bash
   # Create read replica for reporting queries
   aws rds create-db-instance-read-replica \
     --db-instance-identifier tfe-postgres-replica \
     --source-db-instance-identifier tfe-postgres \
     --db-instance-class db.r5.large
   ```

3. **Database Maintenance**
   ```bash
   # Run VACUUM and ANALYZE
   kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
     psql $TFE_DATABASE_URL -c "VACUUM ANALYZE;"
   
   # Rebuild indexes if needed
   kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
     psql $TFE_DATABASE_URL -c "REINDEX DATABASE tfe;"
   ```

## Storage-Related Issues

### Issue: Object Storage Connectivity Problems
**Symptoms**:
- State file operations failing
- Workspace configuration uploads failing
- Plan/apply logs not saved

**Diagnostic Steps**:
```bash
# Test S3 connectivity from TFE pod
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  aws s3 ls s3://$TFE_OBJECT_STORAGE_BUCKET/

# Check S3 bucket permissions
aws s3api get-bucket-policy --bucket $TFE_OBJECT_STORAGE_BUCKET

# Check IAM role permissions
aws sts get-caller-identity
aws iam get-role --role-name $TFE_IAM_ROLE

# Test specific operations
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  aws s3 cp /tmp/test.txt s3://$TFE_OBJECT_STORAGE_BUCKET/test/
```

**Solutions**:
1. **Fix S3 Bucket Policy**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "TFEAccess",
         "Effect": "Allow",
         "Principal": {
           "AWS": "arn:aws:iam::123456789012:role/tfe-role"
         },
         "Action": [
           "s3:GetObject",
           "s3:PutObject",
           "s3:DeleteObject",
           "s3:ListBucket"
         ],
         "Resource": [
           "arn:aws:s3:::tfe-bucket",
           "arn:aws:s3:::tfe-bucket/*"
         ]
       }
     ]
   }
   ```

2. **Update IAM Role Permissions**
   ```bash
   # Attach necessary S3 permissions
   aws iam attach-role-policy \
     --role-name tfe-role \
     --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
   ```

3. **Check Regional Endpoint Configuration**
   ```bash
   # Set correct S3 region endpoint
   kubectl set env deployment/terraform-enterprise -n terraform-enterprise \
     TFE_OBJECT_STORAGE_S3_REGION=$AWS_REGION
   ```

## Network and Connectivity Issues

### Issue: DNS Resolution Problems
**Symptoms**:
- Unable to access TFE via custom domain
- Certificate validation errors
- External API calls failing

**Diagnostic Steps**:
```bash
# Test DNS resolution
nslookup terraform.company.com
dig terraform.company.com

# Test from within cluster
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  nslookup terraform.company.com

# Check ingress DNS configuration
kubectl get ingress terraform-enterprise -n terraform-enterprise -o yaml

# Test certificate validation
openssl s_client -connect terraform.company.com:443 -servername terraform.company.com
```

**Solutions**:
1. **Update DNS Records**
   ```bash
   # Get load balancer DNS name
   ALB_DNS=$(kubectl get ingress terraform-enterprise -n terraform-enterprise \
     -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
   
   # Update Route53 record
   aws route53 change-resource-record-sets \
     --hosted-zone-id $ZONE_ID \
     --change-batch '{
       "Changes": [{
         "Action": "UPSERT",
         "ResourceRecordSet": {
           "Name": "terraform.company.com",
           "Type": "CNAME",
           "TTL": 300,
           "ResourceRecords": [{"Value": "'$ALB_DNS'"}]
         }
       }]
     }'
   ```

2. **Fix Certificate Issues**
   ```bash
   # Request new ACM certificate
   aws acm request-certificate \
     --domain-name terraform.company.com \
     --validation-method DNS
   
   # Update ingress with new certificate ARN
   kubectl annotate ingress terraform-enterprise -n terraform-enterprise \
     alb.ingress.kubernetes.io/certificate-arn=arn:aws:acm:region:account:certificate/cert-id
   ```

### Issue: Load Balancer Health Check Failures
**Symptoms**:
- Intermittent connectivity issues
- 502/503 errors from load balancer
- Health check failing in AWS console

**Diagnostic Steps**:
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN

# Check health check configuration
aws elbv2 describe-target-groups --target-group-arns $TARGET_GROUP_ARN

# Test health check endpoint directly
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  curl http://localhost:8080/_health_check

# Check service and endpoint status
kubectl get endpoints terraform-enterprise -n terraform-enterprise
```

**Solutions**:
1. **Fix Health Check Configuration**
   ```bash
   # Update ingress health check path
   kubectl annotate ingress terraform-enterprise -n terraform-enterprise \
     alb.ingress.kubernetes.io/healthcheck-path="/_health_check"
   
   # Set health check interval and timeout
   kubectl annotate ingress terraform-enterprise -n terraform-enterprise \
     alb.ingress.kubernetes.io/healthcheck-interval-seconds="30" \
     alb.ingress.kubernetes.io/healthcheck-timeout-seconds="5"
   ```

2. **Verify Pod Health**
   ```bash
   # Check readiness and liveness probes
   kubectl describe pod terraform-enterprise-xxx -n terraform-enterprise
   
   # Update probe configuration if needed
   kubectl patch deployment terraform-enterprise -n terraform-enterprise \
     -p '{"spec":{"template":{"spec":{"containers":[{"name":"terraform-enterprise","readinessProbe":{"httpGet":{"path":"/_health_check","port":8080},"initialDelaySeconds":30,"periodSeconds":10}}]}}}}'
   ```

## Authentication and Authorization Issues

### Issue: SSO Authentication Failures
**Symptoms**:
- Users unable to log in via SSO
- SAML assertion errors
- Authentication redirects failing

**Diagnostic Steps**:
```bash
# Check SAML configuration
kubectl get secret tfe-saml-config -n terraform-enterprise -o yaml

# Check TFE logs for auth errors
kubectl logs -n terraform-enterprise deployment/terraform-enterprise | \
  grep -i "saml\|auth\|login"

# Test SAML endpoint
curl -I https://terraform.company.com/session

# Verify certificate validity
openssl x509 -in saml-cert.pem -text -noout | grep -i "not after"
```

**Solutions**:
1. **Update SAML Configuration**
   ```bash
   # Update SAML certificate
   kubectl create secret generic tfe-saml-config \
     --from-file=certificate=new-saml-cert.pem \
     --from-file=private-key=new-saml-key.pem \
     --dry-run=client -o yaml | kubectl apply -f -
   
   # Restart TFE to pick up new config
   kubectl rollout restart deployment/terraform-enterprise -n terraform-enterprise
   ```

2. **Verify Identity Provider Configuration**
   ```bash
   # Check IdP metadata URL
   curl https://identity.company.com/metadata
   
   # Verify callback URL configuration in IdP
   # Should be: https://terraform.company.com/session
   ```

## Performance Issues

### Issue: Slow Web UI Response Times
**Symptoms**:
- Pages taking long time to load
- Timeouts when viewing large workspaces
- Slow API responses

**Diagnostic Steps**:
```bash
# Check application response times
curl -w "@curl-format.txt" -o /dev/null -s https://terraform.company.com/app/organizations

# Monitor resource utilization
kubectl top pods -n terraform-enterprise
kubectl top nodes

# Check database performance
kubectl exec -n terraform-enterprise terraform-enterprise-xxx -- \
  psql $TFE_DATABASE_URL -c "SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 5;"

# Test different endpoints
time curl https://terraform.company.com/api/v2/organizations
time curl https://terraform.company.com/api/v2/workspaces
```

**Solutions**:
1. **Scale Application Resources**
   ```bash
   # Increase pod resources
   kubectl patch deployment terraform-enterprise -n terraform-enterprise \
     -p '{"spec":{"template":{"spec":{"containers":[{"name":"terraform-enterprise","resources":{"requests":{"memory":"6Gi","cpu":"3"},"limits":{"memory":"12Gi","cpu":"6"}}}]}}}}'
   
   # Scale out replicas
   kubectl scale deployment terraform-enterprise -n terraform-enterprise --replicas=5
   ```

2. **Optimize Database Performance**
   ```bash
   # Scale up database instance
   aws rds modify-db-instance \
     --db-instance-identifier tfe-postgres \
     --db-instance-class db.r5.4xlarge \
     --apply-immediately
   
   # Add read replicas for read-heavy workloads
   ```

3. **Implement Caching**
   ```bash
   # Deploy Redis for caching
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm install redis bitnami/redis -n terraform-enterprise
   
   # Configure TFE to use Redis
   kubectl set env deployment/terraform-enterprise -n terraform-enterprise \
     TFE_REDIS_HOST=redis-master.terraform-enterprise.svc.cluster.local
   ```

## Emergency Procedures

### Complete Platform Outage
**Immediate Actions** (0-15 minutes):
1. Confirm outage scope and impact
2. Check overall AWS service health
3. Verify EKS cluster status
4. Check database availability
5. Notify stakeholders via status page

**Response Steps**:
```bash
# Quick health check of all components
kubectl get nodes
kubectl get pods -n terraform-enterprise
aws rds describe-db-instances --db-instance-identifier tfe-postgres
aws elbv2 describe-load-balancers

# If pods are down, check events
kubectl get events -n terraform-enterprise --sort-by='.lastTimestamp'

# Restart deployment if needed
kubectl rollout restart deployment/terraform-enterprise -n terraform-enterprise

# Monitor recovery
kubectl rollout status deployment/terraform-enterprise -n terraform-enterprise
```

### Data Corruption or Loss
**Immediate Actions**:
1. Stop all write operations to prevent further damage
2. Take emergency snapshots of database and storage
3. Assess extent of corruption
4. Activate incident response team

**Recovery Steps**:
```bash
# Create emergency database snapshot
aws rds create-db-snapshot \
  --db-instance-identifier tfe-postgres \
  --db-snapshot-identifier emergency-snapshot-$(date +%Y%m%d-%H%M)

# Backup current S3 state
aws s3 sync s3://$TFE_OBJECT_STORAGE_BUCKET s3://emergency-backup-bucket/ \
  --include="*" --storage-class STANDARD_IA

# If recovery needed, restore from known good backup
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier tfe-postgres-restored \
  --db-snapshot-identifier last-known-good-snapshot
```

### Security Incident Response
**Immediate Actions**:
1. Isolate affected systems
2. Preserve evidence and logs
3. Assess scope of compromise
4. Notify security team and management

**Containment Steps**:
```bash
# Block suspicious traffic at load balancer
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=fixed-response,FixedResponseConfig='{StatusCode=503,ContentType=text/plain,MessageBody=Service Temporarily Unavailable}'

# Rotate all secrets and tokens
kubectl delete secret tfe-database-credentials -n terraform-enterprise
kubectl create secret generic tfe-database-credentials \
  --from-literal=password="$(openssl rand -base64 32)" \
  -n terraform-enterprise

# Enable enhanced logging
kubectl set env deployment/terraform-enterprise -n terraform-enterprise \
  TFE_LOG_LEVEL=DEBUG TFE_AUDIT_LOG_LEVEL=DEBUG
```

## Escalation Procedures

### Internal Escalation Path
1. **Level 1**: Platform Operations Team
2. **Level 2**: Senior Platform Engineers  
3. **Level 3**: Platform Architect and Engineering Manager
4. **Level 4**: CTO and Executive Team

### External Escalation
- **HashiCorp Support**: Enterprise support with 4-hour SLA
- **AWS Support**: Enterprise support for infrastructure issues
- **Security Incidents**: External security firm (if applicable)

### Contact Information
```
Platform Operations Team: platform-ops@company.com
On-Call Engineer: +1-555-PLATFORM (555-752-8367)
HashiCorp Support: https://support.hashicorp.com
AWS Support: AWS Console Support Center
Emergency Escalation: emergency@company.com
```

### Support Case Creation
```bash
# HashiCorp Support Case Template
Subject: [URGENT] TFE Production Issue - [Brief Description]

Environment:
- TFE Version: v202401-1
- Kubernetes Version: 1.28
- Database: PostgreSQL 14.9 on AWS RDS
- Infrastructure: AWS EKS

Issue Description:
[Detailed description of the issue]

Impact:
[Business impact and affected users]

Steps Taken:
[Actions already performed]

Logs and Diagnostics:
[Attach relevant logs and diagnostic output]
```

---
**Troubleshooting Guide Version**: 1.0  
**Last Updated**: 2024-01-15  
**Next Review Date**: 2024-04-15  
**Document Owner**: Platform Operations Team