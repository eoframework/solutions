# Training Materials - AWS Cloud Migration

## Overview

This document provides comprehensive training materials for AWS cloud migration projects, including administrator training, operations procedures, and migration management protocols.

---

## Training Program Structure

### Module 1: AWS Cloud Migration Fundamentals (6 hours)
**Audience:** All project team members  
**Prerequisites:** Basic AWS knowledge  

#### Topics Covered:
- Cloud migration concepts and strategies
- AWS migration services overview (MGN, DMS, SMS)
- Migration patterns and best practices
- Cost optimization during migration
- Security considerations for cloud migration

#### Hands-on Labs:
1. **Lab 1.1: AWS Console Navigation for Migration**
   - Navigate AWS Migration Hub
   - Review MGN dashboard
   - Examine DMS tasks
   - Explore SMS console

2. **Lab 1.2: Migration Assessment Tools**
   - AWS Application Discovery Service
   - Migration evaluator
   - TSO Logic assessment
   - Cost estimation tools

---

### Module 2: AWS Application Migration Service (MGN) Deep Dive (8 hours)
**Audience:** Infrastructure team, migration engineers  
**Prerequisites:** Module 1 completion  

#### Topics Covered:
- MGN architecture and components
- Replication agent installation and configuration
- Launch templates and testing procedures
- Cutover processes and validation

#### Hands-on Labs:
1. **Lab 2.1: MGN Agent Installation**
   ```bash
   # Download and install replication agent
   wget -O ./aws-replication-installer-init https://aws-application-migration-service-us-east-1.s3.us-east-1.amazonaws.com/latest/linux/aws-replication-installer-init
   sudo python3 aws-replication-installer-init --region us-east-1
   
   # Verify agent installation
   sudo systemctl status aws-replication-agent
   sudo tail -f /opt/aws/aws-replication-agent/logs/agent.log
   ```

2. **Lab 2.2: Source Server Configuration**
   ```bash
   # Check source server status
   aws mgn describe-source-servers --source-server-ids s-1234567890abcdef0
   
   # Monitor replication progress
   aws mgn describe-source-servers \
     --source-server-ids s-1234567890abcdef0 \
     --query 'items[0].dataReplicationInfo'
   ```

3. **Lab 2.3: Test Launch and Validation**
   ```bash
   # Launch test instance
   aws mgn start-test --source-server-ids s-1234567890abcdef0
   
   # Monitor test launch job
   aws mgn describe-jobs --filters jobType=LAUNCH
   
   # Validate test instance
   aws ec2 describe-instances --filters Name=tag:Name,Values=*test*
   ```

---

### Module 3: AWS Database Migration Service (DMS) Training (8 hours)
**Audience:** Database administrators, data engineers  
**Prerequisites:** Module 1 completion  

#### Topics Covered:
- DMS architecture and components
- Source and target endpoint configuration
- Replication instance sizing and configuration
- Migration task creation and monitoring
- Data validation and troubleshooting

#### Hands-on Labs:
1. **Lab 3.1: DMS Endpoint Configuration**
   ```bash
   # Create source endpoint
   aws dms create-endpoint \
     --endpoint-identifier source-mysql \
     --endpoint-type source \
     --engine-name mysql \
     --server-name source-db.company.local \
     --port 3306 \
     --username migrationuser \
     --password password123
   
   # Create target endpoint
   aws dms create-endpoint \
     --endpoint-identifier target-aurora \
     --endpoint-type target \
     --engine-name aurora-mysql \
     --server-name target-cluster.cluster-xyz.us-east-1.rds.amazonaws.com \
     --port 3306 \
     --username admin \
     --password newpassword123
   ```

2. **Lab 3.2: Replication Task Creation**
   ```bash
   # Create replication task
   aws dms create-replication-task \
     --replication-task-identifier migration-task-1 \
     --source-endpoint-arn arn:aws:dms:us-east-1:123456789012:endpoint:source-mysql \
     --target-endpoint-arn arn:aws:dms:us-east-1:123456789012:endpoint:target-aurora \
     --replication-instance-arn arn:aws:dms:us-east-1:123456789012:rep:replication-instance \
     --migration-type full-load-and-cdc \
     --table-mappings file://table-mappings.json
   ```

3. **Lab 3.3: Migration Monitoring and Validation**
   ```python
   import boto3
   import time
   
   def monitor_migration_task(task_arn):
       dms = boto3.client('dms')
       
       while True:
           response = dms.describe_replication_tasks(
               ReplicationTaskArns=[task_arn]
           )
           
           task = response['ReplicationTasks'][0]
           status = task['Status']
           
           print(f"Task Status: {status}")
           
           if 'ReplicationTaskStats' in task:
               stats = task['ReplicationTaskStats']
               print(f"Full Load Progress: {stats.get('FullLoadProgressPercent', 0)}%")
               print(f"Tables Loaded: {stats.get('TablesLoaded', 0)}")
               print(f"Tables Loading: {stats.get('TablesLoading', 0)}")
           
           if status in ['stopped', 'failed', 'ready']:
               break
           
           time.sleep(30)
   ```

