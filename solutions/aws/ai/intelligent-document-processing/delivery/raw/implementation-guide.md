---
document_title: Implementation Guide
solution_name: AWS Intelligent Document Processing
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: aws
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the AWS Intelligent Document Processing (IDP) solution. The guide covers infrastructure provisioning, AWS AI service configuration (Textract, Comprehend, A2I), and integration setup using Infrastructure as Code (IaC) automation.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying the IDP solution on AWS. All commands and procedures have been validated against target AWS environments.

## Implementation Approach

The implementation follows a serverless-first, infrastructure-as-code methodology using Terraform for AWS resource provisioning, Python scripts for AI service configuration, and AWS native tools for deployment orchestration. The approach ensures repeatable, auditable deployments across all environments.

## Automation Framework Overview

The following automation technologies are included in this delivery.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| Terraform | Infrastructure provisioning | `scripts/terraform/` | Terraform 1.6+, AWS CLI |
| Python | AI service configuration & automation | `scripts/python/` | Python 3.10+, pip |
| Bash | Linux/Unix automation | `scripts/bash/` | Bash 4.0+ |

## Scope Summary

### In Scope

The following components are deployed using the automation framework.

- AWS infrastructure (VPC, S3, Lambda, API Gateway, DynamoDB)
- AI services (Amazon Textract, Amazon Comprehend, Amazon A2I)
- Document processing pipeline configuration
- Security controls and IAM policies
- Monitoring, alerting, and dashboards
- API integration and testing

### Out of Scope

The following items are excluded from automated deployment.

- Custom ML model development (not in scope)
- Third-party system integration development (client responsibility)
- End-user training (covered separately)
- Ongoing managed services operations

## Timeline Overview

The implementation follows a phased deployment approach with validation gates.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Prerequisites & AWS Account Setup | 1 week | AWS account configured, IAM ready |
| 2 | Foundation Infrastructure | 3 weeks | VPC, S3, IAM deployed |
| 3 | AI Services Configuration | 4 weeks | Textract, Comprehend, A2I configured |
| 4 | Pipeline & API Development | 3 weeks | End-to-end pipeline operational |
| 5 | Integration & Testing | 3 weeks | All tests passing, security validated |
| 6 | Go-Live & Hypercare | 4 weeks | Production stable, team trained |

**Total Implementation:** 18 weeks (~4.5 months) + hypercare = 6 months

# Prerequisites

This section documents all requirements that must be satisfied before infrastructure deployment can begin.

## Tool Installation

The following tools must be installed on the deployment workstation before proceeding.

### Required Tools Checklist

Use the following checklist to verify all required tools are installed.

- [ ] **AWS CLI v2** >= 2.13 - AWS service management
- [ ] **Terraform** >= 1.6.0 - Infrastructure provisioning
- [ ] **Python** >= 3.10 - AI service automation scripts
- [ ] **Git** - Source code management
- [ ] **jq** - JSON processing for scripts

### AWS CLI Installation

Install and configure the AWS CLI.

```bash
# macOS (using Homebrew)
brew install awscli

# Windows (using MSI installer)
# Download from https://aws.amazon.com/cli/

# Linux (using pip)
pip3 install awscli --upgrade

# Verify installation
aws --version
```

### Terraform Installation

Install Terraform using the appropriate method for your operating system.

```bash
# macOS (using Homebrew)
brew install terraform

# Windows (using Chocolatey)
choco install terraform

# Linux (manual installation)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

### Python Environment Setup

Set up Python environment for AI service scripts.

```bash
# Verify Python version
python3 --version

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install required packages
pip install boto3 pandas
pip install -r scripts/python/requirements.txt
```

## AWS Account Configuration

Configure AWS authentication and verify required permissions.

### AWS Authentication

Configure AWS CLI profiles for each deployment environment.

```bash
# Configure production profile
aws configure --profile idp-production
# Enter: AWS Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)

# Configure development profile
aws configure --profile idp-development

# Verify authentication
aws sts get-caller-identity --profile idp-production

