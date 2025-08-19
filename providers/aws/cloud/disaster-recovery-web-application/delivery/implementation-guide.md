# AWS Disaster Recovery Solution - Implementation Guide

## Document Information
**Solution**: AWS Disaster Recovery for Web Applications  
**Version**: 1.0  
**Date**: January 2025  
**Audience**: Implementation Teams, DevOps Engineers  

---

## Overview

This implementation guide provides step-by-step instructions for deploying the AWS Disaster Recovery solution. The implementation follows a phased approach to minimize risk and ensure successful deployment.

### Implementation Phases
1. **Phase 1**: Foundation Setup (AWS accounts, networking, security)
2. **Phase 2**: Primary Region Deployment (application infrastructure)
3. **Phase 3**: Secondary Region Setup (DR infrastructure)
4. **Phase 4**: DR Configuration (replication, failover, monitoring)
5. **Phase 5**: Testing and Validation (DR testing, documentation)

---

## Prerequisites

Before starting implementation, ensure all prerequisites from the prerequisites document are met:
- AWS accounts configured with appropriate permissions
- Domain name registered and accessible
- Application code and database schema ready
- Team trained on AWS services and tools
- Implementation environment prepared

---

## Phase 1: Foundation Setup

### Step 1.1: AWS Account Preparation

#### Configure AWS CLI
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
# Enter your Access Key ID
# Enter your Secret Access Key
# Default region: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

#### Set Environment Variables
```bash
# Set project variables
export PROJECT_NAME="dr-webapp"
export PRIMARY_REGION="us-east-1"
export SECONDARY_REGION="us-west-2"
export DOMAIN_NAME="example.com"
export ENVIRONMENT="production"
```

### Step 1.2: IAM Roles and Policies

#### Create EC2 Instance Role
```bash
# Create trust policy for EC2
cat > ec2-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
  --role-name ${PROJECT_NAME}-ec2-role \
  --assume-role-policy-document file://ec2-trust-policy.json

# Attach policies
aws iam attach-role-policy \
  --role-name ${PROJECT_NAME}-ec2-role \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

aws iam attach-role-policy \
  --role-name ${PROJECT_NAME}-ec2-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create instance profile
aws iam create-instance-profile \
  --instance-profile-name ${PROJECT_NAME}-ec2-profile

aws iam add-role-to-instance-profile \
  --instance-profile-name ${PROJECT_NAME}-ec2-profile \
  --role-name ${PROJECT_NAME}-ec2-role
```

#### Create S3 Replication Role
```bash
# Create trust policy for S3 replication
cat > s3-replication-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create replication policy
cat > s3-replication-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl"
      ],
      "Resource": "arn:aws:s3:::${PROJECT_NAME}-primary/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Resource": "arn:aws:s3:::${PROJECT_NAME}-secondary/*"
    }
  ]
}
EOF

# Create IAM role for S3 replication
aws iam create-role \
  --role-name ${PROJECT_NAME}-s3-replication-role \
  --assume-role-policy-document file://s3-replication-trust-policy.json

aws iam put-role-policy \
  --role-name ${PROJECT_NAME}-s3-replication-role \
  --policy-name ${PROJECT_NAME}-s3-replication-policy \
  --policy-document file://s3-replication-policy.json
```

### Step 1.3: KMS Key Setup

#### Create KMS Keys for Encryption
```bash
# Create KMS key for primary region
PRIMARY_KEY_ID=$(aws kms create-key \
  --region ${PRIMARY_REGION} \
  --description "${PROJECT_NAME} encryption key - primary region" \
  --query 'KeyMetadata.KeyId' \
  --output text)

# Create alias for primary key
aws kms create-alias \
  --region ${PRIMARY_REGION} \
  --alias-name alias/${PROJECT_NAME}-primary \
  --target-key-id ${PRIMARY_KEY_ID}

# Create KMS key for secondary region
SECONDARY_KEY_ID=$(aws kms create-key \
  --region ${SECONDARY_REGION} \
  --description "${PROJECT_NAME} encryption key - secondary region" \
  --query 'KeyMetadata.KeyId' \
  --output text)

# Create alias for secondary key
aws kms create-alias \
  --region ${SECONDARY_REGION} \
  --alias-name alias/${PROJECT_NAME}-secondary \
  --target-key-id ${SECONDARY_KEY_ID}

echo "Primary KMS Key ID: ${PRIMARY_KEY_ID}"
echo "Secondary KMS Key ID: ${SECONDARY_KEY_ID}"
```

---

## Phase 2: Primary Region Deployment

### Step 2.1: Network Infrastructure

