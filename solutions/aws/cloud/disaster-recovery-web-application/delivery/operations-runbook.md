# AWS Disaster Recovery Solution - Operations Runbook

## Document Information
**Solution**: AWS Disaster Recovery for Web Applications  
**Version**: 1.0  
**Date**: January 2025  
**Audience**: Operations Teams, Support Engineers  

---

## Overview

This operations runbook provides comprehensive procedures for managing and troubleshooting the AWS Disaster Recovery solution. It includes daily operations, emergency procedures, troubleshooting guides, and maintenance tasks.

---

## Daily Operations

### Morning Health Check Routine

#### 1. System Status Check
```bash
# Check overall system health
echo "=== Daily Health Check - $(date) ==="

# Check primary region ALB status
echo "Primary ALB Health:"
aws elbv2 describe-target-health --target-group-arn ${PRIMARY_TG_ARN}

# Check secondary region readiness
echo "Secondary ALB Health:"
aws elbv2 describe-target-health --region us-west-2 --target-group-arn ${SECONDARY_TG_ARN}

# Check RDS replication lag
echo "RDS Replication Lag:"
aws cloudwatch get-metric-statistics \
  --region us-west-2 \
  --namespace AWS/RDS \
  --metric-name ReplicaLag \
  --start-time $(date -d '1 hour ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 300 \
  --statistics Average \
  --dimensions Name=DBInstanceIdentifier,Value=dr-webapp-secondary-db

# Check S3 replication status
echo "S3 Replication Status:"
aws s3api head-object \
  --bucket dr-webapp-primary-123456789012 \
  --key health-check-$(date +%Y%m%d).txt \
  --query 'ReplicationStatus'
```

#### 2. Performance Metrics Review
```bash
# Check CloudWatch metrics for the last 24 hours
echo "Performance Metrics Review:"

# ALB response time
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time $(date -d '24 hours ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 3600 \
  --statistics Average,Maximum \
  --dimensions Name=LoadBalancer,Value=${ALB_NAME}

# RDS CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --start-time $(date -d '24 hours ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 3600 \
  --statistics Average,Maximum \
  --dimensions Name=DBInstanceIdentifier,Value=dr-webapp-primary-db
```

### Ongoing Monitoring Tasks

#### Application Health Monitoring
- **Frequency**: Every 5 minutes (automated)
- **Method**: Route 53 health checks + CloudWatch alarms
- **Action Required**: Investigate any health check failures immediately

#### Database Replication Monitoring
- **Frequency**: Every 15 minutes
- **Threshold**: Lag > 60 seconds requires investigation
- **Escalation**: Lag > 300 seconds requires immediate attention

#### Storage Replication Monitoring
- **Frequency**: Hourly
- **Method**: S3 replication metrics
- **Action Required**: Failed replications require investigation

---

## Emergency Procedures

### Disaster Recovery Activation

#### Scenario 1: Primary Region Complete Outage

**Activation Criteria:**
- Primary region ALB returning 5xx errors for >5 minutes
- Multiple AWS services unavailable in primary region
- Route 53 health checks failing consistently

**Immediate Actions (0-15 minutes):**

1. **Assess Situation**
   ```bash
   # Check AWS Service Health Dashboard
   # https://status.aws.amazon.com/
   
   # Verify outage scope
   aws ec2 describe-instances --region us-east-1 --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'
   aws rds describe-db-instances --region us-east-1 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
   ```

2. **Notify Stakeholders**
   ```bash
   # Send initial notification
   aws sns publish \
     --topic-arn arn:aws:sns:us-east-1:123456789012:dr-webapp-alerts \
     --message "ALERT: DR activation initiated due to primary region outage. Investigation in progress."
   ```

3. **Promote Read Replica**
   ```bash
   # Promote secondary database to primary
   aws rds promote-read-replica \
     --region us-west-2 \
     --db-instance-identifier dr-webapp-secondary-db
   
   # Monitor promotion progress
   aws rds describe-events \
     --region us-west-2 \
     --source-identifier dr-webapp-secondary-db \
     --source-type db-instance
   ```