# Set default profile for session
export AWS_PROFILE=idp-production
```

### Required IAM Permissions

The deployment user/role requires the following permissions.

- **IAM:** CreateRole, AttachRolePolicy, CreatePolicy
- **S3:** CreateBucket, PutObject, GetObject, DeleteObject
- **Lambda:** CreateFunction, UpdateFunctionCode, InvokeFunction
- **API Gateway:** CreateRestApi, CreateResource, CreateMethod
- **DynamoDB:** CreateTable, PutItem, GetItem, Query
- **Textract:** AnalyzeDocument, StartDocumentAnalysis
- **Comprehend:** DetectEntities, DetectPiiEntities
- **A2I:** CreateHumanTaskUi, CreateFlowDefinition
- **CloudWatch:** PutMetricData, CreateDashboard, PutMetricAlarm
- **SNS:** CreateTopic, Subscribe, Publish
- **KMS:** CreateKey, Encrypt, Decrypt
- **Step Functions:** CreateStateMachine, StartExecution

### Service Quotas Validation

Verify AWS service quotas are sufficient for deployment.

```bash
# Check Lambda concurrent executions quota
aws service-quotas get-service-quota \
  --service-code lambda \
  --quota-code L-B99A9384

# Request quota increase if needed
aws service-quotas request-service-quota-increase \
  --service-code lambda \
  --quota-code L-B99A9384 \
  --desired-value 500
```

## Prerequisite Validation

Run the prerequisite validation script to verify all requirements.

```bash
# Navigate to scripts directory
cd delivery/scripts/

# Run prerequisite validation
./validate-prerequisites.sh

# Or manually verify each component
aws --version
terraform version
python3 --version
aws sts get-caller-identity
```

### Validation Checklist

Complete this checklist before proceeding to environment setup.

- [ ] AWS CLI v2 installed and accessible in PATH
- [ ] AWS credentials configured with appropriate permissions
- [ ] Terraform installed and accessible
- [ ] Python 3.10+ installed with pip
- [ ] Required Python packages installed
- [ ] Network connectivity to AWS APIs verified

# Environment Setup

This section covers the initial setup of Terraform state management and environment-specific configurations.

## Terraform Directory Structure

The Terraform automation follows a modular structure for IDP components.

```
delivery/scripts/terraform/
├── environments/
│   ├── production/
│   │   ├── terraform.tf            # Backend & version configuration
│   │   ├── providers.tf            # AWS provider settings
│   │   ├── main.tf                 # Infrastructure deployment
│   │   ├── variables.tf            # Variable definitions
│   │   ├── outputs.tf              # Output definitions
│   │   ├── deploy.sh               # Deployment automation script
│   │   └── config/
│   │       ├── project.tfvars      # Project identity
│   │       ├── networking.tfvars   # Network configuration
│   │       ├── security.tfvars     # Security settings
│   │       └── ai-services.tfvars  # AI service configuration
│   └── test/
├── modules/
│   └── aws/
│       ├── networking/             # VPC, subnets, endpoints
│       ├── security/               # IAM, KMS, security groups
│       ├── storage/                # S3 buckets, DynamoDB
│       ├── compute/                # Lambda, Step Functions
│       ├── api/                    # API Gateway
│       ├── ai-services/            # Textract, Comprehend, A2I
│       └── monitoring/             # CloudWatch, alarms
└── docs/
    └── TERRAFORM_SETUP_GUIDE.md
```

## Backend State Configuration

Configure remote state storage before initializing Terraform.

### AWS S3 Backend Setup

Initialize the S3 backend for storing Terraform state.

```bash
# Navigate to Terraform scripts directory
cd delivery/scripts/terraform/scripts/

# Run backend initialization script
./init-backend-aws.sh idp-solution us-east-1 production

# Expected output:
# - S3 bucket created: idp-solution-terraform-state-us-east-1
# - DynamoDB table created: idp-solution-terraform-locks
# - Encryption enabled on S3 bucket
# - Versioning enabled on S3 bucket
```

## Environment Configuration

Configure environment-specific settings in the tfvars files.

### Project Configuration

Edit the project configuration file with your deployment settings.

```bash
# Navigate to production environment
cd delivery/scripts/terraform/environments/production/

