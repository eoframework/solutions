#!/bin/bash

# Initialize AWS S3 Backend for Terraform State Management
# This script creates the necessary AWS infrastructure to store Terraform state files

set -e

# Configuration
PROJECT_NAME="${1:-my-enterprise-project}"
REGION="${2:-us-east-1}"
PROFILE="${3:-default}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message $BLUE "🚀 Initializing AWS Backend for Terraform State Management"
print_message $YELLOW "Project: $PROJECT_NAME"
print_message $YELLOW "Region: $REGION"
print_message $YELLOW "Profile: $PROFILE"
echo

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_message $RED "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Verify AWS credentials
print_message $BLUE "🔍 Verifying AWS credentials..."
if ! aws sts get-caller-identity --profile $PROFILE > /dev/null 2>&1; then
    print_message $RED "❌ AWS credentials not configured for profile: $PROFILE"
    print_message $YELLOW "Please run: aws configure --profile $PROFILE"
    exit 1
fi
print_message $GREEN "✅ AWS credentials verified"

# Create S3 bucket for state storage
BUCKET_NAME="${PROJECT_NAME}-terraform-state-${REGION}"
print_message $BLUE "📦 Creating S3 bucket: $BUCKET_NAME"

# Check if bucket already exists
if aws s3api head-bucket --bucket $BUCKET_NAME --profile $PROFILE 2>/dev/null; then
    print_message $YELLOW "⚠️  Bucket $BUCKET_NAME already exists"
else
    # Create bucket
    if [ "$REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --profile $PROFILE
    else
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --region $REGION \
            --create-bucket-configuration LocationConstraint=$REGION \
            --profile $PROFILE
    fi

    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket $BUCKET_NAME \
        --versioning-configuration Status=Enabled \
        --profile $PROFILE

    # Enable server-side encryption
    aws s3api put-bucket-encryption \
        --bucket $BUCKET_NAME \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }' \
        --profile $PROFILE

    # Block public access
    aws s3api put-public-access-block \
        --bucket $BUCKET_NAME \
        --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
        --profile $PROFILE

    print_message $GREEN "✅ S3 bucket created and configured"
fi

# Create DynamoDB table for state locking
TABLE_NAME="${PROJECT_NAME}-terraform-locks"
print_message $BLUE "🔒 Creating DynamoDB table: $TABLE_NAME"

# Check if table already exists
if aws dynamodb describe-table --table-name $TABLE_NAME --profile $PROFILE --region $REGION > /dev/null 2>&1; then
    print_message $YELLOW "⚠️  DynamoDB table $TABLE_NAME already exists"
else
    aws dynamodb create-table \
        --table-name $TABLE_NAME \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --profile $PROFILE \
        --region $REGION

    # Wait for table to be created
    print_message $YELLOW "⏳ Waiting for DynamoDB table to be created..."
    aws dynamodb wait table-exists --table-name $TABLE_NAME --profile $PROFILE --region $REGION
    print_message $GREEN "✅ DynamoDB table created"
fi

# Generate backend configuration files
print_message $BLUE "📄 Generating backend configuration files..."

# Production backend config
cat > ../environments/production/backend.hcl << EOF
bucket         = "$BUCKET_NAME"
key            = "production/terraform.tfstate"
region         = "$REGION"
profile        = "$PROFILE"
dynamodb_table = "$TABLE_NAME"
encrypt        = true
EOF

# Disaster Recovery backend config
cat > ../environments/disaster-recovery/backend.hcl << EOF
bucket         = "$BUCKET_NAME"
key            = "disaster-recovery/terraform.tfstate"
region         = "$REGION"
profile        = "$PROFILE"
dynamodb_table = "$TABLE_NAME"
encrypt        = true
EOF

# Test backend config
cat > ../environments/test/backend.hcl << EOF
bucket         = "$BUCKET_NAME"
key            = "test/terraform.tfstate"
region         = "$REGION"
profile        = "$PROFILE"
dynamodb_table = "$TABLE_NAME"
encrypt        = true
EOF

print_message $GREEN "✅ Backend configuration files generated"

# Create initialization script for each environment
cat > init-production.sh << 'EOF'
#!/bin/bash
cd ../environments/production
terraform init -backend-config=backend.hcl
EOF

cat > init-disaster-recovery.sh << 'EOF'
#!/bin/bash
cd ../environments/disaster-recovery
terraform init -backend-config=backend.hcl
EOF

cat > init-test.sh << 'EOF'
#!/bin/bash
cd ../environments/test
terraform init -backend-config=backend.hcl
EOF

chmod +x init-*.sh

print_message $GREEN "✅ Environment initialization scripts created"

echo
print_message $GREEN "🎉 AWS Backend Setup Complete!"
print_message $BLUE "Next steps:"
echo "1. Run ./init-production.sh to initialize production environment"
echo "2. Run ./init-disaster-recovery.sh to initialize disaster recovery environment"
echo "3. Run ./init-test.sh to initialize test environment"
echo
print_message $YELLOW "Resources created:"
echo "📦 S3 Bucket: $BUCKET_NAME"
echo "🔒 DynamoDB Table: $TABLE_NAME"
echo "📄 Backend config files in each environment directory"