4. **Scale Up Secondary Region**
   ```bash
   # Increase Auto Scaling Group capacity
   aws autoscaling set-desired-capacity \
     --region us-west-2 \
     --auto-scaling-group-name dr-webapp-secondary-asg \
     --desired-capacity 3
   
   # Monitor scaling progress
   aws autoscaling describe-scaling-activities \
     --region us-west-2 \
     --auto-scaling-group-name dr-webapp-secondary-asg
   ```

**Validation Steps (15-30 minutes):**

1. **Test Application Functionality**
   ```bash
   # Test health endpoint
   curl -f http://dr-webapp-secondary-alb-123456789.us-west-2.elb.amazonaws.com/health
   
   # Test database connectivity
   mysql -h dr-webapp-secondary-db.cluster-xyz.us-west-2.rds.amazonaws.com -u admin -p
   
   # Test application critical paths
   curl -X POST http://secondary-alb-dns/api/test-endpoint
   ```

2. **Monitor Performance**
   ```bash
   # Check response times
   aws cloudwatch get-metric-statistics \
     --region us-west-2 \
     --namespace AWS/ApplicationELB \
     --metric-name TargetResponseTime \
     --start-time $(date -d '30 minutes ago' -Iseconds) \
     --end-time $(date -Iseconds) \
     --period 300 \
     --statistics Average
   ```

3. **Update Stakeholders**
   ```bash
   # Send status update
   aws sns publish \
     --topic-arn arn:aws:sns:us-west-2:123456789012:dr-webapp-alerts \
     --message "UPDATE: DR activation complete. Application running in secondary region. Performance normal."
   ```

#### Scenario 2: Partial Service Degradation

**Activation Criteria:**
- Database connectivity issues
- High error rates (>5% 5xx errors)
- Severe performance degradation (>10 second response times)

**Response Actions:**

1. **Immediate Assessment**
   ```bash
   # Check specific service health
   aws elbv2 describe-target-health --target-group-arn ${PRIMARY_TG_ARN}
   
   # Check RDS status
   aws rds describe-db-instances --db-instance-identifier dr-webapp-primary-db
   
   # Check recent CloudWatch alarms
   aws cloudwatch describe-alarm-history --alarm-name dr-webapp-cpu-high
   ```

2. **Mitigation Steps**
   ```bash
   # Scale up if performance issue
   aws autoscaling set-desired-capacity \
     --auto-scaling-group-name dr-webapp-asg \
     --desired-capacity 4
   
   # Restart unhealthy instances if needed
   aws autoscaling terminate-instance-in-auto-scaling-group \
     --instance-id i-1234567890abcdef0 \
     --should-decrement-desired-capacity false
   ```

### Failback Procedures

#### When to Failback
- Primary region services fully restored
- All health checks passing for >30 minutes
- Stakeholder approval obtained
- Maintenance window available

#### Failback Steps

1. **Prepare Primary Region**
   ```bash
   # Recreate read replica in primary region
   aws rds create-db-instance-read-replica \
     --region us-east-1 \
     --db-instance-identifier dr-webapp-primary-replica \
     --source-db-instance-identifier arn:aws:rds:us-west-2:123456789012:db:dr-webapp-secondary-db
   
   # Wait for replica creation
   aws rds wait db-instance-available \
     --region us-east-1 \
     --db-instance-identifier dr-webapp-primary-replica
   ```

2. **Synchronize Data**
   ```bash
   # Ensure S3 data is synchronized
   aws s3 sync s3://dr-webapp-secondary-123456789012 s3://dr-webapp-primary-123456789012 --delete
   
   # Verify synchronization
   aws s3api list-objects-v2 --bucket dr-webapp-primary-123456789012 --query 'KeyCount'
   ```

