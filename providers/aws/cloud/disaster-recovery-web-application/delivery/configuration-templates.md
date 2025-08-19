# Configuration Templates - AWS Disaster Recovery

## Overview

This document provides standardized configuration templates for implementing AWS disaster recovery solutions. These templates ensure consistent, secure, and optimized DR deployments.

---

## Route 53 Health Check Configuration

### Primary Application Health Check
```json
{
  "Name": "primary-app-health-check",
  "Type": "HTTPS",
  "ResourcePath": "/health",
  "FullyQualifiedDomainName": "app.example.com",
  "Port": 443,
  "RequestInterval": 30,
  "FailureThreshold": 3,
  "CloudWatchAlarmRegion": "us-east-1",
  "InsufficientDataHealthStatus": "Failure",
  "AlarmIdentifier": {
    "Region": "us-east-1",
    "Name": "primary-app-alarm"
  }
}
```

### Failover Routing Policy
```json
{
  "SetIdentifier": "primary",
  "Failover": "PRIMARY",
  "TTL": 60,
  "ResourceRecords": [
    {
      "Value": "primary-alb-12345.us-east-1.elb.amazonaws.com"
    }
  ],
  "HealthCheckId": "primary-health-check-id"
}
```

---

## RDS Cross-Region Read Replica Configuration

### Aurora MySQL Read Replica
```yaml
AuroraReadReplica:
  Type: AWS::RDS::DBCluster
  Properties:
    Engine: aurora-mysql
    EngineVersion: 8.0.mysql_aurora.3.02.0
    DatabaseName: !Ref DatabaseName
    MasterUsername: !Ref MasterUsername
    ReplicationSourceIdentifier: !Sub 
      - arn:aws:rds:${SourceRegion}:${AWS::AccountId}:cluster:${SourceClusterIdentifier}
      - SourceRegion: us-east-1
        SourceClusterIdentifier: !Ref SourceCluster
    BackupRetentionPeriod: 7
    PreferredBackupWindow: "03:00-04:00"
    PreferredMaintenanceWindow: "sun:04:00-sun:05:00"
    VpcSecurityGroupIds:
      - !Ref DatabaseSecurityGroup
    DBSubnetGroupName: !Ref DBSubnetGroup
    StorageEncrypted: true
    KmsKeyId: !Ref KMSKey
```

### RDS MySQL Read Replica
```yaml
ReadReplica:
  Type: AWS::RDS::DBInstance
  Properties:
    SourceDBInstanceIdentifier: !Sub 
      - arn:aws:rds:${SourceRegion}:${AWS::AccountId}:db:${SourceDBInstanceIdentifier}
      - SourceRegion: us-east-1
        SourceDBInstanceIdentifier: !Ref SourceDatabase
    DBInstanceClass: db.t3.medium
    PubliclyAccessible: false
    VPCSecurityGroups:
      - !Ref DatabaseSecurityGroup
    DBSubnetGroupName: !Ref DBSubnetGroup
    BackupRetentionPeriod: 7
    MultiAZ: true
    StorageEncrypted: true
    KmsKeyId: !Ref KMSKey
    DeletionProtection: true
```

---

## S3 Cross-Region Replication Configuration

### Replication Configuration
```json
{
  "Role": "arn:aws:iam::123456789012:role/replication-role",
  "Rules": [
    {
      "ID": "ReplicateEverything",
      "Status": "Enabled",
      "Priority": 1,
      "Filter": {},
      "Destination": {
        "Bucket": "arn:aws:s3:::dr-webapp-secondary-123456789012",
        "StorageClass": "STANDARD_IA",
        "ReplicationTime": {
          "Status": "Enabled",
          "Time": {
            "Minutes": 15
          }
        },
        "Metrics": {
          "Status": "Enabled",
          "EventThreshold": {
            "Minutes": 15
          }
        }
      }
    }
  ]
}
```

