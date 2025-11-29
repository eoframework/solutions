# Terraform Environments

This directory contains environment-specific Terraform configurations for deploying the solution infrastructure.

## Directory Structure

```
environments/
├── prod/           # Production environment (full deployment)
├── test/           # Test environment (minimal deployment)
├── dr/             # Disaster Recovery environment
└── README.md       # This file
```

## Prerequisites

### 1. Terraform Installation

Install Terraform version 1.6.0 or later:

```bash
# macOS (Homebrew)
brew install terraform

# Linux (apt)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform version
```

### 2. AWS CLI Installation & Configuration

Install AWS CLI v2:

```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Verify installation
aws --version
```

### 3. AWS Authentication

Choose ONE of the following authentication methods:

#### Option A: AWS CLI Profile (Recommended for local development)

Configure named profiles in `~/.aws/credentials`:

```ini
[mycompany-prod]
aws_access_key_id = AKIA...
aws_secret_access_key = ...

[mycompany-test]
aws_access_key_id = AKIA...
aws_secret_access_key = ...

[mycompany-dr]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
```

Then set the profile in `main.tfvars`:

```hcl
aws_profile = "mycompany-prod"
```

#### Option B: Environment Variables (CI/CD pipelines)

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"
```

#### Option C: IAM Role (EC2/ECS/Lambda)

When running on AWS compute services, attach an IAM role with appropriate permissions. No additional configuration needed.

#### Option D: AWS SSO

```bash
aws configure sso
aws sso login --profile mycompany-prod
```

### 4. Remote State Backend (Required for Team Collaboration)

Create S3 bucket and DynamoDB table for Terraform state:

```bash
# Create S3 bucket for state storage
aws s3 mb s3://mycompany-terraform-state --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket mycompany-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Then update `providers.tf` in each environment with your backend configuration.

### 5. Required IAM Permissions

The AWS credentials need permissions to create/manage:

**Core Infrastructure:**
- VPC, Subnets, NAT Gateway, Internet Gateway
- Security Groups, Network ACLs
- EC2 instances, Launch Templates, Auto Scaling Groups
- Application Load Balancer, Target Groups
- RDS instances, Subnet Groups, Parameter Groups
- ElastiCache clusters (Redis)
- KMS keys
- IAM roles, policies, instance profiles
- S3 buckets (for logs)

**Security:**
- WAF Web ACLs
- GuardDuty detectors
- CloudTrail trails

**Monitoring:**
- CloudWatch dashboards, alarms, log groups
- SNS topics
- X-Ray groups

**Well-Architected (optional):**
- AWS Config (recorder, rules, delivery channel)
- AWS Backup (vaults, plans, selections)
- AWS Budgets (budgets, notifications, actions)
- EventBridge (rules for GuardDuty alerting)

## Environment Configuration

### File Structure (per environment)

| File | Purpose |
|------|---------|
| `main.tfvars` | Solution identity, AWS config, ownership |
| `well-architected.tfvars` | AWS Well-Architected configuration |
| `variables.tf` | Variable definitions with validation |
| `providers.tf` | Terraform & AWS provider configuration |
| `main.tf` | Module composition and locals |
| `well-architected.tf` | Well-Architected module composition |
| `outputs.tf` | Output values |
| `deploy.sh` | Terraform wrapper script |

### Naming Convention

All resources follow the pattern: `{solution_abbr}-{environment}-{resource_type}`

Examples:
- `smp-prod-vpc` - Production VPC
- `smp-test-alb` - Test Application Load Balancer
- `smp-dr-rds` - DR RDS instance

### Common Tags

All resources are automatically tagged via AWS provider `default_tags`:

| Tag | Description |
|-----|-------------|
| `Solution` | Full solution name |
| `SolutionAbbr` | Abbreviated solution name |
| `Environment` | Environment identifier (prod/test/dr) |
| `Provider` | Provider name (e.g., dell, aws) |
| `Category` | Category name (e.g., cloud, security) |
| `Region` | AWS region |
| `ManagedBy` | "terraform" |
| `CostCenter` | Cost center code |
| `Owner` | Owner email |
| `ProjectCode` | Project tracking code |

## Quick Start

### 1. Configure Environment

