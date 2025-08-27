# Scripts - AWS Intelligent Document Processing

## Overview

This directory contains automation scripts and utilities for AWS Intelligent Document Processing solution deployment, testing, and operations. Leveraging AWS AI services including Amazon Textract, Amazon Comprehend, and Amazon Bedrock for comprehensive document analysis and processing automation.

---

## Script Categories

### Infrastructure Scripts
- **cloudformation-deploy.py** - CloudFormation stack deployment with AWS CDK
- **infrastructure-setup.sh** - Complete AWS infrastructure automation
- **s3-bucket-setup.py** - S3 bucket configuration for document storage
- **lambda-deployment.sh** - Lambda function deployment automation
- **api-gateway-setup.py** - API Gateway configuration and deployment

### AI Service Configuration
- **textract-setup.py** - Amazon Textract configuration and optimization
- **comprehend-config.py** - Amazon Comprehend custom entity recognition setup
- **bedrock-model-config.py** - Amazon Bedrock model configuration and fine-tuning
- **ai-services-integration.py** - Cross-service AI workflow orchestration

### Document Processing Scripts
- **batch-processor.py** - Batch document processing automation
- **real-time-processor.py** - Real-time document processing pipeline
- **document-classifier.py** - ML-based document classification
- **extraction-pipeline.py** - Data extraction and validation pipeline

### Testing Scripts
- **document-processing-tests.py** - Comprehensive document processing validation
- **performance-testing.sh** - Load testing and performance benchmarking
- **accuracy-validation.py** - AI model accuracy testing and reporting
- **integration-tests.py** - End-to-end integration testing

### Operations Scripts
- **health-monitoring.sh** - System health checks and CloudWatch monitoring
- **cost-optimization.py** - Cost analysis and optimization recommendations
- **backup-management.sh** - Backup and disaster recovery procedures
- **log-analysis.py** - CloudWatch logs analysis and alerting

---

## Prerequisites

### Required Tools
- **AWS CLI v2.15+** - AWS command line interface
- **Python 3.9+** - Python runtime environment
- **boto3** - AWS SDK for Python
- **AWS CDK v2** - AWS Cloud Development Kit
- **jq** - JSON processor for script automation
- **curl** - HTTP client for API testing

### AWS Services Required
- Amazon S3 (document storage)
- Amazon Textract (OCR and document analysis)
- Amazon Comprehend (natural language processing)
- Amazon Bedrock (foundation models)
- AWS Lambda (serverless processing)
- Amazon API Gateway (API management)
- Amazon CloudWatch (monitoring and logging)
- AWS IAM (identity and access management)

### Python Dependencies
```bash
pip install boto3 botocore aws-cdk-lib requests pandas numpy
```

### Configuration
```bash
# Configure AWS credentials
aws configure --profile idp-production
aws configure set region us-east-1 --profile idp-production

# Set environment variables
export AWS_PROFILE=idp-production
export AWS_DEFAULT_REGION=us-east-1
export IDP_BUCKET_NAME=intelligent-document-processing-bucket
export IDP_ENVIRONMENT=production
export TEXTRACT_ROLE_ARN=arn:aws:iam::account:role/TextractServiceRole
export COMPREHEND_ENDPOINT=comprehend-custom-endpoint
```

---

## Usage Instructions

### Infrastructure Deployment
```bash
# Deploy CloudFormation infrastructure
python cloudformation-deploy.py \
  --stack-name idp-production \
  --environment production \
  --region us-east-1

# Setup complete infrastructure
./infrastructure-setup.sh \
  --environment production \
  --region us-east-1 \
  --enable-bedrock \
  --enable-comprehend

# Configure S3 buckets with proper policies
python s3-bucket-setup.py \
  --bucket-name $IDP_BUCKET_NAME \
  --enable-versioning \
  --enable-encryption

# Deploy Lambda functions
./lambda-deployment.sh \
  --functions all \
  --environment production \
  --memory 1024 \
  --timeout 300
```

