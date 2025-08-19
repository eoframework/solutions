# AWS Disaster Recovery Architecture

## Solution Overview

This document describes the technical architecture for AWS disaster recovery solution providing automated failover, cross-region replication, and business continuity capabilities.

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USERS / CLIENTS                             │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     ROUTE 53 DNS                                   │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐      │
│  │ Health Checks   │ │ Failover Policy │ │ Latency Routing │      │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘      │
└─────────────────────────┬───────────────────┬───────────────────────┘
                          │                   │
                          ▼                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PRIMARY REGION (us-east-1)                      │
│                                                                     │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐      │
│  │ Application     │ │   RDS MySQL     │ │   S3 Storage    │      │
│  │ Load Balancer   │ │   Primary DB    │ │   Primary       │      │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘      │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐      │
│  │  Auto Scaling   │ │    Lambda       │ │   CloudWatch    │      │
│  │     Group       │ │   Functions     │ │   Monitoring    │      │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘      │
└─────────────────────────┬───────────────────────────────────────────┘
                          │ Cross-Region Replication
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   SECONDARY REGION (us-west-2)                     │
│                                                                     │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐      │
│  │ Application     │ │   RDS MySQL     │ │   S3 Storage    │      │
│  │ Load Balancer   │ │  Read Replica   │ │   Secondary     │      │
│  │   (Standby)     │ │                 │ │                 │      │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘      │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐      │
│  │  Auto Scaling   │ │    Lambda       │ │   CloudWatch    │      │
│  │ Group (Standby) │ │   Functions     │ │   Monitoring    │      │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Network Architecture

### Multi-Region VPC Design

#### Primary Region (us-east-1)
```
VPC: 10.0.0.0/16

Public Subnets:
├── 10.0.1.0/24 (us-east-1a) - ALB, NAT Gateway
├── 10.0.2.0/24 (us-east-1b) - ALB, NAT Gateway
└── 10.0.3.0/24 (us-east-1c) - ALB, NAT Gateway

Private Subnets:
├── 10.0.10.0/24 (us-east-1a) - Application Tier
├── 10.0.11.0/24 (us-east-1b) - Application Tier
├── 10.0.12.0/24 (us-east-1c) - Application Tier
├── 10.0.20.0/24 (us-east-1a) - Database Tier
├── 10.0.21.0/24 (us-east-1b) - Database Tier
└── 10.0.22.0/24 (us-east-1c) - Database Tier
```

#### Secondary Region (us-west-2)
```
VPC: 10.1.0.0/16

Public Subnets:
├── 10.1.1.0/24 (us-west-2a) - ALB, NAT Gateway
├── 10.1.2.0/24 (us-west-2b) - ALB, NAT Gateway
└── 10.1.3.0/24 (us-west-2c) - ALB, NAT Gateway

Private Subnets:
├── 10.1.10.0/24 (us-west-2a) - Application Tier
├── 10.1.11.0/24 (us-west-2b) - Application Tier
├── 10.1.12.0/24 (us-west-2c) - Application Tier
├── 10.1.20.0/24 (us-west-2a) - Database Tier
├── 10.1.21.0/24 (us-west-2b) - Database Tier
└── 10.1.22.0/24 (us-west-2c) - Database Tier
```

---

## Application Architecture

### Load Balancer Configuration
- **Type:** Application Load Balancer (ALB)
- **Scheme:** Internet-facing
- **Target Groups:** Web application instances
- **Health Checks:** /health endpoint
- **SSL Termination:** AWS Certificate Manager

### Auto Scaling Configuration
- **Primary Region:** 3-10 instances (production)
- **Secondary Region:** 1-10 instances (standby, scales on failover)
- **Instance Type:** t3.medium (adjustable)
- **Scaling Metrics:** CPU, memory, request count

---

## Database Architecture