#### Deploy VPC and Networking
```bash
# Create VPC
VPC_ID=$(aws ec2 create-vpc \
  --region ${PRIMARY_REGION} \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

# Tag VPC
aws ec2 create-tags \
  --region ${PRIMARY_REGION} \
  --resources ${VPC_ID} \
  --tags Key=Name,Value=${PROJECT_NAME}-primary-vpc

# Enable DNS hostnames
aws ec2 modify-vpc-attribute \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --enable-dns-hostnames

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --region ${PRIMARY_REGION} \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

# Attach Internet Gateway
aws ec2 attach-internet-gateway \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --internet-gateway-id ${IGW_ID}

# Create subnets
PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ${PRIMARY_REGION}a \
  --query 'Subnet.SubnetId' \
  --output text)

PUBLIC_SUBNET_2=$(aws ec2 create-subnet \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ${PRIMARY_REGION}b \
  --query 'Subnet.SubnetId' \
  --output text)

PRIVATE_SUBNET_1=$(aws ec2 create-subnet \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.10.0/24 \
  --availability-zone ${PRIMARY_REGION}a \
  --query 'Subnet.SubnetId' \
  --output text)

PRIVATE_SUBNET_2=$(aws ec2 create-subnet \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.11.0/24 \
  --availability-zone ${PRIMARY_REGION}b \
  --query 'Subnet.SubnetId' \
  --output text)

DB_SUBNET_1=$(aws ec2 create-subnet \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.20.0/24 \
  --availability-zone ${PRIMARY_REGION}a \
  --query 'Subnet.SubnetId' \
  --output text)

DB_SUBNET_2=$(aws ec2 create-subnet \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.21.0/24 \
  --availability-zone ${PRIMARY_REGION}b \
  --query 'Subnet.SubnetId' \
  --output text)

# Tag subnets
aws ec2 create-tags --region ${PRIMARY_REGION} --resources ${PUBLIC_SUBNET_1} --tags Key=Name,Value=${PROJECT_NAME}-public-1
aws ec2 create-tags --region ${PRIMARY_REGION} --resources ${PUBLIC_SUBNET_2} --tags Key=Name,Value=${PROJECT_NAME}-public-2
aws ec2 create-tags --region ${PRIMARY_REGION} --resources ${PRIVATE_SUBNET_1} --tags Key=Name,Value=${PROJECT_NAME}-private-1
aws ec2 create-tags --region ${PRIMARY_REGION} --resources ${PRIVATE_SUBNET_2} --tags Key=Name,Value=${PROJECT_NAME}-private-2
aws ec2 create-tags --region ${PRIMARY_REGION} --resources ${DB_SUBNET_1} --tags Key=Name,Value=${PROJECT_NAME}-db-1
aws ec2 create-tags --region ${PRIMARY_REGION} --resources ${DB_SUBNET_2} --tags Key=Name,Value=${PROJECT_NAME}-db-2
```

#### Create NAT Gateways
```bash
# Allocate Elastic IPs
EIP_1=$(aws ec2 allocate-address \
  --region ${PRIMARY_REGION} \
  --domain vpc \
  --query 'AllocationId' \
  --output text)

EIP_2=$(aws ec2 allocate-address \
  --region ${PRIMARY_REGION} \
  --domain vpc \
  --query 'AllocationId' \
  --output text)

# Create NAT Gateways
NAT_GW_1=$(aws ec2 create-nat-gateway \
  --region ${PRIMARY_REGION} \
  --subnet-id ${PUBLIC_SUBNET_1} \
  --allocation-id ${EIP_1} \
  --query 'NatGateway.NatGatewayId' \
  --output text)

NAT_GW_2=$(aws ec2 create-nat-gateway \
  --region ${PRIMARY_REGION} \
  --subnet-id ${PUBLIC_SUBNET_2} \
  --allocation-id ${EIP_2} \
  --query 'NatGateway.NatGatewayId' \
  --output text)

# Wait for NAT Gateways to be available
aws ec2 wait nat-gateway-available --region ${PRIMARY_REGION} --nat-gateway-ids ${NAT_GW_1} ${NAT_GW_2}
```

