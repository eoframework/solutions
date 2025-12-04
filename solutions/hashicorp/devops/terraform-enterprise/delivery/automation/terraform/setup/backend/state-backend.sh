#!/bin/bash
#------------------------------------------------------------------------------
# State Backend Setup Script - Terraform Enterprise
#------------------------------------------------------------------------------
# Creates S3 buckets and DynamoDB tables for Terraform state management
#------------------------------------------------------------------------------
set -e

SOLUTION_ABBR="tfe"
ENVIRONMENTS=("prod" "test" "dr")
PRIMARY_REGION="us-east-1"
DR_REGION="us-west-2"

echo "Setting up Terraform state backends for ${SOLUTION_ABBR}..."

for ENV in "${ENVIRONMENTS[@]}"; do
    BUCKET_NAME="${SOLUTION_ABBR}-${ENV}-tfstate"
    LOCK_TABLE="${SOLUTION_ABBR}-${ENV}-tflock"

    # Determine region
    if [ "$ENV" = "dr" ]; then
        REGION="${DR_REGION}"
    else
        REGION="${PRIMARY_REGION}"
    fi

    echo "Creating backend for ${ENV} in ${REGION}..."

    # Create S3 bucket
    if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
        echo "  Bucket ${BUCKET_NAME} already exists"
    else
        aws s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${REGION}" \
            $([ "$REGION" != "us-east-1" ] && echo "--create-bucket-configuration LocationConstraint=${REGION}")

        # Enable versioning
        aws s3api put-bucket-versioning \
            --bucket "${BUCKET_NAME}" \
            --versioning-configuration Status=Enabled

        # Enable encryption
        aws s3api put-bucket-encryption \
            --bucket "${BUCKET_NAME}" \
            --server-side-encryption-configuration '{
                "Rules": [{
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "aws:kms"
                    }
                }]
            }'

        # Block public access
        aws s3api put-public-access-block \
            --bucket "${BUCKET_NAME}" \
            --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

        echo "  Created bucket ${BUCKET_NAME}"
    fi

    # Create DynamoDB table for locking
    if aws dynamodb describe-table --table-name "${LOCK_TABLE}" --region "${REGION}" 2>/dev/null; then
        echo "  Lock table ${LOCK_TABLE} already exists"
    else
        aws dynamodb create-table \
            --table-name "${LOCK_TABLE}" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --billing-mode PAY_PER_REQUEST \
            --region "${REGION}"

        echo "  Created lock table ${LOCK_TABLE}"
    fi
done

echo ""
echo "State backend setup complete!"
echo ""
echo "Backend configuration:"
for ENV in "${ENVIRONMENTS[@]}"; do
    if [ "$ENV" = "dr" ]; then
        REGION="${DR_REGION}"
    else
        REGION="${PRIMARY_REGION}"
    fi
    echo "  ${ENV}:"
    echo "    bucket         = \"${SOLUTION_ABBR}-${ENV}-tfstate\""
    echo "    key            = \"terraform.tfstate\""
    echo "    region         = \"${REGION}\""
    echo "    dynamodb_table = \"${SOLUTION_ABBR}-${ENV}-tflock\""
    echo "    encrypt        = true"
    echo ""
done