### AI Services Configuration
```bash
# Configure Amazon Textract
python textract-setup.py \
  --enable-tables \
  --enable-forms \
  --enable-queries \
  --output-format json

# Setup Amazon Comprehend custom models
python comprehend-config.py \
  --train-custom-classifier \
  --document-types invoice,contract,form \
  --training-data ./training-data/

# Configure Amazon Bedrock models
python bedrock-model-config.py \
  --model-id anthropic.claude-v2 \
  --fine-tune-task document-analysis \
  --enable-guardrails
```

### Document Processing
```bash
# Process documents in batch
python batch-processor.py \
  --input-bucket $IDP_BUCKET_NAME \
  --output-bucket $IDP_BUCKET_NAME/processed \
  --document-types pdf,jpg,png \
  --max-concurrent 10

# Start real-time processing pipeline
python real-time-processor.py \
  --sqs-queue document-processing-queue \
  --enable-notifications \
  --retry-failed-docs 3

# Classify documents automatically
python document-classifier.py \
  --model-endpoint $COMPREHEND_ENDPOINT \
  --confidence-threshold 0.85 \
  --batch-size 25
```

### Testing and Validation
```bash
# Run comprehensive test suite
python document-processing-tests.py \
  --test-suite full \
  --test-data ./test-documents/ \
  --generate-report

# Performance benchmarking
./performance-testing.sh \
  --duration 600 \
  --concurrent-docs 100 \
  --document-sizes small,medium,large \
  --test-types ocr,classification,extraction

# Validate AI model accuracy
python accuracy-validation.py \
  --test-documents ./validation-docs/ \
  --ground-truth ./ground-truth.json \
  --metrics precision,recall,f1-score \
  --export-results ./validation-results.csv
```

### Operations and Monitoring
```bash
# Comprehensive health monitoring
./health-monitoring.sh \
  --check-services textract,comprehend,bedrock \
  --cloudwatch-metrics \
  --alert-thresholds ./alert-config.json

# Cost optimization analysis
python cost-optimization.py \
  --period 30-days \
  --services textract,comprehend,s3,lambda \
  --recommendations \
  --export-report ./cost-analysis.pdf

# Backup and recovery management
./backup-management.sh \
  --operation backup \
  --retention 30-days \
  --backup-models \
  --backup-configs

# Analyze processing logs
python log-analysis.py \
  --log-group /aws/lambda/document-processor \
  --time-range 24h \
  --error-patterns \
  --performance-metrics
```

---

## Directory Structure

```
scripts/
├── ansible/              # Ansible playbooks for configuration management
├── bash/                 # Shell scripts for automation
├── powershell/          # PowerShell scripts for Windows environments
├── python/              # Python scripts for AWS service integration
└── terraform/           # Terraform configurations for IaC
```

---

## Error Handling and Troubleshooting

### Common Issues

#### Textract API Rate Limits
```bash
# Monitor and handle rate limits
python textract-setup.py --enable-retry-backoff --max-retries 5
```

#### Document Processing Failures
```bash
# Reprocess failed documents
python batch-processor.py --reprocess-failed --error-log ./processing-errors.log
```

#### Cost Optimization
```bash
# Implement cost controls
python cost-optimization.py --set-budget-alerts --monthly-limit 1000
```

### Monitoring Commands
```bash
# Check service health
aws textract describe-document-text-detection --job-id <job-id>
aws comprehend describe-document-classification-job --job-id <job-id>
aws bedrock get-model-invocation-logging-configuration
```

---

## Security Best Practices

- Use IAM roles with minimal required permissions
- Enable AWS CloudTrail for audit logging
- Implement S3 bucket policies for data protection
- Use AWS KMS for encryption at rest
- Enable VPC endpoints for secure API communication

---

**Directory Version**: 2.0  
**Last Updated**: January 2025  
**Maintained By**: AWS AI Solutions DevOps Team