---

### Module 4: Migration Operations and Monitoring (4 hours)
**Audience:** Operations team, DevOps engineers  
**Prerequisites:** Modules 1-3 completion  

#### Topics Covered:
- Migration monitoring and dashboards
- Performance optimization during migration
- Error handling and troubleshooting
- Rollback procedures and contingency planning

#### Standard Operating Procedures:

##### Daily Migration Health Check
```bash
#!/bin/bash
# daily_migration_health_check.sh

echo "=== Migration Daily Health Check - $(date) ==="

# 1. Check MGN source servers
echo "Checking MGN source servers..."
aws mgn describe-source-servers --query 'items[*].[sourceServerID,dataReplicationInfo.dataReplicationState]' --output table

# 2. Check DMS task status
echo "Checking DMS replication tasks..."
aws dms describe-replication-tasks --query 'ReplicationTasks[*].[ReplicationTaskIdentifier,Status]' --output table

# 3. Check migration progress
echo "Checking migration progress..."
python3 migration_progress_monitor.py

# 4. Review error logs
echo "Reviewing error logs..."
aws logs filter-log-events \
  --log-group-name /aws/dms/task/migration-task-1 \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --filter-pattern 'ERROR'

echo "Health check completed at $(date)"
```

#### Weekly Migration Review Tasks:
- [ ] Review migration performance metrics
- [ ] Validate data consistency across migrated systems
- [ ] Update migration timeline and milestones
- [ ] Review and update cost projections
- [ ] Conduct stakeholder status meetings

---

### Module 5: Post-Migration Operations (6 hours)
**Audience:** Operations team, application owners  
**Prerequisites:** Module 4 completion  

#### Topics Covered:
- Post-migration validation procedures
- Performance tuning and optimization
- Monitoring and alerting setup
- Documentation and knowledge transfer
- Decommissioning legacy systems

#### Post-Migration Validation Workflow:
```bash
#!/bin/bash
# post_migration_validation.sh

echo "Starting Post-Migration Validation - $(date)"

# 1. Application functionality testing
echo "Testing application functionality..."
python3 application_functional_tests.py

# 2. Performance validation
echo "Validating performance..."
artillery run load-test-config.yml

# 3. Data integrity verification
echo "Verifying data integrity..."
python3 data_validation_suite.py

# 4. Security configuration validation
echo "Validating security configuration..."
aws-cli-security-audit.sh

# 5. Backup and recovery testing
echo "Testing backup and recovery..."
aws rds create-db-snapshot \
  --db-instance-identifier migrated-database \
  --db-snapshot-identifier test-snapshot-$(date +%Y%m%d)

echo "Post-migration validation completed - $(date)"
```

---

## Administrator Training Materials

### AWS CLI and SDK Configuration
```bash
# Configure AWS CLI for migration operations
aws configure set region us-east-1
aws configure set output json

# Set up named profiles for different environments
aws configure set region us-east-1 --profile migration-prod
aws configure set region us-west-2 --profile migration-dr

# Test configuration
aws sts get-caller-identity --profile migration-prod
```

### Migration Service Permissions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mgn:*",
        "dms:*",
        "sms:*",
        "ec2:*",
        "rds:*",
        "s3:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole",
        "iam:CreateRole",
        "iam:AttachRolePolicy"
      ],
      "Resource": "arn:aws:iam::*:role/MGN*"
    }
  ]
}
```

### Migration Automation Scripts
```python
# migration_orchestrator.py
import boto3
import logging
import time
from datetime import datetime

class MigrationOrchestrator:
    def __init__(self, region='us-east-1'):
        self.mgn = boto3.client('mgn', region_name=region)
        self.dms = boto3.client('dms', region_name=region)
        self.ec2 = boto3.client('ec2', region_name=region)
        
        # Setup logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
    
    def start_server_migration(self, source_server_ids):
        """Start MGN replication for multiple servers"""
        for server_id in source_server_ids:
            try:
                response = self.mgn.start_replication(
                    sourceServerID=server_id
                )
                self.logger.info(f"Started replication for {server_id}")
            except Exception as e:
                self.logger.error(f"Failed to start replication for {server_id}: {e}")
    
    def monitor_migration_progress(self, source_server_ids):
        """Monitor MGN replication progress"""
        while True:
            all_ready = True
            
            for server_id in source_server_ids:
                response = self.mgn.describe_source_servers(
                    sourceServerIDs=[server_id]
                )
                
                state = response['items'][0]['dataReplicationInfo']['dataReplicationState']
                self.logger.info(f"Server {server_id}: {state}")
                
                if state != 'CONTINUOUS_REPLICATION':
                    all_ready = False
            
            if all_ready:
                self.logger.info("All servers ready for testing")
                break
            
            time.sleep(60)
    
    def validate_migration(self, instance_ids):
        """Validate migrated instances"""
        for instance_id in instance_ids:
            try:
                response = self.ec2.describe_instances(
                    InstanceIds=[instance_id]
                )
                
                state = response['Reservations'][0]['Instances'][0]['State']['Name']
                self.logger.info(f"Instance {instance_id}: {state}")
                
            except Exception as e:
                self.logger.error(f"Failed to validate {instance_id}: {e}")