#### Configure Route Tables
```bash
# Get default route table
DEFAULT_RT=$(aws ec2 describe-route-tables \
  --region ${PRIMARY_REGION} \
  --filters "Name=vpc-id,Values=${VPC_ID}" "Name=association.main,Values=true" \
  --query 'RouteTables[0].RouteTableId' \
  --output text)

# Create public route table
PUBLIC_RT=$(aws ec2 create-route-table \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --query 'RouteTable.RouteTableId' \
  --output text)

# Add route to Internet Gateway
aws ec2 create-route \
  --region ${PRIMARY_REGION} \
  --route-table-id ${PUBLIC_RT} \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id ${IGW_ID}

# Associate public subnets with public route table
aws ec2 associate-route-table --region ${PRIMARY_REGION} --subnet-id ${PUBLIC_SUBNET_1} --route-table-id ${PUBLIC_RT}
aws ec2 associate-route-table --region ${PRIMARY_REGION} --subnet-id ${PUBLIC_SUBNET_2} --route-table-id ${PUBLIC_RT}

# Create private route tables
PRIVATE_RT_1=$(aws ec2 create-route-table \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --query 'RouteTable.RouteTableId' \
  --output text)

PRIVATE_RT_2=$(aws ec2 create-route-table \
  --region ${PRIMARY_REGION} \
  --vpc-id ${VPC_ID} \
  --query 'RouteTable.RouteTableId' \
  --output text)

# Add routes to NAT Gateways
aws ec2 create-route --region ${PRIMARY_REGION} --route-table-id ${PRIVATE_RT_1} --destination-cidr-block 0.0.0.0/0 --nat-gateway-id ${NAT_GW_1}
aws ec2 create-route --region ${PRIMARY_REGION} --route-table-id ${PRIVATE_RT_2} --destination-cidr-block 0.0.0.0/0 --nat-gateway-id ${NAT_GW_2}

# Associate private subnets with private route tables
aws ec2 associate-route-table --region ${PRIMARY_REGION} --subnet-id ${PRIVATE_SUBNET_1} --route-table-id ${PRIVATE_RT_1}
aws ec2 associate-route-table --region ${PRIMARY_REGION} --subnet-id ${PRIVATE_SUBNET_2} --route-table-id ${PRIVATE_RT_2}
aws ec2 associate-route-table --region ${PRIMARY_REGION} --subnet-id ${DB_SUBNET_1} --route-table-id ${PRIVATE_RT_1}
aws ec2 associate-route-table --region ${PRIMARY_REGION} --subnet-id ${DB_SUBNET_2} --route-table-id ${PRIVATE_RT_2}
```

### Step 2.2: Security Groups

#### Create Security Groups
```bash
# Create ALB Security Group
ALB_SG=$(aws ec2 create-security-group \
  --region ${PRIMARY_REGION} \
  --group-name ${PROJECT_NAME}-alb-sg \
  --description "Security group for Application Load Balancer" \
  --vpc-id ${VPC_ID} \
  --query 'GroupId' \
  --output text)

# Create EC2 Security Group
EC2_SG=$(aws ec2 create-security-group \
  --region ${PRIMARY_REGION} \
  --group-name ${PROJECT_NAME}-ec2-sg \
  --description "Security group for EC2 instances" \
  --vpc-id ${VPC_ID} \
  --query 'GroupId' \
  --output text)

# Create RDS Security Group
RDS_SG=$(aws ec2 create-security-group \
  --region ${PRIMARY_REGION} \
  --group-name ${PROJECT_NAME}-rds-sg \
  --description "Security group for RDS database" \
  --vpc-id ${VPC_ID} \
  --query 'GroupId' \
  --output text)

# Configure ALB Security Group rules
aws ec2 authorize-security-group-ingress \
  --region ${PRIMARY_REGION} \
  --group-id ${ALB_SG} \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --region ${PRIMARY_REGION} \
  --group-id ${ALB_SG} \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# Configure EC2 Security Group rules
aws ec2 authorize-security-group-ingress \
  --region ${PRIMARY_REGION} \
  --group-id ${EC2_SG} \
  --protocol tcp \
  --port 80 \
  --source-group ${ALB_SG}

aws ec2 authorize-security-group-ingress \
  --region ${PRIMARY_REGION} \
  --group-id ${EC2_SG} \
  --protocol tcp \
  --port 22 \
  --cidr 10.0.0.0/16

# Configure RDS Security Group rules
aws ec2 authorize-security-group-ingress \
  --region ${PRIMARY_REGION} \
  --group-id ${RDS_SG} \
  --protocol tcp \
  --port 3306 \
  --source-group ${EC2_SG}
```

### Step 2.3: Database Setup

#### Create DB Subnet Group
```bash
# Create DB subnet group
aws rds create-db-subnet-group \
  --region ${PRIMARY_REGION} \
  --db-subnet-group-name ${PROJECT_NAME}-db-subnet-group \
  --db-subnet-group-description "DB subnet group for ${PROJECT_NAME}" \
  --subnet-ids ${DB_SUBNET_1} ${DB_SUBNET_2}
```

