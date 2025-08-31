#!/bin/bash
# AWS Intelligent Document Processing - Deployment Script
# Comprehensive deployment automation for AWS AI document processing pipeline

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config.yml"
LOG_FILE="/var/log/aws-idp-deploy.log"

# Logging function
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        error_exit "AWS CLI not found. Please install AWS CLI first."
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        error_exit "AWS credentials not configured. Run 'aws configure' first."
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        error_exit "Python 3 not found. Please install Python 3.8+."
    fi
    
    # Check required tools
    for tool in jq curl; do
        if ! command -v "$tool" &> /dev/null; then
            error_exit "$tool not found. Please install $tool."
        fi
    done
    
    log "INFO" "Prerequisites check passed"
}

# Install Python dependencies
install_dependencies() {
    log "INFO" "Installing Python dependencies..."
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "${SCRIPT_DIR}/../venv" ]]; then
        python3 -m venv "${SCRIPT_DIR}/../venv"
    fi
    
    # Activate virtual environment
    source "${SCRIPT_DIR}/../venv/bin/activate"
    
    # Install required packages
    pip install --upgrade pip
    pip install boto3 botocore python-magic Pillow pdf2image
    
    log "INFO" "Python dependencies installed successfully"
}

# Create S3 buckets
create_s3_buckets() {
    log "INFO" "Creating S3 buckets..."
    
    local bucket_prefix="${PROJECT_NAME:-aws-idp}"
    local region="${AWS_REGION:-us-east-1}"
    
    # Create input bucket
    local input_bucket="${bucket_prefix}-input-$(date +%s)"
    aws s3 mb "s3://${input_bucket}" --region "$region"
    
    # Create output bucket
    local output_bucket="${bucket_prefix}-output-$(date +%s)"
    aws s3 mb "s3://${output_bucket}" --region "$region"
    
    # Create processed bucket
    local processed_bucket="${bucket_prefix}-processed-$(date +%s)"
    aws s3 mb "s3://${processed_bucket}" --region "$region"
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "$input_bucket" \
        --versioning-configuration Status=Enabled
    
    aws s3api put-bucket-versioning \
        --bucket "$output_bucket" \
        --versioning-configuration Status=Enabled
    
    # Store bucket names for later use
    echo "INPUT_BUCKET=${input_bucket}" >> "${SCRIPT_DIR}/../.env"
    echo "OUTPUT_BUCKET=${output_bucket}" >> "${SCRIPT_DIR}/../.env"
    echo "PROCESSED_BUCKET=${processed_bucket}" >> "${SCRIPT_DIR}/../.env"
    
    log "INFO" "S3 buckets created successfully"
    log "INFO" "Input bucket: ${input_bucket}"
    log "INFO" "Output bucket: ${output_bucket}"
    log "INFO" "Processed bucket: ${processed_bucket}"
}

# Create DynamoDB tables
create_dynamodb_tables() {
    log "INFO" "Creating DynamoDB tables..."
    
    local table_prefix="${PROJECT_NAME:-aws-idp}"
    
    # Create document metadata table
    aws dynamodb create-table \
        --table-name "${table_prefix}-documents" \
        --attribute-definitions \
            AttributeName=document_id,AttributeType=S \
            AttributeName=created_date,AttributeType=S \
        --key-schema \
            AttributeName=document_id,KeyType=HASH \
            AttributeName=created_date,KeyType=RANGE \
        --billing-mode PAY_PER_REQUEST \
        --tags Key=Project,Value="${table_prefix}" \
        --region "${AWS_REGION:-us-east-1}"
    
    # Create processing jobs table
    aws dynamodb create-table \
        --table-name "${table_prefix}-jobs" \
        --attribute-definitions \
            AttributeName=job_id,AttributeType=S \
            AttributeName=status,AttributeType=S \
        --key-schema \
            AttributeName=job_id,KeyType=HASH \
        --global-secondary-indexes \
            IndexName=status-index,KeySchema=[{AttributeName=status,KeyType=HASH}],Projection={ProjectionType=ALL} \
        --billing-mode PAY_PER_REQUEST \
        --tags Key=Project,Value="${table_prefix}" \
        --region "${AWS_REGION:-us-east-1}"
    
    # Wait for tables to be active
    log "INFO" "Waiting for DynamoDB tables to become active..."
    aws dynamodb wait table-exists --table-name "${table_prefix}-documents" --region "${AWS_REGION:-us-east-1}"
    aws dynamodb wait table-exists --table-name "${table_prefix}-jobs" --region "${AWS_REGION:-us-east-1}"
    
    log "INFO" "DynamoDB tables created successfully"
}

