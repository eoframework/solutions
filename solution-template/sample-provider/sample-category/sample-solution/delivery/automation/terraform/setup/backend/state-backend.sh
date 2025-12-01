#!/bin/bash
#------------------------------------------------------------------------------
# Terraform S3 Backend Bootstrap Script
#------------------------------------------------------------------------------
# Creates AWS resources required for Terraform remote state storage:
# - S3 bucket with versioning, encryption, and public access blocking
# - DynamoDB table for state locking
#
# This script is idempotent - safe to run multiple times.
#
# Usage:
#   ./bootstrap-backend.sh [environment]
#
# Arguments:
#   environment - Optional: prod, test, or dr (auto-detected from folder if omitted)
#
# Prerequisites:
#   - AWS CLI configured with appropriate credentials
#   - jq installed (for parsing tfvars)
#
# Naming Convention:
#   S3 Bucket:      {org_prefix}-{solution_abbr}-{environment}-terraform-state
#   DynamoDB Table: {org_prefix}-{solution_abbr}-{environment}-terraform-locks
#   State Key:      terraform.tfstate
#------------------------------------------------------------------------------

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#------------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------------

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse value from tfvars file (handles quotes and comments)
parse_tfvar() {
    local file="$1"
    local var="$2"
    grep "^${var}\s*=" "$file" 2>/dev/null | sed 's/.*=\s*"\([^"]*\)".*/\1/' | head -1
}

#------------------------------------------------------------------------------
# Determine Environment
#------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENTS_DIR="$(dirname "$SCRIPT_DIR")/environments"

# Get environment from argument or auto-detect
if [ -n "$1" ]; then
    ENVIRONMENT="$1"
else
    # Try to detect from current directory
    CURRENT_DIR="$(pwd)"
    if [[ "$CURRENT_DIR" == *"/environments/prod"* ]]; then
        ENVIRONMENT="prod"
    elif [[ "$CURRENT_DIR" == *"/environments/test"* ]]; then
        ENVIRONMENT="test"
    elif [[ "$CURRENT_DIR" == *"/environments/dr"* ]]; then
        ENVIRONMENT="dr"
    else
        log_error "Cannot auto-detect environment. Please specify: prod, test, or dr"
        echo "Usage: $0 [prod|test|dr]"
        exit 1
    fi
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(prod|test|dr)$ ]]; then
    log_error "Invalid environment: $ENVIRONMENT. Must be: prod, test, or dr"
    exit 1
fi

ENV_DIR="${ENVIRONMENTS_DIR}/${ENVIRONMENT}"
CONFIG_DIR="${ENV_DIR}/config"
TFVARS_FILE="${CONFIG_DIR}/project.tfvars"

# Fallback to main.tfvars for legacy support
if [ ! -f "$TFVARS_FILE" ] && [ -f "${ENV_DIR}/main.tfvars" ]; then
    TFVARS_FILE="${ENV_DIR}/main.tfvars"
    log_warn "Using legacy main.tfvars (consider migrating to config/project.tfvars)"
fi

log_info "Environment: ${ENVIRONMENT}"
log_info "Config file: ${TFVARS_FILE}"

#------------------------------------------------------------------------------
# Read Configuration from tfvars
#------------------------------------------------------------------------------

if [ ! -f "$TFVARS_FILE" ]; then
    log_error "Configuration file not found: $TFVARS_FILE"
    log_error "Please create config/project.tfvars with required values."
    exit 1
fi

# Parse required values
SOLUTION_ABBR=$(parse_tfvar "$TFVARS_FILE" "solution_abbr")
ORG_PREFIX=$(parse_tfvar "$TFVARS_FILE" "org_prefix")
AWS_REGION=$(parse_tfvar "$TFVARS_FILE" "aws_region")
AWS_PROFILE_VAR=$(parse_tfvar "$TFVARS_FILE" "aws_profile")

# Validate required values
if [ -z "$SOLUTION_ABBR" ]; then
    log_error "solution_abbr not found in $TFVARS_FILE"
    exit 1
fi

if [ -z "$ORG_PREFIX" ]; then
    log_error "org_prefix not found or empty in $TFVARS_FILE"
    log_error "Please set org_prefix to ensure globally unique S3 bucket names."
    log_error "Example: org_prefix = \"acme\""
    exit 1
fi

if [ -z "$AWS_REGION" ]; then
    log_error "aws_region not found in $TFVARS_FILE"
    exit 1
fi

# Set AWS profile if specified
if [ -n "$AWS_PROFILE_VAR" ]; then
    export AWS_PROFILE="$AWS_PROFILE_VAR"
    log_info "Using AWS profile: $AWS_PROFILE"
fi

#------------------------------------------------------------------------------
# Generate Resource Names
#------------------------------------------------------------------------------

S3_BUCKET="${ORG_PREFIX}-${SOLUTION_ABBR}-${ENVIRONMENT}-terraform-state"
DYNAMODB_TABLE="${ORG_PREFIX}-${SOLUTION_ABBR}-${ENVIRONMENT}-terraform-locks"