#### Create RDS Database
```bash
# Generate random password
DB_PASSWORD=$(openssl rand -base64 12)
echo "Database Password: ${DB_PASSWORD}" > db-credentials.txt
echo "IMPORTANT: Store this password securely!"

# Create RDS instance
aws rds create-db-instance \
  --region ${PRIMARY_REGION} \
  --db-instance-identifier ${PROJECT_NAME}-primary-db \
  --db-instance-class db.t3.medium \
  --engine mysql \
  --engine-version 8.0.35 \
  --master-username admin \
  --master-user-password "${DB_PASSWORD}" \
  --allocated-storage 20 \
  --storage-type gp2 \
  --storage-encrypted \
  --kms-key-id alias/${PROJECT_NAME}-primary \
  --vpc-security-group-ids ${RDS_SG} \
  --db-subnet-group-name ${PROJECT_NAME}-db-subnet-group \
  --backup-retention-period 7 \
  --multi-az \
  --auto-minor-version-upgrade \
  --publicly-accessible false \
  --deletion-protection

# Wait for database to be available
echo "Waiting for database to be available... This may take several minutes."
aws rds wait db-instance-available --region ${PRIMARY_REGION} --db-instance-identifier ${PROJECT_NAME}-primary-db

# Get database endpoint
DB_ENDPOINT=$(aws rds describe-db-instances \
  --region ${PRIMARY_REGION} \
  --db-instance-identifier ${PROJECT_NAME}-primary-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

echo "Database endpoint: ${DB_ENDPOINT}"
```

### Step 2.4: S3 Bucket Setup

#### Create S3 Bucket for Primary Region
```bash
# Create S3 bucket
aws s3 mb s3://${PROJECT_NAME}-primary-${AWS_ACCOUNT_ID} --region ${PRIMARY_REGION}

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket ${PROJECT_NAME}-primary-${AWS_ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

# Configure server-side encryption
aws s3api put-bucket-encryption \
  --bucket ${PROJECT_NAME}-primary-${AWS_ACCOUNT_ID} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "aws:kms",
          "KMSMasterKeyID": "alias/'${PROJECT_NAME}'-primary"
        },
        "BucketKeyEnabled": true
      }
    ]
  }'

# Configure public access block
aws s3api put-public-access-block \
  --bucket ${PROJECT_NAME}-primary-${AWS_ACCOUNT_ID} \
  --public-access-block-configuration \
    BlockPublicAcls=true,\
    IgnorePublicAcls=true,\
    BlockPublicPolicy=true,\
    RestrictPublicBuckets=true
```

### Step 2.5: Application Infrastructure

#### Create Launch Template
```bash
# Create user data script
cat > user-data.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y httpd mysql
systemctl start httpd
systemctl enable httpd

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CWEOF'
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/httpd/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/httpd/error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
CWEOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# Create health check endpoint
cat > /var/www/html/health << 'HEALTHEOF'
#!/bin/bash
echo "Content-Type: application/json"
echo ""
echo '{"status":"healthy","timestamp":"'$(date -Iseconds)'","version":"1.0.0"}'
HEALTHEOF

chmod +x /var/www/html/health

# Configure health check in Apache
echo 'ScriptAlias /health /var/www/html/health' >> /etc/httpd/conf/httpd.conf
systemctl restart httpd
EOF

# Base64 encode user data
USER_DATA_B64=$(base64 -w 0 user-data.sh)

# Create launch template
aws ec2 create-launch-template \
  --region ${PRIMARY_REGION} \
  --launch-template-name ${PROJECT_NAME}-launch-template \
  --launch-template-data '{
    "ImageId": "ami-0c02fb55956c7d316",
    "InstanceType": "t3.medium",
    "IamInstanceProfile": {
      "Name": "'${PROJECT_NAME}'-ec2-profile"
    },
    "SecurityGroupIds": ["'${EC2_SG}'"],
    "UserData": "'${USER_DATA_B64}'",
    "TagSpecifications": [
      {
        "ResourceType": "instance",
        "Tags": [
          {
            "Key": "Name",
            "Value": "'${PROJECT_NAME}'-web-server"
          },
          {
            "Key": "Project",
            "Value": "'${PROJECT_NAME}'"
          }
        ]
      }
    ]
  }'
```

#### Create Application Load Balancer
```bash
# Create Application Load Balancer
ALB_ARN=$(aws elbv2 create-load-balancer \
  --region ${PRIMARY_REGION} \
  --name ${PROJECT_NAME}-alb \
  --subnets ${PUBLIC_SUBNET_1} ${PUBLIC_SUBNET_2} \
  --security-groups ${ALB_SG} \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text)

# Get ALB DNS name
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --region ${PRIMARY_REGION} \
  --load-balancer-arns ${ALB_ARN} \
  --query 'LoadBalancers[0].DNSName' \
  --output text)

echo "ALB DNS Name: ${ALB_DNS}"

# Create target group
TG_ARN=$(aws elbv2 create-target-group \
  --region ${PRIMARY_REGION} \
  --name ${PROJECT_NAME}-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id ${VPC_ID} \
  --health-check-path /health \
  --health-check-interval-seconds 30 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 5 \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

# Create listener
aws elbv2 create-listener \
  --region ${PRIMARY_REGION} \
  --load-balancer-arn ${ALB_ARN} \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=${TG_ARN}
```

