# Troubleshooting Guide - AWS Disaster Recovery

## Overview

This document provides comprehensive troubleshooting procedures for AWS disaster recovery solutions, including common issues, diagnostic steps, and resolution strategies.

---

## Common Issues and Resolutions

### 1. Route 53 Health Check Failures

#### Symptoms
- Health check status shows FAILURE
- DNS failover not triggering
- Application appears unreachable

#### Diagnostic Steps
```bash
# Check health check status
aws route53 get-health-check --health-check-id Z1234567890ABC

# Get failure reason
aws route53 get-health-check-last-failure-reason --health-check-id Z1234567890ABC

# Test endpoint manually
curl -v http://app.example.com/health
curl -v https://app.example.com/health

# Check from multiple locations
dig +short app.example.com @8.8.8.8
dig +short app.example.com @1.1.1.1
```

#### Common Causes & Resolutions
1. **Security Group Issues**
   - Verify ALB security group allows health check traffic
   - Ensure health checker IPs are whitelisted
   ```bash
   aws ec2 describe-security-groups --group-ids sg-12345678
   ```

2. **Application Load Balancer Issues**
   - Check ALB target health
   - Verify target group configuration
   ```bash
   aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...
   ```

3. **Health Endpoint Issues**
   - Verify /health endpoint returns HTTP 200
   - Check application logs for errors
   ```bash
   # Test health endpoint
   curl -f http://internal-alb/health
   ```

---

### 2. RDS Replication Lag Issues

#### Symptoms
- Replication lag > 300 seconds
- Data inconsistency between regions
- Failed read operations on replica

#### Diagnostic Steps
```bash
# Check replication lag
aws cloudwatch get-metric-statistics \
  --region us-west-2 \
  --namespace AWS/RDS \
  --metric-name ReplicaLag \
  --dimensions Name=DBInstanceIdentifier,Value=dr-webapp-replica \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum
```

```sql
-- Check replication status on replica
SHOW SLAVE STATUS\G

-- Check for blocking queries
SHOW PROCESSLIST;

-- Check binary log position
SHOW MASTER STATUS;
```

#### Common Causes & Resolutions
1. **High Write Load**
   - Scale up replica instance class
   - Optimize write-heavy queries
   ```bash
   aws rds modify-db-instance \
     --db-instance-identifier dr-webapp-replica \
     --db-instance-class db.t3.large \
     --apply-immediately
   ```

2. **Network Issues**
   - Check network connectivity between regions
   - Verify security groups allow replication traffic
   ```bash
   # Test connectivity
   telnet primary-db-endpoint 3306
   ```

3. **Long-Running Transactions**
   - Identify and optimize long transactions
   - Consider read-only mode during high lag
   ```sql
   -- Find long-running transactions
   SELECT * FROM information_schema.processlist 
   WHERE command != 'Sleep' AND time > 300;
   ```

---

### 3. S3 Cross-Region Replication Issues

#### Symptoms
- Objects not replicating to secondary bucket
- High replication latency
- Replication failure notifications

#### Diagnostic Steps
```bash
# Check replication configuration
aws s3api get-bucket-replication --bucket dr-webapp-primary-123456789012

# Check replication metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name ReplicationLatency \
  --dimensions Name=SourceBucket,Value=dr-webapp-primary-123456789012 \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum

# Test replication manually
echo "test-$(date)" > test-file.txt
aws s3 cp test-file.txt s3://dr-webapp-primary-123456789012/test/
sleep 60
aws s3 ls s3://dr-webapp-secondary-123456789012/test/
```

#### Common Causes & Resolutions
1. **IAM Permission Issues**
   - Verify replication role has correct permissions
   - Check cross-account access if applicable
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "s3:GetObjectVersionForReplication",
           "s3:GetObjectVersionAcl"
         ],
         "Resource": "arn:aws:s3:::source-bucket/*"
       }
     ]
   }
   ```

2. **Object Size Issues**
   - Large objects may take longer to replicate
   - Consider multipart upload for large files
   ```bash
   # Configure multipart threshold
   aws configure set s3.multipart_threshold 64MB
   ```

3. **Encryption Key Access**
   - Verify KMS key permissions for cross-region access
   - Check key policies allow replication service
   ```bash
   aws kms describe-key --key-id alias/s3-replication-key
   ```

---

### 4. Auto Scaling Issues

#### Symptoms
- Instances not scaling during failover
- Scaling activities timing out
- Unhealthy instances in Auto Scaling group

#### Diagnostic Steps
```bash
# Check Auto Scaling group status
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names dr-webapp-secondary-asg