# Edit project configuration
vim config/project.tfvars
```

Configure the following settings in `config/project.tfvars`:

```hcl
# Project Identity
project_name = "intelligent-document-processing"
environment  = "production"
owner_email  = "project-team@company.com"
cost_center  = "IDP-PROJECT"

# AWS Configuration
aws_profile = "idp-production"
aws_region  = "us-east-1"

# Tagging
tags = {
  Project     = "intelligent-document-processing"
  Environment = "production"
  Owner       = "project-team"
  CostCenter  = "IDP-PROJECT"
}
```

### AI Services Configuration

Configure AI service settings in `config/ai-services.tfvars`.

```hcl
# Amazon Textract Configuration
textract_enabled = true

# Amazon Comprehend Configuration
comprehend_enabled = true
comprehend_pii_detection = true

# Amazon A2I Configuration (Human Review)
a2i_enabled = true
a2i_workforce_type = "private"  # private or public

# Processing Configuration
confidence_threshold = 0.85
max_document_size_mb = 25
supported_formats = ["pdf", "png", "jpg", "tiff"]
```

## Environment Initialization

Initialize Terraform for the target environment.

```bash
# Navigate to production environment
cd delivery/scripts/terraform/environments/production/

# Initialize Terraform
./deploy.sh init

# Validate configuration
./deploy.sh validate

# Format check
./deploy.sh fmt
```

# Infrastructure Deployment

This section covers the phased deployment of AWS infrastructure for the IDP solution.

## Deployment Overview

Infrastructure deployment follows a dependency-ordered sequence.

<!-- TABLE_CONFIG: widths=[15, 25, 35, 25] -->
| Phase | Layer | Components | Dependencies |
|-------|-------|------------|--------------|
| 1 | Networking | VPC, Subnets, VPC Endpoints, NAT Gateway | None |
| 2 | Security | IAM Roles, KMS Keys, Security Groups | Networking |
| 3 | Storage | S3 Buckets, DynamoDB Tables | Security |
| 4 | Compute | Lambda Functions, Step Functions | Storage |
| 5 | API | API Gateway, Cognito | Compute |
| 6 | AI Services | Textract, Comprehend, A2I | All above |
| 7 | Monitoring | CloudWatch, Alarms, Dashboards | All above |

## Phase 1: Networking Layer

Deploy the foundational networking infrastructure.

### Networking Components

The networking module deploys the following resources.

- Virtual Private Cloud (VPC) with /16 CIDR
- Private subnets across 2 availability zones
- VPC Endpoints for S3, DynamoDB, Textract, Comprehend
- NAT Gateway for Lambda external access
- VPC Flow Logs for network monitoring

### Deployment Steps

```bash
# Navigate to production environment
cd delivery/scripts/terraform/environments/production/

# Plan networking deployment
./deploy.sh plan

# Review the plan output for networking resources
# Apply networking infrastructure
./deploy.sh apply
```

### Networking Validation

```bash
# Verify VPC created
aws ec2 describe-vpcs \
  --filters "Name=tag:Project,Values=intelligent-document-processing" \
  --query "Vpcs[*].[VpcId,CidrBlock,State]" \
  --output table

# Verify VPC endpoints created
aws ec2 describe-vpc-endpoints \
  --filters "Name=tag:Project,Values=intelligent-document-processing" \
  --query "VpcEndpoints[*].[ServiceName,State]" \
  --output table
```

## Phase 2: Security Layer

Deploy security controls including IAM roles and KMS keys.

### Security Components

- IAM roles for Lambda, Step Functions
- KMS customer-managed key for data encryption
- Security groups for Lambda
- Secrets Manager for API keys and credentials

### Deployment Steps

```bash
# Plan security deployment
./deploy.sh plan

