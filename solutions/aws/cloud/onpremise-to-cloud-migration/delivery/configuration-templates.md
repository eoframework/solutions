# Configuration Templates - AWS Cloud Migration

## Overview

This document provides standardized configuration templates for AWS cloud migration projects. These templates ensure consistent, secure, and optimized cloud deployments.

---

## AWS Landing Zone Configuration

### Multi-Account Structure
```yaml
OrganizationalUnits:
  - Name: Security
    Accounts:
      - SecurityAccount
      - LogArchiveAccount
  - Name: Production
    Accounts:
      - ProductionAccount
  - Name: NonProduction
    Accounts:
      - DevelopmentAccount
      - TestingAccount

ServiceControlPolicies:
  - Name: DenyRootUser
    TargetType: ACCOUNT
    Policy: |
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Deny",
            "Principal": {"AWS": "*"},
            "Action": "*",
            "Resource": "*",
            "Condition": {
              "StringEquals": {
                "aws:PrincipalType": "Root"
              }
            }
          }
        ]
      }
```

### VPC Configuration Template
```yaml
VPC:
  Type: AWS::EC2::VPC
  Properties:
    CidrBlock: 10.0.0.0/16
    EnableDnsHostnames: true
    EnableDnsSupport: true
    Tags:
      - Key: Name
        Value: migration-vpc

PublicSubnets:
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true

  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.2.0/24
      AvailabilityZone: !Select [1, !GetAZs '']
      MapPublicIpOnLaunch: true

PrivateSubnets:
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.10.0/24
      AvailabilityZone: !Select [0, !GetAZs '']

  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.11.0/24
      AvailabilityZone: !Select [1, !GetAZs '']
```

---

## Auto Scaling and Load Balancer Configuration

### Application Load Balancer
```yaml
ApplicationLoadBalancer:
  Type: AWS::ElasticLoadBalancingV2::LoadBalancer
  Properties:
    Name: migrated-app-alb
    Scheme: internet-facing
    Type: application
    IpAddressType: ipv4
    SecurityGroups:
      - !Ref ALBSecurityGroup
    Subnets:
      - !Ref PublicSubnet1
      - !Ref PublicSubnet2
    Tags:
      - Key: Environment
        Value: production

TargetGroup:
  Type: AWS::ElasticLoadBalancingV2::TargetGroup
  Properties:
    Name: migrated-app-tg
    Port: 80
    Protocol: HTTP
    VpcId: !Ref VPC
    HealthCheckPath: /health
    HealthCheckIntervalSeconds: 30
    HealthCheckTimeoutSeconds: 5
    HealthyThresholdCount: 2
    UnhealthyThresholdCount: 3
```

### Auto Scaling Group Configuration
```yaml
LaunchTemplate:
  Type: AWS::EC2::LaunchTemplate
  Properties:
    LaunchTemplateName: migrated-app-lt
    LaunchTemplateData:
      ImageId: ami-0abcdef1234567890  # Update with latest AMI
      InstanceType: t3.medium
      SecurityGroupIds:
        - !Ref WebServerSecurityGroup
      IamInstanceProfile:
        Arn: !GetAtt InstanceProfile.Arn
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y amazon-cloudwatch-agent
          # Application-specific setup commands

AutoScalingGroup:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    AutoScalingGroupName: migrated-app-asg
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
```

---

## Database Migration Configuration

### RDS Instance Configuration
```yaml
DatabaseSubnetGroup:
  Type: AWS::RDS::DBSubnetGroup
  Properties:
    DBSubnetGroupName: migrated-db-subnet-group
    DBSubnetGroupDescription: Subnet group for migrated database
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2

DatabaseInstance:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: migrated-database
    DBInstanceClass: db.t3.medium
    Engine: mysql
    EngineVersion: 8.0.35
    AllocatedStorage: 100
    StorageType: gp3
    StorageEncrypted: true
    KmsKeyId: !Ref DatabaseKMSKey
    DBSubnetGroupName: !Ref DatabaseSubnetGroup
    VPCSecurityGroups:
      - !Ref DatabaseSecurityGroup
    BackupRetentionPeriod: 7
    PreferredBackupWindow: "03:00-04:00"
    PreferredMaintenanceWindow: "sun:04:00-sun:05:00"
    MultiAZ: true
    PubliclyAccessible: false
    DeletionProtection: true
```

### DMS Migration Configuration
```yaml
DMSReplicationInstance:
  Type: AWS::DMS::ReplicationInstance
  Properties:
    ReplicationInstanceIdentifier: migration-replication-instance
    ReplicationInstanceClass: dms.t3.medium
    AllocatedStorage: 100
    VpcSecurityGroupIds:
      - !Ref DMSSecurityGroup
    ReplicationSubnetGroupIdentifier: !Ref DMSSubnetGroup

DMSSourceEndpoint:
  Type: AWS::DMS::Endpoint
  Properties:
    EndpointIdentifier: source-database-endpoint
    EndpointType: source
    EngineName: mysql
    ServerName: source.database.local
    Port: 3306
    DatabaseName: production_db
    Username: !Ref SourceDBUsername
    Password: !Ref SourceDBPassword

DMSTargetEndpoint:
  Type: AWS::DMS::Endpoint
  Properties:
    EndpointIdentifier: target-rds-endpoint
    EndpointType: target
    EngineName: mysql
    ServerName: !GetAtt DatabaseInstance.Endpoint.Address
    Port: 3306
    DatabaseName: production_db
    Username: !Ref TargetDBUsername
    Password: !Ref TargetDBPassword
```

