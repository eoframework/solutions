# Terraform Setup

This directory contains prerequisite infrastructure that must be deployed before the main Terraform environments.

## Directory Structure

```
setup/
├── backend/           # Remote state infrastructure (S3 + DynamoDB)
│   ├── state-backend.sh
│   └── state-backend.bat
└── secrets/           # Secrets management (Secrets Manager + SSM Parameter Store)
    ├── modules/secrets/
    ├── prod/
    └── test/
```

## Deployment Sequence

Run these setup modules in order before deploying the main environments:

### Step 1: Backend (Remote State)

Creates the S3 bucket and DynamoDB table for Terraform remote state storage.

```bash
cd backend/

# Linux/macOS
./state-backend.sh prod   # For production
./state-backend.sh test   # For test

# Windows
state-backend.bat prod
state-backend.bat test
```

This generates `backend.tfvars` in each environment directory for state configuration.

### Step 2: Secrets

Provisions application secrets in AWS Secrets Manager and SSM Parameter Store.

```bash
cd secrets/prod
terraform init
terraform plan
terraform apply

cd ../test
terraform init
terraform plan
terraform apply
```

### Step 3: Main Environments

After setup is complete, deploy the main infrastructure:

```bash
cd ../../environments/prod
terraform init -backend-config=backend.tfvars
terraform plan -var-file=config/project.tfvars -var-file=config/networking.tfvars ...
terraform apply
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.6.0
- Sufficient IAM permissions for S3, DynamoDB, Secrets Manager, and SSM

## Environment Isolation

Each environment (prod, test) maintains separate:
- Remote state buckets and lock tables
- Secrets and parameter values
- Infrastructure resources

This ensures complete isolation between environments.