# Apply security infrastructure
./deploy.sh apply
```

### Security Validation

```bash
# Verify IAM roles created
aws iam list-roles \
  --query "Roles[?contains(RoleName, 'idp')].[RoleName,Arn]" \
  --output table

# Verify KMS key created
aws kms list-aliases \
  --query "Aliases[?contains(AliasName, 'idp')].[AliasName,TargetKeyId]" \
  --output table
```

## Phase 3: Storage Layer

Deploy S3 buckets and DynamoDB tables.

### Storage Components

- S3 bucket for document uploads (with encryption)
- S3 bucket for processing results
- DynamoDB table for document metadata
- DynamoDB table for processing jobs

### Deployment Steps

```bash
# Apply storage infrastructure
./deploy.sh apply
```

### Storage Validation

```bash
# Verify S3 buckets created
aws s3 ls | grep idp

# Verify bucket encryption
aws s3api get-bucket-encryption --bucket idp-documents-production

# Verify DynamoDB tables
aws dynamodb list-tables --query "TableNames[?contains(@, 'idp')]"
```

## Phase 4: Compute Layer

Deploy Lambda functions and Step Functions.

### Compute Components

- Lambda function for document processing orchestration
- Lambda function for Textract processing
- Lambda function for Comprehend analysis
- Lambda function for A2I human review integration
- Lambda function for results aggregation
- Step Functions state machine for workflow orchestration

### Deployment Steps

```bash
# Apply compute infrastructure
./deploy.sh apply
```

### Compute Validation

```bash
# Verify Lambda functions
aws lambda list-functions \
  --query "Functions[?contains(FunctionName, 'idp')].[FunctionName,Runtime,MemorySize]" \
  --output table

# Verify Step Functions state machine
aws stepfunctions list-state-machines \
  --query "stateMachines[?contains(name, 'idp')].[name,stateMachineArn]" \
  --output table
```

## Phase 5: API Layer

Deploy API Gateway and Cognito authentication.

### API Components

- REST API Gateway with resource definitions
- Cognito User Pool for authentication
- API Gateway authorizers
- Usage plans and API keys

### Deployment Steps

```bash
# Apply API infrastructure
./deploy.sh apply
```

### API Validation

```bash
# Verify API Gateway
aws apigateway get-rest-apis \
  --query "items[?contains(name, 'idp')].[name,id]" \
  --output table

# Get API endpoint
API_ID=$(terraform output -raw api_gateway_id)
echo "API Endpoint: https://${API_ID}.execute-api.us-east-1.amazonaws.com/v1"
```

## Phase 6: AI Services Configuration

Configure AWS AI services for document processing.

### Amazon Textract Configuration

Configure Textract for document analysis.

```bash
# Test Textract with sample document
aws textract analyze-document \
  --document '{"S3Object":{"Bucket":"idp-documents-production","Name":"samples/sample-invoice.pdf"}}' \
  --feature-types '["FORMS","TABLES"]' \
  --query "Blocks[?BlockType=='KEY_VALUE_SET']"
```

### Amazon Comprehend Configuration

Configure Comprehend for entity extraction and PII detection.

```bash
# Test entity detection
aws comprehend detect-entities \
  --language-code en \
  --text "Invoice #12345 from Acme Corp for $5,000"

# Test PII detection
aws comprehend detect-pii-entities \
  --language-code en \
  --text "John Smith, SSN 123-45-6789, john@example.com"
```

### Amazon A2I Configuration (Human Review)

Configure Amazon A2I for human review workflows.

```bash
# Navigate to Python scripts
cd delivery/scripts/python/

# Activate virtual environment
source venv/bin/activate

# Configure A2I human task UI
python3 configure_a2i.py \
  --environment production \
  --workforce private \
  --review-threshold 0.85

# Create A2I flow definition
python3 create_flow_definition.py \
  --environment production \
  --task-type document-review
```

### AI Services Validation

```bash
# Test end-to-end document processing
python3 test_pipeline.py \
  --document samples/sample-invoice.pdf \
  --expected-type invoice