3. **Gradual Traffic Shift**
   ```bash
   # Use weighted routing for gradual shift
   # 90% secondary, 10% primary initially
   aws route53 change-resource-record-sets \
     --hosted-zone-id Z123456789 \
     --change-batch file://weighted-routing-10-90.json
   
   # Monitor for 30 minutes, then shift to 50-50
   aws route53 change-resource-record-sets \
     --hosted-zone-id Z123456789 \
     --change-batch file://weighted-routing-50-50.json
   
   # Finally shift to 100% primary
   aws route53 change-resource-record-sets \
     --hosted-zone-id Z123456789 \
     --change-batch file://failover-routing.json
   ```

---

## Troubleshooting Guide

### DNS and Route 53 Issues

#### Issue: DNS Failover Not Working

**Symptoms:**
- Primary region down but traffic still routing to primary
- Users receiving timeouts or connection errors
- Route 53 health check shows healthy when it should fail

**Diagnosis:**
```bash
# Check Route 53 health check status
aws route53 get-health-check --health-check-id Z123456789ABC

# Get health check failure reason
aws route53 get-health-check-last-failure-reason --health-check-id Z123456789ABC

# Test DNS resolution
dig example.com
nslookup example.com

# Check current resolved IP
curl -I http://example.com
```

**Common Causes and Solutions:**

1. **Health Check Configuration Issues**
   ```bash
   # Update health check configuration
   aws route53 update-health-check \
     --health-check-id Z123456789ABC \
     --failure-threshold 3 \
     --request-interval 30
   ```

2. **DNS TTL Too High**
   ```bash
   # Update DNS record with lower TTL
   aws route53 change-resource-record-sets \
     --hosted-zone-id Z123456789 \
     --change-batch '{
       "Changes": [{
         "Action": "UPSERT",
         "ResourceRecordSet": {
           "Name": "example.com",
           "Type": "A",
           "TTL": 60,
           "ResourceRecords": [{"Value": "1.2.3.4"}]
         }
       }]
     }'
   ```

3. **Health Check Endpoint Issues**
   ```bash
   # Test endpoint manually
   curl -f http://alb-dns-name/health
   
   # Check ALB target health
   aws elbv2 describe-target-health --target-group-arn ${TG_ARN}
   ```

#### Issue: Slow DNS Resolution

**Diagnosis:**
```bash
# Test DNS resolution time
time nslookup example.com
dig example.com +trace
dig example.com @8.8.8.8

# Check Route 53 query logs
aws logs filter-log-events --log-group-name /aws/route53/example.com
```

**Solutions:**
1. Optimize DNS configuration
2. Use Route 53 resolver in same region
3. Configure DNS failover properly

### Load Balancer Issues

#### Issue: Load Balancer Health Check Failures

**Symptoms:**
- Targets showing as unhealthy
- 502/503 errors from load balancer
- Traffic not distributed to all instances

**Diagnosis:**
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn ${TG_ARN}

# Review load balancer access logs
aws s3 cp s3://alb-logs-bucket/log-file - | grep "5[0-9][0-9]"

# Check load balancer metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time $(date -d '1 hour ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 300 \
  --statistics Average
```

**Solutions:**

1. **Security Group Issues**
   ```bash
   # Fix security group rules
   aws ec2 authorize-security-group-ingress \
     --group-id sg-12345678 \
     --protocol tcp \
     --port 80 \
     --source-group sg-87654321
   ```

2. **Application Not Responding**
   ```bash
   # Check application status on instances
   ssh ec2-user@instance-ip 'sudo systemctl status httpd'
   
   # Restart application if needed
   ssh ec2-user@instance-ip 'sudo systemctl restart httpd'
   ```

3. **Instance Resource Issues**
   ```bash
   # Check instance metrics
   aws cloudwatch get-metric-statistics \
     --namespace AWS/EC2 \
     --metric-name CPUUtilization \
     --dimensions Name=InstanceId,Value=i-1234567890abcdef0
   ```

### Auto Scaling Issues

#### Issue: Auto Scaling Not Triggering

**Symptoms:**
- High CPU/memory but no new instances launching
- Instances not terminating during low usage
- Scaling events not appearing in console

**Diagnosis:**
```bash
# Check Auto Scaling Group status
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names dr-webapp-asg

