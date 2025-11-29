# Terraform Backend Bootstrap

This directory contains scripts to create the AWS resources required for Terraform remote state storage before running `terraform init`.

## Overview

Terraform remote state with S3 backend requires:
- **S3 Bucket** - Stores the state file with versioning and encryption
- **DynamoDB Table** - Provides state locking to prevent concurrent modifications

These resources must exist *before* Terraform can use them, creating a chicken-and-egg problem. The bootstrap scripts solve this by creating the backend resources using AWS CLI/SDK.

## Naming Convention

Resources are named to be globally unique and solution/environment specific:

| Resource | Pattern | Example |
|----------|---------|---------|
| S3 Bucket | `{org_prefix}-{solution_abbr}-{env}-terraform-state` | `acme-vxr-prod-terraform-state` |
| DynamoDB Table | `{org_prefix}-{solution_abbr}-{env}-terraform-locks` | `acme-vxr-prod-terraform-locks` |
| State Key | `terraform.tfstate` | `terraform.tfstate` |

## Prerequisites

1. **AWS Credentials** - Configure via `aws configure` or environment variables
2. **org_prefix** - Must be set in `environments/{env}/main.tfvars`
3. **Bash script**: AWS CLI and jq installed
4. **Python script**: Python 3.8+ and boto3 (`pip install boto3`)

## Configuration

Before running bootstrap, ensure your `main.tfvars` has the required values:

```hcl
# Required for bootstrap
solution_abbr = "vxr"           # 3-4 char abbreviation
org_prefix    = "acme"          # Organization prefix for uniqueness
aws_region    = "us-east-1"     # Target region

# Optional
aws_profile   = "mycompany"     # AWS CLI profile name
```

## Usage

### Option 1: Bash Script (Linux/macOS/WSL)

```bash
# From any directory - specify environment
./setup/setup-backend.sh prod

# From within environment directory - auto-detects
cd environments/prod
../../setup/setup-backend.sh

# Make executable first if needed
chmod +x setup/setup-backend.sh
```

### Option 2: Python Script (Cross-platform)

```bash
# Install boto3 if not present
pip install boto3

# From any directory - specify environment
python setup/setup-backend.py prod

# From within environment directory - auto-detects
cd environments/prod
python ../../setup/setup-backend.py
```

## What Gets Created

The bootstrap scripts create:

1. **S3 Bucket** with:
   - Versioning enabled
   - Server-side encryption (AES-256)
   - Public access blocked (all settings)
   - Tags for identification

2. **DynamoDB Table** with:
   - `LockID` (String) as hash key
   - Pay-per-request billing mode
   - Tags for identification

3. **backend.tfvars** file in the environment directory

## After Bootstrap

1. The script outputs the backend configuration to add to `providers.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "acme-vxr-prod-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-vxr-prod-terraform-locks"
    encrypt        = true
  }
}
```

2. Or use the generated `backend.tfvars`:

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars
```

## Idempotent Operation

Both scripts are idempotent - they can be run multiple times safely:
- Existing buckets/tables are detected and skipped
- Configuration is always applied (versioning, encryption, etc.)
- `backend.tfvars` is regenerated each run

## Multi-Environment Setup

Run bootstrap for each environment separately:

```bash
# Production (us-east-1)
./setup/setup-backend.sh prod

# Test (us-east-1, same region as prod is fine)
./setup/setup-backend.sh test

# DR (us-west-2, different region for true DR)
./setup/setup-backend.sh dr
```

Each environment gets isolated state storage.

## Cleanup

To remove backend resources (use with caution!):

```bash
# Empty the bucket first (required before deletion)
aws s3 rm s3://acme-vxr-prod-terraform-state --recursive

# Delete the bucket
aws s3api delete-bucket --bucket acme-vxr-prod-terraform-state

# Delete the DynamoDB table
aws dynamodb delete-table --table-name acme-vxr-prod-terraform-locks
```

**Warning**: Deleting state storage will lose all Terraform state. Ensure you have backups and no active infrastructure before cleanup.

## Troubleshooting

### "org_prefix not found or empty"
Set `org_prefix` in your `main.tfvars`:
```hcl
org_prefix = "mycompany"
```

### "AWS credentials not configured"
Configure AWS CLI:
```bash
aws configure
# or
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

### "Bucket name already exists"
S3 bucket names are globally unique. Either:
- Use a more specific `org_prefix`
- The bucket may already be created (check ownership)

### Permission denied on script
```bash
chmod +x setup/setup-backend.sh
```