# Usage example
if __name__ == "__main__":
    orchestrator = MigrationOrchestrator()
    
    servers = ['s-1234567890abcdef0', 's-1234567890abcdef1']
    orchestrator.start_server_migration(servers)
    orchestrator.monitor_migration_progress(servers)
```

---

## Troubleshooting Training

### Common Migration Issues

#### Issue: MGN Agent Connection Problems
**Symptoms:**
- Agent fails to connect to AWS
- Replication not starting
- Network connectivity errors

**Diagnostic Steps:**
```bash
# Check agent status
sudo systemctl status aws-replication-agent

# Review agent logs
sudo tail -f /opt/aws/aws-replication-agent/logs/agent.log

# Test network connectivity
curl -I https://mgn.us-east-1.amazonaws.com
nc -zv mgn.us-east-1.amazonaws.com 443

# Check IAM permissions
aws sts get-caller-identity
aws mgn describe-source-servers --dry-run
```

**Resolution Steps:**
1. Verify network connectivity and firewall rules
2. Check IAM permissions for MGN service
3. Restart the replication agent
4. Re-register agent if needed

#### Issue: DMS Task Failures
**Symptoms:**
- Migration task stops with errors
- Data validation failures
- High replication lag

**Diagnostic Steps:**
```bash
# Check task status
aws dms describe-replication-tasks --replication-task-identifier migration-task-1

# Review task logs
aws logs get-log-events \
  --log-group-name /aws/dms/task/migration-task-1 \
  --log-stream-name dms-1-1234567890

# Check table statistics
aws dms describe-table-statistics \
  --replication-task-arn arn:aws:dms:us-east-1:123456789012:task:migration-task-1
```

**Resolution Steps:**
1. Review and fix data type compatibility issues
2. Increase replication instance size if needed
3. Optimize source database queries
4. Adjust task settings for better performance

---

## Training Assessment

### Practical Skills Assessment

#### Scenario 1: Database Migration Performance Issue
**Situation:** DMS task showing high replication lag (>300 seconds)  
**Required Actions:**
1. Analyze task performance metrics
2. Identify bottlenecks (source DB, network, target DB)
3. Implement optimization strategies
4. Monitor improvement and document changes

#### Scenario 2: Application Migration Failure
**Situation:** MGN test launch fails with network configuration errors  
**Required Actions:**
1. Review launch template configuration
2. Validate security group and VPC settings
3. Fix network configuration issues
4. Re-execute test launch and validate

### Knowledge Assessment Questions

1. What are the three main AWS migration services and their use cases?
2. How do you configure MGN replication agents for optimal performance?
3. What are the key considerations for DMS endpoint configuration?
4. How do you troubleshoot high replication lag in DMS?
5. What validation steps should be performed after migration?

---

## Training Resources

### Documentation Links
- [AWS Migration Hub User Guide](https://docs.aws.amazon.com/migrationhub/)
- [AWS Application Migration Service](https://docs.aws.amazon.com/mgn/)
- [AWS Database Migration Service](https://docs.aws.amazon.com/dms/)
- [AWS Server Migration Service](https://docs.aws.amazon.com/sms/)

### Training Videos
- AWS Migration Fundamentals (60 min)
- MGN Deep Dive Training (90 min)
- DMS Best Practices (75 min)
- Migration Troubleshooting (45 min)

### Certification Paths
- AWS Certified Solutions Architect - Associate
- AWS Certified Database - Specialty
- AWS Certified Advanced Networking - Specialty

---

## Training Schedule Template

### Week 1: Foundation Training
- **Day 1:** AWS Migration Fundamentals (Module 1)
- **Day 2:** MGN Deep Dive Part 1 (Module 2)
- **Day 3:** MGN Deep Dive Part 2 (Module 2)
- **Day 4:** DMS Training Part 1 (Module 3)
- **Day 5:** DMS Training Part 2 (Module 3)

### Week 2: Operations and Validation
- **Day 1:** Migration Operations (Module 4)
- **Day 2:** Post-Migration Operations (Module 5)
- **Day 3:** Hands-on Practice and Labs
- **Day 4:** Troubleshooting Workshop
- **Day 5:** Assessment and Certification

---

## Training Environment Setup

### Lab Environment Requirements
- AWS account with migration services enabled
- Sample source environment (VMs/databases)
- Network connectivity between source and AWS
- Pre-configured IAM roles and permissions

### Training Data Sets
- Sample databases with realistic data volumes
- Application configurations and dependencies
- Network topology documentation
- Security requirements and configurations

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Migration Training Team