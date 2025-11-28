---
document_title: Implementation Guide
solution_name: GitHub Actions Enterprise CI/CD
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: github
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the GitHub Actions Enterprise CI/CD platform. The guide covers AWS VPC infrastructure setup, self-hosted runner deployment using Terraform, OIDC configuration for keyless AWS authentication, reusable workflow templates, and Kubernetes deployment automation.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying the CI/CD platform with 20 self-hosted runners and 15 reusable workflow templates. All commands and procedures have been validated against target AWS and GitHub environments.

## Implementation Approach

The implementation follows a pilot-validate-expand methodology with infrastructure-first deployment. The approach uses Terraform for AWS infrastructure, GitHub CLI for organization configuration, and reusable workflows for standardization.

## Automation Framework Overview

The following automation technologies are included in this delivery.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| Terraform | AWS runner infrastructure | `scripts/terraform/` | Terraform 1.5+, AWS CLI |
| GitHub CLI | Organization configuration | `scripts/bash/` | gh CLI 2.x installed |
| Python | Bulk automation | `scripts/python/` | Python 3.10+, pip |
| Bash | Shell automation | `scripts/bash/` | Bash 4.0+ |

## Scope Summary

### In Scope

The following components are deployed using the automation framework.

- AWS VPC and networking infrastructure
- Self-hosted runners (16 Linux, 4 Windows) with auto-scaling
- OIDC provider for keyless AWS authentication
- 15 reusable workflow templates
- Environment protection rules
- Container registry integration
- Monitoring integration (Datadog, CloudWatch)

### Out of Scope

The following items are excluded from automated deployment.

- EKS cluster creation (existing clusters used)
- GitHub Enterprise licensing (procured separately)
- Application code migration (application team responsibility)

## Timeline Overview

The implementation follows a phased deployment approach.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Prerequisites & VPC Setup | 1 week | AWS infrastructure ready |
| 2 | Runner Infrastructure | 2 weeks | Runners operational |
| 3 | OIDC & Security | 1 week | Keyless auth working |
| 4 | Workflow Templates | 2 weeks | 15 templates deployed |
| 5 | Pilot Migration | 3 weeks | 10 apps migrated |
| 6 | Full Migration | 6 weeks | All 50 apps migrated |
| 7 | Testing & Validation | 3 weeks | UAT complete |
| 8 | Go-Live & Hypercare | 6 weeks | Production stable |

**Total Implementation:** 24 weeks (~6 months)

# Prerequisites

This section documents all requirements that must be satisfied before deployment can begin.

## Tool Installation

The following tools must be installed on the deployment workstation.

### Required Tools Checklist

- [ ] **Terraform** >= 1.5.0 - Infrastructure as code
- [ ] **AWS CLI** >= 2.x - AWS management
- [ ] **GitHub CLI** >= 2.x - GitHub management
- [ ] **Python** >= 3.10 - Automation scripts
- [ ] **kubectl** >= 1.28 - Kubernetes management
- [ ] **Docker** >= 24.x - Container builds

### Terraform Installation

```bash
# macOS (using Homebrew)
brew install terraform

# Linux (Ubuntu/Debian)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform --version
```

### AWS CLI Installation

```bash
# macOS (using Homebrew)
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

### GitHub CLI Installation

```bash
# macOS (using Homebrew)
brew install gh

# Linux (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Verify installation
gh --version
```

## AWS Account Configuration

Configure AWS credentials and verify access.

```bash
# Configure AWS credentials
aws configure
# AWS Access Key ID: [YOUR_ACCESS_KEY]
# AWS Secret Access Key: [YOUR_SECRET_KEY]
# Default region name: us-east-1
# Default output format: json

# Verify credentials
aws sts get-caller-identity

# Verify required permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT_ID:user/YOUR_USER \
  --action-names ec2:RunInstances ec2:CreateSecurityGroup iam:CreateRole
```

## GitHub Account Configuration

Configure GitHub CLI and verify organization access.

```bash
# Authenticate with GitHub
gh auth login
# Select GitHub.com, HTTPS, and authenticate via browser

# Verify authentication
gh auth status

# Verify organization access
gh api /orgs/YOUR_ORG -q '.login'

# Set default organization
gh config set org YOUR_ORG
```

## Prerequisite Validation

Run the prerequisite validation script.

```bash
cd delivery/scripts/
./validate-prerequisites.sh