# Verify extraction accuracy
python3 validate_extraction.py \
  --test-data samples/test-documents/ \
  --expected-results samples/expected-results.json
```

## Phase 7: Monitoring Layer

Deploy CloudWatch monitoring and alerting.

### Monitoring Components

- CloudWatch dashboard for IDP metrics
- CloudWatch alarms for critical metrics
- CloudWatch Logs for Lambda and API Gateway
- X-Ray tracing for distributed debugging

### Deployment Steps

```bash
# Apply monitoring infrastructure
./deploy.sh apply
```

### Monitoring Validation

```bash
# Verify CloudWatch dashboard
aws cloudwatch list-dashboards \
  --query "DashboardEntries[?contains(DashboardName, 'idp')].[DashboardName]" \
  --output table

# Verify alarms configured
aws cloudwatch describe-alarms \
  --alarm-name-prefix "idp" \
  --query "MetricAlarms[*].[AlarmName,StateValue]" \
  --output table
```

# Application Configuration

This section covers post-infrastructure configuration for the IDP pipeline.

## Pipeline Configuration

Configure the document processing pipeline.

### Step Functions Workflow

The processing workflow includes the following steps.

1. **Document Validation:** Validate document format and size
2. **OCR Processing:** Extract text using Textract
3. **Entity Extraction:** Extract entities using Comprehend
4. **PII Detection:** Detect and redact PII using Comprehend
5. **Confidence Check:** Evaluate confidence against threshold (85%)
6. **Human Review:** Route low-confidence documents to A2I
7. **Results Storage:** Store results in DynamoDB and S3
8. **Notification:** Send completion notification via SNS

### Configuration Deployment

```bash
# Navigate to Python scripts
cd delivery/scripts/python/

# Configure pipeline settings
python3 configure.py \
  --environment production \
  --component pipeline \
  --config-file config/pipeline-config.json

# Validate configuration
python3 validate.py \
  --environment production \
  --test-suite configuration
```

## API Configuration

Configure API Gateway and authentication.

### API Endpoints

The following API endpoints are deployed.

<!-- TABLE_CONFIG: widths=[15, 35, 20, 30] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /v1/documents | Cognito JWT | Upload document for processing |
| GET | /v1/documents/{id} | Cognito JWT | Get document status and results |
| GET | /v1/documents/{id}/extractions | Cognito JWT | Get extracted data |
| GET | /v1/documents | Cognito JWT | List documents |
| DELETE | /v1/documents/{id} | Cognito JWT | Delete document |

### API Testing

```bash
# Get API endpoint
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Get authentication token
TOKEN=$(aws cognito-idp admin-initiate-auth \
  --user-pool-id $USER_POOL_ID \
  --client-id $CLIENT_ID \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=test,PASSWORD=TestPass123! \
  --query "AuthenticationResult.IdToken" --output text)

# Test document upload
curl -X POST "${API_ENDPOINT}/documents" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"document_name":"test.pdf","content_type":"application/pdf"}'

# Test document status
curl -X GET "${API_ENDPOINT}/documents/{document_id}" \
  -H "Authorization: Bearer ${TOKEN}"
```

# Integration Testing

This section covers integration testing procedures.

## Test Environment Preparation

Prepare test data and environment.

```bash
# Navigate to Python scripts
cd delivery/scripts/python/

# Load test documents
python3 configure.py \
  --environment production \
  --component test-data \
  --action load

# Verify test data loaded
aws s3 ls s3://idp-documents-production/test-data/
```

## Integration Test Execution

### Functional Tests

```bash
# Execute functional tests
python3 validate.py \
  --environment production \
  --test-suite functional \
  --verbose \
  --report

# Review results
cat reports/functional-test-results.json | jq '.summary'
```

### AI Service Accuracy Tests

```bash
# Test Textract extraction accuracy
python3 validate.py \
  --environment production \
  --test-suite textract-accuracy \
  --document-types invoice,contract,form

# Test Comprehend entity extraction
python3 validate.py \
  --environment production \
  --test-suite comprehend-accuracy
