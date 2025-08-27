# Scripts - AWS Disaster Recovery Web Application

## Overview

This directory contains automation scripts and utilities for AWS Disaster Recovery Web Application solution deployment, testing, and operations. Provides comprehensive disaster recovery capabilities using AWS services including Route 53, ELB, Auto Scaling, RDS Multi-AZ, and cross-region replication for business continuity.

---

## Script Categories

### Infrastructure Scripts
- **cloudformation-deploy.py** - CloudFormation stack deployment for multi-region DR
- **infrastructure-setup.sh** - Complete AWS DR infrastructure automation
- **vpc-peering-setup.py** - VPC peering and cross-region networking
- **route53-config.py** - Route 53 health checks and DNS failover
- **load-balancer-setup.py** - Application Load Balancer configuration

### Database Recovery Scripts
- **rds-setup.py** - RDS Multi-AZ and read replica configuration
- **database-backup.py** - Automated database backup and point-in-time recovery
- **cross-region-replication.py** - Cross-region database replication setup
- **database-failover.py** - Automated database failover procedures

### Application Recovery Scripts
- **application-deployment.py** - Multi-region application deployment
- **auto-scaling-config.py** - Auto Scaling group configuration for DR
- **ecs-cluster-setup.py** - ECS cluster deployment for containerized apps
- **lambda-deployment.sh** - Lambda function deployment for DR automation

### Failover Scripts
- **dns-failover.py** - Automated DNS failover orchestration
- **application-failover.py** - Application-level failover procedures
- **traffic-shifting.py** - Gradual traffic shifting between regions
- **failback-procedures.py** - Automated failback to primary region

### Testing Scripts
- **dr-testing-suite.py** - Comprehensive disaster recovery testing
- **rto-rpo-validation.py** - Recovery Time/Point Objective validation
- **chaos-engineering.py** - Chaos engineering for DR preparedness
- **load-testing.sh** - Load testing for failover scenarios

### Monitoring Scripts
- **health-monitoring.sh** - Multi-region health monitoring
- **cloudwatch-setup.py** - CloudWatch alarms and metrics configuration
- **notification-setup.py** - SNS alerts and notification configuration
- **log-aggregation.py** - Centralized logging across regions

---

## Prerequisites

### Required Tools
- **AWS CLI v2.15+** - AWS command line interface
- **Python 3.9+** - Python runtime environment
- **boto3** - AWS SDK for Python
- **AWS CDK v2** - AWS Cloud Development Kit
- **jq** - JSON processor for script automation
- **curl** - HTTP client for health checks

### AWS Services Required
- Amazon Route 53 (DNS and health checks)
- Elastic Load Balancing (application load balancers)
- Amazon Auto Scaling (automatic capacity management)
- Amazon RDS (database with Multi-AZ)
- Amazon S3 (backup storage and static content)
- Amazon CloudWatch (monitoring and alerting)
- Amazon SNS (notifications)
- AWS Lambda (automation functions)
- Amazon VPC (networking)

### Python Dependencies
```bash
pip install boto3 botocore aws-cdk-lib requests psycopg2-binary pymysql
```

### Configuration
```bash
# Configure AWS credentials for multiple regions
aws configure --profile dr-primary
aws configure set region us-east-1 --profile dr-primary
aws configure --profile dr-secondary  
aws configure set region us-west-2 --profile dr-secondary

# Set environment variables
export AWS_PROFILE=dr-primary
export PRIMARY_REGION=us-east-1
export SECONDARY_REGION=us-west-2
export DR_ENVIRONMENT=production
export RTO_TARGET=300  # 5 minutes
export RPO_TARGET=60   # 1 minute
export HEALTH_CHECK_INTERVAL=30
```

---

## Usage Instructions