# Manual verification
terraform --version    # >= 1.5.0
aws --version          # >= 2.x
gh --version           # >= 2.x
python3 --version      # >= 3.10
kubectl version        # >= 1.28
docker --version       # >= 24.x
```

# Environment Setup

This section covers the initial environment configuration for the CI/CD platform deployment.

## AWS Environment Configuration

Configure AWS environments for runner infrastructure.

### Environment Variables

```bash
# Set environment variables
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export GITHUB_ORG="YOUR_ORG"
export PROJECT_NAME="github-actions-cicd"

# Verify environment
echo "Region: $AWS_REGION"
echo "Account: $AWS_ACCOUNT_ID"
echo "Org: $GITHUB_ORG"
```

### Terraform Backend Setup

```bash
# Navigate to Terraform scripts directory
cd delivery/scripts/terraform/backend/

# Run backend initialization script
./init-backend.sh

# Expected output:
# - S3 bucket created: github-actions-terraform-state-us-east-1
# - DynamoDB table created: github-actions-terraform-locks
# - Encryption enabled on S3 bucket
# - Versioning enabled on S3 bucket
```

## GitHub Organization Configuration

Configure GitHub organization settings.

### Organization Security Defaults

```bash
# Enable required organization settings
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG \
  -f default_repository_permission=read \
  -f members_can_create_repositories=false

# Verify settings
gh api /orgs/YOUR_ORG -q '{default_permission: .default_repository_permission}'
```

### Runner Groups Configuration

```bash
# Create runner groups for different environments
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG/actions/runner-groups \
  -f name="production-runners" \
  -f visibility="selected"

gh api \
  --method POST \
  /orgs/YOUR_ORG/actions/runner-groups \
  -f name="development-runners" \
  -f visibility="all"
```

# Infrastructure Deployment

This section covers the deployment of AWS infrastructure for self-hosted runners. The deployment follows a phased approach covering networking configuration, security group setup, compute instance provisioning, and monitoring dashboard integration.

## Networking Configuration

Deploy VPC and networking infrastructure using Terraform.

### VPC Deployment

```bash
# Navigate to VPC module
cd delivery/scripts/terraform/vpc/

# Initialize Terraform
terraform init

# Review plan
terraform plan -var-file=environments/production.tfvars

# Apply infrastructure
terraform apply -var-file=environments/production.tfvars
```

### VPC Terraform Variables

```hcl
# environments/production.tfvars
vpc_name            = "github-actions-runners"
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

tags = {
  Project     = "github-actions-cicd"
  Environment = "production"
  ManagedBy   = "terraform"
}
```

### VPC Verification

```bash
# Verify VPC created
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=github-actions-runners" \
  --query 'Vpcs[0].{VpcId:VpcId,CidrBlock:CidrBlock}'

# Verify subnets created
aws ec2 describe-subnets --filters "Name=vpc-id,Values=VPC_ID" \
  --query 'Subnets[].{SubnetId:SubnetId,AZ:AvailabilityZone}'
```

## Security Configuration

Deploy security groups and IAM roles.

### Security Groups Deployment

```bash
# Navigate to security groups module
cd delivery/scripts/terraform/security-groups/

# Apply security group configuration
terraform apply -var-file=environments/production.tfvars
```

### Security Group Rules

```hcl
# Outbound rules for runners
egress_rules = [
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to GitHub and registries"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for package downloads"
  }
]

# No inbound rules - runners initiate all connections
ingress_rules = []
```

### OIDC Provider Deployment

```bash
# Create OIDC provider via AWS CLI
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"

# Verify provider created
aws iam list-open-id-connect-providers
```

## Compute Infrastructure

Deploy self-hosted runner instances with auto-scaling.

### Runner AMI Creation

```bash
# Navigate to AMI scripts
cd delivery/scripts/packer/

# Build Linux runner AMI
packer build -var-file=variables.pkrvars.hcl linux-runner.pkr.hcl

# Build Windows runner AMI
packer build -var-file=variables.pkrvars.hcl windows-runner.pkr.hcl
```

### Auto-Scaling Group Deployment

```bash
# Navigate to ASG module
cd delivery/scripts/terraform/runners/

# Deploy Linux runner ASG
terraform apply -var-file=environments/production-linux.tfvars