### Bucket Versioning
```yaml
S3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub 'dr-webapp-primary-${AWS::AccountId}'
    VersioningConfiguration:
      Status: Enabled
    ReplicationConfiguration:
      Role: !GetAtt ReplicationRole.Arn
      Rules:
        - Id: ReplicateAll
          Status: Enabled
          Prefix: ''
          Destination:
            Bucket: !Sub 'arn:aws:s3:::dr-webapp-secondary-${AWS::AccountId}'
            StorageClass: STANDARD_IA
```

---

## Auto Scaling Group Configuration

### Primary Region ASG
```yaml
AutoScalingGroup:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    LaunchTemplate:
      LaunchTemplateId: !Ref LaunchTemplate
      Version: !GetAtt LaunchTemplate.LatestVersionNumber
    MinSize: 2
    MaxSize: 10
    DesiredCapacity: 3
    VPCZoneIdentifier:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    TargetGroupARNs:
      - !Ref TargetGroup
    HealthCheckType: ELB
    HealthCheckGracePeriod: 300
    Tags:
      - Key: Name
        Value: dr-webapp-primary-asg
        PropagateAtLaunch: true
      - Key: Environment
        Value: production
        PropagateAtLaunch: true
```

### Secondary Region ASG (Standby)
```yaml
StandbyAutoScalingGroup:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    LaunchTemplate:
      LaunchTemplateId: !Ref StandbyLaunchTemplate
      Version: !GetAtt StandbyLaunchTemplate.LatestVersionNumber
    MinSize: 0
    MaxSize: 10
    DesiredCapacity: 1
    VPCZoneIdentifier:
      - !Ref StandbyPrivateSubnet1
      - !Ref StandbyPrivateSubnet2
    TargetGroupARNs:
      - !Ref StandbyTargetGroup
    HealthCheckType: ELB
    HealthCheckGracePeriod: 300
```

---

## CloudWatch Alarms Configuration

### Application Load Balancer Alarms
```yaml
ALBHighLatencyAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: dr-webapp-alb-high-latency
    AlarmDescription: ALB response time exceeds threshold
    MetricName: TargetResponseTime
    Namespace: AWS/ApplicationELB
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 5.0
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: LoadBalancer
        Value: !GetAtt ApplicationLoadBalancer.LoadBalancerFullName
    AlarmActions:
      - !Ref SNSTopicARN

ALBHighErrorRateAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: dr-webapp-alb-high-errors
    MetricName: HTTPCode_Target_5XX_Count
    Namespace: AWS/ApplicationELB
    Statistic: Sum
    Period: 300
    EvaluationPeriods: 2
    Threshold: 10
    ComparisonOperator: GreaterThanThreshold
```

### RDS Replication Lag Alarm
```yaml
ReplicationLagAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: rds-replication-lag-high
    AlarmDescription: RDS read replica lag exceeds threshold
    MetricName: ReplicaLag
    Namespace: AWS/RDS
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 300
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: DBInstanceIdentifier
        Value: !Ref ReadReplica
```

---

## Security Group Templates

### Application Load Balancer Security Group
```yaml
ALBSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupName: dr-webapp-alb-sg
    GroupDescription: Security group for DR web application load balancer
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 80
        ToPort: 80
        CidrIp: 0.0.0.0/0
        Description: HTTP from anywhere
      - IpProtocol: tcp
        FromPort: 443
        ToPort: 443
        CidrIp: 0.0.0.0/0
        Description: HTTPS from anywhere
    SecurityGroupEgress:
      - IpProtocol: tcp
        FromPort: 80
        ToPort: 80
        DestinationSecurityGroupId: !Ref WebServerSecurityGroup
        Description: HTTP to web servers
```

### Web Server Security Group
```yaml
WebServerSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupName: dr-webapp-web-sg
    GroupDescription: Security group for DR web servers
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 80
        ToPort: 80
        SourceSecurityGroupId: !Ref ALBSecurityGroup
        Description: HTTP from ALB
      - IpProtocol: tcp
        FromPort: 22
        ToPort: 22
        SourceSecurityGroupId: !Ref BastionSecurityGroup
        Description: SSH from bastion
```