#### Create Auto Scaling Group
```bash
# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
  --region ${PRIMARY_REGION} \
  --auto-scaling-group-name ${PROJECT_NAME}-asg \
  --launch-template LaunchTemplateName=${PROJECT_NAME}-launch-template,Version=\$Latest \
  --min-size 2 \
  --max-size 6 \
  --desired-capacity 2 \
  --target-group-arns ${TG_ARN} \
  --health-check-type ELB \
  --health-check-grace-period 300 \
  --vpc-zone-identifier "${PRIVATE_SUBNET_1},${PRIVATE_SUBNET_2}"

# Create scaling policies
SCALE_UP_POLICY=$(aws autoscaling put-scaling-policy \
  --region ${PRIMARY_REGION} \
  --auto-scaling-group-name ${PROJECT_NAME}-asg \
  --policy-name ${PROJECT_NAME}-scale-up \
  --policy-type StepScaling \
  --adjustment-type ChangeInCapacity \
  --step-adjustments MetricIntervalLowerBound=0,ScalingAdjustment=1 \
  --query 'PolicyARN' \
  --output text)

SCALE_DOWN_POLICY=$(aws autoscaling put-scaling-policy \
  --region ${PRIMARY_REGION} \
  --auto-scaling-group-name ${PROJECT_NAME}-asg \
  --policy-name ${PROJECT_NAME}-scale-down \
  --policy-type StepScaling \
  --adjustment-type ChangeInCapacity \
  --step-adjustments MetricIntervalUpperBound=0,ScalingAdjustment=-1 \
  --query 'PolicyARN' \
  --output text)

# Create CloudWatch alarms
aws cloudwatch put-metric-alarm \
  --region ${PRIMARY_REGION} \
  --alarm-name ${PROJECT_NAME}-cpu-high \
  --alarm-description "Scale up on high CPU" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions ${SCALE_UP_POLICY} \
  --dimensions Name=AutoScalingGroupName,Value=${PROJECT_NAME}-asg

aws cloudwatch put-metric-alarm \
  --region ${PRIMARY_REGION} \
  --alarm-name ${PROJECT_NAME}-cpu-low \
  --alarm-description "Scale down on low CPU" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 20 \
  --comparison-operator LessThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions ${SCALE_DOWN_POLICY} \
  --dimensions Name=AutoScalingGroupName,Value=${PROJECT_NAME}-asg
```

---

## Phase 3: Secondary Region Setup

### Step 3.1: Replicate Infrastructure in Secondary Region

#### Set Secondary Region Variables
```bash
# Switch to secondary region
export CURRENT_REGION=${SECONDARY_REGION}

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
```

#### Deploy VPC in Secondary Region
```bash
# Create VPC in secondary region (similar to primary)
# Note: Use the same commands as Step 2.1 but with different CIDR (10.1.0.0/16)

# Create VPC
SEC_VPC_ID=$(aws ec2 create-vpc \
  --region ${SECONDARY_REGION} \
  --cidr-block 10.1.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

# Continue with subnet creation using 10.1.x.x addressing...
# (Similar commands as primary region but with secondary region parameters)
```

### Step 3.2: Create Read Replica

#### Create RDS Read Replica
```bash
# Create read replica in secondary region
aws rds create-db-instance-read-replica \
  --region ${SECONDARY_REGION} \
  --db-instance-identifier ${PROJECT_NAME}-secondary-db \
  --source-db-instance-identifier arn:aws:rds:${PRIMARY_REGION}:${AWS_ACCOUNT_ID}:db:${PROJECT_NAME}-primary-db \
  --db-instance-class db.t3.medium \
  --storage-encrypted \
  --kms-key-id alias/${PROJECT_NAME}-secondary \
  --vpc-security-group-ids ${SEC_RDS_SG} \
  --db-subnet-group-name ${PROJECT_NAME}-secondary-db-subnet-group

# Wait for read replica to be available
aws rds wait db-instance-available --region ${SECONDARY_REGION} --db-instance-identifier ${PROJECT_NAME}-secondary-db
```

### Step 3.3: Configure S3 Cross-Region Replication

#### Create Secondary S3 Bucket
```bash
# Create S3 bucket in secondary region
aws s3 mb s3://${PROJECT_NAME}-secondary-${AWS_ACCOUNT_ID} --region ${SECONDARY_REGION}

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket ${PROJECT_NAME}-secondary-${AWS_ACCOUNT_ID} \
  --versioning-configuration Status=Enabled
```