# Deploy Windows runner ASG
terraform apply -var-file=environments/production-windows.tfvars
```

### Linux Runner ASG Configuration

```hcl
# environments/production-linux.tfvars
asg_name           = "gha-runners-linux-asg"
instance_type      = "c5.2xlarge"
ami_id             = "ami-XXXXXXXXXXXX"  # From AMI build
min_size           = 8
max_size           = 24
desired_capacity   = 16

runner_labels = ["self-hosted", "linux", "x64"]

scaling_policies = {
  scale_up = {
    scaling_adjustment = 2
    cooldown           = 300
    metric_alarm = {
      metric_name         = "GitHubActionsQueueDepth"
      threshold           = 5
      comparison_operator = "GreaterThanThreshold"
    }
  }
  scale_down = {
    scaling_adjustment = -1
    cooldown           = 900
    metric_alarm = {
      metric_name         = "RunnerIdleTime"
      threshold           = 900
      comparison_operator = "GreaterThanThreshold"
    }
  }
}
```

### Runner Registration

```bash
# Get runner registration token
RUNNER_TOKEN=$(gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG/actions/runners/registration-token \
  -q '.token')

# Verify runners registered
gh api /orgs/YOUR_ORG/actions/runners -q '.runners[] | {id, name, os, status}'
```

## Monitoring Infrastructure

Deploy monitoring and alerting infrastructure.

### CloudWatch Dashboard

```bash
# Create CloudWatch dashboard
aws cloudwatch put-dashboard \
  --dashboard-name "GitHubActionsRunners" \
  --dashboard-body file://delivery/scripts/cloudwatch/dashboard.json
```

### CloudWatch Alarms

```bash
# Create scaling alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "GHA-QueueDepth-High" \
  --metric-name "GitHubActionsQueueDepth" \
  --namespace "Custom/GitHubActions" \
  --statistic Average \
  --period 300 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:autoscaling:us-east-1:ACCOUNT_ID:scalingPolicy:...
```

# Application Configuration

This section covers the configuration of GitHub Actions workflows and environments.

## Reusable Workflow Templates

Deploy reusable workflow templates to the organization.

### Workflow Library Setup

```bash
# Create .github repository for organization workflows
gh repo create YOUR_ORG/.github --private --description "Organization reusable workflows"

# Clone and setup
git clone https://github.com/YOUR_ORG/.github
cd .github
mkdir -p workflow-templates
```

### .NET Core Workflow

```yaml
# workflow-templates/dotnet-build-deploy.yml
name: .NET Core Build and Deploy

on:
  workflow_call:
    inputs:
      dotnet-version:
        required: false
        type: string
        default: '8.0.x'
      project-path:
        required: true
        type: string
      environment:
        required: true
        type: string

permissions:
  id-token: write
  contents: read

jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ inputs.dotnet-version }}

      - name: Restore dependencies
        run: dotnet restore ${{ inputs.project-path }}

      - name: Build
        run: dotnet build ${{ inputs.project-path }} --no-restore --configuration Release

      - name: Test
        run: dotnet test ${{ inputs.project-path }} --no-build --verbosity normal

      - name: Publish
        run: dotnet publish ${{ inputs.project-path }} -c Release -o ./publish

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: dotnet-app
          path: ./publish

  deploy:
    needs: build
    runs-on: self-hosted
    environment: ${{ inputs.environment }}
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: dotnet-app

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT_ID:role/github-actions-${{ inputs.environment }}-deploy
          aws-region: us-east-1

      - name: Deploy to EKS
        run: |
          aws eks update-kubeconfig --name ${{ inputs.environment }}-cluster
          kubectl apply -f k8s/
```

### Node.js Workflow

```yaml
# workflow-templates/nodejs-build-deploy.yml
name: Node.js Build and Deploy

on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '20'
      environment:
        required: true
        type: string

permissions:
  id-token: write
  contents: read

jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: nodejs-app
          path: ./dist
```

### Docker Build Workflow

```yaml
# workflow-templates/docker-build-push.yml
name: Docker Build and Push

on:
  workflow_call:
    inputs:
      image-name:
        required: true
        type: string
      registry:
        required: false
        type: string
        default: 'ghcr.io'
      environment:
        required: true
        type: string

permissions:
  id-token: write
  contents: read
  packages: write

jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to registry
        uses: docker/login-action@v3
        with:
          registry: ${{ inputs.registry }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ inputs.registry }}/${{ github.repository }}/${{ inputs.image-name }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Workflow Deployment

```bash
# Add all workflow templates
git add workflow-templates/
git commit -m "Add reusable workflow templates"
git push

# Verify templates available
gh api /orgs/YOUR_ORG/repos/.github/contents/workflow-templates -q '.[].name'
```

## Environment Protection Rules

Configure deployment environments with protection rules.

### Environment Creation

```bash
# Create environments for each repository
for repo in $(gh repo list YOUR_ORG --json name -q '.[].name'); do
  for env in development staging production; do
    gh api \
      --method PUT \
      -H "Accept: application/vnd.github+json" \
      /repos/YOUR_ORG/$repo/environments/$env
  done
done
```

### Protection Rules

```bash
# Add protection rules to production environment
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/YOUR_ORG/REPO_NAME/environments/production \
  -f deployment_branch_policy=null \
  -F reviewers[][type]="User" \
  -F reviewers[][id]=USER_ID \
  -F reviewers[][type]="Team" \
  -F reviewers[][id]=TEAM_ID
```

## IAM Roles for OIDC

Configure IAM roles for GitHub Actions OIDC authentication.

### Trust Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/*:environment:production"
        }
      }
    }
  ]
}
```

### Role Permission Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    }
  ]
}
```

# Integration Testing

This section covers integration testing procedures for the CI/CD platform.

## Test Environment Preparation

Prepare test applications and workflows.

```bash
# Create test repository
gh repo create YOUR_ORG/cicd-test-app --private

# Clone and setup test application
git clone https://github.com/YOUR_ORG/cicd-test-app
cd cicd-test-app

# Add sample Node.js application
cat > package.json << 'EOF'
{
  "name": "cicd-test-app",
  "version": "1.0.0",
  "scripts": {
    "test": "echo 'Tests passed'",
    "build": "echo 'Build completed'"
  }
}
EOF

# Add workflow using reusable template
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOF'
name: CI
on: [push, pull_request]
jobs:
  build:
    uses: YOUR_ORG/.github/.github/workflows/nodejs-build-deploy.yml@main
    with:
      node-version: '20'
      environment: development
EOF

git add .
git commit -m "Add test application"
git push
```

## Functional Test Execution

### Workflow Trigger Tests

```bash
# Run functional test suite
python3 delivery/scripts/python/validate.py \
  --environment production \
  --test-suite functional \
  --report

# Verify workflow triggered
gh run list --repo YOUR_ORG/cicd-test-app --limit 5
```

### OIDC Authentication Tests

```bash
# Test OIDC authentication in workflow
# Create test workflow that assumes role
cat > .github/workflows/oidc-test.yml << 'EOF'
name: OIDC Test
on: workflow_dispatch
permissions:
  id-token: write
  contents: read
jobs:
  test:
    runs-on: self-hosted
    environment: development
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT_ID:role/github-actions-dev-deploy
          aws-region: us-east-1
      - name: Verify AWS access
        run: aws sts get-caller-identity
EOF

# Trigger workflow
gh workflow run oidc-test.yml --repo YOUR_ORG/cicd-test-app
```

## Performance Test Execution

### Pipeline Duration Tests

```bash
# Run performance tests
python3 delivery/scripts/python/validate.py \
  --environment production \
  --test-suite performance \
  --iterations 10 \
  --report

# Verify pipeline duration < 10 minutes
# Verify concurrent build capacity >= 25
```

### Concurrent Build Tests

```bash
# Submit 25 concurrent builds
for i in $(seq 1 25); do
  gh workflow run ci.yml --repo YOUR_ORG/test-app-$i &
done
wait

# Monitor completion
gh api /orgs/YOUR_ORG/actions/runs --paginate -q '.workflow_runs[] | select(.status == "in_progress") | .id' | wc -l
```

## Test Success Criteria

Complete this checklist before proceeding.

- [ ] All workflow templates functional
- [ ] OIDC authentication working for all environments
- [ ] Pipeline duration < 10 minutes
- [ ] Concurrent capacity >= 25 builds
- [ ] Auto-scaling triggering on queue depth
- [ ] Artifact upload/download working
- [ ] Environment protection rules enforced

# Security Validation

This section covers security validation procedures for the CI/CD platform.

## Security Configuration Audit

### Runner Security Scan