# Review scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name dr-webapp-asg

# Check scaling policies
aws autoscaling describe-policies --auto-scaling-group-name dr-webapp-asg

# Verify CloudWatch alarms
aws cloudwatch describe-alarms --alarm-names dr-webapp-cpu-high
```

**Solutions:**

1. **CloudWatch Alarm Issues**
   ```bash
   # Check alarm state
   aws cloudwatch describe-alarms \
     --alarm-names dr-webapp-cpu-high \
     --query 'MetricAlarms[0].StateValue'
   
   # Update alarm if needed
   aws cloudwatch put-metric-alarm \
     --alarm-name dr-webapp-cpu-high \
     --alarm-description "Scale up on high CPU" \
     --metric-name CPUUtilization \
     --namespace AWS/EC2 \
     --statistic Average \
     --period 300 \
     --threshold 70 \
     --comparison-operator GreaterThanThreshold
   ```

2. **Scaling Policy Issues**
   ```bash
   # Update scaling policy
   aws autoscaling put-scaling-policy \
     --auto-scaling-group-name dr-webapp-asg \
     --policy-name scale-up \
     --scaling-adjustment 2 \
     --adjustment-type ChangeInCapacity
   ```

### Database Issues

#### Issue: RDS Connection Problems

**Symptoms:**
- Application unable to connect to database
- Connection timeouts
- Too many connections errors

**Diagnosis:**
```bash
# Check RDS instance status
aws rds describe-db-instances --db-instance-identifier dr-webapp-primary-db

# Test database connectivity
mysql -h db-endpoint -u admin -p -e "SELECT 1;"

# Check database metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=dr-webapp-primary-db
```

**Solutions:**

1. **Security Group Issues**
   ```bash
   # Fix database security group
   aws ec2 authorize-security-group-ingress \
     --group-id sg-database123 \
     --protocol tcp \
     --port 3306 \
     --source-group sg-application456
   ```

2. **Connection Pool Exhaustion**
   ```bash
   # Check current connections
   mysql -h db-endpoint -u admin -p \
     -e "SHOW PROCESSLIST;" | wc -l
   
   # Kill long-running connections if needed
   mysql -h db-endpoint -u admin -p \
     -e "SHOW PROCESSLIST;" | awk '/Sleep/ && $6 > 3600 {print "KILL " $1 ";"}'
   ```

#### Issue: RDS Read Replica Lag

**Symptoms:**
- High replication lag in secondary region
- Data inconsistency between regions
- Read replica falling behind

**Diagnosis:**
```bash
# Check replica lag
aws cloudwatch get-metric-statistics \
  --region us-west-2 \
  --namespace AWS/RDS \
  --metric-name ReplicaLag \
  --dimensions Name=DBInstanceIdentifier,Value=dr-webapp-secondary-db

# Check replica status
aws rds describe-db-instances \
  --region us-west-2 \
  --db-instance-identifier dr-webapp-secondary-db
```

**Solutions:**

1. **Scale Replica Instance**
   ```bash
   # Upgrade replica instance class
   aws rds modify-db-instance \
     --region us-west-2 \
     --db-instance-identifier dr-webapp-secondary-db \
     --db-instance-class db.t3.large \
     --apply-immediately
   ```

2. **Create Monitoring Alarm**
   ```bash
   # Create alarm for replica lag
   aws cloudwatch put-metric-alarm \
     --region us-west-2 \
     --alarm-name "RDS-ReplicaLag" \
     --alarm-description "RDS Read Replica Lag" \
     --metric-name ReplicaLag \
     --namespace AWS/RDS \
     --statistic Average \
     --period 300 \
     --threshold 60 \
     --comparison-operator GreaterThanThreshold
   ```

### Storage Issues

#### Issue: S3 Cross-Region Replication Failures

**Symptoms:**
- Objects not replicating to secondary region
- Replication failure notifications
- Inconsistent data between regions

**Diagnosis:**
```bash
# Check replication configuration
aws s3api get-bucket-replication --bucket dr-webapp-primary-123456789012