```

### Performance Tests

```bash
# Execute load test
python3 validate.py \
  --environment production \
  --test-suite performance \
  --documents 100 \
  --duration 3600 \
  --report

# Review performance metrics
cat reports/performance-test-results.json | jq '.latency_p95'
```

## Test Success Criteria

Complete this checklist before proceeding.

- [ ] All functional tests passing (> 95% pass rate)
- [ ] Textract extraction accuracy > 95%
- [ ] Comprehend entity extraction accuracy > 90%
- [ ] Processing latency < 30 seconds p95
- [ ] No critical security findings
- [ ] API response time < 2 seconds
- [ ] A2I human review workflow operational

# Security Validation

This section covers security validation procedures.

## Security Scan Execution

### Infrastructure Security Scan

```bash
# Navigate to Terraform directory
cd delivery/scripts/terraform/

# Run tfsec scan
tfsec . --minimum-severity MEDIUM --format json > reports/tfsec-results.json

# Review critical findings
cat reports/tfsec-results.json | jq '.results[] | select(.severity == "CRITICAL")'
```

### IAM Policy Validation

```bash
# Verify least privilege policies
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::${ACCOUNT_ID}:role/idp-lambda-role \
  --action-names s3:* \
  --resource-arns arn:aws:s3:::*

# Check for overly permissive policies
python3 validate.py \
  --environment production \
  --test-suite iam-security
```

## Compliance Validation

### Encryption Validation

```bash
# Verify S3 encryption
aws s3api get-bucket-encryption --bucket idp-documents-production

# Verify DynamoDB encryption
aws dynamodb describe-table \
  --table-name idp-documents \
  --query "Table.SSEDescription"

# Verify Lambda environment encryption
aws lambda get-function-configuration \
  --function-name idp-document-processor \
  --query "KMSKeyArn"
```

### Audit Logging Validation

```bash
# Verify CloudTrail enabled
aws cloudtrail describe-trails \
  --query "trailList[?Name=='idp-audit-trail']"

# Verify API Gateway access logging
aws apigateway get-stage \
  --rest-api-id $API_ID \
  --stage-name v1 \
  --query "accessLogSettings"
```

## Security Validation Checklist

- [ ] Infrastructure security scan completed
- [ ] No critical vulnerabilities identified
- [ ] All data encrypted at rest (S3, DynamoDB)
- [ ] All data encrypted in transit (TLS 1.2+)
- [ ] IAM roles follow least privilege
- [ ] CloudTrail logging enabled
- [ ] VPC Flow Logs enabled
- [ ] No secrets in code or configuration

# Migration & Cutover

This section covers production cutover procedures.

## Pre-Migration Checklist

- [ ] All infrastructure deployed and validated
- [ ] AI services achieving target accuracy (95%+)
- [ ] All integration tests passing
- [ ] Security validation completed
- [ ] Rollback plan documented
- [ ] Stakeholder approval obtained
- [ ] Maintenance window scheduled

## Production Cutover

### DNS and API Cutover

```bash
# Update DNS to point to new API Gateway (if applicable)
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://dns-cutover.json

# Verify DNS propagation
dig api.idp.company.com +short
```

### Traffic Validation

```bash
# Monitor API Gateway metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiName,Value=idp-api \
  --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 60 \
  --statistics Sum

# Check application health
curl -s "${API_ENDPOINT}/health" | jq
```

## Rollback Procedures

If critical issues are identified, execute rollback.

```bash
# Revert DNS to previous infrastructure (if applicable)
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://dns-rollback.json

# Rollback Lambda functions
aws lambda update-alias \
  --function-name idp-document-processor \
  --name live \
  --function-version $PREVIOUS_VERSION

