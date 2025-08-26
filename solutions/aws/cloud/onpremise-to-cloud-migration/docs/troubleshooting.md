# Troubleshooting Guide - AWS Cloud Migration

## Overview

This document provides comprehensive troubleshooting procedures for AWS cloud migration projects, including common issues, diagnostic steps, and resolution strategies for AWS MGN, DMS, and SMS services.

---

## Migration Service Issues

### 1. AWS Application Migration Service (MGN) Issues

#### Symptoms
- Source server not replicating
- High replication lag
- Launch test failures
- Cutover issues

#### Diagnostic Steps
```bash
# Check source server status
aws mgn describe-source-servers --source-server-ids s-1234567890abcdef0

# Check replication status
aws mgn describe-source-servers \
  --source-server-ids s-1234567890abcdef0 \
  --query 'items[0].dataReplicationInfo'

# Check jobs status
aws mgn describe-jobs --filters jobType=LAUNCH

# Review MGN logs
aws logs describe-log-groups --log-group-name-prefix /aws/mgn
```

#### Common Causes & Resolutions

1. **Agent Installation Issues**
   ```bash
   # Verify agent is running on source server
   sudo systemctl status aws-replication-agent
   
   # Check agent logs
   sudo tail -f /opt/aws/aws-replication-agent/logs/agent.log
   
   # Reinstall agent if needed
   sudo /opt/aws/aws-replication-agent/bin/installer --remove
   wget -O ./aws-replication-installer-init https://aws-application-migration-service-us-east-1.s3.us-east-1.amazonaws.com/latest/linux/aws-replication-installer-init
   sudo python3 aws-replication-installer-init --region us-east-1
   ```

2. **Network Connectivity Issues**
   ```bash
   # Test connectivity to MGN endpoints
   curl -I https://mgn.us-east-1.amazonaws.com
   
   # Check firewall rules
   sudo iptables -L | grep -E "(443|22)"
   
   # Test bandwidth
   wget --output-document=/dev/null --report-speed=bits https://speed.cloudflare.com/__down?bytes=25000000
   ```

3. **Disk Space Issues**
   ```bash
   # Check disk usage on source
   df -h
   
   # Check staging area on target
   aws ec2 describe-volumes --filters Name=tag:Name,Values=*mgn-staging*
   
   # Increase staging area size if needed
   aws ec2 modify-volume --volume-id vol-1234567890abcdef0 --size 200
   ```

4. **IAM Permission Issues**
   ```bash
   # Verify MGN service role permissions
   aws iam get-role --role-name AWSApplicationMigrationServiceRole
   
   # Check EC2 permissions
   aws sts get-caller-identity
   aws ec2 describe-instances --dry-run
   ```

---

### 2. AWS Database Migration Service (DMS) Issues

#### Symptoms
- Migration task failures
- High replication lag
- Data validation errors
- Connection failures

#### Diagnostic Steps
```bash
# Check DMS task status
aws dms describe-replication-tasks --filters Name=replication-task-id,Values=task-12345

# Check task statistics
aws dms describe-table-statistics --replication-task-arn arn:aws:dms:us-east-1:123456789012:task:task-12345

# Review DMS logs
aws logs describe-log-groups --log-group-name-prefix /aws/dms
aws logs get-log-events --log-group-name /aws/dms/task/task-12345
```

#### Common Causes & Resolutions

1. **Connection Issues**
   ```bash
   # Test source database connectivity
   mysql -h source-db.company.local -u migrationuser -p -e "SELECT 1;"
   
   # Test target database connectivity
   mysql -h target-db.cluster-xyz.us-east-1.rds.amazonaws.com -u admin -p -e "SELECT 1;"
   
   # Check security groups
   aws ec2 describe-security-groups --group-ids sg-12345678
   
   # Test from DMS replication instance
   aws dms test-connection \
     --replication-instance-arn arn:aws:dms:us-east-1:123456789012:rep:rep-instance \
     --endpoint-arn arn:aws:dms:us-east-1:123456789012:endpoint:endpoint-12345
   ```

2. **Data Type Conversion Issues**
   ```sql
   -- Check for unsupported data types
   SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE 
   FROM information_schema.columns 
   WHERE TABLE_SCHEMA = 'production' 
   AND DATA_TYPE IN ('ENUM', 'SET', 'JSON');
   
   -- Create transformation rules
   -- Example DMS transformation rule for ENUM to VARCHAR
   {
     "rule-type": "transformation",
     "rule-id": "1",
     "rule-name": "enum-to-varchar",
     "rule-action": "change-data-type",
     "rule-target": "column",
     "object-locator": {
       "schema-name": "production",
       "table-name": "users",
       "column-name": "status"
     },
     "data-type": {
       "type": "string",
       "length": 50
     }
   }
   ```