# Check scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name dr-webapp-secondary-asg \
  --max-items 10

# Check instance health
aws autoscaling describe-auto-scaling-instances \
  --instance-ids i-1234567890abcdef0
```

#### Common Causes & Resolutions
1. **AMI Issues**
   - Verify AMI exists in target region
   - Check AMI permissions and encryption
   ```bash
   aws ec2 describe-images --image-ids ami-12345678 --region us-west-2
   ```

2. **Launch Template Issues**
   - Verify launch template configuration
   - Check security groups and subnets exist
   ```bash
   aws ec2 describe-launch-templates --launch-template-names dr-webapp-template
   ```

3. **Service Quotas**
   - Check EC2 instance limits in region
   - Request quota increases if needed
   ```bash
   aws service-quotas get-service-quota \
     --service-code ec2 \
     --quota-code L-1216C47A
   ```

---

### 5. Lambda Failover Function Issues

#### Symptoms
- Failover Lambda function timing out
- Errors in function execution
- Incomplete failover process

#### Diagnostic Steps
```bash
# Check Lambda function logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/dr-failover

# Get recent log events
aws logs get-log-events \
  --log-group-name /aws/lambda/dr-failover-function \
  --log-stream-name $(aws logs describe-log-streams \
    --log-group-name /aws/lambda/dr-failover-function \
    --order-by LastEventTime \
    --descending \
    --max-items 1 \
    --query 'logStreams[0].logStreamName' \
    --output text)

# Test function manually
aws lambda invoke \
  --function-name dr-failover-function \
  --payload '{"test": true}' \
  response.json
```

#### Common Causes & Resolutions
1. **Timeout Issues**
   - Increase Lambda timeout setting
   - Optimize function code for performance
   ```bash
   aws lambda update-function-configuration \
     --function-name dr-failover-function \
     --timeout 900
   ```

2. **Permission Issues**
   - Verify Lambda execution role permissions
   - Check cross-region access permissions
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "rds:PromoteReadReplica",
           "autoscaling:SetDesiredCapacity",
           "route53:ChangeResourceRecordSets"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

3. **VPC Configuration**
   - Check VPC endpoint configuration
   - Verify subnets and security groups
   ```bash
   aws lambda get-function-configuration --function-name dr-failover-function
   ```

---

### 6. Network Connectivity Issues

#### Symptoms
- Cannot reach secondary region resources
- High latency between regions
- Intermittent connection failures

#### Diagnostic Steps
```bash
# Test basic connectivity
ping -c 10 secondary-alb.us-west-2.elb.amazonaws.com
traceroute secondary-alb.us-west-2.elb.amazonaws.com

# Test specific ports
nc -zv secondary-db.us-west-2.rds.amazonaws.com 3306

# Check VPC peering/Transit Gateway
aws ec2 describe-vpc-peering-connections
aws ec2 describe-transit-gateways

# Monitor bandwidth
iperf3 -c test-endpoint -t 60
```

#### Common Causes & Resolutions
1. **Security Group Rules**
   - Verify cross-region security group rules
   - Check NACLs for blocking rules
   ```bash
   aws ec2 describe-security-groups --group-ids sg-12345678
   aws ec2 describe-network-acls --network-acl-ids acl-12345678
   ```

2. **Route Table Issues**
   - Check route tables for proper routing
   - Verify internet gateway/NAT gateway routes
   ```bash
   aws ec2 describe-route-tables --route-table-ids rtb-12345678
   ```

3. **DNS Resolution**
   - Verify DNS resolution works correctly
   - Check Route 53 resolver configuration
   ```bash
   nslookup secondary-alb.us-west-2.elb.amazonaws.com
   dig +trace secondary-alb.us-west-2.elb.amazonaws.com
   ```

---

## Performance Troubleshooting

### 7. Application Performance Issues

#### Symptoms
- High response times after failover
- Database connection timeouts
- Memory or CPU exhaustion

#### Diagnostic Steps
```bash
# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=app/dr-webapp-alb/1234567890123456 \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum

# Check instance metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum
```

#### Resolutions
1. **Scale Resources**
   ```bash
   # Scale up Auto Scaling group
   aws autoscaling set-desired-capacity \
     --auto-scaling-group-name dr-webapp-secondary-asg \
     --desired-capacity 5
   
   # Scale up database instance
   aws rds modify-db-instance \
     --db-instance-identifier dr-webapp-secondary-db \
     --db-instance-class db.r5.large \
     --apply-immediately
   ```

2. **Optimize Application Configuration**
   - Increase connection pool sizes
   - Adjust memory settings
   - Enable application caching

---

## Monitoring and Alerting Issues

### 8. CloudWatch Alert Issues

#### Symptoms
- Alerts not firing when expected
- False positive alerts
- Missing alert notifications

#### Diagnostic Steps
```bash
# Check alarm configuration
aws cloudwatch describe-alarms --alarm-names dr-webapp-high-cpu