# Check replication metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name ReplicationLatency \
  --dimensions Name=SourceBucket,Value=dr-webapp-primary-123456789012

# List failed replications
aws s3api list-objects-v2 \
  --bucket dr-webapp-primary-123456789012 \
  --query 'Contents[?ReplicationStatus==`FAILED`]'
```

**Solutions:**

1. **IAM Permission Issues**
   ```bash
   # Check replication role policy
   aws iam get-role-policy \
     --role-name dr-webapp-s3-replication-role \
     --policy-name ReplicationPolicy
   
   # Update policy if needed
   aws iam put-role-policy \
     --role-name dr-webapp-s3-replication-role \
     --policy-name ReplicationPolicy \
     --policy-document file://replication-policy.json
   ```

2. **Test Replication**
   ```bash
   # Test with small file
   echo "test" > test-replication.txt
   aws s3 cp test-replication.txt s3://dr-webapp-primary-123456789012/test/
   
   # Check if file appears in destination
   aws s3 ls s3://dr-webapp-secondary-123456789012/test/
   ```

---

## Monitoring and Alerting

### Key Metrics to Monitor

#### Application Metrics
- **Response Time**: < 2 seconds average
- **Error Rate**: < 1% of requests
- **Availability**: > 99.9% uptime
- **Throughput**: Requests per second

#### Infrastructure Metrics
- **CPU Utilization**: < 80% average
- **Memory Usage**: < 85% of available
- **Disk Usage**: < 80% of available
- **Network Latency**: < 100ms between regions

#### Database Metrics
- **Connection Count**: < 80% of max_connections
- **CPU Utilization**: < 80% average
- **Replication Lag**: < 60 seconds
- **IOPS**: Within provisioned limits

### CloudWatch Alarms Configuration

```bash
# Critical Alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "ALB-HighErrorRate" \
  --alarm-description "ALB error rate exceeds 5%" \
  --metric-name HTTPCode_Target_5XX_Count \
  --namespace AWS/ApplicationELB \
  --statistic Sum \
  --period 300 \
  --threshold 50 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:us-east-1:123456789012:critical-alerts

aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-HighCPU" \
  --alarm-description "RDS CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:us-east-1:123456789012:critical-alerts

# Warning Alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "ALB-HighLatency" \
  --alarm-description "ALB response time exceeds 5 seconds" \
  --metric-name TargetResponseTime \
  --namespace AWS/ApplicationELB \
  --statistic Average \
  --period 300 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:us-east-1:123456789012:warning-alerts
```

### Dashboard Configuration

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "dr-webapp-alb"],
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "dr-webapp-alb"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Primary Region - ALB Performance"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "dr-webapp-primary-db"],
          ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "dr-webapp-primary-db"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Primary Region - RDS Performance"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/RDS", "ReplicaLag", "DBInstanceIdentifier", "dr-webapp-secondary-db"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-west-2",
        "title": "Secondary Region - Replication Lag"
      }
    }
  ]
}
```

---

## Maintenance Procedures

### Weekly Maintenance Tasks

#### System Health Review
1. **Review CloudWatch Metrics**
   - Check all key performance indicators
   - Identify trending issues
   - Update capacity planning

2. **Backup Verification**
   ```bash
   # Verify RDS automated backups
   aws rds describe-db-snapshots \
     --db-instance-identifier dr-webapp-primary-db \
     --snapshot-type automated
   
   # Test S3 replication
   aws s3api head-object \
     --bucket dr-webapp-primary-123456789012 \
     --key weekly-test-$(date +%Y%m%d).txt
   ```