3. **Large Object (LOB) Issues**
   ```bash
   # Configure LOB settings in DMS task
   aws dms modify-replication-task \
     --replication-task-arn arn:aws:dms:us-east-1:123456789012:task:task-12345 \
     --replication-task-settings '{
       "TargetMetadata": {
         "SupportLobs": true,
         "FullLobMode": false,
         "LobChunkSize": 64,
         "LimitedSizeLobMode": true,
         "LobMaxSize": 32
       }
     }'
   ```

4. **Performance Optimization**
   ```bash
   # Scale up replication instance
   aws dms modify-replication-instance \
     --replication-instance-arn arn:aws:dms:us-east-1:123456789012:rep:rep-instance \
     --replication-instance-class dms.r5.xlarge \
     --apply-immediately
   
   # Optimize table settings
   aws dms modify-replication-task \
     --replication-task-arn arn:aws:dms:us-east-1:123456789012:task:task-12345 \
     --table-mappings '{
       "rules": [
         {
           "rule-type": "table-settings",
           "rule-id": "1",
           "rule-name": "optimize-large-tables",
           "object-locator": {
             "schema-name": "production",
             "table-name": "large_table"
           },
           "parallel-load": {
             "type": "partitions-auto"
           }
         }
       ]
     }'
   ```

---

### 3. AWS Server Migration Service (SMS) Issues

#### Symptoms
- Replication job failures
- AMI generation errors
- Launch failures
- Network configuration issues

#### Diagnostic Steps
```bash
# Check SMS replication jobs
aws sms get-replication-jobs

# Check replication runs
aws sms get-replication-runs --replication-job-id sms-job-12345

# Check connectors
aws sms get-connectors

# Review SMS service role
aws iam get-role --role-name sms
```

#### Common Causes & Resolutions

1. **VMware Connector Issues**
   ```bash
   # Check connector status
   aws sms get-connectors --query 'connectorList[?connectorId==`c-12345`]'
   
   # Re-register connector if needed
   # On VMware vCenter:
   # 1. Download new OVA template
   # 2. Deploy connector VM
   # 3. Configure with AWS credentials
   ```

2. **Replication Frequency Issues**
   ```bash
   # Modify replication frequency
   aws sms update-replication-job \
     --replication-job-id sms-job-12345 \
     --frequency 24 \
     --next-replication-run-start-time $(date -d "+1 hour" --iso-8601)
   ```

3. **IAM Role Issues**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "ec2:CreateImage",
           "ec2:CreateSnapshot",
           "ec2:CreateTags",
           "ec2:DescribeImages",
           "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

---

## Network and Connectivity Issues

### 4. Hybrid Connectivity Problems

#### Symptoms
- Cannot reach on-premise resources
- High latency between on-premise and AWS
- VPN connection drops
- DNS resolution failures

#### Diagnostic Steps
```bash
# Test VPN connectivity
aws ec2 describe-vpn-connections

# Check VPN tunnel status
aws ec2 describe-vpn-connections --query 'VpnConnections[0].VgwTelemetry'

# Test Direct Connect
aws directconnect describe-connections

# Network diagnostics
ping -c 10 on-premise-server.company.local
traceroute on-premise-server.company.local
nslookup on-premise-server.company.local
```

#### Resolutions

1. **VPN Configuration Issues**
   ```bash
   # Check route tables
   aws ec2 describe-route-tables --route-table-ids rtb-12345678
   
   # Add routes if needed
   aws ec2 create-route \
     --route-table-id rtb-12345678 \
     --destination-cidr-block 192.168.0.0/16 \
     --gateway-id vgw-12345678
   
   # Check security groups
   aws ec2 authorize-security-group-ingress \
     --group-id sg-12345678 \
     --protocol tcp \
     --port 443 \
     --cidr 192.168.0.0/16
   ```

2. **DNS Resolution Issues**
   ```bash
   # Configure DNS forwarding
   aws route53resolver create-resolver-rule \
     --creator-request-id $(uuidgen) \
     --domain-name company.local \
     --rule-type FORWARD \
     --resolver-endpoint-id rslvr-in-12345678 \
     --target-ips Ip=192.168.1.10,Port=53
   ```

---

## Application Migration Issues

### 5. Application Compatibility Problems

#### Symptoms
- Application fails to start on AWS
- Missing dependencies
- Configuration errors
- Performance degradation

#### Diagnostic Steps
```bash
# Check application logs
sudo journalctl -u application-service -f

# Check system resources
top
htop
iostat 1

# Check network connectivity
netstat -tulpn
ss -tulpn

# Check file permissions
ls -la /opt/application/
sudo find /opt/application/ -type f -name "*.conf" -exec ls -l {} \;
```