---

## Security Configuration

### IAM Roles and Policies
```yaml
EC2InstanceRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: migrated-app-ec2-role
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: ec2.amazonaws.com
          Action: sts:AssumeRole
    ManagedPolicyArns:
      - arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
      - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
    Policies:
      - PolicyName: S3AccessPolicy
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - s3:GetObject
                - s3:PutObject
              Resource: !Sub '${ApplicationBucket}/*'

SecurityGroups:
  ALBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: migrated-app-alb-sg
      GroupDescription: Security group for application load balancer
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0

  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: migrated-app-web-sg
      GroupDescription: Security group for web servers
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          SourceSecurityGroupId: !Ref ALBSecurityGroup
```

---

## Monitoring and Logging Configuration

### CloudWatch Log Groups
```yaml
ApplicationLogGroup:
  Type: AWS::Logs::LogGroup
  Properties:
    LogGroupName: /aws/ec2/migrated-application
    RetentionInDays: 30

DatabaseLogGroup:
  Type: AWS::Logs::LogGroup
  Properties:
    LogGroupName: /aws/rds/instance/migrated-database/error
    RetentionInDays: 7
```

### CloudWatch Alarms
```yaml
HighCPUAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: migrated-app-high-cpu
    AlarmDescription: High CPU utilization
    MetricName: CPUUtilization
    Namespace: AWS/EC2
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 80
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref ScaleUpPolicy

DatabaseConnectionsAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: migrated-db-high-connections
    MetricName: DatabaseConnections
    Namespace: AWS/RDS
    Statistic: Average
    Period: 300
    Threshold: 40
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: DBInstanceIdentifier
        Value: !Ref DatabaseInstance
```

---

## Backup and Recovery Configuration

### Automated Backup Policy
```yaml
BackupPlan:
  Type: AWS::Backup::BackupPlan
  Properties:
    BackupPlan:
      BackupPlanName: migrated-app-backup-plan
      BackupPlanRule:
        - RuleName: daily-backups
          TargetBackupVault: !Ref BackupVault
          ScheduleExpression: cron(0 2 * * ? *)
          StartWindowMinutes: 60
          CompletionWindowMinutes: 120
          Lifecycle:
            MoveToColdStorageAfterDays: 30
            DeleteAfterDays: 365

BackupSelection:
  Type: AWS::Backup::BackupSelection
  Properties:
    BackupPlanId: !Ref BackupPlan
    BackupSelection:
      SelectionName: migrated-resources
      IamRoleArn: !GetAtt BackupRole.Arn
      Resources:
        - !Sub 'arn:aws:rds:${AWS::Region}:${AWS::AccountId}:db:${DatabaseInstance}'
      Conditions:
        StringEquals:
          'aws:ResourceTag/Environment': 'production'
```

---

## Migration-Specific Configuration

### AWS Application Migration Service (MGN)
```yaml
MGNLaunchTemplate:
  LaunchTemplate:
    Name: mgn-launch-template
    ImageId: ami-0abcdef1234567890
    InstanceType: t3.medium
    SecurityGroups:
      - sg-12345678
    IamInstanceProfile: MGN-InstanceProfile
    BlockDeviceMappings:
      - DeviceName: /dev/sda1
        Ebs:
          VolumeSize: 50
          VolumeType: gp3
          Encrypted: true

SourceServerConfigurations:
  ReplicationSettings:
    AssociateDefaultSecurityGroup: false
    BandwidthThrottling: 100
    CreatePublicIP: false
    DataPlaneRouting: PRIVATE_IP
    DefaultLargeStagingDiskType: GP3
    EbsEncryption: DEFAULT
    ReplicationServerInstanceType: t3.small
    ReplicationServersSecurityGroupsIDs:
      - sg-replication123
    StagingAreaSubnetId: subnet-staging123
    StagingAreaTags:
      Environment: migration
    UseDedicatedReplicationServer: false
```

---

## Cost Optimization Configuration

### Cost Allocation Tags
```yaml
ResourceTags:
  StandardTags:
    - Key: Environment
      Value: production
    - Key: Project
      Value: cloud-migration
    - Key: CostCenter
      Value: IT-Infrastructure
    - Key: Owner
      Value: platform-team
    - Key: BackupRequired
      Value: 'true'

CostAnomalyDetection:
  Type: AWS::CE::AnomalyDetector
  Properties:
    AnomalyDetectorName: migration-cost-anomaly
    MonitorType: DIMENSIONAL
    MonitorSpecification: |
      {
        "Dimension": "SERVICE",
        "MatchOptions": ["EQUALS"],
        "Values": ["Amazon Elastic Compute Cloud - Compute"]
      }
```

---

## Environment-Specific Configurations

### Development Environment
```yaml
Development:
  InstanceType: t3.micro
  MinSize: 1
  MaxSize: 2
  DesiredCapacity: 1
  DatabaseInstanceClass: db.t3.micro
  BackupRetentionPeriod: 1
```

### Production Environment
```yaml
Production:
  InstanceType: t3.medium
  MinSize: 2
  MaxSize: 10
  DesiredCapacity: 3
  DatabaseInstanceClass: db.t3.medium
  BackupRetentionPeriod: 7
  MultiAZ: true
  DeletionProtection: true
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: AWS Migration Team