3. **Security Review**
   - Review IAM access logs
   - Check security group changes
   - Validate encryption status

#### Health Check Testing
```bash
# Automated health check script
#!/bin/bash
echo "=== Weekly Health Check - $(date) ==="

# Test primary region
echo "Testing primary region..."
curl -f http://primary-alb-dns/health || echo "PRIMARY HEALTH CHECK FAILED"

# Test secondary region
echo "Testing secondary region..."
curl -f http://secondary-alb-dns/health || echo "SECONDARY HEALTH CHECK FAILED"

# Test database connectivity
echo "Testing database..."
mysql -h primary-db-endpoint -u admin -p${DB_PASSWORD} -e "SELECT 1;" || echo "DATABASE CONNECTION FAILED"

# Generate weekly report
echo "Health check completed at $(date)" >> weekly-health-report.log
```

### Monthly Maintenance Tasks

#### Disaster Recovery Testing
1. **Scheduled DR Test**
   ```bash
   # Simulate failover (during maintenance window)
   echo "Starting DR test at $(date)"
   
   # Record baseline metrics
   aws cloudwatch get-metric-statistics \
     --namespace AWS/ApplicationELB \
     --metric-name RequestCount \
     --start-time $(date -d '1 hour ago' -Iseconds) \
     --end-time $(date -Iseconds)
   
   # Initiate controlled failover
   aws route53 change-resource-record-sets \
     --hosted-zone-id Z123456789 \
     --change-batch file://test-failover.json
   
   # Monitor and measure
   ./measure-failover-time.sh
   
   # Restore normal operation
   aws route53 change-resource-record-sets \
     --hosted-zone-id Z123456789 \
     --change-batch file://restore-primary.json
   ```

2. **Performance Baseline Update**
   - Update performance thresholds
   - Review and adjust auto-scaling policies
   - Update capacity planning

#### Security Updates
1. **Patch Management**
   ```bash
   # Update launch template with latest AMI
   LATEST_AMI=$(aws ec2 describe-images \
     --owners amazon \
     --filters "Name=name,Values=amzn2-ami-hvm-*" \
     --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
     --output text)
   
   # Create new launch template version
   aws ec2 create-launch-template-version \
     --launch-template-name dr-webapp-launch-template \
     --source-version 1 \
     --launch-template-data '{"ImageId":"'${LATEST_AMI}'"}'
   ```

2. **Key Rotation**
   ```bash
   # Rotate KMS keys
   aws kms enable-key-rotation --key-id alias/dr-webapp-primary
   aws kms enable-key-rotation --key-id alias/dr-webapp-secondary
   
   # Update access keys (if using)
   aws iam create-access-key --user-name dr-webapp-user
   ```

### Quarterly Maintenance Tasks

#### Architecture Review
1. **Cost Optimization Review**
   - Analyze usage patterns
   - Right-size instances
   - Review Reserved Instance utilization

2. **Performance Optimization**
   - Review and tune database performance
   - Optimize application code
   - Update caching strategies

3. **Capacity Planning**
   - Forecast growth requirements
   - Plan infrastructure scaling
   - Update disaster recovery capacity

---

## Performance Optimization

### Application Performance Tuning

#### Database Optimization
```sql
-- Identify slow queries
SELECT * FROM mysql.slow_log 
WHERE start_time > DATE_SUB(NOW(), INTERVAL 1 HOUR)
ORDER BY query_time DESC;

-- Check query execution plans
EXPLAIN SELECT * FROM users WHERE email = 'example@domain.com';

-- Review index usage
SHOW INDEX FROM users;

-- Optimize table structure
OPTIMIZE TABLE users;
```

#### Application Caching
```bash
# Implement ElastiCache for session storage
aws elasticache create-cache-cluster \
  --cache-cluster-id dr-webapp-cache \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1

# Configure application to use cache
# Update application configuration with cache endpoint
```