# Verify rollback successful
curl -s "${API_ENDPOINT}/health" | jq
```

# Operational Handover

This section covers the transition to ongoing operations.

## Monitoring Dashboard Access

### CloudWatch Dashboard

```bash
# Get dashboard URL
DASHBOARD_URL="https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=idp-production"
echo "Dashboard URL: ${DASHBOARD_URL}"
```

### Key Metrics to Monitor

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Processing Latency | > 30s p95 | Warning | Investigate pipeline |
| Extraction Accuracy | < 90% | Warning | Review samples |
| Lambda Errors | > 5% | Critical | Check logs |
| API 5xx Errors | > 1% | Critical | Immediate investigation |
| Queue Depth | > 500 | Warning | Scale resources |

## Support Transition

### Support Model

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | Initial triage, known issues | Client Help Desk | 15 minutes |
| L2 | Technical troubleshooting | Client IT Support | 1 hour |
| L3 | Complex issues, AI problems | Vendor Support | 4 hours |
| L4 | Engineering escalation | Vendor Engineering | Next business day |

### Escalation Contacts

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Technical Lead | [NAME] | tech@company.com | [PHONE] |
| Project Manager | [NAME] | pm@company.com | [PHONE] |
| Emergency | On-Call | oncall@company.com | [PHONE] |

# Training Program

This section documents the training program for the IDP solution.

## Training Overview

Training ensures all user groups achieve competency with the IDP solution.

### Training Schedule

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | IDP Architecture Overview | Administrators | 2 | ILT | None |
| TRN-002 | AWS AI Services Overview | IT Team | 3 | Hands-On | TRN-001 |
| TRN-003 | Infrastructure Management | DevOps | 3 | Hands-On | TRN-001 |
| TRN-004 | Human Review Workflow | Reviewers | 2 | Hands-On | None |
| TRN-005 | API Integration | Developers | 2 | Hands-On | TRN-001 |
| TRN-006 | Monitoring & Troubleshooting | IT Support | 2 | ILT | TRN-003 |
| TRN-007 | End User Training | Business Users | 1 | VILT | None |

## Training Materials

The following training materials are provided.

- Quick Start Guide (one-page reference)
- API Documentation with examples
- Administrator Guide (technical reference)
- Video recordings of training sessions
- Hands-on lab exercises
- FAQ document

# Appendices

## Appendix A: Environment Reference

### Production Environment

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Parameter | Value | Description |
|-----------|-------|-------------|
| Environment Name | production | Primary production environment |
| AWS Region | us-east-1 | Primary deployment region |
| VPC CIDR | 10.0.0.0/16 | Virtual network address space |
| Lambda Concurrency | 50 reserved | Reserved concurrent executions |
| API Rate Limit | 100 req/min | Per-client throttling |

## Appendix B: Troubleshooting Guide

### Common Issues and Resolutions

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| Textract timeout | Large document | Split document or use async API |
| Low accuracy | Poor document quality | Improve scan quality, adjust confidence threshold |
| Lambda timeout | Complex document | Increase timeout or optimize code |
| API 429 errors | Rate limiting | Request quota increase |
| A2I task not created | Configuration error | Verify flow definition and workforce |

### Diagnostic Commands

```bash
# Check Lambda errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/idp-document-processor \
  --filter-pattern "ERROR"

# Check Step Functions executions
aws stepfunctions list-executions \
  --state-machine-arn $STATE_MACHINE_ARN \
  --status-filter FAILED

# Check API Gateway errors
aws logs filter-log-events \
  --log-group-name /aws/api-gateway/idp-api \
  --filter-pattern "5"

# Check A2I human tasks
aws sagemaker-a2i-runtime list-human-loops \
  --flow-definition-arn $FLOW_DEFINITION_ARN
```

## Appendix C: AWS Service Limits

### Relevant Service Quotas

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Service | Quota | Default | Recommended |
|---------|-------|---------|-------------|
| Lambda Concurrent Executions | L-B99A9384 | 1,000 | 500 |
| Textract API TPS | L-E2B3C7F0 | 10 | 25 |
| Comprehend API TPS | L-34BEDC5F | 25 | 50 |
| API Gateway TPS | L-8A5B8E43 | 10,000 | 10,000 |
| A2I Human Loops | N/A | 100 concurrent | 100 |