#### Resolutions

1. **Dependency Issues**
   ```bash
   # Install missing packages
   sudo yum update -y
   sudo yum install -y missing-package
   
   # For Ubuntu/Debian
   sudo apt update
   sudo apt install -y missing-package
   
   # Check for library compatibility
   ldd /opt/application/binary
   ```

2. **Configuration Updates**
   ```bash
   # Update database connection strings
   sudo sed -i 's/old-db-server/new-rds-endpoint.amazonaws.com/g' /opt/application/config.conf
   
   # Update API endpoints
   sudo sed -i 's/internal-api.company.local/api.company.com/g' /opt/application/config.conf
   ```

3. **Performance Tuning**
   ```bash
   # Increase file descriptor limits
   echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
   echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
   
   # Optimize network settings
   echo "net.core.rmem_max = 16777216" | sudo tee -a /etc/sysctl.conf
   echo "net.core.wmem_max = 16777216" | sudo tee -a /etc/sysctl.conf
   sudo sysctl -p
   ```

---

## Database Migration Issues

### 6. Data Validation Problems

#### Symptoms
- Row count mismatches
- Data corruption
- Missing indexes
- Performance degradation

#### Diagnostic Steps
```sql
-- Compare row counts
SELECT 'source' as location, COUNT(*) as row_count FROM source_table
UNION ALL
SELECT 'target' as location, COUNT(*) as row_count FROM target_table;

-- Check for data consistency
SELECT 
    source.id, 
    source.checksum as source_checksum,
    target.checksum as target_checksum
FROM (
    SELECT id, MD5(CONCAT_WS('|', col1, col2, col3)) as checksum 
    FROM source_table
) source
LEFT JOIN (
    SELECT id, MD5(CONCAT_WS('|', col1, col2, col3)) as checksum 
    FROM target_table
) target ON source.id = target.id
WHERE source.checksum != target.checksum OR target.checksum IS NULL;

-- Check indexes
SHOW INDEX FROM target_table;
```

#### Resolutions

1. **Data Consistency Issues**
   ```sql
   -- Re-sync specific tables
   DELETE FROM target_table WHERE id IN (SELECT id FROM inconsistent_records);
   INSERT INTO target_table SELECT * FROM source_table WHERE id IN (SELECT id FROM inconsistent_records);
   
   -- Add missing records
   INSERT INTO target_table 
   SELECT * FROM source_table s
   WHERE NOT EXISTS (SELECT 1 FROM target_table t WHERE t.id = s.id);
   ```

2. **Index Recreation**
   ```sql
   -- Recreate missing indexes
   CREATE INDEX idx_user_email ON users(email);
   CREATE INDEX idx_order_date ON orders(order_date);
   CREATE INDEX idx_product_category ON products(category_id);
   
   -- Analyze tables for optimal query plans
   ANALYZE TABLE users, orders, products;
   ```

---

## Security Issues

### 7. Security Group and Access Issues

#### Symptoms
- Connection timeouts
- Access denied errors
- SSL/TLS handshake failures

#### Diagnostic Steps
```bash
# Check security groups
aws ec2 describe-security-groups --group-ids sg-12345678

# Test specific ports
nc -zv target-server 3306
nc -zv target-server 443

# Check SSL certificates
openssl s_client -connect target-server:443 -servername target-server

# Verify IAM permissions
aws sts get-caller-identity
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/migration-user \
  --action-names ec2:DescribeInstances \
  --resource-arns "*"
```

#### Resolutions

1. **Security Group Updates**
   ```bash
   # Add necessary inbound rules
   aws ec2 authorize-security-group-ingress \
     --group-id sg-12345678 \
     --protocol tcp \
     --port 3306 \
     --source-group sg-87654321
   
   # Add outbound rules
   aws ec2 authorize-security-group-egress \
     --group-id sg-12345678 \
     --protocol tcp \
     --port 443 \
     --cidr 0.0.0.0/0
   ```

2. **SSL Certificate Issues**
   ```bash
   # Request new certificate
   aws acm request-certificate \
     --domain-name app.company.com \
     --validation-method DNS
   
   # Install certificate on load balancer
   aws elbv2 modify-listener \
     --listener-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/1234567890123456/1234567890123456 \
     --certificates CertificateArn=arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
   ```

---

## Performance Issues

### 8. Slow Migration Performance

#### Symptoms
- Low throughput during migration
- High replication lag
- Resource exhaustion