### Infrastructure Optimization

#### Instance Right-Sizing
```bash
# Monitor instance utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --start-time $(date -d '7 days ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 3600 \
  --statistics Average,Maximum

# Analyze and recommend instance types
aws compute-optimizer get-ec2-instance-recommendations
```

#### Network Optimization
```bash
# Enable enhanced networking
aws ec2 modify-instance-attribute \
  --instance-id i-1234567890abcdef0 \
  --ena-support

# Monitor network performance
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name NetworkIn \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0
```

---

## Security Operations

### Security Monitoring

#### CloudTrail Log Analysis
```bash
# Monitor for suspicious API calls
aws logs filter-log-events \
  --log-group-name CloudTrail/dr-webapp \
  --filter-pattern "{ ($.errorCode = *Exception) || ($.errorCode = *Error) }" \
  --start-time $(date -d '24 hours ago' +%s)000

# Check for root account usage
aws logs filter-log-events \
  --log-group-name CloudTrail/dr-webapp \
  --filter-pattern "{ $.userIdentity.type = Root }" \
  --start-time $(date -d '24 hours ago' +%s)000
```

#### VPC Flow Log Analysis
```bash
# Analyze network traffic patterns
aws logs filter-log-events \
  --log-group-name /aws/vpc/flowlogs \
  --filter-pattern "[time, account, eni, source, destination, srcport, destport=22, protocol=6, packets, bytes, windowstart, windowend, action=REJECT]" \
  --start-time $(date -d '24 hours ago' +%s)000
```

### Incident Response

#### Security Incident Procedure
1. **Immediate Containment**
   ```bash
   # Isolate affected instances
   aws ec2 modify-instance-attribute \
     --instance-id i-compromised123 \
     --groups sg-quarantine
   
   # Disable compromised user accounts
   aws iam attach-user-policy \
     --user-name compromised-user \
     --policy-arn arn:aws:iam::aws:policy/AWSDenyAll
   ```

2. **Investigation**
   ```bash
   # Create forensic snapshots
   aws ec2 create-snapshot \
     --volume-id vol-compromised123 \
     --description "Forensic snapshot - $(date)"
   
   # Collect logs
   aws logs create-export-task \
     --log-group-name /aws/ec2/security \
     --from $(date -d '7 days ago' +%s)000 \
     --to $(date +%s)000 \
     --destination s3://security-logs-bucket
   ```

3. **Recovery**
   ```bash
   # Replace compromised instances
   aws autoscaling terminate-instance-in-auto-scaling-group \
     --instance-id i-compromised123 \
     --should-decrement-desired-capacity false
   
   # Rotate credentials
   aws iam update-access-key \
     --access-key-id AKIA... \
     --status Inactive
   ```

---

## Support and Escalation

### Internal Support Structure
1. **Level 1**: Operations team (initial response)
2. **Level 2**: Engineering team (technical issues)
3. **Level 3**: Architecture team (design issues)
4. **Level 4**: AWS Support (platform issues)

### Emergency Contact Procedure
1. **Critical Issues**: Page on-call engineer immediately
2. **High Priority**: Email operations team within 1 hour
3. **Medium Priority**: Create ticket within 4 hours
4. **Low Priority**: Email team within 24 hours

### AWS Support Integration
```bash
# Create AWS Support case
aws support create-case \
  --subject "DR Solution Performance Issue" \
  --service-code "amazon-ec2" \
  --severity-code "high" \
  --category-code "performance" \
  --communication-body "Detailed description of the issue..."

# Check case status
aws support describe-cases --case-id-list case-12345678
```

---

## Documentation Maintenance

### Update Procedures
- Update runbook after each incident
- Review procedures quarterly
- Validate all commands and scripts
- Share knowledge with team members

### Version Control
- Maintain runbook in version control
- Track changes and approvals
- Regular backup of documentation
- Ensure team access to latest version

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Next Review**: April 2025  
**Maintained By**: Operations Team