# Check alarm history
aws cloudwatch describe-alarm-history --alarm-name dr-webapp-high-cpu

# Test SNS topic
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:123456789012:dr-alerts \
  --message "Test alert message"
```

#### Resolutions
1. **Adjust Alarm Thresholds**
   ```bash
   aws cloudwatch put-metric-alarm \
     --alarm-name dr-webapp-high-cpu \
     --alarm-description "High CPU utilization" \
     --metric-name CPUUtilization \
     --namespace AWS/EC2 \
     --statistic Average \
     --period 300 \
     --threshold 80 \
     --comparison-operator GreaterThanThreshold \
     --evaluation-periods 2
   ```

2. **Verify SNS Subscriptions**
   ```bash
   aws sns list-subscriptions-by-topic \
     --topic-arn arn:aws:sns:us-east-1:123456789012:dr-alerts
   ```

---

## Emergency Procedures

### 9. Manual Failover Steps

When automated failover fails, follow these manual steps:

```bash
#!/bin/bash
# emergency-manual-failover.sh

echo "EMERGENCY: Executing manual failover"

# 1. Scale up secondary region immediately
aws autoscaling set-desired-capacity \
  --region us-west-2 \
  --auto-scaling-group-name dr-webapp-secondary-asg \
  --desired-capacity 5

# 2. Promote read replica
aws rds promote-read-replica \
  --region us-west-2 \
  --db-instance-identifier dr-webapp-secondary-db

# 3. Update Route 53 manually
cat > emergency-failover.json << EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "app.example.com",
        "Type": "A",
        "SetIdentifier": "Primary",
        "Failover": "PRIMARY",
        "AliasTarget": {
          "DNSName": "secondary-alb.us-west-2.elb.amazonaws.com",
          "EvaluateTargetHealth": true,
          "HostedZoneId": "Z1H1FL5HABSF5"
        }
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://emergency-failover.json

echo "Manual failover initiated. Monitor application health."
```

### 10. Rollback Procedures

If failover causes issues, use these rollback steps:

```bash
#!/bin/bash
# emergency-rollback.sh

echo "EMERGENCY: Rolling back to primary region"

# 1. Update Route 53 back to primary
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://rollback-to-primary.json

# 2. Scale down secondary region
aws autoscaling set-desired-capacity \
  --region us-west-2 \
  --auto-scaling-group-name dr-webapp-secondary-asg \
  --desired-capacity 1

echo "Rollback initiated. Verify primary region health."
```

---

## Support and Escalation

### 11. Escalation Matrix

| Severity | Response Time | Escalation Path |
|----------|---------------|-----------------|
| Critical | 15 minutes | Operations Manager → CTO |
| High | 1 hour | Senior Engineer → Operations Manager |
| Medium | 4 hours | Engineer → Senior Engineer |
| Low | Next business day | Engineer |

### 12. Emergency Contacts

```yaml
Primary Contacts:
  Operations Team: +1-555-0123
  Network Team: +1-555-0124
  Database Team: +1-555-0125

Vendor Support:
  AWS Enterprise Support: +1-206-266-4064
  Case URL: https://console.aws.amazon.com/support/

Internal Escalation:
  Operations Manager: manager@company.com
  CTO: cto@company.com
```

### 13. Useful Commands Reference

```bash
# Quick health check script
#!/bin/bash
echo "=== DR Health Check ==="
curl -f http://app.example.com/health && echo "Primary: OK" || echo "Primary: FAIL"
curl -f http://dr-app.us-west-2.elb.amazonaws.com/health && echo "Secondary: OK" || echo "Secondary: FAIL"

# Database connectivity test
mysql -h primary-db -u admin -p -e "SELECT 1;" && echo "Primary DB: OK" || echo "Primary DB: FAIL"
mysql -h secondary-db -u admin -p -e "SELECT 1;" && echo "Secondary DB: OK" || echo "Secondary DB: FAIL"

# Replication lag check
aws cloudwatch get-metric-statistics \
  --region us-west-2 \
  --namespace AWS/RDS \
  --metric-name ReplicaLag \
  --dimensions Name=DBInstanceIdentifier,Value=dr-webapp-replica \
  --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --query 'Datapoints[0].Average'
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: DR Operations Team