log_info "S3 Bucket: ${S3_BUCKET}"
log_info "DynamoDB Table: ${DYNAMODB_TABLE}"
log_info "AWS Region: ${AWS_REGION}"

#------------------------------------------------------------------------------
# Verify AWS Credentials
#------------------------------------------------------------------------------

log_info "Verifying AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    log_error "AWS credentials not configured or invalid"
    log_error "Please configure AWS CLI: aws configure"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
log_success "AWS Account: ${ACCOUNT_ID}"

#------------------------------------------------------------------------------
# Create S3 Bucket
#------------------------------------------------------------------------------

log_info "Creating S3 bucket: ${S3_BUCKET}..."

# Check if bucket exists
if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
    log_warn "S3 bucket already exists: ${S3_BUCKET}"
else
    # Create bucket (different syntax for us-east-1)
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$S3_BUCKET" \
            --region "$AWS_REGION"
    else
        aws s3api create-bucket \
            --bucket "$S3_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi
    log_success "S3 bucket created: ${S3_BUCKET}"
fi

# Enable versioning
log_info "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket "$S3_BUCKET" \
    --versioning-configuration Status=Enabled
log_success "Versioning enabled"

# Enable server-side encryption (AES-256)
log_info "Enabling server-side encryption..."
aws s3api put-bucket-encryption \
    --bucket "$S3_BUCKET" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            },
            "BucketKeyEnabled": true
        }]
    }'
log_success "Encryption enabled (AES-256)"

# Block all public access
log_info "Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$S3_BUCKET" \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'
log_success "Public access blocked"

# Add tags
log_info "Adding tags to S3 bucket..."
aws s3api put-bucket-tagging \
    --bucket "$S3_BUCKET" \
    --tagging "TagSet=[
        {Key=Name,Value=${S3_BUCKET}},
        {Key=Environment,Value=${ENVIRONMENT}},
        {Key=Solution,Value=${SOLUTION_ABBR}},
        {Key=Purpose,Value=terraform-state},
        {Key=ManagedBy,Value=bootstrap-script}
    ]"
log_success "Tags applied"

#------------------------------------------------------------------------------
# Create DynamoDB Table
#------------------------------------------------------------------------------

log_info "Creating DynamoDB table: ${DYNAMODB_TABLE}..."

# Check if table exists
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" > /dev/null 2>&1; then
    log_warn "DynamoDB table already exists: ${DYNAMODB_TABLE}"
else
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION" \
        --tags \
            Key=Name,Value="$DYNAMODB_TABLE" \
            Key=Environment,Value="$ENVIRONMENT" \
            Key=Solution,Value="$SOLUTION_ABBR" \
            Key=Purpose,Value=terraform-locks \
            Key=ManagedBy,Value=bootstrap-script

    log_info "Waiting for DynamoDB table to become active..."
    aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION"
    log_success "DynamoDB table created: ${DYNAMODB_TABLE}"
fi

#------------------------------------------------------------------------------
# Output Backend Configuration
#------------------------------------------------------------------------------

echo ""
echo "=============================================================================="
echo -e "${GREEN}Bootstrap Complete!${NC}"
echo "=============================================================================="
echo ""
echo "Add the following backend configuration to your providers.tf:"
echo ""
echo -e "${YELLOW}terraform {${NC}"
echo -e "${YELLOW}  backend \"s3\" {${NC}"
echo -e "${YELLOW}    bucket         = \"${S3_BUCKET}\"${NC}"
echo -e "${YELLOW}    key            = \"terraform.tfstate\"${NC}"
echo -e "${YELLOW}    region         = \"${AWS_REGION}\"${NC}"
echo -e "${YELLOW}    dynamodb_table = \"${DYNAMODB_TABLE}\"${NC}"
echo -e "${YELLOW}    encrypt        = true${NC}"
echo -e "${YELLOW}  }${NC}"
echo -e "${YELLOW}}${NC}"
echo ""
echo "Or add to ${ENV_DIR}/backend.tfvars:"
echo ""
echo "bucket         = \"${S3_BUCKET}\""
echo "key            = \"terraform.tfstate\""
echo "region         = \"${AWS_REGION}\""
echo "dynamodb_table = \"${DYNAMODB_TABLE}\""
echo "encrypt        = true"
echo ""
echo "Then initialize with: terraform init -backend-config=backend.tfvars"
echo "=============================================================================="

# Create backend.tfvars file
BACKEND_FILE="${ENV_DIR}/backend.tfvars"
log_info "Creating backend configuration file: ${BACKEND_FILE}"

cat > "$BACKEND_FILE" << EOF
#------------------------------------------------------------------------------
# Terraform Backend Configuration
#------------------------------------------------------------------------------
# Generated by bootstrap-backend.sh
# Use with: terraform init -backend-config=backend.tfvars
#------------------------------------------------------------------------------

bucket         = "${S3_BUCKET}"
key            = "terraform.tfstate"
region         = "${AWS_REGION}"
dynamodb_table = "${DYNAMODB_TABLE}"
encrypt        = true
EOF

log_success "Backend configuration saved to: ${BACKEND_FILE}"
