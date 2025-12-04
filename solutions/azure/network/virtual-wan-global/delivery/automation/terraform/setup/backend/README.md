# Terraform Backend Setup

This directory contains scripts to set up Azure Storage backend for Terraform state management.

## Prerequisites

- Azure CLI installed and configured
- Appropriate permissions to create resources in Azure subscription
- Bash shell environment

## Usage

### Create Backend for Production Environment

```bash
cd setup/backend
./state-backend.sh prod
```

### Create Backend for Test Environment

```bash
cd setup/backend
./state-backend.sh test
```

### Create Backend for DR Environment

```bash
cd setup/backend
./state-backend.sh dr
```

## What Gets Created

The script creates:

1. **Resource Group**: `tfstate-{env}-rg`
2. **Storage Account**: `tfstate{random-suffix}`
3. **Blob Container**: `tfstate`
4. **Backend Config**: `environments/{env}/backend.tfvars`

## Next Steps

After running the backend setup:

1. Navigate to the environment directory:
   ```bash
   cd ../../environments/{env}
   ```

2. Initialize Terraform with the backend configuration:
   ```bash
   terraform init -backend-config=backend.tfvars
   ```

3. Apply the configuration:
   ```bash
   terraform apply -var-file=config/project.tfvars \
                   -var-file=config/vwan.tfvars \
                   -var-file=config/connectivity.tfvars \
                   -var-file=config/security.tfvars \
                   -var-file=config/monitoring.tfvars
   ```

## Security Notes

- The storage account uses TLS 1.2 minimum
- Blob encryption is enabled by default
- Access keys are not stored in version control
- Backend state files contain sensitive information - ensure proper access controls