#### Diagnostic Steps
```bash
# Monitor DMS performance
aws cloudwatch get-metric-statistics \
  --namespace AWS/DMS \
  --metric-name CDCLatencySource \
  --dimensions Name=ReplicationInstanceIdentifier,Value=rep-instance \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Check resource utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/DMS \
  --metric-name CPUUtilization \
  --dimensions Name=ReplicationInstanceIdentifier,Value=rep-instance \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

#### Resolutions

1. **Scale Migration Resources**
   ```bash
   # Scale up DMS replication instance
   aws dms modify-replication-instance \
     --replication-instance-arn arn:aws:dms:us-east-1:123456789012:rep:rep-instance \
     --replication-instance-class dms.r5.2xlarge \
     --apply-immediately
   
   # Add more parallel connections
   aws dms modify-replication-task \
     --replication-task-arn arn:aws:dms:us-east-1:123456789012:task:task-12345 \
     --replication-task-settings '{
       "TargetMetadata": {
         "ParallelLoadThreads": 8,
         "ParallelLoadBufferSize": 250
       }
     }'
   ```

2. **Optimize Network Bandwidth**
   ```bash
   # Use Enhanced Networking
   aws ec2 modify-instance-attribute \
     --instance-id i-1234567890abcdef0 \
     --ena-support
   
   # Enable Placement Groups for high bandwidth
   aws ec2 create-placement-group \
     --group-name migration-pg \
     --strategy cluster
   ```

---

## Emergency Procedures

### 9. Migration Rollback

When migration fails and rollback is needed:

```bash
#!/bin/bash
# migration-rollback.sh

echo "EMERGENCY: Initiating migration rollback"

# 1. Stop DMS tasks
aws dms stop-replication-task \
  --replication-task-arn arn:aws:dms:us-east-1:123456789012:task:task-12345

# 2. Redirect traffic back to on-premise
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://rollback-dns.json

# 3. Stop MGN instances
aws mgn terminate-target-instances \
  --source-server-ids s-1234567890abcdef0

# 4. Notify stakeholders
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:123456789012:migration-alerts \
  --subject "ALERT: Migration Rollback Executed" \
  --message "Migration rollback completed. Systems restored to on-premise."

echo "Rollback completed. Verify on-premise systems."
```

### 10. Data Recovery Procedures

```sql
-- Emergency data recovery from backups
-- 1. Identify last known good backup
SELECT backup_name, backup_date, size_mb 
FROM backup_catalog 
WHERE backup_type = 'FULL' 
AND backup_date > DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY backup_date DESC;

-- 2. Restore specific tables if needed
RESTORE TABLE users, orders, products 
FROM BACKUP 'backup_20250118_0300.bak'
TO DATABASE recovery_db;

-- 3. Validate restored data
SELECT COUNT(*) as recovered_users FROM recovery_db.users;
SELECT COUNT(*) as recovered_orders FROM recovery_db.orders;
```

---

## Monitoring and Alerting

### 11. Key Metrics to Monitor

```bash
# Create CloudWatch dashboard for migration monitoring
aws cloudwatch put-dashboard \
  --dashboard-name "Migration-Monitoring" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/DMS", "CDCLatencyTarget", "ReplicationInstanceIdentifier", "rep-instance"],
            ["AWS/MGN", "ReplicationLag", "SourceServerID", "s-1234567890abcdef0"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "Migration Replication Lag"
        }
      }
    ]
  }'

# Set up critical alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "DMS-High-Lag" \
  --alarm-description "DMS replication lag too high" \
  --metric-name CDCLatencyTarget \
  --namespace AWS/DMS \
  --statistic Average \
  --period 300 \
  --threshold 300 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=ReplicationInstanceIdentifier,Value=rep-instance \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-east-1:123456789012:migration-alerts
```

---

## Support and Escalation

### 12. Contact Information

```yaml
Migration Team Contacts:
  Primary Engineer: migration-team@company.com
  Database Specialist: dba-team@company.com
  Network Team: network-team@company.com

AWS Support:
  Enterprise Support: +1-206-266-4064
  Case Management: https://console.aws.amazon.com/support/

Vendor Support:
  VMware: support.vmware.com
  Database Vendor: support.database-vendor.com
```

### 13. Quick Reference Commands

```bash
# Migration health check script
#!/bin/bash
echo "=== Migration Health Check ==="

# Check DMS tasks
aws dms describe-replication-tasks --query 'ReplicationTasks[*].[ReplicationTaskIdentifier,Status]' --output table

# Check MGN servers
aws mgn describe-source-servers --query 'items[*].[sourceServerID,dataReplicationInfo.dataReplicationState]' --output table

# Check network connectivity
curl -I https://dms.us-east-1.amazonaws.com
curl -I https://mgn.us-east-1.amazonaws.com

echo "Health check completed"
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Migration Operations Team