Edit `main.tfvars` with your solution details:

```hcl
solution_name = "my-solution"
solution_abbr = "mysol"
provider_name = "mycompany"
category_name = "cloud"

aws_region  = "us-east-1"
aws_profile = "mycompany-prod"  # Optional

cost_center  = "CC-12345"
owner_email  = "team@mycompany.com"
project_code = "PRJ-001"
```

### 2. Configure Backend (providers.tf)

Uncomment and set backend configuration:

```hcl
backend "s3" {
  bucket         = "mycompany-terraform-state"
  key            = "solutions/my-solution/prod/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-locks"
  encrypt        = true
  profile        = "mycompany-prod"  # Optional
}
```

### 3. Deploy

```bash
cd environments/prod

# Initialize Terraform
./deploy.sh init

# Review plan
./deploy.sh plan

# Apply changes
./deploy.sh apply

# View outputs
./deploy.sh output
```

## Environment Differences

| Feature | prod | test | dr |
|---------|------|------|-----|
| **Modules** | core, security, database, cache, monitoring | core, database | core, database, cache, monitoring |
| **Multi-AZ** | Yes | No | Yes |
| **NAT Gateway** | HA (per AZ) | Single | HA (per AZ) |
| **Instance Size** | t3.medium+ | t3.small | t3.medium+ |
| **RDS Size** | db.t3.medium+ | db.t3.micro | db.t3.medium+ |
| **Deletion Protection** | Yes | No | Yes |
| **Backup Retention** | 30 days | 1 day | 30 days |
| **WAF/GuardDuty** | Yes | No | No |
| **Region** | us-east-1 | us-east-1 | us-west-2 |

## AWS Well-Architected Framework Integration

The deployment includes optional resources aligned with AWS Well-Architected Framework pillars. Configure these in `well-architected.tfvars`.

### Six Pillars Implementation

| Pillar | Module | Default | Description |
|--------|--------|---------|-------------|
| **Operational Excellence** | config-rules | Enabled | AWS Config for compliance monitoring and drift detection |
| **Security** | guardduty | Disabled* | Enhanced GuardDuty with S3/malware protection |
| **Reliability** | backup-plans | Enabled | Centralized backup with daily/weekly/monthly schedules |
| **Performance Efficiency** | - | N/A | Handled via compute/cache module configurations |
| **Cost Optimization** | budgets | Enabled | Budget alerts and optional auto-remediation |
| **Sustainability** | - | N/A | Handled via right-sizing in other modules |

*Enhanced GuardDuty is disabled by default because basic GuardDuty is already enabled via the security module.

### Well-Architected Configuration Example

```hcl
# well-architected.tfvars

# Operational Excellence
enable_config_rules = true
config_retention_days = 365

# Reliability
enable_backup_plans = true
backup_daily_retention = 30
backup_weekly_retention = 90
backup_monthly_retention = 365
enable_backup_cross_region = true  # For DR

# Cost Optimization
enable_budgets = true
monthly_budget_amount = 5000
budget_alert_thresholds = [50, 80, 100]
budget_alert_emails = ["finance@company.com"]
```

### Compliance Mapping

The Well-Architected modules support the following compliance frameworks:

| Compliance | Config Rules | GuardDuty | Backup | Budgets |
|------------|--------------|-----------|--------|---------|
| CIS AWS Benchmark | Yes | Yes | - | - |
| PCI DSS | Yes | Yes | Yes | - |
| HIPAA | Yes | Yes | Yes | - |
| SOC 2 | Yes | Yes | Yes | - |
| GDPR | - | - | Yes | - |

## Troubleshooting

### Authentication Errors

```
Error: No valid credential sources found
```

Solution: Verify AWS credentials are configured correctly. Check:
- `aws sts get-caller-identity` works
- Profile name matches `aws_profile` in main.tfvars
- Environment variables are set (for CI/CD)

### State Lock Errors

```
Error: Error acquiring the state lock
```

Solution: Another Terraform operation may be running. Wait or force unlock:
```bash
terraform force-unlock LOCK_ID
```

### Backend Initialization

```
Error: Backend configuration changed
```

Solution: Reinitialize with migration:
```bash
terraform init -migrate-state
```