### RDS Configuration
```yaml
Primary Database (us-east-1):
  Engine: MySQL 8.0
  Instance Class: db.t3.medium
  Multi-AZ: Yes
  Backup Retention: 7 days
  Backup Window: 03:00-04:00 UTC
  Maintenance Window: sun:04:00-sun:05:00 UTC
  
Read Replica (us-west-2):
  Engine: MySQL 8.0
  Instance Class: db.t3.medium
  Source: Primary database ARN
  Backup Retention: 7 days
  Encrypted: Yes
```

### Replication Flow
1. **Continuous Replication:** Binary log streaming from primary to replica
2. **Lag Monitoring:** CloudWatch metrics track replication lag
3. **Automated Promotion:** Lambda function promotes replica during failover

---

## Storage Architecture

### S3 Cross-Region Replication
```yaml
Primary Bucket (us-east-1):
  Name: dr-webapp-primary-{account-id}
  Versioning: Enabled
  Encryption: AES-256
  
Secondary Bucket (us-west-2):
  Name: dr-webapp-secondary-{account-id}
  Versioning: Enabled
  Encryption: AES-256
  Replication: From primary bucket
```

### Replication Configuration
- **Replication Time Control:** 15 minutes
- **Metrics:** Enabled for monitoring
- **Destination Storage Class:** Standard-IA
- **Delete Marker Replication:** Enabled

---

## DNS and Routing Architecture

### Route 53 Configuration

#### Health Checks
```yaml
Primary Health Check:
  Type: HTTPS
  FQDN: primary-alb.us-east-1.elb.amazonaws.com
  Path: /health
  Port: 443
  Request Interval: 30 seconds
  Failure Threshold: 3
  
Secondary Health Check:
  Type: HTTPS
  FQDN: secondary-alb.us-west-2.elb.amazonaws.com
  Path: /health
  Port: 443
  Request Interval: 30 seconds
  Failure Threshold: 3
```

#### Failover Routing
```yaml
Primary Record:
  Name: app.example.com
  Type: A
  Alias: primary-alb.us-east-1.elb.amazonaws.com
  Routing Policy: Failover - Primary
  Health Check: Primary health check
  TTL: 60 seconds

Secondary Record:
  Name: app.example.com
  Type: A
  Alias: secondary-alb.us-west-2.elb.amazonaws.com
  Routing Policy: Failover - Secondary
  Health Check: Secondary health check
  TTL: 60 seconds
```

---

## Security Architecture

### Network Security
```yaml
Security Groups:
  ALB Security Group:
    Inbound: 80/443 from 0.0.0.0/0
    Outbound: 80/443 to Web Server SG
    
  Web Server Security Group:
    Inbound: 80/443 from ALB SG, 22 from Bastion SG
    Outbound: 3306 to Database SG, 443 to 0.0.0.0/0
    
  Database Security Group:
    Inbound: 3306 from Web Server SG
    Outbound: None
    
  Bastion Security Group:
    Inbound: 22 from Admin IP ranges
    Outbound: 22 to Web Server SG
```

### IAM Roles and Policies
```yaml
EC2 Instance Role:
  Policies:
    - CloudWatchAgentServerPolicy
    - AmazonSSMManagedInstanceCore
    - Custom S3 access policy
    
Lambda Execution Role:
  Policies:
    - VPCAccessExecutionRole
    - Custom RDS and Route53 access
    - SNS publish permissions
    
S3 Replication Role:
  Policies:
    - S3 cross-region replication permissions
    - KMS encryption/decryption access
```

---

## Monitoring and Alerting Architecture

### CloudWatch Metrics
```yaml
Application Metrics:
  - ALB Request Count
  - ALB Target Response Time
  - ALB HTTP 5XX Errors
  - EC2 CPU Utilization
  - EC2 Memory Utilization

Database Metrics:
  - RDS CPU Utilization
  - RDS Database Connections
  - RDS Replica Lag
  - RDS Read/Write IOPS

Storage Metrics:
  - S3 Replication Latency
  - S3 Replication Failure Count
  - S3 Request Count
```

### CloudWatch Alarms
```yaml
Critical Alarms:
  - ALB 5XX errors > 10 in 5 minutes
  - RDS replica lag > 300 seconds
  - Primary region health check failure
  - Auto Scaling capacity changes

Warning Alarms:
  - ALB response time > 5 seconds
  - RDS CPU > 80%
  - EC2 CPU > 80%
  - S3 replication lag > 60 minutes
```