#### Configure Cross-Region Replication
```bash
# Create replication configuration
cat > s3-replication-config.json << EOF
{
  "Role": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${PROJECT_NAME}-s3-replication-role",
  "Rules": [
    {
      "ID": "ReplicateEverything",
      "Status": "Enabled",
      "Priority": 1,
      "Filter": {
        "Prefix": ""
      },
      "Destination": {
        "Bucket": "arn:aws:s3:::${PROJECT_NAME}-secondary-${AWS_ACCOUNT_ID}",
        "StorageClass": "STANDARD",
        "EncryptionConfiguration": {
          "ReplicaKmsKeyID": "alias/${PROJECT_NAME}-secondary"
        }
      }
    }
  ]
}
EOF

# Apply replication configuration
aws s3api put-bucket-replication \
  --bucket ${PROJECT_NAME}-primary-${AWS_ACCOUNT_ID} \
  --replication-configuration file://s3-replication-config.json
```

---

## Phase 4: DR Configuration

### Step 4.1: Route 53 Setup

#### Create Hosted Zone
```bash
# Create hosted zone
HOSTED_ZONE_ID=$(aws route53 create-hosted-zone \
  --name ${DOMAIN_NAME} \
  --caller-reference $(date +%s) \
  --query 'HostedZone.Id' \
  --output text)

echo "Hosted Zone ID: ${HOSTED_ZONE_ID}"

# Get name servers
aws route53 get-hosted-zone --id ${HOSTED_ZONE_ID} --query 'DelegationSet.NameServers'
```

#### Create Health Checks
```bash
# Create health check for primary region
PRIMARY_HEALTH_CHECK=$(aws route53 create-health-check \
  --caller-reference primary-$(date +%s) \
  --health-check-config '{
    "Type": "HTTP",
    "ResourcePath": "/health",
    "FullyQualifiedDomainName": "'${ALB_DNS}'",
    "Port": 80,
    "RequestInterval": 30,
    "FailureThreshold": 3
  }' \
  --query 'HealthCheck.Id' \
  --output text)

echo "Primary Health Check ID: ${PRIMARY_HEALTH_CHECK}"
```

#### Configure DNS Records
```bash
# Create DNS records with failover routing
cat > primary-record.json << EOF
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "${DOMAIN_NAME}",
        "Type": "A",
        "SetIdentifier": "primary",
        "Failover": "PRIMARY",
        "HealthCheckId": "${PRIMARY_HEALTH_CHECK}",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "${PRIMARY_ALB_IP}"
          }
        ]
      }
    }
  ]
}
EOF

# Apply DNS record
aws route53 change-resource-record-sets \
  --hosted-zone-id ${HOSTED_ZONE_ID} \
  --change-batch file://primary-record.json
```

### Step 4.2: Monitoring and Alerting

#### Create CloudWatch Dashboards
```bash
# Create dashboard configuration
cat > dashboard-config.json << EOF
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${ALB_ARN##*/}"],
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${ALB_ARN##*/}"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${PRIMARY_REGION}",
        "title": "Primary Region - ALB Metrics"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${PROJECT_NAME}-primary-db"],
          ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${PROJECT_NAME}-primary-db"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${PRIMARY_REGION}",
        "title": "Primary Region - RDS Metrics"
      }
    }
  ]
}
EOF

# Create dashboard
aws cloudwatch put-dashboard \
  --region ${PRIMARY_REGION} \
  --dashboard-name ${PROJECT_NAME}-dashboard \
  --dashboard-body file://dashboard-config.json
```

#### Set Up SNS Notifications
```bash
# Create SNS topic
SNS_TOPIC_ARN=$(aws sns create-topic \
  --region ${PRIMARY_REGION} \
  --name ${PROJECT_NAME}-alerts \
  --query 'TopicArn' \
  --output text)

# Subscribe email to topic
aws sns subscribe \
  --region ${PRIMARY_REGION} \
  --topic-arn ${SNS_TOPIC_ARN} \
  --protocol email \
  --notification-endpoint your-email@company.com

echo "Please confirm the SNS subscription in your email."
```

---

## Phase 5: Testing and Validation

### Step 5.1: Application Testing

#### Test Primary Region
```bash
# Test health check endpoint
curl -f http://${ALB_DNS}/health

# Test application functionality
curl -I http://${ALB_DNS}/

# Check database connectivity
mysql -h ${DB_ENDPOINT} -u admin -p${DB_PASSWORD} -e "SELECT 1;"
```