### Database Security Group
```yaml
DatabaseSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupName: dr-webapp-db-sg
    GroupDescription: Security group for DR database
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 3306
        ToPort: 3306
        SourceSecurityGroupId: !Ref WebServerSecurityGroup
        Description: MySQL from web servers
```

---

## Lambda Function Configuration

### Failover Automation Lambda
```python
import boto3
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Automated failover function for DR
    """
    route53 = boto3.client('route53')
    autoscaling = boto3.client('autoscaling', region_name='us-west-2')
    
    # Update Route 53 to point to secondary region
    try:
        response = route53.change_resource_record_sets(
            HostedZoneId='Z123456789',
            ChangeBatch={
                'Changes': [{
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': 'app.example.com',
                        'Type': 'A',
                        'SetIdentifier': 'failover',
                        'Failover': 'SECONDARY',
                        'TTL': 60,
                        'ResourceRecords': [{'Value': 'secondary-alb-dns'}]
                    }
                }]
            }
        )
        
        # Scale up secondary region Auto Scaling Group
        autoscaling.set_desired_capacity(
            AutoScalingGroupName='dr-webapp-secondary-asg',
            DesiredCapacity=3,
            HonorCooldown=False
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps('Failover initiated successfully')
        }
        
    except Exception as e:
        logger.error(f"Failover failed: {str(e)}")
        raise
```

---

## IAM Roles and Policies

### S3 Replication Role
```yaml
ReplicationRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: s3-replication-role
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: s3.amazonaws.com
          Action: sts:AssumeRole
    Policies:
      - PolicyName: ReplicationPolicy
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - s3:ReplicateObject
                - s3:ReplicateDelete
                - s3:ReplicateTags
              Resource: 
                - !Sub '${DestinationBucket}/*'
            - Effect: Allow
              Action:
                - s3:GetObjectVersionForReplication
                - s3:GetObjectVersionAcl
              Resource:
                - !Sub '${SourceBucket}/*'
```

---

## Monitoring Dashboard Configuration

### CloudWatch Dashboard JSON
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
          ["AWS/RDS", "ReplicaLag", "DBInstanceIdentifier", "dr-webapp-replica"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-west-2",
        "title": "Database Replication Lag"
      }
    }
  ]
}
```

---

## Configuration Management

### Parameter Store Configuration
```yaml
Parameters:
  DatabaseEndpoint:
    Type: AWS::SSM::Parameter
    Properties:
      Name: /dr-webapp/database/primary-endpoint
      Type: String
      Value: !GetAtt DatabaseCluster.Endpoint.Address
      
  ReplicaEndpoint:
    Type: AWS::SSM::Parameter
    Properties:
      Name: /dr-webapp/database/replica-endpoint
      Type: String
      Value: !GetAtt ReadReplica.Endpoint.Address
```

### Secrets Manager Configuration
```yaml
DatabaseSecret:
  Type: AWS::SecretsManager::Secret
  Properties:
    Name: dr-webapp/database/credentials
    Description: Database credentials for DR webapp
    GenerateSecretString:
      SecretStringTemplate: '{"username": "admin"}'
      GenerateStringKey: 'password'
      PasswordLength: 16
      ExcludeCharacters: '"@/\'
```

---

## Validation and Testing

### Configuration Validation Script
```bash
#!/bin/bash
# validate-dr-config.sh

echo "Validating DR Configuration..."

# Check Route 53 health checks
aws route53 get-health-check --health-check-id $HEALTH_CHECK_ID

# Verify RDS replication
aws rds describe-db-instances --db-instance-identifier $REPLICA_ID

# Check S3 replication status
aws s3api get-bucket-replication --bucket $SOURCE_BUCKET

# Validate security groups
aws ec2 describe-security-groups --group-ids $ALB_SG_ID $WEB_SG_ID $DB_SG_ID

echo "Configuration validation complete."
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: AWS Solutions Architecture Team