```bash
# Audit runner security configuration
python3 delivery/scripts/python/audit_security.py \
  --component runners \
  --output reports/runner-security-audit.json

# Verify security groups
aws ec2 describe-security-groups --group-ids SG_ID \
  --query 'SecurityGroups[0].{Inbound:IpPermissions,Outbound:IpPermissionsEgress}'
```

### OIDC Configuration Validation

```bash
# Verify OIDC provider configuration
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com

# Verify role trust policies
aws iam get-role --role-name github-actions-prod-deploy \
  --query 'Role.AssumeRolePolicyDocument'
```

### Secrets Management Audit

```bash
# List organization secrets
gh api /orgs/YOUR_ORG/actions/secrets -q '.secrets[].name'

# Verify no secrets in logs
gh run view RUN_ID --log --repo YOUR_ORG/REPO_NAME | grep -i "secret\|password\|token"
```

## Compliance Validation

### Encryption Validation

```bash
# Verify S3 encryption
aws s3api get-bucket-encryption --bucket github-actions-artifacts-bucket

# Verify EBS encryption
aws ec2 describe-volumes --filters "Name=tag:Project,Values=github-actions-cicd" \
  --query 'Volumes[].Encrypted'
```

### Network Isolation Validation

```bash
# Verify runners cannot access unauthorized networks
# Test from runner instance
curl -m 5 https://internal-system.example.com || echo "Blocked as expected"

# Verify allowed destinations
curl -s https://github.com > /dev/null && echo "GitHub accessible"
```

## Security Validation Checklist

- [ ] Runner security groups restrict inbound access
- [ ] OIDC roles use least privilege
- [ ] Secrets masked in workflow logs
- [ ] S3 artifacts encrypted at rest
- [ ] Network isolation enforced
- [ ] Audit logging enabled
- [ ] No static credentials in workflows

# Migration & Cutover

This section covers production cutover procedures for the CI/CD platform.

## Pre-Migration Checklist

- [ ] All 50 applications with workflows configured
- [ ] Pipeline duration < 10 minutes validated
- [ ] OIDC authentication tested for all environments
- [ ] DevOps engineers trained
- [ ] Rollback plan documented
- [ ] Stakeholder approval obtained
- [ ] Jenkins parallel operation planned

## Production Cutover

### Jenkins Parallel Operation

```bash
# Configure Jenkins to GitHub webhook forwarding (optional)
# During transition, both systems run in parallel

# Monitor GitHub Actions adoption
gh api /orgs/YOUR_ORG/actions/runs --paginate -q '.workflow_runs | length'
```

### Application Migration

```bash
# Migrate applications in waves
# Wave 1: 15 applications
# Wave 2: 15 applications
# Wave 3: 20 applications

# Verify each wave before proceeding
python3 delivery/scripts/python/validate_migration.py \
  --wave 1 \
  --report
```

### Traffic Validation

```bash
# Monitor GitHub Actions usage
gh api /orgs/YOUR_ORG/settings/billing/actions -q '{total_minutes_used, included_minutes}'

# Check runner utilization
gh api /orgs/YOUR_ORG/actions/runners -q '.runners[] | {name, status, busy}'
```

## Rollback Procedures

If critical issues are identified, execute rollback.

```bash
# Disable GitHub Actions workflow
gh workflow disable ci.yml --repo YOUR_ORG/REPO_NAME

# Re-enable Jenkins webhook
# Configure Jenkins job to trigger on push

# Scale down runners
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name gha-runners-linux-asg \
  --desired-capacity 0
```

# Operational Handover

This section covers the transition to ongoing operations.

## Monitoring Dashboard Access

### GitHub Actions Monitoring

```bash
# Access workflow run history
gh run list --repo YOUR_ORG/REPO_NAME --limit 20

# View runner status
gh api /orgs/YOUR_ORG/actions/runners -q '.runners[] | {name, os, status, busy}'

# Check Actions usage
gh api /orgs/YOUR_ORG/settings/billing/actions
```

### Key Metrics to Monitor

The following metrics should be monitored continuously.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Pipeline Duration | > 10 minutes | Warning | Investigate bottlenecks |
| Queue Depth | > 10 jobs | Warning | Scale up runners |
| Runner Offline | Any | Critical | Check ASG health |
| OIDC Auth Failures | > 5% | Warning | Verify role configuration |
| Deployment Success | < 95% | Critical | Review deployment logs |