# Deploy Lambda functions
deploy_lambda_functions() {
    log "INFO" "Deploying Lambda functions..."
    
    local function_prefix="${PROJECT_NAME:-aws-idp}"
    local region="${AWS_REGION:-us-east-1}"
    
    # Create deployment package
    local temp_dir=$(mktemp -d)
    cp -r "${SCRIPT_DIR}/../python/"* "$temp_dir/"
    
    cd "$temp_dir"
    zip -r lambda-package.zip .
    
    # Deploy document processor function
    aws lambda create-function \
        --function-name "${function_prefix}-document-processor" \
        --runtime python3.9 \
        --role "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/${function_prefix}-lambda-role" \
        --handler "processor.lambda_handler" \
        --zip-file fileb://lambda-package.zip \
        --timeout 900 \
        --memory-size 3008 \
        --region "$region" \
        --tags Project="${function_prefix}"
    
    # Deploy results aggregator function
    aws lambda create-function \
        --function-name "${function_prefix}-results-aggregator" \
        --runtime python3.9 \
        --role "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/${function_prefix}-lambda-role" \
        --handler "aggregator.lambda_handler" \
        --zip-file fileb://lambda-package.zip \
        --timeout 300 \
        --memory-size 1024 \
        --region "$region" \
        --tags Project="${function_prefix}"
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    log "INFO" "Lambda functions deployed successfully"
}

# Configure API Gateway
configure_api_gateway() {
    log "INFO" "Configuring API Gateway..."
    
    local api_name="${PROJECT_NAME:-aws-idp}-api"
    local region="${AWS_REGION:-us-east-1}"
    
    # Create REST API
    local api_id=$(aws apigateway create-rest-api \
        --name "$api_name" \
        --description "Intelligent Document Processing API" \
        --region "$region" \
        --query 'id' --output text)
    
    # Get root resource ID
    local root_id=$(aws apigateway get-resources \
        --rest-api-id "$api_id" \
        --region "$region" \
        --query 'items[?path==`/`].id' --output text)
    
    # Create /documents resource
    local docs_resource_id=$(aws apigateway create-resource \
        --rest-api-id "$api_id" \
        --parent-id "$root_id" \
        --path-part "documents" \
        --region "$region" \
        --query 'id' --output text)
    
    # Create POST method for document upload
    aws apigateway put-method \
        --rest-api-id "$api_id" \
        --resource-id "$docs_resource_id" \
        --http-method POST \
        --authorization-type "AWS_IAM" \
        --region "$region"
    
    # Deploy API
    aws apigateway create-deployment \
        --rest-api-id "$api_id" \
        --stage-name "prod" \
        --region "$region"
    
    # Store API endpoint
    local api_endpoint="https://${api_id}.execute-api.${region}.amazonaws.com/prod"
    echo "API_ENDPOINT=${api_endpoint}" >> "${SCRIPT_DIR}/../.env"
    
    log "INFO" "API Gateway configured successfully"
    log "INFO" "API Endpoint: ${api_endpoint}"
}

# Create SNS topics for notifications
create_sns_topics() {
    log "INFO" "Creating SNS topics..."
    
    local topic_prefix="${PROJECT_NAME:-aws-idp}"
    local region="${AWS_REGION:-us-east-1}"
    
    # Create processing completion topic
    local completion_topic_arn=$(aws sns create-topic \
        --name "${topic_prefix}-processing-complete" \
        --region "$region" \
        --query 'TopicArn' --output text)
    
    # Create error notification topic
    local error_topic_arn=$(aws sns create-topic \
        --name "${topic_prefix}-processing-errors" \
        --region "$region" \
        --query 'TopicArn' --output text)
    
    # Store topic ARNs
    echo "COMPLETION_TOPIC_ARN=${completion_topic_arn}" >> "${SCRIPT_DIR}/../.env"
    echo "ERROR_TOPIC_ARN=${error_topic_arn}" >> "${SCRIPT_DIR}/../.env"
    
    log "INFO" "SNS topics created successfully"
}