#### Test Auto Scaling
```bash
# Generate load to test auto scaling
# Install Apache Bench for load testing
sudo yum install -y httpd-tools

# Generate load (run from a separate EC2 instance)
ab -n 10000 -c 100 http://${ALB_DNS}/

# Monitor scaling activity
aws autoscaling describe-scaling-activities \
  --region ${PRIMARY_REGION} \
  --auto-scaling-group-name ${PROJECT_NAME}-asg
```

### Step 5.2: Disaster Recovery Testing

#### Test Failover Process
```bash
# Simulate primary region failure by stopping ALB
aws elbv2 modify-load-balancer-attributes \
  --region ${PRIMARY_REGION} \
  --load-balancer-arn ${ALB_ARN} \
  --attributes Key=deletion_protection.enabled,Value=false

# Monitor DNS failover
watch -n 10 'dig ${DOMAIN_NAME} +short'

# Test secondary region accessibility
curl -f http://${SECONDARY_ALB_DNS}/health
```

#### Test Database Promotion
```bash
# Promote read replica to primary
aws rds promote-read-replica \
  --region ${SECONDARY_REGION} \
  --db-instance-identifier ${PROJECT_NAME}-secondary-db

# Wait for promotion to complete
aws rds wait db-instance-available \
  --region ${SECONDARY_REGION} \
  --db-instance-identifier ${PROJECT_NAME}-secondary-db

# Test database write capability
mysql -h ${SECONDARY_DB_ENDPOINT} -u admin -p${DB_PASSWORD} \
  -e "CREATE TABLE test_table (id INT PRIMARY KEY, message VARCHAR(50));"
```

### Step 5.3: Performance Validation

#### Measure RTO and RPO
```bash
# Script to measure failover time
cat > measure-failover.sh << 'EOF'
#!/bin/bash
START_TIME=$(date +%s)
DOMAIN=$1

echo "Starting failover test at $(date)"
echo "Monitoring DNS resolution for $DOMAIN"

ORIGINAL_IP=$(dig +short $DOMAIN | head -1)
echo "Original IP: $ORIGINAL_IP"

# Simulate failure (this would be done differently in real scenario)
echo "Simulating primary region failure..."

# Monitor for IP change
while true; do
    CURRENT_IP=$(dig +short $DOMAIN | head -1)
    if [ "$CURRENT_IP" != "$ORIGINAL_IP" ] && [ -n "$CURRENT_IP" ]; then
        END_TIME=$(date +%s)
        FAILOVER_TIME=$((END_TIME - START_TIME))
        echo "Failover completed at $(date)"
        echo "New IP: $CURRENT_IP"
        echo "Total failover time: ${FAILOVER_TIME} seconds"
        break
    fi
    sleep 10
done
EOF

chmod +x measure-failover.sh
```

---

## Post-Implementation Tasks

### Step 6.1: Documentation

#### Update Configuration Documentation
```bash
# Create configuration summary
cat > deployment-summary.txt << EOF
Deployment Summary for ${PROJECT_NAME}
=====================================

Primary Region: ${PRIMARY_REGION}
Secondary Region: ${SECONDARY_REGION}

Infrastructure IDs:
- VPC: ${VPC_ID}
- ALB: ${ALB_ARN}
- Target Group: ${TG_ARN}
- Auto Scaling Group: ${PROJECT_NAME}-asg
- RDS Primary: ${PROJECT_NAME}-primary-db
- RDS Secondary: ${PROJECT_NAME}-secondary-db
- S3 Primary: ${PROJECT_NAME}-primary-${AWS_ACCOUNT_ID}
- S3 Secondary: ${PROJECT_NAME}-secondary-${AWS_ACCOUNT_ID}

DNS Configuration:
- Hosted Zone: ${HOSTED_ZONE_ID}
- Domain: ${DOMAIN_NAME}
- Health Check: ${PRIMARY_HEALTH_CHECK}

Monitoring:
- SNS Topic: ${SNS_TOPIC_ARN}
- Dashboard: ${PROJECT_NAME}-dashboard

Access Information:
- ALB DNS: ${ALB_DNS}
- DB Endpoint: ${DB_ENDPOINT}
- DB Password: [See db-credentials.txt]

Next Steps:
1. Update DNS nameservers with your domain registrar
2. Configure SSL certificates
3. Deploy your application code
4. Set up monitoring alerts
5. Schedule regular DR testing
EOF

echo "Deployment complete! See deployment-summary.txt for details."
```

### Step 6.2: Security Hardening

#### Implement Additional Security Measures
```bash
# Enable VPC Flow Logs
aws ec2 create-flow-logs \
  --region ${PRIMARY_REGION} \
  --resource-type VPC \
  --resource-ids ${VPC_ID} \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /aws/vpc/flowlogs

# Enable CloudTrail
aws cloudtrail create-trail \
  --region ${PRIMARY_REGION} \
  --name ${PROJECT_NAME}-cloudtrail \
  --s3-bucket-name ${PROJECT_NAME}-cloudtrail-${AWS_ACCOUNT_ID} \
  --include-global-service-events \
  --is-multi-region-trail

# Enable GuardDuty
aws guardduty create-detector \
  --region ${PRIMARY_REGION} \
  --enable
```