## Support Transition

### Support Model

The following support model is implemented for CI/CD operations.

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | Initial triage | Platform Team | 15 minutes |
| L2 | Technical investigation | DevOps Engineering | 1 hour |
| L3 | Complex issues | Vendor Support | 4 hours |
| L4 | GitHub platform | GitHub Support | Per contract |

### Runbook Locations

The following runbooks document operational procedures.

<!-- TABLE_CONFIG: widths=[30, 40, 30] -->
| Runbook | Purpose | Location |
|---------|---------|----------|
| Runner Management | Health checks, scaling | `/delivery/docs/runbooks/runners.md` |
| Workflow Debugging | Log analysis, retries | `/delivery/docs/runbooks/workflows.md` |
| OIDC Troubleshooting | Token issues | `/delivery/docs/runbooks/oidc.md` |
| Incident Response | Emergency procedures | `/delivery/docs/runbooks/incidents.md` |

### Escalation Contacts

The following contacts are available for escalation.

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Platform Lead | [NAME] | platform@company.com | [PHONE] |
| DevOps Lead | [NAME] | devops@company.com | [PHONE] |
| Emergency | On-Call | oncall@company.com | [PHONE] |

# Training Program

This section documents the training program for CI/CD operations.

## Training Overview

Training ensures all user groups achieve competency with GitHub Actions.

### Training Schedule

The following training modules are delivered as part of the implementation.

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | GitHub Actions Overview | All Developers | 1 | VILT | None |
| TRN-002 | Reusable Workflows | Developers | 2 | Hands-On | TRN-001 |
| TRN-003 | DevOps Engineer Certification | DevOps | 4 | Hands-On | TRN-001 |
| TRN-004 | OIDC Authentication | DevOps | 1 | Video | TRN-003 |
| TRN-005 | Pipeline Troubleshooting | DevOps | 2 | Hands-On | TRN-003 |
| TRN-006 | Platform Administration | Admins | 4 | Hands-On | TRN-003 |

## Training Materials

The following training materials are provided.

- Developer Quick Start Guide (one-page reference)
- DevOps Engineer Certification Guide (30 pages)
- Video tutorials (8 recordings, 90 minutes total)
- Hands-on lab exercises
- FAQ document
- Quick reference cards

# Appendices

## Appendix A: Environment Reference

The following table documents the production environment configuration.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Parameter | Value | Description |
|-----------|-------|-------------|
| Organization | YOUR_ORG | GitHub organization |
| AWS Region | us-east-1 | Primary region |
| VPC CIDR | 10.0.0.0/16 | Runner VPC |
| Linux Runners | 16 | Default capacity |
| Windows Runners | 4 | Default capacity |

## Appendix B: Troubleshooting Guide

The following table documents common issues and resolutions.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| Runner offline | Instance terminated | Check ASG health |
| OIDC auth fails | Role trust policy | Verify subject claim |
| Slow pipelines | No caching | Enable dependency cache |
| Docker build fails | BuildKit issue | Check Dockerfile |
| Queue starvation | Insufficient runners | Scale up ASG |

### Diagnostic Commands

```bash
# List organization runners
gh api /orgs/YOUR_ORG/actions/runners -q '.runners[] | {name, status}'

# View workflow runs
gh run list --repo YOUR_ORG/REPO_NAME --limit 10

# Check runner logs
aws logs get-log-events --log-group-name /github-actions/runners --log-stream-name RUNNER_ID

# Scale runners manually
aws autoscaling set-desired-capacity --auto-scaling-group-name gha-runners-linux-asg --desired-capacity 20
```

## Appendix C: AWS Resource Reference

The following table documents AWS resources created.

<!-- TABLE_CONFIG: widths=[30, 30, 40] -->
| Resource | Identifier | Purpose |
|----------|------------|---------|
| VPC | vpc-xxxxxxxxx | Runner network |
| ASG (Linux) | gha-runners-linux-asg | Linux runner scaling |
| ASG (Windows) | gha-runners-windows-asg | Windows runner scaling |
| OIDC Provider | token.actions.githubusercontent.com | GitHub OIDC |
| IAM Role (Dev) | github-actions-dev-deploy | Dev deployments |
| IAM Role (Prod) | github-actions-prod-deploy | Prod deployments |