---

## Automation Architecture

### Lambda Functions

#### Failover Automation
```python
# Simplified failover logic
def lambda_handler(event, context):
    # 1. Promote RDS read replica
    rds.promote_read_replica(DBInstanceIdentifier='dr-replica')
    
    # 2. Scale up secondary region
    autoscaling.set_desired_capacity(
        AutoScalingGroupName='secondary-asg',
        DesiredCapacity=3
    )
    
    # 3. Update Route 53 (handled by health checks)
    # 4. Send notifications
    sns.publish(
        TopicArn='arn:aws:sns:region:account:dr-alerts',
        Message='DR failover completed'
    )
```

### CloudFormation Infrastructure
- **Nested Stacks:** Separate stacks for network, compute, database
- **Cross-Stack References:** Outputs from one stack used in others
- **Parameter Store:** Configuration values stored centrally

---

## Performance Specifications

### Service Level Objectives
```yaml
Availability: 99.9% (8.76 hours downtime/year)
RTO (Recovery Time Objective): < 15 minutes
RPO (Recovery Point Objective): < 1 hour
Response Time: < 2 seconds (95th percentile)
Throughput: 1000 requests/second
```

### Capacity Planning
```yaml
Primary Region:
  EC2 Instances: 3-10 t3.medium instances
  RDS: db.t3.medium with 100GB storage
  ALB: 1000 new connections/second capacity
  
Secondary Region:
  EC2 Instances: 1-10 t3.medium instances (standby)
  RDS: db.t3.medium read replica
  ALB: 1000 new connections/second capacity
```

---

## Disaster Recovery Scenarios

### Scenario 1: Single AZ Failure
- **Impact:** Minimal - Auto Scaling redistributes load
- **Recovery:** Automatic within minutes
- **Action Required:** Monitor and investigate

### Scenario 2: Primary Region Partial Outage
- **Impact:** Degraded performance
- **Recovery:** Scale secondary region proactively
- **Action Required:** Manual intervention may be needed

### Scenario 3: Primary Region Complete Outage
- **Impact:** Service interruption
- **Recovery:** Automated failover to secondary region
- **Action Required:** Monitor failover completion

---

## Integration Points

### External Systems
- **Corporate LDAP:** Authentication integration
- **Payment Gateway:** API integration with failover endpoints
- **CDN:** CloudFront with multiple origins
- **Monitoring:** Third-party APM tools

### API Endpoints
```yaml
Primary Endpoints:
  - https://api.example.com/v1/*
  - https://app.example.com/*
  
Secondary Endpoints:
  - https://api-dr.example.com/v1/*
  - https://app-dr.example.com/*
```

---

## Compliance and Governance

### Compliance Requirements
- **SOC 2 Type II:** Audit controls for availability
- **ISO 27001:** Information security management
- **PCI DSS:** Payment card data protection

### Governance Framework
- **Change Control:** All DR changes require approval
- **Testing Schedule:** Monthly DR tests mandatory
- **Documentation:** Runbooks updated quarterly
- **Training:** Annual DR training for operations team

---

## Cost Architecture

### Primary Region Costs (Monthly)
```yaml
Compute: $500 (3 x t3.medium instances)
Database: $200 (db.t3.medium Multi-AZ)
Load Balancer: $25 (ALB)
Storage: $50 (S3 + EBS)
Data Transfer: $100
Total: ~$875/month
```

### Secondary Region Costs (Monthly)
```yaml
Compute: $200 (1 x t3.medium standby)
Database: $150 (db.t3.medium read replica)
Load Balancer: $25 (ALB standby)
Storage: $50 (S3 replication)
Data Transfer: $50
Total: ~$475/month
```

### Total DR Solution Cost
- **Monthly:** ~$1,350
- **Annual:** ~$16,200
- **Cost per hour of protection:** ~$1.85

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Approved By**: Solutions Architecture Team