### Step 6.3: Operational Readiness

#### Create Operational Procedures
```bash
# Create maintenance scripts directory
mkdir -p operational-scripts

# Create backup verification script
cat > operational-scripts/verify-backups.sh << 'EOF'
#!/bin/bash
# Verify RDS automated backups
aws rds describe-db-snapshots \
  --db-instance-identifier ${PROJECT_NAME}-primary-db \
  --snapshot-type automated \
  --query 'DBSnapshots[0].[DBSnapshotIdentifier,SnapshotCreateTime,Status]'

# Verify S3 replication status
aws s3api head-object \
  --bucket ${PROJECT_NAME}-primary-${AWS_ACCOUNT_ID} \
  --key test-replication-file.txt \
  --query 'ReplicationStatus'
EOF

# Create health check script
cat > operational-scripts/health-check.sh << 'EOF'
#!/bin/bash
# Check primary region health
echo "Checking primary region health..."
curl -sf http://${ALB_DNS}/health || echo "Primary region health check failed"

# Check secondary region health
echo "Checking secondary region health..."
curl -sf http://${SECONDARY_ALB_DNS}/health || echo "Secondary region health check failed"

# Check database replication lag
aws cloudwatch get-metric-statistics \
  --region ${SECONDARY_REGION} \
  --namespace AWS/RDS \
  --metric-name ReplicaLag \
  --start-time $(date -d '1 hour ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 300 \
  --statistics Average \
  --dimensions Name=DBInstanceIdentifier,Value=${PROJECT_NAME}-secondary-db
EOF

chmod +x operational-scripts/*.sh
```

---

## Troubleshooting Common Issues

### Issue 1: Auto Scaling Not Working
```bash
# Check Auto Scaling Group status
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names ${PROJECT_NAME}-asg

# Check scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name ${PROJECT_NAME}-asg

# Check CloudWatch alarms
aws cloudwatch describe-alarms \
  --alarm-names ${PROJECT_NAME}-cpu-high ${PROJECT_NAME}-cpu-low
```

### Issue 2: Health Check Failures
```bash
# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn ${TG_ARN}

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids ${EC2_SG} ${ALB_SG}

# Test health endpoint directly
curl -v http://${ALB_DNS}/health
```

### Issue 3: RDS Replication Issues
```bash
# Check replication lag
aws cloudwatch get-metric-statistics \
  --region ${SECONDARY_REGION} \
  --namespace AWS/RDS \
  --metric-name ReplicaLag \
  --start-time $(date -d '1 hour ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 300 \
  --statistics Average \
  --dimensions Name=DBInstanceIdentifier,Value=${PROJECT_NAME}-secondary-db

# Check RDS events
aws rds describe-events \
  --source-identifier ${PROJECT_NAME}-secondary-db \
  --source-type db-instance
```

---

## Cleanup (For Testing Environments)

### Clean Up Resources
```bash
# WARNING: This will delete all resources. Use only for test environments.

# Delete Auto Scaling Group
aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name ${PROJECT_NAME}-asg \
  --force-delete

# Delete Launch Template
aws ec2 delete-launch-template \
  --launch-template-name ${PROJECT_NAME}-launch-template

# Delete Load Balancer
aws elbv2 delete-load-balancer \
  --load-balancer-arn ${ALB_ARN}

# Delete Target Group
aws elbv2 delete-target-group \
  --target-group-arn ${TG_ARN}

# Delete RDS instances
aws rds delete-db-instance \
  --db-instance-identifier ${PROJECT_NAME}-primary-db \
  --skip-final-snapshot

# Delete S3 buckets
aws s3 rb s3://${PROJECT_NAME}-primary-${AWS_ACCOUNT_ID} --force
aws s3 rb s3://${PROJECT_NAME}-secondary-${AWS_ACCOUNT_ID} --force

# Delete VPC (will delete associated resources)
aws ec2 delete-vpc --vpc-id ${VPC_ID}
```

---

## Next Steps

1. **Application Deployment**: Deploy your actual application code
2. **SSL Configuration**: Set up SSL certificates for HTTPS
3. **Monitoring Enhancement**: Add custom application metrics
4. **Performance Optimization**: Fine-tune based on usage patterns
5. **Disaster Recovery Testing**: Schedule regular DR tests
6. **Documentation Updates**: Keep all documentation current

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Next Review**: April 2025  
**Maintained By**: Implementation Team