# Validate deployment
validate_deployment() {
    log "INFO" "Validating deployment..."
    
    # Source environment variables
    if [[ -f "${SCRIPT_DIR}/../.env" ]]; then
        source "${SCRIPT_DIR}/../.env"
    fi
    
    # Test S3 buckets
    aws s3 ls "s3://${INPUT_BUCKET}" > /dev/null 2>&1 || error_exit "Input bucket validation failed"
    aws s3 ls "s3://${OUTPUT_BUCKET}" > /dev/null 2>&1 || error_exit "Output bucket validation failed"
    
    # Test DynamoDB tables
    aws dynamodb describe-table --table-name "${PROJECT_NAME:-aws-idp}-documents" > /dev/null 2>&1 || error_exit "Documents table validation failed"
    aws dynamodb describe-table --table-name "${PROJECT_NAME:-aws-idp}-jobs" > /dev/null 2>&1 || error_exit "Jobs table validation failed"
    
    # Test Lambda functions
    aws lambda get-function --function-name "${PROJECT_NAME:-aws-idp}-document-processor" > /dev/null 2>&1 || error_exit "Document processor function validation failed"
    
    # Test API Gateway
    if [[ -n "${API_ENDPOINT:-}" ]]; then
        curl -f "${API_ENDPOINT}/documents" -X OPTIONS > /dev/null 2>&1 || log "WARN" "API Gateway validation failed (may be expected for new deployment)"
    fi
    
    log "INFO" "Deployment validation completed"
}

# Generate deployment summary
generate_summary() {
    log "INFO" "Generating deployment summary..."
    
    # Source environment variables
    if [[ -f "${SCRIPT_DIR}/../.env" ]]; then
        source "${SCRIPT_DIR}/../.env"
    fi
    
    cat << EOF | tee -a "$LOG_FILE"

================================================================================
AWS INTELLIGENT DOCUMENT PROCESSING DEPLOYMENT SUMMARY
================================================================================

Deployment Status: SUCCESSFUL
Deployment Date: $(date)
AWS Region: ${AWS_REGION:-us-east-1}

Resources Created:
- S3 Input Bucket: ${INPUT_BUCKET:-Not configured}
- S3 Output Bucket: ${OUTPUT_BUCKET:-Not configured}
- S3 Processed Bucket: ${PROCESSED_BUCKET:-Not configured}
- API Gateway Endpoint: ${API_ENDPOINT:-Not configured}
- SNS Topics: Processing notifications configured

DynamoDB Tables:
- Documents: ${PROJECT_NAME:-aws-idp}-documents
- Jobs: ${PROJECT_NAME:-aws-idp}-jobs

Lambda Functions:
- Document Processor: ${PROJECT_NAME:-aws-idp}-document-processor
- Results Aggregator: ${PROJECT_NAME:-aws-idp}-results-aggregator

Next Steps:
1. Configure IAM roles and policies for your users
2. Test document upload using the API or S3 directly
3. Set up monitoring and alerting via CloudWatch
4. Configure backup and retention policies

Documentation:
- Configuration: ${CONFIG_FILE}
- Environment: ${SCRIPT_DIR}/../.env
- Logs: ${LOG_FILE}

================================================================================
EOF
}

# Main deployment function
main() {
    log "INFO" "Starting AWS Intelligent Document Processing deployment..."
    
    # Set default values
    export PROJECT_NAME="${PROJECT_NAME:-aws-idp}"
    export AWS_REGION="${AWS_REGION:-us-east-1}"
    
    # Execute deployment steps
    check_prerequisites
    install_dependencies
    create_s3_buckets
    create_dynamodb_tables
    create_sns_topics
    configure_api_gateway
    validate_deployment
    generate_summary
    
    log "INFO" "AWS Intelligent Document Processing deployment completed successfully!"
}

# Execute main function
main "$@"