### Infrastructure Deployment
```bash
# Deploy primary region infrastructure
python cloudformation-deploy.py \
  --region $PRIMARY_REGION \
  --stack-name dr-primary \
  --template-file ./templates/primary-region.yaml

# Deploy secondary region infrastructure  
python cloudformation-deploy.py \
  --region $SECONDARY_REGION \
  --stack-name dr-secondary \
  --template-file ./templates/secondary-region.yaml

# Setup VPC peering between regions
python vpc-peering-setup.py \
  --primary-region $PRIMARY_REGION \
  --secondary-region $SECONDARY_REGION \
  --enable-dns-resolution

# Configure Route 53 health checks and failover
python route53-config.py \
  --domain example.com \
  --primary-endpoint primary-lb.example.com \
  --secondary-endpoint secondary-lb.example.com \
  --health-check-interval $HEALTH_CHECK_INTERVAL
```

### Database Recovery Setup
```bash
# Configure RDS with Multi-AZ deployment
python rds-setup.py \
  --primary-region $PRIMARY_REGION \
  --enable-multi-az \
  --enable-encryption \
  --backup-retention 7

# Setup cross-region read replicas
python cross-region-replication.py \
  --source-region $PRIMARY_REGION \
  --target-region $SECONDARY_REGION \
  --enable-automatic-failover

# Configure automated backups
python database-backup.py \
  --backup-schedule "0 2 * * *" \
  --retention-days 30 \
  --cross-region-backup
```

### Application Deployment
```bash
# Deploy application to primary region
python application-deployment.py \
  --region $PRIMARY_REGION \
  --environment production \
  --health-check-path /health

# Deploy application to secondary region (standby)
python application-deployment.py \
  --region $SECONDARY_REGION \
  --environment standby \
  --minimal-capacity

# Configure Auto Scaling for DR scenarios
python auto-scaling-config.py \
  --primary-region $PRIMARY_REGION \
  --secondary-region $SECONDARY_REGION \
  --scale-out-cooldown 300 \
  --scale-in-cooldown 900
```

### Disaster Recovery Testing
```bash
# Run comprehensive DR test suite
python dr-testing-suite.py \
  --test-type full \
  --include-database-failover \
  --include-application-failover \
  --generate-report

# Validate RTO/RPO objectives
python rto-rpo-validation.py \
  --target-rto $RTO_TARGET \
  --target-rpo $RPO_TARGET \
  --test-scenarios ./test-scenarios.json

# Perform chaos engineering tests
python chaos-engineering.py \
  --chaos-type instance-termination \
  --target-region $PRIMARY_REGION \
  --duration 600 \
  --validate-recovery

# Load testing during failover
./load-testing.sh \
  --endpoint example.com \
  --concurrent-users 1000 \
  --duration 300 \
  --simulate-failover
```

### Failover Operations
```bash
# Initiate DNS failover to secondary region
python dns-failover.py \
  --domain example.com \
  --target-region $SECONDARY_REGION \
  --health-check-override \
  --notification-topic arn:aws:sns:region:account:dr-alerts

# Perform application failover
python application-failover.py \
  --source-region $PRIMARY_REGION \
  --target-region $SECONDARY_REGION \
  --scale-target-capacity 100 \
  --enable-notifications

# Execute database failover
python database-failover.py \
  --source-region $PRIMARY_REGION \
  --target-region $SECONDARY_REGION \
  --promote-read-replica \
  --update-application-config

# Gradual traffic shifting
python traffic-shifting.py \
  --source-region $PRIMARY_REGION \
  --target-region $SECONDARY_REGION \
  --shift-percentage 10,25,50,75,100 \
  --interval 300
```

### Monitoring and Alerting
```bash
# Setup comprehensive monitoring
./health-monitoring.sh \
  --regions $PRIMARY_REGION,$SECONDARY_REGION \
  --check-interval 60 \
  --alert-thresholds ./alert-thresholds.json

# Configure CloudWatch alarms
python cloudwatch-setup.py \
  --metrics HealthyHostCount,UnHealthyHostCount,DatabaseConnections \
  --alarm-actions arn:aws:sns:region:account:dr-alerts \
  --evaluation-periods 2

# Setup notification channels
python notification-setup.py \
  --sns-topic dr-alerts \
  --email-subscribers ops-team@company.com \
  --sms-subscribers +1234567890 \
  --slack-webhook https://hooks.slack.com/webhook
```

---

## Directory Structure

```
scripts/
├── ansible/              # Ansible playbooks for configuration management
├── bash/                 # Shell scripts for automation and monitoring
├── powershell/          # PowerShell scripts for Windows environments
├── python/              # Python scripts for AWS service integration
└── terraform/           # Terraform configurations for infrastructure
    ├── primary-region/   # Primary region infrastructure
    ├── secondary-region/ # Secondary region infrastructure
    └── shared/          # Shared resources (Route 53, IAM)
```

---

## Recovery Procedures

### Disaster Detection
1. **Automated Detection**: CloudWatch alarms detect service failures
2. **Health Check Failures**: Route 53 health checks fail for primary region
3. **Manual Trigger**: Operations team initiates DR procedures

### Failover Sequence
```bash
# 1. Assess the situation
python disaster-assessment.py --check-all-services --generate-status-report

# 2. Initiate database failover
python database-failover.py --promote-replica --verify-data-consistency  

# 3. Scale up secondary region capacity
python auto-scaling-config.py --region $SECONDARY_REGION --target-capacity 100

# 4. Update DNS to point to secondary region
python dns-failover.py --switch-to-secondary --verify-propagation

# 5. Validate recovery
python dr-testing-suite.py --test-type post-failover --quick-validation
```

### Failback Sequence
```bash
# 1. Verify primary region recovery
python failback-procedures.py --verify-primary-health --check-data-sync

# 2. Sync data from secondary to primary
python database-sync.py --source $SECONDARY_REGION --target $PRIMARY_REGION

# 3. Gradually shift traffic back
python traffic-shifting.py --target $PRIMARY_REGION --gradual-shift

# 4. Update DNS back to primary
python dns-failover.py --switch-to-primary --verify-health-checks
```

---

## Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| **RTO** (Recovery Time Objective) | < 5 minutes | Time to restore service |
| **RPO** (Recovery Point Objective) | < 1 minute | Maximum data loss |
| **DNS Propagation** | < 60 seconds | Route 53 TTL settings |
| **Health Check Interval** | 30 seconds | Route 53 health check frequency |
| **Auto Scaling Response** | < 3 minutes | Scale-out time |

---

## Error Handling and Troubleshooting

### Common Issues

#### DNS Failover Delays
```bash
# Check Route 53 health check status
aws route53 get-health-check --health-check-id <check-id>

# Force DNS record update
python route53-config.py --force-update --domain example.com
```

#### Database Replication Lag
```bash
# Monitor replication lag
python database-monitoring.py --check-replica-lag --alert-threshold 30

# Force replication sync
python cross-region-replication.py --force-sync --verify-consistency
```

#### Auto Scaling Issues
```bash
# Check scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name dr-asg

# Manual scaling override
python auto-scaling-config.py --manual-override --desired-capacity 10
```

### Monitoring Commands
```bash
# Check overall DR health
aws route53 list-health-checks --query 'HealthChecks[?Config.Type==`HTTPS`]'
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

---

## Security Best Practices

- Use cross-region IAM roles for secure access
- Enable AWS CloudTrail in both regions for audit logging
- Implement least-privilege access for DR automation
- Use AWS Secrets Manager for database credentials
- Enable encryption in transit and at rest for all services
- Regularly rotate access keys and certificates

---

## Cost Optimization

- Use Reserved Instances for predictable workloads
- Implement intelligent tiering for S3 backup storage
- Use Spot Instances for non-critical DR testing
- Monitor cross-region data transfer costs
- Implement lifecycle policies for backup retention

---

**Directory Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: AWS Cloud Infrastructure DevOps Team